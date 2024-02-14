
local config=aura_env.config

for k,v in pairs(config) do
    if type(v)=="table" then
        if not GeRODPS.Options[k] then
            GeRODPS.Options[k]={}
        end
        for k2,v2 in pairs(v) do
            GeRODPS.Options[k][k2]=v2
        end
    else
        GeRODPS.Options[k]=v
    end
end



