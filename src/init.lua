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
    },
    Options = {}
}

-- Safe module loader
function Serenity._loadModule(path)
    local url = "https://raw.githubusercontent.com/PapaDusty/Serenity/main/" .. path
    print("📥 Loading: " .. path)
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ Loaded: " .. path)
        return result
    else
        print("❌ Failed to load: " .. path)
        print("Error: " .. tostring(result))
        return nil
    end
end

-- Load dependencies
local Creator = Serenity._loadModule("src/Creator.lua")
local Acrylic = Serenity._loadModule("src/Acrylic/init.lua")

-- Fallback if Creator fails
if not Creator then
    Creator = {
        New = function(className, properties, children)
            local instance = Instance.new(className)
            for property, value in pairs(properties) do
                if property == "Parent" then
                    instance.Parent = value
                else
                    instance[property] = value
                end
            end
            if children then
                for _, child in ipairs(children) do
                    child.Parent = instance
                end
            end
            return instance
        end
    }
end

Serenity.Creator = Creator

function Serenity:CreateWindow(config)
    config = config or {}
    
    local WindowModule = Serenity._loadModule("src/Components/Window.lua")
    if WindowModule then
        return WindowModule(config)
    else
        -- Fallback window
        return self:_createFallbackWindow(config)
    end
end

function Serenity:_createFallbackWindow(config)
    local player = game:GetService("Players").LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SerenityFallback"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = config.Size or UDim2.fromOffset(600, 360)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame
    
    local window = {
        ScreenGui = screenGui,
        Root = mainFrame
    }
    
    function window:AddTab(tabConfig)
        print("📑 AddTab:", tabConfig.Title)
        
        local tab = {}
        function tab:AddSection(sectionConfig)
            print("📦 AddSection:", sectionConfig.Title)
            
            local section = {}
            function section:AddToggle(toggleConfig)
                print("🔘 AddToggle:", toggleConfig.Title)
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = window.Root
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = toggleConfig.Title
                toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleLabel.TextSize = 14
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                local toggleBox = Instance.new("TextButton")
                toggleBox.Size = UDim2.new(0, 20, 0, 20)
                toggleBox.Position = UDim2.new(1, -25, 0.5, -10)
                toggleBox.AnchorPoint = Vector2.new(1, 0.5)
                toggleBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                toggleBox.AutoButtonColor = false
                toggleBox.Text = ""
                toggleBox.Parent = toggleFrame
                
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = toggleBox
                
                local toggleValue = toggleConfig.Default or false
                
                local function updateToggle()
                    if toggleValue then
                        toggleBox.BackgroundColor3 = Color3.fromRGB(76, 194, 255)
                    else
                        toggleBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    end
                end
                
                toggleBox.MouseButton1Click:Connect(function()
                    toggleValue = not toggleValue
                    updateToggle()
                    if toggleConfig.Callback then
                        toggleConfig.Callback(toggleValue)
                    end
                end)
                
                updateToggle()
                
                local toggleObj = {}
                function toggleObj:SetValue(value)
                    toggleValue = value
                    updateToggle()
                end
                
                return toggleObj
            end
            
            function section:AddButton(buttonConfig)
                print("🔼 AddButton:", buttonConfig.Title)
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -20, 0, 40)
                button.Position = UDim2.new(0, 10, 0, 0)
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                button.Text = buttonConfig.Title
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.Font = Enum.Font.Gotham
                button.Parent = window.Root
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button
                
                if buttonConfig.Callback then
                    button.MouseButton1Click:Connect(buttonConfig.Callback)
                end
                
                return {}
            end
            
            return section
        end
        return tab
    end
    
    return window
end

function Serenity:Notify(config)
    print("💬 [Serenity] " .. (config.Title or "Notification") .. ": " .. (config.Content or ""))
end

return Serenity
