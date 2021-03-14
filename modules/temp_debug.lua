--Next Interrupter!!!! V 1.4
--WORK Only counter interruptCounterName=1

interruptCounterName = "wantinterrupt"

--------CODE AERA-------------------

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





local currentSpec = GetSpecialization()
IROSpecID  = GetSpecializationInfo(currentSpec)

if not IROInterruptTier then
    IROInterruptTier = {}
    IROInterruptTier[71] = {'B','Pummel'} -- Arm
    IROInterruptTier[72] = {'B','Pummel'} -- fury
    IROInterruptTier[73] = {'A','Pummel'} -- Protection
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
------------------------------------
-----  function IROSendISM  -----
if not IROSendISM then
    IROSendISM = function(isForce,ForceInterruptStatus)
        local tGUID=(UnitGUID("target") or "error")
        
        local canInterrupt = ForceInterruptStatus
        
        if canInterrupt == nil then
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
end
------------------------------------
------  function IROOnEvent  --------

if not IROOnEvent then
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
    
end
------------------------------------
--------Setup Frame + INIT Var--------

IROTargetGUIDForInterrupt = ''
IROprefix = "IRODPS"
IROPlayerName = GetUnitName("player")

-- true = ready , false = not ready

OldcanInterruptStatus = true

IROInterrupterName = IROInterruptTier[IROSpecID][1].. '-'..IROPlayerName.. '-' ..GetRealmName()
IROInterruptSpellName = IROInterruptTier[IROSpecID][2]

IRODPSInterruptTable = {}

if IROFrame == nil then
    
    IROFrame = CreateFrame("Frame")
    IROFrame:RegisterEvent("CHAT_MSG_ADDON")
    IROFrame:SetScript("OnEvent", IROOnEvent)
    
    
    -- in combat event
    IROFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    -- out combat event
    -- IROFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    C_ChatInfo.RegisterAddonMessagePrefix(IROprefix)
    
    
end

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





