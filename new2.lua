-- Fluent-like UI Library for Roblox
local Fluent = {Windows = {}, Options = {}, Unloaded = false, Version = "1.0.0"}
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

-- Built-in Managers
local SaveManager = {
	Library = nil,
	Ignored = {},
	Folder = nil,
	ConfigFolder = "Configs"
}

local InterfaceManager = {
	Library = nil,
	Folder = nil
}

function SaveManager:SetLibrary(lib)
	self.Library = lib
end

function SaveManager:IgnoreThemeSettings()
	table.insert(self.Ignored, "Theme")
end

function SaveManager:SetIgnoreIndexes(indexes)
	for _, idx in ipairs(indexes) do
		table.insert(self.Ignored, idx)
	end
end

function SaveManager:SetFolder(folder)
	self.Folder = folder
end

function SaveManager:BuildConfigSection(tab)
	tab:AddButton({Title = "Create Config", Description = "Create a new configuration", Callback = function()
		print("Config created")
	end})
	
	tab:AddButton({Title = "Load Config", Description = "Load selected configuration", Callback = function()
		print("Config loaded")
	end})
	
	tab:AddButton({Title = "Save Config", Description = "Save current configuration", Callback = function()
		print("Config saved")
	end})
	
	tab:AddButton({Title = "Delete Config", Description = "Delete selected configuration", Callback = function()
		print("Config deleted")
	end})
	
	tab:AddToggle({Title = "Auto Save", Default = false, Callback = function(v)
		print("Auto save:", v)
	end})
end

function SaveManager:LoadAutoloadConfig()
	print("Loaded autoload config")
end

function InterfaceManager:SetLibrary(lib)
	self.Library = lib
end

function InterfaceManager:SetFolder(folder)
	self.Folder = folder
end

function InterfaceManager:BuildInterfaceSection(tab)
	tab:AddParagraph({Title = "Interface Settings", Content = "Manage your UI preferences"})
	
	tab:AddButton({Title = "Reset UI Position", Description = "Reset window to center", Callback = function()
		for _, window in ipairs(self.Library.Windows) do
			window.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
		end
	end})
	
	tab:AddToggle({Title = "UI Notifications", Default = true, Callback = function(v)
		print("Notifications:", v)
	end})
end

function Fluent:CreateWindow(config)
	if type(config) ~= "table" then return warn("Config must be a table") end

	local Window = {
		Tabs = {},
		CurrentTab = nil,
		Connections = {},
		Title = tostring(config.Title or "Fluent " .. self.Version),
		SubTitle = tostring(config.SubTitle or ""),
		TabWidth = config.TabWidth or 160,
		Size = config.Size or UDim2.fromOffset(580, 460),
		Acrylic = config.Acrylic ~= false,
		MinimizeKey = config.MinimizeKey or Enum.KeyCode.LeftControl,
		Minimized = false,
		UseMultiColumn = true
	}

	local windowOffset = #self.Windows * 0.05

	local gui = Create("ScreenGui", {
		Name = "FluentUI_" .. (#self.Windows + 1),
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})

	local main = Create("Frame", {
		Name = "Main",
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5 + windowOffset, 0, 0.5, 0),
		Size = Window.Size,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderSizePixel = 0,
		ClipsDescendants = true
	})

	Create("UICorner", {CornerRadius = UDim.new(0.02, 0), Parent = main})
	Create("UIStroke", {Color = Color3.fromRGB(25, 25, 25), Thickness = 1, Parent = main})

	-- Title Bar
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
		Position = UDim2.new(0, 48, 0, 10),
		Size = UDim2.new(1, -96, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = Window.Title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	if Window.SubTitle ~= "" then
		Create("TextLabel", {
			Parent = titleBar,
			Position = UDim2.new(0, 48, 0, 26),
			Size = UDim2.new(1, -96, 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = Window.SubTitle,
			TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	-- Control buttons
	local minimizeBtn = Create("ImageButton", {
		Parent = titleBar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -36, 0, 12),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://104255241083015",
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = Color3.fromRGB(200, 200, 200)
	})

	local closeBtn = Create("ImageButton", {
		Parent = titleBar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://114783304987099",
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = Color3.fromRGB(255, 100, 100)
	})

	-- Tab container
	local tabContainer = Create("Frame", {
		Parent = main,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(0, Window.TabWidth, 1, -96),
		BackgroundTransparency = 1
	})

	Create("UIPadding", {Parent = tabContainer, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
	Create("UIListLayout", {Parent = tabContainer, Padding = UDim.new(0, 4)})

	-- Content area
	local contentScroll = Create("ScrollingFrame", {
		Parent = main,
		Position = UDim2.new(0, Window.TabWidth, 0, 46),
		Size = UDim2.new(1, -Window.TabWidth, 1, -96),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})

	Create("UIPadding", {
		Parent = contentScroll,
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10)
	})

	Create("UIGridLayout", {
		Parent = contentScroll,
		CellSize = UDim2.new(1, 0, 0, 42),
		CellPadding = UDim2.new(0, 0, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	})

	-- Avatar Section (Bottom Left)
	local avatarSection = Create("Frame", {
		Parent = main,
		Position = UDim2.new(0, 12, 1, -42),
		Size = UDim2.new(0, Window.TabWidth - 24, 0, 36),
		BackgroundTransparency = 1
	})

	local avatarCircle = Create("ImageLabel", {
		Parent = avatarSection,
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundTransparency = 1,
		Image = Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
		ScaleType = Enum.ScaleType.Crop
	})
	Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = avatarCircle})

	local avatarStroke = Create("UIStroke", {
		Parent = avatarCircle,
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 2
	})

	local avatarName = Create("TextLabel", {
		Parent = avatarSection,
		Position = UDim2.new(0, 42, 0, 4),
		Size = UDim2.new(1, -42, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = game.Players.LocalPlayer.DisplayName,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	Create("TextLabel", {
		Parent = avatarSection,
		Position = UDim2.new(0, 42, 0, 20),
		Size = UDim2.new(1, -42, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "@" .. game.Players.LocalPlayer.Name,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	-- Dragging functionality
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

	-- Minimize/Close functionality
	table.insert(Window.Connections, minimizeBtn.MouseButton1Click:Connect(function()
		Window.Minimized = not Window.Minimized
		local targetHeight = Window.Minimized and 46 or Window.Size.Y.Offset
		Tween(main, {Size = UDim2.new(0, Window.Size.X.Offset, 0, targetHeight)}):Play()
		contentScroll.Visible = not Window.Minimized
		tabContainer.Visible = not Window.Minimized
		avatarSection.Visible = not Window.Minimized
	end))

	table.insert(Window.Connections, closeBtn.MouseButton1Click:Connect(function()
		Window:Destroy()
	end))

	-- Minimize keybind
	table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Window.MinimizeKey then
			minimizeBtn:Activate()
		end
	end))

	function Window:AddTab(config)
		if type(config) ~= "table" or not config.Title then return warn("Tab config required with Title") end

		local Tab = {
			Elements = {}, 
			Name = config.Title, 
			Icon = config.Icon or "",
			ContentRows = {}
		}
		local isFirst = #Window.Tabs == 0

		local btn = Create("TextButton", {
			Parent = tabContainer,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BackgroundTransparency = isFirst and 0 or 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = config.Title,
			TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false
		})

		Create("UIPadding", {Parent = btn, PaddingLeft = UDim.new(0, 12)})
		Create("UICorner", {CornerRadius = UDim.new(0.05, 0), Parent = btn})

		local content = Create("Frame", {
			Parent = contentScroll,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Visible = isFirst,
			LayoutOrder = #Window.Tabs
		})

		local layout = Create("UIListLayout", {
			Parent = content,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		})

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
			RunService.Heartbeat:Wait()
			contentScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
		end)

		table.insert(Window.Connections, btn.MouseButton1Click:Connect(function()
			if Window.CurrentTab == Tab then return end
			for _, tab in ipairs(Window.Tabs) do
				Tween(tab.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
				tab.Content.Visible = false
			end
			Tween(btn, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			content.Visible = true
			Window.CurrentTab = Tab
		end))

		Tab.Button = btn
		Tab.Content = content
		table.insert(Window.Tabs, Tab)
		if isFirst then Window.CurrentTab = Tab end

		-- Multi-column rendering system
		function Tab:CreateRow()
			local row = {
				Elements = {},
				Frame = Create("Frame", {
					Parent = content,
					Size = UDim2.new(1, 0, 0, 42),
					BackgroundTransparency = 1
				})
			}
			Create("UIListLayout", {
				Parent = row.Frame,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				HorizontalAlignment = Enum.HorizontalAlignment.Left
			})
			table.insert(Tab.ContentRows, row)
			return row
		end

		function Tab:RecalculateLayout()
			for _, row in ipairs(Tab.ContentRows) do
				local count = #row.Elements
				if count > 0 then
					local width = (1 / count) - ((count - 1) * 8 / content.AbsoluteSize.X)
					for _, element in ipairs(row.Elements) do
						element.Size = UDim2.new(width, 0, 1, 0)
					end
				end
			end
		end

		-- Component functions
		function Tab:AddParagraph(config)
			local elem = {
				Type = "Paragraph", 
				Title = config.Title or "", 
				Content = config.Content or "", 
				Visible = true,
				Row = nil
			}
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0,
					AutomaticSize = elem.Row and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.05, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				Create("UIPadding", {Parent = elem.Frame, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
				
				local container = Create("Frame", {Parent = elem.Frame, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
				Create("UIListLayout", {Parent = container, Padding = UDim.new(0, 4)})
				
				Create("TextLabel", {
					Parent = container,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
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
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 13,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y
				})
			end
			
			if config.SameLine then
				local row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem.Frame)
				elem.Row = row
				Tab:RecalculateLayout()
			end
			
			render()
			table.insert(Tab.Elements, elem)
			
			return {
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end
			}
		end

		function Tab:AddButton(config)
			local elem = {
				Type = "Button", 
				Title = config.Title or "Button", 
				Description = config.Description or "", 
				Callback = config.Callback or function() end, 
				Visible = true,
				Row = nil
			}
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0.5, -7),
					Size = UDim2.new(0.95, 0, 0, 14),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				if elem.Description ~= "" then
					Create("TextLabel", {
						Parent = elem.Frame,
						Position = UDim2.new(0.026, 0, 0.5, 8),
						Size = UDim2.new(0.95, 0, 0, 12),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Description,
						TextColor3 = Color3.fromRGB(150, 150, 150),
						TextSize = 11,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				end
				
				local btn = Create("TextButton", {
					Parent = elem.Frame,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false
				})
				
				btn.MouseButton1Click:Connect(function()
					pcall(function()
						Tween(elem.Frame, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.1):Play()
						task.delay(0.1, function() Tween(elem.Frame, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.1):Play() end)
						elem.Callback()
					end)
				end)
			end
			
			local row
			if config.SameLine then
				row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem)
				elem.Row = row
			end
			
			render()
			table.insert(Tab.Elements, elem)
			if row then Tab:RecalculateLayout() end
			
			return {
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end
			}
		end

		function Tab:AddToggle(config)
			local elem = {
				Type = "Toggle",
				Title = config.Title or "Toggle",
				Value = config.Default or false,
				Callback = config.Callback or function() end,
				Visible = true,
				Row = nil
			}
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0, 12),
					Size = UDim2.new(0.7, 0, 1, -24),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local indicator = Create("Frame", {
					Parent = elem.Frame,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(0.975, 0, 0.5, 0),
					Size = UDim2.new(0, 40, 0, 20),
					BackgroundColor3 = elem.Value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60),
					BorderSizePixel = 0
				})
				Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = indicator})
				
				local slider = Create("Frame", {
					Parent = indicator,
					AnchorPoint = Vector2.new(elem.Value and 1 or 0, 0.5),
					Position = UDim2.new(elem.Value and 1 or 0, elem.Value and -2 or 2, 0.5, 0),
					Size = UDim2.new(0, 16, 0, 16),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0
				})
				Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = slider})
				
				local btn = Create("TextButton", {
					Parent = elem.Frame,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false
				})
				
				btn.MouseButton1Click:Connect(function()
					pcall(function()
						elem.Value = not elem.Value
						Tween(indicator, {BackgroundColor3 = elem.Value and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)}):Play()
						Tween(slider, {AnchorPoint = Vector2.new(elem.Value and 1 or 0, 0.5), Position = UDim2.new(elem.Value and 1 or 0, elem.Value and -2 or 2, 0.5, 0)}, 0.2):Play()
						elem.Callback(elem.Value)
					end)
				end)
			end
			
			local row
			if config.SameLine then
				row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem)
				elem.Row = row
			end
			
			render()
			table.insert(Tab.Elements, elem)
			if row then Tab:RecalculateLayout() end
			
			return {
				SetValue = function(_, val) if type(val) == "boolean" then elem.Value = val render() end end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddInput(config)
			local elem = {
				Type = "Input",
				Title = config.Title or "Input",
				Value = config.Default or "",
				Placeholder = config.Placeholder or "",
				Numeric = config.Numeric or false,
				Finished = config.Finished or false,
				Callback = config.Callback or function() end,
				Visible = true,
				Row = nil
			}
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0, 12),
					Size = UDim2.new(0.45, 0, 0, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local inputFrame = Create("Frame", {
					Parent = elem.Frame,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(0.975, 0, 0, 7),
					Size = UDim2.new(0.45, 0, 0, 28),
					BackgroundColor3 = Color3.fromRGB(15, 15, 15),
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
				
				if elem.Numeric then
					input:GetPropertyChangedSignal("Text"):Connect(function()
						input.Text = input.Text:gsub("%D", "")
					end)
				end
				
				input.FocusLost:Connect(function()
					pcall(function()
						elem.Value = input.Text
						elem.Callback(elem.Value)
					end)
				end)
			end
			
			local row
			if config.SameLine then
				row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem)
				elem.Row = row
			end
			
			render()
			table.insert(Tab.Elements, elem)
			if row then Tab:RecalculateLayout() end
			
			return {
				SetValue = function(_, val) elem.Value = tostring(val) render() end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddSlider(config)
			local elem = {
				Type = "Slider",
				Title = config.Title or "Slider",
				Description = config.Description or "",
				Value = config.Default or 50,
				Min = config.Min or 0,
				Max = config.Max or 100,
				Rounding = config.Rounding or 1,
				Callback = config.Callback or function() end,
				Visible = true,
				Row = nil
			}
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 60),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0, 8),
					Size = UDim2.new(0.6, 0, 0, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				if elem.Description ~= "" then
					Create("TextLabel", {
						Parent = elem.Frame,
						Position = UDim2.new(0.026, 0, 0, 26),
						Size = UDim2.new(0.7, 0, 0, 12),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = elem.Description,
						TextColor3 = Color3.fromRGB(150, 150, 150),
						TextSize = 11,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				end
				
				local valueLabel = Create("TextLabel", {
					Parent = elem.Frame,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(0.975, 0, 0, 8),
					Size = UDim2.new(0, 50, 0, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Text = tostring(elem.Value),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Right
				})
				
				local sliderTrack = Create("Frame", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 1, -18),
					Size = UDim2.new(0.948, 0, 0, 8),
					BackgroundColor3 = Color3.fromRGB(15, 15, 15),
					BorderSizePixel = 0
				})
				Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = sliderTrack})
				
				local sliderFill = Create("Frame", {
					Parent = sliderTrack,
					Size = UDim2.new((elem.Value - elem.Min) / (elem.Max - elem.Min), 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0
				})
				Create("UICorner", {CornerRadius = UDim.new(0.5, 0), Parent = sliderFill})
				
				local dragging = false
				sliderTrack.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						local relativePos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
						local newValue = elem.Min + (elem.Max - elem.Min) * relativePos
						elem.Value = math.floor(newValue * (10 ^ elem.Rounding) + 0.5) / (10 ^ elem.Rounding)
						valueLabel.Text = tostring(elem.Value)
						sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
						elem.Callback(elem.Value)
					end
				end)
			end
			
			local row
			if config.SameLine then
				row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem)
				elem.Row = row
			end
			
			render()
			table.insert(Tab.Elements, elem)
			if row then Tab:RecalculateLayout() end
			
			return {
				SetValue = function(_, val) elem.Value = math.clamp(val, elem.Min, elem.Max) render() end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddDropdown(config)
			local elem = {
				Type = "Dropdown",
				Title = config.Title or "Dropdown",
				Values = config.Values or {},
				Multi = config.Multi or false,
				Value = config.Multi and {} or (config.Default or (config.Values and config.Values[1]) or ""),
				Callback = config.Callback or function() end,
				Visible = true,
				Open = false,
				Row = nil
			}
			
			if config.Multi and config.Default then
				for _, v in ipairs(config.Default) do
					elem.Value[v] = true
				end
			end
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0,
					ClipsDescendants = true
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0, 12),
					Size = UDim2.new(0.45, 0, 0, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local displayText = elem.Multi and (#elem.Value > 0 and table.concat(elem.Value, ", ") or "None") or tostring(elem.Value)
				local dropdownBtn = Create("TextButton", {
					Parent = elem.Frame,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(0.975, 0, 0, 7),
					Size = UDim2.new(0.45, 0, 0, 28),
					BackgroundColor3 = Color3.fromRGB(15, 15, 15),
					BorderSizePixel = 0,
					Font = Enum.Font.Gotham,
					Text = displayText,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 13,
					TextTruncate = Enum.TextTruncate.AtEnd
				})
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = dropdownBtn})
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dropdownBtn})
				
				local dropdownMenu = Create("ScrollingFrame", {
					Parent = dropdownBtn,
					Position = UDim2.new(0, 0, 1, 5),
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0,
					ScrollBarThickness = 3,
					Visible = false,
					ZIndex = 10,
					AutomaticSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(0, 0, 0, 0)
				})
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = dropdownMenu})
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = dropdownMenu})
				Create("UIPadding", {Parent = dropdownMenu, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
				local menuLayout = Create("UIListLayout", {Parent = dropdownMenu, Padding = UDim.new(0, 2)})
				
				dropdownBtn.MouseButton1Click:Connect(function()
					elem.Open = not elem.Open
					dropdownMenu.Visible = elem.Open
				end)
				
				local function updateDisplay()
					if elem.Multi then
						local values = {}
						for k, v in pairs(elem.Value) do
							if v then table.insert(values, k) end
						end
						dropdownBtn.Text = #values > 0 and table.concat(values, ", ") or "None"
					else
						dropdownBtn.Text = tostring(elem.Value)
					end
				end
				
				for _, option in ipairs(elem.Values) do
					local optionBtn = Create("TextButton", {
						Parent = dropdownMenu,
						Size = UDim2.new(1, 0, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = option,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						AutoButtonColor = false,
						ZIndex = 11
					})
					Create("UIPadding", {Parent = optionBtn, PaddingLeft = UDim.new(0, 8)})
					
					optionBtn.MouseButton1Click:Connect(function()
						if elem.Multi then
							elem.Value[option] = not elem.Value[option]
						else
							elem.Value = option
							elem.Open = false
							dropdownMenu.Visible = false
						end
						updateDisplay()
						elem.Callback(elem.Value)
					end)
					
					optionBtn.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							Tween(optionBtn, {BackgroundTransparency = 0.9}):Play()
						end
					end)
					
					optionBtn.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							Tween(optionBtn, {BackgroundTransparency = 1}):Play()
						end
					end)
				end
			end
			
			local row
			if config.SameLine then
				row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem)
				elem.Row = row
			end
			
			render()
			table.insert(Tab.Elements, elem)
			if row then Tab:RecalculateLayout() end
			
			return {
				SetValue = function(_, val)
					if elem.Multi then
						elem.Value = val
					else
						elem.Value = tostring(val)
					end
					render()
				end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddKeybind(config)
			local elem = {
				Type = "Keybind",
				Title = config.Title or "Keybind",
				Value = config.Default or "LeftControl",
				Mode = config.Mode or "Toggle",
				Callback = config.Callback or function() end,
				ChangedCallback = config.ChangedCallback or function() end,
				Visible = true,
				Active = false
			}
			
			-- Convert string to KeyCode
			if type(elem.Value) == "string" then
				local success, key = pcall(function() return Enum.KeyCode[elem.Value] end)
				elem.Value = success and key or Enum.KeyCode.LeftControl
			end
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = content,
					Size = UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0, 12),
					Size = UDim2.new(0.6, 0, 0, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local keyBtn = Create("TextButton", {
					Parent = elem.Frame,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(0.975, 0, 0, 7),
					Size = UDim2.new(0, 100, 0, 28),
					BackgroundColor3 = Color3.fromRGB(15, 15, 15),
					BorderSizePixel = 0,
					Font = Enum.Font.Gotham,
					Text = elem.Value.Name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 13
				})
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = keyBtn})
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = keyBtn})
				
				keyBtn.MouseButton1Click:Connect(function()
					keyBtn.Text = "..."
					elem.Listening = true
				end)
			end
			
			render()
			table.insert(Tab.Elements, elem)
			
			-- Keybind handler
			table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if elem.Listening and not gameProcessed then
					elem.Listening = false
					elem.Value = input.KeyCode
					render()
					elem.ChangedCallback(input.KeyCode)
				elseif not gameProcessed and input.KeyCode == elem.Value then
					if elem.Mode == "Toggle" then
						elem.Active = not elem.Active
						elem.Callback(elem.Active)
					elseif elem.Mode == "Hold" then
						elem.Active = true
						elem.Callback(true)
					elseif elem.Mode == "Always" then
						elem.Callback(true)
					end
				end
			end))
			
			table.insert(Window.Connections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
				if not gameProcessed and input.KeyCode == elem.Value and elem.Mode == "Hold" then
					elem.Active = false
					elem.Callback(false)
				end
			end))
			
			return {
				SetValue = function(_, key) elem.Value = key render() end,
				GetValue = function() return elem.Value end,
				GetState = function() return elem.Active end,
				OnClick = function(_, cb) elem.Callback = cb end,
				OnChanged = function(_, cb) elem.ChangedCallback = cb end,
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end
			}
		end

		function Tab:AddColorpicker(config)
			local elem = {
				Type = "Colorpicker",
				Title = config.Title or "Colorpicker",
				Value = config.Default or Color3.fromRGB(255, 255, 255),
				Transparency = config.Transparency,
				Callback = config.Callback or function() end,
				Visible = true,
				Row = nil
			}
			
			local function render()
				if elem.Frame then elem.Frame:Destroy() end
				if not elem.Visible then return end
				
				elem.Frame = Create("Frame", {
					Parent = elem.Row and elem.Row.Frame or content,
					Size = elem.Row and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 0, 42),
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					BorderSizePixel = 0
				})
				
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = elem.Frame})
				Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = elem.Frame})
				
				Create("TextLabel", {
					Parent = elem.Frame,
					Position = UDim2.new(0.026, 0, 0, 12),
					Size = UDim2.new(0.6, 0, 0, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = elem.Title,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local colorBtn = Create("TextButton", {
					Parent = elem.Frame,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(0.975, 0, 0, 7),
					Size = UDim2.new(0, 40, 0, 28),
					BackgroundColor3 = elem.Value,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false
				})
				Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = colorBtn})
				Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1, Parent = colorBtn})
				
				if elem.Transparency then
					local transIndicator = Create("Frame", {
						Parent = colorBtn,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = elem.Transparency,
						BorderSizePixel = 0
					})
					Create("UICorner", {CornerRadius = UDim.new(0.1, 0), Parent = transIndicator})
				end
				
				colorBtn.MouseButton1Click:Connect(function()
					elem.Callback(elem.Value, elem.Transparency or 0)
				end)
			end
			
			local row
			if config.SameLine then
				row = Tab.ContentRows[#Tab.ContentRows] or Tab:CreateRow()
				table.insert(row.Elements, elem)
				elem.Row = row
			end
			
			render()
			table.insert(Tab.Elements, elem)
			if row then Tab:RecalculateLayout() end
			
			return {
				SetValue = function(_, color) elem.Value = color render() end,
				GetValue = function() return elem.Value end,
				Hide = function() elem.Visible = false render() end,
				Show = function() elem.Visible = true render() end,
				OnChanged = function(_, cb) elem.Callback = cb end
			}
		end

		function Tab:AddDivider()
			local elem = {Type = "Divider", Visible = true}
			table.insert(Tab.Elements, elem)
			
			local frame = Create("Frame", {
				Parent = content,
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundTransparency = 1
			})
			
			Create("Frame", {
				Parent = frame,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.95, 0, 0, 1),
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				BorderSizePixel = 0
			})
			
			return {
				Hide = function() frame.Visible = false end,
				Show = function() frame.Visible = true end
			}
		end

		return Tab
	end

	function Window:SelectTab(index)
		local tab = self.Tabs[index]
		if tab and tab.Button then
			tab.Button:Activate()
		end
	end

	function Window:Notify(config)
		local notif = Create("Frame", {
			Parent = gui,
			Position = UDim2.new(1, 10, 1, -10),
			Size = UDim2.new(0, 300, 0, 80),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			BorderSizePixel = 0
		})
		Create("UICorner", {CornerRadius = UDim.new(0.05, 0), Parent = notif})
		Create("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1, Parent = notif})
		
		Create("TextLabel", {
			Parent = notif,
			Position = UDim2.new(0, 12, 0, 8),
			Size = UDim2.new(1, -24, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = config.Title or "Notification",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		Create("TextLabel", {
			Parent = notif,
			Position = UDim2.new(0, 12, 0, 28),
			Size = UDim2.new(1, -24, 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = config.Content or "",
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		Tween(notif, {Position = UDim2.new(1, -320, 1, -90)}, 0.3):Play()
		
		if config.Duration then
			task.delay(config.Duration, function()
				Tween(notif, {Position = UDim2.new(1, 340, 1, -90)}, 0.3):Play()
				task.wait(0.3)
				notif:Destroy()
			end)
		end
	end

	function Window:Destroy()
		pcall(function()
			for _, conn in ipairs(Window.Connections) do
				if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
			end
			gui:Destroy()
			for i, win in ipairs(self.Windows) do
				if win == Window then table.remove(self.Windows, i) break end
			end
			if #self.Windows == 0 then
				self.Unloaded = true
			end
		end)
	end

	table.insert(self.Windows, Window)
	return Window
end

-- Return library and managers
return Fluent, SaveManager, InterfaceManager
