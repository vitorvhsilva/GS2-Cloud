package br.com.fiap.GlobalSolutionJava.service;

import br.com.fiap.GlobalSolutionJava.exceptions.*;
import br.com.fiap.GlobalSolutionJava.promptAI.CareerPrompt;
import br.com.fiap.GlobalSolutionJava.dto.request.CareerRequest;
import br.com.fiap.GlobalSolutionJava.dto.response.CareerResponse;
import br.com.fiap.GlobalSolutionJava.dto.request.Question;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class CareerService {

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate;

    private final String apiKey;
    private final String model;

    private static final List<Question> QUESTIONS = List.of(
            new Question(1, "O que você mais gosta de fazer no dia a dia (estudar, criar, liderar, programar, cuidar de pessoas, etc.)?"),
            new Question(2, "Você prefere trabalhar com pessoas, dados, máquinas, natureza ou ideias abstratas? Por quê?"),
            new Question(3, "Qual é seu nível de interesse por tecnologia e inteligência artificial? (0 a 10) Explique."),
            new Question(4, "Você se vê mais como criativo(a), analítico(a), organizador(a), cuidador(a) ou executor(a) prático(a)? Dê exemplos."),
            new Question(5, "Como você imagina o mundo do trabalho daqui a 10–20 anos?"),
            new Question(6, "Você prefere rotina estável ou desafios novos o tempo todo? Em que tipo de ambiente você rende mais?"),
            new Question(7, "Quais áreas te chamam mais atenção hoje? (ex.: saúde, jogos, negócios, sustentabilidade, artes, educação, finanças, etc.)"),
            new Question(8, "Você gostaria de trabalhar remoto, híbrido ou presencial? E em empresas, startups, governo, ONG, autônomo?"),
            new Question(9, "Quais habilidades você acha que já tem bem desenvolvidas? (ex.: comunicação, lógica, empatia, escrita, liderança)"),
            new Question(10, "Quanto tempo você estaria disposto(a) a investir em estudos intensos para se tornar referência em uma área? (ex.: 1, 3, 5, 10 anos)")
    );

    public CareerService(
            ObjectMapper objectMapper,
            @Value("${gemini.api.key:#{null}}") String apiKeyProperty,
            @Value("${gemini.model:gemini-2.0-flash}") String modelProperty
    ) {
        this.objectMapper = objectMapper;
        this.restTemplate = new RestTemplate();

        String envApiKey = System.getenv("GEMINI_API_KEY");
        String resolvedKey = (apiKeyProperty != null && !apiKeyProperty.isBlank())
                ? apiKeyProperty
                : envApiKey;

        if (resolvedKey == null || resolvedKey.isBlank()) {
            throw new GeminiApiKeyNotFound();
        }
        this.apiKey = resolvedKey;

        String envModel = System.getenv("GEMINI_MODEL");
        this.model = (modelProperty != null && !modelProperty.isBlank())
                ? modelProperty
                : (envModel != null && !envModel.isBlank() ? envModel : "gemini-2.5-flash");
    }

    public CareerResponse generateCareer(CareerRequest request) {
        Map<String, Object> payload = Map.of(
                "perguntas", QUESTIONS,
                "respostas", request.answers()
        );

        String payloadJson;
        try {
            payloadJson = objectMapper.writeValueAsString(payload);
        } catch (JsonProcessingException e) {
            throw new InvalidJson();
        }

        String fullPrompt = CareerPrompt.CAREER_PROMPT +
                "\n\nENTRADA (JSON):\n" +
                payloadJson;

        String rawText = callGemini(fullPrompt);

        return parseCareerResponse(rawText);
    }


    @SuppressWarnings("unchecked")
    private String callGemini(String fullPrompt) {
        String url = "https://generativelanguage.googleapis.com/v1beta/models/"
                + model + ":generateContent?key=" + apiKey;

        Map<String, Object> body = Map.of(
                "contents", List.of(
                        Map.of(
                                "parts", List.of(
                                        Map.of("text", fullPrompt)
                                )
                        )
                )
        );

        try {
            Map<String, Object> response = restTemplate.postForObject(url, body, Map.class);
            if (response == null) {
                throw new ResponseIANotFound();
            }

            List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
            if (candidates == null || candidates.isEmpty()) {
                throw new ResponseIANotFound();
            }

            Map<String, Object> content = (Map<String, Object>) candidates.get(0).get("content");
            if (content == null) {
                throw new ResponseIANotFound();
            }

            List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
            if (parts == null || parts.isEmpty()) {
                throw new ResponseIANotFound();
            }

            Object text = parts.get(0).get("text");
            if (text == null) {
                throw new ResponseIANotFound();
            }

            return text.toString();
        } catch (RestClientException e) {
            throw new ApiKeyLakedOrExpired();
        }
    }

    private CareerResponse parseCareerResponse(String rawText) {
        String raw = rawText == null ? "" : rawText.trim();

        if (raw.contains("```")) {
            int start = raw.indexOf("```");
            int end = raw.lastIndexOf("```");
            if (start != -1 && end != -1 && end > start) {
                String fenced = raw.substring(start + 3, end).trim();
                String lower = fenced.toLowerCase();
                if (lower.startsWith("json")) {
                    fenced = fenced.substring(4).trim();
                }
                raw = fenced;
            }
        }

        int startBrace = raw.indexOf('{');
        int endBrace = raw.lastIndexOf('}');
        if (startBrace == -1 || endBrace == -1 || endBrace <= startBrace) {
            throw new InvalidJson();
        }

        String jsonStr = raw.substring(startBrace, endBrace + 1);

        try {
            return objectMapper.readValue(jsonStr, CareerResponse.class);
        } catch (JsonProcessingException e) {
            throw new InvalidJson();
        }
    }
}