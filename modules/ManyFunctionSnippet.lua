-- Many Function Version 9.0.5/73
-- Set Priority to 1
-- this file save many function for paste to TMW Snippet LUA

--function IROEnemyCountInRange(nRange) ; return count, nRange = yard e.g. 2 5 8 15 20 30 40 50 200
--function PercentCastbar2(PercentCast, MustInterruptAble,unit, MinTMS,MaxTMS); return true/false
--function GCDActiveLessThan(ttime) ; return true/false
--function SumHPMobinCombat() ; return SumHP
--function SumHPMobin8yd() ; return SumHP
--function IROTargetVVHP(nMultipy,unit) ; return (nMultipy*playerHealth*nG)<targetHealth;unit is unit or "target"
--function IROEnemyGroupVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<EnemyGroupHP
--function GCDCDTime() ; return GCD length time, = 1.5*(100/(100+UnitSpellHaste("player")))
--function IsMyInterruptSpellReady() ; true/false

--function IROVar.ERO_Old_Val.Check(functionName,input_val_string) ; return Old Val at Same GetTime() , or nil
--function IROVar.ERO_Old_Val.Update(functionName,input_val_string,result_val) ; update Old_Val at same GetTime()
--function IROVar.Debug() show some Debug val
--function SumPartyHP() return party HP
--var IROSpecID = GetSpecializationInfo(GetSpecialization()),e.g. 62="Mage arcane",63="Mage fire",64="Mage frost"
--function IROVar.CheckDPSRange(nUnit) ; return Can Dps Unit?
--function IROVar.allDeBuffByMe(unit) ; return table of debuff
--function IROVar.allBuffByMe(unit,needLowerCaseName)
----*********return table of [Buff name] = Buff time remaining

--function TMW.CNDT.Env.CooldownDuration([spellName/Id, e.g. "execute"], [include GCD, true/false]); return CD remain (sec)
--function TMW.CNDT.Env.AuraDur(unit, name, filter) ; return duration,MaxDuration,TimeEnd
    --unit, e.g. "player"
    --name, e.g. "arcane brilliance" **** muse be lower case
    --filter, e.g. "HELPFUL"
--var IROVar.Icon ; Keep Icon Data from TMW for Use further
--function IROVar.IsIconShow(icon) ; return true/false
--function IROVar.IconSweepCompair(icon,max,min) ; return (max > SweepCD > min) (true/false)
--function IROVar.IconSweepRemain(icon) -- return SecRemain,MaxRemain
--var IROVar.activeConduits ; dump soulbind to table
--var IROVar.playerGUID ;
--var IROVar.incombat ;

--function IROVar.RegisterIncombatCallBackRun(name,callBack)
--function IROVar.RegisterOutcombatCallBackRun(name,callBack)
--function IROVar.UnRegisterOutcombatCallBackRun(name)
--function IROVar.UnRegisterIncombatCallBackRun(name)

--function IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK(name,callBack)
    -- note callBack is Function(...) ; ... = CombatLogGetCurrentEventInfo()
--function IROVar.UnRegister_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK(name)

--function IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK(name,callBack)
    -- note callBack is Function(GCDEnd) ; GCDEnd = st+du of (GetSpellCooldown(TMW.GCDSpell))
--function IROVar.UnRegister_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK(name)
--function IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK(name,callBack)
--function IROVar.UnRegister_PLAYER_TARGET_CHANGED_scrip_CALLBACK(name)
--var IROVar.SPELL_UPDATE_COOLDOWN_count = Count Event Call; use to detemin Update CD
--var IROVar.TickCount01 = Tick Count every 0.1 sec; use to detemin Update CD
--var IROVar.TargetChangeCount=0;

--var IROVar.Haste ; player Haste
--var IROVar.CastTime2sec ; cast time in second mod by haste
--var IROVar.CastTime6sec
--var IROVar.CastTime1_5sec ; cast time in second mod by haste
--var IROVar.CastTime0_5sec
--var IROVar.HasteFactor ; multiply by cast time = time to cast , = 100/(100+UnitSpellHaste("player"))
--function AuraUtil.FindAuraByName(auraName, unit, filter) -- return only 1st auraName match
--function AuraUtil.ForEachAura(unit, filter, [maxCount|nil], func)
--[[  name, icon, count, dispelType, duration, expirationTime, source, isStealable,
nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer,
nameplateShowAll, timeMod, ... = UnitAura(unit, index [, filter])  ]]
--[[
    function IROVar.CounterSetUpdate(CounterSet)
    CounterSet = {
        ["counterName1"]=Value1,
        ["counterName2"]=Value2,
        ....
    }
]]

--function IROVar.TargetCastBar(percenCheck ; nil = 0.6 , DontCheckCantKick ; nil = false
    --, Spell ; nil = any spell ; can be Spell Name or SpellID) ; return true/false
    --DontCheckCantKick = true mean kick even notInterruptible (for Stun)

--function IROVar.Range(unit) ; return range
--IROVar.ignoreName = {Mob Name = true} ; ignore mob name
--IROVar.TargetName = TargetName;
--IROVar.TargetGUID = TargetGUID;
--IROVar.TargetLV = UnitLevel("target")
    --e.g. "IROVar and (not IROVar.ignoreName[IROVar.TargetName])"
--function IROVar.CompareTable(a,b) ; return true|false
--function IROVar.DecurseInGroup() ; reutnr number
--function IROVar.UnitCount(n) ; return unit in nameplate
--var IROVar.PLAYER_TARGET_CHANGED_Time = GetTime()
--function IROVar.IsUnitCCed(unit) ; return true/false | Dont Break CC
--function IROVar.KickPress() ; IROVar.KickPressed=true 0.5 sec after turn to false

if not IROVar then IROVar={} end
IROVar.Icon = {}
function IROVar.IsIconShow(icon)
    return icon and icon.attributes.shown and not icon:Update() and icon.attributes.realAlpha > 0
end
local GetTime=GetTime
local GetSpellCooldown=GetSpellCooldown

IROVar.playerGUID = UnitGUID("player")
IROVar.DebugMode = false
IROVar.InterruptSpell = nil
IROVar.SkillCheckDPSRange = nil
IROVar.InstanceName = GetInstanceInfo()
IROVar.activeConduits = {}
IROVar.EditKeyMacroForAutoTarget = 50 -- Update Macro After Restart
IROVar.PLAYER_TARGET_CHANGED_Time = GetTime()
IROVar.CCDebuff={}
for k,v in ipairs(TMW.BE.debuffs.CrowdControl) do
    IROVar.CCDebuff[v]=true
end

function IROVar.IsUnitCCed(unit)
    if not UnitExists(unit) then return false end
    local CCed=false
    for i=1,40 do
        local name,_,_,_,_,_,_,_,_,spellId=UnitAura(unit,i,"HARMFUL")
        if name then
            if IROVar.CCDebuff[spellId] or IROVar.CCDebuff[name] then
                CCed=true
                break
            end
        else break end
    end
    return CCed
end

function IROVar.CounterSetUpdate(c)
    for k,v in pairs(c) do
        TMW_ST:UpdateCounter(k,v)
    end
end


function IROVar.CalculateHaste()
    IROVar.Haste = UnitSpellHaste("player")
    IROVar.HasteFactor = 100/(100+IROVar.Haste)
    IROVar.CastTime2sec = 2*IROVar.HasteFactor
    IROVar.CastTime1_5sec = 1.5*IROVar.HasteFactor
    IROVar.CastTime6sec = 6*IROVar.HasteFactor
    IROVar.CastTime0_5sec = 0.5*IROVar.HasteFactor
end
IROVar.CalculateHaste()
C_Timer.After(2,IROVar.CalculateHaste)
if not IROSpecID then
    IROSpecID = GetSpecializationInfo(GetSpecialization())
end
IROInterruptTier = {}
--IROInterruptTier[specID]={interruptTier,interruptSpellName,DPSCheckSkill,Range,Role,CastType}
--MOVE this table to ERO DPS Decoder 9.0.5/5
for k,v in pairs(IROUsedSkillControl.ClassType) do
    IROInterruptTier[k]=v
end

--IROVar.FireCri=GetSpellCritChance(3)
IROVar.fhaste = CreateFrame("Frame")
IROVar.fhaste:RegisterEvent("UNIT_SPELL_HASTE")
--IROVar.fhaste:RegisterEvent("COMBAT_RATING_UPDATE")
IROVar.fhaste:SetScript("OnEvent", function(self,event,unittoken)
    if event=="UNIT_SPELL_HASTE" and unittoken=="player" then
        IROVar.CalculateHaste()
    end
--[[    if event=="COMBAT_RATING_UPDATE" then
        IROVar.FireCri=GetSpellCritChance(3)
    end]]
end)

function IROVar.Debug()
    IROVar.DebugMode=not IROVar.DebugMode
    print("IROVar.DebugMode : "..(IROVar.DebugMode and "On" or "Off"))
end
function IROVar:fspecOnEvent(event)
    if IROVar.DebugMode then print("Event : "..((event~=nil) and event or "nil")) end
    IROVar.UpdateVar()
    C_Timer.After(5,IROVar.UpdateVar)
end

IROVar.fspec = CreateFrame("Frame")
IROVar.fspec:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IROVar.fspec:RegisterEvent("ZONE_CHANGED_NEW_AREA")
IROVar.fspec:SetScript("OnEvent", IROVar.fspecOnEvent)

function IROVar.UpdateVar()
    IROVar.InstanceName = GetInstanceInfo()
    local newSpec = GetSpecializationInfo(GetSpecialization())
    if IROVar.DebugMode then
        if (IROSpecID~=newSpec) and (newSpec~=nil)  then
            print("old Spec :"..((IROSpecID~=nil) and IROSpecID or "nil"))
            print("new Spec :"..((newSpec~=nil) and newSpec or "nil"))
        end
    end
    IROSpecID = newSpec or IROSpecID
    if IROInterruptTier[IROSpecID] then
        IROVar.InterruptSpell = IROInterruptTier[IROSpecID][2]
        IROVar.SkillCheckDPSRange = IROInterruptTier[IROSpecID][3]
    else
        IROVar.InterruptSpell = nil
        IROVar.SkillCheckDPSRange = nil
    end
end

IROVar.UpdateVar() --update Now after login
C_Timer.After(5,IROVar.UpdateVar) --update 5 sec after login

IROVar.CheckDPSRange = function(nUnit)
    if IROVar.SkillCheckDPSRange == nil then return true end
    nUnit = nUnit or "target"
    return IsSpellInRange(IROVar.SkillCheckDPSRange,nUnit)==1
end

IROVar.ERO_Old_Val = {Timer=0,Old_Val={},
    Check = function(functionName,input_val_string)
        input_val_string=input_val_string or ""
        return ((IROVar.ERO_Old_Val.Timer==IROVar.TickCount01)
        and IROVar.ERO_Old_Val.Old_Val[functionName]
        and IROVar.ERO_Old_Val.Old_Val[functionName][input_val_string])
        and IROVar.ERO_Old_Val.Old_Val[functionName][input_val_string] or nil
    end,
    Update = function(functionName,input_val_string,result_val)
        input_val_string=input_val_string or ""
        local currenTimer = IROVar.TickCount01
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

local ItemRangeCheck2 = {
    [2] =37727, -- Ruby Acorn -- not work
    [3] =42732, -- Everfrost Razor -- not work
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
local ItemRangeCheck2_2={}
for k,v in pairs(ItemRangeCheck2) do
    ItemRangeCheck2_2[k]="item:"..v
end
local ItemRangeCheckOrder = {}
for i=1,200 do
    if ItemRangeCheck2[i] then
        table.insert(ItemRangeCheckOrder,i)
    end
end

IROVar.ItemNameToCheck8 = "item:34368"

function IROVar.Range(unit)
    for i=1,#ItemRangeCheckOrder do
        if IsItemInRange(ItemRangeCheck2_2[ItemRangeCheckOrder[i]],unit) then
            return ItemRangeCheckOrder[i-1] or 0
        end
    end
    return 300
end

function IROEnemyCountInRange(nRange)
    nRange = nRange or 8
    local OldVal=IROVar.ERO_Old_Val.Check("IROEnemyCountInRange",nRange)
    if OldVal then return OldVal end
    if nRange<2 then nRange=2 end
    while(ItemRangeCheck2[nRange]==nil)do
        nRange=nRange-1
    end
    local ItemNameToCheck = ItemRangeCheck2_2[nRange]
    local nn
    local count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player", nn) then
            if IsItemInRange(ItemNameToCheck,nn)and(UnitAffectingCombat(nn) or (nRange<=8) or IsItemInRange(IROVar.ItemNameToCheck8, nn)) then
                count=count+1
            end
        end
        if count>=8 then break end
    end
    IROVar.ERO_Old_Val.Update("IROEnemyCountInRange",nRange,count)
    return count
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

IROVar.ignoreName={
    ["Spiteful Shade"]=true,
    ["Slithering Ooze"]=true,
}
function SumHPMobinCombat()
    local Old_Val=IROVar.ERO_Old_Val.Check("SumHPMobinCombat","")
    if Old_Val then return Old_Val end
    local sumhp =0
    local nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and (not IROVar.ignoreName[UnitName(nn)]) and UnitCanAttack("player",nn)
        and (UnitAffectingCombat(nn) or IsItemInRange(IROVar.ItemNameToCheck8,nn))
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

function IROTargetVVHP(nMultipy,unit)
    unit=unit or "target"
    nMultipy=nMultipy or 2
    local playerHealth=SumPartyHP()
    local targetHealth=UnitHealth(unit)
    return (nMultipy*playerHealth)<targetHealth
end

IROVar.IROEnemyGroupVVHPOldVal={}
IROVar.IROEnemyGroupVVHPRun=false
function IROEnemyGroupVVHP(nMultipy)
    IROVar.IROEnemyGroupVVHPRun=true
    nMultipy=nMultipy or 3
    if IROVar.IROEnemyGroupVVHPOldVal[nMultipy] then
        IROVar.IROEnemyGroupVVHPRun=false
        return IROVar.IROEnemyGroupVVHPOldVal[nMultipy]
    end
    local playerHealth=SumPartyHP()
    local EnemyGroupHP=SumHPMobinCombat()
    local ans=(nMultipy*playerHealth)<EnemyGroupHP
    IROVar.IROEnemyGroupVVHPOldVal[nMultipy]=ans
    IROVar.IROEnemyGroupVVHPRun=false
    return ans
end
C_Timer.NewTicker(0.5,function()
    if not IROVar.IROEnemyGroupVVHPRun then
        IROVar.IROEnemyGroupVVHPOldVal={}
    end
end)




local IROClassGCDOneSec = {
    [259]=true,[260]=true,[261]=true, -- rogue
    [269]=true, -- monk WW
    [103]=true, -- druid feral
}

IROVar.GCDCDTimeOldHaste=0
IROVar.GCDCDTimeOldGCD=0

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
            if IROVar.GCDCDTimeOldHaste~=IROVar.Haste then
                GCDCD = 1.5*(100/(100+IROVar.Haste))
                IROVar.GCDCDTimeOldHaste=IROVar.Haste
                IROVar.GCDCDTimeOldGCD=GCDCD
            else
                GCDCD=IROVar.GCDCDTimeOldGCD
            end
        end
    end
    IROVar.ERO_Old_Val.Update("GCDCDTime","",GCDCD)
    return GCDCD
end

--Temp Val of allDeBuffByMe
IROVar.temp_allDeBuffByMe ={[1]=0,[2]={}}
--[1]=timer , [2]= [GUID] = result
function IROVar.allDeBuffByMe(unit)
    --*********return table of [Debuff name] = Debuff time remaining
	local allDeBuff={}
	local unitGUID = UnitGUID(unit)
	if not unitGUID then return allDeBuff end
	local currentTimer = GetTime()
	if (IROVar.temp_allDeBuffByMe[1]==currentTimer)and(IROVar.temp_allDeBuffByMe[2][unitGUID]) then
		return IROVar.temp_allDeBuffByMe[2][unitGUID]
	end
	if IROVar.temp_allDeBuffByMe[1]<currentTimer then
		IROVar.temp_allDeBuffByMe[1]=currentTimer
		IROVar.temp_allDeBuffByMe[2]={}
	end
    local DebuffName,expTime
    for i=1,400 do
        DebuffName,_,_,_,_,expTime = UnitAura(unit, i, "PLAYER|HARMFUL")
        if DebuffName then
            allDeBuff[DebuffName]=expTime-GetTime()
        else break end
    end
	IROVar.temp_allDeBuffByMe[2][unitGUID]=allDeBuff
    return allDeBuff
end

--Temp Val of allBuffByMe
IROVar.temp_allBuffByMe ={[1]=0,[2]={}}
--[1]=timer , [2]= [GUID] = result
function IROVar.allBuffByMe(unit,needLowerCaseName)
    --*********return table of [Buff name] = Buff time remaining
	local allBuff={}
	local unitGUID = UnitGUID(unit)
	if not unitGUID then return allBuff end
	local currentTimer = GetTime()
	if (IROVar.temp_allBuffByMe[1]==currentTimer)and(IROVar.temp_allBuffByMe[2][unitGUID]) then
		return IROVar.temp_allBuffByMe[2][unitGUID]
	end
	if IROVar.temp_allBuffByMe[1]<currentTimer then
		IROVar.temp_allBuffByMe[1]=currentTimer
		IROVar.temp_allBuffByMe[2]={}
	end
    local buffName,expTime
	if needLowerCaseName then
		for i=1,400 do
			buffName,_,_,_,_,expTime = UnitAura(unit, i, "PLAYER|HELPFUL")
			if buffName then
				allBuff[string.lower(buffName)]=expTime-GetTime()
			else break end
		end
	else
		for i=1,400 do
			buffName,_,_,_,_,expTime = UnitAura(unit, i, "PLAYER|HELPFUL")
			if buffName then
				allBuff[buffName]=expTime-GetTime()
			else break end
		end
	end
	IROVar.temp_allBuffByMe[2][unitGUID]=allBuff
    return allBuff
end

function IROVar.IconSweepCompair(icon,max,min)
    --return max>SweepCD>min
    if not icon then return true end
    if (min<=0) and (icon.Modules.IconModule_CooldownSweep.start==0) then return true end
    local stdu=icon.Modules.IconModule_CooldownSweep.start+icon.Modules.IconModule_CooldownSweep.duration
    local mint=stdu-max
    local maxt=stdu-min
    local ct=GetTime()
    return  (ct>mint) and (ct<maxt)
end

function IROVar.IconSweepRemain(icon) -- return SecRemain,MaxRemain
    --return max>SweepCD>min
    if not icon then return 0,1 end
    if icon.Modules.IconModule_CooldownSweep.start==0 then return 0,1 end
    local du=icon.Modules.IconModule_CooldownSweep.duration
    local remain=icon.Modules.IconModule_CooldownSweep.start+du-GetTime()
    return remain,du
end

function IROVar.DetermineActiveCovenantAndSoulbindAndConduits()
    local covenantID = C_Covenants.GetActiveCovenantID();
    if ( not covenantID or covenantID == 0 ) then
      --No active covenants
      return nil;
    end
    local covenantData = C_Covenants.GetCovenantData(covenantID);
    if ( not covenantData ) then 
      --No covenant found
      return nil;
    end
    local covenantName = covenantData.name;
    local soulbindID = C_Soulbinds.GetActiveSoulbindID();
    if ( not soulbindID or soulbindID == 0 ) then 
      --No active soulbinds
      return nil;
    end
    local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
    if ( not soulbindData ) then
      --No active soulbinds
      return nil;
    end
    local id = soulbindData["ID"];
    --local covenantID = soulbindData["covenantID"];
    local soulbindName = soulbindData["name"];
    local description = soulbindData["description"];
    local tree = soulbindData["tree"];
    local nodes = tree["nodes"];
    local activeConduitsSpells = {};
    activeConduitsSpells.covenantName = covenantName;
    activeConduitsSpells.soulbindName = soulbindName;
    activeConduitsSpells.conduits = {};
    for _, ve in pairs(nodes) do
      local node_id = ve["ID"];
      local node_row = ve.row;
      local node_column = ve.column;
      local node_spellID = ve.spellID; -- this will be 0 for uninit spell, not nil
      local node_conduitID = ve.conduitID; -- this will be 0 for uninit conduit, not nil
      local node_conduitRank = ve.conduitRank;
      local node_state = ve.state;
      local node_conduitType = ve.conduitType; -- this can be nil
      if ( node_state == 3 ) then
        local node_spellName;
        if ( node_spellID ~= 0 ) then
          node_spellName = GetSpellInfo(node_spellID);
        elseif ( node_conduitID ~= 0 ) then
          local conduitSpellID = C_Soulbinds.GetConduitSpellID(node_conduitID,node_conduitRank);
          node_spellID = conduitSpellID;
          node_spellName = GetSpellInfo(conduitSpellID);
        else
          node_spellID = nil;
          node_spellName = nil;
        end
        if ( node_spellID ) then
          activeConduitsSpells.conduits[#activeConduitsSpells.conduits + 1] = { spellID = node_spellID, spellName = node_spellName };
          activeConduitsSpells[node_spellID]=true
          activeConduitsSpells[node_spellName]=true
        end
      end
    end
    return activeConduitsSpells;
end

IROVar.justCheckActiveConduits=0

IROVar.fconduitOnEvent=function()
    local now=GetTime()
    if now <= IROVar.justCheckActiveConduits then return end
    IROVar.justCheckActiveConduits=now+0.4
    C_Timer.After(0.5,function()
        IROVar.activeConduits=IROVar.DetermineActiveCovenantAndSoulbindAndConduits()
        if not IROVar.activeConduits then IROVar.activeConduits={} end
    end)
end

-- patch 9.x.x Shadowlands SL
-- listen to soulbinds/conduits changes
IROVar.fconduit = CreateFrame("Frame")
IROVar.fconduit:RegisterEvent("COVENANT_CALLINGS_UPDATED")
IROVar.fconduit:RegisterEvent("COVENANT_CHOSEN")
IROVar.fconduit:RegisterEvent("SOULBIND_ACTIVATED")
IROVar.fconduit:RegisterEvent("SOULBIND_PATH_CHANGED")
--IROVar.fconduit:RegisterEvent("SOULBIND_CONDUITS_RESET")
IROVar.fconduit:RegisterEvent("SOULBIND_NODE_UPDATED")
IROVar.fconduit:RegisterEvent("GARRISON_UPDATE")
IROVar.fconduit:SetScript("OnEvent", IROVar.fconduitOnEvent)

C_Timer.After(1,IROVar.fconduitOnEvent)


IROVar.incombatCallBackRun={}
IROVar.outcombatCallBackRun={}
function IROVar.RegisterIncombatCallBackRun(name,callBack)
    IROVar.incombatCallBackRun[name]=callBack
end
function IROVar.RegisterOutcombatCallBackRun(name,callBack)
    IROVar.outcombatCallBackRun[name]=callBack
end
function IROVar.UnRegisterOutcombatCallBackRun(name)
    IROVar.outcombatCallBackRun[name]=nil
end
function IROVar.UnRegisterIncombatCallBackRun(name)
    IROVar.incombatCallBackRun[name]=nil
end
IROVar.incombat = UnitAffectingCombat("player")
IROVar.incombatFrame = CreateFrame("Frame")
IROVar.incombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
IROVar.incombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
IROVar.incombatFrame:SetScript("OnEvent", function(self, event)
    IROVar.incombat = (event=="PLAYER_REGEN_DISABLED")
    if event=="PLAYER_REGEN_DISABLED" then
        -- In Combat
        for k,v in pairs(IROVar.incombatCallBackRun) do if v then v() end end
    else
        -- Out Combat
        for k,v in pairs(IROVar.outcombatCallBackRun) do if v then v() end end
    end
end)
IROVar.COMBAT_LOG_EVENT_UNFILTERED_CALLBACK={}
function IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK(name,callBack)
    IROVar.COMBAT_LOG_EVENT_UNFILTERED_CALLBACK[name]=callBack
end
function IROVar.UnRegister_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK(name)
    IROVar.COMBAT_LOG_EVENT_UNFILTERED_CALLBACK[name]=nil
end

function IROVar.COMBAT_LOG_EVENT_UNFILTERED_scrip(...)
    for k,v in pairs(IROVar.COMBAT_LOG_EVENT_UNFILTERED_CALLBACK) do if v then v(...) end end
end
IROVar.COMBAT_LOG_EVENT_UNFILTERED_frame = CreateFrame("Frame")
IROVar.COMBAT_LOG_EVENT_UNFILTERED_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.COMBAT_LOG_EVENT_UNFILTERED_frame:SetScript("OnEvent", function(self, event, ...)
    IROVar.COMBAT_LOG_EVENT_UNFILTERED_scrip(CombatLogGetCurrentEventInfo())
end)

IROVar.PLAYER_TARGET_CHANGED_CALLBACK={}
function IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK(name,callBack)
    IROVar.PLAYER_TARGET_CHANGED_CALLBACK[name]=callBack
end
function IROVar.UnRegister_PLAYER_TARGET_CHANGED_scrip_CALLBACK(name)
    IROVar.PLAYER_TARGET_CHANGED_CALLBACK[name]=nil
end
IROVar.PLAYER_TARGET_CHANGED_frame = CreateFrame("Frame")
IROVar.PLAYER_TARGET_CHANGED_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
IROVar.PLAYER_TARGET_CHANGED_frame:SetScript("OnEvent", function()
    for k,v in pairs(IROVar.PLAYER_TARGET_CHANGED_CALLBACK) do if v then v() end end
end)


IROVar.SPELL_UPDATE_COOLDOWN_CALLBACK={}

function IROVar.SPELL_UPDATE_COOLDOWN_scrip()
    local st,du = GetSpellCooldown(TMW.GCDSpell)
    local GCDEnd=0
    if st then
        GCDEnd=st+du
    end
    for k,v in pairs(IROVar.SPELL_UPDATE_COOLDOWN_CALLBACK) do
        if v then v(GCDEnd) end
    end
end

IROVar.SPELL_UPDATE_COOLDOWN_count=0

function IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK(name,callBack)
    IROVar.SPELL_UPDATE_COOLDOWN_CALLBACK[name]=callBack
end
function IROVar.UnRegister_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK(name)
    IROVar.SPELL_UPDATE_COOLDOWN_CALLBACK[name]=nil
end
IROVar.SPELL_UPDATE_COOLDOWN_frame = CreateFrame("Frame")
IROVar.SPELL_UPDATE_COOLDOWN_frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
IROVar.SPELL_UPDATE_COOLDOWN_frame:RegisterEvent("SPELL_UPDATE_USABLE")
IROVar.SPELL_UPDATE_COOLDOWN_frame:SetScript("OnEvent", function(self, event, ...)
    IROVar.SPELL_UPDATE_COOLDOWN_count=IROVar.SPELL_UPDATE_COOLDOWN_count+1
    IROVar.SPELL_UPDATE_COOLDOWN_scrip()
end)

IROVar.TickCount01=0
IROVar.TickCount01_Handle=C_Timer.NewTicker(0.017,function()
    IROVar.TickCount01=IROVar.TickCount01+1
end)

IROVar.CastBar={}
IROVar.CastBar.Casting=nil
IROVar.CastBar.Channeling=nil
IROVar.CastBar.Calculated={}
--kick mean interrupt
--IROVar.CastBar.Calculated[percent][1]=0 --start Kick
--IROVar.CastBar.Calculated[percent][2]=0 --end Kick
IROVar.CastBar.Spell=nil
IROVar.CastBar.SpellId=nil
IROVar.CastBar.CantKick=false
function IROVar.CastBar.CheckCasting()
    local C={UnitCastingInfo("target")}
    if C[1] then IROVar.CastBar.Casting=C
    else IROVar.CastBar.Casting=nil
    end
end

function IROVar.CastBar.CheckChanneling()
    local C={UnitChannelInfo("target")}
    if C[1] then IROVar.CastBar.Channeling=C
    else IROVar.CastBar.Channeling=nil
    end
end

function IROVar.CastBar.ResetKick()
    IROVar.CastBar.CantKick=false
    IROVar.CastBar.Spell=nil
    IROVar.CastBar.SpellId=nil
    IROVar.CastBar.Calculated={}
end

function IROVar.CastBar.CheckSpellInfo()
    local notInterruptible = false
    local spell = nil
    local SpellId = nil
    if IROVar.CastBar.Casting then
        notInterruptible=IROVar.CastBar.Casting[8]
        spell=IROVar.CastBar.Casting[1]
        SpellId=IROVar.CastBar.Casting[9]
    elseif IROVar.CastBar.Channeling then
        notInterruptible=IROVar.CastBar.Channeling[7]
        spell=IROVar.CastBar.Channeling[1]
        SpellId=IROVar.CastBar.Channeling[8]
    end
    IROVar.CastBar.CantKick=notInterruptible
    IROVar.CastBar.Spell=spell
    IROVar.CastBar.SpellId=SpellId
end

function IROVar.CastBar.CalculateInterruptTimer(percenC)
    -- minC = dont interrupt before this time
    -- percenC = interrupt after this percent of the cast time
    -- maxC = dont interrupt after endCastTime-max time
    local maxC=0.2
    percenC=percenC or 0.6
    local startI = 0
    local endI = 0
    if IROVar.CastBar.Casting then
        local startTime=IROVar.CastBar.Casting[4]/1000
        local endCastTime=IROVar.CastBar.Casting[5]/1000
        local castTime=endCastTime-startTime
        local castTimePercent=castTime*percenC
        startI=castTimePercent+startTime
        endI=endCastTime-maxC
    elseif IROVar.CastBar.Channeling then
        local startTime=IROVar.CastBar.Channeling[4]/1000
        local endCastTime=IROVar.CastBar.Channeling[5]/1000
        local castTime=endCastTime-startTime
        if castTime>=1 then
            startI=startTime+0.8
            endI=endCastTime-maxC
        end
    end
    IROVar.CastBar.Calculated[percenC]={startI,endI}
end

IROVar.TargetChangeCount=0
IROVar.TargetName=UnitName("target")
IROVar.TargetGUID=UnitGUID("target")
IROVar.TargetLV=UnitLevel("target")

function IROVar.CastBar.CheckAll()
    IROVar.CastBar.CheckCasting()
    IROVar.CastBar.CheckChanneling()
    IROVar.CastBar.ResetKick()
    IROVar.CastBar.CheckSpellInfo()
end

IROVar.CastBar.CastFrame=CreateFrame("Frame")
IROVar.CastBar.CastFrame:RegisterEvent("UNIT_SPELLCAST_START")
IROVar.CastBar.CastFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
IROVar.CastBar.CastFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
IROVar.CastBar.CastFrame:SetScript("OnEvent",function(self,event,arg1,...)
    if event=="UNIT_SPELLCAST_START" and arg1=="target" then
        IROVar.CastBar.Channeling=nil
        IROVar.CastBar.CheckCasting()
        IROVar.CastBar.ResetKick()
        IROVar.CastBar.CheckSpellInfo()
    elseif event=="UNIT_SPELLCAST_CHANNEL_START" and arg1=="target" then
        IROVar.CastBar.Casting=nil
        IROVar.CastBar.CheckChanneling()
        IROVar.CastBar.ResetKick()
        IROVar.CastBar.CheckSpellInfo()
    elseif event=="PLAYER_TARGET_CHANGED" then
        IROVar.PLAYER_TARGET_CHANGED_Time=GetTime()
        IROVar.TargetChangeCount=IROVar.TargetChangeCount+1
        IROVar.TargetName=UnitName("target")
        IROVar.TargetGUID=UnitGUID("target")
        IROVar.TargetLV=UnitLevel("target")
        IROVar.CastBar.CheckAll()
    end
end)

C_Timer.NewTicker(0.3,IROVar.CastBar.CheckAll)

IROVar.CastBar.CastFrame2=CreateFrame("Frame")
IROVar.CastBar.CastFrame2:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
IROVar.CastBar.CastFrame2:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
IROVar.CastBar.CastFrame2:RegisterEvent("UNIT_SPELLCAST_STOP")
IROVar.CastBar.CastFrame2:SetScript("OnEvent",function(self,event,arg1,...)
    if arg1=="target" then
        IROVar.CastBar.Casting=nil
        IROVar.CastBar.Channeling=nil
        IROVar.CastBar.ResetKick()
    end
end)

function IROVar.TargetCastBar(percenCheck,DontCheckCantKick,Spell)
    if Spell and Spell~=IROVar.CastBar.SpellId and Spell~=IROVar.CastBar.Spell then
        return false
    end
    percenCheck=percenCheck or 0.6
    --Spell = nil ; mean any spell ; can be ID and Name
    --DontCheckCantKick = true mean kick even notInterruptible (for Stun)
    if not IROVar.CastBar.Calculated[percenCheck] then
        IROVar.CastBar.CalculateInterruptTimer(percenCheck)
    end
    local startKick=IROVar.CastBar.Calculated[percenCheck][1]
    local endKick=IROVar.CastBar.Calculated[percenCheck][2]
    if not DontCheckCantKick and IROVar.CastBar.CantKick then
            return false
    end
    local currentTime=GetTime()
    return currentTime>=startKick and currentTime<=endKick
end

function IROVar.CompareTable(a,b)
    local function subcompare(aa,bb)
        if (not aa) or (not bb) then return false end
        local equal=true
        for k,v in pairs(aa) do
            if type(v)=="table" then
                equal=IROVar.CompareTable(v,bb[k])
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

--IROVar.SPELL_UPDATE_COOLDOWN_count
IROInterruptTier.CDEnd=0
IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("IsMyInterruptSpellReady",function(GCDCDEnd)
    local st,du=GetSpellCooldown(IROVar.InterruptSpell)
    if st then IROInterruptTier.CDEnd=st+du else IROInterruptTier.CDEnd=0 end
end)

function IsMyInterruptSpellReady()
    if not IROVar.InterruptSpell then return false end
    return IROInterruptTier.CDEnd<=GetTime()
end

--UnitGroupRolesAssigned(n)
--TANK, HEALER, DAMAGER, NONE
--className, classFilename, classId = UnitClass(unit)
--[[
1	Warrior	WARRIOR	
2	Paladin	PALADIN	
3	Hunter	HUNTER	
4	Rogue	ROGUE	
5	Priest	PRIEST	
6	Death Knight	DEATHKNIGHT	Added in 3.0.2
7	Shaman	SHAMAN	
8	Mage	MAGE	
9	Warlock	WARLOCK	
10	Monk	MONK	Added in 4.0.1
11	Druid	DRUID	
12	Demon Hunter	DEMONHUNTER	Added in 7.0.3
]]
local classDecurse =
{
    ["MAGE"]=true,
    ["SHAMAN"]=true,
    ["DRUID"]=true,
}
IROVar.decurseInGroup=0

function IROVar.DecurseCheck()-- return number of Decurser
    local function DecurseClass(UnitToken)
        local _,class=UnitClass(UnitToken)
        return classDecurse[class]
    end
    local Dn=0
    if IsInRaid() then
        for i=1,40 do
            local n="raid"..i
            if UnitExists(n) and DecurseClass(n) then Dn=Dn+1 end
        end
    elseif IsInGroup() then
        for i=1,4 do
            local n="party"..i
            if UnitExists(n) and DecurseClass(n) then Dn=Dn+1 end
        end
        if DecurseClass("player") then Dn=Dn+1 end
    else
        if DecurseClass("player") then Dn=Dn+1 end
    end
    IROVar.decurseInGroup=Dn
end

IROVar.IsDecurseF=CreateFrame("Frame")
IROVar.IsDecurseF:RegisterEvent("GROUP_ROSTER_UPDATE")
IROVar.IsDecurseF:SetScript("OnEvent",function()
    IROVar.DecurseCheck()
end)
C_Timer.NewTicker(6,IROVar.DecurseCheck,10)

function IROVar.DecurseInGroup()
    return IROVar.decurseInGroup
end

function IROVar.UnitCount(n)
    return IROVar.AutoTarget and IROVar.AutoTarget.UnitCount[n] or 0
end

IROVar.KickPressed=false
function IROVar.KickPress()
    IROVar.KickPressed=true
    C_Timer.After(0.4,function()
        IROVar.KickPressed=false
    end)
end