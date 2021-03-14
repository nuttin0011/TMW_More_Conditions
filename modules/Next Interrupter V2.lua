--Next Interrupter!!!! V 2.0
--WORK Only counter interruptCounterName=1

interruptCounterName = "wantinterrupt"

-- (not NextInterrupter) or NextInterrupter.IsMyTurn()
--------CODE AERA-------------------
if (not NextInterrupter) or (not NextInterrupter.Setuped) then
    NextInterrupter={}
    NextInterrupter.Setuped=false
    NextInterrupter.SpecID=nil
    NextInterrupter.myInterruptSpell=nil
    NextInterrupter.Tier=nil
    NextInterrupter.SpellName=nil
    NextInterrupter.Name=nil
    NextInterrupter.PlayerName=nil
    NextInterrupter.isWalock=nil
    NextInterrupter.Enabled=false
    NextInterrupter.ITable={}
    NextInterrupter.AddonMessagePrefix = "IRODPSUN"
    NextInterrupter.imInList=false
    NextInterrupter.canInterrupt=false
    NextInterrupter.TargetGUID=''
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
    NextInterrupter.IsMyTurn = function(nUnit)
        nUnit=nUnit or "target"
        local uGUID=UnitGUID(nUnit)
        return (not NextInterrupter.Enabled)
            or (not NextInterrupter.ITable[uGUID])
            or (next(NextInterrupter.ITable[uGUID])==nil)
            or (NextInterrupter.ITable[uGUID][1]==NextInterrupter.Name)
    end
    NextInterrupter.Enable = function()
        NextInterrupter.Enabled=true
        NextInterrupter.updateSpec()
        NextInterrupter.SendISM()
    end
    NextInterrupter.Disable = function()
        NextInterrupter.Enabled=false
        NextInterrupter.SendISM(false)
    end
    NextInterrupter.CheckAndSendISM = function()
        local SReady=GetSpellCooldown(NextInterrupter.SpellName) == 0
        local nUnit = "target"
        local tGUID=(UnitGUID(nUnit) or "0")
        local canInterrupt= SReady and (IsSpellInRange(NextInterrupter.SpellName, nUnit)==1)
        if  NextInterrupter.isWarlock then
            local iSpell=GetSpellInfo(NextInterrupter.SpellName)
            if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
            canInterrupt=false end
        end

        local willSend = false

        if tGUID~=NextInterrupter.TargetGUID then
            if (NextInterrupter.canInterrupt~=canInterrupt) or canInterrupt then
                willSend = true
            end
        end
        if NextInterrupter.canInterrupt~=canInterrupt then willSend = true end

        if willSend then
            NextInterrupter.SendISM(canInterrupt)
        end
    end
    NextInterrupter.SendISM = function(ForceInterruptStatus)
        print(GetTime().." SendedISM")
        local nUnit = "target"
        local tGUID=(UnitGUID(nUnit) or "0")
        local canInterrupt = ForceInterruptStatus
        if canInterrupt == nil then
            if NextInterrupter.SpellName == '' then
                canInterrupt=false
            else
                canInterrupt= (GetSpellCooldown(NextInterrupter.SpellName) == 0) and (IsSpellInRange(NextInterrupter.SpellName, nUnit)==1)
            end
            if  NextInterrupter.isWarlock then
                local iSpell=GetSpellInfo(NextInterrupter.SpellName)
                if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
                canInterrupt=false end
            end
        end
        NextInterrupter.canInterrupt=canInterrupt
        NextInterrupter.TargetGUID=tGUID
        local SendType = IsInInstance() and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or "WHISPER"))
        local SendTarget = NextInterrupter.PlayerName
        local Prefix = NextInterrupter.AddonMessagePrefix
        local SendMessage = (canInterrupt and 'CI^' or 'CN^')..NextInterrupter.Name.."^"..tGUID
        C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
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
        
        if m1 ~= NextInterrupter.AddonMessagePrefix then 
            --print(m1)
            return 0
        end

        local iaction,iname,iGUID = strsplit("^", m2,3)
        local iMobID,iIndex,ii,ifound

        if iname==NextInterrupter.Name then
            if (iaction=="CN") then
                NextInterrupter.imInList=false
            else
                NextInterrupter.imInList=true
            end
        end

        -- cannot interrupt / used interrupt skill
        
        if (iaction=="CN")or(iaction=="CI") then
            --print('if 1')
            for iMobID in pairs(NextInterrupter.ITable) do
                for iIndex in pairs(NextInterrupter.ITable[iMobID]) do
                    if NextInterrupter.ITable[iMobID][iIndex]==iname then
                        table.remove(NextInterrupter.ITable[iMobID],iIndex)
                        if next(NextInterrupter.ITable[iMobID])==nil then
                            NextInterrupter.ITable[iMobID]=nil
                        end
                        break
                    end 
                end
            end
        end
        
        if iaction == "CI" then
            --print('if 2')
            ifound=false
            iIndex=0
            if not NextInterrupter.ITable[iGUID] then
                NextInterrupter.ITable[iGUID]={}
            end
            for ii in pairs(NextInterrupter.ITable[iGUID]) do
                iIndex=ii
                if iname:sub(1,1) < NextInterrupter.ITable[iGUID][ii]:sub(1,1) then
                    ifound=true
                    break
                end
            end
            if not ifound then iIndex=iIndex+1 end
            table.insert(NextInterrupter.ITable[iGUID],iIndex,iname) 
        end
    end

    NextInterrupter.updateSpec()
    NextInterrupter.fspec = CreateFrame("Frame")
    NextInterrupter.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    NextInterrupter.fspec:SetScript("OnEvent", NextInterrupter.updateSpec)

    NextInterrupter.AddonMFrame = CreateFrame("Frame")
    NextInterrupter.AddonMFrame:RegisterEvent("CHAT_MSG_ADDON")
    NextInterrupter.AddonMFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    NextInterrupter.AddonMFrame:SetScript("OnEvent", NextInterrupter.AddonMessageEvent)
    C_ChatInfo.RegisterAddonMessagePrefix(NextInterrupter.AddonMessagePrefix)

    NextInterrupter.C_TimerHandle = C_Timer.NewTicker(0.1, function()  
        local cc=TMW_ST:GetCounter(interruptCounterName)
        if cc==0 then
            if NextInterrupter.Enabled then NextInterrupter.Disable() end
            return
        end
        if cc==1 then
            if not NextInterrupter.Enabled then NextInterrupter.Enable() end
            NextInterrupter.CheckAndSendISM()
        end
    end)

    NextInterrupter.Setuped=true
end