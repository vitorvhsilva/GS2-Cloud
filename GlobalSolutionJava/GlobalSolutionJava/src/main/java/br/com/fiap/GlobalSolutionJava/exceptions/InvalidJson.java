package br.com.fiap.GlobalSolutionJava.exceptions;

public class InvalidJson extends RuntimeException {

    public InvalidJson(){
        super("invalid.json");
    }

    public InvalidJson(String message) {
        super(message);
    }
}
