package br.com.fiap.GlobalSolutionJava.messaging.rabbit;

import br.com.fiap.GlobalSolutionJava.dto.message.EnderecoUsuarioMessage;
import br.com.fiap.GlobalSolutionJava.service.EnderecoUsuarioService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Service;

/*
@Service
@AllArgsConstructor
public class RabbitEnderecoListener {

    private final EnderecoUsuarioService enderecoUsuarioService;
    private final ObjectMapper mapper;

    @RabbitListener(queues = RabbitConfig.QUEUE)
    public void consumir(String mensagemJson) {
        try {
            EnderecoUsuarioMessage dto =
                    mapper.readValue(mensagemJson, EnderecoUsuarioMessage.class);
            System.out.println("Mensagem recebida: " + dto);
            enderecoUsuarioService.updateEnderecoUsuario(dto);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao processar mensagem RabbitMQ", e);
        }
    }
}

 */