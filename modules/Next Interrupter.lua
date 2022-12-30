--Next Interrupter!!!! V 3.1
--WORK Only counter interruptCounterName=1
-- Set Priority to 10

InterruptCounterName = "wantinterrupt"

--[[ check use
(not NextInterrupter) or NextInterrupter.IsMyTurn()
]]
--------CODE AERA-------------------
TMW_ST:UpdateCounter(InterruptCounterName,1)
NextInterrupter={}

NextInterrupter.Watch="target"
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
NextInterrupter.CheckSyncRecive={}
NextInterrupter.interruptTier={
    [71] = {'B','Pummel'}, -- Arm
    [72] = {'B','Pummel'}, -- fury
    [73] = {'A','Pummel'}, -- Protection
--  [265] = {'D','Spell Lock'}, -- Aff 'Spell Lock'119910
--  [266] = {'D','Axe Toss'}, -- Demo 'Command Demon' 'Axe Toss'119914
--  [267] = {'D','Spell Lock'}, -- Dest 'Spell Lock'119910
    [265] = {'D','Command Demon'}, -- Aff 'Spell Lock'119910
    [266] = {'D','Command Demon'}, -- Demo 'Command Demon' 'Axe Toss'119914
    [267] = {'D','Command Demon'}, -- Dest 'Spell Lock'119910
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
function NextInterrupter.SyncCode()
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
function NextInterrupter.updateSpec()
    NextInterrupter.SpecID=GetSpecializationInfo(GetSpecialization())
    if not NextInterrupter.interruptTier[NextInterrupter.SpecID] then
        NextInterrupter.Tier="F"
        NextInterrupter.SpellName=""
    else
        NextInterrupter.Tier=NextInterrupter.interruptTier[NextInterrupter.SpecID][1]
        NextInterrupter.SpellName=NextInterrupter.interruptTier[NextInterrupter.SpecID][2]
        local spellID=select(7,GetSpellInfo(NextInterrupter.interruptTier[NextInterrupter.SpecID][2]))
        NextInterrupter.SpellID=spellID or 0
    end
    NextInterrupter.PlayerName=UnitName("player")..'-'..GetRealmName()
    NextInterrupter.Name=NextInterrupter.Tier..'-'..NextInterrupter.PlayerName
    NextInterrupter.isWarlock=(NextInterrupter.SpecID>=265)and(NextInterrupter.SpecID<=267)
    NextInterrupter.isWarrior=(NextInterrupter.SpecID>=71)and(NextInterrupter.SpecID<=73)
end
function NextInterrupter.IsMyTurn(nUnit)
    nUnit=nUnit or "target"
    local uGUID=UnitGUID(nUnit)
    return (not NextInterrupter.Enabled)
        or (not NextInterrupter.ITable[uGUID])
        or (next(NextInterrupter.ITable[uGUID])==nil)
        or (NextInterrupter.ITable[uGUID][1]==NextInterrupter.Name)
end
function NextInterrupter.Enable()
    if NextInterrupter.HasDebugAddon then
        NextInterrupter.AddDebugTextLog("*** NextInterrupter.Enable : "..GetTime())
    end
    NextInterrupter.Enabled=true
    NextInterrupter.updateSpec()
    NextInterrupter.SendISM()
end
function NextInterrupter.Disable()
    if NextInterrupter.HasDebugAddon then
        NextInterrupter.AddDebugTextLog("*** NextInterrupter.Disable : "..GetTime())
    end
    NextInterrupter.Enabled=false
    NextInterrupter.SendISM(false)
end
function NextInterrupter.CanIInterrupt()
    if UnitIsDead("player") then return false end
    --local SReady=GetSpellCooldown(NextInterrupter.SpellName) == 0
    local SReady=IsMyInterruptSpellReady()
    local canInterrupt= SReady and (IsSpellInRange(NextInterrupter.SpellName, NextInterrupter.Watch)==1)
    if canInterrupt and NextInterrupter.isWarlock then
        local iSpell=GetSpellInfo(NextInterrupter.SpellName)
        if (iSpell~='Axe Toss')and(iSpell~='Spell Lock') then
        canInterrupt=false end
    end
    if canInterrupt and NextInterrupter.isWarrior then
        local isBS = TMW.CNDT.Env.AuraDur("player", "bladestorm", "PLAYER HELPFUL")
        if isBS>0.1 then canInterrupt=false end
    end
    return canInterrupt
end
function NextInterrupter.CheckAndSendISM()
    local tGUID=(UnitGUID(NextInterrupter.Watch) or "0")
    local canInterrupt=NextInterrupter.CanIInterrupt()
    local willSend = false
    if tGUID~=NextInterrupter.TargetGUID then
        if (NextInterrupter.canInterrupt~=canInterrupt) or canInterrupt then willSend = true end
    else
        if NextInterrupter.canInterrupt~=canInterrupt then willSend = true end
    end
    if willSend then NextInterrupter.SendISM(canInterrupt) end
end
function NextInterrupter.SendISM(ForceInterruptStatus)
    if NextInterrupter.HasDebugAddon then NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime()) end
    local tGUID=(UnitGUID(NextInterrupter.Watch) or "0")
    local canInterrupt = ForceInterruptStatus or NextInterrupter.CanIInterrupt()
    NextInterrupter.canInterrupt=canInterrupt
    NextInterrupter.TargetGUID=tGUID
    local SendType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or "WHISPER"))
    local SendTarget = NextInterrupter.PlayerName
    local Prefix = NextInterrupter.AddonMessagePrefix
    local SendMessage = (canInterrupt and 'CI^' or 'CN^')..NextInterrupter.Name.."^"..tGUID
    if NextInterrupter.HasDebugAddon then NextInterrupter.AddDebugTextLog(">>>> "..SendType..' : "'..SendMessage..'"')end
    C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
end
function NextInterrupter.AddonMessageEvent(_, event, m1, m2)
    if (event=="PLAYER_REGEN_DISABLED") and NextInterrupter.Enabled then NextInterrupter.SendISM() end--froce send
    if event~="CHAT_MSG_ADDON" then return end
    if m1 ~= NextInterrupter.AddonMessagePrefix then return end
    if NextInterrupter.HasDebugAddon then
        NextInterrupter.AddDebugTextLog("\\\\ReciveISM : "..GetTime())
        NextInterrupter.AddDebugTextLog('<<<< "'..m2..'"')
    end
    local iaction,iname,iGUID = strsplit("^", m2,3)
    local iIndex,ifound
    if (iaction=="CK") then
        local SendType = "WHISPER"
        local SendTarget = iname
        local Prefix = NextInterrupter.AddonMessagePrefix
        local SendMessage = "CR^"..NextInterrupter.PlayerName.."^"..NextInterrupter.SyncCode()
        if NextInterrupter.HasDebugAddon then
            NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime())
            NextInterrupter.AddDebugTextLog(">>>> "..SendType..' : "'..SendMessage..'"')
        end
        C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
        return
    end
    if (iaction=="CR")and NextInterrupter.HasDebugAddon then
        NextInterrupter.CheckSyncRecive[iname]=iGUID
        NextInterrupter.updateTree(true)
        return
    end
    local TableEdited=false
    if (iaction=="CN")or(iaction=="CI") then
        for iMobID in pairs(NextInterrupter.ITable) do
            for iiIndex in pairs(NextInterrupter.ITable[iMobID]) do
                if NextInterrupter.ITable[iMobID][iiIndex]==iname then
                    TableEdited=true
                    table.remove(NextInterrupter.ITable[iMobID],iiIndex)
                    if next(NextInterrupter.ITable[iMobID])==nil then
                        NextInterrupter.ITable[iMobID]=nil end
                    break
    end end end end
    local inamesub11=iname:sub(1,1)
    if iaction == "CI" then
        ifound=false
        iIndex=0
        if not NextInterrupter.ITable[iGUID] then NextInterrupter.ITable[iGUID]={} end
        for ii in pairs(NextInterrupter.ITable[iGUID]) do
            iIndex=ii
            if inamesub11 < NextInterrupter.ITable[iGUID][ii]:sub(1,1) then
                ifound=true
                break
        end end
        if not ifound then iIndex=iIndex+1 end
        TableEdited=true
        table.insert(NextInterrupter.ITable[iGUID],iIndex,iname)
    end
    if NextInterrupter.HasDebugAddon then
        if TableEdited then
            NextInterrupter.AddDebugTextLog(GetTime().." Table Change")
            NextInterrupter.updateTree(true)
        else
            NextInterrupter.AddDebugTextLog(GetTime().." Table Not Change")
        end end
end
--Update all variable for 1st time
NextInterrupter.updateSpec()
NextInterrupter.fspec = CreateFrame("Frame")
NextInterrupter.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
NextInterrupter.fspec:SetScript("OnEvent", NextInterrupter.updateSpec)
NextInterrupter.AddonMFrame = CreateFrame("Frame")
NextInterrupter.AddonMFrame:RegisterEvent("CHAT_MSG_ADDON")
NextInterrupter.AddonMFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
NextInterrupter.AddonMFrame:SetScript("OnEvent", NextInterrupter.AddonMessageEvent)
C_ChatInfo.RegisterAddonMessagePrefix(NextInterrupter.AddonMessagePrefix)

function NextInterrupter.CheckTarget()
    local cc=TMW_ST:GetCounter(InterruptCounterName)
    if cc==1 then
        if not NextInterrupter.Enabled then NextInterrupter.Enable() end
        NextInterrupter.CheckAndSendISM()
    else
        if NextInterrupter.Enabled then NextInterrupter.Disable() end
    end
end
NextInterrupter.fCheck=CreateFrame("Frame")
NextInterrupter.fCheck:RegisterEvent("SPELL_UPDATE_COOLDOWN")
NextInterrupter.fCheck:RegisterEvent("SPELL_UPDATE_USABLE")
NextInterrupter.fCheck:RegisterEvent("PLAYER_TARGET_CHANGED")
NextInterrupter.fCheck:SetScript("OnEvent", NextInterrupter.CheckTarget)
--Set to Check Target Every 0.47 sec
NextInterrupter.C_TimerHandle = C_Timer.NewTicker(0.47, NextInterrupter.CheckTarget)


function NextInterrupter.ChangeWatch(nUnit)
    if UnitCastingInfo(nUnit) or UnitChannelInfo(nUnit) then
        NextInterrupter.Watch=nUnit
        NextInterrupter.CheckTarget()
    else
        NextInterrupter.Watch="target"
        NextInterrupter.CheckTarget()
    end
end

NextInterrupter.fStopCast=CreateFrame("Frame")
NextInterrupter.fStopCast:RegisterEvent("UNIT_SPELLCAST_STOP")
NextInterrupter.fStopCast:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
NextInterrupter.fStopCast:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
--NextInterrupter.fStopCast:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
NextInterrupter.fStopCast:SetScript("OnEvent", function(self,event,arg1,arg2,arg3)
    if arg1~="target" and arg1==NextInterrupter.Watch then
        NextInterrupter.Watch="target"
        NextInterrupter.CheckTarget()
    end
end)

IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("NextInterrupter",function(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags,
    sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName
    =...
    if subevent=="SPELL_CAST_SUCCESS" and spellName==NextInterrupter.SpellName then
        C_Timer.After(0.04,function()
            NextInterrupter.Watch="target"
            NextInterrupter.CheckTarget()
        end)
    end
end)

NextInterrupter.Setuped=true

--[[
UNIT_SPELLCAST_STOP
    arg1 UnitToken
    arg2 CastID
    arg3 SpellID
UNIT_SPELLCAST_CHANNEL_STOP
    arg1 UnitToken
    arg2 nil
    arg3 SpellID
UNIT_SPELLCAST_FAILED_QUIET
    arg1 UnitToken
    arg2 CastID
    arg3 SpellID
]]