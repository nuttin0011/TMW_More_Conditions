-- Set

EROMapName=C_Map.GetMapInfo(WorldMapFrame:GetMapID()).name

EROPositionList={}
EROPositionList["Krasarang Wilds"]={
    {41.81,89.81},
    {42.97,90.47},
    {43.73,89.30},
    {42.89,88.95}
}

EROPointToGo=nil


function FindNearestPosition()
    if not EROPositionList then return 0 end
    if not EROPositionList[EROMapName] then return 0 end
    local pP = C_Map.GetPlayerMapPosition( C_Map.GetBestMapForUnit("player"), "player")
    local WalkLen = 100000
    local WalkPoint = 0
    for k,v in pairs(EROPositionList[EROMapName]) do
        local Dest = CreateVector2D(v[1]/100,v[2]/100)
        Dest:Subtract(pP)
        local len = Dest:GetLength()
        if len < WalkLen then
            WalkPoint=k
            WalkLen=len
        end
    end
    print("Find Nearest Position")
    print("Nearest is : ",WalkPoint)
    return WalkPoint
end

function GoNextPoint()
    print("GoTo : "..EROPointToGo.." Done")
    
    EROPointToGo=EROPointToGo+1
    if not EROPositionList[EROMapName][EROPointToGo] then
        EROPointToGo=1
    end
    print("Next is : "..EROPointToGo)
end


if (not EROMoveHandle) then EROMoveHandle=C_Timer.NewTimer(0,function() end) end

function stopmove(t)
    t=t or 0.1
    EROMoveHandle:Cancel()
    EROMoveHandle= C_Timer.NewTimer(t,function() TMW_ST:UpdateCounter("movedir",0) end)
end

