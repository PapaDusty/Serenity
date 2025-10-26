return function(Title, Parent, IsOpen)
    local Serenity = require(script.Parent.Parent)
    local TweenService = game:GetService("TweenService")
    
    local Section = {
        Type = "Section",
        IsOpen = IsOpen ~= false, -- Default to open
        Elements = {}
    }

    -- Load icon library with error handling
    local IconLibrary = nil
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/main.lua"))()
    end)
    
    if success then
        IconLibrary = result
    else
        IconLibrary = {
            GetIcon = function(self, name, source)
                local fallbackIcons = {
                    chevron_down = "10734961420",
                    chevron_up = "10734961420"
                }
                return fallbackIcons[name] or "10734961420"
            end
        }
    end

    -- Function to get icon
    local function getIcon(iconName, source)
        if not iconName or iconName == "" then
            return nil
        end
        
        local success, iconId = pcall(function()
            return IconLibrary:GetIcon(iconName, source or "Symbols")
        end)
        
        return success and iconId or "10734961420"
    end

    -- Create section frame
    Section.Frame = Serenity.Creator.New("Frame", {
        Name = Title .. "Section",
        Size = UDim2.new(1, -10, 0, Section.IsOpen and 100 or 40), -- Dynamic height
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        Parent = Parent
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(55, 55, 55),
            Thickness = 1
        })
    })

    -- Section title (darker grey and smaller)
    Section.TitleLabel = Serenity.Creator.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.fromOffset(10, 5),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Section.Frame
    })

    -- Expand/collapse button (top right)
    Section.ExpandButton = Serenity.Creator.New("TextButton", {
        Name = "ExpandButton",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0, 10),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Section.Frame
    })

    Section.ExpandIcon = Serenity.Creator.New("ImageLabel", {
        Name = "ExpandIcon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. getIcon(Section.IsOpen and "chevron_up" or "chevron_down"),
        ImageColor3 = Color3.fromRGB(150, 150, 150),
        Rotation = Section.IsOpen and 0 or 180,
        Parent = Section.ExpandButton
    })

    -- Elements container
    Section.Container = Serenity.Creator.New("Frame", {
        Name = "Elements",
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.fromOffset(10, 35),
        BackgroundTransparency = 1,
        Visible = Section.IsOpen,
        Parent = Section.Frame
    }, {
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 8)
        })
    })

    -- Update section size function
    function Section:UpdateSize()
        if self.IsOpen then
            local elementsLayout = self.Container:FindFirstChild("UIListLayout")
            if elementsLayout then
                local contentHeight = elementsLayout.AbsoluteContentSize.Y
                self.Frame.Size = UDim2.new(1, -10, 0, contentHeight + 45)
            end
        else
            self.Frame.Size = UDim2.new(1, -10, 0, 40)
        end
    end

    -- Toggle section visibility
    function Section:Toggle()
        self.IsOpen = not self.IsOpen
        self.Container.Visible = self.IsOpen
        
        TweenService:Create(self.ExpandIcon, TweenInfo.new(0.2), {
            Rotation = self.IsOpen and 0 or 180
        }):Play()
        
        self:UpdateSize()
    end

    -- Set section open state
    function Section:SetOpen(state)
        if self.IsOpen ~= state then
            self:Toggle()
        end
    end

    -- Connect expand button
    Section.ExpandButton.MouseButton1Click:Connect(function()
        Section:Toggle()
    end)

    -- Auto-update size when elements are added
    local elementsLayout = Section.Container:WaitForChild("UIListLayout")
    elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if Section.IsOpen then
            Section:UpdateSize()
        end
    end)

    -- Add toggle element
    function Section:AddToggle(config)
        local toggleConfig = config or {}
        
        local toggleFrame = Serenity.Creator.New("Frame", {
            Name = toggleConfig.Title .. "Toggle",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = self.Container
        })

        -- Toggle box (checkbox style)
        local toggleBox = Serenity.Creator.New("TextButton", {
            Name = "ToggleBox",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 0, 0.5, -10),
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
            }),
            Serenity.Creator.New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 70, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 40, 200))
                })
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
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = toggleFrame
        })

        local toggleValue = toggleConfig.Default or false

        local function updateToggle()
            if toggleValue then
                checkmark.Size = UDim2.new(0, 0, 0, 0)
                checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
                checkmark.Visible = true
                
                TweenService:Create(toggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(120, 60, 220)
                }):Play()
                
                TweenService:Create(checkmark, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0.5, -7, 0.5, -7)
                }):Play()
            else
                TweenService:Create(toggleBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
                
                TweenService:Create(checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                
                delay(0.2, function()
                    if not toggleValue then
                        checkmark.Visible = false
                    end
                end)
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
                TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                }):Play()
            end
        end)

        toggleBox.MouseLeave:Connect(function()
            if not toggleValue then
                TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
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
        self:UpdateSize()
        
        return toggleObj
    end

    -- Add button element
    function Section:AddButton(config)
        local buttonConfig = config or {}
        
        local button = Serenity.Creator.New("TextButton", {
            Name = buttonConfig.Title .. "Button",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Text = buttonConfig.Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = self.Container
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })

        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end)

        button.MouseButton1Click:Connect(function()
            if buttonConfig.Callback then
                buttonConfig.Callback()
            end
        end)

        local buttonObj = {}
        table.insert(self.Elements, buttonObj)
        self:UpdateSize()
        
        return buttonObj
    end

    -- Add label element
    function Section:AddLabel(config)
        local labelConfig = config or {}
        
        local label = Serenity.Creator.New("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = labelConfig.Text or labelConfig.Title or "Label",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = self.Container
        })

        local labelObj = {}
        table.insert(self.Elements, labelObj)
        self:UpdateSize()
        
        return labelObj
    end

    -- Add divider
    function Section:AddDivider()
        local divider = Serenity.Creator.New("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Color3.fromRGB(55, 55, 55),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = self.Container
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        })
        
        local dividerObj = {}
        table.insert(self.Elements, dividerObj)
        self:UpdateSize()
        
        return dividerObj
    end

    -- Destroy section
    function Section:Destroy()
        if self.Frame and self.Frame.Parent then
            self.Frame:Destroy()
        end
    end

    -- Initial size update
    Section:UpdateSize()

    return Section
end
