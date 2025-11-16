select dtRef,
descLifeCycle,
cluster,
count(*) as qtdCliente

from life_cycle

where descLifeCycle <> '05 - ZUMBI'
group by 1,2,3
order by 1,2,3