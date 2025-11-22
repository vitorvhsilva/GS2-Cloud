package br.com.fiap.GlobalSolutionJava.service;

import br.com.fiap.GlobalSolutionJava.domain.User;
import br.com.fiap.GlobalSolutionJava.dto.message.EnderecoUsuarioMessage;
import br.com.fiap.GlobalSolutionJava.dto.response.ViaCepResponse;
import br.com.fiap.GlobalSolutionJava.exceptions.UserNotFoundException;
import br.com.fiap.GlobalSolutionJava.http.ViaCepClient;
import br.com.fiap.GlobalSolutionJava.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class EnderecoUsuarioService {
    public final ViaCepClient viaCepClient;
    public final UserRepository userRepository;

    @Transactional
    public void updateEnderecoUsuario(EnderecoUsuarioMessage message) {
        ViaCepResponse response = viaCepClient.getAddress(message.cep());
        User user = userRepository.findById(message.idUsuario()).orElseThrow(() -> new UserNotFoundException());
        user.setEndereco(response.toEnderecoUsuario(user));
        System.out.println("Endereço atualizado para o usuário ID: " + message.idUsuario());
    }

}
