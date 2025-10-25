-- Serenity UI Library
local Serenity = {
    Version = "1.0.0",
    UseAcrylic = false,
    MinimizeKey = Enum.KeyCode.RightControl,
    Themes = {
        Dark = {
            Background = Color3.fromRGB(21, 21, 21),
            Foreground = Color3.fromRGB(31, 31, 31),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(76, 194, 255),
            SubText = Color3.fromRGB(150, 150, 150)
        }
    }
}

Serenity.Options = {}

-- Load dependencies
local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/Creator.lua"))()
local Acrylic = loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/Acrylic/init.lua"))()

function Serenity:CreateWindow(config)
    config = config or {}
    
    local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/Components/Window.lua"))()
    return Window(config)
end

function Serenity:Notify(config)
    -- Notification implementation
    print("[Serenity] " .. (config.Title or "Notification") .. ": " .. (config.Content or ""))
end

return Serenity
