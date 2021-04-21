-- Key Setting...
local Nm={}


Nm[1]=''
Nm[2]=''




--print((IROVar.InterruptSpell~=nil) and IROVar.InterruptSpell or "nil")
--print((IROSpecID~=nil) and IROSpecID or "nil")
local iS=IROVar.InterruptSpell or ""
Nm[8]='/use [mod:ctrl,nomod:alt]13\n/use [mod:ctrl,nomod:alt]14\n/targetenemy [nomod:ctrl,mod:alt]\n/cleartarget [nomod]'
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
            if select(2,GetNumMacros()) >=18 then
                print('ERROR------------"')
                print('Cannot Create More Macro, Please Delete More "Specific Macro"')
                print('and use "/reload"')
            end
            CreateMacro(nname,460699,Nm[i] ,true)
end end end
SetKey(true)

