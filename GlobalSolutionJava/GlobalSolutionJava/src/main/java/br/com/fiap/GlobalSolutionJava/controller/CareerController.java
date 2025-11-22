package br.com.fiap.GlobalSolutionJava.controller;

import br.com.fiap.GlobalSolutionJava.domain.FormularioProfissaoUsuario;
import br.com.fiap.GlobalSolutionJava.dto.request.CareerRequest;
import br.com.fiap.GlobalSolutionJava.dto.response.CareerResponse;
import br.com.fiap.GlobalSolutionJava.dto.response.CareerUserResponse;
import br.com.fiap.GlobalSolutionJava.exceptions.AnswerAllQuestions;
import br.com.fiap.GlobalSolutionJava.exceptions.UserNotFoundException;
import br.com.fiap.GlobalSolutionJava.repository.FormularioProfissaoUsuarioRepository;
import br.com.fiap.GlobalSolutionJava.repository.UserRepository;
import br.com.fiap.GlobalSolutionJava.service.CareerService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@AllArgsConstructor
@RestController
public class CareerController {

    private final CareerService careerService;
    private final UserRepository userRepository;
    private final FormularioProfissaoUsuarioRepository formularioProfissaoUsuarioRepository;

    /**
     * Gera a carreira via IA e salva a profissão recomendada.
     */
    @PostMapping("/users/{idUsuario}/career")
    public ResponseEntity<CareerResponse> generateCareer(
            @PathVariable String idUsuario,
            @RequestBody @Valid CareerRequest request
    ) {
        if (request.answers() == null || request.answers().size() < 10) {
            throw new AnswerAllQuestions();
        }

        userRepository.findById(idUsuario).orElseThrow(UserNotFoundException::new);

        CareerResponse response = careerService.generateCareer(request);

        String profissao = response.nomeProfissao();
        if (profissao != null && profissao.length() > 100) {
            profissao = profissao.substring(0, 100);
        }

        FormularioProfissaoUsuario entity = formularioProfissaoUsuarioRepository.findById(idUsuario)
                .orElse(new FormularioProfissaoUsuario());
        entity.setIdUsuario(idUsuario);
        entity.setProfissaoRecomendada(profissao);

        formularioProfissaoUsuarioRepository.save(entity);

        return ResponseEntity.ok(response);
    }

    /**
     * Retorna apenas a profissão recomendada salva para o usuário.
     */
    @GetMapping("/users/{idUsuario}/career")
    public ResponseEntity<CareerUserResponse> getCareer(
            @PathVariable String idUsuario
    ) {
        userRepository.findById(idUsuario).orElseThrow(UserNotFoundException::new);

        var optionalFormulario  = formularioProfissaoUsuarioRepository.findById(idUsuario);

        if (optionalFormulario.isEmpty()) {
            return ResponseEntity.ok(new CareerUserResponse(
                    idUsuario,
                    null
            ));
        }

        var entity = optionalFormulario.get();

        return ResponseEntity.ok(new CareerUserResponse(
                idUsuario,
                entity.getProfissaoRecomendada()
        ));
    }
}