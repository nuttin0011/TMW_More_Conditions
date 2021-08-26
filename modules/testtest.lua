
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

