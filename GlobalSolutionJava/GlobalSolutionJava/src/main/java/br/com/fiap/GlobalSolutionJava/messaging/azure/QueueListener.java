package br.com.fiap.GlobalSolutionJava.messaging.azure;

import br.com.fiap.GlobalSolutionJava.dto.message.EnderecoUsuarioMessage;
import br.com.fiap.GlobalSolutionJava.service.EnderecoUsuarioService;
import com.azure.storage.queue.QueueClient;
import com.azure.storage.queue.models.QueueMessageItem;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

//@Service
//@AllArgsConstructor
//public class QueueListener {
//
//    private final QueueClient queueClient;
//    private final EnderecoUsuarioService enderecoUsuarioService;
//    private final ObjectMapper objectMapper;
//
//    public void processarMensagens() {
//        for (QueueMessageItem msg : queueClient.receiveMessages(1)) {
//            try {
//                String json = msg.getMessageText();
//                EnderecoUsuarioMessage dto = objectMapper.readValue(json, EnderecoUsuarioMessage.class);
//                enderecoUsuarioService.updateEnderecoUsuario(dto);
//                queueClient.deleteMessage(msg.getMessageId(), msg.getPopReceipt());
//
//            } catch (Exception e) {
//                throw new RuntimeException("Erro ao converter mensagem para DTO", e);
//            }
//        }
//    }
//}
