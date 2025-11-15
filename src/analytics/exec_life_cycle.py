# %%
import pandas as pd
import sqlalchemy

# %%
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query
query = import_query("life_cycle.sql")
print(query)

engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///../../data/analytics/analytical.db")
# %%
df = pd.read_sql(query, engine_app)

df.to_sql("life_cycle", engine_analytical, if_exists="append", index=False)