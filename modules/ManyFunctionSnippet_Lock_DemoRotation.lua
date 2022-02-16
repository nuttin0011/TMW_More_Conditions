--Pre Process Lock Demo Rotation
--Set Priority to 2
--function IROVar.Lock.DemoRotationGenerateStartData(haste)
--var IROVar.Lock.DemoRotation[haste][SS][DemonicCore][Has DemonicCalling]
--IROVar.Lock.DemoRotation[20][0][0][0]
--var IROVar.Lock.DemoRotationQData[haste][SS][DemonicCore][Has DemonicCalling]
--function IROVar.Lock.SearchRotation(HasteForCal)

if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end

local Lock=IROVar.Lock
Lock.DemoRotationSkill={
    {
        Name="Summon Demonic Tyrant",
        NextSequence=nil, -- follow by skill name
        SS=5, -- generate SS
        CastTime=2, -- befor Haste Modify
        TimeLimit=99, -- limit Rotation time after Cast
        InstanceCast=false, -- if true, limit time calculate at Begin of CastTime
        TimeLimitDepenOnHaste=false, -- if true, limit time mod by Haste
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true,[0]=true},
        CheckCDName="Summon Demonic Tyrant", -- check CD
        UseDemonicCalling=0,-- -1: must not has DemonicCalling; 0: dont check; 1: must has DemonicCalling
        NeedDemonicCore=false,
        FinishRotation=true, -- Stop Calculate Rotation
    },
    {
        Name="Hand of Gul'dan", -- use at 2 SS before Summon Tyrant
        NextSequence=nil, -- Set this to Lock.DemoRotationSkill[1] later
        SS=-2,
        CastTime=1.5,
        TimeLimit=12,
        InstanceCast=false,
        TimeLimitDepenOnHaste=true,
        UseWhenSS={[2]=true},
        CheckCDName=nil,
        UseDemonicCalling=0,
        NeedDemonicCore=false,
        FinishRotation=true,
    },
    {
        Name="Call Dreadstalkers",
        SS=0,
        CastTime=1.5,
        TimeLimit=12,
        InstanceCast=true, -- Instance Mean TimeLimit = TimeLimit
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true,[0]=true},
        CheckCDName="Call Dreadstalkers",
        UseDemonicCalling=1, -- -1: must not has DemonicCalling; 0: dont check; 1: must has DemonicCalling
        NeedDemonicCore=false,
    },
    {
        Name="Call Dreadstalkers",
        SS=-2,
        CastTime=1.5,
        TimeLimit=12,
        InstanceCast=false, -- false InstanceCast Mean TimeLimit = TimeLimit+CastTime
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true},
        CheckCDName="Call Dreadstalkers",
        UseDemonicCalling=-1, -- -1: must not has DemonicCalling; 0: dont check; 1: must has DemonicCalling
        NeedDemonicCore=false,
    },
    {
        Name="Hand of Gul'dan",
        SS=-3,
        CastTime=1.5,
        TimeLimit=12,
        InstanceCast=false,
        TimeLimitDepenOnHaste=true,
        UseWhenSS={[5]=true,[4]=true,[3]=true},
        CheckCDName=nil,
        UseDemonicCalling=0,
        NeedDemonicCore=false,
    },
    {
        Name="Shadow Bolt",
        SS=1,
        CastTime=2,
        TimeLimit=99,
        InstanceCast=false,
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[4]=true,[3]=true,[2]=true,[1]=true,[0]=true},
        CheckCDName=nil,
        UseDemonicCalling=0,
        NeedDemonicCore=false,
    },
    {
        Name="Demonbolt",
        SS=2,
        CastTime=1.5,
        TimeLimit=99,
        InstanceCast=true,
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[3]=true,[2]=true,[1]=true,[0]=true},
        CheckCDName=nil,
        UseDemonicCalling=1,
        NeedDemonicCore=false,
    },
    {
        Name="Grimoire: Felguard",
        SS=-1,
        CastTime=1.5,
        TimeLimit=17,
        InstanceCast=true,
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true},
        CheckCDName="Grimoire: Felguard",
        UseDemonicCalling=0,
        NeedDemonicCore=false,
    },
    {
        Name="Summon Vilefiend",
        SS=-1,
        CastTime=2,
        TimeLimit=15,
        InstanceCast=false,
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true},
        CheckCDName="Summon Vilefiend",
        UseDemonicCalling=0,
        NeedDemonicCore=false,
    },
}
Lock.DemoRotationSkill[2].NextSequence=Lock.DemoRotationSkill[1] --set sequence use HoG at SS=2 and Tyrant immediately
Lock.DemoRotationSkillGenSSByName={}
for k,v in pairs(Lock.DemoRotationSkill) do
    Lock.DemoRotationSkillGenSSByName[v.Name]=v.SS
end
Lock.DemoRotationSkillGenSSByName["Call Dreadstalkers"]=-2 -- Set Call DS to not use Demonic Calling


Lock.DemoRotation={} -- [Haste%]={}
local DemoRotation=Lock.DemoRotation
--[[    {
        Sequence={Lock.DemoRotationSkill[1]},
        TotalTimeUse=13, -- Time When Summon Tyrant Finish must multiple by HasteFactor
        ImpCreate=6,-- must recalculate
        CallDSUseAt=6, -- -1 = not use , other = Time use
        SummonVFUseAt=8,
        GrimoireFGUseAt=9.5,
        SummonTyrantUseAt=11,
        DemonboltUse=3,
    },]]

Lock.DemoRotationQData={} -- [Haste%][start SS][start Demonic Core][start HasDemonicCalling]={}
local QData=Lock.DemoRotationQData
--[[
    Sequence={},
    TotalTimeUse=0, -- Time When Summon Tyrant Finish must multiple by HasteFactor
    ImpCreate=0,-- must recalculate
    CallDSUseAt=-1, -- -1 = not use , other = Time use
    SummonVFUseAt=-1,
    GrimoireFGUseAt=-1,
    SummonTyrantUseAt=-1,
    DemonboltUse=0,
    TimeLimit=99,
    SS=0,
    DemonicCore=2,
]]

local DataInQ=0
local DataInRotation=0
function Lock.DemoRotationGenerateStartData(HasteForCal)
    if QData[HasteForCal]==nil then
        QData[HasteForCal]={}
    end
    for i=0,0 do --ss 0-5
        if QData[HasteForCal][i]==nil then
            QData[HasteForCal][i]={}
        end
        for i2=0,0 do --Demonic Core 0-4
            if QData[HasteForCal][i][i2]==nil then
                QData[HasteForCal][i][i2]={}
            end
            for i3=0,0 do --Demonic Calling 0-1
                if QData[HasteForCal][i][i2][i3]==nil then
                    QData[HasteForCal][i][i2][i3]={}
                end
                table.insert(QData[HasteForCal][i][i2][i3],
                    {
                        Sequence={},
                        TotalTimeUse=0,
                        ImpCreate=0,
                        ["Call Dreadstalkers"]=99, -- 99 = not use , other = Time use
                        ["Summon Vilefiend"]=99,
                        ["Grimoire: Felguard"]=99,
                        ["Summon Demonic Tyrant"]=99,
                        DemonboltUse=0,
                        TimeLimit=99,
                        SS=i,
                        DemonicCore=i2,
                        HasDemonicCalling=i3, -- 0 = false , 1= true
                        TyrantBuff=0,
                    }
                )
                DataInQ=DataInQ+1
            end
        end
    end
end

--tyrant buff weight
local TyrantImpBuff=2
local TyrantFGBuff=10 -- FG = Grimoire: Felguard = Velfiend
local TyrantDSBuff=11

function Lock.AddRotationSetToDemoRotation(Haste,StartSS,StartDemonicCore,StartHasDemonicCalling,RotationSet)
    function CalculateTyrantBuff(rotation)
        local TyrantBuff=rotation.ImpCreate*TyrantImpBuff
        if rotation["Grimoire: Felguard"]~=99 then
            TyrantBuff=TyrantBuff+TyrantFGBuff
        end
        if rotation["Summon Vilefiend"]~=99 then
            TyrantBuff=TyrantBuff+TyrantFGBuff
        end
        if rotation["Call Dreadstalkers"]~=99 then
            TyrantBuff=TyrantBuff+TyrantDSBuff
        end
        return TyrantBuff
    end

    function CompareSummon(Rotation1,Rotation2)
        local equal=true
        local Ro1FG=Rotation1["Grimoire: Felguard"]~=99
        local Ro2FG=Rotation2["Grimoire: Felguard"]~=99
        local Ro1VF=Rotation1["Summon Vilefiend"]~=99
        local Ro2VF=Rotation2["Summon Vilefiend"]~=99
        local Ro1DS=Rotation1["Call Dreadstalkers"]~=99
        local Ro2DS=Rotation2["Call Dreadstalkers"]~=99
        if Ro1FG~=Ro2FG then
            equal=false
        end
        if Ro1VF~=Ro2VF then
            equal=false
        end
        if Ro1DS~=Ro2DS then
            equal=false
        end
        return equal
    end

    function ChoseBestRotation(Rotation1,Rotation2,ss,demonicCalling) -- return 1 or 2
        -- criteria 1. SS must not Hit 5 when use Demonbolt
        -- criteria 2. SS must not Hit 5 when use DS wile demonicCalling
        -- criteria 3. chose less Time use
        -- criteria 4. chose more Time limit
        -- criteria 5. G:FG befor VF Befor DS
        -- criteria 6. HoG use Late as possible
        local UseRotation11=true
        local UseRotation12=true
        local UseRotation21=true
        local UseRotation22=true
        local ss1=ss
        local ss2=ss
        for k,v in ipairs(Rotation1.Sequence) do -- criteria 1+2
            local GenSS1 = Lock.DemoRotationSkillGenSSByName[v]
            if (demonicCalling==1) and (v.Name=="Call Dreadstalkers") then
                GenSS1=GenSS1+2
            end
            ss1=ss1+GenSS1
            if (ss1==5) then
                if (v=="Demonbolt") then
                    UseRotation11=false
                    break
                elseif (v=="Call Dreadstalkers") and (demonicCalling==1) then
                    UseRotation12=false
                end
            end
        end
        for k,v in ipairs(Rotation2.Sequence) do -- criteria 1+2
            local GenSS2 = Lock.DemoRotationSkillGenSSByName[v]
            if (demonicCalling==1) and (v.Name=="Call Dreadstalkers") then
                GenSS2=GenSS2+2
            end
            ss2=ss2+GenSS2
            if (ss2==5) then
                if (v=="Demonbolt") then
                    UseRotation21=false
                    break
                elseif (v=="Call Dreadstalkers") and (demonicCalling==1) then
                    UseRotation22=false
                end
            end
        end
        if UseRotation11~=UseRotation12 then
            return UseRotation11 and 1 or 2
        end
        if UseRotation21~=UseRotation22 then
            return UseRotation21 and 1 or 2
        end
        if math.abs(Rotation1.TotalTimeUse-Rotation2.TotalTimeUse)>0.1 then -- criteria 3
            return Rotation1.TotalTimeUse<Rotation2.TotalTimeUse and 1 or 2
        end
        if math.abs(Rotation1.TimeLimit-Rotation2.TimeLimit)>0.1 then -- criteria 4
            return Rotation1.TimeLimit>Rotation2.TimeLimit and 1 or 2
        end
        local FG1=Rotation1["Grimoire: Felguard"]
        local FG2=Rotation2["Grimoire: Felguard"]
        local VF1=Rotation1["Summon Vilefiend"]
        local VF2=Rotation2["Summon Vilefiend"]
        local DS1=Rotation1["Call Dreadstalkers"]
        local DS2=Rotation2["Call Dreadstalkers"]
        UseRotation11=false
        UseRotation12=false
        if (FG1~=99 and 1 or 0)+(VF1~=99 and 1 or 0)+(DS1~=99 and 1 or 0)>=2 then -- criteria 5
            -- check at least 2 Summon
            if FG1==99 then FG1=0 FG2=0 end
            if VF1==99 then VF1=(FG1+DS1)/2 VF2=(FG2+DS2)/2 end
            if (FG1<VF1)and(VF1<DS1) then
                UseRotation11=true
            end
            if (FG2<VF2)and(VF2<DS2) then
                UseRotation12=true
            end
        end
        if UseRotation11~=UseRotation12 then
            return UseRotation11 and 1 or 2
        end
        local HoGScore1=0
        local HoGScore2=0
        for k,v in ipairs(Rotation1.Sequence) do -- criteria 6
            if v=="Hand of Gul'dan" then
                HoGScore1=HoGScore1+k
            end
        end
        for k,v in ipairs(Rotation2.Sequence) do
            if v=="Hand of Gul'dan" then
                HoGScore2=HoGScore2+k
            end
        end
        if HoGScore1~=HoGScore2 then
            return HoGScore1>HoGScore2 and 1 or 2
        end
        return 2
    end

    if not DemoRotation then print("not DemoRotation") return end
    if DemoRotation[Haste]==nil then
        DemoRotation[Haste]={}
    end
    if DemoRotation[Haste][StartSS]==nil then
        DemoRotation[Haste][StartSS]={}
    end
    if DemoRotation[Haste][StartSS][StartDemonicCore]==nil then
        DemoRotation[Haste][StartSS][StartDemonicCore]={}
    end
    if DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling]==nil then
        DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling]={}
    end
    local TBuff=CalculateTyrantBuff(RotationSet)
    local AddToRotation=true
    for i,v in pairs(DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling]) do
        if CompareSummon(RotationSet,v) then
            if TBuff<v.TyrantBuff  then
                AddToRotation=false
                break
            end
            if TBuff==v.TyrantBuff then
                if ChoseBestRotation(RotationSet,v,StartSS,StartHasDemonicCalling)==1 then
                    DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling][i]=nil
                    DataInRotation=DataInRotation-1
                else
                    AddToRotation=false
                    break
                end
            end
            if TBuff>v.TyrantBuff then
                DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling][i]=nil
                DataInRotation=DataInRotation-1
            end
        end
    end

    print("AddToRotation : ",AddToRotation)

    if AddToRotation then
        RotationSet.TyrantBuff=TBuff
        DataInRotation=DataInRotation+1
        table.insert(DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling],RotationSet)
    end
end


function Lock.SearchRotation(HasteForCal) -- return true if must continue search
    function AddSkillToRotationSet(RotationSet,skill,hasteFactor)
        RotationSet.Sequence[#RotationSet.Sequence+1]=skill.Name --add skill name

        if RotationSet[skill.Name]==99 then -- if Check CD then add time use
            RotationSet[skill.Name]=RotationSet.TotalTimeUse
        end

        local TrueCastTime=skill.CastTime*hasteFactor

        local TrueTimeLimit=skill.TimeLimit
        if skill.TimeLimitDepenOnHaste then
            TrueTimeLimit=TrueTimeLimit*hasteFactor
        end
        if skill.InstanceCast then
            TrueTimeLimit=TrueTimeLimit-TrueCastTime
        end
        RotationSet.TimeLimit=math.min(RotationSet.TimeLimit-TrueCastTime,TrueTimeLimit)

        RotationSet.TotalTimeUse=RotationSet.TotalTimeUse+TrueCastTime

        if skill.Name=="Hand of Gul'dan" then
            RotationSet.ImpCreate=RotationSet.ImpCreate-skill.SS
        end

        RotationSet.SS=RotationSet.SS+skill.SS
        if RotationSet.SS>5 then
            RotationSet.SS=5
        end

        if skill.Name=="Demonbolt" then
            RotationSet.DemonboltUse=RotationSet.DemonboltUse+1
            RotationSet.DemonicCore=RotationSet.DemonicCore-1
        end

        if skill.NextSequence then
            AddSkillToRotationSet(RotationSet,skill.NextSequence,hasteFactor)
        end
    end

    function CheckCanUseThisSkill(RotationSet,skill,hasteFactor)
        local TrueCastTime=skill.CastTime*hasteFactor
        local CheckSkillNextSequence=skill.NextSequence
        while CheckSkillNextSequence do -- commulate CastTime this sequence
            TrueCastTime=TrueCastTime+CheckSkillNextSequence.CastTime*hasteFactor
            CheckSkillNextSequence=CheckSkillNextSequence.NextSequence
        end

        if skill.UseWhenSS[RotationSet.SS] and -- check SS
        (RotationSet.TimeLimit>=TrueCastTime+(skill.FinishRotation and 0 or (hasteFactor*2))) and -- check time limit if not finish spare for Tyrant
        (skill.NeedDemonicCore==false or RotationSet.DemonicCore>=1) and
        (not skill.CheckCDName or (RotationSet[skill.CheckCDName]==99)) and
        ((skill.UseDemonicCalling==0) or
         ((RotationSet.HasDemonicCalling==1) and skill.UseDemonicCalling==1) or
         ((RotationSet.HasDemonicCalling==0) and skill.UseDemonicCalling==-1))
        then
            return true
        end
        return false
    end

    function CopyRotation(RotationSet)
        local NewRotationSet={}
        for k,v in pairs(RotationSet) do
            if k=="Sequence" then
                NewRotationSet[k]={}
                for k2,v2 in pairs(v) do
                    NewRotationSet[k][k2]=v2
                end
            else
                NewRotationSet[k]=v
            end
        end
        return NewRotationSet
    end

    local HasteFactor=100/(100+HasteForCal)
    if QData[HasteForCal] then
        for k2,v2 in pairs(QData[HasteForCal]) do--start SS
            for k3,v3 in pairs(v2) do--start demonic core
                for k4,v4 in pairs(v3) do--has demonic calling
                    local PopRotation=table.remove(v4,1)
                    if PopRotation~=nil then
                        DataInQ=DataInQ-1
                        for k5,skillTry in pairs(Lock.DemoRotationSkill) do
                            if CheckCanUseThisSkill(PopRotation,skillTry,HasteFactor) then
                                local tempRotation=CopyRotation(PopRotation)
                                AddSkillToRotationSet(tempRotation,skillTry,HasteFactor)
                                if skillTry.FinishRotation then
                                    Lock.AddRotationSetToDemoRotation(HasteForCal,k2,k3,k4,tempRotation)
                                    print(skillTry.Name.." finish : "..DataInRotation)
                                    print("Q : "..DataInQ)
                                else
                                    table.insert(v4,tempRotation)
                                    DataInQ=DataInQ+1
                                end
                            end
                        end
                        return true
                    end
                end
            end
        end
    end
    return false
end
