
if not NotifyGapSpell then
    NotifyGapSpell={}
end

local spellCasting = nil
local oldspellCasting = nil
local GapStartCheck = 0
local lassSucceeded = 0

local function sFrame_onevent(self,event,UnitToken,CastID,SpellID)
    if UnitToken~="player" then return end
    local currentTime=GetTime()
    local GCD=GCDCDTime()
    if event=="UNIT_SPELLCAST_START" then
        if currentTime-lassSucceeded<GCD then
            print("Gap =",currentTime-lassSucceeded)
        end
        oldspellCasting=spellCasting
        spellCasting=SpellID
    elseif event=="UNIT_SPELLCAST_STOP" then
        oldspellCasting=spellCasting
        spellCasting=nil
    elseif event=="UNIT_SPELLCAST_SUCCEEDED" then

        if spellCasting==nil then -- instance cast spell
            print("Gap =",currentTime-lassSucceeded)
            lassSucceeded=currentTime+GCD
        else
            lassSucceeded=GetTime()
        end
    end
end

local sFrame = CreateFrame("Frame")
sFrame:RegisterEvent("UNIT_SPELLCAST_START")
sFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
sFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
sFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
sFrame:SetScript("OnEvent", sFrame_onevent)