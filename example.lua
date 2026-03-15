local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/serenity/main/library.lua"))()

local Window = Library:Window({
    Name = "RoForge",
})

local MainPage = Window:Page({
    Name = "Main",
    Icon = "136879043989014"   -- optional icon
})

local Section1 = MainPage:Section({
    Name = "Section 1",
    Icon = "",                  -- optional
    Side = 1                    -- 1 = left column, 2 = right column
})

Section1:Toggle({
    Name = "Enable Feature",
    Flag = "feature_toggle",    -- used for config saving
    Default = false,
    Callback = function(value)
        print("Toggle is now", value)
    end
})

Section1:Button({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})

Section1:Slider({
    Name = "Speed",
    Flag = "speed_slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Decimals = 1,
    Callback = function(value)
        print("Speed:", value)
    end
})

Section1:Dropdown({
    Name = "Mode",
    Flag = "mode_dropdown",
    Items = {"Easy", "Medium", "Hard"},
    Default = "Medium",
    Multi = false,
    Callback = function(value)
        print("Selected mode:", value)
    end
})

-- label with attached colorpicker
local colorLabel = Section1:Label("Color")
colorLabel:Colorpicker({
    Flag = "color_picker",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Color changed to", color)
    end
})

-- label with attached keybind
local keyLabel = Section1:Label("Key")
keyLabel:Keybind({
    Flag = "key_bind",
    Default = Enum.KeyCode.X,
    Mode = "Toggle",
    Callback = function(value)
        print("Keybind toggled:", value)
    end
})

Section1:Textbox({
    Flag = "text_input",
    Placeholder = "Enter text...",
    Default = "Hello",
    Finished = false,           -- if true, callback only on enter
    Numeric = false,
    Callback = function(value)
        print("Text:", value)
    end
})

-- second section to column 2
local Section2 = MainPage:Section({
    Name = "Section 2",
    Side = 2
})

Section2:Dropdown({
    Name = "Multi Select",
    Flag = "multi_dropdown",
    Items = {"Option A", "Option B", "Option C"},
    Default = {"Option A", "Option C"},
    Multi = true,
    Callback = function(selected)
        print("Selected:", table.concat(selected, ", "))
    end
})

-- settings page (pre-built)
local SettingsPage = Window:Page({
    Name = "Settings",
    Icon = "72732892493295"
})
Library:CreateSettingsPage(SettingsPage)

Library:Notification("Library loaded successfully!", 3, "94627324690861")  -- icon is optional
