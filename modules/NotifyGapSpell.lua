-- this is LUA Snipped in TMW

if not NotifyGapSpell then
    NotifyGapSpell={}
end

local spellCasting = 0
local lassSucceeded = 0
local spellSent = 0
local lastSucceededIsPredictGCD=false
local function sFrame_onevent(self,event,arg1,arg2,arg3,arg4)
    if arg1~="player" then return end
    local currentTime=GetTime()
    local GCD=1.5*(100/(100+UnitSpellHaste("player")))
    if (event=="UNIT_SPELLCAST_START") and (spellSent==arg3) then
        spellCasting=arg3
        if currentTime-lassSucceeded<GCD then
            local diffTime=currentTime-lassSucceeded
            if lastSucceededIsPredictGCD then
                if diffTime<0.001 then diffTime=0 end
                diffTime=diffTime.." (predict GCD)"
            end
            print("Gap =",diffTime)
        end
    elseif event=="UNIT_SPELLCAST_STOP" then
        if arg3==spellCasting then
            spellCasting=0
        end
    elseif event=="UNIT_SPELLCAST_SUCCEEDED" then
        if (spellCasting==0) and (spellSent==arg3) then -- instance cast spell
            spellSent=0
            local diffTime=currentTime-lassSucceeded
            if lastSucceededIsPredictGCD then
                if diffTime<0.001 then diffTime=0 end
                diffTime=diffTime.." (predict GCD)"
            end
            print("Gap =",diffTime)
            lassSucceeded=currentTime+GCD
            lastSucceededIsPredictGCD=true
        elseif spellCasting==arg3 then
            spellSent=0
            spellCasting=0
            lassSucceeded=GetTime()
            lastSucceededIsPredictGCD=false
        end
    elseif event=="UNIT_SPELLCAST_SENT" then
        if spellCasting==0 then
            spellSent=arg4
        end
    elseif event=="PLAYER_REGEN_DISABLED" then
        spellCasting = 0
        lassSucceeded = 0
        lastSucceededIsPredictGCD=false
    end
end

local sFrame = CreateFrame("Frame")
sFrame:RegisterEvent("UNIT_SPELLCAST_START")
sFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
sFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
sFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
sFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
sFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

sFrame:SetScript("OnEvent", sFrame_onevent)