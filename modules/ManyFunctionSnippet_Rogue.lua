-- Many Function Rogue 9.0.5/1

--function IROVar.Rogue.UpdateRTBBuff() ; return count , update IROVar.Rogue.RTBBuff table
--function IROVar.Rogue.NeedRTB() ; return true / false

if not IROVar then IROVar={} end
if not IROVar.Rogue then IROVar.Rogue={} end

IROVar.Rogue.RTBBuffName={
    ["Broadside"]=true,
    ["True Bearing"]=true,
    ["Ruthless Precision"]=true,
    ["Skull and Crossbones"]=true,
    ["Buried Treasure"]=true,
    ["Grand Melee"]=true,
}

IROVar.Rogue.RTBBuff={} -- keep RTB status
IROVar.Rogue.RTBBuff.count=0
IROVar.Rogue.RTBBuff.expireTime=0

function IROVar.Rogue.UpdateRTBBuff()
    local now=GetTime()
    if IROVar.Rogue.RTBBuff.expireTime>now then return IROVar.Rogue.RTBBuff.count end
    local count=0
    IROVar.Rogue.RTBBuff={}
    IROVar.Rogue.RTBBuff.expireTime=0
    for i=1,40 do
        local name, _, _, _, _, exTime=UnitBuff("player",i,"PLAYER")
        if not name then
            break
        else
            if IROVar.Rogue.RTBBuffName[name] and ((exTime-now)>1) then
                count=count+1
                IROVar.Rogue.RTBBuff[name]=true
                IROVar.Rogue.RTBBuff.expireTime=exTime-1
            end
        end
    end
    IROVar.Rogue.RTBBuff.count=count
    return count
end

function IROVar.Rogue.NeedRTB()
    -- CD Roll the Bones > 0 --> false
    if TMW.CNDT.Env.CooldownDuration("Roll the Bones") > 0 then return false end

    if (IROVar.Rogue.RTBBuff.count==0) or (IROVar.Rogue.RTBBuff.expireTime<GetTime()) then
        IROVar.Rogue.UpdateRTBBuff()
    end
    if IROVar.Rogue.RTBBuff.count==0 then return true end

    -- >3 buff --> false
    if (IROVar.Rogue.RTBBuff.count>=3) then
        return false
    end

    -- 2 buff --> false
    -- 2 buff and buff is "Grand Melee+Buried Treasure" --> true
    if IROVar.Rogue.RTBBuff.count==2 then
        return IROVar.Rogue.RTBBuff["Grand Melee"] and IROVar.Rogue.RTBBuff["Buried Treasure"]
    end

    -- SoHConduit + 1 buff --> true
    if IROVar.activeConduits["Sleight of Hand"] then return true end

    -- 1 buff + Broadside/True Bearing --> false
    return not(IROVar.Rogue.RTBBuff["Broadside"] or IROVar.Rogue.RTBBuff["True Bearing"])

end
