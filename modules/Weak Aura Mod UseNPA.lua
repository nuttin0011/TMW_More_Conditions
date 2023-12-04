-- setting up some variables
aura_env.userLists = {}
aura_env.defaultLists = {}
aura_env.mergedList = {}
aura_env.ignoreList = {}
aura_env.triggerWatchList = {}
aura_env.soundWatchList = {}

-- table of valid spellTypes for bars. 
-- if the user made a typo or defined a spellType that's not here it'd throw an error.
-- so we check it against this list to catch it.
aura_env.validSpellTypes= {
    ["kick"] = true,
    ["stun"] = true,
    ["frontal"] = true,
    ["swirly"] = true,
    ["tank"] = true,
    ["damage"] = true,
    ["avoid"] = true,
    ["alert"] = true,    
}

-- using this ticker to check unit targets every 100ms
if not _G.THV_Ticker_100ms then
    C_Timer.NewTicker(0.100, function()
            WeakAuras.ScanEvents("THV_Ticker_100ms")
    end)
    setglobal("THV_Ticker_100ms", true)
end


-- used to check nameplate ranges for "avoid" spellType
aura_env.LRC = LibStub("LibRangeCheck-3.0")

-- displays or hides the glow effect.
local LCG = LibStub("LibCustomGlow-1.0")
aura_env.Glow = function(frame,show, spellType, alertColor, interruptReady, ccReady)
    if show then
        LCG.PixelGlow_Start(
            frame,
            alertColor,
            aura_env.settings["glowSettings"][1], -- lineNumber
            aura_env.settings["glowSettings"][2], -- lineSpeed
            aura_env.settings["glowSettings"][3], -- lineLength
            aura_env.settings["glowSettings"][4], -- lineThickness
            aura_env.settings["glowSettings"][5], -- lineOffsetX
            aura_env.settings["glowSettings"][6], -- lineOffsetY
            false,
        "NPA_"..aura_env.id)
        if spellType == "kick" and not interruptReady
        or spellType == "stun" and not ccReady then
            frame["_PixelGlowNPA_"..aura_env.id]:SetScale(0.5) 
        else
            frame["_PixelGlowNPA_"..aura_env.id]:SetScale(1) 
        end
    else
        LCG.PixelGlow_Stop(frame, "NPA_"..aura_env.id)
    end
end

-- function to get just the healthbar of a nameplate. 
local LGF = LibStub("LibGetFrame-1.0")
aura_env.GetNameplate = function(unitNameplate)
    return LGF.GetUnitNameplate(unitNameplate)
end

-- sometimes a channeled cast is preceded by a regular cast with the same id. 
-- both, the cast and the channel, would trigger the sound effect, which we don't want.
-- the first function stores spellIDs of successful casts (not channels) in a list.
-- if a channel happens, the second function compares the channel's spellId with the IDs in the list from before.
-- if we find a match, it means this channel had a precast, in which case we can ignore the sound effect.
aura_env.spellCastList = {}
aura_env.AddSpellToList = function(spellId)
    if aura_env.spellCastList[spellId] == nil then
        aura_env.spellCastList[spellId] = true
    end
end
aura_env.CheckSpellList = function(spellId)
    if aura_env.spellCastList[spellId] then 
        return false -- overwrites the playSound variable in main trigger
    end
    return true
end

aura_env.CheckInterrupt = function()
    for spell,_ in pairs(aura_env.settings["interruptList"]) do
        if spell then
            if IsUsableSpell(spell) and IsSpellKnown(spell) then 
                local _,cd = GetSpellCooldown(spell)
                local _,gcd = GetSpellCooldown(61304)
                if cd - gcd <= 0 then 
                    return true 
                end
            end
        end
    end 
    return false
end

aura_env.CheckCC = function()
    for spell,_ in pairs(aura_env.settings["ccList"]) do
        if spell then
            if IsUsableSpell(spell) and IsSpellKnown(spell) then 
                local _,cd = GetSpellCooldown(spell)
                local _,gcd = GetSpellCooldown(61304)
                if cd - gcd <= 0 then 
                    return true 
                end
            end
        end
    end 
    return false
end

-- this does a bunch of additional checks to determine whether a sound should be played or not.
aura_env.CheckSound = function(spellId, spellType, unitToken, event, enableSound, range, onlyIfTargeted, ttsTargeted, ttsInput)
    -- if the user wants the sound effect only for their target or focus then
    -- this bit will disable the sound if those conditions aren't met.
    local interruptReady = false
    local ccReady = false
    local unmuteIfTargeted = false
    
    if spellType == "kick" then
        if aura_env.settings["playKickTarget"] and aura_env.settings["playKickFocus"] then 
            if not UnitIsUnit(unitToken, "target") 
            and not UnitIsUnit(unitToken, "focus") then
                enableSound = false
            end
            
        elseif (aura_env.settings["playKickTarget"] and not UnitIsUnit(unitToken, "target")) 
        or (aura_env.settings["playKickFocus"] and not UnitIsUnit(unitToken, "focus")) then
            enableSound = false
        end
        
        interruptReady = aura_env.CheckInterrupt()
        if aura_env.settings["playKickInterrupt"] then
            if enableSound then
                if not ttsInput then
                    enableSound = interruptReady
                end
                
                if onlyIfTargeted 
                or ttsTargeted then
                    unmuteIfTargeted = true
                end
            end
        end
        
    elseif spellType == "stun" then
        -- same as above. ignoring cc status if custom TTS input was found.
        ccReady = aura_env.CheckCC()
        if enableSound then
            if not ttsInput then
                enableSound = ccReady
            end
            
            if onlyIfTargeted 
            or ttsTargeted then
                unmuteIfTargeted = true
            end
        end
    end
    
    -- thanks for killing this, blizzard :<
    --[[
    -- if a custom range has been specified in the tags, disable sound if player is out of range.
    if range and enableSound then
        
        local rangeChecker = aura_env.LRC:GetSmartChecker(range, false, true)
        
        local inRange = rangeChecker(unitToken)
        print(UnitName(unitToken), inRange)
        if not inRange then enableSound = false end

end
]]--
    
    -- this prevents a sound from being repeated if a cast goes into a channel with the same spellId.
    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        if not (enableSound and aura_env.CheckSpellList(spellId)) then 
            enableSound = false
            unmuteIfTargeted = false
        end
    end

    return enableSound, interruptReady, ccReady, unmuteIfTargeted
end


-- spellcheck for spellType. if user mistyped a spellType, we'll catch it here and print a warning.
aura_env.Spellcheck = function(spellType)
    -- if spellType is unknown (wrong input by user or a typo) we return.
    if aura_env.validSpellTypes[spellType] == nil then 
        print("!!! M+ Nameplate Alerts")
        print("!!! -- Unknown spellType: \""..spellType.."\"")
        print("!!! -- Probably a typo. Check your lists!")
        return false 
    end
    return true
end


-- this takes the user's spellType string and returns the actual spellType.
-- it then loads the right settings for this spellType and applies any overrides for this specific cast.
aura_env.ParseSpellType = function(spellTypeUser)
    local spellTypeList = {}
    local ttsInput = false
    local ttsTargeted = false
    local spellType, alertColor, enableSound, enableGlow, enableBar, soundFileId, ttsEnable
    local onlyIfTargeted = false
    local ignoreCombat = false
    local delaySound = 0
    local delayTargeting = 0.5
    local range = nil
    local cleu = false
    local spellTypeLookup = {
        ["nosound"]=false,
        ["dosound"]=true,
        ["noglow"]=false,
        ["doglow"]=true,
        ["nobar"]=false,
        ["dobar"]=true,
    }
    
    for str in string.gmatch(spellTypeUser, "[^/]+") do
        table.insert(spellTypeList, str)
    end
    
    spellType = string.lower(spellTypeList[1])
    if aura_env.Spellcheck(spellType) == false then return false end
    
    alertColor,
    enableSound,
    enableGlow,
    enableBar,
    ttsEnable,
    soundFileId = unpack(aura_env.settings[spellType])
    
    if spellType == "tank" and aura_env.settings["isTank"] == false then 
        -- disabling tank alerts for specs that aren't tanking.
        enableGlow = false
        enableBar = false
        enableSound = false
    elseif spellType == "avoid" then
        -- setting default range for avoid spells.
        -- could be changed with a custom tag in the upcoming loop.
        range = 7
    end 
    
    -- applying overrides if any
    for _,v in pairs(spellTypeList) do
        v = string.lower(v)
        if v == "nosound" or v == "dosound" then
            enableSound = spellTypeLookup[v]
        elseif v == "noglow" or v == "doglow" then
            enableGlow = spellTypeLookup[v]
        elseif v == "nobar" or v == "dobar" then
            enableBar = spellTypeLookup[v]
        elseif string.match(v, "ttscustom_") then
            ttsInput = v:gsub("ttscustom_", "")
        elseif string.match(v, "ttsonme_") then
            ttsTargeted = v:gsub("ttsonme_", "")
        elseif string.match(v, "range_") then
            range = v:gsub("range_", "")
            range = tonumber(range)
        elseif string.match(v, "delaysound_") then
            delaySound = v:gsub("delaysound_", "")
            delaySound = tonumber(delaySound)
        elseif string.match(v, "onlyifonme") then
            onlyIfTargeted = true
        elseif string.match(v, "cleustart") then
            cleu = "start"
        elseif string.match(v, "cleusuccess") then
            cleu = "success"
        elseif string.match(v, "ignorecombat") then
            ignoreCombat = true
        elseif string.match(v, "delaytargeting_") then
            delayTargeting = v:gsub("delaytargeting_", "")
            delayTargeting = tonumber(delayTargeting)
        end
    end
    return spellType, alertColor, enableSound, enableGlow, enableBar, soundFileId, ttsEnable, ttsInput, ttsTargeted, onlyIfTargeted,delaySound,range,cleu,ignoreCombat,delayTargeting
end

-- checks combat status of a unit.
aura_env.UnitIsInCombat = function(unitToken)
    if aura_env.NotInCombatWithParty(unitToken) then
        if not aura_env.OwnerInCombat(unitToken) then
            return false
        end
    end
    return true
end

-- returns true if neither player or party members are in combat with this unit.
aura_env.NotInCombatWithParty = function(unitToken)
    local _, status  = UnitDetailedThreatSituation("player", unitToken)
    if status then
        return false
    end
    
    for i=1,4 do
        local partyMember = "party"..i
        if UnitExists(partyMember) then
            if UnitIsUnit(partyMember,unitToken.."target") then
                return false
            end
        end
    end
    return true
end

-- determining if unit is owned by another unit and if the owner is in combat with the group.
-- used to include units that may not be directly in combat with players - like totems.
aura_env.OwnerInCombat = function(minion)
    for i=1,40 do
        local master = "nameplate"..i
        if UnitExists(master) then
            if master ~= minion then
                if UnitIsOwnerOrControllerOfUnit(master, minion) then
                    if not aura_env.NotInCombatWithParty(master) then
                        -- unit is owned and owner is in combat with party
                        return true    
                    end
                end
            end
        end
    end
    return false
end

aura_env.lastPlayed = {
    ["kick"] = GetTime(),
    ["stun"] = GetTime(),
    ["swirly"] = GetTime(),
    ["frontal"] = GetTime(),
    ["avoid"] = GetTime(),
    ["tank"] = GetTime(),
    ["alert"] = GetTime(),
    ["damage"] = GetTime(),
}
aura_env.soundThrottle = 1.5
aura_env.ttsQueue = 0
aura_env.ttsQueueMax = 2
aura_env.ttsIsPlaying = false
aura_env.PlaySound = function(spellType, ttsEnable, ttsInput, soundFileId, delay, priority, unitToken, guid)
    
    if priority then delay = 0 end
    if ttsInput then ttsEnable = true end
    
    if delay == 0 then
        if aura_env.lastPlayed[spellType] then
            if ( GetTime() - aura_env.lastPlayed[spellType] <= aura_env.soundThrottle )
            and not priority then
                return
            else
                aura_env.lastPlayed[spellType] = GetTime()
            end
        end
        
        if ttsEnable then
            -- TTS will not work if not connected to voice chat.
            -- will use regular sounds instead.
            ttsEnable = C_VoiceChat.IsVoiceChatConnected()
        end
        
        if ttsEnable then
            local ttsVoice = aura_env.settings["ttsVoice"]
            local ttsSpeed = aura_env.settings["ttsSpeed"]
            local ttsVolume = aura_env.settings["ttsVolume"]
            
            if not ttsInput then
                ttsInput = spellType
            end
            
            if aura_env.ttsIsPlaying then 
                aura_env.ttsQueue = aura_env.ttsQueue + 1 
            end
            
            if aura_env.ttsQueue >= aura_env.ttsQueueMax then
                priority = true
            end
            
            if priority then
                C_VoiceChat.StopSpeakingText()
                C_Timer.After(0.1, function()
                        C_VoiceChat.SpeakText(ttsVoice, ttsInput, 0, ttsSpeed, ttsVolume)
                end)
            else
                C_VoiceChat.SpeakText(ttsVoice, ttsInput, 0, ttsSpeed, ttsVolume)
            end
        else
            PlaySoundFile(soundFileId, "Master")
        end
        
    else
        local numChecks = delay*10
        aura_env.soundWatchList[guid] = {numChecks, spellType, ttsEnable, ttsInput, soundFileId, priority, unitToken}
    end
    
end

aura_env.PlayAnim = function(unitToken, spellType, enableGlow, interruptReady, ccReady)
    -- pulses the pixelglow when interrupt is ready and "kick" is being cast.
    if not enableGlow then
        return
        
    elseif spellType == "kick" then
        if not interruptReady then
            return
        end
        
    elseif spellType == "stun" then
        if not ccReady then
            return
        end
        
    else
        return 
    end
    
    local frame = aura_env.GetNameplate(unitToken)
    if not frame then return end
    local frameGlow = frame["_PixelGlowNPA_"..aura_env.id]
    if not frameGlow then return end
    frameGlow.animationGroup = frameGlow.animationGroup or frameGlow:CreateAnimationGroup();
    local group = frameGlow.animationGroup;
    
    group.glowScale = group.glowScale or group:CreateAnimation("scale");
    local glowScale = group.glowScale;
    
    local duration = 0.15
    local scale = 4
    frame["_PixelGlowNPA_"..aura_env.id]:SetScale(1)
    
    group:SetLooping("none")
    glowScale:SetDuration(duration);
    glowScale:SetScaleTo(scale, scale)
    group:Play();
    C_Timer.After(duration, function()
            if UnitExists(unitToken) then
                group:Play(true)
            end  
    end)
end

-- when a highlight is delayed, we re-check if the unit still matches after the delay passed.
aura_env.UnitConfirmed = function(unitToken, spellId, guid, channeledCast, checkCasting)    
    if UnitExists(unitToken)  then
        if guid ~= UnitGUID(unitToken) then
            return false
        elseif checkCasting then
            local spellIdTemp
            if channeledCast then
                spellIdTemp = select(8,UnitChannelInfo(unitToken))
            else
                spellIdTemp = select(9,UnitCastingInfo(unitToken))
            end
            if spellId ~= spellIdTemp then
                return false
            end
        else 
            return true
        end
    else
        return false
    end
    return true
end

aura_env.MergeTables = function(tableAdd, tableMain)
    for k,v in pairs(tableAdd) do
        tableMain[k] = v
    end
    return tableMain
end

aura_env.CreateMergedList = function()
    local tables = {
        [1]=aura_env.defaultLists,
        [2]=aura_env.userLists,
    }
    
    for _,table in pairs(tables) do
        for k,v in pairs(table) do
            if v and not aura_env.ignoreList[k] then
                aura_env.MergeTables(k, aura_env.mergedList)
            end
        end
    end
    
    WeakAuras.ScanEvents("NPA_MERGEDLIST", aura_env.mergedList)
    setglobal("NPA_mergedList", aura_env.mergedList)
end

-----------------------------------------------------
------------------ GeRODPS MOD ----------------------
-----------------------------------------------------

local StunSpell={
    [103]={"Mighty Bash"}, -- feral
    [253]={"Intimidation"}, -- BM
    [254]={"Intimidation"}, -- MM
    [255]={"Intimidation"}, -- Sur
}
local function isStunSpellReady()
    if not IROVar.NPA.UseStun[IROSpecID] then return false end
    for k,v in pairs(IROVar.NPA.UseStun[IROSpecID][1]) do
        if IROVar.NPA.UseStun[IROSpecID][2][k] and TMW.CNDT.Env.CooldownDuration(v)==0 then
            return true
        end
    end
    return false
end
C_Timer.After(3,function()
    IROVar=IROVar or {}
    IROVar.UseNPAWA=1
    IROVar.NPA=IROVar.NPA or {}
    IROVar.NPA.SpellID=IROVar.NPA.SpellID or {}
    for k,_ in pairs(aura_env.validSpellTypes) do
        IROVar.NPA.SpellID[k]={}
    end
    IROVar.NPA.UseStun={}-- { [SpecID] = {{"Spell1","Spell1"}, {[spellKnown1],[spellKnown2]}}
    for k,v in pairs(StunSpell) do
        IROVar.NPA.UseStun[k]={{},{}}
        for kk,vv in pairs(v) do
            table.insert(IROVar.NPA.UseStun[k][1],vv)
            table.insert(IROVar.NPA.UseStun[k][2],GetSpellInfo(vv)~=nil)
        end
    end
    if not IROVar.fspecOnEventCallBack["UseNAP"] then
        IROVar.Register_TALENT_CHANGE_scrip_CALLBACK("UseNAP",function() -- recheck Known Skill?
            if not IROVar.NPA.UseStun[IROSpecID] then return end
            for k,v in pairs(IROVar.NPA.UseStun[IROSpecID]) do
                IROVar.NPA.UseStun[IROSpecID][2][k]=GetSpellInfo(v)~=nil
            end
        end)
    end
end)

local GeroCheckSound = aura_env.CheckSound
aura_env.CheckSound = function(...)
    local spellId, spellType, unitToken, event, enableSound, range, onlyIfTargeted, ttsTargeted, ttsInput=...
    local interruptReady, ccReady, unmuteIfTargeted
    enableSound, interruptReady, ccReady, unmuteIfTargeted = GeroCheckSound(...)

    IROVar.NPA.SpellID[spellType][spellId]=1

    if enableSound then
        local n=GetSpellInfo(spellId)
        print(enableSound and "sound" or "NOsound",spellId,spellType,n)
    end
    if spellType=="damage" then
        IROVar.UpdateCounter("npadmgnotify",1)
        C_Timer.After(2,function()
            IROVar.UpdateCounter("npadmgnotify",0)
        end)
    end

    if enableSound and spellType=="kick" and TMW_ST:GetCounter("cyclekick")==1 then
        do
            local tGUID=UnitGUID(unitToken)
            local tToken=unitToken
            if tGUID then
                print("Queue KICK")
                IROVar.TargetEnemy.RegisterTargetting(tGUID,10,function()
                    return not IsMyInterruptSpellReady() or not IROVar.TargetEnemy.IsTargetCasting(tGUID,tToken)
                end)
            end
        end
    end

    if enableSound and spellType=="stun" and TMW_ST:GetCounter("cyclekick")==1 and isStunSpellReady() then
        do
            local tGUID=UnitGUID(unitToken)
            local tToken=unitToken
            if tGUID then
                print("Queue STUN")
                IROVar.TargetEnemy.RegisterTargetting(tGUID,10,function()
                    return not isStunSpellReady() or not IROVar.TargetEnemy.IsTargetCasting(tGUID,tToken)
                end)
            end
        end
    end

    return enableSound, interruptReady, ccReady, unmuteIfTargeted
end
