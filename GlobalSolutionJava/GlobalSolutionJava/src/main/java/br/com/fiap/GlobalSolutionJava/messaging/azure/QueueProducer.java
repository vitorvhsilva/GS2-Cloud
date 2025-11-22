package br.com.fiap.GlobalSolutionJava.messaging.azure;

import br.com.fiap.GlobalSolutionJava.dto.message.EnderecoUsuarioMessage;
import com.azure.storage.queue.QueueClient;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

//@Service
//@AllArgsConstructor
//public class QueueProducer {
//
//    private final QueueClient queueClient;
//    private final ObjectMapper objectMapper;
//
//    public void enviarMensagem(EnderecoUsuarioMessage message) {
//        try {
//            String json = objectMapper.writeValueAsString(message);
//            queueClient.sendMessage(json);
//            System.out.println("📨 DTO enviado para a fila!");
//        } catch (Exception e) {
//            throw new RuntimeException("Erro ao enviar DTO para a fila", e);
//        }
//    }
//}