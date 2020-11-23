local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local CNDT = TMW.CNDT
local Env = CNDT.Env

local playerGUID = UnitGUID("player")
local extended_check_timer = _GetTime()
local old_timer_check = 0
local old_spell_finish_cast_check = 0
local old_val = 0
local trust_segment_cast = true

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
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,SpellName = _CombatLogGetCurrentEventInfo()

        if (sourceGUID==playerGUID)  and (subevent=="SPELL_CAST_FAILED") then
	trust_segment_cast = true
       end
end

function TMW_MC:PredictSS()
	-- if (trust_segment_cast == Ture) Must Recalculate
	-- if (trust_segment_cast == False) Must Use old_val
	
	local currentTime = _GetTime()

	if old_timer_check == currentTime then
		return old_val
	end

	if (not trust_segment_cast) then
		if (currentTime>old_spell_finish_cast_check) then
			trust_segment_cast = true
		else
			return old_val
		end
	end

	local currentSS = _UnitPower("player",7)

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo("player")

	if spellName then
		-- if in 6/10 of spell bar ?
		trust_segment_cast = 0.6>((currentTime*1000)-startTimeMS)/(endTimeMS-startTimeMS)
		if trust_segment_cast then
			currentSS = currentSS+(LockSpellModSS[spellName] or 0)
			currentSS = (currentSS<=5)and currentSS or 5
			currentSS = (currentSS>=0)and currentSS or 0
			old_spell_finish_cast_check = (endTimeMS/1000)+0.2
		else
			return old_val
		end
	end

	old_timer_check = currentTime
	old_val = currentSS

	return currentSS
end

PredictSSFrame = CreateFrame("Frame")
PredictSSFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PredictSSFrame:SetScript("OnEvent", PredictSSFrameEvent)

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", false, false)

ConditionCategory:RegisterCondition(8.5,  "TMWMCPREDICTSS", {
    text = "Predict Warlock Soul Shard",
    tooltip = "Predict Warlock SS after casting spell.",
    step = 1,
    min = 0,
    max = 5,
    unit="player",

    icon = "Interface\\Icons\\ability_druid_bash",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

    funcstr = function(c, parent)
        return [[(PredictLockSS() c.Operator c.Level)]]
    end
})
