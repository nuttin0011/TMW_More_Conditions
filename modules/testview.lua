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
            SetBindingMacro('NUMPAD'..i,'~!Num'..i)
        end
        TMW.CNDT.Env.IRODPSversion()
        DeleteMacro("~NumDotUsedSkill")
        DeleteMacro("~NumDotUsedSkill")
        CreateMacro("~NumDotUsedSkill",460699, M0, true)
        SetBindingMacro("NUMPADDECIMAL","~NumDotUsedSkill")
        SaveBindings(GetCurrentBindingSet())
    end
end
SetNumDotKey()

IROStopCastHandle=C_Timer.NewTimer(0.1,function() end)
IROPressStopCast=function()
    if not IsAltKeyDown() then return end
    IROStopCasted=true
    IROStopCastHandle:Cancel()
    IROStopCastHandle=C_Timer.NewTimer(0.5,function()
            IROStopCasted=nil
    end)
end



