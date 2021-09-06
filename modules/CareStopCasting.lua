-- Care Stop Casting 1.0 Icon
-- Stop Cast when Mob Cast Interrupt Spell e.g. "Interrupting Roar", "Quake"

-- IROVar.CSC.HasInterrupting(1.5) -- Interrupting come in 1.5 sec should stop cast/use only instance skill
-- IROVar.CSC.PlayerShouldStopCasting() -- should /stopcasting


if not IROVar then IROVar={} end
if not IROVar.CSC then
    IROVar.CSC={}
    IROVar.CSC.PlayerHitedTime={0}
    IROVar.CSC.playerShouldStopCast=false
    IROVar.CSC.TimeStopcast=0.2
    --[spell id/ spell name]= 1(stop cast is enough),2(must CD e.g. "Unending Resolve")
    IROVar.CSC.InterruptSpellCast ={
        [342135]=1,--["Interrupting Roar"]=1,
        [339415]=1,--["Deafening Crash"]=1,
        [335495]=2,--["Severing Roar"]=2,
    }

    IROVar.CSC.DebuffAtPlayer ={
        [240447]=1,--["Quake"]=1,
    }

    IROVar.CSC.BuffAtPlayer ={
        --none ???
    }

    function IROVar.CSC.HasInterrupting(t)
        t=t or math.huge
        local currentTime=GetTime()
        for i=1,table.getn(IROVar.CSC.PlayerHitedTime) do
            if IROVar.CSC.PlayerHitedTime[i]>currentTime and
            IROVar.CSC.PlayerHitedTime[i]<=t+currentTime then
                return true
            end
        end
    end

    function IROVar.CSC.PlayerShouldStopCasting()
        return IROVar.CSC.playerShouldStopCast
    end

    function IROVar.CSC.CheckPlayerCasting()
        local _,_,_,_,endTimeMS = UnitCastingInfo("player")
        if not endTimeMS then
            _,_,_,_,endTimeMS  = UnitChannelInfo("player")
        end
        if endTimeMS then
            local currentTime=GetTime()
            endTimeMS=(endTimeMS/1000)+IROVar.CSC.TimeStopcast
            for i=1,table.getn(IROVar.CSC.PlayerHitedTime) do
                if endTimeMS>IROVar.CSC.PlayerHitedTime[i] then
                    IROVar.CSC.playerShouldStopCast=true
                    break
                end
            end
        end
    end

    function IROVar.CSC.AddPlayerHitedTime(t)
        local currentTime=GetTime()
        local added=false
        for i=1,table.getn(IROVar.CSC.PlayerHitedTime)do
            if IROVar.CSC.PlayerHitedTime[i]<currentTime then
                IROVar.CSC.PlayerHitedTime[i]=t
                added=true
                break
            end
        end
        if not added then
            table.insert(IROVar.CSC.PlayerHitedTime,t)
        end
        IROVar.CSC.CheckPlayerCasting()
    end

    function IROVar.CSC.COMBAT_LOG_EVENT_UNFILTERED_OnEvent()
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,spellId, spellName, spellSchool, amount,
        overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
        = CombatLogGetCurrentEventInfo()
        if (subevent=="SPELL_AURA_APPLIED")and(destGUID==IROVar.playerGUID) then
            if IROVar.CSC.DebuffAtPlayer[spellId] then
                IROVar.CSC.AddPlayerHitedTime(select(3,TMW.CNDT.Env.AuraDur("player",spellId,"harm")))
            end
            if IROVar.CSC.BuffAtPlayer[spellId] then
                IROVar.CSC.AddPlayerHitedTime(select(3,TMW.CNDT.Env.AuraDur("player",spellId)))
            end
        end
    end
    IROVar.CSC.fcombat = CreateFrame("Frame")
    IROVar.CSC.fcombat:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    IROVar.CSC.fcombat:SetScript("OnEvent", IROVar.CSC.COMBAT_LOG_EVENT_UNFILTERED_OnEvent)

    function IROVar.CSC.CAST_START_OnEvent(self,event,arg1,arg2,arg3)
        if event=="NAME_PLATE_UNIT_ADDED" and
        UnitCanAttack("player", arg1) then
            local _,_,_,_,endTimeMS,_,_,_,spellId = UnitCastingInfo(arg1)
            if not endTimeMS then
                _,_,_,_,endTimeMS,_,_,spellId  = UnitChannelInfo(arg1)
            end
            if endTimeMS and IROVar.CSC.InterruptSpellCast[spellId] then
                IROVar.CSC.AddPlayerHitedTime(endTimeMS/1000)
            end
        end
        if (event=="UNIT_SPELLCAST_START" or event=="UNIT_SPELLCAST_CHANNEL_START") and
        UnitCanAttack("player", arg1) and
        IROVar.CSC.InterruptSpellCast[arg3] then
            local _,_,_,_,endTimeMS,_,_,_,spellId = UnitCastingInfo(arg1)
            if not endTimeMS then
                _,_,_,_,endTimeMS,_,_,spellId  = UnitChannelInfo(arg1)
            end
            if endTimeMS then
                IROVar.CSC.AddPlayerHitedTime(endTimeMS/1000)
            end
        end
        if (event=="UNIT_SPELLCAST_START" or event=="UNIT_SPELLCAST_CHANNEL_START") and
        arg1=="player" and IROVar.CSC.HasInterrupting() then
            IROVar.CSC.CheckPlayerCasting()
        end
        if (event=="UNIT_SPELLCAST_STOP" or event=="UNIT_SPELLCAST_CHANNEL_STOP") and
        arg1=="player" then
            IROVar.CSC.playerShouldStopCast=false
        end
    end
    IROVar.CSC.fcast = CreateFrame("Frame")
    IROVar.CSC.fcast:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    IROVar.CSC.fcast:RegisterEvent("UNIT_SPELLCAST_START")
    IROVar.CSC.fcast:RegisterEvent("UNIT_SPELLCAST_STOP")
    IROVar.CSC.fcast:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    IROVar.CSC.fcast:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    IROVar.CSC.fcast:SetScript("OnEvent", IROVar.CSC.CAST_START_OnEvent)
end