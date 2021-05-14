-- Key Setting...
local Nm={}

Nm[0]="/cast [mod:ctrlalt]Aspect of the Turtle;[mod:ctrl]Command Pet;[mod:alt]Exhilaration;[nomod]Hunter's Mark"
Nm[1]="/cast [mod:ctrlalt]Kill Shot;[mod:ctrl]Misdirection;[mod:alt]Revive Pet;[nomod]Steady Shot"
Nm[2]="/cast [mod:ctrlalt]Arcane Shot;[mod:ctrl]Tranquilizing Shot;[mod:alt]Wing Clip;[nomod]Aspect of the Eagle"
Nm[3]="/cast [mod:ctrlalt]Carve;[mod:ctrl]Coordinated Assault;[mod:alt]Intimidation;[nomod]Kill Command"
Nm[4]="/cast [mod:ctrlalt]Muzzle;[mod:ctrl]Serpent Sting;[mod:alt]Shrapnel Bomb;[nomod]Butchery"
Nm[5]="/cast [mod:ctrlalt]A Murder of Crows;[mod:ctrl]Mongoose Bite;[mod:alt]Flanking Strike;[nomod]Chakrams"



if not IROUsedSkillControl then IROUsedSkillControl={} end
IROUsedSkillControl.ColorToSpell={
    ["ff000000"]="---",
    ["ff033003"]="Aspect of the Turtle",
    ["ff013001"]="Command Pet",
    ["ff023002"]="Exhilaration",
    ["ff003000"]="Hunter's Mark",
    ["ff033103"]="Kill Shot",
    ["ff013101"]="Misdirection",
    ["ff023102"]="Revive Pet",
    ["ff003100"]="Steady Shot",
    ["ff033203"]="Arcane Shot",
    ["ff013201"]="Tranquilizing Shot",
    ["ff023202"]="Wing Clip",
    ["ff003200"]="Aspect of the Eagle",
    ["ff033303"]="Carve",
    ["ff013301"]="Coordinated Assault",
    ["ff023302"]="Intimidation",
    ["ff003300"]="Kill Command",
    ["ff033403"]="Muzzle",
    ["ff013401"]="Serpent Sting",
    ["ff023402"]="Shrapnel Bomb",
    ["ff003400"]="Butchery",
    ["ff033503"]="A Murder of Crows",
    ["ff013501"]="Mongoose Bite",
    ["ff023502"]="Flanking Strike",
    ["ff003500"]="Chakrams",
    
    ["ff013801"]="Use Trinket",
    ["ff023802"]="Target Enemy",
    ["ff003800"]="Clear Target",
    ["ff033903"]="Focus MouseOver",
    ["ff013901"]="Interrupt Focus",
    ["ff023902"]="Interrupt Target",
    ["ff013a01"]="Use Healthstone",
    ["ff023a02"]="Stop Casting",
}

--print((IROVar.InterruptSpell~=nil) and IROVar.InterruptSpell or "nil")
--print((IROSpecID~=nil) and IROSpecID or "nil")
local iS=IROVar.InterruptSpell or ""
Nm[8]='/petattack [mod:ctrlalt]\n/cast [mod:ctrlalt]Claw\n/cast [mod:ctrlalt]Bite\n/cast [mod:ctrlalt]Smack\n/use [mod:ctrl,nomod:alt]13\n/use [mod:ctrl,nomod:alt]14\n/targetenemy [nomod:ctrl,mod:alt]\n/cleartarget [nomod]'
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

