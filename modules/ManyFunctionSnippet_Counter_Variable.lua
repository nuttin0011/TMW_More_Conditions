-- ManyFunctionSnippet_Counter_Variable 10.0.0/1
-- Set Priority to 6

-- counter "enemycountviii" = IROEnemyCountInRange(8)


if not IROVar then IROVar = {} end
if not IROVar.CV then IROVar.CV = {} end

--Enemy Count 8yard Counter Name
IROVar.CV.EC8Cn="enemycountviii"
--Enemy Count 8yard handler
local function EC8()
    local nn
    local c=0
    for i=1,30 do
        nn='nameplate'..i
        if UnitExists(nn) and UnitCanAttack("player",nn) then
            c=c+(IsItemInRange("item:34368",nn) and 1 or 0)
        end
        if c>=6 then break end
    end
    return c
end
IROVar.CV.EC8h=C_Timer.NewTicker(0.8,function()
    IROVar.UpdateCounter(IROVar.CV.EC8Cn,EC8())
end)

