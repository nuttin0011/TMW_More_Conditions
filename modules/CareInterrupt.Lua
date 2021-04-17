-- Care Interrupt V 1.2 ICON
-- interrupt Only Important Spell at Specific Mob
-- IROVar.CareInterrupt(unit e.g. "target") ; return true / false

if not IROVar then IROVar={} end
if not IROVar.InstanceName then IROVar.InstanceName = GetInstanceInfo() end
if (not IROVar.fspec) and (not IROVar.finstanceName) then
    IROVar.finstanceName = CreateFrame("Frame")
    IROVar.finstanceName:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    IROVar.finstanceName:SetScript("OnEvent", function()
            IROVar.InstanceName = GetInstanceInfo()
    end)
end
if not IROVar.MobListForInterrupt then
    IROVar.MobListForInterrupt = {
        ["Mists of Tirna Scithe"] = {
            ["Ingra Maloch"] = {["Spirit Bolt"] = true,},
            ["Mistcaller"] = {["Patty Cake"] = true,},
            ["Tred'ova"] = {
                ["Parasitic Pacification"] = true,
                ["Parasitic Incapacitation"] = true,
                ["Parasitic Domination"] = true,
            },
            ["Drust Harvester"] = {["Harvest Essence"] = true,},
            ["Mistveil Tender"] = {["Nourish the Forest"] = true,},
            ["Mistveil Shaper"] = {["Bramblethorn Coat"] = true,},
            ["Spinemaw Staghorn"] = {
                ["Stimulate Resistance"] = true,
                ["Stimulate Regeneration"] = true,
            }
        },
        ["The Necrotic Wake"] ={
            ["Amarth"] ={["Necrotic Bolt"] = true,},
            ["Skeletal Marauder"] ={["Rasping Scream"] = true,},
            ["Stitching Assistant"]={["Drain Fluids"] = true,},
            ["Corpse Harvester"] = {["Drain Fluids"] = true,},
            ["Corpse Collector"] = {["Drain Fluids"] = true,},
            ["Nar'zudah"] = {["Necrotic Bolt"] = true,},
            ["Zolramus Gatekeeper"] = {["Necrotic Bolt"] = true,},
            ["Zolramus Necromancer"] = {["Necrotic Bolt"] = true,},
            ["Zolramus Sorcerer"] = {["Necrotic Bolt"] = true,},
        },
        ["De Other Side"] ={
            ["Atal'ai Deathwalker"] ={["Bladestorm"] = true,},
            ["Atal'ai Devoted"] ={["Devoted Sacrifice"] =true,},
            ["Atal'ai High Priest"]={["Heal"] = true,},
            ["Atal'ai Hoodoo Hexxer"]={["Healing Wave"]=true,},
            ["Lubricator"]={["Self-Cleaning Cycle"]=true,},
        },
        ["Sanguine Depths"] ={
            ["Kryxis the Voracious"]={["Hungering Drain"] =true,},
            ["Wicked Oppressor"]={["Wrack Soul"] = true,},
            ["Chamber Sentinel"]={["Stoneskin"]=true,},
        },
        ["Halls of Atonement"]={
            ["Depraved Houndmaster"]={["Loyal Beasts"]=true,},
            ["Depraved Collector"]={["Collect Sins"]=true,},
            ["Stoneborn Reaver"]={["Turn to Stone"]=true,},
            ["High Adjudicator Aleez"]={["Volley of Power"]=true,},
        },
        ["Plaguefall"]={
            ["Fungi Stormer"]={["Fungistorm"]=true},
            ["Defender of Many Eyes"]={["Bulwark of Maldraxxus"]=true,},
            ["Rotmarrow Slime"]={["Corrosive Gunk"]=true,},
        },
        ["Spires of Ascension"]={
            ["Forsworn Mender"]={["Forsworn Doctrine"]=true,},
            ["Forsworn Castigator"]={["Burden of Knowledge"]=true,},
            ["Forsworn Goliath"]={["Rebellious Fist"]=true,},
            ["Forsworn Champion"]={["Forsworn Doctrine"]=true,},
            ["Forsworn Warden"]={["Greater Mending"]=true,},
            ["Forsworn Justicar"]={["Forced Confession"]=true,},
        },
        ["Theater of Pain"]={
            ["Battlefield Ritualist"]={["Unholy Fervor"]=true,},
            ["Dokigg the Brutalizer"]={["Battle Trance"]=true,},
            ["Harugia the Bloodthirsty"]={["Battle Trance"]=true,},
            ["Ancient Captain"]={["Demoralizing Shout"]=true,},
            ["Xav the Unfallen"]={["Deafening Crash"]=true,},
            ["Blighted Sludge-Spewer"]={["Withering Discharge"]=true,},
            ["Bone Magus"]={["Bone Spear"]=true,},
            ["Maniacal Soulbinder"]={["Necrotic Bolt Volley"]=true,},
        }
    }
    IROVar.CareInterrupt = function(nUnit)
        if not IROVar.MobListForInterrupt[IROVar.InstanceName] then
            return true
        end
        local MobName=UnitName(nUnit)
        if not MobName then return true end
        if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName] then
            return true
        end
        local SName = UnitCastingInfo(nUnit)
        if not SName then SName = UnitChannelInfo(nUnit) end
        if not SName then return false end
        return IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName]==true
    end
end

