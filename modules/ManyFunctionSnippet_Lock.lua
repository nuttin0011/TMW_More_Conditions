-- Many Function Version Warlock 9.0.5/7
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Lock.Pet(PetType) return true/false
----PetType 1=Felg 2=Succ 4=Felh 8=Voidw 16=Imp can use 3 for check felg+succ
--function IROVar.Lock.PredictSS() return SSFragment / 10 SSFragment = 1 SS
--function IROVar.Lock.GetWildImpCount(FelFireboltRemainAtLeast) ; return wild imp
-- var IROVar.Lock.GUIDImmolate ; Check not cast same GUID target
-- 	use /run IROVar.Lock.GUIDImmolate=UnitGUID("target") after use macro cast immolate
--[[ NOTE
GetSpellCount("Implosion") ;Implosion Stack
UnitPower("player",7) ; SoulShards
UnitPower("player",7,true) ; SSFragment
]]


if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end

IROVar.Lock.PetActive=nil
IROVar.Lock.playerGUID=UnitGUID("player")
IROVar.Lock.SS={}
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

IROVar.Lock.Imp={}
IROVar.Lock.Imp.FreezEn=false
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

IROVar.Lock.PetCheckedTime=0
IROVar.Lock.PetCheckTimer=6 --ll check 6 sec for sure
IROVar.Lock.PetActiveOldVal=-1
IROVar.Lock.JustRunPetCheck=0
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
	["Voidlord"]=8,["Fel Imp"]=16,
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

function IROVar.Lock.COMBAT_LOG_EVENT_UNFILTERED_OnEvent()
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = CombatLogGetCurrentEventInfo()
    if (sourceGUID==IROVar.Lock.playerGUID)  and (subevent=="SPELL_CAST_FAILED") then
		IROVar.Lock.SS.trust_segment_cast = true
	end
	if IROSpecID==266 then -- Demo Sepc
		if (sourceGUID==IROVar.Lock.playerGUID) then
			if (subevent=="SPELL_SUMMON") then
				if (DesName=="Wild Imp") then
					IROVar.Lock.Imp.spawn[DesGUID]={
						FelFireboltCount=6,
						SpawnTime=GetTime()+(IROVar.Lock.Imp.FreezEn and 15 or 0), -- FreezEN=buff Demonic Power
						ExpireTimeHandel=C_Timer.NewTimer(21,IROVar.Lock.CheckImpExpire),
					}
					IROVar.Lock.Imp.count=IROVar.Lock.Imp.count+1
				end
			elseif (subevent=="SPELL_CAST_SUCCESS") and (spellID==196277) then --Implosion
				for _,v in pairs(IROVar.Lock.Imp.spawn) do
					v.ExpireTimeHandel:Cancel()
				end
				IROVar.Lock.Imp.spawn={}
				IROVar.Lock.Imp.count=0
			elseif (subevent=="SPELL_AURA_APPLIED") and (spellID==265273) then --buff Demonic Power
				IROVar.Lock.Imp.FreezEn=true
				for _,v in pairs(IROVar.Lock.Imp.spawn) do
					v.SpawnTime=v.SpawnTime+15
				end
			elseif (subevent=="SPELL_AURA_REMOVED") and (spellID==265273) then --buff Demonic Power
				IROVar.Lock.Imp.FreezEn=false
				--C_Timer.After(1,function() IROVar.Lock.Imp.FreezEn=false end)
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

IROVar.Lock.SS.Frame = CreateFrame("Frame")
IROVar.Lock.SS.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Lock.SS.Frame:SetScript("OnEvent", IROVar.Lock.COMBAT_LOG_EVENT_UNFILTERED_OnEvent)
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
		if (currentTime>IROVar.Lock.SS.old_spell_finish_cast_check) then
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
		-- if > 6/10 of spell cast bar ?
		-- trust_segment_cast = 0.6>((currentTime*1000)-startTimeMS)/(endTimeMS-startTimeMS)
		-- if spell < 0.3 sec befor finish casting
		IROVar.Lock.SS.trust_segment_cast = (endTime-currentTime)>0.3
		if IROVar.Lock.SS.trust_segment_cast then
			if spellName == "Incinerate" then
				-- check Havoc for double SS generate
				local nn
				local nnDebuff
				local hasHavoc = false
				for ii = 1,30 do
					nn="nameplate"..ii
					if UnitExists(nn) and UnitCanAttack("player", nn) then
						nnDebuff = IROVar.allDeBuffByMe(nn)
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
function IROVar.Lock.GUIDImmolate_OnEvent(self,Event,Unit,CastID,SpellID)
	if (Unit ~= "player") or
	(SpellID ~= 348) or -- Immolate
	(IROSpecID~=267) then -- Destruction
		return
	end
	if Event == "UNIT_SPELLCAST_START" then
		IROVar.Lock.GUIDImmolate_Old=IROVar.Lock.GUIDImmolate
	elseif Event == "UNIT_SPELLCAST_STOP" then
		if IROVar.Lock.GUIDImmolate_Old==IROVar.Lock.GUIDImmolate then
			IROVar.Lock.GUIDImmolate=nil
		end
	end

end
IROVar.Lock.GUIDImmolate_Frame = CreateFrame("Frame")
IROVar.Lock.GUIDImmolate_Frame:RegisterEvent("UNIT_SPELLCAST_START")
IROVar.Lock.GUIDImmolate_Frame:RegisterEvent("UNIT_SPELLCAST_STOP")
IROVar.Lock.GUIDImmolate_Frame:SetScript("OnEvent", IROVar.Lock.GUIDImmolate_OnEvent)