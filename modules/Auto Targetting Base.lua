-- Auto Target Base Version 1.1
-- Set Priority to 10

if not IROVar then IROVar={} end
if not IROVar.AutoTarget then IROVar.AutoTarget={} end
local AT=IROVar.AutoTarget

AT.Unit={}
--AT.Unit[UnitToken].Name=Name
--AT.Unit[UnitToken].Range=Range
AT.UnitCount={}
--AT.UnitCount[UnitName]=Count

--IROVar.AutoTarget.UnitCount
AT.RegisterMacro = {}
--[[
    --key 12 = "3d" = "NUMPADMULTIPLY"
AT.RegisterMacro = {}
AT.RegisterMacro["interrupt"] =
{
    MacroName = "~!Num12",
    Max = 6,
    IROCode = {
        [1] = {"ff033d03","[mod:ctrlalt]"}
        [2] = {"ff053d05","[mod:ctrlshift]"}
        [3] = {"ff013d01","[mod:ctrl]"}
        [4] = {"ff023d02","[mod:alt]"}
        [5] = {"ff043d04","[mod:shift]"}
        [6] = {"ff003d00","[nomod]"}
    },
    Command = "/cast Counter Shot"
    Suffix = "/run IUSC.SU('3d')"
    MobName={
        "Mob Name1" = 1;
        "Mob Name2" = 2;
    }
}
]]

--[[AT.MobSet=
    ["GroupName1"] = {"MobName1","MobName2","MobName3",...},
    ["GroupName2"] = {"MobName1","MobName2","MobName3",...},
    ...
]]
AT.MobSet={
    ["Default_M_Group"]={
        "Urh Dismantler",
    },
}
--[[AT.MobAddon=
    ["NameDungeon"]={
        ["MobNameDetected"]={"GroupName1","GroupName2","GroupName3",...},...
        ...
    },
    ...
]]
AT.MobAddon={
    ["All_Dungeon"]={
        ["All_Mob"]={"Default_M_Group",},
    }
}

AT.IncombatLock = false
AT.Enable=false
AT.CreateMacroDone = false
AT.EventFrame=CreateFrame("Frame")
AT.EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
AT.EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
AT.EventFrame:SetScript("OnEvent",function(self,event,arg1,...)
    if not IROVar.AutoTarget.Enable then return end
    if event=="NAME_PLATE_UNIT_ADDED" and UnitCanAttack("player",arg1) then
        local name = UnitName(arg1)
        if name then
            IROVar.AutoTarget.Unit[arg1]={}
            IROVar.AutoTarget.Unit[arg1].Name=name
            IROVar.AutoTarget.UnitCount[name]=(IROVar.AutoTarget.UnitCount[name] or 0)+1
        end
    elseif event=="NAME_PLATE_UNIT_REMOVED" then
        if IROVar.AutoTarget.Unit[arg1] then
            local name = IROVar.AutoTarget.Unit[arg1].Name
            IROVar.AutoTarget.UnitCount[name]=(IROVar.AutoTarget.UnitCount[name] or 1)-1
            IROVar.AutoTarget.Unit[arg1]=nil
        end
    end
end)

function AT.RefreshUnit()
    AT.Unit={}
    AT.UnitCount={}
    for i=1,40 do
        local n="nameplate"..i
        if UnitExists(n) and UnitCanAttack("player",n) then
            local name = UnitName(n)
            if name then
                AT.Unit[n]={}
                AT.Unit[n].Name=name
                AT.UnitCount[name]=(AT.UnitCount[name] or 0)+1
            end
        end
    end
end

IROVar.RegisterIncombatCallBackRun("AutoTarget1",function()
    if not IROVar.AutoTarget.Enable then return end
    IROVar.AutoTarget.IncombatLock=true
end)
IROVar.RegisterOutcombatCallBackRun("AutoTarget1",function()
    if not IROVar.AutoTarget.Enable then return end
    IROVar.AutoTarget.IncombatLock=false
    IROVar.AutoTarget.RefreshUnit()
end)

function AT.UpdateRange()
    for k,v in pairs(AT.Unit) do
        if UnitExists(k) then
            v.Range=IROVar.Range(k)
        else
            AT.Unit[k]=nil
        end
    end
end

function AT.SortByRange() -- return table {[UnitToken]=Range,[UnitToken]=Range,...}
    local t={}
    for k,v in pairs(AT.Unit) do
        t[#t+1]={k,v.Name,v.Range}
    end
    table.sort(t,function(a,b) return a[3]<b[3] end)
    --delete duplicate Name
    local duplicate={}
    local i=1
    while i<=#t do
        if duplicate[t[i][2]] then
            table.remove(t,i)
        else
            duplicate[t[i][2]]=true
            i=i+1
        end
    end
    return t
end

--[[
function create macro
"/target [mod:ctrlalt]name1;[mod:ctrlshift]name2;[mod:ctrl]name3;[mod:alt]name4;[mod:shift]name5;[nomod]name6
/cast Counter Shot
/targetlasttarget"
if #MobName > # IROCode it ll choose nearest mob
function GetIROCodeByMobName(MobName,MacroName)
    return IROCode that match MobName
end
]]

function AT.PushUnitToMacro(forcedUpdate)
    if InCombatLockdown() then return end
    AT.CreateMacroDone = false
    AT.UpdateRange()
    local Unit=AT.SortByRange()
    for k,v in pairs(AT.RegisterMacro) do
        local newMobName={}
        local MaxN=math.min(v.Max,#Unit,6)
        for i=1,MaxN do
            newMobName[Unit[i][2]]=i
        end
        if forcedUpdate or (IROVar.EditKeyMacroForAutoTarget>0) or (not IROVar.CompareTable(v.MobName,newMobName)) then
            v.MobName=newMobName
            local MacroName=v.MacroName
            local Text1="/target "
            local Text2="\n"..v.Command
            local Text3="\n/targetlasttarget"
            local Text4="\n"..v.Suffix
            for i=1,MaxN do
                Text1=Text1..v.IROCode[i][2]..Unit[i][2]..";"
            end
            local MacroBody=Text1..Text2..Text3..Text4
            local _,macroIcon=GetMacroInfo(MacroName)
            EditMacro(MacroName,MacroName,macroIcon,MacroBody)
        end
    end
    IROVar.EditKeyMacroForAutoTarget=IROVar.EditKeyMacroForAutoTarget-1
    AT.CreateMacroDone = true
end

C_Timer.NewTicker(0.52,function()
    if not IROVar.AutoTarget.Enable then return end
    if InCombatLockdown() then return end
    IROVar.AutoTarget.PushUnitToMacro()
end)

AT.TickerHandle=C_Timer.NewTicker(0.2,function()
    if UnitExists("nameplate1") then
        local name=UnitName("nameplate1")
        if (name~=nil)and(name~="Unknown")then
            IROVar.AutoTarget.TickerHandle:Cancel()
            IROVar.AutoTarget.Enable=true
            IROVar.AutoTarget.RefreshUnit()
        end
    end
end)



function AT.GetIROCode(SetName,MobName)
    if (not SetName)or(not SetName)or(not AT.RegisterMacro[SetName])then return "ff000000" end
    if not AT.RegisterMacro[SetName].MobName[MobName] then return "ff000000" end
    return AT.RegisterMacro[SetName].IROCode[AT.RegisterMacro[SetName].MobName[MobName]][1] or "ff000000"
end

function AT.CanSelect(SetName,UnitToken)
    if not AT.Enable then return false end
    local name=UnitName(UnitToken)
    if not name
    or UnitIsUnit("target",UnitToken)
    or not AT.RegisterMacro[SetName]
    or not AT.RegisterMacro[SetName].MobName[name] then return false end
    if (AT.UnitCount[name] or 0)<=1 then return true end
    local UnitRange=IROVar.Range(UnitToken)
    for k,v in pairs(AT.Unit) do
        if (v.Name==name)and(not UnitIsUnit(k,UnitToken))and(UnitRange>=IROVar.Range(k))then
            return false
        end
    end
    return true
end
