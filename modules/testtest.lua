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

Env.printc = function(c)
	--print(c)
	return true
end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC_Test", 14, "Test Condition", true, false)

ConditionCategory:RegisterCondition(6,  "TMWMCTEST1111", {
    text = "Nearest / Furthest Enemy",
	tooltip = "Nearest / Furthest Enemy\nNote. Only ENEMY.",
	unit=nil,
	min =0,
	max =1,
	levelChecks = true,
	step =1,
	nooperator = true,
	name=function(editbox) 
		editbox:SetTexts("EnemyUnit Check",'e.g. "target; party1target; party2target"\ncannot use like "party 1-4"')
	end,
	texttable = {
		[0] = "is Nearest",
		[1] = "is Furthest",
	},
    icon = "interface\\icons\\achievement_raid_revendrethraid_siredenathrius",
    tcoords = CNDT.COMMON.standardtcoords,
	funcstr = function(c, parent)
		return [[printc(c.Name)]]
    end,	

})

