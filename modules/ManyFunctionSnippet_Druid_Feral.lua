-- Many Function Version Druid Feral 9.2.0/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.DruidFeral.DotRakeEmpower(unitToken) -- return %Rake DMG , Eg no buff = 100, Has Berserk = 160
--function IROVar.DruidFeral.DotRipEmpower(unitToken) -- return %Rip DMG , Dot at target , Eg no buff = 100, Has Bloodtalons = 130
--function IROVar.DruidFeral.CastRakeEmpower() -- return %Rip DMG, will cast to target
--function IROVar.DruidFeral.CastRipEmpower()

if not IROVar then IROVar = {} end
if not IROVar.DruidFeral then IROVar.DruidFeral = {} end

IROVar.DruidFeral.HasBloodtalonsTalent = false
IROVar.DruidFeral.HasTigerFuryAurs = TMW.CNDT.Env.AuraDur("player", "tiger's fury", "PLAYER HELPFUL")>0
IROVar.DruidFeral.HasSavageRoarAura = TMW.CNDT.Env.AuraDur("player", "savage roar", "PLAYER HELPFUL")>0
IROVar.DruidFeral.HasBerserkAurs = TMW.CNDT.Env.AuraDur("player", "berserk", "PLAYER HELPFUL")>0
IROVar.DruidFeral.HasBloodtalonsAura = TMW.CNDT.Env.AuraDur("player", "bloodtalons", "PLAYER HELPFUL")>0

IROVar.DruidFeral.AuraEffectRakeRip ={
    -- [auraName] = {effect Rake, effect rip, %increase}
    ["Tiger's Fury"]={true,true,15},
    ["Savage Roar"]={true,true,15},
    ["Berserk"]={true,false,60},
    ["Bloodtalons"]={false,true,30},
    ["Sudden Ambush"]={true,false,60},
}

function IROVar.DruidFeral.CheckCarnivorousInstinct()
    if IROVar.activeConduits["Carnivorous Instinct"] then -- conduit + Dmg Tiger's Fury assume 5%
        IROVar.DruidFeral.AuraEffectRakeRip["Tiger's Fury"][3]=20
    end
end
IROVar.DruidFeral.CheckCarnivorousInstinct()

IROVar.DruidFeral.PlayerHasAura ={
    ["Sudden Ambush"]=TMW.CNDT.Env.AuraDur("player", "sudden ambush", "PLAYER HELPFUL")>0,
    ["Bloodtalons"]=TMW.CNDT.Env.AuraDur("player", "bloodtalons", "PLAYER HELPFUL")>0,
    ["Savage Roar"]=TMW.CNDT.Env.AuraDur("player", "savage roar", "PLAYER HELPFUL")>0,
    ["Tiger's Fury"]=TMW.CNDT.Env.AuraDur("player", "tiger's fury", "PLAYER HELPFUL")>0,
    ["Berserk"]=TMW.CNDT.Env.AuraDur("player", "berserk", "PLAYER HELPFUL")>0
}

IROVar.DruidFeral.CastEmpowerInfo = {100,100} --{RakeEmpower,RipEmpower},
IROVar.DruidFeral.DotAtMobInfo = {}
--[[
    IROVar.DruidFeral.DotAtMobInfo = {
        ["Mob GUID"] = {RakeEmpower,RipEmpower},
]]

function IROVar.DruidFeral.EncodeEmpowerAura(aura) -- aura 1 is Rake , 2 is Rip
    local power = 100
    for k,v in pairs(IROVar.DruidFeral.PlayerHasAura) do
        if v then
            power = power + (IROVar.DruidFeral.AuraEffectRakeRip[k][aura] and IROVar.DruidFeral.AuraEffectRakeRip[k][3] or 0)
        end
    end
    return power
end


function IROVar.DruidFeral.DotRakeEmpower(unitToken) -- return %Rake DMG , Eg no buff = 100, Has Berserk = 160
    --Rake
    unitToken=unitToken or "target"
    local unitGUID=UnitGUID(unitToken)
    if not unitGUID then return 0 end
    if not IROVar.DruidFeral.DotAtMobInfo[unitGUID] then return 0 end
    return IROVar.DruidFeral.DotAtMobInfo[unitGUID][1] or 0
end

function IROVar.DruidFeral.DotRipEmpower(unitToken) -- return %Rip DMG , Eg no buff = 100, Has Bloodtalons = 130
    --rip
    unitToken=unitToken or "target"
    local unitGUID=UnitGUID(unitToken)
    if not unitGUID then return 0 end
    if not IROVar.DruidFeral.DotAtMobInfo[unitGUID] then return 0 end
    return IROVar.DruidFeral.DotAtMobInfo[unitGUID][2] or 0
end

function IROVar.DruidFeral.CastRakeEmpower()
    return IROVar.DruidFeral.CastEmpowerInfo[1]
end

function IROVar.DruidFeral.CastRipEmpower()
    return IROVar.DruidFeral.CastEmpowerInfo[2]
end

function IROVar.DruidFeral.CheckTalent()
    local _,TName,_,TSelected=GetTalentInfo(7,2,1)
    IROVar.DruidFeral.HasBloodtalonsTalent = (TName=="Bloodtalons") and TSelected
end

IROVar.DruidFeral.FOnEvent=function(_,event)
    if IROVar.DebugMode then
        print("Event in DruidFeral On Event",event)
    end
    if event == "PLAYER_TALENT_UPDATE" then
        C_Timer.After(2,IROVar.DruidFeral.CheckTalent)
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- out combat
        IROVar.DruidFeral.DotAtMobInfo ={}
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- in combat
        IROVar.DruidFeral.CheckCarnivorousInstinct()
    end
end

IROVar.DruidFeral.FEvent = CreateFrame("Frame")
IROVar.DruidFeral.FEvent:RegisterEvent("PLAYER_TALENT_UPDATE")
IROVar.DruidFeral.FEvent:RegisterEvent("PLAYER_REGEN_ENABLED")
IROVar.DruidFeral.FEvent:RegisterEvent("PLAYER_REGEN_DISABLED")
IROVar.DruidFeral.FEvent:SetScript("OnEvent", IROVar.DruidFeral.FOnEvent)
IROVar.DruidFeral.CheckTalent()

IROVar.DruidFeral.CombatEvent = function(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    if sourceGUID~=IROVar.playerGUID then return end

    local function CheckRakeRip(sName,dGUID,isRemoved)
        if sName == "Rake" then
            if not IROVar.DruidFeral.DotAtMobInfo[dGUID] then
                IROVar.DruidFeral.DotAtMobInfo[dGUID]={}
            end
            IROVar.DruidFeral.DotAtMobInfo[dGUID][1]=isRemoved and 0 or IROVar.DruidFeral.CastEmpowerInfo[1]
        elseif sName == "Rip" then
            if not IROVar.DruidFeral.DotAtMobInfo[dGUID] then
                IROVar.DruidFeral.DotAtMobInfo[dGUID]={}
            end
            IROVar.DruidFeral.DotAtMobInfo[dGUID][2]=isRemoved and 0 or IROVar.DruidFeral.CastEmpowerInfo[2]
        end
    end

    local function CheckCastEmpower(sName)
        for i=1,2 do
            if IROVar.DruidFeral.AuraEffectRakeRip[sName][i] then
                IROVar.DruidFeral.CastEmpowerInfo[i]=IROVar.DruidFeral.EncodeEmpowerAura(i)
            end
        end
    end

    if subevent=="SPELL_AURA_APPLIED" then
        local spellID, spellName = select(12,...)
        if IROVar.DruidFeral.AuraEffectRakeRip[spellName] then
            IROVar.DruidFeral.PlayerHasAura[spellName]=true
            CheckCastEmpower(spellName)
        else
            CheckRakeRip(spellName,destGUID)
        end
    elseif subevent=="SPELL_AURA_REMOVED" then
        local spellID, spellName = select(12,...)
        if IROVar.DruidFeral.AuraEffectRakeRip[spellName] then
            IROVar.DruidFeral.PlayerHasAura[spellName]=false
            CheckCastEmpower(spellName)
        else
            CheckRakeRip(spellName,destGUID,true)
        end
    elseif subevent=="SPELL_AURA_REFRESH" then
        local spellID, spellName = select(12,...)
        CheckRakeRip(spellName,destGUID)
    end
end

IROVar.DruidFeral.FCombatEvent = CreateFrame("Frame")
IROVar.DruidFeral.FCombatEvent:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.DruidFeral.FCombatEvent:SetScript("OnEvent", function(self, event)
    IROVar.DruidFeral.CombatEvent(CombatLogGetCurrentEventInfo())
end)

