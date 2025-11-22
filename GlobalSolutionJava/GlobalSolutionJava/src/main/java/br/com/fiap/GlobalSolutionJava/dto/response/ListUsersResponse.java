package br.com.fiap.GlobalSolutionJava.dto.response;

import br.com.fiap.GlobalSolutionJava.domain.User;

import java.time.LocalDate;

public record ListUsersResponse(
        String idUsuario,
        String emailUsuario,
        String nomeUsuario,
        LocalDate dataNascimentoUsuario
){
    public static ListUsersResponse fromModel(User user) {
        return new ListUsersResponse(
                user.getIdUsuario(),
                user.getEmailUsuario(),
                user.getNomeUsuario(),
                user.getDataNascimentoUsuario()
        );
    }
}
