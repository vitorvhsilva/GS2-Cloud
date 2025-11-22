package br.com.fiap.GlobalSolutionJava.exceptions;

public class MissingTokenException extends RuntimeException {

    public MissingTokenException() {
        super("token.missing");
    }

    public MissingTokenException(String messagekey) {
        super(messagekey);
    }
}
