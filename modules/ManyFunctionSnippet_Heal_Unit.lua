
-- function IROVar.Healer.UnitToIROCode(unit)
if not IROVar then IROVar={} end
if not IROVar.Healer then IROVar.Healer={} end
IROVar.Healer.UnitToIRO={
    ['player']='ff073b07',
    ['party1']='ff033b03',
    ['party2']='ff053b05',
    ['party3']='ff063b06',
    ['party4']='ff013b01',
    ['raid1']='ff023b02',
    ['raid2']='ff043b04',
    ['raid3']='ff003b00',
    ['raid4']='ff073c07',
    ['raid5']='ff033c03',
    ['raid6']='ff053c05',
    ['raid7']='ff063c06',
    ['raid8']='ff013c01',
    ['raid9']='ff023c02',
    ['raid10']='ff043c04',
    ['raid11']='ff003c00',
    ['raid12']='ff033d03',
    ['raid13']='ff053d05',
    ['raid14']='ff063d06',
    ['raid15']='ff013d01',
    ['raid16']='ff023d02',
    ['raid17']='ff043d04',
    ['raid18']='ff003d00',
    ['raid19']='ff073e07',
    ['raid20']='ff033e03',
    ['raid21']='ff053e05',
    ['raid22']='ff063e06',
    ['raid23']='ff013e01',
    ['raid24']='ff023e02',
    ['raid25']='ff043e04',
    ['raid26']='ff003e00',
}

--[[ this color use this set macro

NumpadAdd
/focus [mod:ctrlaltshift,@player];[mod:ctrlalt,@party1];[mod:ctrlshift,@party2];[mod:altshift,@party3];[mod:ctrl,@party4];[mod:alt,@raid1];[mod:shift,@raid2];[nomod,@raid3];

NumpadSub
/focus [mod:ctrlaltshift,@raid4];[mod:ctrlalt,@raid5];[mod:ctrlshift,@raid6];[mod:altshift,@raid7];[mod:ctrl,@raid8];[mod:alt,@raid9];[mod:shift,@raid10];[nomod,@raid11];

NumpadMult
/focus [mod:ctrlaltshift];[mod:ctrlalt,@raid12];[mod:ctrlshift,@raid13];[mod:altshift,@raid14];[mod:ctrl,@raid15];[mod:alt,@raid16];[mod:shift,@raid17];[nomod,@raid18];

NumpadDiv
/focus [mod:ctrlaltshift,@raid19];[mod:ctrlalt,@raid20];[mod:ctrlshift,@raid21];[mod:altshift,@raid22];[mod:ctrl,@raid23];[mod:alt,@raid24];[mod:shift,@raid25];[nomod,@raid26];

]]

function IROVar.Healer.UnitToIROCode(unit)
    if not unit then return "ff000000" end
    local c=IROVar.Healer.UnitToIRO[unit]
    if not c then return "ff000000" end
    return c
end

