package br.com.fiap.GlobalSolutionJava;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableCaching
@SpringBootApplication
@EnableFeignClients
@EnableScheduling
public class GlobalSolutionJavaApplication {

	public static void main(String[] args) {
		SpringApplication.run(GlobalSolutionJavaApplication.class, args);
	}

}
