-- Many Function Version Warlock2 10.0.0/1
-- Set Priority to 10
-- this file save many function for paste to TMW Snippet LUA

-- counter "pausedps" pause DPS for Drain Soul/Drain Life ; 0=DPS normaly, 1=Pause DPS
--function IROVar.Lock.ChannelPluseDPS()
--function IROVar.Lock.SoulLeechPercen()


if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end


-- Counter Pause DPS for Drain Soul/ Drain Life
--[[
UNIT_SPELLCAST_CHANNEL_START "player" nil spellID
UNIT_SPELLCAST_CHANNEL_STOP
198590 Drain Soul
234153 Drain Life
]]

IROVar.Lock.ChannelStep={0,0,0,0,0,0,0,math.huge}
IROVar.Lock.ChannelHandle=nil

TMW_ST:AddEvent("UNIT_SPELLCAST_CHANNEL_START",
function(EventName,unit,arg3,spellID)
    if unit~="player" then return end
    if spellID~=198590 and spellID~=234153 then return end
    local _,_,_,startTime,endTime,_,_,spellId = UnitChannelInfo("player")
    startTime=startTime/1000
    endTime=endTime/1000
    local du=endTime-startTime-0.2
    local tick=du/5
    local _5=IROVar.CastTime0_5sec
    IROVar.Lock.ChannelStep[1]=startTime+tick+tick
    IROVar.Lock.ChannelStep[2]=IROVar.Lock.ChannelStep[1]+_5
    IROVar.Lock.ChannelStep[3]=IROVar.Lock.ChannelStep[1]+tick
    IROVar.Lock.ChannelStep[4]=IROVar.Lock.ChannelStep[3]+_5
    IROVar.Lock.ChannelStep[5]=IROVar.Lock.ChannelStep[3]+tick
    IROVar.Lock.ChannelStep[6]=IROVar.Lock.ChannelStep[5]+_5
    IROVar.Lock.ChannelStep[7]=IROVar.Lock.ChannelStep[5]+tick
    IROVar.Lock.ChannelStep[8]=math.huge
    if du<IROVar.CastTime2sec*2 then--[Nightfall]
        --print("[Nightfall]")
        IROVar.Lock.ChannelStep[1]=IROVar.Lock.ChannelStep[7]
    end
end)
TMW_ST:AddEvent("UNIT_SPELLCAST_CHANNEL_STOP",
function()
    IROVar.Lock.ChannelStep={0,0,0,0,0,0,0,math.huge}
end)
-- Channeling
-- start time st , pause
-- duration du-0.2
-- n tick = n*(du-0.2)/5
-- [1] 2nd tick , DPS
-- [2] 2nd tick + IROVar.CastTime0_5sec , pause
-- [3] 3rd tick , DPS
-- [4] 3nd tick + IROVar.CastTime0_5sec , pause
-- [5] 4th tick , DPS
-- [6] 4th tick + IROVar.CastTime0_5sec , pause
-- [7] 5th tick , DPS

function IROVar.Lock.ChannelPluseDPS() -- false = dont DPS
    local cTime=GetTime()
    local dps=false
    for i=1,7 do
        if cTime<IROVar.Lock.ChannelStep[i] then break end
        dps=not dps
    end
    return dps
end

IROVar.Lock.soulLeechPercen=0

function IROVar.Lock.UpdateSoulLeech()
    local SoulLeech=select(16,AuraUtil.FindAuraByName("Soul Leech","player","HELPFUL PLAYER")) or 0
    IROVar.Lock.soulLeechPercen=SoulLeech/UnitHealthMax("player")*100
end

C_Timer.After(2,IROVar.Lock.UpdateSoulLeech)

TMW_ST:AddEvent("UNIT_AURA",
function(event,unit)
    if unit~="player" then return end
    IROVar.Lock.UpdateSoulLeech()
end)

function IROVar.Lock.SoulLeechPercen()
    return IROVar.Lock.soulLeechPercen
end