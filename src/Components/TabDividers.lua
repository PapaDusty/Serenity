local TabDividers = {}

function TabDividers:AddContentDivider(tabContent)
    return Serenity.Creator.New("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = tabContent
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })
end

function TabDividers:AddTabDivider(tabHolder, tabIndex)
    return Serenity.Creator.New("Frame", {
        Name = "TabDivider",
        Size = UDim2.new(1, -10, 0, 1),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        LayoutOrder = tabIndex + 0.5,
        Parent = tabHolder
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })
end

return TabDividers
