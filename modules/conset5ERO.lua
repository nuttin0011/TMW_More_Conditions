-- ERO DPS Decoder 9.0.5/2
-- can copy this to LUA Snippted

--Setup UsedSkill System

--Wait For Use Skill Icon Control
--can use skill when "IROUsedSkillControl.Stage=1"
--show icon that block Rotation "IROUsedSkillControl.NotReadyToUseSkill()==true"
--@Numdot
--/run IROUsedSkillControl.NumDotPress()

local TMW = TMW
local CNDT = TMW.CNDT
local Env = CNDT.Env
local GCDSpell=TMW.GCDSpell
local GetSpellCooldown=GetSpellCooldown
local UnitCastingInfo=UnitCastingInfo
local UnitChannelInfo=UnitChannelInfo
local GetTime=GetTime

-- this function Change Normal IROcode --> miniIROCode
-- it's ll compress 3 Icon --> 1 Icon
-- ctrl		= 001 00000 = 32	= 0x20
-- alt		= 010 00000 = 64	= 0x40
-- shift	= 100 00000 = 128	= 0x80
-- e.g.
-- c1 = "ff002100" (F1)			--> 0x01
-- c2 = "ff003000" ({Numpad0})	--> 0x0d
-- c3 = "ff042604" (Shift-F6)	--> 0x06 + 0x80 (shift code) --> 0x86
-- c1+c2+c3 = miniIROCode = "ff860d01"
-- NOTE. need to swap byte c1 and c3 cause of EroDPS PixelGetColor function
-- enMiniIROcode("ff002100","ff003000","ff042604")="ff860d01"

local IROcolorCode ={
	["00"]=0x00,
	["21"]=0x01, --{F1}
	["22"]=0x02, --{F2}
	["23"]=0x03, --{F3}
	["24"]=0x04, --{F4}
	["25"]=0x05, --{F5}
	["26"]=0x06, --{F6}
	["27"]=0x07, --{F7}
	["28"]=0x08, --{F8}
	["29"]=0x09, --{F9}
	["2a"]=0x0a, --{F10}
	["2b"]=0x0b, --{F11}
	["2c"]=0x0c, --{F12}
	["30"]=0x0d, --{Numpad0}
	["31"]=0x0e, --{Numpad1}
	["32"]=0x0f, --{Numpad2}
	["33"]=0x10, --{Numpad3}
	["34"]=0x11, --{Numpad4}
	["35"]=0x12, --{Numpad5}
	["36"]=0x13, --{Numpad6}
	["37"]=0x14, --{Numpad7}
	["38"]=0x15, --{Numpad8}
	["39"]=0x16, --{Numpad9}
	["3a"]=0x17, --{NumpadDot}	
	["3b"]=0x18, --{NumpadAdd}
	["3c"]=0x19, --{NumpadSub}
	["3d"]=0x1a, --{NumpadMult}
	["3e"]=0x1b, --{NumpadDiv}
	["55"]=0x1c, --MoveJump ; 0x005500 : MoveJump
}

-- 1 = ctrl , 2 = alt , 4 = shift
-- 1 = 001 , 2 = 010 , 4 = 100
local modStr ={
	["00"]=0,
	["01"]=bit.lshift(0x01,5),
	["02"]=bit.lshift(0x02,5),
	["03"]=bit.lshift(0x03,5),
	["04"]=bit.lshift(0x04,5),
	["05"]=bit.lshift(0x05,5),
	["06"]=bit.lshift(0x06,5),
	["07"]=bit.lshift(0x07,5),
}

function enSubMiniIROCode(IROcode)
	--"ff042604" (Shift-F6)	--> 0x06 + 0x20 (shift code) --> 0x26
	-- if error return "00"
	if not IROcode then return "00" end
	local modstr = modStr[string.sub(IROcode,3,4)]
	if not modstr then return "00" end
	local miniIROCode = IROcolorCode[string.sub(IROcode,5,6)]
	if not miniIROCode then return "00" end
	return string.format("%02x",miniIROCode+modstr)
end

function getMetaIconColor(icon)
	local a=icon.__currentIcon
	local b=a and a.__currentIcon or nil
	while b do
		a=b
		b=a.__currentIcon
	end
	local c=a and a.States[1].Color or "ff000000"
	return c
end

function enMiniIROcode(IROcode1,IROcode2,IROcode3)
	local miniIROCode1 = enSubMiniIROCode(IROcode1)
	local miniIROCode2 = enSubMiniIROCode(IROcode2)
	local miniIROCode3 = enSubMiniIROCode(IROcode3)
	return "ff"..miniIROCode3..miniIROCode2..miniIROCode1
end

local WorldPing={}
WorldPing.now=0
WorldPing.adjustTiming=3.14 -- check World Ping Every 3.14 sec
WorldPing.adjustWorldPing = function()
	WorldPing.now=(select(4,GetNetStats())/1000)
	C_Timer.After(WorldPing.adjustTiming,WorldPing.adjustWorldPing)
end
WorldPing.adjustWorldPing()

local DefaultPingAdjust = 0.2 --sec

function NextTimeCheckLockUseSkill(PingAdjust)
	local GCDst,GCDdu=GetSpellCooldown(GCDSpell)
	local spellname, _, _, startTimeMS, endTimeMS = UnitCastingInfo("player")
	if not spellname then
		spellname, _, _, startTimeMS, endTimeMS = UnitChannelInfo("player")
	end	
	local currentTime=GetTime()	
	local endTime,CutPoint
	PingAdjust=PingAdjust or DefaultPingAdjust
	if spellname then --Player Casting/Channel Spell
		endTime=(endTimeMS/1000)
		CutPoint=endTime-(WorldPing.now+PingAdjust)
		if currentTime<CutPoint then
			return CutPoint,false
		else
			return endTime+PingAdjust,true
		end
	else -- Player Not Casting/Channel
		if not GCDst then
			-- Player Not Has GCDSpell
			return currentTime+0.3,true
		else
			endTime=GCDst+GCDdu
			CutPoint=endTime-(WorldPing.now+PingAdjust)
			if currentTime<CutPoint then
				return CutPoint,false
			else
				return endTime+PingAdjust,true
			end			
		end
	end
end

--Setup UsedSkill System

IROUsedSkillControl={}
IROUsedSkillControl.Stage=1
IROUsedSkillControl.pingadjust=0.25 
IROUsedSkillControl.SkillHandle={}
IROUsedSkillControl.PlayerGUID=UnitGUID("player")
IROUsedSkillControl.NextForceReady=0
function IROUsedSkillControl.OnEvent(self, event)
	local _, subevent, _, sourceGUID = CombatLogGetCurrentEventInfo()
	if (sourceGUID==IROUsedSkillControl.PlayerGUID)and(subevent=="SPELL_CAST_FAILED")
	then IROUsedSkillControl.forceReady() end
end
IROUsedSkillControl.f = CreateFrame("Frame")
IROUsedSkillControl.f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROUsedSkillControl.f:SetScript("OnEvent", IROUsedSkillControl.OnEvent)
IROUsedSkillControl.NumDotPress = function()
	IROUsedSkillControl.Stage=2
	IROUsedSkillControl.Stage2to4()
end
IROUsedSkillControl.NotReadyToUseSkill = function()
	return IROUsedSkillControl.Stage~=1
end
IROUsedSkillControl.forceReady = function()
	local currentTime=GetTime()
	if IROUsedSkillControl.NextForceReady>currentTime then return end
	IROUsedSkillControl.NextForceReady=currentTime+0.19
	for k,v in pairs(IROUsedSkillControl.SkillHandle) do
		v:Cancel()
	end
	IROUsedSkillControl.SkillHandle={}
	IROUsedSkillControl.Stage=1
end
IROUsedSkillControl.Stage2to4 = function()
	IROUsedSkillControl.Stage=3
	table.insert(IROUsedSkillControl.SkillHandle,C_Timer.NewTimer(0.2,IROUsedSkillControl.CheckStageto4))
end
IROUsedSkillControl.CheckStageto4 = function()
	if IROUsedSkillControl.Stage~=1 then
		IROUsedSkillControl.Stage=4
		IROUsedSkillControl.Stage4to1()
	end
end
IROUsedSkillControl.Stage4to1 = function()
	local currentTime
	local IROTimeCheckUseSkill,IROCanUseSkill=NextTimeCheckLockUseSkill(IROUsedSkillControl.pingadjust)
	if IROCanUseSkill then
		IROUsedSkillControl.forceReady()
	else
		IROUsedSkillControl.Stage=5
		currentTime=GetTime()
		local dT=IROTimeCheckUseSkill-currentTime
		if dT>0.2 then dT=0.2 end
		if dT<0 then dT=0 end
		table.insert(IROUsedSkillControl.SkillHandle,
			C_Timer.NewTimer(dT,IROUsedSkillControl.CheckStageto4))
	end
end

