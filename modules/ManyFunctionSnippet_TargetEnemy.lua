--Many Function Target Enemy Version 2
--Set Priority to 10
if not IROVar then IROVar={} end
IROVar.TargetEnemy={}

IROVar.TargetEnemy.Cycling=false
IROVar.TargetEnemy.CyclingH=C_Timer.NewTimer(0.1,function() end)
IROVar.TargetEnemy.Cycle=false
IROVar.TargetEnemy.CycleH=C_Timer.NewTimer(0.1,function() end)
IROVar.TargetEnemy.Queue={}
IROVar.TargetEnemy.Pause=false
--[[
    [1] = {
        priority = 1,  -- lower do first
        TargetGUID = UnitGUID, -- find target,
        DoneThis = function() end, -- return true if finish this target,
        name = name or nil,
    }
]]

IROVar.TargetEnemy.tGUID=nil
IROVar.TargetEnemy.tDone=function() return true end
IROVar.TargetEnemy.tPriority=999
IROVar.TargetEnemy.tTimesClick=1
IROVar.TargetEnemy.tExpTime=TMW.time+9999

function IROVar.TargetEnemy.RegisterTargetting(unitGUID,priority,DoneThisFunc,name,ExpTime)
    table.insert(IROVar.TargetEnemy.Queue,
        {
            ["TargetGUID"]=unitGUID,
            ["priority"]=priority,
            ["DoneThis"]=DoneThisFunc,
            ["Name"]=name,
            ["ExpTime"]=TMW.time + (ExpTime or 5),
        })
    if not IROVar.TargetEnemy.Cycling or priority<IROVar.TargetEnemy.tPriority then
        IROVar.TargetEnemy.NextJob()
    end
end

function IROVar.TargetEnemy.FindJobName(name) -- return #index in queue / nil if not found
    for k,v in ipairs(IROVar.TargetEnemy.Queue) do
        if v.Name==name then
            return k
        end
    end
    return nil
end

function IROVar.TargetEnemy.NextJob()
    local min=999
    local vv
    local deleteTable={}
    for k,v in ipairs(IROVar.TargetEnemy.Queue) do
        if v.DoneThis() or TMW.time>v.ExpTime then
            table.insert(deleteTable,k)
        else
            if min>v.priority then
                min=v.priority
                vv=v
            end
        end
    end
    if vv then
        if UnitGUID("target")==vv.TargetGUID then
            print("FoundEnemy")
            IROVar.UpdateCounter("cycletargetenemy",0)
            IROVar.TargetEnemy.Cycle=false
        else
            IROVar.UpdateCounter("cycletargetenemy",1)
            IROVar.TargetEnemy.Cycle=true
        end
        IROVar.UpdateCounter("cycletargetingenemy",1)
        IROVar.TargetEnemy.Cycling=true
        IROVar.TargetEnemy.tGUID=vv.TargetGUID
        IROVar.TargetEnemy.tDone=vv.DoneThis
        IROVar.TargetEnemy.tPriority=vv.priority
        IROVar.TargetEnemy.tExpTime=vv.ExpTime
    else
        IROVar.TargetEnemy.tGUID=nil
        IROVar.TargetEnemy.tDone=function() return true end
        IROVar.TargetEnemy.Cycling=false
        IROVar.TargetEnemy.Cycle=false
        IROVar.TargetEnemy.tPriority=999
        IROVar.TargetEnemy.tExpTime=TMW.time+9999
        IROVar.UpdateCounter("cycletargetenemy",0)
        IROVar.UpdateCounter("cycletargetingenemy",0)
    end
    for i=#deleteTable,1,-1 do
        table.remove(IROVar.TargetEnemy.Queue,deleteTable[i])
    end
end

--[[function IROVar.TargetEnemy.ClickTargetEnemy() -- use after /TargetEnemy
    if not IROVar.TargetEnemy.Cycling then return end
    if UnitGUID("target")==IROVar.TargetEnemy.tGUID then
        IROVar.TargetEnemy.Cycle=false
        IROVar.UpdateCounter("cycletargetenemy",0)
    end
end]]

function IROVar.TargetEnemy.IntervalCheck() -- run check every 0.1 sec if Cycling
    if not IROVar.TargetEnemy.Cycling then return end -- should Kill Tick Check interval
    if IROVar.TargetEnemy.tDone() or TMW.time > IROVar.TargetEnemy.tExpTime then
        IROVar.TargetEnemy.NextJob()
    elseif UnitGUID("target")~=IROVar.TargetEnemy.tGUID and not IROVar.TargetEnemy.Cycle then
        IROVar.TargetEnemy.Cycle=true
        IROVar.UpdateCounter("cycletargetenemy",1)
    end
end

C_Timer.NewTicker(0.15,IROVar.TargetEnemy.IntervalCheck)

---ClickMouse To Change Target is Pause Targeting for 1 sec

function IROVar.TargetEnemy.AfterTargetEnemyMacro() -- Use after use Macro /targetenemy
    IROVar.TargetEnemy.tTimesClick=IROVar.TargetEnemy.tTimesClick+1
    if not IROVar.TargetEnemy.Cycling then return end
    if IROVar.TargetEnemy.tDone() or TMW.time > IROVar.TargetEnemy.tExpTime then
        IROVar.TargetEnemy.NextJob()
    elseif UnitGUID("target")==IROVar.TargetEnemy.tGUID then
        IROVar.TargetEnemy.Cycle=false
        IROVar.UpdateCounter("cycletargetenemy",0)
        return true
    else
        IROVar.TargetEnemy.Cycle=true
        IROVar.UpdateCounter("cycletargetenemy",1)
        return false
    end
end

function IROVar.TargetEnemy.IsTargetCasting(tGUID,tUnitToken) -- Check Target token/GUID is casting?
    if UnitGUID(tUnitToken)~=tGUID then
        local m
        for i=1,30 do
            local mm="nameplate"..i
            if UnitGUID(mm)==tGUID then
                m=mm
                break
            end
        end
        if m then tGUID=m else return false end
    end
    local n=UnitCastingInfo(tUnitToken)
    if not n then
        n=UnitChannelInfo(tUnitToken)
    end
    if n then return true else return false end
end

IROVar.UseNAPCycle=nil
function IROVar.IsTargeted()
    if not IROVar.TargetEnemy.Cycle then return end
    print("TargetEnemy")
    if IROVar.TargetEnemy.AfterTargetEnemyMacro() then print("FoundEnemy") end
end

IROVar.UseNAPCyclingH=C_Timer.NewTimer(1,function()end)