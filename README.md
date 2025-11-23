# SkillShift — A Plataforma que Prepara Pessoas para o Futuro do Trabalho

## O que é o SkillShift?

O **SkillShift** é uma plataforma simples, acessível e objetiva que concentra conteúdos curados — **vídeos e artigos** — organizados em trilhas de aprendizagem criadas para preparar jovens e profissionais para o **mercado do futuro**.

A plataforma oferece **aprendizado rápido, direto e sem complexidade**, sem desafios, avaliações ou projetos.  
O objetivo é permitir que qualquer pessoa — mesmo sem experiência — consiga entender as tendências e habilidades necessárias para trabalhar nos novos modelos profissionais.

---

## 👤 Fluxo do Usuário

### **1. Cadastro**
O usuário informa:
- Nome  
- Email  
- Data de nascimento  
- Senha  

### **2. Login**
Após criar a conta, o usuário acessa a plataforma com suas credenciais.

### **3. Dashboard Inicial**
O usuário visualiza todas as **Trilhas SkillShift**, cada uma representando um caminho completo de formação.

### **4. Acesso às Trilhas**
Dentro de cada trilha, o usuário encontra:
- Vídeos explicativos  
- Artigos curtos  
- Conteúdos rápidos e de fácil aprendizado  

### **5. Progresso Automático**
Ao assistir vídeos e ler artigos, os conteúdos são marcados automaticamente como **concluídos**.

### **6. Conclusão da Trilha**
Ao finalizar uma trilha, o usuário pode gerar um **certificado digital opcional** (funcionalidade extra).

---

## Trilhas de Aprendizagem

### **1. Introdução ao Futuro do Trabalho**  
Tendências, automação, IA e as mudanças no mundo profissional.

### **2. Inteligência Artificial Aplicada**  
Uso prático da IA no dia a dia, ferramentas populares e seu impacto.

### **3. Habilidades Digitais Essenciais**  
Fundamentos de navegação digital, segurança, cloud e tecnologia.

### **4. Carreiras em Tecnologia**  
Visão geral de desenvolvimento, dados, automação, cibersegurança, IA e UX.

### **5. Empreendedorismo Moderno**  
Inovação, economia digital e novos modelos de negócio.

### **6. Produtividade e Organização**  
Métodos e ferramentas modernas de gestão pessoal.

### **7. Soft Skills do Futuro**  
Comunicação, criatividade, colaboração, adaptabilidade e outras human skills.

### **8. Dados e Analytics**  
Conceitos básicos, indicadores, visualização e tomada de decisão.

### **9. Criatividade e Inovação**  
Pensamento criativo, resolução de problemas e metodologias atuais.

### **10. Liderança e Gestão 4.0**  
Liderança humanizada, inteligência emocional e gestão híbrida/remota.

---

## Diferenciais do SkillShift

### ✔️ Plataforma simples e intuitiva  
Fácil de usar, mesmo para iniciantes.

### ✔️ Curadoria inteligente de conteúdo  
Vídeos e artigos escolhidos para facilitar o entendimento rápido.

### ✔️ Trilhas completas e estruturadas  
O usuário segue um caminho guiado, sem precisar escolher assuntos soltos.

### ✔️ Foco no futuro do trabalho  
Conteúdos alinhados às tendências reais do mercado.

### ✔️ Essencial, direto e prático  
Sem enrolação: só o que realmente importa.

### ✔️ Acessível para todos  
Ideal para estudantes, profissionais iniciantes ou em transição de carreira.

---

## Objetivo Final

Preparar pessoas para carreiras que ainda estão surgindo,  
desenvolvendo habilidades essenciais para um mundo cada vez mais digital, automatizado e humano ao mesmo tempo.

---

## 🚀 Tecnologias

- **Linguagem:** Java 21
- **Framework Web:** Spring Boot
- **Banco de Dados:** Oracle (driver `ojdbc11`)
- **ORM:** Spring Data JPA / Hibernate
- **Segurança & Autenticação:**
    - Spring Security
    - JWT com `com.auth0:java-jwt`
- **Validação:** Bean Validation (`spring-boot-starter-validation`)
- **Cache:** Spring Cache
- **Mensageria:**
    - RabbitMQ (`spring-boot-starter-amqp`)
    - Azure Storage Queue (`spring-cloud-azure-starter-storage-queue`)
- **Comunicação entre serviços:** Spring Cloud OpenFeign
- **Teste:** Spring Boot Test, Spring Security Test
- **Produtividade:** Spring DevTools
- **Code Generation:** Lombok

--- 

# Guia rápido para criar e publicar a API SkillShift no Azure com Java 21 e SQL Server.

```bash

az group create --name skillshift-rg --location brazilsouth

az appservice plan create --name skillshift-plan --resource-group skillshift-rg --sku B1

az webapp create --resource-group skillshift-rg --plan skillshift-plan --name skillshift-api --runtime "JAVA:21" --deployment-local-git

az webapp config set --resource-group skillshift-rg --name skillshift-api --use-32bit-worker-process false

az sql server create --name skillshiftsqlserver --resource-group skillshift-rg --location brazilsouth --admin-user sqladmin --admin-password SenhaForte!123

az sql db create --resource-group skillshift-rg --server skillshiftsqlserver --name SkillShiftDB --service-objective S0 --backup-storage-redundancy Local

az sql server firewall-rule create --resource-group skillshift-rg --server skillshiftsqlserver --name AllowAllIPs --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

# configurar variaveis de ambiente

az webapp config appsettings set --name skillshift-api --resource-group skillshift-rg --settings DB_URL="jdbc:sqlserver://skillshiftsqlserver.database.windows.net:1433;database=SkillShiftDB;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;" DB_USERNAME="sqladmin" DB_PASSWORD=SenhaForte!123 

```
Antes de dar o deploy certifique que esta dentro da pasta GlobalSolutionJava

```

az webapp deploy --resource-group skillshift-rg --name skillshift-api --src-path "./target/GlobalSolutionJava-0.0.1-SNAPSHOT.jar" --type jar

```

Para rodar o projeto local: 

Inicie o docker

No terminal do projeto dentro de Global-Solution-Java-E-IOT/GlobalSolutionJava/GlobalSolutionJava execute o comando: docker-compose up --build --force-recreate

Para baixar a imagem do RabbitMq

Rode o projeto.
