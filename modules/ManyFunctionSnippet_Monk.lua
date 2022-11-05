-- Many Function Monk 10.0.0/1
-- Set Priority to 5

--function IROVar.Monk.CanUseCombo(skillName) ; check for ComboStrinkeSkill skillName Case Sensitive
--counter "usedskill" ; check old skill use see in variables IROVar.Monk.ComboStrikesSkill
--"enemycountviii" = IROEnemyCountInRange(8)

if not IROVar then IROVar={} end
if not IROVar.Monk then IROVar.Monk={} end

IROVar.Monk.CounterName="usedskill"
IROVar.Monk.ComboStrikesSkill={
    ["Tiger Palm"]=1,
    ["Blackout Kick"]=2,
    ["Fist of the White Tiger"]=3,
    ["Fists of Fury"]=4,
    ["Rising Sun Kick"]=5,
    ["Whirling Dragon Punch"]=6,
    ["Weapons of Order"]=7,
    ["Spinning Crane Kick"]=8,
    ["Crackling Jade Lightning"]=9,
    ["Expel Harm"]=10,
    ["Flying Serpent Kick"]=11,
}
IROVar.Monk.playerGUID=UnitGUID("player")

IROVar.Monk.OldComboStrikesSkill=""

function IROVar.Monk.CombatEvent(...)
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,spellName=...
    if (sourceGUID==IROVar.Monk.playerGUID) and
    (subevent=="SPELL_CAST_SUCCESS") and
    (IROVar.Monk.ComboStrikesSkill[spellName])
    then
        IROVar.Monk.OldComboStrikesSkill=spellName
        IROVar.UpdateCounter("usedskill",IROVar.Monk.ComboStrikesSkill[spellName])
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Monk DPS",IROVar.Monk.CombatEvent)
IROVar.RegisterOutcombatCallBackRun("Monk DPS",function()
    IROVar.UpdateCounter("usedskill",0)
end)

function IROVar.Monk.CanUseCombo(skillName)
    return skillName~=IROVar.Monk.OldComboStrikesSkill
end

--"enemycountviii" = IROEnemyCountInRange(8)
--Enemy Count 8yard
--"item:34368" 8 yard
--"item:28767" 40 yard
IROVar.CV.EC8Tick=0.8
local function EC8()
    local nn
    local c=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player",nn) then
            c=c+(IsItemInRange("item:34368",nn) and 1 or 0)
        end
        if c>=6 then break end
    end
    IROVar.UpdateCounter("enemycountviii",c)
end
IROVar.CV.EC8H=C_Timer.NewTicker(IROVar.CV.EC8Tick,function()
    if TMW.time-IUSC.SkillPressStampTime>=IROVar.CV.EC8Tick then
        EC8()
    end
end)
IUSC.RegCallBackAfterSU["EC8"]=EC8