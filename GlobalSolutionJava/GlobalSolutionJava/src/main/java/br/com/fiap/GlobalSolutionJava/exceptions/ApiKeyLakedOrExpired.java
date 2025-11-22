package br.com.fiap.GlobalSolutionJava.exceptions;

public class ApiKeyLakedOrExpired extends RuntimeException {

    public ApiKeyLakedOrExpired() {
        super("gemini.apikeylakedorexpired");
    }


    public ApiKeyLakedOrExpired(String message) {
        super(message);
    }
}
