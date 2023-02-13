-- Many Function Version Druid Balance Rotation 10.0.5/1
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

local function CDReady(n)
    return CooldownDuration(n)==0
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
    local SpellCasting=UnitCastingInfo("player")
    local wrathCount=GetSpellCount("Wrath")
    local starfireCount=GetSpellCount("Starfire")
    local aoeCount=COUNTERS["spellhitaoetrunk"]
    local rawAoeCount=COUNTERS["spellhitaoe"]
    local wantWW=COUNTERS["wantww"]
    local aoeAction=(aoeCount>=3 and wantWW>=1) or wantWW>=2
    local wantStarFall=COUNTERS["wantstarfall"]==1
    local starFallAction=aoeAction or wantStarFall
    local playerMove=PlayerMove or IsFalling()
    local nextEclipseLunar=(wrathCount==1) and (SpellCasting=="Wrath")
    local nextEclipseSolar=(starfireCount==1) and (SpellCasting=="Starfire")

    local wantEclipseStage=COUNTERS["wanteclipse"]
    local needEnterEclipseSular=(wantEclipseStage==0) or (wantEclipseStage==1 and not aoeAction)
    --local needEnterEclipseLunar=(wantEclipseStage==2) or (wantEclipseStage==1 and aoeAction)
    local needEnterEclipseLunar=not needEnterEclipseSular

    local starFallAPUse=StarfallAP()
    local starSurgeAPUse=StarsurgeAP()
    local targetHpTimeRemain=COUNTERS["targethptimeremain"]
    local predictAstral=COUNTERS["lunarpoweradd"]
    local shootingStarsCount=COUNTERS["shootingstarscount"]
    local predictShootingStarRemain=(30-shootingStarsCount)/(rawAoeCount*0.8)
    local rattledStars=COUNTERS["rattledstars"]
    local rattledStarsStack=IROVar.Aura1.GetAuraStack("Rattled Stars")

    local rattledStarsTime=IROVar.Aura1.GetAura("Rattled Stars")
    rattledStarsTime=rattledStarsTime and (rattledStarsTime-0.5-GetTime())
    local rattledStarLessThan1GCD=rattledStarsTime and (rattledStarsTime<IROVar.CastTime1_5sec)

    local starFireCastTime=2.25*IROVar.HasteFactor
    local wrathCastTime=IROVar.CastTime1_5sec

    local function CastSSorSFPredict()
        if starFallAction and predictAstral>=starFallAPUse then
            Cast("Starfall")
            return true
        end
        if not starFallAction and predictAstral>=starSurgeAPUse then
            Cast("Starsurge")
            return true
        end
        return false
    end

    if rattledStarsTime and rattledStarLessThan1GCD then
        if CastSSorSFPredict() then return end
    end
    if (eclipselunarBuff==0) and (eclipsesoalrBuff==0) and
    (not nextEclipseLunar) and (not nextEclipseSolar) and needEnterEclipseSular then
        if rattledStarsTime and rattledStarsTime<starFireCastTime then
            if CastSSorSFPredict() then return end
        end
        Cast("Starfire")
        return
    end
    if (eclipselunarBuff<=1) and (eclipsesoalrBuff<=1) and
    (not nextEclipseLunar) and (not nextEclipseSolar) and needEnterEclipseLunar then
        Cast("Wrath")
        return
    end
    if COUNTERS["sunfire"]<=5 then
        Cast("Sunfire")
        return
    end
    if COUNTERS["moonfire"]<=6 then
        Cast("Moonfire")
        return
    end
    if (COUNTERS["stellarflare"]<=7) and (IROVar.DruidBalance.StellarFlareTarget~=UnitGUID("target")) then
        Cast("Stellar Flare")
        return
    end

    if (rattledStars<=3) or (astralPower>=70) then
        if (rattledStarsTime and rattledStarsTime>starFireCastTime) and (astralPower<70) then
            -- cast Starfire or Wrath
        elseif rattledStarsTime and (not aoeAction) and (rattledStarsTime>wrathCastTime) and (astralPower<70)then
            -- cast Wrath
        else
            if starFallAction and astralPower>=starFallAPUse then
                Cast("Starfall")
                return
            end
            if not starFallAction and astralPower>=starSurgeAPUse then
                Cast("Starsurge")
                return
            end
        end
    end

    if CheckHasSpell("Fury of Elune") and CDReady("Fury of Elune")
    and (eclipselunarBuff>=7 or eclipsesoalrBuff>=7) and astralPower<=50 then
        Cast("Fury of Elune")
        return
    end
    if aoeAction then
        Cast("Starfire")
        return
    else
        Cast("Wrath")
        return
    end
end


C_Timer.NewTicker(0.1,IROVar.DruidBalance.CalDPS)