
-- icon 1
function(event,color1)
    if not color1 then return true end
    local div255=GeRODPS.div255
    local r=div255[tonumber(string.sub(color1,3,4),16)]
    local g=div255[tonumber(string.sub(color1,5,6),16)]
    local b=div255[tonumber(string.sub(color1,7,8),16)]
    local a=1
    if not aura_env.GeROsubRegions then
        for k,v in pairs(aura_env.region.subRegions) do
            if v.type=="subborder" then
                aura_env.GeROsubRegions=aura_env.region.subRegions[k]
                break
            end
        end
    end
    aura_env.GeROsubRegions:SetBorderColor(r,g,b,a)
    return true
end






-- icon 2
function(event,color1,color2)
    if not color2 then return true end
    local div255=GeRODPS.div255
    local r=div255[tonumber(string.sub(color2,3,4),16)]
    local g=div255[tonumber(string.sub(color2,5,6),16)]
    local b=div255[tonumber(string.sub(color2,7,8),16)]
    local a=1
    if not aura_env.GeROsubRegions then
        for k,v in pairs(aura_env.region.subRegions) do
            if v.type=="subborder" then
                aura_env.GeROsubRegions=aura_env.region.subRegions[k]
                break
            end
        end
    end
    aura_env.GeROsubRegions:SetBorderColor(r,g,b,a)
    return true
end



-- icon 3
function(event,color1,color2,color3)
    if not color3 then return true end
    local div255=GeRODPS.div255
    local r=div255[tonumber(string.sub(color3,3,4),16)]
    local g=div255[tonumber(string.sub(color3,5,6),16)]
    local b=div255[tonumber(string.sub(color3,7,8),16)]
    local a=1
    if not aura_env.GeROsubRegions then
        for k,v in pairs(aura_env.region.subRegions) do
            if v.type=="subborder" then
                aura_env.GeROsubRegions=aura_env.region.subRegions[k]
                break
            end
        end
    end
    aura_env.GeROsubRegions:SetBorderColor(r,g,b,a)
    return true
end








