--Next Interrupter!!!! V 1.4
--WORK Only counter interruptCounterName=1

interruptCounterName = "wantinterrupt"

--------CODE AERA-------------------
NextInterrupter={}
NextInterrupter.SpecID=nil
NextInterrupter.myInterruptSpell=nil
NextInterrupter.Tier=nil
NextInterrupter.SpellName=nil
NextInterrupter.Name=nil
NextInterrupter.PlayerName=nil
NextInterrupter.isWalock=nil
NextInterrupter.ITable={}
NextInterrupter.AddonMessagePrefix = "IRODPSUN"
NextInterrupter.interruptTier={
    [71] = {'B','Pummel'}, -- Arm
    [72] = {'B','Pummel'}, -- fury
    [73] = {'A','Pummel'}, -- Protection
    [265] = {'D','Command Demon'}, -- Aff [Spell Lock]
    [266] = {'D','Command Demon'}, -- Demo
    [267] = {'D','Command Demon'}, -- Dest
    [262] = {'C','Wind Shear'}, -- Element
    [263] = {'B','Wind Shear'}, -- Enha
    [264] = {'D','Wind Shear'}, -- Resto
    [259] = {'B','Kick'}, -- Ass
    [260] = {'B','Kick'}, -- Out
    [261] = {'B','Kick'}, -- Sub
    [256] = {'N',''}, -- Disc
    [257] = {'N',''}, -- Holy
    [258] = {'D','Silence'}, -- Shadow
    [65] = {'N',''}, -- Holy
    [66] = {'A','Rebuke'}, -- Port
    [67] = {'B','Rebuke'}, -- Ret
    [268] = {'A','Spear Hand Strike'}, -- Brewmaster
    [270] = {'N',''}, -- Mistweaver
    [269] = {'B','Spear Hand Strike'}, -- Windwalker
    [62] = {'C','Counterspell'}, -- arcane
    [63] = {'C','Counterspell'}, -- fire
    [64] = {'C','Counterspell'}, -- frost
    [253] = {'C','Counter Shot'}, -- Beast Mastery
    [254] = {'C','Counter Shot'}, -- Marksmanship
    [255] = {'C','Muzzle'}, -- Survival
    [102] = {'C','Solar Beam'}, -- Balance
    [103] = {'B','Skull Bash'}, -- Feral
    [104] = {'A','Skull Bash'}, -- Guardian
    [105] = {'N',''}, -- Restoration
    [577] = {'B','Disrupt'}, -- Havoc
    [581] = {'A','Disrupt'}, -- Vengeance
    [250] = {'A','Mind Freeze'}, -- Blood
    [251] = {'B','Mind Freeze'}, -- frost
    [252] = {'B','Mind Freeze'}, -- unholy
}
NextInterrupter.updateSpec = function()
    NextInterrupter.SpecID=GetSpecializationInfo(GetSpecialization())
    NextInterrupter.Tier=NextInterrupter.interruptTier[NextInterrupter.SpecID][1]
    NextInterrupter.SpellName=NextInterrupter.interruptTier[NextInterrupter.SpecID][2]
    NextInterrupter.PlayerName=UnitName("player")
    NextInterrupter.Name=NextInterrupter.Tier..'-'..NextInterrupter.PlayerName..'-'..GetRealmName()
    NextInterrupter.isWarlock=(NextInterrupter.SpecID>=265)and(NextInterrupter.SpecID<=267)
end
NextInterrupter.SendISM = function(ForceInterruptStatus)
    local tGUID=(UnitGUID("target") or "0")
    local canInterrupt = ForceInterruptStatus
    if canInterrupt == nil then
        if NextInterrupter.SpellName == '' then
            canInterrupt=false
        else
            canInterrupt= (GetSpellCooldown(NextInterrupter.SpellName) == 0) and (IsSpellInRange(NextInterrupter.SpellName, "target")==1)
        end
        if  NextInterrupter.isWarlock then
            local iSpell=GetSpellInfo(NextInterrupter.SpellName)
            if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
            canInterrupt=false end
        end
    end
    local SendType = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or "WHISPER")
    local SendTarget = NextInterrupter.PlayerName
    local Prefix = NextInterrupter.AddonMessagePrefix
    local SendMessage = (canInterrupt and 'CI^' or 'CN^')..NextInterrupter.Name.."^"..tGUID
    C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
--[[
    if canInterrupt then
        if IsInRaid() then        
            C_ChatInfo.SendAddonMessage(NextInterrupter.AddonMessagePrefix, 'CI^'..NextInterrupter.Name.."^"..tGUID, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage(NextInterrupter.AddonMessagePrefix, 'CI^'..NextInterrupter.Name.."^"..tGUID, "PARTY")
        else
            C_ChatInfo.SendAddonMessage(NextInterrupter.AddonMessagePrefix, 'CI^'..NextInterrupter.Name.."^"..tGUID, "WHISPER", NextInterrupter.PlayerName)
        end
    end
    if not canInterrupt then
        if IsInRaid() then        
            C_ChatInfo.SendAddonMessage("IRODPSUN", 'CN^'..NextInterrupter.Name.."^0", "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("IRODPSUN", 'CN^'..NextInterrupter.Name.."^0", "PARTY")
        else
            C_ChatInfo.SendAddonMessage("IRODPSUN", 'CN^'..NextInterrupter.Name.."^0", "WHISPER", NextInterrupter.PlayerName)
        end
    end
    --]]
end

NextInterrupter.AddonMessageEvent = function(self, event, ...)
    --print(event)
    
    if event=="PLAYER_REGEN_DISABLED" then
        -- incombat event
        --print('in in')
        -- force send message
        NextInterrupter.SendISM()
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



NextInterrupter.updateSpec()
NextInterrupter.fspec = CreateFrame("Frame")
NextInterrupter.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
NextInterrupter.fspec:SetScript("OnEvent", NextInterrupter.updateSpec)

NextInterrupter.AddonMFrame = CreateFrame("Frame")
NextInterrupter.AddonMFrame:RegisterEvent("CHAT_MSG_ADDON")
IROFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
NextInterrupter.AddonMFrame:SetScript("OnEvent", NextInterrupter.AddonMessageEvent)
C_ChatInfo.RegisterAddonMessagePrefix(NextInterrupter.AddonMessagePrefix)








oldInterruptCounterStatus=false
sendedIROSendISMafterNoMobExists=false
interruptCounterON=false

if not IRO_Smart_Interrupt_C_TimerHandle then
    IRO_Smart_Interrupt_C_TimerHandle = C_Timer.NewTicker(0.1, function()
            
            local cc
            
            if (not UnitExists("target"))
            or(not UnitCanAttack("player", "target"))
            or UnitIsDead("target")
            or(not IsItemInRange("item:28767", "target"))
            then
                --print("Leave .. out of range")
                if not sendedIROSendISMafterNoMobExists then
                    IROSendISM(true,false)
                    sendedIROSendISMafterNoMobExists=true
                end
                return 1
            else
                cc=TMW_ST:GetCounter(interruptCounterName)
                if cc==1 then
                    --print("enter ... smart interrupt")
                    interruptCounterON=true
                    oldInterruptCounterStatus=true
                    sendedIROSendISMafterNoMobExists=false
                    IROSendISM()
                else
                    --print("leave ... counter off")
                    interruptCounterON=false
                    if oldInterruptCounterStatus then
                        IROSendISM(true,false)
                        oldInterruptCounterStatus=false
                    end
                end
            end
    end)
end

------------------------------------
-----  function IROSendISM  -----
if not IROSendISM then
    
end
------------------------------------
------  function IROOnEvent  --------

if not IROOnEvent then
   
    
end
------------------------------------
--------Setup Frame + INIT Var--------

IROTargetGUIDForInterrupt = ''
IROprefix = "IRODPS"
IROPlayerName = GetUnitName("player")

-- true = ready , false = not ready

OldcanInterruptStatus = true

IRODPSInterruptTable = {}

if not IsMyTurnToInterrupt then
    IsMyTurnToInterrupt=function()
        return (not interruptCounterON) or
        (not IROInterrupterName) or 
        (not IRODPSInterruptTable) or 
        (not IRODPSInterruptTable[UnitGUID("target")]) or 
        (next(IRODPSInterruptTable[UnitGUID("target")])==nil) or 
        (IRODPSInterruptTable[UnitGUID("target")][1] == IROInterrupterName)
    end
end

-------------------EOF---------------------





