package br.com.fiap.GlobalSolutionJava.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record Answer(

        @JsonProperty("question_id")
        @NotNull
        Integer questionId,

        @NotBlank
        String resposta
) {}