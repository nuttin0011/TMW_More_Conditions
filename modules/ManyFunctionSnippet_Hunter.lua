-- Many Function Version Hunter 9.2.5/3
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Hun.TBreakDPSForBS() ; return Break Time for Shoot Barbed shot
--function IROVar.Hun.BreakDPSForBS() ; return True/false
--var IROVar.Hun.AimedShotActive ; true = cast Aimed Shoot + after success 0.4 GCD sec

if not IROVar then IROVar={} end
if not IROVar.Hun then IROVar.Hun={} end

IROVar.Hun.AimedShotActive=false

local function CDend(s)
	local st,du=GetSpellCooldown(s)
	if st then
		return st+du
	else return 0 end
end

IROVar.Hun.TotHBuffEnd=0 --Thrill of the Hunt buff end time
IROVar.Hun.BarbedCDEnd=CDend("barbed shot") --Barbed shot CD end time


function IROVar.Hun.CombatLog_OnEvent(...)
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = ...
    if sourceGUID~=IROVar.playerGUID then return end
    if IROSpecID==254 then -- MM
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
    if IROSpecID==253 then -- BM
        if spellID==257946 then --Thrill of the Hunt
            if subevent=="SPELL_AURA_APPLIED" then
                IROVar.Hun.TotHBuffEnd=GetTime()+8
            end
            if subevent=="SPELL_AURA_APPLIED_DOSE" then
                IROVar.Hun.TotHBuffEnd=GetTime()+8
            end
            if subevent=="SPELL_AURA_REMOVED" then
                IROVar.Hun.TotHBuffEnd=0
            end
        end

    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Hun",IROVar.Hun.CombatLog_OnEvent)

IROVar.RegisterOutcombatCallBackRun("Hun",function(self, event)
    if event=="PLAYER_REGEN_ENABLED" then IROVar.Hun.AimedShotActive=false end
end)

IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("Hun",function(GCDCDEnd)
    local CDEnd=CDend("barbed shot")
    if CDEnd<=GCDCDEnd then CDEnd=0 end
    IROVar.Hun.BarbedCDEnd=CDEnd
end)

IROVar.Hun.cdBDPS={}
function IROVar.Hun.TBreakDPSForBS()
    local h=IROVar.Haste
    if IROVar.Hun.cdBDPS[h] then return IROVar.Hun.cdBDPS[h] end
    IROVar.Hun.cdBDPS[h]=.4+IROVar.CastTime1_5sec*1.1 -- 0.4+(GCD*1.1)
    return IROVar.Hun.cdBDPS[h]
end

function IROVar.Hun.GetTotHDur()
    if IROVar.Hun.TotHBuffEnd==0 then return 0 end
    local t=IROVar.Hun.TotHBuffEnd-GetTime()
    if t<0 then t=0 end
    return t
end

function IROVar.Hun.GetBarbedCDRemain()
    if IROVar.Hun.BarbedCDEnd==0 then return 0 end
    local t=IROVar.Hun.BarbedCDEnd-GetTime()
    if t<0 then t=0 end
    return t
end

function IROVar.Hun.BreakDPSForBS()
    local d=IROVar.Hun.GetTotHDur()
    local g=IROVar.Hun.TBreakDPSForBS()
    local b=IROVar.Hun.GetBarbedCDRemain()
    return (d<=g)and(b<=d)
end


