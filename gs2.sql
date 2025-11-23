set verify off;
set serveroutput on;

drop table tb_conteudo_trilha_usuario cascade constraints;
drop table tb_conteudo_trilha cascade constraints;
drop table tb_formulario_profissao_usuario cascade constraints;
drop table tb_endereco_usuario cascade constraints;
drop table tb_trilha_usuario cascade constraints;
drop table tb_trilha cascade constraints;
drop table tb_usuario cascade constraints;
drop table tb_auditoria cascade constraints;

create table tb_usuario (
    id_usuario              varchar2(36)  not null,
    nome_usuario            varchar2(255) not null,
    email_usuario           varchar2(255) not null,
    senha_usuario           varchar2(255) not null,
    data_nascimento_usuario timestamp     not null,

    constraint tb_usuario_id_usuario_pk primary key (id_usuario)
);


create table tb_trilha (
    id_trilha                  varchar2(36)  not null,
    nome_trilha                varchar2(200) not null,
    quantidade_conteudo_trilha number        not null,

    constraint tb_trilha_id_trilha_pk primary key (id_trilha)
);


create table tb_conteudo_trilha (
    id_conteudo_trilha          varchar2(36)   not null,
    nome_conteudo_trilha        varchar2(200)  not null,
    tipo_conteudo_trilha        varchar2(20)   not null,
    texto_conteudo_trilha       varchar2(3000) not null,
    id_trilha                   varchar2(36)   not null,

    constraint tb_conteudo_trilha_id_conteudo_trilha_pk primary key (id_conteudo_trilha),
    constraint tb_conteudo_trilha_id_trilha_fk foreign key (id_trilha)
        references tb_trilha (id_trilha)
);


create table tb_conteudo_trilha_usuario (
    id_conteudo_trilha_usuario        varchar2(36) not null,
    conteudo_trilha_concluida_usuario char(1),
    id_usuario                        varchar2(36) not null,
    id_conteudo_trilha                varchar2(36) not null,

    constraint tb_conteudo_trilha_usuario_id_conteudo_trilha_usuario_pk primary key (id_conteudo_trilha_usuario),
    constraint tb_conteudo_trilha_usuario_id_conteudo_trilha foreign key (id_conteudo_trilha)
        references tb_conteudo_trilha (id_conteudo_trilha),
    constraint tb_conteudo_trilha_usuario_id_usuario foreign key (id_usuario)
        references tb_usuario (id_usuario)
);


create table tb_endereco_usuario (
    id_usuario          varchar2(36) not null,
    cep_endereco        varchar2(20) not null,
    logradouro_endereco varchar2(200),
    estado_endereco     varchar2(200),

    constraint tb_endereco_usuario_id_usuario_pk primary key (id_usuario),
    constraint tb_endereco_usuario_id_usuario_fk foreign key (id_usuario)
        references tb_usuario (id_usuario)
);


create table tb_formulario_profissao_usuario (
    id_usuario            varchar2(36) not null,
    resposta_pergunta_1   varchar2(1000),
    resposta_pergunta_2   varchar2(1000),
    resposta_pergunta_3   varchar2(1000),
    resposta_pergunta_4   varchar2(1000),
    resposta_pergunta_5   varchar2(1000),
    resposta_pergunta_6   varchar2(1000),
    resposta_pergunta_7   varchar2(1000),
    resposta_pergunta_8   varchar2(1000),
    resposta_pergunta_9   varchar2(1000),
    resposta_pergunta_10  varchar2(1000),
    profissao_recomendada varchar2(100),

    constraint tb_formulario_profissao_usuario_id_usuario_pk primary key (id_usuario),
    constraint tb_formulario_profissao_usuario_id_usuario_fk foreign key (id_usuario)
        references tb_usuario (id_usuario)
);


create table tb_trilha_usuario (
    id_trilha_usuario        varchar2(36) not null,
    id_usuario               varchar2(36) not null,
    id_trilha                varchar2(36) not null,
    trilha_concluida_usuario char(1),

    constraint tb_trilha_usuario_id_trilha_usuario_pk primary key (id_trilha_usuario),
    constraint tb_trilha_usuario_id_trilha_fk foreign key (id_trilha)
        references tb_trilha (id_trilha),
    constraint tb_trilha_usuario_id_usuario_fk foreign key (id_usuario)
        references tb_usuario (id_usuario)
);


-- AUDITORIA

create table tb_auditoria (
    id_auditoria    varchar2(36) default sys_guid() primary key,
    nome_tabela     varchar2(100),
    operacao        varchar2(10),
    registro        varchar2(3000),
    data_operacao   timestamp
);

create or replace trigger trg_au_tb_usuario
after insert or update or delete on tb_usuario
for each row
declare
    v_registro varchar2(32767);
    v_old_dt   varchar2(19);
    v_new_dt   varchar2(19);
begin
    -- formata datas para string (evita null concatenation)
    if :old.data_nascimento_usuario is not null then
        v_old_dt := to_char(:old.data_nascimento_usuario, 'yyyy-mm-dd hh24:mi:ss');
    else
        v_old_dt := null;
    end if;

    if :new.data_nascimento_usuario is not null then
        v_new_dt := to_char(:new.data_nascimento_usuario, 'yyyy-mm-dd hh24:mi:ss');
    else
        v_new_dt := null;
    end if;

    if inserting then
        v_registro :=
              'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'nome_usuario=' || nvl(:new.nome_usuario, '') || '; '
            || 'email_usuario=' || nvl(:new.email_usuario, '') || '; '
            || 'senha_usuario=' || nvl(:new.senha_usuario, '') || '; '
            || 'data_nascimento_usuario=' || nvl(v_new_dt, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_usuario', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'nome_usuario(old)=' || nvl(:old.nome_usuario, '') || ' -> nome_usuario(new)=' || nvl(:new.nome_usuario, '') || '; '
            || 'email_usuario(old)=' || nvl(:old.email_usuario, '') || ' -> email_usuario(new)=' || nvl(:new.email_usuario, '') || '; '
            || 'senha_usuario(old)=' || nvl(:old.senha_usuario, '') || ' -> senha_usuario(new)=' || nvl(:new.senha_usuario, '') || '; '
            || 'data_nascimento_usuario(old)=' || nvl(v_old_dt, '') || ' -> data_nascimento_usuario(new)=' || nvl(v_new_dt, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_usuario', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_usuario=' || nvl(:old.id_usuario, '') || '; '
            || 'nome_usuario=' || nvl(:old.nome_usuario, '') || '; '
            || 'email_usuario=' || nvl(:old.email_usuario, '') || '; '
            || 'senha_usuario=' || nvl(:old.senha_usuario, '') || '; '
            || 'data_nascimento_usuario=' || nvl(v_old_dt, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_usuario', 'delete', v_registro, systimestamp);
    end if;
end;
/

create or replace trigger trg_au_tb_trilha
after insert or update or delete on tb_trilha
for each row
declare
    v_registro varchar2(32767);
begin
    if inserting then
        v_registro :=
              'id_trilha=' || nvl(:new.id_trilha, '') || '; '
            || 'nome_trilha=' || nvl(:new.nome_trilha, '') || '; '
            || 'quantidade_conteudo_trilha=' || nvl(to_char(:new.quantidade_conteudo_trilha), '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_trilha', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_trilha=' || nvl(:new.id_trilha, '') || '; '
            || 'nome_trilha(old)=' || nvl(:old.nome_trilha, '') 
            || ' -> nome_trilha(new)=' || nvl(:new.nome_trilha, '') || '; '
            || 'quantidade_conteudo_trilha(old)=' || nvl(to_char(:old.quantidade_conteudo_trilha), '')
            || ' -> quantidade_conteudo_trilha(new)=' || nvl(to_char(:new.quantidade_conteudo_trilha), '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_trilha', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_trilha=' || nvl(:old.id_trilha, '') || '; '
            || 'nome_trilha=' || nvl(:old.nome_trilha, '') || '; '
            || 'quantidade_conteudo_trilha=' || nvl(to_char(:old.quantidade_conteudo_trilha), '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_trilha', 'delete', v_registro, systimestamp);
    end if;
end;
/

create or replace trigger trg_au_tb_conteudo_trilha
after insert or update or delete on tb_conteudo_trilha
for each row
declare
    v_registro varchar2(32767);
begin
    if inserting then
        v_registro :=
              'id_conteudo_trilha=' || nvl(:new.id_conteudo_trilha, '') || '; '
            || 'nome_conteudo_trilha=' || nvl(:new.nome_conteudo_trilha, '') || '; '
            || 'tipo_conteudo_trilha=' || nvl(:new.tipo_conteudo_trilha, '') || '; '
            || 'texto_conteudo_trilha=' || nvl(:new.texto_conteudo_trilha, '') || '; '
            || 'id_trilha=' || nvl(:new.id_trilha, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_conteudo_trilha', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_conteudo_trilha=' || nvl(:new.id_conteudo_trilha, '') || '; '
            || 'nome_conteudo_trilha(old)=' || nvl(:old.nome_conteudo_trilha, '') 
            || ' -> (new)=' || nvl(:new.nome_conteudo_trilha, '') || '; '
            || 'tipo_conteudo_trilha(old)=' || nvl(:old.tipo_conteudo_trilha, '') 
            || ' -> (new)=' || nvl(:new.tipo_conteudo_trilha, '') || '; '
            || 'texto_conteudo_trilha(old)=' || nvl(:old.texto_conteudo_trilha, '') 
            || ' -> (new)=' || nvl(:new.texto_conteudo_trilha, '') || '; '
            || 'id_trilha(old)=' || nvl(:old.id_trilha, '') 
            || ' -> (new)=' || nvl(:new.id_trilha, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_conteudo_trilha', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_conteudo_trilha=' || nvl(:old.id_conteudo_trilha, '') || '; '
            || 'nome_conteudo_trilha=' || nvl(:old.nome_conteudo_trilha, '') || '; '
            || 'tipo_conteudo_trilha=' || nvl(:old.tipo_conteudo_trilha, '') || '; '
            || 'texto_conteudo_trilha=' || nvl(:old.texto_conteudo_trilha, '') || '; '
            || 'id_trilha=' || nvl(:old.id_trilha, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_conteudo_trilha', 'delete', v_registro, systimestamp);
    end if;
end;
/

create or replace trigger trg_au_tb_conteudo_trilha_usuario
after insert or update or delete on tb_conteudo_trilha_usuario
for each row
declare
    v_registro varchar2(32767);
begin
    if inserting then
        v_registro :=
              'id_conteudo_trilha_usuario=' || nvl(:new.id_conteudo_trilha_usuario, '') || '; '
            || 'conteudo_trilha_concluida_usuario=' || nvl(:new.conteudo_trilha_concluida_usuario, '') || '; '
            || 'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'id_conteudo_trilha=' || nvl(:new.id_conteudo_trilha, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_conteudo_trilha_usuario', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_conteudo_trilha_usuario=' || nvl(:new.id_conteudo_trilha_usuario, '') || '; '
            || 'conteudo_trilha_concluida_usuario(old)=' || nvl(:old.conteudo_trilha_concluida_usuario, '')
            || ' -> (new)=' || nvl(:new.conteudo_trilha_concluida_usuario, '') || '; '
            || 'id_usuario(old)=' || nvl(:old.id_usuario, '')
            || ' -> (new)=' || nvl(:new.id_usuario, '') || '; '
            || 'id_conteudo_trilha(old)=' || nvl(:old.id_conteudo_trilha, '')
            || ' -> (new)=' || nvl(:new.id_conteudo_trilha, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_conteudo_trilha_usuario', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_conteudo_trilha_usuario=' || nvl(:old.id_conteudo_trilha_usuario, '') || '; '
            || 'conteudo_trilha_concluida_usuario=' || nvl(:old.conteudo_trilha_concluida_usuario, '') || '; '
            || 'id_usuario=' || nvl(:old.id_usuario, '') || '; '
            || 'id_conteudo_trilha=' || nvl(:old.id_conteudo_trilha, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_conteudo_trilha_usuario', 'delete', v_registro, systimestamp);
    end if;
end;
/

create or replace trigger trg_au_tb_endereco_usuario
after insert or update or delete on tb_endereco_usuario
for each row
declare
    v_registro varchar2(32767);
begin
    if inserting then
        v_registro :=
              'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'cep_endereco=' || nvl(:new.cep_endereco, '') || '; '
            || 'logradouro_endereco=' || nvl(:new.logradouro_endereco, '') || '; '
            || 'estado_endereco=' || nvl(:new.estado_endereco, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_endereco_usuario', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'cep_endereco(old)=' || nvl(:old.cep_endereco, '') 
            || ' -> (new)=' || nvl(:new.cep_endereco, '') || '; '
            || 'logradouro_endereco(old)=' || nvl(:old.logradouro_endereco, '') 
            || ' -> (new)=' || nvl(:new.logradouro_endereco, '') || '; '
            || 'estado_endereco(old)=' || nvl(:old.estado_endereco, '') 
            || ' -> (new)=' || nvl(:new.estado_endereco, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_endereco_usuario', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_usuario=' || nvl(:old.id_usuario, '') || '; '
            || 'cep_endereco=' || nvl(:old.cep_endereco, '') || '; '
            || 'logradouro_endereco=' || nvl(:old.logradouro_endereco, '') || '; '
            || 'estado_endereco=' || nvl(:old.estado_endereco, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_endereco_usuario', 'delete', v_registro, systimestamp);
    end if;
end;
/

create or replace trigger trg_au_tb_formulario_profissao_usuario
after insert or update or delete on tb_formulario_profissao_usuario
for each row
declare
    v_registro varchar2(32767);
begin
    if inserting then
        v_registro :=
              'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'resposta_pergunta_1=' || nvl(:new.resposta_pergunta_1, '') || '; '
            || 'resposta_pergunta_2=' || nvl(:new.resposta_pergunta_2, '') || '; '
            || 'resposta_pergunta_3=' || nvl(:new.resposta_pergunta_3, '') || '; '
            || 'resposta_pergunta_4=' || nvl(:new.resposta_pergunta_4, '') || '; '
            || 'resposta_pergunta_5=' || nvl(:new.resposta_pergunta_5, '') || '; '
            || 'resposta_pergunta_6=' || nvl(:new.resposta_pergunta_6, '') || '; '
            || 'resposta_pergunta_7=' || nvl(:new.resposta_pergunta_7, '') || '; '
            || 'resposta_pergunta_8=' || nvl(:new.resposta_pergunta_8, '') || '; '
            || 'resposta_pergunta_9=' || nvl(:new.resposta_pergunta_9, '') || '; '
            || 'resposta_pergunta_10=' || nvl(:new.resposta_pergunta_10, '') || '; '
            || 'profissao_recomendada=' || nvl(:new.profissao_recomendada, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_formulario_profissao_usuario', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'resposta_pergunta_1(old)=' || nvl(:old.resposta_pergunta_1, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_1, '') || '; '
            || 'resposta_pergunta_2(old)=' || nvl(:old.resposta_pergunta_2, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_2, '') || '; '
            || 'resposta_pergunta_3(old)=' || nvl(:old.resposta_pergunta_3, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_3, '') || '; '
            || 'resposta_pergunta_4(old)=' || nvl(:old.resposta_pergunta_4, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_4, '') || '; '
            || 'resposta_pergunta_5(old)=' || nvl(:old.resposta_pergunta_5, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_5, '') || '; '
            || 'resposta_pergunta_6(old)=' || nvl(:old.resposta_pergunta_6, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_6, '') || '; '
            || 'resposta_pergunta_7(old)=' || nvl(:old.resposta_pergunta_7, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_7, '') || '; '
            || 'resposta_pergunta_8(old)=' || nvl(:old.resposta_pergunta_8, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_8, '') || '; '
            || 'resposta_pergunta_9(old)=' || nvl(:old.resposta_pergunta_9, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_9, '') || '; '
            || 'resposta_pergunta_10(old)=' || nvl(:old.resposta_pergunta_10, '') || ' -> (new)=' || nvl(:new.resposta_pergunta_10, '') || '; '
            || 'profissao_recomendada(old)=' || nvl(:old.profissao_recomendada, '') || ' -> (new)=' || nvl(:new.profissao_recomendada, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_formulario_profissao_usuario', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_usuario=' || nvl(:old.id_usuario, '') || '; '
            || 'resposta_pergunta_1=' || nvl(:old.resposta_pergunta_1, '') || '; '
            || 'resposta_pergunta_2=' || nvl(:old.resposta_pergunta_2, '') || '; '
            || 'resposta_pergunta_3=' || nvl(:old.resposta_pergunta_3, '') || '; '
            || 'resposta_pergunta_4=' || nvl(:old.resposta_pergunta_4, '') || '; '
            || 'resposta_pergunta_5=' || nvl(:old.resposta_pergunta_5, '') || '; '
            || 'resposta_pergunta_6=' || nvl(:old.resposta_pergunta_6, '') || '; '
            || 'resposta_pergunta_7=' || nvl(:old.resposta_pergunta_7, '') || '; '
            || 'resposta_pergunta_8=' || nvl(:old.resposta_pergunta_8, '') || '; '
            || 'resposta_pergunta_9=' || nvl(:old.resposta_pergunta_9, '') || '; '
            || 'resposta_pergunta_10=' || nvl(:old.resposta_pergunta_10, '') || '; '
            || 'profissao_recomendada=' || nvl(:old.profissao_recomendada, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_formulario_profissao_usuario', 'delete', v_registro, systimestamp);
    end if;
end;
/



create or replace trigger trg_au_tb_trilha_usuario
after insert or update or delete on tb_trilha_usuario
for each row
declare
    v_registro varchar2(32767);
begin
    if inserting then
        v_registro :=
              'id_trilha_usuario=' || nvl(:new.id_trilha_usuario, '') || '; '
            || 'id_usuario=' || nvl(:new.id_usuario, '') || '; '
            || 'id_trilha=' || nvl(:new.id_trilha, '') || '; '
            || 'trilha_concluida_usuario=' || nvl(:new.trilha_concluida_usuario, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_trilha_usuario', 'insert', v_registro, systimestamp);

    elsif updating then
        v_registro :=
              'id_trilha_usuario=' || nvl(:new.id_trilha_usuario, '') || '; '
            || 'id_usuario(old)=' || nvl(:old.id_usuario, '') 
            || ' -> (new)=' || nvl(:new.id_usuario, '') || '; '
            || 'id_trilha(old)=' || nvl(:old.id_trilha, '') 
            || ' -> (new)=' || nvl(:new.id_trilha, '') || '; '
            || 'trilha_concluida_usuario(old)=' || nvl(:old.trilha_concluida_usuario, '') 
            || ' -> (new)=' || nvl(:new.trilha_concluida_usuario, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_trilha_usuario', 'update', v_registro, systimestamp);

    elsif deleting then
        v_registro :=
              'id_trilha_usuario=' || nvl(:old.id_trilha_usuario, '') || '; '
            || 'id_usuario=' || nvl(:old.id_usuario, '') || '; '
            || 'id_trilha=' || nvl(:old.id_trilha, '') || '; '
            || 'trilha_concluida_usuario=' || nvl(:old.trilha_concluida_usuario, '');

        insert into tb_auditoria (nome_tabela, operacao, registro, data_operacao)
        values ('tb_trilha_usuario', 'delete', v_registro, systimestamp);
    end if;
end;
/



-- INSERTS

create or replace package pkg_inserts as
    procedure inserir_usuario(
        p_id_usuario in varchar2,
        p_nome_usuario in varchar2,
        p_email_usuario in varchar2,
        p_senha_usuario in varchar2,
        p_data_nascimento in timestamp
    );

    procedure inserir_trilha(
        p_id_trilha in varchar2,
        p_nome_trilha in varchar2,
        p_qtd_conteudo in varchar2
    );

    procedure inserir_conteudo_trilha(
        p_id_conteudo in varchar2,
        p_nome_conteudo in varchar2,
        p_tipo_conteudo in varchar2,
        p_texto_conteudo in varchar2,
        p_id_trilha in varchar2
    );

    procedure inserir_conteudo_trilha_usuario(
        p_id_ctu in varchar2,
        p_concluido in char,
        p_id_usuario in varchar2,
        p_id_conteudo in varchar2
    );

    procedure inserir_endereco_usuario(
        p_id_usuario in varchar2,
        p_cep in varchar2,
        p_logradouro in varchar2,
        p_estado in varchar2
    );

    procedure inserir_formulario_profissao(
        p_id_usuario in varchar2,
        p_p1 in varchar2,
        p_p2 in varchar2,
        p_p3 in varchar2,
        p_p4 in varchar2,
        p_p5 in varchar2,
        p_p6 in varchar2,
        p_p7 in varchar2,
        p_p8 in varchar2,
        p_p9 in varchar2,
        p_p10 in varchar2,
        p_recomendada in varchar2
    );

    procedure inserir_trilha_usuario(
        p_id_trilha_usuario in varchar2,
        p_id_usuario in varchar2,
        p_id_trilha in varchar2,
        p_concluida in char
    );
end pkg_inserts;
/

create or replace package body pkg_inserts as

    procedure inserir_usuario(
        p_id_usuario in varchar2,
        p_nome_usuario in varchar2,
        p_email_usuario in varchar2,
        p_senha_usuario in varchar2,
        p_data_nascimento in timestamp
    ) as
    begin
        insert into tb_usuario (
            id_usuario, nome_usuario, email_usuario, senha_usuario, data_nascimento_usuario
        ) values (
            p_id_usuario, p_nome_usuario, p_email_usuario, p_senha_usuario, p_data_nascimento
        );
    end inserir_usuario;


    procedure inserir_trilha(
        p_id_trilha in varchar2,
        p_nome_trilha in varchar2,
        p_qtd_conteudo in varchar2
    ) as
    begin
        insert into tb_trilha (
            id_trilha, nome_trilha, quantidade_conteudo_trilha
        ) values (
            p_id_trilha, p_nome_trilha, p_qtd_conteudo
        );
    end inserir_trilha;


    procedure inserir_conteudo_trilha(
        p_id_conteudo in varchar2,
        p_nome_conteudo in varchar2,
        p_tipo_conteudo in varchar2,
        p_texto_conteudo in varchar2,
        p_id_trilha in varchar2
    ) as
    begin
        insert into tb_conteudo_trilha (
            id_conteudo_trilha, nome_conteudo_trilha, tipo_conteudo_trilha, texto_conteudo_trilha, id_trilha
        ) values (
            p_id_conteudo, p_nome_conteudo, p_tipo_conteudo, p_texto_conteudo, p_id_trilha
        );
    end inserir_conteudo_trilha;


    procedure inserir_conteudo_trilha_usuario(
        p_id_ctu in varchar2,
        p_concluido in char,
        p_id_usuario in varchar2,
        p_id_conteudo in varchar2
    ) as
    begin
        insert into tb_conteudo_trilha_usuario(
            id_conteudo_trilha_usuario, conteudo_trilha_concluida_usuario,
            id_usuario, id_conteudo_trilha
        ) values (
            p_id_ctu, p_concluido, p_id_usuario, p_id_conteudo
        );
    end inserir_conteudo_trilha_usuario;


    procedure inserir_endereco_usuario(
        p_id_usuario in varchar2,
        p_cep in varchar2,
        p_logradouro in varchar2,
        p_estado in varchar2
    ) as
    begin
        insert into tb_endereco_usuario(
            id_usuario, cep_endereco, logradouro_endereco, estado_endereco
        ) values (
            p_id_usuario, p_cep, p_logradouro, p_estado
        );
    end inserir_endereco_usuario;


    procedure inserir_formulario_profissao(
        p_id_usuario in varchar2,
        p_p1 in varchar2,
        p_p2 in varchar2,
        p_p3 in varchar2,
        p_p4 in varchar2,
        p_p5 in varchar2,
        p_p6 in varchar2,
        p_p7 in varchar2,
        p_p8 in varchar2,
        p_p9 in varchar2,
        p_p10 in varchar2,
        p_recomendada in varchar2
    ) as
    begin
        insert into tb_formulario_profissao_usuario(
            id_usuario, resposta_pergunta_1, resposta_pergunta_2,
            resposta_pergunta_3, resposta_pergunta_4, resposta_pergunta_5,
            resposta_pergunta_6, resposta_pergunta_7, resposta_pergunta_8,
            resposta_pergunta_9, resposta_pergunta_10, profissao_recomendada
        ) values (
            p_id_usuario, p_p1, p_p2, p_p3, p_p4, p_p5, p_p6, p_p7,
            p_p8, p_p9, p_p10, p_recomendada
        );
    end inserir_formulario_profissao;


    procedure inserir_trilha_usuario(
        p_id_trilha_usuario in varchar2,
        p_id_usuario in varchar2,
        p_id_trilha in varchar2,
        p_concluida in char
    ) as
    begin
        insert into tb_trilha_usuario (
            id_trilha_usuario, id_usuario, id_trilha, trilha_concluida_usuario
        ) values (
            p_id_trilha_usuario, p_id_usuario, p_id_trilha, p_concluida
        );
    end inserir_trilha_usuario;

end pkg_inserts;
/

declare
    v_u1  varchar2(36) := 'b0a5f2e7-879c-4a13-82ab-71f1b716de11';
    v_u2  varchar2(36) := '5e5fc7b4-863d-4e8a-b0bb-c93a4360f972';
    v_u3  varchar2(36) := 'd1e1faf0-1f4b-4e5e-b20e-61c1ea2cfa16';
    v_u4  varchar2(36) := 'a8c98cb7-2477-4a77-9b18-d4c2c843d814';
    v_u5  varchar2(36) := '1fd6c2a0-5ed9-4c8b-9e8c-85bc03f3e4d5';
    v_u6  varchar2(36) := 'e2a0b2f5-32d6-412d-af4c-917b1f5fb35d';
    v_u7  varchar2(36) := '07db33ad-fd10-4ef0-bc0b-30a69e6ac72d';
    v_u8  varchar2(36) := '6bcff902-6e51-4a97-a7f3-3630b8979a2d';
    v_u9  varchar2(36) := '3f29cdf1-4658-4fa4-81ef-d51ff6cba93b';
    v_u10 varchar2(36) := 'c82ae200-0df6-4f6c-887a-a69e502435f8';
begin
    pkg_inserts.inserir_usuario(v_u1,  'Ana Silva',         'ana@email.com',     'senha1',  systimestamp);
    pkg_inserts.inserir_usuario(v_u2,  'João Prado',        'joao@email.com',    'senha2',  systimestamp);
    pkg_inserts.inserir_usuario(v_u3,  'Marina Costa',      'marina@email.com',  'senha3',  systimestamp);
    pkg_inserts.inserir_usuario(v_u4,  'Pedro Gomes',       'pedro@email.com',   'senha4',  systimestamp);
    pkg_inserts.inserir_usuario(v_u5,  'Carla Melo',        'carla@email.com',   'senha5',  systimestamp);
    pkg_inserts.inserir_usuario(v_u6,  'Lucas Vieira',      'lucas@email.com',   'senha6',  systimestamp);
    pkg_inserts.inserir_usuario(v_u7,  'Fernanda Dias',     'fernanda@email.com','senha7',  systimestamp);
    pkg_inserts.inserir_usuario(v_u8,  'Gustavo Azevedo',   'guga@email.com',    'senha8',  systimestamp);
    pkg_inserts.inserir_usuario(v_u9,  'Aline Braga',       'aline@email.com',   'senha9',  systimestamp);
    pkg_inserts.inserir_usuario(v_u10, 'Ricardo Matos',     'ricardo@email.com', 'senha10', systimestamp);
end;
/

declare
    t1  varchar2(36) := 'f0c9f1b4-0cc9-44b3-b3da-7e51d241a4f5';
    t2  varchar2(36) := '4c9eaa09-e28f-4f8f-a887-6b23fd2d1303';
    t3  varchar2(36) := '0a170d80-cb63-4bb7-83d5-2a46f58fcd88';
    t4  varchar2(36) := 'abfaadcb-eaf7-4fef-aa3b-e3c99e257a6d';
    t5  varchar2(36) := 'ae8d00b7-3580-4c2a-b88e-734af5c30921';
    t6  varchar2(36) := '95c907e1-5b3f-45b2-9bf0-10f2ade753f2';
    t7  varchar2(36) := 'f45b7fa3-52e5-455c-80be-68b52ca90212';
    t8  varchar2(36) := '024b5f75-a237-4e52-9cb5-66a3e655f6df';
    t9  varchar2(36) := 'b337644e-eb7d-44b4-8c31-77ef4d9a9032';
    t10 varchar2(36) := 'dcc7cd01-414b-4a4f-bf6b-4bc62e56b7cb';
begin
    pkg_inserts.inserir_trilha(t1,  'Introdução ao Futuro do Trabalho', 3);
    pkg_inserts.inserir_trilha(t2,  'Inteligência Artificial Aplicada', 3);
    pkg_inserts.inserir_trilha(t3,  'Habilidades Digitais Essenciais', 3);
    pkg_inserts.inserir_trilha(t4,  'Carreira em Tecnologia', 2);
    pkg_inserts.inserir_trilha(t5,  'Empreendedorismo Moderno', 2);
    pkg_inserts.inserir_trilha(t6,  'Produtividade e Organização', 2);
    pkg_inserts.inserir_trilha(t7,  'Soft Skills do Futuro', 3);
    pkg_inserts.inserir_trilha(t8,  'Dados e Analytics', 2);
    pkg_inserts.inserir_trilha(t9,  'Criatividade e Inovação', 2);
    pkg_inserts.inserir_trilha(t10, 'Liderança e Gestão', 3);
end;
/

declare
    t1  varchar2(36) := 'f0c9f1b4-0cc9-44b3-b3da-7e51d241a4f5';
    t2  varchar2(36) := '4c9eaa09-e28f-4f8f-a887-6b23fd2d1303';
    t3  varchar2(36) := '0a170d80-cb63-4bb7-83d5-2a46f58fcd88';
    t4  varchar2(36) := 'abfaadcb-eaf7-4fef-aa3b-e3c99e257a6d';
    t5  varchar2(36) := 'ae8d00b7-3580-4c2a-b88e-734af5c30921';
    t6  varchar2(36) := '95c907e1-5b3f-45b2-9bf0-10f2ade753f2';
    t7  varchar2(36) := 'f45b7fa3-52e5-455c-80be-68b52ca90212';
    t8  varchar2(36) := '024b5f75-a237-4e52-9cb5-66a3e655f6df';
    t9  varchar2(36) := 'b337644e-eb7d-44b4-8c31-77ef4d9a9032';
    t10 varchar2(36) := 'dcc7cd01-414b-4a4f-bf6b-4bc62e56b7cb';
begin
    pkg_inserts.inserir_conteudo_trilha(
        '9a7f2d1b-3c2a-4b9f-8a47-1e0c5d2a9f11',
        'Tendências e Contexto',
        'Vídeo',
        'https://www.youtube.com/watch?v=Lbk-EDaySmw',
        t1
    );
    pkg_inserts.inserir_conteudo_trilha(
        '2b8c6e3d-7f1a-4d2b-ab12-3f8a6d4c2b22',
        'Habilidades Essenciais',
        'Artigo',
        'No cenário profissional contemporâneo, onde mudanças acontecem em ritmo acelerado e novas tecnologias surgem a todo momento, desenvolver habilidades essenciais deixou de ser apenas uma vantagem competitiva — tornou-se um requisito fundamental para qualquer pessoa que deseja se manter relevante no mercado de trabalho. Essas habilidades, que combinam competências técnicas e comportamentais, formam a base para que profissionais possam se adaptar, inovar e assumir papéis cada vez mais estratégicos dentro das organizações.

        Entre as habilidades técnicas mais valorizadas atualmente, destacam-se a capacidade de analisar dados, compreender fluxos digitais e utilizar ferramentas de automação para otimizar processos. Com a crescente presença da inteligência artificial em diferentes setores, entender conceitos básicos de aprendizado de máquina, análise preditiva e integrações tecnológicas também se tornou um diferencial significativo. No entanto, tão importante quanto saber operar novas ferramentas é a habilidade de aprender continuamente, mantendo-se atualizado e apto a lidar com mudanças constantes.

        Do ponto de vista comportamental, habilidades como pensamento crítico, comunicação clara e colaboração eficaz são indispensáveis. Profissionais que conseguem avaliar situações de forma analítica, propor soluções criativas e trabalhar de maneira integrada com equipes diversas tendem a liderar transformações e agregar mais valor às empresas. Além disso, a inteligência emocional tem ganhado destaque, permitindo que indivíduos lidem com pressão, adaptem-se a contextos incertos e cultivem relações saudáveis no ambiente de trabalho.

        Por fim, a combinação equilibrada entre habilidades técnicas e comportamentais cria um perfil profissional completo, preparado para atuar em um mundo cada vez mais digital, dinâmico e orientado por dados. Investir no desenvolvimento dessas competências não é apenas uma preparação para o futuro — é uma estratégia essencial para construir uma carreira sólida, resiliente e alinhada às demandas do mercado moderno.',
        t1
    );
    pkg_inserts.inserir_conteudo_trilha(
        '4c3d9f5e-1a2b-43c4-bd55-6a9e7f8b3c33',
        'Preparação Prática',
        'Vídeo',
        'https://www.youtube.com/watch?v=7wG134Mby8c',
        t1
    );

    pkg_inserts.inserir_conteudo_trilha(
        '5d4e8a6f-2b3c-4f1a-9c22-7b8d6e5f4a44',
        'Fundamentos de IA',
        'Artigo',
        'A Inteligência Artificial (IA) tornou-se um dos pilares tecnológicos mais influentes da era digital, moldando a maneira como empresas, governos e indivíduos interagem com dados, sistemas e processos automatizados. Compreender seus fundamentos é essencial para qualquer pessoa que deseja atuar em um mercado cada vez mais orientado por algoritmos e decisões automatizadas. No nível conceitual, a IA pode ser entendida como a capacidade de máquinas executarem tarefas que tradicionalmente exigiriam inteligência humana, como reconhecer padrões, tomar decisões, aprender com experiências e até mesmo compreender linguagem natural.

        Entre os principais componentes da IA, destacam-se as redes neurais artificiais, inspiradas no funcionamento do cérebro humano. Essas redes são compostas por camadas de “neurônios” capazes de aprender relações complexas entre dados, permitindo que modelos identifiquem padrões que dificilmente seriam percebidos por métodos tradicionais. Outro conceito essencial é a regressão, utilizada para prever valores numéricos a partir de um conjunto de variáveis. Já os algoritmos de classificação permitem categorizar dados em grupos distintos, sendo amplamente utilizados em áreas como detecção de fraudes, diagnósticos médicos e análise de imagens.

        A IA também engloba técnicas como processamento de linguagem natural, visão computacional e sistemas especialistas, que juntos formam um conjunto abrangente de ferramentas aplicáveis a diferentes setores. No entanto, antes de dominar as aplicações práticas, é fundamental compreender os princípios teóricos que sustentam essas tecnologias: como os modelos aprendem, como os dados influenciam os resultados e quais métricas são utilizadas para avaliar a precisão e o desempenho.

        Dominar os fundamentos de IA significa adquirir a base necessária para navegar com segurança em projetos reais, tomar decisões informadas e entender tanto o potencial quanto as limitações dessa tecnologia. É o primeiro passo para explorar campos mais avançados, como aprendizado profundo, otimização de modelos e desenvolvimento de soluções inteligentes de alto impacto.',
        t2
    );
    pkg_inserts.inserir_conteudo_trilha(
        '6e5f7b8c-3c4d-5a2b-8d33-8c9e7f6a5b55',
        'Machine Learning Aplicado',
        'Vídeo',
        'https://www.youtube.com/watch?v=0PrOA2JK6GQ',
        t2
    );
    pkg_inserts.inserir_conteudo_trilha(
        '7f6a8c9d-4d5e-6b3c-9e44-9d0f8a7b6c66',
        'Casos Práticos',
        'Artigo',
        'A aplicação prática de técnicas de machine learning tem transformado diversas indústrias, demonstrando que algoritmos bem treinados podem gerar insights valiosos, automatizar processos complexos e resolver problemas que antes eram considerados desafiadores demais para abordagens tradicionais. Estudar casos reais é uma das melhores maneiras de entender como essas tecnologias se comportam em situações concretas, revelando tanto seu potencial quanto suas limitações.

        Um dos exemplos mais emblemáticos é o uso de modelos de classificação para detecção automática de fraudes em transações financeiras. Instituições bancárias utilizam algoritmos que analisam padrões de comportamento — como horários, valores e locais — para identificar atividades suspeitas em tempo real. Esses sistemas aprendem continuamente com novos dados, tornando-se cada vez mais precisos na distinção entre transações legítimas e fraudulentas.

        Na área da saúde, modelos preditivos têm sido aplicados para auxiliar diagnósticos médicos, detectando doenças em estágios iniciais a partir de exames laboratoriais e imagens. Técnicas como redes neurais convolucionais permitem identificar anomalias em radiografias e tomografias com impressionante precisão, oferecendo suporte valioso para médicos e reduzindo o risco de diagnósticos tardios.

        No setor de marketing, algoritmos de recomendação transformaram a experiência do consumidor em plataformas digitais. Analisando comportamentos, preferências e histórico de navegação, os sistemas conseguem sugerir produtos e conteúdos altamente personalizados, aumentando engajamento e conversão. Esse tipo de abordagem também é utilizado em serviços de streaming para recomendar filmes, séries e músicas alinhadas ao gosto do usuário.

        Casos práticos também aparecem na otimização logística, onde modelos de previsão de demanda e roteamento inteligente reduzem custos e aumentam eficiência. Em indústrias, técnicas de manutenção preditiva analisam dados de sensores para identificar falhas antes que ocorram, aumentando a segurança e prolongando a vida útil de máquinas.

        Estudar esses exemplos reais permite compreender não apenas a teoria por trás dos algoritmos, mas também os desafios enfrentados — como qualidade dos dados, viés, escalabilidade e performance — e como eles são solucionados em projetos de grande impacto.',
        t2
    );

    pkg_inserts.inserir_conteudo_trilha(
        '81a2b3c4-5d6e-7f80-1a2b-3c4d5e6f7a77',
        'Produtividade Digital',
        'Vídeo',
        'https://www.youtube.com/watch?v=dSsmvXLLgAI',
        t3
    );
    pkg_inserts.inserir_conteudo_trilha(
        '92b3c4d5-6e7f-8091-2b3c-4d5e6f7a8b88',
        'Organização de Fluxo',
        'Artigo',
        'Organizar fluxos de trabalho digitais é uma etapa fundamental para qualquer equipe que busca aumentar a eficiência, minimizar retrabalhos e criar processos mais previsíveis. A construção de um bom fluxo começa pela compreensão clara das etapas essenciais de uma tarefa e da forma como elas se conectam entre si. Quando essa estrutura não é bem definida, surgem gargalos, atrasos e inconsistências que afetam diretamente a qualidade das entregas e a produtividade do time. Por isso, entender o fluxo como uma cadeia integrada ajuda a identificar pontos críticos e oportunidades de melhoria.

        Um dos pilares de um bom fluxo é a padronização. Isso significa criar um conjunto de regras, templates e orientações que orientem as atividades de forma uniforme, evitando variações desnecessárias. Além disso, a visibilidade do processo é indispensável. Utilizar ferramentas digitais que permitam acompanhar o andamento das tarefas em tempo real facilita a comunicação entre os membros da equipe e reduz o tempo gasto para esclarecer dúvidas ou localizar informações. Quando todos sabem exatamente em que etapa cada item está, o risco de erros diminui consideravelmente.

        Outro ponto importante é o mapeamento de responsabilidades. Cada etapa do fluxo deve ter um responsável claro, garantindo que não haja sobreposição de funções ou tarefas esquecidas. Ao mesmo tempo, a automação desempenha um papel essencial: atividades repetitivas e manuais podem ser automatizadas para liberar tempo para tarefas mais estratégicas. Por fim, bons fluxos são vivos e devem ser revisados regularmente. Analisar métricas, coletar feedback e testar novas abordagens faz parte do processo de evolução contínua, permitindo que o fluxo se adapte às necessidades do time, do projeto e do negócio como um todo.',
        t3
    );
    pkg_inserts.inserir_conteudo_trilha(
        'a3c4d5e6-7f80-9102-3c4d-5e6f7a8b9c99',
        'Segurança Básica',
        'Vídeo',
        'https://www.youtube.com/watch?v=Gfh2bxe3hGU',
        t3
    );

    pkg_inserts.inserir_conteudo_trilha(
        'b4d5e6f7-8091-1023-4d5e-6f7a8b9c0d10',
        'Planejamento de Carreira',
        'Artigo',
        'Planejar a carreira é um processo contínuo que envolve autoconhecimento, análise de oportunidades e definição de metas realistas para o futuro profissional. Muitas pessoas acreditam que a carreira se desenvolve de forma natural, mas na prática os profissionais que alcançam resultados consistentes são aqueles que estruturam seus objetivos com clareza e revisam suas metas ao longo do tempo. O planejamento começa pela compreensão profunda das próprias habilidades, interesses e valores. Esse exercício permite identificar caminhos que fazem sentido e evitam decisões impulsivas baseadas apenas nas condições do momento.

        Além disso, é fundamental analisar o mercado de trabalho, entendendo tendências, novas profissões, habilidades emergentes e as transformações tecnológicas que influenciam diferentes setores. Com essas informações em mãos, torna-se mais fácil criar um plano coerente, estruturado em etapas claras. Uma boa estratégia envolve estabelecer metas de curto, médio e longo prazo, sempre mensuráveis e alinhadas às aspirações pessoais. Esse processo inclui desde a participação em cursos e certificações até o desenvolvimento de habilidades comportamentais essenciais, como comunicação, liderança e adaptabilidade.

        Outro ponto crucial no planejamento de carreira é a construção de um portfólio sólido e a criação de uma rede de contatos relevante. Networking não serve apenas para buscar oportunidades; ele ajuda a manter-se atualizado e permite aprender com profissionais experientes. Revisar o plano regularmente e ajustar rotas também faz parte da jornada, pois a carreira não é um caminho linear. Mudanças de mercado, novas tecnologias e interesses pessoais evoluem com o tempo, exigindo flexibilidade e capacidade de adaptação. Dessa forma, o planejamento de carreira se torna uma ferramenta poderosa para alcançar crescimento sustentável e realização profissional.',
        t4
    );
    pkg_inserts.inserir_conteudo_trilha(
        'c5e6f708-9102-2134-5e6f-7a8b9c0d1e21',
        'Portfólio Técnico',
        'Vídeo',
        'https://www.youtube.com/watch?v=EtrE7icLfxs',
        t4
    );

    pkg_inserts.inserir_conteudo_trilha(
        'd6f70819-0123-3245-6f70-8a9b0c1d2e32',
        'Modelos de Negócio',
        'Artigo',
        'Compreender modelos de negócio é essencial para qualquer pessoa que deseja criar, gerenciar ou expandir uma empresa. Um modelo de negócio descreve de forma clara como uma organização cria, entrega e captura valor dentro de um mercado. Ele funciona como a estrutura lógica que sustenta a operação e orienta as principais decisões estratégicas. Existem vários tipos de modelos, como assinatura, marketplace, freemium, e-commerce tradicional, franquias e muitos outros, cada um com características que atendem a necessidades específicas de consumidores e segmentos.

        Ao estudar modelos de negócio, o empreendedor começa a perceber como diferentes empresas utilizam estratégias distintas para gerar receita e se diferenciar no mercado. Por exemplo, negócios baseados em assinatura priorizam retenção e previsibilidade financeira, enquanto marketplaces se concentram em conectar compradores e vendedores sem necessariamente produzir bens próprios. Essas escolhas afetam diretamente áreas como marketing, logística, experiência do cliente e estrutura de custos.

        Outro ponto importante é avaliar a proposta de valor, ou seja, o motivo pelo qual um cliente escolheria aquela solução em vez das alternativas existentes. A proposta de valor deve resolver um problema real, oferecer benefícios concretos e se comunicar de forma clara ao público-alvo. Ao mapear o modelo de negócio, ferramentas como o Business Model Canvas tornam o processo mais visual e compreensível, ajudando a identificar oportunidades e riscos. Testar hipóteses e validar ideias no mercado também é parte essencial, pois evita investimentos altos em modelos que não têm aderência. Entender modelos de negócio é, portanto, uma habilidade estratégica para inovar, competir e crescer de maneira sustentável.',
        t5
    );
    pkg_inserts.inserir_conteudo_trilha(
        'e7f8192a-1234-4356-7071-9b0c1d2e3f43',
        'Validação de Ideia',
        'Vídeo',
        'https://www.youtube.com/watch?v=vHvpcs7aTDo',
        t5
    );

    pkg_inserts.inserir_conteudo_trilha(
        'f8091a2b-2345-5467-8172-0c1d2e3f4a54',
        'Rotina Produtiva',
        'Artigo',
        'Manter uma rotina produtiva é um dos pilares do desenvolvimento pessoal e profissional, permitindo que as pessoas utilizem seu tempo de maneira eficiente e alcancem resultados consistentes ao longo do tempo. Uma rotina bem planejada não apenas organiza o dia, mas também cria um ambiente mental favorável para foco, disciplina e clareza de prioridades. Para isso, o primeiro passo é identificar os objetivos principais e estabelecer quais atividades são realmente essenciais para alcançá-los. Quando há essa clareza, torna-se mais fácil evitar distrações e direcionar energia para ações que realmente importam.

        Outro aspecto importante de uma rotina produtiva é a criação de hábitos. Habituar-se a começar o dia com tarefas de maior impacto, por exemplo, aumenta significativamente a sensação de progresso. Estruturas como o método Pomodoro, blocos de tempo e listas priorizadas ajudam a organizar o fluxo de forma equilibrada, reduzindo a procrastinação e aumentando a concentração. Além disso, incorporar pausas estratégicas ao longo do dia é fundamental para manter o desempenho, já que períodos longos de trabalho contínuo tendem a gerar fadiga e prejudicar a qualidade das entregas.

        A disciplina também desempenha um papel crucial. Ter uma rotina não significa rigidez extrema, mas sim consistência. Ajustar horários, eliminar distrações e criar ambientes adequados ao trabalho são ações que reforçam o compromisso com a produtividade. Por fim, uma rotina produtiva deve ser revisada constantemente, levando em conta mudanças no trabalho, na saúde e nas demandas pessoais. Adaptar-se é tão importante quanto manter-se organizado. Ao equilibrar foco, flexibilidade e hábitos saudáveis, qualquer pessoa consegue construir uma rotina que potencializa seu desempenho e contribui para uma vida mais equilibrada e satisfatória.',
        t6
    );
    pkg_inserts.inserir_conteudo_trilha(
        '0a1b2c3d-3456-6578-9273-1d2e3f4a5b65',
        'Técnicas de Foco',
        'Vídeo',
        'https://www.youtube.com/watch?v=U9iE090X-64',
        t6
    );

    pkg_inserts.inserir_conteudo_trilha(
        '1b2c3d4e-4567-7689-a384-2e3f4a5b6c76',
        'Comunicação Efetiva',
        'Artigo',
        'A comunicação efetiva é uma das habilidades mais essenciais na vida profissional e pessoal, pois influencia diretamente a qualidade das relações, a resolução de conflitos e a capacidade de transmitir ideias de maneira clara e persuasiva. Para se comunicar bem, é fundamental entender que comunicação não é apenas falar, mas também ouvir, interpretar e adaptar a mensagem conforme o contexto. A escuta ativa, por exemplo, é um componente central desse processo, pois permite compreender verdadeiramente o que o outro está dizendo, evitando interpretações distorcidas e respostas impulsivas.

        Além disso, a comunicação verbal exige atenção ao tom de voz, à escolha das palavras e à estrutura das frases. Pequenos ajustes podem fazer com que uma mensagem simples se torne mais clara, objetiva e acolhedora. No ambiente profissional, isso pode significar a diferença entre um projeto bem alinhado e uma série de retrabalhos gerados por falhas na comunicação. Já a comunicação escrita requer ainda mais cuidado, especialmente em tempos de mensagens rápidas, e-mails e conversas digitais. Revisar textos, organizar ideias e evitar ambiguidades são práticas fundamentais para transmitir credibilidade e profissionalismo.

        Outro ponto importante é entender que a comunicação efetiva envolve também aspectos não verbais, como postura corporal, expressões faciais e contato visual. Muitas vezes, a linguagem corporal comunica mais do que as palavras, reforçando — ou contradizendo — a mensagem verbal. Desenvolver sensibilidade para esses elementos ajuda a construir relacionamentos mais sólidos e empáticos. Por fim, aprimorar a comunicação é um processo contínuo que envolve prática, autoconhecimento e disposição para ajustar comportamentos. Quando cultivada de forma consciente, essa habilidade se torna um diferencial competitivo e um poderoso instrumento para criar conexões significativas.',
        t7
    );
    pkg_inserts.inserir_conteudo_trilha(
        '2c3d4e5f-5678-879a-b495-3f4a5b6c7d87',
        'Trabalho em Equipe',
        'Vídeo',
        'https://www.youtube.com/watch?v=r6HcE6Bc6KE',
        t7
    );
    pkg_inserts.inserir_conteudo_trilha(
        '3d4e5f60-6789-98ab-c5a6-4a5b6c7d8e98',
        'Feedback Construtivo',
        'Artigo',
        'O feedback construtivo é uma ferramenta poderosa para estimular o crescimento profissional e fortalecer relações de trabalho. Diferente de críticas vagas ou apontamentos puramente negativos, o feedback construtivo busca orientar, apoiar e promover melhorias reais no comportamento ou na performance de uma pessoa. Para oferecê-lo de maneira eficaz, é fundamental que ele seja claro, objetivo e específico, evitando generalizações que podem gerar confusão ou sentimentos de insegurança. A ideia central é mostrar o que pode ser aprimorado, mas também reconhecer pontos fortes e reforçar comportamentos positivos.

        Uma estratégia bastante utilizada é o modelo de feedback baseado em fatos observáveis. Nesse método, a pessoa que dará o feedback descreve situações concretas, explica o impacto da ação e sugere alternativas de melhoria. Isso evita julgamentos pessoais e torna a conversa mais produtiva. Além disso, o tom deve ser sempre respeitoso, pois o objetivo não é constranger, mas sim contribuir para o desenvolvimento do outro. Em ambientes profissionais, quando o feedback é incorporado como prática regular, ele se torna um dos principais mecanismos de evolução individual e coletiva.

        Da mesma forma, saber receber feedback é tão importante quanto saber dar. Receber críticas pode gerar desconforto, mas quando encaradas com maturidade, elas se transformam em oportunidades de aprendizado. Manter postura aberta, fazer perguntas e refletir sobre os pontos levantados são atitudes que demonstram profissionalismo e disposição para crescer. Por fim, o feedback construtivo deve ser contínuo, e não algo restrito a momentos formais de avaliação. Quanto mais integrado ao cotidiano, mais natural e eficiente ele se torna, contribuindo para equipes mais colaborativas, transparentes e de alta performance.',
        t7
    );

    pkg_inserts.inserir_conteudo_trilha(
        '4e5f6071-789a-9abc-d6b7-5b6c7d8e9f09',
        'Introdução a Analytics',
        'Artigo',
        'Analytics é o processo de coletar, organizar, interpretar e transformar dados em informações úteis, capazes de orientar decisões estratégicas. Em um mundo cada vez mais orientado por dados, compreender esse universo se tornou uma habilidade fundamental para profissionais de praticamente todas as áreas. A análise de dados permite entender comportamentos, identificar padrões, prever tendências e otimizar processos de maneira muito mais precisa do que decisões baseadas apenas em intuição. Por isso, empresas que dominam essa prática conseguem agir de forma mais competitiva, ágil e eficiente.

        O processo de analytics envolve várias etapas. A primeira é a coleta de dados, que pode vir de diversas fontes, como sistemas internos, plataformas digitais, sensores IoT, redes sociais e pesquisas. Em seguida, esses dados precisam ser organizados e limpos, removendo duplicidades e inconsistências que possam distorcer análises. Depois disso, começa a interpretação, que utiliza técnicas estatísticas, ferramentas de visualização e modelos matemáticos para extrair insights relevantes. É nesse momento que surgem descobertas capazes de orientar decisões de alto impacto, como estratégias de marketing, melhorias operacionais ou inovações em produtos.

        Outro aspecto importante é a visualização de dados. Gráficos, dashboards e relatórios tornam informações complexas mais acessíveis, facilitando a comunicação com gestores e equipes. Ferramentas modernas como Power BI, Tableau e Looker tornam esse processo mais intuitivo e interativo. Por fim, analytics é uma área em constante evolução, impulsionada por tecnologias como machine learning e inteligência artificial, que ampliam a capacidade de análise e predição. Para quem está começando, compreender os princípios básicos e desenvolver raciocínio analítico já é um excelente caminho para atuar em áreas estratégicas e de grande demanda no mercado.',
        t8
    );
    pkg_inserts.inserir_conteudo_trilha(
        '5f607182-89ab-abcd-e7c8-6c7d8e9f0011',
        'Visualização de Dados',
        'Vídeo',
        'https://www.youtube.com/watch?v=loYuxWSsLNc',
        t8
    );

    pkg_inserts.inserir_conteudo_trilha(
        '60718293-9abc-bcde-f8d9-7d8e9f001122',
        'Design Thinking',
        'Artigo',
        'O Design Thinking é uma abordagem centrada no ser humano que busca compreender profundamente as necessidades, dores e motivações das pessoas antes de qualquer tentativa de solução. Mais do que uma metodologia, trata-se de uma forma de pensar, que valoriza empatia, colaboração multidisciplinar e experimentação constante. Embora muitas vezes seja apresentado como um processo dividido em cinco etapas — Empatia, Definição, Ideação, Prototipagem e Testes — o mais importante é sua flexibilidade e a capacidade de adaptar essas fases ao contexto real do problema.

        Na etapa de Empatia, o objetivo é observar e ouvir usuários reais, entendendo como eles se comportam e quais desafios enfrentam no dia a dia. Esse contato direto revela necessidades ocultas e percepções que dificilmente surgiriam através de análises superficiais. Em seguida, a fase de Definição organiza as descobertas, transformando-as em um problema claro e bem formulado, permitindo que a equipe ataque a causa e não apenas os sintomas.

        A fase de Ideação incentiva a criação de diversas possibilidades, estimulando a criatividade e eliminando julgamentos prematuros. A diversidade de ideias aumenta a probabilidade de surgirem soluções ousadas e relevantes. Logo depois, a Prototipagem transforma ideias em modelos simples e funcionais, que podem ser rapidamente testados. Essa prática reduz custos e acelera o aprendizado. Por fim, os Testes colocam o protótipo diante dos usuários, permitindo ajustes, validações e novas descobertas.

        Organizações que adotam Design Thinking conseguem inovar mais rapidamente, reduzir retrabalho e desenvolver soluções mais conectadas com a realidade das pessoas. É uma filosofia essencial para qualquer profissional que deseja criar produtos, processos e experiências realmente significativas.',
        t9
    );
    pkg_inserts.inserir_conteudo_trilha(
        '718293a4-abcd-cdef-09e1-8e9f00112233',
        'Criatividade Aplicada',
        'Vídeo',
        'https://www.youtube.com/watch?v=neijx0gAKoQ',
        t9
    );

    pkg_inserts.inserir_conteudo_trilha(
        '8293a4b5-bcde-def0-1f22-9f0011223344',
        'Liderança Situacional',
        'Artigo',
        'A Liderança Situacional é um dos modelos mais utilizados no mundo corporativo por reconhecer que não existe um único estilo de liderança ideal. O líder eficaz é aquele que consegue ajustar sua abordagem com base no nível de maturidade, experiência e engajamento de cada colaborador ou equipe. Dessa forma, a liderança deixa de ser fixa e passa a ser adaptativa, permitindo intervenções mais precisas e produtivas.

        O modelo apresenta quatro estilos principais: Direção, Orientação, Apoio e Delegação. O estilo de Direção é recomendado quando o colaborador ainda não possui conhecimento suficiente para atuar de forma independente. Nesse estágio, o líder fornece instruções claras, define prioridades e acompanha de perto a execução. Já o estilo de Orientação mantém o direcionamento, mas agrega explicações detalhadas e maior estímulo, permitindo que o profissional compreenda não apenas o “como”, mas também o “porquê” das tarefas.

        À medida que o colaborador ganha confiança e domínio técnico, o estilo de Apoio se torna apropriado. Nesse momento, o líder reduz o controle e passa a incentivar participação ativa, escuta e tomada conjunta de decisões. Por fim, quando o colaborador atinge plena autonomia, o estilo de Delegação é o mais indicado. Aqui, o líder atua de forma mais distante, realizando apenas alinhamentos periódicos, enquanto o profissional assume responsabilidade total pelo processo.

        Aplicar a Liderança Situacional melhora o clima organizacional, reduz conflitos, acelera o desenvolvimento das pessoas e aumenta a produtividade. Mais do que um modelo, ela representa maturidade emocional e inteligência adaptativa, habilidades essenciais para gestores que desejam conduzir times de maneira eficaz em ambientes dinâmicos e desafiadores.',
        t10
    );
    pkg_inserts.inserir_conteudo_trilha(
        '93a4b5c6-cdef-ef01-2f33-001122334455',
        'Gestão de Equipes Remotas',
        'Vídeo',
        'https://www.youtube.com/watch?v=piqXHbK8dw4',
        t10
    );
    pkg_inserts.inserir_conteudo_trilha(
        'a4b5c6d7-ef01-0123-3f44-112233445566',
        'Tomada de Decisão',
        'Artigo',
        'A Tomada de Decisão é uma das competências mais determinantes para o sucesso de equipes, projetos e organizações. Decidir bem vai muito além de escolher entre alternativas; envolve reconhecer padrões, analisar consequências, compreender riscos e transformar informações complexas em ações concretas. Profissionais que dominam esse processo conseguem agir com clareza mesmo em ambientes de alta pressão e incerteza.

        Entre os modelos mais tradicionais está o processo racional, que consiste em identificar o problema, levantar opções, avaliar impactos e selecionar a escolha mais vantajosa. Apesar de eficiente, esse modelo pode ser lento em situações urgentes. Por isso, métodos complementares — como heurísticas, matrizes de decisão, análise SWOT, árvores decisórias e mapas mentais — ajudam a tornar o processo mais ágil sem perder qualidade. Cada técnica oferece uma perspectiva diferente e ajuda a equilibrar intuição, lógica e experiência.

        Além disso, a tomada de decisão eficaz depende fortemente da colaboração. Quando equipes com diferentes visões participam do processo, as chances de erros diminuem e as soluções se tornam mais completas. Entretanto, decidir não é apenas sobre escolher; é também sobre assumir responsabilidade, acompanhar resultados e revisar decisões quando necessário. A capacidade de aprender com erros, ajustar estratégias e manter transparência fortalece a confiança e aumenta a maturidade organizacional.

        Em um mundo onde as mudanças são rápidas e constantes, saber decidir de forma estruturada e consciente se tornou um diferencial competitivo. Dominar técnicas de tomada de decisão ajuda profissionais e líderes a lidarem melhor com desafios inesperados, a priorizarem o que realmente importa e a conduzirem equipes em direção a resultados mais sólidos e sustentáveis.',
        t10
    );
end;
/



begin
    pkg_inserts.inserir_endereco_usuario('b0a5f2e7-879c-4a13-82ab-71f1b716de11','01001-000','Rua A','SP');
    pkg_inserts.inserir_endereco_usuario('5e5fc7b4-863d-4e8a-b0bb-c93a4360f972','20010-000','Rua B','RJ');
    pkg_inserts.inserir_endereco_usuario('d1e1faf0-1f4b-4e5e-b20e-61c1ea2cfa16','30130-000','Rua C','MG');
    pkg_inserts.inserir_endereco_usuario('a8c98cb7-2477-4a77-9b18-d4c2c843d814','70040-010','Rua D','DF');
    pkg_inserts.inserir_endereco_usuario('1fd6c2a0-5ed9-4c8b-9e8c-85bc03f3e4d5','80010-000','Rua E','PR');
    pkg_inserts.inserir_endereco_usuario('e2a0b2f5-32d6-412d-af4c-917b1f5fb35d','60015-000','Rua F','CE');
    pkg_inserts.inserir_endereco_usuario('07db33ad-fd10-4ef0-bc0b-30a69e6ac72d','40020-000','Rua G','BA');
    pkg_inserts.inserir_endereco_usuario('6bcff902-6e51-4a97-a7f3-3630b8979a2d','88010-000','Rua H','SC');
    pkg_inserts.inserir_endereco_usuario('3f29cdf1-4658-4fa4-81ef-d51ff6cba93b','69005-000','Rua I','AM');
    pkg_inserts.inserir_endereco_usuario('c82ae200-0df6-4f6c-887a-a69e502435f8','66010-000','Rua J','PA');
end;
/

declare
    v_profissoes sys.odcivarchar2list := sys.odcivarchar2list(
        'Cientista de Dados',
        'Engenheiro de Software',
        'Analista de Segurança Cibernética',
        'Designer UX/UI',
        'Analista de Dados',
        'Gestor de Projetos Ágeis',
        'Especialista em Inteligência Artificial',
        'Arquiteto de Soluções',
        'Programador Mobile',
        'Product Manager'
    );

    v_index integer := 1;
begin
    for r in (select id_usuario from tb_usuario order by id_usuario)
    loop
        pkg_inserts.inserir_formulario_profissao(
            r.id_usuario,
            'Resposta 1','Resposta 2','Resposta 3','Resposta 4','Resposta 5',
            'Resposta 6','Resposta 7','Resposta 8','Resposta 9','Resposta 10',
            v_profissoes(v_index)
        );

        v_index := v_index + 1;
        if v_index > v_profissoes.count then
            v_index := 1;
        end if;
    end loop;
end;
/

declare
    u1 varchar2(36) := 'b0a5f2e7-879c-4a13-82ab-71f1b716de11';
    u2 varchar2(36) := '5e5fc7b4-863d-4e8a-b0bb-c93a4360f972';
    u3 varchar2(36) := 'd1e1faf0-1f4b-4e5e-b20e-61c1ea2cfa16';
    u4 varchar2(36) := 'a8c98cb7-2477-4a77-9b18-d4c2c843d814';
    u5 varchar2(36) := '1fd6c2a0-5ed9-4c8b-9e8c-85bc03f3e4d5';
    u6 varchar2(36) := 'e2a0b2f5-32d6-412d-af4c-917b1f5fb35d';
    u7 varchar2(36) := '07db33ad-fd10-4ef0-bc0b-30a69e6ac72d';
    u8 varchar2(36) := '6bcff902-6e51-4a97-a7f3-3630b8979a2d';
    u9 varchar2(36) := '3f29cdf1-4658-4fa4-81ef-d51ff6cba93b';
    u10 varchar2(36) := 'c82ae200-0df6-4f6c-887a-a69e502435f8';
begin
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u2,'9a7f2d1b-3c2a-4b9f-8a47-1e0c5d2a9f11'); 
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u2,'2b8c6e3d-7f1a-4d2b-ab12-3f8a6d4c2b22');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u2,'4c3d9f5e-1a2b-43c4-bd55-6a9e7f8b3c33');
    
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u4,'5d4e8a6f-2b3c-4f1a-9c22-7b8d6e5f4a44');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u4,'6e5f7b8c-3c4d-5a2b-8d33-8c9e7f6a5b55');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u4,'7f6a8c9d-4d5e-6b3c-9e44-9d0f8a7b6c66');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u3,'5d4e8a6f-2b3c-4f1a-9c22-7b8d6e5f4a44'); 

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u6,'81a2b3c4-5d6e-7f80-1a2b-3c4d5e6f7a77');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u6,'92b3c4d5-6e7f-8091-2b3c-4d5e6f7a8b88');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u6,'a3c4d5e6-7f80-9102-3c4d-5e6f7a8b9c99');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u5,'81a2b3c4-5d6e-7f80-1a2b-3c4d5e6f7a77');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u8,'b4d5e6f7-8091-1023-4d5e-6f7a8b9c0d10');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u8,'c5e6f708-9102-2134-5e6f-7a8b9c0d1e21');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u10,'d6f70819-0123-3245-6f70-8a9b0c1d2e32');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u10,'e7f8192a-1234-4356-7071-9b0c1d2e3f43');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u9,'d6f70819-0123-3245-6f70-8a9b0c1d2e32'); 

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u6,'f8091a2b-2345-5467-8172-0c1d2e3f4a54'); 

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u2,'1b2c3d4e-4567-7689-a384-2e3f4a5b6c76');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u8,'4e5f6071-789a-9abc-d6b7-5b6c7d8e9f09');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u10,'60718293-9abc-bcde-f8d9-7d8e9f001122');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u10,'718293a4-abcd-cdef-09e1-8e9f00112233');

    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u9,'8293a4b5-bcde-def0-1f22-9f0011223344');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u9,'93a4b5c6-cdef-ef01-2f33-001122334455');
    pkg_inserts.inserir_conteudo_trilha_usuario(sys_guid(),'s',u9,'a4b5c6d7-ef01-0123-3f44-112233445566');
end;
/

declare
    cursor c_usuarios is
        select id_usuario from tb_usuario order by id_usuario;

    cursor c_trilhas is
        select id_trilha from tb_trilha order by id_trilha;
begin
    for u in c_usuarios loop
        for t in c_trilhas loop
            pkg_inserts.inserir_trilha_usuario(sys_guid(), u.id_usuario, t.id_trilha, 'n');
        end loop;
    end loop;
end;
/

declare
    cursor c_usuarios is
        select id_usuario
        from tb_usuario
        order by id_usuario;

    cursor c_conteudos is
        select id_conteudo_trilha
        from tb_conteudo_trilha
        order by id_conteudo_trilha;
begin
    for u in c_usuarios loop
        for c in c_conteudos loop

            declare
                v_exists number;
            begin
                select count(*)
                into v_exists
                from tb_conteudo_trilha_usuario
                where id_usuario = u.id_usuario
                  and id_conteudo_trilha = c.id_conteudo_trilha;

                if v_exists = 0 then
                    pkg_inserts.inserir_conteudo_trilha_usuario(
                        sys_guid(),
                        'n',
                        u.id_usuario,
                        c.id_conteudo_trilha
                    );
                end if;
            end;

        end loop;
    end loop;
end;
/

create or replace package package_usuario as

    procedure prc_popular_trilhas_e_conteudos_usuario (
        p_id_usuario in varchar2
    );

end package_usuario;
/

create or replace package body package_usuario as
    procedure prc_popular_trilhas_e_conteudos_usuario (
        p_id_usuario in varchar2
    ) is
        cursor c_trilhas is
            select id_trilha
              from tb_trilha
          order by id_trilha;

        cursor c_conteudos is
            select id_conteudo_trilha
              from tb_conteudo_trilha
          order by id_conteudo_trilha;

        v_exists number;
    begin
        for t in c_trilhas loop
            select count(*)
              into v_exists
              from tb_trilha_usuario
             where id_usuario = p_id_usuario
               and id_trilha  = t.id_trilha;

            if v_exists = 0 then
                pkg_inserts.inserir_trilha_usuario(
                    sys_guid(),
                    p_id_usuario,
                    t.id_trilha,
                    'N'
                );
            end if;
        end loop;

        for c in c_conteudos loop
            select count(*)
              into v_exists
              from tb_conteudo_trilha_usuario
             where id_usuario = p_id_usuario
               and id_conteudo_trilha = c.id_conteudo_trilha;

            if v_exists = 0 then
                pkg_inserts.inserir_conteudo_trilha_usuario(
                    sys_guid(),
                    'N',
                    p_id_usuario,
                    c.id_conteudo_trilha
                );
            end if;
        end loop;

    end prc_popular_trilhas_e_conteudos_usuario;
end package_usuario;
/



create or replace package pkg_functions as
    -- FUNCAO 1 
    function fn_to_json_trilhas_usuario_resumido(p_id_usuario varchar2) return varchar2;
    -- FUNCAO 2
    function fn_validar_usuario_e_progresso(p_id_usuario varchar2) return varchar2;
end pkg_functions;
/


create or replace package body pkg_functions as
    -- FUNCAO 1 
    function fn_to_json_trilhas_usuario_resumido(
        p_id_usuario varchar2
    ) return varchar2
    is
        v_json          varchar2(5000);
        v_trilhas       varchar2(5000);
        v_nome_usuario  varchar2(255);
        v_email_usuario varchar2(255);
    
        e_usuario_inexistente exception;
        pragma exception_init(e_usuario_inexistente, -20001);
    
        function escape_json(p_text varchar2) return varchar2 is
        begin
            if p_text is null then
                return '""';
            end if;
            return '"' || replace(replace(p_text, '\', '\\'), '"', '\"') || '"';
        end;
    begin
        begin
            select nome_usuario, email_usuario
            into v_nome_usuario, v_email_usuario
            from tb_usuario
            where id_usuario = p_id_usuario;
        exception 
            when no_data_found then
                raise e_usuario_inexistente;
        end;
    
        v_trilhas := '[';
        for t in (
            select tu.id_trilha_usuario,
                   t.id_trilha,
                   t.nome_trilha,
                   t.quantidade_conteudo_trilha,
                   tu.trilha_concluida_usuario
            from tb_trilha_usuario tu
            inner join tb_trilha t on t.id_trilha = tu.id_trilha
            where tu.id_usuario = p_id_usuario
            order by t.nome_trilha
        ) loop
            if v_trilhas <> '[' then
                v_trilhas := v_trilhas || ',';
            end if;
    
            v_trilhas := v_trilhas ||
                '{' ||
                    '"id_trilha":' || escape_json(t.id_trilha) || ',' ||
                    '"nome":' || escape_json(t.nome_trilha) || ',' ||
                    '"quantidade_conteudos":' || t.quantidade_conteudo_trilha || ',' ||
                    '"trilha_concluida":' || escape_json(nvl(t.trilha_concluida_usuario,'N')) ||
                '}';
        end loop;
        v_trilhas := v_trilhas || ']';
    
        v_json :=
            '{' ||
                '"id_usuario":' || escape_json(p_id_usuario) || ',' || 
                '"nome":' || escape_json(v_nome_usuario) || ',' ||
                '"email":' || escape_json(v_email_usuario) || ',' ||
                '"trilhas":' || v_trilhas ||
            '}';
    
        return v_json;
    
    exception
        when e_usuario_inexistente then
            return '{"error":"Usuário não encontrado"}';
        when others then
            return '{"error":"Erro: ' || replace(sqlerrm,'"','\"') || '"}';
    end fn_to_json_trilhas_usuario_resumido;

    -- FUNCAO 2
    function fn_validar_usuario_e_progresso(
        p_id_usuario varchar2
    ) return varchar2
    is
        v_email    varchar2(255);
        v_nome     varchar2(255);

        v_total_trilhas          number := 0;
        v_total_trilhas_conc     number := 0;
        v_percentual_trilhas     number := 0;

        v_total_conteudos        number := 0;
        v_total_conteudos_conc   number := 0;

        e_formato_email_invalido exception;
        e_uuid_invalido          exception;
        e_usuario_nao_existe     exception;

        pragma exception_init(e_formato_email_invalido, -20010);
        pragma exception_init(e_uuid_invalido, -20011);
        pragma exception_init(e_usuario_nao_existe, -20012);

    begin
        if not regexp_like(
            p_id_usuario,
            '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
        ) then
            raise e_uuid_invalido;
        end if;

        begin
            select nome_usuario, email_usuario
            into v_nome, v_email
            from tb_usuario
            where id_usuario = p_id_usuario;

        exception
            when no_data_found then
                raise e_usuario_nao_existe;
        end;

        if not regexp_like(
            v_email,
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        ) then
            raise e_formato_email_invalido;
        end if;

        select 
            count(*),
            sum(case when trilha_concluida_usuario = 'S' then 1 else 0 end)
        into v_total_trilhas, v_total_trilhas_conc
        from tb_trilha_usuario
        where id_usuario = p_id_usuario;

        if v_total_trilhas > 0 then
            v_percentual_trilhas :=
                round((v_total_trilhas_conc / v_total_trilhas) * 100, 2);
        else
            v_percentual_trilhas := 0;
        end if;

        select 
            count(*),
            sum(case when conteudo_trilha_concluida_usuario = 'S' then 1 else 0 end)
        into v_total_conteudos, v_total_conteudos_conc
        from tb_conteudo_trilha_usuario
        where id_usuario = p_id_usuario;

        return
            '{' ||
                '"id_usuario":"' || p_id_usuario || '",' ||
                '"nome":"' || v_nome || '",' ||
                '"email":"' || v_email || '",' ||
                '"progresso_trilhas":{' ||
                    '"total":' || v_total_trilhas || ',' ||
                    '"concluidas":' || v_total_trilhas_conc || ',' ||
                    '"percentual":' || v_percentual_trilhas ||
                '},' ||
                '"progresso_conteudos":{' ||
                    '"total":' || nvl(v_total_conteudos,0) || ',' ||
                    '"concluidos":' || nvl(v_total_conteudos_conc,0) ||
                '}' ||
            '}';

    exception
        when e_uuid_invalido then
            return '{"error":"ID do usuário não está em formato UUID válido."}';

        when e_usuario_nao_existe then
            return '{"error":"Usuário não encontrado no sistema."}';

        when e_formato_email_invalido then
            return '{"error":"E-mail do usuário não é corporativo ou possui formato inválido."}';

        when others then
            return '{"error":"Erro desconhecido: ' || sqlerrm || '"}';
    end fn_validar_usuario_e_progresso;
end pkg_functions;
/

create or replace package pkg_jobs as
    procedure prc_gerar_json_trilhas_todos;
end pkg_jobs;
/

create or replace package body pkg_jobs as

    procedure prc_gerar_json_trilhas_todos
    is
        v_json        varchar2(32767);
        v_primeiro    boolean := true;
    begin
        dbms_output.put_line('[');  

        for u in (
            select id_usuario
            from tb_usuario
            order by nome_usuario
        ) loop
            begin
                v_json := pkg_functions.fn_to_json_trilhas_usuario_resumido(u.id_usuario);

                if not v_primeiro then
                    dbms_output.put_line(',');
                else
                    v_primeiro := false;
                end if;

                dbms_output.put_line(v_json);

            exception
                when others then
                    dbms_output.put_line('-- ERRO ao gerar JSON para o usuário ' || u.id_usuario || ': ' || sqlerrm);
            end;
        end loop;

        dbms_output.put_line(']');  

        dbms_output.put_line('-- PROCESSO FINALIZADO');
    end prc_gerar_json_trilhas_todos;

end pkg_jobs;
/


/*
--RODAR INDIVIDUALMENTE PARA TESTAR
begin
    dbms_output.put_line(pkg_functions.fn_to_json_trilhas_usuario('b0a5f2e7-879c-4a13-82ab-71f1b716de11'));
end;
/

begin
    dbms_output.put_line(pkg_functions.fn_to_json_trilhas_usuario_resumido('b0a5f2e7-879c-4a13-82ab-71f1b716de11'));
end;
/

begin
    pkg_jobs.prc_gerar_json_trilhas_todos;
end;
/
*/

commit;


