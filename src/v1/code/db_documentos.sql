-- Total de documentos criados em meio eletrônico por:
-- => Órgão
-- => Espécie
-- => Semana
-- => Assunto
-- => Modelo

WITH 
dba_nome AS ( -- Nome do assunto para cada ID
    SELECT 
        id_classificacao
        ,descr_classificacao as assunto
    FROM siga.ex_classificacao
)
, dbd_ativos AS ( -- Documentos únicos criados
    SELECT
        to_char(trunc(dt_doc, 'IW') + 7, 'YYYY/MM/DD') as semana
        ,id_orgao_usu as id_orgao
        ,id_forma_doc
        ,id_classificacao
        ,id_mod
    FROM siga.vw_ex_documento
    WHERE id_orgao_usu <> '9999999999' -- Retira ID do órgão TESTE
    AND to_char(trunc(dt_doc, 'IW'), 'YYYY/MM/DD') IS NOT NULL -- Documentos criados, não contabilizando os temporários
    AND id_doc_pai IS NULL -- Documentos únicos, não contabilizando os juntados
    AND dt_doc < TIMESTAMP '2021-10-18 00:00:00.000'
)
, dbe_tipo AS ( -- Tipo documental (Processo Administrativo / Expediente) para cada espécie (forma)
    SELECT
        dbe.id_forma_doc
        ,dbe_desc.desc_tipo_forma_doc as especie
    FROM
        siga.ex_tipo_forma_documento dbe_desc
    INNER JOIN siga.ex_forma_documento dbe 
    ON dbe.id_tipo_forma_doc = dbe_desc.id_tipo_forma_doc
)
, dbm_nome AS ( -- Nome do modelo para cada ID
    SELECT 
        id_mod 
        ,desc_mod as modelo
    FROM siga.ex_modelo
)
, dbo_nome AS ( -- Nome do órgão para cada ID
    SELECT 
        id_orgao_usu as id_orgao,
        CASE 
            WHEN INSTR(nm_orgao_usu, ' /' ,1) <> 0 
            THEN SUBSTR(nm_orgao_usu, INSTR(nm_orgao_usu, ' /' ,1)+3, LENGTH(nm_orgao_usu)) 
            ELSE nm_orgao_usu 
        END as nome_orgao
    FROM corporativo.cp_orgao_usuario
)
SELECT 
    semana,
    nome_orgao,
    especie,
    UPPER(modelo),
    UPPER(assunto),
    COUNT(1) as total_doc
FROM 
    dba_nome,
    dbd_ativos,
    dbe_tipo,
    dbm_nome,
    dbo_nome
WHERE 
    dba_nome.id_classificacao = dbd_ativos.id_classificacao
    AND dbe_tipo.id_forma_doc = dbd_ativos.id_forma_doc
    AND dbm_nome.id_mod = dbd_ativos.id_mod
    AND dbo_nome.id_orgao = dbd_ativos.id_orgao
GROUP BY 
    semana,
    nome_orgao,
    especie,
    UPPER(modelo),
    UPPER(assunto)
order by semana desc