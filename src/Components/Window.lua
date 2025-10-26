return function(Serenity, Config)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local Window = {
        Minimized = false,
        Maximized = false,
        Size = Config.Size or UDim2.fromOffset(600, 360),
        CurrentPos = 0,
        TabWidth = 140,
        Tabs = {},
        CurrentTab = nil,
        SelectedTab = 1
    }

    Window.Position = UDim2.fromOffset(
        Camera.ViewportSize.X / 2 - Window.Size.X.Offset / 2,
        Camera.ViewportSize.Y / 2 - Window.Size.Y.Offset / 2
    )

    local Dragging, DragInput, MousePos, StartPos = false

    -- Load icons from external file
    local Icons = {}
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/PhosphorIcons.lua"))()
    end)
    
    if success and type(result) == "table" then
        Icons = result
    end

    -- Function to get icon
    local function getIcon(iconName)
        if not iconName or iconName == "" then
            return nil
        end
        return Icons[iconName]
    end

    -- Create main window
    Window.ScreenGui = Serenity.Creator.New("ScreenGui", {
        Name = "SerenityUI",
        ResetOnSpawn = false,
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
        })
    })

    -- Title bar
    local TitleBar = Serenity.Creator.New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8, 0, 0)
        })
    })

    -- Title bar divider line
    Serenity.Creator.New("Frame", {
        Name = "TitleBarDivider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = TitleBar
    })

    -- Title with icon
    local TitleContainer = Serenity.Creator.New("Frame", {
        Name = "TitleContainer",
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center
        })
    })

    -- Title icon
    Serenity.Creator.New("ImageLabel", {
        Name = "TitleIcon",
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1,
        Image = "rbxassetid://118034688779559",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = TitleContainer
    })

    -- Title text
    Serenity.Creator.New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = Config.Title or "Serenity UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = TitleContainer
    })

    -- Subtitle (on the left, bigger text)
    Serenity.Creator.New("TextLabel", {
        Name = "SubTitle",
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Config.SubTitle or "v" .. Serenity.Version,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = TitleBar
    })

    -- Control buttons
    local ButtonContainer = Serenity.Creator.New("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 52, 0.85, 0),
        Position = UDim2.new(1, -55, 0, 3),
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8)
        })
    })

    -- Minimize button
    local MinButton = Serenity.Creator.New("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    local MinButtonBg = Serenity.Creator.New("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 1,
        Parent = MinButton
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://116543637337872",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = MinButton
    })

    -- Close button
    local CloseButton = Serenity.Creator.New("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    local CloseButtonBg = Serenity.Creator.New("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 1,
        Parent = CloseButton
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://114783304987099",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = CloseButton
    })

    -- Tab navigation area
    Window.TabContainer = Serenity.Creator.New("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, Window.TabWidth, 1, -56),
        Position = UDim2.fromOffset(0, 28),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Tab buttons container
    Window.TabHolder = Serenity.Creator.New("ScrollingFrame", {
        Name = "TabHolder",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.TabContainer
    }, {
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    -- Vertical divider between tabs and content
    Window.Divider = Serenity.Creator.New("Frame", {
        Name = "Divider",
        Size = UDim2.new(0, 1, 1, -56),
        Position = UDim2.new(0, Window.TabWidth, 0, 28),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = Window.Root
    })

    -- Content area
    Window.ContentContainer = Serenity.Creator.New("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -Window.TabWidth - 10, 1, -66),
        Position = UDim2.new(0, Window.TabWidth + 5, 0, 38),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Info Container at the bottom
    Window.InfoContainer = Serenity.Creator.New("Frame", {
        Name = "InfoContainer",
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 0, 0, 8)
        })
    })

    -- Info container top divider
    Serenity.Creator.New("Frame", {
        Name = "InfoDivider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = Window.InfoContainer
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

    -- Button hover effects
    MinButton.MouseEnter:Connect(function()
        TweenService:Create(MinButtonBg, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)

    MinButton.MouseLeave:Connect(function()
        TweenService:Create(MinButtonBg, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
    end)

    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButtonBg, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)

    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButtonBg, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
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

    -- Store tabs in proper order
    Window.OrderedTabs = {}
    Window.TabCount = 0

    -- Load components
    local InfoContainer = require(script.Parent.InfoContainer)(Window, Serenity)
    local TabDivider = require(script.Parent.TabDivider)(Window, Serenity)

    function Window:AddTab(config)
        local tabConfig = config or {}
        
        Window.TabCount = Window.TabCount + 1
        local tabIndex = Window.TabCount
        
        -- Get icon
        local iconId = getIcon(tabConfig.Icon)
        
        -- Create tab button
        local tabButton = Serenity.Creator.New("TextButton", {
            Name = tabConfig.Title .. "Tab",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "",
            LayoutOrder = tabIndex,
            Parent = Window.TabHolder
        })

        -- Tab background
        local tabBackground = Serenity.Creator.New("Frame", {
            Name = "Background",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(21, 21, 21),
            BackgroundTransparency = 1,
            Parent = tabButton
        })

        -- Calculate positions
        local textPosition = UDim2.new(0, 10, 0.5, 0)
        if iconId then
            textPosition = UDim2.new(0, 35, 0.5, 0)
            
            -- Icon
            Serenity.Creator.New("ImageLabel", {
                Name = "Icon",
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 10, 0.5, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. iconId,
                ImageColor3 = Color3.fromRGB(200, 200, 200),
                Parent = tabButton
            })
        end

        -- Tab label container
        local labelContainer = Serenity.Creator.New("Frame", {
            Name = "LabelContainer",
            Size = UDim2.new(1, iconId and -35 or -10, 0, 20),
            Position = textPosition,
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Parent = tabButton
        })

        -- Tab label
        local tabLabel = Serenity.Creator.New("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tabConfig.Title,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = labelContainer
        })

        -- Underline
        local underline = Serenity.Creator.New("Frame", {
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
        local tabContent = Serenity.Creator.New("ScrollingFrame", {
            Name = tabConfig.Title .. "Content",
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(21, 21, 21),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.95,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = (tabIndex == 1),
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
            Underline = underline,
            Content = tabContent,
            Sections = {},
            Name = tabConfig.Title,
            Index = tabIndex,
            IsSelected = (tabIndex == 1)
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

        -- Tab selection function
        local function selectTab()
            for i = 1, #Window.OrderedTabs do
                local otherTab = Window.OrderedTabs[i]
                if otherTab then
                    otherTab.Content.Visible = false
                    otherTab.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                    otherTab.Label.TextSize = 14
                    otherTab.IsSelected = false
                    
                    TweenService:Create(otherTab.Underline, TweenInfo.new(0.2), {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 2)
                    }):Play()
                end
            end
            
            tabContent.Visible = true
            tab.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.Label.TextSize = 16
            tab.IsSelected = true
            
            tab.Underline.BackgroundTransparency = 0
            tab.Underline.Size = UDim2.new(0, 0, 0, 2)
            tab.Underline.Position = UDim2.new(0.5, 0, 1, 0)
            
            TweenService:Create(tab.Underline, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 2)
            }):Play()
            
            Window.SelectedTab = tabIndex
        end

        -- Tab switching
        tabButton.MouseButton1Click:Connect(selectTab)

        table.insert(Window.OrderedTabs, tab)
        Window.Tabs[tabConfig.Title] = tab
        
        if tabIndex == 1 then
            selectTab()
        end

        updateTabHolderSize()
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
