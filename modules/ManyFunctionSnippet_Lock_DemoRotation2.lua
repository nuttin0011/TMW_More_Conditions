--Pre Process Lock Demo Rotation2 9.2.0/3
--Set Priority to 30

--var IROVar.LockDemoRotation2.SortedRotation --
--function IROVar.LockDemoRotation2.PredictSkillUse(SS,DC,SGCD)
--function IROVar.LockDemoRotation2.TimeLimitSubGCD(time) -- time to calculate , nil=GetTime()

if not IROVar.LockDemoRotation2 then
    IROVar.LockDemoRotation2={}
end

Rotation=IROVar.LockDemoRotation2
Rotation.TimeLimit=0
-- TimeLimit = 12 sec after Cast Dreadstalkers
-- TimeLimit = 8 GCD after Cast HoG
-- This Rotation Predict Calculate After Cast Dreadstalkers

-- default Rotation = DS(12sec) --> HoG(cast 1 GCD, then Imp Despawn 8 GCD after cast HoG finish)

function Rotation.Event_COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    if sourceGUID~=IROVar.playerGUID then return end
    if subevent=="SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12,...)
        if spellName=="Call Dreadstalkers" then
            Rotation.TimeLimit=GetTime()+12
        elseif spellName=="Hand of Gul'dan" then
            Rotation.TimeLimit=math.min(Rotation.TimeLimit,GetTime()+(8*IROVar.CastTime1_5sec))
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
    val =math.floor(t/IROVar.CastTime0_5sec)
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
    SSMax=5, -- add in all item later
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
    DC=2,
    imp=8,
    SGCD=19,
}
Rotation.SubRotation[4]={
    name="Demonbolt",
    SS=1,
    DC=2,
    imp=5,
    SGCD=16,
}
Rotation.SubRotation[5]={
    name="Hand of Gul'dan",
    SS=3,
    DC=1,
    imp=5,
    SGCD=13,
}
Rotation.SubRotation[6]={
    name="Demonbolt",
    SS=0,
    DC=1,
    imp=2,
    SGCD=10,
}
Rotation.SubRotation[7]={
    name="Hand of Gul'dan",
    SS=2,
    DC=0,
    imp=2,
    SGCD=7,
}
Rotation.SubRotation[8]={
    name="Summon Demonic Tyrant",
    SS=0,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_2]
Rotation.SubRotation[9]={
    name="Hand of Gul'dan",
    SS=5,
    DC=2,
    imp=9,
    SGCD=19,
}
Rotation.SubRotation[10]={
    name="Demonbolt",
    SS=2,
    DC=2,
    imp=6,
    SGCD=16,
}
Rotation.SubRotation[11]={
    name="Hand of Gul'dan",
    SS=4,
    DC=1,
    imp=6,
    SGCD=13,
}
Rotation.SubRotation[12]={
    name="Demonbolt",
    SS=1,
    DC=1,
    imp=3,
    SGCD=10,
}
Rotation.SubRotation[13]={
    name="Hand of Gul'dan",
    SS=3,
    DC=0,
    imp=3,
    SGCD=7,
}
Rotation.SubRotation[14]={
    name="Summon Demonic Tyrant",
    SS=0,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_1]
Rotation.SubRotation[15]={
    name="Hand of Gul'dan",
    SS=5,
    DC=1,
    imp=8,
    SGCD=20,
}
Rotation.SubRotation[16]={
    name="Demonbolt",
    SS=2,
    DC=1,
    imp=5,
    SGCD=17,
}
Rotation.SubRotation[17]={
    name="Hand of Gul'dan",
    SS=4,
    DC=0,
    imp=5,
    SGCD=14,
}
Rotation.SubRotation[18]={
    name="Shadow Bolt",
    SS=1,
    DC=0,
    imp=2,
    SGCD=11,
}
Rotation.SubRotation[19]={
    name="Hand of Gul'dan",
    SS=2,
    DC=0,
    imp=2,
    SGCD=7,
}
Rotation.SubRotation[20]={
    name="Summon Demonic Tyrant",
    SS=0,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_0]
Rotation.SubRotation[21]={
    name="Hand of Gul'dan",
    SS=5,
    DC=0,
    imp=6,
    SGCD=14,
}
Rotation.SubRotation[22]={
    name="Shadow Bolt",
    SS=2,
    DC=0,
    imp=3,
    SGCD=11,
}
Rotation.SubRotation[23]={
    name="Hand of Gul'dan",
    SS=3,
    DC=0,
    imp=3,
    SGCD=7,
}
Rotation.SubRotation[24]={
    name="Summon Demonic Tyrant",
    SS=0,
    DC=0,
    imp=0,
    SGCD=4,
}
-----------Rotation[5_0] Extra proc
Rotation.SubRotation[25]={
    name="Hand of Gul'dan",
    SS=3,
    DC=1,
    imp=5,
    SGCD=13,
}
Rotation.SubRotation[26]={
    name="Demonbolt",
    SS=0,
    DC=1,
    imp=2,
    SGCD=10,
}
Rotation.SubRotation[27]={
    name="Hand of Gul'dan",
    SS=2,
    DC=0,
    imp=2,
    SGCD=7,
}
Rotation.SubRotation[28]={
    name="Summon Demonic Tyrant",
    SS=0,
    DC=0,
    imp=0,
    SGCD=4,
}
Rotation.SubRotation[29]={
    name="Error",
    SS=0,
    DC=0,
    imp=0,
    SGCD=0,
}
for i=1,#Rotation.SubRotation do
    if Rotation.SubRotation[i].name=="Demonbolt" then
        Rotation.SubRotation[i].SSMax=3
    elseif Rotation.SubRotation[i].name=="Shadow Bolt" then
        Rotation.SubRotation[i].SSMax=4
    else
        Rotation.SubRotation[i].SSMax=5
    end
end

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
        elseif t=="Demonbolt" then return 2
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

function Rotation.PredictSkillUse(SS,DC,SGCD)
    -- rule 1 : SS enough , DC enough , SGCD enough
    -- rule 2 : SS not overflow , Shadowbolt: SS<=4 , Demonbolt: SS<=3
    -- rule 3 : lowest SGCD
    -- rule 4 : HoG > Demonbolt > Shadow Bolt > Summon Demonic Tyrant

    if SGCD<0 then SGCD=0 end
    local selected=0
    local SGCDselected=100
    local impSelected=0
    for i=1,#Rotation.SortedRotation do
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