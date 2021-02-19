if not TMW then return end
local TMW = TMW

local VIEW_IDENTIFIER = "test"
local ICON_SIZE = 30

local View = TMW.Classes.IconView:New(VIEW_IDENTIFIER)

View.name = "Test View"
View.desc = "An Icon View created to demonstrate the TMW IconView API"

View:RegisterIconDefaults{
	SettingsPerView = {
		[VIEW_IDENTIFIER] = {
			-- Icon defaults would go here
		}
	}
}

View:RegisterGroupDefaults{
	SettingsPerView = {
		[VIEW_IDENTIFIER] = {
		
			-- "icon1" is the default text layout for the "icon" IconView. We will use it since it will mostly suit our purposes.
			TextLayout = "icon1",
			
			-- Default icon size
			SizeX = ICON_SIZE,
			SizeY = ICON_SIZE,
		}
	}
}

View:ImplementsModule("IconModule_Alpha", 10, true)
View:ImplementsModule("IconModule_Texts", 60, true)
View:ImplementsModule("IconModule_Texture_Colored", 30, function(Module, icon)
	Module:Enable()
	Module.texture:ClearAllPoints()
	Module.texture:SetAllPoints(icon)
end)

View:ImplementsModule("GroupModule_Resizer_ScaleY_SizeX", 10, true)

function View:Icon_Setup(icon)
	local group = icon.group
	local gspv = group:GetSettingsPerView()
	
	icon:SetSize(gspv.SizeX, gspv.SizeY)
end

function View:Group_Setup(group)
	local gs = group:GetSettings()
	local gspv = group:GetSettingsPerView()
	
	group:SetSize(gs.Columns * (gspv.SizeX + gspv.SpacingX) - gspv.SpacingX,
				  gs.Rows * (gspv.SizeY + gspv.SpacingY) - gspv.SpacingY)
end

function View:Icon_GetSize(icon)
	local group = icon.group
	local gspv = group:GetSettingsPerView()
	
	return gspv.SizeX, gspv.SizeY
end

function View:Group_OnCreate(gs)
	gs.Rows, gs.Columns = 2, 2
end

View:Register(20)