--Many Function Lock Demo Tyrant 10.1.5/1
--- Hekili Version
-- Set Priority to 8

if not IROVar.LockDemoRotation3 then
    IROVar.LockDemoRotation3={}
end

local Rotation=IROVar.LockDemoRotation3
local Hekili=Hekili

local COUNTERS=TMW.COUNTERS

Rotation.TimeLimit=0 -- Reset At Icon Go Stage 4 in TMW
Rotation.DSTime=12
Rotation.DSTimeLimit=0
Rotation.HoGCount=0

-- TimeLimit = 12 sec after Cast Dreadstalkers
-- TimeLimit = 8 GCD after Cast HoG
-- This Rotation Predict Calculate After Cast Dreadstalkers
Rotation.DecreaseTimeFactor=0
-- Decrease Time Factor = 1; Mean Rotation.DSTime decrease 1 sec ; HoG Decrease to min(8 GCD,12-Decrease Time Factor)
-- Decrease Time Factor = 2; Mean Rotation.DSTime decrease 2 sec ; HoG Decrease to min(8 GCD,12-Decrease Time Factor)

-- default Rotation = DS(12sec) --> HoG(cast 1 GCD, then Imp Despawn 8 GCD after cast HoG finish)


Rotation.SpellInfo={
    ["Hand of Gul'dan"]={
        DC=0,
        SS=-3,
        CastTime=3,
    },
    ["Shadow Bolt"]={
        DC=0,
        SS=1,
        CastTime=4,
    },
    ["Demonbolt"]={
        DC=-1,
        SS=2,
        CastTime=3,
    },
    ["Summon Demonic Tyrant"]={
        DC=0,
        SS=5,
        CastTime=4,
    },
}
function Rotation.ResourceAfterUseSpell(SS,DC,SGCD,Spell)
    local imp=0
    if Spell=="Hand of Gul'dan" then
        imp=imp+(SS>=3 and 3 or SS)
    end
    SS=SS+Rotation.SpellInfo[Spell].SS
    DC=DC+Rotation.SpellInfo[Spell].DC
    SGCD=SGCD-Rotation.SpellInfo[Spell].CastTime

    return SS,DC,SGCD,imp
end

--[[
Rotation.FullRotation={}
--Rotation.FullRotation[SS][DC]={Spell1,Spell2...}
Rotation.FullRotation["5_3"]={
    "Hand of Gul'dan","Demonbolt",
    "Hand of Gul'dan","Demonbolt",
    "Hand of Gul'dan","Demonbolt",
    "Hand of Gul'dan","Summon Demonic Tyrant",
}
Rotation.FullRotation["5_2"]={
    "Hand of Gul'dan","Demonbolt",
    "Hand of Gul'dan","Demonbolt",
    "Hand of Gul'dan","Summon Demonic Tyrant",
}
Rotation.FullRotation["5_1"]={
    "Hand of Gul'dan","Demonbolt",
    "Hand of Gul'dan","Shadow Bolt",
    "Hand of Gul'dan","Summon Demonic Tyrant",
}
Rotation.FullRotation["5_0"]={
    "Hand of Gul'dan","Shadow Bolt",
    "Hand of Gul'dan","Summon Demonic Tyrant",
}
]]
Rotation.SubRotation={}
-----------Rotation[5_3]
Rotation.SubRotation[1]={
    name="Hand of Gul'dan",
    SS=5,
    SSMax=5,
    DC=3,
    imp=11,
    SGCD=25,
}
Rotation.SubRotation[2]={
    name="Demonbolt",
    SS=2,
    SSMax=3, -- Demonbolt set SSmax=3
    DC=3,
    imp=8,
    SGCD=22,
}
Rotation.SubRotation[3]={
    name="Hand of Gul'dan",
    SS=4,
    SSMax=5,
    DC=2,
    imp=8,
    SGCD=19,
}
Rotation.SubRotation[4]={
    name="Demonbolt",
    SS=1,
    SSMax=3,
    DC=2,
    imp=5,
    SGCD=16,
}
Rotation.SubRotation[5]={
    name="Hand of Gul'dan",
    SS=3,
    SSMax=5,
    DC=1,
    imp=5,
    SGCD=13,
}
Rotation.SubRotation[6]={
    name="Demonbolt",
    SS=0,
    SSMax=3,
    DC=1,
    imp=2,
    SGCD=10,
}
Rotation.SubRotation[7]={
    name="Hand of Gul'dan",
    SS=2,
    SSMax=5,
    DC=0,
    imp=2,
    SGCD=7,
}
Rotation.SubRotation[8]={
    name="Summon Demonic Tyrant",
    SS=0,
    SSMax=5,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_2]
Rotation.SubRotation[9]={
    name="Hand of Gul'dan",
    SS=5,
    SSMax=5,
    DC=2,
    imp=9,
    SGCD=19,
}
Rotation.SubRotation[10]={
    name="Demonbolt",
    SS=2,
    SSMax=3,
    DC=2,
    imp=6,
    SGCD=16,
}
Rotation.SubRotation[11]={
    name="Hand of Gul'dan",
    SS=4,
    SSMax=5,
    DC=1,
    imp=6,
    SGCD=13,
}
Rotation.SubRotation[12]={
    name="Demonbolt",
    SS=1,
    SSMax=3,
    DC=1,
    imp=3,
    SGCD=10,
}
Rotation.SubRotation[13]={
    name="Hand of Gul'dan",
    SS=3,
    SSMax=5,
    DC=0,
    imp=3,
    SGCD=7,
}
Rotation.SubRotation[14]={
    name="Summon Demonic Tyrant",
    SS=0,
    SSMax=5,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_1]
Rotation.SubRotation[15]={
    name="Hand of Gul'dan",
    SS=5,
    SSMax=5,
    DC=1,
    imp=8,
    SGCD=20,
}
Rotation.SubRotation[16]={
    name="Demonbolt",
    SS=2,
    SSMax=3,
    DC=1,
    imp=5,
    SGCD=17,
}
Rotation.SubRotation[17]={
    name="Hand of Gul'dan",
    SS=4,
    SSMax=5,
    DC=0,
    imp=5,
    SGCD=14,
}
Rotation.SubRotation[18]={
    name="Shadow Bolt",
    SS=1,
    SSMax=4,
    DC=0,
    imp=2,
    SGCD=11,
}
Rotation.SubRotation[19]={
    name="Hand of Gul'dan",
    SS=2,
    SSMax=5,
    DC=0,
    imp=2,
    SGCD=7,
}
Rotation.SubRotation[20]={
    name="Summon Demonic Tyrant",
    SS=0,
    SSMax=5,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_0]
Rotation.SubRotation[21]={
    name="Hand of Gul'dan",
    SS=5,
    SSMax=5,
    DC=0,
    imp=6,
    SGCD=14,
}
Rotation.SubRotation[22]={
    name="Shadow Bolt",
    SS=2,
    SSMax=4,
    DC=0,
    imp=3,
    SGCD=11,
}
Rotation.SubRotation[23]={
    name="Hand of Gul'dan",
    SS=3,
    SSMax=5,
    DC=0,
    imp=3,
    SGCD=7,
}
Rotation.SubRotation[24]={
    name="Summon Demonic Tyrant",
    SS=0,
    SSMax=5,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_0] Extra proc
Rotation.SubRotation[25]={
    name="Hand of Gul'dan",
    SS=3,
    SSMax=5,
    DC=1,
    imp=5,
    SGCD=13,
}
Rotation.SubRotation[26]={
    name="Demonbolt",
    SS=0,
    SSMax=3,
    DC=1,
    imp=2,
    SGCD=10,
}
Rotation.SubRotation[27]={
    name="Hand of Gul'dan",
    SS=2,
    SSMax=5,
    DC=0,
    imp=2,
    SGCD=7,
}
Rotation.SubRotation[28]={
    name="Summon Demonic Tyrant",
    SS=0,
    SSMax=5,
    DC=0,
    imp=0,
    SGCD=4,
}

-- rule 1 : SS enough , DC enough , SGCD enough
-- rule 2 : SS not overflow , Shadowbolt: SS<=4 , Demonbolt: SS<=3
-- rule 3 : lowest SGCD
-- rule 4 : HoG > Demonbolt > Shadow Bolt > Summon Demonic Tyrant
function Rotation.SortSubRotationByImp2(rotation)
    local function SpellValue(t)
        if t=="Hand of Gul'dan" then return 3
        elseif t=="Demonbolt" then return 4
        elseif t=="Shadow Bolt" then return 1
        else return 0
        end
    end
    local function comp(a,b)
        return a.imp>b.imp or
        a.imp==b.imp and a.SGCD<b.SGCD or
        a.imp==b.imp and a.SGCD==b.SGCD and SpellValue(a.name)>SpellValue(b.name)
    end
    table.sort(rotation,comp)
    local function equal(a,b)
        return a.name==b.name and a.SS==b.SS and a.SSMax==b.SSMax and
        a.DC==b.DC and a.imp==b.imp and a.SGCD==b.SGCD
    end
    local rotation_without_duplicate={}
    table.insert(rotation_without_duplicate,rotation[1])
    for i=2,#rotation do
        if not equal(rotation[i],rotation[i-1]) then
            table.insert(rotation_without_duplicate,rotation[i])
        end
    end
    return rotation_without_duplicate
end

Rotation.SortedRotation=Rotation.SortSubRotationByImp2(Rotation.SubRotation)
Rotation.nSortedRotation=#Rotation.SortedRotation

function Rotation.toSGCD(t)
    if t<=0 then return 0 end
    local SGCD1=Hekili.State.gcd.execute/3
    return math.floor(t/SGCD1)
end

function Rotation.PredictSkill(SS,DC,SGCD)
    if SGCD<0 then SGCD=0 end
    local selected=Rotation.nSortedRotation
    local SGCDselected=100
    local impSelected=0
    for i=1,Rotation.nSortedRotation do
        if impSelected>Rotation.SortedRotation[i].imp then
            break
        end
        if Rotation.SortedRotation[i].SS<=SS
        and Rotation.SortedRotation[i].DC<=DC
        and Rotation.SortedRotation[i].SGCD<=SGCD
        and Rotation.SortedRotation[i].SSMax>=SS then
            if SGCDselected>Rotation.SortedRotation[i].SGCD then
                selected=i
                SGCDselected=Rotation.SortedRotation[i].SGCD
                impSelected=Rotation.SortedRotation[i].imp
            end
        end
    end
    return Rotation.SortedRotation[selected].name
end

Hekili.State.toSGCD=Rotation.toSGCD
Hekili.State.PredictSkill=Rotation.PredictSkill


--- Warlock Demo Function
--- Tyrant Counter COUNTER["starttyrant"]== 0 not in rotation , 1 in rotation
--- if Tyrant Counter; hogtimer = start timer at 1 st HOG castTime finish,
--- Tyrant Must Cast Finish In 8 GCD after HogTimer
--- gcd = Hekili.State.gcd.execute

local EroTyrant={
    ["hogtimer"]=nil,
    ["calldstimer"]=nil,
    ["tyranttimeup"]=nil
}
local function CheckTyrantHoGTimer()
    if Hekili.State.player.lastgcd=="call_dreadstalkers" then
        EroTyrant.calldstimer=Hekili.State.player.lastgcdtime
    end
    if COUNTERS["starttyrant"]==1 then
        if not EroTyrant.hogtimer and Hekili.State.player.lastgcd=="hand_of_guldan" then
            EroTyrant.hogtimer=Hekili.State.player.lastgcdtime
        end
    end
    if not EroTyrant.tyranttimeup and EroTyrant.hogtimer and EroTyrant.calldstimer then
        local now = Hekili.State.now
        local gcd8 = Hekili.State.gcd.execute*8
        local dsremains = EroTyrant.calldstimer + 12 - now
        if dsremains < 6 then dsremains = 999 end -- if < 6 sec then dont use
        local hogramains = EroTyrant.hogtimer + gcd8 - now
        EroTyrant.tyranttimeup = math.min(dsremains,hogramains) + now - 0.3
    end
    return true
end

local function ResetTyrantHoGTimer()
    if COUNTERS["starttyrant"]==1 and Hekili.State.player.lastgcd=="summon_demonic_tyrant" then
        EroTyrant.hogtimer=nil
        EroTyrant.tyranttimeup=nil
        COUNTERS["starttyrant"]=0
    end
    return true
end
---
Hekili.State.CheckTyrantHoGTimer=CheckTyrantHoGTimer
Hekili.State.ResetTyrantHoGTimer=ResetTyrantHoGTimer

local TyrantTimeLimit=nil
local CheckedTime=0

if Hekili.Class.specs[266] then
    local HoGHandler=Hekili.Class.specs[266].abilities.hand_of_guldan.handler
    local function NewHoGHandler()
        if TyrantTimeLimit then
            if not Hekili.State.buff.dreadstalkers.up then
                TyrantTimeLimit=Hekili.State.query_time+15
            elseif Hekili.State.query_time < CheckedTime then
                TyrantTimeLimit=Hekili.State.query_time+15
            end
        end
        if not TyrantTimeLimit then
            local HoGTimerEnd = Hekili.State.query_time + (Hekili.State.gcd.execute*8)
            local CallDSExpire= Hekili.State.buff.dreadstalkers.expires
            TyrantTimeLimit=math.min(HoGTimerEnd,CallDSExpire)
        end
        HoGHandler()
    end
    Hekili.Class.specs[266].abilities.hand_of_guldan.handler=NewHoGHandler
end

local TyrantState={}
local TyrantState_v = {} -- [1] = time to state 1 , [2] = time to state 2 .....
local TimeQueryMark = Hekili.State.query_time -- if decrease wipe TyrantState_v
--[[
state 1 == fill soul shard 5 , use less demonic core,
    --> SS == 5 CD G:F VF On
state 2 == use G:Felguard , Vilefiend , Call DSs , fill soul shard 5
    --> SS == 5 G:F VF Off Call DSs +-
state 3 == use felguard rotation
    --> Use Tyrant --> go state 0
state 4 >= state 0
]]

local function GetRealTyrantState()
    local t=#TyrantState
    IROVar.UpdateCounter("tyrantstate",t)
    return t
end
Hekili.State.GetRealTyrantState=GetRealTyrantState

local function WipeTyrantState()
    wipe(TyrantState_v)
    wipe(TyrantState)
    GetRealTyrantState()
end
Hekili.State.WipeTyrantState=WipeTyrantState

local function AddTyrantState(t,visual)
    TimeQueryMark = Hekili.State.query_time
    t=t or Hekili.State.query_time
    if visual then
        table.insert(TyrantState_v,t)
    else
        table.insert(TyrantState,t)
        if GetRealTyrantState() ==4 then
            WipeTyrantState()
        end
    end
end
Hekili.State.AddTyrantState=AddTyrantState

local function GetTyrantState(t)
    --[[if Hekili.State.query_time<TimeQueryMark then
        wipe(TyrantState_v)
    end]]
    if Hekili.State.index == 1 then
        wipe(TyrantState_v)
    end
    t=t or Hekili.State.query_time
    if not TyrantState[1] then return 0 end
    local state=#TyrantState
    for i=1,#TyrantState_v do
        if TyrantState_v[i]<=t then
            state=state+1
        end
    end
    if state==4 then return 0 end
    if state>4 then
        Hekili:Notify("TyrantState ERROR Reset to 0")
        Hekili:Print("TyrantState ERROR Reset to 0")
        wipe(TyrantState)
        wipe(TyrantState_v)
        GetRealTyrantState()
        return 0
    end
    return state
end
Hekili.State.GetTyrantState=GetTyrantState

local function sCDUp(s) -- use only VF/G:Felguard
    return Hekili.State.talent[s].rank==1 and Hekili.State.cooldown[s].up
end

local function CanGoState2(t)
    t=t or Hekili.State.query_time
    local TyState=GetTyrantState(t)
    if TyState ~= 1 then return false end
    local VFr=sCDUp("summon_vilefiend") or Hekili.State.talent.summon_vilefiend.rank==0
    local G_FGr=sCDUp("grimoire_felguard") or Hekili.State.talent.grimoire_felguard.rank==0
    local SSr=Hekili.State.soul_shard==5
    return VFr and G_FGr and SSr
end
Hekili.State.CanGoState2=CanGoState2

local function CanGoLastStep(t)
    t=t or Hekili.State.query_time
    local TyState=GetTyrantState(t)
    if TyState ~= 2 then return false end
    local VFGo=not sCDUp("summon_vilefiend")
    local G_FGGo=not sCDUp("grimoire_felguard")
    local SSGo=Hekili.State.soul_shard==5
    return VFGo and G_FGGo and SSGo
end
Hekili.State.CanGoLastStep=CanGoLastStep

local function GoNextState(visual,t)
    if visual then
        t=t or Hekili.State.query_time
        AddTyrantState(t,true)
    else
        t=t or Hekili.State.now
        AddTyrantState(Hekili.State.now,false)
    end
end
Hekili.State.GoNextState=GoNextState

if Hekili.Class.specs[266] then
    local function AddCanGoTyrant(skill)
        local h = Hekili.Class.specs[266].abilities[skill].handler
        local function ff()
            h()
            if Hekili.State.index==2 then wipe(TyrantState_v) end
            if CanGoState2() then GoNextState(true) end
            if CanGoLastStep() then GoNextState(true) end
        end
        Hekili.Class.specs[266].abilities[skill].handler=ff
    end
    AddCanGoTyrant("shadow_bolt")
    AddCanGoTyrant("demonbolt")

    local hh =  Hekili.Class.specs[266].abilities.summon_demonic_tyrant.handler
    local function fff()
        hh()
        if GetTyrantState()==3 then GoNextState(true) end
    end
    Hekili.Class.specs[266].abilities.summon_demonic_tyrant.handler=fff
end

local function PrintQueryTime()
    print(Hekili.State.now,Hekili.State.query_time)
    return true
end
Hekili.State.PrintQueryTime=PrintQueryTime

table.insert(Hekili.Class.specs[266].hooks.COMBAT_LOG_EVENT_UNFILTERED,
function( _, subtype, _, source, _, _, _, destGUID, _, _, _, spellID, spellName )

end)