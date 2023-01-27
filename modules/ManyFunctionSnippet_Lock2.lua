-- Many Function Version Warlock2 10.0.0/5
-- Set Priority to 10
-- this file save many function for paste to TMW Snippet LUA

-- counter "pausedps" pause DPS for Drain Soul/Drain Life ; 0=DPS normaly, 1=Pause DPS
--function IROVar.Lock.ChannelPluseDPS()

--function IROVar.Lock.SoulLeechPercen()

--function IROVar.Lock.PredictSS() -- return SSFragment
-- counter "predssf" = Predict SS fragment in Des
-- counter "predss" = Predict SS in Demo , Aff
-- counter "ssfragment" == UnitPower("player",7,true) -- !!!not finish
-- counter "ss" == UnitPower("player",7)
-- counter "dcore" == Demonic Core Duration
-- counter "dcorestack" == Demonic Core Stack
-- counter "dcall" == Demonic Calling Duration
-- counter "spellhitaoe" tell n mob hit by spell in timeInterval
-- counter "burningrush" Burning Rush

if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end

IROVar.CV.Register_Player_Aura_Duration("Demonic Core","dcore")
IROVar.CV.Register_Player_Aura_Duration("Demonic Calling","dcall")
IROVar.CV.Register_Player_Aura_Has("Burning Rush","burningrush")
IROVar.CV.Register_Player_Aura_Arg("Demonic Core","dcorestack",3)
IROVar.SpellHitAOE.Register_Spell_Hit_AOE_Check("Hand of Gul'dan",8)
IROVar.SpellHitAOE.Register_Spell_Aura_AOE_Check("From the Shadows",8)
IROVar.SpellHitAOE.Register_Spell_FromMyPet_Hit_AOE_Check("Legion Strike",8)
IROVar.SpellHitAOE.Register_Spell_FromMyPet_Hit_AOE_Check("Felstorm",8)


IROVar.Lock.PSS={}
IROVar.Lock.PSS[265]={ -- aff
    [324536]=-1, --Malefic Rapture
}
IROVar.Lock.PSS[266]={ -- demo
    [686]=1, --shadow bolt
    [104316]=-2, --[Call Dreadstalkers]
    [265187]=5, --[Summon Demonic Tyrant]
    [264178]=2, --[Demonbolt]
    [105174]=-3, --[Hand of Gul'dan]
}
IROVar.Lock.PSS[267]={ -- des !!!!!!!!!!!!!! not finish Yet
}
IROVar.Lock.PSS.CastID=nil
IROVar.Lock.PSS.SS=UnitPower("player",7)
IROVar.Lock.PSS.SSf=UnitPower("player",7,true)
--[[
UNIT_SPELLCAST_START
    arg1 UnitToken
    arg2 CastID
    arg3 SpellID

UNIT_SPELLCAST_STOP
    arg1 UnitToken
    arg2 CastID
    arg3 SpellID

UNIT_SPELLCAST_FAILED_QUIET
]]
function IROVar.Lock.PSS.UpdatePSS()
    local ss=IROVar.Lock.PSS.SS
    local pSS=ss+(IROVar.Lock.PSS[IROSpecID][IROVar.Lock.PSS.CastID] or 0)
    pSS=(pSS>5) and 5 or pSS
    pSS=(pSS<0) and 0 or pSS
    IROVar.UpdateCounter("predss",pSS)
end

IROVar.CV.Register_Player_Power(7,"ss",function(p)
    local SSf=UnitPower("player",7,true)
    IROVar.UpdateCounter("predssf",SSf)
    IROVar.Lock.PSS.SS=p
    IROVar.Lock.PSS.SSf=SSf
    IROVar.Lock.PSS.UpdatePSS()
end)

local function PSS_UNIT_SPELLCAST_START(event,UnitToken,CastID,SpellID)
    if UnitToken=="player" then
        IROVar.Lock.PSS.CastID=SpellID
        IROVar.Lock.PSS.UpdatePSS()
    end
end
local function PSS_UNIT_SPELLCAST_STOP(event,UnitToken,CastID,SpellID)
    if UnitToken=="player" and IROVar.Lock.PSS.CastID==SpellID then
        IROVar.Lock.PSS.CastID=nil
        IROVar.Lock.PSS.UpdatePSS()
    end
end
TMW_ST:AddEvent("UNIT_SPELLCAST_START",PSS_UNIT_SPELLCAST_START)
TMW_ST:AddEvent("UNIT_SPELLCAST_STOP",PSS_UNIT_SPELLCAST_STOP)
TMW_ST:AddEvent("UNIT_SPELLCAST_FAILED_QUIET",PSS_UNIT_SPELLCAST_STOP)
IROVar.RegisterOutcombatCallBackRun("Lock.PSS",function()
    IROVar.Lock.PSS.CastID=nil
end)

TMW_ST:AddEvent("UNIT_SPELLCAST_START",
function(event,unit)
    if unit~="player" then return end
    IROVar.Lock.UpdateSoulLeech()
end)

-- Counter Pause DPS for Drain Soul/ Drain Life
--[[
UNIT_SPELLCAST_CHANNEL_START "player" nil spellID
UNIT_SPELLCAST_CHANNEL_STOP
198590 Drain Soul
234153 Drain Life
]]

IROVar.Lock.ChannelStep={0,0,0,0,0,0,0,GetTime()+1000000}
IROVar.Lock.ChannelHandle=nil

local function StepChannel(n,c)
    IROVar.UpdateCounter("pausedps",c)
    if n==8 then
        IROVar.Lock.ChannelHandle=nil
        return
    end
    do
        local cT=GetTime()
        local nextTick=IROVar.Lock.ChannelStep[n+1]-cT
        if nextTick<=0 then
            StepChannel(n+1,math.abs(c-1))
        else
            IROVar.Lock.ChannelHandle=C_Timer.NewTimer(nextTick,function()
                StepChannel(n+1,math.abs(c-1))
            end)
        end
    end
end

TMW_ST:AddEvent("UNIT_SPELLCAST_CHANNEL_START",
function(EventName,unit,arg3,spellID)
    if unit~="player" then return end
    if spellID~=198590 and spellID~=234153 then return end
    local _,_,_,startTime,endTime,_,_,spellId = UnitChannelInfo("player")
    startTime=startTime/1000
    endTime=endTime/1000
    local du=endTime-startTime-0.2
    local tick=du/5
    local _5=IROVar.CastTime0_5sec
    IROVar.Lock.ChannelStep[1]=startTime+tick+tick
    IROVar.Lock.ChannelStep[2]=IROVar.Lock.ChannelStep[1]+_5
    IROVar.Lock.ChannelStep[3]=IROVar.Lock.ChannelStep[1]+tick
    IROVar.Lock.ChannelStep[4]=IROVar.Lock.ChannelStep[3]+_5
    IROVar.Lock.ChannelStep[5]=IROVar.Lock.ChannelStep[3]+tick
    IROVar.Lock.ChannelStep[6]=IROVar.Lock.ChannelStep[5]+_5
    IROVar.Lock.ChannelStep[7]=IROVar.Lock.ChannelStep[5]+tick
    IROVar.Lock.ChannelStep[8]=endTime+100
    if du<IROVar.CastTime2sec*2 then--[Nightfall]
        --print("[Nightfall]")
        IROVar.Lock.ChannelStep[1]=IROVar.Lock.ChannelStep[7]
        IROVar.Lock.ChannelStep[2]=IROVar.Lock.ChannelStep[7]
        IROVar.Lock.ChannelStep[3]=IROVar.Lock.ChannelStep[7]
        IROVar.Lock.ChannelStep[4]=IROVar.Lock.ChannelStep[7]
        IROVar.Lock.ChannelStep[5]=IROVar.Lock.ChannelStep[7]
        IROVar.Lock.ChannelStep[6]=IROVar.Lock.ChannelStep[7]
    end
    StepChannel(0,1)
end)
TMW_ST:AddEvent("UNIT_SPELLCAST_CHANNEL_STOP",
function()
    IROVar.UpdateCounter("pausedps",0)
    if IROVar.Lock.ChannelHandle and not IROVar.Lock.ChannelHandle:IsCancelled() then
        IROVar.Lock.ChannelHandle:Cancel()
        IROVar.Lock.ChannelHandle=nil
    end
    IROVar.Lock.ChannelStep={0,0,0,0,0,0,0,GetTime()+1000000}
end)
-- Channeling
-- start time st , pause
-- duration du-0.2
-- n tick = n*(du-0.2)/5
-- [1] 2nd tick , DPS
-- [2] 2nd tick + IROVar.CastTime0_5sec , pause
-- [3] 3rd tick , DPS
-- [4] 3nd tick + IROVar.CastTime0_5sec , pause
-- [5] 4th tick , DPS
-- [6] 4th tick + IROVar.CastTime0_5sec , pause
-- [7] 5th tick , DPS

function IROVar.Lock.ChannelPluseDPS() -- false = dont DPS
    local cTime=GetTime()
    local dps=false
    for i=1,7 do
        if cTime<IROVar.Lock.ChannelStep[i] then break end
        dps=not dps
    end
    return dps
end

IROVar.Lock.soulLeechPercen=0

function IROVar.Lock.UpdateSoulLeech()
    local SoulLeech=select(16,AuraUtil.FindAuraByName("Soul Leech","player","HELPFUL PLAYER")) or 0
    IROVar.Lock.soulLeechPercen=SoulLeech/UnitHealthMax("player")*100
end

C_Timer.After(2,IROVar.Lock.UpdateSoulLeech)

TMW_ST:AddEvent("UNIT_AURA",
function(event,unit)
    if unit~="player" then return end
    IROVar.Lock.UpdateSoulLeech()
end)

function IROVar.Lock.SoulLeechPercen()
    return IROVar.Lock.soulLeechPercen
end

