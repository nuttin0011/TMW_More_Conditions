-- Key Setting...
local Nm={}

Nm[0]="/cast [mod:ctrlalt]Blackout Kick;[mod:ctrl]Crackling Jade Lightning;[mod:alt]Detox;[nomod]Expel Harm"
Nm[1]="/cast [mod:ctrlalt]Fortifying Brew;[mod:ctrl]Leg Sweep;[mod:alt]Spinning Crane Kick;[nomod]Tiger Palm"
Nm[2]="/cast [mod:ctrlalt]Touch of Death;[mod:ctrl]Vivify;[mod:alt]Breath of Fire;[nomod]Celestial Brew"
Nm[3]="/cast [mod:ctrlalt]Keg Smash;[mod:ctrl]Purifying Brew;[mod:alt]Spear Hand Strike;[nomod]Chi Wave"
Nm[4]="/cast [mod:ctrlalt]Zen Pilgrimage;[mod:ctrl]Black Ox Brew;[mod:alt]Healing Elixir;[nomod]Rushing Jade Wind"
Nm[5]="/cast [mod:ctrlalt]Dampen Harm;[mod:ctrl]Invoke Niuzao, the Black Ox;[mod:alt]\n/petattack [nomod]"

--print((IROVar.InterruptSpell~=nil) and IROVar.InterruptSpell or "nil")
--print((IROSpecID~=nil) and IROSpecID or "nil")
local iS=IROVar.InterruptSpell or ""
Nm[8]='/petattack [mod:ctrlalt]\n/use [mod:ctrl,nomod:alt]13\n/use [mod:ctrl,nomod:alt]14\n/targetenemy [nomod:ctrl,mod:alt]\n/cleartarget [nomod]'
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

