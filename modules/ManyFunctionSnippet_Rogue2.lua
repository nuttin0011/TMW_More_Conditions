-- Many Function Rogue2 9.2.5/9
-- Set Priority to 10
-- Use Many Function Aura Tracker

--counter
--"enemycountviii" = IROEnemyCountInRange(8)
--"comboblank"
--"comboblankwithbuff"
--"rtbstatus" -- 0 = dont RTB, 1 = do RTB
--"kirstatus" Keep RTB -- 0 = dont keep , 1 do keep
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

local Aura_Track_list1={
    "Broadside",
    "True Bearing",
    "Ruthless Precision",
    "Skull and Crossbones",
    "Buried Treasure",
    "Grand Melee",
    "Shadow Blades",
    "Loaded Dice",
}
IROVar.Aura1.RegisterTrackedAura(Aura_Track_list1)

if not IROVar then IROVar={} end
if not IROVar.Rogue2 then IROVar.Rogue2={} end

IROVar.Rogue2.MyAura={} -- Remove later
IROVar.Rogue2.RTBCount=0  -- Remove later
IROVar.Rogue2.ComboMax=UnitPowerMax("player", 4)
IROVar.Rogue2.ComboPoint=UnitPower("player", 4)

IROVar.Rogue2.BuffBroadside=false
IROVar.Rogue2.BuffShadowBlades=false

function IROVar.Rogue2.AuraCheck()
    local BuffBroadside=IROVar.Aura1.My["Broadside"]
    local BuffShadowBlades=IROVar.Aura1.My["Shadow Blades"]
    if (IROVar.Rogue2.BuffBroadside~=BuffBroadside) or (IROVar.Rogue2.BuffShadowBlades~=BuffShadowBlades) then
        IROVar.Rogue2.BuffBroadside=BuffBroadside
        IROVar.Rogue2.BuffShadowBlades=BuffShadowBlades
        IROVar.Rogue2.CheckCPStatusCounter()
    end
end


IROVar.Rogue2.CounterName={}
IROVar.Rogue2.CounterName.CP="comboblank"
IROVar.Rogue2.CounterName.CPcBuff="comboblankwithbuff"

IROVar.Rogue2.CounterName.RTBstatus="rtbstatus" -- 0 = dont RTB, 1 = do RTB
IROVar.Rogue2.CounterName.KiRstatus="kirstatus" -- 0 = dont Keep, 1 = do Keep

function IROVar.Rogue2.CheckCPStatusCounter()
    local cpBlank=IROVar.Rogue2.ComboMax-IROVar.Rogue2.ComboPoint --CP max = 0
    IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CP,cpBlank)
    local cpBlankWithBuff=cpBlank-((IROVar.Rogue2.BuffBroadside or IROVar.Rogue2.BuffShadowBlades) and 1 or 0)
    IROVar.UpdateCounter(IROVar.Rogue2.CounterName.CPcBuff,cpBlankWithBuff)
end

--Enemy Count 8yard
IROVar.CV.EC8Tick=0.8
local function EC8()
    local nn
    local c=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player",nn) then
            c=c+(IsItemInRange("item:34368",nn) and 1 or 0)
        end
        if c>=6 then break end
    end
    IROVar.UpdateCounter("enemycountviii",c)
end
IROVar.CV.EC8H=C_Timer.NewTicker(IROVar.CV.EC8Tick,function()
    if TMW.time-IUSC.SkillPressStampTime>=IROVar.CV.EC8Tick then
        EC8()
    end
end)
IUSC.RegCallBackAfterSU["EC8"]=EC8

---NEW RTB

IROVar.Rogue2.RTBBuffName={
    ["Broadside"]=true,
    ["True Bearing"]=true,
    ["Ruthless Precision"]=true,
    ["Skull and Crossbones"]=true,
    ["Buried Treasure"]=true,
    ["Grand Melee"]=true,
}

function IROVar.Rogue2.RTBBuffCount()
    local count = 0
    for k,_ in pairs(IROVar.Rogue2.RTBBuffName) do
        if IROVar.Aura1.My[k] then count = count+1 end
    end
    return count
end

if next(TMW.CNDT.Env.TalentMap)==nil then -- use function TMW to update player talents,
    TMW.CNDT:PLAYER_TALENT_UPDATE()
    IROVar.Register_TALENT_CHANGE_scrip_CALLBACK("TMW.CNDT.Env.TalentMap",function() TMW.CNDT:PLAYER_TALENT_UPDATE() end)
    -- talent's data in TMW.CNDT.Env.TalentMap
    -- use lower case Ex TMW.CNDT.Env.TalentMap["carnivorous instinct"]
end

--IROVar.Rogue2.CounterName.KiRstatus
function IROVar.Rogue2.RTBStatusCounter()
    --talent [Hidden Opportunity]
    --TMW.CNDT.Env.TalentMap["hidden opportunity"]>0
    local status = 0
    local KiRStatus = 0
    local RTBCount = IROVar.Rogue2.RTBBuffCount()
    if RTBCount>=3 then
        KiRStatus=1
        status=0
    elseif RTBCount==2 then
        if IROVar.Aura1.My["Loaded Dice"] then
            if (not IROVar.Aura1.My["Broadside"]) and
            (not IROVar.Aura1.My["Skull and Crossbones"]) and
            (not IROVar.Aura1.My["True Bearing"]) then
                status=1
            end
        elseif TMW.CNDT.Env.TalentMap["hidden opportunity"]>0 then
            if IROVar.Aura1.My["Grand Melee"] and (not IROVar.Aura1.My["Skull and Crossbones"]) then
                status=1
            else
                status=0
            end
        elseif IROVar.Aura1.My["Grand Melee"] and IROVar.Aura1.My["Buried Treasure"] then
            status=1
        end

        if (IROVar.Aura1.My["Broadside"]) or
        (IROVar.Aura1.My["Skull and Crossbones"]) or
        (IROVar.Aura1.My["True Bearing"]) then
            KiRStatus=1
        end
    elseif RTBCount==1 then
        if IROVar.Aura1.My["Loaded Dice"] then
            status=1
        elseif TMW.CNDT.Env.TalentMap["hidden opportunity"]>0 then
            if IROVar.Aura1.My["Skull and Crossbones"] then
                status=0
            else
                status=1
            end
        elseif (IROVar.Aura1.My["Broadside"] or IROVar.Aura1.My["True Bearing"] or IROVar.Aura1.My["Skull and Crossbones"]) then
            status=0
        else
            status=1
        end
    else
        status=1
    end

    IROVar.UpdateCounter(IROVar.Rogue2.CounterName.RTBstatus,status)
    IROVar.UpdateCounter(IROVar.Rogue2.CounterName.KiRstatus,KiRStatus)
    IROVar.Rogue2.RTBCount=RTBCount  -- Remove later
end


IROVar.Aura.Register_UNIT_AURA_scrip_CALLBACK("IROVar.Rogue2",function(unit)
    if unit=="player" then
        IROVar.Rogue2.AuraCheck()
        IROVar.Rogue2.RTBStatusCounter()
        IROVar.Rogue2.MyAura=IROVar.Aura1.My  -- Remove later
    end
end)
IROVar.Rogue2.AuraCheck()
IROVar.Rogue2.RTBStatusCounter()

---END NEW RTB


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

local playerGUID=UnitGUID("player")

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
    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Rogue SBS",IROVar.Rogue2.CombatLogSBS)


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
    if IROVar.Rogue2.BuffBroadside then comboGen=comboGen+1 end
    if IROVar.Rogue2.BuffShadowBlades then comboGen=comboGen+1 end
    if comboBlank>=4 then
        return true
    else
        return comboGen<=comboBlank
    end
end


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