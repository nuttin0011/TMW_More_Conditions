-- Many Function Rogue 9.0.5/2

--function IROVar.Rogue.UpdateRTBBuff() ; update IROVar.Rogue.RTBBuff table ; return next update time,
--function IROVar.Rogue.RTBBuff.count() ; return Buff RtB count
--IROVar.Rogue.RTBBuff={} -- keep RTB status { buffname = expire_time }
--function IROVar.Rogue.NeedRTB() ; return true / false
--function IROVar.Rogue.IsEnOverFlowNextGCD(n) ; return next n sec is En over flow?
--function IROVar.Rogue.ComboSerratedBoneSpikeGen() ; return number


if not IROVar then IROVar={} end
if not IROVar.Rogue then IROVar.Rogue={} end

IROVar.Rogue.RTBBuffName={
    ["Broadside"]=true,
    ["True Bearing"]=true,
    ["Ruthless Precision"]=true,
    ["Skull and Crossbones"]=true,
    ["Buried Treasure"]=true,
    ["Grand Melee"]=true,
}


IROVar.Rogue.RTBBuff={} -- keep RTB status { buffname = expire_time }
for k,_ in pairs(IROVar.Rogue.RTBBuffName) do
    IROVar.Rogue.RTBBuff[k]=0
end
IROVar.Rogue.playerGUID=UnitGUID("player")
IROVar.Rogue.LastTimeUseRtB=0
IROVar.Rogue.TimeCheckRtB=0

function IROVar.Rogue.UpdateRTBBuff()
    IROVar.Rogue.RTBBuff.OldCount = -1
    local now=GetTime()
    local nextUpdate=math.huge
    for k,_ in pairs(IROVar.Rogue.RTBBuffName) do
        IROVar.Rogue.RTBBuff[k]=0
    end
    for i=1,40 do
        local name, _, _, _, _, exTime=UnitBuff("player",i,"PLAYER")
        if not name then
            break
        else
            exTime=exTime-1
            if IROVar.Rogue.RTBBuffName[name] and (exTime>now) then
                IROVar.Rogue.RTBBuff[name]=exTime
                if exTime<nextUpdate then nextUpdate=exTime end
            end
        end
    end
    return nextUpdate+0.3
end

IROVar.Rogue.RTBBuff.OldCount = -1
-- -1 mean need to recount buff , mod by Change Buff
function IROVar.Rogue.RTBBuff.count()

    local now = GetTime()
    if now>IROVar.Rogue.TimeCheckRtB then
        IROVar.Rogue.TimeCheckRtB=IROVar.Rogue.UpdateRTBBuff()
        IROVar.Rogue.RTBBuff.OldCount = -1
    end
    if IROVar.Rogue.RTBBuff.OldCount >= 0 then return IROVar.Rogue.RTBBuff.OldCount end
    local c =0
    for k,_ in pairs(IROVar.Rogue.RTBBuffName) do
        if IROVar.Rogue.RTBBuff[k]>now then c = c+1 end
    end
    IROVar.Rogue.RTBBuff.OldCount=c
    return c
end

function IROVar.Rogue.CombatEvent()
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,spellName=CombatLogGetCurrentEventInfo()
    if sourceGUID~=IROVar.Rogue.playerGUID then return end
    local now=GetTime()

    if (subevent=="SPELL_CAST_SUCCESS") and (spellName=="Roll the Bones") then
        IROVar.Rogue.LastTimeUseRtB=now
        IROVar.Rogue.TimeCheckRtB=now+0.2

    end
    if subevent=="SPELL_AURA_APPLIED" then
        if IROVar.Rogue.RTBBuffName[spellName] then
            IROVar.Rogue.TimeCheckRtB=now+0.2
        end
    end
    if subevent=="SPELL_AURA_REMOVED" then
        if IROVar.Rogue.RTBBuffName[spellName] then
            IROVar.Rogue.TimeCheckRtB=now+0.2
        end
    end
end

IROVar.Rogue.cframe =CreateFrame("Frame")
IROVar.Rogue.cframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Rogue.cframe:SetScript("OnEvent",IROVar.Rogue.CombatEvent)

function IROVar.Rogue.NeedRTB()
    -- CD Roll the Bones > 0 --> false
    if TMW.CNDT.Env.CooldownDuration("Roll the Bones") > 0 then return false end

    IROVar.Rogue.UpdateRTBBuff()

    local now=GetTime()
    --if used RtB > 30 sec ago --> true
    if now-IROVar.Rogue.LastTimeUseRtB>30 then return true end
    --UpdateRTBBuff
    if now>IROVar.Rogue.TimeCheckRtB then
        IROVar.Rogue.TimeCheckRtB=IROVar.Rogue.UpdateRTBBuff()
        IROVar.Rogue.RTBBuff.OldCount = -1
    end
    local count=IROVar.Rogue.RTBBuff.count()
    if count==0 then return true end
    -- >3 buff --> false
    if (count>=3) then
        return false
    end
    -- 2 buff --> false
    -- 2 buff and buff is "Grand Melee+Buried Treasure" --> true
    if count==2 then
        return (IROVar.Rogue.RTBBuff["Grand Melee"]>now) and (IROVar.Rogue.RTBBuff["Buried Treasure"]>now)
    end
    -- SoHConduit + 1 buff --> true
    if IROVar.activeConduits["Sleight of Hand"] then return true end
    -- 1 buff + Broadside/True Bearing --> false
    return not((IROVar.Rogue.RTBBuff["Broadside"]>now) or (IROVar.Rogue.RTBBuff["True Bearing"]>now))
end

function IROVar.Rogue.IsEnOverFlowNextGCD(n)
    n=n or 1
    local en=UnitPower("player", 3)
    local enMax=UnitPowerMax("player",3)
    local enRe=GetPowerRegen()
    return ((enRe*n)+en)>enMax
end

function IROVar.Rogue.ComboSerratedBoneSpikeGen()
    local combo=1
    for i=1,30 do
        local n="nameplate"..i
        if UnitExists(n) and UnitCanAttack("player", n) then
            if TMW.CNDT.Env.AuraDur(n, "serrated bone spike", "PLAYER HARMFUL")>0 then
                combo=combo+1
            end
        end
    end
    if TMW.CNDT.Env.AuraDur("player", "Broadside", "PLAYER HELPFUL")>0.5 then combo=combo+combo end
    return combo
end

function IROVar.Rogue.NeedSerratedBoneSpike()
    local comboBlank=UnitPowerMax("player", 4)-UnitPower("player", 4)

    if comboBlank==0 then return false end
    local targetHasSBS=TMW.CNDT.Env.AuraDur("target", "serrated bone spike", "PLAYER HARMFUL")>0
    local comboGen=IROVar.Rogue.ComboSerratedBoneSpikeGen()
    local en=UnitPower("player", 3)
    --local enMax=UnitPowerMax("player",3)
    --local enRe=GetPowerRegen()

    local currentCharges, maxCharges, cooldownStart, cooldownDuration = GetSpellCharges("Serrated Bone Spike")
    local SBSChargeMax = (currentCharges==maxCharges) or ((currentCharges==(maxCharges-1)) and (GetTime()>(cooldownStart+cooldownDuration-5)))

    if targetHasSBS then
        --if low en --> true
        if (comboGen<=comboBlank) and (en<60) then
            return true
        end
        if SBSChargeMax then
            if comboGen<=comboBlank then
                return true
            end
            if (comboGen>=3) and (comboBlank>=3) then
                return true
            end
        end
    else
        --target not has SBS
        --can use SBS not over flow Combo --> true
        if comboGen<=comboBlank then
            return true
        end
        --if SBS max charge and over flow 1 combo and Gen 3 Combo-->true
        if SBSChargeMax and (comboGen>=3) and (comboBlank>=3) then
            return true
        end
    end
    return false

end