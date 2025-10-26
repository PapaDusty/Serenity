-- Dropdown component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    
    local Dropdown = {
        Type = "Dropdown",
        Value = Config.Default,
        Values = Config.Values or {},
        Multi = Config.Multi or false,
        Opened = false,
        Callback = Config.Callback or function() end
    }
    
    -- Create dropdown frame
    local dropdownFrame = Serenity.Creator.New("Frame", {
        Name = Config.Title .. "Dropdown",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = Parent
    })

    -- Dropdown label
    Serenity.Creator.New("TextLabel", {
        Name = "DropdownLabel",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = Config.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame
    })

    -- Dropdown button
    local dropdownButton = Serenity.Creator.New("TextButton", {
        Name = "DropdownButton",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = Dropdown.Value or "Select...",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIPadding", {
            PaddingLeft = UDim.new(0, 10)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    -- Dropdown arrow
    local dropdownArrow = Serenity.Creator.New("ImageLabel", {
        Name = "DropdownArrow",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709790948",
        ImageColor3 = Color3.fromRGB(200, 200, 200),
        Parent = dropdownButton
    })

    -- Dropdown options frame
    local optionsFrame = Serenity.Creator.New("ScrollingFrame", {
        Name = "OptionsFrame",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollBarImageTransparency = 0.8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = dropdownFrame
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

    local function updateOptionsSize()
        local layout = optionsFrame:FindFirstChild("UIListLayout")
        if layout then
            local contentSize = layout.AbsoluteContentSize.Y
            optionsFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize)
            optionsFrame.Size = UDim2.new(1, 0, 0, math.min(contentSize + 10, 150))
        end
    end

    local function createOption(value)
        local optionButton = Serenity.Creator.New("TextButton", {
            Name = value .. "Option",
            Size = UDim2.new(1, -10, 0, 25),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Text = value,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = optionsFrame
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),
            Serenity.Creator.New("UIPadding", {
                PaddingLeft = UDim.new(0, 8)
            })
        })

        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        end)

        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end)

        optionButton.MouseButton1Click:Connect(function()
            if Dropdown.Multi then
                -- Multi-dropdown logic
                if not Dropdown.Value then Dropdown.Value = {} end
                Dropdown.Value[value] = not Dropdown.Value[value]
                
                -- Update display text
                local selectedValues = {}
                for val, selected in pairs(Dropdown.Value) do
                    if selected then
                        table.insert(selectedValues, val)
                    end
                end
                dropdownButton.Text = #selectedValues > 0 and table.concat(selectedValues, ", ") or "Select..."
            else
                -- Single dropdown
                Dropdown.Value = value
                dropdownButton.Text = value
                Dropdown.Opened = false
                optionsFrame.Visible = false
                TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
                    Rotation = 0
                }):Play()
            end
            
            Dropdown.Callback(Dropdown.Value)
        end)
    end

    local function populateOptions()
        -- Clear existing options
        for _, child in pairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Create new options
        for _, value in ipairs(Dropdown.Values) do
            createOption(value)
        end
        
        updateOptionsSize()
    end

    local function toggleDropdown()
        Dropdown.Opened = not Dropdown.Opened
        optionsFrame.Visible = Dropdown.Opened
        
        if Dropdown.Opened then
            TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
                Rotation = 180
            }):Play()
            populateOptions()
        else
            TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
                Rotation = 0
            }):Play()
        end
    end

    dropdownButton.MouseButton1Click:Connect(toggleDropdown)

    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Opened then
            local mousePos = input.Position
            local absPos = optionsFrame.AbsolutePosition
            local absSize = optionsFrame.AbsoluteSize
            
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                toggleDropdown()
            end
        end
    end)

    function Dropdown:SetValue(value)
        if Dropdown.Multi then
            if not Dropdown.Value then Dropdown.Value = {} end
            if type(value) == "table" then
                Dropdown.Value = value
            else
                Dropdown.Value[value] = true
            end
            
            local selectedValues = {}
            for val, selected in pairs(Dropdown.Value) do
                if selected then
                    table.insert(selectedValues, val)
                end
            end
            dropdownButton.Text = #selectedValues > 0 and table.concat(selectedValues, ", ") or "Select..."
        else
            Dropdown.Value = value
            dropdownButton.Text = value
        end
    end

    function Dropdown:GetValue()
        return Dropdown.Value
    end

    function Dropdown:SetValues(newValues)
        Dropdown.Values = newValues
        populateOptions()
    end

    -- Initialize
    if Dropdown.Value then
        dropdownButton.Text = Dropdown.Value
    end
    populateOptions()

    return Dropdown
end
