-- Many Function Version Mage 9.0.5/2
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Mage.registerCheckSpellSequence(sequence,timeout,timeout_after1stSpell|nil,callback,run_callback_when_timeout)
--function IROVar.Mage.UseFlurry(n) ; check condition use Flurry when brain freeze proc
--function IROVar.Mage.UseILFrostFinger(n) ; as above
--function IROVar.Mage.FixBrainFreezeStatus() ; fix when casting Flurry. (should not casting flurry)

if not IROVar then IROVar={} end
if not IROVar.Mage then IROVar.Mage={} end

IROVar.Mage.playerGUID=UnitGUID("player")
IROVar.Mage.CastSequenceCheck={}
IROVar.Mage.currentFlurry=1
IROVar.Mage.BrainFreezeStatus=0
IROVar.Mage.currentIL=1
IROVar.Mage.FoFStatus=0
IROVar.Mage.usingFlurryRotation=false
--IROVar.Mage.ResetUsingFlurryRotationHandle=C_Timer.NewTimer(0, function() end)
--use "/run IROVar.Mage.UsingFlurryRotation()" in macro button
--and it ll reset to false when end of Flurry Rotation
IROVar.Mage.BlizardList={}
--
--[[ IROVar.Mage.BlizardList={
    blizzard
    [1]=GUID



}]]


--[[
    CastSequenceCheck = {
        [1] = {
            spellName = {
                [1]="Flurry",
                [2]="Ice Lance",
                [3]="Ice Lance"
            },
            checkOrder = 1,
            timeOut = 65004.25,
            timeout_after1stSpell=5,
            callBack = function() TMW_ST:UpdateCounter("flurry",0) end,
            run_callback_when_timeout = true,
            canceled = false,
        },
    }
]]

function IROVar.Mage.FlurryProcEvent(timeBuff)
    IROVar.Mage.BrainFreezeStatus=IROVar.Mage.BrainFreezeStatus+1
    local flurryFunc=function()
        IROVar.Mage.BrainFreezeStatus=IROVar.Mage.BrainFreezeStatus-1
        IROVar.Mage.currentFlurry=IROVar.Mage.currentFlurry+1
        IROVar.Mage.usingFlurryRotation=false
    end
    IROVar.Mage.registerCheckSpellSequence("Flurry|Ice Lance|Ice Lance",timeBuff,5,flurryFunc,true)
end

function IROVar.Mage.FoFProcEvent(timeBuff)
    local stringIL="Ice Lance"..string.rep("|Ice Lance",IROVar.Mage.FoFStatus)
    IROVar.Mage.FoFStatus=IROVar.Mage.FoFStatus+1
    local ILFunc=function()
        IROVar.Mage.FoFStatus=IROVar.Mage.FoFStatus-1
        IROVar.Mage.currentIL=IROVar.Mage.currentIL+1
    end
    IROVar.Mage.registerCheckSpellSequence(stringIL,timeBuff,nil,ILFunc,true)
end

function IROVar.Mage.destroySequence(se,finishSequence)
    se.canceled=true
    if finishSequence or se.run_callback_when_timeout then
        se.callBack()
    end
end

function IROVar.Mage.UsingFlurryRotation()
    if not IROVar.Mage.usingFlurryRotation then
        --IROVar.Mage.ResetUsingFlurryRotationHandle:Cancel()
        if (IROVar.Mage.FlurryIcon1Show~=nil) and
        (IROVar.Mage.FlurryIcon2Show~=nil) then
            if IROVar.Mage.FlurryIcon1Show or IROVar.Mage.FlurryIcon2Show then
                IROVar.Mage.usingFlurryRotation=true
            end
        else
            IROVar.Mage.usingFlurryRotation=true
        end
    end
end

function IROVar.Mage.CastSequenceCheckEvent(spellName)
    --[[if spellName=="Flurry" then -- "IROVar.Mage.usingFlurryRotation=false" fail save. use 4 GCD after cast flurry
        IROVar.Mage.ResetUsingFlurryRotationHandle:Cancel()
        IROVar.Mage.ResetUsingFlurryRotationHandle=C_Timer.NewTimer(GCDCDTime()*4,
            function()
                IROVar.Mage.usingFlurryRotation=false
            end)
    end]]
    local currentTime=GetTime()
    for k,v in pairs(IROVar.Mage.CastSequenceCheck) do
        if currentTime>v.timeOut then
            IROVar.Mage.destroySequence(v,false)
        end
        if v.spellName[v.checkOrder]==spellName then
            if (v.checkOrder==1)and v.timeout_after1stSpell then
                C_Timer.After(v.timeout_after1stSpell,IROVar.Mage.checkSequenceTimeOut)
                v.timeOut=currentTime+v.timeout_after1stSpell
            end
            v.checkOrder=v.checkOrder+1
            if v.spellName[v.checkOrder]==nil then
                IROVar.Mage.destroySequence(v,true)
            end
        end
        if IROVar.Mage.CastSequenceCheck[k].canceled then
            IROVar.Mage.CastSequenceCheck[k]=nil
        end
    end
end

function IROVar.Mage.destroyAllSequence()
    IROVar.Mage.CastSequenceCheck={}
    IROVar.Mage.BrainFreezeStatus=0
    IROVar.Mage.usingFlurryRotation=false
    IROVar.Mage.FoFStatus=0
end

function IROVar.Mage.FixBrainFreezeStatus()
    IROVar.Mage.destroyAllSequence()
    local BF,FoF,FoFCount
    for i=1,40 do
        local name, _, count = UnitBuff("player",i,"PLAYER")
        if not name then
            break
        elseif name=="Brain Freeze" then
            BF=true
        elseif name=="Fingers of Frost" then
            FoF=true
            FoFCount=count
        end
    end
    if BF then
        IROVar.Mage.FlurryProcEvent()
    end
    if FoF then
        IROVar.Mage.FoFStatus=FoFCount-1
        IROVar.Mage.FoFProcEvent()
    end
end

function IROVar.Mage.CombatEvent()
    local _,subevent,_,sourceGUID,_,_,_,_,_,_,_,_,spellName=CombatLogGetCurrentEventInfo()
    if (sourceGUID~=IROVar.Mage.playerGUID) then return end
    if (subevent=="SPELL_CAST_SUCCESS")then
        IROVar.Mage.CastSequenceCheckEvent(spellName)
    elseif (subevent=="SPELL_AURA_APPLIED") or (subevent=="SPELL_AURA_APPLIED_DOSE") then
        if (spellName=="Brain Freeze") then
            IROVar.Mage.FlurryProcEvent(14)
        elseif (spellName=="Fingers of Frost") then
            IROVar.Mage.FoFProcEvent(14)
        end
    elseif (subevent=="SPELL_CAST_START") and (spellName=="Frostbolt") and IROVar.Mage.usingFlurryRotation then
        IROVar.Mage.usingFlurryRotation=false
        --Fail Save IROVar.Mage.usingFlurryRotation
    end
    --[[
    if (subevent=="SPELL_CAST_START") and(spellName=="Flurry")then
    end
    ]]
end

IROVar.Mage.frame =CreateFrame("Frame")
IROVar.Mage.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Mage.frame:SetScript("OnEvent",IROVar.Mage.CombatEvent)

function IROVar.Mage.checkSequenceTimeOut()
    local currentTime=GetTime()+0.01
    for k,v in pairs(IROVar.Mage.CastSequenceCheck) do
        if currentTime>v.timeOut then
            if v.run_callback_when_timeout then v.callBack() end
            IROVar.Mage.CastSequenceCheck[k]=nil
        end
    end
end

function IROVar.Mage.registerCheckSpellSequence(sequence,timeout,timeout_after1stSpell,callback,run_callback_when_timeout)
    -- run callback function when all sequence casted
    -- or run when timeout when run_callback_when_timeout == true
    -- if timeout (s) ll destroy this sequence
    -- e.g.
    -- sequence = "Flurry|Ice Lance|Ice Lance" use | for split spell
    -- timeout = 5 (sec)
    -- callback = function() TMW_ST:UpdateCounter("flurry",0) end
    -- run_callback_when_timeout = true
    table.insert(IROVar.Mage.CastSequenceCheck,{
        spellName={strsplit("|",sequence)},
        checkOrder=1,
        timeOut=GetTime()+timeout,
        timeout_after1stSpell=timeout_after1stSpell,
        callBack=callback,
        run_callback_when_timeout=run_callback_when_timeout,
        canceled = false,
    })
    C_Timer.After(timeout,IROVar.Mage.checkSequenceTimeOut)
end

function IROVar.Mage.UseFlurry(n)
    -- seperate flurry IL combo to n macro
    -- e.g. 2 macro
    -- 1 /cast reset=3 flurry, Ice Lance, Ice Lance
    -- 2 /cast reset=3.1 flurry, Ice Lance, Ice Lance
    -- syntax "Use1stMacro=IROVar.Mage.UseFlurry(2)==1" ; it's return 1 when macro 1 should use
    -- syntax "Use2ndMacro=IROVar.Mage.UseFlurry(2)==2" ; it's return 2 when macro 2 should use
    -- it' return 0 if IROVar.Mage.BrainFreezeStatus==0
    return (IROVar.Mage.BrainFreezeStatus>=1) and ((IROVar.Mage.currentFlurry % n)+1) or 0
end

function IROVar.Mage.UseILFrostFinger(n)
    --use same as function IROVar.Mage.UseFlurry(n)
    return (IROVar.Mage.FoFStatus>=1) and ((IROVar.Mage.currentIL % n)+1) or 0
end


