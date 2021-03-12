-- Combine Icon
local icon = ...
local pingadjust = 0.25
local IROcode1=getMetaIconColor(IROIcon1)
local IROcode2=getMetaIconColor(IROIcon2)
local IROcode3=getMetaIconColor(IROIcon3)
local cc=enMiniIROcode(IROcode1,IROcode2,IROcode3)

--Sum Colour 3 icon
if icon.States[1].Color~=cc then
    if EROSumIcon1 then
        EROSumIcon1.States[1].Color=cc
    end
    if EROSumIcon2 then
        EROSumIcon2.States[1].Color=cc
    end 
    if TMW_ST:GetCounter("sumicon")==0
    then
        TMW_ST:UpdateCounter("sumicon",1)
    else
        TMW_ST:UpdateCounter("sumicon",0)
    end
end

--Wait For Use Skill Icon Control
--can use skill when "IROusedskillStatus=1"

local currentTime
local IROTimeCheckUseSkill,IROCanUseSkill
if not IRO_UseSkillHandle then IRO_UseSkillHandle={} end
if not IROusedskillStatus then
    IROTimeCheckUseSkill=0
    IROusedskillStatus=1
end
local c=IROusedskillStatus

if(c==2)then -- set counter to 3 and wait 0.2 sec --> Change Counter to 4
	IROusedskillStatus=3
	table.insert(IRO_UseSkillHandle,C_Timer.NewTimer(0.2,
		function() 
			if IROusedskillStatus~=1 then
				IROusedskillStatus=4
			end
		end))
end

if(c==4)then
    IROTimeCheckUseSkill,IROCanUseSkill=NextTimeCheckLockUseSkill(pingadjust)
	if IROCanUseSkill then
		for k,v in pairs(IRO_UseSkillHandle) do
			v:Cancel()
		end
		IRO_UseSkillHandle={}
		IROusedskillStatus=1
	else
		IROusedskillStatus=5
		currentTime=GetTime()
		if IROTimeCheckUseSkill <= currentTime then
			table.insert(IRO_UseSkillHandle,C_Timer.NewTimer(0.2,
				function() 
					if IROusedskillStatus~=1 then
						IROusedskillStatus=4
					end
				end))
		else
			table.insert(IRO_UseSkillHandle,C_Timer.NewTimer(IROTimeCheckUseSkill-currentTime,
				function() 
					if IROusedskillStatus~=1 then
						IROusedskillStatus=4
					end
				end))
		end
	end
end


