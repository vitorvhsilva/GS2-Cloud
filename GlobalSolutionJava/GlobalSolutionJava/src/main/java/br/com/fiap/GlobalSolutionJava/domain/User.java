package br.com.fiap.GlobalSolutionJava.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "TB_USUARIO")
@NamedStoredProcedureQuery(
        name = "User.popularTrilhasEConteudos",
        procedureName = "package_usuario.prc_popular_trilhas_e_conteudos_usuario",
        parameters = {
                @StoredProcedureParameter(mode = ParameterMode.IN, name = "p_id_usuario", type = String.class)
        }
)
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id_usuario", nullable = false, unique = true)
    private String idUsuario;

    @Column(name = "email_usuario", nullable = false, unique = true)
    private String emailUsuario;

    @Column(name = "nome_usuario", nullable = false)
    private String nomeUsuario;

    @Column(name = "senha_usuario", nullable = false)
    private String senhaUsuario;

    @Column(name = "data_nascimento_usuario")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd/MM/yyyy")
    private LocalDate dataNascimentoUsuario;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    private EnderecoUsuario endereco;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public String getPassword() {
        return senhaUsuario;
    }

    @Override
    public String getUsername() {
        return emailUsuario;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    public static User create(String email, String nome, String senha, LocalDate dataNascimento) {
        User user = new User();
        user.setIdUsuario(null);
        user.setEmailUsuario(email);
        user.setNomeUsuario(nome);
        user.setSenhaUsuario(senha);
        user.setDataNascimentoUsuario(dataNascimento);
        user.setEndereco(null);
        return user;
    }
}
