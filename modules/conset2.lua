local TMW = TMW
local TMW_MC = TMW_More_Conditions

local GetTime = GetTime
local UnitExists = UnitExists
local GetSpellInfo=GetSpellInfo
local CNDT = TMW.CNDT
local Env = CNDT.Env

local GetNumGroupMembers= GetNumGroupMembers
local UnitHealth=UnitHealth
local UnitHealthMax=UnitHealthMax

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


--****************************** All Debuff Duration

function TMW_MC:AllDebuffDuration(nSetDebuff,nUnit)
	nSetDebuff = string.lower(nSetDebuff) or ""
	if nSetDebuff==";" then nSetDebuff="" end
	nUnit = nUnit or "target"
	
	if not UnitExists(nUnit) then
		return 0
	end
	
	local deBuff=Env.allDeBuffByMe(nUnit)
	local duration = 500
	
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
	
	if IsSomeSpellHasZeroDuration() then
		return 0
	end
	
	local k,v
    for k,v in pairs(deBuff) do
		if ((nSetDebuff=="")or string.find(nSetDebuff,string.lower(k)))and (duration>v) then
			duration=v
		end
	end
	return duration
end

function Env.AllDebuffDuration(nSetDebuff,nUnit)
	return TMW_MC:AllDebuffDuration(nSetDebuff,nUnit)
end

ConditionCategory:RegisterCondition(9.2,  "TMWMCALLDEBUFFDURATION", {
    text = "Check all set of DeBuff Duration",
	unit=nil,
	step = 0.1,
	percent = false,
    min = 0,
	formatter = TMW.C.Formatter.TIME_0ABSENT,
	range = 10,
	name = function(editbox) 
		editbox:SetTexts("Debuff Set Name To Check","e.g. agony; corruption; unstable affliction")
	end,
	specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

    icon = "Interface\\Icons\\spell_nature_rejuvenation",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		return [[AllDebuffDuration(c.NameRaw,c.Unit) c.Operator c.Level]]
		
    end,
})


--****************************** Target HP compare to (Player HP * Party Size)

function TMW_MC:PlayerPartyHP(nMultiple,IsHealthMax)
	nUnit = nUnit or "target"
	nMultiple = nMultiple or 1
	local numGroup = GetNumGroupMembers()
	if numGroup == 0 then numGroup = 1 end
	if IsHealthMax then
		playerHP=UnitHealthMax("player")
	else
		playerHP=UnitHealth("player")		
	end
	return playerHP*nMultiple
end

function Env.PlayerPartyHP(nMultiple,IsHealthMax)
	return TMW_MC:PlayerPartyHP(nMultiple,IsHealthMax)
end

ConditionCategory:RegisterCondition(9.3,  "TMWMCCOMPAREHPPARTYANDMOB", {
	text = "Compare PlayerGroupHP & Unit",
	tooltip = "Compare PlayerHP * Group_Number and MOB_HP * Multiple_Constant",
	unit="PartyHP",
	step = 0.1,
    min = 0,
	range = 10,
	texttable = function(v) return v.." Times" end,
	name = function(editbox)
		editbox:SetTexts("Unit To compare HP", "e.g. target")
	end,
	check = function(check)
		check:SetTexts("Use PlayerMaxHP", "Use Player Current HP if unchecked")
	end,
	specificOperators = {["<="] = true, [">="] = true},
    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = "<="
        end
    end,

    icon = "Interface\\Icons\\spell_nature_rejuvenation",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		return [[PlayerPartyHP(c.Level,c.Checked) c.Operator UnitHealthMax(c.NameRaw)]]
		
    end,
})




