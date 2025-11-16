# %%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
from sklearn import cluster
from sklearn import preprocessing
import seaborn as sns


#%%
engine= sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

# %%
def import_query(path):
    with open(path) as open_file:
        return open_file.read()
    
query = import_query("frequencia_valor.sql")

# %%
df = pd.read_sql(query, engine)

df.head()

df = df[df['qtdPontos'] < 4000]

# %%
plt.plot(df['qtdFrequencia'], df['qtdPontos'], 'o')
plt.grid(True)
plt.xlabel('Frequência')
plt.ylabel('Valor')
plt.show()

# %%
minmax = preprocessing.MinMaxScaler()
x = minmax.fit_transform(df[['qtdFrequencia', 'qtdPontos']])

df_x = pd.DataFrame(x, columns=['normFreq', 'normValor'])


# %%
kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)
kmean.fit(x)

df['cluster_calc'] = kmean.labels_

df_x['cluster'] = kmean.labels_

df.groupby(by='cluster_calc')['idCliente'].count()




# %%
sns.scatterplot(data=df, x='qtdFrequencia', y='qtdPontos', hue='cluster_calc', palette='deep')
plt.hlines(y=1500,xmin=0, xmax=25, colors='black')
plt.hlines(y=750,xmin=0, xmax=25, colors='black')
plt.vlines(x=4,ymin=0, ymax=750, colors='black')
plt.vlines(x=10,ymin=0, ymax=3000, colors='black')
plt.grid()


# %%
sns.scatterplot(data=df, x='qtdFrequencia', y='qtdPontos', hue='cluster', palette='deep')
plt.hlines(y=1500,xmin=0, xmax=25, colors='black')
plt.hlines(y=750,xmin=0, xmax=25, colors='black')
plt.vlines(x=4,ymin=0, ymax=750, colors='black')
plt.vlines(x=10,ymin=0, ymax=3000, colors='black')
plt.grid()

# %%