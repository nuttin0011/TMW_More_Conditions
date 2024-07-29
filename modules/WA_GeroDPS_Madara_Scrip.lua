
GeRODPS=GeRODPS
Hekili=Hekili

--GeRODPS.CastSkill(skill,delay,icon,condition,timeout)
-- Hekili.State.action.cloak_of_shadows.name
function GeRODPS.notifyAuras(id,text)
    if GeRODPS.notify_aura_active then print(GeRODPS.time.." "..id.." : activated"..(text or ""))end
end


GeRODPS.hekiliName2Wow={}
local mt={
    __index = function(table, key)
       if not rawget(table, key) then
          rawset(table, key, Hekili.State.action[key].name)
          return rawget(table, key)
       else
          return rawget(table, key)
       end
    end
}
setmetatable(GeRODPS.hekiliName2Wow,mt)

function GeRODPS.RogueDef(id,skillSet)
    if not GeRODPS.Options.Def then return end
    --skillSet= { setN={skillN={HekiliName,delay,Button,condition,callback after use skill}...}...}
    local t1=GeRODPS.time.." "..id.." : "
    local t2=""
    local casted=false
    for _,Set in ipairs(skillSet) do
        for _,Skill in ipairs(Set) do
            if GeRODPS.CDReady(GeRODPS.hekiliName2Wow[Skill[1]]) then
                t2=t2..Skill[1].." ready, "
                GeRODPS.CastSkill(Skill[1],Skill[2],Skill[3],Skill[4])
                if Skill[5] then Skill[5]() end
                casted=true
            else
                t2=t2..Skill[1].." CD, "
            end
        end
        if casted then break end
    end
    if not casted then t2=t2.."NONE skill" end
    if GeRODPS.notify_aura_active then print(t1..t2)end
end

GeRODPS.RogueDef(aura_env.id,{{{"cloak_of_shadows",0,2}},{{"feint",0,1,function() return AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")==nil end},{"evasion",0,2}}})

GeRODPS.RogueDef("HEE",{{{"cloak_of_shadows",0,2}},{{"feint",0,1,function() return AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")==nil end},{"evasion",0,2}}})

--[[function GeRODPS.RogueDef_CoS_FeintEvasion(id)
    if GeRODPS.Options.Def then
        if GeRODPS.CDReady("Cloak of Shadows") then
            GeRODPS.notifyAuras(id,"CoS ready Use CoS")
            GeRODPS.CastSkill("cloak_of_shadows",0,2)
        else
            local t="CoS CD "
            if GeRODPS.CDReady("Feint") then
                t=t.."Use Feint "
                GeRODPS.CastSkill("feint",0,1,function() return AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")==nil end)
            else
                t=t.."Feint CD "
            end
            if GeRODPS.CDReady("Evasion") then
                t=t.."Use Evasion"
                GeRODPS.CastSkill("evasion",0,2)
            else
                t=t.."Evasion CD"
            end
            GeRODPS.notifyAuras(id,t)
        end
    end
end]]

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"cloak_of_shadows",0,2}
        },
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
            {"evasion",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("cloak_of_shadows",3)end}
        },
        {
            {"cloak_of_shadows",0,2}
        },
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
            {"evasion",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("evasion",3)end}
        },
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
            {"evasion",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"cloak_of_shadows",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"evasion",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"evasion",0,2,nil,function()GeRODPS.DelaySkill("shadowmeld",3)end}
        },
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("evasion",3)end}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("evasion",3)end}
        },
        {
            {"evasion",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("cloak_of_shadows",3)end}
        },
        {
            {"cloak_of_shadows",0,2}
        }
    }
)


GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("feint",3)end}
        },
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
            {"evasion",0,2}
        }
    }
)


GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"shadowmeld",0,2,nil,function()GeRODPS.DelaySkill("vanish",3)end}
        },
        {
            {"vanish",0,2,nil,function()GeRODPS.DelaySkill("evasion",3)end}
        },
        {
            {"feint",0,1,function() return (select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2 end},
            {"evasion",0,2}
        }
    }
)

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"sprint",0,3},
            {"shadowstep",0,2}
        }
    }
)




if not GeRODPS.Options.NotUseOutlawGrappling then
    GeRODPS.notifyAuras(aura_env.id)
    GeRODPS.CastSkill("grappling_hook",0,2)
end


if GeRODPS.Options.Def then
    GeRODPS.notifyAuras(aura_env.id)
    GeRODPS.CastSkill("tranquilizing_shot",0,1)
end

GeRODPS.RogueDef(aura_env.id,
    {
        {
            {"tranquilizing_shot",0,1},
        }
    }
)




if GeRODPS.Options.Def then
    GeRODPS.notifyAuras(aura_env.id,"tranquilizing_shot")
    GeRODPS.CastSkill("tranquilizing_shot",0.5,1,function() return AuraUtil.FindAuraByName("Energy Surge","boss1","HELPFUL")~=nil end,3)
end

aura_env.state.sourceGUID


--if UnitGUID("target")~=aura_env.state.sourceGUID then
        --aura_env.state.sourceGUID
if not UnitIsUnit("target",aura_env.state.unit) then
    do
        local tGUID=UnitGUID(aura_env.state.unit)
        GeRODPS.TargetEnemy.RegisterTargetting(tGUID,
            100,
            function()
                return Hekili.npUnits[tGUID]==nil or
                UnitGUID("target")==tGUID or
                UnitCastingInfo(Hekili.npUnits[tGUID])==nil
            end,
            "target For tranquilizing_shot",
        3.5)
    end
end



(select(6,AuraUtil.FindAuraByName("Feint","player","HELPFUL|PLAYER")) or GeRODPS.time)-GeRODPS.time<2