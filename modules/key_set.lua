local TMW = TMW
local TMW_MC = TMW_More_Conditions
local CNDT = TMW.CNDT
local Env = CNDT.Env


local InCombatLockdown=InCombatLockdown
local SaveBindings=SaveBindings
local DeleteMacro=DeleteMacro
local CreateMacro=CreateMacro
local ConsoleExec=ConsoleExec
local GetTime=GetTime
local GetSpecialization=GetSpecialization
local GetSpecializationInfo=GetSpecializationInfo

-- Set Key Binding

--********************** Key Set

function Env.IRODPS_init_Key_Bind()
	ConsoleExec("screenFlashEdge 0")
	ConsoleExec("doNotFlashLowHealthWarning 1")
	ConsoleExec("Gamma 1")

	if InCombatLockdown() then
		print("cannot Bind Key While Incombat")
	end

	local M0='/stopcasting [mod:alt]\n/use [mod:ctrl]Healthstone\n/stopmacro [mod]\n/run TMW_ST:UpdateCounter("usedskill", 2)'

	if not(InCombatLockdown()) then
		local i
		for i =0,9 do
			SetBindingMacro('NUMPAD'..i,'~!Num'..i)
		end
		DeleteMacro("~NumDotUsedSkill")
		DeleteMacro("~NumDotUsedSkill")
		CreateMacro("~NumDotUsedSkill",460699, M0, true)
		SetBindingMacro("NUMPADDECIMAL","~NumDotUsedSkill")
		
		SaveBindings(GetCurrentBindingSet())
	end
end

local Old_Timer_IRODPS_Set_Key_Binding = 0
local Old_Spec = 0


function Env.IRODPS_Set_Key_Binding(nCode)

	local currentTime=GetTime()
	
	if currentTime-Old_Timer_IRODPS_Set_Key_Binding < 2 then
		-- Do not Spam
		return true
	end
	
	local currentSpec = GetSpecialization()
	local IROSpecID  = GetSpecializationInfo(currentSpec)
	if Old_Spec==IROSpecID then return false end
	
	Old_Spec=IROSpecID
	
	Old_Timer_IRODPS_Set_Key_Binding=currentTime
	
	--print(nCode)
	nCode = string.upper(nCode)
	if InCombatLockdown() then
		print("cannot Bind Key while Incombat")
		return false
	end

	Nm={}
	if Key_Set[nCode] then
		--print("has code")
		Nm=Key_Set[nCode]()
	end
	
	local i,nname
    for i in pairs(Nm) do
        
        nname='~!Num'..i
        --kname='NUMPAD'..i
        DeleteMacro(nname)
        DeleteMacro(nname)
        CreateMacro(nname,460699,Nm[i] ,true)
        --SetBindingMacro(kname,nname)
    end
	return true
    --SaveBindings(GetCurrentBindingSet())
end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC_KEY_SET", 13, "IRODPS Key Set", false, false)

ConditionCategory:RegisterCondition(6,  "TMWMCKEYSET", {
    text = "Key Set for IRODPS",
	unit="player",
	noslide = true,
	nooperator = true,
	name = function(editbox) 
		editbox:SetTexts("Specific CODE","e.g. IRODPS_LOCK_AFF_9_0_2_20")
	end,

    icon = "Interface\\Icons\\spell_nature_rejuvenation",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		--Env.IRODPS_Set_Key_Binding(c.Name)
		TMW.CNDT.Env.IRODPS_init_Key_Bind()
		return [[IRODPS_Set_Key_Binding(c.NameFirst)]]
    end,	
	events = function(ConditionObject, c)
			return
				ConditionObject:GenerateNormalEventString("PLAYER_LOGIN")
		end,
})

--********************** IRODPS_LOCK_AFF_9_0_2_20

local function IRODPS_LOCK_AFF_9_0_2_20()
	print("Key Bind to IRODPS_LOCK_AFF_9_0_2_20")
	Nm={}
	Nm[0]="/cast [mod:ctrlalt,@mouseover]Agony;[mod:ctrl]Command Demon;[mod:alt]Create Healthstone;[nomod]Curse of Exhaustion"
	Nm[1]="/cast [mod:ctrlalt]Curse of Tongues;[mod:ctrl]Curse of Weakness;[mod:alt]Drain Life;[nomod]Health Funnel"
	Nm[2]="/cast [mod:ctrlalt]Soulstone;[mod:ctrl]Unending Resolve;[mod:alt]Agony;[nomod]Corruption"
	Nm[3]="/cast [mod:ctrlalt]Unstable Affliction;[mod:ctrl]Shadow Bolt;[mod:alt]Haunt;[nomod]Siphon Life"
	Nm[4]="/cast [mod:ctrlalt]notuse;[mod:ctrl,@focus]Agony;[mod:alt,@focus]Corruption;[nomod,@focus]Unstable Affliction"
	Nm[5]="/cast [mod:ctrlalt,@focus]Shadow Bolt;[mod:ctrl,@focus]Haunt;[mod:alt,@focus]Siphon Life;[nomod]Malefic Rapture"
	Nm[6]="/use [mod:ctrl,nomod:alt]14\n/cast [mod:ctrl,nomod:alt]Dark Soul: Misery\n/cast [mod:ctrlalt,@focus]Seed of Corruption;[mod:ctrl]Summon Darkglare;[mod:alt,@mouseover]Corruption;[nomod]Phantom Singularity"
	Nm[7]="/cast [mod:ctrlalt,@focus]Phantom Singularity;[mod:ctrl,@cursor]Vile Taint;[mod:alt]Mortal Coil;[nomod,@mouseover]Siphon Life"
	Nm[8]="/cast [mod:ctrlalt]Dark Soul: Misery;[mod:ctrl]Scouring Tithe\n/petattack [nomod]\n/cancelaura [mod:alt,nomod:ctrl]Burning Rush"
	Nm[9]='/clearfocus [mod:ctrlalt]\n/stopmacro [mod:ctrlalt]\n/target [mod:alt]focus\n/clearfocus [mod:alt]\n/stopmacro [mod:alt]\n/focus [nomod]target\n/targetenemy [nomod][mod:ctrl]\n/run TMW_ST:UpdateCounter("tabtarget", 2);TMW_ST:UpdateCounter("justtabtarget", 1)'

	return Nm

end

--************************ Key Set Table
Key_Set={
	["IRODPS_LOCK_AFF_9_0_2_20"] = IRODPS_LOCK_AFF_9_0_2_20,
	}