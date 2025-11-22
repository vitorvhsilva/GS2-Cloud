package br.com.fiap.GlobalSolutionJava.dto.request;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;


public record CareerRequest(

        @NotEmpty
        List<Answer> answers
) {}