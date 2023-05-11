
if not IROKeyButton then IROKeyButton={} end
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
            if not IROKeyButton[nname] then
                IROKeyButton[nname]=CreateFrame('Button', nname, UIParent, "SecureActionButtonTemplate")
                IROKeyButton[nname]:SetAttribute("type", "macro")
                IROKeyButton[nname]:SetAttribute("macrotext", Nm[i]);
                IROKeyButton[nname]:RegisterForClicks("LeftButtonDown");
            else
                IROKeyButton[nname]:SetAttribute("macrotext", Nm[i]);
            end
end end end
SetKey(true)

IUSC.NumToSpell={}
IUSC.NumToID={}
IUSC.IDToSpell={}

for k,v in pairs(IUSC.ColorToSpell) do
    k=string.sub(k,5,8)
    local n=tonumber(k,16)
    local N,_,_,_,_,_,id=GetSpellInfo(v)
    if N then
        IUSC.NumToSpell[n]=N
        IUSC.NumToID[n]=id
        IUSC.IDToSpell[id]=N
    else
        IUSC.NumToSpell[n]=v
        IUSC.NumToID[n]=0
    end
end
