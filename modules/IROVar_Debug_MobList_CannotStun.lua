
--IROVar.MobList.Debug()
--IROVar.MobCannotStun.Debug()
if not AceGUI then AceGUI = LibStub("AceGUI-3.0") end

if not IROVar.MobList then
    IROVar.MobList={}
    IROVar.MobList.DebugMode=false
    IROVar.MobList.Debug = function()
        IROVar.MobList.DebugMode=true
        IROVar.MobList.Frame=AceGUI:Create("Frame")
        IROVar.MobList.Frame:SetTitle("MobList")
        IROVar.MobList.Frame:SetLayout("Fill")
        IROVar.MobList.Frame:SetWidth(500)
        IROVar.MobList.Frame:SetHeight(600)
        IROVar.MobList.Frame:SetPoint("TOPLEFT","UIParent","TOPLEFT",20,-50)
        IROVar.MobList.Frame:SetCallback("OnClose", function(widget)
            IROVar.MobList.DebugMode=false
            AceGUI:Release(widget)
        end)
        IROVar.MobList.TreeGroup = AceGUI:Create("TreeGroup")
        if not IROVar.MobList.TreeGroupStatus then
            IROVar.MobList.TreeGroupStatus = { groups = {} }
            IROVar.MobList.TreeGroupStatus.treewidth=400
        end
        IROVar.MobList.TreeGroup:SetStatusTable(IROVar.MobList.TreeGroupStatus)
        IROVar.MobList.Frame:AddChild(IROVar.MobList.TreeGroup)
        if not IROVar.MobList.Tree then IROVar.MobList.CreateTree() end
        IROVar.MobList.TreeGroup:SetTree(IROVar.MobList.Tree)
        if not IROVar.MobList.fspec then
            IROVar.MobList.fspec = CreateFrame("Frame")
            IROVar.MobList.fspec:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            IROVar.MobList.fspec:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            IROVar.MobList.fspec:SetScript("OnEvent", IROVar.MobList.OnEvent)
        end
    end
    IROVar.MobList.OnEvent=function(_, event)
        if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
            local iName = IROVar.InstanceName
            local uName = UnitName("target") or ""
            local sName = UnitCastingInfo("target")
            if not sName then sName = UnitChannelInfo("target") or "" end
            IROVar.MobList.DisableText(iName,uName,sName)
        else
            local _, subEvent,_,_,sourceName,_,_,_,_,_,_,_, spellName = CombatLogGetCurrentEventInfo()
            if subEvent == "SPELL_CAST_START" then
                local iName=IROVar.InstanceName
                local uName=sourceName
                local sName = spellName
                IROVar.MobList.DisableText(iName,uName,sName)
            end
        end
    end
    IROVar.MobList.CreateTree = function()
        IROVar.MobList.Tree = {}
        local ii=1
        for k,v in pairs(IROVar.MobListForInterrupt) do
            local subbnT={}
            local ii2=1
            for k2,v2 in pairs(v) do
                local sub3nt={}
                local ii3=1
                for k3,_ in pairs(v2) do
                    table.insert(sub3nt,{
                        value = ii3,
                        text = k3,
                        icon = 136197,
                        disabled = false,
                    })
                    ii3=ii3+1
                end
                table.insert(subbnT,{
                    value = ii2,
                    text = k2,
                    icon = 136224,
                    disabled = false,
                    children = sub3nt
                })
                ii2=ii2+1
            end
            table.insert(IROVar.MobList.Tree,{
                value = ii,
                text = k,
                disabled = false,
                children = subbnT
            })
            ii=ii+1
        end
        IROVar.MobList.KeyPointerToTree = {}
        for _,v in pairs(IROVar.MobList.Tree) do
            IROVar.MobList.KeyPointerToTree[v.text]={}
            IROVar.MobList.KeyPointerToTree[v.text].point=v
            for _,v2 in pairs(v.children) do
                IROVar.MobList.KeyPointerToTree[v.text][v2.text]={}
                IROVar.MobList.KeyPointerToTree[v.text][v2.text].point=v2
                for _,v3 in pairs(v2.children) do
                    IROVar.MobList.KeyPointerToTree[v.text][v2.text][v3.text]={}
                    IROVar.MobList.KeyPointerToTree[v.text][v2.text][v3.text].point=v3
                end
            end
        end
    end
    IROVar.MobList.UpdateTree = function()
        IROVar.MobList.TreeGroup:SetTree(IROVar.MobList.Tree)
    end
    IROVar.MobList.DisableText = function(iName,mName,sName)
        iName=iName or ""
        mName=mName or ""
        sName=sName or ""
        local change = false
        if IROVar.MobList.KeyPointerToTree[iName] then
            if not IROVar.MobList.KeyPointerToTree[iName].point.disabled then
                IROVar.MobList.KeyPointerToTree[iName].point.disabled=true
                change=true
            end
            if IROVar.MobList.KeyPointerToTree[iName][mName] then
                if not IROVar.MobList.KeyPointerToTree[iName][mName].point.disabled then
                    IROVar.MobList.KeyPointerToTree[iName][mName].point.disabled=true
                    change=true
                end
                if IROVar.MobList.KeyPointerToTree[iName][mName][sName] then
                    if not IROVar.MobList.KeyPointerToTree[iName][mName][sName].point.disabled then
                        IROVar.MobList.KeyPointerToTree[iName][mName][sName].point.disabled=true
                        change=true
                    end
                end
            end
        end
        if change then IROVar.MobList.UpdateTree() end
    end
end

if not IROVar.MobCannotStun then
    IROVar.MobCannotStun={}
    IROVar.MobCannotStun.DebugMode=false
    IROVar.MobCannotStun.Debug = function()
        IROVar.MobCannotStun.DebugMode=true
        IROVar.MobCannotStun.Frame=AceGUI:Create("Frame")
        IROVar.MobCannotStun.Frame:SetTitle("MobCannotStun")
        IROVar.MobCannotStun.Frame:SetLayout("Fill")
        IROVar.MobCannotStun.Frame:SetWidth(500)
        IROVar.MobCannotStun.Frame:SetHeight(600)
        IROVar.MobCannotStun.Frame:SetPoint("TOPLEFT","UIParent","TOPLEFT",30,-60)
        IROVar.MobCannotStun.Frame:SetCallback("OnClose", function(widget)
            IROVar.MobCannotStun.DebugMode=false
            AceGUI:Release(widget)
        end)
        IROVar.MobCannotStun.TreeGroup = AceGUI:Create("TreeGroup")
        if not IROVar.MobCannotStun.TreeGroupStatus then
            IROVar.MobCannotStun.TreeGroupStatus = { groups = {} }
            IROVar.MobCannotStun.TreeGroupStatus.treewidth=400
        end
        IROVar.MobCannotStun.TreeGroup:SetStatusTable(IROVar.MobCannotStun.TreeGroupStatus)
        IROVar.MobCannotStun.Frame:AddChild(IROVar.MobCannotStun.TreeGroup)
        if not IROVar.MobCannotStun.Tree then IROVar.MobCannotStun.CreateTree() end
        IROVar.MobCannotStun.TreeGroup:SetTree(IROVar.MobCannotStun.Tree)
        if not IROVar.MobCannotStun.fspec then
            IROVar.MobCannotStun.fspec = CreateFrame("Frame")
            IROVar.MobCannotStun.fspec:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            IROVar.MobCannotStun.fspec:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            IROVar.MobCannotStun.fspec:SetScript("OnEvent", IROVar.MobCannotStun.OnEvent)
        end
    end

    IROVar.MobCannotStun.OnEvent=function(_,event)
        if event ~="COMBAT_LOG_EVENT_UNFILTERED" then
            local iName = IROVar.InstanceName
            local uName = UnitName("target") or ""
            IROVar.MobCannotStun.DisableText(iName,uName)
        else
            local _,_,_,_,sourceName = CombatLogGetCurrentEventInfo()
            local iName=IROVar.InstanceName
            local uName=sourceName
            IROVar.MobCannotStun.DisableText(iName,uName)
        end
    end

    IROVar.MobCannotStun.CreateTree = function()
        IROVar.MobCannotStun.Tree = {}
        local ii=1
        for k,v in pairs(IROVar.cannotStun) do
            local subbnT={}
            local ii2=1
            for k2,v2 in pairs(v) do
                table.insert(subbnT,{
                    value = ii2,
                    text = k2,
                    icon = 136224,
                    disabled = false,
                })
                ii2=ii2+1
            end
            table.insert(IROVar.MobCannotStun.Tree,{
                value = ii,
                text = k,
                disabled = false,
                children = subbnT
            })
            ii=ii+1
        end
        IROVar.MobCannotStun.KeyPointerToTree = {}
        for _,v in pairs(IROVar.MobCannotStun.Tree) do
            IROVar.MobCannotStun.KeyPointerToTree[v.text]={}
            IROVar.MobCannotStun.KeyPointerToTree[v.text].point=v
            for _,v2 in pairs(v.children) do
                IROVar.MobCannotStun.KeyPointerToTree[v.text][v2.text]={}
                IROVar.MobCannotStun.KeyPointerToTree[v.text][v2.text].point=v2
            end
        end
    end

    IROVar.MobCannotStun.UpdateTree = function()
        IROVar.MobCannotStun.TreeGroup:SetTree(IROVar.MobCannotStun.Tree)
    end
    IROVar.MobCannotStun.DisableText = function(iName,mName)
        iName=iName or ""
        mName=mName or ""
        local change = false
        if IROVar.MobCannotStun.KeyPointerToTree[iName] then
            if not IROVar.MobCannotStun.KeyPointerToTree[iName].point.disabled then
                IROVar.MobCannotStun.KeyPointerToTree[iName].point.disabled=true
                change=true
            end
            if IROVar.MobCannotStun.KeyPointerToTree[iName][mName] then
                if not IROVar.MobCannotStun.KeyPointerToTree[iName][mName].point.disabled then
                    IROVar.MobCannotStun.KeyPointerToTree[iName][mName].point.disabled=true
                    change=true
                end
            end
        end
        if change then IROVar.MobCannotStun.UpdateTree() end
    end
end