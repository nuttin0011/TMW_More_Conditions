-- Many Function Version Druid Feral 10.0.2/2
-- Set Priority to 10

--function IROVar.DruidFeral.DotRakeEmpower(unitToken) -- return %Rake DMG , Eg no buff = 100, Has Berserk = 160
--function IROVar.DruidFeral.DotRipEmpower(unitToken) -- return %Rip DMG , Dot at target , Eg no buff = 100, Has Bloodtalons = 130
    -- e.g. IROVar.DruidFeral.DotRakeEmpower("target")
--function IROVar.DruidFeral.CastRakeEmpower() -- return %Rip DMG, will cast to target
--function IROVar.DruidFeral.CastRakeEmpowerWithTigerFury()
--function IROVar.DruidFeral.CastRipEmpower()
--function IROVar.DruidFeral.CastRipEmpowerWithTigerFury()
--function IROVar.DruidFeral.TigerFuryReady()

if not IROVar then IROVar = {} end
if not IROVar.DruidFeral then IROVar.DruidFeral = {} end

if #TMW.CNDT.Env.TalentMap==0 then -- use function TMW to update player talents,
    TMW.CNDT:PLAYER_TALENT_UPDATE()
    -- talent's data in TMW.CNDT.Env.TalentMap
    -- use lower case Ex TMW.CNDT.Env.TalentMap["carnivorous instinct"]
end

IROVar.DruidFeral.HasBloodtalonsTalent = false
IROVar.DruidFeral.TigerFuryReadyTime=GetTime()+TMW.CNDT.Env.CooldownDuration("Tiger's Fury")
IROVar.DruidFeral.FTigerFury = CreateFrame("Frame")
IROVar.DruidFeral.FTigerFury:RegisterEvent("SPELL_UPDATE_COOLDOWN")
IROVar.DruidFeral.FTigerFury:SetScript("OnEvent", function()
    IROVar.DruidFeral.TigerFuryReadyTime=GetTime()+TMW.CNDT.Env.CooldownDuration("Tiger's Fury")
end)
function IROVar.DruidFeral.TigerFuryReady()
    return GetTime()>=IROVar.DruidFeral.TigerFuryReadyTime
end
IROVar.DruidFeral.AuraEffectRakeRip ={
    -- [auraName] = {effect Rake, effect rip, %increase}
    ["Tiger's Fury"]={true,true,15},
    --["Savage Roar"]={true,true,15},
    ["Berserk"]={true,false,60},
    ["Bloodtalons"]={false,true,25},
    ["Sudden Ambush"]={true,false,60},
    ["Prowl"]={true,false,60},
}

function IROVar.DruidFeral.CheckCarnivorousInstinct()
    local ctalent=TMW.CNDT.Env.TalentMap["carnivorous instinct"]
    ctalent=(ctalent or 0)*6
    -- talent "carnivorous instinct" + Dmg 6% per point
    IROVar.DruidFeral.AuraEffectRakeRip["Tiger's Fury"][3]=15+ctalent
end
IROVar.DruidFeral.CheckCarnivorousInstinct()

IROVar.DruidFeral.PlayerHasAura ={}
--[[
    ["Sudden Ambush"]=TMW.CNDT.Env.AuraDur("player", "sudden ambush", "PLAYER HELPFUL")>0,
    ["Bloodtalons"]=TMW.CNDT.Env.AuraDur("player", "bloodtalons", "PLAYER HELPFUL")>0,
    ["Savage Roar"]=TMW.CNDT.Env.AuraDur("player", "savage roar", "PLAYER HELPFUL")>0,
    ["Tiger's Fury"]=TMW.CNDT.Env.AuraDur("player", "tiger's fury", "PLAYER HELPFUL")>0,
    ["Berserk"]=TMW.CNDT.Env.AuraDur("player", "berserk", "PLAYER HELPFUL")>0
]]

IROVar.DruidFeral.CheckPlayerAuraForRakeRip = function()
    for auraName in pairs(IROVar.DruidFeral.AuraEffectRakeRip) do
        IROVar.DruidFeral.PlayerHasAura[auraName] = false
    end
    for i=1,40 do
        local name = UnitBuff("player", i,"PLAYER")
        if name and IROVar.DruidFeral.AuraEffectRakeRip[name] then
            IROVar.DruidFeral.PlayerHasAura[name] = true
        else break end
    end
end

IROVar.DruidFeral.CastEmpowerInfo = {0,0} --{RakeEmpower,RipEmpower},

IROVar.DruidFeral.CheckPlayerAuraForRakeRip()

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
    if aura==1 and IROVar.DruidFeral.PlayerHasAura["Berserk"] and IROVar.DruidFeral.PlayerHasAura["Sudden Ambush"] then
        -- Berserk and Sudden Ambush is same aura
        power = power - 60
    end
    return power
end

function IROVar.DruidFeral.CheckCastEmpower()
    IROVar.DruidFeral.CastEmpowerInfo[1]=IROVar.DruidFeral.EncodeEmpowerAura(1)
    IROVar.DruidFeral.CastEmpowerInfo[2]=IROVar.DruidFeral.EncodeEmpowerAura(2)
end
IROVar.DruidFeral.CheckCastEmpower()

function IROVar.DruidFeral.DotRakeEmpower(unitToken) -- return %Rake DMG , Eg no buff = 100, Has Berserk = 160
    --Rake
    unitToken=unitToken or "target"
    local unitGUID=UnitGUID(unitToken)
    if not unitGUID then return 0 end
    if not IROVar.DruidFeral.DotAtMobInfo[unitGUID] then return 0 end
    return IROVar.DruidFeral.DotAtMobInfo[unitGUID][1]
end

function IROVar.DruidFeral.DotRipEmpower(unitToken) -- return %Rip DMG , Eg no buff = 100, Has Bloodtalons = 130
    --rip
    unitToken=unitToken or "target"
    local unitGUID=UnitGUID(unitToken)
    if not unitGUID then return 0 end
    if not IROVar.DruidFeral.DotAtMobInfo[unitGUID] then return 0 end
    return IROVar.DruidFeral.DotAtMobInfo[unitGUID][2]
end

function IROVar.DruidFeral.CastRakeEmpower()
    return IROVar.DruidFeral.CastEmpowerInfo[1]
end

function IROVar.DruidFeral.CastRipEmpower()
    return IROVar.DruidFeral.CastEmpowerInfo[2]
end

function IROVar.DruidFeral.CastRakeEmpowerWithTigerFury()
    return IROVar.DruidFeral.CastEmpowerInfo[1] +
    (IROVar.DruidFeral.TigerFuryReady() and IROVar.DruidFeral.AuraEffectRakeRip["Tiger's Fury"][3] or 0)
end

function IROVar.DruidFeral.CastRipEmpowerWithTigerFury()
    return IROVar.DruidFeral.CastEmpowerInfo[2] +
    (IROVar.DruidFeral.TigerFuryReady() and IROVar.DruidFeral.AuraEffectRakeRip["Tiger's Fury"][3] or 0)
end


function IROVar.DruidFeral.CheckTalent()
    TMW.CNDT:PLAYER_TALENT_UPDATE()
    IROVar.DruidFeral.HasBloodtalonsTalent = TMW.CNDT.Env.TalentMap["bloodtalons"]
end

function IROVar.DruidFeral.ClearDotAtMobInfo()
    IROVar.DruidFeral.DotAtMobInfo = {}
end

function IROVar.DruidFeral.FOnEvent(_,event)
    if IROVar.DebugMode then
        print("Event in DruidFeral On Event",event)
    end
    if event == "PLAYER_TALENT_UPDATE" then
        C_Timer.After(2,function()
            IROVar.DruidFeral.CheckTalent()
        end)
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- out combat
        IROVar.DruidFeral.ClearDotAtMobInfoHandle=C_Timer.NewTimer(20,IROVar.DruidFeral.ClearDotAtMobInfo)
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- in combat
        if IROVar.DruidFeral.ClearDotAtMobInfoHandle then
            IROVar.DruidFeral.ClearDotAtMobInfoHandle:Cancel()
            IROVar.DruidFeral.ClearDotAtMobInfoHandle=nil
        end
        IROVar.DruidFeral.CheckPlayerAuraForRakeRip()
        IROVar.DruidFeral.CheckCastEmpower()
        IROVar.DruidFeral.CheckCarnivorousInstinct()
    end
end

IROVar.DruidFeral.FEvent = CreateFrame("Frame")
IROVar.DruidFeral.FEvent:RegisterEvent("PLAYER_TALENT_UPDATE")
IROVar.DruidFeral.FEvent:RegisterEvent("PLAYER_REGEN_ENABLED")
IROVar.DruidFeral.FEvent:RegisterEvent("PLAYER_REGEN_DISABLED")
IROVar.DruidFeral.FEvent:SetScript("OnEvent", IROVar.DruidFeral.FOnEvent)
IROVar.DruidFeral.CheckTalent()

IROVar.DruidFeral.AuraDelay={["Prowl"]=true,["Sudden Ambush"]=true} -- this aura Ramoved befor apply dot


IROVar.DruidFeral.CombatEvent = function(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    if sourceGUID~=IROVar.playerGUID then return end

    local function CheckRakeRip(sName,dGUID,isRemoved)
        if sName == "Rake" then
            if not IROVar.DruidFeral.DotAtMobInfo[dGUID] then
                IROVar.DruidFeral.DotAtMobInfo[dGUID]={0,0}
            end
            IROVar.DruidFeral.DotAtMobInfo[dGUID][1]=isRemoved and 0 or IROVar.DruidFeral.CastEmpowerInfo[1]
        elseif sName == "Rip" then
            if not IROVar.DruidFeral.DotAtMobInfo[dGUID] then
                IROVar.DruidFeral.DotAtMobInfo[dGUID]={0,0}
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
            if IROVar.DruidFeral.AuraDelay[spellName] then
                --"Sudden Ambush"+"Prowl" removed befor "Rake" apple , must check "Rake" as have "Sudden Ambush"
                C_Timer.After(0.5,function()
                    IROVar.DruidFeral.PlayerHasAura[spellName]=false
                    CheckCastEmpower(spellName)
                end)
            else
                IROVar.DruidFeral.PlayerHasAura[spellName]=false
                CheckCastEmpower(spellName)
            end
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

