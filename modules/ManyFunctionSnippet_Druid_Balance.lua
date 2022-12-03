-- Many Function Version Druid Balance 9.2.5/2


--var IROVar.DruidBalance.NewMoon ; name spell
--var IROVar.DruidBalance.NewMoonAstGen ; Ast Gen from this spell
--var IROVar.DruidBalance.NewMoonCast ; casting?
--function IROVar.DruidBalance.CountSunfireDotAtEnemy()

--counter number of dot
--"nsunfire",
--"nmoonfire",
--"nstellarflare",


if not IROVar then IROVar = {} end
if not IROVar.DruidBalance then IROVar.DruidBalance = {} end

local dud = IROVar.DruidBalance

dud.NewMoon = "New Moon"
dud.NewMoonAstGen = 10
dud.NewMoonCast = false
    --164815 Sunfire
    --164812 Moonfire
    --202347 Stellar Flare
dud.dotCountList={
    [164815]="nsunfire",
    [164812]="nmoonfire",
    [202347]="nstellarflare",
}
dud.dotCount={
    [164815]=0,
    [164812]=0,
    [202347]=0,
}


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

function CanAttack(u)
    return UnitExists(u) and UnitCanAttack("player", u)
        --(UnitAffectingCombat(u) or  IsItemInRange(IROVar.ItemNameToCheck8, u))
end

function dud.CountDotAtEnemy()
    --164815 Sunfire
    for k in pairs(dud.dotCount) do
        dud.dotCount[k]=0
    end
    for i=1,20 do
        local n="nameplate"..i
        local spellId
        if CanAttack(n) then
            for index=1,40 do
                _,_,_,_,_,_,_,_,_,spellId=UnitDebuff(n,index,"PLAYER")
                if spellId then
                    if dud.dotCountList[spellId] then
                        dud.dotCount[spellId]=dud.dotCount[spellId]+1
                    end else break
end end end end end

C_Timer.NewTicker(0.4,function()
    dud.CountDotAtEnemy()
    for k,v in pairs(dud.dotCount) do
        IROVar.UpdateCounter(dud.dotCountList[k],v)
    end
end)