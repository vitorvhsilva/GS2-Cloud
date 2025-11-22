package br.com.fiap.GlobalSolutionJava.controller;

import br.com.fiap.GlobalSolutionJava.domain.User;
import br.com.fiap.GlobalSolutionJava.dto.request.CreateUser;
import br.com.fiap.GlobalSolutionJava.dto.request.UpdateUser;
import br.com.fiap.GlobalSolutionJava.dto.response.GetUserResponse;
import br.com.fiap.GlobalSolutionJava.dto.response.ListUsersResponse;
import br.com.fiap.GlobalSolutionJava.dto.response.MessageResponse;
import br.com.fiap.GlobalSolutionJava.service.UserService;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import java.time.LocalDate;
import java.util.Locale;

@AllArgsConstructor
@RestController
public class UserController {

    private final UserService userService;

    /**
     * Cria um novo usuário.
     */
    @Transactional
    @PostMapping("/users")
    @CacheEvict(value = "users", allEntries = true)
    public ResponseEntity<ListUsersResponse> newUser(@Valid @RequestBody CreateUser dto) {
        User user = userService.save(User.create(
            dto.emailUsuario(),
            dto.nomeUsuario(),
            dto.senhaUsuario(),
            LocalDate.of(dto.ano(), dto.mes(), dto.dia()
        )), dto.cepUsuario());

        return ResponseEntity.ok(ListUsersResponse.fromModel(user));
    }

    /**
     * Lista os usuários e possui páginação.
     */
    @GetMapping("/users")
    @Cacheable(value = "users", key = "#pageable.pageNumber + '-' + #pageable.pageSize + '-' + #pageable.sort")
    public ResponseEntity<Page<ListUsersResponse>> listUsers(
            @PageableDefault(size = 10, sort = "emailUsuario") Pageable pageable
    ) {
        var usersPage = userService.getAll(pageable);

        var dtoPage = usersPage.map(ListUsersResponse::fromModel);

        return ResponseEntity.ok(dtoPage);
    }

    /**
     * Busca um usuário no banco baseado no ID.
     */
    @GetMapping("/users/{id}")
    public ResponseEntity<GetUserResponse> getById(@PathVariable String id, Locale locale) {
        User user = userService.getById(id, locale);

        return ResponseEntity.ok(GetUserResponse.fromModel(user));
    }

    /**
     * Atualiza informações parciais do usuário.
     */
    @PutMapping("/users/{id}")
    public ResponseEntity<MessageResponse> updateUser(
            @PathVariable String id,
            @RequestBody @Valid UpdateUser dto,
            Locale locale
    ) {
        userService.updateUser(id, dto, locale);

        return ResponseEntity.ok(
                new MessageResponse("Usuário atualizado com sucesso")
        );
    }
}
