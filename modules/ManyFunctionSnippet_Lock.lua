-- Many Function Version Warlock 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.Warlock.Pet(PetType) return true/false
----PetType 1=Felg 2=Succ 4=Felh 8=Voidw 16=Imp can use 3 for check felg+succ


if not IROVar then IROVar={} end
IROVar.Warlock={}
IROVar.Warlock.PetActive=nil
function IROVar.Warlock.Pet(PetType)
    PetType=PetType or 0
    if IROVar.Warlock.PetActive then return bit.band(IROVar.Warlock.PetActivee,PetType)~=0 end
    IROVar.Warlock.SetupPetEvent()
    return IROVar.Warlock.Pet(PetType)
end
IROVar.Warlock.PetTypeBit={["Axe Toss"]=1,["Seduction"]=2,["Spell Lock"]=4,["Shadow Bulwark"]=8,["Singe Magic"]=16}
function IROVar.Warlock.SetupPetEvent()
    IROVar.Warlock.PetEvent=CreateFrame("Frame")
    IROVar.Warlock.PetOnEvent=function()
        IROVar.Warlock.PetActive=0
        local spellName = GetSpellInfo("Command Demon")
        if UnitExists("pet") and (not UnitIsDead("pet")) then
            IROVar.Warlock.PetActive=IROVar.Warlock.PetTypeBit[spellName] or 0
        end
    end
    IROVar.Warlock.PetEvent:RegisterEvent("UNIT_PET")
    IROVar.Warlock.PetEvent:SetScript("OnEvent", IROVar.Warlock.PetOnEvent)
    IROVar.Warlock.PetOnEvent()
end
