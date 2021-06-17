-- Many Function Version Hunter 9.0.5/1a
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Hun.TBreakDPSForBS() ; return Break Time for Shoot Barbed shot
--function IROVar.Hun.BreakDPSForBS() ; return True/false

if not IROVar then IROVar={} end
if not IROVar.Hun then IROVar.Hun={} end

IROVar.Hun.cdBDPS={}
function IROVar.Hun.TBreakDPSForBS()
    local h=GetHaste()
    if IROVar.Hun.cdBDPS[h] then return IROVar.Hun.cdBDPS[h] end
    IROVar.Hun.cdBDPS[h]=.4+select(4,GetSpellInfo("Scare Beast"))*.0014 -- 0.4+(GCD*1.4)
    return IROVar.Hun.cdBDPS[h]
end

function IROVar.Hun.BreakDPSForBS()
    local d=TMW.CNDT.Env.AuraDur("player","thrill of the hunt","HELPFUL")
    local g=IROVar.Hun.TBreakDPSForBS()
    local b=TMW.CNDT.Env.CooldownDuration("barbed shot")
    return (d<=g)and(b<=d)
end