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
        local response = game:HttpGet(url, true)
        return loadstring(response)()
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

-- Load Creator
local Creator = Serenity._loadModule("src/Creator.lua")
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
        return WindowModule(Serenity, config)  -- Pass Serenity as first parameter
    else
        print("⚠️ Using fallback window")
        return self:_createFallbackWindow(config)
    end
end

function Serenity:_createFallbackWindow(config)
    local player = game:GetService("Players").LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SerenityUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = config.Size or UDim2.fromOffset(600, 360)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Serenity UI"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Tab buttons area
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0, 160, 1, -90)
    tabFrame.Position = UDim2.new(0, 10, 0, 50)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -180, 1, -90)
    contentFrame.Position = UDim2.new(0, 170, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    local window = {
        ScreenGui = screenGui,
        Root = mainFrame,
        ContentFrame = contentFrame,
        Tabs = {}
    }
    
    function window:AddTab(tabConfig)
        print("📑 Adding tab:", tabConfig.Title)
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabButton.Text = tabConfig.Title
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.Visible = (#window.Tabs == 0) -- First tab visible
        tabContent.Parent = contentFrame
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Padding = UDim.new(0, 10)
        uiListLayout.Parent = tabContent
        
        local tab = {
            Button = tabButton,
            Content = tabContent,
            Sections = {}
        }
        
        function tab:AddSection(sectionConfig)
            print("📦 Adding section:", sectionConfig.Title)
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = tabContent
            
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -10, 0, 25)
            sectionLabel.Position = UDim2.new(0, 10, 0, 0)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = sectionConfig.Title
            sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionLabel.TextSize = 16
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame
            
            local elementsFrame = Instance.new("Frame")
            elementsFrame.Size = UDim2.new(1, 0, 0, 0)
            elementsFrame.Position = UDim2.new(0, 0, 0, 30)
            elementsFrame.BackgroundTransparency = 1
            elementsFrame.Parent = sectionFrame
            
            local elementsLayout = Instance.new("UIListLayout")
            elementsLayout.Padding = UDim.new(0, 8)
            elementsLayout.Parent = elementsFrame
            
            local section = {
                Frame = sectionFrame,
                ElementsFrame = elementsFrame
            }
            
            function section:AddToggle(toggleConfig)
                print("🔘 Adding toggle:", toggleConfig.Title)
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, 0, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = elementsFrame
                
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
                toggleBox.Position = UDim2.new(1, -10, 0.5, -10)
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
                
                function toggleObj:GetValue()
                    return toggleValue
                end
                
                return toggleObj
            end
            
            function section:AddButton(buttonConfig)
                print("🔼 Adding button:", buttonConfig.Title)
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 0, 40)
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                button.Text = buttonConfig.Title
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.Font = Enum.Font.Gotham
                button.Parent = elementsFrame
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button
                
                button.MouseButton1Click:Connect(function()
                    if buttonConfig.Callback then
                        buttonConfig.Callback()
                    end
                end)
                
                local buttonObj = {}
                return buttonObj
            end
            
            table.insert(tab.Sections, section)
            return section
        end
        
        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(window.Tabs) do
                otherTab.Content.Visible = false
            end
            tabContent.Visible = true
        end)
        
        table.insert(window.Tabs, tab)
        return tab
    end
    
    function window:Destroy()
        screenGui:Destroy()
    end
    
    return window
end

function Serenity:Notify(config)
    print("💬 [Serenity] " .. (config.Title or "Notification") .. ": " .. (config.Content or ""))
end

return Serenity
