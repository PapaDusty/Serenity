local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local Camera = workspace.CurrentCamera

return function(Config)
    local Serenity = require(script.Parent.Parent)
    local Creator = require(script.Parent.Parent.Creator)
    
    local Window = {
        Minimized = false,
        Maximized = false,
        Size = Config.Size or UDim2.fromOffset(600, 360),
        CurrentPos = 0,
        TabWidth = Config.TabWidth or 160,
    }

    Window.Position = UDim2.fromOffset(
        Camera.ViewportSize.X / 2 - Window.Size.X.Offset / 2,
        Camera.ViewportSize.Y / 2 - Window.Size.Y.Offset / 2
    )

    local Dragging, DragInput, MousePos, StartPos = false
    local Resizing, ResizePos = false

    -- Create main window
    Window.ScreenGui = Creator.New("ScreenGui", {
        Name = "SerenityUI",
        Parent = player:WaitForChild("PlayerGui")
    })

    -- Acrylic background
    if Serenity.UseAcrylic then
        Window.AcrylicPaint = require(script.Parent.Parent.Acrylic.AcrylicPaint)()
    end

    -- Main container
    Window.Root = Creator.New("Frame", {
        Name = "MainWindow",
        Size = Window.Size,
        Position = Window.Position,
        BackgroundColor3 = Color3.fromRGB(21, 21, 21),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Window.ScreenGui
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        Creator.New("UIStroke", {
            Color = Color3.fromRGB(45, 45, 45),
            Thickness = 1
        })
    })

    -- Add acrylic if enabled
    if Window.AcrylicPaint then
        Window.AcrylicPaint.AddParent(Window.Root)
    end

    -- Title bar
    Window.TitleBar = require(script.Parent.TitleBar)({
        Title = Config.Title or "Serenity UI",
        SubTitle = Config.SubTitle or "v" .. Serenity.Version,
        Parent = Window.Root,
        Window = Window
    })

    -- Tab navigation
    Window.TabHolder = Creator.New("ScrollingFrame", {
        Name = "TabHolder",
        Size = UDim2.new(0, Window.TabWidth, 1, -100),
        Position = UDim2.fromOffset(10, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.Root
    }, {
        Creator.New("UIListLayout", {
            Padding = UDim.new(0, 5)
        })
    })

    -- Tab selector
    Window.Selector = Creator.New("Frame", {
        Name = "Selector",
        Size = UDim2.fromOffset(4, 30),
        Position = UDim2.fromOffset(0, 17),
        BackgroundColor3 = Color3.fromRGB(76, 194, 255),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = Window.TabHolder
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 2)
        })
    })

    -- Content area
    Window.ContainerHolder = Creator.New("Frame", {
        Name = "ContainerHolder",
        Size = UDim2.new(1, -Window.TabWidth - 30, 1, -90),
        Position = UDim2.fromOffset(Window.TabWidth + 20, 70),
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

    Window.TitleBar.Frame.InputBegan:Connect(function(input)
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

    Window.TitleBar.Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdateDrag(input)
        end
    end)

    -- Tab management
    Window.Tabs = {}
    Window.CurrentTab = nil

    function Window:AddTab(config)
        local Tab = require(script.Parent.Tab)(config, Window)
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        return Tab
    end

    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab:Hide()
        end
        
        Window.CurrentTab = tab
        tab:Show()
        
        -- Update selector position
        local tabIndex = table.find(Window.Tabs, tab)
        if tabIndex then
            local selectorPos = (tabIndex - 1) * 35
            TweenService:Create(Window.Selector, TweenInfo.new(0.2), {
                Position = UDim2.fromOffset(0, selectorPos + 17)
            }):Play()
        end
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
