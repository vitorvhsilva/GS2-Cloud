package br.com.fiap.GlobalSolutionJava.dto.response;

import br.com.fiap.GlobalSolutionJava.domain.User;

import java.time.LocalDate;

public record GetUserResponse(
        String idUsuario,
        String emailUsuario,
        String nomeUsuario,
        LocalDate dataNascimentoUsuario,
        AddressDTO localizacao
){
    public static GetUserResponse fromModel(User user) {
        AddressDTO addressDTO = null;

        if (user.getEndereco() != null) {
            addressDTO = new AddressDTO(
                    user.getEndereco().getCep(),
                    user.getEndereco().getLogradouro(),
                    user.getEndereco().getEstado()
            );
        }

        return new GetUserResponse(
                user.getIdUsuario(),
                user.getEmailUsuario(),
                user.getNomeUsuario(),
                user.getDataNascimentoUsuario(),
                addressDTO
        );
    }
}
