--CastingInfo
--ChannelInfo
IROVar.IROCast={}
IROVar.IROCast.FMobCasttingInfo={}
--[[
    FMobCasttingInfo = {
        [UnitGUID(UnitToken)]={UnitCastingInfo(UnitToken)},
        ...
    }
]]
IROVar.IROCast.FMobChannelInfo={}
--[[
    FMobChannelInfo = {
        [UnitGUID(UnitToken)]={UnitCastingInfo(UnitToken)},
        ...
    }
]]
IROVar.IROCast.MobInterruptStatusInfo={}
--[[
    ["UnitGUID"]={
        ["InterruptCondition_Name"]={
            start = start time to interrupt | time compare with GetTime()/TMW.time
            end = end time to interrupt | time compare with GetTime()/TMW.time
            -- if GetTime()>end, ["InterruptCondition_Name"] = nil
        },

    },
    -- if ["UnitGUID"] = empty table, ["InterruptCondition_Name"] = nil
]]
local IROCast=IROVar.IROCast
local FMobChannelInfo=IROCast.FMobChannelInfo
local FMobCasttingInfo=IROCast.FMobCasttingInfo
local MobISI=IROCast.MobInterruptStatusInfo
IROCast.InterruptCondition={}
--[[
    ["contitionName1"] = {
        OnlyCasting = true/false, -- if false Check both Casting and Channeling
        MSMinCast = milliseconds Time To Start and Befor Cast Finish Interrupt,
            -- Example: MSMinCast = 1000 -- mean Interrupt after 1 sec cast pass and 1 sec befor cast finish
        PercentOfCastTime = 0-100 -- if 0 then interrupt as soon as posible
            -- not effect Channeling
        MustInterruptable = true/false -- if true interrupt only interruptable
    },
    ["0"]={ -- default value
        OnlyCasting = false
        MSMinCast = 300
        PercentOfCastTime = 60
        MustInterruptable = false
    }
]]
IROCast.InterruptCondition[0]={-- default value
    OnlyCasting = false,
    MSMinCast = 300,
    PercentOfCastTime = 60,
    MustInterruptable = false
}
function IROCast.RegisterInterruptCondition(nameCondition,OnlyCasting,MSMinCast,PercentOfCastTime,MustInterruptable)
    IROCast.InterruptCondition[nameCondition]={
        OnlyCasting = OnlyCasting,
        MSMinCast = MSMinCast,
        PercentOfCastTime = PercentOfCastTime,
        MustInterruptable = MustInterruptable
    }
end
function IROCast.UnRegisterInterruptCondition(nameCondition)
    IROCast.InterruptCondition[nameCondition]=nil
end

function IROCast.UnitCastingInfo(unit)
    local info={}
    info.castID,info.spellID,info.spellName,info.spellSchool,info.startTime,info.endTime,info.isTradeSkill,info.castID,info.notInterruptible = UnitCastingInfo(unit)
    if info.castID then
        info.startTime = info.startTime/1000
        info.endTime = info.endTime/1000
        return info
    else
        return nil
    end
end






function IROCast.FInterruptOnEventChannel(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    FMobChannelInfo[UnitGUID(arg1)]={UnitChannelInfo(arg1)}
end
function IROCast.FInterruptOnEventCast(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    FMobCasttingInfo[UnitGUID(arg1)]={UnitCastingInfo(arg1)}
end
function IROCast.FInterruptOnEventNamePlateAdd(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    if UnitCanAttack("player", arg1) then
        FMobChannelInfo[UnitGUID(arg1)]={UnitChannelInfo(arg1)}
        FMobCasttingInfo[UnitGUID(arg1)]={UnitCastingInfo(arg1)}
    end
end
function IROCast.FInterruptOnEventNamePlateRemove(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    if UnitCanAttack("player", arg1) then
        FMobChannelInfo[UnitGUID(arg1)]={UnitChannelInfo(arg1)}
        FMobCasttingInfo[UnitGUID(arg1)]={UnitCastingInfo(arg1)}
    end
end
--[[
UNIT_SPELLCAST_CHANNEL_START: unitTarget, castGUID, spellID
UNIT_SPELLCAST_CHANNEL_STOP: unitTarget, castGUID, spellID
UNIT_SPELLCAST_CHANNEL_UPDATE: unitTarget, castGUID, spellID
UNIT_SPELLCAST_DELAYED: unitTarget, castGUID, spellID
UNIT_SPELLCAST_FAILED: unitTarget, castGUID, spellID
UNIT_SPELLCAST_FAILED_QUIET: unitTarget, castGUID, spellID
UNIT_SPELLCAST_INTERRUPTED: unitTarget, castGUID, spellID
UNIT_SPELLCAST_INTERRUPTIBLE: unitTarget
UNIT_SPELLCAST_NOT_INTERRUPTIBLE: unitTarget
UNIT_SPELLCAST_START: unitTarget, castGUID, spellID
UNIT_SPELLCAST_STOP: unitTarget, castGUID, spellID
UNIT_SPELLCAST_SUCCEEDED: unitTarget, castGUID, spellID

FORBIDDEN_NAME_PLATE_CREATED: namePlateFrame
FORBIDDEN_NAME_PLATE_UNIT_ADDED: unitToken
FORBIDDEN_NAME_PLATE_UNIT_REMOVED: unitToken
NAME_PLATE_CREATED: namePlateFrame
NAME_PLATE_UNIT_ADDED: unitToken
NAME_PLATE_UNIT_REMOVED: unitToken
]]
IROCast.FInterruptChannel = CreateFrame("Frame")
IROCast.FInterruptChannel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
IROCast.FInterruptChannel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
IROCast.FInterruptChannel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
IROCast.FInterruptChannel:SetScript("OnEvent",IROCast.FInterruptOnEventChannel)
IROCast.FInterruptCast = CreateFrame("Frame")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_DELAYED")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_FAILED")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_START")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_STOP")
IROCast.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
IROCast.FInterruptCast:SetScript("OnEvent",IROCast.FInterruptOnEventCast)
IROCast.FInterruptNamePlate = CreateFrame("Frame")
--IROCast.FInterruptNamePlate:RegisterEvent("FORBIDDEN_NAME_PLATE_CREATED")
IROCast.FInterruptNamePlate:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
IROCast.FInterruptNamePlate:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED")
--IROCast.FInterruptNamePlate:RegisterEvent("NAME_PLATE_CREATED")
IROCast.FInterruptNamePlate:RegisterEvent("NAME_PLATE_UNIT_ADDED")
IROCast.FInterruptNamePlate:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
IROCast.FInterruptNamePlate:SetScript("OnEvent",IROCast.FInterruptOnEventNamePlateAdd)
