# processorio_pbi

Código aberto do painel de indicadores do Processo.rio:
https://processo.rio/indicadores-do-projeto/

O código para produção do painel encontra-se em `src`.

> O Processo.rio é construído a partir do módulo Siga-doc do projeto *open source*
> SIGA, veja o [código do projeto aqui](https://github.com/projeto-siga/siga).

## Requerimentos

- [PowerBI Desktop](https://powerbi.microsoft.com/pt-br/desktop/)
- [SQL Developer](https://www.oracle.com/database/technologies/appdev/sqldeveloper-landing.html)
- [Java SE 11 (LTS) ou Java SE 8, utilizado o
  11](https://www.oracle.com/java/technologies/javase-downloads.html)
- Acesso ao banco Oracle (IPLAN)

## Desenvolvimento/Análises

A pasta `analysis` possui notebooks e queries de análise exploratória
dos indicadores. Para explorar os dados do Processo.rio em Python,
siga os passos:

1. Instale os pacotes necessários:

```bash
pip install -r analysis/requirements.txt
```

1. Adicione suas credenciais em `analysis/.env` (user, password, dsn),
   conforme:

```
oracle_prod_user="<user>"
oracle_prod_password="<password>"
oracle_prod_dsn="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=XX.XX.X.XX)(PORT=YYYY))(CONNECT_DATA=(SID=SIGADOC)))"
```

2. Siga os passos de configuração do `cx_Oracle`
   [aqui](https://cx-oracle.readthedocs.io/en/latest/user_guide/installation.html#quick-start-cx-oracle-installation).
   Salve o caminho para o diretório de bibliotecas do `cx_Oracle` no
   `analysis/.env` com o nome `oracle_lib_dir` (ex:
   `oracle_lib_dir="/Users/fernandascovino/Library/Oracle"`).

3. Rode a conexão com o banco em Python no seu notebook chamando as
   [configurações](analysis/config.py) com o comando:

```python3
%load config.py
```