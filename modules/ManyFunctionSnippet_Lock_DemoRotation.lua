--Pre Process Lock Demo Rotation
--Set Priority to 2

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

function Lock.DemoRotationGenerateStartData(HasteForCal)
    if QData[HasteForCal]==nil then
        QData[HasteForCal]={}
    end
    for i=0,5 do
        if QData[HasteForCal][i]==nil then
            QData[HasteForCal][i]={}
        end
        for i2=0,4 do
            if QData[HasteForCal][i][i2]==nil then
                QData[HasteForCal][i][i2]={}
            end
            for i3=0,1 do
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
                    }
                )
            end
        end
    end
end

function Lock.AddRotationSetToDemoRotation(Haste,StartSS,StartDemonicCore,StartHasDemonicCalling,RotationSet)
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
    table.insert(DemoRotation[Haste][StartSS][StartDemonicCore][StartHasDemonicCalling],RotationSet)
end


function Lock.SearchRotation(HasteForCal) -- return true if must continue search
    function AddSkillToRotationSet(RotationSet,skill,hasteFactor)
        RotationSet.Sequence[#RotationSet.Sequence+1]=skill.Name --add skill name

        if RotationSet[skill.Name]==99 then -- if Check CD then add time use
            RotationSet[skill.Name]=RotationSet.TotalTimeUse
        end

        local TrueCastTime=skill.CastTime*hasteFactor
        RotationSet.TotalTimeUse=RotationSet.TotalTimeUse+TrueCastTime

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
        (not skill.CheckCDName or (RotationSet[skill.CheckCDName==99])) and
        ((skill.UseDemonicCalling==0) or
         ((RotationSet.HasDemonicCalling==1) and skill.UseDemonicCalling==1) or
         ((RotationSet.HasDemonicCalling==0) and skill.UseDemonicCalling==-1))
        then
            return true
        end
        return false
    end

    local HasteFactor=100/(100+HasteForCal)
    for k,v in pairs(QData) do--haste
        for k2,v2 in pairs(v) do--start SS
            for k3,v3 in pairs(v2) do--start demonic core
                for k4,v4 in pairs(v3) do--has demonic calling
                    local PopRotation=table.remove(v4,1)
                    for k5,skillTry in pairs(Lock.DemoRotationSkill) do
                        if CheckCanUseThisSkill(PopRotation,skillTry,HasteFactor) then
                            AddSkillToRotationSet(PopRotation,skillTry,HasteFactor)
                            if skillTry.FinishRotation then
                                Lock.AddRotationSetToDemoRotation(k,k2,k3,k4,PopRotation)
                            else
                                table.insert(v4,PopRotation)
                            end
                        end
                    end
                    return true
                end
            end
        end
    end
    return false
end
