with tb_freq_valor as (
    SELECT idCliente,
        count(distinct date(substr(DtCriacao,0,11))) as qtdFrequencia,
        sum(case when QtdePontos > 0 then QtdePontos else 0 end) as qtdPontos,
        sum(abs(QtdePontos)) as qtdPontosAbs
    from transacoes

    where DtCriacao < '2025-09-01'
    and DtCriacao > date('2025-09-01', '-28 day')
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

select *
from tb_cluster
