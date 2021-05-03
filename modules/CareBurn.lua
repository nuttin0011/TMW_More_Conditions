-- Care Burn 1.5 edit Icon
-- Burst Only Condition met / no condition on this mob
-- IROVar.CareBurn(spec) ; return true / false ; can use only "target"

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
            --burn after impact
            ["Sludgefist"]=[[return TMW.CNDT.Env.AuraDur("target", "destructive impact", "HELPFUL")>0]],
            --burn 2 sec befor run impact , 253 is Hunter BM
            ["Sludgefist253"]=[[local tHG=TMW.CNDT.Env.AuraDur("targettarget", "hateful gaze", "HARMFUL");return ((t>0)and(t<2))or(TMW.CNDT.Env.AuraDur("target", "destructive impact", "HELPFUL")>0)]],
            --not has Shield
            ["General Kaal"]=[[return TMW.CNDT.Env.AuraDur("target", "hardened stone form", "HELPFUL")==0]],
            ["General Grashaal"]=[[return TMW.CNDT.Env.AuraDur("target", "hardened stone form", "HELPFUL")==0]],

        },

    }
    IROVar.CareBurn = function(spec)
        spec=spec or ""
        local nUnit="target"
        if not IROVar.MobListForBurn[IROVar.InstanceName] then
            return true
        end
        local MobName=UnitName(nUnit)
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
end













