-- this is LUA Snipped in TMW

if not NotifyGapSpell then
    NotifyGapSpell={}
end

local spellCasting = 0
local spellchannel = 0
local lassSucceeded = 0
local spellSent = 0
local lastSucceededIsPredictGCD=false
local GCD=1.5*(100/(100+UnitSpellHaste("player")))

local function PrintGap(s)
    local currentTime=GetTime()
    local diffTime=currentTime-lassSucceeded
    local sN=GetSpellInfo(s)
    if lastSucceededIsPredictGCD then
        --if diffTime<0.001 then diffTime=0 end
        diffTime=diffTime.." (predict GCD)"
    end
    print(sN,"Gap =",diffTime)
end

local function sFrame_onevent(self,event,arg1,arg2,arg3,arg4)
    if arg1~="player" then return end
    local currentTime=GetTime()
    if (event=="UNIT_SPELL_HASTE") then
        GCD=1.5*(100/(100+UnitSpellHaste("player")))
    elseif (event=="UNIT_SPELLCAST_START")then
        if spellSent==arg3 then
            spellSent=0
            spellCasting=arg3
            PrintGap(arg3)
        end
    elseif event=="UNIT_SPELLCAST_STOP" then
        if spellCasting==arg3 then
            spellCasting=0
        end
    elseif event=="UNIT_SPELLCAST_SUCCEEDED" then
        if spellSent==arg3 then
            spellSent=0
            PrintGap(arg3)
            lassSucceeded=currentTime+GCD
            lastSucceededIsPredictGCD=true
        end
        if spellchannel==arg3 then
            --lassSucceeded=currentTime
            --lastSucceededIsPredictGCD=false
        end
        if spellCasting==arg3 then
            lassSucceeded=currentTime
            lastSucceededIsPredictGCD=false
        end
    elseif event=="UNIT_SPELLCAST_SENT" then -- arg4 = spell
        spellSent=arg4
        if spellchannel~=0 then
            print("interrupt Channeling")
        end
        if spellCasting~=0 then
            print("sent cast in casting")
        end
    elseif event=="PLAYER_REGEN_DISABLED" then
        spellCasting = 0
        spellchannel = 0
        lassSucceeded = 0
        spellSent = 0
        lastSucceededIsPredictGCD=false
        GCD=1.5*(100/(100+UnitSpellHaste("player")))
    elseif event=="UNIT_SPELLCAST_CHANNEL_START" then
        if spellSent==arg3 then
            if spellchannel~=arg3 then
                PrintGap(arg3)
            end
            spellSent=0
            spellchannel=arg3
        end
    elseif event=="UNIT_SPELLCAST_CHANNEL_STOP" then
        if spellchannel==arg3 then
            lassSucceeded=currentTime
            lastSucceededIsPredictGCD=false
            spellchannel=0
        end
    elseif event=="UNIT_SPELLCAST_CHANNEL_UPDATE" then
        if spellSent==arg then
            spellSent=0
        end
    elseif event=="UNIT_SPELLCAST_FAILED_QUIET" then
        spellSent=0
    end
end

local sFrame = CreateFrame("Frame")
sFrame:RegisterEvent("UNIT_SPELLCAST_START")
sFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
sFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
sFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
sFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
sFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
sFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
sFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
sFrame:RegisterEvent("UNIT_SPELL_HASTE")
sFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
sFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")

sFrame:SetScript("OnEvent", sFrame_onevent)