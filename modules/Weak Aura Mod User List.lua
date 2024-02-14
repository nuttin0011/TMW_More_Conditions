--[[
------------------------------------
------------------------------------

This is a "User List".

Entries in this list will take priority over entries in any "Default List".
To ensure your changes persist through updates, don't the use included "User List"-Template.
Instead, make a copy of the Template, rename the copy and make your changes there.
You can have as many copies of these lists loaded as you wish.

Below are some references to help with making new entries.
Check the Custom Options of the Documentation WeakAura for more details.

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
   

For spells cast by units without nameplatss, you can make an entry with just the spellId.
You need to add a cleu tag with this:
######################
[] = "",

Example:
[256005] = "swirly/cleuSuccess", -- Sharkbait's Volatile Bombardment
######################

]]--

aura_env.unitAndSpellList = {
    [122968] = -- Yazma
    {
        ["onCastSuccess"] = {
            [250050] = "swirly", -- Echoes of Shadra
        },
        [249919] = "tank", -- Skewer
        [250096] = "kick/noSound", -- Wracking Pain
        [259187] = "damage/ttsCustom_Drop Adds", -- Soulrend
    },
    
    
    [198933] = -- Iridikron
    {
        [409456] = "alert/ttsCustom_Dodge", -- Earthsurge
        [409635] = "frontal", -- Pulverizing Exhalation
        ["onCastSuccess"] = 
        {
            [414535] = "damage", -- Stonecracker Barrage
        },
    }, 

    [186206] = -- Cruel Bonecrusher -- test at BHH
    {
        [382593] = "damage/onlyIfOnMe", -- crushing smash
       
    }, 
}
