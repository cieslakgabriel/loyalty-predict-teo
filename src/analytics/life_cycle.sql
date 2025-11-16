/* 
## DEFINIÇÃO DO CICLO DE VIDA DO USUARIO
curiosa -> idade < 7
fiel -> recência < 7 e recência anterior < 15
turista -> 7 <= recência <= 14
desencatado -> 14 < recência <= 28
zumbi -> recência > 28
reconquistado -> recência < 7 e 14 <= recência anterior <= 28
reborn -> recência < 7 e  recência anterior <= 28
*/

with 
tb_daily as (
    SELECT DISTINCT
        date(substr(DtCriacao,0,11)) as dtDia
    ,   idCliente
    from transacoes
    where DtCriacao < '{date}'
),
tb_idade as (
    select 
        idCliente
--    ,   min(dtDia) as dtPrimeiraTransacao
    ,   CAST(max(julianday('{date}')-julianday(dtDia)) as int) as qtdDiasPrimeiraTransacao
--    ,   max(dtDia) as dtUltimaTransacao   
    ,   CAST(min(julianday('{date}')-julianday(dtDia)) as int) as qtdDiasUltimaTransacao
    from tb_daily
    group by idCliente
),
tb_rn as (
    select * 
    ,   row_number() over (PARTITION by idCliente order by dtDia desc)as rnDia
    from tb_daily
),
tb_penultima_ativacao as (
    select * 
    ,   cast(julianday('now')- julianday(dtDia) as int) as qtdDiasPenultimaAtivacao    
    from tb_rn
    where rnDia = 2
),
tb_life_cycle as (
    select t1.*
    ,   t2.qtdDiasPenultimaAtivacao
    ,   CASE
            WHEN qtdDiasPrimeiraTransacao <= 7 THEN '01 - CURIOSO'
            WHEN qtdDiasUltimaTransacao	 <= 7 AND qtdDiasPenultimaAtivacao - qtdDiasUltimaTransacao <=14 THEN '02 - FIEL'
            WHEN qtdDiasUltimaTransacao	 BETWEEN 8 AND 14 THEN '03 - TURISTA'
            WHEN qtdDiasUltimaTransacao	 BETWEEN 15 AND 27 THEN '04 - DESENCANTADO'
            WHEN qtdDiasUltimaTransacao	 > 28 THEN '05 - ZUMBI'
            WHEN qtdDiasUltimaTransacao	 <= 7 AND qtdDiasPenultimaAtivacao - qtdDiasUltimaTransacao BETWEEN 15 AND 27 THEN '02 - RECONQUISTADO'
            WHEN qtdDiasUltimaTransacao	 <= 7 AND qtdDiasPenultimaAtivacao - qtdDiasUltimaTransacao > 28 THEN '02 - REBORN'
        end as descLifeCycle      
    from tb_idade as t1
    left JOIN tb_penultima_ativacao as t2
    on t1.idCliente = t2.idCliente
),
tb_freq_valor as (
    SELECT idCliente,
        count(distinct date(substr(DtCriacao,0,11))) as qtdFrequencia,
        sum(case when QtdePontos > 0 then QtdePontos else 0 end) as qtdPontos,
        sum(abs(QtdePontos)) as qtdPontosAbs
    from transacoes

    where DtCriacao < '{date}'
    and DtCriacao > date('{date}', '-28 day')
    group by idCliente
),
tb_cluster as (
select *,
    case
        when qtdFrequencia <= 10 and qtdPontos >= 1500 then '12-HYPERS'
        when qtdFrequencia > 10 and qtdPontos >= 1500 then '22-EFICIENTES'
        when qtdFrequencia <= 10 and qtdPontos > 750 then '11-INDECISOS'
        when qtdFrequencia > 10 and qtdPontos > 750 then '21-ESFORÇADOS'
        when qtdFrequencia < 5 then '00-LURKERS'
        when qtdFrequencia <= 10 then '01-PREGUIÇOSOS'
        when qtdFrequencia > 10 then '20-POTENCIAIS'
    end as cluster
from tb_freq_valor
)

select  
        date('{date}', '-1 day') as dtRef,
        t1.*,
        t2.qtdFrequencia,
        t2.qtdPontos,
        t2.cluster

from tb_life_cycle as t1
left JOIN tb_cluster as t2
on t1.idCliente = t2.idCliente



