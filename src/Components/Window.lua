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

    -- Load executor assets
    local ExecutorAssets = {}
    local success, assetsResult = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/Assets.lua"))()
    end)
    
    if success and type(assetsResult) == "table" then
        ExecutorAssets = assetsResult
    end

    -- Load executor detection
    local ExecutorName = "Unknown"
    local success, executorResult = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/PapaDusty/Serenity/main/src/GetExecutor.lua"))()
    end)
    
    if success and type(executorResult) == "string" then
        ExecutorName = executorResult
    end

    -- Function to get icon
    local function getIcon(iconName)
        if not iconName or iconName == "" then
            return nil
        end
        return Icons[iconName]
    end

    -- Function to get executor icon ID
    local function getExecutorIcon(executorName)
        for name, iconId in pairs(ExecutorAssets) do
            if string.find(executorName:lower(), name:lower()) then
                return iconId
            end
        end
        return "118034688779559" -- Default Roblox icon
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

    -- Title container (centered like before)
    local TitleContainer = Serenity.Creator.New("Frame", {
        Name = "TitleContainer",
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = TitleBar
    })

    -- Layout to align icon + text horizontally and center them
    Serenity.Creator.New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        Parent = TitleContainer
    })

    -- Title icon
    Serenity.Creator.New("ImageLabel", {
        Name = "TitleIcon",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Image = "rbxassetid://118034688779559",
        Parent = TitleContainer
    })

    -- Title text with faster color animation
    local TitleText = Serenity.Creator.New("TextLabel", {
        Name = "Title",
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "serenity.wtf",
        TextColor3 = Color3.fromRGB(180, 120, 255), -- Initial purple
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleContainer
    })

    -- Color animation for title text (faster)
    local colorPresets = {
        Color3.fromRGB(180, 120, 255), -- Light purple
        Color3.fromRGB(220, 100, 255), -- Bright purple
        Color3.fromRGB(160, 80, 220),  -- Medium purple
        Color3.fromRGB(200, 60, 220),  -- Pinkish purple
        Color3.fromRGB(140, 100, 255), -- Blueish purple
    }

    local currentColorIndex = 1
    local function animateTitleColor()
        while true do
            currentColorIndex = currentColorIndex + 1
            if currentColorIndex > #colorPresets then
                currentColorIndex = 1
            end
            
            TweenService:Create(TitleText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextColor3 = colorPresets[currentColorIndex]
            }):Play()
            
            wait(1) -- Change color every 1 second (faster)
        end
    end

    -- Start color animation
    spawn(animateTitleColor)

    -- Subtitle (on the left)
    local SubTitleText = Serenity.Creator.New("TextLabel", {
        Name = "SubTitle",
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Config.SubTitle or "v" .. Serenity.Version,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Control buttons (EXACTLY like before)
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

    -- Minimize button with icon (EXACTLY like before)
    local MinButton = Serenity.Creator.New("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    -- Minimize button background (EXACTLY like before)
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

    -- Minimize icon (EXACTLY like before)
    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://116543637337872",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = MinButton
    })

    -- Close button with icon (EXACTLY like before)
    local CloseButton = Serenity.Creator.New("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    -- Close button background (EXACTLY like before)
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

    -- Close icon (EXACTLY like before)
    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://114783304987099",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = CloseButton
    })

    -- Info Container (taller and properly rounded)
    Window.InfoContainer = Serenity.Creator.New("Frame", {
        Name = "InfoContainer",
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 1, -36),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BorderSizePixel = 0,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        })
    })

    -- Info container divider line (on top)
    Serenity.Creator.New("Frame", {
        Name = "InfoDivider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = Window.InfoContainer
    })

    -- Player avatar (bigger)
    local Avatar = Serenity.Creator.New("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 1,
        Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png",
        Parent = Window.InfoContainer
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })

    -- Player display name (bigger and bolder text)
    Serenity.Creator.New("TextLabel", {
        Name = "PlayerName",
        Size = UDim2.new(0.5, -40, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundTransparency = 1,
        Text = player.DisplayName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window.InfoContainer
    })

    -- Executor container (replaces SubTitleContainer)
    local ExecutorContainer = Serenity.Creator.New("Frame", {
        Name = "ExecutorContainer",
        Size = UDim2.new(0, 160, 1, 0), -- Wider for bigger text
        Position = UDim2.new(1, -165, 0, 0), -- More to the left
        BackgroundTransparency = 1,
        Parent = Window.InfoContainer
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6) -- Closer spacing
        })
    })

    -- Get executor icon ID
    local executorIconId = getExecutorIcon(ExecutorName)

    -- Executor icon (bigger)
    local ExecutorIcon = Serenity.Creator.New("ImageLabel", {
        Name = "ExecutorIcon",
        Size = UDim2.new(0, 22, 0, 22), -- Bigger icon
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. executorIconId,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = ExecutorContainer
    })

    -- Executor text (bigger and white)
    Serenity.Creator.New("TextLabel", {
        Name = "ExecutorText",
        Size = UDim2.new(1, -86, 1, 0), -- Fixed size
        BackgroundTransparency = 1,
        Text = ExecutorName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14, -- Bigger text
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = ExecutorContainer
    })

    -- Tab navigation area
    Window.TabContainer = Serenity.Creator.New("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, Window.TabWidth, 1, -64),
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
        Size = UDim2.new(0, 1, 1, -64),
        Position = UDim2.new(0, Window.TabWidth, 0, 28),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = Window.Root
    })

    -- Content area
    Window.ContentContainer = Serenity.Creator.New("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -Window.TabWidth - 10, 1, -74),
        Position = UDim2.new(0, Window.TabWidth + 5, 0, 38),
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

    -- Button hover effects (EXACTLY like before)
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

    -- Store tabs in proper order using an array
    Window.OrderedTabs = {}
    Window.TabCount = 0

    -- Track button rows for multi-column layout
    local buttonRowTracker = {}

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

        -- Underline (removed animation, just static)
        local underline = Serenity.Creator.New("Frame", {
            Name = "Underline",
            Size = UDim2.new(0, 0, 0, 2),
            Position = UDim2.new(0.5, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(55, 55, 55),
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

        -- Add divider element to tab content
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

        -- Add tab divider
        function tab:AddTabDivider()
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

        function tab:AddSection(sectionConfig)
            local sectionConfig = sectionConfig or {}
            local isOpen = sectionConfig.Open ~= false
            
            -- Updated section size from 0, -10, 0, 40 to 0, 3, 0, 40
            local sectionFrame = Serenity.Creator.New("Frame", {
                Name = sectionConfig.Title .. "Section",
                Size = UDim2.new(1, 3, 0, 40),
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

            -- Section title
            local sectionTitle = Serenity.Creator.New("TextButton", {
                Name = "Title",
                Size = UDim2.new(1, -10, 0, 30),
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

            -- Section icon
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
                Icon = sectionIcon,
                CurrentRow = nil,
                RowElements = {}
            }

            -- Update section size
            local function updateSectionSize()
                if section.IsOpen then
                    local elementsLayout = elementsContainer:FindFirstChild("UIListLayout")
                    if elementsLayout then
                        sectionFrame.Size = UDim2.new(1, 3, 0, elementsLayout.AbsoluteContentSize.Y + 45)
                    end
                else
                    sectionFrame.Size = UDim2.new(1, 3, 0, 40)
                end
            end

            local elementsLayout = elementsContainer:WaitForChild("UIListLayout")
            elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
            updateSectionSize()

            -- Toggle section visibility
            local function toggleSection()
                section.IsOpen = not section.IsOpen
                elementsContainer.Visible = section.IsOpen
                sectionIcon.Image = "rbxassetid://" .. (section.IsOpen and "106435270493821" or "76847249215450")
                updateSectionSize()
            end

            sectionTitle.MouseButton1Click:Connect(toggleSection)

            -- Function to create a new button row
            local function createButtonRow()
                local rowFrame = Serenity.Creator.New("Frame", {
                    Name = "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 36), -- Shorter height
                    BackgroundTransparency = 1,
                    Parent = elementsContainer
                }, {
                    Serenity.Creator.New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 8)
                    })
                })
                
                local row = {
                    Frame = rowFrame,
                    Buttons = {},
                    ButtonCount = 0
                }
                
                table.insert(section.RowElements, row)
                section.CurrentRow = row
                return row
            end

            -- Function to get or create button row
            local function getButtonRow(position)
                if not section.CurrentRow or section.CurrentRow.ButtonCount >= 4 then
                    return createButtonRow()
                end
                return section.CurrentRow
            end

            function section:AddToggle(toggleConfig)
                local toggleFrame = Serenity.Creator.New("Frame", {
                    Name = toggleConfig.Title .. "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = elementsContainer
                })

                -- Toggle box (original checkbox style on the left)
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

                -- Checkmark (original style)
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

                return toggleObj
            end

            function section:AddButton(buttonConfig)
                local buttonConfig = buttonConfig or {}
                local position = buttonConfig.Position or 1
                
                -- Get or create button row
                local row = getButtonRow(position)
                
                -- Calculate button width based on how many buttons in the row
                local buttonWidth = 1
                if row.ButtonCount > 0 then
                    buttonWidth = 1 / (row.ButtonCount + 1)
                    -- Update existing buttons in the row
                    for _, existingButton in pairs(row.Buttons) do
                        existingButton.Size = UDim2.new(buttonWidth, -4, 0.9, 0) -- Shorter height
                    end
                end
                
                -- Create button with dark background, white text, and border
                local button = Serenity.Creator.New("TextButton", {
                    Name = buttonConfig.Title .. "Button",
                    Size = UDim2.new(buttonWidth, -4, 0.9, 0), -- Shorter height
                    BackgroundColor3 = Color3.fromRGB(21, 21, 21), -- Dark background
                    Text = buttonConfig.Title,
                    TextColor3 = Color3.fromRGB(255, 255, 255), -- White text
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    Parent = row.Frame
                }, {
                    Serenity.Creator.New("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    Serenity.Creator.New("UIStroke", {
                        Color = Color3.fromRGB(100, 100, 100), -- Lighter grey border
                        Thickness = 1
                    })
                    -- No UIGradient - removed gradient effect
                })

                -- Store button in row
                table.insert(row.Buttons, button)
                row.ButtonCount = row.ButtonCount + 1

                -- Click animation
                button.MouseButton1Down:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    }):Play()
                end)

                button.MouseButton1Up:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    }):Play()
                end)

                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    }):Play()
                end)

                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(21, 21, 21)
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

        -- Tab selection function
        local function selectTab()
            for i = 1, #Window.OrderedTabs do
                local otherTab = Window.OrderedTabs[i]
                if otherTab then
                    otherTab.Content.Visible = false
                    otherTab.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                    otherTab.Label.TextSize = 14
                    otherTab.IsSelected = false
                    otherTab.Underline.BackgroundTransparency = 1
                end
            end
            
            tabContent.Visible = true
            tab.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.Label.TextSize = 16
            tab.IsSelected = true
            tab.Underline.BackgroundTransparency = 0
            
            Window.SelectedTab = tabIndex
        end

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
