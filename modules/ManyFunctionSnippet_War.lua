-- Many Function Version War 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.War.CanExx(Unit or blank = "target") ; return true/false
--function IROVar.War.IsEquipShield() ; return true/false

if not IROVar then IROVar={} end
IROVar.War={}
IROVar.War.it2Yd = "item:37727"
IROVar.War.isMass = false
IROVar.War.isCondemn = false
IROVar.War.isEquipShield = false


function IROVar.War.CanExx(U)
    U=U or "target"
    if not IROVar.War.FOnEvent then IROVar.War.SetupEventCheck() end
    local OldVal=IROVar.ERO_Old_Val.Check("War.CanExx",U)
    if OldVal then return OldVal end
    local uHP, output
    if UnitCanAttack("player", U) and IsItemInRange(IROVar.War.it2Yd, U) then
        uHP=(UnitHealth(U)/UnitHealthMax(U))*100
        output=(uHP>0) and ((uHP<20) or ((uHP<35) and IROVar.War.isMass) or ((uHP>80) and IROVar.War.isCondemn))
        IROVar.ERO_Old_Val.Update("War.CanExx",U,output)
        return output
    else
        IROVar.ERO_Old_Val.Update("War.CanExx",U,false)
        return false
    end
end

function IROVar.War.CheckTalent()
    local _,TName,_,TSelected=GetTalentInfo(3,1,1)
    IROVar.War.isMass = (TName=="Massacre") and TSelected
    IROVar.War.isCondemn = GetSpellInfo("execute")=="Condemn"
end

function IROVar.War.SetupEventCheck()
    IROVar.War.FOnEvent=function(_,event)
        print("Event in Warrior On Event",event)
        if event == "PLAYER_TALENT_UPDATE" then
            C_Timer.After(2,IROVar.War.CheckTalent)
        elseif event == "UNIT_INVENTORY_CHANGED" then
            local ItemLink=GetInventoryItemLink("player", 17)--shield
            IROVar.War.isEquipShield=(ItemLink~=nil) and (select(7,GetItemInfo(ItemLink))=="Shields") or false
        end
    end
    C_Timer.After(2,IROVar.War.CheckTalent)
    IROVar.War.FEvent = CreateFrame("Frame")
    IROVar.War.FEvent:RegisterEvent("PLAYER_TALENT_UPDATE")
    IROVar.War.FEvent:RegisterEvent("UNIT_INVENTORY_CHANGED")
    IROVar.War.FEvent:SetScript("OnEvent", IROVar.War.FOnEvent)
end

function IROVar.War.IsEquipShield()
    if not IROVar.War.FOnEvent then IROVar.War.SetupEventCheck() end
    return IROVar.War.isEquipShield
end



