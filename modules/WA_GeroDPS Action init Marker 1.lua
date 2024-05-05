--Init

--function GeRODPS.CastSkill(skill,delay,icon) -- skill = Hekili Skill , delay = dealy or 0 , icon = icon or 1

if not _G.GeRODPS then
    setglobal("GeRODPS",{1,2,3})
end
local GeRODPS=GeRODPS
GeRODPS.LoadingComplete=false
GeRODPS.LoadingComplete2=true
GeRODPS.LoadingStatus="GeRODPS Load INCOMPLETE tryto /reload......................"
GeRODPS.time=GetTime()
GeRODPS.timeMarker1sec=GetTime()
GeRODPS.lastsection=0 -- last Calculated + Update if Needed
GeRODPS.LastIcon1Update=0 -- last UpdateIcon if dont update toolong then Forced update 1 times
GeRODPS.LastIcon2Update=0
GeRODPS.LastIcon3Update=0
GeRODPS.class=select(2,UnitClass("player")) -- class e.g. "WARLOCK"
GeRODPS.specID=GetSpecializationInfo(GetSpecialization())
GeRODPS.ZoneName=GetZoneText()
if not GeRODPS.FrameZoneChange then
    GeRODPS.FrameZoneChange = CreateFrame("Frame")
    GeRODPS.FrameZoneChange:RegisterEvent("ZONE_CHANGED")
    GeRODPS.FrameZoneChange:RegisterEvent("ZONE_CHANGED_INDOORS")
    GeRODPS.FrameZoneChange:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    GeRODPS.FrameZoneChange:SetScript("OnEvent", function()
        GeRODPS.ZoneName=GetZoneText()
    end)
end
if not GeRODPS.Frame_Spec then
    GeRODPS.Frame_Spec = CreateFrame("Frame")
    GeRODPS.Frame_Spec:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
    GeRODPS.Frame_Spec:RegisterEvent("PLAYER_TALENT_UPDATE")
    GeRODPS.Frame_Spec:RegisterEvent("TRAIT_CONFIG_UPDATED")
    GeRODPS.Frame_Spec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    GeRODPS.Frame_Spec:SetScript("OnEvent", function()
        GeRODPS.specID=GetSpecializationInfo(GetSpecialization())
    end)
end

GeRODPS.interruptSpell=nil -- interrupt SpellID
GeRODPS.interruptSpellName=nil -- interrupt Spell name
GeRODPS.interruptSpellHekiliName=nil -- interrupt Spell Hekili name
--GeRODPS.interruptSpellReady=nil -- interrupt spell ready ? -- use Hekili interrupt check
GeRODPS.playerTotalAbsorbs=UnitGetTotalAbsorbs("player")
GeRODPS.DefaultOptions={
    ["cycle"]=true,
    ["kick"]=true,
    ["stun"]=true,
    ["kickthreshold"]=40,
    ["Def"]=true,
    ["UseHealthStone"]=true,
    ["CDTTDthreshold"]=30, -- 10-60 sec
    ["CDmode"]=1, -- 0 = off , 1=auto ( use CDTTDthreshold ) , 2=on
    ["CurrentHealingPotion"]=nil,
}
GeRODPS.HealingPotionOptions={
    "Dreamwalker's Healing Potion",
    "Potion of Withering Dreams",
    "Refreshing Healing Potion",
}
GeRODPS.ShortName={
    ["Dreamwalker's Healing Potion"]="Dreamwalker",
    ["Potion of Withering Dreams"]="Withering",
    ["Refreshing Healing Potion"]="Refreshing",
    ["none"]="none"
}

GeRODPS.RealmName=GetRealmName()
GeRODPS.PlayerName=UnitName("player")
GeRODPS.PlayerRealmName=GeRODPS.PlayerName.."-"..GeRODPS.RealmName
GeRODPS.targetTTD=20

GeRODPS.playerStandLastTime=GetTime()

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
    ["ALT-F7"]="ff022702",
    ["ALT-F8"]="ff022802",
    ["ALT-F9"]="ff022902",
    ["ALT-F10"]="ff022a02",
    ["ALT-F11"]="ff022b02",
    ["ALT-F12"]="ff022c02",
}
GeRODPS.div255={}
for i=0,255 do
    GeRODPS.div255[i]=i/255
end

GeRODPS.NoKeyErrorTimeStamp=0
GeRODPS.NoKeyErrorKey=""

GeRODPS.GetKey = function(hekiliSkill)
    if not Hekili or not Hekili.KeybindInfo[hekiliSkill] then return "none" end
    local KeyBindText=Hekili.DB.profile.specs[GeRODPS.specID].abilities[hekiliSkill].keybind
    if KeyBindText and KeyBindText~="" then
        return KeyBindText
    end
    for _,v in pairs(Hekili.KeybindInfo[hekiliSkill].upper) do
        if GeRODPS.KeyToColor[v] then
            return v
        end
    end
    if GeRODPS.time>GeRODPS.NoKeyErrorTimeStamp or GeRODPS.NoKeyErrorKey~=hekiliSkill then
        print("..no skill '"..hekiliSkill.."' in available action bar.")
        GeRODPS.NoKeyErrorTimeStamp=GeRODPS.time+2
        GeRODPS.NoKeyErrorKey=hekiliSkill
    end
    return "none"
end

if not aura_env.saved then aura_env.saved={}end
if not aura_env.saved.GeRODPS then aura_env.saved.GeRODPS={}end
if not aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName] then aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName]={}end
if not aura_env.saved.GeRODPS.offGCDSpellName then aura_env.saved.GeRODPS.offGCDSpellName={}end

local wowversion=select(1,GetBuildInfo())
if aura_env.saved.GeRODPS.offGCDSpellName.Wowversion~=wowversion then
    aura_env.saved.GeRODPS.offGCDSpellName={}
    aura_env.saved.GeRODPS.offGCDSpellName.Wowversion=wowversion
end

GeRODPS.offGCDSpellName=aura_env.saved.GeRODPS.offGCDSpellName

if not aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName].Options then
    aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName].Options={}
end

for k,v in pairs(GeRODPS.DefaultOptions) do
    if aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName].Options[k]==nil then
        aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName].Options[k]=v
    end
end

GeRODPS.Options=aura_env.saved.GeRODPS[GeRODPS.PlayerRealmName].Options
WeakAuras.ScanEvents("GERODPS_OPTIONS")

function GeRODPS._NextHealingPotion()
    local position
    if GeRODPS.Options.CurrentHealingPotion=="none" then
        position=0
    else
        for k,v in ipairs(GeRODPS.HealingPotionOptions) do
            if GeRODPS.Options.CurrentHealingPotion==v then position=k break end
        end
    end
    if not position then return "none" end
    repeat
        position=position+1
        if position>#GeRODPS.HealingPotionOptions then return "none" end
        if GetItemCount(GeRODPS.HealingPotionOptions[position])>0 then return GeRODPS.HealingPotionOptions[position] end
    until false
end

function GeRODPS.NextHealingPotion(forced_Potion)
    GeRODPS.Options.CurrentHealingPotion = forced_Potion or GeRODPS._NextHealingPotion()
    local region=WeakAuras.GetRegion("GeRODPS HealingPotion")
    for _,v in pairs(region.subRegions) do
        if v.type=="subtext" and v.text_text~="Potion" then
            v:ChangeText(GeRODPS.ShortName[GeRODPS.Options.CurrentHealingPotion])
            break
        end
    end
end

function GeRODPS.Select_1_HealingPotion()
    for _,v in ipairs(GeRODPS.HealingPotionOptions) do
        if GetItemCount(v)>0 then return v end
    end
    return "none"
end

C_Timer.After(2,function()
    if not GeRODPS.Options.CurrentHealingPotion or GetItemCount(GeRODPS.Options.CurrentHealingPotion)==0 then
        GeRODPS.Options.CurrentHealingPotion="none"
        GeRODPS.Options.CurrentHealingPotion=GeRODPS.Select_1_HealingPotion()
    end
end)

WeakAuras.ScanEvents("GERODPS_UPDATE","ff000000","ff000000","ff000000")

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
            local SpellName = GetSpellInfo(spell)
            if GeRODPS.class=="WARLOCK" then SpellName="Command Demon" end
            return spell,hekiliName,SpellName
        end
    end
    return nil
end
GeRODPS.interruptSpell,GeRODPS.interruptSpellHekiliName,GeRODPS.interruptSpellName=GeRODPS.CheckInterruptSpell()

GeRODPS.IsMyInterruptSpellReady = function()
    if not GeRODPS.interruptSpell then return false end
    if IsUsableSpell(GeRODPS.interruptSpell) then
        local _,cd = GetSpellCooldown(GeRODPS.interruptSpell)
        if cd==0 or cd==WeakAuras.gcdDuration() then
            return true
        end
    end
    return false
end

if not GeRODPS.CheckInterruptSpellH then
    GeRODPS.CheckInterruptSpellH=C_Timer.NewTicker(2,function()
        GeRODPS.interruptSpell,GeRODPS.interruptSpellHekiliName,GeRODPS.interruptSpellName=GeRODPS.CheckInterruptSpell()
    end)
    GeRODPS.IsMyInterruptSpellReadyH=C_Timer.NewTicker(0.3,
    function()
        GeRODPS.interruptSpellReady=GeRODPS.IsMyInterruptSpellReady()
    end)
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

function GeRODPS.NPA.IsTargetCasting(percenCastCheck) -- percenCast start = 0 , end = 100 , return SpellID
    percenCastCheck=percenCastCheck or 20
    local notInterruptible,spellId,startTimeMS, endTimeMS , casting , _
    casting=true
    _,_,_,startTimeMS, endTimeMS,_,_,notInterruptible,spellId=UnitCastingInfo("target")
    if not spellId then
        casting=false
        _,_,_,startTimeMS, endTimeMS,_,notInterruptible,spellId=UnitChannelInfo("target")
    end
    if not casting then percenCastCheck=10 end -- if channeling interrupt fast

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
GeRODPS.incombatCallBackList={}

GeRODPS.outcombatCallBackList={}
if not GeRODPS.incombatFrame then
    GeRODPS.incombatFrame = CreateFrame("Frame")
    GeRODPS.incombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    GeRODPS.incombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    GeRODPS.incombatFrame:SetScript("OnEvent", function(self, event)
        GeRODPS.incombat = (event=="PLAYER_REGEN_DISABLED")
        if event=="PLAYER_REGEN_DISABLED" then
            -- In Combat
            for _,v in ipairs(GeRODPS.incombatCallBackList) do
                v()
            end
        else
            -- Out Combat
            for _,v in ipairs(GeRODPS.outcombatCallBackList) do
                v()
            end
        end
    end)
end

table.insert(GeRODPS.incombatCallBackList,function()
    SpecID=GetSpecializationInfo(GetSpecialization())
end)
table.insert(GeRODPS.outcombatCallBackList,function()
    wipe(GeRODPS.TargetEnemy.Queue)
    Hekili.DB.profile.specs[SpecID].cycle=old_Hekili_cycle_status
    GeRODPS.TargetEnemy.tGUID=nil
    GeRODPS.TargetEnemy.tDone=return_true_function
    GeRODPS.TargetEnemy.Cycling=false
    GeRODPS.TargetEnemy.Cycle=false
    GeRODPS.TargetEnemy.tPriority=999
    GeRODPS.TargetEnemy.tExpTime=GeRODPS.time+9999
end)

table.insert(GeRODPS.outcombatCallBackList,function()
    if GetItemCount(GeRODPS.Options.CurrentHealingPotion)==0 then
        GeRODPS.Options.CurrentHealingPotion=GeRODPS.Select_1_HealingPotion()
        local r=WeakAuras.GetRegion("GeRODPS HealingPotion")
        for _,v in pairs(r.subRegions) do
            if v.type=="subtext" and v.text_text~="Potion" then
                v:ChangeText(GeRODPS.ShortName[GeRODPS.Options.CurrentHealingPotion])
                break
            end
        end
    end
end)

GeRODPS.PLAYER_TARGET_CHANGEDCallBackList={}
if not GeRODPS.PLAYER_TARGET_CHANGED_frame then
    GeRODPS.PLAYER_TARGET_CHANGED_frame = CreateFrame("Frame")
    GeRODPS.PLAYER_TARGET_CHANGED_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    GeRODPS.PLAYER_TARGET_CHANGED_frame:SetScript("OnEvent", function()
        for _,v in ipairs(GeRODPS.PLAYER_TARGET_CHANGEDCallBackList) do
            v()
        end
    end)
end
table.insert(GeRODPS.PLAYER_TARGET_CHANGEDCallBackList,GeRODPS.TargetEnemy.AfterTargetEnemyMacro)

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
GeRODPS.HealthStoneTime=0

function GeRODPS.Condition_Use_HealthStone()
    return GeRODPS.incombat and GeRODPS.Options.UseHealthStone and
    GeRODPS.health_abs <= GeRODPS.Options.hp_healthstone and
    not GeRODPS.Item_is_not_ready_yet and
    GetItemCount(5512)>0 and
    GetItemCooldown(5512)==0
end

function GeRODPS.Condition_Use_HealingPotion()
    local ans = GeRODPS.time-GeRODPS.HealthStoneTime>1 and
    GeRODPS.incombat and GeRODPS.Options.CurrentHealingPotion~="none" and
    GeRODPS.health_abs <= GeRODPS.Options.hp_healingpotion and
    not GeRODPS.Item_is_not_ready_yet and
    GetItemCount(GeRODPS.Options.CurrentHealingPotion)>0 and
    GetItemCooldown(GeRODPS.Options.CurrentHealingPotion)==0 and
    (GetItemCount(5512)==0 or GetItemCooldown(5512)~=0)
    --if ans then print("Healing Potion Trigger") end
    return ans
end

function GeRODPS.InGCDnoCast()
    return GeRODPS.Options.Def and WeakAuras.gcdDuration()>0 and (UnitCastingInfo("player") or UnitChannelInfo("plater"))~= nil
end

function GeRODPS.CDReady(s)
    local du=select(2,GetSpellCooldown(s))
    return du==0 or du==WeakAuras.gcdDuration()
end

GeRODPS.ExcludeDEF={} -- [Class Name]={["dungeon name1"]=true,["dungeon name2"]=true,...}
GeRODPS.SpecialSkillIcon2={}
GeRODPS.SpecialSkillIcon1={["WARRIOR"] ={},["PALADIN"] ={},["HUNTER"] ={},["ROGUE"] ={},["PRIEST"] ={},["DEATHKNIGHT"] = {},
["SHAMAN"] ={},["MAGE"] = {},["WARLOCK"] ={},["MONK"] ={},["DRUID"] ={},["DEMONHUNTER"] ={},["EVOKER"] ={},["NONE"] ={},}
for k in pairs(GeRODPS.SpecialSkillIcon1) do
    GeRODPS.ExcludeDEF[k]={}
    GeRODPS.SpecialSkillIcon2[k]={}
end



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
-- GeRODPS.Options.cycle_enemy_icon2
function GeRODPS.IsSkillCycle(n) -- return true / false
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended and Recommended.indicator == "cycle"
end

function GeRODPS.IsSkillOffGCD(n)
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    local actionName=Recommended.actionName
    if Hekili.State.trinket[1].__ability==actionName then
        --trinket1
        if WeakAuras.gcdDuration()>0 and select(2,GetItemCooldown(Hekili.State.trinket[1].__id))==0 then
            return true
        end
    elseif Hekili.State.trinket[2].__ability==actionName then
        --trinket2
        if WeakAuras.gcdDuration()>0 and select(2,GetItemCooldown(Hekili.State.trinket[2].__id))==0 then
            return true
        end
    end
    return Recommended and GeRODPS.offGCDSpellName[actionName]
end

function GeRODPS.HekiliActionToColor(HekiliAction) -- input Hekili_Action
    return GeRODPS.KeyToColor[HekiliAction] or
    GeRODPS.KeyToColor[GeRODPS.GetKey(HekiliAction)]
end

function GeRODPS.GetActionFromHikiliRecommended(n)
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended and Recommended.actionName
end

-- e.g. GeRODPS.GetColorFromRecommended(1)
function GeRODPS.GetColorFromRecommended(n)
    local hekiliaction=Hekili.DisplayPool.Primary.Recommendations[n].actionName
    if GeRODPS.skillDelay[hekiliaction] then return false end
    local specialaction=GeRODPS.SpecialTreatment(hekiliaction)
    if specialaction=="wait" then return "ff000000" end

    if specialaction~=hekiliaction then
        for i=1,10 do
            if Hekili.DisplayPool.Primary.Recommendations[i] and
            Hekili.DisplayPool.Primary.Recommendations[i].actionName==specialaction then
                n=i
                break
            end
        end
    end

    local Key=Hekili.DisplayPool.Primary.Buttons[n].Keybinding:GetText()
    if GeRODPS.KeyToColor[Key] then
        GeRODPS._CurrentKey=Key
        GeRODPS._CurrentKeyID=Hekili.DisplayPool.Primary.Recommendations[n].actionID
        return GeRODPS.KeyToColor[Key]
    end
    n=n or 1
    local Recommended=Hekili.DisplayPool.Primary.Recommendations[n]
    GeRODPS._CurrentKey=Recommended and GeRODPS.GetKey(Recommended.actionName)
    GeRODPS._CurrentKeyID=Recommended.actionID
    return Recommended and GeRODPS.KeyToColor[GeRODPS._CurrentKey]
end

-- e.g. GeRODPS.GetSpecialSkillColor(GeRODPS.SpecialSkillIcon1) -- return color or nil
function GeRODPS.GetSpecialSkillColor(SpecialSkillList)
    for _,v in ipairs(SpecialSkillList[GeRODPS.class]) do
        if not GeRODPS.skillDelay[v[1]] and v[2]() then return GeRODPS.HekiliActionToColor(v[1]) end
    end
end

--e.g. GeRODPS.GetKickColorIfNeeded()

function GeRODPS.GetKickColorIfNeeded() -- return Kick Color when Kick needed
    local KickColor=nil
    if not GeRODPS.Options.kick or GeRODPS.skillDelay[GeRODPS.interruptSpellHekiliName] then return false end
    local TargetCastSpellID=GeRODPS.NPA.IsTargetCasting(GeRODPS.Options.kickthreshold)
    if TargetCastSpellID and
        GeRODPS.NPA.SpellID["kick"][TargetCastSpellID] and
        GeRODPS.interruptSpell and
        GeRODPS.interruptSpellReady
    then
        KickColor=GeRODPS.KeyToColor[GeRODPS.GetKey(GeRODPS.interruptSpellHekiliName)]
    end
    return KickColor
end

GeRODPS.offsetGCD=0.28
-- e.g. GeRODPS.GetHekiliSwipeStatus(1) --return true=has swipe active / false
function GeRODPS.GetHekiliSwipeStatus(n)
    GeRODPS.offsetGCD=0.28
    local GCD=Hekili.State.gcd.execute or 1.3
    if GCD<=0.8 then
        GeRODPS.offsetGCD=GeRODPS.Options.system.off_set_click_GCD_07
    elseif GCD<=0.9 then
        GeRODPS.offsetGCD=GeRODPS.Options.system.off_set_click_GCD_08
    elseif GCD<=1 then
        GeRODPS.offsetGCD=GeRODPS.Options.system.off_set_click_GCD_09
    elseif GCD<=1.2 then
        GeRODPS.offsetGCD=GeRODPS.Options.system.off_set_click_GCD_1
    else
        GeRODPS.offsetGCD=GeRODPS.Options.system.off_set_click_GCD_12
    end
    local Recommended1=Hekili.DisplayPool.Primary.Recommendations[n]
    return Recommended1.exact_time and
    Recommended1.exact_time-GeRODPS.time>GeRODPS.offsetGCD
end

GeRODPS._ShouldUseOldKeyH=C_Timer.NewTimer(0.1,function() end)

if not GeRODPS.UNIT_SPELLCAST_frame then
    GeRODPS.UNIT_SPELLCAST_frame = CreateFrame("Frame")
    GeRODPS.UNIT_SPELLCAST_frame:RegisterEvent("UNIT_SPELLCAST_START")
    GeRODPS.UNIT_SPELLCAST_frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    GeRODPS.UNIT_SPELLCAST_frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    GeRODPS.UNIT_SPELLCAST_frame:SetScript("OnEvent", function(self,event,unitToken, castGUID, spellID)
        if unitToken~="player" then return end
        if event=="UNIT_SPELLCAST_START" then
            GeRODPS._ShouldUseOldKey=false
            GeRODPS._OldKey=GeRODPS._CurrentKey
            GeRODPS._OldKeyID=GeRODPS._CurrentKeyID
        elseif event=="UNIT_SPELLCAST_INTERRUPTED" then
            if GeRODPS._OldKeyID==spellID and spellID~=GeRODPS._OldInterrupt then
                GeRODPS._ShouldUseOldKey=true
                GeRODPS._ShouldUseOldKeyH:Cancel()
                GeRODPS._ShouldUseOldKeyH=C_Timer.NewTimer(1,function()
                    GeRODPS._ShouldUseOldKey=false
                    GeRODPS._OldInterrupt=0
                end)
                GeRODPS._RecastIcon=select(3,GetSpellInfo(spellID))
                WeakAuras.ScanEvents("GERODPS_RECAST")
            end
            GeRODPS._OldInterrupt=spellID
        elseif event=="UNIT_SPELLCAST_SUCCEEDED" then
            GeRODPS._ShouldUseOldKey=false
        end
    end)
end

if not GeRODPS.Options.PlayerDPSAverage then GeRODPS.Options.PlayerDPSAverage=UnitHealthMax("player")/10 end
GeRODPS.DPS={}
GeRODPS.DPS.GroupDPSHistory={
    GeRODPS.Options.PlayerDPSAverage,
}
--IROVar.DPS.Average=initDPS   GeRODPS.Options.PlayerDPSAverage
GeRODPS.DPS.nMobLastFight=1
GeRODPS.DPS.CurrentMobAlive=1
GeRODPS.DPS.CalculateMobSum=1
GeRODPS.DPS.CalculateMobTime=1

function GeRODPS.DPS.CalculateDPSAverage() -- Checl After Combat
    local nHistory=#GeRODPS.DPS.GroupDPSHistory
    local n1=math.ceil(nHistory*.2)
    local nn=nHistory-n1+1
    -- calculate from n 20% to 80%
    local n=0
    local sum=0
    for i=n1,nn do
        n=n+1
        sum=sum+GeRODPS.DPS.GroupDPSHistory[i]
    end
    GeRODPS.Options.PlayerDPSAverage=sum/n
end

function GeRODPS.DPS.AddGroupDPSHistory(dps) -- add dps Ascending order
    local n=#GeRODPS.DPS.GroupDPSHistory
    for i=1,n do
        if dps<GeRODPS.DPS.GroupDPSHistory[i] then
            table.insert(GeRODPS.DPS.GroupDPSHistory,i,dps)
            return
        end
    end
    table.insert(GeRODPS.DPS.GroupDPSHistory,dps)
end

function GeRODPS.DPS.DumpGroupDPSLastFight()
    if not Details then return UnitHealthMax("player")/10 end -- if no details

    --get the current combat and the combat time
    local currentCombat = Details:GetCurrentCombat()
    local combatTime = currentCombat:GetCombatTime()
    if combatTime<5 then return 0 end -- if Combat < 5 sec not count
    local nPlayer=0
    --iterate among all actors that performed a heal during the combat
    local totalDPS = 0
    for _, actor in currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
        if (actor:IsPlayer() and actor:IsGroupPlayer()) then
            totalDPS = totalDPS + actor.total
            nPlayer=nPlayer+1
        end
    end
    if nPlayer<1 then nPlayer=1 end
    totalDPS=(totalDPS/combatTime)/nPlayer
    return totalDPS
end

function GeRODPS.DPS.CheckMobIncombat()
    local nMob=Hekili:GetNumTargets()
    if nMob==0 then nMob=1 end
    GeRODPS.DPS.CurrentMobAlive=nMob
    if nMob>=1 then
        GeRODPS.DPS.CalculateMobSum=GeRODPS.DPS.CalculateMobSum+nMob
        GeRODPS.DPS.CalculateMobTime=GeRODPS.DPS.CalculateMobTime+1
    end
end

GeRODPS.DPS.CheckMobIncombatHolder=C_Timer.NewTimer(0.1,function() end)

table.insert(GeRODPS.incombatCallBackList,function()
    GeRODPS.DPS.CheckMobIncombat()
    GeRODPS.DPS.CheckMobIncombatHolder=C_Timer.NewTicker(1,GeRODPS.DPS.CheckMobIncombat)
end)
table.insert(GeRODPS.outcombatCallBackList,function()
    GeRODPS.DPS.CheckMobIncombatHolder:Cancel()
    local TotalDPS=GeRODPS.DPS.DumpGroupDPSLastFight()
    local nMob=GeRODPS.DPS.CalculateMobSum/GeRODPS.DPS.CalculateMobTime
    if nMob<1 then nMob=1 end
    GeRODPS.DPS.CalculateMobSum=1
    GeRODPS.DPS.CalculateMobTime=1
    GeRODPS.DPS.nMobLastFight=nMob
    GeRODPS.DPS.CurrentMobAlive=1
    if TotalDPS<=100 then
        --print("DPS Too Low!! / Or Combat Time too Fast")
        return
    end
    nMob=1+(0.6*(nMob-1))
    local DPSperMob=TotalDPS/nMob
    GeRODPS.DPS.AddGroupDPSHistory(DPSperMob)
    GeRODPS.DPS.CalculateDPSAverage()
end)

function GeRODPS.DPS.PredictTimeToDie()
    local HP=0
    if GeRODPS.Options.Group_TTD then
        if Hekili and Hekili.npGUIDs then
            local targetInclude=false
            local n=0
            for k,_ in pairs(Hekili.npGUIDs) do
                if UnitCanAttack("player",k) and UnitAffectingCombat(k) then
                    n=n+1
                    HP=HP+UnitHealth(k)
                    if UnitIsUnit(k,"target") then targetInclude=true end
                end
            end
            if not targetInclude then
                n=n+1
                HP=HP+UnitHealth("target")
            end
            if HP>0 then
                HP=(HP/n)*(.25*(n-1)+1)
            end
        else
            local targetInclude=false
            for i=1,30 do
                local k="nameplate"..i
                if UnitCanAttack("player",k) and UnitAffectingCombat(k) then
                    HP=HP+UnitHealth(k)
                    if UnitIsUnit(k,"target") then targetInclude=true end
                end
            end
            if not targetInclude then
                HP=HP+UnitHealth("target")
            end
        end
    else
        HP=UnitHealth("target")
    end
    local nGroup=GetNumGroupMembers()
    nGroup=(nGroup==0) and 1 or nGroup
    local DPSmod=((GeRODPS.DPS.CurrentMobAlive-1)*0.4)+1
    return math.floor((HP*GeRODPS.DPS.CurrentMobAlive)/(GeRODPS.Options.PlayerDPSAverage*DPSmod*nGroup))
end

function GeRODPS.DPS.updatetargetTTD()
    GeRODPS.targetTTD=GeRODPS.DPS.PredictTimeToDie()
    if GeRODPS.targetTTD==GeRODPS.OldtargetTTD then return end
    GeRODPS.OldtargetTTD=GeRODPS.targetTTD
    --"GeRODPS targetTTD"
    local r=WeakAuras.GetRegion("GeRODPS targetTTD")
    for _,v in pairs(r.subRegions) do
        if v.type=="subtext" and v.text_text~="TTD" then
            v:ChangeText(tostring(GeRODPS.targetTTD))
            break
        end
    end
end

table.insert(GeRODPS.PLAYER_TARGET_CHANGEDCallBackList,GeRODPS.DPS.updatetargetTTD)
C_Timer.NewTicker(0.8,GeRODPS.DPS.updatetargetTTD)

function GeRODPS.SpecialTreatment(skillName)--function in OnShow
    return skillName
end

GeRODPS.CastSequence={{},{},{}}
GeRODPS.CastSequenceTimeUpdate={}
--[[GeRODPS.CastSkill("evasion",0,2)]]
function GeRODPS.CastSkill(skill,delay,icon,condition,timeout) -- skill = Hekili Skill , delay = dealy or 0 , icon = icon or 1
    if not Hekili.State:IsKnown(skill) then return end
    do
        local s,d,i,c=skill,delay or 0,icon or 1,condition
        local t=timeout and (GeRODPS.time+timeout+d) or (GeRODPS.time+1.2+d)
        C_Timer.After(d,function()
            --if GeRODPS.CDReady(Hekili.State.action[s].name) then
            --table.insert(GeRODPS.CastSequence[i],{s,c})
            GeRODPS.CastSequence[i][1]={s,c,t}
            --else
            --    print("Cannot Use :",s," On CD")
            --end
        end)
    end
end

function GeRODPS.CheckAndRemoveCastSequenceSkill(icon)
    if GeRODPS.CastSequence[icon][1] and Hekili.State.player.lastcast==GeRODPS.CastSequence[icon][1][1] and
    GeRODPS.CastSequenceTimeUpdate[icon] and Hekili.State.player.casttime>GeRODPS.CastSequenceTimeUpdate[icon] then
        table.remove(GeRODPS.CastSequence[icon],1)
        GeRODPS.CastSequenceTimeUpdate[icon]=nil
    end
    if GeRODPS.CastSequence[icon][1] and GeRODPS.CastSequence[icon][1][3]<GeRODPS.time then
        table.remove(GeRODPS.CastSequence[icon],1)
        GeRODPS.CastSequenceTimeUpdate[icon]=nil
    end
end

function GeRODPS.GetColorFromCastSequence(icon)
    local skill=GeRODPS.CastSequence[icon][1] and GeRODPS.CastSequence[icon][1][1]
    if GeRODPS.skillDelay[skill] then return false end
    if skill then
        if GeRODPS.CDReady(Hekili.State.action[skill].name) then
            local condition=GeRODPS.CastSequence[icon][1][2]
            if condition==nil or condition() then
                if not GeRODPS.CastSequenceTimeUpdate[icon] then
                    GeRODPS.CastSequenceTimeUpdate[icon]=GeRODPS.time
                end
                return GeRODPS.KeyToColor[GeRODPS.GetKey(skill)]
            else
                table.remove(GeRODPS.CastSequence[icon],1)
            end
        else
            print("Cannot Use :",skill," On CD")
            GeRODPS.CastSequenceTimeUpdate[icon]=nil
            table.remove(GeRODPS.CastSequence[icon],1)
        end
    end
    return false
end

GeRODPS.skillDelay={}
function GeRODPS.DelaySkill(hekiliSkill,t)
    GeRODPS.skillDelay[hekiliSkill]=GeRODPS.time+t
end

function GeRODPS.CheckSkillDelay()
    for k,v in pairs(GeRODPS.skillDelay) do
        if v<GeRODPS.time then
            GeRODPS.skillDelay[k]=nil
        end
    end
end

GeRODPS.SpellCanReflect={}
GeRODPS.LoadingStatus="GeRODPS Loading Complete"
GeRODPS.LoadingComplete=true