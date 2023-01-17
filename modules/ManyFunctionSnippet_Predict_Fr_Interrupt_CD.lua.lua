-- ManyFunctionSnippet_Predict_Fr_Interrupt_CD 10.0.2/1

-- Set Priority to 5

-- Change Pet event UNIT_PET
-- GROUP_ROSTER_UPDATE
-- Out_Combat

local FrInterStatus={}
-- [GUID]=Last time interrupt used!

local interruptSpell={
	--[Spell]=CD,
    ['Spear Hand Strike']=15,
    ['Skull Bash']=15,
    ['Solar Beam']=60,
    ['Spell Lock']=24,
    ['Axe Toss']=30,
    ['Pummel']=15,--15,14 talent
    ['Wind Shear']=12,
    ['Kick']=15,
    ['Silence']=45,--45,30 talent
    ['Rebuke']=15,
    ['Counterspell']=24, --24,20 if success/talent
    ['Counter Shot']=24,
    ['Muzzle']=15,
    ['Disrupt']=15,
    ['Mind Freeze']=15, -- 15,12 if success/talent
    ['Quell']=40, -- 40,20 talent
}
local PetSpell ={
    ['Spell Lock']=true,
    ['Axe Toss']=true,
}
