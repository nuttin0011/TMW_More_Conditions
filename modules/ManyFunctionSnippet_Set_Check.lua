-- Many Function Rogue 9.2.0/1

--function IROVar.SetCheck.Value() -- return n of set

if not IROVar then IROVar={} end
if not IROVar.SetCheck then IROVar.SetCheck={} end
-- 253 254 255 = hunter
--[Godstalker's Sallet][Godstalker's Pauldrons][Godstalker's Hauberk][Godstalker's Gauntlets][Godstalker's Tassets]
--IROSpecID = GetSpecializationInfo(GetSpecialization())
if not IROSpecID then IROSpecID = GetSpecializationInfo(GetSpecialization()) end
IROVar.SetCheck.Checked=false
IROVar.SetCheck[253]={
    "Godstalker's Sallet",
    "Godstalker's Pauldrons",
    "Godstalker's Hauberk",
    "Godstalker's Gauntlets",
    "Godstalker's Tassets"
}
IROVar.SetCheck[254]=IROVar.SetCheck[253]
IROVar.SetCheck[255]=IROVar.SetCheck[253]

function IROVar.SetCheck.ResetCheck(...)
    IROVar.SetCheck.Checked=false
end

IROVar.SetCheck.FResetCheck=CreateFrame("Frame")
IROVar.SetCheck.FResetCheck:RegisterEvent("BAG_UPDATE")
IROVar.SetCheck.FResetCheck:RegisterEvent("UNIT_INVENTORY_CHANGED", "player")
IROVar.SetCheck.FResetCheck:SetScript("OnEvent", IROVar.SetCheck.ResetCheck)

function IROVar.SetCheck.Value() -- return n of set
    if IROVar.SetCheck.Checked then return IROVar.SetCheck.Checked end
    local num=0
    for i=1,5 do
        if IsEquippedItem(IROVar.SetCheck[IROSpecID][i]) then
            num=num+1
        end
    end
    IROVar.SetCheck.Checked=num
    return num
end
