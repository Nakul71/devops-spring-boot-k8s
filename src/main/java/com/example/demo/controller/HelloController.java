package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class HelloController {

    @Value("${app.message:Hello from Spring Boot}")
    private String customMessage;

    @GetMapping("/hello")
    public MessageResponse sayHello(@RequestParam(defaultValue = "Guest") String name) {
        String podName = System.getenv().getOrDefault("HOSTNAME", "local-machine");
        String hostAddress;
        try {
            hostAddress = InetAddress.getLocalHost().getHostAddress();
        } catch (Exception e) {
            hostAddress = "unknown";
        }

        Map<String, String> details = new HashMap<>();
        details.put("environment", System.getenv().getOrDefault("APP_ENV", "development"));
        details.put("version", "1.0.0");
        details.put("customMessage", customMessage);

        return new MessageResponse(
                "SUCCESS",
                "Hello, " + name + "! Welcome to Kubernetes CI/CD.",
                podName,
                hostAddress,
                Instant.now(),
                details
        );
    }

    @GetMapping("/info")
    public Map<String, Object> getInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("service", "spring-boot-k8s");
        info.put("framework", "Spring Boot 3.3.4");
        info.put("javaVersion", System.getProperty("java.version"));
        info.put("os", System.getProperty("os.name"));
        info.put("status", "UP");
        return info;
    }
}
