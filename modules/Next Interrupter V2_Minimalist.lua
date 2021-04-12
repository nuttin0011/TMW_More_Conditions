--Next Interrupter!!!! V 2.8 Minimalist version
--, no Debug function
--WORK Only counter interruptCounterName=1

InterruptCounterName = "wantinterrupt"

--for check  -- (not NextInterrupter) or NextInterrupter.IsMyTurn(nUnit)
--------CODE AERA-------------------
TMW_ST:UpdateCounter(InterruptCounterName,1)
if not NextInterrupter then NextInterrupter={} end
if not NextInterrupter.Setuped then
    NextInterrupter.Setuped=false
    NextInterrupter.SpecID=nil
    NextInterrupter.Tier=nil
    NextInterrupter.SpellName=nil
    NextInterrupter.Name=nil
    NextInterrupter.PlayerName=nil
    NextInterrupter.isWarlock=nil
    NextInterrupter.isWarrior=nil
    NextInterrupter.Enabled=false
    NextInterrupter.ITable={}
    NextInterrupter.AddonMessagePrefix = "IRODPSUN"
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
        [70] = {'B','Rebuke'}, -- Ret
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
    NextInterrupter.SyncCode = function()
        local mul=0
        local function SumStr(s)
            if not s then return 0 end
            local sum=0
            local len=string.len(s)
            for i =1,len do
                sum=sum+string.byte(s,i)
            end
            mul=mul+1
            return len,(sum*mul)
        end
        local size = 0
        local checksum = 0
        for k,v in pairs(NextInterrupter.ITable) do
            local l,s = SumStr(k)
            size=size+l
            checksum=checksum+s
            for _,v2 in pairs(v) do
                local l2,s2 = SumStr(v2)
                size=size+l2
                checksum=checksum+s2
            end
        end
        return size..checksum
    end
    NextInterrupter.updateSpec = function()
        NextInterrupter.SpecID=GetSpecializationInfo(GetSpecialization())
        if not NextInterrupter.interruptTier[NextInterrupter.SpecID] then
            NextInterrupter.Tier="F"
            NextInterrupter.SpellName=""
        else
            NextInterrupter.Tier=NextInterrupter.interruptTier[NextInterrupter.SpecID][1]
            NextInterrupter.SpellName=NextInterrupter.interruptTier[NextInterrupter.SpecID][2]
        end
        NextInterrupter.PlayerName=UnitName("player")..'-'..GetRealmName()
        NextInterrupter.Name=NextInterrupter.Tier..'-'..NextInterrupter.PlayerName
        NextInterrupter.isWarlock=(NextInterrupter.SpecID>=265)and(NextInterrupter.SpecID<=267)
        NextInterrupter.isWarrior=(NextInterrupter.SpecID>=71)and(NextInterrupter.SpecID<=73)
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
        if canInterrupt and NextInterrupter.isWarlock then
            local iSpell=GetSpellInfo(NextInterrupter.SpellName)
            if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
            canInterrupt=false end
        end
        if canInterrupt and NextInterrupter.isWarrior then
            local isBS = TMW.CNDT.Env.AuraDur("player", "bladestorm", "PLAYER HELPFUL")
            if isBS>0.1 then canInterrupt=false end
        end
        local willSend = false
        if tGUID~=NextInterrupter.TargetGUID then
            if (NextInterrupter.canInterrupt~=canInterrupt) or canInterrupt then
                willSend = true
            end
        else
            if NextInterrupter.canInterrupt~=canInterrupt then willSend = true end
        end
        if willSend then
            NextInterrupter.SendISM(canInterrupt)
        end
    end
    NextInterrupter.SendISM = function(ForceInterruptStatus)
        local nUnit = "target"
        local tGUID=(UnitGUID(nUnit) or "0")
        local canInterrupt = ForceInterruptStatus
        if canInterrupt == nil then
            if NextInterrupter.SpellName == '' then
                canInterrupt=false
            else
                canInterrupt= (GetSpellCooldown(NextInterrupter.SpellName) == 0) and (IsSpellInRange(NextInterrupter.SpellName, nUnit)==1)
            end
            if canInterrupt and NextInterrupter.isWarlock then
                local iSpell=GetSpellInfo(NextInterrupter.SpellName)
                if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
                canInterrupt=false end
            end
            if canInterrupt and NextInterrupter.isWarrior then
                local isBS = TMW.CNDT.Env.AuraDur("player", "bladestorm", "PLAYER HELPFUL")
                if isBS>0.1 then canInterrupt=false end
            end
        end
        NextInterrupter.canInterrupt=canInterrupt
        NextInterrupter.TargetGUID=tGUID
        local SendType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or "WHISPER"))
        local SendTarget = NextInterrupter.PlayerName
        local Prefix = NextInterrupter.AddonMessagePrefix
        local SendMessage = (canInterrupt and 'CI^' or 'CN^')..NextInterrupter.Name.."^"..tGUID
        C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
    end
    NextInterrupter.AddonMessageEvent = function(self, event, ...)
        if event=="PLAYER_REGEN_DISABLED" then
            if NextInterrupter.Enabled then NextInterrupter.SendISM() end
        end
        if event~="CHAT_MSG_ADDON" then
            return 0
        end
        local m1,m2 = ...
        if m1 ~= NextInterrupter.AddonMessagePrefix then return 0 end
        local iaction,iname,iGUID = strsplit("^", m2,3)
        local iIndex,ifound
        if (iaction=="CK") then
            local SendType = "WHISPER"
            local SendTarget = iname
            local Prefix = NextInterrupter.AddonMessagePrefix
            local SendMessage = "CR^"..NextInterrupter.PlayerName.."^"..NextInterrupter.SyncCode()
            C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
            return
        end
        if (iaction=="CN")or(iaction=="CI") then
            for iMobID in pairs(NextInterrupter.ITable) do
                for iiIndex in pairs(NextInterrupter.ITable[iMobID]) do
                    if NextInterrupter.ITable[iMobID][iiIndex]==iname then
                        table.remove(NextInterrupter.ITable[iMobID],iiIndex)
                        if next(NextInterrupter.ITable[iMobID])==nil then
                            NextInterrupter.ITable[iMobID]=nil
                        end
                        break
        end end end end
        local inamesub11=iname:sub(1,1)
        if iaction == "CI" then
            ifound=false
            iIndex=0
            if not NextInterrupter.ITable[iGUID] then
                NextInterrupter.ITable[iGUID]={}
            end
            for ii in pairs(NextInterrupter.ITable[iGUID]) do
                iIndex=ii
                if inamesub11 < NextInterrupter.ITable[iGUID][ii]:sub(1,1) then
                    ifound=true
                    break
            end end
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
    NextInterrupter.C_TimerHandle = C_Timer.NewTicker(0.112, function()
        local cc=TMW_ST:GetCounter(InterruptCounterName)
        if cc==1 then
            if not NextInterrupter.Enabled then NextInterrupter.Enable() end
            NextInterrupter.CheckAndSendISM()
        else
            if NextInterrupter.Enabled then NextInterrupter.Disable() end
        end
    end)
    NextInterrupter.Setuped=true
end