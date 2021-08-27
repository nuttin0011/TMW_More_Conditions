-- Many Function Version Priest 9.1.0/1
-- var IROVar.Priest.GUIDVT ; Check not cast same GUID target
-- 	use /run IROVar.Priest.GUIDVT=UnitGUID("target") after use macro cast VT
-- 	use /run IROVar.Priest.GUIDSpell=UnitGUID("target") after use macro cast spell
-- IROVar.Priest.UnitMSCount ; unit count that MS hit

if not IROVar then IROVar={} end
if not IROVar.Priest then IROVar.Priest={} end

IROVar.Priest.GUIDVT=nil
IROVar.Priest.GUIDVT_Old=nil
IROVar.Priest.GUIDSpell=nil
IROVar.Priest.GUIDSpell_Old=nil

IROVar.Priest.UnitMSCount=0
IROVar.Priest.UnitMSCountTimer=0

function IROVar.Priest.GUIDVT_OnEvent(self,Event,Unit,CastID,SpellID)
	if (Unit ~= "player") then return end -- if not player return
	if (SpellID == 34914) -- VT
	-- .... VT Should Shadow by default??
	then
		if Event == "UNIT_SPELLCAST_START" then
			IROVar.Priest.GUIDVT_Old=IROVar.Priest.GUIDVT
		elseif Event == "UNIT_SPELLCAST_STOP" then
			if IROVar.Priest.GUIDVT_Old==IROVar.Priest.GUIDVT then
				IROVar.Priest.GUIDVT=nil
			end
		end
	end
	-- other spell included VT
	if Event == "UNIT_SPELLCAST_START" then
		IROVar.Priest.GUIDSpell_Old=IROVar.Priest.GUIDSpell
	elseif Event == "UNIT_SPELLCAST_STOP" then
		if IROVar.Priest.GUIDSpell_Old==IROVar.Priest.GUIDSpell then
			IROVar.Priest.GUIDSpell=nil
		end
	end
end
IROVar.Priest.GUIDVT_Frame = CreateFrame("Frame")
IROVar.Priest.GUIDVT_Frame:RegisterEvent("UNIT_SPELLCAST_START")
IROVar.Priest.GUIDVT_Frame:RegisterEvent("UNIT_SPELLCAST_STOP")
IROVar.Priest.GUIDVT_Frame:SetScript("OnEvent", IROVar.Priest.GUIDVT_OnEvent)

function IROVar.Priest.CombatLog_OnEvent()
    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = CombatLogGetCurrentEventInfo()
    if (sourceGUID==IROVar.playerGUID) -- player
    and (subevent=="SPELL_DAMAGE") -- spell damang
    and spellID==(49821)then -- mind sear
        local currentTime=GetTime()
        if currentTime-IROVar.Priest.UnitMSCountTimer<0.1 then
            IROVar.Priest.UnitMSCount=IROVar.Priest.UnitMSCount+1
        else
            IROVar.Priest.UnitMSCount=1
            IROVar.Priest.UnitMSCountTimer=currentTime
        end
    end
end
IROVar.Priest.CombatLog_Frame = CreateFrame("Frame")
IROVar.Priest.CombatLog_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Priest.CombatLog_Frame:SetScript("OnEvent", IROVar.Priest.CombatLog_OnEvent)