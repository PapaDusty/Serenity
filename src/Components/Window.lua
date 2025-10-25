return function(Config)
    local Serenity = require(script.Parent.Parent)
    
    local player = game:GetService("Players").LocalPlayer
    local screenGui = Serenity.Creator.New("ScreenGui", {
        Name = "SerenityUI",
        Parent = player:WaitForChild("PlayerGui")
    })
    
    local mainFrame = Serenity.Creator.New("Frame", {
        Size = Config.Size or UDim2.fromOffset(600, 360),
        Position = UDim2.new(0.5, -300, 0.5, -180),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        Parent = screenGui
    }, {
        Serenity.Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)})
    })
    
    local window = {
        ScreenGui = screenGui,
        Root = mainFrame
    }
    
    function window:AddTab(tabConfig)
        local tab = {}
        function tab:AddSection(sectionConfig)
            local section = {}
            function section:AddToggle(toggleConfig)
                -- Will be implemented by fallback
                return {}
            end
            function section:AddButton(buttonConfig)
                -- Will be implemented by fallback
                return {}
            end
            return section
        end
        return tab
    end
    
    return window
end
