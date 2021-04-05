-- Many Function Version Lock 9.0.5/1
-- this file save many function for paste to TMW Snippet LUA

--function IROVar.LockPet(PetType) return true/false
----PetType 1=Felg 2=Succ 4=Felh 8=Voidw 16=Imp can use 3 for check felg+succ

if not IROVar then IROVar={} end

function IROVar.LockPet(PetType)
    if IROVar.LockPetActive then return bit.band(IROVar.LockPetActive,PetType)~=0 end
    IROVar.LockPetEvent = CreateFrame("Frame")
    IROVar.LockPetOnEvent=function()
        IROVar.LockPetActive=0
        local spellName = GetSpellInfo("Command Demon")
        if UnitExists("pet") and (not UnitIsDead("pet")) then
            if spellName == "Axe Toss" then IROVar.LockPetActive = 1
            elseif spellName == "Seduction" then IROVar.LockPetActive = 2
            elseif spellName == "Spell Lock" then IROVar.LockPetActive = 4
            elseif spellName == "Shadow Bulwark" then IROVar.LockPetActive = 8
            elseif spellName == "Singe Magic" then IROVar.LockPetActive = 16
            end
        end
    end
    IROVar.LockPetEvent:RegisterEvent("UNIT_PET")
    IROVar.LockPetEvent:SetScript("OnEvent", IROVar.LockPetOnEvent)
    IROVar.LockPetOnEvent()
    return IROVar.LockPet(PetType)
end

