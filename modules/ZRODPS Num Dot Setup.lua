-- ZRODPS Num Dot Setup
-- Alt + NumDot = /stopcasting
-- Ctrl + NumDot = /use Healthstone
-- NumDot = **removed in ZRO DPS**
-- When press Alt+NumDot "/stopcasting" and "IROStopCasted=true" ll run
-- that mean if "IROStopCasted==true" u dont press Alt+NumDot again.
-- and IROStopCasted=nil 0.5 sec after press Alt+Numdot

ConsoleExec("screenFlashEdge 0")
ConsoleExec("doNotFlashLowHealthWarning 1")
ConsoleExec("Gamma 1")
local M0='/stopcasting [mod:alt]\n/use [mod:ctrl]Healthstone\n/run IROPressStopCast()'

local function SetNumDotKey()
    if InCombatLockdown() then
        C_Timer.After(1,SetNumDotKey)
    else
        for i =0,9 do
            SetBindingClick('NUMPAD'..i,'~!Num'..i)
        end
        local nDname="~NumDotUsedSkill"
        TMW.CNDT.Env.IRODPSversion()
        DeleteMacro(nDname)
        DeleteMacro(nDname)
        if not IROKeyButton then IROKeyButton={} end
        if not IROKeyButton[nDname] then
            IROKeyButton[nDname]=CreateFrame('Button', nDname, UIParent, "SecureActionButtonTemplate")
            IROKeyButton[nDname]:SetAttribute("type", "macro")
            IROKeyButton[nDname]:SetAttribute("macrotext", M0);
            IROKeyButton[nDname]:RegisterForClicks("LeftButtonDown");
        else
            IROKeyButton[nDname]:SetAttribute("macrotext", M0);
        end
        SetBindingClick("NUMPADDECIMAL","~NumDotUsedSkill")
        SaveBindings(GetCurrentBindingSet())
    end
end
-- Bind +-*/
local function SetBindingAddSubMulDiv()
    if InCombatLockdown() then
        C_Timer.After(1,SetBindingAddSubMulDiv)
    else
        SetBindingClick("NUMPADMULTIPLY",'~!Num12')
        SetBindingClick("NUMPADDIVIDE",'~!Num13')
        SetBindingClick("NUMPADMINUS",'~!Num11')
        SetBindingClick("NUMPADPLUS",'~!Num10')
        SaveBindings(GetCurrentBindingSet())
    end
end

SetNumDotKey()
SetBindingAddSubMulDiv()

IROStopCastHandle=C_Timer.NewTimer(0.1,function() end)
IROPressStopCast=function()
    if not IsAltKeyDown() then return end
    IROStopCasted=true
    IROStopCastHandle:Cancel()
    IROStopCastHandle=C_Timer.NewTimer(0.5,function()
            IROStopCasted=nil
    end)
end


