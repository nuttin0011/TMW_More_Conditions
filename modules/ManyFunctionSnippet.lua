
-- Many Function Version 9.0.2/6
-- this file save many function for paste to TMW Snippet LUA

--function IROEnemyCountIn8yd(Rlevel) ; return count
--function IROEnemyCountInRange(nRange) ; return count, nRange = yard e.g. 2 5 8 15 20 30 40 50 200
--function PercentCastbar(PercentCast, MustInterruptAble,unit, MinTMS,MaxTMS); return true/false
--function GCDActiveLessThan(ttime) ; return true/false
--function SumHPMobinCombat() ; return SumHP
--function SumHPMobin8yd() ; return SumHP
--function IROTargetVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<targetHealth
--function IROEnemyGroupVVHP(nMultipy) ; return (nMultipy*playerHealth*nG)<EnemyGroupHP

local ItemRangeCheck = {
    [1]=34368, -- Attuned Crystal Cores 8 yard
    [2]=33069, -- Sturdy Rope 15 yard
    [3]=10645, -- Gnomish Death Ray 20 yard
    [4]=835, -- Large Rope Net 30 yard
    [5]=28767, -- The Decapitator 40 yard
    [6]=32321, -- Sparrowhawk Net 10 yard
}
local ItemNameToCheck8 = "item:"..ItemRangeCheck[1]
function IROEnemyCountIn8yd(Rlevel)
    --return enemy count in Range Default 8 yard Max 8
    Rlevel = Rlevel or 0
    --Rlevel 0=8,1=15,2=20,3=30,4=40,5=10 yard
    local ItemNameToCheck = "item:"..ItemRangeCheck[Rlevel+1]
    local nn,count
    local count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player", nn) then
            if IsItemInRange(ItemNameToCheck8, nn)or(UnitAffectingCombat(nn)and IsItemInRange(ItemNameToCheck, nn)) then
                count=count+1
            end
        end
        if count>=8 then break end
    end
    return  count
end

local ItemRangeCheck2 = {
    [2] =37727, -- Ruby Acorn
    [3] =42732, -- Everfrost Razor
    [4] =129055, -- Shoe Shine Kit
    [5] =8149, -- Voodoo Charm
    [7] =61323, -- Ruby Seeds
    [8] =34368, -- Attuned Crystal Cores
    [10] =32321, -- Sparrowhawk Net
    [15] =33069, -- Sturdy Rope
    [20] =10645, -- Gnomish Death Ray
    [25] =24268, -- Netherweave Net
    [30] =835, -- Large Rope Net
    [35] =24269, -- Heavy Netherweave Net
    [38] =140786, -- Ley Spider Eggs
    [40] =28767, -- The Decapitator
    [45] =23836, -- Goblin Rocket Launcher
    [50] =116139, -- Haunting Memento
    [55] =74637, -- Kiryn's Poison Vial
    [60] =32825, -- Soul Cannon
    [70] =41265, -- Eyesore Blaster
    [80] =35278, -- Reinforced Net
    [90] =133925, -- Fel Lash
    [100] =33119, -- Malister's Frost Wand
    [150] =46954, -- Flaming Spears
    [200] =75208, -- Rancher's Lariat
}

old_IROEnemyCountInRange_check={}
for k,v in pairs(ItemRangeCheck2) do
	old_IROEnemyCountInRange_check[k]={}
end
--format old_IROEnemyCountInRange_check[yard][1] = time
--       old_IROEnemyCountInRange_check[yard][2] = count
function IROEnemyCountInRange(nRange)
	nRange = nRange or 8
	if nRange<2 then nRange=2 end
	while(ItemRangeCheck2[nRange]==nil)do
		nRange=nRange-1
	end
	
	local currentTime=GetTime()
	
	if old_IROEnemyCountInRange_check[nRange][1]==currentTime then
		return old_IROEnemyCountInRange_check[nRange][2]
	end
	
    local ItemNameToCheck = "item:"..ItemRangeCheck2[nRange]
    local nn,count
    local count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player", nn) then
            if IsItemInRange(ItemNameToCheck, nn) then
                count=count+1
            end
        end
        if count>=8 then break end
    end

	old_IROEnemyCountInRange_check[nRange][1]=currentTime
	old_IROEnemyCountInRange_check[nRange][2]=count		
	
    return count
end

function PercentCastbar(PercentCast, MustInterruptAble,unit, MinTMS,MaxTMS)
    
    PercentCast = PercentCast or 0.6
    if MustInterruptAble == nil then MustInterruptAble = true end
    MaxTMS = MaxTMS or 2000
    MinTMS = MinTMS or 800
	unit = unit or "target"
    
    local castingName, _, _, startTimeMS, endTimeMS, _, _, notInterruptible= UnitCastingInfo(unit)
    
    local wantInterrupt = false
	local totalcastTime
    local currentcastTime
	local percentcastTime
	
    if (castingName ~= nil) and(not(notInterruptible and MustInterruptAble)) then
        totalcastTime = endTimeMS-startTimeMS
        currentcastTime = (GetTime()*1000)-startTimeMS       
        
        if (totalcastTime-currentcastTime)>MaxTMS then
            -- if cast time > MaxTMS ms dont interrupt
            wantInterrupt = false
        elseif (totalcastTime-currentcastTime)<MinTMS then 
            -- if cast time < MinTMS ms dont interrupt
            wantInterrupt = true
        else
            percentcastTime = currentcastTime/totalcastTime
            wantInterrupt = percentcastTime >= PercentCast
        end
        return  wantInterrupt
    end
    
    local channelName, _, _, CstartTimeMS, CendTimeMS,_, CnotInterruptible= UnitChannelInfo(unit) 
    
    if (channelName ~= nil) and (not (CnotInterruptible and MustInterruptAble)) then
        PercentCast = 1-PercentCast
        totalcastTime = CendTimeMS-CstartTimeMS
        currentcastTime = (GetTime()*1000)-CstartTimeMS 
        
        if (currentcastTime>=MinTMS) and (currentcastTime<=(totalcastTime-MinTMS)) then
			wantInterrupt = true
        end
        
        
    end 
    
    return  wantInterrupt
end

function GCDActiveLessThan(ttime)
    ttime = ttime or 0.2
    local s,d = GetSpellCooldown(TMW.GCDSpell)
    return ((s+d)-GetTime())<ttime
end

function SumHPMobinCombat()
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and UnitAffectingCombat(nn) and UnitCanAttack("player", nn) then
            sumhp=sumhp+ UnitHealth(nn)
        end
    end
    return sumhp
end

function SumHPMobin8yd()
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and CheckInteractDistance(nn,2) and UnitCanAttack("player", nn) then
            sumhp=sumhp+ UnitHealth(nn)
    end end
    return sumhp
end

function IROTargetVVHP(nMultipy)
    nMultipy=nMultipy or 2
    local nG=GetNumGroupMembers()
    local playerHealth=UnitHealth("player")
    local targetHealth=UnitHealthMax("target")
    nG=(nG==0) and 1 or nG
    return (nMultipy*playerHealth*nG)<targetHealth
end

function IROEnemyGroupVVHP(nMultipy)
    nMultipy=nMultipy or 3
    local nG=GetNumGroupMembers()
    local playerHealth=UnitHealth("player")
    local EnemyGroupHP=SumHPMobinCombat()
    nG=(nG==0) and 1 or nG
    return (nMultipy*playerHealth*nG)<EnemyGroupHP
end


