-- Many Function Version 9.0.5/25
-- this file save many function for paste to TMW Snippet LUA

--function IROEnemyCountIn8yd(Rlevel) ; return count
--function IROEnemyCountInRange(nRange) ; return count, nRange = yard e.g. 2 5 8 15 20 30 40 50 200
--function PercentCastbar2(PercentCast, MustInterruptAble,unit, MinTMS,MaxTMS); return true/false
--function GCDActiveLessThan(ttime) ; return true/false
--function SumHPMobinCombat() ; return SumHP
--function SumHPMobin8yd() ; return SumHP
--function IROTargetVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<targetHealth
--function IROEnemyGroupVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<EnemyGroupHP

--function GCDCDTime() ; return GCD length time, = 1.5*(100/(100+UnitSpellHaste("player")))
--function isMyInterruptSpellReady() ; true/false
--function TMW.CNDT.Env.CooldownDuration([spellName/Id, e.g. "execute"], [include GCD, true/false]); return CD remain (sec)
--function IROVar.ERO_Old_Val.Check(functionName,input_val_string) ; return Old Val at Same GetTime() , or nil
--function IROVar.ERO_Old_Val.Update(functionName,input_val_string,result_val) ; update Old_Val at same GetTime()
--function IROVar.Debug() show some Debug val
--function SumPartyHP() return party HP
--var IROSpecID = GetSpecializationInfo(GetSpecialization()),e.g. 62="Mage arcane",63="Mage fire",64="Mage frost"
--IROVar.CheckDPSRange = function(nUnit) ; return Can Dps Unit?

if not IROVar then IROVar={} end
--_,IROVar.Talentname,_,IROVar.Talentselected=GetTalentInfo(3,1,1)
--IROVar.isMassacre = (IROVar.Talentname=="Massacre") and IROVar.Talentselected
--IROVar.isCondemn = GetSpellInfo("execute")=="Condemn"
IROVar.DebugMode = false
IROVar.iHaveInterruptSpell = false
IROVar.SkillCheckDPSRange = nil
IROVar.IsEquipShield = false
function IROVar.Debug()
    IROVar.DebugMode=not IROVar.DebugMode
    print("IROVar.DebugMode : "..(IROVar.DebugMode and "On" or "Off"))
end
function IROVar:fspecOnEvent(event)
    if IROVar.DebugMode then print("Event : "..((event~=nil) and event or "nil")) end
    if event=="ZONE_CHANGED" then
        C_Timer.After(10,IROVar.UpdateVar)
    elseif event=="PLAYER_TALENT_UPDATE" then
        C_Timer.After(1,IROVar.UpdateVar)
    elseif event=="BAG_UPDATE" then
        --do notthing yet
    elseif event=="UNIT_INVENTORY_CHANGED" then
        local ItemLink=GetInventoryItemLink("player", 17)--shield
        IROVar.IsEquipShield=(ItemLink~=nil) and (select(7,GetItemInfo(ItemLink))=="Shields") or false
    end
end

if not IROSpecID then
    IROSpecID = GetSpecializationInfo(GetSpecialization())
end

IROVar.fspec = CreateFrame("Frame")
--IROVar.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
--IROVar.fspec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
IROVar.fspec:RegisterEvent("PLAYER_TALENT_UPDATE")
IROVar.fspec:RegisterEvent("ZONE_CHANGED")
IROVar.fspec:RegisterEvent("BAG_UPDATE")
IROVar.fspec:RegisterEvent("UNIT_INVENTORY_CHANGED")
IROVar.fspec:SetScript("OnEvent", IROVar.fspecOnEvent)

function IROVar.UpdateVar()
    local newSpec = GetSpecializationInfo(GetSpecialization())
    _,IROVar.Talentname,_,IROVar.Talentselected=GetTalentInfo(3,1,1)
    local newisMassacre=(IROVar.Talentname=="Massacre") and IROVar.Talentselected
    local newisCondemn=GetSpellInfo("execute")=="Condemn"
    if IROVar.DebugMode then
        if (IROSpecID~=newSpec) and (newSpec~=nil)  then
            print("old Spec :"..((IROSpecID~=nil) and IROSpecID or "nil"))
            print("new Spec :"..((newSpec~=nil) and newSpec or "nil"))
        end
        if IROVar.isMassacre~=newisMassacre then
            print("old isMassacre :"..(IROVar.isMassacre and "true" or "false"))
            print("new isMassacre :"..(newisMassacre and "true" or "false"))
        end
        if IROVar.isCondemn~=newisCondemn then
            print("old isCondemn :"..(IROVar.isCondemn and "true" or "false"))
            print("new isCondemn :"..(newisCondemn and "true" or "false"))
        end
    end
    IROSpecID = newSpec or IROSpecID
    IROVar.isMassacre = newisMassacre
    IROVar.isCondemn = newisCondemn
    if IROInterruptTier[IROSpecID] then
        IROVar.iHaveInterruptSpell = GetSpellInfo(IROInterruptTier[IROSpecID][2])~=nil
        IROVar.SkillCheckDPSRange = IROInterruptTier[IROSpecID][3]
    else
        IROVar.iHaveInterruptSpell = false
        IROVar.SkillCheckDPSRange = nil
    end
    local ItemLink=GetInventoryItemLink("player", 17)--shield
    IROVar.IsEquipShield=(ItemLink~=nil) and (select(7,GetItemInfo(ItemLink))=="Shields") or false
end

C_Timer.After(5,IROVar.UpdateVar) --update 5 sec after login

local ItemRangeCheck = {
    [1]=34368, -- Attuned Crystal Cores 8 yard
    [2]=33069, -- Sturdy Rope 15 yard
    [3]=10645, -- Gnomish Death Ray 20 yard
    [4]=835, -- Large Rope Net 30 yard
    [5]=28767, -- The Decapitator 40 yard
    [6]=32321, -- Sparrowhawk Net 10 yard
}
IROVar.ItemNameToCheck8 = "item:"..ItemRangeCheck[1]

IROVar.CheckDPSRange = function(nUnit)
    if IROVar.SkillCheckDPSRange == nil then return true end
    nUnit = nUnit or "target"
    return IsSpellInRange(IROVar.SkillCheckDPSRange,nUnit)==1
end

IROVar.ERO_Old_Val = {Timer=0,Old_Val={},
    Check = function(functionName,input_val_string)
        return ((IROVar.ERO_Old_Val.Timer==GetTime())
        and IROVar.ERO_Old_Val.Old_Val[functionName]
        and IROVar.ERO_Old_Val.Old_Val[functionName][input_val_string])
        and IROVar.ERO_Old_Val.Old_Val[functionName][input_val_string] or nil
    end,
    Update = function(functionName,input_val_string,result_val)
        local currenTimer = GetTime()
        if IROVar.ERO_Old_Val.Timer < currenTimer then
            IROVar.ERO_Old_Val.Timer = currenTimer
            IROVar.ERO_Old_Val.Old_Val = {}
        end
        if not IROVar.ERO_Old_Val.Old_Val[functionName] then
            IROVar.ERO_Old_Val.Old_Val[functionName]={}
        end
        IROVar.ERO_Old_Val.Old_Val[functionName][input_val_string]=result_val
    end
}


function IROEnemyCountIn8yd(Rlevel)
    --return enemy count in Range Default 8 yard Max 8
    Rlevel = Rlevel or 0
    --Rlevel 0=8,1=15,2=20,3=30,4=40,5=10 yard
    local ItemNameToCheck = "item:"..ItemRangeCheck[Rlevel+1]
    local nn
    local count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player", nn) then
            if IsItemInRange(IROVar.ItemNameToCheck8, nn)or(UnitAffectingCombat(nn)and IsItemInRange(ItemNameToCheck, nn)) then
                count=count+1
            end
        end
        if count>=8 then break end
    end
    return count
end

local ItemRangeCheck2 = {
    [2] =37727, -- Ruby Acorn
    [3] =42732, -- Everfrost Razor
    [4] =129055, -- Shoe Shine Kit
    [5] =8149, -- Voodoo Charm
    [7] =61323, -- Ruby Seeds
    [8] =34368, -- Attuned Crystal Cores
    [10] =32321, -- Sparrowhawk Net
    [15] =33069, -- Sturdy Rope
    [20] =10645, -- Gnomish Death Ray
    [25] =24268, -- Netherweave Net
    [30] =835, -- Large Rope Net
    [35] =24269, -- Heavy Netherweave Net
    [38] =140786, -- Ley Spider Eggs
    [40] =28767, -- The Decapitator
    [45] =23836, -- Goblin Rocket Launcher
    [50] =116139, -- Haunting Memento
    [55] =74637, -- Kiryn's Poison Vial
    [60] =32825, -- Soul Cannon
    [70] =41265, -- Eyesore Blaster
    [80] =35278, -- Reinforced Net
    [90] =133925, -- Fel Lash
    [100] =33119, -- Malister's Frost Wand
    [150] =46954, -- Flaming Spears
    [200] =75208, -- Rancher's Lariat
}

function IROEnemyCountInRange(nRange)
    nRange = nRange or 8
    local OldVal=IROVar.ERO_Old_Val.Check("IROEnemyCountInRange",nRange)
    if OldVal then return OldVal end
    if nRange<2 then nRange=2 end
    while(ItemRangeCheck2[nRange]==nil)do
        nRange=nRange-1
    end
    local ItemNameToCheck = "item:"..ItemRangeCheck2[nRange]
    local nn
    local count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player", nn) then
            if IsItemInRange(ItemNameToCheck, nn) then
                count=count+1
            end
        end
        if count>=8 then break end
    end
    IROVar.ERO_Old_Val.Update("IROEnemyCountInRange",nRange,count)
    return count
end

IROInterruptTier = {}
--IROInterruptTier[specID]={interruptTier,interruptSpellName,DPSCheckSkill}
IROInterruptTier[71] = {'B','Pummel','Pummel'} -- Arm
IROInterruptTier[72] = {'B','Pummel','Pummel'} -- fury
IROInterruptTier[73] = {'A','Pummel','Pummel'} -- Protection
IROInterruptTier[265] = {'D','Command Demon','Corruption'} -- Aff [Spell Lock]
IROInterruptTier[266] = {'D','Command Demon','Corruption'} -- Demo
IROInterruptTier[267] = {'D','Command Demon','Corruption'} -- Dest
IROInterruptTier[262] = {'C','Wind Shear','Lightning Bolt'} -- Element
IROInterruptTier[263] = {'B','Wind Shear','primal strike'} -- Enha
IROInterruptTier[264] = {'D','Wind Shear','Lightning Bolt'} -- Resto
IROInterruptTier[259] = {'B','Kick','Kick'} -- Ass
IROInterruptTier[260] = {'B','Kick','Kick'} -- Out
IROInterruptTier[261] = {'B','Kick','Kick'} -- Sub
IROInterruptTier[256] = {'N','','Smite'} -- Disc
IROInterruptTier[257] = {'N','','Smite'} -- Holy
IROInterruptTier[258] = {'D','Silence','Smite'} -- Shadow
IROInterruptTier[65] = {'N','','Crusader Strike'} -- Holy
IROInterruptTier[66] = {'A','Rebuke','Crusader Strike'} -- Port
IROInterruptTier[70] = {'B','Rebuke','Crusader Strike'} -- Ret
IROInterruptTier[268] = {'A','Spear Hand Strike','Tiger Palm'} -- Brewmaster
IROInterruptTier[270] = {'N','','Tiger Palm'} -- Mistweaver
IROInterruptTier[269] = {'B','Spear Hand Strike','Tiger Palm'} -- Windwalker
IROInterruptTier[62] = {'C','Counterspell','Fire Blast'} -- arcane
IROInterruptTier[63] = {'C','Counterspell','Fire Blast'} -- fire
IROInterruptTier[64] = {'C','Counterspell','Fire Blast'} -- frost
IROInterruptTier[253] = {'C','Counter Shot','Arcane Shot'} -- Beast Mastery
IROInterruptTier[254] = {'C','Counter Shot','Arcane Shot'} -- Marksmanship
IROInterruptTier[255] = {'C','Muzzle','Raptor Strike'} -- Survival
IROInterruptTier[102] = {'C','Solar Beam','Moonfire'} -- Balance
IROInterruptTier[103] = {'B','Skull Bash','Rake'} -- Feral
IROInterruptTier[104] = {'A','Skull Bash','Mangle'} -- Guardian
IROInterruptTier[105] = {'N','','Moonfire'} -- Restoration
IROInterruptTier[577] = {'B','Disrupt','Chaos Strike'} -- Havoc
IROInterruptTier[581] = {'A','Disrupt','Chaos Strike'} -- Vengeance
IROInterruptTier[250] = {'A','Mind Freeze','Death Strike'} -- Blood
IROInterruptTier[251] = {'B','Mind Freeze','Death Strike'} -- frost
IROInterruptTier[252] = {'B','Mind Freeze','Death Strike'} -- unholy

function isMyInterruptSpellReady()
    if IROInterruptTier and IROSpecID then
        return TMW.CNDT.Env.CooldownDuration(IROInterruptTier[IROSpecID][2])==0
    else
        return false
    end
end

function PercentCastbar2(PercentCast, MustInterruptAble,unit, MinTMS,MaxTMS)
    PercentCast = PercentCast or 0.5
    if MustInterruptAble == nil then MustInterruptAble = true end
    MaxTMS = MaxTMS or 2000
    MinTMS = MinTMS or 200
    unit = unit or "target"
    local _, _, _, startTimeMS, endTimeMS, _, _, notInterruptible = UnitCastingInfo(unit)
    local wantInterrupt = false
    local totalcastTime
    local currentcastTime
    local percentcastTime
    if (startTimeMS ~= nil) and(not(notInterruptible and MustInterruptAble)) then
        totalcastTime = endTimeMS-startTimeMS
        currentcastTime = (GetTime()*1000)-startTimeMS
    -- if cast time > MaxTMS ms dont interrupt
    -- if cast time < MinTMS ms dont interrupt
        if ((totalcastTime-currentcastTime)>=MinTMS) and ((totalcastTime-currentcastTime)<=MaxTMS) then
            percentcastTime = currentcastTime/totalcastTime
            wantInterrupt = percentcastTime >= PercentCast
        end
        return wantInterrupt
    end
    local _, _, _, CstartTimeMS, CendTimeMS,_, CnotInterruptible= UnitChannelInfo(unit)
    if (CstartTimeMS ~= nil) and (not (CnotInterruptible and MustInterruptAble)) then
        totalcastTime = CendTimeMS-CstartTimeMS
        currentcastTime = (GetTime()*1000)-CstartTimeMS
        if (currentcastTime>=MinTMS) and (currentcastTime<=(totalcastTime-MinTMS)) then
            wantInterrupt = true
        end
    end
    return wantInterrupt
end

function GCDActiveLessThan(ttime)
    ttime = ttime or 0.2
    local s,d = GetSpellCooldown(TMW.GCDSpell)
    return ((s+d)-GetTime())<ttime
end

function SumPartyHP()
    local Old_Val=IROVar.ERO_Old_Val.Check("SumPartyHP","")
    if Old_Val then return Old_Val end
    local sHP=0
    if IsInRaid() then
        local n = GetNumGroupMembers()
        if n==0 then n=1 end
        for i=1,n do
            sHP=sHP+UnitHealth("raid"..i)
        end
    elseif IsInGroup() then
        sHP=UnitHealth("player")
        local n= GetNumGroupMembers()
        for i=1,n-1 do
            sHP=sHP+UnitHealth("party"..i)
        end
    else
        sHP=UnitHealth("player")
    end
    IROVar.ERO_Old_Val.Update("SumPartyHP","",sHP)
    return sHP
end

function SumHPMobinCombat()
    local Old_Val=IROVar.ERO_Old_Val.Check("SumHPMobinCombat","")
    if Old_Val then return Old_Val end
    local sumhp =0
    local nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and UnitCanAttack("player", nn)
        and (UnitAffectingCombat(nn) or IsItemInRange(IROVar.ItemNameToCheck8, nn))
        then
            sumhp=sumhp+ UnitHealth(nn)
        end
    end
    IROVar.ERO_Old_Val.Update("SumHPMobinCombat","",sumhp)
    return sumhp
end

function SumHPMobin8yd()
    local sumhp =0
    local nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and CheckInteractDistance(nn,2) and UnitCanAttack("player", nn) then
            sumhp=sumhp+ UnitHealth(nn)
    end end
    return sumhp
end

function IROTargetVVHP(nMultipy)
    nMultipy=nMultipy or 2
    local playerHealth=SumPartyHP()
    local targetHealth=UnitHealthMax("target")
    return (nMultipy*playerHealth)<targetHealth
end

function IROEnemyGroupVVHP(nMultipy)
    nMultipy=nMultipy or 3
    local playerHealth=SumPartyHP()
    local EnemyGroupHP=SumHPMobinCombat()
    return (nMultipy*playerHealth)<EnemyGroupHP
end



local IROClassGCDOneSec = {
    [259]=true,[260]=true,[261]=true, -- rogue
    [269]=true, -- monk WW
    [103]=true, -- druid feral
}

function GCDCDTime()
    --return GCD CD
    local OldVal=IROVar.ERO_Old_Val.Check("GCDCDTime","")
    if OldVal then return OldVal end
    local GCDCD=TMW.GCD
    if GCDCD == 0 then
        if not IROSpecID then IROSpecID = GetSpecializationInfo(GetSpecialization()) end
        if IROClassGCDOneSec[IROSpecID] then
            GCDCD = 1
        else
            GCDCD = 1.5*(100/(100+UnitSpellHaste("player")))
        end
    end
    IROVar.ERO_Old_Val.Update("GCDCDTime","",GCDCD)
    return GCDCD
end


