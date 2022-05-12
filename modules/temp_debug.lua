
local function checkUnit(n)
    return UnitExists(n) and
    UnitCanAttack("player",n) and
    (UnitAffectingCombat(n) or IsItemInRange(32321,n))and --32321, -- Sparrowhawk Net 10 yard
    (not UnitIsDead(n)) and
    (IsSpellInRange("Mind Blast","target")==1)
end

local function selectUbyHP(u1,u2)
    return (u1 and (UnitHealth(u1)<=UnitHealth(u2))) and u1 or u2
end

local u=nil
--target
if checkUnit("target") then
    u="target"
end
--mouseover
if checkUnit("mouseover") then
    u=selectUbyHP(u,"mouseover")
end
--focus
if checkUnit("focus") then
    u=selectUbyHP(u,"focus")
end
local uI
--partyXtarget
for i=1,4 do
    if not UnitExists("party"..i) then break end
    uI="party"..i.."target"
    if checkUnit(uI) then
        u=selectUbyHP(u,uI)
    end
end
--raidXtarget
for i=1,13 do
    if not UnitExists("raid"..i) then break end
    uI="raid"..i.."target"
    if checkUnit(uI) then
        u=selectUbyHP(u,uI)
    end
end

local cc=IROVar.Healer.UnitToIRO[u or 1]
if cc and EROSWDIcon1.States[1].Color~=cc then
    if EROSWDIcon1 then
        EROSWDIcon1.States[1].Color=cc
    end
    if EROSWDIcon2 then
        EROSWDIcon2.States[1].Color=cc
    end
    if TMW_ST:GetCounter("swdone")==0
    then
        TMW_ST:UpdateCounter("swdone",1)
    else
        TMW_ST:UpdateCounter("swdone",0)
    end
elseif cc==nil then
    TMW_ST:UpdateCounter("swdone",3)
end




TestCDEvent = CreateFrame("Frame")
TestCDEvent:RegisterEvent("SPELL_UPDATE_COOLDOWN")
TestCDEvent:SetScript("OnEvent", function(self, event,...)
    print(GetTime(),event)
    print("...",...)
end)

TestRampageEvent = CreateFrame("Frame")
TestRampageEvent:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
TestRampageEvent:SetScript("OnEvent", function(self, event)
    if select(13,CombatLogGetCurrentEventInfo())=="Rampage" then
        print(GetTime(),"Rampage")
    end
end)


(function()
    local HavocCD=IROVar.Lock.HavocCDEnd()-GetTime()
    if HavocCD<0 then HavocCD=0 end
    local c,m,s,d=GetSpellCharges("conflagrate")
    local t=d
    if c<m then
        t=(s+d-GetTime())+d
    end
    return HavocCD>t
end)()