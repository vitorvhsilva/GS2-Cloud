package br.com.fiap.GlobalSolutionJava.dto.response;


import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record CareerResponse(

        @JsonProperty("nome_profissao")
        String nomeProfissao,

        String descricao,
        String motivacao,

        @JsonProperty("habilidades_principais")
        List<String> habilidadesPrincipais,

        @JsonProperty("tecnologias_relacionadas")
        List<String> tecnologiasRelacionadas,

        @JsonProperty("trilha_de_aprendizado")
        List<String> trilhaDeAprendizado
) {}