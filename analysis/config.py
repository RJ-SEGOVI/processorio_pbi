%reload_ext autoreload
%autoreload 2

import cx_Oracle
import os
from dotenv import load_dotenv
from copy import deepcopy
import numpy as np
import pandas as pd
pd.options.display.max_columns = 999
import plotly.express as px

# Carrega credenciais
load_dotenv()

# Conecta ao banco
cx_Oracle.init_oracle_client(lib_dir=os.getenv('oracle_lib_dir'))

con = cx_Oracle.connect(
    user=os.getenv('oracle_prod_user'), 
    password=os.getenv('oracle_prod_password'), 
    dsn=os.getenv('oracle_prod_dsn'),
    encoding="UTF-8")

cursor = con.cursor()
