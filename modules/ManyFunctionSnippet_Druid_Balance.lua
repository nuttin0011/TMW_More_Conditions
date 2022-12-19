-- Many Function Version Druid Balance 9.2.5/4


--var IROVar.DruidBalance.NewMoon ; name spell
--var IROVar.DruidBalance.NewMoonAstGen ; Ast Gen from this spell
--var IROVar.DruidBalance.NewMoonCast ; casting?
--function IROVar.DruidBalance.CountSunfireDotAtEnemy()

--var IROVar.DruidBalance.RSend ; "Rattled Stars" buff endTime

--counter number of dot
--"nsunfire",
--"nmoonfire",
--"nstellarflare",
--

--counter spell use at rattledstars 0 mean can use , 1 mean cannot use
--"rsfullmoon" = Full Moon = 3sec
--"rshalfmoon" = Half Moon = 2sec
--"rsnewmoon" = New Moon = 1sec
--"rswrath" = Wrath = 1.5sec
--"rsstarfire" = Starfire = 2.25sec

--counter Predict Astral Power after this spell
--"predictastral"

--input Counter
-- "wantww" = want AOE; 2 = always AOE , 1 = AOE if possible , 0 = Only Single ; reset to 1 after out combat
-- "wantstarfall" = want Starfall ; 1 = use Starfal , just use onece and reset to 0 after use/outcombat
-- "keepap" = keep astral power ; 1 = keep AP as much as possible ; reset to 0 after outcombat
--[[
    use 3 counter condition for use "Starfall" or "Starsurge"
    dud.ManyMob = "nsunfire">=2

    use Starfall when
    must
        IsUsableSpell("Starfall")
            || Rattled Stars nearly end + predict astral power >= can use Starfall
                ** must wait for astral power update for use spell
        ("keepap" == 0) or ("keepap" == 1 and astral power >= 70)
    any
        "wantstarfall" == 1
        "wantww" == 2
        "wantww" == 1 and dud.ManyMob
    after use Starfall
        reset "wantstarfall" to 0

    use Starsurge when
    must
        IsUsableSpell("Starsurge")
            || Rattled Stars nearly end + predict astral power >= can use Starsurge
                ** must wait for astral power update for use spell
        ("keepap" == 0) or ("keepap" == 1 and astral power >= 70)
        condition use Starfall not met

    after out combat
        reset "wantww" to 1
        reset "wantstarfall" to 0
        reset "keepap" to 0

    **Rattled Stars nearly end mean after use current spell/GCD has Buff < 1 GCD
]]
--output counter
--"starsurgeorfall" ; 0 = use Starsurge , 1 = use Starfall




if not IROVar then IROVar = {} end
if not IROVar.DruidBalance then IROVar.DruidBalance = {} end

local dud = IROVar.DruidBalance

dud.NewMoon = "New Moon"
dud.NewMoonAstGen = 10
dud.NewMoonCast = false
    --164815 Sunfire
    --164812 Moonfire
    --202347 Stellar Flare
dud.dotCountList={
    [164815]="nsunfire",
    [164812]="nmoonfire",
    [202347]="nstellarflare",
}
dud.dotCount={
    [164815]=0,
    [164812]=0,
    [202347]=0,
}


function dud.UpdateNewMoon()
    dud.NewMoon = GetSpellInfo("new moon")
    if dud.NewMoon=="New Moon" then
        dud.NewMoonAstGen = 10
    elseif dud.NewMoon=="Half Moon" then
        dud.NewMoonAstGen = 20
    else
        dud.NewMoonAstGen = 40
    end
end
dud.UpdateNewMoon()
IROVar.Register_TALENT_CHANGE_scrip_CALLBACK("dud.UpdateNewMoon",dud.UpdateNewMoon)

function dud.CombatEvent(...)

    local function isNewMoon(sID)
        return (sID>=274281) and (sID<=274283)
    end

    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = ...
    if sourceGUID~=IROVar.playerGUID then return end
    --274281 274282 274283 ; newMoon HalfMoon FullMoon
	if subevent=="SPELL_CAST_SUCCESS" then
        if isNewMoon(spellID) then
            dud.UpdateNewMoon()
        end
        dud.NewMoonCast=false
    elseif subevent=="SPELL_CAST_START" then
        if isNewMoon(spellID) then
            dud.NewMoonCast=true
        end
    elseif subevent=="SPELL_CAST_FAILED" then
        dud.NewMoonCast=false
    end
end

IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("dudbalance",IROVar.DruidBalance.CombatEvent)
IROVar.RegisterIncombatCallBackRun("dudbalance",IROVar.DruidBalance.UpdateNewMoon())

function CanAttack(u)
    return UnitExists(u) and UnitCanAttack("player", u)
        --(UnitAffectingCombat(u) or  IsItemInRange(IROVar.ItemNameToCheck8, u))
end

function dud.CountDotAtEnemy()
    --164815 Sunfire
    for k in pairs(dud.dotCount) do
        dud.dotCount[k]=0
    end
    for i=1,20 do
        local n="nameplate"..i
        local spellId
        if CanAttack(n) then
            for index=1,40 do
                _,_,_,_,_,_,_,_,_,spellId=UnitDebuff(n,index,"PLAYER")
                if spellId then
                    if dud.dotCountList[spellId] then
                        dud.dotCount[spellId]=dud.dotCount[spellId]+1
                    end else break
end end end end end

C_Timer.NewTicker(0.4,function()
    dud.CountDotAtEnemy()
    for k,v in pairs(dud.dotCount) do
        IROVar.UpdateCounter(dud.dotCountList[k],v)
    end
end)

--["Rattled Stars"]="rattledstars"
IROVar.DruidBalance.RSend=select(3,TMW.CNDT.Env.AuraDur("player","rattled stars","HELPFUL PLAYER"))

local RSHandle={
    ["rsfullmoon"] = C_Timer.NewTimer(0.1,function() end),
    ["rshalfmoon"] = C_Timer.NewTimer(0.1,function() end),
    ["rsnewmoon"] = C_Timer.NewTimer(0.1,function() end),
    ["rswrath"] = C_Timer.NewTimer(0.1,function() end),
    ["rsstarfire"] = C_Timer.NewTimer(0.1,function() end),
}
local RSResetHaldle= C_Timer.NewTimer(0.1,function() end)
local SpellCastTime={
    ["rsfullmoon"] = 3,
    ["rshalfmoon"] = 2,
    ["rsnewmoon"] = 1,
    ["rswrath"] = 1.5,
    ["rsstarfire"] = 2.25,
}
local function GetSpellCastTime(s) --use SpellCastTime
    return SpellCastTime[s]*IROVar.HasteFactor
end


--counter Num
--0 == can DPS
--1 == stop if spell end > RS end
--2 == 

local function ResetAllRSCounter() -- set all to 0 and can DPS all skill
    for k,v in pairs(RSHandle) do
        v:Cancel()
        IROVar.UpdateCounter(k,0)
    end
end

IROVar.RegisterOutcombatCallBackRun("dud.ResetAllRSCounter",ResetAllRSCounter)

local function CalculateRSSpell()
    RSResetHaldle:Cancel()
    local cT=GetTime()
    if cT<IROVar.DruidBalance.RSend then -- if Current Time < RSend;
        for k,v in pairs(RSHandle) do
            local counter_val=0
            local spellCastTime=GetSpellCastTime(k)+0.3 --adjust ping
            local LimitStartCast=IROVar.DruidBalance.RSend-spellCastTime
            v:Cancel()
            if cT>LimitStartCast then
                --Spell Cast End > Rattled stars end ; cannot DPS
                IROVar.UpdateCounter(k,1)
            else
                local NextCannotCastTimer=LimitStartCast-cT
                local kk=k
                if NextCannotCastTimer<0.3 then
                    IROVar.UpdateCounter(k,1)
                else
                    IROVar.UpdateCounter(k,0)
                    RSHandle[k]=C_Timer.NewTimer(NextCannotCastTimer,function()
                        IROVar.UpdateCounter(kk,1)
                    end)
                end
            end
        end
        do
            local RSendTimer=IROVar.DruidBalance.RSend-cT-0.3
            if RSendTimer<0.3 then
                ResetAllRSCounter()
            else
                RSResetHaldle:Cancel()
                RSResetHaldle=C_Timer.NewTimer(RSendTimer,ResetAllRSCounter)
            end
        end
    else
        ResetAllRSCounter()
    end
end

local function onUnitAura(self, event, unit)
    if unit ~= "player" then return end
    local Val=select(3,TMW.CNDT.Env.AuraDur("player","rattled stars","HELPFUL PLAYER"))
    if IROVar.DruidBalance.RSend~=Val then
        IROVar.DruidBalance.RSend=Val
        CalculateRSSpell()
    end
end
local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", onUnitAura)

--[[
Full Moon = 3sec
Half Moon = 2sec
New Moon = 1sec
Wrath = 1.5sec
Starfire = 2.25sec
]]





