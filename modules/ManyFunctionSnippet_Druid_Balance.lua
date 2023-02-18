-- Many Function Version Druid Balance 9.2.5/12
-- Set Priority to 10

--var IROVar.DruidBalance.NewMoon ; name spell
--var IROVar.DruidBalance.NewMoonAstGen ; Ast Gen from this spell
--var IROVar.DruidBalance.NewMoonCast ; casting?
--function IROVar.DruidBalance.CountSunfireDotAtEnemy()
--function IROVar.DruidBalance.PredictAPadd() -- predict AP add after use this spell

--function IROVar.DruidBalance.StarfallAP() -- return starfall AP use
--function IROVar.DruidBalance.StarsurgeAP()

--var IROVar.DruidBalance.RSend ; "Rattled Stars" buff endTime

--var IROVar.DruidBalance.StellarFlareTarget : GUID StellarFlareTarget

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

--counter
--Shooting Stars count "shootingstarscount"
-- reset when Full Moon fall by passive skill

--"lunarpower" = astral power
--"lunarpoweradd" = astral power + predict AP
--[[
counter
player buff
"nothasrattledstars" no Buff "Rattled Stars"
    ["Rattled Stars"]="rattledstars",
    ["Eclipse (Solar)"]="eclipsesolar",
    ["Eclipse (Lunar)"]="eclipselunar",
    ["Touch the Cosmos"]="touchthecosmos",
    ["Solstice"]="solstice",
    ******
    "furyofelune"  = counter 8 to 0 every sec after cast Fury of Elune
enemy debuff
    ["Moonfire"]="moonfire",
    ["Sunfire"]="sunfire",
    ["Stellar Flare"]="stellarflare",
    ["Fungal Growth"]="fungalgrowth"

]]

if not IROVar then IROVar = {} end
if not IROVar.DruidBalance then IROVar.DruidBalance = {} end

local spellCheckAOE={
    "Starfire",
    "Sunfire",
    "Moonfire",
    "Wild Mushroom",
    "Fury of Elune",
    "Full Moon",
}
IROVar.SpellHitAOE.Register_Spell_Hit_AOE_Check(spellCheckAOE,8)
IROVar.SpellHitAOE.Register_Spell_Aura_AOE_Check("Sunfire",8)
--ENEMY DEBUFF
local aa="PLAYER HARMFUL"
local a={
    ["Moonfire"]="moonfire",
    ["Sunfire"]="sunfire",
    ["Stellar Flare"]="stellarflare",
    ["Fungal Growth"]="fungalgrowth"}
for k,v in pairs(a) do
    IROVar.CV.Register_Target_Aura_Duration(k,v,aa)
end
--PLAYER BUFF
local b={
    ["Rattled Stars"]="rattledstars",
    ["Eclipse (Solar)"]="eclipsesolar",
    ["Eclipse (Lunar)"]="eclipselunar",
    ["Touch the Cosmos"]="touchthecosmos",
    ["Solstice"]="solstice",
}
for k,v in pairs(b) do
    IROVar.CV.Register_Player_Aura_Duration(k,v)
end
IROVar.CV.Register_Player_Aura_Not_Has("Rattled Stars","nothasrattledstars")


local dud = IROVar.DruidBalance

function dud.StarfallAP()
    --[[
    local s=IROVar.Aura1.GetAuraStack("Rattled Stars") or 0
    local aUse=50-math.floor(s*2.5)
    local ap=TMW_ST:GetCounter("lunarpower")
    return ap>=aUse]]
    return 50-math.floor(2.5*(IROVar.Aura1.GetAuraStack("Rattled Stars") or 0))
end

function dud.StarsurgeAP()
    return 40-((IROVar.Aura1.GetAuraStack("Rattled Stars") or 0)*2)
    --[[local s=IROVar.Aura1.GetAuraStack("Rattled Stars") or 0
    local aUse=40-(s*2)
    local ap=TMW_ST:GetCounter("lunarpower")
    return ap>=aUse]]
end



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
dud.ShootingStarsCount=0

local PredictAPBySpell={
    ["Starfire"]=8,[194153]=8,
    ["Wrath"]=8,[190984]=8,
    ["Stellar Flare"]=8,[202347]=8,
    ["Full Moon"] = 40,[274283]=40,
    ["Half Moon"] = 20,[274282]=20,
    ["New Moon"] = 10,[274281]=10,
}

dud.predictAPadd=0
--IROVar.RegisterOutcombatCallBackRun("reset dud.predictAPadd",function() IROVar.DruidBalance.predictAPadd=0 end)
function dud.PredictAPadd() --after cast current spell
    return dud.predictAPadd or 0
end


local function checkAPAdd()
    local spell=UnitCastingInfo("player")
    if spell and PredictAPBySpell[spell] then
        if spell=="Wrath" and TMW.COUNTERS["eclipsesolar"]>0 then
            dud.predictAPadd=12
        else
            dud.predictAPadd=PredictAPBySpell[spell]
        end
    else
        dud.predictAPadd=0
    end
    IROVar.UpdateCounter("lunarpoweradd",TMW_ST:GetCounter("lunarpower")+IROVar.DruidBalance.PredictAPadd())
end

-- Create a second event frame and function to reset the current spell cast when the cast is finished or fails

local function ResetCurrentSpellCast(event,unit)
    if unit == "player" then
        checkAPAdd()
    end
end

-- Register the reset function to listen for the SPELL_CAST_SUCCESS and SPELL_CAST_FAILED events
--[[
local resetFrame = CreateFrame("FRAME")
resetFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
resetFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
resetFrame:SetScript("OnEvent", ResetCurrentSpellCast)]]
TMW_ST:AddEvent("UNIT_SPELLCAST_STOP",ResetCurrentSpellCast)
TMW_ST:AddEvent("UNIT_SPELLCAST_FAILED_QUIET",ResetCurrentSpellCast)

C_Timer.NewTicker(0.4,checkAPAdd)

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


local nextFullMoonFromSpell=false
local FullMoonTimeStamp=0
function dud.CombatEvent(...)

    local function isNewMoon(sID)
        return (sID>=274281) and (sID<=274283)
    end

    local timestamp,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = ...
    if sourceGUID~=IROVar.playerGUID then return end
    --274281 274282 274283 ; newMoon HalfMoon FullMoon
	if subevent=="SPELL_CAST_SUCCESS" then
        dud.StellarFlareTarget=nil
        if spellID==274283 then
            nextFullMoonFromSpell=true
        end
        if isNewMoon(spellID) then
            dud.UpdateNewMoon()
        end
        dud.NewMoonCast=false
        if spellName=="Fury of Elune" then
            IROVar.UpdateCounter("furyofelune",8)
            C_Timer.NewTicker(0.95,function()
                local c=TMW.COUNTERS["furyofelune"] or 0
                IROVar.UpdateCounter("furyofelune",c-1)
            end,8)
        end
    elseif subevent=="SPELL_CAST_START" then
        checkAPAdd()
        if isNewMoon(spellID) then
            dud.NewMoonCast=true
        end
    elseif subevent=="SPELL_CAST_FAILED" then
        dud.StellarFlareTarget=nil
        dud.NewMoonCast=false
    elseif subevent=="SPELL_DAMAGE" then
        if spellID==202497 then -- "Shooting Stars"
            dud.ShootingStarsCount=dud.ShootingStarsCount+1
            IROVar.UpdateCounter("shootingstarscount",dud.ShootingStarsCount)
        elseif spellID==274283 then -- "Full Moon" --SPELL_DAMAGE Full Moon 274283
            -- full moon from Shooting Stars --> reset Shooting Stars to 0
            if timestamp~=FullMoonTimeStamp then
                FullMoonTimeStamp=timestamp
                if nextFullMoonFromSpell then
                    nextFullMoonFromSpell=false
                else
                    dud.ShootingStarsCount=0
                    IROVar.UpdateCounter("shootingstarscount",dud.ShootingStarsCount)
                end
            end
        end
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

local function onUnitAura(event, unit)
    if unit ~= "player" then return end
    local Val=select(3,TMW.CNDT.Env.AuraDur("player","rattled stars","HELPFUL PLAYER"))
    if IROVar.DruidBalance.RSend~=Val then
        IROVar.DruidBalance.RSend=Val
        CalculateRSSpell()
    end
end
--[[local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", onUnitAura)]]
TMW_ST:AddEvent("UNIT_AURA",onUnitAura)

--PLAYER RESOURCE
IROVar.CV.Register_Player_Power(8,"lunarpower",function(AP)
    --need more counter place here
    IROVar.UpdateCounter("lunarpoweradd",AP+IROVar.DruidBalance.PredictAPadd())
end)


--[[
Full Moon = 3sec
Half Moon = 2sec
New Moon = 1sec
Wrath = 1.5sec
Starfire = 2.25sec
]]





