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
        CurrentTab = nil
    }

    Window.Position = UDim2.fromOffset(
        Camera.ViewportSize.X / 2 - Window.Size.X.Offset / 2,
        Camera.ViewportSize.Y / 2 - Window.Size.Y.Offset / 2
    )

    local Dragging, DragInput, MousePos, StartPos = false

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
        Size = UDim2.new(1, 0, 0, 40),
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
        TextSize = 16,
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
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Control buttons
    local ButtonContainer = Serenity.Creator.New("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -65, 0, 5),
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 5)
        })
    })

    -- Minimize button
    local MinButton = Serenity.Creator.New("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 25, 0, 25),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = "_",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
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
        Size = UDim2.new(0, 25, 0, 25),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = ButtonContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    -- Tab navigation area
    Window.TabContainer = Serenity.Creator.New("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, Window.TabWidth, 1, -90),
        Position = UDim2.fromOffset(10, 50),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Tab buttons container
    Window.TabHolder = Serenity.Creator.New("ScrollingFrame", {
        Name = "TabHolder",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.TabContainer
    }, {
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 5)
        })
    })

    -- Tab selector
    Window.Selector = Serenity.Creator.New("Frame", {
        Name = "Selector",
        Size = UDim2.fromOffset(4, 30),
        Position = UDim2.fromOffset(0, 17),
        BackgroundColor3 = Color3.fromRGB(76, 194, 255),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = Window.TabHolder
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 2)
        })
    })

    -- Content area
    Window.ContentContainer = Serenity.Creator.New("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -Window.TabWidth - 20, 1, -90),
        Position = UDim2.new(0, Window.TabWidth + 10, 0, 50),
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
    MinButton.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    -- Update tab holder size (FIXED)
    local function updateTabHolderSize()
        local contentSize = Window.TabHolder.UIListLayout.AbsoluteContentSize
        Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
    end

    Window.TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabHolderSize)
    updateTabHolderSize() -- Initial update

    function Window:AddTab(config)
        local tabConfig = config or {}
        
        -- Create tab button
        local tabButton = Serenity.Creator.New("TextButton", {
            Name = tabConfig.Title .. "Tab",
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Text = tabConfig.Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = Window.TabHolder
        }, {
            Serenity.Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })

        -- Create tab content
        local tabContent = Serenity.Creator.New("ScrollingFrame", {
            Name = tabConfig.Title .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = (#Window.Tabs == 0), -- First tab is visible
            Parent = Window.ContentContainer
        }, {
            Serenity.Creator.New("UIListLayout", {
                Padding = UDim.new(0, 10)
            })
        })

        local tab = {
            Button = tabButton,
            Content = tabContent,
            Sections = {},
            Name = tabConfig.Title
        }

        function tab:AddSection(sectionConfig)
            local sectionFrame = Serenity.Creator.New("Frame", {
                Name = sectionConfig.Title .. "Section",
                Size = UDim2.new(1, -10, 0, 60), -- Fixed initial size
                BackgroundColor3 = Color3.fromRGB(31, 31, 31),
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

            function section:AddToggle(toggleConfig)
                local toggleFrame = Serenity.Creator.New("Frame", {
                    Name = toggleConfig.Title .. "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = elementsContainer
                })

                -- Toggle label
                Serenity.Creator.New("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleConfig.Title,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })

                -- Toggle box (checkbox style)
                local toggleBox = Serenity.Creator.New("TextButton", {
                    Name = "ToggleBox",
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -10, 0.5, -10),
                    AnchorPoint = Vector2.new(1, 0.5),
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

                local toggleValue = toggleConfig.Default or false

                local function updateToggle()
                    if toggleValue then
                        toggleBox.BackgroundColor3 = Color3.fromRGB(76, 194, 255)
                        checkmark.Visible = true
                    else
                        toggleBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        checkmark.Visible = false
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
                    })
                })

                -- Hover effects
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(55, 55, 55)
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

            -- Update section size when elements are added (FIXED)
            local function updateSectionSize()
                local contentSize = elementsContainer.AbsoluteSize
                sectionFrame.Size = UDim2.new(1, -10, 0, contentSize.Y + 45)
                
                -- Update tab content size
                local tabContentSize = tabContent.AbsoluteSize
                tabContent.CanvasSize = UDim2.new(0, 0, 0, tabContent.UIListLayout.AbsoluteContentSize.Y)
            end

            -- Use a different approach for size updates
            game:GetService("RunService").Heartbeat:Connect(updateSectionSize)

            table.insert(tab.Sections, section)
            return section
        end

        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.Content.Visible = false
            end
            tabContent.Visible = true
            
            -- Update selector position
            local tabIndex = table.find(Window.Tabs, tab)
            if tabIndex then
                local selectorPos = (tabIndex - 1) * 40
                TweenService:Create(Window.Selector, TweenInfo.new(0.2), {
                    Position = UDim2.fromOffset(0, selectorPos + 17)
                }):Play()
            end
        end)

        table.insert(Window.Tabs, tab)
        
        -- Select first tab
        if #Window.Tabs == 1 then
            Window.CurrentTab = tab
            TweenService:Create(Window.Selector, TweenInfo.new(0.2), {
                Position = UDim2.fromOffset(0, 17)
            }):Play()
        end

        return tab
    end

    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        Window.Root.Visible = not Window.Minimized
    end

    function Window:Destroy()
        Window.ScreenGui:Destroy()
    end

    return Window
end
