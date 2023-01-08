-- Many Function Spell Hit AOE 10.0.2/1

-- Set Priority to 5

-- counter "spellhitaoe" tell n mob hit by spell in timeInterval

--function IROVar.SpellHitAOE.Register_Spell_Hit_AOE_Check(spellName,Timer)
--function IROVar.SpellHitAOE.Register_Spell_Aura_AOE_Check(spellName,Timer)

if not IROVar.SpellHitAOE then IROVar.SpellHitAOE={} end
local SpellCheck={} --{[Spell1]=true,....}
local AuraCheck={} --{[Aura1]=true,....}
local MobHited={} --{[MobGUID]=timeExpire}
local MobHitedTimer=8
local counterName="spellhitaoe"

function IROVar.SpellHitAOE.Register_Spell_Hit_AOE_Check(spellName,Timer)
    MobHitedTimer=Timer or MobHitedTimer
    if type(spellName)=="table" then
        for _,v in pairs(spellName) do
            SpellCheck[v]=true
        end
    else
        SpellCheck[spellName]=true
    end
end
function IROVar.SpellHitAOE.Register_Spell_Aura_AOE_Check(spellName,Timer)
    MobHitedTimer=Timer or MobHitedTimer
    if type(spellName)=="table" then
        for _,v in pairs(spellName) do
            AuraCheck[v]=true
        end
    else
        AuraCheck[spellName]=true
    end
end

local playerGUID=UnitGUID("player")
local AuraEVENTCheck={
    ["SPELL_AURA_APPLIED"]=true,
    ["SPELL_AURA_APPLIED_DOSE"]=true,
    ["SPELL_AURA_REFRESH"]=true,
}
local AuraEVENTCheck2={
    ["SPELL_DAMAGE"]=true,
    ["SPELL_PERIODIC_DAMAGE"]=true,
}
local function CheckSpell(...)
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,_,_,_,spellID,spellName = ...
    if subevent=="UNIT_DIED" then
        MobHited[DesGUID]=nil
    end
    if (sourceGUID~=playerGUID) then return end
    if (AuraEVENTCheck2[subevent])and
    (SpellCheck[spellID] or SpellCheck[spellName]) then
        MobHited[DesGUID]=TMW.time+MobHitedTimer
    elseif AuraEVENTCheck[subevent] and (AuraCheck[spellID] or AuraCheck[spellName]) then
        MobHited[DesGUID]=TMW.time+MobHitedTimer
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Spell Hit AOE",CheckSpell)

local function CountMob()
    local count=0
    for k,v in pairs(MobHited) do
        if v>=TMW.time then
            count=count+1
        else
            MobHited[k]=nil
        end
    end
    IROVar.UpdateCounter(counterName,count)
end
C_Timer.NewTicker(0.37,CountMob)