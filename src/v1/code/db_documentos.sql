-- Total de documentos criados em meio eletrônico por:
-- => Órgão
-- => Espécie
-- => Semana
-- => Assunto
-- => Modelo

-- 1. Seleciona subsetores considerados para contagem, com o nome mais recente de cada
with dbo_lotacao as 
    (select * from 
        (select 
            sigla_lotacao,
            id_orgao_usu,
            nome_lotacao,
            id_lotacao,
            row_number() over (partition by sigla_lotacao order by data_ini_lot desc) as rn
        from corporativo.dp_lotacao
        where sigla_lotacao in 
        ('1403', '1405', '42294', '1409', '1408', '47633', '1815', '2309', '1816', '4113'))
    where rn = 1
),
-- 2. Seleciona nomes dos órgãos para cada id
dbo_nome as 
    (select 
        id_orgao_usu as id_orgao,
        case 
            when INSTR(nm_orgao_usu, ' /' ,1) <> 0 
            then SUBSTR(nm_orgao_usu, INSTR(nm_orgao_usu, ' /' ,1)+3, length(nm_orgao_usu)) 
            else nm_orgao_usu 
        end as nome_orgao
    from corporativo.cp_orgao_usuario
), 
-- 3. Lista documentos não juntados, adiciona sigla do órgão/subsetor,
-- adiciona id do tipo documental e separa informações dos subsetores considerados.
dbd_ativos as 
    (select
        to_char(trunc(dt_doc, 'IW') + 7, 'YYYY/MM/DD') as semana
        ,id_doc
        ,case 
            when id_lota_titular in dbl.id_lotacao
            then id_lota_titular
            else docs.id_orgao_usu
        end id_orgao
        ,case 
            when docs.id_lota_titular in dbl.id_lotacao
            then nome_lotacao
            else nome_orgao
        end nome_orgao
        ,id_forma_doc
        ,id_classificacao
        ,id_mod
    from siga.vw_ex_documento docs
    left join dbo_lotacao dbl
    on dbl.id_lotacao = docs.id_lota_titular
    left join dbo_nome dbn
    on dbn.id_orgao = docs.id_orgao_usu
    where docs.id_orgao_usu <> '9999999999' -- Retira ID do órgão TESTE
    and dt_doc is not null -- Documentos criados, não contabilizando os temporários
    and dt_doc > date '2021-01-01' -- Filtra dados de 2021
    and trunc(dt_doc, 'IW') + 7 <= date '2021-11-29' -- Filtra até o dia anterior: ALTERAR AQUI
    and id_doc_pai is null -- Documentos únicos, não contabilizando os juntados
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
),
dba_nome AS ( -- Nome do assunto para cada ID
    SELECT 
        id_classificacao
        ,descr_classificacao as assunto
    FROM siga.ex_classificacao
)
-- 4. Conta documentos por data, orgao/subsetor e tipo (Processo/Expediente)
select 
    semana,
    nome_orgao,
    especie,
    UPPER(modelo),
    UPPER(assunto),
    count(1) as total_doc
from dbd_ativos
inner join dba_nome
on dba_nome.id_classificacao = dbd_ativos.id_classificacao
inner join dbe_tipo
on dbe_tipo.id_forma_doc = dbd_ativos.id_forma_doc
inner join dbm_nome
on dbm_nome.id_mod = dbd_ativos.id_mod
group by 
    semana, 
    nome_orgao, 
    especie,
    UPPER(modelo),
    UPPER(assunto)
order by semana desc