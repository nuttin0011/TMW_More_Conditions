-- Many Function Aura Tracker 10.0.0/5
-- Set Priority to 5

--function IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK(name,callback)
--function IROVar.Aura.UnRegister_UNIT_AURA_scrip_CALLBACK(name)

--Aura1 , Track only Name/ID/ExpTime ( if multiple aura use shortest ExpTime)
--function IROVar.Aura1.RegisterTrackedAura(list)
--function IROVar.Aura1.UnRegisterTrackedAura(list)
--function IROVar.Aura1.GetAura(n) -- return ExpTime , nil = no aura , 0 = no ExpTime
    -- or use IROVar.Aura1.My[n]

if not IROVar then IROVar = {} end
if not IROVar.Aura then IROVar.Aura = {} end

IROVar.Aura.CallBack={}
--[[ run order 1..n
    IROVar.Aura.CallBack = {
        [1] = {
            [1] = name,
            [2] = call back
        }..
    }
]]
IROVar.Aura.Frame=CreateFrame("Frame")
IROVar.Aura.Frame:RegisterEvent("UNIT_AURA")
IROVar.Aura.Frame:SetScript("OnEvent",function(_,_,...)
    for _,v in ipairs(IROVar.Aura.CallBack) do v[2](...)end
end)
function IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK(name,callback)
    table.insert(IROVar.Aura.CallBack,{name,callback})
end
function IROVar.Aura.UnRegister_UNIT_AURA_scrip_CALLBACK(name)
    for k,v in ipairs(IROVar.Aura.CallBack) do
        if v[1]==name then
            table.remove(IROVar.Aura.CallBack,k)
        end
    end
end
-- Aura1 At Player keep only Name , id
if not IROVar.Aura1 then IROVar.Aura1 = {} end

IROVar.Aura1.My={}
IROVar.Aura1.TrackedAura={}
IROVar.Aura1.Changed={} -- true = Changed from last IROVar.Aura1.DumpAura()
--[[    IROVar.Aura1.TrackedAura={
        ["aura Name"]=ExpTime,
        [auraID]=ExpTime,
    }
]]
local function RegisterTracked(list,table)
    if type(list)=="table" then
        for _,v in pairs(list) do
            table[v]=true
        end
    else
        table[list]=true
    end
end
local function UnRegisterTracked(list,table)
    if type(list)=="table" then
        for _,v in pairs(list) do
            table[v]=nil
        end
    else
        table[list]=nil
    end
end
function IROVar.Aura1.RegisterTrackedAura(list)
    RegisterTracked(list,IROVar.Aura1.TrackedAura)
end
function IROVar.Aura1.UnRegisterTrackedAura(list)
    UnRegisterTracked(list,IROVar.Aura1.TrackedAura)
end

function IROVar.Aura1.GetAura(n) -- return ExpTime , nil = no aura , 0 = no ExpTime
    return IROVar.Aura1.My[n]
end
--[[
name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
= UnitAura  (unit, index [, filter])
]]

function IROVar.Aura1.DumpAura()
    local function addAuraToTable(n,e,s)
        if IROVar.Aura1.TrackedAura[n] then
            IROVar.Aura1.My[n]=IROVar.Aura1.My[n] and math.min(e,IROVar.Aura1.My[n]) or e
            IROVar.Aura1.Changed[n]=true
        elseif IROVar.Aura1.TrackedAura[s] then
            IROVar.Aura1.My[s]=IROVar.Aura1.My[s] and math.min(e,IROVar.Aura1.My[s]) or e
            IROVar.Aura1.Changed[s]=true
        end
    end
    local OldAura=IROVar.Aura1.My
    IROVar.Aura1.My={}
    IROVar.Aura1.Changed={}
    local name,exp,spellId
    for i=1,40 do
        name,_,_,_,_,exp,_,_,_,spellId= UnitBuff("player",i)
        if not name then break end
        addAuraToTable(name,exp,spellId)
    end
    for i=1,40 do
        name,_,_,_,_,exp,_,_,_,spellId= UnitDebuff("player",i)
        if not name then break end
        addAuraToTable(name,exp,spellId)
    end
    for k,v in pairs(OldAura) do
        IROVar.Aura1.Changed[k]=not(v==IROVar.Aura1.My[k])
    end
    --print("Dump At :",GetTime())
end
IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.Aura1.My",function(unit)
    if unit=="player" then IROVar.Aura1.DumpAura()end
end)
C_Timer.After(2,function() -- Init Dump Aura
    for _,v in ipairs(IROVar.Aura.CallBack) do v[2]("player")end
end)

-- Aura2 At Target keep only Name , id
--[[
if not IROVar.Aura2 then IROVar.Aura2 = {} end
IROVar.Aura2.My={}
IROVar.Aura2.TrackedAura={}
IROVar.Aura2.Changed={}
]]