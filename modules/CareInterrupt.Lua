-- Care Interrupt V 1.85 ICON
-- interrupt Only Important Spell at Specific Mob
-- IROVar.CareInterrupt(unit e.g. "target") ; return true / false
-- IROVar and IROVar.CareInterrupt and IROVar.CareInterrupt("target")

-- Combo %Cast+Care Interrupt+Smart Interrupt
--[[
    PercentCastbar2 and IROVar and IROVar.CareInterrupt and
    PercentCastbar2()and IROVar.CareInterrupt("target")and
    ((not NextInterrupter) or NextInterrupter.IsMyTurn())
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
if not IROVar.MobListForInterrupt then
    --[[
        [instance name]={[mob name]={[spell name] = true / lua scrip}} interrupt ONLY Spell in list on this mob
        [instance name]={[mob name]=false} NEVER interrupt all spell on this mob
    ]]
    IROVar.MobListForInterrupt = {
        ["Mists of Tirna Scithe"] = {
            ["Ingra Maloch"] = {["Spirit Bolt"] = true,},
            ["Mistcaller"] = {["Patty Cake"] = true,},
            ["Tred'ova"] = {
                ["Parasitic Pacification"] = true,
                ["Parasitic Incapacitation"] = true,
                ["Parasitic Domination"] = true,
                ["Consumption"] = [[return TMW.CNDT.Env.AuraDur("target", "gorging shield", "HELPFUL")==0]],
            },
            ["Drust Harvester"] = {["Harvest Essence"] = true,},
            ["Mistveil Tender"] = {["Nourish the Forest"] = true,},
            ["Mistveil Shaper"] = {["Bramblethorn Coat"] = true,},
            ["Mistveil Guardian"] = {["Bucking Rampage"] = true,},
            ["Spinemaw Staghorn"] = {
                ["Stimulate Resistance"] = true,
                ["Stimulate Regeneration"] = true,
            },
            ["Spinemaw Acidgullet"] = {["Volatile Acid"] = true,},
            ["Spinemaw Gorger"] = {["Acid Globule"] = true,},
        },
        ["The Necrotic Wake"] ={
            ["Corpse Harvester"] = {["Drain Fluids"] = true,},
            ["Amarth"] ={["Necrotic Bolt"] = true,},
            ["Skeletal Marauder"] ={["Rasping Scream"] = true,},
            ["Nar'zudah"] = {["Necrotic Bolt"] = true,},
            ["Corpse Collector"] = {["Drain Fluids"] = true,},
            ["Loyal Creation"] = {["Spine Crush"] = true,},
            ["Stitching Assistant"]={["Drain Fluids"] = true,},
            ["Zolramus Gatekeeper"] = {["Necrotic Bolt"] = true,},
            ["Zolramus Necromancer"] = {["Necrotic Bolt"] = true,},
            ["Zolramus Sorcerer"] = {["Necrotic Bolt"] = true,},
            ["Reanimated Mage"] = {["Frostbolt Volley"] = true,},
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
            ["Vestige of Doubt"]={["Growing Mistrust"]=true,},
        },
        ["Halls of Atonement"]={
            ["Depraved Houndmaster"]={["Loyal Beasts"]=true,},
            ["Depraved Obliterator"]={["Curse of Obliteration"]=true,},
            ["Depraved Collector"]={["Collect Sins"]=true,},
            ["Stoneborn Reaver"]={["Turn to Stone"]=true,},
            ["High Adjudicator Aleez"]={["Volley of Power"]=true,},
        },
        ["Plaguefall"]={
            ["Fungi Stormer"]={["Fungistorm"]=true},
            ["Defender of Many Eyes"]={["Bulwark of Maldraxxus"]=true,},
            ["Brood Ambusher"]={["Stealthlings"]=true,},
            ["Plaguebinder"]={["Gripping Infection"]=true,},
            ["Rotmarrow Slime"]={["Corrosive Gunk"]=true,},
        },
        ["Spires of Ascension"]={
            ["Forsworn Mender"]={["Forsworn Doctrine"]=true,},
            ["Forsworn Castigator"]={["Burden of Knowledge"]=true,},
            ["Forsworn Goliath"]={["Rebellious Fist"]=true,},
            ["Forsworn Champion"]={["Forsworn Doctrine"]=true,},
            ["Forsworn Warden"]={["Greater Mending"]=true,},
            ["Forsworn Justicar"]={["Forced Confession"]=true,},
            ["Forsworn Inquisitor"]={["Internal Strife"]=true,},
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
            ["Sathel the Accursed"]={["Necromantic Bolt"]=[[return TMW.CNDT.Env.AuraDur("target", "one with death", "HELPFUL")==0]]},
        },
        ["Castle Nathria"]={
            ["Stoneborn Maitre D'"]={["Dinner Bell"]=true}
        },
        ["The Shadowlands"]={
            ["Mawsworn Myrmidon"]={["Horrifying Shout"]=true}
        },

    }
    IROVar.CareInterrupt = function(nUnit)
        if not IROVar.MobListForInterrupt[IROVar.InstanceName] then
            return true
        end
        local MobName=UnitName(nUnit)
        if not MobName then return true end
        if IROVar.MobListForInterrupt[IROVar.InstanceName][MobName]==nil then return true end
        if IROVar.MobListForInterrupt[IROVar.InstanceName][MobName]==false then return false end
        local SName = UnitCastingInfo(nUnit)
        if not SName then SName = UnitChannelInfo(nUnit) end
        if not SName then return false end
        if not IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName] then return false end
        return (IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName]==true) and true or
            loadstring(IROVar.MobListForInterrupt[IROVar.InstanceName][MobName][SName])()
    end
end

