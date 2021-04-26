-- Many Function Version War 9.0.5/2c
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.War.CanExx(Unit or blank = "target") ; return true/false
--function IROVar.War.IsEquipShield() ; return true/false

if not IROVar then IROVar={} end
IROVar.War={}
IROVar.War.it2Yd = "item:37727"
IROVar.War.isMass = false
IROVar.War.isCondemn = false
IROVar.War.isEquipShield = false
IROVar.War.MainHandWeaponLink = nil
IROVar.War.OffHandWeaponLink = nil
IROVar.War.ShieldLink = nil
IROVar.War.CanUseSwapWeapon = false
IROVar.War.WeaponChecking=false
IROVar.War.JustCheckShield=0
function IROVar.War.CanExx(U)
    U=U or "target"
    if not IROVar.War.FOnEvent then IROVar.War.SetupEventCheck() end
    local OldVal=IROVar.ERO_Old_Val.Check("War.CanExx",U)
    if OldVal then return OldVal end
    local uHP, output
    if UnitCanAttack("player", U) and IsItemInRange(IROVar.War.it2Yd, U) then
        uHP=(UnitHealth(U)/UnitHealthMax(U))*100
        output=(uHP>0) and ((uHP<20) or ((uHP<35) and IROVar.War.isMass) or ((uHP>80) and IROVar.War.isCondemn))
        IROVar.ERO_Old_Val.Update("War.CanExx",U,output)
        return output
    else
        IROVar.ERO_Old_Val.Update("War.CanExx",U,false)
        return false
    end
end

function IROVar.War.CheckTalent()
    local _,TName,_,TSelected=GetTalentInfo(3,1,1)
    IROVar.War.isMass = (TName=="Massacre") and TSelected
    IROVar.War.isCondemn = GetSpellInfo("execute")=="Condemn"
end

function IROVar.War.CheckBagForOffHandAndUpdateMacro()
    -- not Fury spec
    if (IROSpecID or GetSpecializationInfo(GetSpecialization())) ~=72 then
        IROVar.War.CanUseSwapWeapon=false
        return
    end
    -- incombat
    if InCombatLockdown() then return end
    -- main hand Empty
    local mainHandWeaponLink=GetInventoryItemLink("player", 16)
    if not mainHandWeaponLink then return end
    -- Hold Fishing Poles
    if select(7,GetItemInfo(GetInventoryItemLink("player", 16)))=="Fishing Poles" then return end
    local offHandWeaponLink = nil
    local shieldLink = nil

    --check off hand
    local ItemLink=GetInventoryItemLink("player", 17)
    local ItemEquipLoc
    local mainHandItemEquipLoc=select(9,GetItemInfo(mainHandWeaponLink))
    if ItemLink~=nil then
        ItemEquipLoc=select(9,GetItemInfo(ItemLink))
        if ItemEquipLoc=="INVTYPE_SHIELD" then
            shieldLink=ItemLink
        end
        if ItemEquipLoc == mainHandItemEquipLoc then
            offHandWeaponLink=ItemLink
        end
    end

    local function CheckItemInBag(itemEquipLoc)
        local tempShieldLink=nil
        local ilvltempShieldLink=0
        for bag = 0,4 do
            for slot = 1,GetContainerNumSlots(bag) do
                local IL = GetContainerItemLink(bag,slot)
                if IL and (select(9,GetItemInfo(IL))==itemEquipLoc) and
                C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag,slot))
                then
                    local ilvl=select(4,GetItemInfo(IL))
                    if ilvl>ilvltempShieldLink then
                        tempShieldLink=IL
                        ilvltempShieldLink=ilvl
        end end end end
        return tempShieldLink
    end

    --check Shield In bag
    shieldLink=shieldLink or CheckItemInBag("INVTYPE_SHIELD")
     --check Weapon In bag
    offHandWeaponLink=offHandWeaponLink or CheckItemInBag(mainHandItemEquipLoc)

    --Check Same Set of Weapon?
    if (mainHandWeaponLink==IROVar.War.MainHandWeaponLink) and
    (offHandWeaponLink==IROVar.War.OffHandWeaponLink) and
    (shieldLink==IROVar.War.ShieldLink) then return end
    IROVar.War.MainHandWeaponLink=mainHandWeaponLink
    IROVar.War.OffHandWeaponLink=offHandWeaponLink
    IROVar.War.ShieldLink=shieldLink

    IROVar.War.CanUseSwapWeapon=((mainHandWeaponLink~=nil) and (offHandWeaponLink~=nil) and (shieldLink~=nil)) or false
    --Create Marcro
    if not IROVar.War.CanUseSwapWeapon then return end

    local SetKeyBindToKeyNum = 7
    local macroName="~!Num"..SetKeyBindToKeyNum
    local MacroBody = GetMacroBody(macroName) or ""
    DeleteMacro(macroName)
    DeleteMacro(macroName)
    local sFind = MacroBody:find("/equipslot")
    if sFind then
        MacroBody=string.sub(MacroBody,1,sFind-2)
    end
    local offHanaName=GetItemInfo(offHandWeaponLink)
    local shieldName=GetItemInfo(shieldLink)
    MacroBody=MacroBody.."\n/equipslot [mod:alt,nomod:ctrl] 17 "..offHanaName.."\n/equipslot [nomod] 17 "..shieldName
    CreateMacro(macroName,460699,MacroBody ,true)
end

function IROVar.War.CheckWeapon()
    local currentTime=GetTime()
    if (currentTime-IROVar.War.JustCheckShield)>0.1 then
        IROVar.War.ShieldChecking=true
        local ItemLink=GetInventoryItemLink("player", 17)--shield
        IROVar.War.isEquipShield=(ItemLink~=nil) and (select(7,GetItemInfo(ItemLink))=="Shields") or false
        C_Timer.After(0.1,function() IROVar.War.ShieldChecking=false end)
        IROVar.War.JustCheckShield=currentTime
    end

    if IROVar.War.WeaponChecking then return end
    IROVar.War.WeaponChecking = true
    local function checkWeapon()
        if InCombatLockdown() then
            C_Timer.After(0.6,checkWeapon)
        else
            IROVar.War.WeaponChecking = false
            IROVar.War.CheckBagForOffHandAndUpdateMacro()
        end
    end
    C_Timer.After(0.3,checkWeapon)
end

function IROVar.War.SetupEventCheck()
    IROVar.War.FOnEvent=function(_,event)
        if IROVar.DebugMode then
            print("Event in Warrior On Event",event)
        end
        if event == "PLAYER_TALENT_UPDATE" then
            C_Timer.After(2,IROVar.War.CheckTalent)
            IROVar.War.CheckWeapon()
        end
        if event == "UNIT_INVENTORY_CHANGED" or
        event == "BAG_UPDATE" then
            IROVar.War.CheckWeapon()
        end
    end
    C_Timer.After(2,IROVar.War.CheckTalent)
    IROVar.War.CheckWeapon()
    IROVar.War.FEvent = CreateFrame("Frame")
    IROVar.War.FEvent:RegisterEvent("PLAYER_TALENT_UPDATE")
    IROVar.War.FEvent:RegisterEvent("BAG_UPDATE")
    IROVar.War.FEvent:RegisterEvent("UNIT_INVENTORY_CHANGED")
    IROVar.War.FEvent:SetScript("OnEvent", IROVar.War.FOnEvent)
end

function IROVar.War.IsEquipShield()
    if not IROVar.War.FOnEvent then IROVar.War.SetupEventCheck() end
    return IROVar.War.isEquipShield
end



