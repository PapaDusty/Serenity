return function(Serenity, Config)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local mouse = player:GetMouse()
    local Camera = workspace.CurrentCamera

    local Window = {
        Minimized = false,
        Maximized = false,
        Size = Config.Size or UDim2.fromOffset(600, 360),
        CurrentPos = 0,
        TabWidth = 160,
        Tabs = {},
        CurrentTab = nil,
        SelectedTab = 1,
        SettingsOpen = false,
        AcrylicMode = false,
        BlurOutside = true,
        UIKeybind = Enum.KeyCode.RightControl
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

    -- Blur effect for settings
    local BlurEffect = Serenity.Creator.New("BlurEffect", {
        Name = "BackgroundBlur",
        Size = 0,
        Parent = Window.ScreenGui
    })

    -- Main container
    Window.Root = Serenity.Creator.New("Frame", {
        Name = "MainWindow",
        Size = Window.Size,
        Position = Window.Position,
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 0,
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

    -- Control buttons
    local ButtonContainer = Serenity.Creator.New("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 78, 0.85, 0),
        Position = UDim2.new(1, -83, 0, 3),
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Serenity.Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8)
        })
    })

    -- Settings button with icon
    local SettingsButton = Serenity.Creator.New("TextButton", {
        Name = "Settings",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    -- Settings button background
    local SettingsButtonBg = Serenity.Creator.New("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 1,
        Parent = SettingsButton
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
    })

    -- Settings icon
    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://123547191593412",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = SettingsButton
    })

    -- Minimize button with icon
    local MinButton = Serenity.Creator.New("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    -- Minimize button background
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

    -- Minimize icon
    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://116543637337872",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = MinButton
    })

    -- Close button with icon
    local CloseButton = Serenity.Creator.New("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = ButtonContainer
    })

    -- Close button background
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

    -- Close icon
    Serenity.Creator.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://114783304987099",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = CloseButton
    })

    -- Info Container
    Window.InfoContainer = Serenity.Creator.New("Frame", {
        Name = "InfoContainer",
        Size = UDim2.new(1, -160, 0, 36), -- Stops at divider
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

    -- Player avatar
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

    -- Player display name
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

    -- Tab navigation area
    Window.TabContainer = Serenity.Creator.New("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 160, 1, -64),
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
        Size = UDim2.new(0, 1, 1, -28),
        Position = UDim2.new(0, 160, 0, 28),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        Parent = Window.Root
    })

    -- Content area
    Window.ContentContainer = Serenity.Creator.New("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -165, 1, -74),
        Position = UDim2.new(0, 165, 0, 38),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BackgroundTransparency = 1,
        Parent = Window.Root
    })

    -- Settings GUI
    local SettingsGUI = Serenity.Creator.New("Frame", {
        Name = "SettingsGUI",
        Size = UDim2.new(0, 300, 0, 200),
        Position = UDim2.new(0.5, -150, 0.5, -100),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = Window.Root
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(80, 80, 80),
            Thickness = 2
        })
    })

    -- Settings title
    Serenity.Creator.New("TextLabel", {
        Name = "SettingsTitle",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = SettingsGUI
    })

    -- Settings content
    local SettingsContent = Serenity.Creator.New("Frame", {
        Name = "SettingsContent",
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        Parent = SettingsGUI
    }, {
        Serenity.Creator.New("UIListLayout", {
            Padding = UDim.new(0, 10)
        })
    })

    -- Acrylic Mode Toggle
    local AcrylicToggleFrame = Serenity.Creator.New("Frame", {
        Name = "AcrylicToggle",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = SettingsContent
    })

    Serenity.Creator.New("TextLabel", {
        Name = "AcrylicLabel",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Acrylic Mode",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = AcrylicToggleFrame
    })

    local AcrylicToggleBox = Serenity.Creator.New("TextButton", {
        Name = "AcrylicToggleBox",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        AutoButtonColor = false,
        Text = "",
        Parent = AcrylicToggleFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    local AcrylicCheckmark = Serenity.Creator.New("ImageLabel", {
        Name = "AcrylicCheckmark",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://123547191593412",
        ImageColor3 = Color3.fromRGB(180, 120, 255),
        Visible = false,
        Parent = AcrylicToggleBox
    })

    -- Blur Outside Toggle
    local BlurToggleFrame = Serenity.Creator.New("Frame", {
        Name = "BlurToggle",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = SettingsContent
    })

    Serenity.Creator.New("TextLabel", {
        Name = "BlurLabel",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Blur Outside",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = BlurToggleFrame
    })

    local BlurToggleBox = Serenity.Creator.New("TextButton", {
        Name = "BlurToggleBox",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        AutoButtonColor = false,
        Text = "",
        Parent = BlurToggleFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        Serenity.Creator.New("UIStroke", {
            Color = Color3.fromRGB(65, 65, 65),
            Thickness = 1
        })
    })

    local BlurCheckmark = Serenity.Creator.New("ImageLabel", {
        Name = "BlurCheckmark",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://123547191593412",
        ImageColor3 = Color3.fromRGB(180, 120, 255),
        Visible = true,
        Parent = BlurToggleBox
    })

    -- Keybind setting
    local KeybindFrame = Serenity.Creator.New("Frame", {
        Name = "KeybindFrame",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = SettingsContent
    })

    Serenity.Creator.New("TextLabel", {
        Name = "KeybindLabel",
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "UI Keybind",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = KeybindFrame
    })

    local KeybindButton = Serenity.Creator.New("TextButton", {
        Name = "KeybindButton",
        Size = UDim2.new(0.3, 0, 0, 25),
        Position = UDim2.new(0.7, 0, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderColor3 = Color3.fromRGB(100, 100, 100),
        BorderSizePixel = 2,
        Text = "RightControl",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = KeybindFrame
    }, {
        Serenity.Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        })
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
    local function setupControlButton(button, bg)
        button.MouseEnter:Connect(function()
            TweenService:Create(bg, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(bg, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end)
    end

    setupControlButton(SettingsButton, SettingsButtonBg)
    setupControlButton(MinButton, MinButtonBg)
    setupControlButton(CloseButton, CloseButtonBg)

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

    -- Settings button functionality
    SettingsButton.MouseButton1Click:Connect(function()
        Window:ToggleSettings()
    end)

    -- Settings toggle functionality
    AcrylicToggleBox.MouseButton1Click:Connect(function()
        Window.AcrylicMode = not Window.AcrylicMode
        AcrylicCheckmark.Visible = Window.AcrylicMode
        
        if Window.AcrylicMode then
            TweenService:Create(Window.Root, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(TitleBar, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.3
            }):Play()
            TweenService:Create(Window.InfoContainer, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.3
            }):Play()
        else
            TweenService:Create(Window.Root, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(TitleBar, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(Window.InfoContainer, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
        end
    end)

    BlurToggleBox.MouseButton1Click:Connect(function()
        Window.BlurOutside = not Window.BlurOutside
        BlurCheckmark.Visible = Window.BlurOutside
        
        if Window.SettingsOpen then
            if Window.BlurOutside then
                TweenService:Create(BlurEffect, TweenInfo.new(0.3), {
                    Size = 10
                }):Play()
            else
                TweenService:Create(BlurEffect, TweenInfo.new(0.3), {
                    Size = 0
                }):Play()
            end
        end
    end)

    -- Keybind functionality
    local listeningForKeybind = false
    KeybindButton.MouseButton1Click:Connect(function()
        listeningForKeybind = true
        KeybindButton.Text = "..."
        KeybindButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if listeningForKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
            listeningForKeybind = false
            Window.UIKeybind = input.KeyCode
            KeybindButton.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            KeybindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        elseif input.KeyCode == Window.UIKeybind and not Window.SettingsOpen then
            Window:Minimize()
        end
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
            
            -- Calculate section width based on position
            local sectionWidth = 1
            if sectionConfig.Position then
                sectionWidth = 0.48 -- Two sections side by side
            end
            
            local sectionFrame = Serenity.Creator.New("Frame", {
                Name = sectionConfig.Title .. "Section",
                Size = UDim2.new(sectionWidth, -5, 0, 40),
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
                        sectionFrame.Size = UDim2.new(sectionWidth, -5, 0, elementsLayout.AbsoluteContentSize.Y + 45)
                    end
                else
                    sectionFrame.Size = UDim2.new(sectionWidth, -5, 0, 40)
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
                    Size = UDim2.new(1, 0, 0, 36),
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

                -- Toggle container for layout
                local toggleContainer = Serenity.Creator.New("Frame", {
                    Name = "ToggleContainer",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = toggleFrame
                }, {
                    Serenity.Creator.New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = UDim.new(0, 10)
                    })
                })

                -- Toggle label (on the left)
                Serenity.Creator.New("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -35, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggleConfig.Title,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Parent = toggleContainer
                })

                -- Toggle box (on the right)
                local toggleBox = Serenity.Creator.New("TextButton", {
                    Name = "ToggleBox",
                    Size = UDim2.new(0, 20, 0, 20),
                    BackgroundColor3 = Color3.fromRGB(21, 21, 21),
                    AutoButtonColor = false,
                    Text = "",
                    Parent = toggleContainer
                }, {
                    Serenity.Creator.New("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    Serenity.Creator.New("UIStroke", {
                        Color = Color3.fromRGB(65, 65, 65),
                        Thickness = 1
                    })
                })

                -- Checkmark with smooth animation
                local checkmark = Serenity.Creator.New("ImageLabel", {
                    Name = "Checkmark",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0.5, -7, 0.5, -7),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://123547191593412",
                    ImageColor3 = Color3.fromRGB(180, 120, 255),
                    Visible = false,
                    Parent = toggleBox
                })

                local toggleValue = toggleConfig.Default or false

                local function updateToggle()
                    if toggleValue then
                        TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(120, 60, 220)
                        }):Play()
                        TweenService:Create(checkmark, TweenInfo.new(0.2), {
                            ImageTransparency = 0
                        }):Play()
                        checkmark.Visible = true
                    else
                        TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                        }):Play()
                        TweenService:Create(checkmark, TweenInfo.new(0.2), {
                            ImageTransparency = 1
                        }):Play()
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
                        TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        }):Play()
                    end
                end)

                toggleBox.MouseLeave:Connect(function()
                    if not toggleValue then
                        TweenService:Create(toggleBox, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(21, 21, 21)
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
                        existingButton.Size = UDim2.new(buttonWidth, -4, 0.9, 0)
                    end
                end
                
                -- Create button with proper border (like your example)
                local button = Serenity.Creator.New("TextButton", {
                    Name = buttonConfig.Title .. "Button",
                    Size = UDim2.new(buttonWidth, -4, 0.9, 0),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    BorderColor3 = Color3.fromRGB(100, 100, 100),
                    BorderSizePixel = 2,
                    Text = buttonConfig.Title,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    Parent = row.Frame
                }, {
                    Serenity.Creator.New("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    })
                })

                -- Store button in row
                table.insert(row.Buttons, button)
                row.ButtonCount = row.ButtonCount + 1

                -- Click animation
                button.MouseButton1Down:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    }):Play()
                end)

                button.MouseButton1Up:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    }):Play()
                end)

                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    }):Play()
                end)

                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

        -- Tab selection function with smooth animation
        local function selectTab()
            for i = 1, #Window.OrderedTabs do
                local otherTab = Window.OrderedTabs[i]
                if otherTab then
                    otherTab.Content.Visible = false
                    TweenService:Create(otherTab.Label, TweenInfo.new(0.3), {
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        TextSize = 14
                    }):Play()
                    otherTab.IsSelected = false
                    otherTab.Underline.BackgroundTransparency = 1
                end
            end
            
            tabContent.Visible = true
            TweenService:Create(tabLabel, TweenInfo.new(0.3), {
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16
            }):Play()
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

    -- Settings toggle function
    function Window:ToggleSettings()
        Window.SettingsOpen = not Window.SettingsOpen
        
        if Window.SettingsOpen then
            SettingsGUI.Visible = true
            TweenService:Create(SettingsGUI, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
            
            if Window.BlurOutside then
                TweenService:Create(BlurEffect, TweenInfo.new(0.3), {
                    Size = 10
                }):Play()
            end
        else
            TweenService:Create(SettingsGUI, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {
                Size = 0
            }):Play()
            
            wait(0.3)
            SettingsGUI.Visible = false
        end
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
