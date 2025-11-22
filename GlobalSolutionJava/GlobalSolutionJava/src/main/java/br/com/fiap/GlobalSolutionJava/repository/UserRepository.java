package br.com.fiap.GlobalSolutionJava.repository;

import br.com.fiap.GlobalSolutionJava.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, String> {

    Optional<User> findByEmailUsuario(String emailUsuario);

    @Procedure(name = "User.popularTrilhasEConteudos")
    void populateTrails(@Param("p_id_usuario") String idUsuario);
}
