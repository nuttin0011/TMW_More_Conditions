-- testes is 2 testis
local TMW = TMW
local TMW_MC = TMW_More_Conditions
local CNDT = TMW.CNDT
local Env = CNDT.Env


function Env.TMWMCTest(a,b,c,d)
	print('====')
	print(a)
	print(b)
	print(c)
	print(d)	
	return true
end


local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC_Test", 14, "Test Condition", true, false)

ConditionCategory:RegisterCondition(6,  "TMWMCTEST1111", {
    text = "T111",
	tooltip = "T222",
	unit=nil,
	min =1,
	max =10,
	name="aa",
	name2="bb",
	texttable = function(v) return v.."Times" end,
	check = function(check)
		check:SetTexts("11", "22")
	end,
	check2= function(check)
		check:SetTexts("33", "44")
	end,
    icon = "Interface\\Icons\\spell_nature_rejuvenation",
    tcoords = CNDT.COMMON.standardtcoords,
	specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,
	funcstr = function(c, parent)
		

		return [[UnitHealth("target") > 0]]
    end,	

})

