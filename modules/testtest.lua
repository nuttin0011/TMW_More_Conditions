-- Key Setting...
local Nm={}

Nm[0]="/cast [mod:ctrlalt]Arcane Shot;[mod:ctrl]Misdirection;[mod:alt]Tranquilizing Shot;[nomod]Counter Shot"
Nm[1]="/cast [mod:ctrlalt]Bestial Wrath;[mod:ctrl]Aspect of the Wild;[mod:alt]Multi-Shot;[nomod]Kill Command"
Nm[2]="/cast [mod:ctrlalt]Kill Shot;[mod:ctrl]Barbed Shot;[mod:alt]Cobra Shot;[nomod]Counter Shot"
Nm[3]="/cast [mod:ctrlalt]Revive Pet;[mod:ctrl]Call Pet 1;[mod:alt]Trinket Buff 1;[nomod]Trinket Buff 2"
Nm[4]="/cast [mod:ctrlalt]Trinket Buff 1;[mod:ctrl]Chimaera Shot;[mod:alt]A Murder of Crows;[nomod]Barrage"
Nm[5]="/cast [mod:ctrlalt]Stampede;[mod:ctrl]Bloodshed;[mod:alt]Exhilaration;[nomod]Tranquilizing Shot"
Nm[6]="/cast [mod:ctrlalt]Intimidation;[mod:ctrl]Concussive Shot;[mod:alt]Dire Beast;[nomod]Steady Shot"
Nm[7]='/focus [mod:ctrl,nomod:alt,@targettarget]\n/focus [nomod,@pet]'

if not IROUsedSkillControl then IROUsedSkillControl={} end
IROUsedSkillControl.ColorToSpell={
["ff000000"]="---",
["ff033003"]="Arcane Shot",
["ff013001"]="Misdirection",
["ff023002"]="Tranquilizing Shot",
["ff003000"]="Counter Shot",
["ff033103"]="Bestial Wrath",
["ff013101"]="Aspect of the Wild",
["ff023102"]="Multi-Shot",
["ff003100"]="Kill Command",
["ff033203"]="Kill Shot",
["ff013201"]="Barbed Shot",
["ff023202"]="Cobra Shot",
["ff003200"]="Counter Shot",
["ff033303"]="Revive Pet",
["ff013301"]="Call Pet 1",
["ff023302"]="Trinket Buff 1",
["ff003300"]="Trinket Buff 2",
["ff033403"]="Trinket Buff 1",
["ff013401"]="Chimaera Shot",
["ff023402"]="A Murder of Crows",
["ff003400"]="Barrage",
["ff033503"]="Stampede",
["ff013501"]="Bloodshed",
["ff023502"]="Exhilaration",
["ff003500"]="Tranquilizing Shot",
["ff033603"]="Intimidation",
["ff013601"]="Concussive Shot",
["ff023602"]="Dire Beast",
["ff003600"]="Steady Shot",

["ff013701"]="Focus TargetTarget",
["ff003700"]="Focus Pet",

["ff033803"]="Pet Attack",
["ff013801"]="Use Trinket",
["ff023802"]="Target Enemy",
["ff003800"]="Clear Target",

["ff033903"]="Focus MouseOver",
["ff013901"]="Interrupt Focus",
["ff023902"]="Interrupt Target",
["ff003900"]="KeepLog???",

}



--[[
Nm[1]='/cast [mod:ctrlalt]Bestial Wrath;[mod:ctrl]Aspect of the Wild;[mod:alt]Multi-Shot;Kill Command'
Nm[2]='/cast [mod:ctrlalt]Kill Shot;[mod:ctrl]Barbed Shot;[mod:alt]Cobra Shot;Counter Shot'
Nm[3]='/cast [mod:ctrlalt]Revive Pet;[mod:ctrl]call pet 1\n/stopmacro [mod]\n/cast Claw\n/cast Bite\n/cast Smack\n/petattack'
Nm[4]='/cast [mod:ctrlalt]Dire Beast;[mod:ctrl]Chimaera Shot;[mod:alt]A Murder of Crows;Barrage'
Nm[5]='/cast [mod:ctrlalt]Stampede;[mod:ctrl]Bloodshed;[mod:alt]Exhilaration;Tranquilizing Shot'
Nm[6]='/cast [mod:ctrlalt]Intimidation;[mod:ctrl]Concussive Shot;[mod:alt]Dire Beast;Steady Shot'
Nm[7]='/focus [nomod,@pet]\n/focus [mod:ctrl,nomod:alt,@targettarget]'
Nm[8]='/cast [mod:ctrl,@focus]Misdirection;[mod:alt,@focus]Counter Shot;[@focus]Tranquilizing Shot'

Nm[9]='/use [nomod]13\n/use [nomod]14'

]]


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

