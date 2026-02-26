-- Load the library (if not already loaded)
-- You can replace this with your actual loadstring URL
loadstring(game:HttpGet('https://raw.githubusercontent.com/PapaDusty/Serenity/refs/heads/main/serenity.lua'))()
-- Create the main window
local Window = Library:Window({
Name = "serenity.wtf",
SubTitle = "Full Example",
ExpiresIn = "Never"
})

-- Add a category separator (optional)
Window:Category("Main Features")

-- Create a page called "Combat"
local CombatPage = Window:Page({
Name = "Combat",
Icon = "136879043989014"  -- optional icon asset id
})

-- Create two sections in the Combat page (side 1 and side 2)
local AimbotSection = CombatPage:Section({
Name = "Aimbot",
Icon = "136879043989014",
Side = 1
})

local VisualsSection = CombatPage:Section({
Name = "Visuals",
Icon = "136879043989014",
Side = 2
})

-- --- Aimbot Section (side 1) ---

-- Toggle with optional colorpicker and keybind
local aimToggle = AimbotSection:Toggle({
Name = "Aimbot Enabled",
Flag = "aimbot_enabled",
Default = true,
Callback = function(value)
print("Aimbot toggled:", value)
end
})

-- Add a colorpicker to the toggle
aimToggle:Colorpicker({
Flag = "aimbot_color",
Default = Color3.fromRGB(255, 0, 0),
Callback = function(color)
print("Aimbot color changed:", color)
end
})

-- Add a keybind to the toggle
aimToggle:Keybind({
Flag = "aimbot_key",
Default = Enum.KeyCode.E,
Mode = "Toggle",  -- can be "Toggle", "Hold", "Always"
Callback = function(state)
print("Aimbot key state:", state)
end
})

-- Simple button
AimbotSection:Button({
Name = "Refresh Aimbot",
Callback = function()
print("Aimbot refreshed!")
end
})

-- Slider
AimbotSection:Slider({
Name = "Aim Smoothness",
Flag = "aim_smoothness",
Min = 0,
Max = 100,
Default = 50,
Suffix = "%",
Decimals = 1,
Callback = function(value)
print("Smoothness:", value)
end
})

-- Single-select dropdown
AimbotSection:Dropdown({
Name = "Target Priority",
Flag = "aim_priority",
Items = {"Closest", "Lowest HP", "Highest HP", "Mouse"},
Default = "Closest",
Multi = false,
Callback = function(value)
print("Priority:", value)
end
})

-- Multi-select dropdown
AimbotSection:Dropdown({
Name = "Hitboxes",
Flag = "aim_hitboxes",
Items = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
Default = {"Head", "Torso"},
Multi = true,
Callback = function(selected)
print("Selected hitboxes:", table.concat(selected, ", "))
end
})

-- Textbox (real-time)
AimbotSection:Textbox({
Name = "Custom Filter",
Flag = "aim_filter",
Placeholder = "enter player names...",
Default = "",
Finished = false,  -- if true, only updates on Enter
Numeric = false,
Callback = function(value)
print("Filter:", value)
end
})

-- --- Visuals Section (side 2) ---

-- Toggle with keybind only
local espToggle = VisualsSection:Toggle({
Name = "ESP Enabled",
Flag = "esp_enabled",
Default = true
})

espToggle:Keybind({
Flag = "esp_key",
Default = Enum.KeyCode.X,
Mode = "Hold",
Callback = function(state)
print("ESP key state:", state)
end
})

-- Another slider
VisualsSection:Slider({
Name = "ESP Transparency",
Flag = "esp_transparency",
Min = 0,
Max = 100,
Default = 20,
Suffix = "",
Decimals = 1,
Callback = function(value)
print("Transparency:", value)
end
})

-- Label with colorpicker (independent)
local espColorLabel = VisualsSection:Label("ESP Color")
espColorLabel:Colorpicker({
Flag = "esp_color",
Default = Color3.fromRGB(0, 255, 0),
Callback = function(color)
print("ESP color changed:", color)
end
})

-- Label with keybind (independent)
local espKeyLabel = VisualsSection:Label("ESP Keybind")
espKeyLabel:Keybind({
Flag = "esp_key2",
Default = Enum.KeyCode.C,
Mode = "Toggle"
})

-- Textbox (finished on Enter)
VisualsSection:Textbox({
Name = "Message",
Flag = "esp_message",
Placeholder = "enter message",
Default = "Hello",
Finished = true,
Callback = function(value)
print("Message updated:", value)
end
})

-- Another category
Window:Category("Misc")

-- Create a second page
local MiscPage = Window:Page({
Name = "Misc",
Icon = "72732892493295"
})

-- Section in column 1
local MiscSection1 = MiscPage:Section({
Name = "Miscellaneous",
Icon = "97491613646216",
Side = 1
})

MiscSection1:Button({
Name = "Print Something",
Callback = function()
print("Button clicked!")
end
})

MiscSection1:Slider({
Name = "Volume",
Flag = "volume",
Min = 0.1,
Max = 100,
Default = 80,
Suffix = "%",
Decimals = 2
})

-- Section in column 2
local MiscSection2 = MiscPage:Section({
Name = "Extra",
Icon = "131595494666590",
Side = 2
})

-- Dropdown with refreshable items
local playerDropdown = MiscSection2:Dropdown({
Name = "Players",
Flag = "player_select",
Items = {"Player1", "Player2", "Player3"},  -- initial static list
Default = "Player1"
})

-- You can later refresh it dynamically
task.delay(3, function()
playerDropdown:Refresh({"NewPlayer1", "NewPlayer2", "NewPlayer3", "NewPlayer4"})
end)

-- Another toggle with everything
local extraToggle = MiscSection2:Toggle({
Name = "Extra Feature",
Flag = "extra_feature",
Default = false
})

extraToggle:Colorpicker({Flag = "extra_color"})
extraToggle:Keybind({Flag = "extra_key", Default = Enum.KeyCode.T})

-- Settings page (built-in)
Window:Category("Settings")
local SettingsPage = Window:Page({
Name = "Settings",
Icon = "72732892493295"
})
Library:CreateSettingsPage(SettingsPage)

-- Notifications
Library:Notification("Hello, this is a notification!", 3)  -- no icon
Library:Notification("With icon", 5, "94627324690861")     -- with icon asset id

-- You can access flags anytime
-- print(Library.Flags["aim_smoothness"])
-- print(Library.Flags["esp_color"].Color)

-- To unload the library, use:
-- Library:Unload()
