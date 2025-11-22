package br.com.fiap.GlobalSolutionJava.messaging.rabbit;

import org.springframework.amqp.core.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/*
@Configuration
public class RabbitConfig {

    public static final String QUEUE = "endereco.usuario";
    public static final String EXCHANGE = "exchange.usuario";
    public static final String ROUTING_KEY = "usuario.criado";

    @Bean
    public Queue queue() {
        return QueueBuilder.durable(QUEUE).build();
    }

    @Bean
    public DirectExchange exchange() {
        return new DirectExchange(EXCHANGE);
    }

    @Bean
    public Binding binding() {
        return BindingBuilder
                .bind(queue())
                .to(exchange())
                .with(ROUTING_KEY);
    }
}

 */