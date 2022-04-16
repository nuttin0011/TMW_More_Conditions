CastingInfo
ChannelInfo
IROVar.FMobCasttingInfo={}
--[[
    FMobCasttingInfo = {
        [UnitGUID(UnitToken)]={UnitCastingInfo(UnitToken)},
        ...
    }
]]
IROVar.FMobChannelInfo={}
--[[
    FMobChannelInfo = {
        [UnitGUID(UnitToken)]={UnitChannelInfo(UnitToken)},
        ...
    }
]]
function IROVar.FInterruptOnEventChannel(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    IROVar.FMobChannelInfo[UnitGUID(arg1)]={UnitChannelInfo(arg1)}
end
function IROVar.FInterruptOnEventCast(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    IROVar.FMobCasttingInfo[UnitGUID(arg1)]={UnitCastingInfo(arg1)}
end
function IROVar.FInterruptOnEventNamePlateAdd(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    if UnitCanAttack("player", arg1) then
        IROVar.FMobChannelInfo[UnitGUID(arg1)]={UnitChannelInfo(arg1)}
        IROVar.FMobCasttingInfo[UnitGUID(arg1)]={UnitCastingInfo(arg1)}
    end
end
function IROVar.FInterruptOnEventNamePlateRemove(self,event,arg1,arg2,arg3,...)
    if arg1==nil then return end
    if UnitCanAttack("player", arg1) then
        IROVar.FMobChannelInfo[UnitGUID(arg1)]={UnitChannelInfo(arg1)}
        IROVar.FMobCasttingInfo[UnitGUID(arg1)]={UnitCastingInfo(arg1)}
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
IROVar.FInterruptChannel = CreateFrame("Frame")
IROVar.FInterruptChannel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
IROVar.FInterruptChannel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
IROVar.FInterruptChannel:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
IROVar.FInterruptChannel:SetScript("OnEvent",IROVar.FInterruptOnEventChannel)
IROVar.FInterruptCast = CreateFrame("Frame")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_DELAYED")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_FAILED")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_START")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_STOP")
IROVar.FInterruptCast:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
IROVar.FInterruptCast:SetScript("OnEvent",IROVar.FInterruptOnEventCast)
IROVar.FInterruptNamePlate = CreateFrame("Frame")
--IROVar.FInterruptNamePlate:RegisterEvent("FORBIDDEN_NAME_PLATE_CREATED")
IROVar.FInterruptNamePlate:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
IROVar.FInterruptNamePlate:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED")
--IROVar.FInterruptNamePlate:RegisterEvent("NAME_PLATE_CREATED")
IROVar.FInterruptNamePlate:RegisterEvent("NAME_PLATE_UNIT_ADDED")
IROVar.FInterruptNamePlate:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
IROVar.FInterruptNamePlate:SetScript("OnEvent",IROVar.FInterruptOnEventNamePlateAdd)
