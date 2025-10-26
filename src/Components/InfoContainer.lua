return function(Serenity, Window)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    -- Info Container at the bottom
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

    -- Player avatar circle
    local AvatarContainer = Serenity.Creator.New("Frame", {
        Name = "AvatarContainer",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Parent = InfoContainer
    })

    -- Avatar circle mask
    local AvatarMask = Serenity.Creator.New("ImageLabel", {
        Name = "AvatarMask",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://118034688779559", -- Circle mask image
        ScaleType = Enum.ScaleType.Crop,
        Parent = AvatarContainer
    })

    -- Player avatar
    local PlayerAvatar = Serenity.Creator.New("ImageLabel", {
        Name = "PlayerAvatar",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png",
        ScaleType = Enum.ScaleType.Crop,
        Parent = AvatarMask
    })

    -- Player display name
    Serenity.Creator.New("TextLabel", {
        Name = "PlayerName",
        Size = UDim2.new(1, -35, 1, 0),
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
