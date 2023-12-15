-- Many Function Version 9.0.5/82
-- Set Priority to 1
-- this file save many function for paste to TMW Snippet LUA

--function GCDActiveLessThan(ttime) ; return true/false
--function SumHPMobinCombat() ; return SumHP
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
--function IROVar.Register_TALENT_CHANGE_scrip_CALLBACK(name,callback)
--var IROVar.SPELL_UPDATE_COOLDOWN_count = Count Event Call; use to detemin Update CD
--var IROVar.TickCount01 = Tick Count every 0.1 sec; use to detemin Update CD

--var IROVar.Haste ; player Haste
--var IROVar.CastTime2sec ; cast time in second mod by haste
--var IROVar.CastTime2_25sec
--var IROVar.CastTime6sec
--var IROVar.CastTime1_5sec
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

--IROVar.ignoreName = {Mob Name = true} ; ignore mob name
--IROVar.TargetName = TargetName;
--IROVar.TargetGUID = TargetGUID;
--function IROVar.CompareTable(a,b) ; return true|false

--function IROVar.IsUnitCCed(unit) ; return true/false | Dont Break CC
--function IROVar.KickPress() ; IROVar.KickPressed=true 0.5 sec after turn to false
--function IROVar.UpdateCounter(n,v) ; update counter name to value

--function IROVar.DelayCT(countername,time)
    -- when call turn countername to 1 and time sec pass turn to 0
    -- e.g. IROVar.DelayCT("usehp",1)

--function IROVar.CTTOK(GUID) -- check Mob Cannot CC by Addon CantTouchThis

local TMW=TMW
IROVar=IROVar or {}
--Timer
IROVar.playerName = UnitName("player")
IROVar.realmName = GetRealmName()

IROVar.IROEnemyGroupVVHPRunTick=0.5
IROVar.TickCount01_Tick=0.17
IROVar.CastBarCheck_Tick=0.41

IROVar.UseNAPKickHandle=C_Timer.NewTimer(1,function()end)
IROVar.UseNAPStunHandle=C_Timer.NewTimer(1,function()end)

IROVar.OnlyInterruptThisSpell=nil
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

local DelayCTHandle={}
function IROVar.DelayCT(countername,time)
    TMW_ST:UpdateCounter(countername,1)
    if DelayCTHandle[countername] then
        DelayCTHandle[countername]:Cancel()
    end
    do
        local cn=countername
        DelayCTHandle[countername]=C_Timer.NewTimer(time,function()
            TMW_ST:UpdateCounter(cn,0)
        end)
    end
end

function IROVar.CalculateHaste()
    IROVar.Haste = UnitSpellHaste("player")
    IROVar.HasteFactor = 100/(100+IROVar.Haste)
    IROVar.CastTime2sec = 2*IROVar.HasteFactor
    IROVar.CastTime2_25sec = 2.25*IROVar.HasteFactor
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

IROVar.fspecOnEventCallBack={}
-- [1]={name,callback}...

function IROVar.fspecOnEvent(event)
    if IROVar.DebugMode then print("Event : "..((event~=nil) and event or "nil")) end
    IROVar.UpdateVar()
    C_Timer.After(5,IROVar.UpdateVar)
    for _,v in ipairs(IROVar.fspecOnEventCallBack) do
        v[2]()
    end
end

function IROVar.Register_TALENT_CHANGE_scrip_CALLBACK(name,callback)
    table.insert(IROVar.fspecOnEventCallBack,{name,callback})
end

IROVar.fspec = CreateFrame("Frame")
IROVar.fspec:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
IROVar.fspec:RegisterEvent("PLAYER_TALENT_UPDATE")
IROVar.fspec:RegisterEvent("TRAIT_CONFIG_UPDATED")
IROVar.fspec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
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

function IROTargetVVHP(nMultipy,unit)
    unit=unit or "target"
    nMultipy=nMultipy or 2
    local playerHealth=SumPartyHP()
    local targetHealth=UnitHealth(unit)
    return (nMultipy*playerHealth)<targetHealth
end

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
-- [1] = {name , Callback}
function IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK(name,callBack)
    table.insert(IROVar.PLAYER_TARGET_CHANGED_CALLBACK,{name,callBack})
end
function IROVar.UnRegister_PLAYER_TARGET_CHANGED_scrip_CALLBACK(name)
    for k,v in ipairs(IROVar.PLAYER_TARGET_CHANGED_CALLBACK) do
        if v[1]==name then
            table.remove(IROVar.PLAYER_TARGET_CHANGED_CALLBACK,k)
        end
    end
end
IROVar.PLAYER_TARGET_CHANGED_frame = CreateFrame("Frame")
IROVar.PLAYER_TARGET_CHANGED_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
IROVar.PLAYER_TARGET_CHANGED_frame:SetScript("OnEvent", function()
    for _,v in ipairs(IROVar.PLAYER_TARGET_CHANGED_CALLBACK) do v[2]() end
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
IROVar.TickCount01_Handle=C_Timer.NewTicker(IROVar.TickCount01_Tick,function()
    IROVar.TickCount01=IROVar.TickCount01+1
end)

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
    local st,du=GetSpellCooldown(IROVar.InterruptSpell or " ")
    if st then IROInterruptTier.CDEnd=st+du else IROInterruptTier.CDEnd=0 end
end)

function IsMyInterruptSpellReady()
    if not IROVar.InterruptSpell then return false end
    return IROInterruptTier.CDEnd<=GetTime()
end

IROVar.KickPressed=false
function IROVar.KickPress()
    IROVar.KickPressed=true
    IROVar.UseNAPCycle=nil
    C_Timer.After(0.4,function()
        IROVar.KickPressed=false
    end)
end

function IROVar.UpdateCounter(n,v)
    if TMW.COUNTERS[n]~=v then
        TMW.COUNTERS[n]=v
        TMW:Fire("TMW_COUNTER_MODIFIED",n)
    end
end

function IROVar.CTTOK(GUID)
    if CTT and CTT.immuneKnown then
        local NPCID=CTT.GetNPCId(GUID or "")
        return not(NPCID and CTT.immuneFound[NPCID] or CTT.immuneKnown[NPCID])
    else
        return true
    end
end


