--Pre Process Lock Demo Rotation3 9.2.0/1
--Set Priority to 30

--function Rotation3.StartRotationTimer() -- start rotation timer
--Rotation3.DSTime -- DSTime default = 12 sec

if not IROVar.LockDemoRotation3 then
    IROVar.LockDemoRotation3={}
end

Rotation3=IROVar.LockDemoRotation3

Rotation3.TimeLimit=math.huge
Rotation3.DSTime=12
Rotation3.DecreaseTimeFactor=0
--DecreaseTimeFactor = 1 , mean DSTime = 12-1 ; HoGTime = (24-2) SGCD
--DecreaseTimeFactor = 2 , mean DSTime = 12-2 ; HoGTime = (24-4) SGCD
Rotation3.DSTimeExpire=0
Rotation3.DSUp=false
Rotation3.StartRotation=false -- Set to true to start rotation , Set to False after Summon Demonic Tyrant finished
-- TimeLimit = 12 sec after Cast Dreadstalkers
-- TimeLimit = 8 GCD after Cast HoG
-- This Rotation Predict Calculate After Cast Dreadstalkers

-- default Rotation = DS(12sec) --> HoG(cast 1 GCD, then Imp Despawn 8 GCD after cast HoG finish)

Rotation3.TimeLimitList={}
Rotation3.ClearTimeLimitListHandle=nil
-- low value first
--[1]= GetTime+8*GCD if HoG
--[2]= GetTime+12sec if DS
--if < GetTime Set To nil
function Rotation3.AddTimeLimit(t)
    local index=#Rotation3.TimeLimitList+1
    for i=1,#Rotation3.TimeLimitList do
        if Rotation3.TimeLimitList[i]<t then
            index=i
            break
        end
    end
    table.insert(Rotation3.TimeLimitList,index,t)
end
function Rotation3.TimeLimitList_pop_min(n) -- n is order of time limit, lower first
    local currentTime=GetTime()
    for i=#Rotation3.TimeLimitList,1,-1 do
        if Rotation3.TimeLimitList[i]<currentTime then
            table.remove(Rotation3.TimeLimitList,i)
        else
            break
        end
    end
    n=#Rotation3.TimeLimitList-n+1
    return Rotation3.TimeLimitList[n]
end

function Rotation3.ClearTimeLimit_WhenOutCombat()
    --Clear when OutCombat>20 sec
    Rotation3.ClearTimeLimitListHandle=C_Timer.NewTimer(20,function()
        Rotation3.TimeLimitList={}
    end)
end
function Rotation3.Stop_ClearTimeLimitListHandle_WhenInCombat()
    if Rotation3.ClearTimeLimitListHandle then
        Rotation3.ClearTimeLimitListHandle:Cancel()
        Rotation3.ClearTimeLimitListHandle=nil
    end
end
IROVar.RegisterIncombatCallBackRun("Stop_ClearTimeLimitListHandle_WhenInCombat",Rotation3.Stop_ClearTimeLimitListHandle_WhenInCombat)
IROVar.RegisterOutcombatCallBackRun("ClearTimeLimit_WhenOutCombat",Rotation3.ClearTimeLimit_WhenOutCombat)

function Rotation3.Event_COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    if sourceGUID~=IROVar.playerGUID then return end
    if subevent=="SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12,...)
        if Rotation3.StartRotation then
            if spellName=="Call Dreadstalkers" then
                Rotation3.DSUp=true
                local t=Rotation3.DSTime-Rotation3.DecreaseTimeFactor
                Rotation3.AddTimeLimit(t)
            elseif spellName=="Hand of Gul'dan" then
                local t=(24-(2*Rotation3.DecreaseTimeFactor))*IROVar.CastTime0_5sec
                Rotation3.AddTimeLimit(t)
            elseif spellName=="Summon Demonic Tyrant" then
                Rotation3.StopRotationTimer()
            end
        end
        --[[if spellName=="Call Dreadstalkers" then
            Rotation3.DSTimeExpire=GetTime()+Rotation3.DSTime
        end
        if spellName=="Call Dreadstalkers" and Rotation3.StartRotation then
            Rotation3.DSUp=true
            C_Timer.After(12-IROVar.CastTime2sec-0.3,function()Rotation3.DSUp=false end)
        end
        if spellName=="Call Dreadstalkers" and Rotation3.StartRotation then
            Rotation3.TimeLimit=math.min(Rotation3.TimeLimit,GetTime()+Rotation3.DSTime)
        elseif spellName=="Hand of Gul'dan" and Rotation3.StartRotation then
            Rotation3.TimeLimit=math.min(Rotation3.TimeLimit,GetTime()+(8*IROVar.CastTime1_5sec))
        elseif spellName=="Summon Demonic Tyrant" then
            Rotation3.StopRotationTimer()
        end]]
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("lockRotation3",IROVar.LockDemoRotation3.Event_COMBAT_LOG_EVENT_UNFILTERED)

function Rotation3.StartRotationTimer()
    Rotation3.StartRotation=true
    Rotation3.TimeLimit=GetTime()+Rotation3.DSTime+3
end
function Rotation3.StopRotationTimer()
    Rotation3.StartRotation=false
    Rotation3.TimeLimit=math.huge
end
IROVar.RegisterOutcombatCallBackRun("LockDemoRotation3",Rotation3.StopRotationTimer)


Rotation3.SpellInfo1 = { -- assume has Demonic Calling = Call Dreadstalkers is Instance and use 0 SS
    ["HoG"] = {
        name="Hand of Gul'dan",
        casttime=3, -- sub GCD ; 3 sub GCD = 1 GCD
        SSMin=1,
        SSMax=5,
        SSGen=-3,
        imp=3,
        DC=0,
    },
    ["DB"] = {
        name="Demonbolt",
        casttime=3, -- sub GCD ; 3 sub GCD = 1 GCD
        SSMin=0,
        SSMax=3,
        SSGen=2,
        imp=0,
        DC=-1,
    },
    ["CallDS"] = {
        name="Call Dreadstalkers",
        casttime=3, -- sub GCD ; 12 sub GCD = 1 GCD
        SSMin=0,
        SSMax=5,
        SSGen=0,
        imp=0,
        DC=0,
    },
    ["SB"] = {
        name="Shadow Bolt",
        casttime=4, -- sub GCD ; 12 sub GCD = 1 GCD
        SSMin=0,
        SSMax=4,
        SSGen=1,
        imp=0,
        DC=0,
    },
    ["Tyrant"] = {
        name="Summon Demonic Tyrant",
        casttime=4, -- sub GCD ; 12 sub GCD = 1 GCD
        SSMin=0,
        SSMax=5,
        SSGen=0,
        imp=0,
        DC=0,
    },
}

Rotation3.MainRotation1={ -- Main Rotation -- assume has Demonic Calling = Call Dreadstalkers is Instance and use 0 SS
    [1]={
        StartSS=5,
        StartDC=3,
        CallDreadstalkersCD=-1, --used
        rotation={"HoG","DB","HoG","DB","HoG","DB","HoG","Tyrant"},
    },
    [2]={
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=-1, --used
        rotation={"HoG","DB","HoG","DB","HoG","Tyrant"},
    },
    [3]={
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=-1, --used
        rotation={"HoG","DB","HoG","SB","HoG","Tyrant"},
    },
    [4]={
        StartSS=5,
        StartDC=0,
        CallDreadstalkersCD=-1, --used
        rotation={"HoG","SB","HoG","Tyrant"},
    },
    [5]={
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","HoG","DB","HoG","CallDS","Tyrant"},
    },
    [6]={
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","HoG","DB","CallDS","HoG","Tyrant"},
    },
    [7]={
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","HoG","CallDS","DB","HoG","Tyrant"},
    },
    [8]={
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","CallDS","HoG","DB","HoG","Tyrant"},
    },
    [9]={
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","CallDS","DB","HoG","DB","HoG","Tyrant"},
    },
    [10]={
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","CallDS","DB","HoG","SB","HoG","Tyrant"},
    },
    [11]={
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","CallDS","HoG","SB","HoG","Tyrant"},
    },
    [12]={
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","SB","CallDS","HoG","DB","HoG","Tyrant"},
    },
    [13]={ --HDHCSH
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","HoG","CallDS","SB","HoG","Tyrant"},
    },
    [14]={ --HSHCDH
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","SB","HoG","CallDS","DB","HoG","Tyrant"},
    },
    [15]={ --HDHSCH
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","HoG","SB","CallDS","HoG","Tyrant"},
    },
    [16]={ --HDHSHC
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","DB","HoG","SB","HoG","CallDS","Tyrant"},
    },
    [17]={ --HCSH
        StartSS=5,
        StartDC=0,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","CallDS","SB","HoG","Tyrant"},
    },
    [18]={ --HSCH
        StartSS=5,
        StartDC=0,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","SB","CallDS","HoG","Tyrant"},
    },
    [19]={ --HSHC
        StartSS=5,
        StartDC=0,
        CallDreadstalkersCD=0, --not used
        rotation={"HoG","SB","HoG","CallDS","Tyrant"},
    },
    [20]={ -- Rotation 1-4 and add "CallDS" at 1st skill
        StartSS=5,
        StartDC=3,
        CallDreadstalkersCD=0,
        rotation={"CallDS","HoG","DB","HoG","DB","HoG","DB","HoG","Tyrant"},
    },
    [21]={ -- Rotation 1-4 and add "CallDS" at 1st skill
        StartSS=5,
        StartDC=2,
        CallDreadstalkersCD=0,
        rotation={"CallDS","HoG","DB","HoG","DB","HoG","Tyrant"},
    },
    [22]={ -- Rotation 1-4 and add "CallDS" at 1st skill
        StartSS=5,
        StartDC=1,
        CallDreadstalkersCD=0,
        rotation={"CallDS","HoG","DB","HoG","SB","HoG","Tyrant"},
    },
    [23]={ -- Rotation 1-4 and add "CallDS" at 1st skill
        StartSS=5,
        StartDC=0,
        CallDreadstalkersCD=0,
        rotation={"CallDS","HoG","SB","HoG","Tyrant"},
    },
}

Rotation3.SubRotation1={}
--[[
    [1]={
        name="Hand of Gul'dan",
        SS=2,
        SSMax=5,
        DC=0,
        imp=2,
        SGCD=7,
        CallDSCD=-1,
        TyrantCD=8,
    },...
]]

function Rotation3.Generate_SubRotation1_From_MainRotation1(StartSS,StartDC,CallDreadstalkersCD,rotation)
    local SSByOrder={}
    SSByOrder[1]=StartSS
    for i=1,#rotation do
        if rotation[i]=="HoG" then
            if SSByOrder[i]>3 then
                SSByOrder[i+1]=SSByOrder[i]-3
            else
                SSByOrder[i+1]=0
            end
        else
            SSByOrder[i+1]=SSByOrder[i]+Rotation3.SpellInfo1[rotation[i]].SSGen
        end
    end
    local CallDSIndex=-1
    for i=1,#rotation do
        if rotation[i]=="CallDS" then
            CallDSIndex=i
            break
        end
    end
    for i=1,#rotation do
        local spell=rotation[i]
        local name=Rotation3.SpellInfo1[spell].name
        local SS=SSByOrder[i]
        local SSMax=Rotation3.SpellInfo1[spell].SSMax
        local DC=StartDC
        for iDC=1,i-1 do
            DC=DC+Rotation3.SpellInfo1[rotation[iDC]].DC
        end

        local imp=0
        for iimp=i,#rotation do
            if rotation[iimp]=="HoG" then
                imp=imp+(SSByOrder[iimp]>3 and 3 or SSByOrder[iimp])
            else
                imp=imp+Rotation3.SpellInfo1[rotation[iimp]].imp
            end
        end

        local SGCD=0
        for iSGCD=i,#rotation do
            SGCD=SGCD+Rotation3.SpellInfo1[rotation[iSGCD]].casttime
        end
        local CallDSCD=CallDreadstalkersCD
        if CallDSCD~=-1 then
            if i>CallDSIndex then
                CallDSCD=-1
            else
                CallDSCD=0
                for iCallDSCD=i,CallDSIndex-1 do
                    CallDSCD=CallDSCD+Rotation3.SpellInfo1[rotation[iCallDSCD]].casttime
                end
            end
        end
        local TyrantCD=0
        for iTyrantCD=i,#rotation-1 do
            TyrantCD=TyrantCD+Rotation3.SpellInfo1[rotation[iTyrantCD]].casttime
        end

        table.insert(Rotation3.SubRotation1,{
            name=name,
            SS=SS,
            SSMax=SSMax,
            DC=DC,
            imp=imp,
            SGCD=SGCD,
            CallDSCD=CallDSCD,
            TyrantCD=TyrantCD,
        })

    end
end

for i=1,#Rotation3.MainRotation1 do
    Rotation3.Generate_SubRotation1_From_MainRotation1(
        Rotation3.MainRotation1[i].StartSS,
        Rotation3.MainRotation1[i].StartDC,
        Rotation3.MainRotation1[i].CallDreadstalkersCD,
        Rotation3.MainRotation1[i].rotation
    )
end

Rotation3.SubRotation1_WithOut_Duplicate={}

function Rotation3.Generate_SubRotation1_WithOut_Duplicate()
    for i=1,#Rotation3.SubRotation1 do
        local name=Rotation3.SubRotation1[i].name
        local SS=Rotation3.SubRotation1[i].SS
        local SSMax=Rotation3.SubRotation1[i].SSMax
        local DC=Rotation3.SubRotation1[i].DC
        local imp=Rotation3.SubRotation1[i].imp
        local SGCD=Rotation3.SubRotation1[i].SGCD
        local CallDSCD=Rotation3.SubRotation1[i].CallDSCD
        local TyrantCD=Rotation3.SubRotation1[i].TyrantCD
        local isDuplicate=false
        for j=1,#Rotation3.SubRotation1_WithOut_Duplicate do
            if Rotation3.SubRotation1_WithOut_Duplicate[j].name==name
            and Rotation3.SubRotation1_WithOut_Duplicate[j].SS==SS
            and Rotation3.SubRotation1_WithOut_Duplicate[j].SSMax==SSMax
            and Rotation3.SubRotation1_WithOut_Duplicate[j].DC==DC
            and Rotation3.SubRotation1_WithOut_Duplicate[j].imp==imp
            and Rotation3.SubRotation1_WithOut_Duplicate[j].SGCD==SGCD
            and Rotation3.SubRotation1_WithOut_Duplicate[j].CallDSCD==CallDSCD
            and Rotation3.SubRotation1_WithOut_Duplicate[j].TyrantCD==TyrantCD
            then
                isDuplicate=true
                break
            end
        end
        if not isDuplicate then
            table.insert(Rotation3.SubRotation1_WithOut_Duplicate,{
                name=name,
                SS=SS,
                SSMax=SSMax,
                DC=DC,
                imp=imp,
                SGCD=SGCD,
                CallDSCD=CallDSCD,
                TyrantCD=TyrantCD,
            })
        end
    end
end

Rotation3.Generate_SubRotation1_WithOut_Duplicate()

function Rotation3.Sort_SubRotation1_By_imp()
    --rule 1: selected imp is the biggest
    --rule 2: selected CallDSCD is the smallest
    --rule 3: selected SGCD is the smallest
    --rule 4: selected TyrantCD is the smallest
    --rule 5: selected name ; "CallDS" > "DB" > "HoG" > "SB" > else > "Tyrant"
    local function SpellValue(s)
        if s=="CallDS" then
            return 5
        elseif s=="DB" then
            return 4
        elseif s=="HoG" then
            return 3
        elseif s=="SB" then
            return 2
        elseif s=="Tyrant" then
            return 0
        else
            return 1
        end
    end
    local function Compare(a,b)
        if a.imp==b.imp then
            if a.CallDSCD==b.CallDSCD then
                if a.SGCD==b.SGCD then
                    if a.TyrantCD==b.TyrantCD then
                        return SpellValue(a.name)>SpellValue(b.name)
                    else
                        return a.TyrantCD<b.TyrantCD
                    end
                else
                    return a.SGCD<b.SGCD
                end
            else
                return (a.CallDSCD==-1 and 100 or a.CallDSCD)<(b.CallDSCD==-1 and 100 or b.CallDSCD)
            end
        else
            return a.imp>b.imp
        end
    end
    table.sort(Rotation3.SubRotation1_WithOut_Duplicate,Compare)
end

Rotation3.Sort_SubRotation1_By_imp()

function Rotation3.PredictSkillUse(SubRotation,SS,DC,SGCD,CallDSCD,TyrantCD)
    -- rule 1 : SS enough , DC enough , SGCD enough , CallDSCD lower Skill.CallDSCD , TyrantCD lower Skill.TyrantCD
    -- rule 2 : SS not overflow , Shadowbolt: SS<=4 , Demonbolt: SS<=3
    -- rule 3 : Hiest imp
    -- rule 4 : 1 st Hiest imp is ok because we sorted table,
    local indexSelected=nil
    for i=1,#SubRotation do
        if SubRotation[i].SS<=SS
        and SubRotation[i].DC<=DC
        and SubRotation[i].SGCD<=SGCD
        and SubRotation[i].TyrantCD>=TyrantCD then
            if CallDSCD==-1 then
                if SubRotation[i].CallDSCD==-1 then
                    indexSelected=i
                    break
                end
            elseif SubRotation[i].CallDSCD>=CallDSCD then
                indexSelected=i
                break
            end
        end
    end
    return indexSelected and SubRotation[indexSelected].name or "Error"
end

function Rotation3.Sec_to_SGCD(t,round_Up)
    --SGCD = t / IROVar.CastTime0_5sec
    if t<=0 then return 0 end
    local SGCD=t/IROVar.CastTime0_5sec
    if round_Up then
        return math.ceil(SGCD)
    else
        return math.floor(SGCD)
    end
end

--[[function Rotation3.TimeLimitSubGCD(time) -- time to calculate , nil=GetTime()
    local currentTime=GetTime()
    if (not time) or (time<currentTime) then
        time=currentTime
    end
    local val=IROVar.ERO_Old_Val.Check("TimeLimitSubGCD",time)
    if val then return val end
    local t=Rotation3.TimeLimit - time
    if t<0 then return 0 end
    val =Rotation3.Sec_to_SGCD(t)
    IROVar.ERO_Old_Val.Update("TimeLimitSubGCD",time,val)
    return val
end]]

--function IROVar.GetDSCDEnd()

--function IROVar.GetTyrantCDEnd()
--Rotation3.GetSkill(IUSC.NextReady)


function Rotation3.GetSkill(t) -- t=nil or GetTime()
    t=t or GetTime()

    local DSSGCD=Rotation3.DSUp and -1 or Rotation3.Sec_to_SGCD(IROVar.GetDSCDEnd()-t,true)--must round up
    local TyrantSGCD=Rotation3.Sec_to_SGCD(IROVar.GetTyrantCDEnd()-t,true)--must round up
    local SS=IROVar.Lock.PredictSS()/10
    local DCStack=IROVar.GetDemonicCoreStack()
    local skill
    local TimeLimit
    local TimeLimitSGCD
    local TLimitIndex=1
    repeat
        TimeLimit=Rotation3.TimeLimitList_pop_min(TLimitIndex)
        TimeLimitSGCD=TimeLimit and Rotation3.Sec_to_SGCD(TimeLimit-t) or 100--must round down
        skill=Rotation3.PredictSkillUse(
        Rotation3.SubRotation1_WithOut_Duplicate
        ,SS
        ,DCStack
        ,TimeLimitSGCD
        ,DSSGCD
        ,TyrantSGCD)
        if skill=="Error" and TLimitIndex<#Rotation3.TimeLimitList then
            TLimitIndex=TLimitIndex+1
        end
    until skill~="Error" or TLimitIndex>=#Rotation3.TimeLimitList

    return skill
end