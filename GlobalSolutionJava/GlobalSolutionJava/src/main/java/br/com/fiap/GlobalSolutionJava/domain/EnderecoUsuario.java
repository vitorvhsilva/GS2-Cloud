package br.com.fiap.GlobalSolutionJava.domain;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "TB_ENDERECO_USUARIO")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class EnderecoUsuario {

    @Id
    @Column(name = "id_usuario")
    private String idUsuario;

    @OneToOne
    @MapsId
    @JoinColumn(name = "id_usuario")
    private User user;

    @Column(name = "cep_endereco")
    private String cep;

    @Column(name = "logradouro_endereco")
    private String logradouro;

    @Column(name = "estado_endereco")
    private String estado;
}
