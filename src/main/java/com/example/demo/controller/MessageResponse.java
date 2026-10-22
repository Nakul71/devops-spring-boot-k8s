package com.example.demo.controller;

import java.time.Instant;
import java.util.Map;

public record MessageResponse(
        String status,
        String message,
        String podName,
        String hostAddress,
        Instant timestamp,
        Map<String, String> details
) {
}
