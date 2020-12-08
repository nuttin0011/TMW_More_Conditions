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

Env.PredictLockSS = function()
    return TMW_MC:PredictSS()
end

local LockSpellModSS = {
	["Hand of Gul'dan"]=-3,
	["Shadow Bolt"]=1,
	["Call Dreadstalkers"]=-2,
	["Summon Vilefiend"]=-1,
	["Nether Portal"]=-1,
	["Summon Demonic Tyrant"]=5,
	["Demonbolt"]=2,
	["Seed of Corruption"]=-1,
	["Malefic Rapture"]=-1,
	["Seed of Corruption"]=-1,
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

	local currentSS = _UnitPower("player",7)

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo("player")

	if spellName then
		-- if > 6/10 of spell cast bar ?
		-- trust_segment_cast = 0.6>((currentTime*1000)-startTimeMS)/(endTimeMS-startTimeMS)

		-- if spell < 0.3 sec befor finish casting
		trust_segment_cast = ((endTimeMS/1000)-currentTime)<0.3
	
		if trust_segment_cast then
			currentSS = currentSS+(LockSpellModSS[spellName] or 0)
			currentSS = (currentSS<=5)and currentSS or 5
			currentSS = (currentSS>=0)and currentSS or 0
			old_spell_finish_cast_check = (endTimeMS/1000)+0.2
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
    tooltip = "Predict Warlock SS after casting spell.",
    step = 1,
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
        return [[(PredictLockSS() c.Operator c.Level)]]
    end
})

--****************************percentCastBar*******************************

Env.percentCastBar = function(SpellN)
    return TMW_MC:PercentCastBar(SpellN)
end

local old_val_PercentCastBar = 0
local old_timer_PercentCastBar = 0

function TMW_MC:PercentCastBar(SpellN)
	local currentTimeMS = _GetTime()
	if currentTimeMS==old_timer_PercentCastBar then
		return old_val_PercentCastBar
	end

	old_timer_PercentCastBar = currentTimeMS

	local spellName,_,_, startTimeMS, endTimeMS = _UnitCastingInfo("player")

	if spellName then
		if (spellName==SpellN) or (SpellN==nil) or (SpellN=="") then
			local currentTimeMS = currentTimeMS*1000
			local PercentCast = (currentTimeMS-startTimeMS)/(endTimeMS-startTimeMS)
			old_val_PercentCastBar = PercentCast
			--print(PercentCast)
			return PercentCast
		else
			old_val_PercentCastBar = 0
			return 0
		end
	else
		old_val_PercentCastBar = 0
		return 0
	end
end

ConditionCategory:RegisterCondition(8.6,  "TMWMCPERCENTCAST", {
    text = "% cast bar this spell",
    tooltip = "% cast bar this spell",
	step = 5,
	percent = true,
    min = 0,
	max = 100,
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
        return [[(percentCastBar() c.Operator c.Level)]]
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
	if old_timer_HowManyMobHasMyDot==currentTime then
		return old_val_HowManyMobHasMyDot
	end
	old_timer_HowManyMobHasMyDot=currentTime
    n = 0

        for ii = 1,30 do

        nn = 'nameplate'..ii

        if UnitExists(nn) and UnitDebuff(nn, 1,"PLAYER") then

            
            
            n = n+1

        end

    end

old_val_HowManyMobHasMyDot=n
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

local function allDeBuffByMe(unit)
    -- return table of [Debuff name] = Debuff time remaining
    
    local DebuffName,expTime,i
    local allDeBuff={}
    for i=1,40 do
        DebuffName,_,_,_,_,expTime = _UnitAura(unit, i, "PLAYER|HARMFUL")
        if DebuffName then 
            allDeBuff[DebuffName]=expTime-GetTime()
        else break end
    end
    
    return allDeBuff
end

local old_val_HowManyMyDotOnThisMob = 0
local old_timer_HowManyMyDotOnThisMob = 0
local old_nTarget_HowManyMyDotOnThisMob = ""
local old_nDotTimer_HowManyMyDotOnThisMob = 0
local old_DotSpecific_HowManyMyDotOnThisMob = ""
local old_greaterThan_HowManyMyDotOnThisMob = false

function TMW_MC:HowManyMyDotOnThisMob(nTarget,greaterThan,nDotTimer,DotSpecific)
	nTarget = nTarget or "target"
	nDotTimer = nDotTimer or 3
	greaterThan = greaterThan or false
	DotSpecific = DotSpecific or ""
	DotSpecific = strlower(DotSpecific)
	if DotSpecific==";" then DotSpecific="" end
	--print(DotSpecific)
	if not _UnitExists(nTarget) then return 0 end
	
	local currentTime = _GetTime()
	if (old_timer_HowManyMyDotOnThisMob==currentTime)
		and(old_nTarget_HowManyMyDotOnThisMob==nTarget)
		and(old_greaterThan_HowManyMyDotOnThisMob==greaterThan)
		and(old_nDotTimer_HowManyMyDotOnThisMob==nDotTimer)
		and(old_DotSpecific_HowManyMyDotOnThisMob==DotSpecific)then
		
		return old_val_HowManyMyDotOnThisMob
	end
	
	--strfind(string, pattern [, initpos [, plain]])
	local function isBuffInList(nBuff,nList)
		-- return true/false
		-- e.g. nBuff = "corruption"
		-- e.g. nList = "Corruption; agony"
		return strfind(nList,strlower(nBuff))~=nil
	end
	
	old_timer_HowManyMyDotOnThisMob = currentTime
	old_nTarget_HowManyMyDotOnThisMob = nTarget
	old_nDotTimer_HowManyMyDotOnThisMob = nDotTimer
	old_DotSpecific_HowManyMyDotOnThisMob = DotSpecific
	old_greaterThan_HowManyMyDotOnThisMob = greaterThan
	
	local allDeBuff = allDeBuffByMe(nTarget)
	local nDebuff = 0
	
	local k,v
	for k,v in pairs(allDeBuff) do
		if greaterThan then
			if (v>=nDotTimer)and((DotSpecific=="") or isBuffInList(k,DotSpecific)) then nDebuff=nDebuff+1 end
		else
			if (v<=nDotTimer)and((DotSpecific=="") or isBuffInList(k,DotSpecific)) then nDebuff=nDebuff+1 end
		end
	end

	old_val_HowManyMyDotOnThisMob = nDebuff

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
		return [[(HowManyMyDotOnThisMob(c.Unit,true,3,c.Name) c.Operator c.Level)]]
    end
})
--********************** Enemy Count in 8 yard ********
Env.IROEnemyCountIn8yd = function()
    return TMW_MC:IROEnemyCountIn8yd()
end

local Temp_IROEnemyCountIn8yd ={
	["old_timer"]=0,
	["old_val"]=0,
	}

function TMW_MC:IROEnemyCountIn8yd()
	--return enemy count in 8 yard Max 5
	local currentTime = GetTime()
	
	if Temp_IROEnemyCountIn8yd.old_timer == currentTime then
		return Temp_IROEnemyCountIn8yd.old_val
	end
	
	Temp_IROEnemyCountIn8yd.old_timer = currentTime
	
    local i,nn,count
    count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and IsItemInRange("item:34368", nn) then
            count=count+1
        end
        if count>=5 then break end
    end
    Temp_IROEnemyCountIn8yd.old_val=count
	
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









