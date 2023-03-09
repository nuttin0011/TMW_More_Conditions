-- ManyFunctionSnippet_Counter_Variable 10.0.0/16
-- Set Priority to 6
-- use Many Function Aura Tracker
--[[
"targethp" = UnitHealth("target")
"playerhppercen" = math.floor(UnitHealth("player")/UnitHealthMax("player")*100)
"targetenraged" = Enraged timer 0 = 0.0-0.39
"playernothasquake" = IROVar.CV.Register_Player_Aura_Not_Has("Quake","playernothasquake")

"intericon" = 
    IROVar.InterruptSpell and 
    IROVar.TargetCastBar(0.1) and 
    IsMyInterruptSpellReady() and 
    IROVar.CareInterrupt("target") and 
    NextInterrupter.IsMyTurn() and
    (IsSpellInRange(IROVar.InterruptSpell,"target")==1)
"intericona" = IROVar.TargetCastBar(0.1)and 1 or 0)
"intericonb" = IROVar.TargetCastBar(0.4)and 1 or 0)
"intericonc" = IROVar.TargetCastBar(0.7)and 1 or 0)
"stunicon" = IROVar.TargetCastBar(0.3,true)and IROVar.OKStunedTarget()and NextInterrupter.ZeroSITarget()and(not IROVar.KickPressed)
"stuniconb" = IROVar.VVCareInterruptTarget()
"enemycountviii" = IROEnemyCountInRange(8)

-- Register Counter Aura Duration Track
--Auto Push Aura Duration To Counter
-- 0.0 - 0.39 = 0
-- 0.4 - 1.39 = 1
-- 1.4 - 2.39 = 2 ...
--function IROVar.CV.Register_Player_Aura_Duration(AuraName,counterName)
--function IROVar.CV.UnRegister_Player_Aura_Duration(AuraName)
--function IROVar.CV.Register_Player_Aura_Arg(AuraName,counterName,ArgNo,[function(ArgValue)])

        eg. if expire > 1 sec counter = 1, otherwise 0
        IROVar.CV.Register_Player_Aura_Arg("Demonic Core","demoniccore",6,
            function(expTime)
                return (expTime-GetTime() > 1) and 1 or 0
            end)

-- Aura Has 0 = not sure , 1 = Has , check Duration > 0.4 sec
--function IROVar.CV.Register_Player_Aura_Has(AuraName,counterName)
--function IROVar.CV.UnRegister_Player_Aura_Has(AuraName)

-- Aura not Has 0 = not sure , 1 = not Has , check Duration < 0.1 sec or nil
--function IROVar.CV.Register_Player_Aura_Not_Has(AuraName,counterName)
--function IROVar.CV.UnRegister_Player_Aura_Not_Has(AuraName)

--function IROVar.CV.Register_Target_Aura_Duration(AuraName,counterName,filter)
    --use same filter ll make it faster!!!!!
--function IROVar.CV.UnRegister_Target_Aura_Duration(AuraName,filter)

-- Player Unit Power -- refresh every 0.1 sec
-- function IROVar.CV.Register_Player_Power(PowerType,counterName,[CallBack_function(PowerValue)])
-- function IROVar.CV.UnRegister_Player_Power(PowerType) 
    **** We can use Only 1 Power Type per 1 Counter
    if need more function can insert in [CallBack_function(PowerValue)]
    0="MANA",
    1="RAGE",
    2="FOCUS",
    3="ENERGY",
    4="COMBO_POINTS",
    5="RUNES",
    6="RUNIC_POWER",
    7="SOUL_SHARDS",
    8="LUNAR_POWER",
    9="HOLY_POWER",

    e.g.
    IROVar.CV.Register_Player_Power(3,"en")
    IROVar.CV.Register_Player_Power(1,"rage")
    IROVar.CV.Register_Player_Power(8,"lunarpower",function(AP)
        --need more counter place here
        IROVar.UpdateCounter("lunarpoweradd",AP+IROVar.DruidBalance.PredictAPadd())
    end)
]]
if not IROVar then IROVar = {} end
if not IROVar.CV then IROVar.CV = {} end

IROVar.CV.InterIcon_Trigger_Tick=0.3
IROVar.CV.StunIcon_Trigger_Tick=0.31
IROVar.CV.Targethp_Tick=0.7
IROVar.CV.PlayerHPPercen_Tick=0.18
IROVar.CV.EC8Tick=0.8

--Enemy Count 8yard
--"item:34368" 8 yard
--"item:28767" 40 yard
IROVar.CV.EC8Tick=0.8
local EC8BanName={
    ["Explosive"]=true,
}
local function EC8()
    local nn
    local c=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player",nn) and (not EC8BanName[UnitName(nn)]) then
            c=c+(IsItemInRange("item:34368",nn) and 1 or 0)
        end
        if c>=6 then break end
    end
    IROVar.UpdateCounter("enemycountviii",c)
end
IROVar.CV.EC8H=C_Timer.NewTicker(IROVar.CV.EC8Tick,function()
    if TMW.time-IUSC.SkillPressStampTime>=IROVar.CV.EC8Tick then
        EC8()
    end
end)
IUSC.RegCallBackAfterSU["EC8"]=EC8


----------Interrupt Icon
local func=function()
    IROVar.UpdateCounter("intericon",(IROVar.InterruptSpell and IROVar.TargetCastBar(0.1)and IsMyInterruptSpellReady()and IROVar.CareInterrupt("target")and NextInterrupter.IsMyTurn()and(IsSpellInRange(IROVar.InterruptSpell,"target")==1))and 1 or 0)
    IROVar.UpdateCounter("intericona",IROVar.TargetCastBar(0.1)and 1 or 0)
    IROVar.UpdateCounter("intericonb",IROVar.TargetCastBar(0.4)and 1 or 0)
    IROVar.UpdateCounter("intericonc",IROVar.TargetCastBar(0.7)and 1 or 0)
end
IROVar.CV.InterIconH=C_Timer.NewTicker(IROVar.CV.InterIcon_Trigger_Tick,func)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Counter_Variable intericon",func)

----------Stun Icon
local func2=function()
    IROVar.UpdateCounter("stunicon",(IROVar.TargetCastBar(0.3,true)and IROVar.OKStunedTarget()and NextInterrupter.ZeroSITarget()and(not IROVar.KickPressed))and 1 or 0)
    IROVar.UpdateCounter("stuniconb",IROVar.VVCareInterruptTarget()and 1 or 0)
end
IROVar.CV.StunIconH=C_Timer.NewTicker(IROVar.CV.StunIcon_Trigger_Tick,func2)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Counter_Variable stunicon",func2)

-- target HP
local function TargetHP()
    IROVar.UpdateCounter("targethp",UnitHealth("target"))
end
IROVar.CV.TargetHPH=C_Timer.NewTicker(IROVar.CV.Targethp_Tick,TargetHP)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Target Health Counter",TargetHP)

-- player HP percen
local function PlayerHPP()
    IROVar.UpdateCounter("playerhppercen",math.floor(UnitHealth("player")/UnitHealthMax("player")*100))
end
IROVar.CV.PlayerHPPercenH=C_Timer.NewTicker(IROVar.CV.PlayerHPPercen_Tick,PlayerHPP)

-- Register Counter Aura Duration Track
IROVar.CV.AuraDuration={}
IROVar.CV.AuraHandle={}

local function D2C(Du) -- Change Duration (s) to counter (integer)
    return math.floor(Du+0.6)
end
local function E2D(Exp) -- Change ExpTime to Duration (now)
    local du = Exp-GetTime()
    return du
end
local function NextUpdate(du) -- return Next secound for UpdateCounter
    --ex. if Du = 1.6 , Counter Is 2 , Next Counter Change To 1 is 0.21 s (at Du = 1.39)
    --ex. if Du = 1.39 , Counter Is 1 , Next Counter Change To 0 is 1 s (at Du = 0.39)
    local b=du+0.6
    return b+0.01-math.floor(b)
end

local function UpdateAura(AuraName)
    local function Reset0(a)
        if IROVar.CV.AuraHandle[a] then
            IROVar.CV.AuraHandle[a]:Cancel()
            IROVar.CV.AuraHandle[a]=nil
        end
        IROVar.UpdateCounter(IROVar.CV.AuraDuration[a],0)
    end
    local exp=IROVar.Aura1.My[AuraName]
    if not exp then
        Reset0(AuraName)
    else
        local d=E2D(exp)
        local c=D2C(d)
        if d<0 then --aura has no time limit
            IROVar.UpdateCounter(IROVar.CV.AuraDuration[AuraName],1)
        elseif c<=0 then
            Reset0(AuraName)
        else
            IROVar.UpdateCounter(IROVar.CV.AuraDuration[AuraName],c)
            --print(c,d,NextUpdate(d))
            do
                local a=AuraName
                IROVar.CV.AuraHandle[a]=C_Timer.NewTimer(NextUpdate(d),function()UpdateAura(a)end)
            end
        end
    end
end
function IROVar.CV.DumpAuraDuration()
    for k,_ in pairs(IROVar.CV.AuraDuration) do
        if IROVar.Aura1.Changed[k] then
            if IROVar.CV.AuraHandle[k] then
                IROVar.CV.AuraHandle[k]:Cancel()
                IROVar.CV.AuraHandle[k]=nil
            end
            UpdateAura(k)
        end
    end
end
function IROVar.CV.Register_Player_Aura_Duration(AuraName,counterName)
    if not IROVar.Aura1.TrackedAura[AuraName] then
        IROVar.Aura1.RegisterTrackedAura(AuraName)
    end
    IROVar.CV.AuraDuration[AuraName]=counterName
    if not IROVar.CV.AuraHandle[AuraName] then UpdateAura(AuraName) end
end
function IROVar.CV.UnRegister_Player_Aura_Duration(AuraName)
    IROVar.UpdateCounter(IROVar.CV.AuraDuration[AuraName],0)
    IROVar.CV.AuraDuration[AuraName]=nil
    if IROVar.CV.AuraHandle[AuraName] then
        IROVar.CV.AuraHandle[AuraName]:Cancel()
        IROVar.CV.AuraHandle[AuraName]=nil
    end
end

IROVar.CV.AuraArg={} -- = {[AuraName]={counterName,ArgNo}}
function IROVar.CV.Register_Player_Aura_Arg(AuraName,counterName,ArgNo,callbackArgMod)
    if not IROVar.Aura1.TrackedAura[AuraName] then
        IROVar.Aura1.RegisterTrackedAura(AuraName)
    end
    IROVar.CV.AuraArg[AuraName]={counterName,ArgNo,callbackArgMod}
end
local function UpdateAuraArg(AuraN)
    local cName=IROVar.CV.AuraArg[AuraN][1]
    local aArg=IROVar.CV.AuraArg[AuraN][2]
    local aVal=IROVar.Aura1.AuraInfo[AuraN] and IROVar.Aura1.AuraInfo[AuraN][aArg] or 0
    if IROVar.CV.AuraArg[AuraN][3] then
        aVal=IROVar.CV.AuraArg[AuraN][3](aVal)
    end
    IROVar.UpdateCounter(cName,aVal)
end
function IROVar.CV.DumpAuraArg()
    for k,_ in pairs(IROVar.CV.AuraArg) do
        if IROVar.Aura1.Changed[k] then
            UpdateAuraArg(k)
        end
    end
end
IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("DumpAuraDuration + DumpAuraArg",function(unit)
    if unit=="player" then
        IROVar.CV.DumpAuraDuration()
        IROVar.CV.DumpAuraArg()
    end
end)

-- Aura has 0 = not sure , 1 = has
IROVar.CV.AuraHas={}
IROVar.CV.AuraHasHandle={}

local function NextUpdateAuraHas(du)
    return du-0.39
end
function IROVar.CV.Aura_Has_Update1(n,c)
    local exp=IROVar.Aura1.My[n]
    local du=exp and E2D(exp) or 0
    if du<0 then -- Aura has no time limit
        IROVar.UpdateCounter(c,1)
    elseif du<0.4 then
        IROVar.UpdateCounter(c,0)
    else
        IROVar.UpdateCounter(c,1)
        do
            local a,CC=n,c
            IROVar.CV.AuraHasHandle[a]=C_Timer.NewTimer(NextUpdateAuraHas(du),function()
                IROVar.CV.Aura_Has_Update1(a,CC)
            end)
        end
    end
end
function IROVar.CV.Register_Player_Aura_Has(AuraName,counterName)
    if not IROVar.Aura1.TrackedAura[AuraName] then
        IROVar.Aura1.RegisterTrackedAura(AuraName)
    end
    IROVar.CV.AuraHas[AuraName]=counterName
    IROVar.CV.Aura_Has_Update1(AuraName,counterName)
end
function IROVar.CV.UnRegister_Player_Aura_Has(AuraName)
    IROVar.UpdateCounter(IROVar.CV.AuraHas[AuraName],0)
    IROVar.CV.AuraHas[AuraName]=nil
end
IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.CV.AuraHas",function(unit)
    if unit=="player" then
        for k,v in pairs(IROVar.CV.AuraHas) do
            if IROVar.Aura1.Changed[k] then
                if IROVar.CV.AuraHasHandle[k] then
                    IROVar.CV.AuraHasHandle[k]:Cancel()
                    IROVar.CV.AuraHasHandle[k]=nil
                end
                IROVar.CV.Aura_Has_Update1(k,v)
            end
        end
    end
end)
-- Aura not has 0 = not sure , 1 = not has
IROVar.CV.AuraNotHas={}
IROVar.CV.AuraNotHasHandle={}
local function NextUpdateAuraNotHas(du)
    return du-0.09
end
function IROVar.CV.Aura_Not_Has_Update1(n,c)
    local exp=IROVar.Aura1.My[n]
    local du=exp and E2D(exp) or 0
    if du<0 then --aura has no time limit
        IROVar.UpdateCounter(c,0)
    elseif du>=0.1 then
        IROVar.UpdateCounter(c,0)
        do
            local a,CC=n,c
            IROVar.CV.AuraNotHasHandle[a]=C_Timer.NewTimer(NextUpdateAuraNotHas(du),function()
                IROVar.CV.Aura_Not_Has_Update1(a,CC)
            end)
        end
    else
        IROVar.UpdateCounter(c,1)
    end
end
function IROVar.CV.Register_Player_Aura_Not_Has(AuraName,counterName)
    if not IROVar.Aura1.TrackedAura[AuraName] then
        IROVar.Aura1.RegisterTrackedAura(AuraName)
    end
    IROVar.CV.AuraNotHas[AuraName]=counterName
    IROVar.CV.Aura_Not_Has_Update1(AuraName,counterName)
end
function IROVar.CV.UnRegister_Player_Aura_Not_Has(AuraName)
    IROVar.UpdateCounter(IROVar.CV.AuraNotHas[AuraName],0)
    IROVar.CV.AuraNotHas[AuraName]=nil
end
IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.CV.AuraNotHas",function(unit)
    if unit=="player" then
        for k,v in pairs(IROVar.CV.AuraNotHas) do
            if IROVar.Aura1.Changed[k] then
                if IROVar.CV.AuraNotHasHandle[k] then
                    IROVar.CV.AuraNotHasHandle[k]:Cancel()
                    IROVar.CV.AuraNotHasHandle[k]=nil
                end
                IROVar.CV.Aura_Not_Has_Update1(k,v)
            end
        end
    end
end)

-- Player Unit Power -- refresh every 0.1 sec
-- function IROVar.CV.Register_Player_Power(PowerType,counterName,[CallBack_function(PowerValue)])
-- function IROVar.CV.UnRegister_Player_Power(PowerType) 
IROVar.CV.Power={}
-- ["Power Type"]="counterName"
IROVar.CV.PowerCallBack={}
IROVar.CV.PowerRunning={}
IROVar.CV.PowerChange={}
IROVar.CV.PowerType={
    ["MANA"]=0,
    ["RAGE"]=1,
    ["FOCUS"]=2,
    ["ENERGY"]=3,
    ["COMBO_POINTS"]=4,
    ["RUNES"]=5,
    ["RUNIC_POWER"]=6,
    ["SOUL_SHARDS"]=7,
    ["LUNAR_POWER"]=8,
    ["HOLY_POWER"]=9,
}

--local oldCheck = GetTime()
function IROVar.CV.CheckPower(cN,pT)
    if IROVar.CV.PowerChange[pT] then
        --print (GetTime()-oldCheck)
        --oldCheck=GetTime()
        local power=UnitPower("player",pT)
        IROVar.UpdateCounter(cN,power)
        if IROVar.CV.PowerCallBack[pT] then
            IROVar.CV.PowerCallBack[pT](power)
        end
        IROVar.CV.PowerChange[pT]=false
        IROVar.CV.PowerRunning[pT]=true
        do local cc,pp=cN,pT
            C_Timer.After(0.13,function()
                IROVar.CV.CheckPower(cc,pp)
            end)
        end
    else
        IROVar.CV.PowerRunning[pT]=false
    end
end

local function SetupUnitPowerFrame()
    IROVar.CV.UnitPowerFrame=CreateFrame("Frame")
    IROVar.CV.UnitPowerFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    IROVar.CV.UnitPowerFrame:SetScript("OnEvent",function(_,_,unit,powerType)
        if unit~="player" then return end
        powerType=IROVar.CV.PowerType[powerType] or -1
        local c=IROVar.CV.Power[powerType]
        if not c then return end
        IROVar.CV.PowerChange[powerType]=true
        if not IROVar.CV.PowerRunning[powerType] then
            IROVar.CV.CheckPower(c,powerType)
        end
    end)
end

function IROVar.CV.Register_Player_Power(PowerType,counterName,CallBackFunc)
    IROVar.CV.Power[PowerType]=counterName
    IROVar.CV.PowerCallBack[PowerType]=CallBackFunc
    local power=UnitPower("player",PowerType)
    IROVar.UpdateCounter(counterName,power)
    if CallBackFunc then CallBackFunc(power) end
    if not IROVar.CV.UnitPowerFrame then
        SetupUnitPowerFrame()
    end
end

function IROVar.CV.UnRegister_Player_Power(PowerType)
    IROVar.CV.Power[PowerType]=nil
    IROVar.CV.PowerCallBack[PowerType]=nil
end

--function IROVar.CV.Register_Target_Aura_Duration(AuraName,counterName,filter)
    --use same filter ll make it faster!!!!!
--function IROVar.CV.UnRegister_Target_Aura_Duration(AuraName)

IROVar.CV.TargetAuraDuration={}
-- ["Filter"] = { [AuraName]="CounterName" }
IROVar.CV.TargetAuraDurationHandle={}
-- ["Filter"] = { [AuraName]=Handle C_Timer }

local function UpdateTargetAura(AuraName,filter)
    local function Reset0(a,f)
        if IROVar.CV.TargetAuraDurationHandle[f][a] then
            IROVar.CV.TargetAuraDurationHandle[f][a]:Cancel()
            IROVar.CV.TargetAuraDurationHandle[f][a]=nil
        end
        IROVar.UpdateCounter(IROVar.CV.TargetAuraDuration[f][a],0)
    end

    local exp=IROVar.Aura2.tar[filter] and IROVar.Aura2.tar[filter][AuraName]
    if not exp then
        Reset0(AuraName,filter)
    else
        local d=E2D(exp)
        local c=D2C(d)
        if d<0 then --aura has no time limit
            IROVar.UpdateCounter(IROVar.CV.TargetAuraDuration[filter][AuraName],1)
        elseif c<=0 then
            Reset0(AuraName,filter)
        else
            IROVar.UpdateCounter(IROVar.CV.TargetAuraDuration[filter][AuraName],c)
            --print(c,d,NextUpdate(d))
            do
                local a,f=AuraName,filter
                IROVar.CV.TargetAuraDurationHandle[f][a]=C_Timer.NewTimer(NextUpdate(d),function()UpdateTargetAura(a,f)end)
            end
        end
    end
end

function IROVar.CV.DumpTargetAuraDuration()
    for filter,setAura in pairs(IROVar.CV.TargetAuraDuration) do
        for k,_ in pairs(setAura) do
            if IROVar.Aura2.Changed[filter][k] then
                if IROVar.CV.TargetAuraDurationHandle[filter][k] then
                    IROVar.CV.TargetAuraDurationHandle[filter][k]:Cancel()
                    IROVar.CV.TargetAuraDurationHandle[filter][k]=nil
                end
                UpdateTargetAura(k,filter)
            end
        end
    end
end

function IROVar.CV.Register_Target_Aura_Duration(AuraName,counterName,filter)
    if (not IROVar.Aura2.TrackedAura[filter])or(not IROVar.Aura2.TrackedAura[filter][AuraName]) then
        IROVar.Aura2.RegisterTrackedAura(AuraName,filter)
    end
    IROVar.CV.TargetAuraDuration[filter]=IROVar.CV.TargetAuraDuration[filter] or {}
    IROVar.CV.TargetAuraDuration[filter][AuraName]=counterName
    IROVar.CV.TargetAuraDurationHandle[filter]=IROVar.CV.TargetAuraDurationHandle[filter] or {}
    if not IROVar.CV.TargetAuraDurationHandle[filter][AuraName] then UpdateTargetAura(AuraName,filter) end
end

function IROVar.CV.UnRegister_Target_Aura_Duration(AuraName,filter)
    IROVar.UpdateCounter(IROVar.CV.TargetAuraDuration[filter][AuraName],0)
    IROVar.CV.TargetAuraDuration[filter][AuraName]=nil
    if IROVar.CV.TargetAuraDurationHandle[filter][AuraName] then
        IROVar.CV.TargetAuraDurationHandle[filter][AuraName]:Cancel()
        IROVar.CV.TargetAuraDurationHandle[filter][AuraName]=nil
    end
end

IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.CV.DumpTargetAuraDuration",function(unit)
    if unit=="target" then IROVar.CV.DumpTargetAuraDuration()end
end)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("IROVar.CV.DumpTargetAuraDuration",IROVar.CV.DumpTargetAuraDuration)

local function TargetEnraged() -- return Enraged
    local Enraged=0
    for i=1,40 do
        local name,_,_,dispelType,_,expirationTime=UnitBuff("target",i)
        if not name then break end
        if dispelType=="" then --dispelType="" is Enraged
            if expirationTime==0 then
                Enraged=600
            else
                Enraged=expirationTime-TMW.time
            end
            break
        end
    end
    return Enraged
end
local function UpdateEnragedTimer()
    local t=TargetEnraged()-0.39
    t = math.ceil(t)
    IROVar.UpdateCounter("targetenraged",t)
end

C_Timer.NewTicker(0.45,UpdateEnragedTimer)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("UpdateEnragedTimer",UpdateEnragedTimer)
IROVar.CV.Register_Player_Aura_Not_Has("Quake","playernothasquake")