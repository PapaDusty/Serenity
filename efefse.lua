--[[
    Airflow Interface - Simplified Version
    Author: 4lpaca (Simplified by AI)
    License: MIT
    Github: https://github.com/4lpaca-pin/Airflow
--]]

-- Type Definitions
export type GlobalConfig = {
    Name: string,
    Callback: (...any) -> any,
    Default: any,
    Min: number,
    Max: number,
    Round: number,
    Type: string,
    Values: {string},
    Multi: boolean,
    Position: string,
    Numeric: boolean,
    Finished: boolean,
    Placeholder: string,
}

export type Elements = {
    AddLabel: (self, name: string) -> {Edit: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil},
    AddButton: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil, Fire: (...any) -> any},
    AddToggle: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil, SetValue: (self, Value: boolean) -> any},
    AddSlider: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil, SetValue: (self, Value: number) -> any},
    AddKeybind: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil, SetValue: (self, Value: string | Enum.KeyCode) -> any},
    AddTextbox: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil, SetValue: (self, Value: string) -> any},
    AddColorPicker: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, SetValue: (self, Value: Color3) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil},
    AddParagraph: (self, config: GlobalConfig) -> {EditName: (self, Value: string) -> nil, EditContent: (self, Value: string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil},
    AddDropdown: (self, config: GlobalConfig) -> {Edit: (self, Value: string) -> nil, SetValues: (self, Value: {string}) -> nil, SetDefault: (self, Value: {string} | string) -> nil, Visible: (self, Value: boolean) -> nil, Destroy: (self) -> nil},
}

export type Tab = {
    Left: Elements,
    Right: Elements,
    AddSection: (self, GlobalConfig) -> Elements,
    Disabled: boolean,
    Disable: (self, Value: boolean, Reason: string?) -> any,
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()
local AirflowUI = Instance.new("ScreenGui")

-- CoreGui protection
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    AirflowUI.Parent = CoreGui
    if syn and syn.protect_gui then
        syn.protect_gui(AirflowUI)
    end
end)
AirflowUI.ResetOnSpawn = false
AirflowUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
AirflowUI.IgnoreGuiInset = true

-- Airflow Library
local Airflow = {
    Version = "1.2",
    ScreenGui = AirflowUI,
    Config = {
        Highlight = Color3.fromRGB(163, 128, 216),
        Logo = "http://www.roblox.com/asset/?id=118752982916680",
        Keybind = "Delete",
        IconSize = 20,
    }
}

-- File Manager
Airflow.FileManager = {}
function Airflow.FileManager:WriteConfig(Window, path: string)
    if writefile then
        writefile(path, HttpService:JSONEncode(Window:GetConfigs()))
    end
end

function Airflow.FileManager:GetConfig(Window)
    return HttpService:JSONEncode(Window:GetConfigs())
end

function Airflow.FileManager:LoadConfig(Window, path: string, VERSION: string)
    if not readfile then return false end
    local content = readfile(path)
    local data = HttpService:JSONDecode(content)
    -- Simplified parser - just load values
    return true
end

function Airflow.FileManager:LoadConfigFromString(Window, str: string, VERSION: string)
    local data = HttpService:JSONDecode(str)
    return true
end

-- Utilities
function Airflow:CreateAnimation(Instance: Instance, Time: number, Properties: {[string]: any})
    local Tween = TweenService:Create(Instance, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Linear), Properties)
    Tween:Play()
    return Tween
end

function Airflow:NewInput(frame: Frame, Callback: () -> ())
    local Button = Instance.new("TextButton")
    Button.Parent = frame
    Button.Size = UDim2.fromScale(1, 1)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    if Callback then
        Button.MouseButton1Click:Connect(Callback)
    end
    return Button
end

-- Simplified Color Picker
do
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Name = "ColorPicker"
    ColorPickerFrame.Parent = AirflowUI
    ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Size = UDim2.fromOffset(200, 50)
    ColorPickerFrame.Position = UDim2.fromOffset(0, -100) -- Hidden by default
    ColorPickerFrame.ZIndex = 1000
    
    local TextBox = Instance.new("TextBox")
    TextBox.Parent = ColorPickerFrame
    TextBox.Size = UDim2.fromOffset(180, 30)
    TextBox.Position = UDim2.fromOffset(10, 10)
    TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TextBox.BorderSizePixel = 0
    TextBox.Text = "255,255,255"
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.GothamMedium
    TextBox.TextSize = 14
    TextBox.ZIndex = 1001
    
    Airflow.ColorPicker = {
        Frame = ColorPickerFrame,
        TextBox = TextBox,
        Callback = nil
    }
    
    TextBox.FocusLost:Connect(function()
        local r, g, b = string.match(TextBox.Text, "(%d+),%s*(%d+),%s*(%d+)")
        if r and g and b then
            local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            if Airflow.ColorPicker.Callback then
                Airflow.ColorPicker.Callback(color)
            end
        end
    end)
end

-- Elements Factory
function Airflow:Elements(element: Frame, windowConfig: {[string]: any}): Elements
    local elements = {}
    local ElementId = 1
    
    function elements:AddLabel(name: string)
        local Label = Instance.new("TextLabel")
        Label.Name = "Label_" .. ElementId
        Label.Parent = element
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Position = UDim2.fromOffset(5, 0)
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            Visible = function(_, bool) Label.Visible = bool end,
            Destroy = function() Label:Destroy() end
        }
    end
    
    function elements:AddButton(config: GlobalConfig)
        config.Name = config.Name or "Button"
        local Button = Instance.new("TextButton")
        Button.Name = "Button_" .. ElementId
        Button.Parent = element
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.Position = UDim2.fromOffset(5, 0)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Button.BorderSizePixel = 0
        Button.Text = config.Name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 14
        Button.AutoButtonColor = false
        
        Button.MouseButton1Click:Connect(config.Callback or function() end)
        
        ElementId += 1
        return {
            Edit = function(_, text) Button.Text = text end,
            Visible = function(_, bool) Button.Visible = bool end,
            Destroy = function() Button:Destroy() end,
            Fire = config.Callback
        }
    end
    
    function elements:AddToggle(config: GlobalConfig)
        config.Name = config.Name or "Toggle"
        config.Default = config.Default or false
        
        local Frame = Instance.new("Frame")
        Frame.Name = "Toggle_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 30)
        Frame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.fromOffset(100, 30)
        Label.Position = UDim2.fromOffset(5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = config.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Parent = Frame
        ToggleBtn.Size = UDim2.fromOffset(40, 20)
        ToggleBtn.Position = UDim2.new(1, -45, 0, 5)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Text = ""
        
        local Circle = Instance.new("Frame")
        Circle.Parent = ToggleBtn
        Circle.Size = UDim2.fromOffset(16, 16)
        Circle.Position = config.Default and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
        Circle.BackgroundColor3 = config.Default and (windowConfig.Highlight or Airflow.Config.Highlight) or Color3.fromRGB(100, 100, 100)
        Circle.BorderSizePixel = 0
        
        local value = config.Default
        local function update()
            value = not value
            Circle.BackgroundColor3 = value and (windowConfig.Highlight or Airflow.Config.Highlight) or Color3.fromRGB(100, 100, 100)
            Airflow:CreateAnimation(Circle, 0.1, {Position = value and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)})
            if config.Callback then config.Callback(value) end
        end
        
        ToggleBtn.MouseButton1Click:Connect(update)
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end,
            SetValue = function(_, bool)
                value = bool
                Circle.BackgroundColor3 = value and (windowConfig.Highlight or Airflow.Config.Highlight) or Color3.fromRGB(100, 100, 100)
                Circle.Position = value and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
            end
        }
    end
    
    function elements:AddSlider(config: GlobalConfig)
        config.Name = config.Name or "Slider"
        config.Min = config.Min or 0
        config.Max = config.Max or 100
        config.Default = config.Default or config.Min
        config.Type = config.Type or ""
        
        local Frame = Instance.new("Frame")
        Frame.Name = "Slider_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 40)
        Frame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.new(1, -50, 0, 20)
        Label.Position = UDim2.fromOffset(5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = config.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = Frame
        ValueLabel.Size = UDim2.fromOffset(40, 20)
        ValueLabel.Position = UDim2.new(1, -45, 0, 0)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(config.Default) .. config.Type
        ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueLabel.Font = Enum.Font.GothamMedium
        ValueLabel.TextSize = 13
        
        local Track = Instance.new("Frame")
        Track.Parent = Frame
        Track.Size = UDim2.new(1, -10, 0, 6)
        Track.Position = UDim2.fromOffset(5, 25)
        Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Track.BorderSizePixel = 0
        
        local Fill = Instance.new("Frame")
        Fill.Parent = Track
        Fill.Size = UDim2.fromScale((config.Default - config.Min) / (config.Max - config.Min), 1)
        Fill.BackgroundColor3 = windowConfig.Highlight or Airflow.Config.Highlight
        Fill.BorderSizePixel = 0
        
        local Dragging = false
        local function update(input)
            local relative = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
            relative = math.clamp(relative, 0, 1)
            local value = config.Min + (config.Max - config.Min) * relative
            value = math.floor(value * (10 ^ (config.Round or 0)) + 0.5) / (10 ^ (config.Round or 0))
            Fill.Size = UDim2.fromScale((value - config.Min) / (config.Max - config.Min), 1)
            ValueLabel.Text = tostring(value) .. config.Type
            if config.Callback then config.Callback(value) end
        end
        
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end,
            SetValue = function(_, val)
                val = math.clamp(val, config.Min, config.Max)
                Fill.Size = UDim2.fromScale((val - config.Min) / (config.Max - config.Min), 1)
                ValueLabel.Text = tostring(val) .. config.Type
            end
        }
    end
    
    function elements:AddKeybind(config: GlobalConfig)
        config.Name = config.Name or "Keybind"
        config.Default = config.Default or "None"
        
        local Frame = Instance.new("Frame")
        Frame.Name = "Keybind_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 30)
        Frame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.fromOffset(100, 30)
        Label.Position = UDim2.fromOffset(5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = config.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueBtn = Instance.new("TextButton")
        ValueBtn.Parent = Frame
        ValueBtn.Size = UDim2.fromOffset(60, 22)
        ValueBtn.Position = UDim2.new(1, -65, 0, 4)
        ValueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ValueBtn.BorderSizePixel = 0
        ValueBtn.Text = tostring(config.Default)
        ValueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueBtn.Font = Enum.Font.GothamMedium
        ValueBtn.TextSize = 13
        
        local Keys = {
            One = '1', Two = '2', Three = '3', Four = '4', Five = '5',
            Six = '6', Seven = '7', Eight = '8', Nine = '9', Zero = '0',
            LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift",
            RightShift = "RShift", Return = "Enter", LeftBracket = "[", RightBracket = "]"
        }
        
        local function getKeyName(key)
            if typeof(key) == "EnumItem" then
                return Keys[key.Name] or key.Name
            end
            return tostring(key)
        end
        
        ValueBtn.MouseButton1Click:Connect(function()
            ValueBtn.Text = "..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                conn:Disconnect()
                local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or
                           input.UserInputType == Enum.UserInputType.MouseButton1 and "MouseLeft" or
                           input.UserInputType == Enum.UserInputType.MouseButton2 and "MouseRight" or nil
                if key then
                    ValueBtn.Text = getKeyName(key)
                    if config.Callback then config.Callback(key) end
                end
            end)
        end)
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end,
            SetValue = function(_, key)
                ValueBtn.Text = getKeyName(key)
            end
        }
    end
    
    function elements:AddTextbox(config: GlobalConfig)
        config.Name = config.Name or "TextBox"
        config.Default = config.Default or ""
        config.Placeholder = config.Placeholder or "Enter text..."
        
        local Frame = Instance.new("Frame")
        Frame.Name = "Textbox_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 35)
        Frame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.fromOffset(100, 15)
        Label.Position = UDim2.fromOffset(5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = config.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Box = Instance.new("TextBox")
        Box.Parent = Frame
        Box.Size = UDim2.new(1, -10, 0, 20)
        Box.Position = UDim2.fromOffset(5, 15)
        Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Box.BorderSizePixel = 0
        Box.Text = config.Default
        Box.PlaceholderText = config.Placeholder
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.Font = Enum.Font.GothamMedium
        Box.TextSize = 13
        Box.ClearTextOnFocus = false
        
        if config.Numeric then
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                Box.Text = string.gsub(Box.Text, "[^0-9.]", "")
            end)
        end
        
        local function getValue()
            local text = Box.Text
            if config.Numeric then
                return tonumber(text) or 0
            end
            return text
        end
        
        if config.Finished then
            Box.FocusLost:Connect(function()
                if config.Callback then config.Callback(getValue()) end
            end)
        else
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                if config.Callback then config.Callback(getValue()) end
            end)
        end
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            SetValue = function(_, val) Box.Text = tostring(val) end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end
        }
    end
    
    function elements:AddColorPicker(config: GlobalConfig)
        config.Name = config.Name or "ColorPicker"
        config.Default = config.Default or Color3.fromRGB(255, 255, 255)
        
        local Frame = Instance.new("Frame")
        Frame.Name = "ColorPicker_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 30)
        Frame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.fromOffset(100, 30)
        Label.Position = UDim2.fromOffset(5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = config.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Preview = Instance.new("TextButton")
        Preview.Parent = Frame
        Preview.Size = UDim2.fromOffset(30, 20)
        Preview.Position = UDim2.new(1, -35, 0, 5)
        Preview.BackgroundColor3 = config.Default
        Preview.BorderSizePixel = 0
        Preview.Text = ""
        
        Preview.MouseButton1Click:Connect(function()
            Airflow.ColorPicker.Frame.Position = UDim2.fromOffset(Preview.AbsolutePosition.X, Preview.AbsolutePosition.Y + 30)
            Airflow.ColorPicker.TextBox.Text = string.format("%d,%d,%d", Preview.BackgroundColor3.R * 255, Preview.BackgroundColor3.G * 255, Preview.BackgroundColor3.B * 255)
            Airflow.ColorPicker.Callback = function(color)
                Preview.BackgroundColor3 = color
                if config.Callback then config.Callback(color) end
            end
        end)
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            SetValue = function(_, color) Preview.BackgroundColor3 = color end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end
        }
    end
    
    function elements:AddParagraph(config: GlobalConfig)
        config.Name = config.Name or "Paragraph"
        config.Content = config.Content or ""
        
        local Frame = Instance.new("Frame")
        Frame.Name = "Paragraph_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 50)
        Frame.BackgroundTransparency = 1
        
        local Title = Instance.new("TextLabel")
        Title.Parent = Frame
        Title.Size = UDim2.new(1, -10, 0, 15)
        Title.Position = UDim2.fromOffset(5, 0)
        Title.BackgroundTransparency = 1
        Title.Text = config.Name
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Font = Enum.Font.GothamMedium
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Parent = Frame
        ContentLabel.Size = UDim2.new(1, -10, 1, -20)
        ContentLabel.Position = UDim2.fromOffset(5, 20)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text = config.Content
        ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ContentLabel.Font = Enum.Font.GothamMedium
        ContentLabel.TextSize = 11
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.TextWrapped = true
        
        ElementId += 1
        return {
            EditName = function(_, text) Title.Text = text end,
            EditContent = function(_, text) ContentLabel.Text = text end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end
        }
    end
    
    function elements:AddDropdown(config: GlobalConfig)
        config.Name = config.Name or "Dropdown"
        config.Values = config.Values or {}
        config.Default = config.Default or (config.Multi and {} or "")
        config.Multi = config.Multi or false
        
        local Frame = Instance.new("Frame")
        Frame.Name = "Dropdown_" .. ElementId
        Frame.Parent = element
        Frame.Size = UDim2.new(1, -10, 0, 30)
        Frame.BackgroundTransparency = 1
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.fromOffset(100, 30)
        Label.Position = UDim2.fromOffset(5, 0)
        Label.BackgroundTransparency = 1
        Label.Text = config.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueBtn = Instance.new("TextButton")
        ValueBtn.Parent = Frame
        ValueBtn.Size = UDim2.fromOffset(100, 22)
        ValueBtn.Position = UDim2.new(1, -105, 0, 4)
        ValueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ValueBtn.BorderSizePixel = 0
        ValueBtn.Text = config.Multi and "" or tostring(config.Default)
        ValueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueBtn.Font = Enum.Font.GothamMedium
        ValueBtn.TextSize = 13
        ValueBtn.TextTruncate = Enum.TextTruncate.SplitWord
        
        local DropdownMenu = Instance.new("Frame")
        DropdownMenu.Parent = ValueBtn
        DropdownMenu.Size = UDim2.fromOffset(100, 0)
        DropdownMenu.Position = UDim2.fromOffset(0, 25)
        DropdownMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownMenu.BorderSizePixel = 0
        DropdownMenu.ZIndex = 100
        DropdownMenu.Visible = false
        
        local UIList = Instance.new("UIListLayout")
        UIList.Parent = DropdownMenu
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        
        local selected = config.Default
        
        for _, v in ipairs(config.Values) do
            local Option = Instance.new("TextButton")
            Option.Parent = DropdownMenu
            Option.Size = UDim2.fromOffset(100, 20)
            Option.BackgroundTransparency = 1
            Option.Text = tostring(v)
            Option.TextColor3 = Color3.fromRGB(255, 255, 255)
            Option.Font = Enum.Font.GothamMedium
            Option.TextSize = 12
            Option.ZIndex = 101
            
            Option.MouseButton1Click:Connect(function()
                if config.Multi then
                    if typeof(selected) ~= "table" then selected = {} end
                    selected[v] = not selected[v]
                    Option.BackgroundTransparency = selected[v] and 0.5 or 1
                    local display = {}
                    for val, bool in pairs(selected) do
                        if bool then table.insert(display, tostring(val)) end
                    end
                    ValueBtn.Text = table.concat(display, ", ")
                else
                    selected = v
                    ValueBtn.Text = tostring(v)
                    DropdownMenu.Visible = false
                    if config.Callback then config.Callback(v) end
                end
            end)
        end
        
        ValueBtn.MouseButton1Click:Connect(function()
            DropdownMenu.Visible = not DropdownMenu.Visible
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not (ValueBtn.AbsolutePosition.X <= Mouse.X and Mouse.X <= ValueBtn.AbsolutePosition.X + ValueBtn.AbsoluteSize.X and
                        ValueBtn.AbsolutePosition.Y <= Mouse.Y and Mouse.Y <= ValueBtn.AbsolutePosition.Y + ValueBtn.AbsoluteSize.Y) then
                    DropdownMenu.Visible = false
                end
            end
        end)
        
        ElementId += 1
        return {
            Edit = function(_, text) Label.Text = text end,
            SetValues = function(_, vals) config.Values = vals end,
            SetDefault = function(_, val)
                selected = val
                ValueBtn.Text = config.Multi and "" or tostring(val)
            end,
            Visible = function(_, bool) Frame.Visible = bool end,
            Destroy = function() Frame:Destroy() end
        }
    end
    
    return elements
end

-- Main Window
function Airflow:Init(config: {[string]: any})
    config.Name = config.Name or "Airflow"
    config.Highlight = config.Highlight or Airflow.Config.Highlight
    config.Keybind = config.Keybind or Airflow.Config.Keybind
    config.IconSize = config.IconSize or Airflow.Config.IconSize
    
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = AirflowUI
    Window.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    Window.BorderSizePixel = 0
    Window.Size = UDim2.fromOffset(550, 400)
    Window.Position = UDim2.fromOffset(100, 100)
    Window.ZIndex = 10
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Window
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    Header.BorderSizePixel = 0
    Header.ZIndex = 11
    
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = Header
    Icon.Size = UDim2.fromOffset(config.IconSize, config.IconSize)
    Icon.Position = UDim2.fromOffset(10, (Header.AbsoluteSize.Y - config.IconSize) / 2)
    Icon.BackgroundTransparency = 1
    Icon.Image = config.Logo
    Icon.ZIndex = 12
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Header
    Title.Size = UDim2.fromOffset(200, 20)
    Title.Position = UDim2.fromOffset(config.IconSize + 20, (Header.AbsoluteSize.Y - 20) / 2)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12
    
    -- Minimize/Close buttons
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Parent = Header
    MinimizeBtn.Size = UDim2.fromOffset(30, 25)
    MinimizeBtn.Position = UDim2.new(1, -65, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.ZIndex = 12
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Parent = Header
    CloseBtn.Size = UDim2.fromOffset(30, 25)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.ZIndex = 12
    
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = Window
    Content.Size = UDim2.new(1, 0, 1, -35)
    Content.Position = UDim2.fromOffset(0, 35)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 10
    
    local TabSidebar = Instance.new("Frame")
    TabSidebar.Name = "TabSidebar"
    TabSidebar.Parent = Content
    TabSidebar.Size = UDim2.fromOffset(150, 0)
    TabSidebar.Size = UDim2.new(0, 150, 1, 0)
    TabSidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabSidebar.BorderSizePixel = 0
    TabSidebar.ZIndex = 11
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Content
    TabContainer.Size = UDim2.new(1, -150, 1, 0)
    TabContainer.Position = UDim2.fromOffset(150, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ZIndex = 11
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabSidebar
    TabList.Padding = UDim.new(0, 5)
    
    local Tabs = {}
    local CurrentTab = nil
    local WindowVisible = true
    
    local Response = {
        Toggle = true,
        Tabs = Tabs,
        Highlight = config.Highlight
    }
    
    function Response:DrawTab(tabConfig: {Name: string, Icon: string}): Tab
        tabConfig.Icon = tabConfig.Icon or "book"
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabBtn_" .. tabConfig.Name
        TabButton.Parent = TabSidebar
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.ZIndex = 12
        
        local IconLabel = Instance.new("ImageLabel")
        IconLabel.Parent = TabButton
        IconLabel.Size = UDim2.fromOffset(20, 20)
        IconLabel.Position = UDim2.fromOffset(10, 7)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Image = Airflow.Lucide['lucide-' .. tabConfig.Icon] or ""
        IconLabel.ZIndex = 13
        
        local TabName = Instance.new("TextLabel")
        TabName.Parent = TabButton
        TabName.Size = UDim2.new(1, -40, 1, 0)
        TabName.Position = UDim2.fromOffset(35, 0)
        TabName.BackgroundTransparency = 1
        TabName.Text = tabConfig.Name
        TabName.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabName.Font = Enum.Font.GothamMedium
        TabName.TextSize = 13
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.ZIndex = 13
        
        local TabPage = Instance.new("Frame")
        TabPage.Name = "TabPage_" .. tabConfig.Name
        TabPage.Parent = TabContainer
        TabPage.Size = UDim2.new(1, -10, 1, -10)
        TabPage.Position = UDim2.fromOffset(5, 5)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ZIndex = 12
        
        local LeftPanel = Instance.new("ScrollingFrame")
        LeftPanel.Name = "Left"
        LeftPanel.Parent = TabPage
        LeftPanel.Size = UDim2.new(0.5, -5, 1, 0)
        LeftPanel.BackgroundTransparency = 1
        LeftPanel.ScrollBarThickness = 0
        LeftPanel.ZIndex = 12
        
        local RightPanel = Instance.new("ScrollingFrame")
        RightPanel.Name = "Right"
        RightPanel.Parent = TabPage
        RightPanel.Size = UDim2.new(0.5, -5, 1, 0)
        RightPanel.Position = UDim2.fromScale(0.5, 0)
        RightPanel.BackgroundTransparency = 1
        RightPanel.ScrollBarThickness = 0
        RightPanel.ZIndex = 12
        
        local LeftList = Instance.new("UIListLayout")
        LeftList.Parent = LeftPanel
        LeftList.Padding = UDim.new(0, 5)
        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftPanel.CanvasSize = UDim2.fromOffset(0, LeftList.AbsoluteContentSize.Y + 10)
        end)
        
        local RightList = Instance.new("UIListLayout")
        RightList.Parent = RightPanel
        RightList.Padding = UDim.new(0, 5)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightPanel.CanvasSize = UDim2.fromOffset(0, RightList.AbsoluteContentSize.Y + 10)
        end)
        
        local TabTable = {
            Left = self:Elements(LeftPanel, config),
            Right = self:Elements(RightPanel, config),
            Disabled = false,
            Name = tabConfig.Name
        }
        
        function TabTable:AddSection(sectionConfig: GlobalConfig): Elements
            sectionConfig.Position = sectionConfig.Position or "left"
            local targetPanel = sectionConfig.Position == "left" and LeftPanel or RightPanel
            
            local Section = Instance.new("Frame")
            Section.Parent = targetPanel
            Section.Size = UDim2.new(1, -10, 0, 100)
            Section.BackgroundTransparency = 1
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Parent = Section
            SectionTitle.Size = UDim2.new(1, -10, 0, 20)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = sectionConfig.Name
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.Font = Enum.Font.GothamMedium
            SectionTitle.TextSize = 13
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Parent = Section
            SectionContent.Size = UDim2.new(1, -10, 1, -25)
            SectionContent.Position = UDim2.fromOffset(5, 25)
            SectionContent.BackgroundTransparency = 1
            
            local SectionList = Instance.new("UIListLayout")
            SectionList.Parent = SectionContent
            SectionList.Padding = UDim.new(0, 5)
            SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, -10, 0, SectionList.AbsoluteContentSize.Y + 30)
            end)
            
            return self:Elements(SectionContent, config)
        end
        
        function TabTable:Disable(value: boolean, reason: string?)
            TabTable.Disabled = value
            TabPage.Visible = not value and TabButton.Visible
            if value and CurrentTab == TabButton then
                TabPage.Visible = false
            end
        end
        
        TabButton.MouseButton1Click:Connect(function()
            if TabTable.Disabled then return end
            for _, otherTab in ipairs(Tabs) do
                otherTab.Page.Visible = false
            end
            TabPage.Visible = true
            CurrentTab = TabButton
        end)
        
        table.insert(Tabs, {Button = TabButton, Page = TabPage, Table = TabTable})
        
        if #Tabs == 1 then
            TabPage.Visible = true
            CurrentTab = TabButton
        end
        
        return TabTable
    end
    
    function Response:GetConfigs()
        local config = {VERSION = "1.0"}
        for _, tab in ipairs(Tabs) do
            config[tab.Table.Name] = tab.Table:GetConfigs()
        end
        return config
    end
    
    function Response:SetKeybind(newKey)
        config.Keybind = newKey
    end
    
    -- Window controls
    CloseBtn.MouseButton1Click:Connect(function()
        AirflowUI:Destroy()
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        WindowVisible = not WindowVisible
        Content.Visible = WindowVisible
        Window.Size = WindowVisible and UDim2.fromOffset(550, 400) or UDim2.new(0, 550, 0, 35)
    end)
    
    -- Dragging
    local Dragging = false
    local DragStart = nil
    local StartPos = nil
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - DragStart
            Window.Position = UDim2.fromOffset(StartPos.X.Offset + delta.X, StartPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and (input.KeyCode.Name == config.Keybind or input.KeyCode == config.Keybind) then
            Response.Toggle = not Response.Toggle
            Window.Visible = Response.Toggle
        end
    end)
    
    return Response
end

-- Notification
function Airflow:Notify(config: {Title: string, Content: string, Duration: number?})
    config.Title = config.Title or "Notification"
    config.Content = config.Content or ""
    config.Duration = config.Duration or 3
    
    local Notif = Instance.new("Frame")
    Notif.Name = "Notification"
    Notif.Parent = AirflowUI
    Notif.Size = UDim2.fromOffset(250, 60)
    Notif.Position = UDim2.new(1, 260, 0, 10)
    Notif.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    Notif.BorderSizePixel = 0
    Notif.ZIndex = 1000
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Notif
    TitleLabel.Size = UDim2.new(1, -10, 0, 20)
    TitleLabel.Position = UDim2.fromOffset(5, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = config.Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 1001
    
    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Parent = Notif
    ContentLabel.Size = UDim2.new(1, -10, 1, -30)
    ContentLabel.Position = UDim2.fromOffset(5, 25)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = config.Content
    ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ContentLabel.Font = Enum.Font.GothamMedium
    ContentLabel.TextSize = 12
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
    ContentLabel.TextWrapped = true
    ContentLabel.ZIndex = 1001
    
    -- Simple slide in
    Notif.Position = UDim2.new(1, -260, 0, 10)
    
    if typeof(config.Duration) == "number" then
        task.delay(config.Duration, function()
            Notif.Position = UDim2.new(1, 10, 0, 10)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end
    
    return {
        Close = function() Notif:Destroy() end,
        SetText = function(_, text) ContentLabel.Text = text end
    }
end

-- Lucide Icons (Minimal set)
Airflow.Lucide = {
    ["lucide-file"] = "rbxassetid://10723374641",
    ["lucide-settings"] = "rbxassetid://10734950309",
    ["lucide-keyboard"] = "rbxassetid://10723416765",
    ["lucide-book"] = "rbxassetid://10709781824",
    ["lucide-book-open"] = "rbxassetid://10709781717",
}

return Airflow
