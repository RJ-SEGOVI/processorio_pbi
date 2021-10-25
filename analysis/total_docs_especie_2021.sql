WITH 
dbd_ativos AS ( -- Documentos únicos criados
    SELECT
        trunc(dt_doc, 'MON') as mes
        ,id_forma_doc
    FROM siga.vw_ex_documento
    WHERE id_orgao_usu <> '9999999999' -- Retira ID do órgão TESTE
    AND dt_doc IS NOT NULL -- Documentos criados, não contabilizando os temporários
    AND id_doc_anterior IS NULL -- Documentos únicos, não contabilizando os juntados
    AND dt_doc < TIMESTAMP '2021-09-30 10:00:00'
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
SELECT * FROM (
SELECT 
    mes,
    especie
FROM 
    dbd_ativos,
    dbe_tipo
WHERE 
    dbe_tipo.id_forma_doc = dbd_ativos.id_forma_doc
    AND EXTRACT(YEAR FROM mes) = 2021
)
PIVOT (
  count(especie) FOR especie IN ('Processo Administrativo' as processos, 'Expediente' as expedientes)
)
ORDER BY mes;