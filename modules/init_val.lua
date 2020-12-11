local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local _UnitAura = UnitAura
local _UnitExists = UnitExists
local _UnitAffectingCombat = UnitAffectingCombat
local _UnitHealth = UnitHealth
local _GetSpecialization = GetSpecialization
local _GetSpecializationInfo  = GetSpecializationInfo

local CNDT = TMW.CNDT
local Env = CNDT.Env
local GetRealmName=GetRealmName


local function printtable(a)
	local k,v
	for k,v in pairs(a) do
		print(k,v)
	end
    return 0        
end

IRO_Old_Val = {[1]=0,[2]={}}
-- IRO_Old_Val = {[1] = Timer , [2] = functionName = {[input_val_string] = [result_val]}}


function Env.Old_Val_Check(functionName,input_val_string)
    -- return old value if GetTime and input_val_string is the same
    -- return nil if we must re calculate.
    local currenTimer=_GetTime()
    --print("check at : "..currenTimer)
    if IRO_Old_Val[1]==currenTimer then
        if IRO_Old_Val[2][functionName] and IRO_Old_Val[2][functionName][input_val_string] then
            return IRO_Old_Val[2][functionName][input_val_string]
        end
    end

    return nil
end


function Env.Old_Val_Update(functionName,input_val_string,result_val)
    local currenTimer = GetTime()
    --print("update at : "..currenTimer)
    if IRO_Old_Val[1] < currenTimer then
        IRO_Old_Val[1] = currenTimer
        IRO_Old_Val[2] = {}
    end

    if not IRO_Old_Val[2][functionName] then 
        IRO_Old_Val[2][functionName]={} 
    end

    if not IRO_Old_Val[2][functionName][input_val_string] then 
        IRO_Old_Val[2][functionName][input_val_string]=result_val 
    end

    return true
end


if not IROInterruptTier then
    IROInterruptTier = {}
    IROInterruptTier[71] = {'B','Pummel'} -- Arm
    IROInterruptTier[72] = {'B','Pummel'} -- fury
    IROInterruptTier[72] = {'A','Pummel'} -- Protection
    IROInterruptTier[265] = {'D','Command Demon'} -- Aff [Spell Lock]
    IROInterruptTier[266] = {'D','Command Demon'} -- Demo
    IROInterruptTier[267] = {'D','Command Demon'} -- Dest
    IROInterruptTier[262] = {'C','Wind Shear'} -- Element
    IROInterruptTier[263] = {'B','Wind Shear'} -- Enha
    IROInterruptTier[264] = {'D','Wind Shear'} -- Resto
    IROInterruptTier[259] = {'B','Kick'} -- Ass
    IROInterruptTier[260] = {'B','Kick'} -- Out
    IROInterruptTier[261] = {'B','Kick'} -- Sub
    IROInterruptTier[256] = {'N',''} -- Disc
    IROInterruptTier[257] = {'N',''} -- Holy
    IROInterruptTier[258] = {'D','Silence'} -- Shadow
    IROInterruptTier[65] = {'N',''} -- Holy
    IROInterruptTier[66] = {'A','Rebuke'} -- Port
    IROInterruptTier[67] = {'B','Rebuke'} -- Ret
    IROInterruptTier[268] = {'A','Spear Hand Strike'} -- Brewmaster
    IROInterruptTier[270] = {'N',''} -- Mistweaver
    IROInterruptTier[269] = {'B','Spear Hand Strike'} -- Windwalker
    IROInterruptTier[62] = {'C','Counterspell'} -- arcane
    IROInterruptTier[63] = {'C','Counterspell'} -- fire
    IROInterruptTier[64] = {'C','Counterspell'} -- frost
    IROInterruptTier[253] = {'C','Counter Shot'} -- Beast Mastery
    IROInterruptTier[254] = {'C','Counter Shot'} -- Marksmanship
    IROInterruptTier[255] = {'C','Muzzle'} -- Survival
    IROInterruptTier[102] = {'C','Solar Beam'} -- Balance
    IROInterruptTier[103] = {'B','Skull Bash'} -- Feral
    IROInterruptTier[104] = {'A','Skull Bash'} -- Guardian
    IROInterruptTier[105] = {'N',''} -- Restoration
    IROInterruptTier[577] = {'B','Disrupt'} -- Havoc
    IROInterruptTier[581] = {'A','Disrupt'} -- Vengeance
    IROInterruptTier[250] = {'A','Mind Freeze'} -- Blood
    IROInterruptTier[251] = {'B','Mind Freeze'} -- frost
    IROInterruptTier[252] = {'B','Mind Freeze'} -- unholy
end

if not CleanTypeZZ then
    CleanTypeZZ = {}
    CleanTypeZZ[71] = {0,0,0,0,''} -- Arm
    CleanTypeZZ[72] = {0,0,0,0,''} -- fury
    CleanTypeZZ[72] = {0,0,0,0,''} -- Protection
    CleanTypeZZ[265] = {20,0,0,0,'Singe Magic'} -- Aff
    CleanTypeZZ[266] = {20,0,0,0,'Singe Magic'} -- Demo
    CleanTypeZZ[267] = {20,0,0,0,'Singe Magic'} -- Dest
    CleanTypeZZ[262] = {0,0,0,20,'Cleanse Spirit'} -- Element
    CleanTypeZZ[263] = {0,0,0,20,'Cleanse Spirit'} -- Enha
    CleanTypeZZ[264] = {20,0,0,20,'Purify Spirit'} -- Resto
    CleanTypeZZ[259] = {0,0,0,0,''} -- Ass
    CleanTypeZZ[260] = {0,0,0,0,''} -- Out
    CleanTypeZZ[261] = {0,0,0,0,''} -- Sub
    CleanTypeZZ[256] = {20,20,0,0,'Purify'} -- Disc
    CleanTypeZZ[257] = {20,20,0,0,'Purify'} -- Holy
    CleanTypeZZ[258] = {0,20,0,0,'Purify Disease'} -- Shadow
    CleanTypeZZ[65] = {20,20,20,0,'Cleanse'} -- Holy
    CleanTypeZZ[66] = {0,20,20,0,'Cleanse Toxins'} -- Port
    CleanTypeZZ[67] = {0,20,20,0,'Cleanse Toxins'} -- Ret
    CleanTypeZZ[268] = {0,20,20,0,'Detox'} -- Brewmaster
    CleanTypeZZ[270] = {20,20,20,0,'Detox'} -- Mistweaver
    CleanTypeZZ[269] = {0,20,20,0,'Detox'} -- Windwalker
    CleanTypeZZ[62] = {0,0,0,20,'Remove Curse'} -- arcane
    CleanTypeZZ[63] = {0,0,0,20,'Remove Curse'} -- fire
    CleanTypeZZ[64] = {0,0,0,20,'Remove Curse'} -- frost
    CleanTypeZZ[253] = {0,0,0,0,''} -- Beast Mastery
    CleanTypeZZ[254] = {0,0,0,0,''} -- Marksmanship
    CleanTypeZZ[255] = {0,0,0,0,''} -- Survival
    CleanTypeZZ[102] = {0,0,20,20,'Remove Corruption'} -- Balance
    CleanTypeZZ[103] = {0,0,20,20,'Remove Corruption'} -- Feral
    CleanTypeZZ[104] = {0,0,20,20,'Remove Corruption'} -- Guardian
    CleanTypeZZ[105] = {20,0,20,20,"Nature's Cure"} -- Restoration
    CleanTypeZZ[577] = {0,0,0,0,''} -- Havoc
    CleanTypeZZ[581] = {0,0,0,0,''} -- Vengeance
    CleanTypeZZ[250] = {0,0,0,0,''} -- Blood
    CleanTypeZZ[251] = {0,0,0,0,''} -- frost
    CleanTypeZZ[252] = {0,0,0,0,''} -- unholy
end

function Env.GetMyCleanType()

    local currentSpec = _GetSpecialization()
    local IROSpecID  = _GetSpecializationInfo(currentSpec)
    -- return Magic,Disease,Poison,Curse penalty  
    if not currentSpec then
        return 0,0,0,0
    end
    local M,D,P,C,SpellName
    --print("Your current spec:", currentSpecName,Specid)
    if CleanTypeZZ[IROSpecID] then
        M=CleanTypeZZ[IROSpecID][1]
        D=CleanTypeZZ[IROSpecID][2]
        P=CleanTypeZZ[IROSpecID][3]
        C=CleanTypeZZ[IROSpecID][4]
        SpellName=CleanTypeZZ[IROSpecID][5]
    else
        M=0
        D=0
        P=0
        C=0
        SpellName=''
    end
    return M,D,P,C,SpellName
end

function Env.CheckDebuffAuraType(unit)
    -- return Magic, Disease, Poison, Curse (ture/false)
    local DMagic = false
    local DDisease = false
    local DPoison = false
    local DCurse = false
    local i
    
    local buffName,debuffType
    for i = 1, 40 do
        buffName, _, _, debuffType= _UnitAura(unit, i, "HARMFUL")
        if not buffName then break end
        if debuffType=="Magic" then DMagic = true end
        if debuffType=="Disease"then DDisease = true end
        if debuffType=="Poison" then DPoison = true end
        if debuffType=="Curse" then DCurse = true end
    end
    
    return  DMagic, DDisease, DPoison, DCurse
end

function Env.SumHPMobinCombat()

    local Old_Val = Env.Old_Val_Check("SumHPMobinCombat","")
    if Old_Val then return Old_Val end
    
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if _UnitExists(nn) and _UnitAffectingCombat(nn) then
            sumhp=sumhp+ _UnitHealth(nn)
        end
    end

    Env.Old_Val_Update("SumHPMobinCombat","",sumhp)

    return sumhp
end

--*****************************************Smart Interrupter*********************

local OldcanInterruptStatus = true

IROTargetGUIDForInterrupt = ''
IROprefix = "IRODPS"
IROPlayerName = GetUnitName("player")
IRORealmName=GetRealmName()
IRODPSInterruptTable = {}

IROSendISM = function(isForce)
    local tGUID=(UnitGUID("target") or "error")

    local currentSpec = _GetSpecialization()
    local IROSpecID  = _GetSpecializationInfo(currentSpec)

    local IROInterrupterName = IROInterruptTier[IROSpecID][1].. '-'..IROPlayerName.. '-' ..GetRealmName()
    local IROInterruptSpellName = IROInterruptTier[IROSpecID][2]
    
    local canInterrupt
    if IROInterruptSpellName == '' then
        canInterrupt=false
    else
        canInterrupt= (GetSpellCooldown(IROInterruptSpellName) == 0) and (IsSpellInRange(IROInterruptSpellName, "target")==1)
    end
    
    if (IROSpecID>=265)and(IROSpecID<=267) then
        --Warlock
        local iSpell=GetSpellInfo(IROInterruptSpellName)
        if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
        canInterrupt=false end
    end
    
    if (((tGUID~= IROTargetGUIDForInterrupt) and canInterrupt)or ((not OldcanInterruptStatus)or isForce)and canInterrupt) then
        OldcanInterruptStatus = true
        IROTargetGUIDForInterrupt=tGUID
        if IsInRaid() then        
            C_ChatInfo.SendAddonMessage("IRODPS", 'CI^'..IROInterrupterName.."^"..tGUID, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("IRODPS", 'CI^'..IROInterrupterName.."^"..tGUID, "PARTY")
        else
            C_ChatInfo.SendAddonMessage("IRODPS", 'CI^'..IROInterrupterName.."^"..tGUID, "WHISPER", IROPlayerName)
        end
    end
    
    if (OldcanInterruptStatus or isForce) and (not canInterrupt) then
        OldcanInterruptStatus = false
        if IsInRaid() then        
            C_ChatInfo.SendAddonMessage("IRODPS", 'CN^'..IROInterrupterName.."^".."0", "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("IRODPS", 'CN^'..IROInterrupterName.."^".."0", "PARTY")
        else
            C_ChatInfo.SendAddonMessage("IRODPS", 'CN^'..IROInterrupterName.."^".."0", "WHISPER", IROPlayerName)
        end
    end
end

IROOnEvent = function(self, event, ...)
    --print(event)
    
    if event=="PLAYER_REGEN_DISABLED" then
        -- incombat event
        --print('in in')
        if IROSendISM then
            -- force send message
            IROSendISM(true)
        end
    end
    
    if event~="CHAT_MSG_ADDON" then
        return 0
    end
    
    --print(GetTime())
    local m1,m2 = ...
    --m1 = "IRODPS"
    --m2 = CI/CN+^+interruptTier+-+CharactorName+^+GUIDmob
    -- CI = can interrupt
    -- CN = cannot interrupt
    --exp 'CI^A-Kimiiro^Creature-0-3933-1-153258-0002AC77A2'
    --
    --IRODPSInterruptTable = {
    -- ['GUIDMob1'] = { 'PlayerName1','PlayerName2'....}
    -- ['GUIDMob2'] = { 'PlayerName1','PlayerName2'....}
    -- .... }
    
    if m1 ~= IROprefix then 
        --print(m1)
        return 0
    end
    
    if not IRODPSInterruptTable then
        IRODPSInterruptTable = {}
    end
    
    local iaction,iname,iGUID = strsplit("^", m2,3)
    local iMobID,iIndex,ii,ifound
    
    -- cannot interrupt / used interrupt skill
    
    if (iaction=="CN")or(iaction=="CI") then
        --print('if 1')
        
        for iMobID in pairs(IRODPSInterruptTable) do
            for iIndex in pairs(IRODPSInterruptTable[iMobID]) do
                if IRODPSInterruptTable[iMobID][iIndex]==iname then
                    table.remove(IRODPSInterruptTable[iMobID],iIndex)
                    if next(IRODPSInterruptTable[iMobID])==nil then
                        IRODPSInterruptTable[iMobID]=nil
                    end
                    break
                end 
            end
        end
    end
    
    if iaction == "CI" then
        --print('if 2')
        
        if not IRODPSInterruptTable[iGUID] then
            IRODPSInterruptTable[iGUID]={}
        end
        ifound=false
        iIndex=0
        for ii in pairs(IRODPSInterruptTable[iGUID]) do
            iIndex=ii
            if iname:sub(1,1) < IRODPSInterruptTable[iGUID][ii]:sub(1,1) then
                ifound=true
                break
            end
        end
        if not ifound then iIndex=iIndex+1 end
        table.insert(IRODPSInterruptTable[iGUID],iIndex,iname) 
    end
    
    --print(iaction)
    --print(iname)
    --print(iGUID)
    --print(m1)
    --print(m2)
    
    return 1
end

IROFrame = CreateFrame("Frame")
IROFrame:RegisterEvent("CHAT_MSG_ADDON")
IROFrame:SetScript("OnEvent", IROOnEvent)

-- in combat event
IROFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
-- out combat event
-- IROFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
C_ChatInfo.RegisterAddonMessagePrefix(IROprefix)

--[[
local f = CreateFrame("Frame");
function f:onUpdate(sinceLastUpdate)
	self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if ( self.sinceLastUpdate >= 0.5 ) then -- in seconds
        --print(sinceLastUpdate)
        IROSendISM()
        -- do stuff here
		self.sinceLastUpdate = 0;
	end
end
f:SetScript("OnUpdate",f.onUpdate)
--]]

local Old_Timer_Send_AddonMessage_IsMyTurnToInterrupt = 0;

function Env.IsMyTurnToInterrupt(isForce)
    local currentSpec = _GetSpecialization()
    local IROSpecID  = _GetSpecializationInfo(currentSpec)
	
	
    local IROInterrupterName = IROInterruptTier[IROSpecID][1].. '-'..IROPlayerName.. '-' ..IRORealmName
	
	local currenTimer=GetTime()
    		
	if (currenTimer - Old_Timer_Send_AddonMessage_IsMyTurnToInterrupt >= 0.4) or isForce then
		-- send Addon Message every 0.4 seconds
		Old_Timer_Send_AddonMessage_IsMyTurnToInterrupt = currenTimer
		--print("send Addon Message")
		IROSendISM()
	end
	
    return (not IRODPSInterruptTable)
    or (not IRODPSInterruptTable[UnitGUID("target")])
    or (next(IRODPSInterruptTable[UnitGUID("target")])==nil)
    or (IRODPSInterruptTable[UnitGUID("target")][1] == IROInterrupterName)
end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMC", 12, "More Conditions", true, false)

ConditionCategory:RegisterCondition(6,  "TMWMCISMYTURNTOINTERRUPT", {
    text = "Is my turn to insterrupt?",
	tooltip = "check queue interrupt from Every one that has this function\nThis function send Addon Message to Party/Raid and Auto Queue for you.",
	unit="player",
	noslide = true,
	nooperator = true,
    icon = "Interface\\Icons\\spell_nature_rejuvenation",
    tcoords = CNDT.COMMON.standardtcoords,

	funcstr = function(c, parent)
		
		return [[IsMyTurnToInterrupt(false)]]
    end,	

})

