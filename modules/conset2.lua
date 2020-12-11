local TMW = TMW
local TMW_MC = TMW_More_Conditions

local GetTime = GetTime
local UnitExists = UnitExists
local GetSpellInfo=GetSpellInfo
local CNDT = TMW.CNDT
local Env = CNDT.Env

local strsplit=strsplit

local function printtable(a)
	local k,v
		for k,v in pairs(a) do
			print(k,v)
		end
	
	end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)

--**************************Lowest Duration Debuff*********************

function TMW_MC:LowestDebuffDuration(nDebuff,nSetDebuff,nUnit)
	-- nDebuff is Debuff to check e.g. "Agony"
	-- nSetDebuff is Set of Defuff to check e.g. "Agony; Corruption; Unstable Affliction"
	-- return true if nDebuff has lowest duration
	local OldVal = Env.Old_Val_Check("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit)
	if OldVal then return OldVal end
	
	if not UnitExists(nUnit) then
		Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,false)
		return false 
	end
	
	if not nDebuff then
		Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,false)
		return false 
	end
	
	nDebuffName=GetSpellInfo(nDebuff)
	if not nDebuffName then
		Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,false)
		return false 
	end
	
	nSetDebuff = nSetDebuff or ""
	if nSetDebuff == ";" then nSetDebuff="" end
	
	nDebuff = string.lower(nDebuffName)
	nSetDebuff = string.lower(nSetDebuff)
	nUnit = nUnit or "target"
	
	local deBuff=Env.allDeBuffByMe(nUnit)
	
	local function IsSpellInSpellSet(nspell)
		if nSetDebuff=="" then return true end
		if string.find(nSetDebuff,nspell) then return true end
		return false
	end
	
	local function IsSomeSpellHasZeroDuration()
		local _nSetDebuff = nSetDebuff
		local _nDebuffName
		while(_nSetDebuff)
		do
			_nDebuffName,_nSetDebuff = strsplit(";",_nSetDebuff,2)
			_nDebuffName=GetSpellInfo(_nDebuffName)
			if _nSetDebuff then _nSetDebuff = string.sub(_nSetDebuff,2,string.len(_nSetDebuff)) end
			
			if _nDebuffName and ((not deBuff[_nDebuffName])or(deBuff[_nDebuffName]==0)) then return true end
		end
		return false
	end
	
	if IsSpellInSpellSet(nDebuff)and((not deBuff[nDebuffName])or(deBuff[nDebuffName]==0)) then
		Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,true)
		return true
	end
	if IsSomeSpellHasZeroDuration() then
		Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,false)
		return false
	end

	local DebuffTime = deBuff[nDebuffName]
	
	local k,v
    for k,v in pairs(deBuff) do
		if IsSpellInSpellSet(string.lower(k)) and v<DebuffTime then
			Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,false)
			return false
		end
    end
	
	Env.Old_Val_Update("LowestDebuffDuration",nDebuff..nSetDebuff..nUnit,true)
	return true
end

function Env.LowestDebuffDuration(nDebuff,nSetDebuff,nUnit)
	return TMW_MC:LowestDebuffDuration(nDebuff,nSetDebuff,nUnit)
end

ConditionCategory:RegisterCondition(9.1,  "TMWMCLOWESTDEBUFFDURATION", {
    text = "check Lowest Debuff in this unit",
	unit=nil,
	noslide = true,
	nooperator = true,
	name = function(editbox) 
		editbox:SetTexts("Debuff Name To Check","e.g. agony")
	end,
	name2 = function(editbox) 
		editbox:SetTexts("Set of Debuff to Check","e.g. agony; corruption; siphon life\nleave Blank = check all debuff that available at target")
	end,

    icon = "Interface\\Icons\\spell_nature_rejuvenation",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		return [[LowestDebuffDuration(c.NameFirst,c.Name2Raw,c.Unit)]]
		
    end,
})
















