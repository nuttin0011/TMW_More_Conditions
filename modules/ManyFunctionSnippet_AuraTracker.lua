-- Many Function Aura Tracker 10.0.0/1
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

-- Aura1 keep only Name , id
if not IROVar.Aura1 then IROVar.Aura1 = {} end

IROVar.Aura1.My={}
IROVar.Aura1.TrackedAura={}
--[[
    IROVar.Aura1.TrackedAura={
        ["aura Name"]=ExpTime,
        [auraID]=ExpTime,
    }
]]
function IROVar.Aura1.RegisterTrackedAura(list)
    if type(list)=="table" then
        for _,v in pairs(list) do
            IROVar.Aura1.TrackedAura[v]=true
        end
    else
        IROVar.Aura1.TrackedAura[list]=true
    end
end
function IROVar.Aura1.UnRegisterTrackedAura(list)
    if type(list)=="table" then
        for _,v in pairs(list) do
            IROVar.Aura1.TrackedAura[v]=nil
        end
    else
        IROVar.Aura1.TrackedAura[list]=nil
    end
end

function IROVar.Aura1.GetAura(n) -- return ExpTime , nil = no aura , 0 = no ExpTime
    return IROVar.Aura1.My[n]
end

--[[
name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
= UnitAura  (unit, index [, filter])
]]
function IROVar.Aura1.DumpAura(filter)
    IROVar.Aura1.My={}
    for i=1,100 do
        local name,_,_,_,_,expirationTime,_,_,_,spellId= UnitAura("player", i, filter)
        if not name then return end
        if IROVar.Aura1.TrackedAura[name] or IROVar.Aura1.TrackedAura[spellId] then
            IROVar.Aura1.My[name]=IROVar.Aura1.My[name] and math.min(expirationTime,IROVar.Aura1.My[name]) or expirationTime
            IROVar.Aura1.My[spellId]=IROVar.Aura1.My[spellId] and math.min(expirationTime,IROVar.Aura1.My[spellId]) or expirationTime
        end
    end
end
IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.Aura1.My",function(unit)
    if unit=="player" then IROVar.Aura1.DumpAura()end
end)

