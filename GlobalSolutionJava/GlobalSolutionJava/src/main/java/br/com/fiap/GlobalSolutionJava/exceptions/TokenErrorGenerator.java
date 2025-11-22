package br.com.fiap.GlobalSolutionJava.exceptions;

public class TokenErrorGenerator extends RuntimeException {

    public TokenErrorGenerator() {
        super("token.error");
    }

    public TokenErrorGenerator(String message) {
        super(message);
    }
}
