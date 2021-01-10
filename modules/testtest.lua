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
    text = "Enemy Count In Range Max 8",
	tooltip = "Enemy Count In Range Max 8",
	unit="EnemyCount",
	min =1,
	max =8,
	step =1,
	name=function(editbox) 
		editbox:SetTexts("no Check = 8 yard, Check 1 = 15 yard")
	end,
	name2=function(editbox) 
		editbox:SetTexts("Check 2 = 20 yard, Check 1+2 = 30 yard")
	end,
	texttable = function(v) return v end,
	check = function(check)
		check:SetTexts("Check 1")
	end,
	check2= function(check)
		check:SetTexts("Check 2")
	end,
    icon = "interface\\icons\\spell_arcane_mindmastery",
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

