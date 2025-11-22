package br.com.fiap.GlobalSolutionJava.exceptions;

import br.com.fiap.GlobalSolutionJava.dto.response.ApiError;
import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.Locale;

@RestControllerAdvice
@AllArgsConstructor
public class GlobalExceptionHandler {

    private final MessageSource messageSource;

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ApiError> handleUserNotFound(
            UserNotFoundException ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.NOT_FOUND;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler(MissingTokenException.class)
    public ResponseEntity<ApiError> handleTokenNotFound(
            MissingTokenException ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.FORBIDDEN;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({TokenErrorGenerator.class})
    public ResponseEntity<ApiError> handleTokenErrorGenerator(
            TokenErrorGenerator ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.FORBIDDEN;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({GeminiApiKeyNotFound.class})
    public ResponseEntity<ApiError> handleGeminiApiKeyNotFound(
            GeminiApiKeyNotFound ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.FORBIDDEN;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({GeminiModelError.class})
    public ResponseEntity<ApiError> handleGeminiModelError(
            GeminiModelError ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.BAD_GATEWAY;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({InvalidJson.class})
    public ResponseEntity<ApiError> handleInvalidJson(
            InvalidJson ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.BAD_REQUEST;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({ResponseIANotFound.class})
    public ResponseEntity<ApiError> handleResponseIANotFound(
            ResponseIANotFound ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.BAD_GATEWAY;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({AnswerAllQuestions.class})
    public ResponseEntity<ApiError> handleResponseIANotFound(
            AnswerAllQuestions ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.BAD_REQUEST;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler({ApiKeyLakedOrExpired.class})
    public ResponseEntity<ApiError> handleResponseIANotFound(
            ApiKeyLakedOrExpired ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiError> handleRuntimeException(
            RuntimeException ex,
            HttpServletRequest request
    ) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

        Locale locale = LocaleContextHolder.getLocale();

        String localizedMessage = messageSource.getMessage(
                ex.getMessage(),
                null,
                locale
        );

        ApiError body = new ApiError(
                Instant.now(),
                status.value(),
                localizedMessage,
                request.getRequestURI()
        );

        return ResponseEntity.status(status).body(body);
    }

}
