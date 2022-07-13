-- Care Stun Diminishing returns 3.0
-- Set Priority to 25 
-- use some function from Care Stun

--function IROVar.CareStunDR.CheckDR(nUnit) -- return DR level 100 , 75 , 25 , 0 | 0 = immune or unit invalid
--function IROVar.CareStunDR.CheckDRTarget()

IROVar.CareStunDR={}
IROVar.CareStunDR.UnitList={}
--[[
    {["UnitGUID"]= DR level , ["UnitGUID"]= DR level , ...}
]]
IROVar.CareStunDR.UnitListHandle={}
--[[
    {["UnitGUID"]= Handle , ["UnitGUID"]= Handle , ...}
]]
IROVar.CareStunDR.DRReset=18
IROVar.CareStunDR.DRSpellList={}
for _,v in pairs(TMW.BE.debuffs.Stunned) do
    IROVar.CareStunDR.DRSpellList[v]=1
end

function IROVar.CareStunDR.CheckDR(nUnit)
    nUnit=nUnit or "target"
    local uGUID=UnitGUID(nUnit)
    if not uGUID then return 0 end
    if not IROVar.CareStunDR.UnitList[uGUID] then
        return IROVar.OKStuned and IROVar.OKStuned(nUnit) and 100 or 0
    end
    return IROVar.CareStunDR.UnitList[uGUID]
end
function IROVar.CareStunDR.CheckDRTarget()
    local uGUID=IROVar.TargetGUID
    if not uGUID then return 0 end
    if not IROVar.CareStunDR.UnitList[uGUID] then
        return IROVar.OKStuned and IROVar.OKStunedTarget() and 100 or 0
    end
    return IROVar.CareStunDR.UnitList[uGUID]
end

IROVar.CareStunDR.DRResetHandle=nil
function IROVar.CareStunDR.ClearDR()
    IROVar.CareStunDR.UnitList={}
    IROVar.CareStunDR.UnitListHandle={}
    if IROVar.CareStunDR.DRResetHandle then
        IROVar.CareStunDR.DRResetHandle:Cancel()
        IROVar.CareStunDR.DRResetHandle=nil
    end
end

IROVar.RegisterIncombatCallBackRun("CareStunDR",function()
    if IROVar.CareStunDR.DRResetHandle then
        IROVar.CareStunDR.DRResetHandle:Cancel()
        IROVar.CareStunDR.DRResetHandle=nil
    end
end)
IROVar.RegisterOutcombatCallBackRun("CareStunDR",function()
    IROVar.CareStunDR.DRResetHandle=C_Timer.NewTimer(IROVar.CareStunDR.DRReset+5,IROVar.CareStunDR.ClearDR)
end)

function IROVar.CareStunDR.CombatEvent(...)
    local _,subevent,_,_,_,_,_,destGUID=...
    if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
        local spellID, spellName = select(12, ...)
        if IROVar.CareStunDR.DRSpellList[spellID] or IROVar.CareStunDR.DRSpellList[spellName] then
            local DRLevel=IROVar.CareStunDR.UnitList[destGUID]
            if not DRLevel then
                DRLevel=50
            else
                DRLevel=(DRLevel==100) and 50 or (DRLevel==50) and 25 or 0
            end
            IROVar.CareStunDR.UnitList[destGUID]=DRLevel
        end
    elseif subevent=="SPELL_AURA_REMOVED" then
        local spellID, spellName = select(12,...)
        if IROVar.CareStunDR.DRSpellList[spellID] or IROVar.CareStunDR.DRSpellList[spellName] then
            if IROVar.CareStunDR.UnitList[destGUID] then
                if IROVar.CareStunDR.UnitListHandle[destGUID] then
                    IROVar.CareStunDR.UnitListHandle[destGUID]:Cancel()
                end
            end
            do
                local dGUID=destGUID
                IROVar.CareStunDR.UnitListHandle[dGUID]=C_Timer.NewTimer(IROVar.CareStunDR.DRReset,function()
                    IROVar.CareStunDR.UnitList[dGUID]=nil
                    IROVar.CareStunDR.UnitListHandle[dGUID]=nil
                end)
            end
        end
    end
end

IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("CareStunDR",IROVar.CareStunDR.CombatEvent)