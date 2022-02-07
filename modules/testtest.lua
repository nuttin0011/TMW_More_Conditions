
--function NeedSBS()
(function()
    local comboCurrent=UnitPower("player", 4)
    local comboBlank=UnitPowerMax("player", 4)-comboCurrent
    if comboBlank==0 then return false end
    local comboGen=1
    for i=1,30 do
        local n="nameplate"..i
        if UnitExists(n) and UnitCanAttack("player", n) and (TMW.CNDT.Env.AuraDur(n, "serrated bone spike", "PLAYER HARMFUL")>0) then
            comboGen=comboGen+1
        end
    end
    if TMW.CNDT.Env.AuraDur("player", "broadside", "PLAYER HELPFUL")>0.5 then comboGen=comboGen+1 end
    if TMW.CNDT.Env.AuraDur("player", "shadow blades", "PLAYER HELPFUL")>0.5 then comboGen=comboGen+1 end

    if comboCurrent<=1 then
        return true
    else
        return comboGen<=comboBlank
    end


    --local targetHasSBS=TMW.CNDT.Env.AuraDur("target", "serrated bone spike", "PLAYER HARMFUL")>0
    --local en=UnitPower("player", 3)
    --local currentCharges, maxCharges, cooldownStart, cooldownDuration = GetSpellCharges("Serrated Bone Spike")
    --local SBSChargeMax = (currentCharges==maxCharges) or ((currentCharges==(maxCharges-1)) and (GetTime()>(cooldownStart+cooldownDuration-5)))
--[[
    if targetHasSBS then
        if (comboGen<=comboBlank) and (en<60) then
            return true
        end
        if SBSChargeMax then
            if comboGen<=comboBlank then
                return true
            end
            if (comboGen>=3) and (comboBlank>=3) then
                return true
            end
        end
    else
        if comboGen<=comboBlank then
            return true
        end
        if SBSChargeMax and (comboGen>=3) and (comboBlank>=3) then
            return true
        end
    end]]

    return false
end)()

(function ()-- start Tyrant Rotation by check Vilefiend+Grimoire
    local td= IROVar.GetDemonicCoreStack()
    local t1= (GetSpellCooldown("Summon Vilefiend")==0) and IROVar.CastTime2sec or 0
    local t2= (GetSpellCooldown("Grimoire: Felguard")==0) and IROVar.CastTime2sec or 0
    local t3= 7+t1+t2+(IROVar.CastTime2sec*td)
    local st,du=GetSpellCooldown("Summon Demonic Tyrant")
    local cd=st+du-GetTime()
    return cd<t3
end)()





--IROVar.IconSweepCompair(IROCallDSIcon,18,h) and (IROVar.IconSweepCompair(IROVileFiendIcon,18,h) or not TMW.CNDT.Env.TalentMap["summon vilefiend"])

--IROVar.Lock.GetWildImpCountTimePass(t)

(function()
    local n,_,_,_,et = UnitCastingInfo("player")
    if n~="Summon Demonic Tyrant" then return false end
    local C=(et/1000)-GetTime()
    local ImpTyrant1=IROVar.Lock.GetWildImpCountTimePass(C)
    local TyHoG=IROVar.CastTime1_5sec+IROVar.CastTime2sec
    local ImpTyrant2=IROVar.Lock.GetWildImpCountTimePass(0.2+TyHoG)
    if ImpTyrant2>=ImpTyrant1 then
        TyHoG=TyHoG+0.3
        local DSVFRemain=IROVar.IconSweepCompair(IROCallDSIcon,18,TyHoG) and (IROVar.IconSweepCompair(IROVileFiendIcon,18,TyHoG) or not TMW.CNDT.Env.TalentMap["summon vilefiend"])
        if DSVFRemain then
            return true
        end
    end
    return false
end)()



local a=(not IROVar.activeConduits["Tyrant's Soul"])or(TMW.CNDT.Env.AuraDur("player", "demonic power", "PLAYER HELPFUL")==0)





(function()-- player Castting HoG, then Cast Summon Tyrant After This HoG?
    if GetSpellCooldown("Summon Demonic Tyrant")>0 then return false end
    local n,_,_,_,et = UnitCastingInfo("player")
    if n~="Hand of Gul'dan" then return false end
    local Imp=IROVar.Lock.GetWildImpCount()
    if Imp<3 then return false end
    local SS=IROVar.Lock.PredictSS()
    if SS==0 then return true end

    local C=(et/1000)-GetTime()
    local HoGTyrantCast=C+IROVar.CastTime2sec
    local HoGHoGTyrant=HoGTyrantCast+IROVar.CastTime1_5sec
    local HoGDBHoGTyrant=HoGHoGTyrant+IROVar.CastTime1_5sec
    local ImpHoGTyrantCast=IROVar.Lock.GetWildImpCountTimePass(HoGTyrantCast)
    local DCStack=IROVar.GetDemonicCoreStack()

    if SS==1 and DCStack>=1 then
        local ImpHoGDBHoGTyrant=IROVar.Lock.GetWildImpCountTimePass(HoGDBHoGTyrant)
        return ImpHoGDBHoGTyrant<ImpHoGTyrantCast
    end
    if SS>=2 then
        local ImpHoGHoGTyrant=IROVar.Lock.GetWildImpCountTimePass(HoGHoGTyrant)
        --IROVar.NextSpellIsHoG=true
        return ImpHoGHoGTyrant<ImpHoGTyrantCast
    end
    return false
end)()

local aa=
IROVar.Lock.PredictSS()>=50 or
(IROVar.Lock.PredictSS()>=40 and IROVar.GetDemonicCoreStack()>=2) or
(IROVar.Lock.PredictSS()>=40 and
GetSpellCooldown("Call Dreadstalkers")==0 and
TMW.CNDT.Env.AuraDur("player", "demonic calling", "PLAYER HELPFUL")>0)







