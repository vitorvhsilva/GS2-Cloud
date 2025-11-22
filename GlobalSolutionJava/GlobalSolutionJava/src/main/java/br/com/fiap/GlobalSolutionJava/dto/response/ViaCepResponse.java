package br.com.fiap.GlobalSolutionJava.dto.response;

import br.com.fiap.GlobalSolutionJava.domain.EnderecoUsuario;
import br.com.fiap.GlobalSolutionJava.domain.User;

public record ViaCepResponse(
        String cep,
        String logradouro,
        String complemento,
        String unidade,
        String bairro,
        String localidade,
        String uf,
        String estado,
        String regiao,
        String ibge,
        String gia,
        String ddd,
        String siafi
) {
    public EnderecoUsuario toEnderecoUsuario(User user) {
        return new EnderecoUsuario(
                user.getIdUsuario(),
                user,
                cep,
                logradouro,
                estado
        );
    }
}
