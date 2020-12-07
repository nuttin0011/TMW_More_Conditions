local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local _UnitAura = UnitAura

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

Env.HowManyMyDotOnThisMob = function(nTarget)
    return TMW_MC:HowManyMyDotOnThisMob(nTarget)
end

local old_val_HowManyMobHasMyDot = 0
local old_timer_HowManyMobHasMyDot = 0
local old_nTarget_HowManyMobHasMyDot = 0
local old_nDotTimerRemaining_HowManyMobHasMyDot = 0

local function allDeBuffByMe(unit)
    -- return table of [Debuff name] = Debuff time remaining
    
    local DebuffName,expTime,i
    local DeallBuff={}
    for i=1,40 do
        DebuffName,_,_,_,_,expTime = _UnitAura(unit, i, "PLAYER|HARMFUL")
        if DebuffName then 
            allDeBuff[buffName]=expTime-GetTime()
        else break end
    end
    
    return allDeBuff
end

function TMW_MC:HowManyMyDotOnThisMob(nTarget,nDotTimerRemaining)
	nTarget = nTarget or "target"
	nDotTimerRemaining = nDotTimerRemaining or 3
	
	local currentTime = _GetTime()
	if (old_timer_HowManyMobHasMyDot==currentTime)and(old_nTarget_HowManyMobHasMyDot==nTarget)and(old_nDotTimerRemaining_HowManyMobHasMyDot==nDotTimerRemaining)then
		return old_val_HowManyMobHasMyDot
	end
	
	old_timer_HowManyMobHasMyDot = currentTime
	
	print(nTarget)
	
	local allDeBuff = allDeBuffByMe(nTarget)
	
	local k,v
	for k,v in pairs(allDeBuff) do
		print(k,v)
	end

	

	return 0

end







