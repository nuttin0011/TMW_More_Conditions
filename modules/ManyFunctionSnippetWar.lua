-- Many Function Version War 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IsUsableExecute(nUnit) ; return true/false

IROVar.ItemNameToCheck2Yd = "item:37727"

function IsUsableExecute(nUnit)
    nUnit=nUnit or "target"
    local OldVal=IROVar.ERO_Old_Val.Check("IsUsableExecute",nUnit)
    if OldVal then return OldVal end
    local uH ,uHM, uHP, output
    if UnitCanAttack("player", nUnit) and IsItemInRange(IROVar.ItemNameToCheck2Yd, nUnit) then
        uHM=UnitHealthMax(nUnit)
        uH=UnitHealth(nUnit)
        uHP=(uH/uHM)*100
        output=(uHP>0) and ((uHP<20) or ((uHP<35) and IROVar.isMassacre) or ((uHP>80) and IROVar.isCondemn))
        IROVar.ERO_Old_Val.Update("IsUsableExecute",nUnit,output)
        return output
    else
        IROVar.ERO_Old_Val.Update("IsUsableExecute",nUnit,false)
        return false
    end
end