package br.com.fiap.GlobalSolutionJava.service;

import br.com.fiap.GlobalSolutionJava.exceptions.UserNotFoundException;
import br.com.fiap.GlobalSolutionJava.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class AuthService implements UserDetailsService {

    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UserNotFoundException {
        return userRepository.findByEmailUsuario(username)
                .orElseThrow(() -> new UserNotFoundException());
    }

}