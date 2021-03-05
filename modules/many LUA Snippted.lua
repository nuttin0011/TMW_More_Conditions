--LUA Snippted

-------- Skill Used in 4 Sec

local TMW = TMW
local CNDT = TMW.CNDT
local Env = CNDT.Env

if not IROSkillUseIn4SecConditionCategory then

    if not IROSkillUseIn4SecFrame then
        IROSkillUseIn4SecFrame = CreateFrame("Frame")
        IROSkillUseIn4SecFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        IROSkillUseIn4SecFrame:SetScript("OnEvent", function(self, event)
		    self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
            end)
        function IROSkillUseIn4SecFrame:COMBAT_LOG_EVENT_UNFILTERED(...)
            if not IROplayerGUID then IROplayerGUID=UnitGUID("player") end
            local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
            local spellId, spellName, spellSchool
            local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            local buff,debuff, currentTime
            local loadVal = function(...)
                spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)	
            end
            if sourceGUID~=IROplayerGUID then return false end
            currentTime = GetTime()
            if subevent=="SPELL_CAST_SUCCESS" then
                if not Env.LastCastIn4Sec then
                    Env.LastCastIn4Sec={}
                end
                loadVal(...)
                Env.LastCastIn4Sec[strlower(spellName)] = currentTime
                Env.LastCastIn4Sec[spellId] = currentTime
            end
        end
    end

    IROSkillUseIn4SecConditionCategory= CNDT:GetCategory("IROOTHERCONDITION", 15, "Skill Used in 4 sec", true, false)
    
    IROSkillUseIn4SecConditionCategory:RegisterCondition(1,  "SKILLUSEIN4SEC", {
            text = "Check player Skill use in 4 sec",
            unit = "player",
            step = 1,
            min = 0,
            max = 1,
            noslide = false,
            levelChecks = true,
            nooperator = true,
            useSUG = true,
            allowMultipleSUGEntires = false,
            texttable = {
                [0] = "Used in 4 sec",
                [1] = "not Used in 4 sec",
            },
            name = function(editbox) 
                editbox:SetTexts("Skill Name","e.g. agony")
            end,
            icon = "Interface\\Icons\\spell_druid_bloodythrash",
            tcoords = CNDT.COMMON.standardtcoords,
            funcstr = function(c)
                if c.Level == 0 then
                    if (not Env.LastCastIn4Sec)or(not Env.LastCastIn4Sec[strlower(c.Name)]) then 
                        return [[false]] 
                    else
                        return [[((LastCastIn4Sec[LOWER(c.NameFirst)]or math.huge)+4)>GetTime()]]
                    end
                else
                    if (not Env.LastCastIn4Sec)or(not Env.LastCastIn4Sec[strlower(c.Name)]) then 
                        return [[true]]
                    else                   
                        return [[((LastCastIn4Sec[LOWER(c.NameFirst)]or math.huge)+4)<=GetTime()]]
                    end
                end
            end,
    })
end


-------- end Skill Used in 4 Sec