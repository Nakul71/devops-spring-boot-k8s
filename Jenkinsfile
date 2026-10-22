pipeline {
    agent any

    environment {
        // Docker registry & image configurations
        // Replace 'your-dockerhub-username' with your actual Docker Hub username
        DOCKER_REGISTRY_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_IMAGE_NAME              = 'nakul71/spring-boot-k8s'
        IMAGE_TAG                      = "${BUILD_NUMBER}"
        
        // Kubernetes credentials configuration (Configured in Jenkins Credentials)
        KUBECONFIG_CREDENTIALS_ID      = 'mykubeconfig'
        K8S_DEPLOYMENT_NAME            = 'spring-boot-k8s-deployment'
        K8S_CONTAINER_NAME             = 'spring-boot-k8s'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo '=== Stage 1: Checking out source code ==='
                checkout scm
            }
        }

        stage('Compile & Test Application') {
            steps {
                echo '=== Stage 2: Compiling Java code and running unit tests ==='
                sh '''
                    # Grant execute permissions to maven wrapper if needed
                    chmod +x ./mvnw || true
                    ./mvnw clean test package
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "=== Stage 3: Building Docker Image: ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ==="
                sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} -t ${DOCKER_IMAGE_NAME}:latest .
                """
            }
        }

        stage('Push Image to Registry') {
            steps {
                echo '=== Stage 4: Pushing Docker Image to Registry ==='
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_REGISTRY_CREDENTIALS_ID}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${DOCKER_IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo '=== Stage 5: Deploying manifests and updating container image in K8s ==='
                withKubeConfig([credentialsId: "${KUBECONFIG_CREDENTIALS_ID}"]) {
                    sh """
                        # Apply ConfigMap and Service first
                        kubectl apply -f k8s/configmap.yaml
                        kubectl apply -f k8s/service.yaml

                        # Update deployment image to the newly built tag and apply
                        sed -i.bak 's|image: .*|image: ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml
                        kubectl apply -f k8s/deployment.yaml

                        # Verify zero-downtime rolling update status
                        kubectl rollout status deployment/${K8S_DEPLOYMENT_NAME} --timeout=120s
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '=== Stage 6: Verifying Pods and Service Status ==='
                withKubeConfig([credentialsId: "${KUBECONFIG_CREDENTIALS_ID}"]) {
                    sh """
                        echo "--- Pods Status ---"
                        kubectl get pods -l app=spring-boot-k8s -o wide
                        
                        echo "--- Service Status ---"
                        kubectl get svc spring-boot-k8s-service
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up intermediate local Docker images...'
            sh """
                docker rmi ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} || true
            """
        }
        success {
            echo '==================================================='
            echo '  Pipeline Succeeded! Application is live on K8s! '
            echo '==================================================='
        }
        failure {
            echo '==================================================='
            echo '  Pipeline Failed! Inspecting Kubernetes logs...   '
            echo '==================================================='
            withKubeConfig([credentialsId: "${KUBECONFIG_CREDENTIALS_ID}"]) {
                sh '''
                    kubectl describe deployment spring-boot-k8s-deployment || true
                    kubectl logs -l app=spring-boot-k8s --tail=50 || true
                '''
            }
        }
    }
}
