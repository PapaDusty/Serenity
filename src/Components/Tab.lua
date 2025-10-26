-- Tab component for Serenity UI
return function(Title, Icon, Parent, Window)
    local Serenity = require(script.Parent.Parent)
    local TweenService = game:GetService("TweenService")
    
    local Tab = {
        Type = "Tab",
        Title = Title,
        Sections = {},
        Elements = {}
    }

    -- Load custom icons
    local CustomIcons = {}
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/icons.lua"))()
    end)
    
    if success and type(result) == "table" then
        CustomIcons = result
    end

    -- Function to get icon
    local function getIcon(iconName)
        if not iconName or iconName == "" then
            return nil
        end
        return CustomIcons[iconName]
    end

    -- Get icon ID
    local iconId = getIcon(Icon)

    -- Create tab button
    Tab.Button = Serenity.Creator.New("TextButton", {
        Name = Title .. "Tab",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Parent
    })

    -- Tab background
    Tab.Background = Serenity.Creator.New("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        Parent = Tab.Button
    })

    -- Calculate positions
    local textPosition = UDim2.new(0, 10, 0.5, 0)
    if iconId then
        textPosition = UDim2.new(0, 35, 0.5, 0)
        
        -- Icon
        Tab.Icon = Serenity.Creator.New("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0.5, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. iconId,
            ImageColor3 = Color3.fromRGB(200, 200, 200),
            Parent = Tab.Button
        })
    end

    -- Tab label container
    local labelContainer = Serenity.Creator.New("Frame", {
        Name = "LabelContainer",
        Size = UDim2.new(1, iconId and -35 or -10, 0, 20),
        Position = textPosition,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Parent = Tab.Button
    })

    -- Tab label
    Tab.Label = Serenity.Creator.New("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = labelContainer
    })

    -- Underline (initially hidden with 0 width)
    Tab.Underline = Serenity.Creator.New("Frame", {
        Name = "Underline",
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0.5, 0, 1, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(140, 70, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = labelContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    -- Create tab content
    Tab.Content = Serenity.Creator.New("ScrollingFrame", {
        Name = Title .. "Content",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollBarImageTransparency = 0.95,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = Window.ContentContainer
    }, {
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 10)
        }),
        Serenity.Creator.New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })
    })

    -- Update content size function
    function Tab:UpdateContentSize()
        local contentLayout = self.Content:FindFirstChild("UIListLayout")
        if contentLayout then
            self.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
        end
    end

    local contentLayout = Tab.Content:WaitForChild("UIListLayout")
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab:UpdateContentSize()
    end)
    Tab:UpdateContentSize()

    -- Add divider element to tab content
    function Tab:AddDivider()
        local divider = Serenity.Creator.New("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(55, 55, 55),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = self.Content
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        })
        
        self:UpdateContentSize()
        return divider
    end

    -- Add section to tab
    function Tab:AddSection(sectionConfig)
        local sectionConfig = sectionConfig or {}
        local isOpen = sectionConfig.Open ~= false
        
        local sectionFrame = Serenity.Creator.New("Frame", {
            Name = sectionConfig.Title .. "Section",
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundColor3 = Color3.fromRGB(21, 21, 21),
            Parent = self.Content
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            }),
            Serenity.Creator.New("UIStroke", {
                Color = Color3.fromRGB(55, 55, 55),
                Thickness = 1
            })
        })

        -- Section title (clickable area)
        local sectionTitle = Serenity.Creator.New("TextButton", {
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.fromOffset(10, 5),
            BackgroundTransparency = 1,
            Text = "",
            Parent = sectionFrame
        })

        -- Section title text
        Serenity.Creator.New("TextLabel", {
            Name = "TitleText",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = sectionConfig.Title,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = sectionTitle
        })

        -- Section icon (top right)
        local sectionIcon = Serenity.Creator.New("ImageLabel", {
            Name = "SectionIcon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -25, 0.5, -8),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. (isOpen and "106435270493821" or "76847249215450"),
            ImageColor3 = Color3.fromRGB(150, 150, 150),
            Parent = sectionTitle
        })

        -- Elements container
        local elementsContainer = Serenity.Creator.New("Frame", {
            Name = "Elements",
            Size = UDim2.new(1, -20, 1, -40),
            Position = UDim2.fromOffset(10, 35),
            BackgroundTransparency = 1,
            Visible = isOpen,
            Parent = sectionFrame
        }, {
            Serenity.Creator.New("UIListLayout", {
                Padding = UDim.new(0, 8)
            })
        })

        local section = {
            Frame = sectionFrame,
            Container = elementsContainer,
            IsOpen = isOpen,
            Title = sectionTitle,
            Icon = sectionIcon
        }

        -- Update section size
        local function updateSectionSize()
            if section.IsOpen then
                local elementsLayout = elementsContainer:FindFirstChild("UIListLayout")
                if elementsLayout then
                    sectionFrame.Size = UDim2.new(1, -10, 0, elementsLayout.AbsoluteContentSize.Y + 45)
                end
            else
                sectionFrame.Size = UDim2.new(1, -10, 0, 40)
            end
            self:UpdateContentSize()
        end

        local elementsLayout = elementsContainer:WaitForChild("UIListLayout")
        elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
        updateSectionSize()

        -- Toggle section visibility
        local function toggleSection()
            section.IsOpen = not section.IsOpen
            elementsContainer.Visible = section.IsOpen
            
            -- Update icon
            sectionIcon.Image = "rbxassetid://" .. (section.IsOpen and "106435270493821" or "76847249215450")
            
            updateSectionSize()
        end

        -- Make section title clickable
        sectionTitle.MouseButton1Click:Connect(toggleSection)

        function section:AddToggle(toggleConfig)
            local toggleFrame = Serenity.Creator.New("Frame", {
                Name = toggleConfig.Title .. "Toggle",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = elementsContainer
            })

            -- Toggle box
            local toggleBox = Serenity.Creator.New("TextButton", {
                Name = "ToggleBox",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                AutoButtonColor = false,
                Text = "",
                Parent = toggleFrame
            }, {
                Serenity.Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }),
                Serenity.Creator.New("UIStroke", {
                    Color = Color3.fromRGB(65, 65, 65),
                    Thickness = 1
                })
            })

            -- Checkmark
            local checkmark = Serenity.Creator.New("ImageLabel", {
                Name = "Checkmark",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.5, -7, 0.5, -7),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10734961420",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Visible = false,
                Parent = toggleBox
            })

            -- Toggle label
            Serenity.Creator.New("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -25, 1, 0),
                Position = UDim2.new(0, 25, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleConfig.Title,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = toggleFrame
            })

            local toggleValue = toggleConfig.Default or false

            local function updateToggle()
                if toggleValue then
                    checkmark.Visible = true
                    toggleBox.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
                else
                    checkmark.Visible = false
                    toggleBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                end
            end

            toggleBox.MouseButton1Click:Connect(function()
                toggleValue = not toggleValue
                updateToggle()
                if toggleConfig.Callback then
                    toggleConfig.Callback(toggleValue)
                end
            end)

            -- Hover effects
            toggleBox.MouseEnter:Connect(function()
                if not toggleValue then
                    toggleBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                end
            end)

            toggleBox.MouseLeave:Connect(function()
                if not toggleValue then
                    toggleBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                end
            end)

            updateToggle()

            local toggleObj = {}
            function toggleObj:SetValue(value)
                toggleValue = value
                updateToggle()
            end

            function toggleObj:GetValue()
                return toggleValue
            end

            table.insert(self.Elements, toggleObj)
            updateSectionSize()
            
            return toggleObj
        end

        function section:AddButton(buttonConfig)
            local button = Serenity.Creator.New("TextButton", {
                Name = buttonConfig.Title .. "Button",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Text = buttonConfig.Title,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamSemibold,
                Parent = elementsContainer
            }, {
                Serenity.Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 6)
                })
            })

            -- Hover effects
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end)

            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end)

            button.MouseButton1Click:Connect(function()
                if buttonConfig.Callback then
                    buttonConfig.Callback()
                end
            end)

            local buttonObj = {}
            table.insert(self.Elements, buttonObj)
            updateSectionSize()
            
            return buttonObj
        end

        table.insert(self.Sections, section)
        return section
    end

    -- Tab selection functions
    function Tab:Select()
        self.Content.Visible = true
        self.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.Label.TextSize = 16
        
        -- Animate underline
        self.Underline.BackgroundTransparency = 0
        self.Underline.Size = UDim2.new(0, 0, 0, 2)
        self.Underline.Position = UDim2.new(0.5, 0, 1, 0)
        
        TweenService:Create(self.Underline, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 2)
        }):Play()
    end

    function Tab:Deselect()
        self.Content.Visible = false
        self.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        self.Label.TextSize = 14
        
        -- Hide underline
        TweenService:Create(self.Underline, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 2)
        }):Play()
    end

    return Tab
end
