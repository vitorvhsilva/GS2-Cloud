package br.com.fiap.GlobalSolutionJava.exceptions;

public class AnswerAllQuestions extends RuntimeException{
    public AnswerAllQuestions() {
        super("answer.complete");
    }

    public AnswerAllQuestions(String message) {
        super(message);
    }
}
