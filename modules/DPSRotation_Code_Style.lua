--DPSRotation_Code_Style Base Template v1
--*****Set Priority to 2
--*****Set DPSRotation of Class to 3

IROVar.CastIcon1 = "ff000000"
IROVar.CastIcon2 = "ff000000"
IROVar.CastIcon3 = "ff000000"

function IROVar.Cast1(s)
    IROVar.CastIcon1 = IUSC.SpellToColor and IUSC.SpellToColor[s] or "ff000000"
end
function IROVar.Cast2(s)
    IROVar.CastIcon2 = IUSC.SpellToColor and IUSC.SpellToColor[s] or "ff000000"
end
function IROVar.Cast3(s)
    IROVar.CastIcon3 = IUSC.SpellToColor and IUSC.SpellToColor[s] or "ff000000"
end