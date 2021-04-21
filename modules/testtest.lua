-- Key Setting...
local Nm={}


Nm[0]="/cast [mod:ctrlalt]Astral Shift;[mod:ctrl]Sundering;[mod:alt]Chain Lightning;[nomod]Earth Elemental"
Nm[1]="/cast [mod:ctrlalt]Earthbind Totem;[mod:ctrl]Flame Shock;[mod:alt]Flametongue Weapon;[nomod]Frost Shock"
Nm[2]="/cast [mod:ctrlalt]Ghost Wolf;[mod:ctrl]Healing Stream Totem;[mod:alt]Healing Surge;[nomod]Stormkeeper"
Nm[3]="/cast [mod:ctrlalt]Earthen Spike;[mod:ctrl]Lightning Bolt;[mod:alt]Lightning Shield;[nomod]Purge"
Nm[4]="/cast [mod:ctrlalt]ThisSpellnotuse;[mod:ctrl]Wind Shear;[mod:alt]Cleanse Spirit;[nomod]Crash Lightning"
Nm[5]="/cast [mod:ctrlalt]Feral Spirit;[mod:ctrl]Lava Lash;[mod:alt]Spirit Walk;[nomod]Stormstrike"
Nm[6]="/cast [mod:ctrlalt]Windfury Totem;[mod:ctrl]Windfury Weapon;[mod:alt]Elemental Blast;[nomod]Ice Strike"
Nm[7]="/cast [mod:ctrlalt]Earth Shield;[mod:ctrl]Fire Nova;[mod:alt]Feral Lunge;[nomod]Ascendance"

if not IROUsedSkillControl then IROUsedSkillControl={} end
IROUsedSkillControl.ColorToSpell={
["ff000000"]="---",
["ff033003"]="Astral Shift",
["ff013001"]="Sundering",
["ff023002"]="Chain Lightning",
["ff003000"]="Earth Elemental",
["ff033103"]="Earthbind Totem",
["ff013101"]="Flame Shock",
["ff023102"]="Flametongue Weapon",
["ff003100"]="Frost Shock",
["ff033203"]="Ghost Wolf",
["ff013201"]="Healing Stream Totem",
["ff023202"]="Healing Surge",
["ff003200"]="Stormkeeper",
["ff033303"]="Earthen Spike",
["ff013301"]="Lightning Bolt",
["ff023302"]="Lightning Shield",
["ff003300"]="Purge",
["ff033403"]="Maelstrom Weapon",
["ff013401"]="Wind Shear",
["ff023402"]="Cleanse Spirit",
["ff003400"]="Crash Lightning",
["ff033503"]="Feral Spirit",
["ff013501"]="Lava Lash",
["ff023502"]="Spirit Walk",
["ff003500"]="Stormstrike",
["ff033603"]="Windfury Totem",
["ff013601"]="Windfury Weapon",
["ff023602"]="Elemental Blast",
["ff003600"]="Ice Strike",
["ff033703"]="Earth Shield",
["ff013701"]="Fire Nova",
["ff023702"]="Feral Lunge",
["ff003700"]="Ascendance",
["ff033803"]="Chain Harvest",
["ff013801"]="Use Trinket",
["ff023802"]="Target Enemy",
["ff003800"]="Clear Target",
["ff033903"]="Focus MouseOver",
["ff013901"]="Interrupt Focus",
["ff023902"]="Interrupt Target",
}

--print((IROVar.InterruptSpell~=nil) and IROVar.InterruptSpell or "nil")
--print((IROSpecID~=nil) and IROSpecID or "nil")
local iS=IROVar.InterruptSpell or ""
Nm[8]='/cast [mod:ctrlalt]chain harvest\n/use [mod:ctrl,nomod:alt]13\n/use [mod:ctrl,nomod:alt]14\n/targetenemy [nomod:ctrl,mod:alt]\n/cleartarget [nomod]'
Nm[9]='/focus [@mouseover,exists,harm,nodead,mod:ctrlalt]'..
'\n/cast [mod:ctrl,nomod:alt,@focus]'..iS..';[mod:alt,nomod:ctrl]'..iS..
'\n/stopmacro [mod]'..
'\n/run IROUsedSkillControl.KeepLogOffGCD()'
local function SetKey(IncombatStatus)
    if InCombatLockdown() then
        if IncombatStatus then print("cannot Bind Key while Incombat") end
        C_Timer.After(1,SetKey)
    else
        if not IncombatStatus then print("Out Combat Bind Key Done!") end
        local nname
        for i in pairs(Nm) do
            nname='~!Num'..i
            DeleteMacro(nname)
            DeleteMacro(nname)
            CreateMacro(nname,460699,Nm[i] ,true)
end end end
SetKey(true)

