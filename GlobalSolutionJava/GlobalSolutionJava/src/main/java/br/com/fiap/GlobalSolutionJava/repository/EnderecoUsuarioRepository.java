package br.com.fiap.GlobalSolutionJava.repository;

import br.com.fiap.GlobalSolutionJava.domain.EnderecoUsuario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EnderecoUsuarioRepository extends JpaRepository<EnderecoUsuario, String> {
}
