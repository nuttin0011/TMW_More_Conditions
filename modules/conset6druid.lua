local TMW = TMW
local TMW_MC = TMW_More_Conditions
local CNDT = TMW.CNDT
local Env = CNDT.Env

local ConditionCategory = CNDT:GetCategory("TMWMCSPELL", 14, "More Conditions Spell", false, false)
local IROSkillUseIn4SecFrame = CreateFrame("Frame")
Env.LastCastIn4Sec={}
local GetTime=GetTime
local IROplayerGUID

function IROSkillUseIn4SecFrame:COMBAT_LOG_EVENT_UNFILTERED(...)
    if not IROplayerGUID then IROplayerGUID=UnitGUID("player") end
    local _, subevent, _, sourceGUID, _, _, _, _, _, _, _,spellId, spellName = ...
    local currentTime
    if sourceGUID~=IROplayerGUID then return false end
    currentTime = GetTime()
    if subevent=="SPELL_CAST_SUCCESS" then
        if not Env.LastCastIn4Sec then
            Env.LastCastIn4Sec={}
        end
        Env.LastCastIn4Sec[strlower(spellName)] = currentTime
        Env.LastCastIn4Sec[spellId] = currentTime
    end
end

local IROSkillUseIn4SecFrameSetup=false

local function setupIROSkillUseIn4SecFrame()
    if IROSkillUseIn4SecFrameSetup then return end
    IROSkillUseIn4SecFrameSetup=true
    IROSkillUseIn4SecFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    IROSkillUseIn4SecFrame:SetScript("OnEvent", function(self, event)
        self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
        end)
end

function Env.GetTime()
    return GetTime()
end

ConditionCategory:RegisterCondition(1,  "IROSKILLUSED", {
    text = "Check player Skill used",
    unit = "used",
    step = 0.1,
    min = 0,
    range = 10,
    noslide = false,
    levelChecks = false,
    useSUG = true,
    allowMultipleSUGEntires = false,
	texttable = function(v) return v.." sec ago" end,
    name = function(editbox) 
        editbox:SetTexts("Skill Name","e.g. agony")
    end,
	specificOperators = {["<="] = true, [">="] = true, ["=="] = true, ["~="]=true},
    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = "<="
        end
    end,

    icon = "Interface\\Icons\\spell_druid_bloodythrash",
    tcoords = CNDT.COMMON.standardtcoords,
    funcstr = function(c)
        if not IROSkillUseIn4SecFrameSetup then setupIROSkillUseIn4SecFrame() end
        return [[GetTime() c.Operator ((LastCastIn4Sec[LOWER(c.NameFirst)]or 0)+c.Level)]]
    end,
})
