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
        [388923] = "alert/ttsCustom_Defensive", -- Burst Forth
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
        ["onCastSuccess"] = {
            [377950] = "alert/ttsCustom_Dispel Boss/onlyIfPurge", -- Greater Healing Rapids    
        },
        [378155] = "kick/noSound", -- Earth Bolt
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
        [381770] = "kick/noSound", -- Gushing Ooze
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
        [374073] = "swirly/onlyIfOnMe/ttsCustom_Move/delayTargetCheck_0.2/delaySound_0.5", -- Seismic Slam
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
        --[374020] = "damage/onlyIfOnMe/ttsCustom_Beam", -- Containment Beam
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
        [372262] = "alert/onlyIfOnMe/ttsCustom_Defensive", -- Pierce Marrow
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
    [192791] = { -- Nokhud Warspear
        [381683] = "alert/onlyIfOnMe/ttsCustom_Stab", -- Swift Stab
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
        ["onCastSuccess"] = {
            [384686] = "alert/ttsCustom_Dispel Boss/onlyIfPurge", -- Energy Surge
        },
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
    [196102] = -- Conjured Lasher
    {
        [387564] = "kick/noSound", -- Mystic Vapors
    },
    [196115] = { -- Arcane Tender (Upstairs)
        [0] = "priority",
        [375596] = "kick", -- Erratic Growth
        ["onCastSuccess"] = 
        {
            [375652] = "swirly", -- Wild Eruption
        },
    },
    [191164] = { -- Arcane Tender (Downstairs)
        [0] = "priority",
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
        ["onCastSuccess"] = {
            [389686] = "alert/ttsCustom_Dispel Fury/onlyIfPurge" -- Arcane Fury
        },
    },
    [196116] = { -- Crystal Fury
        [370764] = "frontal", -- Piercing Shards
        ["onCastSuccess"] = {
            [389686] = "alert/ttsCustom_Dispel Fury/onlyIfPurge" -- Arcane Fury
        },
    },
    [187155] = { -- Rune Seal Keeper
        [0] = "priority",
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
        --[374778] = "alert/ttsCustom_Dispel Lieutenant/onlyIfPurge" -- Brilliant Scales
    },
    [190510] = { -- Vault Guard
        [377105] = "tank/noSound", -- Ice Cutter
        --[374778] = "alert/ttsCustom_Dispel Guard/onlyIfPurge" -- Brilliant Scales
    },
    [186739] = { -- Azureblade
        [385578] = "frontal", -- Ancient Orb
        [384223] = "alert/ttsCustom_Add", -- Summon Draconic Image
        [372222] = "frontal/range_5", -- Arcane Cleave
        [384132] = "alert/ttsCustom_Dodge" -- Overwhelming Energy
    },
    [190187] = { -- Draconic Image
        [373932] = "kick/ignoreCombat", -- Illusionary Bolt
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
            --[386526] = "swirly", -- Null Stomp
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
        [1] = "damage", -- Fracture
    },
    [199368] = -- Hardened Crystal
    {
        [0] = "priority",
        [1] = "damage", -- Fracture
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

