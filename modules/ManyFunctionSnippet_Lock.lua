-- Many Function Version Warlock 9.0.5/2c
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Lock.Pet(PetType) return true/false
----PetType 1=Felg 2=Succ 4=Felh 8=Voidw 16=Imp can use 3 for check felg+succ
--function IROVar.Lock.PredictSS() return SSFragment / 10 SSFragment = 1 SS
--function IROVar.Lock.KeepLogText();
---- place befor /run IROUsedSkillControl.NumDotPress() for debug
--function IROVar.Lock.ShowLog()
--[[ NOTE
GetSpellCount("Implosion") ;Implosion Stack
UnitPower("player",7) ; SoulShards
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
	["Axe Toss"]=1,["Seduction"]=2,["Spell Lock"]=4,
	["Shadow Bulwark"]=8,["Singe Magic"]=16,
	["Command Demon"]=128,
}
function IROVar.Lock.SetupPetEvent()
	function IROVar.Lock.CheckPet()
		local currentTime=GetTime()
		if (currentTime-IROVar.Lock.JustRunPetCheck)<0.05 then return end
		IROVar.Lock.JustRunPetCheck=currentTime
		if currentTime<IROVar.Lock.PetCheckedTime+IROVar.Lock.PetCheckTimer then
			IROVar.Lock.PetActive=0
			local spellName = GetSpellInfo("Command Demon")
			if UnitExists("pet") and (not UnitIsDead("pet")) then
				IROVar.Lock.PetActive=IROVar.Lock.PetTypeBit[spellName] or 0
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

function IROVar.Lock.SS.OnEvent()
    local _,subevent,_,sourceGUID = CombatLogGetCurrentEventInfo()
        if (sourceGUID==IROVar.Lock.playerGUID)  and (subevent=="SPELL_CAST_FAILED") then
			IROVar.Lock.SS.trust_segment_cast = true
       end
end

IROVar.Lock.SS.Frame = CreateFrame("Frame")
IROVar.Lock.SS.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Lock.SS.Frame:SetScript("OnEvent", IROVar.Lock.SS.OnEvent)
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

