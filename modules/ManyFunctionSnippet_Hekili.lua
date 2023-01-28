-- Many Function Version Hekili addon 10.0.5/1
-- Set Priority to 5

-- function IROVar.Hekili.Register_Skill(table_of_skill)
--[[
    table_of_skill={
        ["Hekili_Skill_Name"]="Skill Name",
        ...
    }
]]
-- function IROVar.Hekili.GetSkill() -- return Skill in Skill name (case sensitive)

if not IROVar then IROVar={} end
if not IROVar.Hekili then IROVar.Hekili={} end

local Hekili=Hekili
local HekiliToSpell={}

if not Hekili then
    print("need Addon Hekili Priority Helper to process!!!!!!!")
end

function IROVar.Hekili.Register_Skill(table_of_skill)
    for k,v in pairs(table_of_skill) do
        HekiliToSpell[k]=v
    end
end

--[[
Hekili.DisplayPool.Primary.Recommendations[1].actionName
Hekili.DisplayPool.Primary.Recommendations[2].actionName
Hekili.DisplayPool.Primary.Recommendations[3].actionName
]]

function IROVar.Hekili.GetSkill()
    for i=1,6 do
        if Hekili.DisplayPool.Primary.Recommendations[i] then
            local skillname=Hekili.DisplayPool.Primary.Recommendations[i].actionName
            local skill=HekiliToSpell[skillname]
            if skill then
                return skill
            else
                if skillname then
                    print("Hekili skill Not Found:",skillname)
                end
            end
        end
    end
    return nil
end

local skill={
    ["instant_poison"]="Instant Poison",
    ["crippling_poison"]="Crippling Poison",
    ["stealth"]="Stealth",
    ["roll_the_bones"]="Roll the Bones",
    ["sinister_strike"]="Sinister Strike",
    ["blade_flurry"]="Blade Flurry",
    ["between_the_eyes"]="Between the Eyes",
    ["slice_and_dice"]="Slice and Dice",
    ["dispatch"]="Dispatch",
    ["pistol_shot"]="Pistol Shot",
    ["ambush"]="Ambush",
    ["vanish"]="Vanish",
    ["ghostly_strike"]="Ghostly Strike",
    ["marked_for_death"]="Marked for Death",
    ["blade_rush"]="Blade Rush",
    ["killing_spree"]="Killing Spree",
    ["dreadblades"]="Dreadblades",
    ["keep_it_rolling"]="Keep It Rolling",
    ["sepsis"]="Sepsis",
    ["thistle_tea"]="Thistle Tea",
    ["cold_blood"]="Cold Blood",
    ["adrenaline_rush"]="Adrenaline Rush",
}
IROVar.Hekili.Register_Skill(skill)