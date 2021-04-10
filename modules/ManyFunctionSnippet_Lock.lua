-- Many Function Version Warlock 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Lock.Pet(PetType) return true/false
----PetType 1=Felg 2=Succ 4=Felh 8=Voidw 16=Imp can use 3 for check felg+succ
--function IROVar.Lock.PredictSS() return SSFragment / 10 SSFragment = 1 SS
--function IROVar.Lock.KeepLogText();
---- place befor /run IROUsedSkillControl.NumDotPress() for debug
--function IROVar.Lock.ShowLog()
--[[ NOTE
GetSpellCount("Implosion") ;Implosion Stack
UnitPower("player",7) ; SoulShards
]]


if not IROVar then IROVar={} end
if not IROVar.Lock then IROVar.Lock={} end
if not IROVar.Lock.ColorToSpell then IROVar.Lock.ColorToSpell=nil end
IROVar.Lock.PetActive=nil
IROVar.Lock.playerGUID=UnitGUID("player")
IROVar.Lock.SS={}
IROVar.Lock.LogSkillText=""
IROVar.Lock.SS.LockSpellModSS = {
	["Hand of Gul'dan266"]=-30, --266 = Demo
	["Shadow Bolt266"]=10, 
	["Call Dreadstalkers266"]=-20,
	["Summon Vilefiend266"]=-10,
	["Nether Portal266"]=-10,
	["Summon Demonic Tyrant266"]=50,
	["Demonbolt266"]=20,
	["Seed of Corruption265"]=-10, --265 = Aff
	["Malefic Rapture265"]=-10,
	["Chaos Bolt267"]=-20, -- 267 = des
	["Incinerate267"]=2
}

function IROVar.Lock.Pet(PetType)
    PetType=PetType or 0
    if IROVar.Lock.PetActive then return bit.band(IROVar.Lock.PetActivee,PetType)~=0 end
    IROVar.Lock.SetupPetEvent()
    return IROVar.Lock.Pet(PetType)
end
IROVar.Lock.PetTypeBit={["Axe Toss"]=1,["Seduction"]=2,["Spell Lock"]=4,["Shadow Bulwark"]=8,["Singe Magic"]=16}
function IROVar.Lock.SetupPetEvent()
    IROVar.Lock.PetEvent=CreateFrame("Frame")
    IROVar.Lock.PetOnEvent=function()
        IROVar.Lock.PetActive=0
        local spellName = GetSpellInfo("Command Demon")
        if UnitExists("pet") and (not UnitIsDead("pet")) then
            IROVar.Lock.PetActive=IROVar.Lock.PetTypeBit[spellName] or 0
        end
    end
    IROVar.Lock.PetEvent:RegisterEvent("UNIT_PET")
    IROVar.Lock.PetEvent:SetScript("OnEvent", IROVar.Lock.PetOnEvent)
    IROVar.Lock.PetOnEvent()
end

function IROVar.Lock.SS.OnEvent()
    local _,subevent,_,sourceGUID = CombatLogGetCurrentEventInfo()
        if (sourceGUID==IROVar.Lock.playerGUID)  and (subevent=="SPELL_CAST_FAILED") then
			IROVar.Lock.SS.trust_segment_cast = true
       end
end

IROVar.Lock.SS.Frame = CreateFrame("Frame")
IROVar.Lock.SS.Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IROVar.Lock.SS.Frame:SetScript("OnEvent", IROVar.Lock.SS.OnEvent)
IROVar.Lock.SS.trust_segment_cast=true
IROVar.Lock.SS.old_timer_check=0
IROVar.Lock.SS.old_val=0

function IROVar.Lock.PredictSS()
	-- if (trust_segment_cast == Ture) Must Recalculate
	-- if (trust_segment_cast == False) Must Use old_val
	local currentTime = GetTime()

	if IROVar.Lock.SS.old_timer_check == currentTime then
		return IROVar.Lock.SS.old_val
	end
	if (not IROVar.Lock.SS.trust_segment_cast) then
		if (currentTime>IROVar.Lock.SS.old_spell_finish_cast_check) then
			IROVar.Lock.SS.trust_segment_cast = true
		else
			return IROVar.Lock.SS.old_val
		end
	end
	if not IROSpecID then IROSpecID = GetSpecializationInfo(GetSpecialization()) end
	local currentSS = UnitPower("player",7,true)
	local spellName,_,_, startTimeMS, endTimeMS = UnitCastingInfo("player")
	if spellName then
		local endTime = endTimeMS/1000
		-- if > 6/10 of spell cast bar ?
		-- trust_segment_cast = 0.6>((currentTime*1000)-startTimeMS)/(endTimeMS-startTimeMS)
		-- if spell < 0.3 sec befor finish casting
		IROVar.Lock.SS.trust_segment_cast = (endTime-currentTime)>0.3
		if IROVar.Lock.SS.trust_segment_cast then
			if spellName == "Incinerate" then
				-- check Havoc for double SS generate
				local nn
				local nnDebuff
				local hasHavoc = false
				for ii = 1,30 do
					nn="nameplate"..ii
					if UnitExists(nn) and UnitCanAttack("player", nn) then
						nnDebuff = IROVar.allDeBuffByMe(nn)
						if nnDebuff["Havoc"] then
							hasHavoc = (not UnitIsUnit("target",nn)) and (nnDebuff["Havoc"]>(0.1+endTime-currentTime))
							break
						end
					end
				end
				if hasHavoc then
					currentSS = currentSS + 4
				else
					currentSS = currentSS + 2
				end
			else
				currentSS = currentSS+(IROVar.Lock.SS.LockSpellModSS[spellName..IROSpecID] or 0)
			end
			currentSS = (currentSS<=50)and currentSS or 50
			currentSS = (currentSS>=0)and currentSS or 0
			IROVar.Lock.SS.old_spell_finish_cast_check = endTime+0.2
		else
			return IROVar.Lock.SS.old_val
		end
	end
	IROVar.Lock.SS.old_timer_check = currentTime
	IROVar.Lock.SS.old_val = currentSS
	return currentSS
end

IROVar.Lock.KeepLogText = function()
	local currentTime=GetTime()
	local diffTimePress=currentTime-IROUsedSkillControl.OldTimeNumDotPress
	local IROcode1=getMetaIconColor(IROIcon1)
	local IROcode2=getMetaIconColor(IROIcon2)
	local IROcode3=getMetaIconColor(IROIcon3)
	local Code=""
	if IROVar.Lock.ColorToSpell then
		IROcode1 = IROVar.Lock.ColorToSpell[IROcode1] or IROcode1
		IROcode2 = IROVar.Lock.ColorToSpell[IROcode2] or IROcode2
		IROcode3 = IROVar.Lock.ColorToSpell[IROcode3] or IROcode2
	end
	Code = IROcode1.." "..IROcode2.." "..IROcode3
	local SSf = IROVar.Lock.PredictSS()
	IROUsedSkillControl.OldTimeNumDotPress=currentTime
	local SS = UnitPower("player",7)
	local t=string.format("%.2f :OK,dTime: ",currentTime)
	if diffTimePress<=5 then
		t=t..string.format("%.2f : (rSS)pSS: (%d)%.1f : ",diffTimePress,SS,SSf/10)
	else
		t=t..">>5"..string.format(" : (rSS)pSS: (%d)%.1f : ",SS,SSf/10)
	end
	t=t..Code
	IROVar.Lock.LogSkillText=t..'\n'..IROVar.Lock.LogSkillText
	if IROVar.Lock.LogFrameShow then
		IROVar.Lock.UpdateLog()
	end
end

IROVar.Lock.ShowLog = function()
	if IROVar.Lock.LogFrameShow then return end
	if not AceGUI then AceGUI = LibStub("AceGUI-3.0") end
	IROVar.Lock.LogFrameShow=true
	IROVar.Lock.LogFrame=AceGUI:Create("Frame")
	IROVar.Lock.LogFrame:SetTitle("Log Skill")
	IROVar.Lock.LogFrame:SetLayout("Fill")
	IROVar.Lock.LogFrame:SetWidth(500)
	IROVar.Lock.LogFrame:SetHeight(400)
	IROVar.Lock.LogFrame:SetPoint("TOPLEFT","UIParent","TOPLEFT",20,-50)
	IROVar.Lock.LogFrame:SetCallback("OnClose", function(widget)
		IROVar.Lock.LogFrameShow=false
		AceGUI:Release(widget)
	end)
	IROVar.Lock.LogScrollFrame= AceGUI:Create("ScrollFrame")
	IROVar.Lock.LogLabel=AceGUI:Create("Label")
	local fontName, fontHeight, fontFlags = GameFontNormal:GetFont()
	IROVar.Lock.LogLabel:SetFont(fontName,fontHeight*1.2,fontFlags)
	IROVar.Lock.LogLabel:SetWidth(2048)
	IROVar.Lock.LogScrollFrame:AddChild(IROVar.Lock.LogLabel)
	IROVar.Lock.LogFrame:AddChild(IROVar.Lock.LogScrollFrame)
	IROVar.Lock.LogLabel:SetText(IROVar.Lock.LogSkillText)
end

IROVar.Lock.UpdateLog = function()
	if IROVar.Lock.LogLabel then
		IROVar.Lock.LogLabel:SetText(IROVar.Lock.LogSkillText)
	end
end