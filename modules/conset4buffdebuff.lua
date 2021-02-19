local TMW = TMW
local TMW_MC = TMW_More_Conditions
local CNDT = TMW.CNDT
local Env = CNDT.Env
local rc = LibStub("LibRangeCheck-2.0")

local strsplit=strsplit
local allBuffByMe=Env.allBuffByMe

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWMCBUFFDEBUFF", 13, "More Conditions Buff/Debuff", false, false)

local needLowerCaseName=true

function TMW_MC:CountBuff(nUnit,nDuration,nSetOfBuff)
    --nUnit = target e.g. "target","player"
    --nDutarion = lowerest duration to count e.g. 3
    --nSetOfDebuff = set of buff name that from c.Name e.g. ";arcane intellect;ice block;ice barrier;"
    -- NOTE. c.Name ll lower case and has ";" at first and last
    nUnit=nUnit or "target"
    nDuration=nDuration or 0
    local allBuff=allBuffByMe(nUnit,needLowerCaseName)
    local buffCheck
    local bCount =0
    if nSetOfBuff==";" then
        for k,v in pairs(allBuff) do
            bCount=bCount+1
        end       
    else
        buffCheck={TMW_MC:TMWstrsplit(nSetOfBuff)}
        for k,v in pairs(buffCheck) do
            if allBuff[v] and (allBuff[v]>=nDuration) then
                bCount=bCount+1
            end
        end
    end
    return bCount
end

function Env.IROCountBuff(nUnit,nDuration,nSetOfBuff)
    --print("c.Name2Raw :"..(tonumber(nDuration) or "nil"))
    --print(nSetOfBuff)
    return TMW_MC:CountBuff(nUnit,(tonumber(nDuration) or 0),nSetOfBuff)
end


ConditionCategory:RegisterCondition(6,  "TMWMCCOUNTBUFF", {
    text = "count my Buff that name list",
	tooltip = "count my Buff that name list.\nNOTE. buff has Same Name count as 1",
	unit=nil,
	min =0,
    range = 10,
	step =1,
    useSUG = true,
    allowMultipleSUGEntires = true,
	name = function(editbox) 
		editbox:SetTexts("buff Name To Check, can use multiple name","e.g. arcane intellect; ice block; ice barrier")
	end,
    name2 = function(editbox) 
		editbox:SetTexts("lowest duration to check (second)","e.g. 3\nleave blank = 0")
	end,
	specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},
    texttable = function(k) return (k<=1) and ((k) .." buff") or ((k) .." buffs") end,
    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator
        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = ">="
        end
    end,
    icon = "interface\\icons\\spell_holy_wordfortitude",
    tcoords = CNDT.COMMON.standardtcoords,
	funcstr = function(c, parent)
        if c.Name2=="" then
            return [[IROCountBuff(c.Unit,0,c.Name)c.Operator c.Level]]
        else
            return [[IROCountBuff(c.Unit,c.Name2Raw,c.Name)c.Operator c.Level]]
        end
    end,	

})
