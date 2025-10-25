-- Simple Window component
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
        Root = mainFrame,
        Tabs = {}
    }
    
    function window:AddTab(tabConfig)
        print("Adding tab:", tabConfig.Title)
        
        local tab = {
            Title = tabConfig.Title
        }
        
        function tab:AddSection(sectionConfig)
            print("Adding section:", sectionConfig.Title)
            
            local section = {
                Title = sectionConfig.Title
            }
            
            function section:AddToggle(toggleConfig)
                print("Adding toggle:", toggleConfig.Title)
                -- Toggle implementation will be added later
                return {}
            end
            
            function section:AddButton(buttonConfig)
                print("Adding button:", buttonConfig.Title)
                -- Button implementation will be added later
                return {}
            end
            
            return section
        end
        
        table.insert(window.Tabs, tab)
        return tab
    end
    
    return window
end
