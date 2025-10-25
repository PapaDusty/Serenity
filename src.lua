--[[
    SimpleUI Library
    Usage: local SimpleUI = loadstring(game:HttpGet("YOUR_URL_HERE"))()
--]]

local SimpleUI = {}
SimpleUI.Version = "1.0.0"
SimpleUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(40, 40, 40),
        Foreground = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 100, 255)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Foreground = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(0, 100, 255)
    }
}

-- Options storage
SimpleUI.Options = {}

function SimpleUI:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Title = config.Title or "SimpleUI Window",
        Size = config.Size or UDim2.new(0, 500, 0, 400),
        Theme = config.Theme or "Dark",
        Tabs = {}
    }
    
    local currentTheme = SimpleUI.Themes[Window.Theme]
    
    -- Create main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleUI"
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = Window.Size
    mainFrame.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = currentTheme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner rounding
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = currentTheme.Foreground
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Window.Title
    titleLabel.TextColor3 = currentTheme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Tab buttons container
    local tabButtonsFrame = Instance.new("Frame")
    tabButtonsFrame.Name = "TabButtons"
    tabButtonsFrame.Size = UDim2.new(1, 0, 0, 50)
    tabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
    tabButtonsFrame.BackgroundTransparency = 1
    tabButtonsFrame.Parent = mainFrame
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -90)
    contentFrame.Position = UDim2.new(0, 0, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    function Window:AddTab(config)
        local tabConfig = config or {}
        local tab = {
            Title = tabConfig.Title or "Tab",
            Content = {}
        }
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabConfig.Title .. "Tab"
        tabButton.Size = UDim2.new(0, 100, 0, 30)
        tabButton.Position = UDim2.new(0, (#Window.Tabs * 110), 0, 10)
        tabButton.BackgroundColor3 = currentTheme.Accent
        tabButton.Text = tabConfig.Title
        tabButton.TextColor3 = currentTheme.Text
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabButtonsFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        -- Create tab content frame (initially hidden)
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabConfig.Title .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.Visible = (#Window.Tabs == 0) -- First tab is visible
        tabContent.Parent = contentFrame
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Padding = UDim.new(0, 10)
        uiListLayout.Parent = tabContent
        
        -- Tab selection logic
        tabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.ContentFrame.Visible = false
            end
            tabContent.Visible = true
        end)
        
        tab.ContentFrame = tabContent
        tab.UIListLayout = uiListLayout
        
        function tab:AddButton(config)
            local buttonConfig = config or {}
            local button = Instance.new("TextButton")
            button.Name = buttonConfig.Title .. "Button"
            button.Size = UDim2.new(1, -20, 0, 40)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = currentTheme.Accent
            button.Text = buttonConfig.Title
            button.TextColor3 = currentTheme.Text
            button.TextScaled = true
            button.Font = Enum.Font.Gotham
            button.Parent = tabContent
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button
            
            -- Hover effects
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = currentTheme.Accent:Lerp(Color3.new(1, 1, 1), 0.2)
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = currentTheme.Accent
            end)
            
            -- Click callback
            if buttonConfig.Callback then
                button.MouseButton1Click:Connect(buttonConfig.Callback)
            end
            
            return button
        end
        
        function tab:AddLabel(config)
            local labelConfig = config or {}
            local label = Instance.new("TextLabel")
            label.Name = labelConfig.Title .. "Label"
            label.Size = UDim2.new(1, -20, 0, 60)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = labelConfig.Content or labelConfig.Title or "Label"
            label.TextColor3 = currentTheme.Text
            label.TextScaled = true
            label.TextWrapped = true
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tabContent
            
            return label
        end
        
        function tab:AddToggle(config)
            local toggleConfig = config or {}
            local toggleId = toggleConfig.Title or "Toggle"
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = toggleId .. "Toggle"
            toggleFrame.Size = UDim2.new(1, -20, 0, 40)
            toggleFrame.Position = UDim2.new(0, 10, 0, 0)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = tabContent
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Name = "Label"
            toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            toggleLabel.Position = UDim2.new(0, 0, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = toggleConfig.Title or "Toggle"
            toggleLabel.TextColor3 = currentTheme.Text
            toggleLabel.TextScaled = true
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleButton"
            toggleButton.Size = UDim2.new(0, 50, 0, 30)
            toggleButton.Position = UDim2.new(1, -60, 0.5, -15)
            toggleButton.AnchorPoint = Vector2.new(1, 0.5)
            toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(1, 0)
            toggleCorner.Parent = toggleButton
            
            local toggleDot = Instance.new("Frame")
            toggleDot.Name = "ToggleDot"
            toggleDot.Size = UDim2.new(0, 20, 0, 20)
            toggleDot.Position = UDim2.new(0, 5, 0.5, -10)
            toggleDot.AnchorPoint = Vector2.new(0, 0.5)
            toggleDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            toggleDot.Parent = toggleButton
            
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = toggleDot
            
            local toggleState = toggleConfig.Default or false
            SimpleUI.Options[toggleId] = {Value = toggleState, Type = "Toggle"}
            
            local function updateToggle()
                if toggleState then
                    toggleDot.Position = UDim2.new(1, -25, 0.5, -10)
                    toggleButton.BackgroundColor3 = currentTheme.Accent
                else
                    toggleDot.Position = UDim2.new(0, 5, 0.5, -10)
                    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
            
            updateToggle()
            
            toggleButton.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                SimpleUI.Options[toggleId].Value = toggleState
                updateToggle()
                
                if toggleConfig.Callback then
                    toggleConfig.Callback(toggleState)
                end
            end)
            
            local toggleObject = {}
            
            function toggleObject:OnChanged(callback)
                toggleConfig.Callback = callback
            end
            
            function toggleObject:SetValue(value)
                toggleState = value
                SimpleUI.Options[toggleId].Value = value
                updateToggle()
            end
            
            return toggleObject
        end
        
        table.insert(Window.Tabs, tab)
        return tab
    end
    
    function Window:SelectTab(index)
        if Window.Tabs[index] then
            for i, tab in pairs(Window.Tabs) do
                tab.ContentFrame.Visible = (i == index)
            end
        end
    end
    
    return Window
end

function SimpleUI:Notify(config)
    local notifyConfig = config or {}
    
    -- Simple notification implementation
    print("[SimpleUI] " .. (notifyConfig.Title or "Notification") .. ": " .. (notifyConfig.Content or ""))
end

return SimpleUI
