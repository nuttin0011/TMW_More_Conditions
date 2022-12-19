-- Many Function DPS Average 10.0.0/1
-- this file save many function for paste to TMW Snippet LUA
-- Set Priority to 5
-- counter "targethptimeremain" target HP time remain


if not IROVar then IROVar = {} end
if not IROVar.DPS then IROVar.DPS = {} end

local Details=Details -- details
local playerName=UnitName("player")


IROVar.DPS.GroupDPSHistory={
    10000,
}

IROVar.DPS.Average=10000
IROVar.DPS.nMobLastFight=1
IROVar.DPS.CurrentMobAlive=1


IROVar.DPS.CalculateMobSum=1
IROVar.DPS.CalculateMobTime=1

function IROVar.DPS.CalculateDPSAverage()
    local nHistory=#IROVar.DPS.GroupDPSHistory
    local n1=math.ceil(nHistory*.2)
    local nn=nHistory-n1+1
    -- calculate from n 20% to 80%
    local n=0
    local sum=0
    for i=n1,nn do
        n=n+1
        sum=sum+IROVar.DPS.GroupDPSHistory[i]
    end
    IROVar.DPS.Average=sum/n
end

function IROVar.DPS.AddGroupDPSHistory(dps)
    local n=#IROVar.DPS.GroupDPSHistory
    for i=1,n do
        if dps<IROVar.DPS.GroupDPSHistory[i] then
            table.insert(IROVar.DPS.GroupDPSHistory,i,dps)
            return
        end
    end
    table.insert(IROVar.DPS.GroupDPSHistory,dps)
end

function IROVar.DPS.DumpGroupDPSLastFight()
    if not Details then return 10000 end -- if no details

    --get the current combat and the combat time
    local currentCombat = Details:GetCurrentCombat()
    local combatTime = currentCombat:GetCombatTime()
    if combatTime<5 then return 0 end -- if Combat < 5 sec not count

    local nPlayer=0
    if combatTime<1 then combatTime=1 end

    --iterate among all actors that performed a heal during the combat
    local totalDPS = 0
    for _, actor in currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
        if (actor:IsPlayer() and actor:IsGroupPlayer()) then
            totalDPS = totalDPS + actor.total
            nPlayer=nPlayer+1
        end
    end
    --print("Lastfight:",totalDPS,"nPlayer:",nPlayer,"time:",combatTime,"DPS:",(totalDPS/combatTime)/nPlayer)
    if nPlayer<1 then nPlayer=1 end
    totalDPS=(totalDPS/combatTime)/nPlayer
    return totalDPS
end

function IROVar.DPS.CheckMobIncombat()
    local nMob=IROEnemyCountInRange(40)
    if nMob==0 then nMob=1 end
    IROVar.DPS.CurrentMobAlive=nMob
    if nMob>=1 then
        IROVar.DPS.CalculateMobSum=IROVar.DPS.CalculateMobSum+nMob
        IROVar.DPS.CalculateMobTime=IROVar.DPS.CalculateMobTime+1
    end
end

local CheckHolder=C_Timer.NewTimer(0.1,function() end)

IROVar.RegisterIncombatCallBackRun("IROVarDPSCountMob",function()
    CheckHolder=C_Timer.NewTicker(1.34,IROVar.DPS.CheckMobIncombat)
end)
IROVar.RegisterOutcombatCallBackRun("IROVarDPSCountMob",function()
    CheckHolder:Cancel()
    local TotalDPS=IROVar.DPS.DumpGroupDPSLastFight()
    local nMob=IROVar.DPS.CalculateMobSum/IROVar.DPS.CalculateMobTime
    if nMob<1 then nMob=1 end
    IROVar.DPS.CalculateMobSum=1
    IROVar.DPS.CalculateMobTime=1
    IROVar.DPS.nMobLastFight=nMob
    IROVar.DPS.CurrentMobAlive=1
    if TotalDPS<=100 then
        --print("DPS Too Low!! / Or Combat Time too Fast")
        return
    end
    local DPSperMob=TotalDPS/nMob
    IROVar.DPS.AddGroupDPSHistory(DPSperMob)
    IROVar.DPS.CalculateDPSAverage()
    --local s1=string.format("DPSAvrPerMob:%.1f TotalDPS:%.1f", IROVar.DPS.Average,TotalDPS)
    --local s2=string.format("nMob:%.1f DPS/Mob:%.1f", nMob,DPSperMob)
    --print(s1)
    --print(s2)
end)

function IROVar.DPS.PredictTargetLifeTime()
    local HP=UnitHealth("target")
    local nGroup=GetNumGroupMembers()
    nGroup=(nGroup==0) and 1 or nGroup
    return math.floor((HP*IROVar.DPS.CurrentMobAlive)/(IROVar.DPS.Average*nGroup))
end

IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Target Life Time Remain",function()
    IROVar.UpdateCounter("targethptimeremain",IROVar.DPS.PredictTargetLifeTime())
end)

C_Timer.NewTicker(0.8,function()
    IROVar.UpdateCounter("targethptimeremain",IROVar.DPS.PredictTargetLifeTime())
end)