-- Combine Icon
local icon = ...
local IROcode1=getMetaIconColor(IROIcon1)
local IROcode2=getMetaIconColor(IROIcon2)
local IROcode3=getMetaIconColor(IROIcon3)
local cc=enMiniIROcode(IROcode1,IROcode2,IROcode3)

--Sum Colour 3 icon
if icon.States[1].Color~=cc then
    if EROSumIcon1 then
        EROSumIcon1.States[1].Color=cc
    end
    if EROSumIcon2 then
        EROSumIcon2.States[1].Color=cc
    end 
    if TMW_ST:GetCounter("sumicon")==0
    then
        TMW_ST:UpdateCounter("sumicon",1)
    else
        TMW_ST:UpdateCounter("sumicon",0)
    end
end























