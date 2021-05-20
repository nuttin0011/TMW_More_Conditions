-- Many Function Monk 9.0.5/1

--function IROVar.Monk.CanUseCombo(skillName) ; check for ComboStrinkeSkill skillName Case Sensitive
if not IROVar then IROVar={} end
if not IROVar.Monk then IROVar.Monk={} end
IROVar.Monk.playerGUID=UnitGUID("player")
IROVar.Monk.ComboStrikesSkill ={
    ["Tiger Palm"]=true,
    ["Blackout Kick"]=true,
    ["Fist of the White Tiger"]=true,
    ["Fists of Fury"]=true,
    ["Rising Sun Kick"]=true,
    ["Whirling Dragon Punch"]=true,
    ["Weapons of Order"]=true,
    ["Spinning Crane Kick"]=true,
    ["Crackling Jade Lightning"]=true,
    ["Expel Harm"]=true,
    ["Flying Serpent Kick"]=true,
}
IROVar.Monk.OldComboStrikesSkill=""

function IROVar.Monk.CombatEvent()
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,spellName=CombatLogGetCurrentEventInfo()
    if (sourceGUID==IROVar.Monk.playerGUID) and
    (subevent=="SPELL_CAST_SUCCESS") and
    (IROVar.Monk.ComboStrikesSkill[spellName])
    then
        IROVar.Monk.OldComboStrikesSkill=spellName
    end
end

IROVar.Monk.frame =CreateFrame("Frame")
IROVar.Monk.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Monk.frame:SetScript("OnEvent",IROVar.Monk.CombatEvent)

function IROVar.Monk.CanUseCombo(skillName)
    return skillName~=IROVar.Monk.OldComboStrikesSkill
end