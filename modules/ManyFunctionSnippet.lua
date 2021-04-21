-- Many Function Version 9.0.5/38
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
--function IsMyInterruptSpellReady() ; true/false
--function TMW.CNDT.Env.CooldownDuration([spellName/Id, e.g. "execute"], [include GCD, true/false]); return CD remain (sec)
--function IROVar.ERO_Old_Val.Check(functionName,input_val_string) ; return Old Val at Same GetTime() , or nil
--function IROVar.ERO_Old_Val.Update(functionName,input_val_string,result_val) ; update Old_Val at same GetTime()
--function IROVar.Debug() show some Debug val
--function SumPartyHP() return party HP
--var IROSpecID = GetSpecializationInfo(GetSpecialization()),e.g. 62="Mage arcane",63="Mage fire",64="Mage frost"
--function IROVar.CheckDPSRange(nUnit) ; return Can Dps Unit?
--function IROVar.allDeBuffByMe(unit) ; return table of debuff
--function IROVar.allBuffByMe(unit,needLowerCaseName)
----*********return table of [Buff name] = Buff time remaining
--function TMW.CNDT.Env.AuraDur(unit, name, filter) ; return aura Duration
--function IROVar.IconSweepCompair(icon,max,min) ; return (max > SweepCD > min) (true/false)

if not IROVar then IROVar={} end
IROVar.DebugMode = false
IROVar.InterruptSpell = nil
IROVar.SkillCheckDPSRange = nil
IROVar.InstanceName = GetInstanceInfo()
if not IROSpecID then
    IROSpecID = GetSpecializationInfo(GetSpecialization())
end
IROInterruptTier = {}
--IROInterruptTier[specID]={interruptTier,interruptSpellName,DPSCheckSkill,Range,Role,CastType}
--MOVE this table to ERO DPS Decoder 9.0.5/5
for k,v in pairs(IROUsedSkillControl.ClassType) do
    IROInterruptTier[k]=v
end
IROInterruptTier.CDEnd=0

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

function IsMyInterruptSpellReady()
    if not IROVar.InterruptSpell then return false end
    local currentTime=GetTime()
    if IROInterruptTier.CDEnd>currentTime then return false end
    local CD=TMW.CNDT.Env.CooldownDuration(IROVar.InterruptSpell)
    if CD>0 then
        IROInterruptTier.CDEnd=CD+currentTime
        return false
    end
    return true
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

IROVar.DontUseCD ={
    ["Mists of Tirna Scithe"] ={
        ["Droman Oulfarran"]= true,
    }
}

function IROVar.IconSweepCompair(icon,max,min)
    --return max>SweepCD>min
    if not icon then return true end
    local stdu=icon.Modules.IconModule_CooldownSweep.start+icon.Modules.IconModule_CooldownSweep.duration
    local mint=stdu-max
    local maxt=stdu-min
    local ct=GetTime()
    return  (ct>mint) and (ct<maxt)
end