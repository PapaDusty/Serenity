return function(Serenity, Config)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    local Camera = workspace.CurrentCamera

    local Window = {
        Minimized = false,
        Maximized = false,
        Size = Config.Size or UDim2.fromOffset(600, 360),
        CurrentPos = 0,
        TabWidth = Config.TabWidth or 160,
        Tabs = {},
        CurrentTab = nil,
        SelectedTab = 1
    }

    Window.Position = UDim2.fromOffset(
        Camera.ViewportSize.X / 2 - Window.Size.X.Offset / 2,
        Camera.ViewportSize.Y / 2 - Window.Size.Y.Offset / 2
    )

    local Dragging, DragInput, MousePos, StartPos = false

    -- Load icon library with error handling
    local IconLibrary = nil
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/main.lua"))()
    end)
    
    if success then
        IconLibrary = result
        print("✅ Icon library loaded successfully")
    else
        print("⚠️ Icon library failed to load, using fallback")
        IconLibrary = {
            GetIcon = function(self, name, source)
                local fallbackIcons = {
                    house = "10734961420",
                    user = "10734961420",
                    settings = "10734961420",
                    home = "10734961420",
                    sword = "10734961420",
                    chevron_down = "10734961420",
                    chevron_up = "10734961420"
                }
                return fallbackIcons[name] or "10734961420"
            end
        }
    end

    -- Create main window
    Window.ScreenGui = Serenity.Creator.New("ScreenGui", {
        Name = "SerenityUI",
        Parent = player:WaitForChild("PlayerGui")
    })

    -- Main container
    Window.Root = Serenity.Creator.New("Frame", {
        Name = "MainWindow",
        Size = Window.Size,
        Position = Window.Position,
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Window.ScreenGui
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(45, 45, 45),
            Thickness = 1
        })
    })

    -- Title bar
    local TitleBar = Serenity.Creator.New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(31, 31, 31),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8, 0, 0)
        })
    })

    -- Title with bolder font
    Serenity.Creator.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = Config.Title or "Serenity UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold, -- Bolder
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Subtitle with bolder font
    Serenity.Creator.New("TextLabel", {
        Name = "SubTitle",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = Config.SubTitle or "v" .. Serenity.Version,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 11,
        Font = Enum.Font.GothamSemibold, -- Bolder
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Control buttons
    local ButtonContainer = Serenity.Creator.New("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, -55, 0, 2),
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4)
        })
    })

    -- Minimize button
    local MinButton = Serenity.Creator.New("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = "_",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = ButtonContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    -- Close button
    local CloseButton = Serenity.Creator.New("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = ButtonContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    -- Tab navigation area (no border)
    Window.TabContainer = Serenity.Creator.New("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, Window.TabWidth, 1, -78),
        Position = UDim2.fromOffset(10, 38),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Tab buttons container (no border)
    Window.TabHolder = Serenity.Creator.New("ScrollingFrame", {
        Name = "TabHolder",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.TabContainer
    }, {
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 8)
        })
    })

    -- Vertical divider between tabs and content
    local VerticalDivider = Serenity.Creator.New("Frame", {
        Name = "VerticalDivider",
        Size = UDim2.new(0, 1, 1, -78),
        Position = UDim2.new(0, Window.TabWidth + 5, 0, 38),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    -- Content area (no border)
    Window.ContentContainer = Serenity.Creator.New("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -Window.TabWidth - 25, 1, -78), -- Adjusted for divider
        Position = UDim2.new(0, Window.TabWidth + 15, 0, 38), -- Adjusted for divider
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Dragging functionality
    local function UpdateDrag(input)
        if not Dragging then return end
        
        local delta = input.Position - MousePos
        Window.Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
        )
        
        Window.Root.Position = Window.Position
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MousePos = input.Position
            StartPos = Window.Root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdateDrag(input)
        end
    end)

    -- Button functionality
    local destroyDebounce = false
    CloseButton.MouseButton1Click:Connect(function()
        if not destroyDebounce then
            destroyDebounce = true
            Window:Destroy()
        end
    end)

    MinButton.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    -- Update tab holder size
    local function updateTabHolderSize()
        local layout = Window.TabHolder:FindFirstChild("UIListLayout")
        if layout then
            Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end
    end

    local layout = Window.TabHolder:WaitForChild("UIListLayout")
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabHolderSize)
    updateTabHolderSize()

    -- Function to get icon from library with error handling
    local function getIcon(iconName, source)
        if not iconName or iconName == "" then
            return nil
        end
        
        local success, iconId = pcall(function()
            return IconLibrary:GetIcon(iconName, source or "Symbols")
        end)
        
        if success and iconId then
            return iconId
        else
            return "10734961420"
        end
    end

    function Window:AddTab(config)
        local tabConfig = config or {}
        
        -- Get icon if provided
        local iconId = nil
        if tabConfig.Icon then
            iconId = getIcon(tabConfig.Icon, tabConfig.IconSource)
        end
        
        -- Create tab button
        local tabButton = Serenity.Creator.New("TextButton", {
            Name = tabConfig.Title .. "Tab",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "",
            Parent = Window.TabHolder
        })

        -- Tab background (no border initially)
        local tabBackground = Serenity.Creator.New("Frame", {
            Name = "Background",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(21, 21, 21),
            BackgroundTransparency = 0.9,
            Parent = tabButton
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })

        -- Icon (if provided)
        local iconPosition = UDim2.new(0, 12, 0.5, 0)
        local textPosition = UDim2.new(0, iconId and 34 or 12, 0.5, 0)
        
        if iconId then
            Serenity.Creator.New("ImageLabel", {
                Name = "Icon",
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 18, 0, 18),
                Position = iconPosition,
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. iconId,
                ImageColor3 = Color3.fromRGB(180, 180, 180),
                Parent = tabButton
            })
        end

        -- Tab label with bolder font
        local tabLabel = Serenity.Creator.New("TextLabel", {
            Name = "Label",
            AnchorPoint = Vector2.new(0, 0.5),
            Position = textPosition,
            Size = UDim2.new(1, iconId and -34 or -12, 1, 0),
            BackgroundTransparency = 1,
            Text = tabConfig.Title,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            TextTransparency = 0.3,
            TextSize = 12, -- Start smaller
            Font = Enum.Font.GothamSemibold, -- Bolder
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = tabButton
        })

        -- Create tab content
        local tabContent = Serenity.Creator.New("ScrollingFrame", {
            Name = tabConfig.Title .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(21, 21, 21),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.95,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = (#Window.Tabs == 0),
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

        local tab = {
            Button = tabButton,
            Background = tabBackground,
            Label = tabLabel,
            Content = tabContent,
            Sections = {},
            Name = tabConfig.Title,
            Index = #Window.Tabs + 1
        }

        -- Update content size function
        local function updateContentSize()
            local contentLayout = tabContent:FindFirstChild("UIListLayout")
            if contentLayout then
                tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
            end
        end

        local contentLayout = tabContent:WaitForChild("UIListLayout")
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContentSize)
        updateContentSize()

        -- Add divider element to tab
        function tab:AddDivider()
            local divider = Serenity.Creator.New("Frame", {
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
            
            return divider
        end

        function tab:AddSection(sectionConfig)
            local sectionConfig = sectionConfig or {}
            local isOpen = sectionConfig.Open ~= false
            
            local sectionFrame = Serenity.Creator.New("Frame", {
                Name = sectionConfig.Title .. "Section",
                Size = UDim2.new(1, -10, 0, isOpen and 100 or 40),
                BackgroundColor3 = Color3.fromRGB(21, 21, 21),
                Parent = tabContent
            }, {
                Serenity.Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 6)
                }),
                Serenity.Creator.New("UIStroke", {
                    Color = Color3.fromRGB(55, 55, 55),
                    Thickness = 1
                })
            })

            -- Section title with bolder font
            local sectionTitle = Serenity.Creator.New("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -40, 0, 30),
                Position = UDim2.fromOffset(10, 5),
                BackgroundTransparency = 1,
                Text = sectionConfig.Title,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                TextSize = 12,
                Font = Enum.Font.GothamSemibold, -- Bolder
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })

            -- Expand/collapse button
            local expandButton = Serenity.Creator.New("TextButton", {
                Name = "ExpandButton",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0, 10),
                BackgroundTransparency = 1,
                Text = "",
                Parent = sectionFrame
            })

            local expandIcon = Serenity.Creator.New("ImageLabel", {
                Name = "ExpandIcon",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. getIcon(isOpen and "chevron_up" or "chevron_down"),
                ImageColor3 = Color3.fromRGB(150, 150, 150),
                Rotation = isOpen and 0 or 180,
                Parent = expandButton
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
                ExpandButton = expandButton,
                ExpandIcon = expandIcon
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
            end

            local elementsLayout = elementsContainer:WaitForChild("UIListLayout")
            elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
            updateSectionSize()

            -- Toggle section visibility
            local function toggleSection()
                section.IsOpen = not section.IsOpen
                elementsContainer.Visible = section.IsOpen
                
                TweenService:Create(section.ExpandIcon, TweenInfo.new(0.2), {
                    Rotation = section.IsOpen and 0 or 180
                }):Play()
                
                updateSectionSize()
            end

            expandButton.MouseButton1Click:Connect(toggleSection)

            function section:AddToggle(toggleConfig)
                local toggleFrame = Serenity.Creator.New("Frame", {
                    Name = toggleConfig.Title .. "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = elementsContainer
                })

                -- Toggle box - FIXED POSITION (centered vertically)
                local toggleBox = Serenity.Creator.New("TextButton", {
                    Name = "ToggleBox",
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 0, 0.5, 0), -- FIXED: Changed from -10 to 0
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35), -- Dark grey when off
                    AutoButtonColor = false,
                    Text = "",
                    Parent = toggleFrame
                }, {
                    Serenity.Creator.New("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    Serenity.Creator.New("UIStroke", {
                        Color = Color3.fromRGB(55, 55, 55),
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

                -- Toggle label with bolder font
                Serenity.Creator.New("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -25, 1, 0),
                    Position = UDim2.new(0, 25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = toggleConfig.Title,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold, -- Bolder
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = toggleFrame
                })

                local toggleValue = toggleConfig.Default or false

                local function updateToggle()
                    if toggleValue then
                        -- Animate checkmark in
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
                        -- Animate checkmark out - back to dark grey
                        TweenService:Create(toggleBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Dark grey
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
                            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        }):Play()
                    end
                end)

                toggleBox.MouseLeave:Connect(function()
                    if not toggleValue then
                        TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
                    Font = Enum.Font.GothamSemibold, -- Bolder
                    Parent = elementsContainer
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
                return buttonObj
            end

            table.insert(tab.Sections, section)
            return section
        end

        -- Tab selection function with text size animation
        local function selectTab()
            -- Hide all tabs and reset text size
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.Content.Visible = false
                TweenService:Create(otherTab.Background, TweenInfo.new(0.4), {
                    BackgroundTransparency = 0.9
                }):Play()
                TweenService:Create(otherTab.Label, TweenInfo.new(0.4), {
                    TextTransparency = 0.3,
                    TextColor3 = Color3.fromRGB(180, 180, 180),
                    TextSize = 12 -- Smaller text for inactive tabs
                }):Play()
            end
            
            -- Show selected tab with larger text
            tabContent.Visible = true
            TweenService:Create(tab.Background, TweenInfo.new(0.4), {
                BackgroundTransparency = 0.8
            }):Play()
            TweenService:Create(tab.Label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 0,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14 -- Larger text for active tab
            }):Play()
            
            Window.SelectedTab = tab.Index
        end

        -- Tab switching
        tabButton.MouseButton1Click:Connect(selectTab)

        -- Store tabs in order
        table.insert(Window.Tabs, tab)
        
        -- Select first tab
        if #Window.Tabs == 1 then
            selectTab()
        end

        return tab
    end

    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        Window.Root.Visible = not Window.Minimized
    end

    function Window:Destroy()
        if Window.ScreenGui and Window.ScreenGui.Parent then
            Window.ScreenGui:Destroy()
        end
    end

    return Window
end
