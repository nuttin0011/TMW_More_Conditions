-- Marker 1


--[[
priority Icon1

GeRODPS.SpecialSkillIcon1
    --> GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon1)
Cycle Skill
    --> GeRODPS.KeyToColor[GeRODPS.IsSkillCycle(1) and "cycle" or "none"]
Break Icon Swipe
    --> GeRODPS.GetHekiliSwpieStatus(n) and "ff000000"
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
    if GeRODPS.time-GeRODPS.lastsection < 0.05 then return true end
    local FrocedUpdateColor=false
    if GeRODPS.time-GeRODPS.LastIcon1Update>0.5 or
    GeRODPS.time-GeRODPS.LastIcon2Update>0.5 or
    GeRODPS.time-GeRODPS.LastIcon3Update>0.5
    then FrocedUpdateColor=true end
    GeRODPS.health_pct=Hekili.State.health.pct
    GeRODPS.health_current=Hekili.State.health.current
    GeRODPS.playerTotalAbsorbs=UnitGetTotalAbsorbs("player")
    GeRODPS.health_max=Hekili.State.health.max
    GeRODPS.health_abs=((GeRODPS.health_current+GeRODPS.playerTotalAbsorbs)/GeRODPS.health_max)*100


    local color1 = GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon1) or
    (GeRODPS.KeyToColor[GeRODPS.IsSkillCycle(1) and "cycle" or "none"]) or
    (GeRODPS.GetHekiliSwpieStatus(n) and "ff000000") or
    (not GeRODPS.IsSkillOffGCD(1) and GeRODPS.GetColorFromRecommended(1)) or
    "ff000000"

    local color2 = GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon2) or
    (GeRODPS.IsSkillOffGCD(1) and GeRODPS.GetColorFromRecommended(1)) or
    "ff000000"

    local color3 = GeRODPS.GetKickColorIfNeeded() or
    (GeRODPS.TargetEnemy.Cycle and GeRODPS.KeyToColor["cycle"]) or
    "ff000000"

    if color1==GeRODPS.OldColor1 then
        color1=nil
    else
        GeRODPS.OldColor1=color1
        GeRODPS.LastIcon1Update=GeRODPS.time
    end
    if color2==GeRODPS.OldColor2 then
        color2=nil
    else
        GeRODPS.OldColor2=color2
        GeRODPS.LastIcon2Update=GeRODPS.time
    end
    if color3==GeRODPS.OldColor3 then
        color3=nil
    else
        GeRODPS.OldColor3=color3
        GeRODPS.LastIcon3Update=GeRODPS.time
    end

    WeakAuras.ScanEvents("GERODPS_UPDATE",color1,color2,color3)

--[[
    GeRODPS.OldColor=Color
    GeRODPS.OldKickColor=KickColor

    if GeRODPS.offGCDSpellName[Recommended1.actionName] then
        --off GCD use Icon2
        WeakAuras.ScanEvents("GERODPS_UPDATE","ff000000",Color,KickColor)
        GeRODPS.LastIcon1Update=GeRODPS.time
        GeRODPS.LastIcon2Update=GeRODPS.time
        GeRODPS.LastIcon3Update=GeRODPS.time
    else
        --has GCD use Icon1
        WeakAuras.ScanEvents("GERODPS_UPDATE",Color,"ff000000",KickColor)
        GeRODPS.LastIcon1Update=GeRODPS.time
        GeRODPS.LastIcon2Update=GeRODPS.time
        GeRODPS.LastIcon3Update=GeRODPS.time
    end
]]

    --WeakAuras.ScanEvents("GERODPS_UPDATE",Icon1,Icon2,Icon3)
    --WeakAuras.ScanEvents("GERODPS_UPDATE",1,2,3,4,5,6,7,8,9,10,11,12,13,14)
    
    return true
end
