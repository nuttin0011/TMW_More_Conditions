-- On SHOW
-- GeRODPS.BigWigs_GetTimeRemaining(text)
local GeRODPS,Hekili,WeakAuras=GeRODPS,Hekili,WeakAuras
local IsSpellInRange=C_Spell.IsSpellInRange
Hekili.State.gerodps=GeRODPS
Hekili.State.AuraUtil=AuraUtil
Hekili.State.next=next
Hekili.State.debuff_lanced=function()
    return Hekili.State.target.npcid==186616 and AuraUtil.FindAuraByName("Lanced!","target","HARMFUL")
end
GeRODPS.LoadingComplete2=false
local impending_victory_ans,victory_rush_ans
GeRODPS.SpecialSkillIcon1 = { 
    ["WARRIOR"] =
    {
        {"impending_victory",function()--GeRODPS.SpecialSkillIcon1.WARRIOR[1][2]()
            local def = GeRODPS.Options.Def
            local options = GeRODPS.Options.warrior.use_victory_rush
            local talen = Hekili.State.talent.impending_victory.enabled
            local CD = GeRODPS.CDReady(202168)
            local HP = GeRODPS.health_abs <= GeRODPS.Options.warrior.hp_victory_rush
            impending_victory_ans=options and def and HP and talen and CD and IsSpellInRange("Slam","target")
            return impending_victory_ans
        end},
        {"victory_rush",function()--GeRODPS.SpecialSkillIcon1.WARRIOR[2][2]()
            local def = GeRODPS.Options.Def
            local options = GeRODPS.Options.warrior.use_victory_rush
            local talen = not Hekili.State.talent.impending_victory.enabled
            local CD = GeRODPS.CDReady(34428)
            local HP = GeRODPS.health_abs <= GeRODPS.Options.warrior.hp_victory_rush
            local usable = IsUsableSpell(34428)
            victory_rush_ans=options and def and HP and talen and CD and usable and IsSpellInRange("Slam","target")
            return victory_rush_ans
        end},
    },
    ["PALADIN"] =
    {
        {"word_of_glory",function()
            if GeRODPS.specID~=70 and GeRODPS.specID~=66 then return false end--ret,port
            local incombat = GeRODPS.incombat
            local use = GeRODPS.Options.Def and GeRODPS.Options.paladin.use_word_of_glory
            local usable = function() return IsUsableSpell(85673)end
            local known = Hekili.State:IsKnown(85673)
            local HP = GeRODPS.health_abs <= GeRODPS.Options.paladin.word_of_glory_treshold
            local target = function() return UnitCanAttack("player","target") or not UnitExists("target") or UnitIsUnit("target","player")end
            return incombat and use and HP and known and usable() and target()
        end},
        {"flash_of_light",function()
            if GeRODPS.specID~=70 and GeRODPS.specID~=66 then return false end--ret,port
            local incombat = GeRODPS.incombat
            local use = GeRODPS.Options.Def and GeRODPS.Options.paladin.use_flash_of_light
            local usable = function() return IsUsableSpell(19750)end
            local HPveryLow = GeRODPS.health_abs <= GeRODPS.Options.paladin.flash_of_light_treshold
            local HPLow = GeRODPS.health_abs <= GeRODPS.Options.paladin.flash_of_light_outcombat_treshold
            local targetSelf = function() return UnitCanAttack("player","target") or not UnitExists("target") or UnitIsUnit("target","player")end
            local mana_reserved = Hekili.State.mana.pct>GeRODPS.Options.paladin.fol_mana_reserved
            return use and (HPveryLow or not incombat and HPLow)and mana_reserved and usable() and targetSelf()
        end}
    },
    ["HUNTER"] =
    {
        {"exhilaration",function()
            local incombat = GeRODPS.incombat
            local def = GeRODPS.Options.Def
            local known = Hekili.State:IsKnown(109304)
            local CD = GeRODPS.CDReady(109304)
            local hunter=GeRODPS.Options.hunter
            local useskill = (hunter.use_exhilaration and GeRODPS.health_abs<hunter.exhilaration_threshold) or
            (hunter.use_exhilaration_pet and Hekili.State.pet.alive and Hekili.State.pet.health_pct<hunter.exhilaration_pet_threshold)
            --Hekili.State.pet.alive
            return incombat and def and known and CD and useskill
        end},
        {"mend_pet",function()--136
            local def = GeRODPS.Options.Def
            local known = Hekili.State:IsKnown(136)
            local CD = GeRODPS.CDReady(136)
            local use = GeRODPS.Options.hunter.use_mend_pet and Hekili.State.pet.alive and Hekili.State.pet.health_pct<GeRODPS.Options.hunter.mend_pet_threshold
            return def and known and CD and use
        end},
        {"ALT-F9",function() -- only Hunter
            local pet_dead_message = GeRODPS.pet_is_dead_use_revive_pet
            local pet_dead = UnitExists("pet") and UnitIsDead("pet")
            return pet_dead_message or pet_dead
        end}
    },
    ["ROGUE"] =
    {
        {"feint",function() -- 1966
            local exclude = GeRODPS.ExcludeDEF["ROGUE"][GeRODPS.ZoneName]
            local def = GeRODPS.Options.Def
            local useskill = GeRODPS.Options.rogue.use_feint
            local known = Hekili.State:IsKnown(1966)
            local CD = GeRODPS.CDReady(1966)
            local useable=IsUsableSpell(1966)
            local DmgCome=(GeRODPS.time>GeRODPS.NPA.damageStart-2) and (GeRODPS.time<GeRODPS.NPA.damageEnd)
            local aura = function() return WA_GetUnitBuff("player",1966,"PLAYER")==nil end
            return known and useskill and def and DmgCome and CD and useable and not exclude and aura()
        end},
        {"crimson_vial",function() --crimson vail 185311
            local incombat = GeRODPS.incombat
            local def = GeRODPS.Options.Def
            local useskill = GeRODPS.Options.rogue.use_crimson_vial
            local known = Hekili.State:IsKnown(185311)
            local CD = GeRODPS.CDReady(185311)
            local useable=IsUsableSpell(185311)
            local HP = GeRODPS.health_abs <= GeRODPS.Options.rogue.hp_crimson_vial
            return incombat and HP and def and useskill and known and CD and useable
        end},
    },
    ["PRIEST"] =
    {
    },
    ["DEATHKNIGHT"] =
    {
        {"death_strike",function() --49998
            local HP = GeRODPS.health_abs <= 60
            local def = GeRODPS.Options.Def
            local known = Hekili.State:IsKnown(49998)
            local CD = GeRODPS.CDReady(49998)
            local useable=IsUsableSpell(49998)
            local range=IsSpellInRange("death strike","target")
            local canattack = UnitCanAttack("player","target")
            return known and def and CD and useable and HP and range and canattack
        end},
    },
    ["SHAMAN"] =
    {
    },
    ["MAGE"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion}, -- Healing Potion
    },
    ["WARLOCK"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion}, -- Healing Potion
        {"dark_pact",function() --id 108416
            local incombat = GeRODPS.incombat
            local def = GeRODPS.Options.Def
            local deftrigger = GeRODPS.Options.warlock.use_dark_pact_def_trigger and GeRODPS.time<GeRODPS.NPA.damageEnd
            local hptrigger = GeRODPS.Options.warlock.use_dark_pact_hp_trigger and GeRODPS.health_abs <= GeRODPS.Options.warlock.use_dark_pact_hp_percen
            local trigger = deftrigger or hptrigger
            local known = Hekili.State:IsKnown(108416)
            local CD = GetSpellCooldown(108416)==0
            return incombat and def and trigger and known and CD
        end},
        {"unending_resolve",function() -- 104773
            local def = GeRODPS.incombat and GeRODPS.Options.Def and GeRODPS.Options.warlock.use_unending_def_if_cannot_dark_pact
            local deftrigger = GeRODPS.Options.warlock.use_dark_pact_def_trigger and GeRODPS.time<GeRODPS.NPA.damageEnd and GeRODPS.time>GeRODPS.NPA.damageStart-2
            local hptrigger = GeRODPS.Options.warlock.use_dark_pact_hp_trigger and GeRODPS.health_abs <= 90
            local CD = GetSpellCooldown(104773)==0
            local known = Hekili.State:IsKnown(104773)
            return known and def and deftrigger and hptrigger and CD
        end},
    },
    ["MONK"] =
    {
    },
    ["DRUID"] =
    {
        {"regrowth",function()--feral regrowth
            if GeRODPS.specID~=103 then return false end
            local use = GeRODPS.Options.Def and GeRODPS.Options.druid.use_feral_regrowth
            local HP = GeRODPS.health_abs <= GeRODPS.Options.druid.feral_regrowth_treshold
            local aura = function() return WA_GetUnitBuff("player",69369,"PLAYER")~=nil end--Predatory Swiftness
            return use and HP and aura()
        end}
    },
    ["DEMONHUNTER"] =
    {
    },
    ["EVOKER"] =
    {
    },
    ["NONE"] =
    {
    },
}

GeRODPS.SpecialSkillIcon2 = {
    ["WARRIOR"] =
    {
        {"ALT-F8",function()
            return not impending_victory_ans and not victory_rush_ans and GeRODPS.Condition_Use_HealthStone()
        end},
        {"ALT-F7",function()
            return not impending_victory_ans and not victory_rush_ans and GeRODPS.Condition_Use_HealingPotion()
        end},
        {"defensive_stance",function()
            local def = GeRODPS.Options.Def
            local options = GeRODPS.Options.warrior.use_defensive_stance
            local nothasDS=function() return WA_GetUnitBuff("player",386208,"PLAYER")==nil end --defensive stance
            local DmgCome=(GeRODPS.time>GeRODPS.NPA.damageStart-GeRODPS.Options.warrior.use_defensive_stance_time) and (GeRODPS.time<GeRODPS.NPA.damageEnd)
            local aggro = Hekili.State.aggro
            local CD=GetSpellCooldown(386208)==0
            return options and def and (DmgCome or aggro) and CD and nothasDS()
        end},
        {"berserker_stance",function()
            local aggro = Hekili.State.aggro
            local role = Hekili.State.role.attack
            local known = Hekili.State:IsKnown(386196)
            local nothasBS=function() return WA_GetUnitBuff("player",386196,"PLAYER")==nil end--Berserker Stance
            local DmgNone=(GeRODPS.time>GeRODPS.NPA.damageEnd)
            local HP=GeRODPS.health_abs>=80
            local CD=function() return GetSpellCooldown(386196)==0 end
            local DmgUnitCastDone=function()
            if UnitExists(GeRODPS.NPA.damageUnit) then
                return not(UnitCastingInfo(GeRODPS.NPA.damageUnit) or UnitChannelInfo(GeRODPS.NPA.damageUnit))
            else
                return true
            end end
            return not aggro and role and known and DmgNone and HP and CD() and DmgUnitCastDone() and nothasBS()
        end},
        {"battle_stance",function()
            local aggro = Hekili.State.aggro
            local role = Hekili.State.role.attack
            local known = Hekili.State:IsKnown(386164)
            local nothasBS=function() return WA_GetUnitBuff("player",386164,"PLAYER")==nil end --battle_stance
            local DmgNone=(GeRODPS.time>GeRODPS.NPA.damageEnd)
            local HP=GeRODPS.health_abs>=80
            local CD=function() return GetSpellCooldown(386164)==0 end
            local DmgUnitCastDone=function()
                if UnitExists(GeRODPS.NPA.damageUnit) then
                    return not(UnitCastingInfo(GeRODPS.NPA.damageUnit) or UnitChannelInfo(GeRODPS.NPA.damageUnit))
                else
                    return true
                end end
            return not aggro and role and known and DmgNone and HP and CD() and DmgUnitCastDone() and nothasBS()
        end},
    },
    ["PALADIN"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion}, -- Healing Potion
    },
    ["HUNTER"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion}, -- Healing Potion
        {"survival_of_the_fittest",function()
            local def = GeRODPS.Options.Def
            local options = GeRODPS.Options.hunter.use_SotF
            local talent = Hekili.State.talent.survival_of_the_fittest.enabled
            local useable = IsUsableSpell(264735)
            local DmgCome=(GeRODPS.time>GeRODPS.NPA.damageStart-2) and (GeRODPS.time<GeRODPS.NPA.damageEnd)
            local CD=GetSpellCooldown(264735)==0
            local hpthreshold = GeRODPS.NPA.damage*4+(100-GeRODPS.health_abs) > GeRODPS.Options.hunter.SotF_threshold
            return hpthreshold and def and options and talent and useable and DmgCome and CD
        end},
    },
    ["ROGUE"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["PRIEST"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["DEATHKNIGHT"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["SHAMAN"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["MAGE"] =
    {
        {"ALT-F8",function()
            return GeRODPS.InGCDnoCast() and GeRODPS.Condition_Use_HealthStone()
        end},
        {"ALT-F7",function()
            return GeRODPS.InGCDnoCast() and GeRODPS.Condition_Use_HealingPotion()
        end},
    },
    ["WARLOCK"] =
    {
        {"ALT-F8",function()
            return GeRODPS.InGCDnoCast() and GeRODPS.Condition_Use_HealthStone()
        end},
        {"ALT-F7",function()
            return GeRODPS.InGCDnoCast() and GeRODPS.Condition_Use_HealingPotion()
        end},
        {"dark_pact",function() --108416
            local incombat = GeRODPS.incombat
            local def = GeRODPS.Options.Def
            local deftrigger = GeRODPS.Options.warlock.use_dark_pact_def_trigger and GeRODPS.time<GeRODPS.NPA.damageEnd
            local hptrigger = GeRODPS.Options.warlock.use_dark_pact_hp_trigger and GeRODPS.health_abs <= GeRODPS.Options.warlock.use_dark_pact_hp_percen
            local trigger = deftrigger or hptrigger
            local inGCD = GeRODPS.InGCDnoCast()
            local known = Hekili.State:IsKnown(108416)
            local CD = GetSpellCooldown(108416)==0
            return incombat and def and trigger and inGCD and known and CD
        end},
        {"unending_resolve",function() --104773
            local def = GeRODPS.incombat and GeRODPS.Options.Def and GeRODPS.Options.warlock.use_unending_def_if_cannot_dark_pact
            local deftrigger = GeRODPS.Options.warlock.use_dark_pact_def_trigger and GeRODPS.time<GeRODPS.NPA.damageEnd and GeRODPS.time>GeRODPS.NPA.damageStart-2
            local hptrigger = GeRODPS.Options.warlock.use_dark_pact_hp_trigger and GeRODPS.health_abs <= 90
            local inGCD=GeRODPS.InGCDnoCast()
            local CD = GetSpellCooldown(104773)==0
            local known = Hekili.State:IsKnown(104773)
            return known and def and deftrigger and hptrigger and inGCD and CD
        end},
        {"burning_rush",function()
            local options = GeRODPS.Options.warlock.cancel_burning_rush
            local talent = Hekili.State.talent.burning_rush.enabled
            local buff = function() return WA_GetUnitBuff("player", "Burning Rush")~=nil end
            local time = GeRODPS.time-GeRODPS.playerStandLastTime>GeRODPS.Options.warlock.cancel_burning_rush_time
            return options and talent and time and buff()
        end},
    },
    ["MONK"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["DRUID"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
        {"renewal",function() --108238
            local incombat = GeRODPS.incombat
            local known = Hekili.State:IsKnown(108238)
            local use = GeRODPS.Options.Def and GeRODPS.Options.druid.use_renewal
            local HP = GeRODPS.health_abs <= GeRODPS.Options.druid.renewal_treshold
            local CD = GetSpellCooldown(108238)==0
            return incombat and known and use and HP and CD and GeRODPS.InGCDnoCast()
        end},
    },
    ["DEMONHUNTER"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["EVOKER"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
    ["NONE"] =
    {
        {"ALT-F8",GeRODPS.Condition_Use_HealthStone},
        {"ALT-F7",GeRODPS.Condition_Use_HealingPotion},
    },
}
function GeRODPS.SSmorethan(n)
    local SS=UnitPower("player",7)
    return SS>=n or SS + (UnitCastingInfo("player")=="Shadow Bolt" and 1 or 0)>=n
end
function GeRODPS.SpecialTreatment(skillName) -- skillName= hekiliaction , return hekili action / "wait"
    if GeRODPS.specID==266 then -- Warlock Demo
        if skillName=="demonbolt" and
        Hekili.DisplayPool.Primary.Buttons[1].Action=="demonbolt" and
        Hekili.DisplayPool.Primary.Buttons[2].Action=="summon_demonic_tyrant" then
            if GeRODPS.SSmorethan(2) then
                return "hand_of_guldan"
            else
                return "summon_demonic_tyrant"
            end
        elseif skillName=="shadow_bolt" and
        Hekili.DisplayPool.Primary.Buttons[1].Action=="shadow_bolt" and
        Hekili.DisplayPool.Primary.Buttons[2].Action=="summon_demonic_tyrant"  then
            if GeRODPS.SSmorethan(2) then
                return "hand_of_guldan"
            else
                return "summon_demonic_tyrant"
            end
        elseif skillName=="shadow_bolt" and
        Hekili.DisplayPool.Primary.Buttons[1].Action=="shadow_bolt" and
        Hekili.DisplayPool.Primary.Buttons[2].Action=="hand_of_guldan" and
        Hekili.DisplayPool.Primary.Buttons[3].Action=="summon_demonic_tyrant" and
        GeRODPS.SSmorethan(2) and
        WA_GetUnitBuff("player","Nether Portal","PLAYER")~=nil then
            return "hand_of_guldan"
        elseif skillName=="call_dreadstalkers" and not IsUsableSpell("call dreadstalkers")  then --call DS
            return "wait"
        elseif skillName=="power_siphon" and-- power_siphon
        Hekili.DisplayPool.Primary.Buttons[1].Action=="power_siphon" and
        Hekili.DisplayPool.Primary.Buttons[2].Action=="summon_demonic_tyrant" then
            return "summon_demonic_tyrant"
        end
    elseif GeRODPS.specID==267 then -- Warlock Destruction
        --[[if skillName=="immolate" and GeRODPS.IsSkillCycle(1) and Hekili.State.buff.active_havoc.expires>0 then
            
        end]]
    elseif GeRODPS.specID==269 then -- monk WW
        if Hekili.State.prev_gcd.history[1]=="fists_of_fury" then -- wait for FoF channel done
            local _, _, _, _, endTimeMS, _, _, spellId = UnitChannelInfo("player")
            if spellId==113656 and (endTimeMS/1000)-GeRODPS.time>0.2 then
                return "wait"
            end
        end
    elseif GeRODPS.specID==103 then -- druid Feral
        if skillName=="tigers_fury" then
            if not IsSpellInRange("rake","target") then
                return "wait"
            end
        elseif skillName=="berserk" then
            if not IsSpellInRange("rake","target") then
                return "wait"
            end
        elseif skillName=="incarnation_avatar_of_ashamane" then
            if not IsSpellInRange("rake","target") then
                return "wait"
            end
        end
    elseif skillName=="manic_grieftorch" then -- all other
        if GeRODPS.Options.manic_grieftorch_GCD_0 and WeakAuras.gcdDuration()>0 then return "wait" end
    end
    return skillName
end

GeRODPS.KeyBind={}
GeRODPS.KeyBind.Key={
    ["ALT-F7"]={"/use Refreshing Healing Potion","ff022702"},
    ["ALT-F8"]={"/use Healthstone\n/run GeRODPS.HealthStoneTime=GeRODPS.time","ff022802"},
    ["ALT-F9"]={"/run print('ALT-F9')","ff022902"},
    ["ALT-F10"]={"/run print('ALT-F10')","ff022a02"},
    ["ALT-F11"]={"/run print('ALT-F11')","ff022b02"},
    ["ALT-F12"]={"/run print('ALT-F12')","ff022c02"},
}
if select(2,UnitClass("player"))=="HUNTER" then
    GeRODPS.KeyBind.Key["ALT-F9"]={"/cast revive pet","ff022902"}
end
if not GeRODPS.KeyBind.Button then
    GeRODPS.KeyBind.Button={}
    for k,v in pairs(GeRODPS.KeyBind.Key) do
        local ButtonName="GeRODPS_"..k
        GeRODPS.KeyBind.Button[k]=CreateFrame('Button', ButtonName, UIParent, "SecureActionButtonTemplate")
        GeRODPS.KeyBind.Button[k]:SetAttribute("type", "macro")
        GeRODPS.KeyBind.Button[k]:SetAttribute("macrotext", v[1]);
        GeRODPS.KeyBind.Button[k]:RegisterForClicks("LeftButtonDown");
        SetBindingClick(k,ButtonName)
        SaveBindings(GetCurrentBindingSet())
    end
end

function GeRODPS.UpdatePotionKey()
    if not InCombatLockdown() then
        local macro="/use "..GeRODPS.Options.CurrentHealingPotion
        GeRODPS.KeyBind.Button["ALT-F7"]:SetAttribute("macrotext", macro);
    else
        C_Timer.After(3,GeRODPS.UpdatePotionKey)
    end
end
C_Timer.After(3,GeRODPS.UpdatePotionKey)
-- Set Console Button
local region
region=WeakAuras.GetRegion("GeRODPS Cycle Interrupt")
if GeRODPS.Options.cycle then
    region:Color(0.1,0.8,0.1)
else
    region:Color(0.5,0.5,0.5)
end

region=WeakAuras.GetRegion("GeRODPS Hekili CD off")
region:Color(0.5,0.5,0.5)
region=WeakAuras.GetRegion("GeRODPS Hekili CD")
region:Color(0.5,0.5,0.5)
for _,v in pairs(region.subRegions) do
    if v.type=="subtext" and v.text_text~="Auto" then
        v:ChangeText(tostring(GeRODPS.Options.CDTTDthreshold))
        break
    end
end
region=WeakAuras.GetRegion("GeRODPS Hekili CD on")
region:Color(0.5,0.5,0.5)

if GeRODPS.Options.CDmode==0 then
    region=WeakAuras.GetRegion("GeRODPS Hekili CD off")
    region:Color(0.8,0.1,0.1)
elseif GeRODPS.Options.CDmode==1 then
    region=WeakAuras.GetRegion("GeRODPS Hekili CD")
    region:Color(0.1,0.8,0.1)
else
    region=WeakAuras.GetRegion("GeRODPS Hekili CD on")
    region:Color(0.5,0.9,0.6)
end

region=WeakAuras.GetRegion("GeRODPS Kick")
if GeRODPS.Options.kick then
    region:Color(0.1,0.8,0.1)
else
    region:Color(0.5,0.5,0.5)
end

region=WeakAuras.GetRegion("GeRODPS Def")
if GeRODPS.Options.Def then
    region:Color(0.1,0.8,0.1)
else
    region:Color(0.5,0.5,0.5)
end

region=WeakAuras.GetRegion("GeRODPS Kick Threshold")
for _,v in pairs(region.subRegions) do
    if v.type=="subtext" and v.text_text~="Threshold" then
        v:ChangeText(tostring(GeRODPS.Options.kickthreshold))
        break
    end
end

region=WeakAuras.GetRegion("GeRODPS HealthStone")
if GeRODPS.Options.UseHealthStone then
    region:Color(0.1,0.8,0.1)
else
    region:Color(0.5,0.5,0.5)
end

region=WeakAuras.GetRegion("GeRODPS HealingPotion")
for k,v in pairs(region.subRegions) do
    if v.type=="subtext" and v.text_text~="Potion" then
        v:ChangeText(GeRODPS.ShortName[GeRODPS.Options.CurrentHealingPotion])
        break
    end
end

local modeText = Hekili:GetToggleState( "mode" )
if modeText=="automatic" then
    modeText="Auto"
elseif modeText=="single" then
    modeText="Single"
end
region=WeakAuras.GetRegion("GeRODPS Hekili Mode")
for k,v in pairs(region.subRegions) do
    if v.type=="subtext" and v.text_text~="Mode" then
        v:ChangeText(modeText)
        break
    end
end

region=WeakAuras.GetRegion("GeRODPS Dispel/Soothe")
if GeRODPS.Options.UseDispel_Soothe then
    region:Color(0.1,0.8,0.1)
else
    region:Color(0.5,0.5,0.5)
end

-- Set Console Button End

-- Load after Hekili Active
GeRODPS.LoadAfterHekiliH=C_Timer.NewTicker(5,function()
    if not Hekili then return end
    for k,v in pairs(Hekili.State.action) do
        -- e.g. Hekili.State.action.bloodbath.gcdType
        if v.gcdType == "off" then
            GeRODPS.offGCDSpellName[k]=true
        end
    end
    GeRODPS.LoadAfterHekiliH:Cancel()
end)

--[[
PLAYER_EQUIPMENT_CHANGED ; arg1 = slots , 13,14 trinket 1 2

Hekili.State.trinket.t1.__ability = "witherbarks_branch" -- ชื่อ trinket
Hekili.State.trinket.t2.__ability = "null_cooldown" -- กดใช้ไม่ได้

Hekili.DB.profile.specs[GeRODPS.specID].items
Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket.t1.__ability].disabled = false / true
Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket[1].__ability].disabled
]]

function GeRODPS.CheckTrinket(n)
    local region=WeakAuras.GetRegion("GeRODPS Trinket"..n)
    local TStatus=Hekili.State.trinket[n].__ability
    Status= TStatus=="null_cooldown" and "null" or TStatus
    if TStatus=="null_cooldown" then
        TStatus="null"
        region:Color(0.5,0.5,0.5)
    else
        if Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket[n].__ability].disabled then
            region:Color(0.8,0.1,0.1)
            TStatus="Off"
        else
            region:Color(0.5,0.9,0.6)
            TStatus="On"
        end
    end
    for k,v in pairs(region.subRegions) do
        if v.type=="subtext" and v.text_text~="Trinket"..n then
            v:ChangeText(TStatus)
            break
        end
    end
end

C_Timer.After(3,function()GeRODPS.CheckTrinket(1)GeRODPS.CheckTrinket(2)end)

if not GeRODPS.PLAYER_EQUIPMENT_CHANGEDFrame then
    GeRODPS.PLAYER_EQUIPMENT_CHANGEDFrame= CreateFrame("Frame")
    GeRODPS.PLAYER_EQUIPMENT_CHANGEDFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    GeRODPS.PLAYER_EQUIPMENT_CHANGEDFrame:SetScript("OnEvent", function(self,event,arg1)
        if arg1 == 13 or arg1 == 14 then
            do
                local t=arg1-12
                if Hekili.State.trinket[t].__ability~="null_cooldown" then
                    Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket[t].__ability].disabled=false
                end
                C_Timer.After(2,function()
                    GeRODPS.CheckTrinket(t)
                end)
            end
        end
    end)
end

function GeRODPS.TrinketOn(n)
    if Hekili.State.trinket[n].__ability~="null_cooldown" then
        Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket[n].__ability].disabled=false
    end
    GeRODPS.CheckTrinket(n)
end
function GeRODPS.TrinketOff(n)
    if Hekili.State.trinket[n].__ability~="null_cooldown" then
        Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket[n].__ability].disabled=true
    end
    GeRODPS.CheckTrinket(n)
end

--Hekili.DB.profile.specs[GeRODPS.specID].abilities.avatar.disabled

function GeRODPS.DisableSkill(s)
    if Hekili.DB.profile.specs[GeRODPS.specID].abilities[s] then
        Hekili.DB.profile.specs[GeRODPS.specID].abilities[s].disabled=true
    else
        print("GeRODPS.DisableSkill cannot find Skill :",s)
    end
end
function GeRODPS.EnableSkill(s)
    if Hekili.DB.profile.specs[GeRODPS.specID].abilities[s] then
        Hekili.DB.profile.specs[GeRODPS.specID].abilities[s].disabled=false
    else
        print("GeRODPS.EnableSkill cannot find Skill :",s)
    end
end
function GeRODPS.GerSkillStatus(s)
    if Hekili.DB.profile.specs[GeRODPS.specID].abilities[s] then
        return Hekili.DB.profile.specs[GeRODPS.specID].abilities[s].disabled and "disabled" or "enabled"
    else
        return "null"
    end
end

local re1=WeakAuras.GetRegion("GeRODPS Hekili CD off")
local re2=WeakAuras.GetRegion("GeRODPS Hekili CD")
local re3=WeakAuras.GetRegion("GeRODPS Hekili CD on")
function GeRODPS.ClickCDMode(mode)
    if mode=="auto" then
        if GeRODPS.Options.CDmode~=1 then
            re1:Color(0.5,0.5,0.5)re2:Color(0.1,0.8,0.1)re3:Color(0.5,0.5,0.5)
            GeRODPS.Options.CDmode=1
        else
            if GeRODPS.Options.CDTTDthreshold<=5 then
                GeRODPS.Options.CDTTDthreshold=10
            else
                GeRODPS.Options.CDTTDthreshold=GeRODPS.Options.CDTTDthreshold+10
            end
            if GeRODPS.Options.CDTTDthreshold>60 then GeRODPS.Options.CDTTDthreshold=5 end
            for k,v in pairs(re2.subRegions) do
                if v.type=="subtext" and v.text_text~="Auto" then
                    v:ChangeText(tostring(GeRODPS.Options.CDTTDthreshold))
                    break
                end
            end
        end
    elseif mode=="off" then
        re1:Color(0.8,0.1,0.1)re2:Color(0.5,0.5,0.5)re3:Color(0.5,0.5,0.5)
        if Hekili.State.toggle.cooldowns then
            Hekili:FireToggle("cooldowns")
        end
        GeRODPS.Options.CDmode=0
    elseif mode=="on" then
        re1:Color(0.5,0.5,0.5)re2:Color(0.5,0.5,0.5)re3:Color(0.5,0.9,0.6)
        if not Hekili.State.toggle.cooldowns then
            Hekili:FireToggle("cooldowns")
        end
        GeRODPS.Options.CDmode=2
    end
end

--BigWigs_timer_init
local owner = {}
if not GeRODPS.BigWigs_GetTimeRemaining then
    if not BigWigsLoader then
        print("BigWigsLoader wasn't loaded when BigWigs timer conditions tried to initialize.")
        function GeRODPS.BigWigs_GetTimeRemaining()
            return 0, 0
        end
    else
        local Timers = {}
        local function stop(module, text)
            for k = #Timers, 1, -1 do
                local t = Timers[k]
                if t.module == module and (not text or t.text == text) then
                    tremove(Timers, k)
                elseif t.start + t.duration < GeRODPS.time then
                    tremove(Timers, k)
                end
            end
        end
        BigWigsLoader.RegisterMessage(owner, "BigWigs_StartBar", function(_, module, key, text, time)
                stop(module, text)
                tinsert(Timers, {module = module, key = key, text = text:lower(), start = GeRODPS.time, duration = time})
        end)
        BigWigsLoader.RegisterMessage(owner, "BigWigs_StopBar", function(_, module, text)
                stop(module, text)
        end)
        BigWigsLoader.RegisterMessage(owner, "BigWigs_StopBars", function(_, module)
                stop(module)
        end)
        BigWigsLoader.RegisterMessage(owner, "BigWigs_OnBossDisable", function(_, module)
                stop(module)
        end)
        BigWigsLoader.RegisterMessage(owner, "BigWigs_OnPluginDisable", function(_, module)
                stop(module)
        end)
        function GeRODPS.BigWigs_GetTimeRemaining(text)
            for k = 1, #Timers do
                local t = Timers[k]
                if t.text:match(text) then
                    local expirationTime = t.start + t.duration
                    local remaining = (expirationTime) - GeRODPS.time
                    if remaining < 0 then remaining = 0 end
                    return remaining, expirationTime
                end
            end
            return 0, 0
        end
    end
end

print(GeRODPS.LoadingStatus)
GeRODPS.LoadingComplete2=true