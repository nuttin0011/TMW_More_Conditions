--DPSRotation_Code_WarFury v1
--*****Set DPSRotation of Class to 3



local rage=UnitPower("player",1)

if TMW.CNDT.Env.CooldownDuration("Mortal Strike")<=0.3 and rage>= 30 then
    IROVar.Cast1("Mortal Strike")
elseif rage>= 50 then
    IROVar.Cast1("Slam")
else
    IROVar.Cast1("---")
end
