local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local _UnitAura = UnitAura
local _UnitExists = UnitExists
local _UnitGUID = UnitGUID
local Old_Val_Check = TMW.CNDT.Env.Old_Val_Check
local Old_Val_Update = TMW.CNDT.Env.Old_Val_Update
local GetSpellCooldown=GetSpellCooldown

local CNDT = TMW.CNDT
local Env = CNDT.Env

local IsItemInRange=IsItemInRange
local GetSpecialization=GetSpecialization
local GetSpecializationInfo=GetSpecializationInfo
local UnitIsUnit=UnitIsUnit
local UnitChannelInfo=UnitChannelInfo
local UnitSpellHaste=UnitSpellHaste
local UnitCanAttack=UnitCanAttack
local playerGUID = UnitGUID("player")
local extended_check_timer = _GetTime()
local old_timer_check = 0
local old_spell_finish_cast_check = 0
local old_val = 0
local trust_segment_cast = true

local function printtable(a)
	local k,v
		for k,v in pairs(a) do
			print(k,v)
		end
	
	end

--Temp Val of allDeBuffByMe
temp_allDeBuffByMe ={[1]=0,[2]={}}
--[1]=timer , [2]= [GUID] = result

function Env.allDeBuffByMe(unit)

    --*********return table of [Debuff name] = Debuff time remaining
	local allDeBuff={}
	local unitGUID = _UnitGUID(unit)
	if not unitGUID then return allDeBuff end
	local currentTimer = _GetTime()


	if (temp_allDeBuffByMe[1]==currentTimer)and(temp_allDeBuffByMe[2][unitGUID]) then
		return temp_allDeBuffByMe[2][unitGUID]
	end

	if temp_allDeBuffByMe[1]<currentTimer then
		temp_allDeBuffByMe[1]=currentTimer
		temp_allDeBuffByMe[2]={}
	end

    local DebuffName,expTime,i

    for i=1,40 do
        DebuffName,_,_,_,_,expTime = _UnitAura(unit, i, "PLAYER|HARMFUL")
        if DebuffName then 
            allDeBuff[DebuffName]=expTime-GetTime()
        else break end
    end

	temp_allDeBuffByMe[2][unitGUID]=allDeBuff

    return allDeBuff
end

--Temp Val of allBuffByMe
temp_allBuffByMe ={[1]=0,[2]={}}
--[1]=timer , [2]= [GUID] = result

function Env.allBuffByMe(unit)

    --*********return table of [Buff name] = Buff time remaining
	local allBuff={}
	local unitGUID = _UnitGUID(unit)
	if not unitGUID then return allBuff end
	local currentTimer = _GetTime()


	if (temp_allBuffByMe[1]==currentTimer)and(temp_allBuffByMe[2][unitGUID]) then
		return temp_allBuffByMe[2][unitGUID]
	end

	if temp_allBuffByMe[1]<currentTimer then
		temp_allBuffByMe[1]=currentTimer
		temp_allBuffByMe[2]={}
	end

    local DebuffName,expTime,i

    for i=1,40 do
        DebuffName,_,_,_,_,expTime = _UnitAura(unit, i, "PLAYER|HELPFUL")
        if DebuffName then 
            allBuff[DebuffName]=expTime-GetTime()
        else break end
    end

	temp_allBuffByMe[2][unitGUID]=allBuff

    return allBuff
end

Env.PredictLockSS = function()
    return TMW_MC:PredictSS()
end

local LockSpellModSS = {
	["Hand of Gul'dan266"]=-30, --266 = Demo
	["Shadow Bolt266"]=10, 
	["Call Dreadstalkers266"]=-20,
	["Summon Vilefiend266"]=-10,
	["Nether Portal266"]=-10,
	["Summon Demonic Tyrant266"]=50,
	["Demonbolt266"]=20,
	["Seed of Corruption265"]=-10, --265 = Aff
	["Malefic Rapture265"]=-10,
	["Chaos Bolt267"]=-20, -- 267 = des
	["Incinerate267"]=2
}

local function PredictSSFrameEvent(self, event, ...)
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,SpellName = _CombatLogGetCurrentEventInfo()

        if (sourceGUID==playerGUID)  and (subevent=="SPELL_CAST_FAILED") then
			trust_segment_cast = true
       end
end

function TMW_MC:PredictSS()
	-- if (trust_segment_cast == Ture) Must Recalculate
	-- if (trust_segment_cast == False) Must Use old_val
	
	local currentTime = _GetTime()

	if old_timer_check == currentTime then
		return old_val
	end

	if (not trust_segment_cast) then
		if (currentTime>old_spell_finish_cast_check) then
			trust_segment_cast = true
		else
			return old_val
		end
	end

	local currentSpec = GetSpecialization()
    local IROSpecID  = GetSpecializationInfo(currentSpec)

	local currentSS = _UnitPower("player",7,true)

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo("player")

	if spellName then
		local endTime = endTimeMS/1000
		-- if > 6/10 of spell cast bar ?
		-- trust_segment_cast = 0.6>((currentTime*1000)-startTimeMS)/(endTimeMS-startTimeMS)

		-- if spell < 0.3 sec befor finish casting
		trust_segment_cast = (endTime-currentTime)>0.3
		if trust_segment_cast then
			if spellName == "Incinerate" then
				-- check Havoc for double SS generate
				local nn
				local nnDebuff
				local hasHavoc = false
				for ii = 1,30 do
					nn="nameplate"..ii
					if _UnitExists(nn) then
						nnDebuff = Env.allDeBuffByMe(nn)
						if nnDebuff["Havoc"] then
							hasHavoc = (not UnitIsUnit("target",nn)) and (nnDebuff["Havoc"]>(0.1+endTime-currentTime))
							break
						end
					end
				end
				if hasHavoc then 
					currentSS = currentSS + 4
				else
					currentSS = currentSS + 2
				end
			else
				currentSS = currentSS+(LockSpellModSS[spellName..IROSpecID] or 0)
			end
			currentSS = (currentSS<=50)and currentSS or 50
			currentSS = (currentSS>=0)and currentSS or 0
			old_spell_finish_cast_check = endTime+0.2
		else
			return old_val
		end
	end

	old_timer_check = currentTime
	old_val = currentSS
	return currentSS
end

PredictSSFrame = CreateFrame("Frame")
PredictSSFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
PredictSSFrame:SetScript("OnEvent", PredictSSFrameEvent)

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)

ConditionCategory:RegisterCondition(8.5,  "TMWMCPREDICTSS", {
    text = "Predict Warlock Soul Shard",
    tooltip = "Predict Warlock SS after casting spell.\n 0.1 = 1 ss fragment in Des",
    step = 1,
    min = 0,
    max = 50,
    unit="player",
	texttable = function(k) return (k/10) .." ss" end, -- calculate SS fragment, Display SSFragment / 10
    icon = "Interface\\Icons\\ability_druid_bash",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

    funcstr = function(c, parent)
        return [[(PredictLockSS() c.Operator c.Level)]]
    end
})

--****************************percentCastBar*******************************

Env.percentCastBar = function(SpellN,nUnit)
    return TMW_MC:PercentCastBar(SpellN,nUnit)
end

function TMW_MC:PercentCastBar(SpellN,nUnit)

	local currentTimeMS = _GetTime()
	nUnit = nUnit or "target"
	SpellN = SpellN or ""
	if SpellN == ";" then SpellN = "" end
	
	local OldVal = Old_Val_Check("PercentCastBar",SpellN..nUnit)
	if OldVal then return OldVal end

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo(nUnit)
	if not(spellName) then
		spellName, _, _, startTimeMS, endTimeMS = UnitChannelInfo(nUnit)
	end

	if spellName then
		if (spellName==SpellN) or (SpellN=="") then
			currentTimeMS = currentTimeMS*1000
			local PercentCast = (currentTimeMS-startTimeMS)/(endTimeMS-startTimeMS)
			Old_Val_Update("PercentCastBar",SpellN..nUnit,PercentCast)
			--print(PercentCast)
			return PercentCast
		else
			Old_Val_Update("PercentCastBar",SpellN..nUnit,0)
			return 0
		end
	else
		Old_Val_Update("PercentCastBar",SpellN..nUnit,0)
		return 0
	end
end

ConditionCategory:RegisterCondition(8.6,  "TMWMCPERCENTCAST", {
    text = "% cast bar unit's spell",
    tooltip = "% cast bar unit's spell",
	step = 5,
	percent = true,
    min = 0,
	max = 100,
    unit=nil,

    icon = "Interface\\Icons\\ability_druid_bash",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

	funcstr = function(c, parent)
        return [[(percentCastBar(nil,c.Unit) c.Operator c.Level)]]
    end
})
--******************** Castime Remain ?

Env.CasttimeRemain = function(SpellN,nUnit)
    return TMW_MC:CasttimeRemain(SpellN,nUnit)
end

function TMW_MC:CasttimeRemain(SpellN,nUnit)

	local currentTime = _GetTime()
	nUnit = nUnit or "target"
	SpellN = SpellN or ""
	if SpellN == ";" then SpellN = "" end
	
	local OldVal = Old_Val_Check("CasttimeRemain",SpellN..nUnit)
	if OldVal then return OldVal end

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo(nUnit)
	if not(spellName) then
		spellName, _, _, startTimeMS, endTimeMS = UnitChannelInfo(nUnit)
	end

	if spellName then
		if (spellName==SpellN) or (SpellN=="") then
			local timeremain = (endTimeMS/1000)-currentTime
			Old_Val_Update("CasttimeRemain",SpellN..nUnit,timeremain)
			--print(timeremain)
			return timeremain
		else
			Old_Val_Update("CasttimeRemain",SpellN..nUnit,0)
			return 0
		end
	else
		Old_Val_Update("CasttimeRemain",SpellN..nUnit,0)
		return 0
	end
end

ConditionCategory:RegisterCondition(8.65,  "TMWMCCASTTIMEREMAIN", {
    text = "Castime Remain",
    tooltip = "Castime Remain\nNote Not Cast = return 0",
	step = 0.1,
    min = 0,
	max = 10,
    unit=nil,

    icon = "Interface\\Icons\\ability_ardenweald_druid",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true, ["<"] = true, [">"] = true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

	funcstr = function(c, parent)
        return [[(CasttimeRemain(nil,c.Unit) c.Operator c.Level)]]
    end
})




--******************HowManyMobHasMyDot()****************

Env.HowManyMobHasMyDot = function()
    return TMW_MC:HowManyMobHasMyDot()
end

local old_val_HowManyMobHasMyDot = 0
local old_timer_HowManyMobHasMyDot = 0

function TMW_MC:HowManyMobHasMyDot()

    local ii,nn,n
	local currentTime = _GetTime()

	local OldVal = Old_Val_Check("HowManyMobHasMyDot","")
	if OldVal then return OldVal end

	old_timer_HowManyMobHasMyDot=currentTime
    n = 0
        for ii = 1,30 do
        nn = 'nameplate'..ii
        if UnitExists(nn) and UnitDebuff(nn, 1,"PLAYER") then
            n = n+1
        end
    end
	Old_Val_Update("HowManyMobHasMyDot","",n)
  return n

end

ConditionCategory:RegisterCondition(8.7,  "TMWMCHOWMANYMOBHASMYDOT", {
    text = "number of Mob has my DOT",
    tooltip = "number of Mob has my DOT",
	step = 1,
	percent = false,
    min = 0,
	max = 30,
    unit="player",

    icon = "Interface\\Icons\\ability_druid_bash",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

	funcstr = function(c, parent)
        return [[(HowManyMobHasMyDot() c.Operator c.Level)]]
    end
})

--******************HowManyMyDotOnThisMob()****************

Env.HowManyMyDotOnThisMob = function(nTarget,greaterThan,nDotTimer,DotSpecific)
    return TMW_MC:HowManyMyDotOnThisMob(nTarget,greaterThan,nDotTimer,DotSpecific)
end




function TMW_MC:HowManyMyDotOnThisMob(nTarget,greaterThan,nDotTimer,DotSpecific)
	nTarget = nTarget or "target"
	nDotTimer = nDotTimer or 3
	greaterThan = greaterThan or 0 -- 1 = true , 0 = false
	DotSpecific = DotSpecific or ""
	DotSpecific = strlower(DotSpecific)
	if DotSpecific==";" then DotSpecific="" end
	--print(DotSpecific)
	if not _UnitExists(nTarget) then return 0 end
	
	local OldVal=Old_Val_Check("HowManyMyDotOnThisMob",nTarget..greaterThan..nDotTimer..DotSpecific)
	if OldVal then return OldVal end
	
	--strfind(string, pattern [, initpos [, plain]])
	local function isBuffInList(nBuff,nList)
		-- return true/false
		-- e.g. nBuff = "corruption"
		-- e.g. nList = "Corruption; agony"
		return strfind(nList,strlower(nBuff))~=nil
	end
	
	local allDeBuff = Env.allDeBuffByMe(nTarget)
	local nDebuff = 0
	
	local k,v
	for k,v in pairs(allDeBuff) do
		if (greaterThan==1) then
			if (v>=nDotTimer)and((DotSpecific=="") or isBuffInList(k,DotSpecific)) then nDebuff=nDebuff+1 end
		else
			if (v<=nDotTimer)and((DotSpecific=="") or isBuffInList(k,DotSpecific)) then nDebuff=nDebuff+1 end
		end
	end

	Old_Val_Update("HowManyMyDotOnThisMob",nTarget..greaterThan..nDotTimer..DotSpecific,nDebuff)

	return nDebuff

end

ConditionCategory:RegisterCondition(8.8,  "TMWMCHOWMANYMYDOTONTHISMOB", {
    text = "number of My DOT that has duration > 3 Sec",
    tooltip = "Count My DOT.",
	step = 1,
	percent = false,
    min = 0,
	range = 10,
    unit=nil,
	name = function(editbox) 
			editbox:SetTexts("specific Dot","leave blank = check all dot.\ne.g. Corruption; Agony")
		end,
    icon = "Interface\\Icons\\ability_druid_bash",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true,[">="] = true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

	funcstr = function(c, parent)
		return [[(HowManyMyDotOnThisMob(c.Unit,1,3,c.Name) c.Operator c.Level)]]
    end
})
--********************** Enemy Count in 8 yard Max 8********
Env.IROEnemyCountIn8yd = function(Rlevel)
    return TMW_MC:IROEnemyCountIn8yd(Rlevel)
end

local ItemRangeCheck = {
[1]=34368, -- Attuned Crystal Cores 8 yard
[2]=33069, -- Sturdy Rope 15 yard
[3]=10645, -- Gnomish Death Ray 20 yard
[4]=835, -- Large Rope Net 30 yard
[5]=28767, -- The Decapitator 40 yard
}

local ItemNameToCheck8 = "item:"..ItemRangeCheck[1]

function TMW_MC:IROEnemyCountIn8yd(Rlevel)
	--return enemy count in Range Default 8 yard Max 8
	Rlevel = Rlevel or 0
	--print(Rlevel)
	local OldVal=Old_Val_Check("IROEnemyCountIn8yd",Rlevel)
	if OldVal then return OldVal end

	local ItemNameToCheck = "item:"..ItemRangeCheck[Rlevel+1]
    local i,nn,count
	local count=0
    for i=1,30 do
        nn='nameplate'..i
		if UnitExists(nn) then
			if IsItemInRange(ItemNameToCheck8, nn)or(UnitAffectingCombat(nn)and IsItemInRange(ItemNameToCheck, nn)) then
				count=count+1
			end
        end
        if count>=8 then break end
	end

	Old_Val_Update("IROEnemyCountIn8yd",Rlevel,count)
	
    return  count
	
end

ConditionCategory:RegisterCondition(8.9,  "TMWMCIROENEMYCOUNTIN8YD", {
    text = "Enemy Count in Range(Default 8 yards). Max 8 Units",
    tooltip = "Enemy Name plate must turn on!, All Enemy Must In Combat.\nNoTe! Training Dummy almost not incombat.",
	step = 1,
    min = 0,
	max = 8,
    unit="Enemy",
	name=function(editbox) 
		editbox:SetTexts("no Check=8 yard,Check 1=15 yard,Check 2=20 yard, Check 1+2=30 yard")
	end,
	name2=function(editbox) 
		editbox:SetTexts("or Type 8,15,20,30,40 here for range(yards)")
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
		if c.Name2=="40" then return [[(IROEnemyCountIn8yd(4) c.Operator c.Level)]]
		elseif c.Name2=="30" then return [[(IROEnemyCountIn8yd(3) c.Operator c.Level)]]
		elseif c.Name2=="20" then return [[(IROEnemyCountIn8yd(2) c.Operator c.Level)]]
		elseif c.Name2=="15" then return [[(IROEnemyCountIn8yd(1) c.Operator c.Level)]]
		elseif c.Name2=="8" then return [[(IROEnemyCountIn8yd(0) c.Operator c.Level)]]
		end

		if c.Checked then
			if c.Checked2 then
				return [[(IROEnemyCountIn8yd(3) c.Operator c.Level)]]
			else
				return [[(IROEnemyCountIn8yd(1) c.Operator c.Level)]]
			end
		else
			if c.Checked2 then
				return [[(IROEnemyCountIn8yd(2) c.Operator c.Level)]]
			else
				return [[(IROEnemyCountIn8yd(0) c.Operator c.Level)]]
			end
		end
    end
})

--*********************** Compare HP ******************

Env._UnitHealth = UnitHealth

ConditionCategory:RegisterCondition(9,  "TMWMCIROCOMPAREHP", {
    text = "Compare Current HP Unit1 and Unit2",
	unit=true,
	noslide = true,
	name = function(editbox) 
		editbox:SetTexts("Unit 1","e.g. target")
	end,
	name2 = function(editbox) 
		editbox:SetTexts("Unit 2","e.g. targettarget")
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
		return [[(_UnitHealth(c.NameFirst) c.Operator _UnitHealth(c.NameFirst2))]]
		
    end,
})

--***************************************************GCD Remain
function TMW_MC:GCDRemain()
	--return GCD Ramain
	
	local OldVal=Old_Val_Check("GCDRemain","")
	if OldVal then return OldVal end
	
	local st,du=GetSpellCooldown(TMW.GCDSpell)
	local ti = 0
	if st>0 then
		ti=(st+du)-_GetTime()
	end
	
	Old_Val_Update("GCDRemain","",ti)
	
    return  ti
	
end

Env.GCDRemain = function()
    return TMW_MC:GCDRemain()
end


ConditionCategory:RegisterCondition(9,  "TMWMCGCDCOMPARE", {
    text = "GCD",
	unit="player",
	step=0.1,
	min=0,
	max=2,
	icon = "Interface\\Icons\\spell_nature_rejuvenation",	
	formatter = TMW.C.Formatter.TIME_0USABLE,
    tcoords = CNDT.COMMON.standardtcoords,	

	specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true,["<"] = true, [">"] = true},
	
	applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

	funcstr = function(c, parent)
		return [[(GCDRemain() c.Operator c.Level)]]
		
    end,
})

-- ************************* GCD Compare to Spell

IROClassGCDOneSec = { 
    [259]=true,[260]=true,[261]=true, -- rogue
    [269]=true, -- monk WW
    [103]=true, -- druid feral
}

local function round(number, decimals)
	return (("%%.%df"):format(decimals)):format(number)
end

function TMW_MC:GCDCDTime()
	--return GCD CD
	local OldVal=Old_Val_Check("GCDCDTime","")
	if OldVal then return OldVal end
	
	local GCDCD=TMW.GCD

	if GCDCD == 0 then
		local currentSpec = GetSpecialization()
		local IROSpecID  = GetSpecializationInfo(currentSpec)
		if IROClassGCDOneSec[IROSpecID] then
			GCDCD = 1
		else
			GCDCD = round(1.5*(100/(100+UnitSpellHaste("player"))),2)
		end
	end
		
	Old_Val_Update("GCDCDTime","",GCDCD)
	
	return GCDCD
end

Env.GCDCDTime = function()
	return TMW_MC:GCDCDTime()
end

ConditionCategory:RegisterCondition(9,  "TMWMCGCDCOMPARESPELL", {
	text = "Spell's CD Compare To GCD's CD Time",
	tooltip = "Note. GCD's CD = 1.5*(100/(100+%haste)) sec.\n Druid Feral,Monk WW,Rogue have GCD's CD = 1 sec",
	unit="PlayerSpellCD",
	step=0.1,
	min=1,
	max=8,
	icon = "Interface\\Icons\\ability_demonhunter_eyebeam",	
	texttable = function(v)
		if v>0 then
			return "GCD*"..v.."="..(Env.GCDCDTime()*v).."sec"
		end
	end,
    tcoords = CNDT.COMMON.standardtcoords,	
	name = function(editbox) 
		editbox:SetTexts("Spell, Only 1 Spell","e.g. Eye Beam")
	end,
	useSUG = "spell",
	specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true,["<"] = true, [">"] = true},
	
	applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,

	funcstr = function(c, parent)
		return [[CooldownDuration(c.NameFirst, false) c.Operator (GCDCDTime()*c.Level)]]
		--return [[(GCDRemain() c.Operator c.Level)]]
		--return [[true]]
		
    end,
})


--****************** IsUnit Furthest / Nearest

local HarmItemsRangeCheckOrder = {
	{5,8,10,15,20,25,30,35,40,45},
	{45,40,35,30,25,20,15,10,8,5}
}

local HarmItemsRangeCheck = {
    [5] =
        8149, -- Voodoo Charm
    [8] =
        34368, -- Attuned Crystal Cores
    [10] =
        32321, -- Sparrowhawk Net
    [15] =
        33069, -- Sturdy Rope
    [20] =
        10645, -- Gnomish Death Ray
    [25] =
        24268, -- Netherweave Net
    [30] =
        835, -- Large Rope Net
    [35] =
        24269, -- Heavy Netherweave Net
    [40] =
        28767, -- The Decapitator
    [45] =
        23836, -- Goblin Rocket Launcher
}

local function SplitTextToTable(t)
	-- convert string "a; b; c" --> table {"a","b","c"}
	local tableText={}
	local s1 =string.find(t, "; ")
	while s1 do
		t1=string.sub(t,1,s1-1)
		t=string.sub(t,s1+2,string.len(t))
		s1=string.find(t, "; ")
		table.insert(tableText, t1)		
	end
	table.insert(tableText, t)
	return tableText
end

local function IsItemIDInRange(itemID,nn)
	return IsItemInRange("item:"..itemID,nn)
end

function TMW_MC:IsUnitNestest(nUnit,nSetOfUnit)
	--ONLY ENEMY
	--unit e.g. "target" , "party1target"
	--SetOfUnit e.g. "party1target; party2target; party3target"
	
	local OldVal=Old_Val_Check("IsUnitNestest",nUnit..nSetOfUnit)
	if OldVal then return OldVal end
	
	nUnit = nUnit or "target"
	nSetOfUnit = nSetOfUnit or ""
	if (not UnitExists(nUnit)) or (not UnitCanAttack("player", nUnit)) then
		Old_Val_Update("IsUnitNestest",nUnit..nSetOfUnit,false)
		return false 
	end
	
	local SetOfUnit = SplitTextToTable(nSetOfUnit)
	local ItemIDRangeCheck,rangepick
	local found = false
	for ii=1,10 do
		rangepick=HarmItemsRangeCheckOrder[1][ii]
		ItemIDRangeCheck=HarmItemsRangeCheck[HarmItemsRangeCheckOrder[1][ii]]
		for k,nn in pairs(SetOfUnit) do
			if UnitExists(nn) and IsItemIDInRange(ItemIDRangeCheck,nn) then
				found = true
				break
			end
		end
		if found then break end
	end
	if found then
		found = IsItemIDInRange(ItemIDRangeCheck,nUnit)
		Old_Val_Update("IsUnitNestest",nUnit..nSetOfUnit,found)
		return found
	else
		Old_Val_Update("IsUnitNestest",nUnit..nSetOfUnit,true)	
		return true
	end
end

function TMW_MC:IsUnitFurthest(nUnit,nSetOfUnit)
	--ONLY ENEMY
	--unit e.g. "target" , "party1target"
	--SetOfUnit e.g. "party1target; party2target; party3target"
	nUnit = nUnit or "target"
	nSetOfUnit = nSetOfUnit or ""	
	local OldVal=Old_Val_Check("IsUnitFurthest",nUnit..nSetOfUnit)
	if OldVal then return OldVal end
	
	if (not UnitExists(nUnit)) or (not UnitCanAttack("player", nUnit)) then
		Old_Val_Update("IsUnitFurthest",nUnit..nSetOfUnit,false)
		return false
	end
	local SetOfUnit = SplitTextToTable(nSetOfUnit)
	local ItemIDRangeCheck,rangepick
	local found = false
	for ii=1,10 do
		ItemIDRangeCheck=HarmItemsRangeCheck[HarmItemsRangeCheckOrder[2][ii]]
		for k,nn in pairs(SetOfUnit) do
			if UnitExists(nn) and (not IsItemIDInRange(ItemIDRangeCheck,nn)) then
				found = true
				break
			end
		end
		if found then break end
	end
	if found then
		found =not IsItemIDInRange(ItemIDRangeCheck,nUnit)
		Old_Val_Update("IsUnitFurthest",nUnit..nSetOfUnit,found)
		return found
	else
		Old_Val_Update("IsUnitFurthest",nUnit..nSetOfUnit,true)
		return true
	end
end

Env.IsUnitNestest = function(nUnit,nSetOfUnit)
	return TMW_MC:IsUnitNestest(nUnit,nSetOfUnit)
end

Env.IsUnitFurthest = function(nUnit,nSetOfUnit)
	return TMW_MC:IsUnitFurthest(nUnit,nSetOfUnit)
end

ConditionCategory:RegisterCondition(9,  "TMWMCUNITNEARORFAR", {
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
		if c.Level==0 then
			return [[IsUnitNestest(c.Unit,c.NameRaw)]]
		else
			return [[IsUnitFurthest(c.Unit,c.NameRaw)]]		
		end
    end,	

})