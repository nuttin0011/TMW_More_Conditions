-- Many Function Rogue 9.0.5/1

--function IROVar.Rogue.UpdateRTBBuff() ; return count , update IROVar.Rogue.RTBBuff table
--function IROVar.Rogue.NeedRTB() ; return true / false
--function IROVar.Rogue.IsEnOverFlowNextGCD(n) ; return next n sec is En over flow?
--function IROVar.Rogue.ComboSerratedBoneSpikeGen() ; return number

if not IROVar then IROVar={} end
if not IROVar.Rogue then IROVar.Rogue={} end

IROVar.Rogue.RTBBuffName={
    ["Broadside"]=true,
    ["True Bearing"]=true,
    ["Ruthless Precision"]=true,
    ["Skull and Crossbones"]=true,
    ["Buried Treasure"]=true,
    ["Grand Melee"]=true,
}

IROVar.Rogue.RTBBuff={} -- keep RTB status
IROVar.Rogue.RTBBuff.count=0
IROVar.Rogue.RTBBuff.expireTime=0

function IROVar.Rogue.UpdateRTBBuff()
    local now=GetTime()
    if IROVar.Rogue.RTBBuff.expireTime>now then return IROVar.Rogue.RTBBuff.count end
    local count=0
    IROVar.Rogue.RTBBuff={}
    IROVar.Rogue.RTBBuff.expireTime=0
    for i=1,40 do
        local name, _, _, _, _, exTime=UnitBuff("player",i,"PLAYER")
        if not name then
            break
        else
            if IROVar.Rogue.RTBBuffName[name] and ((exTime-now)>1) then
                count=count+1
                IROVar.Rogue.RTBBuff[name]=true
                IROVar.Rogue.RTBBuff.expireTime=exTime-1
            end
        end
    end
    IROVar.Rogue.RTBBuff.count=count
    return count
end

function IROVar.Rogue.NeedRTB()
    -- CD Roll the Bones > 0 --> false
    if TMW.CNDT.Env.CooldownDuration("Roll the Bones") > 0 then return false end

    if (IROVar.Rogue.RTBBuff.count==0) or (IROVar.Rogue.RTBBuff.expireTime<GetTime()) then
        IROVar.Rogue.UpdateRTBBuff()
    end
    if IROVar.Rogue.RTBBuff.count==0 then return true end

    -- >3 buff --> false
    if (IROVar.Rogue.RTBBuff.count>=3) then
        return false
    end

    -- 2 buff --> false
    -- 2 buff and buff is "Grand Melee+Buried Treasure" --> true
    if IROVar.Rogue.RTBBuff.count==2 then
        return IROVar.Rogue.RTBBuff["Grand Melee"] and IROVar.Rogue.RTBBuff["Buried Treasure"]
    end

    -- SoHConduit + 1 buff --> true
    if IROVar.activeConduits["Sleight of Hand"] then return true end

    -- 1 buff + Broadside/True Bearing --> false
    return not(IROVar.Rogue.RTBBuff["Broadside"] or IROVar.Rogue.RTBBuff["True Bearing"])

end

function IROVar.Rogue.IsEnOverFlowNextGCD(n)
    n=n or 1
    local en=UnitPower("player", 3)
    local enMax=UnitPowerMax("player",3)
    local enRe=GetPowerRegen()
    return ((enRe*n)+en)>enMax
end

function IROVar.Rogue.ComboSerratedBoneSpikeGen()
    local combo=1
    for i=1,30 do
        local n="nameplate"..i
        if UnitExists(n) and UnitCanAttack("player", n) then
            if TMW.CNDT.Env.AuraDur(n, "serrated bone spike", "PLAYER HARMFUL")>0 then
                combo=combo+1
            end
        end
    end
    if TMW.CNDT.Env.AuraDur("player", "Broadside", "PLAYER HELP_BUTTON")>0.5 then combo=combo+combo end
    return combo
end

function IROVar.Rogue.NeedSerratedBoneSpike()
    local comboBlank=UnitPowerMax("player", 4)-UnitPower("player", 4)

    if comboBlank==0 then return false end

    local targetHasSBS=TMW.CNDT.Env.AuraDur("target", "serrated bone spike", "PLAYER HARMFUL")>0

    local comboGen=IROVar.Rogue.ComboSerratedBoneSpikeGen()

    local en=UnitPower("player", 3)
    --local enMax=UnitPowerMax("player",3)
    --local enRe=GetPowerRegen()

    local currentCharges, maxCharges, cooldownStart, cooldownDuration = GetSpellCharges("Serrated Bone Spike")
    local SBSChargeMax = (currentCharges==maxCharges) or ((currentCharges==(maxCharges-1)) and (GetTime()>(cooldownStart+cooldownDuration-5)))

    if targetHasSBS then
        --if low en --> true
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
        --target not has SBS
        --can use SBS not over flow Combo --> true
        if comboGen<=comboBlank then
            return true
        end
        --if SBS max charge and over flow 1 combo and Gen 3 Combo-->true
        if SBSChargeMax and (comboGen>=3) and (comboBlank>=3) then
            return true
        end
    end
    return false

end