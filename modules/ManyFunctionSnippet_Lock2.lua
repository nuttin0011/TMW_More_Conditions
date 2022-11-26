-- Many Function Version Warlock2 10.0.0/1
-- Set Priority to 10
-- this file save many function for paste to TMW Snippet LUA

-- counter "pausedps" pause DPS for Drain Soul/Drain Life ; 0=DPS normaly, 1=Pause DPS



if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end





-- Counter Pause DPS for Drain Soul/ Drain Life
--[[
UNIT_SPELLCAST_CHANNEL_START "player" nil spellID
UNIT_SPELLCAST_CHANNEL_STOP
198590 Drain Soul
234153 Drain Life
]]


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

function IROVar.Lock.SetupChannelPluseDPS()
    
end
