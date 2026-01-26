-- Enhanced Roblox UI Library (Fixed Version)
local Library = {Windows = {}, Keybinds = {}, Config = {Theme = "Dark"}}
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
		Hidden = false -- Tracks UI visibility state
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
		Size = UDim2.new(0, 652, 0, 400),
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
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1
	})

	-- Logo (bigger)
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
		Position = UDim2.new(0, 48, 0, 12),
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
			Position = UDim2.new(0, 48, 0, 28),
			Size = UDim2.new(1, -96, 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = Window.Description,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	-- Control buttons container
	local buttonHolder = Create("Frame", {
		Parent = titleBar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 12),
		Size = UDim2.new(0, 70, 0, 22),
		BackgroundTransparency = 1
	})

	-- Create control buttons with hover effect
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
		
		-- Hover background
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
		createButton("rbxassetid://104255241083015", UDim2.new(0, 18, 0, 18), UDim2.new(0, 25, 0, 2), function()
			Window.Hidden = not Window.Hidden
			main.Visible = not Window.Hidden
		end)
	end

	if Window.CanClose then
		createButton("rbxassetid://114783304987099", UDim2.new(0, 18, 0, 18), UDim2.new(0, 48, 0, 2), function()
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

	local tabContainer = Create("Frame", {
		Parent = main,
		Position = UDim2.new(0.019, 0, 0.141, 0),
		Size = UDim2.new(0, 135, 0, 324),
		BackgroundTransparency = 1
	})

	Create("UIListLayout", {Parent = tabContainer, Padding = UDim.new(0, 8)})

	local contentScroll = Create("ScrollingFrame", {
		Parent = main,
		Position = UDim2.new(0.237, 0, 0.116, 0),
		Size = UDim2.new(0.763, 0, 0.883, 0),
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
		PaddingTop = UDim.new(0, 10)
	})

	-- User info frame (bottom left) - slightly smaller avatar
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

	-- Minimize keybind - toggle visibility
	table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Window.MinimizeKey then
			Window.Hidden = not Window.Hidden
			main.Visible = not Window.Hidden
		end
	end))

	function Window:CreateTab(name)
		if type(name) ~= "string" or name == "" then return warn("Tab name required") end

		local Tab = {Elements = {}, Name = name, CurrentSide = 0}
		local isFirst = #Window.Tabs == 0

		local btn = Create("TextButton", {
			Parent = tabContainer,
			Size = UDim2.new(0.98, 0, 0, 35),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			BackgroundTransparency = isFirst and 0 or 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false
		})

		Create("UIPadding", {Parent = btn, PaddingLeft = UDim.new(0, 5)})
		Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = btn})

		local stroke = Create("UIStroke", {
			Color = Color3.fromRGB(116, 116, 116),
			Thickness = 1,
			Transparency = isFirst and 0.8 or 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = btn
		})

		local content = Create("Frame", {
			Parent = contentScroll,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Visible = isFirst,
			AutomaticSize = Enum.AutomaticSize.Y
		})

		local layout = Create("UIListLayout", {Parent = content, Padding = UDim.new(0, 8)})

		-- Handle layout updates
		table.insert(Window.Connections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			contentScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
		end))

		table.insert(Window.Connections, btn.MouseButton1Click:Connect(function()
			if Window.CurrentTab == Tab then return end
			for _, tab in ipairs(Window.Tabs) do
				Tween(tab.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
				Tween(tab.Stroke, {Transparency = 1}):Play()
				tab.Content.Visible = false
			end
			Tween(btn, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			Tween(stroke, {Transparency = 0.8}):Play()
			content.Visible = true
			Window.CurrentTab = Tab
		end))

		Tab.Button = btn
		Tab.Stroke = stroke
		Tab.Content = content

		table.insert(Window.Tabs, Tab)
		if isFirst then Window.CurrentTab = Tab end

		-- Element creation functions
		function Tab:AddParagraph(config)
			config = config or {}
			local elem = {
				Type = "Paragraph",
				Title = tostring(config.Title or ""),
				Content = tostring(config.Content or ""),
				Visible = true
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
			
			-- Return object with OnChanged method
			local toggleObject = {
				SetValue = function(_, val) if type(val) == "boolean" then elem.Value = val Tab:Render() end end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false Tab:Render() end,
				Show = function() elem.Visible = true Tab:Render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
			
			-- Trigger initial callback
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
				Value = tostring(config.Default or "")
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
				Mode = config.Mode or "Toggle", -- Always, Toggle, Hold
				Callback = config.Callback or function() end,
				ChangedCallback = config.ChangedCallback or function() end,
				Visible = true,
				Value = config.Default or Enum.KeyCode.F,
				Active = false,
				Holding = false
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			-- Register global keybind
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
				OnClick = function(_, cb) elem.OnClick = cb end,
				OnChanged = function(_, cb) elem.ChangedCallback = cb end
			}
		end

		function Tab:AddDivider(config)
			config = config or {}
			local elem = {
				Type = "Divider",
				Visible = true
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
			
			-- Initial callback
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
			
			-- Initialize value for multi-dropdown
			if elem.Multi then
				elem.Value = {}
				if config.Default then
					for _, v in ipairs(config.Default) do
						elem.Value[v] = true
					end
				end
			end
			
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			-- Initial callback
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
				Open = false
			}
			table.insert(Tab.Elements, elem)
			Tab:Render()
			
			-- Initial callback
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

		-- Render function with side-by-side support
		function Tab:Render()
			for _, child in ipairs(content:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			local currentRow = nil
			Tab.CurrentSide = 0

			for _, elem in ipairs(Tab.Elements) do
				if not elem.Visible then continue end

				-- Handle side-by-side layout
				if elem.Side == 1 or Tab.CurrentSide == 0 then
					-- Create new row
					currentRow = Create("Frame", {
						Parent = content,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y
					})
					Create("UIListLayout", {
						Parent = currentRow,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 8),
						HorizontalAlignment = Enum.HorizontalAlignment.Left
					})
					Tab.CurrentSide = 1
				end

				local container = elem.Side == 1 and currentRow or (elem.Side == 2 and currentRow or content)

				if elem.Type == "Paragraph" then
					-- Paragraph should be full width, so reset side
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
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side > 0 and 0.5 or 1, elem.Side > 0 and -4 or 0, 0, 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.None
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = frame})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = frame})
					Create("TextLabel", {
						Parent = frame,
						Position = UDim2.new(0.026, 0, 0, 8),
						Size = UDim2.new(0.95, 0, 0, 16),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					if elem.Description ~= "" then
						Create("TextLabel", {
							Parent = frame,
							Position = UDim2.new(0.026, 0, 0, 24),
							Size = UDim2.new(0.95, 0, 0, 14),
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Text = elem.Description,
							TextColor3 = Color3.fromRGB(150, 150, 150),
							TextSize = 11,
							TextXAlignment = Enum.TextXAlignment.Left
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
					if elem.Side > 0 then Tab.CurrentSide = Tab.CurrentSide == 1 and 2 or 0 end

				elseif elem.Type == "Toggle" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side > 0 and 0.5 or 1, elem.Side > 0 and -4 or 0, 0, 42),
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
					local indicator = Create("Frame", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(0.975, 0, 0.5, 0),
						Size = UDim2.new(0, 20, 0, 20),
						BackgroundColor3 = elem.Value and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(30, 30, 30),
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.2, 0), Parent = indicator})
					Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = indicator})
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
							Tween(indicator, {BackgroundColor3 = elem.Value and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(30, 30, 30)}):Play()
							elem.Callback(elem.Value)
						end)
					end)
					if elem.Side > 0 then Tab.CurrentSide = Tab.CurrentSide == 1 and 2 or 0 end

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
						Size = UDim2.new(0.55, 0, 0, 28),
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
					Tab.CurrentSide = 0

				elseif elem.Type == "Keybind" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side > 0 and 0.5 or 1, elem.Side > 0 and -4 or 0, 0, 42),
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
					if elem.Side > 0 then Tab.CurrentSide = Tab.CurrentSide == 1 and 2 or 0 end

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
						Size = UDim2.new(elem.Side > 0 and 0.5 or 1, elem.Side > 0 and -4 or 0, 0, 50),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
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
					local valueLabel = Create("TextLabel", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(0.975, 0, 0, 8),
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
						Position = UDim2.new(0.026, 0, 0, 30),
						Size = UDim2.new(0.948, 0, 0, 8),
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
					if elem.Side > 0 then Tab.CurrentSide = Tab.CurrentSide == 1 and 2 or 0 end

				elseif elem.Type == "Dropdown" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side > 0 and 0.5 or 1, elem.Side > 0 and -4 or 0, 0, elem.Open and math.min(#elem.Values * 30 + 50, 200) or 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
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
					local dropdownBtn = Create("TextButton", {
						Parent = frame,
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(0.974, 0, 0, 8),
						Size = UDim2.new(0, 120, 0, 26),
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderSizePixel = 0,
						Font = Enum.Font.Gotham,
						Text = elem.Multi and (#elem.Value > 0 and table.concat(elem.Value, ", ") or "None") or elem.Value,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						ZIndex = 2
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = dropdownBtn})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dropdownBtn})
					
					local dropdownMenu = Create("ScrollingFrame", {
						Parent = frame,
						Position = UDim2.new(0.026, 0, 0, 42),
						Size = UDim2.new(0.948, 0, 0, math.min(#elem.Values * 28, 150)),
						BackgroundColor3 = Color3.fromRGB(20, 20, 20),
						BorderSizePixel = 0,
						ScrollBarThickness = 3,
						Visible = elem.Open,
						ZIndex = 3
					})
					Create("UICorner", {CornerRadius = UDim.new(0.05, 0), Parent = dropdownMenu})
					Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dropdownMenu})
					Create("UIPadding", {Parent = dropdownMenu, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
					
					dropdownBtn.MouseButton1Click:Connect(function()
						elem.Open = not elem.Open
						Tab:Render()
					end)
					
					for _, option in ipairs(elem.Values) do
						local optionBtn = Create("TextButton", {
							Parent = dropdownMenu,
							Size = UDim2.new(1, 0, 0, 26),
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							Text = option,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 13,
							AutoButtonColor = false,
							ZIndex = 3
						})
						Create("UIPadding", {Parent = optionBtn, PaddingLeft = UDim.new(0, 8)})
						optionBtn.MouseButton1Click:Connect(function()
							if elem.Multi then
								elem.Value[option] = not elem.Value[option]
								dropdownBtn.Text = #elem.Value > 0 and table.concat(elem.Value, ", ") or "None"
							else
								elem.Value = option
								elem.Open = false
							end
							elem.Callback(elem.Value)
							Tab:Render()
						end)
					end
					if elem.Side > 0 then Tab.CurrentSide = Tab.CurrentSide == 1 and 2 or 0 end

				elseif elem.Type == "Colorpicker" then
					local frame = Create("Frame", {
						Parent = container,
						Size = UDim2.new(elem.Side > 0 and 0.5 or 1, elem.Side > 0 and -4 or 0, 0, elem.Open and (elem.Transparency and 120 or 100) or 42),
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BorderSizePixel = 0
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
						elem.Open = not elem.Open
						Tab:Render()
					end)
					
					if elem.Open then
						local hueFrame = Create("Frame", {
							Parent = frame,
							Position = UDim2.new(0.026, 0, 0, 42),
							Size = UDim2.new(0.948, 0, 0, 20),
							BackgroundColor3 = Color3.fromRGB(20, 20, 20),
							BorderSizePixel = 0
						})
						Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = hueFrame})
						Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = hueFrame})
						
						local satFrame = Create("Frame", {
							Parent = frame,
							Position = UDim2.new(0.026, 0, 0, 68),
							Size = UDim2.new(0.948, 0, 0, 20),
							BackgroundColor3 = Color3.fromRGB(20, 20, 20),
							BorderSizePixel = 0
						})
						Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = satFrame})
						Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = satFrame})
						
						if elem.Transparency then
							local transFrame = Create("Frame", {
								Parent = frame,
								Position = UDim2.new(0.026, 0, 0, 94),
								Size = UDim2.new(0.948, 0, 0, 20),
								BackgroundColor3 = Color3.fromRGB(20, 20, 20),
								BorderSizePixel = 0
							})
							Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = transFrame})
							Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = transFrame})
						end
					end
					if elem.Side > 0 then Tab.CurrentSide = Tab.CurrentSide == 1 and 2 or 0 end
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

-- Save Manager (Fully Working Config System)
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
	for _, file in ipairs(listfiles(self.Folder)) do
		if file:sub(-5) == ".json" then
			table.insert(self.Configs, file:match("^.+/(.+)%.json$"))
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

-- Interface Manager
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
	writefile(self.Folder .. "/interface.json", game:GetService("HttpService"):JSONEncode(config))
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
