-- Key Setting...
local Nm={}


Nm[0]="/petattack\n/cast [mod:ctrlalt]Nether Portal;[mod:ctrl]Create Healthstone;[mod:alt]Curse of Exhaustion;[nomod]Curse of Tongues\n/run IUSC.SU('30')"
Nm[1]="\n/petattack\n/cast [mod:ctrlalt]Curse of Weakness;[mod:ctrl]Drain Life;[mod:alt]Health Funnel;[nomod]Shadow Bolt\n/run IUSC.SU('31')"
Nm[2]="/cast [mod:alt,nomod:ctrl,combat]Fel Domination\n/cast [mod:ctrlalt]Shadowfury;[mod:ctrl,@focus]Soulstone;[mod:alt]Summon Felguard;[nomod]Soul Rot\n/run IUSC.SU('32')"
Nm[3]="\n/petattack\n/cast [mod:ctrlalt]Call Dreadstalkers;[mod:ctrl]Implosion;[mod:alt]Soul Strike;[nomod]Demonbolt\n/run IUSC.SU('33')"
Nm[4]="/petassist [mod:ctrl]\n/petattack\n/cast [mod:ctrlalt]Corruption;[mod:ctrl]Summon Demonic Tyrant;[mod:alt,@cursor]Bilescourge Bombers;[nomod]Demonic Strength\n/run IUSC.SU('34')"
Nm[5]="\n/petattack\n/cast [mod:ctrlalt]Power Siphon;[mod:ctrl]Doom;[mod:alt];[nomod]Hand of Gul'dan\n/run IUSC.SU('35')"
Nm[6]="/petassist [mod:ctrlalt][nomod]\n/petattack\n/cast [mod:ctrlalt]Summon Vilefiend;[mod:ctrl]Mortal Coil;[mod:alt]Darkfury;[nomod]Grimoire: Felguard\n/run IUSC.SU('36')"
Nm[7]="/petattack\n/cast [mod:ctrlalt]Command Demon\n/target [@focustarget,mod:alt,nomod:ctrl,harm,nodead]\n/focus [mod:ctrl,nomod:alt,@pet,exists,nodead]\n/cancelaura [nomod]Burning Rush\n/run IUSC.SU('37')"


--print((IROVar.InterruptSpell~=nil) and IROVar.InterruptSpell or "nil")
--print((IROSpecID~=nil) and IROSpecID or "nil")
local iS=IROVar.InterruptSpell or ""
Nm[8]='/petattack\n/use [mod:ctrl,nomod:alt]13\n/use [mod:ctrl,nomod:alt]14\n/cast [mod:alt,nomod:ctrl]Dark Pact;[nomod]Unending Resolve'
Nm[9]='/petattack\n/focus [@mouseover,exists,harm,nodead,mod:ctrlalt]'..
'\n/cast [mod:ctrl,nomod:alt,@focus]'..iS..';[mod:alt,nomod:ctrl]'..iS


if not IROUsedSkillControl then IROUsedSkillControl={} end

IROUsedSkillControl.ColorToSpell={
    ["ff000000"]="---",
    ["ff033003"]="Nether Portal",
    ["ff013001"]="Create Healthstone",
    ["ff023002"]="Curse of Exhaustion",
    ["ff003000"]="Curse of Tongues",
    ["ff033103"]="Curse of Weakness",
    ["ff013101"]="Drain Life",
    ["ff023102"]="Health Funnel",
    ["ff003100"]="Shadow Bolt",
    ["ff033203"]="Shadowfury",
    ["ff013201"]="Soulstone",
    ["ff023202"]="Summon Felguard",
    ["ff003200"]="Soul Rot",
    ["ff033303"]="Call Dreadstalkers",
    ["ff013301"]="Implosion",
    ["ff023302"]="Soul Strike",
    ["ff003300"]="Demonbolt",
    ["ff033403"]="Corruption",
    ["ff013401"]="Summon Demonic Tyrant",
    ["ff023402"]="Bilescourge Bombers",
    ["ff003400"]="Demonic Strength",
    ["ff033503"]="Power Siphon",
    ["ff013501"]="Doom",

    ["ff003500"]="Hand of Gul'dan",
    ["ff033603"]="Summon Vilefiend",
    ["ff013601"]="Mortal Coil",
    ["ff023602"]="Darkfury",
    ["ff003600"]="Grimoire: Felguard",
    ["ff033703"]="Command Demon",
    ["ff013702"]="target focustarget",
    
    ["ff003700"]="Cancel Burning Rush",
    
    ["ff013801"]="Use Trinket",
    ["ff023802"]="Dark Pact",
    ["ff003800"]="Unending Resolve",
    
    
    ["ff013a01"]="Use Health Stone",
    ["ff023902"]="Interrupt Target",
    ["ff013901"]="Interrupt Focus",
    ["ff033903"]="Focus Mouse Over",
    ["ff013701"]="focus pet",
    
    ["ff023a02"]="Stop Casting",
}




local function SetKey(IncombatStatus)
    if InCombatLockdown() then
        if IncombatStatus then print("cannot Bind Key while Incombat") end
        C_Timer.After(1,SetKey)
    else
        if not IncombatStatus then print("Out Combat Bind Key Done!") end
        local nname
        for i in pairs(Nm) do
            nname='~!Num'..i
            DeleteMacro(nname)
            DeleteMacro(nname)
            CreateMacro(nname,460699,Nm[i] ,true)
end end end
SetKey(true)


IUSC.NumToSpell={}
IUSC.NumToID={}
IUSC.IDToSpell={}

for k,v in pairs(IUSC.ColorToSpell) do
    k=string.sub(k,5,8)
    local n=tonumber(k,16)
    local N,_,_,_,_,_,id=GetSpellInfo(v)
    if N then
        IUSC.NumToSpell[n]=N
        IUSC.NumToID[n]=id
        IUSC.IDToSpell[id]=N
    else
        IUSC.NumToSpell[n]=v
        IUSC.NumToID[n]=0
    end
end

