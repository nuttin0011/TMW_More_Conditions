local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching
local _UnitExists = UnitExists
local _CheckInteractDistance = CheckInteractDistance
local _UnitReaction = UnitReaction

local CNDT = TMW.CNDT
local Env = CNDT.Env
local playerGUID = UnitGUID("player")
local extended_check_timer = GetTime()
local old_spell_cast = nil
local old_timer_check = 0
local old_val = 0

Env.PredictLockSS = function()
    return TMW_MC:PredictSS()
end

local LockSpellModSS = {
["Hand of Gul'dan"]=-3,
["Shadow Bolt"]=1,
["Call Dreadstalkers"]=-1,
["Summon Vilefiend"]=-1,
["Nether Portal"]=-1,
["Summon Demonic Tyrant"]=5,
["Demonbolt"]=2,
}

local function PredictSSFrameEvent(self, event, ...)
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,SpellName = CombatLogGetCurrentEventInfo()
        if (sourceGUID==playerGUID) and (subevent=="SPELL_CAST_SUCCESS")  then
	extended_check_timer = GetTime()+0.3
	old_spell_cast=SpellName
       end
end

function TMW_MC:PredictSS()
	local currentTime = GetTime()
	if old_timer_check == currentTime then
		return old_val
	end

	local currentSS = UnitPower("player",7)
	local spellName
	if currentTime<extended_check_timer then
		spellName=old_spell_cast
	else
	    spellName = UnitCastingInfo("player")
	end

	if spellName then
		currentSS = currentSS+(LockSpellModSS[spellName] or 0)
		currentSS = (currentSS<=5)and currentSS or 5
		currentSS = (currentSS>=0)and currentSS or 0		
	end

	old_timer_check = currentTime
	old_val = currentSS

	print(currentSS)
	return currentSS
end

PredictSSFrame = CreateFrame("Frame")
PredictSSFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PredictSSFrame:SetScript("OnEvent", PredictSSFrameEvent)



local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 11, "More Conditions", false, false)

ConditionCategory:RegisterCondition(8.3,  "TMWMCPREDICTSS", {
    text = "Predict Warlock Soul Stone",
    tooltip = "Predict Warlock SS after casting spell.",
    step = 1,
    min = 0,
    max = 5,
    unit="player",

    icon = "Interface\\Icons\\ability_hunter_snipershot",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    "<=",

    funcstr = function(c, parent)
        return [[PredictLockSS() == 5]]
    end
})
