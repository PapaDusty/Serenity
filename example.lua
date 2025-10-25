-- Load Serenity UI
local Serenity = loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/init.lua"))()

-- Create window
local Window = Serenity:CreateWindow({
    Title = "Serenity UI",
    SubTitle = "by YourName",
    Size = UDim2.fromOffset(600, 360),
    TabWidth = 160
})

-- Add tabs
local MainTab = Window:AddTab({Title = "Main", Icon = ""})
local SettingsTab = Window:AddTab({Title = "Settings", Icon = ""})

-- Add elements to main tab
local MainSection = MainTab:AddSection({Title = "Main Section"})

MainSection:AddToggle({
    Title = "Enable Features",
    Default = false,
    Callback = function(value)
        print("Toggle changed:", value)
    end
})

MainSection:AddButton({
    Title = "Test Button",
    Callback = function()
        Serenity:Notify({
            Title = "Test",
            Content = "Button clicked!"
        })
    end
})
