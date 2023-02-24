-- Many Function Version Druid Balance Rotation 10.0.5/2
-- Set Priority to 20

--[[
    counter
    off GCD
    ["ff013001"]="Celestial Alignment",
    ["usecelali"]="Celestial Alignment",
    "usecelali"

    ["ff033203"]="Warrior of Elune",
    ["usewarofelu"]="Warrior of Elune",
    "usewarofelu" 

    ["ff013501"]="Moonfire",
    ["usemoonfir"]="Moonfire",
    "usemoonfir"

    ["ff013601"]="Sunfire",
    ["usesunfir"]="Sunfire",
    "usesunfir"

    ["ff023602"]="Starsurge",
    ["usestasur"]="Starsurge",
    "usestasur"

    ["ff003700"]="Wrath",
    ["usewra"]="Wrath",
    "usewra"

    ["ff033803"]="Astral Communion",
    ["useastcom"]="Astral Communion",
    "useastcom"

    ["ff003800"]="Starfall",
    ["usestafal"]="Starfall",
    "usestafal"

    ["ff033903"]="Starfire",
    ["usestafir"]="Starfire",
    "usestafir"

    ["ff003900"]="Stellar Flare",
    ["usestefla"]="Stellar Flare",
    "usestefla"

    ["ff013b01"]="Force of Nature",
    ["usefornat"]="Force of Nature",
    "usefornat"

    ["ff023b02"]="Convoke the Spirits",
    ["useconspi"]="Convoke the Spirits",
    "useconspi"

    ["ff003b00"]="Wild Mushroom",
    ["usewilmus"]="Wild Mushroom",
    "usewilmus"

    ["ff033c03"]="New Moon",
    ["usenewmoo"]="New Moon",
    "usenewmoo"

    ["ff013c01"]="Fury of Elune",
    ["usefurelu"]="Fury of Elune",
    "usefurelu"

    ["ff023c02"]="Warrior of Elune",
    ["usewarelu"]="Warrior of Elune",
    "usewarelu"

    ["ff003c00"]="Convoke the Spirits with Celestial",
    ["useconspicel"]="Convoke the Spirits with Celestial",
    "useconspicel"

]]

local PlayerMove=false
TMW_ST:AddEvent("PLAYER_STARTED_MOVING",function() PlayerMove=true end)
TMW_ST:AddEvent("PLAYER_STOPPED_MOVING",function() PlayerMove=false end)


local UpdateCounter=IROVar.UpdateCounter
local CooldownDuration=TMW.CNDT.Env.CooldownDuration
local SpellCDEnd={}
TMW_ST:AddEvent("SPELL_UPDATE_COOLDOWN",function() SpellCDEnd={} end)
local function CDReady(n)
    if not SpellCDEnd[n] then
        --local _,start, duration = CooldownDuration(n)
        local start, duration = GetSpellCooldown(n)
        if TMW.GCD~=0 then
            local GCDstart, GCDduration = GetSpellCooldown(TMW.GCDSpell)
            if ((start+duration)-(GCDstart+GCDduration))<=0.05 then
                SpellCDEnd[n]=0
            else
                SpellCDEnd[n]=start+duration
            end
        else
            SpellCDEnd[n]=start+duration
        end
    end
    return TMW.time>=SpellCDEnd[n]
end

local COUNTERS=TMW.COUNTERS
local StarfallAP=IROVar.DruidBalance.StarfallAP
local StarsurgeAP=IROVar.DruidBalance.StarsurgeAP
local GetTime=GetTime
local CounterToSpell={
    ["usecelali"]="Celestial Alignment",
    ["usewarofelu"]="Warrior of Elune",
    ["usemoonfir"]="Moonfire",
    ["usesunfir"]="Sunfire",
    ["usestasur"]="Starsurge",
    ["usewra"]="Wrath",
    ["useastcom"]="Astral Communion",
    ["usestafal"]="Starfall",
    ["usestafir"]="Starfire",
    ["usestefla"]="Stellar Flare",
    ["usefornat"]="Force of Nature",
    ["useconspi"]="Convoke the Spirits",
    ["usewilmus"]="Wild Mushroom",
    ["usenewmoo"]="New Moon",
    ["usefurelu"]="Fury of Elune",
    ["usewarelu"]="Warrior of Elune",
    ["stopcasting"]="Stop Casting",
}
local SpellToCounter={}
for k,v in pairs(CounterToSpell) do
    SpellToCounter[v]=k
end

local HasSpell={}

local function HardCheckHasSpell(n)
    return GetSpellInfo(n)~=nil
end

local function HardCheckHasSpell_afterChangeTalent()
    for k,_ in pairs(SpellToCounter) do
        HasSpell[k]=HardCheckHasSpell(k)
    end
end
HardCheckHasSpell_afterChangeTalent()
IROVar.Register_TALENT_CHANGE_scrip_CALLBACK("Balance Rotation Skill Check",HardCheckHasSpell_afterChangeTalent)

local function CheckHasSpell(n)
    return HasSpell[n]
end

local function ResetAllCounter()
    for k,_ in pairs(CounterToSpell) do
        UpdateCounter(k,0)
    end
end

local function Cast(n)
    if not SpellToCounter[n] then
        print("MF Druid Balance Rotation not found spell :",n)
        return
    end
    ResetAllCounter()
    UpdateCounter(SpellToCounter[n],1)
end

function IROVar.DruidBalance.CalDPS()

    local moonfireDot=COUNTERS["moonfire"]
    local sunfireDot=COUNTERS["sunfire"]
    local stellarflareDot=COUNTERS["stellarflare"]
    local fungalgrowthDot=COUNTERS["fungalgrowth"]
    local astralPower=COUNTERS["lunarpower"]
    local eclipselunarBuff=COUNTERS["eclipselunar"]
    local eclipsesoalrBuff=COUNTERS["eclipsesolar"]
    --print(eclipselunarBuff,eclipsesoalrBuff)
    local SpellCasting=UnitCastingInfo("player")
    local wrathCount=GetSpellCount("Wrath")
    local starfireCount=GetSpellCount("Starfire")
    local aoeCount=COUNTERS["spellhitaoetrunk"]
    local rawAoeCount=COUNTERS["spellhitaoe"]
    local wantWW=COUNTERS["wantww"]
    local aoeAction=(aoeCount>=3 and wantWW>=1) or wantWW>=2
    local wantStarFall=COUNTERS["wantstarfall"]==1
    local starFallAction=aoeAction or wantStarFall
    local playerNotMove=not(PlayerMove or IsFalling())
    local nextEclipseLunar=(wrathCount==1) and (SpellCasting=="Wrath")
    local nextEclipseSolar=(starfireCount==1) and (SpellCasting=="Starfire")
    local wantEclipseStage=COUNTERS["wanteclipse"]
    local needEnterEclipseSular=(wantEclipseStage==0) or (wantEclipseStage==1 and not aoeAction)
    --local needEnterEclipseLunar=(wantEclipseStage==2) or (wantEclipseStage==1 and aoeAction)
    local needEnterEclipseLunar=not needEnterEclipseSular
    local starFallAPUse=StarfallAP()
    local starSurgeAPUse=StarsurgeAP()
    local targetHpTimeRemain=COUNTERS["targethptimeremain"]
    local targetTime20=targetHpTimeRemain>=20
    local targetTime10=targetHpTimeRemain>=10
    local predictAstral=COUNTERS["lunarpoweradd"]
    local shootingStarsCount=COUNTERS["shootingstarscount"]
    --local predictShootingStarRemain=(30-shootingStarsCount)/(rawAoeCount*0.8)
    local rattledStars=COUNTERS["rattledstars"]
    local rattledStarsStack=IROVar.Aura1.GetAuraStack("Rattled Stars")
    local rattledStarsTime=IROVar.Aura1.GetAura("Rattled Stars")
    rattledStarsTime=rattledStarsTime and (rattledStarsTime-GetTime()-0.6)
    local resetRattledStarsIntime=rattledStarsTime and (rattledStarsTime>-0.3)
    local rattledStarLessThan1GCD=rattledStarsTime and (rattledStarsTime<IROVar.CastTime1_5sec)
    local starFireCastTime=2.25*IROVar.HasteFactor
    local wrathCastTime=IROVar.CastTime1_5sec
    local touchTheCosmos=COUNTERS["touchthecosmos"]
    local solstice=COUNTERS["solstice"] -- 200% more shootingStars
    local nSunfire=COUNTERS["nsunfire"]
    local furyofelune=COUNTERS["furyofelune"]

    local playerShouldStopCast=IROVar.CSC.PlayerShouldStopCasting()
    local interruptINC=IROVar.CSC.HasInterrupting(1.5)

    playerNotMove=playerNotMove and not interruptINC

    local wantToContinueRTS=not starFallAction
    --print(CheckHasSpell("Fury of Elune"),CDReady("Fury of Elune"),eclipselunarBuff,eclipsesoalrBuff,astralPower)

    local function CastSSorSF(AP)
        AP=AP or astralPower
        if starFallAction and (AP>=starFallAPUse or nextEclipseLunar or nextEclipseSolar) then
            Cast("Starfall")
            return true
        end
        if not starFallAction and (AP>=starSurgeAPUse or nextEclipseLunar or nextEclipseSolar) then
            Cast("Starsurge")
            return true
        end
        return false
    end
    local function IsHighAstralPower()

        if  targetTime20 and CheckHasSpell("Fury of Elune") and CDReady("Fury of Elune") then
            return true
        end
        local sSC=shootingStarsCount
        local pA=predictAstral
        if solstice>1 then
            sSC=sSC+nSunfire
            pA=pA+nSunfire
        end
        if nSunfire>=2 then
            sSC=sSC+1
            pA=pA+1
        end
        if nSunfire>=4 then
            sSC=sSC+1
            pA=pA+1
        end
        if furyofelune>=2 then
            pA=pA+8
        end

        if sSC>25 then
            return pA>=55
        else
            return pA>=75
        end
    end

    if playerShouldStopCast or ((SpellCasting=="Starfire") and needEnterEclipseSular and (eclipsesoalrBuff>=13)) then
        Cast("Stop Casting")
        return
    end

    if rattledStarsTime and rattledStarLessThan1GCD and resetRattledStarsIntime then --Extented Rattled Stars
        if wantToContinueRTS then
            if CastSSorSF(predictAstral) then return end
        end
    end

    if (eclipselunarBuff<=1) and (eclipsesoalrBuff<=1) and -- Enter Eclipse sun
    (not nextEclipseLunar) and (not nextEclipseSolar) and needEnterEclipseSular then
        if rattledStarsTime and rattledStarsTime<starFireCastTime and resetRattledStarsIntime then
            if wantToContinueRTS then
                if CastSSorSF(predictAstral) then return end
            end
        end
        if playerNotMove and IROVar.CSC.HasInterrupting(starFireCastTime+0.3) then
            Cast("Starfire")
            return
        end
    end

    if (eclipselunarBuff==0) and (eclipsesoalrBuff==0) and -- Enter Eclipse moon
    (not nextEclipseLunar) and (not nextEclipseSolar) and needEnterEclipseLunar and playerNotMove then
        Cast("Wrath")
        return
    end

    local HighAP=IsHighAstralPower()

    if COUNTERS["sunfire"]<=1 then
        Cast("Sunfire")
        return
    end
    if COUNTERS["moonfire"]<=1 then
        Cast("Moonfire")
        return
    end

    if HighAP and wantToContinueRTS then
        if CastSSorSF() then return end
    end

    if targetTime10 and (COUNTERS["stellarflare"]<=1) and (IROVar.DruidBalance.StellarFlareTarget~=UnitGUID("target"))
    and playerNotMove and IROVar.CSC.HasInterrupting(starFireCastTime+0.3) then
        Cast("Stellar Flare")
        return
    end

    if predictAstral>=50 and((touchTheCosmos>=1) or nextEclipseLunar or nextEclipseSolar)and wantToContinueRTS then-- Set 4 Moonkin
        if CastSSorSF() then return end
    end

    if rattledStars<=3 then
--[[       if (rattledStarsTime and rattledStarsTime>starFireCastTime) and (not HighAP) then
            -- cast Starfire or Wrath
        elseif rattledStarsTime and (not aoeAction) and (rattledStarsTime>wrathCastTime) and (not HighAP)then
            -- cast Wrath
        else
            if CastSSorSF() then return end
        end]]
        if rattledStarsTime and (rattledStarsTime>wrathCastTime)and (not HighAP) then
            --cast 1 GCD spell
        else
            if wantToContinueRTS then
                if CastSSorSF() then return end
            end
        end
    end

    if COUNTERS["sunfire"]<=5 then
        Cast("Sunfire")
        return
    end
    if COUNTERS["moonfire"]<=6 then
        Cast("Moonfire")
        return
    end
    if targetTime10 and (COUNTERS["stellarflare"]<=7) and (IROVar.DruidBalance.StellarFlareTarget~=UnitGUID("target"))and playerNotMove then
        Cast("Stellar Flare")
        return
    end

    if (CheckHasSpell("Fury of Elune") and CDReady("Fury of Elune")) and
    ((targetTime20 and (eclipselunarBuff>=6 or eclipsesoalrBuff>=6) and (astralPower<=50)) or (aoeCount>=4)) then
        Cast("Fury of Elune")
        return
    end

    if aoeAction and playerNotMove
    then
        Cast("Starfire")
        return
    else
        if targetTime10 and (eclipsesoalrBuff==0)  and (COUNTERS["stellarflare"]<=10) and (IROVar.DruidBalance.StellarFlareTarget~=UnitGUID("target"))and playerNotMove then
            Cast("Stellar Flare")
            return
        end
        if playerNotMove then
            Cast("Wrath")
            return
        end
    end

    if CastSSorSF() then return end

    if COUNTERS["sunfire"]<=14 then
        Cast("Sunfire")
        return
    end
    Cast("Moonfire")

end


C_Timer.NewTicker(0.07,IROVar.DruidBalance.CalDPS)

local function CalDPSByEvent(event,unit)
    if unit=="player" then
        IROVar.DruidBalance.CalDPS()
    end
end
TMW_ST:AddEvent("UNIT_SPELLCAST_STOP",CalDPSByEvent)
TMW_ST:AddEvent("UNIT_SPELLCAST_FAILED_QUIET",CalDPSByEvent)