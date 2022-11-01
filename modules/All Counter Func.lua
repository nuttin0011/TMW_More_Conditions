--[[ note

--function IROVar.UpdateCounter(n,v) ; update counter name to value

TMW_ST.Timers.Init(name)
TMW_ST.Timers.Start(name)
TMW_ST.Timers.Stop(name)
TMW_ST.Timers.Reset(name)
TMW_ST.Timers.Restart(name)
TMW_ST.Timers.GetTime(name)

TMW_ST:GetCounter(name)
TMW_ST:InitCounter(name)
TMW_ST:UpdateCounter(name, value)

]]



----------- Check event UNIT_AURA
auraArg={}
auraArgisFullUpdate={}
auraFrame=CreateFrame("Frame")
auraFrame:RegisterEvent("UNIT_AURA")
auraFrame:SetScript("OnEvent",function(self,event,unitTarget, updatedAuras)
    if unitTarget~="player" then return end
    --print("UNIT_AURA player")
    --print("updatedAuras",updatedAuras and updatedAuras or "nil")
    if updatedAuras.isFullUpdate then
        print("UNIT_AURA player :: isFullUpdate")
        table.insert(auraArgisFullUpdate,updatedAuras)
    end
    table.insert(auraArg,updatedAuras)
end)



----------Interrupt Icon
local func=function()
    IROVar.UpdateCounter("intericon",(IROVar.InterruptSpell and IROVar.TargetCastBar(0.1)and IsMyInterruptSpellReady()and IROVar.CareInterrupt("target")and NextInterrupter.IsMyTurn()and(IsSpellInRange(IROVar.InterruptSpell,"target")==1))and 1 or 0)
    IROVar.UpdateCounter("intericonb",IROVar.TargetCastBar(0.4)and 1 or 0)
end
if not IROVar.InterIconTrigger then
    IROVar.InterIconTrigger=C_Timer.NewTicker(0.15,func)
end

----------Stun Icon
local func2=function()
    IROVar.UpdateCounter("stunicon",(IROVar.TargetCastBar(0.3,true)and IROVar.OKStunedTarget()and NextInterrupter.ZeroSITarget()and(not IROVar.KickPressed))and 1 or 0)
    IROVar.UpdateCounter("stuniconb",IROVar.VVCareInterruptTarget()and 1 or 0)
end
if not IROVar.StunIconTrigger then
    IROVar.StunIconTrigger=C_Timer.NewTicker(0.15,func2)
end



----------HUNTER-----------
----------HUNTER-----------
----------HUNTER-----------
----------HUNTER-----------

--Tranquilizing Shot Icon
local func3=function()
    TMW_ST.Timers.Restart("changetarget")
end
if not IROVar.PLAYER_TARGET_CHANGED_CALLBACK["HunTQ"] then
    IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("HunTQ",func3)
end




----------ROGUE----------
----------ROGUE----------
----------ROGUE----------
----------ROGUE----------

-- Combo Point
--event UNIT_AURA: unitTarget, isFullUpdate, updatedAuras
--

--("UNIT_POWER_FREQUENT", "player", "COMBO_POINTS")

IROVar.RogueCP={}
IROVar.RogueCP.BuffBroadside=false
IROVar.RogueCP.BuffShadowBlades=false
IROVar.RogueCP.CPMax=UnitPowerMax("player",4)
IROVar.RogueCP.UNIT_AURA_Frame=CreateFrame("Frame")
IROVar.RogueCP.UNIT_AURA_Frame:RegisterEvent("UNIT_AURA")
IROVar.RogueCP.UNIT_AURA_Frame:RegisterEvent("UNIT_POWER_FREQUENT")

IROVar.RogueCP.UNIT_AURA_Frame:SetScript("OnEvent",function(self,event,arg1, arg2)
    if arg1~="player" then return end
    if event=="UNIT_AURA" then
        local name
        local BuffBroadside=false
        local BuffShadowBlades=false
        for i=1,40 do
            name=UnitAura("player",i)
            if not name then break end
            if name =="Broadside" then BuffBroadside=true end
            if name =="Shadow Blades" then BuffShadowBlades=true end
        end
        IROVar.RogueCP.BuffBroadside=BuffBroadside
        IROVar.RogueCP.BuffShadowBlades=BuffShadowBlades
    elseif event=="UNIT_POWER_FREQUENT" then
        if arg1=="COMBO_POINTS" then
            local c=UnitPower("player",4)
        end
    end

end)