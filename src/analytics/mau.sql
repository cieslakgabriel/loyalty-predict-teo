-- mau MONTHLY ACTIVE USERS
-- conta com base de 28 dias, padronizando os valores

with tb_daily as (
SELECT DISTINCT
    date(substr(DtCriacao,0,11)) as DtDia
,   idCliente
from transacoes
order by DtDia
),
tb_distinct_day as (
 select 
    distinct DtDia as dtref
 from tb_daily
 )

SELECT t1.dtRef
,     count(distinct idCliente) as MAU
, count(DISTINCT t2.DtDia) as DAU
from tb_distinct_day t1
left join tb_daily t2
on t2.DtDia <= t1.dtref
and julianday(t1.dtref) - julianday(t2.DtDia) < 28
group by t1.dtRef
order by t1.dtRef asc

