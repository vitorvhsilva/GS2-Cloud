package br.com.fiap.GlobalSolutionJava.messaging.rabbit;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

/*
@Service
@AllArgsConstructor
public class RabbitProducer {

    private final RabbitTemplate rabbitTemplate;
    private final ObjectMapper mapper;

    public void sendMessage(Object dto) {
        try {
            String json = mapper.writeValueAsString(dto);

            rabbitTemplate.convertAndSend(
                    RabbitConfig.EXCHANGE,
                    RabbitConfig.ROUTING_KEY,
                    json
            );

            System.out.println("Mensagem enviada ao RabbitMQ!");
        } catch (Exception e) {
            throw new RuntimeException("Erro ao enviar mensagem RabbitMQ", e);
        }
    }
}
*/
