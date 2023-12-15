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
--aura_env.LRC = LibStub("LibRangeCheck-3.0")

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
            if IsUsableSpell(spell) and (IsSpellKnown(spell) or IsSpellKnown(spell, true)) then 
                --if IsUsableSpell(spell) and IsSpellKnown(spell) then 
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
            if IsUsableSpell(spell) and (IsSpellKnown(spell) or IsSpellKnown(spell, true)) then 
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
    
    -- range-check using player's abilities.
    -- accuray depends on the spec but better than nothing.
    if range then
        local inRange = aura_env.CheckRange(range, unitToken)
        if not inRange then enableSound = false end  
    end
    
    -- Range-check using LibRangeCheck. Disabled for now in favor of a custom range-check.
    -- If this ever gets improved, LibRangeCheck is loaded in line 33
    --[[
    -- if a custom range has been specified in the tags, disable sound if player is out of range.
    if range then
        
        local rangeChecker = aura_env.LRC:GetSmartChecker(range, false, true)
        
        local inRange = rangeChecker(unitToken)
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
        
        --[[
    elseif spellType == "avoid" then
        -- setting default range for avoid spells.
        -- could be changed with a custom tag in the upcoming loop.
        range = 7
        ]]--
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
        elseif string.match(v, "delaytargetcheck_") then
            delayTargeting = v:gsub("delaytargetcheck_", "")
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
                
            elseif priority 
            and ( GetTime() - aura_env.lastPlayed[spellType] <= 0.2 ) then
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

aura_env.UpdateSpellRangeList = function()
    aura_env.rangeTableUnsorted = {}
    aura_env.rangeTable = {}
    
    -- iterate through spellbook to get all known harmful spells.
    -- dumping them in an unsorted list with their range as the key.
    for i = 1, GetNumSpellTabs() do
        local _, _, offset, numSlots = GetSpellTabInfo(i)
        for j = offset+1, offset+numSlots do
            local spellType, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
            local spellInfo = C_SpellBook.GetSpellInfo(id)
            if spellInfo then
                
                local minRange = spellInfo["minRange"]
                if minRange == 0 then
                    minRange = 5
                end
                
                local spellName = spellInfo["name"]
                local isHarmful = IsHarmfulSpell(j, BOOKTYPE_SPELL)
                if isHarmful and IsSpellKnown(id) and SpellHasRange(spellName) then
                    if not aura_env.rangeTableUnsorted[minRange] then
                        aura_env.rangeTableUnsorted[minRange] = {}
                    end
                    aura_env.rangeTableUnsorted[minRange][spellName] = true
                end
            end
        end
    end
    
    -- this sorts the previous list by range.
    local sortedKeys = {}
    for i in pairs(aura_env.rangeTableUnsorted) do table.insert(sortedKeys, i) end
    table.sort(sortedKeys)
    
    for _,v in ipairs(sortedKeys) do
        table.insert(aura_env.rangeTable, {[v] = aura_env.rangeTableUnsorted[v]})
    end
    
end

-- returns true if player is within the specified range of a given unit.
-- also returns true if the closest spell to check is already out of range.
aura_env.CheckRange = function(rangeToTest, unitToken)
    if not UnitExists(unitToken) then
        return false
    end
    
    for index, rangeTable in pairs(aura_env.rangeTable) do
        for rangeValue, spellList in pairs(rangeTable) do 
            for spellName, status in pairs(spellList) do
                if status then
                    if rangeValue < rangeToTest then
                        local spellInRange = IsSpellInRange(spellName, unitToken)
                        if spellInRange == 1 then
                            return true
                        end
                        
                    else
                        local spellInRange = IsSpellInRange(spellName, unitToken)
                        if spellInRange == 1 then
                            return true                            
                        else
                            return false
                        end
                        
                    end
                    
                end
            end
        end
    end
    
    return true
end

-----------------------------------------------------
------------------ GeRODPS MOD ----------------------
-----------------------------------------------------
-----------------------------------------------------
------------------ GeRODPS MOD ----------------------
-----------------------------------------------------

local StunSpell={
    -- [65]={},
    [103]={"Mighty Bash"}, -- feral
    [253]={"Intimidation"}, -- BM
    [254]={"Intimidation"}, -- MM
    [255]={"Intimidation"}, -- Sur
    [259]={"Kidney Shot","Gouge","Blind"}, -- ass
    [260]={"Kidney Shot","Gouge","Blind"}, -- outlaw
    [261]={"Kidney Shot","Gouge","Blind"}, -- sub
    [265]={"Fear"}, -- aff
    [266]={"Fear"}, -- demo
    [267]={"Fear"}, -- des
    [71]={"Storm Bolt","Shockwave","Intimidating Shout"}, -- war arm
    [72]={"Storm Bolt","Shockwave","Intimidating Shout"}, -- war fury
    [73]={"Storm Bolt","Shockwave","Intimidating Shout"}, -- war port
    [65]={"Hammer of Justice"},-- Holy
    [66]={"Hammer of Justice"},-- Port
    [67]={"Hammer of Justice"},-- Ret
}
local StunSpellKnown={}

local function isStunSpellReady()
    if not StunSpell[IROSpecID] then return false end
    for k,v in ipairs(StunSpell[IROSpecID]) do
        if StunSpellKnown[IROSpecID][k] and TMW.CNDT.Env.CooldownDuration(v)==0 then
            return true
        end
    end
    return false
end
C_Timer.After(3,function()
        if not IROVar then return end
        IROVar.UseNPAWA=1
        IROVar.NPA=IROVar.NPA or {}
        IROVar.NPA.SpellID=IROVar.NPA.SpellID or {}
        IROVar.NPA.isStunSpellReady=isStunSpellReady
        for k,_ in pairs(aura_env.validSpellTypes) do
            IROVar.NPA.SpellID[k]={}
        end

        for k,v in pairs(StunSpell) do
            StunSpellKnown[k]={}
            for kk,vv in ipairs(v) do
                StunSpellKnown[k][kk]=GetSpellInfo(vv)~=nil
            end
        end

        if IROVar.fspecOnEventCallBack then
            if not IROVar.fspecOnEventCallBack["UseNPA"] then
                IROVar.Register_TALENT_CHANGE_scrip_CALLBACK("UseNPA",function() -- recheck Known Skill?
                        if not StunSpell[IROSpecID] then return end
                        for k,v in ipairs(StunSpell[IROSpecID]) do
                            StunSpellKnown[IROSpecID][k]=GetSpellInfo(v)~=nil
                        end
                end)
            end
        end
        IROVar.NPA.stopcastingHandle=C_Timer.NewTimer(0.1,function() end)
        IROVar.NPA.stopcastingCheckHandle=C_Timer.NewTimer(0.1,function() end)
end)

local GeroCheckSound = aura_env.CheckSound

local function EndTimeUnitCast(u)
    u=u or "target"
    local _, _, _, _, EndTimeMS = UnitCastingInfo("player")
    if not EndTimeMS then
        _, _, _, _, EndTimeMS = UnitChannelInfo("player")
    end
    return EndTimeMS
end

local spellTypeDmgHandle=C_Timer.NewTimer(0,function() end)

aura_env.CheckSound = function(...)
    local spellId, spellType, unitToken, event, enableSound, range, onlyIfTargeted, ttsTargeted, ttsInput=...
    local interruptReady, ccReady, unmuteIfTargeted
    enableSound, interruptReady, ccReady, unmuteIfTargeted = GeroCheckSound(...)

    if not IROVar then return enableSound, interruptReady, ccReady, unmuteIfTargeted end

    IROVar.NPA.SpellID[spellType][spellId]=1
    if enableSound then
        local n=GetSpellInfo(spellId)
        --print(enableSound and "sound" or "NOsound",spellId,spellType,n,ttsInput)
        print(spellType,unitToken,UnitIsUnit("target",unitToken) and "TARGETED!!" or "",n,ttsInput and ttsInput or "")
    end

    if enableSound and spellType=="damage" then
        IROVar.UpdateCounter("npadmgnotify",ttsInput=="defensive" and 2 or 1)
        spellTypeDmgHandle:Cancel()
        do
            local ttt=EndTimeUnitCast(unitToken)
            ttt=ttt and (ttt/1000 - TMW.time + 0.1) or 2
            spellTypeDmgHandle=C_Timer.NewTimer(ttt,function()
                    IROVar.UpdateCounter("npadmgnotify",0)
            end)
        end
    end

    if ttsInput=="stop casting" then
        IROVar.UpdateCounter("npastopcastingnotify",1)
        local time_to_safe
        local _, _, _, _, endTimeMS = UnitCastingInfo(unitToken)
        time_to_safe = endTimeMS and (endTimeMS/1000) or (2 + TMW.time)
        do
            local ssId_Check,uT,TimeToSave=spellId,unitToken,time_to_safe
            IROVar.NPA.stopcastingCheckHandle:Cancel()
            IROVar.NPA.stopcastingCheckHandle=C_Timer.NewTicker(0.2,function()
                    local  _, _, _, _, playereTMS, _, _, _, ssId = UnitCastingInfo(uT)
                    if not ssId or ssId_Check~=ssId then
                        --print("enemy Stop Cast")
                        IROVar.NPA.stopcastingCheckHandle:Cancel()
                        IROVar.NPA.stopcastingHandle:Cancel()
                        IROVar.UpdateCounter("npastopcastingnotify",0)
                        IROVar.UpdateCounter("npastopplayercasting",0)
                    else
                        --print("enemy Cast")
                        playereTMS = EndTimeUnitCast("player")
                        IROVar.UpdateCounter("npastopplayercasting",playereTMS and playereTMS/1000 > TimeToSave and 1 or 0)
                    end
            end)
        end

        IROVar.NPA.stopcastingHandle:Cancel()
        IROVar.NPA.stopcastingHandle=C_Timer.NewTimer(time_to_safe-TMW.time,function()
                IROVar.UpdateCounter("npastopcastingnotify",0)
                IROVar.UpdateCounter("npastopplayercasting",0)
                IROVar.NPA.stopcastingHandle:Cancel()
        end)

    end

    if enableSound and spellType=="kick" and TMW_ST:GetCounter("cyclekick")==1 and TMW_ST:GetCounter("wantinterrupt")==1 then
        do
            local tGUID=UnitGUID(unitToken)
            local tToken=unitToken
            if tGUID then
                if UnitIsUnit("target",unitToken) then
                    print("Queue KICK : TARGETED!!")
                else
                    print("Queue KICK : not target")
                end
                IROVar.TargetEnemy.RegisterTargetting(tGUID,10,function()
                        return not IsMyInterruptSpellReady() or not IROVar.TargetEnemy.IsTargetCasting(tGUID,tToken)
                end)
            end
        end
    end

    --[[if enableSound then -- CHECK STUN CONDITION
        print("enableSound")
        if spellType=="stun" then
            print("stun")
            if TMW_ST:GetCounter("cyclekick")==1 then
                print("cyclekick==1")
                if isStunSpellReady() then
                    print("isStunSpellReady")
                    if UnitGUID(unitToken) then
                        print("UnitGUID(unitToken)")
                    else
                        print(" NOT UnitGUID(unitToken)")
                    end
                else
                    print("NOT isStunSpellReady")
                end
            else
                print("NOT cyclekick==1")
            end
        else
            print("NOT stun")
        end
    end]]

    if enableSound and spellType=="stun" and TMW_ST:GetCounter("cyclekick")==1 and isStunSpellReady() and TMW_ST:GetCounter("wantstun")==1 then
        --print ("stun trigger !!!!!")
        do
            local tGUID=UnitGUID(unitToken)
            local tToken=unitToken
            --print("Token :",unitToken)
            --print("tGUID :",tGUID)
            if tGUID then
                if UnitIsUnit("target",unitToken) then
                    print("Queue STUN : TARGETED!!")
                else
                    print("Queue STUN : not target")
                end
                IROVar.TargetEnemy.RegisterTargetting(tGUID,10,function()
                        return not isStunSpellReady() or not IROVar.TargetEnemy.IsTargetCasting(tGUID,tToken)
                end)
            end
        end
    end

    return enableSound, interruptReady, ccReady, unmuteIfTargeted
end

