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

