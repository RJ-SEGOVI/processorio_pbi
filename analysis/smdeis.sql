-- TESTE: Identificar tramitação de publicação de licença

WITH dbd AS ( -- ID e número do documento
    SELECT 
        dbu.acronimo_orgao_usu || '-' ||
        dbe.sigla_forma_doc    || '-' ||
        dbd.ano_emissao        || '/' ||
        lpad (dbd.num_expediente, 5, '0') numero_doc,
        dbd.id_doc
    FROM siga.vw_ex_documento dbd  -- Tabela documento só possui id_doc
    INNER JOIN corporativo.cp_orgao_usuario dbu 
    ON (dbd.id_orgao_usu = dbu.id_orgao_usu)
    INNER JOIN siga.ex_forma_documento dbe
    ON (dbd.id_forma_doc = dbe.id_forma_doc)
),
dbm AS ( --  Movimentações para cada ID de documento
    SELECT 
        dbil.id_doc,
        dbmov.id_mov,
        dbmov.id_tp_mov, -- Tipo da movimentação
        dbmov_tipo.descr_tipo_movimentacao,
        dbmov.id_mov_canceladora,
        dbmov.dt_timestamp,
        dbmov.descr_mov, -- Descrição movimentação
        dbmov.id_cadastrante, -- ID do cadastrante,
        -- id_classificacao, NULO
        NM_ARQ_MOV,
        NUM_PAGINAS
    FROM 
        siga.ex_mobil dbil, -- Tabela de-para id_doc, id_mobil
        siga.ex_movimentacao dbmov, -- Tabela movimentação só possui id_mobil
        siga.ex_tipo_movimentacao dbmov_tipo
    WHERE dbil.id_mobil = dbmov.id_mobil 
    AND dbmov_tipo.id_tp_mov = dbmov.id_tp_mov
)
SELECT 
    dbd.numero_doc,
    dbm.*
FROM dbd, dbm
WHERE 
    dbd.id_doc = dbm.id_doc
    AND REGEXP_LIKE (UPPER(nm_arq_mov), '(*)LICENÇA (DE |)(OBRA|REFORMA|CONSTRUÇÃO|DEMOLIÇÃO|MODIFICAÇÃO)(*)')
    -- AND dbm.id_mobil = 21852
    -- AND dbd.numero_doc = 'EIS-PRO-2021/00133''
    -- AND dbd.numero_doc = 'EIS-PRO-2021/00133'
ORDER BY dt_timestamp ASC;
   
-- ==> CHECKS: 

--SELECT 
--    id_mobil, 
--    count(*) as conta 
--FROM siga.ex_movimentacao 
--GROUP BY id_mobil 
--ORDER BY conta DESC;

-- Cada documento possui um id_doc único - OK

--SELECT id_doc, count(*) conta FROM siga.vw_ex_documento GROUP BY id_doc ORDER BY conta DESC;

-- Cada id_doc possui um único id_mobil associado - OK

--SELECT 
--    id_mobil, id_doc, count(*) conta
--FROM siga.ex_mobil 
--GROUP BY id_doc, id_mobil 
--ORDER BY conta ASC;

-- Cada movimentacao possui somente um id_mov - OK
-- SELECT id_mov, count(*) conta FROM siga.ex_movimentacao GROUP BY id_mov ORDER BY conta DESC;

-- Cada id_tipo_mov possui somente uma descr_tipo_movimentacao - OK 

-- SELECT id_tp_mov, count(*) conta FROM siga.ex_tipo_movimentacao GROUP BY id_tp_mov ORDER BY conta DESC;
-- SELECT id_mov, id_tp_mov, count(*) conta FROM siga.ex_movimentacao GROUP BY id_mov, id_tp_mov ORDER BY conta DESC;