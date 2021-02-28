
-- this file save many function for paste to TMW Snippet LUA

--function IROEnemyCountIn8yd(Rlevel) ; return count
--function PercentCastbar(PercentCast, MustInterruptAble, MaxTMS, MinTMS,nUnit) ; return true/false
--function IsMyTurnToInterrupt() ; return true/false
--function GCDActiveLessThan(ttime) ; return true/false
--function SumHPMobinCombat() ; return SumHP
--function SumHPMobin8yd() ; return SumHP
--function IROTargetVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<targetHealth
--function IROEnemyGroupVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<EnemyGroupHP

function TMW.CNDT.Env.IRODPSversion()

    print('ERO DPS template 9.0.2/1c ')
    
    return  true
end

local ItemRangeCheck = {
    [1]=34368, -- Attuned Crystal Cores 8 yard
    [2]=33069, -- Sturdy Rope 15 yard
    [3]=10645, -- Gnomish Death Ray 20 yard
    [4]=835, -- Large Rope Net 30 yard
    [5]=28767, -- The Decapitator 40 yard
    [6]=32321, -- Sparrowhawk Net 10 yard
}
local ItemNameToCheck8 = "item:"..ItemRangeCheck[1]
function IROEnemyCountIn8yd(Rlevel)
    --return enemy count in Range Default 8 yard Max 8
    Rlevel = Rlevel or 0
    --Rlevel 0=8,1=15,2=20,3=30,4=40,5=10 yard
    local ItemNameToCheck = "item:"..ItemRangeCheck[Rlevel+1]
    local i,nn,count
    local count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player", nn) then
            if IsItemInRange(ItemNameToCheck8, nn)or(UnitAffectingCombat(nn)and IsItemInRange(ItemNameToCheck, nn)) then
                count=count+1
            end
        end
        if count>=8 then break end
    end
    return  count
end

function PercentCastbar(PercentCast, MustInterruptAble, MaxTMS, MinTMS,nUnit)
    nUnit=nUnit or "target"
    PercentCast = PercentCast or 0.8
    if MustInterruptAble == nil then MustInterruptAble = true end
    MaxTMS = MaxTMS or 2000
    MinTMS = MinTMS or 800
    local castingName, _, _, startTimeMS, endTimeMS, _, _, notInterruptible= UnitCastingInfo(nUnit)
    
    local wantInterrupt = false
    
    if (castingName ~= nil) and(not(notInterruptible and MustInterruptAble)) then
        local totalcastTime = endTimeMS-startTimeMS
        local currentcastTime = (GetTime()*1000)-startTimeMS       
        
        if (totalcastTime-currentcastTime)>MaxTMS then
            -- if cast time > MaxTMS ms dont interrupt
            wantInterrupt = false
        elseif (totalcastTime-currentcastTime)<MinTMS then 
            -- if cast time < MinTMS ms dont interrupt
            wantInterrupt = true
        else
            local percentcastTime = currentcastTime/totalcastTime
            wantInterrupt = percentcastTime >= PercentCast
        end
        return  wantInterrupt
    end
    local channelName, _, _, CstartTimeMS, CendTimeMS,_, CnotInterruptible= UnitChannelInfo(nUnit) 
    if (channelName ~= nil) and (not (CnotInterruptible and MustInterruptAble)) then
        PercentCast = 1-PercentCast
        local totalcastTime = CendTimeMS-CstartTimeMS
        local currentcastTime = (GetTime()*1000)-CstartTimeMS 
        if (currentcastTime>=MinTMS) and (currentcastTime<=totalcastTime-MinTMS) then
            -- dont interrupt when cast < MinTMS and nerly finish
            local percentcastTime = currentcastTime/totalcastTime
            wantInterrupt = percentcastTime >= PercentCast
    end end
    return  wantInterrupt
end

----------------------------------------------------------------------------------
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
    IROSendISM = function(isForce)
        local tGUID=(UnitGUID("target") or "error")

        local currentSpec = GetSpecialization()
        IROSpecID  = GetSpecializationInfo(currentSpec)

        IROInterrupterName = IROInterruptTier[IROSpecID][1].. '-'..IROPlayerName.. '-' ..GetRealmName()
        IROInterruptSpellName = IROInterruptTier[IROSpecID][2]

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

if not IROC_TimerHandle then
    IROC_TimerHandle = C_Timer.NewTicker(0.2, function() 
            if IROSendISM and UnitExists("target") and UnitCanAttack("player", "target") and IsItemInRange("item:28767", "target") then
                IROSendISM()
            end
        end)
end

-------------------EOF---------------------

function IsMyTurnToInterrupt()
    return (not IROInterrupterName) or 
    (not IRODPSInterruptTable) or 
    (not IRODPSInterruptTable[UnitGUID("target")]) or 
    (next(IRODPSInterruptTable[UnitGUID("target")])==nil) or 
    (IRODPSInterruptTable[UnitGUID("target")][1] == IROInterrupterName)
end


function GCDActiveLessThan(ttime)
    ttime = ttime or 0.2
    local s,d = GetSpellCooldown(TMW.GCDSpell)
    return ((s+d)-GetTime())<ttime
end

function SumHPMobinCombat()
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and UnitAffectingCombat(nn) then
            sumhp=sumhp+ UnitHealth(nn)
        end
    end
    return sumhp
end

function SumHPMobin8yd()
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and CheckInteractDistance(nn,2) then
            sumhp=sumhp+ UnitHealth(nn)
    end end
    return sumhp
end

function IROTargetVVHP(nMultipy)
    nMultipy=nMultipy or 2
    local nG=GetNumGroupMembers()
    local playerHealth=UnitHealth("player")
    local targetHealth=UnitHealthMax("target")
    nG=(nG==0) and 1 or nG
    return (nMultipy*playerHealth*nG)<targetHealth
end

function IROEnemyGroupVVHP(nMultipy)
    nMultipy=nMultipy or 3
    local nG=GetNumGroupMembers()
    local playerHealth=UnitHealth("player")
    local EnemyGroupHP=SumHPMobinCombat()
    nG=(nG==0) and 1 or nG
    return (nMultipy*playerHealth*nG)<EnemyGroupHP
end


