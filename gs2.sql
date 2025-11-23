
IF OBJECT_ID('dbo.tb_conteudo_trilha_usuario', 'U') IS NOT NULL DROP TABLE dbo.tb_conteudo_trilha_usuario;
IF OBJECT_ID('dbo.tb_conteudo_trilha', 'U') IS NOT NULL DROP TABLE dbo.tb_conteudo_trilha;
IF OBJECT_ID('dbo.tb_formulario_profissao_usuario', 'U') IS NOT NULL DROP TABLE dbo.tb_formulario_profissao_usuario;
IF OBJECT_ID('dbo.tb_endereco_usuario', 'U') IS NOT NULL DROP TABLE dbo.tb_endereco_usuario;
IF OBJECT_ID('dbo.tb_trilha_usuario', 'U') IS NOT NULL DROP TABLE dbo.tb_trilha_usuario;
IF OBJECT_ID('dbo.tb_trilha', 'U') IS NOT NULL DROP TABLE dbo.tb_trilha;
IF OBJECT_ID('dbo.tb_usuario', 'U') IS NOT NULL DROP TABLE dbo.tb_usuario;
IF OBJECT_ID('dbo.tb_auditoria', 'U') IS NOT NULL DROP TABLE dbo.tb_auditoria;
GO

/* Tables */

CREATE TABLE dbo.tb_usuario (
    id_usuario varchar(36) NOT NULL PRIMARY KEY,
    nome_usuario varchar(255) NOT NULL,
    email_usuario varchar(255) NOT NULL,
    senha_usuario varchar(255) NOT NULL,
    data_nascimento_usuario datetime2 NOT NULL
);
GO

CREATE TABLE dbo.tb_trilha (
    id_trilha varchar(36) NOT NULL PRIMARY KEY,
    nome_trilha varchar(200) NOT NULL,
    quantidade_conteudo_trilha int NOT NULL
);
GO

CREATE TABLE dbo.tb_conteudo_trilha (
    id_conteudo_trilha varchar(36) NOT NULL PRIMARY KEY,
    nome_conteudo_trilha varchar(200) NOT NULL,
    tipo_conteudo_trilha varchar(20) NOT NULL,
    texto_conteudo_trilha varchar(max) NOT NULL,
    id_trilha varchar(36) NOT NULL,
    CONSTRAINT fk_conteudo_trilha_trilha FOREIGN KEY (id_trilha)
        REFERENCES dbo.tb_trilha(id_trilha)
);
GO

CREATE TABLE dbo.tb_conteudo_trilha_usuario (
    id_conteudo_trilha_usuario varchar(36) NOT NULL PRIMARY KEY,
    conteudo_trilha_concluida_usuario char(1) NULL,
    id_usuario varchar(36) NOT NULL,
    id_conteudo_trilha varchar(36) NOT NULL,
    CONSTRAINT fk_ctu_conteudo FOREIGN KEY (id_conteudo_trilha) REFERENCES dbo.tb_conteudo_trilha(id_conteudo_trilha),
    CONSTRAINT fk_ctu_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.tb_usuario(id_usuario)
);
GO

CREATE TABLE dbo.tb_endereco_usuario (
    id_usuario varchar(36) NOT NULL PRIMARY KEY,
    cep_endereco varchar(20) NOT NULL,
    logradouro_endereco varchar(200) NULL,
    estado_endereco varchar(200) NULL,
    CONSTRAINT fk_end_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.tb_usuario(id_usuario)
);
GO

CREATE TABLE dbo.tb_formulario_profissao_usuario (
    id_usuario varchar(36) NOT NULL PRIMARY KEY,
    resposta_pergunta_1 varchar(1000) NULL,
    resposta_pergunta_2 varchar(1000) NULL,
    resposta_pergunta_3 varchar(1000) NULL,
    resposta_pergunta_4 varchar(1000) NULL,
    resposta_pergunta_5 varchar(1000) NULL,
    resposta_pergunta_6 varchar(1000) NULL,
    resposta_pergunta_7 varchar(1000) NULL,
    resposta_pergunta_8 varchar(1000) NULL,
    resposta_pergunta_9 varchar(1000) NULL,
    resposta_pergunta_10 varchar(1000) NULL,
    profissao_recomendada varchar(100) NULL,
    CONSTRAINT fk_form_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.tb_usuario(id_usuario)
);
GO

CREATE TABLE dbo.tb_trilha_usuario (
    id_trilha_usuario varchar(36) NOT NULL PRIMARY KEY,
    id_usuario varchar(36) NOT NULL,
    id_trilha varchar(36) NOT NULL,
    trilha_concluida_usuario char(1) NULL,
    CONSTRAINT fk_trilha_usuario_trilha FOREIGN KEY (id_trilha) REFERENCES dbo.tb_trilha(id_trilha),
    CONSTRAINT fk_trilha_usuario_usuario FOREIGN KEY (id_usuario) REFERENCES dbo.tb_usuario(id_usuario)
);
GO

CREATE TABLE dbo.tb_auditoria (
    id_auditoria varchar(36) NOT NULL DEFAULT (CONVERT(varchar(36), NEWID())) PRIMARY KEY,
    nome_tabela varchar(100) NULL,
    operacao varchar(10) NULL,
    registro varchar(max) NULL,
    data_operacao datetime2 NULL
);
GO

/* =========================
   Triggers for audit logging
   Using set-based inserts with inserted/deleted
   ========================= */

/* Helper: for each audited table we will insert one row into tb_auditoria for each affected row,
   indicating operation 'insert'/'update'/'delete' and a 'registro' string similar to Oracle version.
*/

/* tb_usuario trigger */
IF OBJECT_ID('trg_au_tb_usuario', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_usuario;
GO
CREATE TRIGGER trg_au_tb_usuario
ON dbo.tb_usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Inserts and updates: rows present in inserted
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_usuario' AS nome_tabela,
        CASE
            WHEN i.id_usuario IS NOT NULL AND d.id_usuario IS NULL THEN 'insert'
            WHEN i.id_usuario IS NOT NULL AND d.id_usuario IS NOT NULL THEN 'update'
            WHEN i.id_usuario IS NULL AND d.id_usuario IS NOT NULL THEN 'delete'
            ELSE 'unknown'
        END AS operacao,
        -- Build registro string showing old -> new values
        'id_usuario=' + ISNULL(COALESCE(i.id_usuario,d.id_usuario),'') + '; '
        + 'nome_usuario(old)=' + ISNULL(d.nome_usuario,'') + ' -> nome_usuario(new)=' + ISNULL(i.nome_usuario,'') + '; '
        + 'email_usuario(old)=' + ISNULL(d.email_usuario,'') + ' -> email_usuario(new)=' + ISNULL(i.email_usuario,'') + '; '
        + 'senha_usuario(old)=' + ISNULL(d.senha_usuario,'') + ' -> senha_usuario(new)=' + ISNULL(i.senha_usuario,'') + '; '
        + 'data_nascimento_usuario(old)=' + ISNULL(CONVERT(varchar(19), d.data_nascimento_usuario, 120),'') + ' -> data_nascimento_usuario(new)=' + ISNULL(CONVERT(varchar(19), i.data_nascimento_usuario, 120),'')
        AS registro,
        SYSDATETIME() AS data_operacao
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_usuario = d.id_usuario;
END;
GO

/* tb_trilha trigger */
IF OBJECT_ID('trg_au_tb_trilha', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_trilha;
GO
CREATE TRIGGER trg_au_tb_trilha
ON dbo.tb_trilha
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_trilha',
        CASE WHEN i.id_trilha IS NOT NULL AND d.id_trilha IS NULL THEN 'insert'
             WHEN i.id_trilha IS NOT NULL AND d.id_trilha IS NOT NULL THEN 'update'
             WHEN i.id_trilha IS NULL AND d.id_trilha IS NOT NULL THEN 'delete'
             ELSE 'unknown' END,
        'id_trilha=' + ISNULL(COALESCE(i.id_trilha,d.id_trilha),'') + '; '
        + 'nome_trilha(old)=' + ISNULL(d.nome_trilha,'') + ' -> nome_trilha(new)=' + ISNULL(i.nome_trilha,'') + '; '
        + 'quantidade_conteudo_trilha(old)=' + ISNULL(CONVERT(varchar(10), d.quantidade_conteudo_trilha),'') + ' -> quantidade_conteudo_trilha(new)=' + ISNULL(CONVERT(varchar(10), i.quantidade_conteudo_trilha),''),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_trilha = d.id_trilha;
END;
GO

/* tb_conteudo_trilha trigger */
IF OBJECT_ID('trg_au_tb_conteudo_trilha', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_conteudo_trilha;
GO
CREATE TRIGGER trg_au_tb_conteudo_trilha
ON dbo.tb_conteudo_trilha
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_conteudo_trilha',
        CASE WHEN i.id_conteudo_trilha IS NOT NULL AND d.id_conteudo_trilha IS NULL THEN 'insert'
             WHEN i.id_conteudo_trilha IS NOT NULL AND d.id_conteudo_trilha IS NOT NULL THEN 'update'
             WHEN i.id_conteudo_trilha IS NULL AND d.id_conteudo_trilha IS NOT NULL THEN 'delete'
             ELSE 'unknown' END,
        'id_conteudo_trilha=' + ISNULL(COALESCE(i.id_conteudo_trilha,d.id_conteudo_trilha),'') + '; '
        + 'nome_conteudo_trilha(old)=' + ISNULL(d.nome_conteudo_trilha,'') + ' -> (new)=' + ISNULL(i.nome_conteudo_trilha,'') + '; '
        + 'tipo_conteudo_trilha(old)=' + ISNULL(d.tipo_conteudo_trilha,'') + ' -> (new)=' + ISNULL(i.tipo_conteudo_trilha,'') + '; '
        + 'texto_conteudo_trilha(old)=' + ISNULL(LEFT(d.texto_conteudo_trilha,1000),'') + ' -> (new)=' + ISNULL(LEFT(i.texto_conteudo_trilha,1000),'') + '; '
        + 'id_trilha=' + ISNULL(COALESCE(i.id_trilha,d.id_trilha),''),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_conteudo_trilha = d.id_conteudo_trilha;
END;
GO

/* tb_conteudo_trilha_usuario trigger */
IF OBJECT_ID('trg_au_tb_conteudo_trilha_usuario', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_conteudo_trilha_usuario;
GO
CREATE TRIGGER trg_au_tb_conteudo_trilha_usuario
ON dbo.tb_conteudo_trilha_usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_conteudo_trilha_usuario',
        CASE WHEN i.id_conteudo_trilha_usuario IS NOT NULL AND d.id_conteudo_trilha_usuario IS NULL THEN 'insert'
             WHEN i.id_conteudo_trilha_usuario IS NOT NULL AND d.id_conteudo_trilha_usuario IS NOT NULL THEN 'update'
             WHEN i.id_conteudo_trilha_usuario IS NULL AND d.id_conteudo_trilha_usuario IS NOT NULL THEN 'delete'
             ELSE 'unknown' END,
        'id_conteudo_trilha_usuario=' + ISNULL(COALESCE(i.id_conteudo_trilha_usuario,d.id_conteudo_trilha_usuario),'') + '; '
        + 'conteudo_trilha_concluida_usuario(old)=' + ISNULL(d.conteudo_trilha_concluida_usuario,'') + ' -> (new)=' + ISNULL(i.conteudo_trilha_concluida_usuario,'') + '; '
        + 'id_usuario(old)=' + ISNULL(d.id_usuario,'') + ' -> (new)=' + ISNULL(i.id_usuario,'') + '; '
        + 'id_conteudo_trilha(old)=' + ISNULL(d.id_conteudo_trilha,'') + ' -> (new)=' + ISNULL(i.id_conteudo_trilha,''),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_conteudo_trilha_usuario = d.id_conteudo_trilha_usuario;
END;
GO

/* tb_trilha_usuario trigger */
IF OBJECT_ID('trg_au_tb_trilha_usuario', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_trilha_usuario;
GO
CREATE TRIGGER trg_au_tb_trilha_usuario
ON dbo.tb_trilha_usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_trilha_usuario',
        CASE WHEN i.id_trilha_usuario IS NOT NULL AND d.id_trilha_usuario IS NULL THEN 'insert'
             WHEN i.id_trilha_usuario IS NOT NULL AND d.id_trilha_usuario IS NOT NULL THEN 'update'
             WHEN i.id_trilha_usuario IS NULL AND d.id_trilha_usuario IS NOT NULL THEN 'delete'
             ELSE 'unknown' END,
        'id_trilha_usuario=' + ISNULL(COALESCE(i.id_trilha_usuario,d.id_trilha_usuario),'') + '; '
        + 'id_usuario(old)=' + ISNULL(d.id_usuario,'') + ' -> (new)=' + ISNULL(i.id_usuario,'') + '; '
        + 'id_trilha(old)=' + ISNULL(d.id_trilha,'') + ' -> (new)=' + ISNULL(i.id_trilha,'') + '; '
        + 'trilha_concluida_usuario(old)=' + ISNULL(d.trilha_concluida_usuario,'') + ' -> (new)=' + ISNULL(i.trilha_concluida_usuario,''),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_trilha_usuario = d.id_trilha_usuario;
END;
GO

/* tb_endereco_usuario trigger */
IF OBJECT_ID('trg_au_tb_endereco_usuario', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_endereco_usuario;
GO
CREATE TRIGGER trg_au_tb_endereco_usuario
ON dbo.tb_endereco_usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_endereco_usuario',
        CASE WHEN i.id_usuario IS NOT NULL AND d.id_usuario IS NULL THEN 'insert'
             WHEN i.id_usuario IS NOT NULL AND d.id_usuario IS NOT NULL THEN 'update'
             WHEN i.id_usuario IS NULL AND d.id_usuario IS NOT NULL THEN 'delete'
             ELSE 'unknown' END,
        'id_usuario=' + ISNULL(COALESCE(i.id_usuario,d.id_usuario),'') + '; '
        + 'cep_endereco(old)=' + ISNULL(d.cep_endereco,'') + ' -> (new)=' + ISNULL(i.cep_endereco,'') + '; '
        + 'logradouro_endereco(old)=' + ISNULL(d.logradouro_endereco,'') + ' -> (new)=' + ISNULL(i.logradouro_endereco,'') + '; '
        + 'estado_endereco(old)=' + ISNULL(d.estado_endereco,'') + ' -> (new)=' + ISNULL(i.estado_endereco,''),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_usuario = d.id_usuario;
END;
GO

/* tb_formulario_profissao_usuario trigger */
IF OBJECT_ID('trg_au_tb_formulario_profissao_usuario', 'TR') IS NOT NULL DROP TRIGGER trg_au_tb_formulario_profissao_usuario;
GO
CREATE TRIGGER trg_au_tb_formulario_profissao_usuario
ON dbo.tb_formulario_profissao_usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_auditoria (nome_tabela, operacao, registro, data_operacao)
    SELECT
        'tb_formulario_profissao_usuario',
        CASE WHEN i.id_usuario IS NOT NULL AND d.id_usuario IS NULL THEN 'insert'
             WHEN i.id_usuario IS NOT NULL AND d.id_usuario IS NOT NULL THEN 'update'
             WHEN i.id_usuario IS NULL AND d.id_usuario IS NOT NULL THEN 'delete'
             ELSE 'unknown' END,
        'id_usuario=' + ISNULL(COALESCE(i.id_usuario,d.id_usuario),'') + '; '
        + 'resposta_pergunta_1(old)=' + ISNULL(d.resposta_pergunta_1,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_1,'') + '; '
        + 'resposta_pergunta_2(old)=' + ISNULL(d.resposta_pergunta_2,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_2,'') + '; '
        + 'resposta_pergunta_3(old)=' + ISNULL(d.resposta_pergunta_3,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_3,'') + '; '
        + 'resposta_pergunta_4(old)=' + ISNULL(d.resposta_pergunta_4,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_4,'') + '; '
        + 'resposta_pergunta_5(old)=' + ISNULL(d.resposta_pergunta_5,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_5,'') + '; '
        + 'resposta_pergunta_6(old)=' + ISNULL(d.resposta_pergunta_6,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_6,'') + '; '
        + 'resposta_pergunta_7(old)=' + ISNULL(d.resposta_pergunta_7,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_7,'') + '; '
        + 'resposta_pergunta_8(old)=' + ISNULL(d.resposta_pergunta_8,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_8,'') + '; '
        + 'resposta_pergunta_9(old)=' + ISNULL(d.resposta_pergunta_9,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_9,'') + '; '
        + 'resposta_pergunta_10(old)=' + ISNULL(d.resposta_pergunta_10,'') + ' -> (new)=' + ISNULL(i.resposta_pergunta_10,'') + '; '
        + 'profissao_recomendada(old)=' + ISNULL(d.profissao_recomendada,'') + ' -> (new)=' + ISNULL(i.profissao_recomendada,''),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_usuario = d.id_usuario;
END;
GO

/* =========================
   Insert procedures (pkg_inserts)
   ========================= */

/* Procedure: inserir_usuario */
IF OBJECT_ID('sp_inserir_usuario', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_usuario;
GO
CREATE PROCEDURE sp_inserir_usuario
    @p_id_usuario varchar(36),
    @p_nome_usuario varchar(255),
    @p_email_usuario varchar(255),
    @p_senha_usuario varchar(255),
    @p_data_nascimento datetime2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_usuario (id_usuario, nome_usuario, email_usuario, senha_usuario, data_nascimento_usuario)
    VALUES (@p_id_usuario, @p_nome_usuario, @p_email_usuario, @p_senha_usuario, @p_data_nascimento);
END;
GO

/* Procedure: inserir_trilha */
IF OBJECT_ID('sp_inserir_trilha', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_trilha;
GO
CREATE PROCEDURE sp_inserir_trilha
    @p_id_trilha varchar(36),
    @p_nome_trilha varchar(200),
    @p_quantidade int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_trilha (id_trilha, nome_trilha, quantidade_conteudo_trilha)
    VALUES (@p_id_trilha, @p_nome_trilha, @p_quantidade);
END;
GO

/* Procedure: inserir_conteudo_trilha */
IF OBJECT_ID('sp_inserir_conteudo_trilha', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_conteudo_trilha;
GO
CREATE PROCEDURE sp_inserir_conteudo_trilha
    @p_id_conteudo_trilha varchar(36),
    @p_nome_conteudo_trilha varchar(200),
    @p_tipo_conteudo_trilha varchar(20),
    @p_texto_conteudo_trilha varchar(max),
    @p_id_trilha varchar(36)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_conteudo_trilha (id_conteudo_trilha, nome_conteudo_trilha, tipo_conteudo_trilha, texto_conteudo_trilha, id_trilha)
    VALUES (@p_id_conteudo_trilha, @p_nome_conteudo_trilha, @p_tipo_conteudo_trilha, @p_texto_conteudo_trilha, @p_id_trilha);
END;
GO

/* Procedure: inserir_conteudo_trilha_usuario */
IF OBJECT_ID('sp_inserir_conteudo_trilha_usuario', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_conteudo_trilha_usuario;
GO
CREATE PROCEDURE sp_inserir_conteudo_trilha_usuario
    @p_id_conteudo_trilha_usuario varchar(36),
    @p_concluida char(1),
    @p_id_usuario varchar(36),
    @p_id_conteudo_trilha varchar(36)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_conteudo_trilha_usuario (id_conteudo_trilha_usuario, conteudo_trilha_concluida_usuario, id_usuario, id_conteudo_trilha)
    VALUES (@p_id_conteudo_trilha_usuario, @p_concluida, @p_id_usuario, @p_id_conteudo_trilha);
END;
GO

/* Procedure: inserir_trilha_usuario */
IF OBJECT_ID('sp_inserir_trilha_usuario', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_trilha_usuario;
GO
CREATE PROCEDURE sp_inserir_trilha_usuario
    @p_id_trilha_usuario varchar(36),
    @p_id_usuario varchar(36),
    @p_id_trilha varchar(36),
    @p_concluida char(1)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_trilha_usuario (id_trilha_usuario, id_usuario, id_trilha, trilha_concluida_usuario)
    VALUES (@p_id_trilha_usuario, @p_id_usuario, @p_id_trilha, @p_concluida);
END;
GO

/* Procedure: inserir_endereco_usuario */
IF OBJECT_ID('sp_inserir_endereco_usuario', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_endereco_usuario;
GO
CREATE PROCEDURE sp_inserir_endereco_usuario
    @p_id_usuario varchar(36),
    @p_cep varchar(20),
    @p_logradouro varchar(200),
    @p_estado varchar(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_endereco_usuario (id_usuario, cep_endereco, logradouro_endereco, estado_endereco)
    VALUES (@p_id_usuario, @p_cep, @p_logradouro, @p_estado);
END;
GO

/* Procedure: inserir_formulario_profissao */
IF OBJECT_ID('sp_inserir_formulario_profissao', 'P') IS NOT NULL DROP PROCEDURE sp_inserir_formulario_profissao;
GO
CREATE PROCEDURE sp_inserir_formulario_profissao
    @p_id_usuario varchar(36),
    @p_p1 varchar(1000), @p_p2 varchar(1000), @p_p3 varchar(1000), @p_p4 varchar(1000), @p_p5 varchar(1000),
    @p_p6 varchar(1000), @p_p7 varchar(1000), @p_p8 varchar(1000), @p_p9 varchar(1000), @p_p10 varchar(1000),
    @p_recomendada varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.tb_formulario_profissao_usuario (
        id_usuario, resposta_pergunta_1, resposta_pergunta_2, resposta_pergunta_3, resposta_pergunta_4,
        resposta_pergunta_5, resposta_pergunta_6, resposta_pergunta_7, resposta_pergunta_8,
        resposta_pergunta_9, resposta_pergunta_10, profissao_recomendada
    )
    VALUES (
        @p_id_usuario, @p_p1, @p_p2, @p_p3, @p_p4, @p_p5, @p_p6, @p_p7, @p_p8, @p_p9, @p_p10, @p_recomendada
    );
END;
GO

/* =========================
   Functions / utilities (converted)
   - fn_to_json_trilhas_usuario_resumido -> sp_get_trilhas_usuario_resumido (@id_usuario)
   - fn_validar_usuario_e_progresso -> sp_validar_usuario_e_progresso (@id_usuario)
   ========================= */

/* Procedure: get trilhas resumo do usuário (retorna JSON) */
IF OBJECT_ID('sp_get_trilhas_usuario_resumido', 'P') IS NOT NULL DROP PROCEDURE sp_get_trilhas_usuario_resumido;
GO
CREATE PROCEDURE sp_get_trilhas_usuario_resumido
    @p_id_usuario varchar(36)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validate user exists
    IF NOT EXISTS (SELECT 1 FROM dbo.tb_usuario WHERE id_usuario = @p_id_usuario)
    BEGIN
        SELECT '{"error":"Usuário não encontrado"}' AS jsonResult;
        RETURN;
    END

    SELECT
        u.id_usuario   AS id_usuario,
        u.nome_usuario AS nome,
        u.email_usuario AS email,
        (
            SELECT
                t.id_trilha AS id_trilha,
                t.nome_trilha AS nome,
                t.quantidade_conteudo_trilha AS quantidade_conteudos,
                ISNULL(tu.trilha_concluida_usuario, 'N') AS trilha_concluida
            FROM dbo.tb_trilha_usuario tu
            INNER JOIN dbo.tb_trilha t ON t.id_trilha = tu.id_trilha
            WHERE tu.id_usuario = @p_id_usuario
            ORDER BY t.nome_trilha
            FOR JSON PATH
        ) AS trilhas
    FROM dbo.tb_usuario u
    WHERE u.id_usuario = @p_id_usuario
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

/* Procedure: validar usuario e progresso (retorna JSON com contagens e percentuais) */
IF OBJECT_ID('sp_validar_usuario_e_progresso', 'P') IS NOT NULL DROP PROCEDURE sp_validar_usuario_e_progresso;
GO
CREATE PROCEDURE sp_validar_usuario_e_progresso
    @p_id_usuario varchar(36)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_id_usuario IS NULL OR LEN(@p_id_usuario) = 0
    BEGIN
        SELECT '{"error":"ID do usuário não está em formato UUID válido."}' AS jsonResult;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.tb_usuario WHERE id_usuario = @p_id_usuario)
    BEGIN
        SELECT '{"error":"Usuário não encontrado no sistema."}' AS jsonResult;
        RETURN;
    END

    DECLARE @v_total_trilhas int = 0,
            @v_total_trilhas_conc int = 0,
            @v_percentual_trilhas int = 0,
            @v_total_conteudos int = 0,
            @v_total_conteudos_conc int = 0;

    SELECT @v_total_trilhas = COUNT(*) FROM dbo.tb_trilha_usuario WHERE id_usuario = @p_id_usuario;
    SELECT @v_total_trilhas_conc = COUNT(*) FROM dbo.tb_trilha_usuario WHERE id_usuario = @p_id_usuario AND trilha_concluida_usuario = 'S';

    SELECT @v_total_conteudos = COUNT(*) FROM dbo.tb_conteudo_trilha_usuario WHERE id_usuario = @p_id_usuario;
    SELECT @v_total_conteudos_conc = COUNT(*) FROM dbo.tb_conteudo_trilha_usuario WHERE id_usuario = @p_id_usuario AND conteudo_trilha_concluida_usuario = 'S';

    IF @v_total_trilhas > 0
        SET @v_percentual_trilhas = (@v_total_trilhas_conc * 100) / @v_total_trilhas;
    ELSE
        SET @v_percentual_trilhas = 0;

    /* Build result as JSON */
    SELECT
        @p_id_usuario AS id_usuario,
        (SELECT nome_usuario FROM dbo.tb_usuario WHERE id_usuario = @p_id_usuario) AS nome,
        (SELECT email_usuario FROM dbo.tb_usuario WHERE id_usuario = @p_id_usuario) AS email,
        (
            SELECT
                @v_total_trilhas AS total,
                @v_total_trilhas_conc AS concluidas,
                @v_percentual_trilhas AS percentual
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS progresso_trilhas,
        (
            SELECT
                @v_total_conteudos AS total,
                @v_total_conteudos_conc AS concluidos
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS progresso_conteudos
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

/* Procedure: prc_gerar_json_trilhas_todos -> prints/returns a JSON array of all users -> using FOR JSON PATH */
IF OBJECT_ID('sp_gerar_json_trilhas_todos', 'P') IS NOT NULL DROP PROCEDURE sp_gerar_json_trilhas_todos;
GO
CREATE PROCEDURE sp_gerar_json_trilhas_todos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.id_usuario,
        u.nome_usuario AS nome,
        u.email_usuario AS email,
        (
            SELECT
                t.id_trilha AS id_trilha,
                t.nome_trilha AS nome,
                t.quantidade_conteudo_trilha AS quantidade_conteudos,
                ISNULL(tu.trilha_concluida_usuario,'N') AS trilha_concluida
            FROM dbo.tb_trilha_usuario tu
            INNER JOIN dbo.tb_trilha t ON t.id_trilha = tu.id_trilha
            WHERE tu.id_usuario = u.id_usuario
            ORDER BY t.nome_trilha
            FOR JSON PATH
        ) AS trilhas
    FROM dbo.tb_usuario u
    ORDER BY u.nome_usuario
    FOR JSON PATH;
END;
GO

/* =========================
   Sample data insertion (converted inserts)
   replacing sys_guid() -> NEWID(), systimestamp -> SYSDATETIME()
   NOTE: In original Oracle file there are many block inserts using pkg_inserts procedures.
   We'll provide an equivalent T-SQL block that uses the procedures above.
   You can uncomment and run to populate sample data.
   ========================= */

/* Example population block - adapt GUIDs as necessary */
/*
EXEC sp_inserir_trilha 'f0c9f1b4-0cc9-44b3-b3da-7e51d241a4f5', 'Introdução ao Futuro do Trabalho', 3;
EXEC sp_inserir_trilha '4c9eaa09-e28f-4f8f-a887-6b23fd2d1303', 'Inteligência Artificial Aplicada', 3;
EXEC sp_inserir_trilha '0a170d80-cb63-4bb7-83d5-2a46f58fcd88', 'Habilidades Digitais Essenciais', 3;
-- ... continue inserting trilhas ...

EXEC sp_inserir_usuario 'b0a5f2e7-879c-4a13-82ab-71f1b716de11','Ana Silva','ana@email.com','senha1', SYSDATETIME();
EXEC sp_inserir_usuario '5e5fc7b4-863d-4e8a-b0bb-c93a4360f972','João Prado','joao@email.com','senha2', SYSDATETIME();
-- ... continue inserting users ...
*/

/* =========================
   Utilities: sample select using the JSON procs
   ========================= */
/*
-- Get one user summary as JSON
EXEC sp_get_trilhas_usuario_resumido 'b0a5f2e7-879c-4a13-82ab-71f1b716de11';

-- Get progress JSON for a user
EXEC sp_validar_usuario_e_progresso 'b0a5f2e7-879c-4a13-82ab-71f1b716de11';

-- Generate all users trilhas JSON
EXEC sp_gerar_json_trilhas_todos;
*/

-- End of conversion script
