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
    [87252]={ -- Unruly Ogron
        [0]="stealth",
    },
    [83578]={ -- Unruly Laborer 1
        [0]="stealth",
    },
    [83761]={ -- Unruly Laborer 2
        [0]="stealth",
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
    [75715]={ -- Reanimated Ritual Bones
        [164907]="tank", -- Void Slash
    },
    [75713]={ -- Shadowmoon Bone-Mender
        [152818]="kick", -- Shadow Mend
    },
    [75652]={ -- Void Spawn
        [152964]="damage/ttsCustom_L O S", -- Void Pulse 
    },
    [75509]={ -- Sadana Bloodfury
        [153094]="damage", -- Whispers of the Dark Star
        [153240]="swirly", -- Daggerfall
    },
    [75966] = -- Defiled Spirit
    {
        [0] = "priority", -- 
    },
    [76446]={ -- Shadowmoon Dominator
        [398150]="kick", -- Domination 
        [153776]="kick", -- Rending Voidlash 
    },
    [75979]={ -- Exhumed Spirit
        [398206]="kick", -- Death Blast
    },
    [75829]={ -- Nhallish
        [152792]="frontal", -- Void Blast
    },
    [76104]={ -- Monstrous Corpse Spider
        [156718]="kick", -- Necrotic Burst
    },
    [76057]={ -- Carrion Worm
        [153395]="frontal", -- Body Slam
        [0]="tank", -- aim it away from the group
    },
    [75452]={ -- Bonemaw
        [154175]="frontal", -- Body Slam
        [153804]="alert", -- Inhale
    },
    [200035]={ -- Carrion Worm (boss)
        [154175]="frontal", -- Body Slam
    },
    [76407]={ -- Ner'zhul
        [154442]="frontal", -- Malevolance
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
        [427510] = "frontal/ttsCustom_Charge", -- Noxious Charge
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







