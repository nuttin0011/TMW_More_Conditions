aura_env.ignoreSymbol= {}
aura_env.InitNPA = function()
    aura_env.userLists = {}
    aura_env.defaultLists = {}
    aura_env.mergedList = {}
    aura_env.ignoreList = {}
    aura_env.glowList = {}
    aura_env.triggerWatchList = {}
    aura_env.soundWatchList = {}
    aura_env.remainingChecks = 0
    aura_env.refreshIsDone = false
    aura_env.ttsQueue = 0
    aura_env.ttsQueueMax = 2
    aura_env.ttsIsPlaying = false
    aura_env.activePreviews = {}
    
    aura_env.soundThrottle = 1.5
    local lastPlayed = GetTime() - aura_env.soundThrottle
    aura_env.lastSoundPlayed = {
        ["kick"] = lastPlayed,
        ["stun"] = lastPlayed,
        ["swirly"] = lastPlayed,
        ["frontal"] = lastPlayed,
        ["avoid"] = lastPlayed,
        ["tank"] = lastPlayed,
        ["alert"] = lastPlayed,
        ["damage"] = lastPlayed,
    }
    aura_env.lastSoundPlayedTTS = {
        ["kick"] = lastPlayed,
        ["stun"] = lastPlayed,
        ["swirly"] = lastPlayed,
        ["frontal"] = lastPlayed,
        ["avoid"] = lastPlayed,
        ["tank"] = lastPlayed,
        ["alert"] = lastPlayed,
        ["damage"] = lastPlayed,
    }
end
aura_env.InitNPA()

aura_env.GetSymbolStates = function()
    return {
        ["kick"]=false,
        ["stun"]=false,
        ["frontal"]=false,
        ["damage"]=false,
        ["alert"]=false,
        ["swirly"]=false,
        ["avoid"]=false,
        ["tank"]=false,
        ["priority"]=false,
        ["stealth"]=false,
    }
end

-- this processes a unitID to determine which symbols should be shown.
aura_env.ProcessUnit = function(unitID)
    if aura_env.settings == nil then
        return false
    end
    
    -- flipping these to true if symbol is to be shown.
    local symbolStates =  aura_env.GetSymbolStates()
    local symbolFound = false
    
    -- iterating through spell-entries for this unit.
    for _, spellTypeUser in pairs(aura_env.mergedList[unitID]) do
        -- need to check for strings because special cases could have a table here instead.
        if type(spellTypeUser) == "string" then
            local spellTypeList = {}
            for str in string.gmatch(spellTypeUser, "[^/]+") do
                table.insert(spellTypeList, str)
            end
            
            local spellType = string.lower(spellTypeList[1])
            
            if symbolStates[spellType] == nil then 
                print("!!! M+ Nameplate Alerts")
                print("!!! -- Unknown spellType: \""..spellType.."\"")
                print("!!! -- Probably a typo. Check your lists!")
            else
                -- if player is not a tank, we'll never show the tank symbol.
                if spellType == "tank" and aura_env.settings["isTank"] == false then
                    symbolStates["tank"] = false
                else
                    local show = aura_env.settings["iconSettings"][spellType]
                    symbolStates[spellType] = show
                    if show then
                        symbolFound = true
                    end
                end
                
                -- running overrides.
                for _,v in pairs(spellTypeList) do
                    v = string.lower(v)
                    if v == "nosymbol" then
                        symbolStates[spellType] = false
                    elseif v == "dosymbol" then
                        symbolStates[spellType] = true
                    end
                end
            end
            
        end
    end
    
    -- ignoring symbol if it's colored by the companion Plater mod.
    if aura_env.ignoreSymbol[unitID] then
        symbolStates[aura_env.ignoreSymbol[unitID]] = false
    end
    
    return symbolFound, symbolStates
end

aura_env.StartTicker = function(numChecks)
    numChecks = numChecks + 1 -- cause numChecks can be 0
    -- starts a ticker for delayed target checks/sound alerts.
    -- numChecks is how many 100ms interval we check.
    -- +1 extra tick to conclude the check if time ran out.
    
    aura_env.remainingChecks = aura_env.remainingChecks or numChecks
    if numChecks > aura_env.remainingChecks then
        aura_env.remainingChecks = numChecks
    end
    
    if aura_env.ticker100ms then
        aura_env.ticker100ms:Cancel()
    end
    
    aura_env.ticker100ms = C_Timer.NewTicker(
        0.1,
        function() WeakAuras.ScanEvents("NPA_Ticker_100ms") end,
        aura_env.remainingChecks
    )
    
end

aura_env.GetCastingInfo = function(unitToken, npa)
    local _
    npa.spellName,
    _,
    npa.spellIcon,
    npa.spellStart,
    npa.spellEnd,
    _,
    _,
    npa.notInterruptible,
    npa.spellID  = UnitCastingInfo(unitToken)
    npa.isChanneled = false
    
    if not npa.spellName then
        npa.spellName,
        _,
        npa.spellIcon,
        npa.spellStart,
        npa.spellEnd,
        _,
        npa.notInterruptible,
        npa.spellID = UnitChannelInfo(unitToken)
        npa.isChanneled = true
    end
    
    return npa
end

-- when a highlight is delayed, we re-check if the unit still matches after the delay passed.
aura_env.UnitConfirmed = function(unitToken, npa) 
    if UnitExists(unitToken)  then
        if npa.guid ~= UnitGUID(unitToken) then
            return false
        elseif npa.spellName then
            local spellIDTemp
            if npa.isChanneled then
                spellIDTemp = select(8,UnitChannelInfo(unitToken))
            else
                spellIDTemp = select(9,UnitCastingInfo(unitToken))
            end
            if npa.spellID ~= spellIDTemp then
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

-- shows or hides the pixelglow.
local LCG = LibStub("LibCustomGlow-1.0")
aura_env.PlayGlow = function(show, unitToken, npa)
    
    if show then
        local lineLength = aura_env.settings["glowSettings"][3]
        local lineThickness = aura_env.settings["glowSettings"][4] -- lineThickness
        if npa.spellType == "kick" and not npa.interruptReady
        or npa.spellType == "stun" and not npa.ccReady then
            lineLength = lineLength/3
            lineThickness = lineThickness/1.5
        end
        local frame = aura_env.GetNameplate(unitToken)
        aura_env.glowList[unitToken] = npa.spellType
        LCG.PixelGlow_Start(
            frame,
            npa.alertColor,
            aura_env.settings["glowSettings"][1], -- lineNumber
            aura_env.settings["glowSettings"][2], -- lineSpeed
            lineLength,
            lineThickness,
            aura_env.settings["glowSettings"][5], -- lineOffsetX
            aura_env.settings["glowSettings"][6], -- lineOffsetY
            false,
        "NPA")        
    else
        -- might have to fetch the nameplate again if WA options was open and list got cleared
        local frame = aura_env.GetNameplate(unitToken)
        if frame then
            LCG.PixelGlow_Stop(frame, "NPA")
            aura_env.glowList[unitToken] = false
        end
    end
end

-- plays a flash animation and the pixelglow.
aura_env.PlayFlashAndGlow = function(npa)
    aura_env.PlayGlow(true, npa.unitToken, npa)
    if not (npa.isChanneled or aura_env.CheckSpellList(npa.spellID)) then
        if (npa.interruptReady and npa.spellType == "kick")
        or (npa.ccReady and npa.spellType == "stun") then
            aura_env.PlayFlash(npa)
        end
    end
end

-- plays only a flash animation.
aura_env.PlayFlash = function(npa)
    local color = select(1, unpack(aura_env.settings[npa.spellType]))
    WeakAuras.ScanEvents("NPA_StartAnim", npa.unitToken, npa.spellType, color)
end

-- this does a bunch of additional checks to determine whether a sound should be played or not.
aura_env.SetupSound = function(npa)
    
    if npa.spellType == "kick" then
        -- if the user wants the sound effect only for their target or focus then
        -- this bit will disable the sound if those conditions aren't met.
        if aura_env.settings["playKickTarget"] and aura_env.settings["playKickFocus"] then
            if not UnitIsUnit(npa.unitToken, "target") 
            and not UnitIsUnit(npa.unitToken, "focus") then
                npa.enableSound = false
            end
            
        elseif (aura_env.settings["playKickTarget"] and not UnitIsUnit(npa.unitToken, "target")) 
        or (aura_env.settings["playKickFocus"] and not UnitIsUnit(npa.unitToken, "focus")) then
            npa.enableSound = false
        end
        
        -- disabling sound if interrupt isn't available.
        -- ignoring interrupt status if TTS input was found because this spell
        -- could then still be relevant to us even if we can't kick it right now.
        if aura_env.settings["playKickOnlyIfInterruptIsReady"]
        and not npa.ttsInput then
            npa.enableSound = npa.interruptReady and npa.enableSound
        end
        
    elseif npa.spellType == "stun"
    and not npa.ttsInput then
        -- ignoring cc status if ttsInput was found for the same reason as above.
        -- for example, this could be a fixate on you.
        npa.enableSound = npa.ccReady and npa.enableSound
    end
    
    -- muting sound if out of range.
    if npa.range
    and npa.enableSound then
        local inRange = aura_env.CheckRange(npa.range, npa.unitToken)
        if not inRange then
            npa.enableSound = false
        end  
    end  
    
    -- this prevents a sound from being repeated if a cast goes into a channel with the same ID.
    if npa.enableSound
    and npa.isChanneled
    and not npa.ignoreIsChanneled then
        npa.enableSound = aura_env.CheckSpellList(npa.spellID)
    end
    
    if npa.ttsInput then
        npa.ttsEnable = true
    end
    
    return npa
end

aura_env.PlaySound = function(npa)
    if not npa.enableSound then
        return
    end
    
    local lastSoundPlayed = aura_env.lastSoundPlayed
    if npa.ttsEnable then
        lastSoundPlayed = aura_env.lastSoundPlayedTTS
    end
    
    if npa.delaySound == 0 then
        if lastSoundPlayed[npa.spellType] then
            if ( GetTime() - lastSoundPlayed[npa.spellType] <= aura_env.soundThrottle )
            and not npa.priority then
                -- throttling sound
                return
            elseif npa.priority 
            and ( GetTime() - lastSoundPlayed[npa.spellType] <= 0.2 ) then
                -- small throttle for priority. this is to prevent duplicate alerts if
                -- multiple priority casts are sent at the exact same time.
                return
            else
                lastSoundPlayed[npa.spellType] = GetTime()
            end
        end
        
        if npa.ttsEnable then
            local ttsVoice = aura_env.settings["ttsVoice"]
            local ttsSpeed = aura_env.settings["ttsSpeed"]
            local ttsVolume = aura_env.settings["ttsVolume"]
            
            if not npa.ttsInput then
                npa.ttsInput = npa.spellType
            end
            
            if aura_env.ttsIsPlaying then 
                aura_env.ttsQueue = aura_env.ttsQueue + 1 
            end
            
            if aura_env.ttsQueue >= aura_env.ttsQueueMax then
                npa.priority = true
            end
            
            if npa.priority then
                C_VoiceChat.StopSpeakingText()
                C_Timer.After(0.1, function()
                        C_VoiceChat.SpeakText(ttsVoice, npa.ttsInput, 1, ttsSpeed, ttsVolume)
                end)
            else
                C_VoiceChat.SpeakText(ttsVoice, npa.ttsInput, 1, ttsSpeed, ttsVolume)
            end
        else
            PlaySoundFile(npa.soundFileID, "Master")
        end
        
    else
        local numChecks = npa.delaySound*10
        aura_env.StartTicker(numChecks)
        -- using guid instead of unitToken because this may come from a CombatLog event.
        aura_env.soundWatchList[npa.guid] = {numChecks, npa}
    end
    
end

-- function to get just the healthbar of a nameplate. 
--local LGF = LibStub("LibGetFrame-1.0")
aura_env.GetNameplate = function(unitNameplate)
    return aura_env.GetFrame(unitNameplate)
    --return LGF.GetUnitNameplate(unitNameplate)
end

-- this takes the user's spellType string, separates the tags from the actual spellType
-- and fetches the relevant settings for everything it finds.
aura_env.ParseSpellType = function(spellTypeUser, npa)
    
    npa.ttsInput = false
    npa.ttsTargeted = false
    npa.spellType = false
    npa.fixate = false
    npa.onlyIfTargeted = false
    npa.ignoreCombat = false
    npa.delaySound = 0
    npa.delayTargeting = 0.5
    npa.range = nil
    npa.cleu = false
    
    local spellTypeList = {}
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
    
    npa.spellType = string.lower(spellTypeList[1])
    if aura_env.CheckSpelling(npa.spellType) == false then
        return npa
    end
    
    if npa.spellType == "stealth"
    or npa.spellType == "priority" then
        return npa
    end
    
    npa.alertColor,
    npa.enableSound,
    npa.enableGlow,
    npa.enableBar,
    npa.ttsEnable,
    npa.soundFileID = unpack(aura_env.settings[npa.spellType])
    
    -- processing the tags
    for _,v in pairs(spellTypeList) do
        v = string.lower(v)
        if v == "nosound" or v == "dosound" then
            npa.enableSound = spellTypeLookup[v]
        elseif v == "noglow" or v == "doglow" then
            npa.enableGlow = spellTypeLookup[v]
        elseif v == "nobar" or v == "dobar" then
            npa.enableBar = spellTypeLookup[v]
        elseif string.match(v, "ttscustom_") then
            npa.ttsInput = v:gsub("ttscustom_", "")
        elseif string.match(v, "ttsonme_") then
            npa.ttsTargeted = v:gsub("ttsonme_", "")
        elseif string.match(v, "range_") then
            npa.range = v:gsub("range_", "")
            npa.range = tonumber(npa.range)
        elseif string.match(v, "delaysound_") then
            npa.delaySound = v:gsub("delaysound_", "")
            npa.delaySound = tonumber(npa.delaySound)
        elseif string.match(v, "onlyifonme") then
            npa.onlyIfTargeted = true
        elseif string.match(v, "cleustart") then
            npa.cleu = "start"
        elseif string.match(v, "cleusuccess") then
            npa.cleu = "success"
        elseif string.match(v, "ignorecombat") then
            npa.ignoreCombat = true
        elseif string.match(v, "delaytargetcheck_") then
            npa.delayTargeting = v:gsub("delaytargetcheck_", "")
            npa.delayTargeting = tonumber(npa.delayTargeting)
        elseif string.match(v, "ischanneled") then
            npa.ignoreIsChanneled = true
        elseif string.match(v, "isfixate_") then
            npa.fixate = v:gsub("isfixate_", "")
            npa.fixate = tonumber(npa.fixate)
        elseif v ~= npa.spellType
        and not (v == "dosymbol" or v == "nosymbol") then
            print("!!! M+ Nameplate Alerts")
            print("!!! -- Unknown tag: \""..v.."\"")
            print("!!! -- Probably a typo. Check your lists!")
        end
    end
    
    if npa.spellType == "tank"
    and aura_env.settings["isTank"] == false then 
        -- disabling tank alerts for specs that aren't tanking.
        npa.enableGlow = false
        npa.enableBar = false
        npa.enableSound = false
        
    elseif npa.spellType == "avoid"
    and not npa.range then
        -- setting default range for avoid spells if no range was provided.
        npa.range = 7
    end 
    
    return npa
end

-- sometimes a channeled cast is preceded by a regular cast with the same ID. 
-- both, the cast and the channel, would trigger the sound effect, which we don't want.
-- the first function stores spellIDs of successful casts (not channels) in a list.
-- if a channel happens, the second function compares the channel's spellID with the IDs in the list from before.
-- if we find a match, it means this channel had a precast, in which case we can ignore the sound effect.
aura_env.spellCastList = {}
aura_env.AddSpellToList = function(spellID)
    if aura_env.spellCastList[spellID] == nil then
        aura_env.spellCastList[spellID] = true
    end
end
aura_env.CheckSpellList = function(spellID)
    if aura_env.spellCastList[spellID] then 
        return false
    end
    return true
end

aura_env.CheckCounterSpells = function(npa)
    if npa.spellType == "kick" then
        npa.interruptReady = aura_env.CheckInterrupt()
    elseif npa.spellType == "stun" then
        npa.ccReady = aura_env.CheckCC()
    end
    return npa
end

aura_env.CheckInterrupt = function()
    if not aura_env.settings["playKickOnlyIfInterruptIsReady"] then
        return true
    end
    
    for spell,_ in pairs(aura_env.settings["interruptList"]) do
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

-- spellcheck for spellType. if user mistyped a spellType, we'll catch it here and print a warning.
aura_env.CheckSpelling = function(spellType)
    local validSpellTypes= {
        ["kick"] = true,
        ["stun"] = true,
        ["frontal"] = true,
        ["swirly"] = true,
        ["tank"] = true,
        ["damage"] = true,
        ["avoid"] = true,
        ["alert"] = true,
        ["stealth"] = true,
        ["priority"] = true,
    }
    if validSpellTypes[spellType] == nil then 
        print("!!! M+ Nameplate Alerts")
        print("!!! -- Unknown spellType: \""..spellType.."\"")
        print("!!! -- Probably a typo. Check your lists!")
        return false 
    end
    return true
end

-- checks combat status of a unit.
aura_env.UnitIsInCombat = function(unitToken)
    local NotInCombatWithParty = function(unit)
        local _, status  = UnitDetailedThreatSituation("player", unit)
        if status then
            return false
        end
        
        for i=1,4 do
            local partyMember = "party"..i
            if UnitExists(partyMember) then
                if UnitIsUnit(partyMember,unit.."target") then
                    return false
                end
            end
        end
        return true
    end
    
    local OwnerInCombat = function(minion)
        for i=1,40 do
            local master = "nameplate"..i
            if UnitExists(master) then
                if master ~= minion then
                    if UnitIsOwnerOrControllerOfUnit(master, minion) then
                        if not NotInCombatWithParty(master) then
                            -- unit is owned and owner is in combat with party
                            return true    
                        end
                    end
                end
            end
        end
        return false
    end
    
    if NotInCombatWithParty(unitToken) then
        if not OwnerInCombat(unitToken) then
            return false
        end
    end
    return true
end

-- merging the unit/spell-lists into one list.
-- user entries take priority over default ones by simply overwriting them.
aura_env.CreateMergedList = function()
    local MergeTables = function(tableAdd, tableMain)
        for k,v in pairs(tableAdd) do
            tableMain[k] = v
        end
    end
    
    local tables = {
        [1]=aura_env.defaultLists,
        [2]=aura_env.userLists,
    }
    
    for _,table in pairs(tables) do
        for k,v in pairs(table) do
            if v and not aura_env.ignoreList[k] then
                MergeTables(k, aura_env.mergedList)
            end
        end
    end
    
    WeakAuras.ScanEvents("NPA_MergedList", aura_env.mergedList)
    setglobal("NPA_mergedList", aura_env.mergedList)
end

-- taken from LibRangeCheck
aura_env.harmItems = {
    [2] = {
        37727, -- Ruby Acorn
    },
    [3] = {
        42732, -- Everfrost Razor
    },
    [4] = {
        129055, -- Shoe Shine Kit
    },
    [5] = {
        8149, -- Voodoo Charm
    },
    [7] = {
        61323, -- Ruby Seeds
    },
    [8] = {
        34368, -- Attuned Crystal Cores
    },
    [10] = {
        32321, -- Sparrowhawk Net
    },
    [15] = {
        33069, -- Sturdy Rope
    },
    [20] = {
        10645, -- Gnomish Death Ray
    },
    [25] = {
        24268, -- Netherweave Net
    },
    [30] = {
        835, -- Large Rope Net
    },
    [35] = {
        24269, -- Heavy Netherweave Net
    },
    [38] = {
        140786, -- Ley Spider Eggs
    },
    [40] = {
        28767, -- The Decapitator
    },
    [45] = {
        --32698, -- Wrangling Rope
        23836, -- Goblin Rocket Launcher
    },
    [50] = {
        116139, -- Haunting Memento
    },
    [55] = {
        74637, -- Kiryn's Poison Vial
    },
}

aura_env.GetClosestRange = function(rangeUser)
    local lastRange = 2
    for r,_ in pairs(aura_env.harmItems)  do
        if r > lastRange and r <= rangeUser then
            lastRange = r
        end
    end
    return lastRange
end

aura_env.IterateRangeItems = function(unitToken)
    local foundNil = false
    for _,i in pairs(aura_env.harmItems) do
        local inRange = IsItemInRange(i[1], unitToken)
        if inRange == nil then
            foundNil = true
        end
    end
    if foundNil then
        return false
    end
    return true
end

-- IsItemInRange() returns nil on the first time.
-- the obvious workarounds of running it once beforehand didn't work.
-- iterating through all items for each unitID seems to do it.
aura_env.unitIsRangeInit = {}
aura_env.InitRange = function(unitToken, unitID)
    if not UnitIsFriend("player", unitToken) and InCombatLockdown() then
        if aura_env.IterateRangeItems(unitToken) then
            aura_env.unitIsRangeInit[unitID] = true
            return
        end
    end
end

-- returns true if player is within the specified range of a given unit.
-- also returns true if the closest spell to check is already out of range.
aura_env.CheckRange = function(rangeUser, unitToken)
    if rangeUser == 0 then
        return true
    end
    
    local rangeToCheck = aura_env.GetClosestRange(rangeUser)
    local itemId = aura_env.harmItems[rangeToCheck][1]
    return IsItemInRange(itemId, unitToken)
end

-- this plays a sound, flashes the nameplate and refreshes the glow when an interrupt or CC comes off cd.
aura_env.SpellReadyAlert = function(unitToken, spellTypeReady)
    local spellCastID = select(9,UnitCastingInfo(unitToken)) or select(8,UnitChannelInfo(unitToken))
    local notInterruptible = select(8,UnitCastingInfo(unitToken)) or select(7,UnitChannelInfo(unitToken))
    if spellTypeReady == "kick" and spellCastID and not notInterruptible 
    or spellTypeReady == "stun" and spellCastID then
        -- unit is casting something. checking if unitID and spellID match with a cast we want kicked.
        local unitGUID = UnitGUID(unitToken)
        local _, _, _, _, _, unitID,_ = strsplit("-", unitGUID)
        unitID = tonumber(unitID)
        
        if not aura_env.mergedList[unitID]
        or not aura_env.mergedList[unitID][spellCastID] then
            return
        end
        
        local npa = {}
        npa.unitToken = unitToken
        local spellTypeUser = aura_env.mergedList[unitID][spellCastID]
        npa = aura_env.ParseSpellType(spellTypeUser, npa)
        
        if not npa.spellType
        or (not npa.ignoreCombat
            and not aura_env.UnitIsInCombat(unitToken))
        or (npa.onlyIfTargeted
            and not UnitIsUnit(unitToken.."target", "player")) then
            return
        end
        
        -- spellTypeReady can be "kick" or "stun"
        if npa.spellType == spellTypeReady then
            if npa.ttsTargeted and UnitIsUnit(unitToken.."target", "player") then
                npa.ttsEnable = true
                npa.ttsInput = npa.ttsTargeted
            end
            
            npa = aura_env.CheckCounterSpells(npa)
            
            -- channeled casts are allowed to trigger a sound here if everything else checks out.
            if npa.enableSound then
                npa.ignoreIsChanneled = true
                npa = aura_env.SetupSound(npa)
                aura_env.PlaySound(npa) 
            end
            
            if npa.enableGlow then
                -- hiding the glow first to redraw the ants at the correct size if needed.
                aura_env.PlayGlow(false, unitToken)
                aura_env.PlayGlow(true, unitToken, npa)
            end
            -- not using the PlayFlashAndGlow function because in this case
            -- we do want a flash, regardless if this is a channeled cast or not.
            aura_env.PlayFlash(npa)
        end
    end
end

-- updates the active glows if interrupts or CC go on cd.
-- currently run on every successful player cast, so there's room for improvement.
aura_env.RefreshGlows = function()
    C_Timer.After(0.01, function()
            local glowList = {}
            local glowsFound = false
            for unitToken,spellType in pairs(aura_env.glowList) do
                if spellType then
                    glowList[unitToken] = spellType
                    glowsFound = true
                end
            end
            
            if not glowsFound then
                return false
            end
            
            local interruptReady = nil
            local ccReady = nil
            
            for unitToken,spellType in pairs(glowList) do
                if spellType == "kick" then
                    if interruptReady == nil then
                        interruptReady = aura_env.CheckInterrupt()
                    end
                    if not interruptReady then
                        local npa = {}
                        npa.spellType = "kick"
                        npa.alertColor = aura_env.settings[spellType][1]
                        aura_env.PlayGlow(false,unitToken)
                        aura_env.PlayGlow(true, unitToken, npa)
                    end
                    
                elseif spellType == "stun" then
                    if ccReady == nil then
                        ccReady = aura_env.CheckCC()
                    end
                    if not ccReady then
                        local npa = {}
                        npa.spellType = "kick"
                        npa.alertColor = aura_env.settings[spellType][1]
                        aura_env.PlayGlow(false,unitToken)
                        aura_env.PlayGlow(true, unitToken, npa)
                    end
                    
                end
                
            end
    end)
end


aura_env.GetFrame = function(unit)
    -- modified from LibGetFrame
    if not unit
    or not aura_env.settings then
        return
    end
    
    local glowFrame = aura_env.settings["glowFrame"]
    
    local GetHealthBar = function(nameplate)
        if nameplate.unitFrame and nameplate.unitFrame.Health then
            -- elvui
            return nameplate.unitFrame.Health
        elseif nameplate.unitFramePlater and nameplate.unitFramePlater.healthBar then
            -- plater
            return nameplate.unitFramePlater.healthBar
        elseif nameplate.kui and nameplate.kui.HealthBar then
            -- kui
            return nameplate.kui.HealthBar
        elseif nameplate.extended and nameplate.extended.visual and nameplate.extended.visual.healthbar then
            -- tidyplates
            return nameplate.extended.visual.healthbar
        elseif nameplate.TPFrame and nameplate.TPFrame.visual and nameplate.TPFrame.visual.healthbar then
            -- tidyplates: threat plates
            return nameplate.TPFrame.visual.healthbar
        elseif nameplate.unitFrame and nameplate.unitFrame.Health then
            -- bdui nameplates
            return nameplate.unitFrame.Health
        elseif nameplate.ouf and nameplate.ouf.Health then
            -- bdNameplates
            return nameplate.ouf.Health
        elseif nameplate.slab and nameplate.slab.components and nameplate.slab.components.healthBar and nameplate.slab.components.healthBar.frame then
            -- Slab
            return nameplate.slab.components.healthBar.frame
        elseif nameplate.UnitFrame and nameplate.UnitFrame.healthBar then
            -- default
            return nameplate.UnitFrame.healthBar
        else
            return nameplate
        end
    end
    
    local GetCastBar = function(nameplate)
        if nameplate.unitFrame and nameplate.unitFrame.Castbar then
            -- elvui
            return nameplate.unitFrame.Castbar
        elseif nameplate.unitFramePlater and nameplate.unitFramePlater.castBar then
            -- plater
            return nameplate.unitFramePlater.castBar
        elseif nameplate.kui and nameplate.kui.CastBar then
            -- kui
            return nameplate.kui.CastBar
        elseif nameplate.extended and nameplate.extended.visual and nameplate.extended.visual.castbar then
            -- tidyplates
            return nameplate.extended.visual.castbar
        elseif nameplate.TPFrame and nameplate.TPFrame.visual and nameplate.TPFrame.visual.castbar then
            -- tidyplates: threat plates
            return nameplate.TPFrame.visual.castbar
        elseif nameplate.unitFrame and nameplate.unitFrame.Castbar then
            -- bdui nameplates
            return nameplate.unitFrame.Castbar
        elseif nameplate.ouf and nameplate.ouf.Castbar then
            -- bdNameplates
            return nameplate.ouf.Castbar
        elseif nameplate.slab and nameplate.slab.components and nameplate.slab.components.castBar and nameplate.slab.components.castBar.frame then
            -- Slab
            return nameplate.slab.components.castBar.frame
        elseif nameplate.UnitFrame and nameplate.UnitFrame.castBar then
            -- default
            return nameplate.UnitFrame.castBar
        else
            return nameplate
        end
    end
    
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate then
        
        if glowFrame == 1 then
            return GetHealthBar(nameplate)
        else
            return GetCastBar(nameplate)
        end
        
        
        
    end
end

-----------------------------------------------------
------------------ GeRODPS MOD ----------------------
-----------------------------------------------------
-----------------------------------------------------
------------------ GeRODPS MOD ----------------------
-----------------------------------------------------
local IsSpellInRange=C_Spell.IsSpellInRange
local function PredictTimeDmgCome(unitToken) -- return start time , end time
    local spellId, endTimeMS
    _,_,_,_, endTimeMS,_,_,_,spellId=UnitCastingInfo(unitToken)
    if spellId then
        endTimeMS=endTimeMS/1000
        return endTimeMS-0.1,endTimeMS+10
    end
    _,_,_,_, endTimeMS,_,_,spellId=UnitChannelInfo(unitToken)
    if spellId then
        endTimeMS=endTimeMS/1000
        return GeRODPS.time-0.1,endTimeMS+10
    end
    return GeRODPS.time-0.1,GeRODPS.time+5
end

local GeroPlaySound = aura_env.PlaySound
local predictDmgEndHandle = C_Timer.NewTimer(0.1,function() end)
aura_env.PlaySound = function(npa)

    local GeRODPS=GeRODPS
    if not GeRODPS then GeroPlaySound(npa) end
    GeRODPS.npa=npa
    GeRODPS.NPA.SpellID[npa.spellType or "damage"][npa.spellID or 0]=true

    if npa.enableSound and npa.spellType=="kick" and GeRODPS.Options.cycle and GeRODPS.Options.kick and
    GeRODPS.interruptSpellName and IsSpellInRange(GeRODPS.interruptSpellName,npa.unitToken)
    then do
            local tGUID,tToken=npa.guid,npa.unitToken
            if tGUID then
                if UnitIsUnit("target",tToken) then print("Queue KICK : TARGETED!!")
                else print("Queue KICK : not target") end
                GeRODPS.TargetEnemy.RegisterTargetting(tGUID,10,function()
                        return not GeRODPS.interruptSpellReady or not GeRODPS.TargetEnemy.IsUnitCasting(tGUID,tToken)
                end)
        end end
    end
    if npa.enableSound and npa.spellType=="damage" then
        GeRODPS.NPA.damageStart,GeRODPS.NPA.damageEnd=PredictTimeDmgCome(npa.unitToken)
        GeRODPS.NPA.damage= npa.ttsInput=="defensive" and 20 or 10 -- 0 none , 10 medium , 20 heavy
        GeRODPS.NPA.damageUnit=npa.unitToken
        GeRODPS.NPA.damageUnitGUID=npa.guid
        GeRODPS.NPA.damageSpellID=npa.spellID
        GeRODPS.NPA.damageSpellName=C_Spell.GetSpellInfo(npa.spellID).name
        predictDmgEndHandle:Cancel()
        predictDmgEndHandle=C_Timer.NewTicker(0.3,function()
            local name=UnitCastingInfo(GeRODPS.NPA.damageUnit)
            if not name then name = UnitChannelInfo(GeRODPS.NPA.damageUnit) end
            if name ~= GeRODPS.NPA.damageSpellName then
                GeRODPS.NPA.damageEnd=GeRODPS.time+0.2
                predictDmgEndHandle:Cancel()
            end
        end)
    end
    if npa.enableSound and npa.spellType=="alert" and string.find(npa.ttsInput,"dispel") then
        GeRODPS.NPA.SpellID["dispel"][npa.spellID or 0]=true
        do
            local tGUID,tToken=npa.guid,npa.unitToken
            if GeRODPS.Options.UseDispel_Soothe and tGUID and GeRODPS.purgeSpellReady and
            IsSpellInRange(GeRODPS.purgeSpellName,npa.unitToken) then
                if UnitIsUnit("target",tToken) then print("Queue DISPEL : TARGETED!!")
                else print("Queue DISPEL : not target") end
                C_Timer.After(0.2,function() -- must delay for Aura Up after Mob Cast Spell
                    GeRODPS.TargetEnemy.RegisterTargetting(tGUID,5,function()
                        return not GeRODPS.purgeSpellReady or not GeRODPS.TargetEnemy.IsUnitMustPurge(tGUID,tToken)
                    end)
                end)
            end
        end
    end
    GeroPlaySound(npa)
end
