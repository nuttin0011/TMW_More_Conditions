-- Many Function Version Warlock 9.0.5/23
-- Set Priority to 20
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Lock.Pet(PetType) return true/false
----PetType 1=Felg 2=Succ 4=Felh 8=Voidw 16=Imp can use 3 for check felg+succ
--function IROVar.Lock.PredictSS() return SSFragment / 10 SSFragment = 1 SS
--function IROVar.Lock.GetWildImpCount(FelFireboltRemainAtLeast) ; return wild imp
--IROVar.Lock.GetWildImpCountTimePass(t) ; return impCount when t sec passed
--function IROVar.Lock.GetHoGActiveCount(timePass) ; return HoG active count when t sec passed
-- var IROVar.Lock.GUIDImmolate ; Check not cast same GUID target
-- var IROVar.Lock.Infernal.Count ; = count infernal in Des spec
-- 	use /run IROVar.Lock.GUIDImmolate=UnitGUID("target") after use macro cast immolate
-- 	use /run IROVar.Lock.GUIDSpell=UnitGUID("target") after use macro cast spell
-- var IROVar.Lock.HavocGUID ; keep HavocGUID
-- function IROVar.Lock.HasHavoc() -- return UnitGUID , or nil
-- var IROVar.Lock.HavocCDEnd() ; return HavocCD end time
-- function IROVar.GetDemonicCoreStack() -- return stack of Demonic Core
-- function IROVar.GetDemonicCoreExpireTime() -- return time of Demonic Core expire
--IROVar.Lock.FromtheShadows.Count ; = count from the shadow
--IROVar.Lock.FromtheShadows.ExpireTime ; = time of from the shadow expire
--function IROVar.GetDSCDEnd() -- return time of CD Dread stalkers end
--function IROVar.GetTyrantCDEnd() -- return time of CD Tyrant end
--IROVar.Lock.EradicationChange -- Check Change of Eradication
--IROVar.Lock.EradicationTargetAuraEnd() -- Check Aura end of target
--var IROVar.Lock.CBCount ; count chaos bolt ; IROVar.Lock.CBCount_Old = 0
--var IROVar.Lock.CBHCount ; count chaos bolt in Havoc ; IROVar.Lock.CBHCount_Old = 0
--function IROVar.Lock.TimeToNeed2ndConflag(r)
--function IROVar.Lock.ConflagChargeTime()
--function IROVar.Lock.CDConflagTwoCharge()
--function IROVar.Lock.PredictSS_ByTime_Des(totalTime,tIdle)
--function IROVar.Lock.PredictSSGen_ByTime_Des(totalTime,tIdle)
--function IROVar.Lock.GetSSFromInfernal(t)
--function IROVar.Lock.GetSSFromImmolate(t)
--var IROVar.Lock.CurrentCast = CurrentCast
--var IROVar.Lock.DemonicCallingBuff = DemonicCallingBuff
--var IROVar.Lock.DemonicCallingTimeOut = DemonicCallingTimeOut
--[[ NOTE:
GetSpellCount("Implosion") ;Implosion Stack
UnitPower("player",7) ; SoulShards
UnitPower("player",7,true) ; SSFragment
]]

--IROVar.Lock.NetherPortal.Up=true
--IROVar.Lock.NetherPortal.Time=GetTime()
--function IROVar.Lock.NetherPortal.Duration()
--IROVar.Lock.JustHoG ; HoG recenly casted

if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end

IROVar.Lock.NetherPortal={}
IROVar.Lock.NetherPortal.Up=false
IROVar.Lock.NetherPortal.Time=0
IROVar.Lock.CurrentCast=nil
IROVar.Lock.PetActive=nil
IROVar.Lock.playerGUID=UnitGUID("player")
IROVar.Lock.SS={}
IROVar.Lock.DemonicCoreStack=0
IROVar.Lock.DemonicCoreExpireTime=0
IROVar.Lock.DemonicCallingBuff=false
IROVar.Lock.FromtheShadows={}
IROVar.Lock.FromtheShadows.Count=0
IROVar.Lock.FromtheShadows.ExpireTime=0
IROVar.RegisterIncombatCallBackRun("ResetFTS",function()
	IROVar.Lock.FromtheShadows.Count=0
end)
IROVar.Lock.CBCount=0
IROVar.Lock.CBCount_Old=0
IROVar.Lock.CBHCount=0
IROVar.Lock.CBHCount_Old=0
IROVar.Lock.HavocTimeStamp=GetTime()
IROVar.Lock.SS.LockSpellModSS = {
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

--[[ not use now
IROVar.Lock.SS.JustUpdateSS=false
IROVar.Lock.SS.JustUpdateSSHandle=nil
function IROVar.Lock.SS.UpdateJustUpdateSS()
	if not IROVar.Lock.SS.JustUpdateSSHandle then
		IROVar.Lock.SS.JustUpdateSS=true
		IROVar.Lock.SS.JustUpdateSSHandle=C_Timer.NewTimer(IROVar.CastTime0_5sec,function()
			IROVar.Lock.SS.JustUpdateSS=false
			IROVar.Lock.SS.JustUpdateSSHandle=nil
		end)
	end
end
IROVar.Lock.SS.FSSUpdateEvent=CreateFrame("Frame")
IROVar.Lock.SS.FSSUpdateEvent:RegisterEvent("UNIT_POWER_UPDATE")
IROVar.Lock.SS.FSSUpdateEvent:RegisterEvent("UNIT_POWER_FREQUENT")
IROVar.Lock.SS.FSSUpdateEvent:SetScript("OnEvent",function(self,event,unit,powertype)
	if unit~="player" or powertype~="SOUL_SHARDS" then return end
	IROVar.Lock.SS.UpdateJustUpdateSS()
end)
]]

function IROVar.Lock.NetherPortal.Duration()
	if not IROVar.Lock.NetherPortal.Up then return 0 end
	return GetTime()-IROVar.Lock.NetherPortal.Time
end


IROVar.Lock.EradicationChange=0

local function CDend(s)
	local st,du=GetSpellCooldown(s)
	if st then
		return st+du
	else return 0 end
end

function IROVar.FixDemonicCoreStack()
	local name, _, count=AuraUtil.FindAuraByName("Demonic Core", "player", "PLAYER HELPFUL")
	if name then
		IROVar.Lock.DemonicCoreStack=count
	else
		IROVar.Lock.DemonicCoreStack=0
	end
end
C_Timer.NewTicker(3.2,IROVar.FixDemonicCoreStack)

function IROVar.GetDemonicCoreStack()
	return IROVar.Lock.DemonicCoreStack
end

function IROVar.GetDemonicCoreExpireTime()
	return IROVar.Lock.DemonicCoreExpireTime
end

IROVar.Lock.DSCDEnd=0
IROVar.Lock.TyrantCDEnd=0

function IROVar.GetDSCDEnd()
	return IROVar.Lock.DSCDEnd
end
function IROVar.GetTyrantCDEnd()
	return IROVar.Lock.TyrantCDEnd
end

IROVar.Lock.DreadstalkerTime=0
IROVar.Lock.VilefiendTime=0
IROVar.Lock.Imp={}
IROVar.Lock.Imp.FreezEn=false
IROVar.Lock.Imp.FreezEnTime=0
IROVar.Lock.Imp.count=0
IROVar.Lock.Imp.spawn={}


--[[
	IROVar.Lock.Imp.spawn = {
		["Creature-0-3766-blablabla"]={
			FelFireboltCount=6
			SpawnTime=2993.546
		}
	}
	****Imp Despawn when cass FelFirebolt 6 times or 21 sec pass
	Event Spawn = COMBAT_LOG_EVENT_UNFILTERED
	Sub event = SPELL_SUMMON
	GUID = playerGUID
	targetGUID = ImpGUID
	spell name = Wild Imp

	Event Shoot FF = COMBAT_LOG_EVENT_UNFILTERED
	Sub event = SPELL_CAST_SUCCESS
	GUID = Imp GUID
	spell name = Fel Firebolt
]]
IROVar.Lock.Infernal={}
IROVar.Lock.Infernal.NextInfernalIs30sec=false
IROVar.Lock.Infernal.Count=0

IROVar.Lock.PetCheckedTime=0
IROVar.Lock.PetCheckTimer=6 --ll check 6 sec for sure
IROVar.Lock.PetActiveOldVal=-1
IROVar.Lock.JustRunPetCheck=0
IROVar.Lock.HavocGUID = nil
IROVar.Lock.HavocCDEndTime = 0
IROVar.Lock.ImmolateChange=-1

IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("HavocCD",function(GCDEnd)
	if IROSpecID==267 then --Des Spec
		IROVar.Lock.HavocCDEndTime = CDend("Havoc")
		if IROVar.Lock.HavocCDEndTime<=GCDEnd then
			IROVar.Lock.HavocCDEndTime=0
		end
	end
end)

function IROVar.Lock.HavocCDEnd()
	return IROVar.Lock.HavocCDEndTime
end


function IROVar.Lock.HasHavoc() -- return UnitGUID , TimeStamp or nil
	return IROVar.Lock.HavocGUID,IROVar.Lock.HavocTimeStamp
end

function IROVar.Lock.Pet(PetType)
    PetType=PetType or 0
    if IROVar.Lock.PetActive then
		if IROVar.Lock.PetActive~=128 then
			return bit.band(IROVar.Lock.PetActive,PetType)~=0
		else
			return UnitExists("pet") and (not UnitIsDead("pet"))
		end
	end
    IROVar.Lock.SetupPetEvent()
    return IROVar.Lock.Pet(PetType)
end
IROVar.Lock.PetTypeBit={
	["Felguard"]=1,["Succubus"]=2,["Felhunter"]=4,
	["Voidwalker"]=8,["Imp"]=16,
	["Wrathguard"]=1,["Shivarra"]=2,["Observer"]=4,
	["Voidlord"]=8,["Fel Imp"]=16,["Incubus"]=2,
	--nil=128
}
function IROVar.Lock.SetupPetEvent()
	function IROVar.Lock.CheckPet()
		local currentTime=GetTime()
		if (currentTime-IROVar.Lock.JustRunPetCheck)<0.05 then return end
		IROVar.Lock.JustRunPetCheck=currentTime
		if currentTime<IROVar.Lock.PetCheckedTime+IROVar.Lock.PetCheckTimer then
			IROVar.Lock.PetActive=0
			if UnitExists("pet") and (not UnitIsDead("pet")) then
				local PetFamily = UnitCreatureFamily("pet")
				IROVar.Lock.PetActive=IROVar.Lock.PetTypeBit[PetFamily] or 0
			else
				IROVar.Lock.PetActive=128
			end
			if IROVar.Lock.PetActive~=IROVar.Lock.PetActiveOldVal then
				IROVar.Lock.PetCheckedTime=currentTime
				IROVar.Lock.PetActiveOldVal=IROVar.Lock.PetActive
			end
			C_Timer.After(0.2,IROVar.Lock.CheckPet)
		end
	end
    IROVar.Lock.PetEvent=CreateFrame("Frame")
    IROVar.Lock.PetEvent:RegisterEvent("UNIT_PET")
    IROVar.Lock.PetEvent:SetScript("OnEvent", function()
		IROVar.Lock.PetCheckedTime=GetTime()
		IROVar.Lock.CheckPet()
	end)
	IROVar.Lock.PetCheckedTime=GetTime()
	IROVar.Lock.CheckPet()
end

function IROVar.Lock.CheckImpExpire()
	local currentTime=GetTime()
	for k,v in pairs(IROVar.Lock.Imp.spawn) do
		if (currentTime-v.SpawnTime)>21 then
			IROVar.Lock.Imp.spawn[k]=nil
			IROVar.Lock.Imp.count=IROVar.Lock.Imp.count-1
		end
	end
end

IROVar.Lock.InternalExpireTime={}
function IROVar.Lock.PushInternalExpireTime(time)
	--big to small
	local N=#IROVar.Lock.InternalExpireTime+1
	for i=1, #IROVar.Lock.InternalExpireTime do
		if time>IROVar.Lock.InternalExpireTime[i] then
			N=i
			break
		end
	end
	table.insert(IROVar.Lock.InternalExpireTime,N,time)
end


function IROVar.Lock.COMBAT_LOG_EVENT_UNFILTERED_OnEvent(...)
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = ...
    if (sourceGUID==IROVar.Lock.playerGUID) and (subevent=="SPELL_CAST_FAILED") then
		IROVar.Lock.SS.trust_segment_cast = true
	end
	if (sourceGUID==IROVar.Lock.playerGUID) and (subevent=="SPELL_CAST_SUCCESS") and IROVar.Lock.JustStage4 then
		-- use to chesk Interrupt Shadow Bolt at Stage 4
		-- 1st cast SB dont interrupt
		IROVar.Lock.JustStage4=false
	end
	if IROSpecID==267 then -- Des spec
		if (sourceGUID==IROVar.Lock.playerGUID) then
			--keep Havoc GUID
			if (subevent=="SPELL_CAST_SUCCESS")and(spellName=="Havoc") then
				IROVar.Lock.HavocGUID=DesGUID
				IROVar.Lock.HavocTimeStamp=GetTime()
				C_Timer.After(12,function() IROVar.Lock.HavocGUID=nil end)
			end
			--count infernal
			if (subevent=="SPELL_CAST_SUCCESS")and(spellName=="Summon Infernal") then
				IROVar.Lock.Infernal.NextInfernalIs30sec=true
			end
			if (subevent=="SPELL_SUMMON")and(spellName=="Summon Infernal" or spellName=="Blasphemy") then
				IROVar.Lock.Infernal.Count=IROVar.Lock.Infernal.Count+1
				local infernalTimer = IROVar.Lock.Infernal.NextInfernalIs30sec and 30 or (spellName=="Blasphemy" and 8 or 10)
				IROVar.Lock.Infernal.NextInfernalIs30sec=false
				IROVar.Lock.PushInternalExpireTime(infernalTimer+GetTime())
				C_Timer.After(infernalTimer,function() IROVar.Lock.Infernal.Count=IROVar.Lock.Infernal.Count-1 end)
			end
			if spellName=="Eradication" then
				IROVar.Lock.EradicationChange=IROVar.Lock.EradicationChange+1
			end
			if (subevent=="SPELL_CAST_SUCCESS")and(spellName=="Immolate") then
				IROVar.Lock.ImmolateChange=IROVar.Lock.ImmolateChange+1
			end
			if (subevent=="SPELL_CAST_SUCCESS")and(spellName=="Chaos Bolt") then
				IROVar.Lock.CBCount=IROVar.Lock.CBCount+1
				if IROVar.Lock.HasHavoc() then
					IROVar.Lock.CBHCount=IROVar.Lock.CBHCount+1
				end
			end
		end
	end

	if IROSpecID==266 then -- Demo Sepc
		if (sourceGUID==IROVar.Lock.playerGUID) then
			if (subevent=="SPELL_SUMMON") then
				if (DesName=="Wild Imp") then
					local ImpSpawnTime=GetTime()
					if IROVar.Lock.Imp.FreezEn then -- FreezEN=buff Demonic Power
						ImpSpawnTime=15+IROVar.Lock.Imp.FreezEnTime
					end
					IROVar.Lock.Imp.spawn[DesGUID]={
						FelFireboltCount=6,
						SpawnTime=ImpSpawnTime,
						ExpireTimeHandel=C_Timer.NewTimer(21,IROVar.Lock.CheckImpExpire),
						PredictDespawnTime=GetTime()+IROVar.CastTime2sec*6
					}
					IROVar.Lock.Imp.count=IROVar.Lock.Imp.count+1
				elseif DesName=="Dreadstalker" then
					IROVar.Lock.DreadstalkerTime=GetTime()
				elseif DesName=="Vilefiend" then
					IROVar.Lock.VilefiendTime=GetTime()
				end
			elseif subevent=="SPELL_CAST_SUCCESS" then
				if spellID==196277 then--Implosion
					for _,v in pairs(IROVar.Lock.Imp.spawn) do
						v.ExpireTimeHandel:Cancel()
					end
					IROVar.Lock.Imp.spawn={}
					IROVar.Lock.Imp.count=0
				elseif spellID==267217 then --Nether Portal
					IROVar.Lock.NetherPortal.Up=true
					IROVar.Lock.NetherPortal.Time=GetTime()
					C_Timer.After(15,function() IROVar.Lock.NetherPortal.Up=false end)
				elseif spellID==105174 then -- hand of gudal
					IROVar.Lock.JustHoG=true
					C_Timer.After(0.4,function() IROVar.Lock.JustHoG=false end)
				end
			elseif spellID==265273 then --buff Demonic Power
				if subevent=="SPELL_AURA_APPLIED" then --buff Demonic Power
				IROVar.Lock.Imp.FreezEn=true
				IROVar.Lock.Imp.FreezEnTime=GetTime()
				for _,v in pairs(IROVar.Lock.Imp.spawn) do
					v.SpawnTime=v.SpawnTime+15
				end
				elseif subevent=="SPELL_AURA_REMOVED" then --buff Demonic Power
					IROVar.Lock.Imp.FreezEn=false
					--C_Timer.After(1,function() IROVar.Lock.Imp.FreezEn=false end)
				end
			elseif spellID==264173 then --buff Demonic Core
				if subevent=="SPELL_AURA_APPLIED" then --buff Demonic Core
					IROVar.Lock.DemonicCoreStack=1
					IROVar.Lock.DemonicCoreExpireTime=GetTime()+20
				elseif subevent=="SPELL_AURA_REMOVED" then
					IROVar.Lock.DemonicCoreStack=0
					IROVar.Lock.DemonicCoreExpireTime=0
				elseif subevent=="SPELL_AURA_APPLIED_DOSE" then
					IROVar.Lock.DemonicCoreStack=IROVar.Lock.DemonicCoreStack+1
					if IROVar.Lock.DemonicCoreStack>4 then
						IROVar.Lock.DemonicCoreStack=4
					end
					IROVar.Lock.DemonicCoreExpireTime=GetTime()+20
				elseif subevent=="SPELL_AURA_REMOVED_DOSE" then
					IROVar.Lock.DemonicCoreStack=IROVar.Lock.DemonicCoreStack-1
				end
			elseif spellID==270569 then -- Debuff "From the Shadows"
				if subevent=="SPELL_AURA_APPLIED" then
					IROVar.Lock.FromtheShadows.Count=IROVar.Lock.FromtheShadows.Count+1
					IROVar.Lock.FromtheShadows.ExpireTime=GetTime()+12
				elseif subevent=="SPELL_AURA_REMOVED" then
					IROVar.Lock.FromtheShadows.Count=IROVar.Lock.FromtheShadows.Count-1
					IROVar.Lock.FromtheShadows.ExpireTime=0
				elseif subevent=="SPELL_AURA_REFRESH" then
					IROVar.Lock.FromtheShadows.ExpireTime=GetTime()+12
				end
			elseif spellID==205146 then--Buff Demonic Calling
				if subevent=="SPELL_AURA_APPLIED" then
					IROVar.Lock.DemonicCallingBuff=true
					IROVar.Lock.DemonicCallingTimeOut=GetTime()+20
				elseif subevent=="SPELL_AURA_REMOVED" then
					IROVar.Lock.DemonicCallingBuff=false
				elseif subevent=="SPELL_AURA_REFRESH" then
					IROVar.Lock.DemonicCallingBuff=true
					IROVar.Lock.DemonicCallingTimeOut=GetTime()+20
				end
			end

		end
		if (not IROVar.Lock.Imp.FreezEn) and IROVar.Lock.Imp.spawn[sourceGUID] and (subevent=="SPELL_CAST_SUCCESS") and (spellID==104318) then --Fel Firebolt
			IROVar.Lock.Imp.spawn[sourceGUID].FelFireboltCount=IROVar.Lock.Imp.spawn[sourceGUID].FelFireboltCount-1
			if IROVar.Lock.Imp.spawn[sourceGUID].FelFireboltCount==0 then
				IROVar.Lock.Imp.spawn[sourceGUID].ExpireTimeHandel:Cancel()
				IROVar.Lock.Imp.spawn[sourceGUID]=nil
				IROVar.Lock.Imp.count=IROVar.Lock.Imp.count-1
			end
		end
		if IROVar.Lock.Imp.spawn[sourceGUID] and (subevent=="SPELL_CAST_START") and (spellID==104318) then --imp Start Cast Fel Firebolt
			local currentTime=GetTime()
			IROVar.Lock.Imp.spawn[sourceGUID].SPELL_CAST_START=currentTime
			IROVar.Lock.Imp.spawn[sourceGUID].PredictDespawnTime=currentTime+(IROVar.CastTime2sec*IROVar.Lock.Imp.spawn[sourceGUID].FelFireboltCount)
		end
	end
end

function IROVar.Lock.GetWildImpCount(FelFireboltRemainAtLeast)
	if IROVar.Lock.Imp.count==0 then return 0 end
	FelFireboltRemainAtLeast=FelFireboltRemainAtLeast or 0
	local ImpCount=IROVar.Lock.Imp.count
	if FelFireboltRemainAtLeast>=2 then
		for _,v in pairs(IROVar.Lock.Imp.spawn) do
			if v.FelFireboltCount<FelFireboltRemainAtLeast then
				ImpCount=ImpCount-1
			end
		end
	end
	return ImpCount
end

function IROVar.Lock.GetWildImpCountTimePass(t)
	-- cannot use when tyrant summoned
	-- use only prepair summon tyrant
	local timeCompare=GetTime()+t
	local ImpCount=0
	for _,v in pairs(IROVar.Lock.Imp.spawn) do
		if v.PredictDespawnTime>timeCompare then
			ImpCount=ImpCount+1
		end
	end
	return ImpCount
end


IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("warlock",IROVar.Lock.COMBAT_LOG_EVENT_UNFILTERED_OnEvent)
IROVar.Lock.SS.trust_segment_cast=true
IROVar.Lock.SS.old_timer_check=0
IROVar.Lock.SS.old_val=0

function IROVar.Lock.PredictSS()
	-- if (trust_segment_cast == Ture) Must Recalculate
	-- if (trust_segment_cast == False) Must Use old_val
	local currentTime = GetTime()
	if IROVar.Lock.SS.old_timer_check == currentTime then
		return IROVar.Lock.SS.old_val
	end
	if (not IROVar.Lock.SS.trust_segment_cast) then
		if (currentTime>(IROVar.Lock.SS.old_spell_finish_cast_check or 0)) then
			IROVar.Lock.SS.trust_segment_cast = true
		else
			return IROVar.Lock.SS.old_val
		end
	end
	if not IROSpecID then IROSpecID = GetSpecializationInfo(GetSpecialization()) end
	local currentSS = UnitPower("player",7,true)
	local spellName,_,_, startTimeMS, endTimeMS = UnitCastingInfo("player")
	if spellName then
		local endTime = endTimeMS/1000
		local timeUnitlCastFinish = endTime-currentTime
		-- if > 6/10 of spell cast bar ?
		-- trust_segment_cast = 0.6>((currentTime*1000)-startTimeMS)/(endTimeMS-startTimeMS)
		-- if spell < 0.3 sec befor finish casting
		IROVar.Lock.SS.trust_segment_cast = (timeUnitlCastFinish)>0.3
		if IROVar.Lock.SS.trust_segment_cast then
			local extraSSfromInfernal = IROVar.Lock.Infernal.Count*ceil(timeUnitlCastFinish/0.5)
			currentSS=currentSS+extraSSfromInfernal
			if spellName == "Incinerate" then
				-- check Havoc for double SS generate
				local unitHavoc,havocStamp = IROVar.Lock.HasHavoc()
				if unitHavoc and (12-(currentTime-havocStamp)>0.1+timeUnitlCastFinish) then
					currentSS = currentSS + 4
				else
					currentSS = currentSS + 2
				end
			else
				currentSS = currentSS+(IROVar.Lock.SS.LockSpellModSS[spellName..IROSpecID] or 0)
			end
			currentSS = (currentSS<=50)and currentSS or 50
			currentSS = (currentSS>=0)and currentSS or 0
			IROVar.Lock.SS.old_spell_finish_cast_check = endTime+0.2
		else
			return IROVar.Lock.SS.old_val
		end
	end
	IROVar.Lock.SS.old_timer_check = currentTime
	IROVar.Lock.SS.old_val = currentSS
	return currentSS
end

IROVar.Lock.GUIDImmolate = nil
IROVar.Lock.GUIDImmolate_Old = nil
IROVar.Lock.GUIDSpell = nil
IROVar.Lock.GUIDSpell_Old = nil

function IROVar.Lock.GUIDImmolate_OnEvent(self,Event,Unit,CastID,SpellID)
	if (Unit ~= "player") then return end -- if not player return
	if (SpellID == 348) -- Immolate
	--and (IROSpecID == 267) -- Destruction .... Immolate Should Des by default??
	then
		if Event == "UNIT_SPELLCAST_START" then
			IROVar.Lock.GUIDImmolate_Old=IROVar.Lock.GUIDImmolate
		elseif Event == "UNIT_SPELLCAST_STOP" then
			if IROVar.Lock.GUIDImmolate_Old==IROVar.Lock.GUIDImmolate then
				IROVar.Lock.GUIDImmolate=nil
			end
		end
	end
	-- other spell included Immolate
	if Event == "UNIT_SPELLCAST_START" then
		IROVar.Lock.GUIDSpell_Old=IROVar.Lock.GUIDSpell
	elseif Event == "UNIT_SPELLCAST_STOP" then
		if IROVar.Lock.GUIDSpell_Old==IROVar.Lock.GUIDSpell then
			IROVar.Lock.GUIDSpell=nil
		end
	end
end
IROVar.Lock.GUIDImmolate_Frame = CreateFrame("Frame")
IROVar.Lock.GUIDImmolate_Frame:RegisterEvent("UNIT_SPELLCAST_START")
IROVar.Lock.GUIDImmolate_Frame:RegisterEvent("UNIT_SPELLCAST_STOP")
IROVar.Lock.GUIDImmolate_Frame:SetScript("OnEvent", IROVar.Lock.GUIDImmolate_OnEvent)

function IROVar.Lock.IsHavocLongerThanCB()
	local unitHavoc,havocDu = IROVar.Lock.HasHavoc()
	if not unitHavoc then return false end
	local CBCastime=(select(4,GetSpellInfo("chaos bolt")) or math.huge)/1000
	return (havocDu-CBCastime)>0.3
end

IROVar.Lock.ConflagCD_Old_Value={
	[1]=2,[2]=2,[3]=GetTime(),[4]=10,[5]=1,
}
IROVar.Lock.Conflag2ChargeCDEnd=GetTime()

function IROVar.Lock.SPELL_UPDATE_COOLDOWN_Event(GCDEnd)
	if IROSpecID==266 then -- Demo Sepc
		local dSCDEnd=CDend("Call Dreadstalkers")
		local tyrantCDEnd=CDend("Summon Demonic Tyrant")
		if GCDEnd>0 then
			if dSCDEnd>0 and GCDEnd>=dSCDEnd then
				dSCDEnd=0
			end
			if tyrantCDEnd>0 and GCDEnd>=tyrantCDEnd then
				tyrantCDEnd=0
			end
		end
		IROVar.Lock.DSCDEnd=dSCDEnd
		IROVar.Lock.TyrantCDEnd=tyrantCDEnd
	elseif IROSpecID==267 then -- Des Spec
		IROVar.Lock.ConflagCD_Old_Value={GetSpellCharges("Conflagrate")}
		local c,m,s,d = unpack(IROVar.Lock.ConflagCD_Old_Value)
		if c==m then IROVar.Lock.Conflag2ChargeCDEnd=0 else
			IROVar.Lock.Conflag2ChargeCDEnd=((m-c-1)*d)+(s+d)
		end
	end
end

IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("LockDemo",IROVar.Lock.SPELL_UPDATE_COOLDOWN_Event)

IROVar.Lock.PLAYER_TARGET_CHANGED_frame=CreateFrame("Frame")
IROVar.Lock.PLAYER_TARGET_CHANGED_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
IROVar.Lock.PLAYER_TARGET_CHANGED_frame:SetScript("OnEvent", function()
	IROVar.Lock.EradicationChange=IROVar.Lock.EradicationChange+1
end)

IROVar.Lock.CURRENT_SPELL_CAST_CHANGED_frame=CreateFrame("Frame")
IROVar.Lock.CURRENT_SPELL_CAST_CHANGED_frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
IROVar.Lock.CURRENT_SPELL_CAST_CHANGED_frame:SetScript("OnEvent", function()
	IROVar.Lock.CurrentCast=select(1,UnitCastingInfo("player"))
end)

IROVar.Lock.Eradication_Old_Value=0
IROVar.Lock.Eradication_Old_Value_Change=0

function IROVar.Lock.EradicationTargetAuraEnd()
	if IROVar.Lock.Eradication_Old_Value_Change==IROVar.Lock.EradicationChange then
		return IROVar.Lock.Eradication_Old_Value
	end
	IROVar.Lock.Eradication_Old_Value_Change=IROVar.Lock.EradicationChange
	local expire=select(6,AuraUtil.FindAuraByName("Eradication", "target", "PLAYER HARMFUL"))
	if expire then
		IROVar.Lock.Eradication_Old_Value=expire
	else
		IROVar.Lock.Eradication_Old_Value=0
	end
	return IROVar.Lock.Eradication_Old_Value
end

IROVar.FireCri=GetSpellCritChance(3)
IROVar.fCri=CreateFrame("Frame")
IROVar.fCri:RegisterEvent("COMBAT_RATING_UPDATE")
IROVar.fCri:SetScript("OnEvent", function()
    IROVar.FireCri=GetSpellCritChance(3)
end)
--[[
	no Havoc
	input Number of Immolate Immo
	input Number of Infernal Infe
	input average time of Infernal InfeT
	input Conflagrate charges time ConfC

	ss gen
	t sec pass
	cir = 35% = 0.35
	1 incinerate Gen= t/4SGCD * (2+Cri)
	2 Immolate Gen= Immo * t/GCD * Cri/2
	3 Conflag Gen= t/ConfC * 5
	4 Infernal Gen= Infe * t*2 ;  * t/InfeT ; InfeT <= t
	ss=t/4SGCD * (2+Cri) + Immo * t/GCD * Cri/2 + t/ConfC * 5 + Infe * t*2
	ss=t((2+Cri)/4SGCD + Immo/GCD*Cri/2 + 5/ConfC + 2*Infe)
	t=ss / ((2+Cri)/4SGCD + Immo*Cri/2GCD + 5/ConfC + 2*Infe)

	if t>InfeT
	t2 = InfeT
	t3 = t-InfeT
	t4 = t3*(1+2+3+4)/(1+2+3)
	ans = t2+t4
]]
--[[
function IROVar.Lock.PredictTimeToReachSS_DesLock(targetSS) -- return time to target SS (sec)
	local SS=IROVar.Lock.PredictSS()
	--************** Not finish Yet ********************
end]]

IROVar.Lock.ImmolateChange_Old=0
IROVar.Lock.Immolate_TargetEnd=0
IROVar.Lock.Immolate_FocusEnd=0

function IROVar.Lock.GetNImmolate() -- return number of Immolate
	local currentTime=GetTime()
	local N=0
	if IROVar.Lock.ImmolateChange_Old~=IROVar.Lock.ImmolateChange then
		IROVar.Lock.ImmolateChange_Old=IROVar.Lock.ImmolateChange
		IROVar.Lock.Immolate_TargetEnd=select(3,TMW.CNDT.Env.AuraDur("target","immolate","PLAYER HARMFUL"))
		IROVar.Lock.Immolate_FocusEnd=select(3,TMW.CNDT.Env.AuraDur("focus","immolate","PLAYER HARMFUL"))
	end
	N=(IROVar.Lock.Immolate_TargetEnd>currentTime and 1 or 0)+(IROVar.Lock.Immolate_FocusEnd>currentTime and 1 or 0)
	return N
end

function IROVar.Lock.GetSSFromInfernal(t) -- return SS fragment from infernal t sec pass
	if  #IROVar.Lock.InternalExpireTime==0 then return 0 end
	local currentTime=GetTime()
	local SS=0
	local N=#IROVar.Lock.InternalExpireTime
	for i=N,1,-1 do
		if IROVar.Lock.InternalExpireTime[i]<currentTime then
			IROVar.Lock.InternalExpireTime[i]=nil
		else
			local t3=IROVar.Lock.InternalExpireTime[i]-currentTime
			if t3>t then t3=t end
			SS=SS+(t3*2)
		end
	end
	return SS
end

function IROVar.Lock.GetSSFromImmolate(t)
	local Immo=IROVar.Lock.GetNImmolate()
	local Cri=IROVar.FireCri/100
	return Immo*(t/IROVar.CastTime1_5sec)*Cri/2
end

function IROVar.Lock.PredictSSGen_ByTime_Des(totalTime,tIdle) -- predict SS Gen fragment t sec pass ; assume DPSing
	--[[
		totalTime = tDPS+tIdle
		tIdel = Time Idel
		tDPS = Time to assume DPSing
		E.G. time = 10 sec, Cast Cataclysm 2 sec, chaos bolt 3 sec, etc 10 sec
		IROVar.Lock.PredictSS_ByTime_Des(10,5) ; cause Cataclysm+chaos bolt not Gen SS
	]]
		totalTime=totalTime or 0
		if totalTime<=0 then return 0 end
		tIdle=tIdle or 0
		local tDPS=totalTime-tIdle
		if tDPS<0 then tDPS=0 end
		local Cri=IROVar.FireCri/100
		local SSImmo=IROVar.Lock.GetSSFromImmolate(totalTime)
		local SSConflag=math.floor(tDPS/IROVar.Lock.ConflagChargeTime())
		local SSIncinerate=(tDPS-(SSConflag*IROVar.CastTime1_5sec))/(IROVar.CastTime2sec)*(2+Cri)
		SSConflag=SSConflag*5
		local SSInfe=IROVar.Lock.GetSSFromInfernal(totalTime)
		return SSImmo+SSInfe+SSIncinerate+SSConflag
	end

function IROVar.Lock.PredictSS_ByTime_Des(totalTime,tIdle) -- predict SS fragment t sec pass ; assume DPSing
	return IROVar.Lock.PredictSS()+IROVar.Lock.PredictSSGen_ByTime_Des(totalTime,tIdle)
end

function IROVar.Lock.CDConflagTwoCharge()
	local t=IROVar.Lock.Conflag2ChargeCDEnd-GetTime()
	if t<=0 then return 0 end
	return t
end

function IROVar.Lock.ConflagChargeTime()
	return IROVar.Lock.ConflagCD_Old_Value[4] or 10
end
--[[
1)rotation(SGCD) Havoc(3) --> CB(6) --> 1st Conflag(3) --> CB(4.2) --> 2nd Conflag
 = 16.2 GCD after cast Havoc
2)Extented Rotation Havoc(3) --> CB(6) --> CB(6) --> 1st Conflag(3) --> CB(4.2) --> 2nd Conflag
 = 22.2 GCD after cast Havoc
]]
function IROVar.Lock.TimeToNeed2ndConflag(r) -- time to 2nd Conflag conpare to GetTime()
	-- if r == true  mean use Rotation 2 = 22.2 SGCD
	local H=IROVar.Lock.HavocCDEndTime
	local t=(r and 22.2 or 16.2)*IROVar.CastTime0_5sec
	local currentTime=GetTime()
	if H==0 or H<=currentTime then return currentTime+t end
	return H+t
end
