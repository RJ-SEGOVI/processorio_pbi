-- Total de usuários internos cadastrados:

WITH 
dbo_nome AS ( -- Nome do órgão para cada ID
    SELECT 
        id_orgao_usu as id_orgao,
        CASE 
            WHEN INSTR(nm_orgao_usu, ' /' ,1) <> 0 
            THEN SUBSTR(nm_orgao_usu, INSTR(nm_orgao_usu, ' /' ,1)+3, LENGTH(nm_orgao_usu)) 
            ELSE nm_orgao_usu 
        END as nome_orgao
    FROM corporativo.cp_orgao_usuario
)
, dbu_interno AS ( -- Usuários internos
    SELECT
        TO_CHAR(trunc(data_criacao_identidade, 'IW') + 7, 'YYYY/MM/DD') semana,
        id_orgao_usu id_orgao
    FROM corporativo.cp_identidade
    WHERE id_orgao_usu NOT IN (9999999999, 90000) -- Retira ID do órgão TESTE e Terceirizados
    AND his_dt_fim IS NULL -- Usuários não excluídos do sistema
    AND data_criacao_identidade < TIMESTAMP '2021-10-11 00:00:00.000'
)
SELECT 
    semana,
    nome_orgao,
    COUNT(1) as total
FROM 
    dbu_interno,
    dbo_nome
WHERE 
    dbo_nome.id_orgao = dbu_interno.id_orgao
GROUP BY 
    nome_orgao,
    semana
order by semana desc