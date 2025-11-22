package br.com.fiap.GlobalSolutionJava.service;

import br.com.fiap.GlobalSolutionJava.domain.User;
import br.com.fiap.GlobalSolutionJava.dto.message.EnderecoUsuarioMessage;
import br.com.fiap.GlobalSolutionJava.dto.request.UpdateUser;
import br.com.fiap.GlobalSolutionJava.exceptions.UserNotFoundException;
//import br.com.fiap.GlobalSolutionJava.messaging.rabbit.RabbitProducer;
import br.com.fiap.GlobalSolutionJava.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Locale;

@Service
@AllArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final MessageSource messageSource;
    private final PasswordEncoder passwordEncoder;
//    private final RabbitProducer rabbitProducer;

    @Transactional
    public User save(User user, String cep) {
        String raw = user.getSenhaUsuario();
        if (raw != null && !raw.isBlank()) {
            user.setSenhaUsuario(passwordEncoder.encode(raw));
        }

        User savedUser = userRepository.save(user);
        userRepository.flush();
        userRepository.populateTrails(savedUser.getIdUsuario());
        //TODO: trocar para Azure
        /*
        rabbitProducer.sendMessage(new EnderecoUsuarioMessage(
            savedUser.getIdUsuario(),
            cep
        ));
         */

        return savedUser;
    }

    public Page<User> getAll(Pageable pageable) {
        return userRepository.findAll(pageable);
    }

    public User getById(String id, Locale locale) {
        return userRepository.findById(id).orElseThrow(() -> new UserNotFoundException());
    }

    @Transactional
    public User updateUser(String id, UpdateUser dto, Locale locale) {
        User user = getById(id, locale);

        user.setNomeUsuario(dto.nomeUsuario());
        user.setSenhaUsuario(passwordEncoder.encode(dto.senhaUsuario()));
        LocalDate dataNascimento = LocalDate.of(dto.ano(), dto.mes(), dto.dia());
        user.setDataNascimentoUsuario(dataNascimento);

        return user;
    }


}
