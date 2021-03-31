--Next Interrupter!!!! V 2.6

--WORK Only counter interruptCounterName=1

InterruptCounterName = "wantinterrupt"

--[[ check use
(not NextInterrupter) or NextInterrupter.IsMyTurn()

or use
((not NextInterrupter)or(not NextInterrupter.Enabled)or(not NextInterrupter.ITable[UnitGUID("target")])or(next(NextInterrupter.ITable[UnitGUID("target")])==nil)or(NextInterrupter.ITable[UnitGUID("target")][1]==NextInterrupter.Name))

Debug
/run NextInterrupter.Debug()
--]]
--------CODE AERA-------------------
TMW_ST:UpdateCounter(InterruptCounterName,1)
if not AceGUI then AceGUI = LibStub("AceGUI-3.0") end
if (not NextInterrupter) or (not NextInterrupter.Setuped) then
    NextInterrupter={}
    NextInterrupter.ver="Next Interrupter!!!! V 2.5"
    NextInterrupter.DebugMode=false
    NextInterrupter.Setuped=false
    NextInterrupter.SpecID=nil
    NextInterrupter.Tier=nil
    NextInterrupter.SpellName=nil
    NextInterrupter.Name=nil
    NextInterrupter.PlayerName=nil
    NextInterrupter.isWarlock=nil
    NextInterrupter.Enabled=false
    NextInterrupter.ITable={}
    NextInterrupter.AddonMessagePrefix = "IRODPSUN"
    NextInterrupter.imInList=false
    NextInterrupter.canInterrupt=false
    NextInterrupter.TargetGUID=''
    NextInterrupter.CheckSyncCode="00"
    NextInterrupter.CheckSyncRecive={}
    NextInterrupter.DebugTextLog={}
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
    NextInterrupter.Debug = function()
        NextInterrupter.DebugMode=not NextInterrupter.DebugMode
        if NextInterrupter.DebugMode then
            print("NextInterrupter Debug Mode : "..(NextInterrupter.DebugMode and "On" or "Off"))
        end
        if NextInterrupter.DebugMode and
        ((not NextInterrupter.DebugFrame) or
        (not NextInterrupter.DebugFrame:IsVisible())) then
            NextInterrupter.DebugFrame=AceGUI:Create("Frame")
            NextInterrupter.DebugFrame:SetTitle("NextInterrupter Queue")
            NextInterrupter.DebugFrame:SetLayout("Fill")
            NextInterrupter.DebugFrame:SetWidth(600)
            NextInterrupter.DebugFrame:SetHeight(300)
            NextInterrupter.DebugFrame:SetPoint("TOPLEFT","UIParent","TOPLEFT",20,-50)
            NextInterrupter.DebugFrame:SetCallback("OnClose", function(widget)
              AceGUI:Release(widget)
              NextInterrupter.DebugMode=false
              print("NextInterrupter Debug Mode : "..(NextInterrupter.DebugMode and "On" or "Off"))
              if NextInterrupter.UpdateTreeHandle then NextInterrupter.UpdateTreeHandle:Cancel() end
            end)
            NextInterrupter.TreeGroup = AceGUI:Create("TreeGroup")
            NextInterrupter.TreeGroupStatus = { groups = {} }
            for i=0,10 do
                NextInterrupter.TreeGroupStatus.groups[i]=true
            end
            NextInterrupter.TreeGroupStatus.treewidth=350
            NextInterrupter.TreeGroup:SetStatusTable( NextInterrupter.TreeGroupStatus )
            NextInterrupter.TreeGroup:SetLayout("Fill")
            NextInterrupter.DebugFrame:AddChild(NextInterrupter.TreeGroup)
            NextInterrupter.ScrollFrame=AceGUI:Create("ScrollFrame")
            NextInterrupter.ScrollFrame:SetLayout("List")
            NextInterrupter.TreeGroup:AddChild(NextInterrupter.ScrollFrame)
            NextInterrupter.Button=AceGUI:Create("Button")
            NextInterrupter.Button:SetText("Check Sync")
            NextInterrupter.Button:SetCallback("OnClick", function()
                local SendType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or "WHISPER"))
                local SendTarget = NextInterrupter.PlayerName
                local Prefix = NextInterrupter.AddonMessagePrefix
                local SendMessage = "CK^"..NextInterrupter.PlayerName.."^00"
                if NextInterrupter.DebugMode then
                    NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime())
                    NextInterrupter.AddDebugTextLog(">>>> "..SendType..' : "'..SendMessage..'"')
                end
                NextInterrupter.CheckSyncCode=NextInterrupter.SyncCode()
                NextInterrupter.CheckSyncRecive={}
                C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
            end)
            NextInterrupter.Label=AceGUI:Create("Label")
            local fontName, fontHeight, fontFlags = GameFontNormal:GetFont()
            NextInterrupter.Label:SetFont(fontName,fontHeight*1.2,fontFlags)
            NextInterrupter.Label:SetWidth(2048)
            NextInterrupter.Label:SetText("")
            NextInterrupter.ScrollFrame:AddChild(NextInterrupter.Button)
            NextInterrupter.ScrollFrame:AddChild(NextInterrupter.Label)

            NextInterrupter.updateTree(true)
            NextInterrupter.AddDebugTextLog("*****Debug Mode ON!!")       
            --NextInterrupter.UpdateTreeHandle = C_Timer.NewTicker(0.05, NextInterrupter.updateTree)
        end
        if not NextInterrupter.DebugMode then
            if NextInterrupter.DebugFrame and NextInterrupter.DebugFrame:IsVisible() then
                AceGUI:Release(NextInterrupter.DebugFrame)
                if NextInterrupter.UpdateTreeHandle then NextInterrupter.UpdateTreeHandle:Cancel() end
            end
        end
    end
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
    NextInterrupter.AddDebugTextLog = function(str,MaxLine)
        if not str then return end
        MaxLine=MaxLine or 200
        local n=table.getn(NextInterrupter.DebugTextLog)+1
        NextInterrupter.DebugTextLog[n]=str
        local s=''
        local startline = ((n-MaxLine)<1) and 1 or (n-MaxLine)
        for i=startline,n do
            s=NextInterrupter.DebugTextLog[i].."\n"..s
        end
        NextInterrupter.Label:SetText(s)
    end
    NextInterrupter.Version = function()
        print(NextInterrupter.ver)
    end
    NextInterrupter.CompareTable = function(a,b)
        local function subcompare(aa,bb)
            if (not aa) or (not bb) then return false end
            local equal=true
            for k,v in pairs(aa) do
                if type(v)=="table" then
                    equal=NextInterrupter.CompareTable(v,bb[k])
                    if not equal then break end
                elseif (equal) and (v~=bb[k]) then
                    equal=false
                    break
                end
            end
            return equal
        end
        local eq = subcompare(a,b)
        if eq then eq=subcompare(b,a) end
        return eq
    end
    NextInterrupter.oldTree ={}
    NextInterrupter.updateTree= function(NotCompareTableBeforUpdate)
        if (not NextInterrupter) or (not NextInterrupter.ITable) then return end
        local NITree = {}
        local i=1
        local NIsubTree = {}
        for k,v in pairs(NextInterrupter.CheckSyncRecive)do
            table.insert(NIsubTree,{
                value=i,
                text=k.." - "..v
            })
            i=i+1
        end

        table.insert(NITree,{
            value=0,
            text="Sync Status - "..NextInterrupter.CheckSyncCode,
            children=NIsubTree
        })

        i=1
        for k,v in pairs(NextInterrupter.ITable) do
            NIsubTree = {}
            for k2,v2 in pairs(v) do
                table.insert(NIsubTree,{
                    value=k2,
                    text=v2
                })
            end
            table.insert(NITree,{
                value= i,
                text = k,
                children=NIsubTree
            })
            i=i+1
        end
        if NotCompareTableBeforUpdate or
        (not NextInterrupter.CompareTable(NextInterrupter.oldTree,NITree))
        then
            NextInterrupter.oldTree=NITree
            NextInterrupter.TreeGroup:SetTree(NITree)
        end
    end
    NextInterrupter.PrintTable = function()
        if next(NextInterrupter.ITable)==nil then
            print("-----{table empty}")
        else
            for k,v in pairs(NextInterrupter.ITable) do
                print(k)
                local iname="-----"
                for _,v2 in pairs(v) do 
                    iname=iname.."{"..v2.."} "
                end
                print(iname)
            end 
        end
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
        if NextInterrupter.DebugMode then
            NextInterrupter.AddDebugTextLog("*** NextInterrupter.Enable : "..GetTime())
            --print("*** NextInterrupter.Enable : "..GetTime())
        end
        NextInterrupter.Enabled=true
        NextInterrupter.updateSpec()
        NextInterrupter.SendISM()
    end
    NextInterrupter.Disable = function()
        if NextInterrupter.DebugMode then
            NextInterrupter.AddDebugTextLog("*** NextInterrupter.Disable : "..GetTime())
            --print("*** NextInterrupter.Disable : "..GetTime())
        end
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
        else
            if NextInterrupter.canInterrupt~=canInterrupt then willSend = true end
        end

        if willSend then
            NextInterrupter.SendISM(canInterrupt)
        end
    end
    NextInterrupter.SendISM = function(ForceInterruptStatus)
        if NextInterrupter.DebugMode then
            NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime())
            --print("//SendedISM : "..GetTime())
        end
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
        local SendType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or (IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or "WHISPER"))
        local SendTarget = NextInterrupter.PlayerName
        local Prefix = NextInterrupter.AddonMessagePrefix
        local SendMessage = (canInterrupt and 'CI^' or 'CN^')..NextInterrupter.Name.."^"..tGUID
        if NextInterrupter.DebugMode then
            NextInterrupter.AddDebugTextLog(">>>> "..SendType..' : "'..SendMessage..'"')
            --print(">>>> "..SendType..' : "'..SendMessage..'"')
        end
        C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
    end
    NextInterrupter.AddonMessageEvent = function(self, event, ...)
        --print(event)
        if event=="PLAYER_REGEN_DISABLED" then
            -- incombat event
            --print('in in')
            -- force send message
            if NextInterrupter.Enabled then NextInterrupter.SendISM() end
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
        -- CK = Check Sync Please Return Sync Code to Sender
        -- CR = Recive Sync Code
        --e.g. 'CK^Kimiiro-Dreadmaul^00
        --e.g. 'CR^Kimiiro-Dreadmaul^584655
        --IRODPSInterruptTable = {
        -- ['GUIDMob1'] = { 'PlayerName1','PlayerName2'....}
        -- ['GUIDMob2'] = { 'PlayerName1','PlayerName2'....}
        -- .... }
        
        if m1 ~= NextInterrupter.AddonMessagePrefix then
            --print(m1)
            return 0
        end
        if NextInterrupter.DebugMode then
            NextInterrupter.AddDebugTextLog("\\\\ReciveISM : "..GetTime())
            NextInterrupter.AddDebugTextLog('<<<< "'..m2..'"')
            --print("\\\\ReciveISM : "..GetTime())
            --print('<<<< "'..m2..'"')
        end
        local iaction,iname,iGUID = strsplit("^", m2,3)
        local iIndex,ifound

        if iname==NextInterrupter.Name then
            if (iaction=="CN") then
                NextInterrupter.imInList=false
            else
                NextInterrupter.imInList=true
            end
        end
        --CHECK SYNCED plase return code to sender
        if (iaction=="CK") then
            local SendType = "WHISPER"
            local SendTarget = iname
            local Prefix = NextInterrupter.AddonMessagePrefix
            local SendMessage = "CR^"..NextInterrupter.PlayerName.."^"..NextInterrupter.SyncCode()
            if NextInterrupter.DebugMode then
                NextInterrupter.AddDebugTextLog("//SendedISM : "..GetTime())
                NextInterrupter.AddDebugTextLog(">>>> "..SendType..' : "'..SendMessage..'"')
                --print(">>>> "..SendType..' : "'..SendMessage..'"')
            end
            C_ChatInfo.SendAddonMessage(Prefix, SendMessage, SendType,SendTarget)
            return
        end
        if (iaction=="CR") then
            NextInterrupter.CheckSyncRecive[iname]=iGUID
            NextInterrupter.updateTree(true)
            return
        end
        -- cannot interrupt / used interrupt skill
        local TableEdited=false
        if (iaction=="CN")or(iaction=="CI") then
            --print('if 1')
            for iMobID in pairs(NextInterrupter.ITable) do
                for iiIndex in pairs(NextInterrupter.ITable[iMobID]) do
                    if NextInterrupter.ITable[iMobID][iiIndex]==iname then
                        TableEdited=true
                        table.remove(NextInterrupter.ITable[iMobID],iiIndex)
                        if next(NextInterrupter.ITable[iMobID])==nil then
                            NextInterrupter.ITable[iMobID]=nil
                        end
                        break
                    end
                end
            end
        end
        local inamesub11=iname:sub(1,1)
        if iaction == "CI" then
            --print('if 2')
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
                end
            end
            if not ifound then iIndex=iIndex+1 end
            TableEdited=true
            table.insert(NextInterrupter.ITable[iGUID],iIndex,iname)
        end
        if NextInterrupter.DebugMode then
            if TableEdited then
                NextInterrupter.AddDebugTextLog(GetTime().." Table Change")
                --print(GetTime().." Table Change")
                NextInterrupter.updateTree(true)
                --NextInterrupter.PrintTable()
            else
                NextInterrupter.AddDebugTextLog(GetTime().." Table Not Change")
                --print(GetTime().." Table Not Change")
            end
        end
    end
    --Update all variable for 1st time
    NextInterrupter.updateSpec()
    --Set Event to Check Spec
    NextInterrupter.fspec = CreateFrame("Frame")
    NextInterrupter.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    NextInterrupter.fspec:SetScript("OnEvent", NextInterrupter.updateSpec)
    --Set Event To receive addon message
    NextInterrupter.AddonMFrame = CreateFrame("Frame")
    NextInterrupter.AddonMFrame:RegisterEvent("CHAT_MSG_ADDON")
    NextInterrupter.AddonMFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    NextInterrupter.AddonMFrame:SetScript("OnEvent", NextInterrupter.AddonMessageEvent)
    C_ChatInfo.RegisterAddonMessagePrefix(NextInterrupter.AddonMessagePrefix)
    --Set to Check Target Every 0.112 sec
    NextInterrupter.C_TimerHandle = C_Timer.NewTicker(0.112, function()
        local cc=TMW_ST:GetCounter(InterruptCounterName)
        if cc==1 then
            if not NextInterrupter.Enabled then NextInterrupter.Enable() end
            NextInterrupter.CheckAndSendISM()
        else
            if NextInterrupter.Enabled then NextInterrupter.Disable() end
        end
    end)
    --set Done Setup
    NextInterrupter.Setuped=true
end