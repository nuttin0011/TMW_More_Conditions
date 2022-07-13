-- Care Burn 3.0
-- Version LUA Snipped
-- Set Priority to 20
-- Burst Only Condition met / no condition on this mob
-- IROVar.CareBurn(spec) ; return true / false ; can use only "target"

--[[
    [instance name]={[mob name/encounterID]=true / false / lua scrip}
]]
IROVar.MobListForBurn = {
    ["Mists of Tirna Scithe"] = {
        ["Ingra Maloch"] = [[return TMW.CNDT.Env.AuraDur("target", "droman's wrath", "HARMFUL")>0]],
        ["Droman Oulfarran"]=false,
    },
    ["De Other Side"] = {
        ["Mueh'zala"] = [[return (UnitHealth("target")/UnitHealthMax("target"))<0.2]],
        ["Shattered Visage"] = true,
        ["Millhouse Manastorm"]=false,
    },
    ["Halls of Atonement"] ={
        ["Echelon"] = [[return UnitCastingInfo("target")=="Stone Call"]],
        ["Undying Stonefiend"] = [[return TMW.CNDT.Env.AuraDur("target", "stone form", "HELPFUL")==0]],
    },
    ["The Necrotic Wake"] ={
        ["Stitchflesh's Creation"]=false,
        ["Zolramus Siphoner"]=false,
    },
    ["Spires of Ascension"] ={
        ["Oryphrion"]=[[return TMW.CNDT.Env.AuraDur("target", "drained", "HARMFUL")>10]],
    },
}

IROVar.MobListForBurn.encounterID=nil
IROVar.MobListForBurn.encounterStart=GetTime()

IROVar.MobListForBurn.encounterStart=0
IROVar.MobListForBurn.eventFunc=function(_,event,encounterID, encounterName, difficultyID, groupSize,success)
    if event=="ENCOUNTER_START" then
        IROVar.MobListForBurn.encounterID=encounterID
        IROVar.MobListForBurn.encounterStart=GetTime()
    elseif event=="ENCOUNTER_END" then
        IROVar.MobListForBurn.encounterID=nil
    end
end

IROVar.MobListForBurn.frame=CreateFrame("Frame")
IROVar.MobListForBurn.frame:RegisterEvent("ENCOUNTER_START")
IROVar.MobListForBurn.frame:RegisterEvent("ENCOUNTER_END")
IROVar.MobListForBurn.frame:SetScript("OnEvent", IROVar.MobListForBurn.eventFunc)

local function ZCareBurn(spec)
    if IROVar.MobListForBurn.encounterID and (not UnitExists("boss1")) then
        IROVar.MobListForBurn.encounterID=nil
    end
    local encounterID=IROVar.MobListForBurn.encounterID or 0
    if IROVar.MobListForBurn[encounterID] then
        if IROVar.MobListForBurn[encounterID][spec]~=nil then
            if IROVar.MobListForBurn[encounterID][spec]==false then return false end
            return (IROVar.MobListForBurn[encounterID][spec]==true) and true or
            loadstring(IROVar.MobListForBurn[encounterID][spec])()
        else
            if IROVar.MobListForBurn[encounterID][0]==false then return false end
            return (IROVar.MobListForBurn[encounterID][0]==true) and true or
            loadstring(IROVar.MobListForBurn[encounterID][0])()
        end
    end
    if not IROVar.MobListForBurn[IROVar.InstanceName] then
        return true
    end
    local MobName=IROVar.TargetName
    if not MobName then return true end
    if IROVar.MobListForBurn[IROVar.InstanceName][MobName]==nil then
        return true
    end
    local MobNameWithSpec=MobName..spec
    if IROVar.MobListForBurn[IROVar.InstanceName][MobNameWithSpec]~=nil then
        MobName=MobNameWithSpec
    end
    if IROVar.MobListForBurn[IROVar.InstanceName][MobName]==false then return false end
    return (IROVar.MobListForBurn[IROVar.InstanceName][MobName]==true) and true or
        loadstring(IROVar.MobListForBurn[IROVar.InstanceName][MobName])()
end

local CBOld={
    [1]=bit.rshift(IROVar.TickCount005,2)-1, -- TickCount
    [2]=IROVar.TargetChangeCount-1, -- TargetCount
    [3]={
        --[spec]=val
    }
}

function IROVar.CareBurn(spec)
    spec=spec or ""
    local Tick=bit.rshift(IROVar.TickCount005,2)
    local Target=IROVar.TargetChangeCount
    if CBOld[1]~=Tick or CBOld[2]~=Target or (CBOld[3][spec]==nil) then
        CBOld[1]=Tick
        CBOld[2]=Target
        CBOld[3][spec]=ZCareBurn(spec)
    end
    return CBOld[3][spec]
end





