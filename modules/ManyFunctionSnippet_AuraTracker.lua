-- Many Function Aura Tracker 10.0.0/7
-- Set Priority to 5

--function IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK(name,callback)
--function IROVar.Aura.UnRegister_UNIT_AURA_scrip_CALLBACK(name)

--Aura1 , Track Player Name/ID/ExpTime/stack ( if multiple aura use shortest ExpTime)
--function IROVar.Aura1.RegisterTrackedAura(list)
--function IROVar.Aura1.UnRegisterTrackedAura(list)
--function IROVar.Aura1.GetAura(n) -- return ExpTime , nil = no aura , 0 = no ExpTime
    -- or use IROVar.Aura1.My[n]
--function IROVar.Aura1.GetAuraStack(n)

-- Aura2 At Target keep only Name , id
--function IROVar.Aura2.RegisterTrackedAura(aura,filter)
--function IROVar.Aura2.UnRegisterTrackedAura(aura,filter)
--function IROVar.Aura2.GetAura(auraName,filter)

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
IROVar.Aura1.Stack={} -- keep Stack of aura
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

function IROVar.Aura1.GetAuraStack(n)
    return IROVar.Aura1.Stack[n]
end
--[[
name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
= UnitAura  (unit, index [, filter])
]]

function IROVar.Aura1.DumpAura()
    local function addAuraToTable(n,e,s,c)
        if IROVar.Aura1.TrackedAura[n] then
            if not IROVar.Aura1.My[n] then
                IROVar.Aura1.My[n]=e
                IROVar.Aura1.Stack[n]=c
            else
                if e<IROVar.Aura1.My[n] then
                    IROVar.Aura1.My[n]=e
                    IROVar.Aura1.Stack[n]=c
                end
            end
            IROVar.Aura1.Changed[n]=true
        end
        if IROVar.Aura1.TrackedAura[s] then
            if not IROVar.Aura1.My[s] then
                IROVar.Aura1.My[s]=e
                IROVar.Aura1.Stack[s]=c
            else
                if e<IROVar.Aura1.My[s] then
                    IROVar.Aura1.My[s]=e
                    IROVar.Aura1.Stack[s]=c
                end
            end
            IROVar.Aura1.Changed[s]=true
        end
    end
    local OldAura=IROVar.Aura1.My
    IROVar.Aura1.My={}
    IROVar.Aura1.Changed={}
    IROVar.Aura1.Stack={}
    local name,exp,spellId,count
    for i=1,40 do
        name,_,count,_,_,exp,_,_,_,spellId= UnitBuff("player",i)
        if not name then break end
        addAuraToTable(name,exp,spellId,count)
    end
    for i=1,40 do
        name,_,count,_,_,exp,_,_,_,spellId= UnitDebuff("player",i)
        if not name then break end
        addAuraToTable(name,exp,spellId,count)
    end
    for k,v in pairs(OldAura) do
        IROVar.Aura1.Changed[k]=v~=IROVar.Aura1.My[k]
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

if not IROVar.Aura2 then IROVar.Aura2 = {} end
IROVar.Aura2.tar={}
IROVar.Aura2.TrackedAura={}
IROVar.Aura2.Changed={}

--[[    IROVar.Aura2.TrackedAura={
        ["filter"]={
            ["aura Name"]=ExpTime,
            [auraID]=ExpTime,
        }
    }
]]

local function RegisterTracked2(aura,table,filter)
    if not table[filter] then table[filter]={} end
    table[filter][aura]=true
end
local function UnRegisterTracked2(aura,table,filter)
    table[filter][aura]=nil
    if next(table[filter])==nil then table[filter]=nil end
end

function IROVar.Aura2.RegisterTrackedAura(aura,filter)
    RegisterTracked2(aura,IROVar.Aura2.TrackedAura,filter)
end

function IROVar.Aura2.UnRegisterTrackedAura(aura,filter)
    UnRegisterTracked2(aura,IROVar.Aura2.TrackedAura,filter)
end

function IROVar.Aura2.DumpAura()
    local OldAura=IROVar.Aura2.tar
    IROVar.Aura2.Changed={}
    IROVar.Aura2.tar={}
    local name,exp,spellId,i
    for filter,aur in pairs(IROVar.Aura2.TrackedAura) do
        IROVar.Aura2.tar[filter]={}
        IROVar.Aura2.Changed[filter]={}
        i=1
        name,_,_,_,_,exp,_,_,_,spellId=UnitAura("target",i,filter)
        while name do
            if aur[name]and(not IROVar.Aura2.tar[filter][name] or IROVar.Aura2.tar[filter][name]>exp)then
                IROVar.Aura2.tar[filter][name]=exp
                IROVar.Aura2.Changed[filter][name]=true
            end
            if aur[spellId]and(not IROVar.Aura2.tar[filter][spellId] or IROVar.Aura2.tar[filter][spellId]>exp) then
                IROVar.Aura2.tar[filter][spellId]=exp
                IROVar.Aura2.Changed[filter][spellId]=true
            end
            i=i+1
            name,_,_,_,_,exp,_,_,_,spellId=UnitAura("target",i,filter)
        end
    end
    for filter,SetAur in pairs(OldAura) do
        for aur,ex in pairs(SetAur) do
            IROVar.Aura2.Changed[filter][aur]=ex~=IROVar.Aura2.tar[filter][aur]
        end
    end
end

function IROVar.Aura2.GetAura(n,f)
    return IROVar.Aura2.tar[f][n]
end

IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.Aura2.tar",function(unit)
    if unit=="target" then IROVar.Aura2.DumpAura()end
end)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("IROVar.Aura2.tar",IROVar.Aura2.DumpAura)
C_Timer.After(2.1,function() -- Init Dump Aura
    for _,v in ipairs(IROVar.Aura.CallBack) do v[2]("target")end
end)