
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
-- Bind +-*/
local function SetBindingAddSubMulDiv()
    if InCombatLockdown() then
        C_Timer.After(1,SetBindingAddSubMulDiv)
    else
        SetBindingMacro("NUMPADMULTIPLY"
        ,'~!Num12')
        SetBindingMacro("NUMPADDIVIDE"
        ,'~!Num13')
        SetBindingMacro("NUMPADMINUS"
        ,'~!Num11')
        SetBindingMacro("NUMPADPLUS"
        ,'~!Num10')
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







--IROVar.IconSweepCompair(IROCallDSIcon,18,h) and (IROVar.IconSweepCompair(IROVileFiendIcon,18,h) or not TMW.CNDT.Env.TalentMap["summon vilefiend"])

--IROVar.Lock.GetWildImpCountTimePass(t)

(function()
    local n,_,_,_,et = UnitCastingInfo("player")
    if n~="Summon Demonic Tyrant" then return false end
    local C=(et/1000)-GetTime()
    local ImpTyrant1=IROVar.Lock.GetWildImpCountTimePass(C)
    local TyHoG=IROVar.CastTime1_5sec+IROVar.CastTime2sec
    local ImpTyrant2=IROVar.Lock.GetWildImpCountTimePass(0.2+TyHoG)
    if ImpTyrant2>=ImpTyrant1 then
        TyHoG=TyHoG+0.3
        local DSVFRemain=IROVar.IconSweepCompair(IROCallDSIcon,18,TyHoG) and (IROVar.IconSweepCompair(IROVileFiendIcon,18,TyHoG) or not TMW.CNDT.Env.TalentMap["summon vilefiend"])
        if DSVFRemain then
            return true
        end
    end
    return false
end)()



local a=(not IROVar.activeConduits["Tyrant's Soul"])or(TMW.CNDT.Env.AuraDur("player", "demonic power", "PLAYER HELPFUL")==0)





(function()-- player Castting HoG, then Cast Summon Tyrant After This HoG?
    if GetSpellCooldown("Summon Demonic Tyrant")>0 then return false end
    local n,_,_,_,et = UnitCastingInfo("player")
    if n~="Hand of Gul'dan" then return false end
    local Imp=IROVar.Lock.GetWildImpCount()
    if Imp<3 then return false end
    local SS=IROVar.Lock.PredictSS()
    if SS==0 then return true end

    local C=(et/1000)-GetTime()
    local HoGTyrantCast=C+IROVar.CastTime2sec
    local HoGHoGTyrant=HoGTyrantCast+IROVar.CastTime1_5sec
    local HoGDBHoGTyrant=HoGHoGTyrant+IROVar.CastTime1_5sec
    local ImpHoGTyrantCast=IROVar.Lock.GetWildImpCountTimePass(HoGTyrantCast)
    local DCStack=IROVar.GetDemonicCoreStack()

    if SS==1 and DCStack>=1 then
        local ImpHoGDBHoGTyrant=IROVar.Lock.GetWildImpCountTimePass(HoGDBHoGTyrant)
        return ImpHoGDBHoGTyrant<ImpHoGTyrantCast
    end
    if SS>=2 then
        local ImpHoGHoGTyrant=IROVar.Lock.GetWildImpCountTimePass(HoGHoGTyrant)
        --IROVar.NextSpellIsHoG=true
        return ImpHoGHoGTyrant<ImpHoGTyrantCast
    end
    return false
end)()

local aa=
IROVar.Lock.PredictSS()>=50 or
(IROVar.Lock.PredictSS()>=40 and IROVar.GetDemonicCoreStack()>=2) or
(IROVar.Lock.PredictSS()>=40 and
GetSpellCooldown("Call Dreadstalkers")==0 and
TMW.CNDT.Env.AuraDur("player", "demonic calling", "PLAYER HELPFUL")>0)

--Spec = "1","2","3"
--IconName = "icon1" , "icon2" , "icon3"
--use IROVar.SetIconColorForDPS(icon,"1","icon1")
function IROVar.SetIconColorForDPS(TMWicon,Spec,IconName)
    local cc=IROVar["Cast"..IconName] or "ff000000"
    local SpecIconName="spec"..Spec..IconName --> all low char
    if TMWicon.States[1].Color~=cc then
        if IROVar[SpecIconName.."1"] then
            IROVar[SpecIconName.."1"].States[1].Color=cc
        end
        if IROVar[SpecIconName.."2"] then
            IROVar[SpecIconName.."2"].States[1].Color=cc
        end
        if TMW_ST:GetCounter(SpecIconName)==0
        then
            TMW_ST:UpdateCounter(SpecIconName,1)
        else
            TMW_ST:UpdateCounter(SpecIconName,0)
        end
    end
end

a=

IROVar and IROVar.CareInterrupt
and PercentCastbar2 and IROVar.InterruptSpell
and (TMW_ST:GetCounter("wantinterrupt")==1)
and (GetSpellCooldown(IROVar.InterruptSpell)==0)
and (IsSpellInRange(IROVar.InterruptSpell,"target")==1)
and PercentCastbar2()
and IROVar.CareInterrupt("target")
and ((not NextInterrupter) or NextInterrupter.IsMyTurn())





if Rotation.TimeLimit-GetTime()>6*Rotation.CastTime0_5sec then TMW_ST:UpdateCounter("wanttyrant",4) else TMW_ST:UpdateCounter("wanttyrant",1) end

/stopmacro [mod]
/run local z if Rotation.TimeLimit-GetTime()>6*IROVar.CastTime0_5sec then z=4 else z=1 end TMW_ST:UpdateCounter("wanttyrant",z)


