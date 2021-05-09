-- Many Function Version Warlock 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Healer.GetMyCleanType() ;  return Magic,Disease,Poison,Curse penalty, spell name

if not IROVar then IROVar={} end
if not IROVar.Healer then IROVar.Healer={} end

IROVar.Healer.CleanType={}
IROVar.Healer.CleanType[71] = {0,0,0,0,''} -- Arm
IROVar.Healer.CleanType[72] = {0,0,0,0,''} -- fury
IROVar.Healer.CleanType[73] = {0,0,0,0,''} -- Protection
IROVar.Healer.CleanType[265] = {20,0,0,0,'Singe Magic'} -- Aff
IROVar.Healer.CleanType[266] = {20,0,0,0,'Singe Magic'} -- Demo
IROVar.Healer.CleanType[267] = {20,0,0,0,'Singe Magic'} -- Dest
IROVar.Healer.CleanType[262] = {0,0,0,20,'Cleanse Spirit'} -- Element
IROVar.Healer.CleanType[263] = {0,0,0,20,'Cleanse Spirit'} -- Enha
IROVar.Healer.CleanType[264] = {20,0,0,20,'Purify Spirit'} -- Resto
IROVar.Healer.CleanType[259] = {0,0,0,0,''} -- Ass
IROVar.Healer.CleanType[260] = {0,0,0,0,''} -- Out
IROVar.Healer.CleanType[261] = {0,0,0,0,''} -- Sub
IROVar.Healer.CleanType[256] = {20,20,0,0,'Purify'} -- Disc
IROVar.Healer.CleanType[257] = {20,20,0,0,'Purify'} -- Holy
IROVar.Healer.CleanType[258] = {0,20,0,0,'Purify Disease'} -- Shadow
IROVar.Healer.CleanType[65] = {20,20,20,0,'Cleanse'} -- Holy
IROVar.Healer.CleanType[66] = {0,20,20,0,'Cleanse Toxins'} -- Port
IROVar.Healer.CleanType[70] = {0,20,20,0,'Cleanse Toxins'} -- Ret
IROVar.Healer.CleanType[268] = {0,20,20,0,'Detox'} -- Brewmaster
IROVar.Healer.CleanType[270] = {20,20,20,0,'Detox'} -- Mistweaver
IROVar.Healer.CleanType[269] = {0,20,20,0,'Detox'} -- Windwalker
IROVar.Healer.CleanType[62] = {0,0,0,20,'Remove Curse'} -- arcane
IROVar.Healer.CleanType[63] = {0,0,0,20,'Remove Curse'} -- fire
IROVar.Healer.CleanType[64] = {0,0,0,20,'Remove Curse'} -- frost
IROVar.Healer.CleanType[253] = {0,0,0,0,''} -- Beast Mastery
IROVar.Healer.CleanType[254] = {0,0,0,0,''} -- Marksmanship
IROVar.Healer.CleanType[255] = {0,0,0,0,''} -- Survival
IROVar.Healer.CleanType[102] = {0,0,20,20,'Remove Corruption'} -- Balance
IROVar.Healer.CleanType[103] = {0,0,20,20,'Remove Corruption'} -- Feral
IROVar.Healer.CleanType[104] = {0,0,20,20,'Remove Corruption'} -- Guardian
IROVar.Healer.CleanType[105] = {20,0,20,20,"Nature's Cure"} -- Restoration
IROVar.Healer.CleanType[577] = {0,0,0,0,''} -- Havoc
IROVar.Healer.CleanType[581] = {0,0,0,0,''} -- Vengeance
IROVar.Healer.CleanType[250] = {0,0,0,0,''} -- Blood
IROVar.Healer.CleanType[251] = {0,0,0,0,''} -- frost
IROVar.Healer.CleanType[252] = {0,0,0,0,''} -- unholy

function IROVar.Healer.GetMyCleanType()
    if not IROSpecID then
        IROSpecID = GetSpecializationInfo(GetSpecialization())
    end
    -- return Magic,Disease,Poison,Curse penalty, spell name
    if not IROSpecID then
        return 0,0,0,0,''
    end
    local M,D,P,C,SpellName
    --print("Your current spec:", currentSpecName,Specid)
    if IROVar.Healer.CleanType[IROSpecID] then
        M=IROVar.Healer.CleanType[IROSpecID][1]
        D=IROVar.Healer.CleanType[IROSpecID][2]
        P=IROVar.Healer.CleanType[IROSpecID][3]
        C=IROVar.Healer.CleanType[IROSpecID][4]
        SpellName=IROVar.Healer.CleanType[IROSpecID][5]
    else
        M=0
        D=0
        P=0
        C=0
        SpellName=''
    end
    return M,D,P,C,SpellName
end

function IROVar.Healer.CheckDebuffAuraType(unit)
    -- return Magic, Disease, Poison, Curse (ture/false)
    local DMagic = false
    local DDisease = false
    local DPoison = false
    local DCurse = false
    local buffName,debuffType
    for i = 1, 40 do
        buffName, _, _, debuffType= UnitAura(unit, i, "HARMFUL")
        if not buffName then break end
        if debuffType=="Magic" then DMagic = true end
        if debuffType=="Disease"then DDisease = true end
        if debuffType=="Poison" then DPoison = true end
        if debuffType=="Curse" then DCurse = true end
    end
    return  DMagic, DDisease, DPoison, DCurse
end

function IROVar.Healer.predictHPremain(unit,DMagic,DDisease,DPoison,DCurse)
    -- return percent HP remain
    -- =currentHP + Shield + IncommingHeal/2
    -- -HealAbsorb + ifHP>80%constant
    -- -WantCleanConstant (Magic,Disease,Poison,Curse)
    local M,D,P,C = IROVar.Healer.CheckDebuffAuraType(unit)
    DMagic = (DMagic or 0)*(M and 1 or 0)
    -- check Unit Has MagicDEBUFF? and if has use as penalty %HP
    DDisease = (DDisease or 0)*(D and 1 or 0)
    DPoison = (DPoison or 0)*(P and 1 or 0)
    DCurse = (DCurse or 0)*(C and 1 or 0)

    local uMHP= UnitHealthMax(unit)/100

    -- if unit not exists return 50000
    if uMHP==0 then return 50000 end

    local iCH = (UnitGetIncomingHeals(unit)or 0) /(uMHP*2)
    local abs = UnitGetTotalAbsorbs(unit)/uMHP
    local Habs= UnitGetTotalHealAbsorbs(unit)/uMHP
    local uHP = UnitHealth(unit)/uMHP
    local HPMod=0 --TMW.CNDT.Env.CheckBuffMustHaveByMe(unit)

    -- debuff penaltry chose only Max one
    local DBP = math.max(DMagic,DDisease,DPoison,DCurse)

    uHP=uHP+abs

    if uHP>60 then uHP=uHP+20 end -- HP > 60% less chance to chose
    if uHP>80 then uHP=uHP+20 end -- if HP > 80% more less chance

    -- Tank -1%hp for 1st pick
    if UnitGroupRolesAssigned(unit) =="TANK" then
        return (uHP+iCH-Habs-DBP-HPMod)-1
    else
        return (uHP+iCH-Habs-DBP-HPMod)
    end
end

function IROVar.Healer.FindLowestHP()
    if UnitIsDead("player") then return "player" end
    local unit="player"
    local HP=IROVar.Healer.predictHPremain(unit)
    local function cHP(Unit)
        if UnitExists(Unit) and (not UnitIsDead(Unit))and UnitInRange(Unit) then
            local tHP=IROVar.Healer.predictHPremain(Unit)
            if tHP<HP then
                HP=tHP
                unit=Unit
            end
        end
    end
    if IsInRaid() then
        for i=1,30 do
            cHP("raid"..i)
        end
    elseif IsInGroup() then
        for i=1,4 do
            cHP("party"..i)
        end
    end
    return unit,HP
end