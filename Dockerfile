# Stage 1: Build stage (Optional if built via Maven in Jenkins)
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-jammy

# Set working directory
WORKDIR /app

# Create a non-privileged system user for running the application
RUN groupadd -r spring && useradd -r -g spring spring

# Copy compiled JAR file from the builder stage
COPY --from=builder /workspace/target/spring-boot-k8s.jar app.jar

# Change ownership of application directory to spring user
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring:spring

# Expose Spring Boot application port
EXPOSE 8080

# Environment variables for JVM options
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Container healthcheck using built-in actuator
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Execute the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
