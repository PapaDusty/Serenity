-- Slider component for Serenity UI
return function(Config, Parent)
    local Serenity = require(script.Parent.Parent)
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    
    local Slider = {
        Type = "Slider",
        Value = Config.Default or Config.Min or 0,
        Min = Config.Min or 0,
        Max = Config.Max or 100,
        Rounding = Config.Rounding or 1,
        Callback = Config.Callback or function() end
    }
    
    -- Create slider frame
    local sliderFrame = Serenity.Creator.New("Frame", {
        Name = Config.Title .. "Slider",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = Parent
    })

    -- Slider label with dashes
    local sliderLabel = Serenity.Creator.New("TextLabel", {
        Name = "SliderLabel",
        Size = UDim2.new(0.6, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = Config.Title .. " ------------",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })

    -- Value display
    local valueDisplay = Serenity.Creator.New("TextLabel", {
        Name = "ValueDisplay",
        Size = UDim2.new(0.4, 0, 0, 20),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(Slider.Value),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame
    })

    -- Slider track
    local sliderTrack = Serenity.Creator.New("Frame", {
        Name = "SliderTrack",
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        Parent = sliderFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    -- Slider fill
    local sliderFill = Serenity.Creator.New("Frame", {
        Name = "SliderFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(140, 70, 255),
        Parent = sliderTrack
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    -- Slider thumb
    local sliderThumb = Serenity.Creator.New("Frame", {
        Name = "SliderThumb",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = sliderTrack
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    local dragging = false
    local connection

    local function round(value, precision)
        return math.floor(value / precision + 0.5) * precision
    end

    local function updateSlider(value, fromInput)
        value = math.clamp(value, Slider.Min, Slider.Max)
        value = round(value, Slider.Rounding)
        Slider.Value = value
        
        local percentage = (value - Slider.Min) / (Slider.Max - Slider.Min)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderThumb.Position = UDim2.new(percentage, -6, 0.5, 0)
        valueDisplay.Text = tostring(value)
        
        if fromInput then
            Slider.Callback(value)
        end
    end

    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            local value = Slider.Min + (relativeX * (Slider.Max - Slider.Min))
            updateSlider(value, true)
        end
    end

    local function startDragging()
        dragging = true
        connection = RunService.RenderStepped:Connect(function()
            if dragging then
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local relativeX = (mouse.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                local value = Slider.Min + (relativeX * (Slider.Max - Slider.Min))
                updateSlider(value, true)
            end
        end)
    end

    local function stopDragging()
        dragging = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDragging()
            local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            local value = Slider.Min + (relativeX * (Slider.Max - Slider.Min))
            updateSlider(value, true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stopDragging()
        end
    end)

    function Slider:SetValue(value)
        updateSlider(value, false)
    end

    function Slider:GetValue()
        return Slider.Value
    end

    -- Initialize
    updateSlider(Slider.Value, false)

    return Slider
end
