local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local CNDT = TMW.CNDT
local Env = CNDT.Env

print('lockpet')

local function printtable(a)
local k,v
    for k,v in pairs(a) do
        print(k,v)
    end

end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)

ConditionCategory:RegisterCondition(8.6,  "TMWMCWARLOCKPET", {
    text = "Warlock Pet Active",
    tooltip = "Warlock Pet Active",
    unit="Pet",
    bitFlagTitle = "select Pet",
    bitFlags={"Felguard", "Succubus", "Felhunter", "Voidwalker", "Imp"},
    icon = "Interface\\Icons\\ability_druid_bash",
    tcoords = CNDT.COMMON.standardtcoords,

    funcstr = function(c)
        --printtable(c)
        return [[true]]
    end
})

