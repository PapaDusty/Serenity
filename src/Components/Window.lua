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

    -- Load icon library
    local IconLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/main.lua"))()

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

    -- Title bar (30% shorter)
    local TitleBar = Serenity.Creator.New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 28), -- Reduced from 40 to 28
        BackgroundColor3 = Color3.fromRGB(31, 31, 31),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8, 0, 0)
        })
    })

    -- Title
    Serenity.Creator.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.fromOffset(15, 0),
        BackgroundTransparency = 1,
        Text = Config.Title or "Serenity UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14, -- Slightly smaller for shorter titlebar
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Subtitle
    Serenity.Creator.New("TextLabel", {
        Name = "SubTitle",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = Config.SubTitle or "v" .. Serenity.Version,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 11, -- Slightly smaller for shorter titlebar
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Control buttons
    local ButtonContainer = Serenity.Creator.New("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 50, 1, 0), -- Smaller for shorter titlebar
        Position = UDim2.new(1, -55, 0, 2), -- Adjusted position
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4)
        })
    })

    -- Minimize button (smaller)
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

    -- Close button (smaller)
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

    -- Tab navigation area (adjusted for shorter titlebar)
    Window.TabContainer = Serenity.Creator.New("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, Window.TabWidth, 1, -78), -- Adjusted for shorter titlebar
        Position = UDim2.fromOffset(10, 38), -- Adjusted for shorter titlebar
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Tab buttons container with gradient background
    Window.TabHolder = Serenity.Creator.New("ScrollingFrame", {
        Name = "TabHolder",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.TabContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(55, 55, 55),
            Thickness = 1
        }),
        Serenity.Creator.New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
            })
        }),
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 3)
        }),
        Serenity.Creator.New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })
    })

    -- Tab selector (removed the blue line, we'll use a different approach)
    Window.Selector = Serenity.Creator.New("Frame", {
        Name = "Selector",
        Size = UDim2.fromOffset(0, 0), -- Will be animated
        BackgroundTransparency = 1,
        Parent = Window.TabHolder
    })

    -- Content area (adjusted for shorter titlebar)
    Window.ContentContainer = Serenity.Creator.New("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -Window.TabWidth - 20, 1, -78), -- Adjusted for shorter titlebar
        Position = UDim2.new(0, Window.TabWidth + 10, 0, 38), -- Adjusted for shorter titlebar
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

    -- Button functionality (FIXED - no more spam)
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

    -- Function to get icon from library
    local function getIcon(iconName, source)
        if not iconName or iconName == "" then
            return nil
        end
        
        local success, iconId = pcall(function()
            return IconLibrary:GetIcon(iconName, source or "Symbols")
        end)
        
        return success and iconId or nil
    end

    function Window:AddTab(config)
        local tabConfig = config or {}
        
        -- Get icon if provided
        local iconId = getIcon(tabConfig.Icon, tabConfig.IconSource)
        
        -- Create tab button with premium styling
        local tabButton = Serenity.Creator.New("TextButton", {
            Name = tabConfig.Title .. "Tab",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Text = "",
            Parent = Window.TabHolder
        })

        -- Tab background with gradient and glow effect
        local tabBackground = Serenity.Creator.New("Frame", {
            Name = "Background",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BackgroundTransparency = 0.9,
            Parent = tabButton
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 5)
            }),
            Serenity.Creator.New("UIStroke", {
                Color = Color3.fromRGB(65, 65, 65),
                Thickness = 1,
                Transparency = 0.8
            }),
            Serenity.Creator.New("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
                })
            })
        })

        -- Icon (if provided)
        local iconPosition = UDim2.new(0, 10, 0.5, 0)
        local textPosition = UDim2.new(0, iconId and 32 or 10, 0.5, 0)
        
        if iconId then
            Serenity.Creator.New("ImageLabel", {
                Name = "Icon",
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 16, 0, 16),
                Position = iconPosition,
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. iconId,
                ImageColor3 = Color3.fromRGB(200, 200, 200),
                Parent = tabButton
            })
        end

        -- Tab label with bold text
        local tabLabel = Serenity.Creator.New("TextLabel", {
            Name = "Label",
            AnchorPoint = Vector2.new(0, 0.5),
            Position = textPosition,
            Size = UDim2.new(1, iconId and -32 or -10, 1, 0),
            BackgroundTransparency = 1,
            Text = tabConfig.Title,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextTransparency = 0.4,
            TextSize = 13,
            Font = Enum.Font.GothamSemibold, -- Bolder font
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = tabButton
        })

        -- Create tab content
        local tabContent = Serenity.Creator.New("ScrollingFrame", {
            Name = tabConfig.Title .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.95,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = (#Window.Tabs == 0), -- First tab is visible
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
            local sectionFrame = Serenity.Creator.New("Frame", {
                Name = sectionConfig.Title .. "Section",
                Size = UDim2.new(1, -10, 0, 0), -- Auto-size
                BackgroundColor3 = Color3.fromRGB(31, 31, 31),
                Parent = tabContent
            }, {
                Serenity.Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 6)
                }),
                Serenity.Creator.New("UIStroke", {
                    Color = Color3.fromRGB(55, 55, 55),
                    Thickness = 1
                }),
                Serenity.Creator.New("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 28))
                    })
                })
            })

            -- Section title
            Serenity.Creator.New("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.fromOffset(10, 5),
                BackgroundTransparency = 1,
                Text = sectionConfig.Title,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })

            -- Elements container
            local elementsContainer = Serenity.Creator.New("Frame", {
                Name = "Elements",
                Size = UDim2.new(1, -20, 1, -40),
                Position = UDim2.fromOffset(10, 35),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            }, {
                Serenity.Creator.New("UIListLayout", {
                    Padding = UDim.new(0, 8)
                })
            })

            local section = {
                Frame = sectionFrame,
                Container = elementsContainer
            }

            -- Update section size
            local function updateSectionSize()
                local elementsLayout = elementsContainer:FindFirstChild("UIListLayout")
                if elementsLayout then
                    sectionFrame.Size = UDim2.new(1, -10, 0, elementsLayout.AbsoluteContentSize.Y + 45)
                end
            end

            local elementsLayout = elementsContainer:WaitForChild("UIListLayout")
            elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
            updateSectionSize()

            function section:AddToggle(toggleConfig)
                local toggleFrame = Serenity.Creator.New("Frame", {
                    Name = toggleConfig.Title .. "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = elementsContainer
                })

                -- Toggle box (checkbox style) - MOVED TO LEFT
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

                -- Checkmark (initially hidden)
                local checkmark = Serenity.Creator.New("ImageLabel", {
                    Name = "Checkmark",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0.5, -7, 0.5, -7),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://10734961420", -- Checkmark icon
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    Visible = false,
                    Parent = toggleBox
                })

                -- Toggle label - MOVED TO RIGHT OF CHECKBOX
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
                        -- Animate checkmark out
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
                    Font = Enum.Font.Gotham,
                    Parent = elementsContainer
                }, {
                    Serenity.Creator.New("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    Serenity.Creator.New("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
                        })
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

        -- Tab selection function with premium animations
        local function selectTab()
            -- Hide all tabs
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.Content.Visible = false
                TweenService:Create(otherTab.Background, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.9,
                    Size = UDim2.new(1, 0, 1, 0)
                }):Play()
                TweenService:Create(otherTab.Label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextTransparency = 0.4,
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }):Play()
                otherTab.Background.UIStroke.Transparency = 0.8
            end
            
            -- Show selected tab with premium animations
            tabContent.Visible = true
            TweenService:Create(tab.Background, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.7,
                Size = UDim2.new(1, -2, 1, -2) -- Slight size increase for "pop" effect
            }):Play()
            TweenService:Create(tab.Label, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                TextTransparency = 0,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(tab.Background.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Transparency = 0.3,
                Color = Color3.fromRGB(100, 100, 255)
            }):Play()
            
            Window.SelectedTab = tab.Index
        end

        -- Tab switching
        tabButton.MouseButton1Click:Connect(selectTab)

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
