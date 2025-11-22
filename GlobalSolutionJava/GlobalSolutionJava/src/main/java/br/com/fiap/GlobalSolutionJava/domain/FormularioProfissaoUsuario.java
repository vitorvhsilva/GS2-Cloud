package br.com.fiap.GlobalSolutionJava.domain;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "TB_FORMULARIO_PROFISSAO_USUARIO")
public class FormularioProfissaoUsuario {

    @Id
    @Column(name = "id_usuario", nullable = false, length = 36)
    private String idUsuario;

    @Column(name = "profissao_recomendada", length = 100)
    private String profissaoRecomendada;
}
