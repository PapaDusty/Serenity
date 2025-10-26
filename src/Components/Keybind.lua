-- Keybind component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local Keybind = {
        Type = "Keybind",
        Value = Config.Default or "LeftControl",
        Mode = Config.Mode or "Toggle", -- Toggle, Hold, Always
        Callback = Config.Callback or function() end,
        IsListening = false
    }
    
    -- Create keybind frame
    local keybindFrame = Serenity.Creator.New("Frame", {
        Name = Config.Title .. "Keybind",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = Parent
    })

    -- Keybind label
    Serenity.Creator.New("TextLabel", {
        Name = "KeybindLabel",
        Size = UDim2.new(0.6, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = Config.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindFrame
    })

    -- Keybind button
    local keybindButton = Serenity.Creator.New("TextButton", {
        Name = "KeybindButton",
        Size = UDim2.new(0.4, 0, 0, 25),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = Keybind.Value,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = keybindFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    -- Mode dropdown
    local modeButton = Serenity.Creator.New("TextButton", {
        Name = "ModeButton",
        Size = UDim2.new(0.4, 0, 0, 25),
        Position = UDim2.new(0.6, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = Keybind.Mode,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = keybindFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    local modeOptions = {"Toggle", "Hold", "Always"}
    local modeOpened = false
    local modeFrame = Serenity.Creator.New("ScrollingFrame", {
        Name = "ModeOptions",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = modeButton
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 2)
        }),
        Serenity.Creator.New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })
    })

    local function toggleModeDropdown()
        modeOpened = not modeOpened
        modeFrame.Visible = modeOpened
        
        if modeOpened then
            -- Clear and populate mode options
            for _, child in pairs(modeFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for _, mode in ipairs(modeOptions) do
                local option = Serenity.Creator.New("TextButton", {
                    Size = UDim2.new(1, -10, 0, 20),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    Text = mode,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    Parent = modeFrame
                }, {
                    Serenity.Creator.New("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    })
                })
                
                option.MouseButton1Click:Connect(function()
                    Keybind.Mode = mode
                    modeButton.Text = mode
                    modeOpened = false
                    modeFrame.Visible = false
                end)
            end
            
            modeFrame.CanvasSize = UDim2.new(0, 0, 0, #modeOptions * 22 + 10)
            modeFrame.Size = UDim2.new(1, 0, 0, math.min(#modeOptions * 22 + 10, 80))
        end
    end

    modeButton.MouseButton1Click:Connect(toggleModeDropdown)

    local function setKeybind(key)
        local keyName = key.Name
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            keyName = "MouseLeft"
        elseif key.UserInputType == Enum.UserInputType.MouseButton2 then
            keyName = "MouseRight"
        elseif key.UserInputType == Enum.UserInputType.MouseButton3 then
            keyName = "MouseMiddle"
        end
        
        Keybind.Value = keyName
        keybindButton.Text = keyName
        Keybind.IsListening = false
        
        TweenService:Create(keybindButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }):Play()
        
        Keybind.Callback(Keybind.Value, Keybind.Mode)
    end

    keybindButton.MouseButton1Click:Connect(function()
        if not Keybind.IsListening then
            Keybind.IsListening = true
            keybindButton.Text = "Press any key..."
            
            TweenService:Create(keybindButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(140, 70, 255)
            }):Play()
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard or
                   input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                   
                    setKeybind(input)
                    connection:Disconnect()
                end
            end)
        end
    end)

    -- Global keybind detection
    UserInputService.InputBegan:Connect(function(input)
        if not Keybind.IsListening then
            local currentKey = Keybind.Value
            local pressedKey
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                pressedKey = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                pressedKey = "MouseLeft"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                pressedKey = "MouseRight"
            else
                return
            end
            
            if pressedKey == currentKey then
                Keybind.Callback(Keybind.Value, Keybind.Mode, true)
            end
        end
    end)

    function Keybind:SetKey(key)
        Keybind.Value = key
        keybindButton.Text = key
    end

    function Keybind:GetKey()
        return Keybind.Value
    end

    function Keybind:SetMode(mode)
        if table.find(modeOptions, mode) then
            Keybind.Mode = mode
            modeButton.Text = mode
        end
    end

    function Keybind:GetMode()
        return Keybind.Mode
    end

    -- Close mode dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and modeOpened then
            local mousePos = input.Position
            local absPos = modeFrame.AbsolutePosition
            local absSize = modeFrame.AbsoluteSize
            
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                modeOpened = false
                modeFrame.Visible = false
            end
        end
    end)

    return Keybind
end
