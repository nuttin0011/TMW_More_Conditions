--local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(unit)


(function()

local _,_,_,_,endTimeMS=UnitCastingInfo("player")
endTimeMS=endTimeMS or 0
endTimeMS=endTimeMS/1000
local CastOverRS=(endTimeMS+0.2)>IROVar.DruidBalance.RSend
local CanCastSS=IsUsableSpell("Starsurge")

return CastOverRS and CanCastSS

end)()



(function() -- timer Rattles Star >0.3 < 1.5 GCD
    local a=IROVar.Aura1.GetAura("Rattled Stars")
    if not a then return false end
    local e=a-GetTime()
    if (e<0.3) or (e>IROVar.CastTime2sec)  then return false end
    return true
end)()



(function() -- for Astral Communion || Rattles Star > GCD+0.2 < 2 GCD
    local a=IROVar.Aura1.GetAura("Rattled Stars")
    if not a then return false end
    local e=a-GetTime()
    if (e<(IROVar.CastTime1_5sec+0.2)) or (e>(IROVar.HasteFactor*3))  then return false end
    return true
end)()


(function() -- return AP use in starfall
    local s=IROVar.Aura1.GetAuraStack("Rattled Stars") or 0
    local aUse=50-math.floor(s*2.5)
    local ap=TMW_ST:GetCounter("lunarpower")
    return ap>=aUse
end)()

(function() -- return AP use in starsurge
    local s=IROVar.Aura1.GetAuraStack("Rattled Stars") or 0
    local aUse=40-(s*2)
    local ap=TMW_ST:GetCounter("lunarpower")
    return ap>=aUse
end)()


(function() -- return AP use in starfall + apAdd
    local s=IROVar.Aura1.GetAuraStack("Rattled Stars") or 0
    local aUse=50-math.floor(s*2.5)
    local ap=TMW_ST:GetCounter("lunarpower")
    local apAdd=IROVar.DruidBalance.PredictAPadd()
    return ap+apAdd>=aUse
end)()

(function() -- return AP use in starsurge + apAdd
    local s=IROVar.Aura1.GetAuraStack("Rattled Stars") or 0
    local aUse=40-(s*2)
    local ap=TMW_ST:GetCounter("lunarpower")
    local apAdd=IROVar.DruidBalance.PredictAPadd()
    return ap+apAdd>=aUse
end)()

local APOverFlow=TMW_ST:GetCounter("lunarpower")+IROVar.DruidBalance.PredictAPadd()>=95


function TMW.CNDT.Env.IRODPSversion()
    
    print('GeRO DPS Druid Balance/Guardian/Cat/Heal 10.0.2/4')
    
    return  true
end

--ENEMY DEBUFF
local aa="HARMFUL PLAYER"
local a={
    ["Moonfire"]="moonfire",
    ["Sunfire"]="sunfire",
    ["Stellar Flare"]="stellarflare",
    ["Fungal Growth"]="fungalgrowth"
}

for k,v in pairs(a) do
    IROVar.CV.Register_Target_Aura_Duration(k,v,aa)
end

--PLAYER BUFF
local b={
    ["Rattled Stars"]="rattledstars",
    ["Eclipse (Solar)"]="eclipsesolar",
    ["Eclipse (Lunar)"]="eclipselunar",
}
for k,v in pairs(b) do
    IROVar.CV.Register_Player_Aura_Duration(k,v)
end
IROVar.CV.Register_Player_Aura_Not_Has("Rattled Stars","nothasrattledstars")

--PLAYER RESOURCE
IROVar.CV.Register_Player_Power(8,"lunarpower")




(function()
    local ap=TMW_ST:GetCounter("lunarpower")
    local apAdd=IROVar.DruidBalance.PredictAPadd()
    return ap+apAdd>=70
end)()




(function() --this spell cast end > rattled end
    local rEnd=IROVar.Aura1.GetAura("Rattled Stars")
    if not rEnd then return false end
    return IUSC.NextReady>(rEnd-0.2)
end)()



