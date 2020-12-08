local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local _GetSpellInfo = GetSpellInfo

local CNDT = TMW.CNDT
local Env = CNDT.Env

local function printtable(a)
local k,v
    for k,v in pairs(a) do
        print(k,v)
    end

end



Env.WarlockPet = function(PetBitCode,reverse)

        return TMW_MC:WarlockPet(PetBitCode,reverse)

end

function TMW_MC:WarlockPet(PetBitCode,reverse)
    -- "Felguard", "Succubus", "Felhunter", "Voidwalker", "Imp"
    -- 1 , 10, 100,1000,10000
    local spellName = _GetSpellInfo("Command Demon")
    --print(spellName)
    local bitCheck = 0
    if spellName == "Axe Toss" then bitCheck=1 
    elseif spellName == "Seduction" then bitCheck=2 
    elseif spellName == "Spell Lock" then bitCheck=4 
    elseif spellName == "Shadow Bulwark" then bitCheck=8 
    elseif spellName == "Singe Magic" then bitCheck=16 
    end
    --print(bitCheck)
   if reverse then
        return not (bit.band(PetBitCode,bitCheck)>0)
    else
        return (bit.band(PetBitCode,bitCheck)>0)
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
	events = function(ConditionObject, c)
			return
				ConditionObject:GenerateNormalEventString("PET_BAR_UPDATE")
		end,
    funcstr = function(c)
        --printtable(c)
        --print(c.BitFlags)
        --print(c.Checked)
        return [[(WarlockPet(c.BitFlags,c.Checked))]]
    end,

})

