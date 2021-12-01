-- Total de usuários internos cadastrados:

-- 1. Seleciona pessoas de subsetores considerados para contagem, com o nome mais recente de cada
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
-- 2. Busca identificador id_pessoa de cada pessoa nos subsetores considerados
dbl_pessoa as (
    select 
        id_pessoa,
        dbl.id_lotacao,
        sigla_lotacao,
        nome_lotacao
    from dbo_lotacao dbl
    inner join corporativo.dp_pessoa dbp
    on dbl.id_lotacao = dbp.id_lotacao
),
-- 3. Seleciona nomes dos órgãos (sem ser subsetor) para cada id_orgao
dbo_nome as 
    (select 
        id_orgao_usu as id_orgao,
        case 
            when INSTR(nm_orgao_usu, ' /' ,1) <> 0 
            then SUBSTR(nm_orgao_usu, INSTR(nm_orgao_usu, ' /' ,1)+3, length(nm_orgao_usu)) 
            else nm_orgao_usu 
        end as nome_orgao
    from corporativo.cp_orgao_usuario
    where his_ativo = 1
),
-- 4. Seleciona todos os logins criados por semana e órgão/subsetor (somente INTERNOS):
db_usuarios as (
    select
        data_criacao_identidade
        ,TO_CHAR(trunc(data_criacao_identidade, 'IW') + 7, 'YYYY/MM/DD') semana
        ,case 
            when dbi.id_pessoa in dbl.id_pessoa
            then id_lotacao
            else id_orgao_usu
        end id_orgao
        ,case 
            when dbi.id_pessoa in dbl.id_pessoa
            then nome_lotacao
            else nome_orgao
        end nome_orgao
    from corporativo.cp_identidade dbi
    left join dbo_nome dbo
    on dbi.id_orgao_usu = dbo.id_orgao
    left join dbl_pessoa dbl
    on dbi.id_pessoa = dbl.id_pessoa
    where id_orgao_usu not in (9999999999, 90000) -- Retira ID do órgão TESTE
    and his_dt_fim IS NULL -- Usuários não excluídos do sistema
    and data_criacao_identidade > date '2021-01-01' -- Filtra dados de 2021
    and trunc(data_criacao_identidade, 'IW') + 7 <= date '2021-11-29' -- Filtra até o dia anterior: ALTERAR AQUI
)
select 
    semana,
    nome_orgao,
    count(1) as total_logins
from db_usuarios
group by 
    nome_orgao,
    semana
order by semana desc