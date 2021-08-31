-- Many Function Version Hunter 9.0.5/2
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Hun.TBreakDPSForBS() ; return Break Time for Shoot Barbed shot
--function IROVar.Hun.BreakDPSForBS() ; return True/false
--var IROVar.Hun.AimedShotActive ; true = cast Aimed Shoot + after success 0.4 GCD sec

if not IROVar then IROVar={} end
if not IROVar.Hun then IROVar.Hun={} end

IROVar.Hun.AimedShotActive=false

function IROVar.Hun.CombatLog_OnEvent()
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = CombatLogGetCurrentEventInfo()
    if (sourceGUID==IROVar.playerGUID) then
        if (subevent=="SPELL_CAST_START") and (spellName=="Aimed Shot") then
            IROVar.Hun.AimedShotActive=true
        end
        if (subevent=="SPELL_CAST_SUCCESS") and (spellName=="Aimed Shot") then
            C_Timer.After(GCDCDTime()*.4,function() IROVar.Hun.AimedShotActive=false end)
        end
        if (subevent=="SPELL_CAST_FAILED") and (spellName=="Aimed Shot") then
            IROVar.Hun.AimedShotActive=false
        end
    end
end
IROVar.Hun.CombatLog_Frame = CreateFrame("Frame")
IROVar.Hun.CombatLog_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Hun.CombatLog_Frame:SetScript("OnEvent", IROVar.Hun.CombatLog_OnEvent)

IROVar.Hun.incombatFrame = CreateFrame("Frame")
IROVar.Hun.incombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
--IROVar.Hun.incombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
IROVar.Hun.incombatFrame:SetScript("OnEvent", function(self, event)
    if event=="PLAYER_REGEN_ENABLED" then IROVar.Hun.AimedShotActive=false end
end)

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


