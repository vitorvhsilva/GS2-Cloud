package br.com.fiap.GlobalSolutionJava.dto.response;

import java.time.Instant;

public record ApiError(
        Instant timestamp,
        int status,
        String message,
        String path
) { }