-- Many Function Version Mage 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Mage.registerCheckSpellSequence(sequence,timeout,timeout_after1stSpell|nil,callback,run_callback_when_timeout)
if not IROVar then IROVar={} end
if not IROVar.Mage then IROVar.Mage={} end

IROVar.Mage.playerGUID=UnitGUID("player")
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
            timeout_after1stSpell=5,
            callBack = function() TMW_ST:UpdateCounter("flurry",0) end,
            run_callback_when_timeout = true,
            canceled = false,
        },
    }
]]

function IROVar.Mage.CombatEvent()
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,spellName=CombatLogGetCurrentEventInfo()
    if (subevent~="SPELL_CAST_SUCCESS") or (sourceGUID~=IROVar.Mage.playerGUID) then return end
    local function destroySequence(se,finishSequence)
        se.canceled=true
        if finishSequence or se.run_callback_when_timeout then
            se.callBack()
        end
    end
    for k,v in pairs(IROVar.Mage.CastSequenceCheck) do
        if GetTime()>v.timeOut then
            destroySequence(v,false)
        end
        if v.spellName[v.checkOrder]==spellName then
            if (v.checkOrder==1)and v.timeout_after1stSpell then
                C_Timer.After(v.timeout_after1stSpell,IROVar.Mage.checkSequenceTimeOut)
                v.timeOut=GetTime()+v.timeout_after1stSpell
            end
            v.checkOrder=v.checkOrder+1
            if v.spellName[v.checkOrder]==nil then
                destroySequence(v,true)
            end
        end
        if IROVar.Mage.CastSequenceCheck[k].canceled then
            IROVar.Mage.CastSequenceCheck[k]=nil
        end
    end
end
IROVar.Mage.frame =CreateFrame("Frame")
IROVar.Mage.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Mage.frame:SetScript("OnEvent",IROVar.Mage.CombatEvent)

function IROVar.Mage.checkSequenceTimeOut()
    local currentTime=GetTime()+0.01
    for k,v in pairs(IROVar.Mage.CastSequenceCheck) do
        if currentTime>v.timeOut then
            if v.run_callback_when_timeout then v.callBack() end
            IROVar.Mage.CastSequenceCheck[k]=nil
        end
    end
end

function IROVar.Mage.registerCheckSpellSequence(sequence,timeout,timeout_after1stSpell,callback,run_callback_when_timeout)
    -- run callback function when all sequence casted
    -- or run when timeout when run_callback_when_timeout == true
    -- if timeout (s) ll destroy this sequence
    -- e.g.
    -- sequence = "Flurry|Ice Lance|Ice Lance" use | for split spell
    -- timeout = 5 (sec)
    -- callback = function() TMW_ST:UpdateCounter("flurry",0) end
    -- run_callback_when_timeout = true
    table.insert(IROVar.Mage.CastSequenceCheck,{
        spellName={strsplit("|",sequence)},
        checkOrder=1,
        timeOut=GetTime()+timeout,
        timeout_after1stSpell=timeout_after1stSpell,
        callBack=callback,
        run_callback_when_timeout=run_callback_when_timeout,
        canceled = false,
    })
    C_Timer.After(timeout,IROVar.Mage.checkSequenceTimeOut)
end
