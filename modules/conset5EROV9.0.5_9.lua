-- ZRO Decoder 9.0.5/9
-- check Spell GCD
--[[ e.g.
IUSC.NumToSpell={}
IUSC.NumToID={}
IUSC.IDToSpell={}

Num= [NumKeyID]..[Mod] in 16 base --> change to 10 base
e.g. key "30" .. Mod CtrlAlt "03" = "0x3003" = 12291

IUSC.SU(k) -- skill use , k= key name string e.g. num0 = "30" , F10="2a"
place at end of macro
e.g. /cast [nomod]shadow bolt; \n/run IUSC.SU("30")

Skill use off gcd
function IUSC.SO(k) --k is string e.g. "33" , "3a"
no any effect.... just keep log.......
]]

-- can copy this to LUA Snippted
-- Set to Hiest Priority!!!!!!!!!!!!!!
-- Setup UsedSkill System

--IUSC=IROUsedSkillControl

--Wait For Use Skill Icon Control
--can use skill when "IUSC.Stage=1"
--show icon that block Rotation "IUSC.NotReadyToUseSkill()==true"

--/run IUSC.forceReady() <-- forceReady
--log work only with EROTools Addon installed

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
IUSC.debugmode=false
IUSC.SkillPressStampTime=0
IUSC.IUSCLog=""
IUSC.IUSCLog1stLine=""
IUSC.SkillPress=0
IUSC.KeepLogOffGCD = function()
	if IUSC.KeepLogText then IUSC.KeepLogText(true) end
end
IUSC.Stage=1
IUSC.GCDCD=1
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

local Ping={}
function Ping.aP()
    Ping.now=(select(4,GetNetStats())/1000)
	Ping.nowPlus=math.min(0.8,Ping.now+0.2)
	--Ping.nowMul=Ping.now*2
    C_Timer.After(7.8,Ping.aP)
end
Ping.aP()

function IUSC.NotReadyToUseSkill()
	return IUSC.Stage~=1
end

function IUSC.Haste_Event(Self,Event,Arg1)
	if(Arg1=="player")and(not IUSC.spec1secGCD[IUSC.PlayerSpec])then
        IUSC.GCDCD = math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
		IUSC.GCDCDMinus005=IUSC.GCDCD-0.05
		IUSC.GCDCDMinus02=IUSC.GCDCD-0.2
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
	IUSC.GCDCDMinus005=IUSC.GCDCD-0.05
	IUSC.GCDCDMinus02=IUSC.GCDCD-0.2
	IUSC.PlayerSpec=spec
end
C_Timer.After(5,IUSC.SpecChanged)
IUSC.f2 = CreateFrame("Frame")
IUSC.f2:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IUSC.f2:SetScript("OnEvent", IUSC.SpecChanged)


------------------------------------------------------------------------------------------------------

function IUSC.Cast_OnEvent(self,Event,arg1,arg2,arg3,arg4)
	local function StopAllPluse()
		IUSC.GCDPluseActive=false
		IUSC.SpellActive=false
		IUSC.GCDTickHandle:Cancel()
		IUSC.forceReady()
	end
	if (arg1 ~= "player") then return end
	if (Event=="UNIT_SPELLCAST_SENT") and (arg4==IUSC.SkillPress) then
		if IUSC.debugmode then
			IUSC.printdebug("|SENT:"..IUSC.IDToSpell[arg4]..string.format(":%.2f",(GetTime()-IUSC.SkillPressStampTime)))
		end
		IUSC.SENTStampTime=GetTime()
		--IUSC.CheckSentEventHandle:Cancel()
    elseif (Event == "UNIT_SPELLCAST_START")and(arg3==IUSC.SkillPress)then
		if IUSC.debugmode then
			IUSC.printdebug("|START")
		end
		if not IUSC.GCDPluseActive then
			IUSC.GCDPluseNextTick=GetTime()+IUSC.GCDCDMinus005-Ping.nowPlus
		end
		IUSC.Stage=2
        IUSC.StopPluse()
        IUSC.CreateCastPluse()
	elseif (Event == "UNIT_SPELLCAST_SUCCEEDED")and(arg3==IUSC.SkillPress)then
		local currentTime=GetTime()
		if (IUSC.SpellActive==false)and((currentTime-IUSC.SENTStampTime)<0.1) then
			--instance cast
			if currentTime-IUSC.SkillPressStampTime>Ping.nowPlus then
				if IUSC.debugmode then
					IUSC.printdebug("|Instance Cast Skill Adjust GCD")
				end
				IUSC.StopPluse()
				IUSC.CreateGCDPluse(IUSC.GCDCDMinus02)
			end
		end
    elseif (Event == "UNIT_SPELLCAST_STOP")and(arg3==IUSC.SkillPress)then
		if IUSC.debugmode then
			IUSC.printdebug("|STOP")
		end
    elseif (Event == "UNIT_SPELLCAST_FAILED")and(arg3==IUSC.SkillPress) then
		if IUSC.debugmode then
			IUSC.printdebug("|FAILED")
		end
		--IUSC.CheckSentEventHandle:Cancel()
		StopAllPluse()
	elseif (Event == "UNIT_SPELLCAST_INTERRUPTED")and(arg3==IUSC.SkillPress) then
		if IUSC.SpellActive==true then
			if IUSC.debugmode then
				IUSC.printdebug("|INTERRUPTED")
			end
			StopAllPluse()
        end
	elseif (Event == "UNIT_SPELLCAST_FAILED_QUIET")and(arg3==IUSC.SkillPress) then
		if IUSC.debugmode then
			IUSC.printdebug("|FAILED_QUIET")
		end
		--IUSC.CheckSentEventHandle:Cancel()
		StopAllPluse()
	end
end

IUSC.f3 = CreateFrame("Frame")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_START")
--IUSC.f3:RegisterEvent("UNIT_SPELLCAST_STOP")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_FAILED")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_SENT")
IUSC.f3:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
IUSC.f3:SetScript("OnEvent", IUSC.Cast_OnEvent)


------------------------------------------------------------------------------------------------------

IUSC.GCDTickHandle=C_Timer.NewTimer(0,function() end)
IUSC.CheckSentEventHandle=C_Timer.NewTimer(0,function() end)
IUSC.GCDPluseActive=false
IUSC.SpellActive=false
IUSC.GCDPluseTimeStamp=0
IUSC.GCDPluseNextTick=0
IUSC.SENTStampTime=0

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
        IUSC.printdebug("|forced ready\n")
    end
    IUSC.Stage=1
end

function IUSC.CreateGCDPluse(T)
	T=T or IUSC.GCDCDMinus005
    if IUSC.debugmode then
        IUSC.printdebug("|create GCD pluse")
    end
    IUSC.GCDTickHandle:Cancel()
    IUSC.GCDPluseActive=true
    IUSC.GCDPluseTimeStamp=GetTime()
    IUSC.GCDPluseNextTick=IUSC.GCDPluseTimeStamp+T
    IUSC.GCDTickHandle=C_Timer.NewTimer(T,
        function()
            if IUSC.debugmode then
                IUSC.printdebug("|GCD Pluse end")
            end
			IUSC.GCDPluseActive=false
            IUSC.forceReady()
    end)
end

function IUSC.StopPluse()
    if IUSC.debugmode then
        IUSC.printdebug("|stop pluse")
    end
    IUSC.GCDTickHandle:Cancel()
    IUSC.GCDPluseActive=false
	IUSC.SpellActive=false
end

function IUSC.CreateCastPluse()
	if IUSC.debugmode then
		IUSC.printdebug("|create cast pluse")
	end
	IUSC.GCDTickHandle:Cancel()
    IUSC.SpellActive=true
    IUSC.SpellTimeStamp=GetTime()
    local n, _, _, _, endTimeMS= UnitCastingInfo("player")
    --if not n then ----------- should not has Channeling??????
    --    n, _, _, _, endTimeMS= UnitChannelInfo("player")
    --end
	endTimeMS=(endTimeMS/1000)-Ping.nowPlus
	if endTimeMS<=IUSC.GCDPluseNextTick then
		if IUSC.debugmode then
			IUSC.printdebug("|casttime<=GCD")
		end
		endTimeMS=IUSC.GCDPluseNextTick-IUSC.SpellTimeStamp
	else
		if IUSC.debugmode then
			IUSC.printdebug("|casttime>GCD")
		end
		endTimeMS=endTimeMS-IUSC.SpellTimeStamp
	end
	if endTimeMS<0 then endTimeMS=0.1 end
    IUSC.GCDTickHandle=C_Timer.NewTimer(endTimeMS,
    function()
		if IUSC.debugmode then
			IUSC.printdebug("|cast pluse end")
		end
		IUSC.SpellActive=false
        IUSC.forceReady()
    end)
end

--Skill Use
function IUSC.SU(k) --k is string e.g. "33" , "3a"
	local S = IsShiftKeyDown() and 4 or 0
	local C = IsControlKeyDown() and 1 or 0
	local A = IsAltKeyDown() and 2 or 0
	C=A+S+C --mod
	S=bit.lshift(tonumber(k,16),8) -- k * 256
	C=bit.bor(C,S) -- k .. mod
	if not IsCurrentSpell(IUSC.NumToID[C]) then
		-- Spell not queue
		if IUSC.debugmode then
			IUSC.printdebug("skill "..(IUSC.NumToSpell[C] or "not found spell")..(IUSC.NumToID[C] or 0).."not queue")
		end
		IUSC.forceReady()
		return
	end
	--keep log
	if IUSC.KeepLogText then IUSC.KeepLogText() end
	IUSC.Stage=2
	IUSC.SkillPress=IUSC.NumToID[C] or 0
	IUSC.SkillPressStampTime=GetTime()
	if IUSC.debugmode then
		IUSC.printdebug("skill use : "..(IUSC.NumToSpell[C] or "none")..(IUSC.NumToID[C] or 0))
	end
	IUSC.CreateGCDPluse()
end

--Skill use off gcd
function IUSC.SO(k) --k is string e.g. "33" , "3a"
	local S = IsShiftKeyDown() and 4 or 0
	local C = IsControlKeyDown() and 1 or 0
	local A = IsAltKeyDown() and 2 or 0
	C=A+S+C --mod
	S=bit.lshift(tonumber(k,16),8) -- k * 256
	C=bit.bor(C,S) -- k .. mod
	print("skill offGCD use : ",IUSC.NumToSpell[C] or "none",IUSC.NumToID[C] or 0)
	if IUSC.KeepLogText then IUSC.KeepLogText(true) end
end





----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------








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