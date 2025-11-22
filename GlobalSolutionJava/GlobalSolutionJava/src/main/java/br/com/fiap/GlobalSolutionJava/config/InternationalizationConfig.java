package br.com.fiap.GlobalSolutionJava.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver;

import java.util.Locale;

@Configuration
public class InternationalizationConfig {

    /*
    Para definir qual idioma deseja, adicione um Header na requisição chamado: Accept-Language
    Valores possíveis no header: pt-BR, en-US
     */
    @Bean
    public LocaleResolver localeResolver() {
        AcceptHeaderLocaleResolver resolver = new AcceptHeaderLocaleResolver();
        resolver.setDefaultLocale(new Locale("pt", "BR"));
        return resolver;
    }
}
