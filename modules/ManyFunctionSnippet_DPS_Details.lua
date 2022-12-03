





--DPS

local _detalhes=_detalhes

local LastCombatTime=_detalhes.tabela_vigente:GetCombatTime()

local playerName=UnitName("player")

local playerDetailsIndex=_detalhes.tabela_vigente[1]._NameIndexTable[playerName]

local playerDmg=_detalhes.tabela_vigente[1]._ActorTable[playerDetailsIndex].total

local playerDPS=playerDmg/LastCombatTime




local PDPS=_detalhes.tabela_vigente[1]._ActorTable[_detalhes.tabela_vigente[1]._NameIndexTable[UnitName("player")]].total/_detalhes.tabela_vigente:GetCombatTime()
