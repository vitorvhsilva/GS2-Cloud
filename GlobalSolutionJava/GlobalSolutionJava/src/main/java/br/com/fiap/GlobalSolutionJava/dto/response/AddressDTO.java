package br.com.fiap.GlobalSolutionJava.dto.response;


public record AddressDTO(
    String cep,
    String logradouro,
    String estado
) {
}
