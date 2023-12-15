-- Key Setting...
local Nm={}


Nm[0]="/cast [mod:ctrlalt]kill command;[mod:ctrl]Crimson Vial;[mod:alt]Regrowth;[nomod]Impending Victory\n/run IROVar.DelayCT('justclickheal',1)"
Nm[1]="/cast [mod:ctrlalt]Healing Surge;[mod:ctrl]Death Strike;[mod:alt,@player]Word of Glory;[nomod]Dark Pact\n/run IROVar.DelayCT('justclickheal',1)"
Nm[2]="/cast [mod:ctrlalt]Expel Harm;[mod:ctrl]Vivify;[mod:alt]Ice Barrier;[nomod]Blazing Barrier\n/run IROVar.DelayCT('justclickheal',1)"
Nm[3]="/cast [mod:ctrlalt]Prismatic Barrier;[mod:ctrl]Power Word: Shield;[mod:alt]Renewal;[nomod]Whirlwind\n/run IROVar.DelayCT('justclickheal',1)"
Nm[4]="/cast [mod:ctrlalt];[mod:ctrl]Tranquilizing Shot;[mod:alt]Shiv;[nomod]Purge"
Nm[5]="/cast [mod:ctrlalt]Defensive Stance;[mod:ctrl]Intimidation;[mod:alt]Berserker Rage;[spec:1]battle stance;[spec:2]berserker stance"
Nm[6]="/cast [mod:ctrlalt]Soothe;[mod:ctrl]Storm Bolt;[mod:alt]Spell Reflection;[nomod]Ignore Pain"
Nm[7]="/cast [mod:ctrlalt]Revive Pet;[mod:ctrl]Escape Artist;[mod:alt]Mend Pet;[nomod]Will to Survive"
Nm[8]="/cast [mod:ctrlalt]Command Pet;[mod:ctrl]Gift of the Naaru;[mod:alt];[nomod]\n/run IUSC.SU('38')"
Nm[9]="/cast [mod:ctrlalt];[mod:ctrl];[mod:alt];[nomod]\n/run IUSC.SU('39')"
Nm[10]="/cast [mod:ctrlalt];[mod:ctrl];[mod:alt]\n/petattack [nomod]"
Nm[11]="/focus [mod:altctrl,@target,exists,harm,nodead]\n/focus [mod:ctrl,nomod:alt,@mouseover,exists,harm,nodead]\n/clearfocus [nomod]"
Nm[12]="/targetenemy [mod:ctrl]\n/cleartarget [nomod]\n/stopmacro [mod:alt][nomod]\n/stopattack\n/run IROVar.IsTargeted()"
Nm[13]="/cast [mod:ctrlalt];[mod:ctrl];[mod:alt];[nomod]\n/run IUSC.SU('3e')"



if not IROUsedSkillControl then IROUsedSkillControl={} end
IROUsedSkillControl.ColorToSpell={
    ["ff000000"]="---",
    --0
    ["ff033003"]="Exhilaration",
    ["ff013001"]="Crimson Vial",
    ["ff023002"]="Regrowth",
    ["ff003000"]="Impending Victory",
    --1
    ["ff033103"]="Healing Surge",
    ["ff013101"]="Death Strike",
    ["ff023102"]="Word of Glory",
    ["ff003100"]="Dark Pact",
    --2
    ["ff033203"]="Expel Harm",
    ["ff013201"]="Vivify",
    ["ff023202"]="Ice Barrier",
    ["ff003200"]="Blazing Barrier",
    --3
    ["ff033303"]="Prismatic Barrier",
    ["ff013301"]="Power Word: Shield",
    ["ff023302"]="Renewal",
    ["ff003300"]="Whirlwind",
    --4
    ["ff033403"]="-------------",
    ["ff013401"]="Tranquilizing Shot",
    ["ff023402"]="Shiv",
    ["ff003400"]="Purge",
    --5
    ["ff033503"]="Defensive Stance",
    ["ff013501"]="Intimidation",
    ["ff023502"]="Berserker Rage",
    ["ff003500"]="battle stance/berserker stance",
    --6
    ["ff033603"]="Soothe",
    ["ff013601"]="Storm Bolt",
    ["ff023602"]="Spell Reflection",
    ["ff003600"]="Ignore Pain",
    --7
    ["ff033703"]="Revive Pet",
    ["ff013701"]="Escape Artist",
    ["ff023702"]="Mend Pet",
    ["ff003700"]="Will to Survive",
    --8
    ["ff033803"]="Command Pet",
    ["ff013801"]="Gift of the Naaru",
    ["ff023802"]="",
    ["ff003800"]="",
    --9
    ["ff033903"]="",
    ["ff013901"]="",
    ["ff023902"]="",
    ["ff003900"]="",
    --10
    ["ff033b03"]="",
    ["ff013b01"]="",
    ["ff023b02"]="",
    ["ff003b00"]="pet attack",
    --11
    ["ff033c03"]="focus target",
    ["ff013c01"]="focus mouseover",
    ["ff023c02"]="",
    ["ff003c00"]="clear focus",
    --12
    ["ff033d03"]="",
    ["ff013d01"]="targetenemy",--stopattack
    ["ff023d02"]="targetenemy",
    ["ff003d00"]="clear target",
    --13
    ["ff033e03"]="Focus MouseOver",
    ["ff013e01"]="Interrupt Focus",
    ["ff023e02"]="Interrupt Target",
    ["ff003e00"]="Use Healing Potion",
    --Dot
    ["ff013a01"]="Use Healthstone",
    ["ff023a02"]="Stop Casting",
    
}

local HealingPotionName={
    "Potion of Withering Dreams",
    "Refreshing Healing Potion",
}
function FindHealingPotion()
    for _,v in ipairs(HealingPotionName) do
        if GetItemCount(v) >= 1 then
            return v
        end
    end
    return HealingPotionName[#HealingPotionName]
end

local iS=IROVar.InterruptSpell or ""
local Nm13_1="/focus [@mouseover,exists,nodead,mod:ctrlalt]\n/cast [mod:ctrl,@focus]"..iS..";[mod:alt]"..iS.."\n/use [nomod]"
local Nm13_HealingPotion=FindHealingPotion()
local Nm13_2="\n/run IUSC.SO('3e')\n/run if IsAltKeyDown()~=IsControlKeyDown() then IROVar.KickPress() end"
Nm[13]=Nm13_1..Nm13_HealingPotion..Nm13_2

if not IROKeyButton then IROKeyButton={} end
local function SetKey(IncombatStatus)
    if InCombatLockdown() then
        if IncombatStatus then print("cannot Bind Key while Incombat") end
        C_Timer.After(1,SetKey)
    else
        if not IncombatStatus then print("Out Combat Bind Key Done!") end
        local nname
        for i,v in pairs(Nm) do
            nname='~!Num'..i
            DeleteMacro(nname)
            DeleteMacro(nname)
            if not IROKeyButton[nname] then
                IROKeyButton[nname]=CreateFrame('Button', nname, UIParent, "SecureActionButtonTemplate")
                IROKeyButton[nname]:SetAttribute("type", "macro")
                IROKeyButton[nname]:SetAttribute("macrotext", v);
                IROKeyButton[nname]:RegisterForClicks("LeftButtonDown");
            else
                IROKeyButton[nname]:SetAttribute("macrotext", v);
            end
end end end
SetKey(true)

local function ReplaceHealingPotionNemaToButton()
    if InCombatLockdown() then return end
    local p=FindHealingPotion()
    if Nm13_HealingPotion==p then return end
    Nm13_HealingPotion=p
    Nm[13]=Nm13_1..Nm13_HealingPotion..Nm13_2
    IROKeyButton['~!Num13']:SetAttribute("macrotext", Nm[13]);
end
C_Timer.NewTicker(3,ReplaceHealingPotionNemaToButton)
IROVar.RegisterOutcombatCallBackRun("ReplaceHealingPotionNemaToButton",ReplaceHealingPotionNemaToButton)

IUSC.NumToSpell={}
IUSC.NumToID={}
IUSC.IDToSpell={}

for k,v in pairs(IUSC.ColorToSpell) do
    k=string.sub(k,5,8)
    local n=tonumber(k,16)
    local N,_,_,_,_,_,id=GetSpellInfo(v)
    if N then
        IUSC.NumToSpell[n]=N
        IUSC.NumToID[n]=id
        IUSC.IDToSpell[id]=N
    else
        IUSC.NumToSpell[n]=v
        IUSC.NumToID[n]=0
    end
end

















-- ZRODPS Num Dot Setup
-- Alt + NumDot = /stopcasting
-- Ctrl + NumDot = /use Healthstone
-- NumDot = **removed in ZRO DPS**
-- When press Alt+NumDot "/stopcasting" and "IROStopCasted=true" ll run
-- that mean if "IROStopCasted==true" u dont press Alt+NumDot again.
-- and IROStopCasted=nil 0.5 sec after press Alt+Numdot

ConsoleExec("screenFlashEdge 0")
ConsoleExec("doNotFlashLowHealthWarning 1")
ConsoleExec("Gamma 1")
local M0='/stopcasting [mod:alt]\n/use [mod:ctrl]Healthstone\n/run IROPressStopCast()'

local function SetNumDotKey()
    if InCombatLockdown() then
        C_Timer.After(1,SetNumDotKey)
    else
        for i =0,9 do
            SetBindingClick('NUMPAD'..i,'~!Num'..i)
        end
        local nDname="~NumDotUsedSkill"
        TMW.CNDT.Env.IRODPSversion()
        DeleteMacro(nDname)
        DeleteMacro(nDname)
        if not IROKeyButton then IROKeyButton={} end
        if not IROKeyButton[nDname] then
            IROKeyButton[nDname]=CreateFrame('Button', nDname, UIParent, "SecureActionButtonTemplate")
            IROKeyButton[nDname]:SetAttribute("type", "macro")
            IROKeyButton[nDname]:SetAttribute("macrotext", M0);
            IROKeyButton[nDname]:RegisterForClicks("LeftButtonDown");
        else
            IROKeyButton[nDname]:SetAttribute("macrotext", M0);
        end
        SetBindingClick("NUMPADDECIMAL","~NumDotUsedSkill")
        SaveBindings(GetCurrentBindingSet())
    end
end
-- Bind +-*/
local function SetBindingAddSubMulDiv()
    if InCombatLockdown() then
        C_Timer.After(1,SetBindingAddSubMulDiv)
    else
        SetBindingClick("NUMPADMULTIPLY",'~!Num12')
        SetBindingClick("NUMPADDIVIDE",'~!Num13')
        SetBindingClick("NUMPADMINUS",'~!Num11')
        SetBindingClick("NUMPADPLUS",'~!Num10')
        SaveBindings(GetCurrentBindingSet())
    end
end

SetNumDotKey()
SetBindingAddSubMulDiv()

IROStopCastHandle=C_Timer.NewTimer(0.1,function() end)
IROPressStopCast=function()
    if not IsAltKeyDown() then return end
    IROStopCasted=true
    IROStopCastHandle:Cancel()
    IROStopCastHandle=C_Timer.NewTimer(0.5,function()
            IROStopCasted=nil
    end)
end


