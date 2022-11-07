-- ManyFunctionSnippet_Counter_Variable 10.0.0/2
-- Set Priority to 6

--[[
"targethp" = UnitHealth("target")
"playerhppercen" = math.floor(UnitHealth("player")/UnitHealthMax("player")*100)

"intericon" = 
    IROVar.InterruptSpell and 
    IROVar.TargetCastBar(0.1) and 
    IsMyInterruptSpellReady() and 
    IROVar.CareInterrupt("target") and 
    NextInterrupter.IsMyTurn() and
    (IsSpellInRange(IROVar.InterruptSpell,"target")==1)
"intericonb" = IROVar.TargetCastBar(0.4)and 1 or 0)
"stunicon" = IROVar.TargetCastBar(0.3,true)and IROVar.OKStunedTarget()and NextInterrupter.ZeroSITarget()and(not IROVar.KickPressed)
"stuniconb" = IROVar.VVCareInterruptTarget()
"enemycountviii" = IROEnemyCountInRange(8)
]]
if not IROVar then IROVar = {} end
if not IROVar.CV then IROVar.CV = {} end

IROVar.CV.InterIcon_Trigger_Tick=0.3
IROVar.CV.StunIcon_Trigger_Tick=0.31
IROVar.CV.Targethp_Tick=0.7
IROVar.CV.PlayerHPPercen_Tick=0.18
IROVar.CV.EC8Tick=0.8

--Enemy Count 8yard
--"item:34368" 8 yard
--"item:28767" 40 yard
IROVar.CV.EC8Tick=0.8
local function EC8()
    local nn
    local c=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player",nn) then
            c=c+(IsItemInRange("item:34368",nn) and 1 or 0)
        end
        if c>=6 then break end
    end
    IROVar.UpdateCounter("enemycountviii",c)
end
IROVar.CV.EC8H=C_Timer.NewTicker(IROVar.CV.EC8Tick,function()
    if TMW.time-IUSC.SkillPressStampTime>=IROVar.CV.EC8Tick then
        EC8()
    end
end)
IUSC.RegCallBackAfterSU["EC8"]=EC8


----------Interrupt Icon
local func=function()
    IROVar.UpdateCounter("intericon",(IROVar.InterruptSpell and IROVar.TargetCastBar(0.1)and IsMyInterruptSpellReady()and IROVar.CareInterrupt("target")and NextInterrupter.IsMyTurn()and(IsSpellInRange(IROVar.InterruptSpell,"target")==1))and 1 or 0)
    IROVar.UpdateCounter("intericonb",IROVar.TargetCastBar(0.4)and 1 or 0)
end
IROVar.CV.InterIconH=C_Timer.NewTicker(IROVar.CV.InterIcon_Trigger_Tick,func)

----------Stun Icon
local func2=function()
    IROVar.UpdateCounter("stunicon",(IROVar.TargetCastBar(0.3,true)and IROVar.OKStunedTarget()and NextInterrupter.ZeroSITarget()and(not IROVar.KickPressed))and 1 or 0)
    IROVar.UpdateCounter("stuniconb",IROVar.VVCareInterruptTarget()and 1 or 0)
end
IROVar.CV.StunIconH=C_Timer.NewTicker(IROVar.CV.StunIcon_Trigger_Tick,func2)

-- target HP
local function TargetHP()
    IROVar.UpdateCounter("targethp",UnitHealth("target"))
end
IROVar.CV.TargetHPH=C_Timer.NewTicker(IROVar.CV.Targethp_Tick,TargetHP)
IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Target Health Counter",TargetHP)

-- player HP percen
local function PlayerHPP()
    IROVar.UpdateCounter("playerhppercen",math.floor(UnitHealth("player")/UnitHealthMax("player")*100))
end
IROVar.CV.PlayerHPPercenH=C_Timer.NewTicker(IROVar.CV.PlayerHPPercen_Tick,PlayerHPP)

