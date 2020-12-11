local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local _UnitAura = UnitAura
local _UnitExists = UnitExists

local CNDT = TMW.CNDT
local Env = CNDT.Env

local function printtable(a)
	local k,v
		for k,v in pairs(a) do
			print(k,v)
		end
	
	end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)

--**************************Lowest Duration Debuff*********************

function TMW_MC:LowestDurationDebuff(nDebuff,nSetDebuff)
	-- nDebuff is Debuff to check e.g. "Agony"
	-- nSetDebuff is Set of Defuff to check e.g. "Agony; Corruption; Unstable Affliction"
	-- return true if nDebuff has lowest duration
	
	if not nDebuff then return false end
	nSetDebuff = nSetDebuff or ""
	if nSetDebuff == ";" then nSetDebuff="" end

	return false
end


