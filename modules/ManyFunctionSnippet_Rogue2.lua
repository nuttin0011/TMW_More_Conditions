-- Many Function Rogue2 9.2.5/4

--var IROVar.Rogue2.RTBCount=0
--function IROVar.Rogue2.RTBBuffCount()
--[[
    IROVar.Rogue2.RTBBuffStatus={
    ["Broadside"]=false,
    ["True Bearing"]=false,
    ["Ruthless Precision"]=false,
    ["Skull and Crossbones"]=false,
    ["Buried Treasure"]=false,
    ["Grand Melee"]=false,
    }
]]
--IROVar.Rogue2.ComboMax=UnitPowerMax("player", 4)
--IROVar.Rogue2.ComboPoint=UnitPower("player", 4)
--IROVar.Rogue2.SBSCount=0

--function IROVar.Rogue2.Register_NPC_Name_Check(SetName,ArrayNPCName)
    --[[
        ArrayNPCName={ "name1","name2","name3"=,..
    ]]
--function IROVar.Rogue2.Register_NPC_ID_Check(SetName,ArrayNPCID)
    --[[
        ArrayNPCID={ ID1,ID2,ID3,....
    ]]
--function IROVar.Rogue2.IsTargetNPCNameSet(SetName)
--function IROVar.Rogue2.IsTargetNPCIDSet(SetName)
--IROVar.Rogue2.TargetName=UnitName("target")
--IROVar.Rogue2.TargetNPCID=TargetNPCID()

if not IROVar then IROVar={} end
if not IROVar.Rogue2 then IROVar.Rogue2={} end

IROVar.Rogue2.BuffBroadside=false
IROVar.Rogue2.BuffShadowBlades=false
function IROVar.Rogue2.AuraCheck()
    local name
    local BuffBroadside=false
    local BuffShadowBlades=false
    for i=1,40 do
        name=UnitAura("player",i)
        if not name then break end
        if name =="Broadside" then BuffBroadside=true end
        if name =="Shadow Blades" then BuffShadowBlades=true end
    end
    IROVar.Rogue2.BuffBroadside=BuffBroadside
    IROVar.Rogue2.BuffShadowBlades=BuffShadowBlades
end
IROVar.Rogue2.AuraCheck()
IROVar.Rogue2.UNIT_AURA_Frame=CreateFrame("Frame")
IROVar.Rogue2.UNIT_AURA_Frame:RegisterEvent("UNIT_AURA")
IROVar.RogueCP.UNIT_AURA_Frame:SetScript("OnEvent",function(self,event,arg1, arg2)
    if arg1~="player" then return end
    if event=="UNIT_AURA" then
        IROVar.Rogue2.AuraCheck()
    end
end)

IROVar.Rogue2.CounterName={}
IROVar.Rogue2.CounterName.CP="cpstatus"
IROVar.Rogue2.CounterName.CPcBuff1="cpcbuffi"
IROVar.Rogue2.CounterName.CPcBuff2="cpcbuffii"
-- 10 = MaxCP , 9 = MaxCP-1 , 8 = MaxCP-2 ..... 0 = CP 0
function IROVar.Rogue2.CheckCPStatusCounter()
    local cp=IROVar.Rogue2.ComboPoint-IROVar.Rogue2.ComboMax --CP max = 0

    if IROVar.Rogue2.ComboPoint==0 then
        IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CP,0)
    else
        IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CP,10+cp)
    end

    if cp<0 or (cp<-1 and (IROVar.Rogue2.BuffBroadside or IROVar.Rogue2.BuffShadowBlades)) then
        IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CPcBuff1,1)
    else
        IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CPcBuff1,0)
    end

    if cp<-1 or (cp<-2 and (IROVar.Rogue2.BuffBroadside or IROVar.Rogue2.BuffShadowBlades)) then
        IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CPcBuff2,1)
    else
        IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CPcBuff2,0)
    end
end



IROVar.Rogue2.MyAura={}


IROVar.Rogue2.RTBBuffName={
    ["Broadside"]=true,
    ["True Bearing"]=true,
    ["Ruthless Precision"]=true,
    ["Skull and Crossbones"]=true,
    ["Buried Treasure"]=true,
    ["Grand Melee"]=true,
}

IROVar.Rogue2.RTBBuff={
    ["Broadside"]=0,
    ["True Bearing"]=0,
    ["Ruthless Precision"]=0,
    ["Skull and Crossbones"]=0,
    ["Buried Treasure"]=0,
    ["Grand Melee"]=0,
}
--[[
    IROVar.Rogue2.RTBBuff={
        ["Broadside"]=expire_time,
        ["True Bearing"]=expire_time,
        ["Ruthless Precision"]=expire_time,
        ["Skull and Crossbones"]=expire_time,
        ["Buried Treasure"]=expire_time,
        ["Grand Melee"]=expire_time,
    }
]]
IROVar.Rogue2.RTBBuffStatus={
    ["Broadside"]=false,
    ["True Bearing"]=false,
    ["Ruthless Precision"]=false,
    ["Skull and Crossbones"]=false,
    ["Buried Treasure"]=false,
    ["Grand Melee"]=false,
}

IROVar.Rogue2.playerGUID=UnitGUID("player")
local playerGUID=IROVar.Rogue2.playerGUID
IROVar.Rogue2.CheckRTBHandle=C_Timer.NewTimer(1,function() end)
IROVar.Rogue2.RTBCount=0

function IROVar.Rogue2.RTBBuffCount()
    local now = GetTime()
    local count = 0
    for k,v in pairs(IROVar.Rogue2.RTBBuffName) do
        if IROVar.Rogue2.RTBBuff[k]>now then count = count+1 end
    end
    return count
end

--function IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK(name,callBack)
    -- note callBack is Function(...) ; ... = CombatLogGetCurrentEventInfo()

function IROVar.Rogue2.CombatLog(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
    destGUID, destName, destFlags, destRaidFlags = ...
    if sourceGUID~=playerGUID then return end
    if subevent=="SPELL_AURA_APPLIED" then
        --local spellId, spellName, spellSchool, amount, overkill, school, resisted,
        --blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
        local spellId,spellName=select(12,...)
        if IROVar.Rogue2.RTBBuffName[spellName] then
            IROVar.Rogue2.CheckRTBBuff()
        end
        if destGUID==playerGUID then
            IROVar.Rogue2.MyAura[spellId]=true
            IROVar.Rogue2.MyAura[spellName]=true
        end
    elseif subevent=="SPELL_AURA_REFRESH" then
        if IROVar.Rogue2.RTBBuffName[select(13,...)] then
            IROVar.Rogue2.CheckRTBBuff()
        end
    elseif subevent=="SPELL_AURA_REMOVED" then
        if destGUID==playerGUID then
            local spellId,spellName=select(12,...)
            IROVar.Rogue2.MyAura[spellId]=false
            IROVar.Rogue2.MyAura[spellName]=false
        end
    end
end

function IROVar.Rogue2.CheckMyAura()
    IROVar.Rogue2.MyAura={}
    for i=1,40 do
        local name,_,_,_,_,_,_,_,_,_,spellId=UnitAura("player",i,"PLAYER")
        if not name then break end
        IROVar.Rogue2.MyAura[name]=true
        IROVar.Rogue2.MyAura[spellId]=true
    end
end

IROVar.RegisterIncombatCallBackRun("Rogue Check Aura",IROVar.Rogue2.CheckMyAura)
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Rogue RTB",IROVar.Rogue2.CombatLog)

function IROVar.Rogue2.CheckRTBBuff()
    local now = GetTime()
    local count = 0
    local nearExp=50000
    local exp=0
    for k,v in pairs(IROVar.Rogue2.RTBBuffStatus) do
        IROVar.Rogue2.RTBBuffStatus[k]=false
    end

    for i=1,40 do
        local name, _, _, _, _, exTime=UnitBuff("player",i,"PLAYER")
        if not name then
            break
        else
            --exTime=exTime-1
            --if IROVar.Rogue2.RTBBuffName[name] and (exTime>GetTime()) then
            exp=exTime-now
            if IROVar.Rogue2.RTBBuffName[name] and (exp>0.1) then
                IROVar.Rogue2.RTBBuff[name]=exTime
                IROVar.Rogue2.RTBBuffStatus[name]=true
                count=count+1
                exTime=exTime-now
                if exp<nearExp then
                    nearExp=exp
                end
            end
        end
    end
    IROVar.Rogue2.RTBCount=count
    IROVar.Rogue2.CheckRTBHandle:Cancel()
    IROVar.Rogue2.CheckRTBHandle=C_Timer.NewTimer(nearExp,IROVar.Rogue2.CheckRTBBuff)
end


--Serrated Bone Spike
IROVar.Rogue2.SBSCount=0
IROVar.Rogue2.SBSMob={}

--[[
    IROVar.Rogue2.SBSMob={
        ["GUID"]=true,
    }
]]
IROVar.Rogue2.SBSMobHandle={}
--[[
    IROVar.Rogue2.SBSMobHandle={
        ["GUID"]=C_Timer.NewTimer(3,function() cancel self end),
    }
]]
IROVar.Rogue2.ShadowBladeBuff=TMW.CNDT.Env.AuraDur("player", "shadow blades", "PLAYER HELPFUL")>0.5

function IROVar.Rogue2.CombatLogSBS(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
    destGUID, destName, destFlags, destRaidFlags,spellID,spellName = ...
    if sourceGUID~=playerGUID then return end
    --print("GUID OK")
    if spellName=="Serrated Bone Spike" then
        if subevent=="SPELL_DAMAGE" or subevent=="SPELL_PERIODIC_DAMAGE" then
            if not IROVar.Rogue2.SBSMob[destGUID] then
                IROVar.Rogue2.SBSCount=IROVar.Rogue2.SBSCount+1
                IROVar.Rogue2.SBSMob[destGUID]=true
            end
            if IROVar.Rogue2.SBSMobHandle[destGUID] then IROVar.Rogue2.SBSMobHandle[destGUID]:Cancel() end
            IROVar.Rogue2.SBSMobHandle[destGUID]=C_Timer.NewTimer(3,function()
                IROVar.Rogue2.SBSMob[destGUID]=nil
                IROVar.Rogue2.SBSCount=IROVar.Rogue2.SBSCount-1
                IROVar.Rogue2.SBSMobHandle[destGUID]=nil
            end)
        end
    elseif subevent=="UNIT_DIED" then
        if IROVar.Rogue2.SBSMob[destGUID] then
            if IROVar.Rogue2.SBSMobHandle[destGUID] then IROVar.Rogue2.SBSMobHandle[destGUID]:Cancel() end
            IROVar.Rogue2.SBSMob[destGUID]=nil
            IROVar.Rogue2.SBSCount=IROVar.Rogue2.SBSCount-1
            IROVar.Rogue2.SBSMobHandle[destGUID]=nil
        end
    elseif spellName=="Shadow Blades"then
        if subevent=="SPELL_AURA_APPLIED" or subevent=="SPELL_AURA_REFRESH" then
            IROVar.Rogue2.ShadowBladeBuff=true
        elseif subevent=="SPELL_AURA_REMOVED" then
            IROVar.Rogue2.ShadowBladeBuff=false
        end
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Rogue SBS",IROVar.Rogue2.CombatLogSBS)


IROVar.Rogue2.ComboMax=UnitPowerMax("player", 4)
IROVar.Rogue2.ComboPoint=UnitPower("player", 4)
IROVar.Rogue2.CheckCPStatusCounter()

IROVar.Rogue2.ComboMaxUpdateFrame=CreateFrame("Frame")
IROVar.Rogue2.ComboMaxUpdateFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
IROVar.Rogue2.ComboMaxUpdateFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
IROVar.Rogue2.ComboMaxUpdateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
IROVar.Rogue2.ComboMaxUpdateFrame:SetScript("OnEvent",function()
    C_Timer.After(1,function() IROVar.Rogue2.ComboMax=UnitPowerMax("player", 4) end)
end)
IROVar.Rogue2.ComboUpdateFrame=CreateFrame("Frame")
IROVar.Rogue2.ComboUpdateFrame:RegisterEvent("UNIT_POWER_FREQUENT")
IROVar.Rogue2.ComboUpdateFrame:SetScript("OnEvent",function(self,event,unit,powerType)
    if unit=="player" and powerType=="COMBO_POINTS" then
        IROVar.Rogue2.ComboPoint=UnitPower("player", 4)
        IROVar.Rogue2.CheckCPStatusCounter()
    end
end)


function IROVar.Rogue2.ShouldUseSBS()
    local comboCurrent=IROVar.Rogue2.ComboPoint
    local comboBlank=IROVar.Rogue2.ComboMax-comboCurrent
    if comboBlank==0 then return false end
    local comboGen=1+IROVar.Rogue2.SBSCount
    if IROVar.Rogue2.RTBBuffStatus["Broadside"] then comboGen=comboGen+1 end
    if IROVar.Rogue2.ShadowBladeBuff then comboGen=comboGen+1 end
    if comboBlank>=4 then
        return true
    else
        return comboGen<=comboBlank
    end
end

--[[(function()
    local comboCurrent=UnitPower("player", 4)
    local comboBlank=UnitPowerMax("player", 4)-comboCurrent
    if comboBlank==0 then return false end
    local comboGen=1
    for i=1,30 do
        local n="nameplate"..i
        if UnitExists(n) and UnitCanAttack("player", n) and (TMW.CNDT.Env.AuraDur(n, "serrated bone spike", "PLAYER HARMFUL")>0) then
            comboGen=comboGen+1
        end
    end
    if TMW.CNDT.Env.AuraDur("player", "broadside", "PLAYER HELPFUL")>0.5 then comboGen=comboGen+1 end
    if TMW.CNDT.Env.AuraDur("player", "shadow blades", "PLAYER HELPFUL")>0.5 then comboGen=comboGen+1 end
    
    if comboBlank>=4 then
        return true
    else
        return comboGen<=comboBlank
    end
end)()]]


IROVar.Rogue2.ArrayNPCName={}
--[[
    {["Set1 Name"]={
        ["NPC Name1"]=true,
        ["NPC Name2"]=true,
        ["NPC Name3"]=true,...
    },["Set2 Name"]={...},...}
]]
IROVar.Rogue2.ArrayNPCNameChecked={}
--[[
    {["Set1 Name"]=true,
    ,["Set2 Name"]=true,...
]]
IROVar.Rogue2.ArrayNPCID={}
IROVar.Rogue2.ArrayNPCIDChecked={}

local function TargetNPCID()
    return tonumber((UnitGUID("target") or ""):match(".-%-%d+%-%d+%-%d+%-%d+%-(%d+)"))
end

local function CheckNPC()
    IROVar.Rogue2.TargetName=UnitName("target")
    IROVar.Rogue2.TargetNPCID=TargetNPCID()
    for k,v in pairs(IROVar.Rogue2.ArrayNPCName) do
        if v[IROVar.Rogue2.TargetName] then
            IROVar.Rogue2.ArrayNPCNameChecked[k]=true
        else
            IROVar.Rogue2.ArrayNPCNameChecked[k]=false
        end
    end
    for k,v in pairs(IROVar.Rogue2.ArrayNPCID) do
        if v[IROVar.Rogue2.TargetNPCID] then
            IROVar.Rogue2.ArrayNPCIDChecked[k]=true
        else
            IROVar.Rogue2.ArrayNPCIDChecked[k]=false
        end
    end
end


C_Timer.After(3,CheckNPC)

IROVar.Register_PLAYER_TARGET_CHANGED_scrip_CALLBACK("Rogue_Target_Name_NPCID",function()
    CheckNPC()
end)

function IROVar.Rogue2.Register_NPC_Name_Check(SetName,ArrayNPCName)
    --[[
        ArrayNPCName={ "name1","name2","name3"=,..
    ]]
    local array={}
    for _,v in pairs(ArrayNPCName) do
        array[v]=true
    end
    IROVar.Rogue2.ArrayNPCName[SetName]=array
end

function IROVar.Rogue2.Register_NPC_ID_Check(SetName,ArrayNPCID)
    --[[
        ArrayNPCID={ ID1,ID2,ID3,....
    ]]
    local array={}
    for _,v in pairs(ArrayNPCID) do
        array[v]=true
    end
    IROVar.Rogue2.ArrayNPCID[SetName]=array
end

function IROVar.Rogue2.IsTargetNPCNameSet(SetName)
    return IROVar.Rogue2.ArrayNPCNameChecked[SetName]
end

function IROVar.Rogue2.IsTargetNPCIDSet(SetName)
    return IROVar.Rogue2.ArrayNPCIDChecked[SetName]
end