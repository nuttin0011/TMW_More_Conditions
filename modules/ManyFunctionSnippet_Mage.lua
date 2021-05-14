

if not IROVar then IROVar={} end
if not IROVar.Mage then IROVar.Mage={} end

IROVar.Mage.CastSequenceCheck={}
--[[
    CastSequenceCheck = {
        [1] = {
            spellName = {
                [1]="Flurry",
                [2]="Ice Lance",
                [3]="Ice Lance"
            },
            checkOrder = 1,
            timeOut = 65004.25,
            callBack = function() TMW_ST:UpdateCounter("flurry",0) end,
            run_callback_when_timeout = true,
        },
    }
]]

function IROVar.Mage.CombatEvent()
    
end

IROVar.Mage.frame =CreateFrame("Frame")
IROVar.Mage.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Mage.frame:SetScript("OnEvent",IROVar.Mage.CombatEvent)


function IROVar.Mage.registerCheckSpellSequence(sequence,timeout,callback,run_callback_when_timeout)
    -- run callback function when all sequence casted
    -- or run when timeout when run_callback_when_timeout == true
    -- if timeout (s) ll destroy this sequence
    -- e.g.
    -- sequence = "Flurry|Ice Lance|Ice Lance" use | for split spell
    -- timeout = 5 (sec)
    -- callback = function() TMW_ST:UpdateCounter("flurry",0) end
    -- run_callback_when_timeout = true
end