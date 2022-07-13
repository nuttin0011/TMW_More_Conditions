-- Care (OK)Stuned V 3.0 +ZeroSI + VVCare
-- Version LUA Snipped
-- Set Priority to 20
-- interrupt Only Important Spell at Specific Mob
-- IROVar.OKStuned(unit e.g. "target") ; return true / false
-- IROVar and IROVar.OKStuned and IROVar.OKStuned("target")

--function IROVar.VVCareInterruptTarget()
--function IROVar.OKStunedTarget()
--function NextInterrupter.ZeroSITarget()

-- ComBO Set %Cast+OK Stun+Zero Smart Interrupt+VVCare Interrupt
--[[
    IROVar and IROVar.OKStuned and IROVar.VVCareInterrupt and 
    PercentCastbar2 and NextInterrupter and NextInterrupter.ZeroSI and 
    PercentCastbar2(0.3,false,"target",200,5000)and IROVar.OKStuned("target")and 
    NextInterrupter.ZeroSI()and IROVar.VVCareInterrupt("target")
    ]]


IROVar.cannotStun ={
    ["Mists of Tirna Scithe"] ={
        ["Drust Boughbreaker"]= true,
        ["Tirnenn Villager"]= true,
        ["Ingra Maloch"]= true,
        ["Droman Oulfarran"]= true,
        ["Mistveil Nightblossom"]= true,
        ["Mistcaller"]= true,
        ["Spinemaw Staghorn"]= true,
        ["Tred'ova"]= true,
        ["Mistveil Gorgegullet"]= true,
        ["Mistveil Matriarch"]= true,
    },
    ["The Necrotic Wake"] ={
        ["Zolramus Gatekeeper"]= true,
        ["Blightbone"]= true,
        ["Skeletal Marauder"]= true,
        ["Nar'zudah"]= true,
        ["Skeletal Monstrosity"]= true,
        ["Amarth"]= true,
        ["Kyrian Stitchwerk"]= true,
        ["Separation Assistant"]= true,
        ["Stitching Assistant"]= true,
        ["Goregrind"]= true,
        ["Rotspew"]= true,
        ["Stitchflesh's Creation"]= true,
        ["Surgeon Stitchflesh"]= true,
        ["Nalthor the Rimebinder"]= true,
    },
    ["De Other Side"] ={
        ["Risen Warlord"]=true,
        ["Death Speaker"]=true,
        ["Enraged Spirit"]=true,
        ["Defunct Dental Drill"]=true,
        ["4.RF-4.RF"]=true,
        ["Millhouse Manastorm"]=true,
        ["Millificent Manastorm"]=true,
        ["Atal'ai Hoodoo Hexxer"]=true,
        ["Atal'ai Devoted"]=true,
        ["Hakkar the Soulflayer"]=true,
        ["Bladebeak Matriarch"]=true,
        ["Mythresh, Sky's Talons"]=true,
        ["Dealer Xy'exa"]=true,
        ["Mueh'zala"]=true,
    },
    ["Sanguine Depths"]={
        ["Regal Mistdancer"]=true,
        ["Insatiable Brute"]=true,
        ["Kryxis the Voracious"]=true,
        ["Chamber Sentinel"]=true,
        ["Grand Overseer"]=true,
        ["Head Custodian Javlin"]=true,
        ["Depths Warden"]=true,
        ["Executor Tarvold"]=true,
        ["Grand Proctor Beryllia"]=true,
        ["General Kaal"]=true,
    },
    ["Halls of Atonement"]={
        ["Loyal Stoneborn"]=true,
        ["Shard of Halkias"]=true,
        ["Halkias"]=true,
        ["Stoneborn Reaver"]=true,
        ["Stoneborn Slasher"]=true,
        ["Echelon"]=true,
        ["High Adjudicator Aleez"]=true,
        ["Inquisitor Sigar"]=true,
        ["Lord Chamberlain"]=true,
    },
    ["Plaguefall"]={
        ["Plaguebound"]=true,
        ["Plagueroc"]=true,
        ["Decaying Flesh Giant"]=true,
        ["Hatchling Nest"]=true,
        ["Plaguebelcher"]=true,
        ["Globgrog"]=true,
        ["Unstable Canister"]=true,
        ["Blighted Spinebreaker"]=true,
        ["Virulax Blightweaver"]=true,
        ["Doctor Ickus"]=true,
        ["Domina Venomblade"]=true,
        ["Ickor Bileflesh"]=true,
        ["Margrave Stradama"]=true,
    },
    ["Spires of Ascension"]={
        ["Forsworn Goliath"]=true,
        ["Azules"]=true,
        ["Kin-Tara"]=true,
        ["Forsworn Squad-Leader"]=true,
        ["Ventunax"]=true,
        ["Forsworn Helion"]=true,
        ["Oryphrion"]=true,
        ["Klotos"]=true,
        ["Lakesis"]=true,
        ["Astronos"]=true,
        ["Devos"]=true,
    },
    ["Theater of Pain"]={
        ["Raging Bloodhorn"]=true,
        ["Dessia the Decapitator"]=true,
        ["Paceran the Virulent"]=true,
        ["Sathel the Accursed"]=true,
        ["Dokigg the Brutalizer"]=true,
        ["Harugia the Bloodthirsty"]=true,
        ["Advent Nevermore"]=true,
        ["Xav the Unfallen"]=true,
        ["Portal Guardian"]=true,
        ["Soulforged Bonereaver"]=true,
        ["Nefarious Darkspeaker"]=true,
        ["Kul'tharok"]=true,
        ["Rancid Gasbag"]=true,
        ["Gorechop"]=true,
        ["Mordretha, the Endless Empress"]=true,
        ["Nekthara the Mangler"]=true,
        ["Heavin the Breaker"]=true,
        ["Rek the Hardened"]=true,
    },
    ["Tazavesh, the Veiled Market"]={
        ["Gatewarden Zo'mazz"]=true,
        ["Armored Overseer"]=true,
        ["Portalmancer Zo'honn"]=true,
        ["Zo'phex"]=true,
        ["Tracker Zo'korss"]=true,
        ["Ancient Core Hound"]=true,
        ["Enraged Direhorn"]=true,
        ["Commerce Enforcer"]=true,
        ["Commander Zo'far"]=true,
        ["Cartel Muscle"]=true,
        ["Oasis Security"]=true,
        ["Zo'gron"]=true,
        ["Alcruux"]=true,
        ["Achillite"]=true,
        ["Venza Goldfuse"]=true,
        ["P.O.S.T. Master"]=true,
        ["So'azmi"]=true,
        ["Murkbrine Shorerunner"]=true,
        ["Coastwalker Goliath"]=true,
        ["Stormforged Guardian"]=true,
        ["Hylbrande"]=true,
        ["Drunk Pirate"]=true,
        ["Corsair Officer"]=true,
        ["Timecap'n Hooktail"]=true,
        ["Adorned Starseer"]=true,
        ["So'leah"]=true,
    }
}

local function CheckOK(GUID,name,nL)
    if CTT and CTT.immuneKnown then
        local NPCID=CTT.GetNPCId(GUID or "")
        return not(NPCID and CTT.immuneFound[NPCID] or CTT.immuneKnown[NPCID])
    end
    if nL==-1 then return false end
    if nL==0 then return true end
    if not IROVar.cannotStun[IROVar.InstanceName] then
        return true
    end
    if not name then return true end
    return not(IROVar.cannotStun[IROVar.InstanceName][name]==true)
end

function IROVar.OKStuned(nUnit)
    nUnit = nUnit or "target"
    return CheckOK(UnitGUID(nUnit),UnitName(nUnit),UnitLevel(nUnit))
end

function IROVar.OKStunedTarget()
    return CheckOK(IROVar.TargetGUID or "",IROVar.TargetName or "",IROVar.TargetLV)
end

-- NextInterrupter and NextInterrupter.ZeroSI and NextInterrupter.ZeroSI()
function NextInterrupter.ZeroSI(nUnit)
    --ZeroSI=Zero-Smart-Interrupt
    nUnit=nUnit or "target"
    local CanNotInterrupt = select(8,UnitCastingInfo(nUnit))
    if CanNotInterrupt == nil then CanNotInterrupt = select(7,UnitChannelInfo(nUnit)) end
    if CanNotInterrupt == true then return true end
    local uGUID=UnitGUID(nUnit)
    return (not NextInterrupter.Enabled)
    or (not NextInterrupter.ITable[uGUID])
    or (next(NextInterrupter.ITable[uGUID])==nil)
end

function NextInterrupter.ZeroSITarget()
    --ZeroSI=Zero-Smart-Interrupt
    local CanNotInterrupt=nil
    if IROVar.CastBar.Casting then
        CanNotInterrupt=IROVar.CastBar.Casting[8]
    elseif IROVar.CastBar.Channeling then
        CanNotInterrupt=IROVar.CastBar.Channeling[7]
    end
    if CanNotInterrupt==true then return true end
    local uGUID=IROVar.TargetGUID
    return (not NextInterrupter.Enabled)
    or (not NextInterrupter.ITable[uGUID])
    or (next(NextInterrupter.ITable[uGUID])==nil)
end

-- IROVar and IROVar.VVCareInterrupt and IROVar.VVCareInterrupt("target")
--if not IROVar then IROVar={} end

local function VVCare1(MobName)
    if not MobName then return false end
    if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName] then return false end
    return true
end
local function VVCare2(MobName,SName)
    if not SName then return false end
    if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName] then return false end
    return (IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName]==true) or
        loadstring(IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName])()
end
function IROVar.VVCareInterrupt(nUnit)
    --if not IROVar.MobListForInterrupt then return false end --should have?
    if not IROVar.MobListForInterrupt[IROVar.InstanceName] then return false end
    local MobName=UnitName(nUnit)
    if VVCare1(MobName) then
        local SName = UnitCastingInfo(nUnit)
        if not SName then SName = UnitChannelInfo(nUnit) end
        return VVCare2(MobName,SName)
    end
    return false
end
function IROVar.VVCareInterruptTarget()
    --if not IROVar.MobListForInterrupt then return false end --should have?
    if not IROVar.MobListForInterrupt[IROVar.InstanceName] then return false end
    if VVCare1(IROVar.TargetName) then
        local SName=nil
        if IROVar.CastBar.Casting then
            SName=IROVar.CastBar.Casting[1]
        elseif IROVar.CastBar.Channeling then
            SName=IROVar.CastBar.Channeling[1]
        end
        return VVCare2(IROVar.TargetName,SName)
    end
    return false
end

