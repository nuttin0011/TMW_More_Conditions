-- ERO DPS Decoder 9.0.5/6

-- can copy this to LUA Snippted
-- Set to Hiest Priority!!!!!!!!!!!!!!
-- Setup UsedSkill System

--Wait For Use Skill Icon Control
--can use skill when "IROUsedSkillControl.Stage=1"
--show icon that block Rotation "IROUsedSkillControl.NotReadyToUseSkill()==true"
--@Numdot
--/run IROUsedSkillControl.NumDotPress() <-- keep log for in GCD skill
--/run IROUsedSkillControl.KeepLogOffGCD() <-- keep log off GCD skill
--log work only with EROTools Addon installed
if not IROUsedSkillControl then
	IROUsedSkillControl={}
end

IROUsedSkillControl.IdleTimeAfterUseSkill=0.2
IROUsedSkillControl.PlayerSpec=GetSpecializationInfo(GetSpecialization())
IROUsedSkillControl.AdjustIdleTimeAfterUseSkill = function()
	IROUsedSkillControl.PlayerSpec=GetSpecializationInfo(GetSpecialization())
	local CastType=IROUsedSkillControl.ClassType[IROUsedSkillControl.PlayerSpec][6]
	if CastType=='Caster' then
		IROUsedSkillControl.IdleTimeAfterUseSkill=0.4
	else
		IROUsedSkillControl.IdleTimeAfterUseSkill=0.2
	end
end
C_Timer.After(5,IROUsedSkillControl.AdjustIdleTimeAfterUseSkill)
IROUsedSkillControl.f2 = CreateFrame("Frame")
IROUsedSkillControl.f2:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IROUsedSkillControl.f2:SetScript("OnEvent", IROUsedSkillControl.AdjustIdleTimeAfterUseSkill)
-- recommend 0.2 for instance class e.g. warrior
-- 0.4 for caster
IROUsedSkillControl.pingadjust=0.25
-- 0.25 for SEA?
IROUsedSkillControl.ClassType={
	--[specID]={interruptTier,interruptSpellName,DPSCheckSkill,Range,Role,CastType}
	[71] = {'B','Pummel','Pummel','Melee','DPS','InstanceCast'} -- Arm
	,[72] = {'B','Pummel','Pummel','Melee','DPS','InstanceCast'} -- fury
	,[73] = {'A','Pummel','Pummel','Melee','Tank','InstanceCast'} -- Protection
	,[265] = {'D','Command Demon','Corruption','Range','DPS','Caster'} -- Aff [Spell Lock]
	,[266] = {'D','Command Demon','Corruption','Range','DPS','Caster'} -- Demo
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
WorldPing.adjustTiming=5.14 -- check World Ping Every 3.14 sec
WorldPing.adjustWorldPing = function()
	WorldPing.now=(select(4,GetNetStats())/1000)
	C_Timer.After(WorldPing.adjustTiming,WorldPing.adjustWorldPing)
end
WorldPing.adjustWorldPing()

local DefaultPingAdjust = 0.2 --sec

function NextTimeCheckLockUseSkill(PingAdjust)
	local GCDst,GCDdu=GetSpellCooldown(GCDSpell)
	local spellname, _, _, _, endTimeMS = UnitCastingInfo("player")
	if not spellname then
		spellname, _, _, _, endTimeMS = UnitChannelInfo("player")
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

IROUsedSkillControl.Stage=1
IROUsedSkillControl.SkillHandle={}
IROUsedSkillControl.PlayerGUID=UnitGUID("player")
IROUsedSkillControl.NextForceReady=0
IROUsedSkillControl.OldTimeNumDotPress=0
function IROUsedSkillControl.OnEvent()
	local _, subevent, _, sourceGUID = CombatLogGetCurrentEventInfo()
	if (sourceGUID==IROUsedSkillControl.PlayerGUID)and(subevent=="SPELL_CAST_FAILED")
	then IROUsedSkillControl.forceReady() end
end
IROUsedSkillControl.f = CreateFrame("Frame")
IROUsedSkillControl.f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROUsedSkillControl.f:SetScript("OnEvent", IROUsedSkillControl.OnEvent)
IROUsedSkillControl.KeepLogOffGCD = function()
	if IROUsedSkillControl.KeepLogText then IROUsedSkillControl.KeepLogText(true) end
end
IROUsedSkillControl.NumDotPress = function()
	if IROUsedSkillControl.KeepLogText then IROUsedSkillControl.KeepLogText() end
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
	for _,v in pairs(IROUsedSkillControl.SkillHandle) do
		v:Cancel()
	end
	IROUsedSkillControl.SkillHandle={}
	IROUsedSkillControl.Stage=1
end
IROUsedSkillControl.Stage2to4 = function()
	IROUsedSkillControl.Stage=3
	table.insert(IROUsedSkillControl.SkillHandle,C_Timer.NewTimer(IROUsedSkillControl.IdleTimeAfterUseSkill,IROUsedSkillControl.CheckStageto4))
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

