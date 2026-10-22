package com.example.demo.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(HelloController.class)
class HelloControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testSayHelloDefault() throws Exception {
        mockMvc.perform(get("/api/v1/hello")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SUCCESS"))
                .andExpect(jsonPath("$.message").value(
                        "Hello, Guest! Welcome to Version 2.0 deployed automatically via Jenkins CI/CD!"));
    }

        @Test
    void testSayHelloWithName() throws Exception {
        mockMvc.perform(get("/api/v1/hello?name=Alice")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SUCCESS"))
                .andExpect(jsonPath("$.message").value("Hello, Alice! Welcome to Version 2.0 deployed automatically via Jenkins CI/CD!"));
    }


    @Test
    void testGetInfo() throws Exception {
        mockMvc.perform(get("/api/v1/info")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.service").value("spring-boot-k8s"))
                .andExpect(jsonPath("$.status").value("UP"));
    }
}
