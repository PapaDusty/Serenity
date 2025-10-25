
return function(Config, Parent)
    local Creator = require(script.Parent.Parent.Creator)
    
    local Toggle = {
        Value = Config.Default or false
    }

    local ToggleFrame = Creator.New("Frame", {
        Name = Config.Title .. "Toggle",
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        Parent = Parent
    }, {
        Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
    })

    -- Toggle label
    local Label = Creator.New("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = Config.Title or "Toggle",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })

    -- Toggle box
    local ToggleBox = Creator.New("TextButton", {
        Name = "ToggleBox",
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        AutoButtonColor = false,
        Text = "",
        Parent = ToggleFrame
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    -- Checkmark (initially hidden)
    local Checkmark = Creator.New("ImageLabel", {
        Name = "Checkmark",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734961420", -- Checkmark icon
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Visible = Toggle.Value,
        Parent = ToggleBox
    })

    local function UpdateToggle()
        if Toggle.Value then
            TweenService:Create(ToggleBox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(76, 194, 255)
            }):Play()
            Checkmark.Visible = true
        else
            TweenService:Create(ToggleBox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
            Checkmark.Visible = false
        end
    end

    ToggleBox.MouseButton1Click:Connect(function()
        Toggle.Value = not Toggle.Value
        UpdateToggle()
        
        if Config.Callback then
            Config.Callback(Toggle.Value)
        end
    end)

    -- Hover effects
    ToggleBox.MouseEnter:Connect(function()
        if not Toggle.Value then
            TweenService:Create(ToggleBox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            }):Play()
        end
    end)

    ToggleBox.MouseLeave:Connect(function()
        if not Toggle.Value then
            TweenService:Create(ToggleBox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end
    end)

    function Toggle:SetValue(value)
        Toggle.Value = value
        UpdateToggle()
    end

    function Toggle:GetValue()
        return Toggle.Value
    end

    -- Initialize
    UpdateToggle()

    return Toggle
end
