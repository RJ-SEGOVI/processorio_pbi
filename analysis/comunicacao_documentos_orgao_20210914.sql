-- Pedido para Comunicação (Karol Magalhães): Total de documentos gerados por órgão nessa gestão (2021)

SELECT
    TO_CHAR(dbd.dt_doc, 'YYYY') ano_criacao,
    dbd.id_orgao_usu id_orgao,
    (
        SELECT
            nm_orgao_usu
        FROM
            corporativo.cp_orgao_usuario dbo
        WHERE
            dbo.id_orgao_usu = dbd.id_orgao_usu
    )              nome_orgao,
    COUNT(1)       total_docs
FROM
    siga.vw_ex_documento dbd
WHERE
    dbd.id_orgao_usu <> '9999999999' -- retira ORGAO_TESTE_ZZ
AND 
    TO_CHAR(dbd.dt_doc, 'YYYY') IS NOT NULL
AND
    dbd.dt_doc < DATE '2021-09-14' -- Documento gerados até segunda (13/09)
AND
    EXTRACT(YEAR FROM dbd.dt_doc) = 2021
GROUP BY
    dbd.id_orgao_usu,
    TO_CHAR(dbd.dt_doc, 'YYYY')
ORDER BY
    ano_criacao DESC,
    total_docs DESC;