return function(Serenity, Window)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    -- Create info container at the bottom
    local InfoContainer = Serenity.Creator.New("Frame", {
        Name = "InfoContainer",
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 0, 0, 8)
        })
    })

    -- Top divider line
    Serenity.Creator.New("Frame", {
        Name = "InfoDivider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = InfoContainer
    })

    -- Player avatar
    local Avatar = Serenity.Creator.New("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 8, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BorderSizePixel = 0,
        Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png",
        Parent = InfoContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    -- Player display name
    Serenity.Creator.New("TextLabel", {
        Name = "PlayerName",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = player.DisplayName,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = InfoContainer
    })

    return InfoContainer
end
