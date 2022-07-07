-- Auto Target Hunter Version 1.3
-- Set Priority to 20
local AT=IROVar.AutoTarget
------------------ INTERRUPT SECTION -----------------------------------------
--[[AT.RegisterMacro["interrupt"] =
{
    MacroName = "~!Num12",
    Max = 6,
    IROCode = {
        [1] = {"ff033d03","[mod:ctrlalt]"},
        [2] = {"ff053d05","[mod:ctrlshift]"},
        [3] = {"ff013d01","[mod:ctrl]"},
        [4] = {"ff023d02","[mod:alt]"},
        [5] = {"ff043d04","[mod:shift]"},
        [6] = {"ff003d00","[nomod]"},
    },
    Command = "/cast Counter Shot",
    Suffix = "/run IUSC.SO('3d')",
    MobName ={},
}

function AT.SetInterrupt(UnitToken,TimeExpire)--; return true if set success
    --if TimeExpire then (endTimeMS/1000) muse be bigger than TimeExpire
    if IsMyInterruptSpellReady()
    and AT.CanSelect("interrupt",UnitToken)
    and UnitCanAttack("player",UnitToken)
    and (IsSpellInRange(IROVar.InterruptSpell,UnitToken)==1)
    and IROVar.CareInterrupt(UnitToken)
    --and IROVar.VVCareInterrupt(UnitToken)
    --and UnitIsPlayer(UnitToken.."target") 
    then
        local name, text, texture, startTimeMS, endTimeMS, isTradeSkill,
        castID, notInterruptible, spellId = UnitCastingInfo(UnitToken)
        if name and (not notInterruptible)
        and ((not TimeExpire)or(endTimeMS/1000>TimeExpire)) then
            --print("Unit : ",UnitToken,UnitName(UnitToken),name)
            AT.CastDetectEnable=false
            AT.CastUnit=UnitToken
            AT.CastDetectSetup=true
            NextInterrupter.ChangeWatch(AT.CastUnit)
            C_Timer.After(0.2,function()
                IROVar.AutoTarget.CastDetect=true
            end)
            C_Timer.After(1,function()
                IROVar.AutoTarget.CastDetectEnable=true
                IROVar.AutoTarget.CastDetect=false
                IROVar.AutoTarget.CastUnit=nil
                IROVar.AutoTarget.CastDetectSetup=false
            end)
        end
        return true
    else
        return false
    end
end

AT.CastDetect=false
AT.CastDetectSetup=false
AT.CastUnit=nil
AT.CastDetectEnable=true
AT.CastDetectFrame=CreateFrame("Frame")
AT.CastDetectFrame:RegisterEvent("UNIT_SPELLCAST_START")
AT.CastDetectFrame:SetScript("OnEvent",function(self,event,UnitToken)
    if not IROVar.AutoTarget.CastDetectEnable then return end
    IROVar.AutoTarget.SetInterrupt(UnitToken)
end)

AT.OldInterruptStatus=GetSpellCooldown(IROVar.InterruptSpell)==0
IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("InterruptSpellCheck",function()
    local s=IsMyInterruptSpellReady()
    if (not IROVar.AutoTarget.OldInterruptStatus) and s then
        --Check all Name plate for interrupt
        local TimeExpire=GetTime()+0.8
        for i=1,40 do
            local UnitToken="nameplate"..i
            if UnitExists(UnitToken) and IROVar.AutoTarget.SetInterrupt(UnitToken,TimeExpire) then
                break
            end
        end
    end
    IROVar.AutoTarget.OldInterruptStatus=s
end)
]]
------------------------------------------------------------------------------------
-------------------Barbed AOE-------------Auto Target

AT.RegisterMacro["Barbed"]={
    MacroName = "~!Num11",
    Max = 6,
    IROCode = {
        [1] = {"ff033c03","[mod:ctrlalt]"},
        [2] = {"ff053c05","[mod:ctrlshift]"},
        [3] = {"ff013c01","[mod:ctrl]"},
        [4] = {"ff023c02","[mod:alt]"},
        [5] = {"ff043c04","[mod:shift]"},
        [6] = {"ff003c00","[nomod]"},
    },
    Command = "/cast Barbed Shot",
    Suffix = "/run IUSC.SU('3c')",
    MobName ={},
}


AT.BarbedUnit ={
    --[UnitGUID1]=ExpTime,
    --[UnitGUID2]=ExpTime,
    -- reset when Out Combat
}

IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("BarbedUnit",function(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags,
    sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName
    =...
    if subevent=="SPELL_CAST_SUCCESS" and spellName=="Barbed Shot" then
        IROVar.AutoTarget.BarbedUnit[destGUID]=GetTime()+10

        --[[local name, icon, count, dispelType, duration, expirationTime, source, isStealable,
nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer,
nameplateShowAll, timeMod =AuraUtil.FindAuraByName("Barbed Shot", unit, filter)]]
    end
end)
IROVar.RegisterOutcombatCallBackRun("BarbedUnit",function()
    IROVar.AutoTarget.BarbedUnit={}
    IROVar.AutoTarget.TargetBarbed=nil
end)

function AT.BarbDebuff(UnitToken)
    local DebuffTime=(IROVar.AutoTarget.BarbedUnit[UnitGUID(UnitToken)] or 0)-GetTime()
    return DebuffTime<0 and 0 or DebuffTime
end

AT.TargetBarbed=nil
--IROVar.AutoTarget.TargetBarbed=nil
--IROVar.AutoTarget.BarbDebuff("target")
function AT.SelectTargetForBarbed()
    local function Selected(n)
        local function subSe(nn)
            return UnitCanAttack("player", nn)
            and (AT.BarbDebuff(nn)<=AT.BarbDebuff("target")) and AT.CanSelect("Barbed",nn)
            and (not IROVar.IsUnitCCed(n))
        end
        if not UnitExists(n) or UnitIsUnit("target",n) then return false end
        if IsItemInRange("item:34368",n) then --("n 8 yard")
            return subSe(n)
        end
        return UnitAffectingCombat(n) and UnitIsFriend("player",n.."target")
        and IsSpellInRange("Barbed Shot",n) and subSe(n)
    end

    local SelectToken=nil
    local SelectHP=0
    for k,v in pairs(AT.Unit) do
        if Selected(k) then
            local hp=UnitHealth(k)
            if hp>SelectHP then
                SelectToken=k
                SelectHP=hp
            end
        end
    end
    AT.TargetBarbed=SelectToken
end

IUSC.RegCallBackAfterSU["ATBarbed"]=function()
    C_Timer.After(0.1,function()
        if IROVar.Hun.GetBarbedCDRemain()==0 then
            IROVar.AutoTarget.SelectTargetForBarbed()
        end
    end)
end

--[[C_Timer.NewTicker(0.4,function()
    if IROVar.Hun.GetBarbedCDRemain()==0 then
        IROVar.AutoTarget.SelectTargetForBarbed()
    end
end)]]

--------------------------------------------------------------------------------------

--------------------------------------Tranquilizing Shot Section----------------------

