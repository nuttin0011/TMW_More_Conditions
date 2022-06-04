--Pre Process Lock Demo Rotation2 9.2.0/7
--Set Priority to 30

--var IROVar.LockDemoRotation2.SortedRotation --
--function IROVar.LockDemoRotation2.PredictSkillUse(SS,DC,SGCD)
--function IROVar.LockDemoRotation2.TimeLimitSubGCD(time) -- time to calculate , nil=GetTime()
--Rotation.GetTimeLimit()

if not IROVar.LockDemoRotation2 then
    IROVar.LockDemoRotation2={}
end

Rotation=IROVar.LockDemoRotation2
Rotation.TimeLimit=0
Rotation.DSTime=12
Rotation.DSTimeLimit=0
-- TimeLimit = 12 sec after Cast Dreadstalkers
-- TimeLimit = 8 GCD after Cast HoG
-- This Rotation Predict Calculate After Cast Dreadstalkers
Rotation.DecreaseTimeFactor=0
-- Decrease Time Factor = 1; Mean Rotation.DSTime decrease 1 sec ; HoG Decrease to min(8 GCD,12-Decrease Time Factor)
-- Decrease Time Factor = 2; Mean Rotation.DSTime decrease 2 sec ; HoG Decrease to min(8 GCD,12-Decrease Time Factor)

-- default Rotation = DS(12sec) --> HoG(cast 1 GCD, then Imp Despawn 8 GCD after cast HoG finish)

local function GetCDEnd(s)
    local start,duration = GetSpellCooldown(s)
    if start then
        return start+duration
    end
    return 0
end

function Rotation.GetTimeLimit()
    local t=Rotation.TimeLimit- GetTime()
    if t<0 then t=0 end
    return t
end

Rotation.CallDSCDEnd=GetCDEnd("Call Dreadstalkers")
Rotation.TyrantCDEnd=GetCDEnd("Summon Demonic Tyrant")
IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("CallDS",function(GCDEnd)
    if IROSpecID~=266 then return end
    local callDSCDEnd=GetCDEnd("Call Dreadstalkers")
    local tyrantCDEnd=GetCDEnd("Summon Demonic Tyrant")
    if callDSCDEnd>GCDEnd then Rotation.CallDSCDEnd=callDSCDEnd end
    if tyrantCDEnd>GCDEnd then Rotation.TyrantCDEnd=tyrantCDEnd end
end)

function Rotation.Event_COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    if (sourceGUID~=IROVar.playerGUID) or (IROSpecID~=266) then return end
    if subevent=="SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12,...)
        if spellName=="Call Dreadstalkers" then
            Rotation.TimeLimit=Rotation.TimeLimit+IROVar.CastTime1_5sec
            Rotation.DSTimeLimit=(GetTime()+Rotation.DSTime-Rotation.DecreaseTimeFactor)
        elseif spellName=="Hand of Gul'dan" then
            local tTemp=(12-Rotation.DecreaseTimeFactor)/IROVar.CastTime0_5sec --seconds to SGCD
            local HoGFactor=24 -- SubGCD
            HoGFactor=math.min(HoGFactor,tTemp)
            local CallDSCD=Rotation.CallDSCDEnd-GetTime()
            if CallDSCD<9 then
                HoGFactor=HoGFactor-3 -- Call DS < 9sec mean spare time to cast 3 SubGCD
            end
            Rotation.TimeLimit=math.min(Rotation.TimeLimit,GetTime()+(HoGFactor*IROVar.CastTime0_5sec))
        end
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("lockRotation2",IROVar.LockDemoRotation2.Event_COMBAT_LOG_EVENT_UNFILTERED)

-- Sub GCD = 1/3 GCD
-- HoG = 3 SGCD
-- Shadow Bolt = 4 SGCD
-- Summon Demonic Tyrant = 4 SGCD
-- Demonbolt = 3 SGCD

function Rotation.TimeLimitSubGCD(time) -- time to calculate , nil=GetTime()
    local currentTime=GetTime()
    if (not time) or (time<currentTime) then
        time=currentTime
    end
    local val=IROVar.ERO_Old_Val.Check("TimeLimitSubGCD",time)
    if val then return val end
    local t=Rotation.TimeLimit - time
    if t<0 then return 0 end
    val =t/IROVar.CastTime0_5sec
    IROVar.ERO_Old_Val.Update("TimeLimitSubGCD",time,val)
    return val
end

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

Rotation.FullRotation={}
--Rotation.FullRotation[SS][DC]={Spell1,Spell2...}
Rotation.SubRotation={}

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

function Rotation.SortSubRotationByImp(subrotation)
    local function CheckDuplicate(skill,subrotationtable)
        for i=1,#subrotationtable do
            if (subrotationtable[i].name==skill.name)and
            (subrotationtable[i].SS==skill.SS)and
            (subrotationtable[i].SSMax==skill.SSMax)and
            (subrotationtable[i].DC==skill.DC)and
            (subrotationtable[i].imp==skill.imp)and
            (subrotationtable[i].SGCD==skill.SGCD) then
                return true
            end
        end
        return false
    end

    local function SpellValue(t)
        if t=="Hand of Gul'dan" then return 3
        elseif t=="Demonbolt" then return 4
        elseif t=="Shadow Bolt" then return 1
        else return 0
        end
    end

    local subrotation_without_duplicate={}
    for i=1,#subrotation do
        if not CheckDuplicate(subrotation[i],subrotation_without_duplicate) then
            table.insert(subrotation_without_duplicate,subrotation[i])
        end
    end
    local sorted={}
    for i=1,#subrotation_without_duplicate do
        local max=-1
        local max_index=0
        local max_index_SGCD=100
        local max_index_name="Summon Demonic Tyrant"
        for j,v in pairs(subrotation_without_duplicate) do
            if v and
                (v.imp>max
                or (v.imp==max and v.SGCD<max_index_SGCD)
                or (v.imp==max and v.SGCD==max_index_SGCD and SpellValue(v.name)>SpellValue(max_index_name))) then
                max=v.imp
                max_index=j
                max_index_SGCD=v.SGCD
                max_index_name=v.name
            end
        end
        table.insert(sorted,subrotation_without_duplicate[max_index])
        subrotation_without_duplicate[max_index]=nil
    end
    return sorted
end

Rotation.SortedRotation=Rotation.SortSubRotationByImp(Rotation.SubRotation)
-- insert last subrotation
table.insert(Rotation.SortedRotation,{
    name="Error",
    SS=0,
    SSMax=5,
    DC=0,
    imp=0,
    SGCD=100,
})
Rotation.nSortedRotation=#Rotation.SortedRotation


function Rotation.PredictSkillUse(SS,DC,SGCD)
    -- rule 1 : SS enough , DC enough , SGCD enough
    -- rule 2 : SS not overflow , Shadowbolt: SS<=4 , Demonbolt: SS<=3
    -- rule 3 : lowest SGCD
    -- rule 4 : HoG > Demonbolt > Shadow Bolt > Summon Demonic Tyrant
    SGCD=SGCD-1
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

Rotation.SkillUse=Rotation.PredictSkillUse(IROVar.Lock.PredictSS()/10,IROVar.GetDemonicCoreStack(),IROVar.LockDemoRotation2.TimeLimitSubGCD(IUSC.NextReady)-1)
Rotation.SkillUseLastTime=GetTime()

function Rotation.GetSkill()
    local currentTime=GetTime()
    if Rotation.SkillUseLastTime==currentTime then
        return Rotation.SkillUse
    else
        Rotation.SkillUseLastTime=currentTime
        Rotation.SkillUse=Rotation.PredictSkillUse(IROVar.Lock.PredictSS()/10,IROVar.GetDemonicCoreStack(),IROVar.LockDemoRotation2.TimeLimitSubGCD(IUSC.NextReady)-1)
        return Rotation.SkillUse
    end
end

function Rotation.FixRotation()
    local z=TMW_ST:GetCounter('wanttyrant')
    if z==0 then return end

    if Rotation.TimeLimit-GetTime()>4*IROVar.CastTime0_5sec then
        z=4
    else
        z=5
    end
    print('Fix Rotation : go '..z)
    TMW_ST:UpdateCounter('wanttyrant',z)
end
local DStoSGCDPredict={
    [0]=10,[1]=16,[2]=15,[3]=21,[4]=21
}
for i=0,4 do
    DStoSGCDPredict[i]=DStoSGCDPredict[i]-1
end

Rotation.Adjust=3

function Rotation.Check_CD_Tyrant_CallDS_Befor_Start_Rotation()
    --Wilfred's Sigil of Superior Summoning Off
    -- Rotation.DSTimeLimit>5.5 mean Has CallDS up
    local currentTime=GetTime()
    local SGCDPredict=DStoSGCDPredict[IROVar.Lock.DemonicCoreStack]
    local CallDSUP=(Rotation.DSTimeLimit-currentTime)>SGCDPredict*IROVar.CastTime0_5sec
    local CallDSCDPredict=CallDSUP and 100 or SGCDPredict*IROVar.CastTime0_5sec
    local CallTyrantCDPredict=(SGCDPredict+(CallDSUP and 0 or 3))*IROVar.CastTime0_5sec
    return (CallTyrantCDPredict+currentTime+Rotation.Adjust>(Rotation.TyrantCDEnd+1)) and
    (CallDSCDPredict+currentTime>(Rotation.CallDSCDEnd+1))
end

Rotation.GFGCDEnd=GetCDEnd("Grimoire: Felguard")
Rotation.GFGUpdate=-1

function Rotation.Check_CD_Tyrant_CallDS_Befor_Start_Rotation2()
    --Wilfred's Sigil of Superior Summoning On
    -- Rotation.DSTimeLimit>5.5 mean Has CallDS up
        local currentTime=GetTime()
        local SGCDPredict=DStoSGCDPredict[IROVar.Lock.DemonicCoreStack]
        local CallDSUP=(Rotation.DSTimeLimit-currentTime)>SGCDPredict*IROVar.CastTime0_5sec
        local CallDSCDPredict=CallDSUP and 100 or SGCDPredict*IROVar.CastTime0_5sec
        local CallTyrantCDPredict=(SGCDPredict+(CallDSUP and 0 or 3))*IROVar.CastTime0_5sec
        local GFG=TMW.CNDT.Env.TalentMap["grimoire: felguard"]
        local GFGAddOn=0
        if GFG then
            if Rotation.GFGUpdate~=IROVar.SPELL_UPDATE_COOLDOWN_count then
                Rotation.GFGUpdate=IROVar.SPELL_UPDATE_COOLDOWN_count
                Rotation.GFGCDEnd=GetCDEnd("Grimoire: Felguard")
            end
            if Rotation.GFGCDEnd<(currentTime+15) then
                GFGAddOn=IROVar.HasteFactor*3.5
            end
        end
        return (CallTyrantCDPredict+currentTime+GFGAddOn+Rotation.Adjust>(Rotation.TyrantCDEnd-5)) and
        (CallDSCDPredict+currentTime>(Rotation.CallDSCDEnd+1))
    end

function Rotation.Predict_NextTime_Start_Rotation()
    local currentTime=GetTime()
    local SGCDPredict=DStoSGCDPredict[IROVar.Lock.DemonicCoreStack]
    return (Rotation.TyrantCDEnd-(currentTime+SGCDPredict*IROVar.CastTime0_5sec))+0.5
end