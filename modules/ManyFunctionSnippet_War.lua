-- Many Function Version War 9.0.5/5
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.War.CanExx(Unit or blank = "target") ; return true/false
--function IROVar.War.IsEquipShield() ; return true/false
--function IROVar.War.PredictFuryRageFromAutoAttack(r,t) ; return rage ; t is time ; r is rage from skill
--function IROVar.War.ChangeCovenantSkillMacro(mName) ; change Skill in Macro to Covenant skill

if not IROVar then IROVar={} end
if not IROVar.InstanceName then IROVar.InstanceName = GetInstanceInfo() end
if (not IROVar.fspec) and (not IROVar.finstanceName) then
    IROVar.finstanceName = CreateFrame("Frame")
    IROVar.finstanceName:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    IROVar.finstanceName:SetScript("OnEvent", function()
            IROVar.InstanceName = GetInstanceInfo()
    end)
end
IROVar.War={}
-- [Skill Name] ={lowercase = "lower case skill",[instance name]={[Mob Name]= true / false / Lua Scrip}}
IROVar.War.SpellThatCare = {
    ["Shattering Throw"] = {
        lowercase = "shattering throw",
        ["The Necrotic Wake"] ={
            ["Nalthor the Rimebinder"]=[[return TMW.CNDT.Env.AuraDur("target", "icebound aegis", "HELPFUL")>0]],
        },
        ["Theater of Pain"]={
            ["Sathel the Accursed"]=[[return TMW.CNDT.Env.AuraDur("target", "one with death", "HELPFUL")>0]],
        }
    }
}
IROVar.War.it2Yd = "item:37727"
IROVar.War.isMass = false
IROVar.War.isCondemn = false
IROVar.War.isEquipShield = false
IROVar.War.MainHandWeaponLink = nil
IROVar.War.OffHandWeaponLink = nil
IROVar.War.MHType=false
IROVar.War.OHType=false
IROVar.War.MHRage=2
IROVar.War.OHRage=1
IROVar.War.ReckEnd=0
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
        local MHItemLink=GetInventoryItemLink("player", 16)-- MH
        local OHItemLink=GetInventoryItemLink("player", 17)-- Off hand

        --local MHType=GetItemInfo(GetInventoryItemLink("player", 16))
        --local OHType=GetItemInfo(GetInventoryItemLink("player", 17))
        IROVar.War.isEquipShield=(OHItemLink~=nil) and (select(7,GetItemInfo(OHItemLink))=="Shields") or false
        IROVar.War.MHType=(MHItemLink~=nil) and select(9,GetItemInfo(MHItemLink)) or false
        IROVar.War.OHType=(OHItemLink~=nil) and select(9,GetItemInfo(OHItemLink)) or false
        IROVar.War.MHRage=(IROVar.War.MHType=="INVTYPE_2HWEAPON") and 6 or ((IROVar.War.MHType=="INVTYPE_WEAPON") and 4 or 2)
        IROVar.War.OHRage=(IROVar.War.OHType=="INVTYPE_2HWEAPON") and 3 or ((IROVar.War.OHType=="INVTYPE_WEAPON") and 2 or 1)
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

C_Timer.After(0.1,function() IROVar.War.SetupEventCheck() end)

function IROVar.War.IsEquipShield()
    if not IROVar.War.FOnEvent then IROVar.War.SetupEventCheck() end
    return IROVar.War.isEquipShield
end

function IROVar.War.VVCareSpell(nSpell) --Use Only Target
    if not IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName] then return false end
    local mName=UnitName("target")
    if not mName then return false end
    if not IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName] then return false end
    return (IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName]==true) and true or
            loadstring(IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName])()
end

function IROVar.War.CareSpell(nSpell) --Use Only Target
    if not IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName] then return true end
    local mName=UnitName("target")
    if not mName then return true end
    if IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName]==false then return false end
    if IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName]==nil then return true end
    return (IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName]==true) and true or
            loadstring(IROVar.War.SpellThatCare[nSpell][IROVar.InstanceName][mName])()
end

function IROVar.War.PredictFuryRageFromAutoAttack(r,t)
    t=t or IROVar.CastTime1_5sec or 0
    r=r or 0
    local rage=UnitPower("player")
    local MHNextSwing=TMW.COMMON.SwingTimerMonitor.SwingTimers[16].startTime+TMW.COMMON.SwingTimerMonitor.SwingTimers[16].duration
    local OHNextSwing=TMW.COMMON.SwingTimerMonitor.SwingTimers[17].startTime+TMW.COMMON.SwingTimerMonitor.SwingTimers[17].duration
    local currentTimeT=GetTime()+t

    if currentTimeT>MHNextSwing then
        rage=rage+IROVar.War.MHRage
        if MHNextSwing<IROVar.War.ReckEnd then
            rage=rage+IROVar.War.MHRage
        end
    end
    if currentTimeT>OHNextSwing then
        rage=rage+IROVar.War.OHRage
        if OHNextSwing<IROVar.War.ReckEnd then
            rage=rage+IROVar.War.OHRage
        end
    end
    rage=rage+r
    if currentTimeT<IROVar.War.ReckEnd then
        rage=rage+r
    end
    return rage
end

IROVar.War.UnitAuraEvent=function(self,event,unit,_,table)
    if unit=="player"  then
        if table and table[1] and table[1].name=="Recklessness" then
            --Reck Change Time
            IROVar.War.ReckEnd=select(3,TMW.CNDT.Env.AuraDur("player","recklessness","PLAYER HELPFUL"))
        end
    end
end
IROVar.War.UnitAuraFrame=CreateFrame("Frame")
IROVar.War.UnitAuraFrame:RegisterEvent("UNIT_AURA")
IROVar.War.UnitAuraFrame:SetScript("OnEvent", IROVar.War.UnitAuraEvent)

IROVar.War.OldCovenantBeforChangeSkill=nil
--ex /run IROVar.War.ChangeCovenantSkillMacro("War Covenant1")
function IROVar.War.ChangeCovenantSkillMacro(mName,mName2)
    local CovenantName=IROVar.activeConduits.covenantName
    if not CovenantName then return end
    if CovenantName==IROVar.War.OldCovenantBeforChangeSkill then return end
    IROVar.War.OldCovenantBeforChangeSkill=CovenantName
    local MacroName,MacroIcon,MacroBody = GetMacroInfo(mName);
    local MacroName2,MacroIcon2,MacroBody2 = GetMacroInfo(mName2);
    if CovenantName=="Necrolord" then
        MacroBody="#showtooltip Conqueror's Banner\n/cast Conqueror's Banner"
        --[Conqueror's Banner]3578234  [Fleshcraft]3586267
        MacroIcon=3578234
        MacroBody2="#showtooltip Fleshcraft\n/cast Fleshcraft"
        MacroIcon2=3586267
    end
    if CovenantName=="Venthyr" then
        MacroBody="#showtooltip Condemn\n/cast Condemn"
        --[Condemn]3565727  [Door of Shadows] 3586270
        MacroIcon=3565727
        MacroBody2="#showtooltip Door of Shadows\n/cast Door of Shadows"
        MacroIcon2=3586270
    end
    if CovenantName=="Night Fae" then
        --[Ancient Aftershock]3636851  [Soulshape]3586268
        MacroBody="#showtooltip Ancient Aftershock\n/cast Ancient Aftershock"
        MacroIcon=3636851
        MacroBody2="#showtooltip Soulshape\n/cast Soulshape"
        MacroIcon2=3586268
    end
    if CovenantName=="Kyrian" then --[Spear of Bastion]3565453  [Summon Steward]3586266
        MacroBody="#showtooltip Spear of Bastion\n/cast [@player]Spear of Bastion"
        MacroIcon=3565453
        MacroBody2="#showtooltip Summon Steward\n/cast [nomounted]Summon Steward"
        MacroIcon2=3586266
    end
    if MacroName then EditMacro(MacroName, MacroName, MacroIcon, MacroBody) end
    if MacroName2 then EditMacro(MacroName2, MacroName2, MacroIcon2, MacroBody2) end
end
