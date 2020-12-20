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

local CNDT = TMW.CNDT
local Env = CNDT.Env

local GetSpecialization=GetSpecialization
local GetSpecializationInfo=GetSpecializationInfo
local UnitIsUnit=UnitIsUnit

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

	old_timer_PercentCastBar = currentTimeMS

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo(nUnit)

	if spellName then
		if (spellName==SpellN) or (SpellN=="") then
			local currentTimeMS = currentTimeMS*1000
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
--********************** Enemy Count in 8 yard ********
Env.IROEnemyCountIn8yd = function()
    return TMW_MC:IROEnemyCountIn8yd()
end

function TMW_MC:IROEnemyCountIn8yd()
	--return enemy count in 8 yard Max 5
	
	local OldVal=Old_Val_Check("IROEnemyCountIn8yd","")
	if OldVal then return OldVal end
	
    local i,nn,count
    count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and IsItemInRange("item:34368", nn) then
            count=count+1
        end
        if count>=5 then break end
	end
	
	Old_Val_Update("IROEnemyCountIn8yd","",count)
	
    return  count
	
end

ConditionCategory:RegisterCondition(8.9,  "TMWMCIROENEMYCOUNTIN8YD", {
    text = "return Enemy Count in 8 yard. Max 5",
    tooltip = "Enemy Name playe must turn on!",
	step = 1,
	percent = false,
    min = 0,
	max = 5,
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
        return [[(IROEnemyCountIn8yd() c.Operator c.Level)]]
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




