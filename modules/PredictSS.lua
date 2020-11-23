local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching
local _UnitExists = UnitExists
local _CheckInteractDistance = CheckInteractDistance
local _UnitReaction = UnitReaction

local CNDT = TMW.CNDT
local Env = CNDT.Env

local PredictSSFrame = CreateFrame("Frame")
PredictSSFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
PredictSSFrame:SetScript("OnEvent", PredictSSFrameEvent)

function PredictSSFrameEvent(self, event, ...)
    if event=="UNIT_SPELLCAST_FAILED" then
    end
    
    local m1,m2 = ...
    
    print(m1..'  '..m2)

end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 11, "More Conditions", false, false)

ConditionCategory:RegisterCondition(8.3,  "TMWMCPREDICTSS", {
    text = "Predict Warlock Soul Stone",
    tooltip = "Predict Warlock SS after casting spell.\n1.0 mean 1 SS\n1.1 mean 1 SS and 1 SS Fragment(in destruction)",
    step = 0.1,
    min = 0,
    max = 5,
    unit="player",

    icon = "Interface\\Icons\\ability_hunter_snipershot",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    "<=",

    funcstr = function(c, parent)
        return [[true]]
    end
})
