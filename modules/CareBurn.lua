-- Care Burn 1.7 Icon
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
        ["Castle Nathria"]={
            --burn after impact
            ["Sludgefist"]=[[return TMW.CNDT.Env.AuraDur("target", "destructive impact", "HELPFUL")>0]],
            --burn 2 sec befor run impact , 253=Hunter BM ,72=war fury
            ["Sludgefist253"]=[[local t=TMW.CNDT.Env.AuraDur("targettarget", "hateful gaze", "HARMFUL");return ((t>0)and(t<2))or(TMW.CNDT.Env.AuraDur("target", "destructive impact", "HELPFUL")>0)]],
            ["Sludgefist72"]=[[local t=TMW.CNDT.Env.AuraDur("targettarget", "hateful gaze", "HARMFUL");return ((t>0)and(t<2))or(TMW.CNDT.Env.AuraDur("target", "destructive impact", "HELPFUL")>0)]],
            --not has Shield
            ["General Kaal"]=[[return TMW.CNDT.Env.AuraDur("target", "hardened stone form", "HELPFUL")==0]],
            ["General Grashaal"]=[[return TMW.CNDT.Env.AuraDur("target", "hardened stone form", "HELPFUL")==0]],
        },
    }
    IROVar.MobListForBurn.encounterID=nil
    IROVar.MobListForBurn.encounterStart=GetTime()
    IROVar.MobListForBurn.enTimer1=0
    IROVar.MobListForBurn.enTimer2=0
    IROVar.MobListForBurn.enTimer3=0
    if not IROVar.MobListForBurn.event then
        IROVar.MobListForBurn.encounterStart=0
        IROVar.MobListForBurn.eventFunc=function(_,event,encounterID, encounterName, difficultyID, groupSize,success)
            if event=="ENCOUNTER_START" then
                IROVar.MobListForBurn.encounterID=encounterID
                IROVar.MobListForBurn.encounterStart=GetTime()
                IROVar.MobListForBurn.enTimer1=0
                IROVar.MobListForBurn.enTimer2=0
                IROVar.MobListForBurn.enTimer3=0
            elseif event=="ENCOUNTER_END" then
                IROVar.MobListForBurn.encounterID=nil
            end
        end
    end
    if not IROVar.MobListForBurn.frame then
        IROVar.MobListForBurn.frame=CreateFrame("Frame")
        IROVar.MobListForBurn.frame:RegisterEvent("ENCOUNTER_START")
        IROVar.MobListForBurn.frame:RegisterEvent("ENCOUNTER_END")
        IROVar.MobListForBurn.frame:SetScript("OnEvent", IROVar.MobListForBurn.eventFunc)
    end
    IROVar.CareBurn = function(spec)
        if IROVar.MobListForBurn.encounterID and (not UnitExists("boss1")) then
            IROVar.MobListForBurn.encounterID=nil
        end
        spec=spec or ""
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



IROVar.MobListForBurnByEncounterID = {
    [2383]={
        timer_name ={"timer1","timer2","timer3"},
        start_up = [[reset("timer1") reset("timer2")]],
        register_event ={
            ["SPELL_CAST_START 22354"]=[[reset("timer1") reset("timer2")]],
            ["SPELL_AURA_APPLIED 55445"]=[[reset("timer3")]]
        },
        condition=[[return (TMW.CNDT.Env.AuraDur("player","debuff", "HARMFUL")==0)and (val("timer1")<25)]],
        condition72=[[return true]],
    }
}





