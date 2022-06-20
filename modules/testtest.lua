

IROVar.CastBar={}
IROVar.CastBar.Casting=nil
IROVar.CastBar.Channeling=nil
IROVar.CastBar.Spell=nil
IROVar.CastBar.SpellId=nil
IROVar.CastBar.StartKick=0 --kick mean interrupt
IROVar.CastBar.EndKick=0
IROVar.CastBar.CantKick=false
IROVar.CastBar.OldPercenCheck=0.6
--name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(unit)
--name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo(unit)
function IROVar.CastBar.CheckCasting()
    IROVar.CastBar.Casting={UnitCastingInfo("target")}
end

function IROVar.CastBar.CheckChanneling()
    IROVar.CastBar.Channeling={UnitChannelInfo("target")}
end


function IROVar.CastBar.ResetKick()
    IROVar.CastBar.StartKick=0
    IROVar.CastBar.EndKick=0
    IROVar.CastBar.CantKick=false
    IROVar.CastBar.Spell=nil
    IROVar.CastBar.SpellId=nil
end

function IROVar.CastBar.CalculateInterruptTimer(percenC)
    -- minC = dont interrupt before this time
    -- percenC = interrupt after this percent of the cast time
    -- maxC = dont interrupt after endCastTime-max time
    local maxC=0.2
    percenC=percenC or 0.6
    IROVar.CastBar.OldPercenCheck=percenC
    local startI = 0
    local endI = 0
    local notInterruptible = false
    local spell = nil
    local SpellId = nil
    if IROVar.CastBar.Casting then
        local startTime=IROVar.CastBar.Casting[4]/1000
        local endCastTime=IROVar.CastBar.Casting[5]/1000
        local castTime=endCastTime-startTime
        local castTimePercent=castTime*percenC
        startI=castTimePercent
        endI=endCastTime-maxC
        notInterruptible=IROVar.CastBar.Casting[8]
        spell=IROVar.CastBar.Casting[1]
        SpellId=IROVar.CastBar.Casting[9]
    elseif IROVar.CastBar.Channeling then
        local startTime=IROVar.CastBar.Channeling[4]/1000
        local endCastTime=IROVar.CastBar.Channeling[5]/1000
        local castTime=endCastTime-startTime
        if castTime>=1 then
            startI=startTime+0.5
            endI=endCastTime-maxC
            notInterruptible=IROVar.CastBar.Channeling[7]
            spell=IROVar.CastBar.Channeling[1]
            SpellId=IROVar.CastBar.Channeling[8]
        end
    end
    IROVar.CastBar.StartKick=startI
    IROVar.CastBar.EndKick=endI
    IROVar.CastBar.CantKick=notInterruptible
    IROVar.CastBar.Spell=spell
    IROVar.CastBar.SpellId=SpellId
end

IROVar.CastBar.CastFrame=CreateFrame("Frame")
IROVar.CastBar.CastFrame:RegisterEvent("UNIT_SPELLCAST_START")
IROVar.CastBar.CastFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
IROVar.CastBar.CastFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
IROVar.CastBar.CastFrame:SetScript("OnEvent",function(self,event,arg1,...)
    if event=="UNIT_SPELLCAST_START" and arg1=="target" then
        IROVar.CastBar.Channeling=nil
        IROVar.CastBar.CheckCasting()
        IROVar.CastBar.CalculateInterruptTimer(IROVar.CastBar.OldPercenCheck)
    elseif event=="UNIT_SPELLCAST_CHANNEL_START" and arg1=="target" then
        IROVar.CastBar.Casting=nil
        IROVar.CastBar.CheckChanneling()
        IROVar.CastBar.CalculateInterruptTimer(IROVar.CastBar.OldPercenCheck)
    elseif event=="PLAYER_TARGET_CHANGED" then
        IROVar.CastBar.CheckCasting()
        IROVar.CastBar.CheckChanneling()
        IROVar.CastBar.CalculateInterruptTimer(IROVar.CastBar.OldPercenCheck)
    end
end)

IROVar.CastBar.CastFrame2=CreateFrame("Frame")
IROVar.CastBar.CastFrame2:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
IROVar.CastBar.CastFrame2:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
IROVar.CastBar.CastFrame2:RegisterEvent("UNIT_SPELLCAST_STOP")
IROVar.CastBar.CastFrame2:SetScript("OnEvent",function(self,event,arg1,...)
    if arg1=="target" then
        IROVar.CastBar.Casting=nil
        IROVar.CastBar.Channeling=nil
        IROVar.CastBar.ResetKick()
    end
end)

function IROVar.TargetCastBar(percenCheck,DontCheckCantKick)
    --DontCheckCantKick = true mean kick even notInterruptible (for Stun)
    if IROVar.CastBar.OldPercenCheck~=percenCheck then
        IROVar.CastBar.CalculateInterruptTimer(percenCheck)
    end
    if not DontCheckCantKick then
        if IROVar.CastBar.CantKick then
            return false
        end
        local currentTime=GetTime()
        return currentTime>=IROVar.CastBar.StartKick and currentTime<=IROVar.CastBar.EndKick
    else
        local currentTime=GetTime()
        return currentTime>=IROVar.CastBar.StartKick and currentTime<=IROVar.CastBar.EndKick
    end
end
