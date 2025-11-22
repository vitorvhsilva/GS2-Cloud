package br.com.fiap.GlobalSolutionJava.exceptions;

public class UserNotFoundException extends RuntimeException {

  public UserNotFoundException() {
        super("user.notfound");
  }

  public UserNotFoundException(String message) {
        super(message);
    }
}
