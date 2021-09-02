
local MAdd="/cast [mod:ctrlaltshift,@raid12]Shadow Word: Death;[mod:ctrlalt,@player]Shadow Word: Death;[mod:ctrlshift,@raid13]Shadow Word: Death;[mod:altshift,@raid14]Shadow Word: Death;[mod:ctrl,@party1]Shadow Word: Death;[mod:alt,@party2]Shadow Word: Death"

local MSub="/cast [mod:ctrlaltshift,@raid16];[mod:ctrlalt,@party4];[mod:ctrlshift,@raid17];[mod:altshift,@raid18];[mod:ctrl,@raid1];[mod:alt,@raid2];[mod:shift,@raid19];[nomod,@raid3];"

local MMul="/cast [mod:ctrlaltshift];[mod:ctrlalt,@raid4];[mod:ctrlshift,@raid20];[mod:altshift,@raid21];[mod:ctrl,@raid5];[mod:alt,@raid6];[mod:shift,@raid22];[nomod,@raid7];"

local MDiv="/cast [mod:ctrlaltshift,@raid23];[mod:ctrlalt,@raid8];[mod:ctrlshift,@raid24];[mod:altshift,@raid25];[mod:ctrl,@raid9];[mod:alt,@raid10];[mod:shift,@raid26];[nomod,@raid11];"


if not IROVar then IROVar={} end
if not IROVar.Healer then IROVar.Healer={} end
IROVar.Healer.UnitToIRO={
['player']='ff033b03',
['party1']='ff013b01',
['party2']='ff023b02',
['party3']='ff003b00',
['party4']='ff033c03',
['raid1']='ff013c01',
['raid2']='ff023c02',
['raid3']='ff003c00',
['raid4']='ff033d03',
['raid5']='ff013d01',
['raid6']='ff023d02',
['raid7']='ff003d00',
['raid8']='ff033e03',
['raid9']='ff013e01',
['raid10']='ff023e02',
['raid11']='ff003e00',
['raid12']='ff073b07',
['raid13']='ff053b05',
['raid14']='ff063b06',
['raid15']='ff043b04',
['raid16']='ff073c07',
['raid17']='ff053c05',
['raid18']='ff063c06',
['raid19']='ff043c04',
['raid20']='ff053d05',
['raid21']='ff063d06',
['raid22']='ff043d04',
['raid23']='ff073e07',
['raid24']='ff053e05',
['raid25']='ff063e06',
['raid26']='ff043e04',
}



local MAdd="/cast [mod:ctrlaltshift,@party4target]Flayed Shot;[mod:ctrlalt,@party3target]Flayed Shot;[mod:ctrlshift,@party2target]Flayed Shot;[mod:altshift,@party1target]Flayed Shot;[mod:ctrl,@focus]Flayed Shot;[mod:alt,@mouseover]Flayed Shot"