-- Care Interrupt V 4.12
-- Version LUA Snipped
-- Set Priority to 10
-- interrupt Only Important Spell at Specific Mob
-- IROVar.CareInterrupt(unit e.g. "target") ; return true / false
-- IROVar.CareInterruptLV2(unit e.g. "target") ; return true / false ; interrupt only in list
-- IROVar and IROVar.CareInterrupt and IROVar.CareInterrupt("target")

-- Combo %Cast+Care Interrupt+Smart Interrupt
--[[
    PercentCastbar2 and IROVar and IROVar.CareInterrupt and
    PercentCastbar2()and IROVar.CareInterrupt("target")and
    ((not NextInterrupter) or NextInterrupter.IsMyTurn())
]]

--[[
    [instance name]={[mob name]={[spell name] = true / lua scrip}} interrupt ONLY Spell in list on this mob
    [instance name]={[mob name]=false} NEVER interrupt all spell on this mob
]]
IROVar.MobListForInterrupt = {
    ["Mists of Tirna Scithe"] = {
        ["Ingra Maloch"] = {["Spirit Bolt"] = true,},
        ["Mistcaller"] = {["Patty Cake"] = true,},
        ["Tred'ova"] = {
            ["Parasitic Pacification"] = true,
            ["Parasitic Incapacitation"] = true,
            ["Parasitic Domination"] = true,
            ["Consumption"] = [[return TMW.CNDT.Env.AuraDur("target", "gorging shield", "HELPFUL")==0]],
        },
        ["Drust Harvester"] = {["Harvest Essence"] = true,},
        ["Mistveil Tender"] = {["Nourish the Forest"] = true,},
        ["Mistveil Shaper"] = {["Bramblethorn Coat"] = true,},
        ["Mistveil Guardian"] = {["Bucking Rampage"] = true,},
        ["Spinemaw Staghorn"] = {
            ["Stimulate Resistance"] = true,
            ["Stimulate Regeneration"] = true,
        },
        ["Spinemaw Acidgullet"] = {["Volatile Acid"] = true,},
        ["Spinemaw Gorger"] = {["Acid Globule"] = true,},
    },
    ["The Necrotic Wake"] ={
        ["Corpse Harvester"] = {["Drain Fluids"] = true,},
        ["Amarth"] ={["Necrotic Bolt"] = true,},
        ["Skeletal Marauder"] ={["Rasping Scream"] = true,},
        ["Nar'zudah"] = {["Necrotic Bolt"] = true,},
        ["Corpse Collector"] = {["Drain Fluids"] = true,},
        ["Loyal Creation"] = {["Spine Crush"] = true,},
        ["Stitching Assistant"]={["Drain Fluids"] = true,},
        ["Zolramus Gatekeeper"] = {["Necrotic Bolt"] = true,},
        ["Zolramus Necromancer"] = {["Necrotic Bolt"] = true,},
        ["Zolramus Sorcerer"] = {["Necrotic Bolt"] = true,},
        ["Reanimated Mage"] = {["Frostbolt Volley"] = true,},
    },
    ["De Other Side"] ={
        ["Atal'ai Deathwalker"] ={["Bladestorm"] = true,},
        ["Atal'ai Devoted"] ={["Devoted Sacrifice"] =true,},
        ["Atal'ai High Priest"]={["Heal"] = true,},
        ["Atal'ai Hoodoo Hexxer"]={["Healing Wave"]=true,},
        ["Lubricator"]={["Self-Cleaning Cycle"]=true,},
    },
    ["Sanguine Depths"] ={
        ["Kryxis the Voracious"]={["Hungering Drain"] =true,},
        ["Wicked Oppressor"]={["Wrack Soul"] = true,},
        ["Chamber Sentinel"]={["Stoneskin"]=true,},
        ["Vestige of Doubt"]={["Growing Mistrust"]=true,},
    },
    ["Halls of Atonement"]={
        ["Depraved Houndmaster"]={["Loyal Beasts"]=true,},
        ["Depraved Obliterator"]={
            ["Curse of Obliteration"]=[[return IROVar.UnitCount("Depraved Obliterator")+IROVar.UnitCount("Depraved Collector")>IROVar.DecurseInGroup()]],
            ["Wicked Bolt"]=[[return IROVar.UnitCount("Depraved Obliterator")+IROVar.UnitCount("Depraved Collector")<=IROVar.DecurseInGroup()]],
        },
        ["Depraved Collector"]={["Collect Sins"]=true,},
        ["Stoneborn Reaver"]={["Turn to Stone"]=true,},
        ["High Adjudicator Aleez"]={["Volley of Power"]=true,},
    },
    ["Plaguefall"]={
        ["Fungi Stormer"]={["Fungistorm"]=true},
        ["Defender of Many Eyes"]={["Bulwark of Maldraxxus"]=true,},
        ["Brood Ambusher"]={["Stealthlings"]=true,},
        ["Plaguebinder"]={["Gripping Infection"]=true,},
        ["Rotmarrow Slime"]={["Corrosive Gunk"]=true,},
    },
    ["Spires of Ascension"]={
        ["Forsworn Mender"]={["Forsworn Doctrine"]=true,},
        ["Forsworn Castigator"]={["Burden of Knowledge"]=true,},
        ["Forsworn Goliath"]={["Rebellious Fist"]=true,},
        ["Forsworn Champion"]={["Forsworn Doctrine"]=true,},
        ["Forsworn Warden"]={["Greater Mending"]=true,},
        ["Forsworn Justicar"]={["Forced Confession"]=true,},
        ["Forsworn Inquisitor"]={["Internal Strife"]=true,},
    },
    ["Theater of Pain"]={
        ["Battlefield Ritualist"]={["Unholy Fervor"]=true,},
        ["Dokigg the Brutalizer"]={["Battle Trance"]=true,},
        ["Harugia the Bloodthirsty"]={["Battle Trance"]=true,},
        ["Ancient Captain"]={["Demoralizing Shout"]=true,},
        ["Xav the Unfallen"]={["Deafening Crash"]=true,},
        ["Blighted Sludge-Spewer"]={["Withering Discharge"]=true,},
        ["Bone Magus"]={["Bone Spear"]=true,},
        ["Maniacal Soulbinder"]={["Necrotic Bolt Volley"]=true,},
        ["Sathel the Accursed"]={ --1st boss
            ["Necromantic Bolt"]=[[return TMW.CNDT.Env.AuraDur("target", "one with death", "HELPFUL")==0]],
            ["Searing Death"]=true,
        },
    },
    ["Castle Nathria"]={
        ["Stoneborn Maitre D'"]={["Dinner Bell"]=true}
    },
    ["The Shadowlands"]={
        ["Mawsworn Myrmidon"]={["Horrifying Shout"]=true}
    },
    ["Tazavesh, the Veiled Market"]={
        --Tazavesh: Streets of Wonder , "Tazavesh, the Veiled Market"
        ["Disruptive Patron"]={["Teleport"]=true,["Hyperlight Bolt"]=true},
        ["Support Officer"]={["Hard Light Barrier"]=true},
        ["Interrogation Specialist"]={["Stasis Beam"]=true},
        ["Veteran Sparkcaster"]={["Scintillate"]=true},
        --["Portalmancer Zo'honn"]={["Radiant Pulse"]=true}, --kick all spell
        --["Tracker Zo'korss"]={["Beam Splicer"]=true}, --cant kick any spell
        ["Ancient Core Hound"]={["Ancient Dread"]=true},
        ["Market Peacekeeper"]={["Phalanx Field"]=true}, -- stun
        ["So'azmi"]={["Double Technique"]=[[return IROVar.TargetCastBar(0.8)]]}, --Kick at 80%
        --Tazavesh: So'leah's Gambit
        ["Hourglass Tidesage"]={["Brackish Bolt"]=true},
        ["Devoted Accomplice"]={["Reinvigorate"]=true},
        ["Focused Ritualist"]={["Unstable Rift"]=true},
        ["Murkbrine Scalebinder"]={["Invigorating Fish Stick"]=true},--stun
        ["Murkbrine Fishmancer"]={["Waterbolt"]=[[return IsMyInterruptSpellReady()]]},
        ["Murkbrine Shellcrusher"]={["Cry of Mrrggllrrgg"]=true},
    },
    ["Grimrail Depot"]={
        ["Grimrail Technician"]={["Activating"]=true,["50,000 Volts"]=true},
        ["Grom'kar Gunner"]={["Shrapnel Blast"]=true},
        ["Grom'kar Boomer"]={["Cannon Barrage"]=true,["Blackrock Mortar"]=true},
        ["Grom'kar Cinderseer"]={["Flametongue"]=true},
    },
    ["Iron Docks"]={
        ["Thunderlord Wrangler"]={["Throw"]=true,["Serrated Spear"]=true},
    },
    ["Return to Karazhan"]={
    },
    ["Operation: Mechagon"]={
        ["Scrapbone Shaman"]={["Grasping Hex"]=true,["Stoneskin"]=true},
        ["Scrapbone Grinder"]={["Skullcracker"]=true,["Enrage"]=true},
        ["Scraphound"]={["B.O.R.K"]=true,},
        ["Anodized Coilbearer"]={["Charged Coil"]=true},
        ["Mechagon Trooper"]={["Nanoslicer"]=true},
        ["Mechagon Renormalizer"]={["Shrink"]=true,["Enlarge"]=true,},
        ["Bomb Tonk"]={["Detonate"]=true},
        ["Rocket Tonk"]={["Rocket Barrage"]=true},
        ["Junkyard D.0.G."]={["Flaming Refuse"]=true},
        ["Mechagon Tinkerer"]={["Giga-Wallop"]=true,["Activate Anti-Personnel Squirrel"]=true},
        ["Pistonhead Mechanic"]={["Repair"]=true},
        ["Toxic Lurker"]={["Suffocating Smog"]=true},
        ["Slime Elemental"]={["Slimebolt"]=true,["Slimewave"]=true},
    },
-------------------- Dragonflight 10.0.2 --Stun / Interrupt List
    ["Algeth'ar Academy"]={
        ["Spellbound Scepter"] = {["Mystic Blast"]=true,["Arcane Rain"]=true},
        ["Unruly Textbook"] = {["Monotonous Lecture"]=true},
        ["Corrupted Manafiend"] = {["Mana Void"]=true,["Surge"]=true},
        ["Mana Wyrms"] = {["Vicious Lunge"]=true},
        ["Alpha Eagle"] = {["Call of the Flock"]=true},
        ["Ancient Branch"] = {["Healing Touch"]=true},
        ["Algeth'ar Echoknight"] = {["Astral Whirlwind"]=true},
        --["Algeth'ar Security"] = {["Disrupting Pulse"]=true},
        ["Spectral Invoker"] = {["Astral Bomb"]=false,["Arcane Missiles"]=true},
    },
--------------------------------------------------------
    ["Court of Stars"]={
        ["Guardian Construct"] = {["Suppress"]=true,["Charging Station"]=true},
        ["Duskwatch Sentry"] = {["Sound Alarm"]=true},
        ["Watchful Inquisitor"] = {["Searing Glare"]=true},
        ["Blazing Imp"] = {["Drifting Embers"]=true},
        ["Baalgar the Watchful"] = {["Disintegration Beam"]=true},
        ["Talixae Flamewreath"] = {["Withering Soul"]=true},
    },
--------------------------------------------------------
    ["Halls of Valor"]={
        ["Valarjar Mystic"] = {["Rune of Healing"]=true,["Holy Radiance"]=true},
        ["Stormforged Obliterator"] = {["Surge"]=true},
        ["Valarjar Runecarver"] = {["Etch"]=true,["Shattered Rune"]=true},
        ["Valarjar Thundercaller"] = {["Thunderous Bolt"]=true},
        ["Valarjar Marksman"] = {["Penetrating Shot"]=true},
        ["King Haldor"] = {["Unruly Yell"]=true},
        ["King Ranulf"] = {["Unruly Yell"]=true},
        ["King Bjorn"] = {["Unruly Yell"]=true},
        ["King Tor"] = {["Unruly Yell"]=true},
    },
--------------------------------------------------------
    ["Ruby Life Pools"]={
        ["Primalist Shockcaster"] = {["Lightning Bolt"]=true},
        ["Primal Thundercloud"] = {["Crackling Detonation "]=true},
        ["Tempest Channeler"] = {["Thunder Bolt"]=true},
        ["High Channeler Ryvati"] = {["Shock Blast"]=true},
        ["Flame Channeler"] = {["Flashfire"]=true},
        ["Primalist Cinderweaver"] = {["Cinderbolt"]=true},
        ["Primalist Flamedancer"] = {["Flame Dance"]=true},
        ["Flashfrost Chillweaver"] = {["Ice Shield"]=true},
        ["Flashfrost Earthshaper"] = {["Tectonic Slam"]=true},
        ["Melidrussa Chillworn"] = {["Frost Overload"]=true},
    },
--------------------------------------------------------
    ["Shadowmoon Burial Grounds"]={
        ["Shadowmoon Bone-Mender"] = {["Shadow Mend"]=true,["Shadow Bolt"]=true},
        ["Shadowmoon Dominator"] = {["Rending Voidlash"]=true,
            ["Domination"]=[[return (function() local n,_,_,sT,eT=UnitChannelInfo("target")return n and (eT-sT<604700000)end)()]]},
            --[[
                return (function() local n,_,_,sT,eT=UnitChannelInfo("target")return n and (eT-sT<604800000)end)()
            ]]
        ["Shadowmoon Exhumer"] = {["Void Bolt"]=true},
--        ["Shadowmoon Exhumer"] = {["Void Bolt"]=true,["Exhume the Crypts"]=true},
        ["Exhumed Spirit"] = {["Death Blast"]=true},
        ["Monstrous Corpse Spider"] = {["Necrotic Burst"]=true},
        ["Plagued Bat"] = {["Plague Spit"]=true},
    },
--------------------------------------------------------
    ["Temple of the Jade Serpent"]={
        ["Fallen Waterspeaker"] = {["Hydrolance"]=true,["Tidal Burst"]=true},
        ["Haunting Sha"] = {["Haunting Scream"]=true},
        ["The Talking Fish"] = {["Sleepy Soliloquy"]=true},
        ["The Golden Beetle"] = {["Golden Barrier"]=true},
        ["The Nodding Tiger"] = {["Cat Nap"]=true},
        ["The Crybaby Hozen"] = {["Fit of Rage"]=true},
        ["Sha-Touched Guardian"] = {["Leg Sweep"]=true},
        ["Depraved Mistweaver"] = {["Defiling Mist"]=true},
        ["Minion of Doubt"] = {["Dark Claw"]=true},
        ["Wise Mari"] = {["Hydrolance"]=true},
    },
--------------------------------------------------------
    ["The Azure Vault"]={
        ["Conjured Lasher"] = {["Mystic Vapors"]=true},
        ["Shrieking Whelp"] = {["Shriek"]=true},
        ["Arcane Elemental"] = {["Waking Bane"]=true},
        ["Rune Seal Keeper"] = {["Icy Bindings"]=true,["Condensed Frost"]=false},
        ["Crystal Fury"] = {["Piercing Shards"]=true},
        ["Crystal Thrasher"] = {["Splintering Shards"]=true},
        ["Astral Attendant"] = {["Unstable Power"]=true},
        ["Vault Guard"] = {["Ice Cutter"]=true},
        ["Scalebane Lieutenant"] = {["Ice Cutter"]=true},
        ["Nullmagic Hornswog"] = {["Null Stomp"]=true},
    },
--------------------------------------------------------
    ["The Nokhud Offensive"]={
        ["Nokhud Longbow"] = {["Shoot"]=true,["Rain of Arrows"]=true},
        ["Nokhud Warspear"] = {["Swift Stab"]=true},
        ["Nokhud Hornsounder"] = {["Rally the Clan"]=true},
        ["Primalist Stormspeaker"] = {["Stormbolt"]=true,["Tempest"]=true},
        ["Primalist Thunderbeast"] = {["Chain Lightning"]=true,["Thunderstrike"]=true,["Thunder Clap"]=true}, --[Thunderstrike][Thunder Clap] ???
        ["Soulharvester Duuren"] = {["Death Bolt Volley"]=true},
        ["Soulharvester Galtmaa"] = {["Death Bolt Volley"]=true},
        ["Soulharvester Tumen"] = {["Death Bolt Volley"]=true},
        ["Soulharvester Mandakh"] = {["Death Bolt Volley"]=true},
        ["Ukhel Deathspeaker"] = {["Grasp of the Dead"]=true},
        ["Ukhel Willcrusher"] = {["Dominate"]=true},
        ["Nokhud Thunderfist"] = {["Storm Shock"]=true},
    },
--------------------------------------------------------

}

IROVar.CareInOld={
    [1]=IROVar.TickCount01-1, -- TickCount
    [2]=IROVar.TargetChangeCount-1, -- TargetCount
    [3]={
        --[unittoken]=val
    }
}

function IROVar.CareInterrupt(nUnit)
    local TickC=IROVar.TickCount01
    local UseOldCal = false
    local ClearOldCal = true
    local nUnitTarget=nUnit=="target"
    if IROVar.CareInOld[1]==TickC then
        ClearOldCal=false
        if nUnitTarget then
            if IROVar.CareInOld[2]==IROVar.TargetChangeCount then
                UseOldCal = true
            end
        else
            UseOldCal = true
        end
    end
    if ClearOldCal then
        IROVar.CareInOld[3]={}
    end
    if UseOldCal then
        if IROVar.CareInOld[3][nUnit]==nil then
            UseOldCal=false
        end
    end
    if UseOldCal then
        return IROVar.CareInOld[3][nUnit]
    end

    IROVar.CareInOld[1]=TickC
    IROVar.CareInOld[2]=IROVar.TargetChangeCount
    local MobName
    local SName
    local ans
    if not IROVar.MobListForInterrupt[IROVar.InstanceName] then
        ans=true
    else
        if nUnitTarget then
            MobName=IROVar.TargetName
        else MobName=UnitName(nUnit) end
        if not MobName then ans=true
        elseif IROVar.MobListForInterrupt[IROVar.InstanceName][MobName]==nil then ans=true
        elseif IROVar.MobListForInterrupt[IROVar.InstanceName][MobName]==false then ans=false
        else
            if nUnitTarget then
                if IROVar.CastBar.Casting then
                    SName=IROVar.CastBar.Casting[1]
                elseif IROVar.CastBar.Channeling then
                    SName=IROVar.CastBar.Channeling[1]
                end
            else
                SName = UnitCastingInfo(nUnit)
                if not SName then SName = UnitChannelInfo(nUnit) end
            end
            if not SName then ans=false
            elseif not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName] then ans=false
            else
                ans=(IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName]==true) or
                loadstring(IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName])()
            end
        end
    end
    IROVar.CareInOld[3][nUnit]=ans
    return ans
end


--function IROVar.CareInterruptLV2(nUnit)
    -- same function with IROVar.VVCareInterrupt
--[[
    OLD Function 
    function IROVar.CareInterrupt(nUnit)
        if not IROVar.MobListForInterrupt[IROVar.InstanceName] then
            return true
        end
        local MobName=UnitName(nUnit)
        if not MobName then return true end
        if IROVar.MobListForInterrupt[IROVar.InstanceName][MobName]==nil then return true end
        if IROVar.MobListForInterrupt[IROVar.InstanceName][MobName]==false then return false end
        local SName = UnitCastingInfo(nUnit)
        if not SName then SName = UnitChannelInfo(nUnit) end
        if not SName then return false end
        if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName] then return false end
        return (IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName]==true) or
        loadstring(IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName])()
    end
]]