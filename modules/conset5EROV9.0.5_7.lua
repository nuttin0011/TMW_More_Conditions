-- ERO DPS Decoder 9.0.5/7

-- can copy this to LUA Snippted
-- Set to Hiest Priority!!!!!!!!!!!!!!
-- Setup UsedSkill System

--Wait For Use Skill Icon Control
--can use skill when "IROUsedSkillControl.Stage=1"
--show icon that block Rotation "IROUsedSkillControl.NotReadyToUseSkill()==true"
--@Numdot
--/run IROUsedSkillControl.NumDotPress() <-- keep log for in GCD skill
--/run IROUsedSkillControl.KeepLogOffGCD() <-- keep log off GCD skill
--@etc
--/run IROUsedSkillControl.forceReady() <-- forceReady
--log work only with EROTools Addon installed

if not IROUsedSkillControl then
	IROUsedSkillControl={}
end
local IUSC=IROUsedSkillControl
local GetTime=GetTime
IUSC.debugmode=false
IUSC.KeepLogOffGCD = function()
	if IUSC.KeepLogText then IUSC.KeepLogText(true) end
end
IUSC.Stage=1
IUSC.GCDCD=1
IUSC.PlayerSpec=GetSpecializationInfo(GetSpecialization())
IUSC.spec1secGCD = {
	[259] = true-- Ass
	,[260] = true -- Out
	,[261] = true -- Sub
	,[103] = true -- Feral
	,[269] = true -- Windwalker
}

local Ping={}
function Ping.aP()
    Ping.now=(select(4,GetNetStats())/1000)
	Ping.nowPlus=Ping.now+0.2
    C_Timer.After(7.88,Ping.aP)
end
Ping.aP()

function IUSC.NotReadyToUseSkill()
	return IUSC.Stage~=1
end
function IUSC.printdebug(m)
	if IUSC.debugmode then
		print(m)
	end
end
function IUSC.Haste_Event(Self,Event,Arg1)
	if(Arg1=="player")and(not IUSC.spec1secGCD[IUSC.PlayerSpec])then
        IUSC.GCDCD = math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
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
		IUSC.GCDCD=math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
	end
	IUSC.PlayerSpec=spec
end
C_Timer.After(5,IUSC.SpecChanged)
IUSC.f2 = CreateFrame("Frame")
IUSC.f2:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IUSC.f2:SetScript("OnEvent", IUSC.SpecChanged)

function IUSC.Cast_OnEvent(self,Event,Unit,CastID,SpellID)
	if (Unit ~= "player") then return end
    if Event == "UNIT_SPELLCAST_START" then
		IUSC.printdebug("casting start")
		if not IUSC.GCDPluseActive then
			IUSC.GCDPluseNextTick=GetTime()+IUSC.GCDCD-Ping.nowPlus
		end
		IUSC.Stage=2
        IUSC.StopGCDPluse()
        IUSC.CreateCastPluse()
    elseif Event == "UNIT_SPELLCAST_STOP" then
		IUSC.printdebug("casting stop")
    elseif Event == "UNIT_SPELLCAST_FAILED" then
		IUSC.printdebug("casting fail!!!")
		IUSC.GCDPluseActive=false
		IUSC.SpellActive=false
		IUSC.GCDTickHandle:Cancel()
		IUSC.forceReady()
	elseif Event == "UNIT_SPELLCAST_INTERRUPTED" then
		if IUSC.SpellActive==true then
			IUSC.printdebug("cast Interrupted!")
			IUSC.SpellActive=false
			IUSC.GCDTickHandle:Cancel()
            IUSC.forceReady()
        end
	end
end

IUSC.f3 = CreateFrame("Frame")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_START")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_STOP")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_FAILED")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
IUSC.f3:SetScript("OnEvent", IUSC.Cast_OnEvent)

IUSC.GCDTickHandle=C_Timer.NewTimer(0,function() end)
IUSC.GCDPluseActive=false
IUSC.GCDPluseTimeStamp=0
IUSC.GCDPluseNextTick=0
IUSC.SpellActive=false
IUSC.SpellTimeStamp=0
IUSC.forceReadyCheckHandle=C_Timer.NewTimer(0,function() end)
IUSC.NumDotStampTime=0

function IUSC.forceReadyCheck()
    if IUSC.Stage==1 then
		IUSC.printdebug("forceReadyCheck -> Stop GCD Pluse")
		IUSC.GCDPluseActive=false
		IUSC.SpellActive=false
        IUSC.GCDTickHandle:Cancel()
    end
end

function IUSC.forceReady()
	IUSC.printdebug("forced ready")
    IUSC.forceReadyCheckHandle:Cancel()
    IUSC.Stage=1
    IUSC.forceReadyCheckHandle=C_Timer.NewTimer(0.4,IUSC.forceReadyCheck)
end

function IUSC.RepeatGCDPluse()
	IUSC.printdebug("GCD tick")
    IUSC.forceReady()
	IUSC.GCDPluseNextTick=GetTime()+IUSC.GCDCD
    IUSC.GCDTickHandle=C_Timer.NewTimer(IUSC.GCDCD,IUSC.RepeatGCDPluse)
end

function IUSC.CreateNewGCDPluse()
	IUSC.printdebug("create GCD pluse")
    IUSC.GCDTickHandle:Cancel()
    IUSC.GCDPluseActive=true
    IUSC.GCDPluseTimeStamp=GetTime()
	IUSC.GCDPluseNextTick=IUSC.GCDPluseNextTick+IUSC.GCDCD-0.05
    IUSC.GCDTickHandle=C_Timer.NewTimer(IUSC.GCDCD-0.05,
    function()
		IUSC.printdebug("Start Tick")
        IUSC.RepeatGCDPluse()
    end)
end

function IUSC.StopGCDPluse()
	IUSC.printdebug("stop GCD pluse")
    IUSC.GCDTickHandle:Cancel()
    IUSC.GCDPluseActive=false
end

function IUSC.CreateCastPluse()
	IUSC.printdebug("create cast pluse")
    IUSC.SpellActive=true
    IUSC.SpellTimeStamp=GetTime()
    local n, _, _, _, endTimeMS= UnitCastingInfo("player")
    if not n then
        n, _, _, _, endTimeMS= UnitChannelInfo("player")
    end
	endTimeMS=(endTimeMS/1000)-Ping.nowPlus

	--endTimeMS=math.max((endTimeMS/1000)-Ping.nowPlus,IUSC.GCDPluseNextTick)-IUSC.SpellTimeStamp
	if endTimeMS<=IUSC.GCDPluseNextTick then
		IUSC.printdebug("casttime<=GCD : use GCD timer")
		endTimeMS=IUSC.GCDPluseNextTick-IUSC.SpellTimeStamp
	else
		IUSC.printdebug("casttime>GCD : use Spell timer")
		endTimeMS=endTimeMS-IUSC.SpellTimeStamp
	end
	if endTimeMS<0 then endTimeMS=0.1 end
    IUSC.GCDTickHandle=C_Timer.NewTimer(endTimeMS,
    function()
		IUSC.printdebug("cast pluse end")
		IUSC.SpellActive=false
        IUSC.forceReady()
    end)
end

function IUSC.NumDotPress()
	IUSC.NumDotStampTime=GetTime()
	IUSC.printdebug("numdot press")
    if IUSC.KeepLogText then IUSC.KeepLogText() end
    IUSC.Stage=2
    if (not IUSC.GCDPluseActive)and(not IUSC.SpellActive) then
        IUSC.CreateNewGCDPluse()
    end
end

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
	if not icon then return "ff000000" end
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

IUSC.ClassType={
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