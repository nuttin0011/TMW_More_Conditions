local TMW = TMW
local TMW_MC = TMW_More_Conditions
local CNDT = TMW.CNDT
local Env = CNDT.Env

--cache

local GetSpecialization=GetSpecialization
local GetSpecializationInfo=GetSpecializationInfo
local UnitGUID=UnitGUID
local CombatLogGetCurrentEventInfo=CombatLogGetCurrentEventInfo
local allBuffByMe=Env.allBuffByMe
local allDeBuffByMe=Env.allDeBuffByMe
local GetTime=GetTime
local UnitExists=UnitExists
local UnitCastingInfo=UnitCastingInfo

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)
-- for mage

local playerGUID
local f = CreateFrame("Frame")
local FlurryTargetGUID = ""
local FlurryTargetTime = 0
local FlurryBuffWinterChillCount = 0
local EbonboltHitTime = 0

local function checkFlurryTimer()
	local currentTime = GetTime()
	if (FlurryBuffWinterChillCount>0 )and (FlurryTargetTime<currentTime) then
		FlurryBuffWinterChillCount=0
		FlurryTargetGUID=""
	end
end


function f:COMBAT_LOG_EVENT_UNFILTERED(...)
	if not playerGUID then playerGUID=UnitGUID("player") end

	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
	local buff,debuff, currentTime
	currentTime = GetTime()
	-- check Spell Flurry for Ice Mage

	checkFlurryTimer()

	if subevent == "SPELL_CAST_SUCCESS" then

		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)

		--reset Flurry Time if cast > 6 sec ago


		--cast Flurry instance setup
		if spellName=="Ebonbolt" then
			EbonboltHitTime = currentTime+1
			print("ebon")
		end

		if spellName=="Flurry" then
			buff = allBuffByMe("player")
			if (buff["Brain Freeze"] and buff["Brain Freeze"] or 0)>0.2 then
				--print ('cast Flurry instance')
				--print(destGUID)
				FlurryTargetGUID = destGUID
				FlurryTargetTime = currentTime+6
				if EbonboltHitTime>currentTime then 
					FlurryBuffWinterChillCount=1
				else
					FlurryBuffWinterChillCount=2
				end

			end
		end

		if (FlurryBuffWinterChillCount>0)and(destGUID==FlurryTargetGUID) then
			if (spellName == "Ice Lance") or
			(spellName == "Glacial Spike")
			then
				FlurryBuffWinterChillCount=FlurryBuffWinterChillCount-1
			end
			--print (FlurryBuffWinterChillCount)
		end

	end

--[[
	if subevent == "SWING_DAMAGE" then
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
	elseif subevent == "SPELL_DAMAGE" then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
	end
--]]

--[[
	if critical and sourceGUID == playerGUID then
		-- get the link of the spell or the MELEE globalstring
		local action = spellId and GetSpellLink(spellId) or MELEE
		print(action, destName, amount)
	end
	-]]

end

local initFunctionSeted = false

function TMW_MC:InitMageCombatEvent()
	if (not initFunctionSeted) then
		initFunctionSeted=true
		local currentSpec = GetSpecialization()
		local IROSpecID  = GetSpecializationInfo(currentSpec)
		if (IROSpecID >=62) and (IROSpecID <=64) then --mage
			f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			f:SetScript("OnEvent", function(self, event)
				self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
			end)
		end
	end
end

function TMW_MC:PredictWinterChill(nUnit)

	if (not initFunctionSeted) then TMW_MC:InitMageCombatEvent() end
	nUnit=nUnit or "target"
	if not UnitExists(nUnit) then return false end
	if UnitGUID(nUnit)~=FlurryTargetGUID then return false end
	checkFlurryTimer()
	if FlurryBuffWinterChillCount==0 then return false end
	if (FlurryBuffWinterChillCount==1) and (UnitCastingInfo("player")=="Glacial Spike") then
		return false
	end
	return true
end

Env.PredictWinterChillForIL = function(nUnit)
	return TMW_MC:PredictWinterChill(nUnit)
end

ConditionCategory:RegisterCondition(9.5,  "TMWMCPREDICTIL", {
	text = "Predict Winter's Chill For use Ice Lance",
	tooltip = [[Predict Winter's Chill For use Ice Lance. NOTE! Winter's Chill is DeBuff at "Target" not "player"]],
	unit=nil,
	step = 1,
	min = 0,
	max =1,
	bool = true,
	texttable = {
		[0] = "Winter's chill Proc",
		[1] = "Winter's chill not Proc",
	},

    icon = "Interface\\Icons\\spell_ice_rune",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		if c.Level==0 then
			return [[PredictWinterChillForIL(c.Unit)]]
		else
			return [[not PredictWinterChillForIL(c.Unit)]]
		end
		
    end,
})