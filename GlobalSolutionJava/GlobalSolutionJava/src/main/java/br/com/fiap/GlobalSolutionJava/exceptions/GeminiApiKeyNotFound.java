package br.com.fiap.GlobalSolutionJava.exceptions;

public class GeminiApiKeyNotFound extends RuntimeException {

    public GeminiApiKeyNotFound() {
        super("gemini.notdefined");
    }

    public GeminiApiKeyNotFound(String message) {
        super(message);
    }
}
