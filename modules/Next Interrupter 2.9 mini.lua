--Next Interrupter!!!! V 2.9
InterruptCounterName="wantinterrupt"
TMW_ST:UpdateCounter(InterruptCounterName,1)
if not NextInterrupter then NextInterrupter={}end
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
NextInterrupter.AddonMessagePrefix="IRODPSUN"
NextInterrupter.canInterrupt=false
NextInterrupter.TargetGUID=''
NextInterrupter.CheckSyncRecive={}
NextInterrupter.interruptTier={
    [71]={'B','Pummel'},
    [72]={'B','Pummel'},
    [73]={'A','Pummel'},
    [265]={'D','Command Demon'},
    [266]={'D','Command Demon'},
    [267]={'D','Command Demon'},
    [262]={'C','Wind Shear'},
    [263]={'B','Wind Shear'},
    [264]={'D','Wind Shear'},
    [259]={'B','Kick'},
    [260]={'B','Kick'},
    [261]={'B','Kick'},
    [256]={'N',''},
    [257]={'N',''},
    [258]={'D','Silence'},
    [65]={'N',''},
    [66]={'A','Rebuke'},
    [70]={'B','Rebuke'},
    [268]={'A','Spear Hand Strike'},
    [270]={'N',''},
    [269]={'B','Spear Hand Strike'},
    [62]={'C','Counterspell'},
    [63]={'C','Counterspell'},
    [64]={'C','Counterspell'},
    [253]={'C','Counter Shot'},
    [254]={'C','Counter Shot'},
    [255]={'C','Muzzle'},
    [102]={'C','Solar Beam'},
    [103]={'B','Skull Bash'},
    [104]={'A','Skull Bash'},
    [105]={'N',''},
    [577]={'B','Disrupt'},
    [581]={'A','Disrupt'},
    [250]={'A','Mind Freeze'},
    [251]={'B','Mind Freeze'},
    [252]={'B','Mind Freeze'}
}

NextInterrupter.SyncCode=function()
    local a=0
    local function b(c)if not c then return 0 end
    local d=0
    local e=string.len(c)for f=1,e do d=d+string.byte(c,f)end
    a=a+1
    return e,d*a end
    local g=0
    local h=0
    for i,j in pairs(NextInterrupter.ITable)do local k,c=b(i)g=g+k
    h=h+c
    for l,m in pairs(j)do local n,o=b(m)g=g+n
    h=h+o end end
    return g..h
end

NextInterrupter.CompareTable=function(p,q)
    local function r(s,t)
        if not s or not t then return false end
        local u=true
        for i,j in pairs(s)do
            if type(j)=="table"then
                u=NextInterrupter.CompareTable(j,t[i])
                if not u then break end
            elseif u and j~=t[i]then
                u=false
                break
            end
        end

        return u
    end
    local v=r(p,q)
    if v then v=r(q,p)end
    return v
end

NextInterrupter.updateSpec=function()
    NextInterrupter.SpecID=GetSpecializationInfo(GetSpecialization())
    if not NextInterrupter.interruptTier[NextInterrupter.SpecID]then 
        NextInterrupter.Tier="F"
        NextInterrupter.SpellName=""
    else
        NextInterrupter.Tier=NextInterrupter.interruptTier[NextInterrupter.SpecID][1]
        NextInterrupter.SpellName=NextInterrupter.interruptTier[NextInterrupter.SpecID][2]
    end

    NextInterrupter.PlayerName=UnitName("player")..'-'..GetRealmName()
    NextInterrupter.Name=NextInterrupter.Tier..'-'..NextInterrupter.PlayerName
    NextInterrupter.isWarlock=NextInterrupter.SpecID>=265 and NextInterrupter.SpecID<=267
    NextInterrupter.isWarrior=NextInterrupter.SpecID>=71 and NextInterrupter.SpecID<=73
end

NextInterrupter.IsMyTurn=function(w)
    w=w or"target"
    local x=UnitGUID(w)
    return not NextInterrupter.Enabled 
    or not NextInterrupter.ITable[x]
    or next(NextInterrupter.ITable[x])==nil 
    or NextInterrupter.ITable[x][1]==NextInterrupter.Name
end

NextInterrupter.Enable=function()
    if NextInterrupter.HasDebugAddon then
        NextInterrupter.AddDebugTextLog("*** NextInterrupter.Enable : "..GetTime())
    end
    NextInterrupter.Enabled=true
    NextInterrupter.updateSpec()
    NextInterrupter.SendISM()
end

NextInterrupter.Disable=function()
    if NextInterrupter.HasDebugAddon then 
        NextInterrupter.AddDebugTextLog("*** NextInterrupter.Disable : "..GetTime())
    end
    NextInterrupter.Enabled=false
    NextInterrupter.SendISM(false)
end

NextInterrupter.CanIInterrupt=function()
    if UnitIsDead("player")then
        return false
    end
    local y=GetSpellCooldown(NextInterrupter.SpellName)==0
    local w="target"
    local z=y and IsSpellInRange(NextInterrupter.SpellName,w)==1
    if z and NextInterrupter.isWarlock then
        local A=GetSpellInfo(NextInterrupter.SpellName)
        if A~='Axe Toss'and A~='Spell Lock'then z=false end 
    end
    if z and NextInterrupter.isWarrior then 
        local B=TMW.CNDT.Env.AuraDur("player","bladestorm","PLAYER HELPFUL")
        if B>0.1 then
            z=false
        end
    end
    return z
end

NextInterrupter.CheckAndSendISM=function()
    local w="target"
    local C=UnitGUID(w)or"0"
    local z=NextInterrupter.CanIInterrupt()
    local D=false
    if C~=NextInterrupter.TargetGUID then
        if NextInterrupter.canInterrupt~=z or z then
            D=true end 
    else
        if NextInterrupter.canInterrupt~=z then
            D=true
        end
    end
    if D then
        NextInterrupter.SendISM(z)
    end
end

NextInterrupter.SendISM=function(E)
    if NextInterrupter.HasDebugAddon then 
        NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime())
    end
    local w="target"
    local C=UnitGUID(w)or"0"
    local z=E or NextInterrupter.CanIInterrupt()
    NextInterrupter.canInterrupt=z
    NextInterrupter.TargetGUID=C
    local F=IsInGroup(LE_PARTY_CATEGORY_INSTANCE)and"INSTANCE_CHAT"or(IsInRaid()and"RAID"or(IsInGroup()and"PARTY"or"WHISPER"))
    local G=NextInterrupter.PlayerName
    local H=NextInterrupter.AddonMessagePrefix
    local I=(z and'CI^'or'CN^')..NextInterrupter.Name.."^"..C
    if NextInterrupter.HasDebugAddon then 
        NextInterrupter.AddDebugTextLog(">>>> "..F..' : "'..I..'"')
    end
    C_ChatInfo.SendAddonMessage(H,I,F,G)
end

NextInterrupter.AddonMessageEvent=function(l,J,K,L)
    if J=="PLAYER_REGEN_DISABLED"and NextInterrupter.Enabled then 
        NextInterrupter.SendISM()
    end
    if J~="CHAT_MSG_ADDON"then 
        return 
    end
    if K~=NextInterrupter.AddonMessagePrefix then 
        return 
    end
    if NextInterrupter.HasDebugAddon then 
        NextInterrupter.AddDebugTextLog("\\\\ReciveISM : "..GetTime())
        NextInterrupter.AddDebugTextLog('<<<< "'..L..'"')
    end
    local M,N,O=strsplit("^",L,3)local P,Q
    if M=="CK"then 
        local F="WHISPER"
        local G=N
        local H=NextInterrupter.AddonMessagePrefix
        local I="CR^"..NextInterrupter.PlayerName.."^"..NextInterrupter.SyncCode()
        if NextInterrupter.HasDebugAddon then 
            NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime())
            NextInterrupter.AddDebugTextLog(">>>> "..F..' : "'..I..'"')
        end
        C_ChatInfo.SendAddonMessage(H,I,F,G)return
    end

    if M=="CR"and NextInterrupter.HasDebugAddon then
        NextInterrupter.CheckSyncRecive[N]=O
        NextInterrupter.updateTree(true)
        return
    end
    local R=false
    if M=="CN"or M=="CI"then 
        for S in pairs(NextInterrupter.ITable)do
            for T in pairs(NextInterrupter.ITable[S])do
                if NextInterrupter.ITable[S][T]==N then
                    R=true
                    table.remove(NextInterrupter.ITable[S],T)
                    if next(NextInterrupter.ITable[S])==nil then
                        NextInterrupter.ITable[S]=nil
                    end
                    break
                end
            end
        end
    end
    local U=N:sub(1,1)
    if M=="CI"then
        Q=false
        P=0
        if not NextInterrupter.ITable[O]then
            NextInterrupter.ITable[O]={}
        end
        for V in pairs(NextInterrupter.ITable[O])do P=V
        if U<NextInterrupter.ITable[O][V]:sub(1,1)then
            Q=true
            break
        end
    end
    if not Q then
        P=P+1
    end
    R=true
    table.insert(NextInterrupter.ITable[O],P,N)end
    if NextInterrupter.HasDebugAddon then 
        if R then
            NextInterrupter.AddDebugTextLog(GetTime().." Table Change")
            NextInterrupter.updateTree(true)
        else
            NextInterrupter.AddDebugTextLog(GetTime().." Table Not Change")
        end
    end
end

NextInterrupter.updateSpec()
NextInterrupter.fspec=CreateFrame("Frame")
NextInterrupter.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
NextInterrupter.fspec:SetScript("OnEvent",NextInterrupter.updateSpec)
NextInterrupter.AddonMFrame=CreateFrame("Frame")
NextInterrupter.AddonMFrame:RegisterEvent("CHAT_MSG_ADDON")
NextInterrupter.AddonMFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
NextInterrupter.AddonMFrame:SetScript("OnEvent",NextInterrupter.AddonMessageEvent)
C_ChatInfo.RegisterAddonMessagePrefix(NextInterrupter.AddonMessagePrefix)
NextInterrupter.C_TimerHandle=C_Timer.NewTicker(0.112,
function()
    local W=TMW_ST:GetCounter(InterruptCounterName)
    if W==1 then
        if not NextInterrupter.Enabled
        then NextInterrupter.Enable()
        end
        NextInterrupter.CheckAndSendISM()
    else
        if NextInterrupter.Enabled then
            NextInterrupter.Disable()
        end
    end
end)

NextInterrupter.Setuped=true
