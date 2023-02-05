-- Many Function Spell Hit AOE 10.0.2/3

-- Set Priority to 6
-- Use Many Function DPS Average 10.0.0/3 if calculate

-- counter "spellhitaoe" tell n mob hit by spell in timeInterval
-- counter "spellhitaoetrunk" exclude mob die in 4 sec out

--function IROVar.SpellHitAOE.Register_Spell_Hit_AOE_Check(spellName,Timer)
--function IROVar.SpellHitAOE.Register_Spell_Aura_AOE_Check(spellName,Timer)
--function IROVar.SpellHitAOE.Register_Spell_FromMyPet_Hit_AOE_Check(spellName,Timer)


if not IROVar.SpellHitAOE then IROVar.SpellHitAOE={} end
local SpellCheck={} --{[Spell1]=true,....}
local SpellPetChesk={}
local AuraCheck={} --{[Aura1]=true,....}
local MobHited={} --{[MobGUID]=timeExpire}
local MobHitedTimer=8
local counterName="spellhitaoe"
local counterNameTrunk="spellhitaoetrunk"

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

function IROVar.SpellHitAOE.Register_Spell_FromMyPet_Hit_AOE_Check(spellName,Timer)
    MobHitedTimer=Timer or MobHitedTimer
    if type(spellName)=="table" then
        for _,v in pairs(spellName) do
            SpellPetChesk[v]=true
        end
    else
        SpellPetChesk[spellName]=true
    end
end

local playerGUID=UnitGUID("player")
local petGUID=UnitGUID("pet")
TMW_ST:AddEvent("UNIT_PET",function(event,UnitToken)
    if UnitToken=="player" then
        petGUID=UnitGUID("pet")
        print("pet change")
    end
end)

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
    if (sourceGUID==playerGUID) then
        if (AuraEVENTCheck2[subevent])and
        (SpellCheck[spellID] or SpellCheck[spellName]) then
            MobHited[DesGUID]=TMW.time+MobHitedTimer
        elseif AuraEVENTCheck[subevent] and (AuraCheck[spellID] or AuraCheck[spellName]) then
            MobHited[DesGUID]=TMW.time+MobHitedTimer
        end
    elseif petGUID and (sourceGUID==petGUID) then
        if (AuraEVENTCheck2[subevent])and
        (SpellPetChesk[spellID] or SpellPetChesk[spellName]) then
            MobHited[DesGUID]=TMW.time+MobHitedTimer
        end
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Spell Hit AOE",CheckSpell)

local function CountMob()
    local tarGUID=UnitGUID("target")
    if not tarGUID then
        IROVar.UpdateCounter(counterName,0)
        IROVar.UpdateCounter(counterNameTrunk,0)
    elseif (not MobHited[tarGUID])or(MobHited[tarGUID]<TMW.time)  then
        IROVar.UpdateCounter(counterName,1)
        IROVar.UpdateCounter(counterNameTrunk,1)
    else
        local count=0
        for k,v in pairs(MobHited) do
            if v>=TMW.time then
                count=count+1
            else
                MobHited[k]=nil
            end
        end
        IROVar.UpdateCounter(counterName,count)

        count=0
        for i=1,30 do
            local np="nameplate"..i
            local npGUID=UnitGUID(np)
            count=count+((npGUID and MobHited[npGUID] and IROVar.DPS.PredictUnitLifeTime(np)>4) and 1 or 0)
        end
        IROVar.UpdateCounter(counterNameTrunk,count)
    end
end

C_Timer.NewTicker(0.37,CountMob)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Spell Hit AOE",CountMob)