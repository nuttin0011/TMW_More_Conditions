-- War Fury Use Shield When Need


EROWarFuryUseShield = {}
EROWarFuryUseShield.ThresholeEquipShield = 6
EROWarFuryUseShield.ShieldLinkID = nil
EROWarFuryUseShield.ShieldIlvl = 0
EROWarFuryUseShield.WeaponLinkID = nil
EROWarFuryUseShield.WeaponIlvl = 0
EROWarFuryUseShield.PlayerLevel = 0
EROWarFuryUseShield.IsEquippedShield = false
EROWarFuryUseShield.IsSetuped=false
EROWarFuryUseShield.MobTypeWeight = {
    ["worldboss"]=10,
    ["rareelite"]=5,
    ["elite"]=1,
    ["rare"]=2,
 }

EROWarFuryUseShield.FindBestShieldInBag = function()
    --return ItemLink , ItemLevel
    local itemLevel,itemSubType
    local BestShieldInBag = nil
    local ShieldIlvlInBag = 0
    for bag=0,4 do
        for bagSlot=1,GetContainerNumSlots(bag) do
            local tempItemLink=select(7,GetContainerItemInfo(bag,bagSlot))
            if tempItemLink then
                _, _, _, itemLevel, _, _, itemSubType = GetItemInfo(tempItemLink)
                if(itemSubType =="Shields")and(itemLevel>ShieldIlvlInBag)then
                    --print(GetItemInfo(tempItemLink))
                    BestShieldInBag=tempItemLink
                    ShieldIlvlInBag=itemLevel
                end
            end
        end
    end
    return BestShieldInBag,ShieldIlvlInBag
end

EROWarFuryUseShield.FindBestOffHand = function()
    --return ItemLink , ItemLevel
    local itemLink = GetInventoryItemLink("player", 17)
    local _, _, _, itemLevel, _, _, itemSubType = GetItemInfo(itemLink)
    return itemLink,itemLevel
end

EROWarFuryUseShield.EquipShield = function()
    EquipItemByName(EROWarFuryUseShield.ShieldLinkID,17)
end

EROWarFuryUseShield.EquipWeapon = function()
    EquipItemByName(EROWarFuryUseShield.WeaponLinkID,17)
end

EROWarFuryUseShield.WeightEliteAgroMe = function()
    --return number
    --calculate with MobTypeWeight * Diff LV Mob and Player
    local playerlevel=EROWarFuryUseShield.PlayerLevel
    local numberAgrome=0
    local nn
    for ii =1,30 do
        nn='nameplate'..ii
        if (UnitExists(nn)==true)
        and (UnitCanAttack("player", nn))
        and ((select(3, UnitDetailedThreatSituation("player", nn)) or 0)>=100 ) then
            local nnLevel = UnitLevel(nn)
            if nnLevel==-1 then nnLevel=1000 end
            local diffLevel = nnLevel-playerlevel
            if nnLevel>=playerlevel then
                local MobType=UnitClassification(nn)
                local MobWeight=EROWarFuryUseShield.MobTypeWeight[MobType] and EROWarFuryUseShield.MobTypeWeight[MobType] or 0
                numberAgrome=numberAgrome+(MobWeight*(diffLevel+1))
            end
        end
    end
    return numberAgrome
end

















EROWarFuryUseShield.Setup = function()
    if EROWarFuryUseShield.IsSetuped then return end
    EROWarFuryUseShield.ShieldLinkID,EROWarFuryUseShield.ShieldIlvl=EROWarFuryUseShield.FindBestShieldInBag()
    EROWarFuryUseShield.WeaponLinkID,EROWarFuryUseShield.WeaponIlvl=EROWarFuryUseShield.FindBestOffHand()
    EROWarFuryUseShield.PlayerLevel = UnitLevel("player")
    EROWarFuryUseShield.IsEquippedShield = select(2,IsUsableSpell("shield block"))==true
end

EROWarFuryUseShield.Setup()