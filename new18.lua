-- Enhanced Roblox UI Library (Fully Fixed & Fluent-Style)
local Library = {Windows = {}, Keybinds = {}, Config = {Theme = "Dark"}, OpenFrames = {}}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	return obj
end

local function Tween(obj, props, duration, style, direction)
	return TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
end

-- Load Lucide Icons
local Icons = {}
local success, response = pcall(function()
	return game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/LucideIcons.luau ")
end)
if success then
	Icons = loadstring(response)()
else
	warn("Failed to load Lucide Icons library")
	Icons = {}
end

-- Global keybind handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for _, keybind in pairs(Library.Keybinds) do
		if keybind.Value == input.KeyCode or keybind.Value == input.UserInputType then
			if keybind.Mode == "Toggle" then
				keybind.Active = not keybind.Active
				pcall(keybind.Callback, keybind.Active)
			elseif keybind.Mode == "Hold" then
				keybind.Holding = true
				pcall(keybind.Callback, true)
			elseif keybind.Mode == "Always" then
				pcall(keybind.Callback)
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	for _, keybind in pairs(Library.Keybinds) do
		if keybind.Mode == "Hold" and (keybind.Value == input.KeyCode or keybind.Value == input.UserInputType) then
			keybind.Holding = false
			pcall(keybind.Callback, false)
		end
	end
end)

function Library:CreateWindow(config)
	if type(config) ~= "table" then return warn("Config must be a table") end

	local Window = {
		Tabs = {},
		CurrentTab = nil,
		Connections = {},
		Title = tostring(config.Title or "UI Library"),
		Description = tostring(config.Description or ""),
		Image = config.Image or nil,
		ImageTransparency = type(config.ImageTransparency) == "number" and config.ImageTransparency or 0.42,
		MinimizeKey = config.MinimizeKey or Enum.KeyCode.LeftControl,
		Minimized = false,
		CanMinimize = config.CanMinimize ~= false,
		CanClose = config.CanClose ~= false,
		Hidden = false
	}

	local windowOffset = #Library.Windows * 0.05

	local gui = Create("ScreenGui", {
		Name = "LibraryUI_" .. (#Library.Windows + 1),
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})

	local main = Create("Frame", {
		Name = "Main",
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5 + windowOffset, 0, 0.5, 0),
		Size = UDim2.new(0, 620, 0, 460),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		ClipsDescendants = true
	})

	Create("UICorner", {CornerRadius = UDim.new(0.02, 0), Parent = main})
	Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = main})

	if Window.Image then
		local bgImage = Create("ImageLabel", {
			Parent = main,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = Window.Image,
			ImageTransparency = Window.ImageTransparency,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 0
		})
		Create("UICorner", {CornerRadius = UDim.new(0.02, 0), Parent = bgImage})
	end

	local titleBar = Create("Frame", {
		Name = "TitleBar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, 40), -- Shorter title bar (was 46)
		BackgroundTransparency = 1
	})

	local logo = Create("ImageLabel", {
		Parent = titleBar,
		Position = UDim2.new(0, 15, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		Image = "rbxassetid://116523599334562",
		ScaleType = Enum.ScaleType.Fit
	})

	Create("TextLabel", {
		Parent = titleBar,
		Position = UDim2.new(0, 48, 0, 10),
		Size = UDim2.new(1, -96, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = Window.Title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	if Window.Description ~= "" then
		Create("TextLabel", {
			Parent = titleBar,
			Position = UDim2.new(0, 48, 0, 25),
			Size = UDim2.new(1, -96, 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = Window.Description,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	local buttonHolder = Create("Frame", {
		Parent = titleBar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.new(0, 70, 0, 24),
		BackgroundTransparency = 1
	})

	local createButton = function(icon, size, pos, callback)
		local btn = Create("ImageButton", {
			Parent = buttonHolder,
			Position = pos,
			Size = size,
			BackgroundTransparency = 1,
			Image = icon,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = Color3.fromRGB(180, 180, 180)
		})
		
		local hoverBg = Create("Frame", {
			Parent = btn,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			BackgroundTransparency = 1,
			ZIndex = -1
		})
		Create("UICorner", {CornerRadius = UDim.new(0.2, 0), Parent = hoverBg})
		
		btn.MouseEnter:Connect(function()
			Tween(hoverBg, {BackgroundTransparency = 0.7}):Play()
		end)
		btn.MouseLeave:Connect(function()
			Tween(hoverBg, {BackgroundTransparency = 1}):Play()
		end)
		
		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	if Window.CanMinimize then
		createButton("rbxassetid://104255241083015", UDim2.new(0, 18, 0, 20), UDim2.new(0, 20, 0, 2), function()
			Window.Hidden = not Window.Hidden
			main.Visible = not Window.Hidden
		end)
	end

	if Window.CanClose then
		createButton("rbxassetid://114783304987099", UDim2.new(0, 16, 0, 20), UDim2.new(0, 42, 0, 2), function()
			Window:Destroy()
		end)
	end

	local contentBg = Create("Frame", {
		Parent = main,
		Position = UDim2.new(0.238, 0, 0.115, 0),
		Size = UDim2.new(0, 497, 0, 354),
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0
	})

	Create("UICorner", {CornerRadius = UDim.new(0.01, 0), Parent = contentBg})
	Create("UIStroke", {Color = Color3.fromRGB(25, 25, 25), Thickness = 1, Parent = contentBg})

	-- TAB CONTAINER - Made longer and wider
	local tabContainer = Create("Frame", {
		Parent = main,
		Position = UDim2.new(0.01, 0, 0.115, 0), -- Adjusted position
		Size = UDim2.new(0, 150, 0, 380), -- Longer and wider (was 135, 324)
		BackgroundTransparency = 1
	})

	Create("UIListLayout", {
		Parent = tabContainer, 
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Left
	})

	local contentScroll = Create("ScrollingFrame", {
		Parent = main,
		Position = UDim2.new(0.26, 0, 0.115, 0), -- Adjusted for new tab width
		Size = UDim2.new(0.74, 0, 0.883, 0), -- Adjusted size
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	})

	Create("UIPadding", {
		Parent = contentScroll,
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10) -- Added bottom padding
	})

	local userInfoFrame = Create("Frame", {
		Parent = main,
		Position = UDim2.new(0, 15, 1, -45),
		Size = UDim2.new(0, 200, 0, 36),
		BackgroundTransparency = 1
	})

	local player = Players.LocalPlayer
	local userId = player.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	local avatarImg = Create("ImageLabel", {
		Parent = userInfoFrame,
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 0, 0, 2),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		Image = content,
		BackgroundTransparency = 0
	})
	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = avatarImg})
	Create("UIStroke", {Color = Color3.fromRGB(200, 200, 200), Thickness = 1, Transparency = 0.8, Parent = avatarImg})

	Create("TextLabel", {
		Parent = userInfoFrame,
		Position = UDim2.new(0, 38, 0, 0),
		Size = UDim2.new(0, 150, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = player.DisplayName,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	Create("TextLabel", {
		Parent = userInfoFrame,
		Position = UDim2.new(0, 38, 0, 18),
		Size = UDim2.new(0, 150, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "@" .. player.Name,
		TextColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	-- Dragging
	local dragging, dragStart, startPos
	table.insert(Window.Connections, titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end))

	table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))

	table.insert(Window.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	-- Minimize keybind
	table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Window.MinimizeKey then
			Window.Hidden = not Window.Hidden
			main.Visible = not Window.Hidden
		end
	end))

	function Window:CreateTab(config)
		local name = config.Name or config.Title or "Tab"
		local icon = config.Icon or config.Image or nil
		if type(name) ~= "string" or name == "" then return warn("Tab name required") end

		local Tab = {Elements = {}, Name = name, CurrentSide = 0, Icon = icon}
		local isFirst = #Window.Tabs == 0

		-- TAB BUTTON - Fixed with proper icon positioning
		local btn = Create("TextButton", {
			Parent = tabContainer,
			Size = UDim2.new(0.9, 0, 0, 40), -- Slightly taller
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = "", -- Text will be handled separately
			TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
			TextSize = isFirst and 16 or 14, -- Bigger text for selected tab
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			ClipsDescendants = true
		})

		-- Icon
		local iconLabel = nil
		if icon and Icons[icon] then
			iconLabel = Create("ImageLabel", {
				Parent = btn,
				Position = UDim2.new(0, 8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, isFirst and 20 or 18, 0, isFirst and 20 or 18), -- Bigger icon for selected
				BackgroundTransparency = 1,
				Image = "rbxassetid://" .. tostring(Icons[icon]),
				ScaleType = Enum.ScaleType.Fit,
				ImageColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
			})
		end

		-- Text label for tab
		local textLabel = Create("TextLabel", {
			Parent = btn,
			Position = UDim2.new(0, iconLabel and 32 or 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(1, -40, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
			TextSize = isFirst and 16 or 14, -- Bigger text for selected tab
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd
		})

		Create("UIPadding", {Parent = btn, PaddingLeft = UDim.new(0, 5)})

		-- Underline for selected tab
		local underline = Create("Frame", {
			Parent = btn,
			Size = UDim2.new(0, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(100, 150, 255),
			BorderSizePixel = 0,
			BackgroundTransparency = isFirst and 0 or 1
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = underline})

		local content = Create("Frame", {
			Parent = contentScroll,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Visible = isFirst,
			AutomaticSize = Enum.AutomaticSize.Y
		})

		local layout = Create("UIListLayout", {Parent = content, Padding = UDim.new(0, 12)}) -- Increased spacing

		table.insert(Window.Connections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			contentScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40) -- Added padding for scroll
		end))

		table.insert(Window.Connections, btn.MouseButton1Click:Connect(function()
			if Window.CurrentTab == Tab then return end
			for _, tab in ipairs(Window.Tabs) do
				-- Reset all tabs
				Tween(tab.Button.TextLabel, {TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14}):Play()
				Tween(tab.Underline, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2)}):Play()
				if tab.IconLabel then
					Tween(tab.IconLabel, {ImageColor3 = Color3.fromRGB(150, 150, 150), Size = UDim2.new(0, 18, 0, 18)}):Play()
				end
				tab.Content.Visible = false
			end
			-- Activate current tab
			Tween(textLabel, {TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16}):Play()
			Tween(underline, {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 2)}):Play()
			if iconLabel then
				Tween(iconLabel, {ImageColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 20, 0, 20)}):Play()
			end
			content.Visible = true
			Window.CurrentTab = Tab
		end))

		Tab.Button = btn
		Tab.Content = content
		Tab.Underline = underline
		Tab.IconLabel = iconLabel
		Tab.TextLabel = textLabel

		table.insert(Window.Tabs, Tab)
		if isFirst then Window.CurrentTab = Tab end

		function Tab:AddParagraph(config)
			config = config or {}
			local elem = {
				Type = "Paragraph",
				Title = tostring(config.Title or ""),
				Content = tostring(config.Content or ""),
				Visible = true,
				Side = 0
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			return {
				SetTitle = function(_, title) elem.Title = tostring(title) Tab:Render() end,
				SetContent = function(_, content) elem.Content = tostring(content) Tab:Render() end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end
			}
		end

		function Tab:AddButton(config)
			config = config or {}
			local elem = {
				Type = "Button",
				Title = tostring(config.Title or "Button"),
				Description = tostring(config.Description or ""),
				Callback = config.Callback or function() end,
				Visible = true,
				Side = config.Side or 0
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			return {
				SetTitle = function(_, title) elem.Title = tostring(title) Tab:Render() end,
				SetDescription = function(_, desc) elem.Description = tostring(desc) Tab:Render() end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end
			}
		end

		function Tab:AddToggle(config)
			config = config or {}
			local elem = {
				Type = "Toggle",
				Title = tostring(config.Title or "Toggle"),
				Default = type(config.Default) == "boolean" and config.Default or false,
				Callback = config.Callback or function() end,
				Visible = true,
				Side = config.Side or 0,
				Value = type(config.Default) == "boolean" and config.Default or false
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			local toggleObject = {
				SetValue = function(_, val) if type(val) == "boolean" then elem.Value = val Tab:Render() end end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
			
			pcall(elem.Callback, elem.Value)
			
			return toggleObject
		end

		function Tab:AddInput(config)
			config = config or {}
			local elem = {
				Type = "Input",
				Title = tostring(config.Title or "Input"),
				Default = tostring(config.Default or ""),
				Placeholder = tostring(config.Placeholder or ""),
				Numeric = config.Numeric or false,
				Finished = config.Finished or false,
				Callback = config.Callback or function() end,
				Visible = true,
				Value = tostring(config.Default or ""),
				Side = 0
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			return {
				SetValue = function(_, val) elem.Value = tostring(val) Tab:Render() end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddKeybind(config)
			config = config or {}
			local elem = {
				Type = "Keybind",
				Title = tostring(config.Title or "Keybind"),
				Default = config.Default or Enum.KeyCode.F,
				Mode = config.Mode or "Toggle",
				Callback = config.Callback or function() end,
				ChangedCallback = config.ChangedCallback or function() end,
				Visible = true,
				Value = config.Default or Enum.KeyCode.F,
				Active = false,
				Holding = false,
				Listening = false
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			table.insert(Library.Keybinds, elem)
			
			return {
				SetValue = function(_, key, mode)
					elem.Value = typeof(key) == "EnumItem" and key or Enum.KeyCode.F
					elem.Mode = mode or elem.Mode
					Tab:Render()
				end,
				GetValue = function() return elem.Value end,
				GetState = function() return elem.Active or elem.Holding end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.ChangedCallback = cb end
			}
		end

		function Tab:AddDivider(config)
			config = config or {}
			local elem = {
				Type = "Divider",
				Visible = true,
				Side = 0
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			return {
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end
			}
		end

		function Tab:AddSlider(config)
			config = config or {}
			config.Default = tonumber(config.Default) or 50
			config.Min = tonumber(config.Min) or 0
			config.Max = tonumber(config.Max) or 100
			config.Rounding = tonumber(config.Rounding) or 0

			local elem = {
				Type = "Slider",
				Title = tostring(config.Title or "Slider"),
				Min = config.Min,
				Max = config.Max,
				Value = math.clamp(config.Default, config.Min, config.Max),
				Rounding = config.Rounding,
				Callback = config.Callback or function() end,
				Visible = true,
				Side = config.Side or 0
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			pcall(elem.Callback, elem.Value)
			
			return {
				SetValue = function(_, val)
					elem.Value = math.clamp(val, elem.Min, elem.Max)
					Tab:Render()
				end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddDropdown(config)
			config = config or {}
			local elem = {
				Type = "Dropdown",
				Title = tostring(config.Title or "Dropdown"),
				Values = type(config.Values) == "table" and config.Values or {},
				Value = config.Default or (config.Values and config.Values[1]) or "",
				Multi = config.Multi or false,
				Callback = config.Callback or function() end,
				Visible = true,
				Open = false,
				Side = config.Side or 0
			}
			
			if elem.Multi then
				elem.Value = {}
				if config.Default and type(config.Default) == "table" then
					for _, v in ipairs(config.Default) do
						elem.Value[v] = true
					end
				end
			end
			
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			pcall(elem.Callback, elem.Value)
			
			return {
				SetValue = function(_, val)
					if elem.Multi then
						elem.Value = type(val) == "table" and val or {}
					else
						elem.Value = tostring(val)
					end
					Tab:Render()
				end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddColorpicker(config)
			config = config or {}
			local elem = {
				Type = "Colorpicker",
				Title = tostring(config.Title or "Colorpicker"),
				Default = config.Default or Color3.fromRGB(255, 255, 255),
				Transparency = config.Transparency,
				Value = config.Default or Color3.fromRGB(255, 255, 255),
				TransValue = config.Transparency and 0 or nil,
				Callback = config.Callback or function() end,
				Visible = true,
				Open = false,
				Side = 0
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			pcall(elem.Callback, elem.Value)
			
			return {
				SetValue = function(_, color, trans)
					elem.Value = color or elem.Value
					elem.TransValue = trans or elem.TransValue
					Tab:Render()
				end,
				GetValue = function() return elem.Value, elem.TransValue end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:GetSelectedOptions(valueTable)
			local selected = {}
			for option, isSelected in pairs(valueTable) do
				if isSelected then
					table.insert(selected, option)
				end
			end
			return selected
		end

		function Tab:Render()
			for _, child in ipairs(content:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			Tab.CurrentSide = 0
			local currentRow = nil

			for _, elem in ipairs(Tab.Elements) do
				if not elem.Visible then continue end

				local elemSide = elem.Side or 0
				if elemSide == 1 or Tab.CurrentSide == 0 then
					currentRow = Create("Frame", {
						Parent = content,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						Name = "RowFrame"
					})
					Create("UIListLayout", {
						Parent = currentRow,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 8),
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder
					})
					Tab.CurrentSide = 1
				end

				local container = (elem.Side == 1 or elem.Side == 2) and currentRow or content

				if elem.Type == "Paragraph" then
					Tab.CurrentSide = 0
					container = content
					
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y
					})
					Create("UICorner", {CornerRadius = UDim.new(0.05, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					Create("UIPadding", {Parent = frame, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
					local container = Create("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
					Create("UIListLayout", {Parent = container, Padding = UDim.new(0, 4)})
					Create("TextLabel", {
						Parent = container,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y
					})
					Create("TextLabel", {
						Parent = container,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Content,
						TextColor3 = Color3.fromRGB(180, 180, 180),
						TextSize = 13,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y
					})

				elseif elem.Type == "Button" then
					-- Taller button (was 42)
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side == 1 and 0.5 or 1, elem.Side == 1 and -4 or 0, 0, 48),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.None
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					
					-- Text container like Paragraph
					Create("UIPadding", {Parent = frame, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})
					local textContainer = Create("Frame", {
						Parent = frame,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1
					})
					Create("UIListLayout", {Parent = textContainer, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center})
					
					Create("TextLabel", {
						Parent = textContainer,
						Size = UDim2.new(1, 0, 0, 16),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.VerticalAlignment.Bottom
					})
					if elem.Description ~= "" then
						Create("TextLabel", {
							Parent = textContainer,
							Size = UDim2.new(1, 0, 0, 14),
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Text = elem.Description,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 11,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.VerticalAlignment.Top
						})
					end
					
					local btn = Create("TextButton", {
						Parent = frame,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						AutoButtonColor = false
					})
					btn.MouseButton1Click:Connect(function()
						pcall(function()
							Tween(frame, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1):Play()
							task.delay(0.1, function() Tween(frame, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.1):Play() end)
							elem.Callback()
						end)
					end)
					if elem.Side == 2 then Tab.CurrentSide = 0 end

				elseif elem.Type == "Toggle" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side == 1 and 0.5 or 1, elem.Side == 1 and -4 or 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					Create("TextLabel", {
						Parent = frame,
						Position = UDim2.new(0.026, 0, 0, 0),
						Size = UDim2.new(0.75, 0, 1, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					
					-- Fluent-style toggle
					local toggleFrame = Create("Frame", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.975, 0, 0.5, 0),
						Size = UDim2.new(0, 40, 0, 20),
						BackgroundColor3 = elem.Value and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(30, 30, 30),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = toggleFrame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = toggleFrame})
					
					local toggleDot = Create("Frame", {
						Parent = toggleFrame,
						Size = UDim2.new(0, 16, 0, 16),
						Position = elem.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = toggleDot})
					
					local btn = Create("TextButton", {
						Parent = frame,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						AutoButtonColor = false
					})
					btn.MouseButton1Click:Connect(function()
						pcall(function()
							elem.Value = not elem.Value
							Tween(toggleFrame, {BackgroundColor3 = elem.Value and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(30, 30, 30)}, 0.2):Play()
							Tween(toggleDot, {Position = elem.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2):Play()
							elem.Callback(elem.Value)
						end)
					end)
					if elem.Side == 2 then Tab.CurrentSide = 0 end

				elseif elem.Type == "Input" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(1, 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					Create("TextLabel", {
						Parent = frame,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.026, 0, 0.5, 0),
						Size = UDim2.new(0.35, 0, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					local inputFrame = Create("Frame", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.974, 0, 0.5, 0),
						Size = UDim2.new(0.45, 0, 0, 28),
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = inputFrame})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = inputFrame})
					local input = Create("TextBox", {
						Parent = inputFrame,
						Position = UDim2.new(0, 10, 0, 0),
						Size = UDim2.new(1, -20, 1, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						PlaceholderText = elem.Placeholder,
						PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
						Text = elem.Value,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						ClearTextOnFocus = false
					})
					input.FocusLost:Connect(function()
						pcall(function()
							elem.Value = input.Text
							if elem.Numeric then
								elem.Value = tonumber(elem.Value) or 0
							end
							if not elem.Finished or input.UserInputType == Enum.UserInputType.Keyboard then
								elem.Callback(elem.Value)
							end
						end)
					end)

				elseif elem.Type == "Keybind" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side == 1 and 0.5 or 1, elem.Side == 1 and -4 or 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					Create("TextLabel", {
						Parent = frame,
						Position = UDim2.new(0.026, 0, 0, 0),
						Size = UDim2.new(0.6, 0, 1, 0),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					local keyBtn = Create("TextButton", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.974, 0, 0.5, 0),
						Size = UDim2.new(0, 80, 0, 28),
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderSizePixel = 0,
						Font = Enum.Font.Gotham,
						Text = elem.Listening and "..." or elem.Value.Name,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = keyBtn})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = keyBtn})
					keyBtn.MouseButton1Click:Connect(function()
						elem.Listening = true
						keyBtn.Text = "..."
					end)
					table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if elem.Listening and not gameProcessed then
							elem.Listening = false
							elem.Value = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
							keyBtn.Text = elem.Value.Name
							pcall(elem.ChangedCallback, elem.Value)
							Tab:Render()
						end
					end))
					if elem.Side == 2 then Tab.CurrentSide = 0 end

				elseif elem.Type == "Divider" then
					Create("Frame", {
						Parent = content,
						Size = UDim2.new(1, 0, 0, 2),
						BackgroundTransparency = 1
					}).ChildAdded:Connect(function(child)
						if child:IsA("Frame") then
							child.AnchorPoint = Vector2.new(0.5, 0.5)
							child.Position = UDim2.new(0.5, 0, 0.5, 0)
							child.Size = UDim2.new(0.9, 0, 0, 1)
							child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
							child.BorderSizePixel = 0
						end
					end)
					Tab.CurrentSide = 0

				elseif elem.Type == "Slider" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side == 1 and 0.5 or 1, elem.Side == 1 and -4 or 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					
					Create("TextLabel", {
						Parent = frame,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.026, 0, 0.5, 0),
						Size = UDim2.new(0.35, 0, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					
					-- Value label on LEFT of slider (FIXED)
					local valueLabel = Create("TextLabel", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.5, -5, 0.5, 0), -- Moved left of slider
						Size = UDim2.new(0, 40, 0, 18),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = string.format("%." .. elem.Rounding .. "f", elem.Value),
						TextColor3 = Color3.fromRGB(150, 150, 150),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Right
					})
					
					local sliderTrack = Create("Frame", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.974, 0, 0.5, 0),
						Size = UDim2.new(0.35, 0, 0, 6), -- Slightly smaller to fit value
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = sliderTrack})
					
					local sliderFill = Create("Frame", {
						Parent = sliderTrack,
						Size = UDim2.new((elem.Value - elem.Min) / (elem.Max - elem.Min), 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(100, 150, 255),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = sliderFill})
					
					local sliderBtn = Create("TextButton", {
						Parent = sliderTrack,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Text = "",
						ZIndex = 2
					})
					
					local draggingSlider = false
					sliderBtn.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							draggingSlider = true
						end
					end)
					
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							draggingSlider = false
						end
					end)
					
					UserInputService.InputChanged:Connect(function(input)
						if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
							local relativePos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
							local newValue = elem.Min + (elem.Max - elem.Min) * relativePos
							elem.Value = elem.Rounding > 0 and tonumber(string.format("%." .. elem.Rounding .. "f", newValue)) or math.floor(newValue)
							valueLabel.Text = string.format("%." .. elem.Rounding .. "f", elem.Value)
							sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
							elem.Callback(elem.Value)
						end
					end)
					
					if elem.Side == 2 then Tab.CurrentSide = 0 end

				elseif elem.Type == "Dropdown" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side == 1 and 0.5 or 1, elem.Side == 1 and -4 or 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0,
						Name = "DropdownContainer",
						ClipsDescendants = true -- Prevent overflow
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					
					Create("TextLabel", {
						Parent = frame,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.026, 0, 0.5, 0),
						Size = UDim2.new(0.35, 0, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					
					local dropdownBtn = Create("TextButton", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.974, 0, 0.5, 0),
						Size = UDim2.new(0.45, 0, 0, 28),
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderSizePixel = 0,
						Font = Enum.Font.Gotham,
						Text = elem.Multi and (next(elem.Value) and table.concat(Tab:GetSelectedOptions(elem.Value), ", ") or "None") or elem.Value,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						ZIndex = 2,
						TextTruncate = Enum.TextTruncate.AtEnd
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = dropdownBtn})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dropdownBtn})
					
					-- Dropdown menu - Fixed positioning and ZIndex
					local dropdownMenu = Create("ScrollingFrame", {
						Parent = frame,
						Position = UDim2.new(0.5, 0, 0, 44),
						AnchorPoint = Vector2.new(0.5, 0),
						Size = UDim2.new(0.95, 0, 0, math.min(#elem.Values * 28, 180)), -- Slightly taller options
						BackgroundColor3 = Color3.fromRGB(20, 20, 20),
						BorderSizePixel = 0,
						ScrollBarThickness = 3,
						Visible = elem.Open,
						ZIndex = 100, -- High ZIndex to be visible
						CanvasSize = UDim2.new(0, 0, 0, #elem.Values * 28),
						ScrollingDirection = Enum.ScrollingDirection.Y
					})
					Create("UICorner", {CornerRadius = UDim.new(0.05, 0), Parent = dropdownMenu})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dropdownMenu})
					Create("UIPadding", {Parent = dropdownMenu, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
					Create("UIListLayout", {
						Parent = dropdownMenu,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder
					})
					
					dropdownBtn.MouseButton1Click:Connect(function()
						elem.Open = not elem.Open
						Tab:Render()
					end)
					
					-- Clear old options
					for _, child in ipairs(dropdownMenu:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					
					for i, option in ipairs(elem.Values) do
						local optionBtn = Create("TextButton", {
							Parent = dropdownMenu,
							Size = UDim2.new(1, 0, 0, 26), -- Slightly taller
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Text = option,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 13,
							AutoButtonColor = false,
							ZIndex = 100,
							LayoutOrder = i
						})
						Create("UIPadding", {Parent = optionBtn, PaddingLeft = UDim.new(0, 8)})
						
						-- Visual indicator for selected options
						if elem.Multi then
							if elem.Value[option] then
								optionBtn.Font = Enum.Font.GothamBold
								optionBtn.Text = "✓ " .. option
							end
						else
							if elem.Value == option then
								optionBtn.Font = Enum.Font.GothamBold
							end
						end
						
						optionBtn.MouseButton1Click:Connect(function()
							if elem.Multi then
								elem.Value[option] = not elem.Value[option]
								dropdownBtn.Text = next(elem.Value) and table.concat(Tab:GetSelectedOptions(elem.Value), ", ") or "None"
							else
								elem.Value = option
								elem.Open = false
								dropdownBtn.Text = option
							end
							elem.Callback(elem.Value)
							Tab:Render()
						end)
					end
					
					if elem.Side == 2 then Tab.CurrentSide = 0 end

				elseif elem.Type == "Colorpicker" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side == 1 and 0.5 or 1, elem.Side == 1 and -4 or 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0,
						ClipsDescendants = true
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					Create("TextLabel", {
						Parent = frame,
						Position = UDim2.new(0.026, 0, 0, 8),
						Size = UDim2.new(0.6, 0, 0, 18),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					
					local colorPreview = Create("TextButton", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(0.974, 0, 0, 8),
						Size = UDim2.new(0, 40, 0, 26),
						BackgroundColor3 = elem.Value,
						BorderSizePixel = 0,
						Text = "",
						ZIndex = 2
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = colorPreview})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = colorPreview})
					
					if elem.Transparency then
						colorPreview.BackgroundTransparency = elem.TransValue
					end
					
					colorPreview.MouseButton1Click:Connect(function()
						-- Create proper color picker dialog
						local dialog = Create("Frame", {
							Parent = gui,
							Size = UDim2.new(0, 350, 0, 400),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							BackgroundColor3 = Color3.fromRGB(25, 25, 25),
							BorderSizePixel = 0,
							ZIndex = 200
						})
						Create("UICorner", {CornerRadius = UDim.new(0.02, 0), Parent = dialog})
						Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dialog})
						
						local closeBtn = Create("TextButton", {
							Parent = dialog,
							Size = UDim2.new(0, 30, 0, 30),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -5, 0, 5),
							BackgroundTransparency = 1,
							Text = "×",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 24,
							ZIndex = 201
						})
						closeBtn.MouseButton1Click:Connect(function() dialog:Destroy() end)
						
						-- Color wheel (simplified HSV picker)
						local hueSatFrame = Create("ImageButton", {
							Parent = dialog,
							Size = UDim2.new(0, 200, 0, 200),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5, 0, 0, 50),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							ZIndex = 201
						})
						Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = hueSatFrame})
						
						-- Hue gradient
						local hueGradient = Create("UIGradient", {
							Parent = hueSatFrame,
							Rotation = 0,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
							})
						})
						
						-- Saturation/Value overlay
						local satOverlay = Create("Frame", {
							Parent = hueSatFrame,
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 0,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							ZIndex = 2
						})
						local svGradient = Create("UIGradient", {
							Parent = satOverlay,
							Rotation = -90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
							}),
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 1)
							})
						})
						
						-- Value slider
						local valueSlider = Create("Frame", {
							Parent = dialog,
							Size = UDim2.new(0, 20, 0, 200),
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.new(0.5, 110, 0, 50),
							BackgroundColor3 = Color3.fromRGB(30, 30, 30),
							ZIndex = 201
						})
						Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = valueSlider})
						Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = valueSlider})
						
						-- Value gradient
						local valueGradient = Create("UIGradient", {
							Parent = valueSlider,
							Rotation = 90,
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
							})
						})
						
						local valueHandle = Create("Frame", {
							Parent = valueSlider,
							Size = UDim2.new(1, 0, 0, 4),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							ZIndex = 202
						})
						
						-- Preview
						local preview = Create("Frame", {
							Parent = dialog,
							Size = UDim2.new(0, 100, 0, 100),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5, 0, 0, 270),
							BackgroundColor3 = elem.Value,
							ZIndex = 201
						})
						Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = preview})
						
						-- Apply button
						local applyBtn = Create("TextButton", {
							Parent = dialog,
							Size = UDim2.new(0, 100, 0, 35),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5, 0, 1, -45),
							BackgroundColor3 = Color3.fromRGB(100, 150, 255),
							Font = Enum.Font.Gotham,
							Text = "Apply",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 14,
							ZIndex = 201
						})
						Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = applyBtn})
						
						-- Color picker logic (simplified)
						local currentHue, currentSat, currentVal = 0, 1, 1
						
						hueSatFrame.MouseButton1Down:Connect(function(input)
							local pos = Vector2.new(input.Position.X - hueSatFrame.AbsolutePosition.X, input.Position.Y - hueSatFrame.AbsolutePosition.Y)
							currentHue = pos.X / hueSatFrame.AbsoluteSize.X
							currentSat = pos.Y / hueSatFrame.AbsoluteSize.Y
						end)
						
						valueSlider.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								local connection
								connection = RunService.RenderStepped:Connect(function()
									local pos = UserInputService:GetMouseLocation().Y - valueSlider.AbsolutePosition.Y
									currentVal = 1 - math.clamp(pos / valueSlider.AbsoluteSize.Y, 0, 1)
									valueHandle.Position = UDim2.new(0.5, 0, currentVal, 0)
									elem.Value = Color3.fromHSV(currentHue, currentSat, currentVal)
									preview.BackgroundColor3 = elem.Value
									colorPreview.BackgroundColor3 = elem.Value
								end)
								valueSlider.InputEnded:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.MouseButton1 then
										connection:Disconnect()
									end
								end)
							end
						end)
						
						applyBtn.MouseButton1Click:Connect(function()
							elem.Callback(elem.Value)
							dialog:Destroy()
							Tab:Render()
						end)
						
						elem.Open = not elem.Open
						Tab:Render()
					end)
					
					if elem.Side == 2 then Tab.CurrentSide = 0 end
				end
			end
		end

		return Tab
	end

	function Window:Destroy()
		pcall(function()
			for _, conn in ipairs(Window.Connections) do
				if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
			end
			gui:Destroy()
			for i, win in ipairs(Library.Windows) do
				if win == Window then table.remove(Library.Windows, i) break end
			end
		end)
	end

	table.insert(Library.Windows, Window)
	return Window
end

-- Save Manager (Fixed)
Library.SaveManager = {
	Library = nil,
	Folder = "LibraryConfigs",
	Ignore = {},
	Configs = {},
	CurrentConfig = nil
}

function Library.SaveManager:SetLibrary(lib)
	self.Library = lib
end

function Library.SaveManager:IgnoreThemeSettings()
	self.Ignore = {"Theme", "Acrylic", "Transparency"}
end

function Library.SaveManager:SetIgnoreIndexes(indexes)
	for _, index in ipairs(indexes) do
		table.insert(self.Ignore, index)
	end
end

function Library.SaveManager:SetFolder(folder)
	self.Folder = folder
	self:BuildFolder()
end

function Library.SaveManager:BuildFolder()
	if not isfolder(self.Folder) then
		makefolder(self.Folder)
	end
end

function Library.SaveManager:Save(name)
	if not name or name == "" then return end
	
	local config = {}
	for _, window in ipairs(self.Library.Windows) do
		for _, tab in ipairs(window.Tabs) do
			for _, elem in ipairs(tab.Elements) do
				local key = elem.Title or "Unnamed"
				if elem.Type == "Toggle" then
					config[key] = {Value = elem.Value, Type = "Toggle"}
				elseif elem.Type == "Input" then
					config[key] = {Value = elem.Value, Type = "Input"}
				elseif elem.Type == "Slider" then
					config[key] = {Value = elem.Value, Type = "Slider"}
				elseif elem.Type == "Dropdown" then
					config[key] = {Value = elem.Value, Type = "Dropdown", Multi = elem.Multi}
				elseif elem.Type == "Colorpicker" then
					config[key] = {Value = {elem.Value.R, elem.Value.G, elem.Value.B}, Trans = elem.TransValue, Type = "Colorpicker", Transparency = elem.Transparency}
				elseif elem.Type == "Keybind" then
					config[key] = {Value = elem.Value.Name, Mode = elem.Mode, Type = "Keybind"}
				end
			end
		end
	end
	
	writefile(self.Folder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(config))
	self:Refresh()
end

function Library.SaveManager:Load(name)
	if not name or name == "" then return end
	local path = self.Folder .. "/" .. name .. ".json"
	if not isfile(path) then return end
	
	local success, config = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(path))
	end)
	if not success then return end
	
	for _, window in ipairs(self.Library.Windows) do
		for _, tab in ipairs(window.Tabs) do
			for _, elem in ipairs(tab.Elements) do
				local key = elem.Title or "Unnamed"
				if config[key] and not table.find(self.Ignore, key) then
					local data = config[key]
					if elem.Type == "Toggle" and data.Type == "Toggle" then
						elem.Value = data.Value
						elem.Callback(elem.Value)
					elseif elem.Type == "Input" and data.Type == "Input" then
						elem.Value = data.Value
						elem.Callback(elem.Value)
					elseif elem.Type == "Slider" and data.Type == "Slider" then
						elem.Value = data.Value
						elem.Callback(elem.Value)
					elseif elem.Type == "Dropdown" and data.Type == "Dropdown" then
						elem.Value = data.Value
						elem.Callback(elem.Value)
					elseif elem.Type == "Colorpicker" and data.Type == "Colorpicker" then
						elem.Value = Color3.new(data.Value[1], data.Value[2], data.Value[3])
						if elem.Transparency then
							elem.TransValue = data.Trans
						end
						elem.Callback(elem.Value)
					elseif elem.Type == "Keybind" and data.Type == "Keybind" then
						elem.Value = Enum.KeyCode[data.Value] or Enum.KeyCode.F
						elem.Mode = data.Mode
						elem.ChangedCallback(elem.Value)
					end
				end
			end
			tab:Render()
		end
	end
end

function Library.SaveManager:Refresh()
	self.Configs = {}
	if isfolder(self.Folder) then
		for _, file in ipairs(listfiles(self.Folder)) do
			if file:sub(-5) == ".json" then
				table.insert(self.Configs, file:match("^.+/(.+)%.json$"))
			end
		end
	end
end

function Library.SaveManager:Delete(name)
	if not name or name == "" then return end
	local path = self.Folder .. "/" .. name .. ".json"
	if isfile(path) then
		delfile(path)
		self:Refresh()
	end
end

function Library.SaveManager:LoadAutoloadConfig()
	self:Refresh()
	if table.find(self.Configs, "autosave") then
		self:Load("autosave")
	end
end

-- Interface Manager (Fixed)
Library.InterfaceManager = {
	Library = nil,
	Folder = "LibraryInterface",
	Theme = "Dark"
}

function Library.InterfaceManager:SetLibrary(lib)
	self.Library = lib
end

function Library.InterfaceManager:SetFolder(folder)
	self.Folder = folder
	self:BuildFolder()
end

function Library.InterfaceManager:BuildFolder()
	if not isfolder(self.Folder) then
		makefolder(self.Folder)
	end
end

function Library.InterfaceManager:Save()
	local config = {Theme = self.Theme}
	if isfolder(self.Folder) then
		writefile(self.Folder .. "/interface.json", game:GetService("HttpService"):JSONEncode(config))
	end
end

function Library.InterfaceManager:Load()
	local path = self.Folder .. "/interface.json"
	if isfile(path) then
		local success, config = pcall(function()
			return game:GetService("HttpService"):JSONDecode(readfile(path))
		end)
		if success then
			self.Theme = config.Theme or "Dark"
		end
	end
end

function Library.InterfaceManager:BuildInterfaceSection(tab)
	tab:AddDropdown({
		Title = "Theme",
		Values = {"Dark", "Light", "Amoled"},
		Default = self.Theme,
		Callback = function(value)
			self.Theme = value
			self:Save()
		end
	})
end

return Library
