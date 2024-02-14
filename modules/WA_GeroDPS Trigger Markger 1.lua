-- Marker 1


--[[
priority Icon1

GeRODPS.SpecialSkillIcon1
    --> GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon1)
OldKey From Old Interrupt
    --> GeRODPS._ShouldUseOldKey and GeRODPS.KeyToColor(GeRODPS._OldKey)
Cycle Skill
    --> GeRODPS.KeyToColor[GeRODPS.IsSkillCycle(1) and "cycle" or "none"]
Break Icon Swipe
    --> GeRODPS.GetHekiliSwipeStatus(n) and "ff000000"
Skill GCD
    --> not GeRODPS.IsSkillOffGCD(1) and GeRODPS.GetColorFromRecommended(1)
no action
    --> "ff000000"

priority Icon2

GeRODPS.SpecialSkillIcon2
    --> GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon2)
Skill Off GCD
    --> GeRODPS.IsSkillOffGCD(1) and GeRODPS.GetColorFromRecommended(1)
no action
    --> "ff000000"

priority Icon3
Kick
    --> GeRODPS.GetKickColorIfNeeded()
Cycle enemy (kick)
    --> GeRODPS.TargetEnemy.Cycle and GeRODPS.KeyToColor["cycle"]
no action
    --> "ff000000"
]]

function()
    local Hekili=Hekili
    local GeRODPS=GeRODPS
    GeRODPS.time=GetTime()
    if GeRODPS.time-GeRODPS.lastsection < GeRODPS.Options.system.update_interval_time then
        if GeRODPS.time>GeRODPS.timeMarker1sec then
            GeRODPS.timeMarker1sec=GeRODPS.time+1
            WeakAuras.ScanEvents("GERODPS_UPDATE_1SEC")
        end
        return true
    end

    if GeRODPS.Options.CDmode==1 then
        if not Hekili.State.toggle.cooldowns and GeRODPS.targetTTD>=GeRODPS.Options.CDTTDthreshold and
        UnitCanAttack("player","target") then
            Hekili:FireToggle("cooldowns")
        elseif Hekili.State.toggle.cooldowns and (GeRODPS.targetTTD<GeRODPS.Options.CDTTDthreshold or
         not UnitCanAttack("player","target")) then
            Hekili:FireToggle("cooldowns")
        end
    elseif GeRODPS.Options.CDmode==2 and not Hekili.State.toggle.cooldowns then
        Hekili:FireToggle("cooldowns")
    elseif GeRODPS.Options.CDmode==0 and Hekili.State.toggle.cooldowns then
        Hekili:FireToggle("cooldowns")
    end

    if Hekili.State.moving then
        GeRODPS.playerStandLastTime=GeRODPS.time
    end

    GeRODPS.health_current=Hekili.State.health.current or UnitHealth("player")
    GeRODPS.playerTotalAbsorbs=UnitGetTotalAbsorbs("player")
    GeRODPS.health_max=Hekili.State.health.max or UnitHealthMax("player")
    GeRODPS.health_pct=Hekili.State.health.pct or (100*GeRODPS.health_current/GeRODPS.health_max)
    GeRODPS.health_abs=((GeRODPS.health_current+GeRODPS.playerTotalAbsorbs)/GeRODPS.health_max)*100

--Hekili.DisplayPool.Primary.Recommendations[1].actionName
    local Recommendations=Hekili.DisplayPool.Primary.Recommendations

    local useCycle = true -- code for Lock Des immolate + havoc
    if GeRODPS.specID==267 and Recommendations[1].actionName=="immolate" and GeRODPS.IsSkillCycle(1) and GeRODPS.time-Hekili.State.last_havoc<14 then
        if GeRODPS.time-Hekili.State.last_havoc<14 then
            local HavocTargetHasImmolate = false
            for k in pairs(Hekili.npGUIDs) do -- 80240 = Havoc , 157736 = immolate
                if WA_GetUnitDebuff(k,80240,"PLAYER")~=nil then -- has Havoc
                    if WA_GetUnitDebuff(k,157736,"PLAYER")~=nil then
                        HavocTargetHasImmolate = true
                    end
                    break
                end
            end
            if not HavocTargetHasImmolate then
                useCycle = false
            end
        else
            --[[if WA_GetUnitDebuff(k,157736,"PLAYER")==nil then
                useCycle = false
            end]]
        end
    end

    GeRODPS.CheckAndRemoveCastSequenceSkill(1)
    GeRODPS.CheckAndRemoveCastSequenceSkill(2)
    GeRODPS.CheckAndRemoveCastSequenceSkill(3)
    GeRODPS.CheckSkillDelay()
    --WeakAuras.gcdDuration()
    local icon1OffGlobal=GeRODPS.IsSkillOffGCD(1)
    local icon1Swipe
    if icon1OffGlobal then
        icon1Swipe=WeakAuras.gcdDuration()>0
    else
        icon1Swipe=GeRODPS.GetHekiliSwipeStatus(1)
    end
    local color1 = (not icon1Swipe and GeRODPS.GetColorFromCastSequence(1)) or
    (not icon1Swipe and GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon1)) or
    (not icon1Swipe and GeRODPS._ShouldUseOldKey and GeRODPS.KeyToColor[GeRODPS._OldKey]) or
    (GeRODPS.KeyToColor[useCycle and (GeRODPS.IsSkillCycle(1) or GeRODPS.Options.cycle_enemy_icon2 and Recommendations[1].actionName~=Recommendations[2].actionName and GeRODPS.IsSkillCycle(2) and icon1Swipe) and "cycle" or "none"]) or
    (icon1Swipe and "ff000000") or
    (not icon1OffGlobal and GeRODPS.GetColorFromRecommended(1)) or
    (GeRODPS.GetColorFromRecommended(2)) or
    (GeRODPS.GetColorFromRecommended(3)) or
    "ff000000"

    
    local color2 =  GeRODPS.GetColorFromCastSequence(2) or
    GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon2) or
    (icon1OffGlobal and GeRODPS.GetColorFromRecommended(1)) or
    "ff000000"
    

    local skill1IsInterrupt=Recommendations[1] and Hekili.State.action[Recommendations[1].actionName] and Hekili.State.action[Recommendations[1].actionName].toggle=="interrupts"
    local skill2IsInterrupt=nil
    if GeRODPS.Options.system.hekili_kick_icon2 then
        skill2IsInterrupt=Recommendations[2] and Hekili.State.action[Recommendations[2].actionName] and Hekili.State.action[Recommendations[2].actionName].toggle=="interrupts"
    end

    local color3 =  GeRODPS.GetColorFromCastSequence(3) or
    GeRODPS.GetKickColorIfNeeded() or
    (GeRODPS.TargetEnemy.Cycle and GeRODPS.KeyToColor["cycle"]) or
    (skill1IsInterrupt and GeRODPS.GetColorFromRecommended(1)) or --Hekili Interrupt
    (skill2IsInterrupt and GeRODPS.GetColorFromRecommended(2)) or --Hekili Interrupt
    "ff000000"
    
    if color1==GeRODPS.OldColor1 and GeRODPS.time-GeRODPS.LastIcon1Update<0.9 then
        color1=nil
    else
        GeRODPS.OldColor1=color1
        GeRODPS.LastIcon1Update=GeRODPS.time
    end
    if color2==GeRODPS.OldColor2 and GeRODPS.time-GeRODPS.LastIcon2Update<0.9 then
        color2=nil
    else
        GeRODPS.OldColor2=color2
        GeRODPS.LastIcon2Update=GeRODPS.time
    end
    if color3==GeRODPS.OldColor3 and GeRODPS.time-GeRODPS.LastIcon3Update<0.9 then
        color3=nil
    else
        GeRODPS.OldColor3=color3
        GeRODPS.LastIcon3Update=GeRODPS.time
    end

    WeakAuras.ScanEvents("GERODPS_UPDATE",color1,color2,color3)

    return true
end

