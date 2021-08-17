-- Care Stop Casting 1.0 Icon
-- Stop Cast when Mob Cast Interrupt Spell e.g. "Interrupting Roar", "Quake"

if not IROVar then IROVar={} end
if not IROVar.CSC then
    IROVar.CSC={}
    --[spell id/ spell name]= 1(stop cast is enough),2(must CD e.g. "Unending Resolve")
    IROVar.CSC.InterruptSpellCast ={
        [242135]=1,--["Interrupting Roar"]=1,
        [339415]=1,--["Deafening Crash"]=1,
        [335495]=2,--["Severing Roar"]=2,
    }

    IROVar.CSC.DebuffAtPlayer ={
        [240447]=1,--["Quake"]=1,
    }

    IROVar.CSC.COMBAT_LOG_EVENT_UNFILTERED_OnEvent = function()

        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,spellId, spellName, spellSchool, amount,
        overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
        = CombatLogGetCurrentEventInfo()
        --if sourceGUID~=IROVar.playerGUID then return end

        if (subevent=="SPELL_CAST_START") and IROVar.CSC.InterruptSpellCast[spellId] then
            print ("ENEMY CAST INTERRUPT SPELL ----------++++++")
        end

        if (subevent=="SPELL_CAST_SUCCESS") and IROVar.CSC.InterruptSpellCast[spellId] then
            print ("ENEMY CAST INTERRUPT SPELL SUCCESS ::::----------++++++")
        end

        if (subevent=="SPELL_CAST_FAILED") and IROVar.CSC.InterruptSpellCast[spellId] then
            print ("ENEMY CAST INTERRUPT SPELL FAILED ////----------++++++")
        end

        if (subevent=="SPELL_AURA_APPLIED") and IROVar.CSC.DebuffAtPlayer[spellId] then
            print ("Player Has Quake !!!!!!!!!!!!!!!!!!!!!")
        end


    end

    IROVar.CSC.fcombat = CreateFrame("Frame")
    IROVar.CSC.fcombat:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    IROVar.CSC.fcombat:SetScript("OnEvent", IROVar.CSC.COMBAT_LOG_EVENT_UNFILTERED_OnEvent)

end