--Init

if not _G.GeRODPS then
    setglobal("GeRODPS",{1,2,3})
end
local GeRODPS=GeRODPS
GeRODPS.time=GetTime()
GeRODPS.lastsection=0 -- last Calculated + Update if Needed
GeRODPS.LastIcon1Update=0 -- last UpdateIcon if dont update toolong then Forced update 1 times
GeRODPS.LastIcon2Update=0
GeRODPS.LastIcon3Update=0
GeRODPS.class=select(2,UnitClass("player")) -- class e.g. "WARLOCK"
GeRODPS.interruptSpell=nil -- interrupt SpellID
--GeRODPS.interruptSpellName=nil -- interrupt Spell name
GeRODPS.interruptSpellHekiliName=nil -- interrupt Spell Hekili name
GeRODPS.interruptSpellReady=nil -- interrupt spell ready ?
GeRODPS.playerTotalAbsorbs=UnitGetTotalAbsorbs("player")
GeRODPS.Options={
    ["cycle"]=true,
    ["kick"]=true,
    ["stun"]=true,
    ["kickthreshold"]=40,
}

GeRODPS.KeyToColor={
    [""]="ff000000",
    ["1"]="ff001100",["2"]="ff001200",["3"]="ff001300",["4"]="ff001400",
    ["5"]="ff001500",["6"]="ff001600",["7"]="ff001700",["8"]="ff001800",
    ["9"]="ff001900",["0"]="ff001a00",["-"]="ff001b00",["="]="ff001c00",
    ["F1"]="ff002100",["F2"]="ff002200",["F3"]="ff002300",
    ["F4"]="ff002400",["F5"]="ff002500",["F6"]="ff002600",
    ["F7"]="ff002700",["CF7"]="ff012701",["SF7"]="ff042704",
    ["F8"]="ff002800",["CF8"]="ff012801",["SF8"]="ff042804",
    ["F9"]="ff002900",["CF9"]="ff012901",["SF9"]="ff042904",
    ["F10"]="ff002a00",["CF10"]="ff012a01",["SF10"]="ff042a04",
    ["F11"]="ff002b00",["CF11"]="ff012b01",["SF11"]="ff042b04",
    ["F12"]="ff002c00",["CF12"]="ff012c01",["SF12"]="ff042c04",
    ["cycle"]="ff0a010a", -- click next enemy
}
GeRODPS.div255={}
for i=0,255 do
    GeRODPS.div255[i]=i/255
end

GeRODPS.GetKey = function(hekiliSkill)
    if not Hekili or not Hekili.KeybindInfo[hekiliSkill] then return "none" end
    for _,v in pairs(Hekili.KeybindInfo[hekiliSkill].upper) do
        if GeRODPS.KeyToColor[v] then
            return v
        end
    end
    return "none"
end

if not aura_env.saved then
    aura_env.saved={}
end
if not aura_env.saved.offGCDSpellName then
    aura_env.saved.offGCDSpellName={}
end
local wowversion=select(1,GetBuildInfo())
if aura_env.saved.offGCDSpellName.Wowversion~=wowversion then
    aura_env.saved.offGCDSpellName={}
    aura_env.saved.offGCDSpellName.Wowversion=wowversion
end
GeRODPS.offGCDSpellName=aura_env.saved.offGCDSpellName

WeakAuras.ScanEvents("GERODPS_UPDATE","ff000000","ff000000")

GeRODPS.interruptsList = {
    ["WARRIOR"] = 
    {
        [6552] = "pummel", -- Pummel
        --[386071] = true, -- Disrupting Shout
    },
    ["PALADIN"] = 
    {
        [96231] = "rebuke", -- Rebuke
        --[31935] = true, -- Avenger's Shield
    },
    ["HUNTER"] = 
    {
        [147362] = "counter_shot", -- Counter Shot
        [187707] = "muzzle", -- Muzzle
        --[392060] = true, -- Wailing Arrow
    },
    ["ROGUE"] = 
    {
        [1766] = "kick", -- Kick
    },
    ["PRIEST"] = 
    {
        [15487] = "silence", -- Silence
    },
    ["DEATHKNIGHT"] = 
    {
        [47528] = "mind_freeze", -- Mind Freeze
    },
    ["SHAMAN"] = 
    {
        [57994] = "wind_shear", -- Wind Shear
    },
    ["MAGE"] = 
    {
        [2139] = "counterspell", -- Counterspell
    },
    ["WARLOCK"] = 
    {
        [19647] = "spell_lock", -- Spell Lock
        [89766] = "axe_toss", -- Axe Toss
    },
    ["MONK"] = 
    {
        [116705] = "spear_hand_strike", -- Spear Hand Strike
    },
    ["DRUID"] = 
    {
        [106839] = "skullbash", -- Skullbash
        [78675] = "solar_beam", -- Solar Beam
    },
    ["DEMONHUNTER"] = 
    {
        [183752] = "disrupt", -- Disrupt
        --[202137] = true, -- Sigil of Silence
    },
    ["EVOKER"] = 
    {
        [351338] = "quell", -- Quell
    },
    ["NONE"] = 
    {
    },
}


GeRODPS.CheckInterruptSpell = function()
    for spell,hekiliName in pairs(GeRODPS.interruptsList[GeRODPS.class]) do
        if IsSpellKnown(spell) or IsSpellKnown(spell, true) then
            return spell,hekiliName
        end
    end
    return nil
end
GeRODPS.interruptSpell=GeRODPS.CheckInterruptSpell()
GeRODPS.IsMyInterruptSpellReady = function()
    if not GeRODPS.interruptSpell then return false end
    if IsUsableSpell(GeRODPS.interruptSpell) then
        local _,cd = GetSpellCooldown(GeRODPS.interruptSpell)
        local _,gcd = GetSpellCooldown(61304)
        if cd - gcd <= 0 then
            return true
        end
    end
    return false
end

if not GeRODPS.CheckInterruptSpellH then
    GeRODPS.CheckInterruptSpellH=C_Timer.NewTicker(2,function()
        GeRODPS.interruptSpell,GeRODPS.interruptSpellHekiliName=GeRODPS.CheckInterruptSpell()
    end)
    GeRODPS.IsMyInterruptSpellReadyH=C_Timer.NewTicker(0.3,function()GeRODPS.interruptSpellReady=GeRODPS.IsMyInterruptSpellReady()end)
end

GeRODPS.NPA={}
GeRODPS.NPA.validSpellTypes= {
    ["kick"] = true,
    ["stun"] = true,
    ["frontal"] = true,
    ["swirly"] = true,
    ["tank"] = true,
    ["damage"] = true,
    ["avoid"] = true,
    ["alert"] = true,
}
GeRODPS.NPA.SpellID={}
for k,_ in pairs(GeRODPS.NPA.validSpellTypes) do
    GeRODPS.NPA.SpellID[k]={}
end

GeRODPS.NPA.IsTargetCasting = function(percenCastCheck) -- percenCast start = 0 , end = 100 , return SpellID
    percenCastCheck=percenCastCheck or 20
    local notInterruptible,spellId,startTimeMS, endTimeMS , casting
    casting=true
    _,_,_,startTimeMS, endTimeMS,_,_,notInterruptible,spellId=UnitCastingInfo("target")
    if not spellId then
        casting=false
        _,_,_,startTimeMS, endTimeMS,_,notInterruptible,spellId=UnitChannelInfo("target")
    end
    if not casting then percenCastCheck=15 end -- if channeling interrupt fast

    if not spellId then return false end
    startTimeMS=startTimeMS/1000
    endTimeMS=endTimeMS/1000
    local castTime=endTimeMS-startTimeMS
    local casted=GeRODPS.time-startTimeMS
    local percenCast=(casted/castTime)*100
    if percenCast>percenCastCheck then
        return spellId
    else
        return false
    end
end

GeRODPS.NPA.damage = 0 -- 0 none , 1 medium , 2 heavy
GeRODPS.NPA.damageStart = 0
GeRODPS.NPA.damageEnd = 0
GeRODPS.NPA.damageUnit = "target"
GeRODPS.NPA.damageUnitGUID = ""
GeRODPS.NPA.damageSpellID = 0

GeRODPS.TargetEnemy={}----------------------------------------
local function return_true_function() return true end
GeRODPS.TargetEnemy.Cycling=false -- true until all job done
GeRODPS.TargetEnemy.CyclingH=C_Timer.NewTimer(0.1,function() end)
GeRODPS.TargetEnemy.Cycle=false -- true if want to swap
GeRODPS.TargetEnemy.CycleH=C_Timer.NewTimer(0.1,function() end)
GeRODPS.TargetEnemy.Queue={}
GeRODPS.TargetEnemy.Pause=false
GeRODPS.TargetEnemy.tGUID=nil
GeRODPS.TargetEnemy.tDone=return_true_function
GeRODPS.TargetEnemy.tPriority=999
GeRODPS.TargetEnemy.tTimesClick=1
GeRODPS.TargetEnemy.tExpTime=GeRODPS.time+9999

local SpecID=GetSpecializationInfo(GetSpecialization())

local old_Hekili_cycle_status = Hekili.DB.profile.specs[SpecID].cycle

function GeRODPS.TargetEnemy.RegisterTargetting(unitGUID,priority,DoneThisFunc,name,ExpTime)
    table.insert(GeRODPS.TargetEnemy.Queue,
        {
            ["TargetGUID"]=unitGUID,
            ["priority"]=priority,
            ["DoneThis"]=DoneThisFunc,
            ["Name"]=name or "noname",
            ["ExpTime"]=GeRODPS.time + (ExpTime or 3.4),
        })
    if not GeRODPS.TargetEnemy.Cycling or priority<GeRODPS.TargetEnemy.tPriority then
        GeRODPS.TargetEnemy.NextJob()
    end
end

function GeRODPS.TargetEnemy.FindJobName(name) -- return #index in queue / nil if not found
    for k,v in ipairs(GeRODPS.TargetEnemy.Queue) do
        if v.Name==name then
            return k
        end
    end
    return nil
end

function GeRODPS.TargetEnemy.NextJob()
    local min=999
    local vv
    local deleteTable={}
    for k,v in ipairs(GeRODPS.TargetEnemy.Queue) do
        if v.DoneThis() or GeRODPS.time>v.ExpTime then
            table.insert(deleteTable,k)
        else
            if min>v.priority then
                min=v.priority
                vv=v
            end
        end
    end
    if vv then
        if not GeRODPS.TargetEnemy.Cycling then
            old_Hekili_cycle_status=Hekili.DB.profile.specs[SpecID].cycle -- keep Hekili Auto Cycle status
        end
        Hekili.DB.profile.specs[SpecID].cycle=false -- turn off Hekili Auto Cycle
        if UnitGUID("target")==vv.TargetGUID then
            print("FoundEnemy")
            GeRODPS.TargetEnemy.Cycle=false
        else
            GeRODPS.TargetEnemy.Cycle=true
        end
        GeRODPS.TargetEnemy.Cycling=true
        GeRODPS.TargetEnemy.tGUID=vv.TargetGUID
        GeRODPS.TargetEnemy.tDone=vv.DoneThis
        GeRODPS.TargetEnemy.tPriority=vv.priority
        GeRODPS.TargetEnemy.tExpTime=vv.ExpTime
    else
        Hekili.DB.profile.specs[SpecID].cycle=old_Hekili_cycle_status-- turn Hekili Auto Cycle to old value
        GeRODPS.TargetEnemy.tGUID=nil
        GeRODPS.TargetEnemy.tDone=return_true_function
        GeRODPS.TargetEnemy.Cycling=false
        GeRODPS.TargetEnemy.Cycle=false
        GeRODPS.TargetEnemy.tPriority=999
        GeRODPS.TargetEnemy.tExpTime=GeRODPS.time+9999
    end
    for i=#deleteTable,1,-1 do
        table.remove(GeRODPS.TargetEnemy.Queue,deleteTable[i])
    end
end

local lastTimeCheck = GeRODPS.time

function GeRODPS.TargetEnemy.IntervalCheck() -- run check every 0.15 sec if Cycling
    if #GeRODPS.TargetEnemy.Queue==0 or GeRODPS.time < lastTimeCheck+0.15 then return end -- should Kill Tick Check interval
    if GeRODPS.TargetEnemy.tDone() or GeRODPS.time > GeRODPS.TargetEnemy.tExpTime then
        GeRODPS.TargetEnemy.NextJob()
    elseif UnitGUID("target")~=GeRODPS.TargetEnemy.tGUID and not GeRODPS.TargetEnemy.Cycle then
        GeRODPS.TargetEnemy.Cycle=true
    end
end

if not GeRODPS.TargetEnemy.IntervalCheckH then
    GeRODPS.TargetEnemy.IntervalCheckH=C_Timer.NewTicker(0.15,GeRODPS.TargetEnemy.IntervalCheck)
end

---ClickMouse To Change Target is Pause Targeting for 1 sec

function GeRODPS.TargetEnemy.AfterTargetEnemyMacro() -- Use after PLAYER_TARGET_CHANGED
    lastTimeCheck = GeRODPS.time
    if #GeRODPS.TargetEnemy.Queue==0 or not GeRODPS.Options.cycle then return end
    if UnitGUID("target")==GeRODPS.TargetEnemy.tGUID then print("FoundEnemy") end
    if GeRODPS.TargetEnemy.tDone() or GeRODPS.time > GeRODPS.TargetEnemy.tExpTime then
        WeakAuras.ScanEvents("GERODPS_UPDATE",nil,nil,"ff000000")
        GeRODPS.TargetEnemy.NextJob()
    elseif UnitGUID("target")==GeRODPS.TargetEnemy.tGUID then
        GeRODPS.TargetEnemy.Cycle=false
        WeakAuras.ScanEvents("GERODPS_UPDATE",nil,nil,"ff000000")
        return true
    else
        GeRODPS.TargetEnemy.Cycle=true
        WeakAuras.ScanEvents("GERODPS_UPDATE",nil,nil,GeRODPS.KeyToColor["cycle"])
        return false
    end
end

function GeRODPS.TargetEnemy.IsUnitCasting(tGUID,tUnitToken) -- Check Target token/GUID is casting?
    if UnitGUID(tUnitToken)~=tGUID then
        tUnitToken=Hekili.npUnits[tGUID]
        if not tUnitToken then return end
    end
    local n=UnitCastingInfo(tUnitToken)
    if not n then
        n=UnitChannelInfo(tUnitToken)
    end
    if n then return true else return false end
end

GeRODPS.incombat = UnitAffectingCombat("player")
if not GeRODPS.incombatFrame then
    GeRODPS.incombatFrame = CreateFrame("Frame")
    GeRODPS.incombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    GeRODPS.incombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    GeRODPS.incombatFrame:SetScript("OnEvent", function(self, event)
        GeRODPS.incombat = (event=="PLAYER_REGEN_DISABLED")
        if event=="PLAYER_REGEN_DISABLED" then
            -- In Combat
            SpecID=GetSpecializationInfo(GetSpecialization())
        else
            -- Out Combat
            wipe(GeRODPS.TargetEnemy.Queue)
            Hekili.DB.profile.specs[SpecID].cycle=old_Hekili_cycle_status
            GeRODPS.TargetEnemy.tGUID=nil
            GeRODPS.TargetEnemy.tDone=return_true_function
            GeRODPS.TargetEnemy.Cycling=false
            GeRODPS.TargetEnemy.Cycle=false
            GeRODPS.TargetEnemy.tPriority=999
            GeRODPS.TargetEnemy.tExpTime=GeRODPS.time+9999
        end
    end)
end

if not GeRODPS.PLAYER_TARGET_CHANGED_frame then
    GeRODPS.PLAYER_TARGET_CHANGED_frame = CreateFrame("Frame")
    GeRODPS.PLAYER_TARGET_CHANGED_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    GeRODPS.PLAYER_TARGET_CHANGED_frame:SetScript("OnEvent", GeRODPS.TargetEnemy.AfterTargetEnemyMacro)
end

GeRODPS.UI_ERROR_MESSAGE_handle=C_Timer.NewTimer(0.1,function() end)
if not GeRODPS.UI_ERROR_MESSAGE_frame then
    GeRODPS.UI_ERROR_MESSAGE_frame = CreateFrame("Frame")
    GeRODPS.UI_ERROR_MESSAGE_frame:RegisterEvent("UI_ERROR_MESSAGE")
    GeRODPS.UI_ERROR_MESSAGE_frame:SetScript("OnEvent", function(self,event,arg1,arg2)
        local errorText1="Item is not ready yet."
        if arg2==errorText1 then
            GeRODPS.UI_ERROR_MESSAGE_handle:Cancel()
            GeRODPS.Item_is_not_ready_yet=true
            GeRODPS.UI_ERROR_MESSAGE_handle=C_Timer.NewTimer(3,function()
                GeRODPS.Item_is_not_ready_yet=false
            end)
        end
    end)
end
--[[
    ["WARLOCK"] = 
    {
        [spellID] = {HekiliName,CallBack() return true = use}
        [108416] = {"dark_pact",
]]

GeRODPS.health_pct=100
GeRODPS.health_max=UnitHealthMax("player")
GeRODPS.health_current=UnitHealth("player")

function GeRODPS.Condition_Use_HealthStone()
    return GeRODPS.health_abs <= 35 and GeRODPS.Item_is_not_ready_yet and GetItemCooldown("Healthstone")==0
end

GeRODPS.SpecialSkillIcon1 = {
    ["WARRIOR"] =
    {
    },
    ["PALADIN"] = 
    {
    },
    ["HUNTER"] = 
    {
    },
    ["ROGUE"] = 
    {
    },
    ["PRIEST"] = 
    {
    },
    ["DEATHKNIGHT"] = 
    {
    },
    ["SHAMAN"] = 
    {
    },
    ["MAGE"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["WARLOCK"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
        {"dark_pact",function() --id 108416
            return (GeRODPS.time<GeRODPS.NPA.damageEnd or GeRODPS.health_abs <= 50) and
            Hekili.State:IsKnown(108416) and --known
            GetSpellCooldown(108416)==0 -- ready
        end},
    },
    ["MONK"] = 
    {
    },
    ["DRUID"] = 
    {
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
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["PALADIN"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["HUNTER"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["ROGUE"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["PRIEST"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["DEATHKNIGHT"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["SHAMAN"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["MAGE"] = 
    {
    },
    ["WARLOCK"] = 
    {
    },
    ["MONK"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["DRUID"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["DEMONHUNTER"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["EVOKER"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
    ["NONE"] = 
    {
        {"healthstone",GeRODPS.Condition_Use_HealthStone},
    },
}
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
priority Icon1
Def Skill GCD / Cannot cast while Casting
Cycle Skill
Break GCD
Skill GCD

priority Icon2
Def Skill off GCD
Skill Off GCD

priority Icon3
Cycle Kick
Kick
]]

-- e.g. GeRODPS.IsSkillCycle(1)
function GeRODPS.IsSkillCycle(n) -- return true / false
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended and Recommended.indicator == "cycle"
end

function GeRODPS.IsSkillOffGCD(n)
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended and GeRODPS.offGCDSpellName[Recommended.actionName]
end

function GeRODPS.HekiliActionToColor(HekiliAction) -- input Hekili_Action
    return GeRODPS.KeyToColor[GeRODPS.GetKey(HekiliAction)]
end

function GeRODPS.GetActionFromHikiliRecommended(n)
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended and Recommended.actionName
end

-- e.g. GeRODPS.GetColorFromRecommended(1)
function GeRODPS.GetColorFromRecommended(n)
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended and GeRODPS.KeyToColor[GeRODPS.GetKey(Recommended.actionName)]
end

-- e.g. GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon1) -- return color or nil
function GeRODPS.GetSpecialSkillColor(SpecialSkillList)
    for _,v in ipairs(SpecialSkillList[GeRODPS.class]) do
        if v[2]() then return GeRODPS.HekiliActionToColor(v[1]) end
    end
end

--e.g. GeRODPS.GetKickColorIfNeeded()
function GeRODPS.GetKickColorIfNeeded() -- return Kick Color when Kick needed
    local KickColor=nil
    local TargetCastSpellID=GeRODPS.NPA.IsTargetCasting(GeRODPS.Options.kickthreshold)
    if TargetCastSpellID and
    GeRODPS.NPA.SpellID["kick"][TargetCastSpellID] and
    GeRODPS.interruptSpell and
    GeRODPS.interruptSpellReady
    then
        KickColor=GeRODPS.KeyToColor[GeRODPS.GetKey(GeRODPS.interruptSpellHekiliName)]
        if not KickColor then
            print("no Interrupt Spell in available Bar !!!!")
        end
    end
    return KickColor
end

GeRODPS.offsetGCD=0.28
-- e.g. GeRODPS.GetHekiliSwpieStatus(1) --return true=has swipe active / false
function GeRODPS.GetHekiliSwpieStatus(n)
    GeRODPS.offsetGCD=0.28
    local GCD=Hekili.State.gcd.execute or 1.3
    if GCD<=0.9 then
        GeRODPS.offsetGCD=0.08
    elseif GCD<=1 then
        GeRODPS.offsetGCD=0.15
    elseif GCD<=1.1 then
        GeRODPS.offsetGCD=0.2
    end
    local Recommended1=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended1.exact_time and
    Recommended1.exact_time-GetTime()>GeRODPS.offsetGCD
end