local TMW = TMW
local TMW_MC = TMW_More_Conditions
local CNDT = TMW.CNDT
local Env = CNDT.Env
local rc = LibStub("LibRangeCheck-2.0")
-- 
-- rc.RegisterCallback(self, rc.CHECKERS_CHANGED, function() print("need to refresh my stored checkers") end)
-- 
-- local minRange, maxRange = rc:GetRange('target')
-- if not minRange then
--     print("cannot get range estimate for target")
-- elseif not maxRange then
--     print("target is over " .. minRange .. " yards")
-- else
--     print("target is between " .. minRange .. " and " .. maxRange .. " yards")
-- end

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
local IROSpecID = nil

local FireBallTravelTime = 0

--Index
local FTarGUID = 0
local FTarRange = 1
local FCastFinish = 2
local FCastSpellName = 3
local FEstimateHitTime = 4
local FCastSyntax = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]="",[FEstimateHitTime]=0}

--order Now->0->1->2->3->delete
--keep only Fireball,Phoenix Flames,Pyroblast (spell that has travel time + trigger "Heating up"
local isProjectileFireSpell = {
	["Fireball"]=true,
	["Phoenix Flames"]=true,
	["Pyroblast"]=true
}

local FireCastFinishTime = {
	[0] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]="",[FEstimateHitTime]=0},
	[1] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]="",[FEstimateHitTime]=0},
	[2] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]="",[FEstimateHitTime]=0},
	[3] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]="",[FEstimateHitTime]=0}
}

local function checkFlurryTimer()
	local currentTime = GetTime()
	if (FlurryBuffWinterChillCount>0 )and (FlurryTargetTime<currentTime) then
		FlurryBuffWinterChillCount=0
		FlurryTargetGUID=""
	end
end

local function predictFireSpellhittime(timeCastFinish,targetRange)
	timeCastFinish = timeCastFinish or GetTime()
	targetRange = targetRange or 0
	local timeMod = 0
	--fire ball travel time >20 yard = 0.7+-0.1 sec
	--fire ball travel time 15-20 yard = 0.45+-0.1 sec
	--fire ball travel time 10-15 yard = 0.3+-0.1 sec
	--fire ball travel time 5-10 yard = 0.2+-0.1 sec	
	--fire ball travel time 2-5 yard = 0.15+-0.1 sec
	--fire ball travel time <2 yard = 0 sec
	if targetRange>20 then timeMod =0.6
	elseif targetRange>=15 then timeMod =0.35
	elseif targetRange>=10 then timeMod =0.2
	elseif targetRange>=5 then timeMod =0.1
	else timeMod=0 end
	return timeCastFinish+timeMod
end


function f:COMBAT_LOG_EVENT_UNFILTERED(...)
	if not playerGUID then playerGUID=UnitGUID("player") end
	if not IROSpecID then IROSpecID = GetSpecializationInfo(GetSpecialization()) end 
	--62 arcane, 63 fire, 64 frost
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
	local buff,debuff, currentTime
	local loadVal = function(...)
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)	
	end
	
	-- DO ONLY PLAYER EVENT
	if sourceGUID~=playerGUID then return false end
	
	currentTime = GetTime()
	-- check Spell Flurry for Ice Mage


	--********** FORST MAGE Begin *********
	if IROSpecID==64 then checkFlurryTimer()end	
	if (IROSpecID==64)and(subevent=="SPELL_CAST_SUCCESS") then
		loadVal(...)
		--reset Flurry Time if cast > 6 sec ago
		--cast Flurry instance setup
		if spellName=="Ebonbolt" then
			EbonboltHitTime = currentTime+1
			--print("ebon")
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
	--********** FROST MAGE END ***********
	
	--********** FIRE MAGE Begin **********
	--*** Assume Cast to "Target"....... cannot detect other e.g. "focus"
	if (IROSpecID==63)and(subevent=="SPELL_CAST_SUCCESS") then
		loadVal(...)
		if (isProjectileFireSpell[spellName]==true) then
			print(FireCastFinishTime[0][FCastSpellName]..FireCastFinishTime[1][FCastSpellName]..FireCastFinishTime[2][FCastSpellName]..FireCastFinishTime[3][FCastSpellName])

			for ii=3,1,-1 do print(ii);FireCastFinishTime[ii]=FireCastFinishTime[ii-1] end
			FireCastFinishTime[0][FTarGUID]=destGUID
			FireCastFinishTime[0][FTarRange]=rc:GetRange('target')
			FireCastFinishTime[0][FCastFinish]=currentTime
			FireCastFinishTime[0][FCastSpellName]=spellName
			FireCastFinishTime[0][FEstimateHitTime]=predictFireSpellhittime(currentTime,FireCastFinishTime[0][FTarRange])
	print(FireCastFinishTime[0][FCastSpellName]..FireCastFinishTime[1][FCastSpellName]..FireCastFinishTime[2][FCastSpellName]..FireCastFinishTime[3][FCastSpellName])

		end
	end
--[[	if (IROSpecID==63)and(subevent=="SPELL_DAMAGE") then	
		loadVal(...)
		if (isProjectileFireSpell[spellName]==true) then
			for ii=3,0,-1 do
				if (FireCastFinishTime[ii][FCastSpellName]==spellName)
				and math.abs(FireCastFinishTime[ii][FEstimateHitTime]-currentTime)<0.4 then
					FireCastFinishTime[ii][FEstimateHitTime]=0
					break
				end
			end
		end
	end
	--]]
	--print(FireCastFinishTime[0][FCastSpellName]..FireCastFinishTime[1][FCastSpellName]..FireCastFinishTime[2][FCastSpellName]..FireCastFinishTime[3][FCastSpellName])
	
--order Now->0->1->2->3->5delete
--keep only Fireball,Phoenix Flames,Pyroblast (spell that has travel time + trigger "Heating up"	
--[[	if (IROSpecID==63)and(subevent=="SPELL_CAST_START") then
		loadVal(...)
		if (spellName=="Fireball")or(spellName=="Pyroblast") then
			FireCastFinishTime[3]=FireCastFinishTime[2]
			FireCastFinishTime[2]=FireCastFinishTime[1]
			FireCastFinishTime[1]=FireCastFinishTime[0]
			--FTarGUID = 0,FTarRange = 1,FCastFinish = 2
			FireCastFinishTime[0][FTarGUID]=UnitGUID("target")
			FireCastFinishTime[0][FTarRange]=rc:GetRange('target')
			FireCastFinishTime[0][FCastFinish]=select(5,UnitCastingInfo("player"))/1000
			FireCastFinishTime[0][FCastSpellName] = spellName
			print(FireCastFinishTime[0][FCastFinish])
			print(FireCastFinishTime[0][FTarRange])
			print(FireCastFinishTime[0][FTarGUID])
			print(FireCastFinishTime[0][FCastSpellName])
		end
	end	
	--********** FIRE MAGE END ************
--]]
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
		--local currentSpec = GetSpecialization()
		if not IROSpecID then IROSpecID = GetSpecializationInfo(GetSpecialization()) end
		if (IROSpecID >=62) and (IROSpecID <=64) then --62 arcane, 63 fire, 64 frost
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