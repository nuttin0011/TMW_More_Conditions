--

local c="wanthavoc" local a=TMW_ST:GetCounter(c) a=a+1 a=a>2 and 0 or a TMW_ST:UpdateCounter(c,a)