-- Many Function Version War 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.War.CanExx(U) ; return true/false

if not IROVar then IROVar={} end
IROVar.War={}
IROVar.War.It2Yd = "item:37727"
IROVar.War.isMass = nil
IROVar.War.isCondemn = nil




function IROVar.War.CanExx(U)
    U=U or "target"
    if IROVar.War.isMass==nil then IROVar.War.SetupTalentCheck() end
    local OldVal=IROVar.ERO_Old_Val.Check("War.CanExx",U)
    if OldVal then return OldVal end
    local uH ,uHM, uHP, output
    if UnitCanAttack("player", U) and IsItemInRange(IROVar.War.It2Yd, U) then
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

function IROVar.War.SetupTalentCheck()
    IROVar.War.FOnEvent=function()
        C_Timer.After(1,IROVar.War.CheckTalent)
    end
    IROVar.War.CheckTalent()
    IROVar.War.FEvent = CreateFrame("Frame")
    IROVar.War.FEvent:RegisterEvent("PLAYER_TALENT_UPDATE")
    IROVar.War.FEvent:SetScript("OnEvent", IROVar.War.FOnEvent)
end




