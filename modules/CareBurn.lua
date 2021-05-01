-- Care Burn 1.4b Icon
-- Burst Only Condition met / no condition on this mob
-- IROVar.CareBurn() ; return true / false ; can use only "target"

if not IROVar then IROVar={} end
if not IROVar.InstanceName then IROVar.InstanceName = GetInstanceInfo() end
if (not IROVar.fspec) and (not IROVar.finstanceName) then
    IROVar.finstanceName = CreateFrame("Frame")
    IROVar.finstanceName:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    IROVar.finstanceName:SetScript("OnEvent", function()
            IROVar.InstanceName = GetInstanceInfo()
    end)
end
if not IROVar.MobListForBurn then
    --[[
        [instance name]={[mob name]=true / false / lua scrip}
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
        ["Castle Nathria"]={
            ["Sludgefist"]=[[return TMW.CNDT.Env.AuraDur("target", "destructive impact")>0]],
        },

    }
    IROVar.CareBurn = function()
        local nUnit="target"
        if not IROVar.MobListForBurn[IROVar.InstanceName] then
            return true
        end
        local MobName=UnitName(nUnit)
        if not MobName then return true end
        if IROVar.MobListForBurn[IROVar.InstanceName][MobName]==nil then
            return true
        end
        if IROVar.MobListForBurn[IROVar.InstanceName][MobName]==false then return false end
        return (IROVar.MobListForBurn[IROVar.InstanceName][MobName]==true) and true or
            loadstring(IROVar.MobListForBurn[IROVar.InstanceName][MobName])()
    end
end













