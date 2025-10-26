-- TextBox component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    
    local TextBox = {
        Type = "TextBox",
        Value = Config.Default or "",
        Callback = Config.Callback or function() end
    }
    
    -- Create textbox frame
    local textboxFrame = Serenity.Creator.New("Frame", {
        Name = Config.Title .. "TextBox",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = Parent
    })

    -- TextBox label
    Serenity.Creator.New("TextLabel", {
        Name = "TextBoxLabel",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = Config.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textboxFrame
    })

    -- TextBox input
    local textBoxInput = Serenity.Creator.New("TextBox", {
        Name = "TextBoxInput",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = TextBox.Value,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = Config.Placeholder or "Enter text...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Parent = textboxFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    -- Focus effects
    textBoxInput.Focused:Connect(function()
        textBoxInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end)

    textBoxInput.FocusLost:Connect(function()
        textBoxInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TextBox.Value = textBoxInput.Text
        TextBox.Callback(TextBox.Value)
    end)

    function TextBox:SetValue(value)
        textBoxInput.Text = value
        TextBox.Value = value
    end

    function TextBox:GetValue()
        return TextBox.Value
    end

    function TextBox:SetPlaceholder(text)
        textBoxInput.PlaceholderText = text
    end

    return TextBox
end
