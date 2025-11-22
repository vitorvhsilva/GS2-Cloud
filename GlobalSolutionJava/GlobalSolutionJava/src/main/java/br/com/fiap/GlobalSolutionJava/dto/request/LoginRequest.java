package br.com.fiap.GlobalSolutionJava.dto.request;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(

        @NotBlank(message = "{user.email.notblank}")
        String emailUsuario,

        @NotBlank(message = "{user.password.notblank}")
        String senhaUsuario

) {}
