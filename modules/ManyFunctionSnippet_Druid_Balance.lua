-- Many Function Version Druid Balance 9.2.5/1


--var IROVar.DruidBalance.NewMoon ; name spell
--var IROVar.DruidBalance.NewMoonAstGen ; Ast Gen from this spell
--var IROVar.DruidBalance.NewMoonCast ; casting?

if not IROVar then IROVar = {} end
if not IROVar.DruidBalance then IROVar.DruidBalance = {} end

local dud = IROVar.DruidBalance

dud.NewMoon = "New Moon"
dud.NewMoonAstGen = 10
dud.NewMoonCast = false


function dud.UpdateNewMoon()
    dud.NewMoon = GetSpellInfo("new moon")
    if dud.NewMoon=="New Moon" then
        dud.NewMoonAstGen = 10
    elseif dud.NewMoon=="Half Moon" then
        dud.NewMoonAstGen = 20
    else
        dud.NewMoonAstGen = 40
    end
end
dud.UpdateNewMoon()

function dud.CombatEvent(...)

    local function isNewMoon(sID)
        return (sID>=274281) and (sID<=274283)
    end

    local _,subevent,_,sourceGUID,_,_,_,DesGUID,DesName,_,_,spellID,spellName = ...
    if sourceGUID~=IROVar.playerGUID then return end
    --274281 274282 274283 ; newMoon HalfMoon FullMoon
	if subevent=="SPELL_CAST_SUCCESS" then
        if isNewMoon(spellID) then
            dud.UpdateNewMoon()
        end
        dud.NewMoonCast=false
    elseif subevent=="SPELL_CAST_START" then
        if isNewMoon(spellID) then
            dud.NewMoonCast=true
        end
    elseif subevent=="SPELL_CAST_FAILED" then
        dud.NewMoonCast=false
    end
end

IROVar.Register_COMBAT_LOG_EVENT_UNFILTERED_CALLBACK("dudbalance",IROVar.DruidBalance.CombatEvent)
IROVar.RegisterIncombatCallBackRun("dudbalance",IROVar.DruidBalance.UpdateNewMoon())