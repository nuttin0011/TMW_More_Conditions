



if not IROVar then IROVar={} end
if not IROVar.AutoTarget then IROVar.AutoTarget={} end
local AT=IROVar.AutoTarget

AT.Unit={}

--AT.Unit[UnitToken].Name=Name
--AT.Unit[UnitToken].Range=Range

--IROVar.AutoTarget.Unit


AT.IncombatLock = false
AT.CreateMacroDone = false
AT.MobName = {
    --[1]="Mob Name1",
    --[2]="Mob Name2", ...
    --lock mob name when in combat
}
AT.EventFrame=CreateFrame("Frame")
AT.EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
AT.EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
AT.EventFrame:SetScript("OnEvent",function(self,event,arg1,...)
    if event=="NAME_PLATE_UNIT_ADDED" and UnitCanAttack("player",arg1) then
        local name = UnitName(arg1)
        if name then
            AT.Unit={}
            AT.Unit[arg1].Name=name
        end
    elseif event=="NAME_PLATE_UNIT_REMOVED" then
        AT.Unit[arg1]=nil
    end
end)

function AT.RefreshUnit()
    AT.Unit={}
    for i=1,40 do
        local n="nameplate"..i
        if UnitExists(n) and UnitCanAttack("player",n) then
            local name = UnitName(n)
            if name then
                AT.Unit[n].Name=name
            end
        end
    end
end

IROVar.RegisterIncombatCallBackRun("AutoTarget1",function()
    AT.IncombatLock=true
end)
IROVar.RegisterOutcombatCallBackRun("AutoTarget1",function()
    AT.IncombatLock=false
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
        t[#t+1]={k,v.Range}
    end
    table.sort(t,function(a,b) return a[2]<b[2] end)
    return t
end

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
}

function create macro
"
/target [mod:ctrlalt]name1;[mod:ctrlshift]name2;[mod:ctrl]name3;[mod:alt]name4;[mod:shift]name5;[nomod]name6
/cast Counter Shot
/targetlasttarget
"
if #MobName > # IROCode it ll choose nearest mob

function GetIROCodeByMobName(MobName,MacroName)
    return IROCode that match MobName
end


]]





