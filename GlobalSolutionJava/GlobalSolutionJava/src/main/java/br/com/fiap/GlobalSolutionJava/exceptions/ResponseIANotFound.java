package br.com.fiap.GlobalSolutionJava.exceptions;

public class ResponseIANotFound extends RuntimeException {

    public ResponseIANotFound(){
        super("response.ia.notfound");
    }

    public ResponseIANotFound(String message) {
        super(message);
    }
}
