-- ZRO Decoder 9.0.5/ Hekili2

-- Set Priority to 0


if not IROUsedSkillControl then
    IROUsedSkillControl={}
end
if not IUSC then
    IUSC=IROUsedSkillControl
end

if not EROTools then EROTools={} end
if not EROTools.IUSCLog then EROTools.IUSCLog={} end
if not EROTools.IUSCLog.UpdateText then EROTools.IUSCLog.UpdateText=function() end end

local GetTime=GetTime
-- adjust GCD + Cast by check GCD/SpellCastTime and ClickGap
-- Max Adjust = 0.1 sec
-- Goal ; GCD == ClickGap | SpellCastTime-0.2 == ClickGap
IUSC.NeedAdjust=false
IUSC.GCDAdjust=0
IUSC.GCDAdjustT1=0
IUSC.GCDAdjustT2=0
IUSC.CastAdjust=0
IUSC.CastAdjustT1=0
IUSC.CastAdjustT2=0
--
IUSC.debugmode=false
IUSC.SkillPressStampTime=0
IUSC.IUSCLog=""
IUSC.IUSCLog1stLine=""
IUSC.SkillPress=0
IUSC.KeepLogOffGCD = function()
	if IUSC.KeepLogText then IUSC.KeepLogText(true) end
end
IUSC.NextReady=GetTime()
IUSC.Stage=1
IUSC.GCDCD=1
IUSC.GCDAtPluse=IUSC.GCDCD
IUSC.GCDCDMinus005=IUSC.GCDCD-0.05
IUSC.GCDCDMinus02=IUSC.GCDCD-0.2
IUSC.PlayerSpec=GetSpecializationInfo(GetSpecialization())
IUSC.spec1secGCD = {
	[259] = true-- Ass
	,[260] = true -- Out
	,[261] = true -- Sub
	,[103] = true -- Feral
	,[269] = true -- Windwalker
}

IUSC.NumToSpell={}
IUSC.NumToID={}
IUSC.IDToSpell={}
IUSC.RegCallBackAfterSO={
	--[nameCallBack]=CallBack,...
}
IUSC.RegCallBackAfterSU={
	--[nameCallBack]=CallBack,...
}
IUSC.AfterSO=function(SkillID)
	for _,v in pairs(IUSC.RegCallBackAfterSO) do v(SkillID)end
end
IUSC.AfterSU=function(SkillID)
	for _,v in pairs(IUSC.RegCallBackAfterSU) do v(SkillID)end
end
IUSC.LastSU=nil
IUSC.Ping={}
local Ping=IUSC.Ping
function Ping.aP()
    Ping.now=(select(4,GetNetStats())/1000)
	--Ping.nowPlus=math.min(0.5,Ping.now+0.25)
	Ping.nowPlus=math.min(0.8,Ping.now*2)
	--Ping.nowMul=Ping.now*2
	--/dump IUSC.Ping.nowPlus
    C_Timer.After(7.8,Ping.aP)
end
Ping.aP()

local function CDEnd(s)
	local st,du=GetSpellCooldown(s)
	return st+du
end

local function GCD()
	return select(2,GetSpellCooldown(TMW.GCDSpell))
end

function IUSC.LastSkillUse()
	return IUSC.LastSU
end

function IUSC.NotReadyToUseSkill()
	return IUSC.Stage~=1
end

function IUSC.Haste_Event(Self,Event,Arg1)
	if(Arg1=="player")and(not IUSC.spec1secGCD[IUSC.PlayerSpec])then
        IUSC.GCDCD = math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
		IUSC.GCDCD = math.floor(IUSC.GCDCD*1000)/1000
		IUSC.GCDCDMinus005=IUSC.GCDCD-0.05
		--IUSC.GCDCDMinus02=IUSC.GCDCD-0.2
		IUSC.GCDCDMinus02=IUSC.GCDCD-Ping.nowPlus
	end
end

IUSC.Haste_Event(nil,nil,"player")
IUSC.f1=CreateFrame("Frame")
IUSC.f1:RegisterEvent("UNIT_SPELL_HASTE")
IUSC.f1:SetScript("OnEvent", IUSC.Haste_Event)

function IUSC.SpecChanged()
	local spec=GetSpecializationInfo(GetSpecialization())
	if IUSC.spec1secGCD[spec] then
		IUSC.GCDCD=1
	else
        IUSC.GCDCD = math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
		IUSC.GCDCD = math.floor(IUSC.GCDCD*1000)/1000
	end
	IUSC.GCDCDMinus005=IUSC.GCDCD-0.05
	--IUSC.GCDCDMinus02=IUSC.GCDCD-0.2
	IUSC.GCDCDMinus02=IUSC.GCDCD-Ping.nowPlus
	IUSC.PlayerSpec=spec
end
C_Timer.After(5,IUSC.SpecChanged)
IUSC.f2 = CreateFrame("Frame")
IUSC.f2:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IUSC.f2:SetScript("OnEvent", IUSC.SpecChanged)

IUSC.GCDTickHandle=C_Timer.NewTimer(0.1,function() end)
IUSC.CheckSentEventHandle=C_Timer.NewTimer(0.1,function() end)
IUSC.GCDPluseActive=false
IUSC.SpellActive=false
IUSC.GCDPluseTimeStamp=0
IUSC.GCDPluseNextTick=0
IUSC.SENTStampTime=0
IUSC.SkillNameLen=0

function IUSC.printdebug(m)
    IUSC.IUSCLog1stLine=IUSC.IUSCLog1stLine..m
    if string.sub(IUSC.IUSCLog1stLine,string.len(IUSC.IUSCLog1stLine))=="\n" then
        IUSC.IUSCLog=IUSC.IUSCLog1stLine..IUSC.IUSCLog
        IUSC.IUSCLog1stLine=""
    end
    EROTools.IUSCLog.UpdateText()
end

function IUSC.forceReady()
    if IUSC.debugmode then
        IUSC.printdebug("^READY\n")
    end
    IUSC.Stage=1
	IUSC.NextReady=0
end

function IUSC.StopPluse(nkl)--nkl = Not keep log in debug mode
    if IUSC.debugmode and not nkl then
        IUSC.printdebug("^stop pluse")
    end
    IUSC.GCDTickHandle:Cancel()
    IUSC.GCDPluseActive=false
	IUSC.SpellActive=false
end

function IUSC.CreateCastPluse()
	if IUSC.debugmode then
		IUSC.printdebug("^Cast pluse")
	end
	IUSC.GCDTickHandle:Cancel()
    IUSC.SpellActive=true
    IUSC.SpellTimeStamp=GetTime()
    local n, _, _, _, endTimeMS= UnitCastingInfo("player")
    --if not n then ----------- should not has Channeling??????
    --    n, _, _, _, endTimeMS= UnitChannelInfo("player")
    --end
	endTimeMS=(endTimeMS/1000)-Ping.nowPlus
	if IUSC.debugmode then
		IUSC.printdebug("^castting..")
	end
	endTimeMS=endTimeMS-IUSC.SpellTimeStamp
	if endTimeMS<0 then endTimeMS=0.1 end
	IUSC.NextReady=IUSC.SpellTimeStamp+endTimeMS
	if endTimeMS<0.1 then endTimeMS=0.1 end
    IUSC.GCDTickHandle=C_Timer.NewTimer(endTimeMS,
    function()
		if IUSC.debugmode then
			IUSC.printdebug("^cast pluse end")
		end
		IUSC.SpellActive=false
        IUSC.forceReady()
    end)
end

--Skill Use
function IUSC.SU(k,t) --k is string e.g. "33" , "3a" , t=GCD /nil=default
	if IUSC.Stage~=1 then
		return
	end
	local S = IsShiftKeyDown() and 4 or 0
	local C = IsControlKeyDown() and 1 or 0
	local A = IsAltKeyDown() and 2 or 0
	C=A+S+C --mod
	S=bit.lshift(tonumber(k,16),8) -- k * 256
	C=bit.bor(C,S) -- k .. mod
	if not IsCurrentSpell(IUSC.NumToID[C]) then
		local newSpellID=select(7,GetSpellInfo(IUSC.NumToSpell[C]))
		if newSpellID and IsCurrentSpell(newSpellID) then
			IUSC.NumToID[C]=newSpellID
		else
			-- Spell not queue
			if IUSC.debugmode then
				IUSC.printdebug("skill "..(IUSC.NumToSpell[C] or "SPELL NOT FOUND").."NOT Q")
			end
			IUSC.forceReady()
			return
		end
	end
	--keep log
	if IUSC.KeepLogText then IUSC.KeepLogText() end
	IUSC.SkillPress=IUSC.NumToID[C] or 0
	local cTime=GetTime()
	IUSC.SkillPressStampTime=cTime
	IUSC.LastSU=IUSC.NumToSpell[C]
	IUSC.AfterSU(IUSC.NumToID[C])
end

--Skill use off gcd
function IUSC.SO(k) --k is string e.g. "33" , "3a"
	local S = IsShiftKeyDown() and 4 or 0
	local C = IsControlKeyDown() and 1 or 0
	local A = IsAltKeyDown() and 2 or 0
	C=A+S+C --mod
	S=bit.lshift(tonumber(k,16),8) -- k * 256
	C=bit.bor(C,S) -- k .. mod
	--print("skill offGCD use : ",IUSC.NumToSpell[C] or "none",IUSC.NumToID[C] or 0)
	if IUSC.KeepLogText then IUSC.KeepLogText(true) end
	IUSC.AfterSO(IUSC.NumToID[C])
end

IUSC.ClassType={
	--[specID]={interruptTier,interruptSpellName,DPSCheckSkill,Range,Role,CastType}
	[71] = {'B','Pummel','Pummel','Melee','DPS','InstanceCast'} -- Arm
	,[72] = {'B','Pummel','Pummel','Melee','DPS','InstanceCast'} -- fury
	,[73] = {'A','Pummel','Pummel','Melee','Tank','InstanceCast'} -- Protection
--	,[265] = {'D','Spell Lock','Corruption','Range','DPS','Caster'} -- Aff 'Spell Lock' 119910
--	,[266] = {'D','Axe Toss','Corruption','Range','DPS','Caster'} -- Demo 'Axe Toss'119914
--	,[267] = {'D','Spell Lock','Corruption','Range','DPS','Caster'} -- Dest
	,[265] = {'D','Command Demon','Corruption','Range','DPS','Caster'} -- Aff 'Spell Lock' 119910
	,[266] = {'D','Command Demon','Corruption','Range','DPS','Caster'} -- Demo 'Axe Toss'119914
	,[267] = {'D','Command Demon','Corruption','Range','DPS','Caster'} -- Dest
	,[262] = {'C','Wind Shear','Lightning Bolt','Range','DPS','Caster'} -- Element
	,[263] = {'B','Wind Shear','primal strike','Melee','DPS','InstanceCast'} -- Enha
	,[264] = {'D','Wind Shear','Lightning Bolt','Range','Healer','Caster'} -- Resto
	,[259] = {'B','Kick','Kick','Melee','DPS','InstanceCast'} -- Ass
	,[260] = {'B','Kick','Kick','Melee','DPS','InstanceCast'} -- Out
	,[261] = {'B','Kick','Kick','Melee','DPS','InstanceCast'} -- Sub
	,[256] = {'N','','Smite','Range','Healer','Caster'} -- Disc
	,[257] = {'N','','Smite','Range','Healer','Caster'} -- Holy
	,[258] = {'D','Silence','Smite','Range','DPS','Caster'} -- Shadow
	,[65] = {'N','','Crusader Strike','Range','Healer','Caster'} -- Holy
	,[66] = {'A','Rebuke','Crusader Strike','Melee','Tank','InstanceCast'} -- Port
	,[70] = {'B','Rebuke','Crusader Strike','Melee','DPS','InstanceCast'} -- Ret
	,[268] = {'A','Spear Hand Strike','Tiger Palm','Melee','Tank','InstanceCast'} -- Brewmaster
	,[270] = {'N','','Tiger Palm','Range','Healer','Caster'} -- Mistweaver
	,[269] = {'B','Spear Hand Strike','Tiger Palm','Melee','DPS','InstanceCast'} -- Windwalker
	,[62] = {'C','Counterspell','Fire Blast','Range','DPS','Caster'} -- arcane
	,[63] = {'C','Counterspell','Fire Blast','Range','DPS','Caster'} -- fire
	,[64] = {'C','Counterspell','Fire Blast','Range','DPS','Caster'} -- frost
	,[253] = {'C','Counter Shot','Arcane Shot','Range','DPS','InstanceCast'} -- Beast Mastery
	,[254] = {'C','Counter Shot','Arcane Shot','Range','DPS','InstanceCast'} -- Marksmanship
	,[255] = {'C','Muzzle','Raptor Strike','Melee','DPS','InstanceCast'} -- Survival
	,[102] = {'C','Solar Beam','Moonfire','Range','DPS','Caster'} -- Balance
	,[103] = {'B','Skull Bash','Rake','Melee','DPS','InstanceCast'} -- Feral
	,[104] = {'A','Skull Bash','Mangle','Melee','Tank','Caster'} -- Guardian
	,[105] = {'N','','Moonfire','Range','Healer','Caster'} -- Restoration
	,[577] = {'B','Disrupt','Chaos Strike','Melee','DPS','InstanceCast'} -- Havoc
	,[581] = {'A','Disrupt','Chaos Strike','Melee','Tank','InstanceCast'} -- Vengeance
	,[250] = {'A','Mind Freeze','Death Strike','Melee','Tank','InstanceCast'} -- Blood
	,[251] = {'B','Mind Freeze','Death Strike','Melee','DPS','InstanceCast'} -- frost
	,[252] = {'B','Mind Freeze','Death Strike','Melee','DPS','InstanceCast'} -- unholy
}


C_Timer.NewTicker(0.05,function()
    local currentTime=GetTime()
    local GCDEnd=CDEnd(TMW.GCDSpell)
    if GCDEnd>0 and (GCDEnd-currentTime)>0.3 then
        IUSC.Stage=2
        return
    end
	local cast=true
    local name,_,_,_,endTimeMS = UnitCastingInfo("player")
    if not name then
		cast=false
        name,_,_,_,endTimeMS = UnitChannelInfo("player")
    end
    if not name then
        IUSC.Stage=1
        return
    end
    endTimeMS=(endTimeMS/1000)-currentTime
    if (cast and endTimeMS<=0.3) or (endTimeMS<=0.2)then
        IUSC.Stage=1
    else
        IUSC.Stage=2
    end
end)
