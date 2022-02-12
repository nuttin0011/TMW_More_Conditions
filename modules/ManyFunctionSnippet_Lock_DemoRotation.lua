--Pre Process Lock Demo Rotation

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
        CheckCDName={["Summon Demonic Tyrant"]=true}, -- check CD
        UseDemonicCalling=0,-- -1: must not has DemonicCalling; 0: dont check; 1: must has DemonicCalling
        NeedDemonicCore=false,
        isHoG=false,
        FinishRotation=true, -- Stop Calculate Rotation
    },
    {
        Name="Hand of Gul'dan", -- use at 2 SS before Summon Tyrant
        NextSequence="Summon Demonic Tyrant",
        SS=5,
        CastTime=3.5,
        TimeLimit=12,
        InstanceCast=false,
        TimeLimitDepenOnHaste=true,
        UseWhenSS={[2]=true},
        CheckCDName=nil,
        UseDemonicCalling=0,
        NeedDemonicCore=false,
        isHoG=false,
    },
    {
        Name="Call Dreadstalkers",
        SS=0,
        CastTime=1.5,
        TimeLimit=12,
        InstanceCast=true, -- Instance Mean TimeLimit = TimeLimit
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true,[0]=true},
        CheckCDName={["Call Dreadstalkers"]=true},
        UseDemonicCalling=1, -- -1: must not has DemonicCalling; 0: dont check; 1: must has DemonicCalling
        NeedDemonicCore=false,
        isHoG=false,
    },
    {
        Name="Call Dreadstalkers",
        SS=-2,
        CastTime=1.5,
        TimeLimit=12,
        InstanceCast=false, -- false InstanceCast Mean TimeLimit = TimeLimit+CastTime
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true},
        CheckCDName={["Call Dreadstalkers"]=true},
        UseDemonicCalling=-1, -- -1: must not has DemonicCalling; 0: dont check; 1: must has DemonicCalling
        NeedDemonicCore=false,
        isHoG=false,
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
        isHoG=false,
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
        isHoG=false,
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
        isHoG=false,
    },
    {
        Name="Grimoire: Felguard",
        SS=-1,
        CastTime=1.5,
        TimeLimit=17,
        InstanceCast=true,
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true},
        CheckCDName={["Grimoire: Felguard"]=true},
        UseDemonicCalling=0,
        NeedDemonicCore=false,
        isHoG=false,
    },
    {
        Name="Summon Vilefiend",
        SS=-1,
        CastTime=2,
        TimeLimit=15,
        InstanceCast=false,
        TimeLimitDepenOnHaste=false,
        UseWhenSS={[5]=true,[4]=true,[3]=true,[2]=true,[1]=true},
        CheckCDName={["Summon Vilefiend"]=true},
        UseDemonicCalling=0,
        NeedDemonicCore=false,
        isHoG=false,
    },
}

Lock.DemoRotation={}
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

Lock.DemoRotationQueue={}
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

for i=0,5 do
    for i2=0,4 do
        table.insert(Lock.DemoRotationQueue,
            {
                Sequence={},
                TotalTimeUse=0, -- Time When Summon Tyrant Finish must multiple by HasteFactor
                ImpCreate=0,-- must recalculate
                CallDSUseAt=-1, -- -1 = not use , other = Time use
                SummonVFUseAt=-1,
                GrimoireFGUseAt=-1,
                SummonTyrantUseAt=-1,
                DemonboltUse=0,
                TimeLimit=99,
                SS=i,
                DemonicCore=i2,
            }
        )
    end
end

function SearchRotation() -- return true if must continue search
    if table.getn(Lock.DemoRotationQueue)==0 then return false end
    local SummonTyrantCastTime=2
    local Rotation=table.remove(Lock.DemoRotationQueue)
    for k,v in pairs(Lock.DemoRotationSkill) do
        local SS=
        if v.UseWhenSS[Rotation.SS] and
            (Rotation.TimeLimit<=v.CastTime+SummonTyrantCastTime)
        then

        end
        --local newRotation=CopyTable(Rotation)


        --table.insert(newRotation.Sequence,v)

    end
    return true
end