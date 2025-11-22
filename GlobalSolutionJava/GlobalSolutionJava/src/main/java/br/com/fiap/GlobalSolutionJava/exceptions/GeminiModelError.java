package br.com.fiap.GlobalSolutionJava.exceptions;

public class GeminiModelError extends RuntimeException {

  public GeminiModelError() {
    super("gemini.modelerror");
  }

  public GeminiModelError(String message) {
    super(message);
  }
}
