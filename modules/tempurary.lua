function IROVar.TargetEnemy.IsUnitCasting(tGUID,tUnitToken) -- Check Target token/GUID is casting?
    if UnitGUID(tUnitToken)~=tGUID then
        tUnitToken=Hekili.npUnits[tGUID]
        if not tUnitToken then return end
    end
    local n=UnitCastingInfo(tUnitToken)
    if not n then
        n=UnitChannelInfo(tUnitToken)
    end
    if n then return true else return false end
end

