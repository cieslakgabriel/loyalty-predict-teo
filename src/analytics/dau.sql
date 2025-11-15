-- dau DAILY ACTIVE USERS
SELECT substr(DtCriacao,0,11) as DtDia,
count(DISTINCT idCliente) as DAU
from transacoes
group by 1
order by DtDia
