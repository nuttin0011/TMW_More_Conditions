-- OK Stuned V 1.5 ICON + ZeroSI + VVCare
-- interrupt Only Important Spell at Specific Mob
-- IROVar.OKStuned(unit e.g. "target") ; return true / false
-- IROVar and IROVar.OKStuned and IROVar.OKStuned("target")

-- ComBO Set %Cast+OK Stun+Zero Smart Interrupt+VVCare Interrupt
--[[
    IROVar and IROVar.OKStuned and IROVar.VVCareInterrupt and 
    PercentCastbar2 and NextInterrupter and NextInterrupter.ZeroSI and 
    PercentCastbar2(0.3,false,"target",200,5000)and IROVar.OKStuned("target")and 
    NextInterrupter.ZeroSI()and IROVar.VVCareInterrupt("target")
    ]]

if not IROVar then IROVar={} end
if not IROVar.InstanceName then IROVar.InstanceName = GetInstanceInfo() end
if (not IROVar.fspec) and (not IROVar.finstanceName) then
    IROVar.finstanceName = CreateFrame("Frame")
    IROVar.finstanceName:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    IROVar.finstanceName:SetScript("OnEvent", function()
        IROVar.InstanceName = GetInstanceInfo()
    end)
end
if not IROVar.cannotStun then
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
        }
    }
    IROVar.OKStuned = function(nUnit)
        if CTT and CTT.immuneKnown then
            local NPCID=CTT.GetNPCId(UnitGUID(nUnit) or "")
            return not(NPCID and CTT.immuneFound[NPCID] or CTT.immuneKnown[NPCID])
        end
        nUnit = nUnit or "target"
        local nL=UnitLevel(nUnit)
        if nL==-1 then return false end
        if nL==0 then return true end
        if not IROVar.cannotStun[IROVar.InstanceName] then
            return true
        end
        local MobName=UnitName(nUnit)
        if not MobName then return true end
        return not(IROVar.cannotStun[IROVar.InstanceName][MobName]==true)
    end
end

-- NextInterrupter and NextInterrupter.ZeroSI and NextInterrupter.ZeroSI()
if not NextInterrupter then NextInterrupter={} end
if not NextInterrupter.ZeroSI then
    NextInterrupter.ZeroSI = function(nUnit)
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
end

-- IROVar and IROVar.VVCareInterrupt and IROVar.VVCareInterrupt("target")
--if not IROVar then IROVar={} end
if not IROVar.VVCareInterrupt then
    IROVar.VVCareInterrupt = function(nUnit)
        if not IROVar.MobListForInterrupt then return false end
        if not IROVar.MobListForInterrupt[IROVar.InstanceName] then
            return false
        end
        local MobName=UnitName(nUnit)
        if not MobName then return false end
        if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName] then
            return false
        end
        local SName = UnitCastingInfo(nUnit)
        if not SName then SName = UnitChannelInfo(nUnit) end
        if not SName then return false end
        if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName] then return false end
        return (IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName]==true) and true or
            loadstring(IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName])()
    end
end


