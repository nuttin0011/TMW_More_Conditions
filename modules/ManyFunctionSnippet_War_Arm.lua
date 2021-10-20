-- Many Function Version War Arm 9.1.0/1
-- this file save many function for paste to TMW Snippet LUA


if not IROVar then IROVar={} end
IROVar.WarArm={}
IROVar.WarArm.isRend=false
IROVar.WarArm.RagePerAttack=20

IROVar.WarArm.FOnEvent=function(_,event)
    if event=="PLAYER_TALENT_UPDATE" then
        local _,TName,_,TSelected=GetTalentInfo(3,3,1)
        IROVar.WarArm.isRend = (TName=="Rend") and TSelected
    elseif event=="PLAYER_EQUIPMENT_CHANGED" then
        IROVar.WarArm.RagePerAttack = math.floor(UnitAttackSpeed("player")*(100+UnitSpellHaste("player"))/100*7)-1
    end
end
C_Timer.After(2,function()
    IROVar.WarArm.FOnEvent(nil,"PLAYER_TALENT_UPDATE")
    IROVar.WarArm.FOnEvent(nil,"PLAYER_EQUIPMENT_CHANGED")
end)

IROVar.WarArm.FEvent = CreateFrame("Frame")
IROVar.WarArm.FEvent:RegisterEvent("PLAYER_TALENT_UPDATE")
IROVar.WarArm.FEvent:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
IROVar.WarArm.FEvent:SetScript("OnEvent", IROVar.WarArm.FOnEvent)

IROVar.WarArm.PredictRageForMSOldVal=0
IROVar.WarArm.PredictRageForMSTimeStamp=0

function IROVar.WarArm.PredictRageForMS()
    local currentTime=GetTime()
    if IROVar.WarArm.PredictRageForMSTimeStamp==currentTime then return IROVar.WarArm.PredictRageForMSOldVal end
    IROVar.WarArm.PredictRageForMSTimeStamp=currentTime
    local MSCDDu=TMW.CNDT.Env.CooldownDuration("Mortal Strike")
    local st
    local rage=UnitPower("player",1)
    if MSCDDu==0 then
        IROVar.WarArm.PredictRageForMSOldVal=rage
        return rage
    else
        local SwSt= TMW.COMMON.SwingTimerMonitor.SwingTimers[16].startTime
        local SwDu= TMW.COMMON.SwingTimerMonitor.SwingTimers[16].duration
        st=currentTime+MSCDDu-0.4
        SwSt=SwSt+SwDu

        while (SwDu>0) and (st>SwSt) do
            rage=rage+IROVar.WarArm.RagePerAttack
            SwSt=SwSt+SwDu
        end
        if IROVar.WarArm.isRend then
            local RDu=TMW.CNDT.Env.AuraDur("target","rend","PLAYER HARM")
            if RDu<4 then
                rage=rage-30
            else
                if (RDu-4)<MSCDDu then
                    rage=rage-30
                end
            end
        end
        IROVar.WarArm.PredictRageForMSOldVal=rage
        return rage
    end
end
