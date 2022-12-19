--local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo(unit)


(function()

local _,_,_,_,endTimeMS=UnitCastingInfo("player")
endTimeMS=endTimeMS or 0
endTimeMS=endTimeMS/1000
local CastOverRS=(endTimeMS+0.2)>IROVar.DruidBalance.RSend
local CanCastSS=IsUsableSpell("Starsurge")

return CastOverRS and CanCastSS

end)()