return function(Window, Serenity)
    local TabDivider = {}
    
    function TabDivider:AddToTab(tab, tabIndex)
        local tabDivider = Serenity.Creator.New("Frame", {
            Name = "TabDivider",
            Size = UDim2.new(1, -10, 0, 1),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundColor3 = Color3.fromRGB(55, 55, 55),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            LayoutOrder = tabIndex + 0.5,
            Parent = Window.TabHolder
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        })
        
        return tabDivider
    end
    
    function TabDivider:AddToSection(sectionFrame)
        local divider = Serenity.Creator.New("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(55, 55, 55),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = sectionFrame
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        })
        
        return divider
    end
    
    return TabDivider
end
