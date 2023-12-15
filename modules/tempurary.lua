if not IROVar.TargetEnemy.FindJobName("DoomBrand") then
    IROVar.TargetEnemy.RegisterTargetting("xx",50,
    function()
        return Hekili:TargetIsNearPet( "target" ) and
        AuraUtil.FindAuraByName("Doom Brand","target", "PLAYER HARMFUL")==nil and
        UnitHealth( "target" ) > IROVar.HPMobDieIn4sec or
        not InCombatLockdown()
    end,"DoomBrand")
end



local function f()
    IROVar.HPMobDieIn5sec = IROVar.DPS.PredictHealthDieIn(5)
    IROVar.HPMobDieIn4sec = IROVar.HPMobDieIn5sec*0.8
end

if IROSpecID==266 then
    IROVar.RegisterIncombatCallBackRun("find IROVar.HPMobDieIn5sec",function()C_Timer.After(1,f)end)
    C_Timer.NewTicker(1.5,f)
end