


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
IROUsedSkillControl.KeepLogOffGCD = function()
	if IROUsedSkillControl.KeepLogText then IROUsedSkillControl.KeepLogText(true) end
end
IROUsedSkillControl.Stage=1
IROUsedSkillControl.GCDCD=1
IROUsedSkillControl.PlayerSpec=GetSpecializationInfo(GetSpecialization())
IROUsedSkillControl.spec1secGCD = {
	[259] = true-- Ass
	,[260] = true -- Out
	,[261] = true -- Sub
	,[103] = true -- Feral
	,[269] = true -- Windwalker
}

function IROUsedSkillControl.NotReadyToUseSkill()
	return IROUsedSkillControl.Stage~=1
end

function IROUsedSkillControl.Haste_Event(Self,Event,Arg1)
	if(Arg1=="player")and(not IROUsedSkillControl.spec1secGCD[IROUsedSkillControl.PlayerSpec])then
        IROUsedSkillControl.GCDCD = math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
	end
end
IROUsedSkillControl.Haste_Event(nil,nil,"player")
IROUsedSkillControl.f1=CreateFrame("Frame")
IROUsedSkillControl.f1:RegisterEvent("UNIT_SPELL_HASTE")
IROUsedSkillControl.f1:SetScript("OnEvent", IROUsedSkillControl.Haste_Event)

function IROUsedSkillControl.SpecChanged()
	local spec=GetSpecializationInfo(GetSpecialization())
	if IROUsedSkillControl.spec1secGCD[spec] then
		IROUsedSkillControl.GCDCD=1
	else
		IROUsedSkillControl.GCDCD=math.max(0.5,1.5*(100/(100+UnitSpellHaste("player"))))
	end
	IROUsedSkillControl.PlayerSpec=spec
end
C_Timer.After(5,IROUsedSkillControl.SpecChanged)
IROUsedSkillControl.f2 = CreateFrame("Frame")
IROUsedSkillControl.f2:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IROUsedSkillControl.f2:SetScript("OnEvent", IROUsedSkillControl.SpecChanged)

function IROUsedSkillControl.Cast_OnEvent(self,Event,Unit,CastID,SpellID)
	if (Unit ~= "player") then return end -- if not player return
    if Event == "UNIT_SPELLCAST_START" then
        IROUsedSkillControl.StopGCDPluse()
        IROUsedSkillControl.CreateCastPluse()
    elseif Event == "UNIT_SPELLCAST_STOP" then
       -- if not IROUsedSkillControl.GCDPluseActive
        -- ไปดูก่อนว่า จะ Start ก่อน Stop ได้ไหม ? ถ้าไม่ได้ให้ทำ
        IROUsedSkillControl.SpellActive=false
        if IROUsedSkillControl.GCDPluseTimeStamp<=IROUsedSkillControl.SpellTimeStamp then
            IROUsedSkillControl.forceReady()
        end
    end
end

IROUsedSkillControl.f3 = CreateFrame("Frame")
IROUsedSkillControl.f3:RegisterEvent("UNIT_SPELLCAST_START")
IROUsedSkillControl.f3:RegisterEvent("UNIT_SPELLCAST_STOP")
IROUsedSkillControl.f3:SetScript("OnEvent", IROUsedSkillControl.Cast_OnEvent)

IROUsedSkillControl.GCDTickHandle=C_Timer.NewTimer(0,function() end)
IROUsedSkillControl.GCDPluseActive=false
IROUsedSkillControl.GCDPluseTimeStamp=0
IROUsedSkillControl.SpellActive=false
IROUsedSkillControl.SpellTimeStamp=0
IROUsedSkillControl.forceReadyCheckHandle=C_Timer.NewTimer(0,function() end)

function IROUsedSkillControl.forceReadyCheck()
    if IROUsedSkillControl.Stage==1 then
        IROUsedSkillControl.GCDTickHandle:Cancel()
    end
end

function IROUsedSkillControl.forceReady()
    IROUsedSkillControl.forceReadyCheckHandle:Cancel()
    IROUsedSkillControl.Stage=1
    IROUsedSkillControl.forceReadyCheckHandle=C_Timer.NewTimer(0.4,IROUsedSkillControl.forceReadyCheck)
end

function IROUsedSkillControl.RepeatGCDPluse()
    IROUsedSkillControl.forceReady()
    IROUsedSkillControl.GCDTickHandle=C_Timer.NewTimer(IROUsedSkillControl.GCDCD,IROUsedSkillControl.RepeatGCDPluse)
end

function IROUsedSkillControl.CreateNewGCDPluse()
    IROUsedSkillControl.GCDTickHandle:Cancel()
    IROUsedSkillControl.GCDPluseActive=true
    IROUsedSkillControl.GCDPluseTimeStamp=GetTime()
    IROUsedSkillControl.GCDTickHandle=C_Timer.NewTimer(IROUsedSkillControl.GCDCD-0.05,
    function()
        IROUsedSkillControl.RepeatGCDPluse()
    end)
end

function IROUsedSkillControl.StopGCDPluse()
    IROUsedSkillControl.GCDTickHandle:Cancel()
    IROUsedSkillControl.GCDPluseActive=false
end

function IROUsedSkillControl.CreateCastPluse()
    IROUsedSkillControl.SpellActive=true
    IROUsedSkillControl.SpellTimeStamp=GetTime()
    local n, _, _, _, endTimeMS= UnitCastingInfo("player")
    if not n then
        n, _, _, _, endTimeMS= UnitChannelInfo("player")
    end
    endTimeMS=(endTimeMS/1000)-GetTime()-0.4
    IROUsedSkillControl.GCDTickHandle=C_Timer.NewTimer(endTimeMS,
    function()
        IROUsedSkillControl.forceReady()
    end)
end

function IROUsedSkillControl.NumDotPress()
    if IROUsedSkillControl.KeepLogText then IROUsedSkillControl.KeepLogText() end
    IROUsedSkillControl.Stage=2
    if not IROUsedSkillControl.GCDPluseActive then
        IROUsedSkillControl.CreateNewGCDPluse()
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