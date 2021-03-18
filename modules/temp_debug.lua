-- Spec 1 macro setting...
local Nm={}
local nname

--Nm[1]=''
--Nm[2]=''

local iS
if IROInterruptTier then iS=IROInterruptTier[IROSpecID][2]else iS="" end
Nm[9]='/focus [@mouseover,exists,harm,nodead,mod:ctrlalt]'..
'\n/cast [mod:ctrl,nomod:alt,@focus]'..iS..';[mod:alt,nomod:ctrl]'..iS..
'\n/use [nomod]13'..
'\n/use [nomod]14'
IROISN=iS
if InCombatLockdown() then
    print("cannot Bind Key while Incombat")
end

if not(InCombatLockdown()) then
    for i in pairs(Nm) do
        nname='~!Num'..i
        DeleteMacro(nname)
        DeleteMacro(nname)
        CreateMacro(nname,460699,Nm[i] ,true)
    end
end

