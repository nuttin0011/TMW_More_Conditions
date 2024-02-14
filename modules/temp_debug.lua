local status=Hekili.State.trinket.t1.__ability
if status~="null_cooldown" then
    Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket.t1.__ability].disabled=not Hekili.DB.profile.specs[GeRODPS.specID].items[Hekili.State.trinket.t1.__ability].disabled
end
GeRODPS.CheckTrinket(1)
GeRODPS.CheckTrinket(2)