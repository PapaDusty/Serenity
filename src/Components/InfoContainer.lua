return function(Window, Serenity)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    local InfoContainer = {}
    
    function InfoContainer:Create()
        -- Player info container
        local PlayerInfo = Serenity.Creator.New("Frame", {
            Name = "PlayerInfo",
            Size = UDim2.new(1, -20, 1, -10),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = Window.InfoContainer
        }, {
            Serenity.Creator.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10),
                VerticalAlignment = Enum.VerticalAlignment.Center
            })
        })

        -- Player avatar
        local Avatar = Serenity.Creator.New("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png",
            Parent = PlayerInfo
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        })

        -- Player display name
        Serenity.Creator.New("TextLabel", {
            Name = "DisplayName",
            Size = UDim2.new(1, -30, 1, 0),
            BackgroundTransparency = 1,
            Text = player.DisplayName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = PlayerInfo
        })
        
        return InfoContainer
    end
    
    return InfoContainer:Create()
end
