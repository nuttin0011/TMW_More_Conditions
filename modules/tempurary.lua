-- Do not remove this comment, it is part of this aura: Core - NPA
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

-- Do not remove this comment, it is part of this aura: Settings - NPA
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

-- Do not remove this comment, it is part of this aura: Bars - NPA
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

aura_env.remainingChecks = 0
aura_env.StartTicker = function(numChecks)
    numChecks = math.ceil(numChecks) + 1 
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

-- used to check nameplate ranges for "avoid" spellType
--aura_env.LRC = LibStub("LibRangeCheck-3.0")

-- displays or hides the glow effect.
local LCG = LibStub("LibCustomGlow-1.0")
aura_env.Glow = function(frame,show, spellType, alertColor, interruptReady, ccReady)
    if show then
        local lineLength = aura_env.settings["glowSettings"][3]
        local lineThickness = aura_env.settings["glowSettings"][4] -- lineThickness
        if spellType == "kick" and not interruptReady
        or spellType == "stun" and not ccReady then
            lineLength = lineLength/3
            lineThickness = lineThickness/1.5
        end
        
        LCG.PixelGlow_Start(
            frame,
            alertColor,
            aura_env.settings["glowSettings"][1], -- lineNumber
            aura_env.settings["glowSettings"][2], -- lineSpeed
            lineLength,
            lineThickness,
            aura_env.settings["glowSettings"][5], -- lineOffsetX
            aura_env.settings["glowSettings"][6], -- lineOffsetY
            false,
        "NPA_"..aura_env.id)        
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
    local validSpellTypes= {
        ["kick"] = true,
        ["stun"] = true,
        ["frontal"] = true,
        ["swirly"] = true,
        ["tank"] = true,
        ["damage"] = true,
        ["avoid"] = true,
        ["alert"] = true,    
    }
    if validSpellTypes[spellType] == nil then 
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
    local spellType, alertColor, enableSound, enableGlow, enableBar, soundFileId, ttsEnable, fixate
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
        elseif string.match(v, "delaytargetcheck_") then
            delayTargeting = v:gsub("delaytargetcheck_", "")
            delayTargeting = tonumber(delayTargeting)
        elseif string.match(v, "isfixate_") then
            fixate = v:gsub("isfixate_", "")
            fixate = tonumber(fixate)
        end
    end
    return spellType, alertColor, enableSound, enableGlow, enableBar, soundFileId, ttsEnable, ttsInput, ttsTargeted, onlyIfTargeted,delaySound,range,cleu,ignoreCombat,delayTargeting, fixate
end

-- checks combat status of a unit.
aura_env.UnitIsInCombat = function(unitToken)
    local NotInCombatWithParty = function(unitToken)
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
    
    local OwnerInCombat = function(minion)
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
    
    if NotInCombatWithParty(unitToken) then
        if not OwnerInCombat(unitToken) then
            return false
        end
    end
    return true
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
aura_env.lastPlayedTTS = {
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
    
    local lastPlayed = aura_env.lastPlayed
    if ttsEnable then
        lastPlayed = aura_env.lastPlayedTTS
    end
    
    if delay == 0 then
        if lastPlayed[spellType] then
            if ( GetTime() - lastPlayed[spellType] <= aura_env.soundThrottle )
            and not priority then
                return
                
            elseif priority 
            and ( GetTime() - lastPlayed[spellType] <= 0.2 ) then
                return
                
            else
                lastPlayed[spellType] = GetTime()
            end
        end
        
        --[[
        if ttsEnable then
            -- TTS will not work if not connected to voice chat.
            -- will use regular sounds instead.
            ttsEnable = C_VoiceChat.IsVoiceChatConnected()
        end
        ]]--
        
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
                        C_VoiceChat.SpeakText(ttsVoice, ttsInput, 1, ttsSpeed, ttsVolume)
                end)
            else
                C_VoiceChat.SpeakText(ttsVoice, ttsInput, 1, ttsSpeed, ttsVolume)
            end
        else
            PlaySoundFile(soundFileId, "Master")
        end
        
    else
        local numChecks = delay*10
        aura_env.StartTicker(numChecks)
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
    
    
    --[[
    local duration = 1
    if not group.glowScale then
        group.glowScale = group:CreateAnimation("scale")
        group.glowScale:SetDuration(duration)
        
        group.glowScale:SetScaleFrom(1, 1)
        group.glowScale:SetScaleTo(4, 4)
        group:SetScript("OnLoop", function() if group:GetLoopState() == "REVERSE" then group:Finish() end end)
    end
    
    group:SetLooping("BOUNCE")
    
    group:Play()
    ]]--
    
    group.glowScale = group.glowScale or group:CreateAnimation("scale");
    local glowScale = group.glowScale;
    
    local duration = 0.15
    local scale = 4
    frameGlow:SetScale(1)
    
    group:SetLooping("none")
    glowScale:SetDuration(duration)
    glowScale:SetScaleFrom(1, 1)
    glowScale:SetScaleTo(scale, scale)
    group:Play();
    C_Timer.After(duration, function()
            group:Play(true)
            group:Finish()
            frameGlow:SetScale(1)
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
    local lastRange = 0
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
-- the obvious workarounds of running it sometime beforehand didn't work.
-- iterating through all items for each unitId seems to do it.
aura_env.unitIsRangeInit = {}
aura_env.InitRange = function(unitToken, unitId)
    if not UnitIsFriend("player", unitToken) and InCombatLockdown() then
        if aura_env.IterateRangeItems(unitToken) then
            aura_env.unitIsRangeInit[unitId] = true
            return
        end
    end
end

-- returns true if player is within the specified range of a given unit.
-- also returns true if the closest spell to check is already out of range.
aura_env.CheckRange = function(rangeUser, unitToken)
    local rangeToCheck = aura_env.GetClosestRange(rangeUser)
    local itemId = aura_env.harmItems[rangeToCheck][1]
    return IsItemInRange(itemId, unitToken)
end

-- Do not remove this comment, it is part of this aura: Symbols - NPA
-- these are the symbols being shown on the nameplates.
aura_env.symbolTextures = 
{
    ["kick"]="Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura15",
    ["stun"]="Interface\\Addons\\WeakAuras\\Media\\Textures\\Circle_Squirrel", -- 534837
    ["frontal"]="dragon-rostrum",
    ["swirly"]=3459217,
    ["avoid"]=4675656, --1024962,--617214,
    ["damage"]="Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Auras\\Aura10",
    ["alert"]="Azerite-PointingArrow", --"perks-warning-large"
    ["tank"]="ui-castingbar-shield", --132064 --ui-castingbar-shield --166662
    ["priority"]="ui-hud-unitframe-player-group-leadericon",
    ["stealth"]=166057,
    
}

-- if multiple symbols are being shown on one nameplate, this is the order they'll be put in.
aura_env.symbolIndex = 
{
    ["kick"]=1,
    ["stun"]=2,
    ["frontal"]=3,
    ["damage"]=4,
    ["alert"]=5,
    ["swirly"]=6,
    ["avoid"]=7,
    ["tank"]=8,
    ["priority"]=9,
    ["stealth"]=10,
}

-- width and height scales for consistent shape and size between symbols
aura_env.symbolScale = {
    ["kick"] = {1,0.85},
    ["stun"] = {0.8,0.8},
    ["frontal"] = {0.9,0.9},
    ["damage"] = {1,1.4},
    ["alert"] = {0.8,0.7},
    ["swirly"] = {0.9,0.9},
    ["avoid"] = {0.9,0.9},
    ["tank"] = {0.6,0.7},
    ["priority"] = {1.1,1.1},
    ["stealth"] = {0.8,0.8},
}


aura_env.symbolOffsetY = {
    ["kick"] = 0,
    ["stun"] = 0,
    ["frontal"] = 0,
    ["damage"] = 1,
    ["alert"] = 0,
    ["swirly"] = 0,
    ["avoid"] = 0,
    ["tank"] = 0,
    ["priority"] = 0,
    ["stealth"] = 0,
}





-- Do not remove this comment, it is part of this aura: Fixated  - NPA
aura_env.nameplateList = {}
aura_env.unitsThatFixate = {}
aura_env.auraToGuid = {}
aura_env.ignoreSpitefulShades = false


aura_env.fixateSpells = {
    ["Fixate"] = true,
    ["Fixieren"] = true,
    ["Fijar"] = true,
    ["Fixer"] = true,
    ["Ossessione"] = true,
    ["Fixar"] = true,
    ["Сосредоточение внимания"] = true,    
}

if not _G.THV_Ticker_250ms then
    C_Timer.NewTicker(0.250, function()
            WeakAuras.ScanEvents("THV_Ticker_250ms")
    end)
    setglobal("THV_Ticker_250ms", true)
end

-- Do not remove this comment, it is part of this aura: Targeted - NPA
aura_env.triggerWatchList = {}

if not _G.THV_Ticker_100ms then
    C_Timer.NewTicker(0.100, function()
            WeakAuras.ScanEvents("THV_Ticker_100ms")
    end)
    setglobal("THV_Ticker_100ms", true)
end

aura_env.UnitConfirmed = function(unitToken, spellId, guid)
    if UnitExists(unitToken)  then
        if guid ~= UnitGUID(unitToken) then
            return false
        else
            local spellIdTemp = 
            select(8,UnitChannelInfo(unitToken)) or select(9,UnitCastingInfo(unitToken))
            
            if spellId ~= spellIdTemp then
                return false
            end
        end
    else
        return false
    end
    return true
end

-- checks relative difficulty ofa  unit.
-- don't want to be warned for casts from grey units etc.
aura_env.IsUnitChallenging = function(unitToken)
    if UnitEffectiveLevel(unitToken) == -1 then
        -- is boss level
        return true
    else
        if C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unitToken) >= 2  then
            -- is in yellow range or higher
            return true
        end
    end
    -- grey or green level
    return false
end





-- Do not remove this comment, it is part of this aura: PreviewCast - NPA
--local font, size2, flags2 = aura_env.region.subRegions[2].text:GetFont()
local font, _, flags = aura_env.region.subRegions[3].text:GetFont()

aura_env.SetFont = function()
    local size = aura_env.state.barHeight * 0.7
    aura_env.region.subRegions[3].text:SetFont(font, size, flags) 
    aura_env.region.subRegions[4].text:SetFont(font, size, flags) 
end

-- Do not remove this comment, it is part of this aura: PreviewButton Kick - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Stun - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Frontal - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Swirly - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Avoid - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Damage - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Alert - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Tank - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Priority - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewButton Stealth - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end
aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()



-- Do not remove this comment, it is part of this aura: PreviewMode Text - NPA
if not aura_env.region.button then
    aura_env.region.button = CreateFrame("BUTTON", nil, aura_env.region)
end

aura_env.region.button:SetAllPoints()
aura_env.region.button:Hide()

-- Do not remove this comment, it is part of this aura: UserList - Template - NPA
--[[
------------------------------------
------------------------------------

This is a "User List".

Entries in this list will take priority over entries in any "Default List".
To ensure your changes persist through updates, don't use the included "User List"-Template directly.
Instead, make a copy of the Template, rename the copy and make your changes there.
You can have as many copies of these lists loaded as you wish.

Below are some references to help with making new entries.
Check the Custom Options of the Documentation WeakAura for more details.
You can also look at the entries in the "Default Lists" to see how things work.

------------------------------------
------------------------------------

Available spellTypes:
    "kick", "stun", "frontal", "swirly", "avoid", "danger", "alert", "tank",
    "priority", "stealth"

Available tags:
    "/noSound", "/doSound", "/noGlow", "/doGlow", "/noBar", "/doBar", "/noSymbol", "/doSymbol",
    "/ttsCustom_", "/ttsOnMe_", "/onlyIfOnMe", "/delaySound_", "/delayTargeting_", "/range_",
    "/cleuStart", "/cleuSuccess"

Examples of spellType and tag combinations:
    "frontal/ttsCustom_Charge", "stun/ttsOnMe_Fixate", "alert/onlyIfOnMe/ttsCustom_Lightning Lash", 
    "/frontal/range_15", "swirly/delaySound_0.5",
    

New entry template to copy&paste:
######################
[] = -- 
{
    [] = "", -- 
},
######################


For sounds to play at the end of a cast, add this where you'd normally add the spellId:
######################
["onCastSuccess"] = 
{
    [] = "", -- 
},
######################
   

For spells cast by units with no nameplate, you can make an entry with just the spellId.
You need to add a cleu tag with these:
######################
[] = "",

Example:
[256005] = "swirly/cleuSuccess", -- Sharkbait's Volatile Bombardment
######################

]]--

aura_env.unitAndSpellList = {
    
}

-- Do not remove this comment, it is part of this aura: DefaultList - Generic - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
}

-- Do not remove this comment, it is part of this aura: DefaultList - DF Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- Algeth'ar Academy
    --------------------------------------------------
    --------------------------------------------------
    [197219] = { -- Vile Lasher
        ["onCastSuccess"] = 
        {
            [390912] = "swirly", -- Detonation Seeds
        }
    },
    [196482] = { -- Overgrown Ancient
        [388796] = "swirly", -- Germinate
        [388544] = "tank", -- Barkbreaker
        [388923] = "alert/ttsCustom_Adds", -- Burst Forth
        [388623] = "alert/ttsCustom_Tree Incoming", -- Branch Out
    },
    [196548] = { -- Ancient Branch
        [0] = "priority", -- 
        [396640] = "kick", -- Healing Touch
        [396720] = "alert/ttsCustom_Get In", -- Abundance
    },
    [192333] = { -- Alpha Eagle
        [377383] = "frontal", -- Gust
        [377389] = "kick", -- Call of the Flock
    },
    [191736] = { -- Crawth
        [377004] = "damage/ttsCustom_Stop Casting/delaySound_0.5", -- Deafening Screech
        [377034] = "frontal", -- Overpowering Gust
        [376997] = "tank", -- Savage Peck
    },
    [192680] = { -- Guardian Sentry
        [378003] = "swirly", -- Deadly Winds
        [377991] = "tank", -- Storm Slash
        [377912] = "avoid/range_30", -- Expel Intruders
    },
    [196671] = { -- Arcane Ravager
        [388942] = "alert/ttsCustom_Charge/ttsOnMe_Targeted", -- Vicious Ambush
        [388976] = "frontal", -- Riftbreath (Precast)
        [388958] = "frontal/noSound", -- Riftbreath (Channel)
    },
    [196044] = { -- Unruly Textbook
        [388392] = "kick", -- Monotonous Lecture
    },
    [196045] = -- Corrupted Manafiend
    {
        [388863] = "kick", -- Mana Void
    },
    [196576] = { -- Spellbound Scepter
        [396812] = "stun", -- Mystic Blast
    },
    [197905] = { -- Spellbound Scepter
        [388886] = "stun", -- Arcane Rain
        ["onCastSuccess"] = {
            [388886] = "swirly", -- Arcane Rain
        },
        [396812] = "kick", -- Mystic Blast
    }, 
    [194181] = { -- Vexamus
        [385958] = "frontal", -- Arcane Expulsion
        [388537] = "alert/ttsCustom_Knockback", -- Arcane Fissure
        ["onCastSuccess"] = {
            [388537] = "alert/ttsCustom_Move", -- Arcane Fissure
        },
        [387691] = "alert/ttsCustom_Collect/delaySound_3", -- Arcane Orbs
    },
    [196202] = { -- Spectral Invoker
        [387974] = "kick", -- Arcane Missiles
        [387843] = "kick", -- Astral Bomb
    },
    [196200] = -- Algeth'ar Echoknight
    {
        [387910] = "stun", -- Astral Whirlwind
        ["onCastSuccess"] = {
            [387910] = "avoid/range_5", -- Astral Whirlwind
        },
    },
    [190609] = { -- Echo of Doragosa
        [374361] = "frontal", -- Astral Breath
        [388822] = "avoid/ttsCustom_Get Out/range_10", -- Power Vacuum
        [439488] = "damage", -- Unleash Energy
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Brackenhide Hollow
    --------------------------------------------------
    --------------------------------------------------
    [185534] = { -- Bonebolt Hunter
        [368287] = "swirly/onlyIfOnMe/ttsCustom_Move", -- Toxic Trap
        ["onCastSuccess"] = {
            [368287] = "swirly", -- Toxic Trap
        }  
    },
    [185529] = { -- Bracken Warscourge
        [367500] = "kick", -- Hideous Cackle
        [382555] = "avoid/range_2", -- Ragestorm
        [0] = "stealth",
        [1] = "priority",
    },
    [195135] = { -- Bracken Warscourge (ambush on left side)
        [367500] = "kick", -- Hideous Cackle
        [382555] = "avoid/range_2", -- Ragestorm
        [0] = "stealth",
        [1] = "priority",
    },
    [185508] = { -- Claw Fighter
        [367484] = "stun/ttsOnMe_Fixate/isFixate_0", -- Vicious Clawmangle
    },
    [185691] = { -- Vicious Hyena
        [0] = "stealth",
        [384970] = "alert/onlyIfOnMe/ttsCustom_Fixate/isFixate_0", -- Scented Meat
    },
    [185528] = { -- Trickclaw Mystic
        --[382410] = "kick", -- Witherbolt
    },
    [186191] = { -- Decay Speaker
        [367503] = "kick", -- Withering Burst
        ["onCastSuccess"] = {
            [382435] = "alert/ttsCustom_Totem", -- Rotchanting Totem (Removed)
        },        
    },
    [193799] = { -- Rotchanting Totem
        [0] = "priority",
    },
    [186122] = { -- Rira Hackclaw
        [0] = "tank",
        [381444] = "alert/onlyIfOnMe/ttsCustom_Stand Still", -- Savage Charge
        [381834] = "alert/ttsOnMe_Run Away/ttsCustom_Blade Storm/range_20", -- Bladestorm (First Cast)
        [377844] = "alert/onlyIfOnMe/ttsCustom_Run Away/isChanneled/range_20", -- Bladestorm (Repeat Casts)
    },
    [381444] = "tank/cleuStart/ttsCustom_Intercept", -- Savage Charge
    [186124] = { -- Gashtooth 
        --[378029] = "damage/ttsCustom_Defensive", -- Gash Frenzy
        [378208] = "damage/onlyIfOnMe/ttsCustom_Defensive", -- Marked for Butchery
    },
    [186125] = { -- Tricktotem 
        [377950] = "kick", -- Greater Healing Rapids
        [381470] = "alert/ttsCustom_Totem", -- Hextrick Totem
    },
    [193352] = { -- Hextrick Totem
        [0] = "priority",
    },
    [186246] = { -- Fleshripper Vulture
        [385029] = "kick", -- Screech
    },
    [186220] = { -- Brackenhide Shaper
        [372711] = "kick", -- Infuse Corruption
    },
    [189531] = { -- Decayed Elder
        [373897] = "kick", -- Decaying Roots
    },
    [186229] = { -- Wilted Oak
        [0] = "stealth",
        --[382712] = "kick/ttsCustom_Frontal", -- Necrotic Breath
        [382712] = "frontal/range_20", -- Necrotic Breath
        [373943] = "avoid/range_8", -- Stomp
    },
    
    [186226] = { -- Fetid Rotsinger
        [374544] = "kick", -- Burst of Decay
        ["onCastSuccess"] = {
            [375065] = "alert/ttsCustom_Totem", -- Summon Totem
        },        
        [0] = "stealth",
    },
    [190426] = { -- Rotchanting Totem
        [0] = "priority",
    },
    [186227] = { -- Monstrous Decay
        [374569] = "avoid/range_7", -- Burst
    },
    [189299] = -- Decaying Slime 1
    {
        [375614] = "avoid/range_2", -- Burst
    },
    [194330] = -- Decaying Slime 2
    {
        [375614] = "avoid/range_2", -- Burst
    },
    [192481] = -- Decaying Slime (Treemouth)
    {
        [378057] = "avoid/range_2", -- Burst
    },
    [186120] = { -- Treemouth
        ["onCastSuccess"] = {
            [376811] = "swirly", -- Decay Spray
        },
        [377559] = "frontal", -- Vine Whip
        [376934] = "alert/ttsCustom_Run Soon", -- Grasping Vines
        [377859] = "swirly", -- Infectious Spit
    },
    [187033] = { -- Stinkbreath
        --[388060] = "frontal/range_30", -- Stink Breath
        [0] = "stealth",
        [388060] = "frontal/ttsOnMe_SideStep/range_30", -- Stink Breath
        [388046] = "avoid/range_3", -- Violent Whirlwind
    },
    [186208] = { -- Rotbow Ranger
        [0] = "stealth",
        [384961] = "alert/onlyIfOnMe/ttsCustom_Avoid Dogs", -- Rotten Meat
        [384899] = "damage", -- Bone Bolt Volley
    },
    [187192] = { -- Rageclaw
        [385832] = "frontal/ttsCustom_Charge", -- Bloodthirsty Charge
        [385824] = "tank", -- Feral Claw
        [0] = "stealth",
    },
    [186284] = { -- Gutchewer Bear
        [372151] = "tank", -- Maul
    },
    [186116] = { -- Gutshot
        [384353] = "tank/ttsCustom_Knockback", -- Gut Shot
        [384633] = "kick", -- Master's Call
        ["onCastSuccess"] = {
            [385359] = "swirly", -- Ensnaring Trap
        },
        [384416] = "alert/onlyIfOnMe/ttsCustom_Avoid Dogs", -- Meat Toss
    },
    [194745] = -- Rotfang Hyena
    {
        [384531] = "swirly/onlyIfOnMe/ttsCustom_Move", -- Bounding Leap
        [384577] = "damage/onlyIfOnMe/ttsCustom_Bleed", -- Crippling Bite
        [384725] = "alert/onlyIfOnMe/ttsCustom_Fixate/isFixate_10", -- Feeding Frenzy
    },
    [185656] = { -- Filth Caller
        [383385] = "stun", -- Rotting Surge
        ["onCastSuccess"] = {
            [383385] = "swirly", -- Rotting Surge
        },
    },
    [187224] = { -- Vile Rothexer 1
        [382802] = "alert/onlyIfOnMe/ttsCustom_Get Out", -- Withering Contagion
        [382883] = "damage", -- Siphon Decay
    },
    [194487] = { -- Vile Rothexer 2
        [382802] = "alert/onlyIfOnMe/ttsCustom_Get Out", -- Withering Contagion
        [382883] = "damage", -- Siphon Decay
    },
    [194241] = { -- Vile Rothexer 3
        [382802] = "alert/onlyIfOnMe/ttsCustom_Get Out", -- Withering Contagion
        [382883] = "damage", -- Siphon Decay
    },
    [186121] = { -- Decatriarch Wratheye
        [376170] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0/range_15", -- Choking Rotcloud
        [373912] = "tank", -- Decaystrike
        [373942] = "alert/ttsCustom_Totem", -- Rotburst Totem
        [373960] = "damage", -- Decaying Strength
    },
    [190381] = { -- Rotburst Totem
        [0] = "priority", -- 
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Dawn of the Infinites
    --------------------------------------------------
    --------------------------------------------------
    [205408] = -- Infinite Timeslicer
    {
        [412012] = "stun", -- Temposlice 
    },
    [205384] = -- Infinite Chronoweaver 
    {
        [411994] = "kick", -- Chronomelt
    }, 
    [205435] = -- Epoch Ripper
    {
        [412063] = "avoid/range_7", -- Timerip
    }, 
    [198995] = -- Chronikar 
    {
        [413013] = "tank", -- Chronoshear
    }, 
    [199749] = -- Timestream Anomaly
    {
        [413529] = "frontal", -- Untwist
    }, 
    [206066] = -- Timestream Leech 
    {
        [415437] = "kick", -- Enervate 
        ["onCastSuccess"]=
        {
            [415437] = "alert/ttsCustom_Watch Beam/ttsOnMe_Get Out", -- Enervate 
        },
    }, 
    [206140] = -- Coalesced Time 
    {
        [415770] = "kick", -- Infinite Bolt Volley 
        [415769] = "alert/ttsCustom_Circles" -- Chronoburst
    }, 
    [206065] = -- Interval 
    {
        [415773] = "avoid/range_7", -- Temporal Detonation 
    }, 
    [206064] = -- Coalesced Moment
    {
        --[415436] = "stun", -- Tainted Sands
    }, 
    [198996] = -- Manifested Timeways
    {
        [405431] = "alert/ttsCustom_Dodge", -- Fragments of Time 
        [414303] = "frontal", -- Unwind
    }, 
    [206214] = { -- Infinite Infiltrator 
        ["onCastSuccess"]=
        {
            [413621] = "swirly", -- Timeless Curse 
        },
        [413622] = "damage", -- Infinite Fury 
        [0] = "stealth",
    },
    [205804] = -- Risen Dragon
    {
        [412806] = "swirly", -- Blight Spew
        [1] = "damage", -- constant aoe dmg
        [0] = "stealth",
    }, 
    [198997] = -- Blight of Galakrond 
    {
        [407159] = "frontal", -- Blight Reclamation 
        [406886] = "alert/onlyIfOnMe/ttsCustom_Corrosive", -- Corrosive Infusion
    }, 
    [201792] = -- Ahnzon 
    {
        [407978] = "alert/ttsCustom_Dodge", -- Necrotic Winds 
        [407159] = "frontal", -- Blight Reclamation 
        [406886] = "alert/onlyIfOnMe/ttsCustom_Corrosive", -- Corrosive Infusion
    }, 
    [201788] = -- Dazhak 
    {
        [408141] = "frontal", -- Incinerating Blightbreath
    }, 
    [201790] = { -- Loszkeleth
        [407159] = "frontal", -- Blight Reclamation 
        [406886] = "alert/onlyIfOnMe/ttsCustom_Corrosive", -- Corrosive Infusion
    },
    [205691] = -- Iridikron's Creation
    {
        [411958] = "kick", -- Stonebolt
    }, 
    [198933] = -- Iridikron
    {
        [409456] = "alert/ttsCustom_Dodge", -- Earthsurge
        [414535] = "alert/ttsCustom_Soak", -- Stonecracker Barrage
        [409635] = "frontal", -- Pulverizing Exhalation
    },
    [204918] = -- Iridikron's Creation (Boss)
    {
        --[0] = "priority", -- 
    }, 
    [205151] = -- Tyr's Vanguard
    {
        [412505] = "frontal/noSound", -- Rending Cleave
    }, 
    [201222] = -- Timesworn Keeper 
    {
        [412136] = "swirly", -- Temporal Strike
        [413024] = "tank/ttsCustom_Barrier", -- Titanic Bulwark
    }, 
    [205158] = -- Spurlok, Timeworn Sentinel 
    {
        [412922] = "kick", -- Binding Grasp 
        [412215] = "alert/ttsCustom_Snake" -- Shrouding Sandstorm
    }, 
    [201223] = -- Infinite Twilight Magus 
    {
        [413607] = "kick", -- Corroding Volley
    }, 
    [205152] = -- Lerai, Timesworn Maiden 
    {
        [412129] = "frontal", -- Orb of Contemplation
        --[413023] = "damage", -- Ancient Radiance
    }, 
    [198998] = -- Tyr, the Infinite Keeper
    {
        [401482] = "frontal", -- Infinite Annihilation
        [401248] = "frontal", -- Titanic Blow
        [400641] = "alert/ttsCustom_Soak", -- Dividing Strike
        [400642] = "alert/ttsCustom_Collect", -- Siphon Oathstone
    }, 
    [207177] = { -- Infinite Watchkeeper
        ["onCastSuccess"]=
        {
            [413621] = "swirly", -- Timeless Curse
        },
        [413622] = "damage", -- Infinite Fury 
    },
    [199748] = -- Timeline Marauder
    {
        [417481] = "kick", -- Displace Chronosequence
        ["onCastSuccess"] = {
            --[419327] = "avoid/range_7", -- Infinite Schism
        },
    }, 
    [208438] = { -- Infinite Saboteur
        [419351] = "frontal", -- Bronze Exhalation
        ["onCastSuccess"] = {
            [413621] = "swirly", -- Timeless Curse
        },
    },
    [206230] = { -- Infinite Diversionist
        [413622] = "damage", -- Infinite Fury 
        ["onCastSuccess"]=
        {
            [413621] = "swirly", -- Timeless Curse
        },
    },
    [208698] = -- Infinite Riftmage
    {
        [418202] = "kick", -- Temporal Blast
        [418200] = "kick", -- Infinite Burn
    }, 
    [205363] = -- Time-Lost Waveshaper
    {
        [411300] = "kick", -- Fish Bolt Volley 
        [411407] = "swirly", -- Bubbly Barrage
    }, 
    [205337] = -- Infinite Timebender 
    {
        [411952] = "damage/ttsCustom_Shield", -- Millennium Aid
        [412378] = "kick", -- Dizzying Sands
    }, 
    [198999] = -- Morchie 
    {
        [404916] = "frontal", -- Sand Blast 
        [403891] = "alert/ttsCustom_Split", -- More Problems!
        [407504] = "alert/ttsCustom_Fixate", -- Familiar Faces
        [405279] = "alert/ttsCustom_Fixate", -- Familiar Faces
        [406481] = "swirly", -- Time Traps
    }, 
    [205723] = -- Time-Lost Aerobot
    {
        [412200] = "frontal", -- Electro-Juiced Gigablast
        ["onCastSuccess"] = {
            [412156] = "swirly"
        },
    }, 
    [205727] = -- Time-Lost Rocketeer
    {
        [412233] = "kick", -- Rocket Bolt Volley 
    }, 
    [203861] = -- Horde Destroyer 
    {
        [407535] = "alert/ttsCustom_Adds", -- Deploy Goblin Sappers
        [407205] = "frontal", -- Volatile Mortar
        
    }, 
    [207969] = -- Horde Raider 
    {
        [407124] = "kick", -- Rallying Shout
        [407125] = "frontal/range_10", -- Sundering Slam
    }, 
    [204206] = { -- Horde Farseer
        [407902] = "swirly", -- Earthquake
        [407891] = "kick", -- Healing Wave 
    },
    [203799] = -- Horde Axe Thrower
    {
        --[406962] = "stun", -- Axe Throw 
        [0] = "priority",
    },
    [203857] = -- Horde Warlock
    {
        --[407122] = "kick", -- Rain of Fire
        [407123] = "swirly", -- Rain of Fire
        --[407121] = "kick", -- Immolate
    },
    [203678] = -- Grommash Hellscream 
    {
        [410254] = "tank", -- Decapitate
        [408228] = "frontal", -- Shockwave
        [410234] = "alert/ttsOnMe_Run Away/ttsCustom_Blade Storm", -- Bladestorm
        --[410236] = "avoid/noSound", -- Bladestorm (Channel)
    }, 
    [208208] = -- Alliance Destroyer
    {
        [407205] = "frontal", -- Volatile Mortar
        [418684] = "alert/ttsCustom_Adds", -- Deploy Dwarven Bombers
    }, 
    [208165] = -- Alliance Knight
    {
        [407124] = "kick", -- Rallying Shout
        [407125] = "frontal/range_10", -- Sundering Slam
    }, 
    [208193] = { -- Paladin of the Silver Hand
        [416999] = "tank/ttsCustom_Move", -- Consecration
        [417011] = "kick", -- Holy Light
    },
    [206352] = -- Alliance Archer
    {
        --[418009] = "stun", -- Serrated Arrows
        [0] = "priority",
    },
    [203679] = -- Anduin Lothar
    {
        [418059] = "tank", -- Mortal Strikes
        [418056] = "frontal", -- Shockwave
        [410234] = "alert/ttsOnMe_Run Away/ttsCustom_Blade Storm", -- Bladestorm
        --[410236] = "avoid/noSound", -- Bladestorm (Channel)
    }, 
    [206070] = -- Chronaxie 
    {
        [419516] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0", -- Chronal Eruption
        [419511] = "alert/ttsCustom_Slow DPS", -- Temporal Link 
    }, 
    [208440] = { -- Infinite Slayer
        [413622] = "damage", -- Infinite Fury 
        [419351] = "frontal", -- Bronze Exhalation
    },
    [199000] = { -- Chrono-Lord Deios
        [416139] = "frontal", -- Temporal Breath 
        [410904] = "alert/noSound", -- Infinity Orb
    },
    [205212] = -- Infinite Keeper
    {
        [0] = "priority", -- 
    }, 
    ------- CLEU ENTRIES -------
    [410904] = "alert/ttsCustom_Orbs/cleuStart", -- Infinity Orb
    
    
    --------------------------------------------------
    --------------------------------------------------
    -- Halls of Infusion
    --------------------------------------------------
    --------------------------------------------------
    --[[
    [190348] = { -- Primalist Ravager
        [374080] = "kick", -- Blasting Gust
    },
    ]]--
    [190345] = { -- Primalist Geomancer
        ["onCastSuccess"] = {
            [374073] = "swirly", -- Seismic Slam
        }
    },
    [190340] = { -- Refti Defender
        [374339] = "kick", -- Demoralizing Shout
        [393432] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0/range_7", -- Spear Flurry
    },
    [190342] = { -- Containment Apparatus
        [374045] = "kick", -- Expulse
        [374020] = "damage/onlyIfOnMe/ttsCustom_Beam", -- Containment Beam
        [0] = "stealth",
    },
    [189719] = { -- Watcher Irideus
        [384524] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0", -- Titanic Fist
        [384014] = "damage", -- Static Surge
        [384351] = "swirly/ttsCustom_Move", -- Spark Volley
        [389179] = "alert/ttsCustom_Puddles", -- Power Overload
    },
    [196712] = { -- Nullification Device
        [389446] = "avoid/range_5", -- Nullifying Pulse
    },
    [199037] = { -- Primalist Shocktrooper
        [395694] = "kick", -- Elemental Focus
    },
    [190362] = { -- Dazzling Dragonfly
        [374563] = "kick/ttsCustom_Frontal/ttsOnMe_Sidestep/delayTargetCheck_0/range_10", -- Dazzle
    },
    [190370] = -- Squallbringer Cyraz
    {
        [0] = "stealth",
        [375079] = "avoid", -- Whirling Fury
    },
    [190368] = { -- Flamecaller Aymi
        [0] = "stealth",
        [374699] = "kick", -- Cauterize
        [374706] = "kick", -- Pyretic Burst
        [374724] = "alert/onlyIfOnMe/ttsCustom_Rooted", -- Molten Subduction
        [374735] = "swirly/ttsOnMe_Move/delayTargetCheck_1", -- Magma Crush
        ["onCastSuccess"] = {
            --[374735] = "swirly", -- Magma Crush
        }  
    },
    [189722] = { -- Gulping Goliath
        --[385442] = "damage", -- Toxic Effluvia
        [385181] = "damage", -- Overpowering Croak
        [385531] = "swirly/ttsOnMe_Move", -- Belly Slam
        [385551] = "tank/ttsCustom_Get In", -- Gulp
    },
    [190401] = { -- Gusting Proto-Dragon
        --[391610] = "damage", -- Binding Winds
        [375348] = "frontal", -- Gusting Breath
    },
    [190371] = { -- Primalist Earthshaker
        [408388] = "avoid/range_5", -- Rumbling Earth
    },
    [190373] = { -- Primalist Galesinger
        [385141] = "swirly", -- Thunderstorm (Removed)
        [437719] = "stun", -- Thunderstrike
        --[385036] = "kick", -- Wind Buffet (Removed)
    },
    [190377] = { -- Primalist Icecaller
        [376171] = "kick", -- Refreshing Tides
    },
    [190404] = { -- Subterranean Proto-Dragon
        [375327] = "frontal", -- Tectonic Breath
        [0] = "stealth",
    },
    [190403] = { -- Glacial Proto-Dragon
        [375351] = "frontal/range_15", -- Oceanic Breath
        [391634] = "damage", -- Deep Chill
        [0] = "stealth",
    },
    [189727] = { -- Khajin the Unyielding
        [386757] = "alert/ttsCustom_L O S", -- Hailstorm
        [386559] = "alert/ttsCustom_Watch your Feet", -- Glacial Surge
        [390111] = "frontal", -- Frost Cyclone
    },
    [190407] = { -- Aqua Rager
        [377341] = "kick/noSymbol", -- Tidal Divergence
        --[377384] = "kick", -- Boiling Rage
    },
    [190405] = { -- Infuser Sariya
        [377402] = "kick", -- Aqueous Barrier
        [390290] = "avoid/range_10", -- Flash Flood
        [388882] = "damage", -- Inundate
        [0] = "stealth",
    },
    [189729] = { -- Primal Tsunami
        [387504] = "tank/ttsCustom_Knockback", -- Squall Buffet
        [387571] = "tank/noSound", -- Focused Deluge
        [389875] = "tank/ttsCustom_Get Closer", -- Undertow
        [388424] = "damage", -- Tempest's Fury
        [388760] = "frontal", -- Rogue Waves
        ["onCastSuccess"] = {
            [387559] = "swirly", -- Infused Globules
        }  
    },
    [196043] = { -- Primalist Infuser
        [388882] = "stun", -- Inundate
        
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Neltharus
    --------------------------------------------------
    --------------------------------------------------
    [193293] = { -- Qalashi Warden
        [382708] = "frontal/range_20/ttsOnMe_Sidestep/delayTargetCheck_0", -- Volcanic Guard
        [384597] = "tank/noSound", -- Blazing Slash
        [0] = "stealth",
    },
    [192787] = { -- Qalashi Spinecrusher
        --[378847] = "frontal", -- Brutal Strike
    },
    [192786] = { -- Qalashi Plunderer
        [378827] = "swirly", -- Explosive Concoction
    },
    [192788] = { -- Qalashi Thaumaturge
        [378818] = "stun", -- Magma Conflagration
        [378282] = "kick", -- Molten Core
        ["onCastSuccess"] = {
            [378282] = "alert/ttsCustom_Empowered", -- Molten Core
        }
    },
    [181861] = { -- Magmatusk
        [375251] = "frontal", -- Lava Spray
        [375439] = "frontal/ttsCustom_Charge/ttsOnMe_Sidestep", -- Blazing Charge
        [374365] = "damage", -- Volatile Mutation
        [391457] = "tank/ttsCustom_Move Boss", -- Lava Empowerment
    },
    [189227] = { -- Qalashi Hunter
        [372561] = "swirly", -- Binding Spear
    },
    [189266] = { -- Qalashi Trainee
        [372311] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0/range_5", -- Magma Fist
    },
    [189235] = { -- Overseer Lahar
        [395427] = "kick", -- Burning Roar
        [376186] = "swirly", -- Eruptive Crush
        [0] = "stealth",
    },
    [189265] = { -- Qalashi Bonetender
        [372223] = "kick", -- Mending Clay
    },
    [189340] = { -- Chargath, Bane of Scales
        [375056] = "damage", -- Fiery Focus
        [373742] = "frontal", -- Magma Wave
        [373424] = "alert/ttsCustom_Spears", -- Grounding Spear
    },
    [189472] = { -- Qalashi Lavabearer
        [0] = "stealth",
        [379406] = "swirly", -- Throw Lava
    },
    [189470] = { -- Lava Flare
        [372538] = "kick/noSound", -- Melt
    },
    [189464] = { -- Qalashi Irontorch
        --[384161] = "kick", -- Mote of Combustion
        [372201] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0/range_10", -- Scorching Breath
        [372202] = "frontal/noSound", -- Scorching Breath (channel)
    },
    [189467] = { -- Qalashi Bonesplitter
        [372262] = "alert/onlyIfOnMe/ttsCustom_Targeted", -- Pierce Marrow
        [372225] = "stun", -- Dragonbone Axe
    },
    [189466] = { -- Irontorch Commander
        [372296] = "alert/ttsCustom_Watch your Feet", -- Conflagrant Battery 
        [0] = "stealth",
    },
    [189471] = { -- Qalashi Blacksmith
        [384623] = "damage", -- Forgestomp      
        [372971] = "tank", -- Reverberating Slam
    },
    [194816] = { -- Forgewrought Monstrosity
        [0] = "priority", -- Forgewrought Fury
    },
    [189478] = { -- Forgemaster Gorek
        ["onCastSuccess"] = {
            [374969] = "swirly", -- Forgestomp  
        },  
        [374634] = "damage", -- Might of the Forge
        [374839] = "alert/ttsCustom_Spread", -- Blazing Aegis
        [374533] = "tank/ttsCustom_Knockback", -- Heated Swings
    },
    [193291] = { -- Apex Blazewing
        [381663] = "damage/ttsCustom_Wind", -- Candescent Tempest    
        --[382002] = "tank", -- Scalding Chomp
    },
    [193944] = { -- Qalashi Lavamancer
        [383651] = "kick", -- Molten Army
        [382791] = "alert/ttsCustom_Shield", -- Molten Barrier
    },
    [189901] = { -- Warlord Sargha
        [376780] = "alert/ttsCustom_Shield", -- Magma Shield
        [377473] = "alert/ttsCustom_Add", -- Burning Ember
        [377204] = "frontal", -- The Dragon's Kiln
    },
    [192464] = -- Raging Ember
    {
        [377522] = "alert/onlyIfOnMe/ttsCustom_Fixate/isFixate_0", -- Burning Pursuit
    },
    ------- CLEU ENTRIES -------
    [375068] = "swirly/cleuStart", -- Magmatusk Tentacle's Magma Blob  
    --------------------------------------------------
    --------------------------------------------------
    -- Nokhud Offensive
    --------------------------------------------------
    --------------------------------------------------
    [192789] = { -- Nokhud Longbow
        ["onCastSuccess"] = 
        {
            [384476] = "swirly", -- Rain of Arrows
        },
    },
    [192796] = { -- Nokhud Hornsounder
        [383823] = "stun", -- Rally the Clan
    },
    [192800] = { -- Nokhud Lancemaster
        [0] = "frontal", -- 
        [1] = "stealth",
        [384365] = "kick", -- Disruptive Shout
        [384336] = "avoid/range_10", -- War Stomp
    },
    [191847] = { -- Nokhud Plainstomper
        [0] = "stealth",
        [384365] = "kick", -- Disruptive Shout
        [384336] = "avoid/range_10", -- War Stomp
    },
    [186616] = -- Granyth
    {
        [388283] = "alert/ttsCustom_Fire Catapult", -- Eruption
        [388817] = "damage", -- Shards of Stone
        [385916] = "avoid/range_10", -- Tectonic Stomp
    },
    [195821] = { -- Nokhud Saboteur
        [0] = "priority", -- 
        [386490] = "stun/ignoreCombat", -- Dismantle
    },
    [195580] = { -- Nokhud Saboteur 2
        [0] = "priority", -- 
        [386490] = "stun/ignoreCombat", -- Dismantle
    },
    [195820] = { -- Nokhud Saboteur 3
        [0] = "priority", -- 
        [386490] = "stun/ignoreCombat", -- Dismantle
    },
    [194894] = { -- Primalist Stormspeaker
        [386024] = "kick", -- Tempest
    },
    [194317] = { -- Stormcaller Boroo
        [0] = "stealth",
        [386012] = "kick", -- Stormbolt
        [387145] = "damage", -- Totemic Overload
    },
    [194897] = -- Stormsurge Totem
    {
        [0] = "priority",
        [386694] = "avoid", -- Stormsurge
    },
    [195265] = { -- Stormcaller Arynga
        [0] = "stealth",
        [386012] = "kick", -- Stormbolt
        [387145] = "damage", -- Totemic Overload
    },
    [194315] = { -- Stormcaller Solongo
        [0] = "stealth",
        [386012] = "kick", -- Stormbolt
        [387145] = "damage", -- Totemic Overload
    },
    [194316] = { -- Stormcaller Zarii
        [0] = "stealth",
        [386012] = "kick", -- Stormbolt
        [387145] = "damage", -- Totemic Overload
    },
    [195696] = { -- Primalist Thunderbeast
        [0] = "stealth",
        [387125] = "kick", -- Thunderstrike
        [386028] = "avoid", -- Thunder Clap
        [387127] = "alert/onlyIfOnMe/ttsCustom_Get Out", -- Chain Lightning
    },
    [186615] = { -- The Raging Tempest
        [384761] = "tank/ttsCustom_Get Closer", -- Wind Burst
        [384316] = "alert/ttsCustom_Circles", -- Lightning Strike
        [384686] = "alert/ttsCustom_Dispel Boss", -- Energy Surge
        [384628] = "damage", -- Electrical Storm
        [384620] = "damage", -- Electrical Storm
    },
    [195842] = -- Ukhel Corruptor
    {
        [387608] = "stun/noSound", -- Necrotic Eruption
        ["onCastSuccess"] = {
            [387608] = "swirly", -- Necrotic Eruption  
        },
    },
    [195927] = { -- Soulharvester Galtmaa
        [0] = "stealth",
        [395035] = "alert/ttsCustom_Souls", -- Shatter Soul
        [387411] = "kick", -- Death Bolt Volley
    },
    [195928] = { -- Soulharvester Duuren
        [0] = "stealth",
        [395035] = "alert/ttsCustom_Souls", -- Shatter Soul
        [387411] = "kick", -- Death Bolt Volley
    },
    [195930] = { -- Soulharvester Mandakh
        [0] = "stealth",
        [395035] = "alert/ttsCustom_Souls", -- Shatter Soul
        [387411] = "kick", -- Death Bolt Volley
    },
    [195929] = { -- Soulharvester Tumen
        [0] = "stealth",
        [395035] = "alert/ttsCustom_Souls", -- Shatter Soul
        [387411] = "kick", -- Death Bolt Volley
    },
    [195876] = { -- Desecrated Ohuna
        --[387629] = "frontal/range_20", -- Rotting Wind (removed)
        [436841] = "kick", -- Rotting Wind
    },
    [195878] = { -- Ukhel Beastcaller
        [0] = "priority",
        [387440] = "alert/ttsCustom_Adds/delaySound_2", -- Desecrating Roar
    },
    [195851] = { -- Ukhel Deathspeaker
        [387614] = "avoid/range_10", -- Chant of the Dead
    },
    [186338] = -- Maruuk
    {
        [382836] = "tank", -- Brutalize
        [386063] = "avoid/range_20", -- Frightful Roar
        [385339] = "alert/ttsCustom_Dodge", -- Earthsplitter
    },
    [186339] = -- Teera
    {
        [384808] = "kick", -- Guardian Wind
        [382670] = "alert/ttsCustom_Tornadoes", -- Gale Arrow
        [385434] = "tank/ttsCustom_Leap", -- Spirit Leap
        [386547] = "alert/ttsCustom_Knockback", -- Repel
    },
    [199717] = { -- Nokhud Defender
        [0] = "frontal", -- 
        [373395] = "kick", -- Bloodcurdling Shout
        [384336] = "avoid/range_10", -- War Stomp
    },
    [193373] = { -- Nokhud Thunderfist
        [397394] = "kick", -- Deadly Thunder
    },
    [193553] = -- Nokhud Warhound
    {
        [0] = "stealth",
    },
    [193462] = { -- Batak
        [373395] = "kick", -- Bloodcurdling Shout
        [382233] = "frontal", -- Broad Stomp       
    },
    [193457] = { -- Balara
        [372147] = "swirly", -- Ravaging Spear
        [0] = "frontal", -- re-labeling the spell below to "alert" to work around sound throttle.
        [382277] = "alert/ttsCustom_Charge/ttsOnMe_Sidestep/delayTargetCheck_0", -- Vehement Charge       
    },
    [186151] = { -- Balakar Khan
        [375937] = "tank", -- Rending Strike
        [376827] = "tank", -- Conductive Strike
        [375943] = "frontal/ttsCustom_Damage", -- Upheaval    
        [376892] = "frontal/ttsCustom_Puddles", -- Crackling Upheaval 
        [376644] = "alert/ttsCustom_Spear", -- Iron Spear
        [376865] = "alert/ttsCustom_Pull", -- Static Spear
        [376683] = "alert/ttsCustom_Charge", -- Iron Stampede
    },
    [190294] = { -- Nokhud Stormcaster
        [0] = "priority", -- 
        [376725] = "kick/noSound", -- Storm Bolt
    },
    ------- CLEU ENTRIES -------
    [386748] = "alert/cleuSuccess/ttsCustom_Add", -- Summon Saboteur
    [386320] = "alert/cleuSuccess/ttsCustom_Add", -- Summon Saboteur
    [386747] = "alert/cleuSuccess/ttsCustom_Add", -- Summon Saboteur
    --------------------------------------------------
    --------------------------------------------------
    -- Ruby Life Pools
    --------------------------------------------------
    --------------------------------------------------
    [188244] = { -- Primal Juggernaut
        [372696] = "swirly", -- Excavating Blast
        [372730] = "tank", -- Crushing Smash
    },
    [187969] = { -- Flashfrost Earthshaper
        [372735] = "stun", -- Tectonic Slam
    },
    [188067] = { -- Flashfrost Chillweaver
        [372743] = "kick", -- Ice Shield
    },
    [187897] = { -- Defier Draghar
        [372087] = "frontal/ttsCustom_Charge", -- Blazing Rush
        [372047] = "tank", -- Steel Barrage
        ["onCastSuccess"] = {
            [372047] = "swirly", -- Steel Barrage
        },
        [0] = "stealth",
    },
    [188252] = { -- Melidrussa Chillworn
        [373680] = "kick", -- Frost Overload
        [396044] = "swirly", -- Hailbombs
        [373046] = "alert/ttsCustom_Adds", -- Awaken Whelps
        [373686] = "alert/ttsCustom_Focus Boss", -- Frost Overload
        [372851] = "alert/ttsOnMe_Get Out/ttsCustom_Pull soon/delayTargetCheck_0.1", -- Chillstorm
    },
    [197698] = { -- Thunderhead
        [391726] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0", -- Storm Breath
        [392395] = "tank/ttsCustom_Knockback", -- Thunder Jaw
        [392640] = "damage", -- Rolling Thunder
    },
    [195119] = -- Primalist Shockcaster
    {
        [385310] = "kick", -- Lightning Bolt
        [385313] = "alert/onlyIfOnMe/ttsCustom_Defensive", -- Unlucky Strike
    },
    [190207] = { -- Primalist Cinderweaver
        [384194] = "kick", -- Cinderbolt
    },
    [190206] = { -- Primalist Flamedancer
        [385536] = "stun", -- Flame Dance
        [373972] = "swirly", -- Blaze of Glory
    },
    [190034] = { -- Blazebound Destroyer
        [373692] = "damage", -- Inferno
        [373614] = "avoid/range_25", -- Burnout
        [373693] = "alert/onlyIfOnMe/ttsCustom_You the Bombb", -- Living Bomb
        [0] = "stealth",
    },
    [197697] = { -- Flamegullet
        [0] = "stealth",
        [391723] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0", -- Flame Breath
        [392569] = "damage", -- Molten Blood
        [392394] = "tank", -- Fire Maw
    },
    [189232] = { -- Kokia Blazehoof
        [372858] = "tank", -- Searing Blows
        [372107] = "frontal", -- Molten Boulder
        [372863] = "alert/ttsCustom_Add", -- Ritual of Blazebinding
    },
    [189886] = { -- Blazebound Firestorm
        [384823] = "damage", -- Inferno
        [373087] = "avoid/range_25", -- Burnout
        [373017] = "kick", -- Roaring Blaze
    },
    [198047] = { -- Tempest Channeler
        [392486] = "damage", -- Lightning Storm
    },
    [197985] = { -- Flame Channeler
        [392451] = "kick", -- Flashfire
    },
    [197509] = -- Primal Thundercloud
    {
        [392398] = "swirly", -- Crackling Detonation
    },
    [197535] = { -- High Channeler Ryvati
        [392924] = "kick", -- Shock Blast
        [392486] = "damage", -- Lightning Storm
    },
    [190485] = { -- Erkhart Stormvein
        [381512] = "tank", -- Stormslam
        [381517] = "alert/ttsCustom_Wind", -- Winds of Change
        [381516] = "damage/ttsCustom_Stop Casting/delaySound_1.2", -- Interrupting Cloudburst
    },
    [190484] = { -- Kyrakka
        [381525] = "frontal", -- Roaring Firebreath
        [0] = "priority", 
    },
    --------------------------------------------------
    --------------------------------------------------
    -- The Azure Vault
    --------------------------------------------------
    --------------------------------------------------
    [187159] = { -- Shrieking Welp (Patrolling)
        [0] = "stealth", -- 
        [370225] = "alert/ttsCustom_Whelpling", -- Shriek
        [397726] = "alert/ttsCustom_Whelpling", -- Shriek
    },
    [188100] = { -- Shrieking Welp (Stationary)
        [0] = "stealth", -- 
        [370225] = "alert/ttsCustom_Whelpling", -- Shriek
        [397726] = "alert/ttsCustom_Whelpling", -- Shriek
    },
    [196115] = { -- Arcane Tender (Upstairs)
        [375596] = "kick", -- Erratic Growth
        ["onCastSuccess"] = 
        {
            [375652] = "swirly", -- Wild Eruption
        },
    },
    [191164] = { -- Arcane Tender (Downstairs)
        [375596] = "kick", -- Erratic Growth
        ["onCastSuccess"] = 
        {
            [375652] = "swirly", -- Wild Eruption
        },
    },
    [196559] = -- Volatile Sapling
    {
        [375591] = "avoid", -- Sappy Burst
    },
    [191313] = -- Bubbling Sapling
    {
        [375591] = "avoid", -- Sappy Burst
    },
    [186644] = { -- Leymor
        [374364] = "alert/ttsCustom_Trees", -- Ley-Line Sprouts
        [374720] = "damage", -- Consuming Stomp
        [374567] = "alert/ttsCustom_Knockback", -- Explosive Brand
        [374789] = "tank", -- Infused Strike
        [386660] = "frontal/ttsOnMe_Sidestep/delayTargetCheck_0", -- Erupting Fissure
    },
    [187154] = { -- Unstable Curator
        [389804] = "kick", -- Heavy Tome
        ["onCastSuccess"] = 
        {
            [371358] = "swirly", -- Forbidden Knowledge
        },
        [0] = "stealth",
    },
    [186741] = { -- Arcane Elemental
        [386546] = "kick", -- Waking Bane
    },
    [187160] = { -- Crystal Fury (Inactive)
        [370764] = "frontal", -- Piercing Shards
    },
    [196116] = { -- Crystal Fury
        [370764] = "frontal", -- Piercing Shards
    },
    [187155] = { -- Rune Seal Keeper
        [377488] = "kick", -- Icy Bindings
    },
    [189555] = { -- Astral Attendant
        ["onCastSuccess"] = 
        {
            [374885] = "swirly", -- Unstable Power
        }
    },
    [187139] = { -- Crystal Thrasher (Inactive)
        [370766] = "avoid/range_15", -- Crystalline Rupture
    },
    [196117] = { -- Crystal Thrasher
        [370766] = "avoid/range_15", -- Crystalline Rupture
    },
    [186740] = { -- Arcane Construct
        [387067] = "frontal/range_10/ttsOnme_SideStep/delayTargetCheck_0", -- Arcane Bash
        [0] = "tank", -- knockback
    },
    [191739] = { -- Scalebane Lieutenant
        [377105] = "tank/noSound", -- Ice Cutter
        [391118] = "frontal/range_10", -- Spellfrost Breath
    },
    [190510] = { -- Vault Guard
        [377105] = "tank/noSound", -- Ice Cutter
    },
    [186739] = { -- Azureblade
        [385578] = "frontal", -- Ancient Orb
        [384223] = "alert/ttsCustom_Add", -- Summon Draconic Image
        [372222] = "frontal/range_5", -- Arcane Cleave
        [384132] = "alert/ttsCustom_Dodge" -- Overwhelming Energy
    },
    [190187] = { -- Draconic Image
        [373932] = "kick", -- Illusionary Bolt
        [389792] = "swirly/ignoreCombat", -- Unstable Magic
    },
    [192955] = { -- Draconic Illusion
        [0] = "priority", --
        [389792] = "swirly/ignoreCombat", -- Unstable Magic
    },
    [187240] = { -- Drakonid Breaker
        [0] = "stealth", -- 
        [396991] = "damage", -- Bestial Roar
        [391136] = "alert/ttsCustom_Charge/ttsOnMe_Targeted", -- Shoulder Slam
    },
    [187246] = { -- Nullmagic Hornswog
        [0] = "stealth", -- 
        [386526] = "stun/noSound", -- Null Stomp
        ["onCastSuccess"] = 
        {
            [386526] = "swirly", -- Null Stomp
        }
    },
    [186737] = -- Telash Greywing
    {
        [388008] = "alert/ttsCustom_Hide", -- Absolute Zero
        [387151] = "damage/onlyIfOnMe/ttsCustom_Defensive", -- Icy Devastator
        [386781] = "alert/ttsCustom_Puddles", -- Frost Bomb
    },
    [186738] = { -- Umbrelskul
        [384699] = "frontal", -- Crystalline Roar
        [388804] = "alert/ttsCustom_Knockback", -- Unleashed Destruction
        [384978] = "tank", -- Dragon Strike
        [386746] = "alert/ttsCustom_Focus Crystals", -- Brittle
        [385075] = "alert/ttsCustom_Watch your feet", -- Arcane Eruption
    },
    [195138] = { -- Detonating Crystal
        [385331] = "damage/noSound/ignoreCombat", -- Fracture
    },
    [199368] = -- Hardened Crystal
    {
        [0] = "priority",
        [385331] = "damage/noSound/ignoreCombat", -- Fracture
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Uldaman: Legacy of Tyr
    --------------------------------------------------
    --------------------------------------------------
    [184023] = { -- Vicious Basilisk
        [369826] = "kick", -- Spiked Carapace
        ["onCastSuccess"] = {
            [369828] = "tank/ttsCustom_Bleed", -- Chomp
        },
    },
    [184020] = { -- Hulking Berserker
        [369811] = "avoid/range_5", -- Brutal Slam
    },
    [184022] = { -- Stonevault Geomancer
        [369675] = "kick", -- Chain Lightning
    },
    [184581] = { -- Baelog
        [369563] = "frontal/noSound", -- Wild Cleave
        [369573] = "frontal", -- Heavy Arrow
    },
    [184582] = { -- Eric "The Swift"
        [369791] = "swirly", -- Skullcracker
    },
    [184580] = { -- Olaf
        [369602] = "kick", -- Defensive Bulwark
        [369677] = "alert/onlyIfOnMe/ttsCustom_Get Out", -- Ricocheting Shield
    },
    [184019] = -- Burly Rock-Thrower
    {
        [369853] = "swirly/onlyIfOnMe/ttsCustom_Move/delayTargetCheck_0.2/delaySound_1.5", -- Throw Rock
    },
    [186696] = { -- Quaking Totem
        [0] = "priority", -- 
    },
    [184018] = { -- Bromach
        [369703] = "avoid/range_15", -- Thundering Slam
        [382303] = "alert/ttsCustom_Totem", -- Quaking Totem
        [369605] = "alert/ttsCustom_Adds", -- Call of the Deep
    },
    [186658] = -- Stonevault Geomancer
    {
        [369675] = "kick", -- Chain Lightning
    },
    [184319] = { -- Refti Custodian
        [0] = "stealth",
        [377732] = "tank/ttsCustom_Bleed", -- Jagged Bite
    },
    [184130] = { -- Earthen Custodian
        [369409] = "frontal/noSound", -- Cleave        
    },
    [186420] = { -- Earthen Weaver
        [369465] = "stun", -- Hail of Stone
    },
    [184124] = { -- Sentinel Talondras
        [372701] = "damage/ttsCustom_Knockback", -- Crushing Stomp
        [372719] = "alert/ttsCustom_Stun Boss", -- Titanic Empowerment
    },
    [184132] = { -- Earthen Warder
        [369365] = "kick", -- Curse of Stone
    },
    [184107] = { -- Runic Protector
        [0] = "stealth",
        [369328] = "damage", -- Earthquake
        ["onCastSuccess"] = {
            [369335] = "swirly", --    
        }
    },    
    [184301] = { -- Cavern Seeker
        [369411] = "kick", -- Sonic Burst
    },
    [184422] = { -- Emberon
        [369110] = "damage/ttsCustom_Spread", -- Unstable Embers
        [369061] = "frontal", -- Searing Clap
    },
    [184300] = { -- Ebonstone Golem
        [381593] = "damage/ttsCustom_L O S", -- Thunderous Clap
        [0] = "stealth",
    },
    [184131] = { -- Earthen Guardian
        [382578] = "tank/ttsCustom_Barrier", -- Blessing of Tyr
        [382696] = "tank", -- Bulwark Slam
    },
    [184335] = { -- Infinite Agent
        [377500] = "kick", -- Hasten
    },
    [184331] = { -- Infinite Timereaver
        [0] = "damage", -- 
    },
    [184125] = { -- Chrono-Lord Deios
        [375727] = "frontal", -- Sand Breath 
        [376049] = "damage/ttsCustom_Knockback", -- Wing Buffet
        [376208] = "alert/ttsCustom_Soak Puddles", -- Rewind Timeflow
    },
    ------- CLEU ENTRIES -------
    [368990] = "damage/cleuStart/ttsCustom_Dodge Beams", -- Emberon's Purging Flames
    
}

-- Do not remove this comment, it is part of this aura: DefaultList - SL Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- De Other Side
    --------------------------------------------------
    --------------------------------------------------
    [168942] = -- Death Speaker
    {
        [334051] = "frontal", -- Erupting Darkness
        [334076] = "kick", -- Shadowcore
    },    
    [168934] = -- Enraged Spirit
    {
        [333787] = "damage", -- Rage
    },
    [170572] = -- Atal'ai Hoodoo Hexxer
    {
        [332605] = "kick", -- Hex
        [332612] = "kick", -- Healing Wave
    },
    [170490] = -- Atal'ai High Priest
    {
        [332706] = "kick", -- Heal
    },
    [170480] = -- Atal'ai Deathwalker
    {
        [332671] = "avoid/range_7", -- Bladestorm
    },
    [170486] = -- Atal'ai Devoted
    {
        [0] = "priority", -- 
        [332329] = "stun", -- Devoted Sacrifice
    },
    [170488] = -- Son of Hakkar (trash)
    {
        [0] = "priority", -- 
    },
    [165905] = -- Son of Hakkar (boss)
    {
        [0] = "priority", -- 
    },
    [164558] = -- Hakkar the Soulflayer
    {
        [322759] = "damage", -- Blood Barrier
    },
    [164861] = -- Spriggan Barkbinder
    {
        [321764] = "kick", -- Bark Armor
    },
    [164857] = -- Spriggan Mendbender
    {
        [321349] = "kick", -- Absorbing Haze
    },
    [171341] = -- Bladebeak Hatchling
    {
        [0] = "priority", -- 
        [334664] = "stun", -- Frightened Cries
    },
    [164450] = -- Dealer Xy'exa
    {
        [320230] = "alert/ttsCustom_Bombs", -- Explosive Contrivance
        [342961] = "swirly", -- Localized Explosive Contrivance (M+)
    },    
    [167965] = -- Lubricator
    {
        [332084] = "kick", -- Self-Cleaning Cycle
    },
    [167962] = -- Defunct Dental Drill
    {
        [331927] = "damage", -- Haywire
    },
    [166608] = -- Mueh'zala
    {
        [325258] = "frontal", -- Master of Death
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Halls of Atonement
    --------------------------------------------------
    --------------------------------------------------
    [174175] = -- Loyal Stoneborn
    {
        [346866] = "frontal", -- Stone Breath
    },
    [165515] = -- Depraved Darkblade
    {
        [0] = "frontal", -- 
        [325523] = "tank", -- Deadly Thrust
    },
    [164563] = -- Vicious Gargon
    {
        [0] = "stealth", -- 
    },
    [165414] = -- Depraved Obliterator
    {
        [325876] = "kick", -- Curse of Obliteration
    },
    [165529] = -- Depraved Collector
    {
        [325700] = "kick", -- Collect Sins
        [325701] = "stun", -- Siphon Life
    },
    [164562] = -- Depraved Houndmaster
    {
        [326450] = "stun", -- Loyal Beasts
    },    
    [164557] = -- Shard of Halkias
    {
        [326441] = "swirly", -- Sin Quake
        [326409] = "damage", -- Thrash
    },
    [165408] = -- Halkias
    {
        [322943] = "swirly", -- Heavy Debris
    },
    [167612] = -- Stoneborn Reaver
    {
        [326607] = "kick", -- Turn to Stone
    },
    
    [167607] = -- Stoneborn Slasher
    {
        [326997] = "tank", -- Powerful Swipe
        [0] = "frontal",
    },
    [165410] = -- High Adjudicator Aleez
    {
        [323552] = "kick", -- Volley of Power
    },
    
    [167876] = -- Inquisitor Sigar
    {
        [326829] = "kick", -- Wicked Bolt
    },
    [164218] = -- Lord Chamberlain
    {
        [323143] = "alert/ttsCustom_Statue", -- Telekinetic Toss
        [323236] = "frontal", -- Unleashed Suffering
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Mists of Tirna Scithe
    --------------------------------------------------
    --------------------------------------------------    
    [164929] = -- Tirnenn Villager
    {
        [321968] = "frontal", -- Bewildering Pollen
        [0] = "stealth", --
    },
    [164921] = -- Drust Harvester
    {
        [322938] = "kick", -- Harvest Essence
    },
    [164926] = -- Drust Boughbreaker
    {
        [324923] = "swirly", -- Bramble Burst
        [324909] = "damage", -- Furious Thrashing
    },
    [164804] = -- Droman Oulfarran
    {
        [323137] = "frontal", -- Bewildering Pollen
    },
    [171772] = -- Mistveil Defender 1
    {
        [331718] = "frontal", -- Spear Flurry
    },
    [163058] = -- Mistveil Defender 2
    {
        [331718] = "frontal", -- Spear Flurry
    },
    [166275] = -- Mistveil Shaper
    {
        [324776] = "kick", -- Bramblethorn Coat
    },
    [166299] = -- Mistveil Tender
    {
        [324914] = "kick", -- Nourish the Forest
    },
    [173655] = -- Mistveil Matriarch
    {
        [340160] = "frontal", -- Radiant Breath
        [340189] = "tank/ttsCustom_Pool", -- Pool of Radiance
    },
    [173720] = -- Mistveil Gorgegullet
    {
        [340300] = "frontal", -- Tongue Lashing
    },
    [164501] = -- Mistcaller
    {
        [321834] = "frontal", -- Dodge Ball
        [321828] = "tank/ttsCustom_Kick", -- Patty Cake
    },    
    [167111] = -- Spinemaw Staghorn
    {
        [326046] = "kick", -- Stimulate Resistance
        [340544] = "kick", -- Stimulate Regeneration
    },
    [164517] = -- Tred'ova
    {
        [337249] = "kick", -- Parasitic Incapacitation
        [337255] = "kick", -- Parasitic Domination
        [337235] = "kick", -- Parasitic Pacification
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Plaguefall
    --------------------------------------------------
    --------------------------------------------------
    [163882] = -- Decaying Flesh Giant
    {
        [320040] = "kick", -- Creepy Crawlers
    },
    [168572] = -- Fungi Stormer
    {
        [330423] = "stun", -- Fungistorm
    },
    [168578] = -- Fungalmancer
    {
        [328016] = "kick", -- Wonder Grow
    },
    [168396] = -- Plaguebelcher
    {
        [327233] = "frontal", -- Belch Plague
    },
    [164255] = -- Globgrog
    {
        [324667] = "frontal", -- Slime Wave
        [324527] = "damage", -- Plague Stomp
    },
    [163894] = -- Blighted Spinebreaker
    {
        [318949] = "frontal", -- Festering Belch
        [320517] = "swirly", -- Jagged Spines
    },
    [170927] = -- Erupting Ooze
    {
        [320103] = "alert/noSound", -- Metamorphosis
    },
    [168627] = -- Plaguebinder
    {
        [328180] = "kick", -- Gripping Infection
    },
    [164707] = -- Congealed Slime
    {
        [0] = "priority", -- 
    },
    [169861] = -- Ickor Bileflesh
    {
        [0] = "priority", -- 
    },
    
    [169498] = -- Plague Bomb
    {
        [321406] = "alert/ttsCustom_Add", -- Virulent Explosion
        [0] = "priority",
    },
    [163862] = -- Defender of Many Eyes
    {
        [336451] = "stun", -- Bulwark of Maldraxxus
    },
    [167493] = -- Venomous Sniper
    {
        [328651] = "kick", -- Call Venomfang
    },
    [164737] = -- Brood Ambusher
    {
        [328400] = "alert/ttsCustom_Adds", -- Stealthlings
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Sanguine Depths
    --------------------------------------------------
    --------------------------------------------------    
    [166396] = -- Noble Skirmisher
    {
        [324609] = "stun", -- Animate Weapon
    },
    [171448] = -- Dreadful Huntmaster
    {
        ["onCastSuccess"] = 
        {
            [334558] = "swirly", -- Volatile Trap
        },
    },
    [162038] = -- Regal Mistdancer
    {
        [320991] = "frontal", -- Echoing Thrust
    },
    [165076] = -- Gluttonous Tick
    {
        [334653] = "kick", -- Engorge
    },    
    [162100] = -- Kryxis the Voracious
    {
        [319654] = "kick", -- Hungering Drain
    },
    [162039] = -- Wicked Oppressor
    {
        [326836] = "kick", -- Curse of Suppression
    },
    [162057] = -- Chamber Sentinel
    {
        [322433] = "kick", -- Stoneskin
        [328170] = "swirly", -- Craggy Fracture
    },
    [162040] = -- Grand Overseer
    {
        [0] = "priority", -- 
        [326827] = "alert/ttsCustom_Chains", -- Dread Bindings
    },
    [171376] = -- Head Custodian Javlin
    {
        [334329] = "frontal", -- Sweeping Slash
        [334326] = "tank", -- Bludgeoning Bash
    },
    [171799] = -- Depths Warden
    {
        [335305] = "kick", -- Barbed Shackles
    }, 
    [172265] = -- Remnant of Fury
    {
        [336277] = "kick", -- Explosive Anger
    },
    [162102] = -- Grand Proctor Beryllia
    {
        [325254] = "tank", -- Iron Spikes
    },
    [166085] = -- General Kaal (trash)
    {
        [0] = "priority", -- 
        [322903] = "damage", -- Gloom Squall
    },
    [162099] = -- General Kaal
    {
        [322903] = "damage", -- Gloom Squall
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Spires of Ascension
    --------------------------------------------------
    --------------------------------------------------
    [163457] = -- Forsworn Vanguard
    {
        [317943] = "frontal", -- Sweeping Blow
    },
    [163459] = -- Forsworn Mender
    {
        [317936] = "kick", -- Forsworn Doctrine
    },
    [163458] = -- Forsworn Castigator
    {
        [317963] = "kick", -- Burden of Knowledge
    },
    [168318] = -- Forsworn Goliath
    {
        [327413] = "kick", -- Rebellious Fist
    },
    [162059] = -- Kin-Tara
    {
        [321009] = "swirly", -- Charged Spear
        [320966] = "tank", -- Overhead Slash
    },
    [163077] = -- Azules
    {
        [324368] = "frontal", -- Attenuated Barrage
    },
    [168420] = -- Forsworn Champion
    {
        [317936] = "kick", -- Forsworn Doctrine
    },
    [168418] = -- Forsworn Inquisitor
    {
        [327648] = "kick", -- Internal Strife
    },
    [163520] = -- Forsworn Squad-Leader
    {
        [0] = "priority", -- 
        [317985] = "frontal", -- Crashing Strike
    },
    
    [162058] = -- Ventunax
    {
        [324205] = "frontal", -- Blinding Flash
    },
    [168681] = -- Forsworn Helion
    {
        [328217] = "frontal", -- Crescendo
    },
    [168718] = -- Forsworn Warden
    {
        [328295] = "kick", -- Greater Mending
    },
    [168717] = -- Forsworn Justicar
    {
        [328331] = "kick", -- Forced Confession
    },
    [162060] = -- Oryphrion
    {
        [324608] = "frontal", -- Charged Stomp
    },
    [168845] = -- Astronos
    {
        [328458] = "frontal", -- Diminuendo
        [328462] = "swirly", -- Charged Spear
    },
    [168844] = -- Lakesis
    {
        [328458] = "frontal", -- Diminuendo
        [328462] = "swirly", -- Charged Spear
    },
    [168843] = -- Klotos
    {
        [328458] = "frontal", -- Diminuendo
        [328462] = "swirly", -- Charged Spear
    },
    [162061] = -- Devos
    {
        [323943] = "frontal/ttsCustom_Charge", -- Run Through
        [334625] = "damage", -- Abyssal Detonation
    },
    --------------------------------------------------
    --------------------------------------------------
    -- The Necrotic Wake
    --------------------------------------------------
    --------------------------------------------------
    [166302] = -- Corpse Harvester
    {
        [334749] = "kick", -- Drain Fluids
    },
    [162691] = -- Blightbone
    {
        [320596] = "frontal", -- Heaving Retch
    },
    [163128] = -- Zolramus Sorcerer
    {
        [320571] = "swirly", -- Shadow Well
    },
    [163618] = -- Zolramus Necromancer
    {
        [0] = "priority", -- 
    },
    [163126] = -- Brittlebone Mage
    {
        [328667] = "kick", -- Frostbolt Volley
    },
    [165222] = -- Zolramus Bonemender
    {
        [335143] = "kick", -- Bonemend
        [320822] = "stun", -- Final Bargain
    },
    [165919] = -- Skeletal Marauder
    {
        [324323] = "frontal", -- Gruesome Cleave
        [324293] = "kick", -- Rasping Scream
    },
    [163157] = -- Amarth
    {
        [333488] = "frontal", -- Necrotic Breath
    },
    [165911] = -- Loyal Creation
    {
        [327240] = "avoid/range_7", -- Spine Crush
    },
    [165872] = -- Flesh Crafter
    {
        [327130] = "kick", -- Repair Flesh
        [323496] = "tank", -- Throw Cleaver
    },
    [173016] = -- Corpse Collector
    {
        [334748] = "kick", -- Drain Fluids
        [338353] = "kick", -- Goresplatter
    },
    [172981] = -- Kyrian Stitchwerk
    {
        [0] = "tank", -- Tenderize
    },
    [173044] = -- Stitching Assistant
    {
        [334748] = "kick", -- Drain Fluids
        [323496] = "tank", -- Throw Cleaver
    },
    [167731] = -- Separation Assistant
    {
        [338606] = "alert/ttsCustom_Fixate", -- Morbid Fixation
        [323496] = "tank", -- Throw Cleaver
    },
    [163621] = -- Goregrind
    {
        [333477] = "frontal", -- Gut Slice
        [0] = "tank", -- Tenderize
    },    
    [164578] = -- Stitchflesh's Creation
    {
        [320208] = "frontal", -- Meat Hook
    },
    [162689] = -- Surgeon Stitchflesh
    {
        [0] = "priority", -- 
    },
    [162693] = -- Nalthor the Rimebinder
    {
        [320772] = "swirly", -- Comet Storm
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Theater of Pain
    --------------------------------------------------
    --------------------------------------------------
    [174197] = -- Battlefield Ritualist
    {
        [341902] = "kick", -- Unholy Fervor 
    },
    [170850] = -- Raging Bloodhorn
    {
        [333241] = "damage", -- Raging Tantrum
    },
    [164451] = -- Dessia the Decapitator
    {
        [0] = "priority", -- 
    },
    [164461] = -- Sathel the Accursed
    {
        [333231] = "kick", -- Searing Death
    },
    [164464] = -- Xira the Underhanded
    {
        [333540] = "alert/ttsCustom_C C", -- Opportunity Strikes
    },
    [167538] = -- Dokigg the Brutalizer
    {
        [0] = "stealth", -- 
        [342125] = "swirly", -- Brutal Leap
    },
    [162744] = -- Nekthara the Mangler
    {
        [0] = "stealth", -- 
        [342135] = "damage/ttsCustom_Stop Casting", -- Interrupting Roar
        [317605] = "avoid/range_7", -- Whirlwind
    },
    [167532] = -- Heavin the Breaker
    {
        [0] = "stealth", -- 
        [342135] = "damage/ttsCustom_Stop Casting", -- Interrupting Roar
        [332708] = "avoid/range_7", -- Ground Smash
    },
    [167536] = -- Harugia the Bloodthirsty
    {
        [342139] = "kick", -- Battle Trance
        [0] = "stealth", -- 
        [334023] = "frontal/ttsCustom_Charge", -- Bloodthirsty Charge
    },
    [167533] = -- Advent Nevermore
    {
        [0] = "stealth", -- 
    },
    [167534] = -- Rek the Hardened
    {
        [0] = "stealth", -- 
        [317605] = "avoid/range_7", -- Whirlwind
    },
    [164510] = -- Shambling Arbalest
    {
        [0] = "damage", -- 
    },
    [164506] = -- Ancient Captain
    {
        [0] = "priority", -- 
    },
    [170234] = -- Oppressive Banner
    {
        [0] = "stealth", -- 
    },
    [167998] = -- Portal Guardian
    {
        [330716] = "damage", -- Soulstorm
    },
    [170882] = -- Bone Magus
    {
        [342675] = "kick", -- Bone Spear
    },
    [169893] = -- Nefarious Darkspeaker
    {
        [333294] = "alert/ttsCustom_Dodge", -- Death Winds
    },
    [160495] = -- Maniacal Soulbinder
    {
        [330868] = "kick", -- Necrotic Bolt Volley
    },
    [174210] = -- Blighted Sludge
    {
        [341969] = "kick", -- Withering Discharge
    },
    [169927] = -- Putrid Butcher
    {
        [330586] = "stun", -- Devour Flesh
    },
    [163086] = -- Rancid Gasbag
    {
        [330614] = "frontal", -- Vile Eruption
    },
    [165946] = -- Mordretha, the Endless Empress
    {
        [323608] = "frontal", -- Dark Devastation
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Tazavesh: Streets of Wonder
    --------------------------------------------------
    --------------------------------------------------
    [178392] = -- Gatewarden Zo'mazz
    {
        [356548] = "damage", -- Radiant Pulse
    },
    [177807] = -- Customs Security
    {
        [355900] = "swirly", -- Disruption Grenade
    },
    [177808] = -- Armored Overseer
    {
        [356001] = "alert/ttsCustom_Beam", -- Beam Splicer
    },
    [177817] = -- Support Officer
    {
        [355934] = "kick", -- Hard Light Barrier
    },
    [177816] = -- Interrogation Specialist
    {
        [356031] = "kick", -- Stasis Beam
    },
    [179334] = -- Portalmancer Zo'honn
    {
        [356537] = "kick", -- Empowered Glyph of Restraint
        [356548] = "damage", -- Radiant Pulse
    },
    [175616] = -- Zo'phex
    {
        [348350] = "alert/ttsCustom_Fixate", -- Interrogation
    },
    [179837] = -- Tracker Zo'korss
    {
        [356001] = "alert/ttsCustom_Beam", -- Beam Splicer
    },
    [180091] = -- Ancient Core Hound
    {
        [356407] = "kick", -- Ancient Dread
        [0] = "frontal", -- 
    },
    [180348] = -- Cartel Muscle
    {
        [357229] = "tank/ttsCustom_Kite", -- Chronolight Enhancer
        [356967] = "tank/ttsCustom_Knockback", -- Hyperlight Backhand
    },
    [180336] = -- Cartel Wiseguy
    {
        [357197] = "avoid/range_7", -- Lightshard Retreat
    },
    [179842] = -- Commerce Enforcer
    {
        [355477] = "tank/ttsCustom_Knockback", -- Power Kick
    },
    [179841] = -- Veteran Sparkcaster
    {
        [355642] = "kick", -- Hyperlight Salvo
    },
    [179840] = -- Market Peacekeeper
    {
        [355637] = "alert/ttsCustom_Stop Casting", -- Quelling Strike
    },
    [176555] = -- Achillite
    {
        [349939] = "kick", -- Flagellation Protocol
    },
    [176396] = -- Defective Sorter
    {
        [347721] = "stun", -- Open Cage
    },
    
    [175646] = -- P.O.S.T. Master
    {
        [346742] = "damage", -- Fan Mail
    },
    [179269] = -- Oasis Security
    {
        [350922] = "kick", -- Menacing Shout
    },
    [176563] = -- Zo'gron
    {
        [350922] = "kick", -- Menacing Shout
        [350919] = "frontal", -- Crowd Control
    },
    [179821] = -- Commander Zo'far
    {
        [355477] = "tank/ttsCustom_Knockback", -- Power Kick
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Tazavesh: So'leah's Gambit
    --------------------------------------------------
    --------------------------------------------------
    [178139] = -- Murkbrine Shellcrusher
    {
        [355057] = "stun", -- Cry of Mrrggllrrgg
    },
    [178142] = -- Murkbrine Fishmancer
    {
        --[355234] = "kick", -- Volatile Pufferfish
        ["onCastSuccess"] = 
        {
            [355234] = "swirly", -- Volatile Pufferfish
        },
    },
    [178141] = -- Murkbrine Scalebinder
    {
        [355132] = "stun", -- Invigorating Fish Stick
        ["onCastSuccess"] = 
        {
            [355132] = "alert/ttsCustom_Totem", -- Fish Stick
        },
    },    
    [179733] = -- Invigorating Fish Stick
    {
        [0] = "priority", -- 
    },
    [178165] = -- Coastwalker Goliath
    {
        [355429] = "damage", -- Tidal Stomp
        [355464] = "swirly", -- Boulder Throw
    },
    [175663] = -- Hylbrande
    {
        [347094] = "frontal", -- Titanic Crash
    },
    [180015] = -- Burly Deckhand
    {
        [0] = "tank", -- 
    },
    [179388] = -- Hourglass Tidesage
    {
        [356843] = "kick", -- Brackish Bolt
        ["onCastSuccess"] = 
        {
            [356260] = "swirly", -- Tidal Burst
        },
    },
    [180431] = -- Focused Ritualist
    {
        [357260] = "kick", -- Unstable Rift
    },
    [180432] = -- Devoted Accomplice
    {
        [357284] = "kick", -- Reinvigorate
    },
    [180429] = -- Adorned Starseer
    {
        [357238] = "alert/ttsCustom_Add", -- Wandering Pulsar
        [357226] = "frontal", -- Drifting Star
    },
    [180433] = -- Wandering Pulsar
    {
        [0] = "priority", -- 
    },
    [177716] = -- So Cartel Assassin
    {
        [351119] = "kick", -- Shuriken Blitz
    },
    
    [177269] = -- So'leah
    {
        [351096] = "alert", -- Energy Fragmentation
    },
}








-- Do not remove this comment, it is part of this aura: DefaultList - BfA Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- Atal'Dazar
    --------------------------------------------------
    --------------------------------------------------
    [128434] = -- Feasting Skyscreamer
    {
        [255041] = "kick", -- Terrifying Screech
    },
    [129552] = -- Monzumi
    {
        [256882] = "damage", -- Wild Thrash
    },
    [128455] = -- T'lonja
    {
        [255567] = "frontal/ttsCustom_Charge/ttsOnMe_Sidestep/delayTargetCheck_0", -- Frenzied Charge
    },
    [129553] = -- Dinomancer Kish'o
    {
        [256849] = "kick", -- Dino Might
        --[256846] = "tank", -- Deadeye Aim
        [256846] = "alert/onlyIfOnMe/ttsCustom_Defensive", -- Deadeye Aim
    },
    [122963] = -- Rezan
    {
        [257407] = "alert/onlyIfOnMe/ttsCustom_Fixate", -- Pursuit
        [255371] = "alert/ttsCustom_L O S/doBar", -- Terrifying Visage
        [255434] = "tank/ttsCustom_Bleed", -- Serrated Teeth
    },
    [127799] = -- Dazar'ai Honor Guard
    {
        [256138] = "tank/noSound", -- Fervent Strike
    },
    [122971] = -- Dazar'ai Juggernaut
    {
        [253239] = "frontal/ttsCustom_Charge", -- Merciless Assault
        --[255824] = "kick", -- Fanatic's Rage
    },
    [122973] = -- Dazar'ai Confessor
    {
        [253544] = "kick", -- Bwonsamdi's Mantle
        ["onCastSuccess"] = 
        {
            [253544] = "alert/ttsCustom_Barrier", -- Bwonsamdi's Mantle
        },
        [253517] = "kick", -- Mending Word
    },
    [122972] = -- Dazar'ai Augur
    {
        --[253582] = "kick", -- Fiery Enchant
        [253583] = "kick", -- Fiery Enchant (Channel)
        ["onCastSuccess"] = 
        {
            [253583] = "swirly/delaySound_1", -- Fiery Enchant (Channel)
        },
    },
    [122984] = -- Dazar'ai Colossus
    {
        [0] = "stealth", -- 
        [254959] = "alert/onlyIfOnMe/ttsCustom_Defensive", -- Soulburn
    },
    [132126] = -- Gilded Priestess
    {
        --[260666] = "alert/ttsCustom_Beam", -- Transfusion
    },
    [122967] = -- Priestess Alun'za
    {
        [255579] = "tank", -- Gilded Claws
        [255577] = "damage/ttsCustom_Soak Blood", -- Transfusion
    },
    [127757] = -- Reanimated Honor Guard
    {
        [255626] = "avoid/range_10/ignoreCombat", -- Festering Eruption
    },
    [127315] = -- Reanimation Totem
    {
        [0] = "priority",
    },
    [122969] = -- Zanchuli Witch-Doctor
    {
        [252781] = "kick", -- Unstable Hex
    },
    [127879] = -- Shieldbearer of Zul
    {
        [0] = "stealth", --
        [273185] = "tank/noSound", -- Shield Bash
        [253721] = "stun", -- Bulwark of Juju
    },
    [122965] = -- Vol'kaal
    {
        [259572] = "kick", -- Noxious Stench
        [250258] = "swirly", -- Toxic Leap
        [250241] = "alert/ttsCustom_Go Boss" -- Rapid Decay
    },
    [122968] = -- Yazma
    {
        [249919] = "tank", -- Skewer
        --[250096] = "alert/onlyIfOnMe/ttsCustom_Defensive", -- Wracking Pain
        [259187] = "alert/ttsCustom_Drop Adds", -- Soulrend
    },
    ------- CLEU ENTRIES -------
    [259531] = "alert/ttsCustom_Kill Totems/cleuStart", -- Totem casting Reanimate
    [250050] = "swirly/ttsCustom_Watch your feet/cleuSuccess", -- Echoes of Shadra
    [250096] = "alert/cleuStart/onlyIfOnMe/ttsCustom_Defensive", -- Wracking Pain
    
    --------------------------------------------------
    --------------------------------------------------
    -- Freehold
    --------------------------------------------------
    --------------------------------------------------
    [129602] = -- Irontide Enforcer
    {
        [257426] = "frontal", -- Brutal Backhand
        [257732] = "damage/delaySound_0.5/ttsCustom_Stop Casting", -- Shattering Bellow
    },
    [128551] = -- Irontide Mastiff
    {
        [0] = "tank", -- because fervent strikes
    },
    [126918] = -- Irontide Crackshot
    {
        [258672] = "swirly", -- Azerite Grenade
    },
    [129788] = -- Irontide Bonesaw
    {
        [257397] = "kick", -- Healing Balm
    },
    [126832] = -- Skycap'n Kragg
    {
        [255952] = "frontal/ttsCustom_Charge", -- Charrrrrge
        [256060] = "kick", -- Revitalizing Brew
    },
    [127111] = -- Irontide Oarsman
    {
        ["onCastSuccess"] = 
        {
            [258777] = "swirly", -- Sea Spout
        }        
    },
    [129559] = -- Cutwater Duelist
    {
        [274400] = "frontal/ttsCustom_Charge", -- Duelist Dash
    },
    [130404] = -- Vermin Trapper
    {
        ["onCastSuccess"] = 
        {
            [274383] = "swirly", -- Rat Traps
        },
    },
    [126848] = -- Captain Eudora
    {
        [258381] = "frontal", -- Grapeshot
    },
    [126847] = -- Captain Raoul
    {
        [256589] = "avoid/range_15", -- Barrel Smash
    },
    [126845] = -- Captain Jolly
    {
        [267522] = "frontal", -- Cutting Surge
    },
    [129600] = -- Bilge Rat Brinescale
    {
        [257784] = "kick", -- Frost Blast
    },
    [129547] = -- Blacktooth Knuckleduster
    {
        --[257732] = "kick", -- Shattering Bellow
    },
    [130400] = -- Irontide Crusher
    {
        [258199] = "avoid/range 15", -- Ground Shatter
        [258181] = "swirly", -- Boulder Throw
    },
    [129529] = -- Blacktooth Scrapper
    {
        [257739] = "stun/ttsOnMe_Fixate/isFixate_0", -- Blind Rage
    },
    [129527] = -- Bilge Rat Buccaneer
    {
        [257756] = "avoid/range_7", -- Goin' Bananas
    },
    [129699] = -- Ludwig Von Tortollan
    {
        [257904] = "alert/ttsCustom_Shell", -- Shell Bounce
    },
    [126969] = -- Trothak THE SHARK PUNCHER!!!
    {
        [256405] = "avoid/range_10", -- Shark Tornado
    },
    [130012] = -- Irontide Ravager
    {
        --[257899] = "kick", -- Painful Motivation
    },
    [126919] = -- Irontide Stormcaller
    {
        [257736] = "kick", -- Thundering Squall
    },
    [130011] = -- Irontide Buccaneer
    {
        [257870] = "stun", -- Blade Barrage
    },
    [127106] = -- Irontide Officer
    {
        [257899] = "kick", -- Painful Motivation
        [257908] = "tank", -- Oiled Blade
    },
    [126983] = -- Harlan Sweete
    {
        [413147] = "frontal", -- Swiftwind Saber
        [413145] = "alert/ttsCustom_Dodge", -- Swiftwind Saber (Empowered)
        [257316] = "alert/ttsCustom_Add", -- Avast, ye!
    },
    ------- CLEU ENTRIES -------
    [268717] = "frontal/ttsCustom_Charge/cleuSuccess", -- Sharkbait's Charge    
    [256005] = "swirly/ttsCustom_Poop/cleuSuccess", -- Sharkbait's Volatile Bombardment
    
    
    --------------------------------------------------
    --------------------------------------------------
    -- Mechagon Junkyard
    --------------------------------------------------
    --------------------------------------------------
    [150146] = -- Scrapbone Shaman
    {
        [300436] = "kick", -- Grasping Hex
    },
    [150143] = -- Scrapbone Grinder
    {
        [300414] = "tank", -- Enrage
    },
    [150160] = -- Scrapbone Bully
    {
        [300414] = "kick", -- Enrage
        [300424] = "frontal", -- Shockwave
    },
    [152009] = -- Malfunctioning Scrapbot
    {
        [294884] = "avoid/range_7", -- Gyro-Scrap
        [300102] = "tank", -- Exhaust
    },
    [150276] = -- Heavy Scrapbot
    {
        [300159] = "avoid/range_7", -- Gyro-Scrap
        [300171] = "kick", -- Repair Protocol
        [300177] = "tank", -- Exhaust
    },
    [150254] = -- Scraphound
    {
        [299475] = "frontal", -- B.O.R.K.
        [0] = "stealth", --
    },
    [150251] = -- Pistonhead Mechanic
    {
        [300087] = "kick", -- Repair
        [299588] = "kick", -- Overclock
    },
    [150253] = -- Weaponized Crawler
    {
        [300188] = "frontal", -- Scrap Cannon
    },
    [153755] = -- Naeno Megacrash
    {
        [298940] = "frontal", -- Bolt Buster
        [298946] = "frontal/ttsCustom_Charge", -- Roadkill
    },
    [150297] = -- Mechagon Renormalizer
    {
        [284219] = "kick", -- Shrink
        [301629] = "kick", -- Enlarge
    },
    [150168] = --Toxic Monstrosity 
    {
        [300687] = "avoid/range_10", -- Consume
    },
    [150165] = -- Slime Elemental
    {
        [300777] = "frontal/ttsCustom_Charge", -- Slimewave
    },
    [150169] = -- Toxic Lurker
    {
        [300650] = "kick", -- Suffocating Smog
    },
    [150292] = -- Mechagon Cavalry
    {
        [301681] = "frontal/ttsCustom_Charge", -- Charge
        [301667] = "frontal", -- Rapid Fire
        [0] = "stealth", --
    },
    [150293] = -- Mechagon Prowler
    {
        [0] = "stealth", -- 
    },
    [155090] = -- Anodized Coilbearer
    {
        [301689] = "kick", -- Charged Coil
    },
    [150295] = -- Tank Buster MK1
    {
        [302279] = "tank", -- Wreck
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Mechagon Workshop
    --------------------------------------------------
    --------------------------------------------------
    [151657] = -- Bomb Tonk
    {
        [301088] = "kick", -- Detonate
    },
    [145185] = -- Gnomercy 4.U.
    {
        [283422] = "frontal/ttsCustom_Charge", -- Maximum Thrust
        [285388] = "damage", -- Vent Jets
    },
    [144244] = -- The Platinum Pummeler
    {
        [285020] = "avoid/range_10", -- Whirling Edge
    },
    [144293] = -- Waste Processing Unit
    {
        [294290] = "frontal", -- Process Waste
        [294324] = "avoid/range_10", -- Mega Drill
    },
    [144301] = -- Living Waste
    {
        [294349] = "damage/ttsCustom_L O S", -- Volatile Waste
    },
    [144246] = -- K.U.-J.0.
    {
        [291946] = "damage/ttsCustom_L O S", -- Venting Flames
    },
    [144298] = -- Defense Bot Mk III
    {
        [297128] = "damage", -- Short Out
    },
    [151476] = -- Blastatron X-80
    {
        [293986] = "frontal", -- Sonic Pulse
        [294015] = "swirly", -- Launch High-Explosive Rockets
    },
    [144294] = -- Mechagon Tinkerer
    {
        [293854] = "swirly", -- Activate Anti-Personnel Squirrel
    },
    [144295] = -- Mechagon Mechanic
    {
        [293729] = "kick", -- Tune Up
    },
    [144248] = -- Head Machinist Sparkflux
    {
        [285440] = "alert/ttsCustom_Flames", -- "Hidden" Flame Cannon
    },
    [144296] = -- Spider Tank
    {
        [293986] = "frontal", -- Sonic Pulse
        [294015] = "swirly", -- Launch High-Explosive Rockets
    },
    [150396] = -- Aerial Unit R-21/X
    {
        [291928] = "frontal", -- Giga-Zap
    },
    [144249] = -- Omega Buster
    {
        [292264] = "frontal", -- Giga-Zap
    },
    --------------------------------------------------
    --------------------------------------------------
    -- The Underrot
    --------------------------------------------------
    --------------------------------------------------
    [130909] = -- Fetid Maggot
    {
        [265540] = "frontal/range_20", -- Rotten Bile
    },
    [131436] = -- Chosen Blood Matron
    {
        --[265016] = "damage", -- Blood Harvest
        [265019] = "frontal/range_5", -- Savage Cleave
        [0]="stealth",
    },
    [131492] = -- Devout Blood Priest
    {
        [265089] = "kick", -- Dark Reconstitution
        [265091] = "kick", -- Gift of G'huun
    },
    [133685] = -- Befouled Spirit
    {
        [278755] = "kick", -- Harrowing Despair
        [0] = "stealth",
    },
    [131318] = -- Elder Leaxa
    {
        [260894] = "frontal", -- Creeping Rot
        [264757] = "avoid/range_7", -- Sanguine Feast
        [260879] = "kick/noSound", -- Blood Bolt
    },
    [134701] = -- Blood Effigy
    {
        [260894] = "frontal", -- Creeping Rot
        [264757] = "avoid/range_7", -- Sanguine Feast
        [260879] = "kick/noSound", -- Blood Bolt
    },    
    [133852] = -- Living Rot
    {
        --[265668] = "swirly", -- Wave of Decay
    },
    [133835] = -- Feral Bloodswarmer
    {
        [266106] = "kick", -- Sonic Screech
        [266107] = "alert/onlyIfOnMe/ttsCustom_Fixate/isFixate_15", -- Thirst For Blood
    },
    [133870] = -- Diseased Lasher
    {
        [278961] = "kick", -- Decaying Mind
    },
    [131817] = -- Cragmaw the Infested
    {
        [260292] = "frontal/ttsCustom_Charge", -- Charge
        [260793] = "frontal", -- Indigestion
        [260333] = "damage", -- Tantrum
    },
    [133836] = -- Reanimated Guardian
    {
        --[266201] = "kick", -- Bone Shield
    },
    [138187] = -- Grotesque Horror
    {
        [413044] = "kick", -- Dark Echoes
    },
    [134284] = -- Fallen Deathspeaker
    {
        --[272183] = "kick", -- Raise Dead
        [266209] = "kick", -- Wicked Frenzy
    },    
    [133912] = -- Bloodsworn Defiler
    {
        [265433] = "kick", -- Withering Curse
        [265487] = "kick", -- Shadow Bolt Volley
        ["onCastSuccess"] = 
        {
            [265523] = "avoid/range_7/noSymbol/ttsCustom_Totem", -- Summon Spirit Drain Totem
        },
    },
    [135169] = -- Spirit Drain Totem
    {
        [265511] = "avoid/range_7/noSound", -- Spirit Drain
    },
    [131383] = -- Sporecaller Zancha
    {
        [272457] = "frontal", -- Shockwave
    },
    [138281] = -- Faceless Corruptor
    {
        [272609] = "frontal", -- Maddening Gaze
        ["onCastSuccess"] = 
        {
            [272592] = "swirly/ttsCustom_Tentacles", -- Abyssal Reach
        },
    },
    [133007] = -- Unbound Abomination
    {
        [269843] = "frontal", -- Vile Expulsion
    },
    [137103] = -- Blood Visage
    {
        [0] = "priority",
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Waycrest Manor
    --------------------------------------------------
    --------------------------------------------------
    [135240] = -- Soul Essence
    {
        --[267824] = "kick", -- Scar Soul
    },
    [131685] = -- Runic Disciple
    {
        --[426541] = "kick", -- Runic Bolt
        [264390] = "kick", -- Spellbind
    },
    [131585] = -- Enthralled Guard
    {
        --[265371] = "tank", -- Focused Strike
    },
    [135474] = -- Thistle Acolyte
    {
        --[264050] = "kick", -- Infected Thorn
        [266036] = "kick", -- Drain Essence
    },
    [135049] = -- Dreadwing Raven
    {
        [265346] = "kick", -- Pallid Glare
    },
    [131677] = -- Heartsbane Runeweaver
    {
        [263943] = "damage/onlyIfOnMe/ttsCustom_Defensive", -- Etch
        --[264105] = "", -- Runic Mark
    },
    [131587] = -- Bewitched Captain
    {
        [265372] = "frontal/range_15", -- Shadow Cleave
        [265368] = "kick", -- Spirited Defense
    },
    [135052] = -- Blight Toad
    {
        [265352] = "avoid/ignoreCombat/range_5", -- Toad Blight
    },
    [131824] = -- Sister Solena
    {
        --[260698] = "kick", -- Soul Bolt (Empowered)
        [260699] = "kick/noSound", -- Soul Bolt
        --[268077] = "alert/ttsCustom_Reduced healing", -- Aura of Apathy
        [260907] = "alert/ttsCustom_Mind Control", -- Soul Manipulation
    },
    [131825] = -- Sister Briar
    {
        [260701] = "kick/noSound", -- Bramble Bolt
        --[260697] = "kick", -- Bramble Bolt (Empowered)
        [260741] = "damage/onlyIfOnMe/ttsCustom_Defensive", -- Jagged Nettles
    },
    [131823] = -- Sister Malady
    {
        [268088] = "alert/ttsCustom_Move to live", -- Aura of Dread
        --[260696] = "kick", -- Ruinous Bolt  (Empowered)
        [260700] = "kick/noSound", -- Ruinous Bolt
    },
    [131666] = -- Coven Thornshaper
    {
        [264050] = "kick", -- Infected Thorn
        [264038] = "alert/onlyIfOnMe/ttsCustom_knockback", -- Uproot
    },
    [131858] = -- Thornguard
    {
        [257260] = "tank/ttsCustom_Enrage", -- Enrage
        --[264150] = "avoid/range_10/ignoreCombat", -- Shatter (doesn't work)
    },
    [135329] = -- Matron Bryndle
    {
        ["onCastSuccess"] = 
        {
            [265759] = "swirly", -- Splinter Spike
        },
        --[265760] = "tank/ttsCustom_Barrage", -- Thorned Barrage
        --[265741] = "", -- Drain Soul Essence
    },
    [131667] = -- Soulbound Goliath
    {
        --[260551] = "", -- Soul Thorns
        [260508] = "tank", -- Crush
    },
    [135048] = -- Gorestained Piglet
    {
        --[265474] = "", -- Eat Corpse
        --[265337] = "", -- Snout Smack
    },
    [134024] = -- Devouring Maggot 1
    {
        --[278440] = "", -- Infest
        [278444] = "kick/noSymbol", -- Infest
    },
    [142587] = -- Devouring Maggot 2
    {
        --[278440] = "", -- Infest
        [278444] = "kick/noSymbol", -- Infest
    },
    [137830] = -- Pallid Gorger
    {
        [271174] = "kick/range_10", -- Retch
    },
    [131586] = -- Banquet Steward
    {
        [265407] = "avoid/range_10", -- Dinner Bell
        [0] = "priority",
    },    
    [131863] = -- Raal the Gluttonous
    {
        [264923] = "frontal", -- Tenderize
        [264734] = "tank/ttsCustom_Get Closer", -- Consume All
        [264694] = "alert/ttsCustom_Breath/ttsOnMe_Dodge Breath", -- Rotten Expulsion
        [264931] = "alert/ttsCustom_Adds", -- Call Servant
    },
    [133361] = -- Wasting Servant
    {
        [0] = "priority",
    },
    [136541] = -- Bile Oozeling
    {
        [268234] = "avoid/ignoreCombat/range_5", -- Bile Explosion
    },
    [135234] = -- Diseased Mastiff
    {
        --[265642] = "", -- Diseased Crunch
    },
    [131849] = -- Crazed Marksman
    {
        --[264510] = "", -- Shoot
    },
    [131850] = -- Maddened Survivalist
    {
        [264520] = "kick", -- Severing Serpent
        ["onCastSuccess"] = 
        {
            [264525] = "swirly/delaySound_0.5", -- Shrapnel Trap
        },
    },
    [131821] = -- Faceless Maiden
    {
        --[256922] = "", -- Runic Blade
        [264407] = "kick", -- Horrific Visage
    },
    [135365] = -- Matron Alma
    {
        [265876] = "kick", -- Ruinous Volley
    },
    [131819] = -- Coven Diviner
    {
        --[426596] = "kick", -- Soul Bolt
    },
    [131812] = -- Heartsbane Soulcharmer
    {
        [263959] = "kick", -- Soul Volley
        --[264024] = "kick", -- Soul Bolt
        [263961] = "tank/ttsCustom_Candles", -- Warding Candles
    },
    [131545] = -- Lady Waycrest
    {
        [268278] = "kick/range_20", -- Wracking Chord
    },
    [131527] = -- Lord Waycrest
    {
        [261438] = "tank", -- Wasting Strike
    },
    [131864] = -- Gorak Tul
    {
        [266225] = "kick", -- Darkened Lightning
    },
    [135552] = -- Deathtouched Slaver
    {
        [268202] = "stun", -- Death Lens
    },
    ------- CLEU ENTRIES -------
    [264734] = "tank/ttsCustom_Get Closer/cleuStart", -- Raal's Consume All (nobody in range)
    [268306] = "swirly/cleuSuccess", -- Lady Waycrest's Discordant Cadenza
    --------------------------
    
}








-- Do not remove this comment, it is part of this aura: DefaultList - Legion Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- Black Rook Hold
    --------------------------------------------------
    --------------------------------------------------
    [98366] = -- Ghostly Retainer
    {
        --[200084] = "tank/noSound", -- Soul Blade
    },
    [98368] = -- Ghostly Protector
    {
        [200105] = "alert/ttsCustom_Focus Protector", -- Sacrifice Soul
        [0] = "priority",
    },
    [98370] = -- Ghostly Councilor
    {
        [199663] = "kick", -- Soul Blast
    },
    [98521] = -- Lord Etheldrin Ravencrest
    {
        [196883] = "kick", -- Spirit Blast
        [194966] = "alert/onlyIfOnMe/ttsCustom_Echoes", -- Soul Echoes
    },
    [98538] = -- Lady Velandras Ravencrest
    {
        --[196916] = "", -- Glaive Toss
        [225732] = "tank", -- Strike Down
    },
    [98542] = -- Amalgam of Souls
    {
        [195254] = "swirly/ttsOnMe_Sidestep", -- Swirling Scythe
        [194956] = "frontal", -- Reap Soul
        [194966] = "alert/onlyIfOnMe/ttsCustom_Echoes", -- Soul Echoes
        [196587] = "damage", -- Soul Burst
    },
    [98280] = -- Risen Arcanist
    {
        [200248] = "kick", -- Arcane Blitz
    },
    [100486] = -- Risen Arcanist (@ Boss)
    {
        [197797] = "kick", -- Arcane Blitz
    },
    [98275] = -- Risen Archer
    {
        [200345] = "stun/ttsCustom_Arrows", -- Arrow Barrage
    },
    [98243] = -- Soul-Torn Champion
    {
        [200261] = "frontal/range_15", -- Bonebreaking Strike
    },
    [98691] = -- Risen Scout
    {
        [200291] = "stun", -- Knife Dance
    },
    [101549] = -- Arcane Minion
    {
        [200256] = "swirly", -- Phased Explosion
    },
    [98706] = -- Commander Shemdah'sohn
    {
        [200261] = "frontal", -- Bonebreaking Strike
    },
    [98696] = -- Illysanna Ravencrest
    {
        --[197696] = "alert/ttsCustom_Beam", -- Eye Beams
        [197418] = "tank", -- Vengeful Shear
        --[197546] = "alert/onlyIfOnMe/ttsCustom_Glaive", -- Brutal Glaive
    },
    [100485] = -- Soul-torn Vanguard
    {
        [197974] = "frontal/range_15", -- Bonecrushing Strike
    },
    [98792] = -- Wyrmtongue Scavenger
    {
        [200784] = "stun/noSound", -- "Drink" Ancient Potion
        --[201176] = "stun", -- Throw Priceless Artifact
        [200913] = "frontal/noSymbol/range_20", -- Indigestion
    },
    [98813] = -- Bloodscent Felhound
    {
        [204896] = "kick", -- Drain Life
    },
    [98810] = -- Wrathguard Bladelord
    {
        [201139] = "tank", -- Brutal Assault
    },
    [102788] = -- Felspite Dominator
    {
        [227913] = "kick", -- Felfrenzy
        [203163] = "alert/onlyIfOnMe/ttsCustom_Fixate", -- Sic Bats!
    },
    [98949] = -- Smashspite the Hateful
    {
        [198079] = "tank/ttsCustom_Intercept", -- Hateful Gaze
        [198073] = "damage/ttsCustom_Knockback", -- Earthshaking Stomp
    },
    [102094] = -- Risen Swordsman
    {
        [214003] = "tank/noSound", -- Coup de Grace
    },
    [102095] = -- Risen Lancer
    {
        [214001] = "swirly", -- Raven's Dive
    },
    [98965] = -- Kur'talos Ravencrest
    {
        [198641] = "frontal/ttsCustom_Blade/ttsOnMe_Sidestep", -- Whirling Blade
        --[198635] = "tank", -- Unerring Shear
    },
    [98970] = -- Dantalionax
    {
        [199143] = "swirly", -- Cloud of Hypnosis
        [199193] = "alert/ttsCustom_Run soon", -- Dreadlord's Guile
        [202019] = "damage", -- Shadow Bolt Volley
        [201733] = "alert/ttsCustom_Swarm/onlyIfOnMe", -- Stinging Swarm
    },
    --[241672] = "alert/ttsCustom_Dodge/cleuSuccess", -- Latosius's Dark Obliteration
    
    --------------------------------------------------
    --------------------------------------------------
    -- Court of Stars
    --------------------------------------------------
    --------------------------------------------------
    [111563] = { -- Duskwatch Guard 1
        [209027] = "frontal/range_10", -- Quelling Strikes
    },
    [104246] = { -- Duskwatch Guard 2
        [209027] = "frontal/range_10", -- Quelling Strikes
    },
    [104247] = { -- Duskwatch Arcanist
        [209404] = "kick", -- Seal Magic
        [209410] = "kick", -- Nightfall Orb
    },
    [105704] = { -- Arcane Manifestation
        [209485] = "kick", -- Drain Magic
    },
    [104270] = { -- Guardian Construct
        [209495] = "frontal/range_10", -- Charged Smash
        [209413] = "kick", --Suppress
        [1] = "stealth"
    },
    [105699] = { -- Mana Saber
        [0] = "stealth", -- 
    },
    [104251] = { -- Duskwatch Sentry
        [210261] = "kick", -- Sound Alarm
        [0] = "priority", -- 
    },
    [107073] = { -- Duskwatch Reinforcement
        [212773] = "kick", -- Subdue
    },
    [105705] = { -- Bound Energy
        [212031] = "frontal", -- Charged Blast
    },    
    [104215] = { -- Patrol Captain Gerdo
        [207278] = "alert/ttsCustom_Jump", -- Arcane Lockdown
        [207261] = "swirly", -- Resonant Slash
    },
    [104918] = { -- Vigilant Duskwatch
        [215204] = "kick", -- Hinder
    },
    [105715] = { -- Watchful Inquisitor
        [211299] = "kick", -- Searing Glare
    },
    [104300] = { -- Shadow Mistress
        [211470] = "kick", -- Bewitch
    },
    [104277] = { -- Legion Hound
        [0] = "stealth", -- 
    },
    [104295] = { -- Blazing Imp
        [0] = "priority", -- 
    },
    [104278] = { -- Felbound Enforcer
        [211464] = "damage/ttsCustom_L O S", -- Fel Detonation
        [0] = "stealth",
    },
    [104273] = { -- Jazshariu
        [207979] = "frontal", -- Shockwave
    },
    [104274] = { -- Baalgar the Watchful
        [207980] = "kick", -- Disintegration Beam
    },
    [104275] = { -- Imacu'tya
        [397892] = "damage/ttsCustom_Stop Casting", -- Scream of Pain
    },
    [104217] = { -- Talixae Flamewreath
        [208165] = "kick", -- Withering Soul
        [207881] = "swirly", -- Infernal Eruption
    },
    [104218] = { -- Advisor Melandrus
        [209676] = "damage", --  Slicing Maelstrom
        [209628] = "alert/ttsCustom_Lines", --  Piercing Gale
        [209602] = "frontal/ttsCustom_Charge", --  Blade Surge
    },
    
    --------------------------------------------------
    --------------------------------------------------
    -- Darkheart Thicket
    --------------------------------------------------
    --------------------------------------------------
    [95769] = -- Mindshattered Screecher
    {
        [200630] = "kick", -- Unnerving Screech
    },
    [95771] = -- Dreadsoul Ruiner
    {
        --[200642] = "kick/noSound", -- Despair
        [200658] = "kick", -- Star Shower
        ["onCastSuccess"] = {
            [200658] = "swirly", -- Star Shower
        },
    },
    [95779] = -- Festerhide Grizzly
    {
        [200580] = "damage", -- Maddening Roar
    },
    [95766] = -- Crazed Razorbeak
    {
        [200768] = "frontal/ttsCustom_Charge/ttsOnMe_Sidestep/delayTargetCheck_0", -- Propelling Charge
        [0] = "tank",
    },
    [96512] = -- Archdruid Glaidalis
    {
        [198379] = "frontal/ttsCustom_Charge/ttsOnMe_Tank/delayTargetCheck_0", -- Primal Rampage
    },
    [99360] = -- Vilethorn Blossom
    {
        [201123] = "swirly", -- Root Burst
    },
    
    [99359] = -- Rotheart Keeper
    {
        [220369] = "alert/ttsCustom_Mushroom", -- Vile Mushroom
        [0] = "priority",
    },
    [101991] = -- Nightmare Dweller
    {
        [204243] = "kick", -- Tormenting Eye
    },    
    [103344] = -- Oakheart
    {
        [204611] = "tank", -- Crushing Grip (precast)
        [204644] = "tank/noSound", -- Crushing Grip (while gripped)
        [204666] = "damage/ttsCustom_Knockback", -- Shattered Earth
        [204667] = "frontal/range_15", -- Nightmare Breath
        [204574] = "swirly/delaySound_1/ttsCustom_Move", -- Strangling Roots
    },
    [100527] = -- Dreadfire Imp
    {
        [201399] = "kick", -- Dread Inferno
    },
    [99366] = -- Taintheart Summoner
    {
        [201839] = "kick", -- Curse of Isolation
    },
    [100531] = -- Bloodtainted Fury
    {
        [201226] = "frontal/ttsCustom_Charge/ttsOnMe_Sidestep/delayTargetCheck_0", -- Blood Assault
        [0] = "tank",
        [201272] = "swirly", -- Blood Bomb
    },
    [100532] = -- Bloodtainted Burster
    {
        [225562] = "kick", -- Blood Metamorphosis
    },
    [113398] = -- Bloodtainted Fury (Re-formed Burster)
    {
        [201226] = "frontal/ttsCustom_Charge/ttsOnMe_Sidestep/delayTargetCheck_0", -- Blood Assault
        [0] = "tank",
        [201272] = "swirly", -- Blood Bomb
    },
    [99200] = -- Dresaron
    {
        [199329] = "frontal", -- Breath of Corruption (pre"cast", actually an instant)
        -- [199332] = "frontal", -- Breath of Corruption (the actual breath, also an instant)
        [199345] = "alert/ttsCustom_Wind", -- Down Draft
        [199389] = "damage", -- Earthshaking Roar
    },
    [99192] = -- Shade of Xavius
    {
        [200289] = "alert/onlyIfOnMe/ttsCustom_Stay Away", -- Growing Paranoia
        [200185] = "alert/onlyIfOnMe/ttsCustom_Group up", -- Nightmare Bolt
        --[200182] = "tank", -- Festering Rip
        [200050] = "damage", -- Apocalyptic Nightmare
        [200238] = "alert/onlyIfOnMe/ttsCustom_Defensive", -- Feed on the Weak        
    },
    
    --------------------------------------------------
    --------------------------------------------------
    -- Halls of Valor
    --------------------------------------------------
    --------------------------------------------------
    [95842] = { -- Valarjar Thundercaller
        [198595] = "kick", -- Thunderous Bolt
    },
    [97068] = { -- Storm Drake (Entrance)
        [198888] = "frontal", -- Lightning Breath
    },
    [99891] = { -- Storm Drake (Fenryr)
        [198888] = "frontal", -- Lightning Breath
    },
    [96574] = { -- Stormforged Sentinel
        [210875] = "avoid/range_15", -- Charged Pulse
    },
    [95834] = { -- Valarjar Mystic
        [215433] = "kick", -- Holy Radiance
        [198934] = "tank/ttsCustom_Rune", -- Rune of Healing
    },
    [96664] = { -- Valarjar Runecarver
        [198959] = "kick", -- Etch
    },
    [94960] = { -- Hymdall
        [193235] = "swirly", -- Dancing Blade
        [193092] = "tank", -- Bloodletting Sweep
    },
    
    [95832] = { -- Valarjar Shieldmaiden 1
        [1] = "frontal/range_10",
        [199050] = "tank/noSound", -- Mortal Hew
    },
    [101639] = { -- Valarjar Shieldmaiden 2
        [1] = "frontal/range_10",
        [199050] = "tank/noSound", -- Mortal Hew
    },
    [96640] = { -- Valarjar Marksman
        [199210] = "frontal", -- Penetrating Shot
    },
    [97197] = { -- Valarjar Purifier
        [192563] = "kick", -- Cleansing Flames
    },
    [101637] = { -- Valarjar Aspirant
        [191508] = "frontal", -- Blast of Light
        [199034] = "frontal/ttsCustom_Charge", -- Valkyra's Advance
    },    
    [97219] = { -- Solsten
        [200901] = "damage", -- Eye of the Storm
    },
    [97202] = { -- Olmyr the Enlightened
        [192288] = "kick", -- Searing Light
        [192158] = "alert/ttsCustom_Orbs", -- Sanctify
    },
    [95833] = { -- Hyrja
        [192018] = "frontal", -- Shield of Light
        [192307] = "alert/ttsCustom_Orbs", -- Sanctify
        [200901] = "damage", -- Eye of the Storm
    },
    [96609] = { -- Gildedfur Stag
        [199146] = "frontal/ttsCustom_Charge", -- Bucking Charge
    },
    [96934] = { -- Valarjar Trapper
        [199341] = "swirly", -- Bear Trap
    },
    [95674] = { -- Fenryr 1
        [196543] = "damage/ttsCustom_Stop Casting", -- Unnerving Howl
    },
    [99868] = { -- Fenryr 2
        [196543] = "damage/ttsCustom_Stop Casting", -- Unnerving Howl
    },
    [97083] = { -- King Ranulf
        [199726] = "kick", -- Unruly Yell
    },
    [95843] = { -- King Haldor
        [199726] = "kick", -- Unruly Yell
    },
    [97081] = { -- King Bjorn
        [199726] = "kick", -- Unruly Yell
    },
    [97084] = { -- King Tor
        [199726] = "kick", -- Unruly Yell
    },
    [95675] = { -- God-King Skovald
        [193826] = "damage", -- Ragnarok
    },
    [95676] = { -- Odyn
        [197961] = "alert/ttsCustom_Runes", -- Runic Brand
        [198077] = "alert/ttsCustom_Orbs", -- Shatter Spears
    },
    [102019] = { -- Stormforged Obliterator
        [198750] = "kick", -- Surge
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Neltharion's Lair
    --------------------------------------------------
    --------------------------------------------------
    [98406] = { -- Embershard Scorpion
        [193941] = "tank", -- Impaling Shard
    },
    [91001] = { -- Tarspitter Lurker
        [183465] = "frontal/range_15", -- Viscid Bile
    },
    [91000] = { -- Vileshard Hulk
        [193505] = "tank/ttsCustom_Knockback", -- Fracture
        [226296] = "frontal", -- Piercing Shards
    },
    [101438] = { -- Vileshard Chunk
        [226287] = "avoid/range_15", -- Crush
    },
    [91003] = { -- Rokmora
        [188169] = "frontal", -- Razor Shards
        [188114] = "damage", -- Shatter
    },
    [113998] = { -- Mightstone Breaker 1
        [183088] = "damage/ttsCustom_Move", -- Avalanche
    },
    [90997] = { -- Mightstone Breaker 2
        [183088] = "damage/ttsCustom_Move", -- Avalanche
    },
    [92612] = { -- Mightstone Breaker (Summoned by Drums)
        [183088] = "damage/ttsCustom_Move", -- Avalanche
    },
    [92610] = { -- Understone Drummer
        [183526] = "stun", -- War Drums
    },
    [91006] = -- Rockback Gnasher
    {
        [202181] = "kick", -- Stone Gaze
    },
    [90998] = -- Blightshard Shaper
    {
        --[202108] = "swirly", -- Petrifying Totem
    },
    [94224] = { -- Petrifying Totem
        --[0] = "priority", -- 
    },
    [91004] = { -- Ularog Cragshaper
        [198496] = "tank", -- Sunder
        [198428] = "alert/ttsCustom_Move", -- Strike of the Mountain
        [193375] = "alert/ttsCustom_Totems", -- Bellow of the Deeps
    },
    [98081] = { -- Bellowing Idol
        --[0] = "priority", -- 
    },
    [101437] = { -- Burning Geode
        [0] = "priority", -- 
    },
    [92538] = { -- Tarspitter Grub
        [193803] = "stun/ttsCustom_Maggot", -- Metamorphosis 
    },
    [91005] = { -- Naraxas
        [199176] = "tank/ttsCustom_Run Away", -- Spiked Tongue
        [198963] = "tank/ttsCustom_Get Closer", -- Putrid Skies
    },
    [101075] = { -- Wormspeaker Devout
        [0] = "priority", -- 
    },
    [113537] = -- Emberhusk Dominator 1
    {
        [226406] = "frontal/noSound", -- Ember Swipe        
    },
    [102253] = -- Understone Demolisher
    {
        [188587] = "stun", -- Charskin      
    },
    [102287] = -- Emberhusk Dominator 2
    {
        [226406] = "frontal/noSound", -- Ember Swipe
    },
    [102232] = -- Rockback Trapper
    {
        [193585] = "kick", -- Bound
    },
    [91007] = { -- Dargrul
        [200732] = "tank", -- Molten Crash
        [200700] = "frontal", -- Landslide
        [200551] = "swirly", -- Crystal Spikes
        [200418] = "damage/ttsCustom_Hide", -- Magma Wave (precast)
        [200404] = "damage/noSound", -- Magma Wave (damage)
        
    },
    [101476] = { -- Molten Charskin
        [0] = "priority", -- 
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Return to Karazhan: Lower
    --------------------------------------------------
    --------------------------------------------------
    [114626] = -- Forlorn Spirit
    {
        [228254] = "kick", -- Soul Leech
    },
    [114542] = -- Ghostly Philanthropist
    {
        [227999] = "stun", -- Pennies from Heaven
    },
    [114329] = -- Luminore
    {
        [228025] = "kick", -- Heat Wave
    },
    [114330] = -- Babblet
    {
        [228221] = "alert/ttsCustom_Fixate", -- Severe Dusting
    },
    [114328] = -- Coggleston
    {
        [227987] = "kick", -- Dinner Bell
    },
    [114261] = -- Toe Knee
    {
        [227568] = "avoid/range_7", -- Burning Leg Sweep        
    },
    [114251] = -- Galindre
    {
        [227776] = "alert/ttsCustom_Fly", -- Wondrous Radiance    
        [227341] = "kick", -- Flashy Bolt
    },
    [114526] = -- Ghostly Understudy
    {
        [227917] = "kick", -- Poetry Slam
    },
    [116549] = -- Backup Singer
    {
        [232115] = "kick", -- Firelands Portal
    },
    [114544] = -- Skeletal Usher
    {
        [227966] = "damage/ttsCustom_Look Away", -- Flashlight
    },
    [114632] = -- Spectral Attendant
    {
        [228279] = "kick", -- Shadow Rejuvenation
    },
    [114633] = -- Spectral Valet
    {
        [228278] = "kick", -- Demoralizing Shout
    },
    [114796] = -- Wholesome Hostess
    {
        [0] = "priority", -- 
        [228625] = "kick", -- Banshee Wail
    },
    [183425] = -- Wholesome Host
    {
        [0] = "priority", -- 
        [228625] = "kick", -- Banshee Wail
    },
    [114783] = -- Reformed Maiden
    {
        [241798] = "kick", -- Kiss of Death
    },
    [183423] = -- Reformed Bachelor
    {
        [241798] = "kick", -- Kiss of Death
    },
    [114792] = -- Virtuous Lady
    {
        [241808] = "kick", -- Shadowbolt Volley
        [228555] = "kick", -- Horrific Visage
    },
    [183424] = -- Virtuous Gentleman
    {
        [241808] = "kick", -- Shadowbolt Volley
        [228555] = "kick", -- Horrific Visage
    },
    [113971] = -- Maiden of Virtue
    {
        [227800] = "kick", -- Holy Shock
        [227823] = "damage", -- Holy Wrath
    },
    [114629] = -- Spectral Retainer
    {
        [0] = "priority", -- 
        [241784] = "kick", -- Shadowbolt Volley
        [228280] = "kick", -- Oath of Fealty
    },
    [114794] = -- Skeletal Hound
    {
        [0] = "stealth", -- 
    },
    [114628] = -- Skeletal Waiter
    {
        [230297] = "tank", -- Brittle Bones
    },
    [114316] = -- Baroness Dorothea Millstipe
    {
        [227545] = "kick", -- Mana Drain
    },
    [114318] = -- Baron Rafe Dreuger
    {
        [227646] = "avoid/range_7", -- Iron Whirlwind
    },
    [114320] = -- Lord Robin Daris
    {
        [227463] = "swirly", -- Whirling Edge
    },
    [114319] = -- Lady Keira Berrybuck
    {
        [227616] = "kick", -- Empowered Arms
    },
    [114317] = -- Lady Catriona Von'Indi
    {
        [0] = "priority", -- 
        [227578] = "kick", -- Healing Stream
    },
    [114321] = -- Lord Crispin Ference
    {
        [227672] = "frontal", -- Will Breaker
    },
    [114803] = -- Spectral Stable Hand
    {
        [228606] = "kick", -- Healing Stomp
    },
    [114804] = -- Spectral Charger
    {
        [228603] = "frontal/ttsCustom_Charge", -- Charge
    },
    [114262] = -- Attumen the Huntsman
    {
        [228852] = "alert/ttsCustom_Soak", -- Shared Suffering
    },
    [114264] = -- Midnight
    {
        [227363] = "damage/ttsCustom_Stop Casting", -- Mighty Stomp
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Return to Karazhan: Lower
    --------------------------------------------------
    --------------------------------------------------
    [114627] = -- Shrieking Terror
    {
        [228239] = "kick", -- Terrifying Wail
    },
    [114350] = -- Shade of Medivh
    {
        [227592] = "kick", -- Frostbite
        [228269] = "alert/ttsCustom_Don't Move", -- Flame Wreath
    },
    [115484] = -- Fel Bat
    {
        [229622] = "frontal", -- Fel Breath
    },
    [115486] = -- Erudite Slayer
    {
        [229608] = "tank", -- Mighty Swing
        [0] = "frontal", -- 
    },
    [114790] = -- Viz'aduum
    {
        [229083] = "kick", -- Burning Blast
        [229151] = "frontal", -- Disintegrate
    },
}







-- Do not remove this comment, it is part of this aura: DefaultList - WoD Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- Grimrail Depot
    --------------------------------------------------
    --------------------------------------------------
    [81212] = -- Grimrail Overseer
    {
        [164168] = "tank/ttsCustom_Dash", -- Dash
    },
    [81236] = -- Grimrail Technician
    {
        [164192] = "kick", -- 50.000 Volts
        [163966] = "stun", -- Activating
    },
    [77816] = -- Borka the Brute
    {
        [162617] = "damage/ttsCustom_Stop Casting", -- Slam
        [161090] = "tank/ttsCustom_Dash", -- Mad Dash
    },
    [77803] = -- Railmaster Rocketspark
    {
        [162407] = "damage", -- X21-01A Missile Barrage
    },
    [80937] = -- Grom'kar Gunner
    {
        [166675] = "tank", -- Shrapnel Blast
        [0] = "frontal",
    },
    [88163] = -- Grom'kar Cinderseer
    {
        [176032] = "tank", -- Flametongue
    },
    [80935] = -- Grom'kar Boomer
    {
        [176127] = "tank", -- Cannon Barrage
        [156301] = "swirly", -- Blackrock Mortar
        [0] = "frontal",
    },
    [79545] = -- Nitrogg Thundertower
    {
        [163550] = "frontal", -- Blackrock Mortar
    },
    [79720] = -- Grom'kar Boomer (Boss)
    {
        [156301] = "swirly", -- Blackrock Mortar
        [0] = "priority", -- 
    },
    [77483] = -- Grom'kar Gunner (Boss)
    {
        [160943] = "frontal", -- Shrapnel Blast
    },
    [82579] = -- Grom'kar Far Seer
    {
        [166335] = "kick", -- Storm Shield
        [166341] = "swirly", -- Thunder Zone
    },
    [82597] = -- Grom'kar Captain
    {
        [166380] = "avoid/range_7", -- Reckless Slash
    },
    [80005] = -- Skylord Tovra
    {
        [162066] = "swirly", -- Freezing Snare
        [162058] = "frontal", -- Spinning Spear
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Iron Docks
    --------------------------------------------------
    --------------------------------------------------
    [87252] = { -- Unruly Ogron
        [0] = "stealth",
    },
    [83578] = { -- Unruly Laborer 1
        [0] = "stealth",
    },
    [83761] = { -- Unruly Laborer 2
        [0] = "stealth",
    },
    [86809] = -- Grom'kar Incinerator
    {
        [167516] = "frontal", -- Shrapnel Blast
    },
    [83025] = -- Grom'kar Battlemaster
    {
        [167232] = "avoid/range_7", -- Bladestorm
    },
    [83763] = -- Grom'kar Technician 1 
    {
        [172649] = "swirly", -- Grease Vial
    },
    [81432] = -- Grom'kar Technician 2
    {
        [172649] = "swirly", -- Grease Vial
    },
    [83026] = -- Siegemaster Olugar
    {
        [172982] = "avoid/range_7", -- Shattering Strike
        [172952] = "swirly", -- Throw Gatecrasher
    },
    [84520] = -- Pitwarden Gwarnok
    {
        [172943] = "tank", -- Brutal Inspiration
        [167232] = "avoid/range_7", -- Bladestorm
    },
    [81305] = -- Fleshrender Nok'gar
    {
        [164426] = "alert", -- Reckless Provocation
    },
    [80816] = -- Ahri'ok Dugru
    {
        [163689] = "alert", -- Sanguine Sphere
        [0] = "priority", --
    },
    [80805] = -- Makogg Emberblade
    {
        [163665] = "frontal", -- Flaming Slash
    },
    [80808] = -- Neesa Nox
    {
        [163390] = "swirly", -- Ogre Traps
    },
    [83390] = -- Thunderlord Wrangler
    {
        [0] = "frontal", -- Rending Cleave
    },
    [83392] = -- Rampaging Clefthoof
    {
        [173384] = "frontal", -- Trampling Stampede
    },
    [83389] = -- Ironwing Flamespitter
    {
        [173514] = "frontal", -- Lava Blast
        [173480] = "swirly", -- Lava Barrage
    },
    [84028] = -- Siegemaster Rokra
    {
        [172982] = "avoid/range_7", -- Shattering Strike
        [172952] = "swirly", -- Throw Gatecrasher
    },
    [79852] = -- Oshir
    {
        [0] = "damage", -- 
    },
    [89011] = -- Rylak Skyterror
    {
        [178154] = "kick", -- 
    },
    [83613] = -- Koramar
    {
        [0] = "priority", -- 
        [168402] = "avoid/range_7", -- Bladestorm
        
    },
    --------------------------------------------------
    --------------------------------------------------
    -- Shadowmoon Burial Grounds
    --------------------------------------------------
    --------------------------------------------------
    [75715] = { -- Reanimated Ritual Bones
        [164907] = "tank", -- Void Slash
    },
    [75713] = { -- Shadowmoon Bone-Mender
        [152818] = "kick", -- Shadow Mend
    },
    [75652] = { -- Void Spawn
        [152964] = "damage/ttsCustom_L O S", -- Void Pulse 
    },
    [75509] = { -- Sadana Bloodfury
        [153094] = "damage", -- Whispers of the Dark Star
        [153240] = "swirly", -- Daggerfall
    },
    [75966] = -- Defiled Spirit
    {
        [0] = "priority", -- 
    },
    [76446] = { -- Shadowmoon Dominator
        [398150] = "kick", -- Domination 
        [153776] = "kick", -- Rending Voidlash 
    },
    [75979] = { -- Exhumed Spirit
        [398206] = "kick", -- Death Blast
    },
    [75829] = { -- Nhallish
        [152792] = "frontal", -- Void Blast
    },
    [76104] = { -- Monstrous Corpse Spider
        [156718] = "kick", -- Necrotic Burst
    },
    [76057] = { -- Carrion Worm
        [153395] = "frontal", -- Body Slam
        [0] = "tank", -- aim it away from the group
    },
    [75452] = { -- Bonemaw
        [154175] = "frontal", -- Body Slam
        [153804] = "alert", -- Inhale
    },
    [200035] = { -- Carrion Worm (boss)
        [154175] = "frontal", -- Body Slam
    },
    [76407] = { -- Ner'zhul
        [154442] = "frontal", -- Malevolance
    },
    --------------------------------------------------
    --------------------------------------------------
    -- The Everbloom
    --------------------------------------------------
    --------------------------------------------------
    [81819] = -- Everbloom Naturalist
    {
        [164965] = "kick", -- Choking Vines
    },
    [81985] = -- Everbloom Cultivator
    {
        --[165213] = "kick", -- Enraged Growth
        ["onCastSuccess"] = 
        {
            --[165213] = "tank/noSymbol/ttsCustom_Enrage", -- Enraged Growth
        },
    },
    [86372] = -- Melded Berserker
    {
        [172578] = "avoid/range_7", -- Bounding Whirl
        [38166] = "tank/noSymbol/ttsCustom_Enrage", -- Enrage
    },
    [81820] = -- Everbloom Mender
    {
        [164887] = "kick", -- Healing Waters
    },
    [81984] = -- Gnarlroot
    {
        ["onCastSuccess"] = 
        {
            [169494] = "swirly", -- Living Leaves
        },
        [426500] = "alert/ttsCustom_Roots", -- Gnarled Roots
    },
    [84767] = -- Twisted Abomination
    {
        [169445] = "damage", -- Noxious Eruption
    },
    [83894] = -- Dulhu
    {
        [427510] = "frontal/ttsCustom_Puddles/ttsOnMe_Charge/delayTargetCheck_0", -- Noxious Charge
    },
    [83892] = -- Life Warden Gola
    {
        [427498] = "damage", -- Torrential Fury
        [168082] = "kick", -- Revitalize
    },
    [83893] = -- Earthshaper Telu
    {
        [427459] = "kick", -- Toxic Bloom
        [427509] = "damage", -- Terrestrial Fury
    },
    [81522] = -- Witherbark
    {
        --[164306] = "alert/ttsCustom_Fixate", -- Unchecked Growth
        [164357] = "frontal", -- Parched Gasp
        [164275] = "alert/ttsCustom_Bonus Damage", -- Brittle Bark
        [164718] = "alert/ttsCustom_Bonus Over", -- Cancel Brittle Bark
    },
    ------- CLEU ENTRY -------
    [177731] = "swirly/cleuSuccess", -- Witherbark Swirly
    --------------------------
    [81737] = -- Unchecked Growth
    {
        [181113] = "alert/ttsCustom_Add", -- Encounter Spawn
    },
    [84989] = -- Infested Icecaller
    {
        --[169840] = "kick", -- Frostbolt
        [426845] = "alert/ttsCustom_Dodge", -- Cold Fusion
    },
    [84957] = -- Putrid Pyromancer
    {
        [169839] = "kick", -- Pyroblast
        [427223] = "damage", -- Cinderbolt Salvo
    },
    [84990] = -- Addled Arcanomancer
    {
        --[169841] = "kick", -- Arcane Blast
        [426974] = "alert/ttsCustom_Move/onlyIfOnMe", -- Spatial Disruption
    },
    [82682] = -- Archmage Sol
    {
        --[427899] = "damage", -- Cinderbolt Storm
        --[428139] = "swirly/ttsCustom_Bait", -- Spatial Compression
        --[428082] = "alert/ttsCustom_Dodge", -- Glacial Fusion
    },
    [83846] = -- Yalnu
    {
        [169179] = "damage", -- Colossal Blow
        [428823] = "alert/ttsCustom_Tree Incoming", -- Verdant Eruption
        --[169613] = "alert", -- Genesis
        
    },
    ------- CLEU ENTRY -------
    [428746] = "alert/ttsCustom_Bonus Damage/cleuSuccess", -- Lady Baihu's Brushfire
    [428823] = "alert/ttsCustom_Bonus over/cleuSuccess", -- Yalnu's Verdant Eruption
    
    --------------------------
    [84400] = -- Gnarled Ancient
    {
        [169929] = "frontal/noSound", -- Lumbering Swipe        
        [0] = "priority",
    },
    
    
}









-- Do not remove this comment, it is part of this aura: DefaultList - MoP Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- Temple of the Jade Serpent
    --------------------------------------------------
    --------------------------------------------------
    [200126] = { -- Fallen Waterspeaker
        [397889] = "kick", -- Tidal Burst
    },
    [59873] = { -- Corrupt Living Water
        [397878] = "damage/ttsCustom_L O S", -- Tainted Ripple
    },
    [56448] = { -- Wise Mari
        [397783] = "alert/ttsCustom_Beam", -- Wash Away
    },
    [59555] = { -- Haunting Sha
        [395859] = "kick", -- Haunting Scream
    },
    [57109] = { -- Minion of Doubt
        [397931] = "tank", -- Dark Claw
    },
    [65317] = { -- Xiang
        [0] = "damage", -- 
    },
    [59547] = { -- Jiang
        [0] = "damage", -- 
    },
    [59546] = { -- The Talking Fish
        [395872] = "kick", -- Sleepy Soliloquy
    },
    [59553] = { -- The Songbird Queen
        [396001] = "avoid/range_7", -- Territorial Display
    },
    [59545] = { -- The Golden Beetle
        [0] = "priority", -- 
    },
    [59552] = { -- The Crybaby Hozen
        [396018] = "kick", -- Fit of Rage
    },
    [200387] = { -- Shambling Infester
        [398300] = "frontal", -- Flames of Doubt
    },
    [200137] = { -- Depraved Mistweaver
        [397914] = "kick", -- Defiling Mist
    },
    [56732] = { -- Liu Flameheart
        [106823] = "tank", -- Serpent Strike
        [106841] = "tank", -- Serpent Strike
        [106859] = "avoid/range_7", -- Serpent Kick
        [106864] = "avoid/range_7", -- Serpent Kick
    },
    [56762] = -- Yu'Lon
    {
        [396907] = "frontal", -- Jade Fire Breath
    },
}










-- Do not remove this comment, it is part of this aura: DefaultList - Cata Dungeons - NPA
--[[
------------------------------------
------------------------------------

This is a "Default List".

If you edit this list, your changes will be overwritten next time you update the WA.
To make permanent edits to individual entries you can use a "User List" instead. 
Those can also be used to make your own lists from scratch.

See the documentation for a detailed explanation of everything.

------------------------------------
------------------------------------   
]]--

aura_env.unitAndSpellList = {
    --------------------------------------------------
    --------------------------------------------------
    -- Throne of the Tides
    --------------------------------------------------
    --------------------------------------------------
    [212681] = -- Vicious Snap Dragon
    {
        [426663] = "alert/onlyIfOnMe/ttsCustom_Fixate/isFixate_0", -- Ravenous Pursuit
        [0] = "priority",
    },
    [41096] = -- Naz'jar Oracle
    {
        [76813] = "kick", -- Healing Wave
        [76820] = "kick", -- Hex
    },
    [41139] = -- Naz'jar Oracle (gauntlet)
    {
        [76813] = "kick", -- Healing Wave
        [76820] = "kick", -- Hex
    },
    [40577] = -- Naz'jar Sentinel
    {
        [426741] = "tank", -- Shellbreaker
        [428542] = "alert/onlyIfOnMe/ttsCustom_Heal Absorb", -- Crushing Depths
    },
    [214140] = -- Naz'jar Sentinel (gauntlet)
    {
        [426741] = "tank", -- Shellbreaker
        [428542] = "alert/onlyIfOnMe/ttsCustom_Heal Absorb", -- Crushing Depths
    },
    [212673] = -- Naz'jar Ravager
    {
        [426645] = "frontal", -- Acid Barrage
        [426684] = "swirly", -- Volatile Bolt
        [0] = "stealth",
    },
    [40634] = -- Naz'jar Tempest Witch
    {
        --[426768] = "kick", -- Lightning Bolt
        --[75992] = "alert/ttsCustom_Spread", -- Lightning Surge
    },
    [214209] = -- Naz'jar Tempest Witch (gauntlet)
    {
        --[426768] = "kick", -- Lightning Bolt
        [75992] = "alert/ttsCustom_Spread", -- Lightning Surge
    },
    [40586] = -- Lady Naz'jar
    {
        [428263] = "kick/noSound", -- Water Bolt
        [428374] = "damage", -- Focused Tempest
        [427771] = "swirly", -- Geysers
        [428054] = "alert/onlyIfOnMe/ttsCustom_Get Out", -- Shock Blast
        ["onCastSuccess"] = {
            --[428054] = "alert/ttsCustom_Dodge" -- Shock Blast
        },
        --[75683] = "cast", -- High Tide
    },
    [44404] = -- Naz'jar Frost Witch
    {
        [428103] = "kick/noSound", -- Frostbolt
        --[428329] = "instant", -- Icy Veins
    },
    [40633] = -- Naz'jar Honor Guard
    {
        --[428291] = "instant", -- Slithering Assault
        [428293] = "frontal/range_10", -- Trident Flurry
    },
    [40765] = -- Commander Ulthok
    {
        [427670] = "tank", -- Crushing Claw
        ["onCastSuccess"] = {
            [427672] = "swirly", -- Bubbling Fissure
        },
        [427456] = "alert/ttsCustom_Adds", -- Awaken Ooze
        [427668] = "damage/ttsCustom_Knockback", -- Festering Shockwave
    },
    [40936] = -- Faceless Watcher
    {
        [428926] = "alert/ttsCustom_Grip", -- Clenching Tentacles
        [429021] = "tank", -- Crush
        --[76590] = "alert/ttsCustom_Get Out", -- Shadow Smash
        [0] = "stealth",
    },
    [212775] = -- Faceless Seer
    {
        [426783] = "kick", -- Mind Flay
        [426796] = "alert/ttsCustom_Dodge", -- Null Blast
    },
    [212778] = -- Minion of Ghur'sha
    {
        [426905] = "stun/noSound", -- Psionic Pulse
    },
    [40825] = -- Erunak Stonespeaker
    {
        ["onCastSuccess"] = {
            [429051] = "swirly/ttsCustom_Move", -- Earthfury
            [429037] = "alert/ttsCustom_Totem", -- Stormflurry Totem
        },
        --[429048] = "instant", -- Flame Shock
    },
    [214117] = -- Stormflurry Totem
    {
        [0] = "priority",
    },
    [40788] = -- Mindbender Ghur'sha
    {
        [429172] = "alert/ttsCustom_L O S/doBar", -- Terrifying Vision
    },
    [40943] = -- Gilgoblin Aquamage
    {
        [429176] = "kick", -- Aquablast
    },
    [40925] = -- Tainted Sentry
    {
        [76634] = "damage", -- Swell
    },
    [213770] = -- Ink of Ozumat
    {
        [428530] = "frontal", -- Murk Spew
        [428868] = "damage", -- Putrid Roar
        [428401] = "alert/ttsCustom_Puddles", -- Blotting Barrage
        [428889] = "tank/ttsCustom_Get closer", -- Foul Bolt (if tank is not in melee range)
    },
    ------- CLEU ENTRY -------
    --[428674] = "alert/ttsCustom_Clean Up/cleuSuccess", -- Neptulon's Cleansing Flux
    --------------------------
    [213806] = -- Splotch
    {
        [428526] = "kick/noSound", -- Ink Blast
    },
    
    
    --------------------------------------------------
    --------------------------------------------------
    -- Vortex Pinnacle
    --------------------------------------------------
    --------------------------------------------------
    [45915] = { -- Armored Mistral
        [410999] = "avoid/range_20", -- Pressurized Blast
    },
    [45912] = { -- Wild Vortex
        [410870] = "kick", -- Cyclone
    },
    [45917] = { -- Cloud Prince
        [411002] = "damage/ttsCustom_Wind", -- Turbulence
        [411004] = "swirly", -- Bomb Cyclone        
    },
    [43878] = { -- Grand Vizier Ertan
        [86331] = "kick/noSound", -- Lightning Bolt
    },
    [45924] = { -- Turbulent Squall
        [88170] = "kick", -- Cloudburst
    },
    [45922] = { -- Empyrean Assassin
        --[88186] = "kick", -- Vapor Form
    },
    [45919] = { -- Young Storm Dragon
        [411012] = "frontal", -- Chilling Breath
        [88194] = "damage", -- Icy Buffet
    },
    [43873] = { -- Altairus
        [88308]= "frontal", -- Chilling Breath
        [413313] = "alert/ttsCustom_Wind", -- Change Winds
    },
    [413295]= "swirly/ttsCustom_Circle/cleuSuccess", -- Altairus's Downburst
    
    [45928] = { -- Executor of the Caliph
        [413387] = "damage", -- Crashing Stone
        [87761] = "kick", -- Rally
        --[87759] = "frontal", -- Shockwave
    },
    [45935] = { -- Temple Adept
        --[0] = "priority", -- Murders tanks
        [87779] = "kick", -- Greater Heal
    },
    [45926] = { -- Servant of Asaad
        [0] = "tank",
        --[87771] = "tank", -- Sure Strike
    },
    
    [45930] = { -- Minister of Air
        [87762] = "alert/ttsCustom_Hide/onlyIfOnMe", -- Lightning Lash
        ["onCastSuccess"] = {
            [87762] = "alert/ttsCustom_Get Out/onlyIfOnMe/delaySound_4.8", -- Lightning Lash
        },
        --[413385] = "alert/ttsCustom_Get Out", -- Overload Grounding Field
    },
    [43875] = { -- Asaad
        [86911] = "alert/ttsCustom_Hide", -- Unstable Grounding Field
        [96260] = "alert/ttsCustom_Add", -- Summon Skyfall Nova
    },
    [87618] = "damage/delaySound_2/ttsCustom_Jump/cleuStart", -- Asaad's Static Cling 
    [52019] = -- Skyfall Nova
    {
        [0] = "priority",
    },
}








