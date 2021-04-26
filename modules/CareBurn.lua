-- Care Burn 1.0 Icon
-- Burst Only Condition met / no condition on this mob
-- IROVar.CareBurn(unit e.g. "target") ; return true / false

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
    IROVar.MobListForBurn = {
        ["Mists of Tirna Scithe"] = {
            ["Ingra Maloch"] = [[return TMW.CNDT.Env.AuraDur("target", "droman's wrath", "HARMFUL")>0]],
            ["Droman Oulfarran"]=false,
        },
        ["Castle Nathria"]={
            ["Sludgefist"]=[[return TMW.CNDT.Env.AuraDur("target", "destructive impact", "HARMFUL")>0]],
        },
    }
    IROVar.CareBurn = function(nUnit)
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













