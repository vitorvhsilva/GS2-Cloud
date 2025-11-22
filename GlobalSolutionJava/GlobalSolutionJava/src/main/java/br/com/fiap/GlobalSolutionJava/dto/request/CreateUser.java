package br.com.fiap.GlobalSolutionJava.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateUser(
        @NotBlank(message = "{user.email.notblank}")
        String emailUsuario,

        @NotBlank(message = "{user.username.notblank}")
        String nomeUsuario,

        @NotBlank(message = "{user.password.notblank}")
        String senhaUsuario,

        @NotNull(message = "{user.dayofbirth.notblank}")
        Integer dia,

        @NotNull(message = "{user.monthofbirth.notblank}")
        Integer mes,

        @NotNull(message = "{user.yearofbirth.notblank}")
        Integer ano,

        @NotBlank(message = "{user.cep.notblank}")
        String cepUsuario
) {}
