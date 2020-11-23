local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching
local _UnitExists = UnitExists
local _CheckInteractDistance = CheckInteractDistance
local _UnitReaction = UnitReaction

local CNDT = TMW.CNDT
local Env = CNDT.Env

--expose CountInRange to condition functions
Env.CountInRange = function()
    return TMW_ST:CountInRange()
end

local BB = 5

local CC = 7


local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 11, "More Conditions", false, false)

ConditionCategory:RegisterCondition(8.3,  "TMWMCPREDICTSS", {
    text = "Predict Warlock Soul Stone",
    tooltip = "Predict Warlock SS after casting spell.",
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
