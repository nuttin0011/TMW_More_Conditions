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
local Old_Val_Check=Env.Old_Val_Check
local Old_Val_Update=Env.Old_Val_Update

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)
-- for mage

local playerGUID
local f = CreateFrame("Frame")
local FlurryTargetGUID = ""
local FlurryTargetTime = 0
local FlurryBuffWinterChillCount = 0
local EbonboltHitTime = 0
local IROSpecID = nil
local function fspecOnEvent(self, event, ...)
	--print(event, ...)
	local spec={[62]="arcane",[63]="fire",[64]="frost"}	
	--print("old Spec :"..spec[IROSpecID])
	IROSpecID = GetSpecializationInfo(GetSpecialization())
	--print("new Spec :"..spec[IROSpecID])
end
local fspec = CreateFrame("Frame")
fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
fspec:SetScript("OnEvent", fspecOnEvent)

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
local isNotProjectileFireSpell = {
	["Scorch"]=true,
	["Fire Blast"]=true,
	["Dragon's Breath"]=true
}
local FireCastFinishTime = {
	[0] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]=nil,[FEstimateHitTime]=0},
	[1] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]=nil,[FEstimateHitTime]=0},
	[2] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]=nil,[FEstimateHitTime]=0},
	[3] = {[FTarGUID]="",[FTarRange]=0,[FCastFinish]=0,[FCastSpellName]=nil,[FEstimateHitTime]=0}
}
local TimeDelayAfterSpellHit = 0

local TimerDelay = 0.4

local CSSpellHitTime=0
local CSSpellHitDelay=1
local CSSpellID=2
local CSSpellRange=3
local CSSpellName=4
local FireCastingSpell={}
-- [0]->[1]->delete
for ii=0,1 do
	FireCastingSpell[ii]={}
	for ii2=0,4 do
		FireCastingSpell[ii][ii2]=nil
	end
end
--Check Save Zone for Heating up?
--1 currentTime < all FEstimateHitTime (from projectile)
--2 if Spell that generater Heating up Hit --> set TimeDelayAfterSpellHit=currentTime+abitdealy(~0.1-0.2)
--	and  (currentTime > TimeDelayAfterSpellHit) and all projectile hited!
--3 UnitCastingInfo("player") --> currentTime < EstimateHitTime-0.2 (from Casting spell)
--	and if this spell goto projectile recalculate it


local function checkFlurryTimer()
	local currentTime = GetTime()
	if (FlurryBuffWinterChillCount>0 )and (FlurryTargetTime<currentTime) then
		FlurryBuffWinterChillCount=0
		FlurryTargetGUID=""
	end
end

local function predictFireSpellhittime(timeCastFinish,targetRange)
	timeCastFinish = timeCastFinish or 0
	targetRange = targetRange or 0
	local timeMod = 0
	--fire ball travel time >20 yard = 0.7+-0.1 sec
	--fire ball travel time 15-20 yard = 0.45+-0.1 sec
	--fire ball travel time 10-15 yard = 0.3+-0.1 sec
	--fire ball travel time 5-10 yard = 0.2+-0.1 sec	
	--fire ball travel time 2-5 yard = 0.15+-0.1 sec
	--fire ball travel time <2 yard = 0 sec
	if targetRange>20 then timeMod =0.5
	elseif targetRange>=15 then timeMod =0.3
	elseif targetRange>=10 then timeMod =0
	elseif targetRange>=5 then timeMod =0
	else timeMod=0 end
	--print(timeCastFinish.."+"..timeMod)
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
	if (IROSpecID==64) then checkFlurryTimer()end	
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
	if IROSpecID==63 then

		if (subevent=="SPELL_CAST_SUCCESS") then
			loadVal(...)
			if (isProjectileFireSpell[spellName]==true) then

				for ii=3,1,-1 do 
					for ii2=0,4 do
						FireCastFinishTime[ii][ii2]=FireCastFinishTime[ii-1][ii2]
					end
				end
				FireCastFinishTime[0][FTarGUID]=destGUID
				FireCastFinishTime[0][FTarRange]=rc:GetRange('target')
				FireCastFinishTime[0][FCastFinish]=currentTime
				FireCastFinishTime[0][FCastSpellName]=spellName
				FireCastFinishTime[0][FEstimateHitTime]=predictFireSpellhittime(currentTime,FireCastFinishTime[0][FTarRange])
				--print("[0]"..FireCastFinishTime[0][FEstimateHitTime])
				--for ii=0,3 do
				--	if FireCastFinishTime[ii][FEstimateHitTime]>0 then
				--		print(ii..":"..FireCastFinishTime[ii][FCastSpellName])
				--	end
				--end

			end
		end
		local ccc=0
		if (subevent=="SPELL_DAMAGE") then
			loadVal(...)
			if isProjectileFireSpell[spellName] then
				for ii=3,0,-1 do
					if (FireCastFinishTime[ii][FCastSpellName]==spellName) then
						FireCastFinishTime[ii][FCastSpellName]=nil
						--print(currentTime-FireCastFinishTime[ii][FEstimateHitTime])
						FireCastFinishTime[ii][FEstimateHitTime]=0
						TimeDelayAfterSpellHit = currentTime+TimerDelay
						break
					end
				end		
			elseif isNotProjectileFireSpell[spellName] then
				TimeDelayAfterSpellHit = currentTime+TimerDelay
			end
			for ii=1,0,-1 do
				if FireCastingSpell[ii][CSSpellName]==spellName then
					FireCastingSpell[ii][CSSpellID]=nil
				end
			end
		end
		if (subevent=="SPELL_CAST_FAILED") then
			loadVal(...)
			for ii=1,0,-1 do
				if FireCastingSpell[ii][CSSpellName]==spellName then
					FireCastingSpell[ii][CSSpellID]=nil
				end
			end			
		end
	end	
	--for ii=0 , 3 do
	--if isProjectileFireSpell[FireCastFinishTime[ii][FCastSpellName]] then ccc=ccc+1 end end
	--print(ccc)			
	
--order Now->0->1->2->3->delete
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
local function InitMageCombatEvent()
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

	if (not initFunctionSeted) then InitMageCombatEvent() end
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

function TMW_MC:PredictCanCheckHotstreak()
	if (not initFunctionSeted) then InitMageCombatEvent() end
	local oldval = Old_Val_Check("PredictCanCheckHotstreak","")
	if oldval then return oldval end

	local currentTime=GetTime()
	local name,_,_,startTimeMS,endTimeMS,_,castID=UnitCastingInfo("player")
	local targetRange=rc:GetRange('target')

	if name then
		if (FireCastingSpell[0][CSSpellID]~=castID)and(FireCastingSpell[1][CSSpellID]~=castID) then
			if (isNotProjectileFireSpell[name] or (isProjectileFireSpell[name] and (targetRange<=5))) then
				for ii=0,4 do
					FireCastingSpell[1][ii]=FireCastingSpell[0][ii]
				end
				if isNotProjectileFireSpell[name] then 
					FireCastingSpell[0][CSSpellHitTime]=(endTimeMS/1000)-0.2
					FireCastingSpell[0][CSSpellHitDelay]=FireCastingSpell[0][CSSpellHitTime]+0.3
					FireCastingSpell[0][CSSpellID]=castID
					FireCastingSpell[0][CSSpellRange]=0
					FireCastingSpell[0][CSSpellName]=name
				else
					FireCastingSpell[0][CSSpellHitTime]=(endTimeMS/1000)-0.2
					FireCastingSpell[0][CSSpellHitDelay]=FireCastingSpell[0][CSSpellHitTime]+0.3
					FireCastingSpell[0][CSSpellID]=castID
					FireCastingSpell[0][CSSpellRange]=targetRange
					FireCastingSpell[0][CSSpellName]=name
				end
			end
		else
			if (FireCastingSpell[0][CSSpellID]==castID) then
				if(isProjectileFireSpell[name])and(targetRange>5) then
					FireCastingSpell[0][CSSpellID]=nil
				end
			elseif (FireCastingSpell[1][CSSpellID]==castID) then
				if(isProjectileFireSpell[name])and(targetRange>5) then
					FireCastingSpell[1][CSSpellID]=nil
				end
			end
		end
	end
	for ii=0,1 do
		if FireCastingSpell[ii][CSSpellID] 
		and (currentTime>= FireCastingSpell[ii][CSSpellHitTime])
		and (currentTime< FireCastingSpell[ii][CSSpellHitDelay]) then
			Old_Val_Update("PredictCanCheckHotstreak","",false)
			return false
		end
	end

	local foundProjectile=false
	for ii=0,3 do
		if FireCastFinishTime[ii][FCastSpellName] then
			if (currentTime>FireCastFinishTime[ii][FEstimateHitTime]) then
				Old_Val_Update("PredictCanCheckHotstreak","",false)
				return false
			end
			foundProjectile=true
		end
	end
	if (currentTime<TimeDelayAfterSpellHit)and(not foundProjectile) then
		Old_Val_Update("PredictCanCheckHotstreak","",false)
		return false 
	end

	Old_Val_Update("PredictCanCheckHotstreak","",true)
	return true
end

Env.PredictCanCheckHotstreak = function()
	return TMW_MC:PredictCanCheckHotstreak()
end

ConditionCategory:RegisterCondition(9.5,  "TMWMCPREDICTHOTSTREAK", {
	text = "Predict Time to check Hot Streak",
	tooltip = "this is save time to check Hot Streak (no Fire Projectile hit soon)",
	unit="Player",
	step = 1,
	min = 0,
	max =1,
	bool = true,
	texttable = {
		[0] = "Can Check NOW!",
		[1] = "Cannot Check NOW!",
	},

    icon = "Interface\\Icons\\ability_mage_hotstreak",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		if c.Level==0 then
			return [[PredictCanCheckHotstreak()]]
		else
			return [[not PredictCanCheckHotstreak()]]
		end
		
    end,
})