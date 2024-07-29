-- getting custom sound effects or assigning default ones
local soundTable = {}
local soundVarTable = {
    [1] = { -- kick
        [1] = 569179,
        [2] = aura_env.config.settings.soundKickCustom,
    }, 
    [2] = { -- stun
        [1] = 2138729,
        [2] = aura_env.config.settings.soundStunCustom,
    },
    [3] = { -- frontal
        [1] = 567617,
        [2] = aura_env.config.settings.soundFrontalCustom,
    },
    [4] = { -- swirly
        [1] = 801442,
        [2] = aura_env.config.settings.soundSwirlyCustom,
    },
    [5] = { -- avoid
        --[1] = 2829404, -- sawblade
        [1] = 644612, -- spinning
        --[1] = 978998, -- strike
        [2] = aura_env.config.settings.soundAvoidCustom,
    },
    
    [6] = { -- damage
        [1] = 1495882,
        [2] = aura_env.config.settings.soundDamageCustom,
    },
    
    [7] = { -- alert
        [1] = 1272537,--569545,--567471,--4618271,--1129274,--1129273, --
        [2] = aura_env.config.settings.soundAlertCustom,
    },
    [8] = { -- tank
        [1] = 568121,
        [2] = aura_env.config.settings.soundTankCustom,
    },
    
}
for i=1,8 do
    if soundVarTable[i][2] == 1 then -- means "None" so using Default Sound for this
        soundTable[i] = soundVarTable[i][1]
    else
        soundTable[i] = soundVarTable[i][2]
    end
end

-- settings table that gets passed on to other weakauras via payload of a custom event
aura_env.settings = {
    ["kick"]={
        aura_env.config.settings.colorKick, -- color
        aura_env.config.settings.playKick,  -- play sound effect
        aura_env.config.settings.glowKick,  -- show glow
        aura_env.config.settings.barKick,   -- show castbar
        aura_env.config.settings.ttsKick,   -- enable text-to-speech
        soundTable[1],                      -- sound effect                    
    },
    ["stun"]={
        aura_env.config.settings.colorStun, 
        aura_env.config.settings.playStun, 
        aura_env.config.settings.glowStun, 
        aura_env.config.settings.barStun, 
        aura_env.config.settings.ttsStun,
        soundTable[2],
    },
    ["frontal"]={
        aura_env.config.settings.colorFrontal, 
        aura_env.config.settings.playFrontal, 
        aura_env.config.settings.glowFrontal, 
        aura_env.config.settings.barFrontal, 
        aura_env.config.settings.ttsFrontal,
        soundTable[3],
    },
    ["swirly"]={
        aura_env.config.settings.colorSwirly, 
        aura_env.config.settings.playSwirly, 
        aura_env.config.settings.glowSwirly, 
        aura_env.config.settings.barSwirly, 
        aura_env.config.settings.ttsSwirly,
        soundTable[4],
    },
    ["avoid"]={
        aura_env.config.settings.colorAvoid, 
        aura_env.config.settings.playAvoid, 
        aura_env.config.settings.glowAvoid, 
        aura_env.config.settings.barAvoid, 
        aura_env.config.settings.ttsAvoid,
        soundTable[5],
    },
    ["damage"]={
        aura_env.config.settings.colorDamage, 
        aura_env.config.settings.playDamage, 
        aura_env.config.settings.glowDamage, 
        aura_env.config.settings.barDamage, 
        aura_env.config.settings.ttsDamage,
        soundTable[6],
    },
    
    ["alert"]={
        aura_env.config.settings.colorAlert, 
        aura_env.config.settings.playAlert, 
        aura_env.config.settings.glowAlert, 
        aura_env.config.settings.barAlert, 
        aura_env.config.settings.ttsAlert,
        soundTable[7],
    },
    ["tank"]={
        aura_env.config.settings.colorTank, 
        aura_env.config.settings.playTank, 
        aura_env.config.settings.glowTank, 
        aura_env.config.settings.barTank, 
        aura_env.config.settings.ttsTank,
        soundTable[8],
    },
    ["priority"]={
        aura_env.config.settings.colorPriority,
    },
    ["glowSettings"]={
        aura_env.config.settings.lineNumber,
        aura_env.config.settings.lineSpeed,
        aura_env.config.settings.lineLength,
        aura_env.config.settings.lineThickness,
        aura_env.config.settings.lineOffsetX,
        aura_env.config.settings.lineOffsetY,
    },
    ["iconSettings"]={
        ["kick"] = aura_env.config.settings.iconKick,
        ["stun"] = aura_env.config.settings.iconStun,
        ["frontal"] = aura_env.config.settings.iconFrontal,
        ["swirly"] = aura_env.config.settings.iconSwirly,
        ["avoid"] = aura_env.config.settings.iconAvoid,
        ["damage"] = aura_env.config.settings.iconDamage,
        ["alert"] = aura_env.config.settings.iconAlert,
        ["tank"] = aura_env.config.settings.iconTank,
        ["priority"] = aura_env.config.settings.iconPriority,
        ["stealth"] = aura_env.config.settings.iconStealth,
    },
    ["isTank"] = false, -- this tracks if the player is a tank
    ["playKickTarget"] = false,
    ["playKickFocus"] = false,
    ["playKickOnlyIfInterruptIsReady"] = false,
    ["previewMode"] = aura_env.config.settings.previewMode,
    ["interruptList"] = {},
    ["iconColors"] = true,
    ["alertTargeted"] = aura_env.config.settings.alertTargeted,
    ["alertTargetedNr"] = aura_env.config.settings.alertTargetedNr,
    ["alertTargetedSound"] = aura_env.config.settings.alertTargetedSound,
    ["alertFixated"] = aura_env.config.settings.alertFixated,
    ["alertFixatedIgnoreSpiteful"] = aura_env.config.settings.alertFixatedIgnoreSpiteful,
    ["ttsVoice"] = aura_env.config.settings.ttsVoice,
    ["ttsVolume"] = aura_env.config.settings.ttsVolume,
    ["ttsSpeed"] = aura_env.config.settings.ttsSpeed,
    ["glowFrame"] = aura_env.config.settings.glowFrame,
    ["playerRole"] = nil,
    ["playerCanPurge"] = false,
    ["playerCanSoothe"] = false,
}

if aura_env.config.settings.playKickRule == 2 then
    aura_env.settings["playKickTarget"] = true
elseif aura_env.config.settings.playKickRule == 3 then
    aura_env.settings["playKickFocus"] = true
elseif aura_env.config.settings.playKickRule == 4 then
    aura_env.settings["playKickTarget"] = true
    aura_env.settings["playKickFocus"] = true
end

if aura_env.config.settings.playKickRuleInterrupt == 2 then
    aura_env.settings["playKickOnlyIfInterruptIsReady"] = true
end

-- this checks if the player is a tank
aura_env.CheckForTankSpec = function()
    if UnitLevel("player") < 10 then return false end
    if IsSpellKnown(76671)   -- prot pally, divine bulwark
    or IsSpellKnown(76857)   -- prot warrior, critical block
    or IsSpellKnown(155783)  -- guardian druid, nature's guardian
    or IsSpellKnown(203747)  -- vengeance dh, fel blood
    or IsSpellKnown(77513)   -- blood dk, blood shield
    or IsSpellKnown(117906)  -- brewmaster, elusive brawler  
    then
        return true
    end
    return false
end

-- spells to consider for whether your class has an interrupt ready or not.
-- you can add more spells (like aoe CCs for example) to this list if you wish.
local interruptsList = {
    ["WARRIOR"] = 
    {
        [6552] = true, -- Pummel
        [386071] = true, -- Disrupting Shout
    },
    ["PALADIN"] = 
    {
        [96231] = true, -- Rebuke
        [31935] = true, -- Avenger's Shield
    },
    ["HUNTER"] = 
    {
        [147362] = true, -- Counter Shot
        [187707] = true, -- Muzzle
        [392060] = true, -- Wailing Arrow
    },
    ["ROGUE"] = 
    {
        [1766] = true, -- Kick
    },
    ["PRIEST"] = 
    {
        [15487] = true, -- Silence
    },
    ["DEATHKNIGHT"] = 
    {
        [47528] = true, -- Mind Freeze
    },
    ["SHAMAN"] = 
    {
        [57994] = true, -- Wind Shear
    },
    ["MAGE"] = 
    {
        [2139] = true, -- Counterspell
    },
    ["WARLOCK"] = 
    {
        [19647] = true, -- Spell Lock
        [89766] = true, -- Axe Toss
    },
    ["MONK"] = 
    {
        [116705] = true, -- Spear Hand Strike
    },
    ["DRUID"] = 
    {
        [106839] = true, -- Skullbash
        [78675] = true, -- Solar Beam
    },
    ["DEMONHUNTER"] = 
    {
        [183752] = true, -- Disrupt
        [202137] = true, -- Sigil of Silence
    },
    ["EVOKER"] = 
    {
        [351338] = true, -- Quell
    },
    ["NONE"] = 
    {
    },
}
local _,playerClass = UnitClass("player")
aura_env.settings["interruptList"] = interruptsList[playerClass]
for id,_ in pairs(interruptsList[playerClass]) do
    WeakAuras.WatchSpellCooldown(id)
end

local ccList = {
    ["WARRIOR"] = 
    {
        [46968] = true, -- Shockwave
        [5246] = true, -- Intimidating Shout
        [107570] = true, -- Storm Bolt
    },
    ["PALADIN"] = 
    {
        [115750] = true, -- Blinding Light
        [853] = true, -- Hammer of Justice
    },
    ["HUNTER"] = 
    {
        [19577] = true, -- Intimidation
    },
    ["ROGUE"] = 
    {
        [408] = true, -- Kidney Shot
        [1776] = true, -- Gouge
        [2094] = true, -- Blind
    },
    ["PRIEST"] = 
    {
        [8122] = true, -- Psychic Scream
        [64044] = true, -- Psychic Horror
        [88625] = true, -- Holy Word: Chastise
    },
    ["DEATHKNIGHT"] = 
    {
        [221562] = true, -- Asphyxiate
        [108194] = true, -- Asphyxiate Talent
        [207167] = true, -- Blinding Sleet
    },
    ["SHAMAN"] = 
    {
        [192058] = true, -- Capacitor Totem
        [197214] = true, -- Sundering
        [51490] = true, -- Thunderstorm
    },
    ["MAGE"] = 
    {
        [31661] = true, -- Dragon's Breath
        [157981] = true, -- Blast Wave
    },
    ["WARLOCK"] = 
    {
        [6789] = true, -- Mortal Coil
        [30283] = true, -- Shadowfury
        [5484] = true, -- Howl of Terror
    },
    ["MONK"] = 
    {
        [119381] = true, -- Leg Sweep
        [198898] = true, -- Song of Chi-Ji
        [116844] = true, -- Ring of Peace
    },
    ["DRUID"] = 
    {
        [99] = true, -- Incapacitating Roar
        [132469] = true, -- Typhoon
        [5211] = true, -- Mighty Bash
        [22570] = true, -- Maim
    },
    ["DEMONHUNTER"] = 
    {
        [179057] = true, -- Chaos Nova
        [211881] = true, -- Fel Eruption
        [207684] = true, -- Sigil of Misery
    },
    ["EVOKER"] = 
    {
        [368970] = true, -- Tail Swipe
        [357214] = true, -- Wing Buffet
    },
    ["NONE"] = 
    {
    },
}
aura_env.settings["ccList"] = ccList[playerClass]
for id,_ in pairs(ccList[playerClass]) do
    WeakAuras.WatchSpellCooldown(id)
end

-- playing a preview for TTS voice.
-- idea taken from LiquidWeakAuras.
if not aura_env.saved then aura_env.saved = {} end
if aura_env.saved.ttsVoice and aura_env.config.settings.ttsVoice ~= aura_env.saved.ttsVoice
or aura_env.saved.ttsVolume and aura_env.config.settings.ttsVolume ~= aura_env.saved.ttsVolume
or aura_env.saved.ttsSpeed and aura_env.config.settings.ttsSpeed ~= aura_env.saved.ttsSpeed then
    C_VoiceChat.StopSpeakingText()
    C_Timer.After(0.01, function()
            C_VoiceChat.SpeakText(aura_env.config.settings.ttsVoice, aura_env.config.settings.ttsExample, 1, aura_env.config.settings.ttsSpeed, aura_env.config.settings.ttsVolume)
    end)
end
aura_env.saved.ttsVoice = aura_env.config.settings.ttsVoice
aura_env.saved.ttsVolume = aura_env.config.settings.ttsVolume
aura_env.saved.ttsSpeed = aura_env.config.settings.ttsSpeed

setglobal("NPA_settings", aura_env.settings)

-- used to prompt a cache update for Plater Mod
setglobal("NPA_cacheUpToDate", false)

local UpdateRole = function()
    local classId = select(3,UnitClass("player"))
    local specId = GetSpecialization()
    local role
    
    if classId == 1 then -- Warrior
        role = "mdps"
        if specId == 3 then
            role = "tank"
        end
        
    elseif classId == 2 then -- Paladin
        role = "mdps"
        if specId == 2 then
            role = "tank"
        elseif specId == 1 then
            role = "healer"
        end
        
    elseif classId == 3 then -- Hunter
        role = "rdps"
        if specId == 3 then
            role = "mdps"
        end
        
    elseif classId == 4 then -- Rogue
        role = "mdps"
        
    elseif classId == 5 then -- Priest
        role = "healer"
        if specId == 3 then
            role = "rdps"
        end
        
    elseif classId == 6 then --Deathknight
        role = "mdps"
        if specId == 1 then
            role = "tank"
        end
        
    elseif classId == 7 then -- Shaman
        role = "rdps"
        if specId == 2 then
            role = "mdps"
        elseif specId == 3 then
            role = "healer"
        end
        
    elseif classId == 8 then -- Mage
        role = "rdps"
        
    elseif classId == 9 then -- Warlock
        role = "rdps"
        
    elseif classId == 10 then -- Monk
        role = "tank"
        if specId == 2 then
            role = "healer"
        elseif specId == 3 then
            role = "mdps"
        end
        
    elseif classId == 11 then -- Druid
        role = "rdps"
        if specId == 2 then
            role = "mdps"
        elseif specId == 3 then
            role = "tank"
        elseif specId == 4 then
            role = "healer"
        end
        
    elseif classId == 12 then -- Demon Hunter
        role = "mdps"
        if specId == 2 then
            role = "tank"
        end
        
    elseif classId == 13 then -- Evoker
        role = "rdps"
        if specId == 2 then
            role = "healer"
        end
        
    end
    
    aura_env.settings.playerRole = role
end

local UpdatePurge = function()
    local spellList = {
        [278326] = true, -- Consume Pagic
        [19801] = true, -- Tranquilizing Shot
        [30449] = true, -- Spellsteal
        [528] = true, -- Dispel Magic
        [32375] = true, -- Mass Dispel
        [370] = true, -- Purge
        [378773] = true, -- Greater Purge
    }
    for spell,_ in pairs(spellList) do
        if IsSpellKnown(spell) then
            aura_env.settings.playerCanPurge = true
            return
        end
    end
end

local UpdateSoothe = function()
    local spellList = {
        [2908] = true, -- Soothe
        [374346] = true, -- Overawe
        [19801] = true, -- Tranquilizing Shot
    }
    for spell,_ in pairs(spellList) do
        if IsSpellKnown(spell) then
            aura_env.settings.playerCanSoothe = true
            return
        end
    end
end

aura_env.UpdateSpecSettings = function()
    UpdateRole()
    UpdatePurge()
    UpdateSoothe()
end

aura_env.UpdateSpecSettings()

