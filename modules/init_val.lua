local TMW = TMW
local TMW_MC = TMW_More_Conditions

--caching

local _GetTime = GetTime
local _UnitPower = UnitPower
local _UnitCastingInfo = UnitCastingInfo
local _CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local _UnitAura = UnitAura
local _UnitExists = UnitExists
local _UnitAffectingCombat = UnitAffectingCombat
local _UnitHealth = UnitHealth
local _GetSpecialization = GetSpecialization
local _GetSpecializationInfo  = GetSpecializationInfo

local CNDT = TMW.CNDT
local Env = CNDT.Env
local GetRealmName=GetRealmName
local UnitGUID=UnitGUID

local function printtable(a)
	local k,v
	for k,v in pairs(a) do
		print(k,v)
	end
    return 0        
end

IRO_Old_Val = {[1]=0,[2]={}}
-- IRO_Old_Val = {[1] = Timer , [2] = functionName = {[input_val_string] = [result_val]}}


function Env.Old_Val_Check(functionName,input_val_string)
    -- return old value if GetTime and input_val_string is the same
    -- return nil if we must re calculate.
    local currenTimer=_GetTime()
    --print("check at : "..currenTimer)
    if IRO_Old_Val[1]==currenTimer then
        if IRO_Old_Val[2][functionName] and IRO_Old_Val[2][functionName][input_val_string] then
            return IRO_Old_Val[2][functionName][input_val_string]
        end
    end

    return nil
end


function Env.Old_Val_Update(functionName,input_val_string,result_val)
    local currenTimer = GetTime()
    --print("update at : "..currenTimer)
    if IRO_Old_Val[1] < currenTimer then
        IRO_Old_Val[1] = currenTimer
        IRO_Old_Val[2] = {}
    end

    if not IRO_Old_Val[2][functionName] then 
        IRO_Old_Val[2][functionName]={} 
    end

    if not IRO_Old_Val[2][functionName][input_val_string] then 
        IRO_Old_Val[2][functionName][input_val_string]=result_val 
    end

    return true
end

if not CleanTypeZZ then
    CleanTypeZZ = {}
    CleanTypeZZ[71] = {0,0,0,0,''} -- Arm
    CleanTypeZZ[72] = {0,0,0,0,''} -- fury
    CleanTypeZZ[72] = {0,0,0,0,''} -- Protection
    CleanTypeZZ[265] = {20,0,0,0,'Singe Magic'} -- Aff
    CleanTypeZZ[266] = {20,0,0,0,'Singe Magic'} -- Demo
    CleanTypeZZ[267] = {20,0,0,0,'Singe Magic'} -- Dest
    CleanTypeZZ[262] = {0,0,0,20,'Cleanse Spirit'} -- Element
    CleanTypeZZ[263] = {0,0,0,20,'Cleanse Spirit'} -- Enha
    CleanTypeZZ[264] = {20,0,0,20,'Purify Spirit'} -- Resto
    CleanTypeZZ[259] = {0,0,0,0,''} -- Ass
    CleanTypeZZ[260] = {0,0,0,0,''} -- Out
    CleanTypeZZ[261] = {0,0,0,0,''} -- Sub
    CleanTypeZZ[256] = {20,20,0,0,'Purify'} -- Disc
    CleanTypeZZ[257] = {20,20,0,0,'Purify'} -- Holy
    CleanTypeZZ[258] = {0,20,0,0,'Purify Disease'} -- Shadow
    CleanTypeZZ[65] = {20,20,20,0,'Cleanse'} -- Holy
    CleanTypeZZ[66] = {0,20,20,0,'Cleanse Toxins'} -- Port
    CleanTypeZZ[67] = {0,20,20,0,'Cleanse Toxins'} -- Ret
    CleanTypeZZ[268] = {0,20,20,0,'Detox'} -- Brewmaster
    CleanTypeZZ[270] = {20,20,20,0,'Detox'} -- Mistweaver
    CleanTypeZZ[269] = {0,20,20,0,'Detox'} -- Windwalker
    CleanTypeZZ[62] = {0,0,0,20,'Remove Curse'} -- arcane
    CleanTypeZZ[63] = {0,0,0,20,'Remove Curse'} -- fire
    CleanTypeZZ[64] = {0,0,0,20,'Remove Curse'} -- frost
    CleanTypeZZ[253] = {0,0,0,0,''} -- Beast Mastery
    CleanTypeZZ[254] = {0,0,0,0,''} -- Marksmanship
    CleanTypeZZ[255] = {0,0,0,0,''} -- Survival
    CleanTypeZZ[102] = {0,0,20,20,'Remove Corruption'} -- Balance
    CleanTypeZZ[103] = {0,0,20,20,'Remove Corruption'} -- Feral
    CleanTypeZZ[104] = {0,0,20,20,'Remove Corruption'} -- Guardian
    CleanTypeZZ[105] = {20,0,20,20,"Nature's Cure"} -- Restoration
    CleanTypeZZ[577] = {0,0,0,0,''} -- Havoc
    CleanTypeZZ[581] = {0,0,0,0,''} -- Vengeance
    CleanTypeZZ[250] = {0,0,0,0,''} -- Blood
    CleanTypeZZ[251] = {0,0,0,0,''} -- frost
    CleanTypeZZ[252] = {0,0,0,0,''} -- unholy
end

function Env.GetMyCleanType()

    local currentSpec = _GetSpecialization()
    local IROSpecID  = _GetSpecializationInfo(currentSpec)
    -- return Magic,Disease,Poison,Curse penalty  
    if not currentSpec then
        return 0,0,0,0
    end
    local M,D,P,C,SpellName
    --print("Your current spec:", currentSpecName,Specid)
    if CleanTypeZZ[IROSpecID] then
        M=CleanTypeZZ[IROSpecID][1]
        D=CleanTypeZZ[IROSpecID][2]
        P=CleanTypeZZ[IROSpecID][3]
        C=CleanTypeZZ[IROSpecID][4]
        SpellName=CleanTypeZZ[IROSpecID][5]
    else
        M=0
        D=0
        P=0
        C=0
        SpellName=''
    end
    return M,D,P,C,SpellName
end

function Env.CheckDebuffAuraType(unit)
    -- return Magic, Disease, Poison, Curse (ture/false)
    local DMagic = false
    local DDisease = false
    local DPoison = false
    local DCurse = false
    local i
    
    local buffName,debuffType
    for i = 1, 40 do
        buffName, _, _, debuffType= _UnitAura(unit, i, "HARMFUL")
        if not buffName then break end
        if debuffType=="Magic" then DMagic = true end
        if debuffType=="Disease"then DDisease = true end
        if debuffType=="Poison" then DPoison = true end
        if debuffType=="Curse" then DCurse = true end
    end
    
    return  DMagic, DDisease, DPoison, DCurse
end

function Env.SumHPMobinCombat()

    local Old_Val = Env.Old_Val_Check("SumHPMobinCombat","")
    if Old_Val then return Old_Val end
    
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if _UnitExists(nn) and _UnitAffectingCombat(nn) then
            sumhp=sumhp+ _UnitHealth(nn)
        end
    end

    Env.Old_Val_Update("SumHPMobinCombat","",sumhp)

    return sumhp
end

--********************** OLD FUNCTION **************************


function TMW.CNDT.Env.IROEnemyCount()
    -- return Enemy Count in 8 yd Max 5
    if GetTime() == oldtimeIROEnemyCount then
        return oldIROEnemyCount
    end
    oldtimeIROEnemyCount = GetTime()
    local i,nn,count
    count=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and IsItemInRange("item:34368", nn) then
            count=count+1
        end
        if count>=5 then break end
    end
    oldIROEnemyCount=count
    return  count
end

function TMW.CNDT.Env.GroupHPPercent()
    if GroupHPPercentTimer == GetTime() then
        return GroupHPPercentOldVar
    end
    local i,nn,sumHP,sumHPMax
    if IsInRaid() then
        sumHP=0
        sumHPMax=0
        for i=1,40 do
            nn="raid"..i
            if UnitExists(nn)and(not UnitIsDead(nn))and UnitInRange(nn) then
                sumHP=sumHP+UnitHealth(nn)
                sumHPMax=sumHPMax+UnitHealthMax(nn)
    end end else
        sumHP=UnitHealth("player")
        sumHPMax=UnitHealthMax("player")
        for i=1,4 do
            nn="party"..i
            if UnitExists(nn)and(not UnitIsDead(nn))and UnitInRange(nn) then
                sumHP=sumHP+UnitHealth(nn)
                sumHPMax=sumHPMax+UnitHealthMax(nn)
    end end end
    GroupHPPercentTimer = GetTime()
    GroupHPPercentOldVar = (sumHP/sumHPMax)*100
    return GroupHPPercentOldVar
end

function TMW.CNDT.Env.GroupHPPercent()
    if GroupHPPercentTimer == GetTime() then
        return GroupHPPercentOldVar
    end
    local i,nn,sumHP,sumHPMax
    if IsInRaid() then
        sumHP=0
        sumHPMax=0
        for i=1,40 do
            nn="raid"..i
            if UnitExists(nn)and(not UnitIsDead(nn))and UnitInRange(nn) then
                sumHP=sumHP+UnitHealth(nn)
                sumHPMax=sumHPMax+UnitHealthMax(nn)
    end end else
        sumHP=UnitHealth("player")
        sumHPMax=UnitHealthMax("player")
        for i=1,4 do
            nn="party"..i
            if UnitExists(nn)and(not UnitIsDead(nn))and UnitInRange(nn) then
                sumHP=sumHP+UnitHealth(nn)
                sumHPMax=sumHPMax+UnitHealthMax(nn)
    end end end
    GroupHPPercentTimer = GetTime()
    GroupHPPercentOldVar = (sumHP/sumHPMax)*100
    return GroupHPPercentOldVar
end

function TMW.CNDT.Env.SumHPMobin8yd()
    local sumhp =0
    local ii,nn
    for ii =1,30 do
        nn='nameplate'..ii
        if UnitExists(nn) and IsItemInRange("item:34368", nn) then
            sumhp=sumhp+ UnitHealth(nn)
        end
    end
    return sumhp
end

function TMW.CNDT.Env.PercentCastbar(PercentCast, MustInterruptAble, MaxTMS, MinTMS)
    
    PercentCast = PercentCast or 0.6
    if MustInterruptAble == nil then MustInterruptAble = true end
    MaxTMS = MaxTMS or 2000
    MinTMS = MinTMS or 800
    
    local castingName, _, _, startTimeMS, endTimeMS, _, _, notInterruptible= UnitCastingInfo("target")
    
    local wantInterrupt = false
    
    if (castingName ~= nil) and(not(notInterruptible and MustInterruptAble)) then
        local totalcastTime = endTimeMS-startTimeMS
        local currentcastTime = (GetTime()*1000)-startTimeMS       
        
        if (totalcastTime-currentcastTime)>MaxTMS then
            -- if cast time > MaxTMS ms dont interrupt
            wantInterrupt = false
        elseif (totalcastTime-currentcastTime)<MinTMS then 
            -- if cast time < MinTMS ms dont interrupt
            wantInterrupt = true
        else
            local percentcastTime = currentcastTime/totalcastTime
            wantInterrupt = percentcastTime >= PercentCast
        end
        return  wantInterrupt
    end
    
    
    local channelName, _, _, CstartTimeMS, CendTimeMS,_, CnotInterruptible= UnitChannelInfo("target") 
    
    if (channelName ~= nil) and (not (CnotInterruptible and MustInterruptAble)) then
        PercentCast = 1-PercentCast
        local totalcastTime = CendTimeMS-CstartTimeMS
        local currentcastTime = (GetTime()*1000)-CstartTimeMS 
        
        if (currentcastTime>=MinTMS) and (currentcastTime<=totalcastTime-MinTMS) then
            -- dont interrupt when cast < MinTMS and nerly finish
            local percentcastTime = currentcastTime/totalcastTime
            wantInterrupt = percentcastTime >= PercentCast
        end
        
        
    end 
    
    return  wantInterrupt
end

--[[  this function already exists at "conset1.lua"
function TMW.CNDT.Env.allBuffByMe(unit)
    -- return table of [buff name] = buff time remaining
    
    local buffName,expTime,i
    local allBuff={}
    for i=1,40 do
        buffName,_,_,_,_,expTime = UnitAura(unit, i, "PLAYER|HELPFUL")
        if buffName then 
            allBuff[buffName]=expTime-GetTime()
        else break  end
    end
    
    return allBuff
end
--]]



-- THIS Function for Shaman Heal 8.3!!!!!
function TMW.CNDT.Env.CheckBuffMustHaveByMe(unit)
    -- return %HP modify if condition met.
    
    local buffMustHave = {}
    local i
    local HPMod = 0
    
    -- assign buff must have
    -- buffMustHave[n]={"buffName",minCDRemain,HPmod,["Roles assigned"]}
    
    buffMustHave[1] = {"Ancestral Vigor",3,10,"TANK"}
    
    -- get all buff by me
    local allBuff = TMW.CNDT.Env.allBuffByMe(unit)
    
    for i in pairs(buffMustHave) do
        
        if (not allBuff[buffMustHave[i][1]]) or (allBuff[buffMustHave[i][1]]<buffMustHave[i][2]) then
            -- notHave Buff/Have Buff but CD < MinCDRemain
            if (buffMustHave[i][4]~=nil) then 
                -- Have UnitGroupRolesAssigned condition
                if (UnitGroupRolesAssigned(unit)==buffMustHave[i][4]) then 
                    if (HPMod<buffMustHave[i][3]) then
                        HPMod=buffMustHave[i][3]
                    end
                end               
            else
                -- not Have UnitGroupRolesAssigned condition
                if (HPMod<buffMustHave[i][3]) then
                    HPMod=buffMustHave[i][3]
                end
            end
        end
    end
    
    
    return HPMod
end

function TMW.CNDT.Env.predictHPremain(unit,DMagic,DDisease,DPoison,DCurse)
    -- return percent HP remain
    -- =currentHP + Shield + IncommingHeal/2
    -- -HealAbsorb + ifHP>80%constant
    -- -WantCleanConstant (Magic,Disease,Poison,Curse)
    local M,D,P,C = TMW.CNDT.Env.CheckDebuffAuraType(unit)
    
    DMagic = (DMagic or 0)*(M and 1 or 0)
    -- check Unit Has MagicDEBUFF? and if has use as penalty %HP
    DDisease = (DDisease or 0)*(D and 1 or 0)
    DPoison = (DPoison or 0)*(P and 1 or 0)
    DCurse = (DCurse or 0)*(C and 1 or 0)
    
    local uMHP= UnitHealthMax(unit)/100
    
    -- if unit not exists return 50000
    if uMHP==0 then return 50000 end
    
    local iCH = (UnitGetIncomingHeals(unit)or 0) /(uMHP*2)
    local abs = UnitGetTotalAbsorbs(unit)/uMHP
    local Habs= UnitGetTotalHealAbsorbs(unit)/uMHP
    local uHP = UnitHealth(unit)/uMHP
    local HPMod=0 --TMW.CNDT.Env.CheckBuffMustHaveByMe(unit)
    
    -- debuff penaltry chose only Max one
    local DBP = math.max(DMagic,DDisease,DPoison,DCurse)
    
    uHP=uHP+abs
    
    if uHP>60 then uHP=uHP+20 end -- HP > 60% less chance to chose
    if uHP>80 then uHP=uHP+20 end -- if HP > 80% more less chance
    
    -- Tank -1%hp for 1st pick
    if UnitGroupRolesAssigned(unit) =="TANK" then
        return (uHP+iCH-Habs-DBP-HPMod)-1
    else
        return (uHP+iCH-Habs-DBP-HPMod)
    end
    
end

function TMW.CNDT.Env.NumberPPLNeedBuff(buffNeed,PLowHP)
    
    -- Return number of Player HP < PLowHP
    
    function percentHP(unit)
        return UnitHealth(unit)/UnitHealthMax(unit)*100
    end
    
    function hasbuff(unit,ibuff)
        local i
        local buffName
        local ihasbuff=false
        
        for i=1,40 do
            buffName=UnitAura(unit, i, "PLAYER|HELPFUL")
            if buffName then 
                if buffName==ibuff then 
                    ihasbuff=true                    
                    break
                end
            else 
                break  
            end
        end
        return ihasbuff
    end
    
    
    local i,NN
    local ppl=0
    local pplparty=0
    local pplraid=0
    if (percentHP("player")<PLowHP)and(not hasbuff("player",buffNeed)) then 
        ppl=ppl+1 
    end
    
    
    for i =1,4 do
        NN ="party"..i
        if (UnitExists(NN)and(not UnitIsDead(NN))and UnitInRange(NN))then
            if (percentHP(NN)<PLowHP)and(not hasbuff(NN,buffNeed))then
                pplparty=pplparty+1
            end    
            
        end   
    end
    
    for i =1,40 do
        NN ="raid"..i
        if (UnitExists(NN)and(not UnitIsDead(NN))and UnitInRange(NN)) then
            if (percentHP(NN)<PLowHP)and(not hasbuff(NN,buffNeed))then 
                pplraid=pplraid+1
            end             
        end       
    end   
    --print(ppl)
    
    if (pplraid==0) then 
        -- in party
        return (ppl+pplparty)
    else 
        -- in raid
        return pplraid
    end
    
end

function TMW.CNDT.Env.NumberPPLLowHP(PLowHP)
    
    PLowHP = PLowHP or 80 -- if PLowHP = 0 or nil then PLowHP = 80
    -- Return number of Player HP < PLowHP
    -- PLowHP is number 0..100
    
    function percentHP(unit)
        return UnitHealth(unit)/UnitHealthMax(unit)*100
    end
    
    --1=solo,2=party,3=raid
    local groupType = ((IsInRaid() and 3) or (IsInGroup() and 2) or 1)
    
    local i,NN
    local ppl=0
    
    
    
    if groupType<=2 then
        if percentHP("player")<PLowHP then ppl=ppl+1 end
        
        if groupType==2 then
            for i =1,4 do
                NN ="party"..i
                if (UnitExists(NN)and(not UnitIsDead(NN))and UnitInRange(NN)) then
                    if percentHP(NN)<PLowHP then ppl=ppl+1 end
                end   
            end
        end
        
    else --groupType==3
        for i =1,40 do
            NN ="raid"..i
            if (UnitExists(NN)and(not UnitIsDead(NN))and UnitInRange(NN)) then
                if percentHP(NN)<PLowHP then ppl=ppl+1 end             
            end
            if ppl>=5 then break end
        end
    end
    
    return ppl
    
end






























