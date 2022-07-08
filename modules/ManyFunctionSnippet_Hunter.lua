-- Many Function Version Hunter 9.2.5/6d
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Hun.TBreakDPSForBS() ; return Break Time for Shoot Barbed shot
--function IROVar.Hun.BreakDPSForBS() ; return True/false
--var IROVar.Hun.AimedShotActive ; true = cast Aimed Shoot + after success 0.4 GCD sec
--var IROVar.Hun.CSCountAfterKC ; Cobra Shot Count After Kill Command
--var IROVar.Hun.MD.nameMacro="~!Num0" ; name Macro for MD to tank set to [nomod] num0

if not IROVar then IROVar={} end
if not IROVar.Hun then IROVar.Hun={} end

IROVar.Hun.AimedShotActive=false
IROVar.Hun.BarbedFullCD=select(4,GetSpellCharges("barbed shot"))
IROVar.Hun.MD={}
IROVar.Hun.MD.EditingMacro=false
IROVar.Hun.MD.TankName="pet"
IROVar.Hun.MD.nameMacro="~!Num0"

local function CDend(s)
	local st,du=GetSpellCooldown(s)
	if st then
		return st+du
	else return 0 end
end

IROVar.Hun.TotHBuffEnd=0 --Thrill of the Hunt buff end time
IROVar.Hun.BarbedCDEnd=CDend("barbed shot") --Barbed shot CD end time
IROVar.Hun.CSCountAfterKC=0

function IROVar.Hun.CombatLog_OnEvent(...)
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = ...
    if sourceGUID~=IROVar.playerGUID then return end
    if IROSpecID==254 then -- MM
        if (subevent=="SPELL_CAST_START") and (spellName=="Aimed Shot") then
            IROVar.Hun.AimedShotActive=true
        end
        if (subevent=="SPELL_CAST_SUCCESS") and (spellName=="Aimed Shot") then
            C_Timer.After(GCDCDTime()*.4,function() IROVar.Hun.AimedShotActive=false end)
        end
        if (subevent=="SPELL_CAST_FAILED") and (spellName=="Aimed Shot") then
            IROVar.Hun.AimedShotActive=false
        end
    end
    if IROSpecID==253 then -- BM
        if spellID==257946 then --Thrill of the Hunt
            if subevent=="SPELL_AURA_APPLIED" then
                IROVar.Hun.TotHBuffEnd=GetTime()+8
            elseif subevent=="SPELL_AURA_APPLIED_DOSE" then
                IROVar.Hun.TotHBuffEnd=GetTime()+8
            elseif subevent=="SPELL_AURA_REFRESH" then
                IROVar.Hun.TotHBuffEnd=GetTime()+8
            elseif subevent=="SPELL_AURA_REMOVED" then
                IROVar.Hun.TotHBuffEnd=0
            end
        elseif subevent=="SPELL_CAST_SUCCESS" then
            if spellName=="Kill Command" then
                IROVar.Hun.CSCountAfterKC=0
            elseif spellName=="Cobra Shot" then
                IROVar.Hun.CSCountAfterKC=IROVar.Hun.CSCountAfterKC+1
            end
        end

    end
end
IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("Hun",IROVar.Hun.CombatLog_OnEvent)

IROVar.RegisterOutcombatCallBackRun("Hun",function(self, event)
    if event=="PLAYER_REGEN_ENABLED" then IROVar.Hun.AimedShotActive=false end
end)

IROVar.Register_SPELL_UPDATE_COOLDOWN_scrip_CALLBACK("Hun",function(GCDCDEnd)
    local CDEnd=CDend("barbed shot")
    if CDEnd<=GCDCDEnd then CDEnd=0 end
    IROVar.Hun.BarbedCDEnd=CDEnd
end)

IROVar.Hun.cdBDPS={}
function IROVar.Hun.TBreakDPSForBS()
    local h=IROVar.Haste
    if IROVar.Hun.cdBDPS[h] then return IROVar.Hun.cdBDPS[h] end
    IROVar.Hun.cdBDPS[h]=IROVar.CastTime1_5sec+IROVar.Hun.GetTimeVeryEndBS()
    return IROVar.Hun.cdBDPS[h]
end

function IROVar.Hun.GetTotHDur()
    if IROVar.Hun.TotHBuffEnd==0 then return 0 end
    local t=IROVar.Hun.TotHBuffEnd-GetTime()
    if t<0 then t=0 end
    return t
end

function IROVar.Hun.GetBarbedCDRemain()
    if IROVar.Hun.BarbedCDEnd==0 then return 0 end
    local t=IROVar.Hun.BarbedCDEnd-GetTime()
    if t<0 then t=0 end
    return t
end

function IROVar.Hun.BreakDPSForBS()
    local d=IROVar.Hun.GetTotHDur()
    local g=IROVar.Hun.TBreakDPSForBS()
    local b=IROVar.Hun.GetBarbedCDRemain()
    return (d<=g)and(b<=d)
end


IROVar.Hun.fhaste = CreateFrame("Frame")
IROVar.Hun.fhaste:RegisterEvent("UNIT_SPELL_HASTE")
IROVar.Hun.fhaste:RegisterEvent("PLAYER_REGEN_DISABLED")
IROVar.Hun.fhaste:SetScript("OnEvent", function(self,event,unittoken)
    if event=="PLAYER_REGEN_DISABLED" or
    (event=="UNIT_SPELL_HASTE" and unittoken=="player") then
        IROVar.Hun.BarbedFullCD=select(4,GetSpellCharges("barbed shot"))
    end
end)

IROVar.Hun.ShootBSInTimeOld={}

function IROVar.Hun.GetTimeVeryEndBS()
    local H=IROVar.Hun.BarbedFullCD
    local H2=IROVar.Hun.ShootBSInTimeOld[H]
    if not H2 then
        H2=(H<9.5) and 1.1 or ((H>10.3) and .6 or (((10.3-H)*.625)+.6))
        IROVar.Hun.ShootBSInTimeOld[H]=H2
    end
    return H2
end

function IROVar.Hun.ShootBSInTime()
    if IROVar.Hun.GetBarbedCDRemain()>0.3 then return false end
    local TotHDu=IROVar.Hun.GetTotHDur()
    if TotHDu<0.2 then return false end
    return TotHDu<=IROVar.Hun.GetTimeVeryEndBS()
end

function IROVar.Hun.GetTankPosition()
    if IsInRaid() then
        for i=1,40 do
            local n="raid"..i
            if UnitExists(n) and UnitGroupRolesAssigned(n)=="TANK" and IsSpellInRange("Misdirection",n) then
                return n
            end
        end
    elseif IsInGroup() then
        for i=1,4 do
            local n="party"..i
            if UnitExists(n) and UnitGroupRolesAssigned(n)=="TANK" and IsSpellInRange("Misdirection",n) then
                return n
            end
        end
    end
    return "pet"
end

function IROVar.Hun.CheckMDTankName()
    local macroName=IROVar.Hun.MD.nameMacro
    local macroBody=GetMacroBody(macroName)
    if macroBody==nil then return "pet" end
    local tankName=string.sub(macroBody,string.find(macroBody,"nomod,@")+7,string.find(macroBody,",exists,nodead,help")-1)
    return tankName
end

function IROVar.Hun.SetMDMacro()
    local macroName=IROVar.Hun.MD.nameMacro
    if InCombatLockdown() then
        IROVar.Hun.MD.EditingMacro=false
        return
    end
    --[[
        GROUP_ROSTER_UPDATE
        /cast bla bla bla;
        /cast [@focus,nomod,exists,help,nodead][nomod,@pet,exists,nodead,help]Misdirection
    ]]
    local TankName=IROVar.Hun.GetTankPosition()
    --if IROVar.Hun.MD.TankName==TankName then
    IROVar.Hun.MD.TankName=IROVar.Hun.CheckMDTankName()
    if IROVar.Hun.MD.TankName==TankName then
        IROVar.Hun.MD.EditingMacro=false
        return
    end
    local text1="nomod,@"
    local text2=",exists,nodead,help]Misdirection"
    local _,macroIcon,macrobody=GetMacroInfo(macroName)
    local pointEdit=string.find(macrobody,text1)
    local NewMacroBody
    if pointEdit then
        NewMacroBody=string.sub(macrobody,1,pointEdit-1)..text1..TankName..text2
    else
    end
    if NewMacroBody~=macrobody then
        EditMacro(macroName,macroName,macroIcon,NewMacroBody)
    end
    IROVar.Hun.MD.TankName=TankName
    --[[do
        --DEBUG!!
        local MB=GetMacroBody(macroName) or ""
        print(MB==NewMacroBody and "/////Edit Macro susccess" or "/////Edit Macro FAIL!!!!!!!!!")
        if MB~=NewMacroBody then
            TempMB=MB
            Tempmacrobody=NewMacroBody
        end
        print("Tank : ",TankName,UnitName(TankName))
        print("Macro Name : ",IROVar.Hun.CheckMDTankName())
    end]]
    IROVar.Hun.MD.EditingMacro=false
end


IROVar.Hun.MD.EventFrame=CreateFrame("Frame")
IROVar.Hun.MD.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
IROVar.Hun.MD.EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
function IROVar.Hun.MD.EventCallBack()
    if InCombatLockdown() then
        C_Timer.After(1,IROVar.Hun.MD.EventCallBack)
    elseif IROVar.Hun.MD.nameMacro then
        --print("ROSTER_UPDATE")
        if not IROVar.Hun.MD.EditingMacro then
            --print("not EditingMacro")
            IROVar.Hun.MD.EditingMacro=true
            C_Timer.After(0.2,IROVar.Hun.SetMDMacro)
        end
    end
end

IROVar.Hun.MD.EventFrame:SetScript("OnEvent",IROVar.Hun.MD.EventCallBack)

C_Timer.NewTicker(6,IROVar.Hun.MD.EventCallBack,20)
