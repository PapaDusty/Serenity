-- Rayfield UI Library
-- Complete UI system with tabs, components, icons, and themes

local Rayfield = {}
Rayfield.Library = {}
Rayfield.Config = {}
Rayfield.Themes = {}

-- Integrated Nebula Icon Library
local IconLibrary = {
	Material = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/MaterialIcons.luau"))(),
	Lucide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/LucideIcons.luau"))(),
	Phosphor = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/Phosphor.luau"))(),
	["Phosphor-Filled"] = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/Phosphor%20Filled.luau"))(),
	SF = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/SFSymbols.luau"))(),
	Symbols = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/Symbols.luau"))(),
	["Symbols-Filled"] = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/Symbols-Filled.luau"))(),
	Lab = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/LucideLab.luau"))(),
	Fluency = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/Fluency.luau"))()
}

IconLibrary.nebulaIcons = {
	stripes = 8834748103,
	circles = 73048796459024,
	nebula = 76656741080367,
	home = 111043355839507,
	keycache = 13587387127,
	apps = 13300918120,
	view_in_ar = 113380429914565,
	home_material = 9080449299,
	location = 6034996695,
	sparkle = 4483362748,
}

function IconLibrary:GetIcon(name, source)
	source = source or "Symbols"
	local iconId = self[source] and self[source][name]
	if not iconId then
		warn(string.format("Icon '%s' not found in %s set", tostring(name), tostring(source)))
		return nil
	end
	return string.format("rbxassetid://%s", iconId)
end

-- Theme System
Rayfield.Themes.Default = {
	Background = Color3.fromRGB(30, 30, 30),
	SecondaryBackground = Color3.fromRGB(40, 40, 40),
	TertiaryBackground = Color3.fromRGB(50, 50, 50),
	Topbar = Color3.fromRGB(35, 35, 35),
	TabBackground = Color3.fromRGB(25, 25, 25),
	Text = Color3.fromRGB(220, 220, 220),
	SubText = Color3.fromRGB(180, 180, 180),
	Accent = Color3.fromRGB(100, 150, 255),
	Divider = Color3.fromRGB(80, 80, 80),
	Positive = Color3.fromRGB(35, 209, 96),
	Negative = Color3.fromRGB(255, 60, 60)
}

-- Utility Functions
local function Create(instance, properties)
	local obj = Instance.new(instance)
	for property, value in pairs(properties or {}) do
		obj[property] = value
	end
	return obj
end

local function Tween(object, properties, duration, style, direction)
	style = style or Enum.EasingStyle.Quad
	direction = direction or Enum.EasingDirection.Out
	duration = duration or 0.3
	game:GetService("TweenService"):Create(object, TweenInfo.new(duration, style, direction), properties):Play()
end

local function SearchTable(table, query)
	query = string.lower(tostring(query))
	local results = {}
	for _, item in pairs(table) do
		if string.find(string.lower(tostring(item)), query) then
			table.insert(results, item)
		end
	end
	return results
end

-- Config System
function Rayfield.Config:Save(folder, file, data)
	local HttpService = game:GetService("HttpService")
	local dir = folder or "Rayfield"
	pcall(function()
		if not isfolder(dir) then
			makefolder(dir)
		end
		writefile(string.format("%s/%s.json", dir, file), HttpService:JSONEncode(data))
	end)
end

function Rayfield.Config:Load(folder, file)
	local HttpService = game:GetService("HttpService")
	local dir = folder or "Rayfield"
	local success, result = pcall(function()
		if isfile(string.format("%s/%s.json", dir, file)) then
			return HttpService:JSONDecode(readfile(string.format("%s/%s.json", dir, file)))
		end
	end)
	return success and result or nil
end

-- Main Library
function Rayfield:CreateWindow(options)
	options = options or {}
	local Name = options.Name or "Rayfield"
	local Premium = options.Premium or false
	local ConfigFolder = options.ConfigFolder or "Rayfield"
	local Key = options.Key
	
	-- Screen GUI
	local ScreenGui = Create("ScreenGui", {
		Name = Name,
		Parent = game:GetService("CoreGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	
	-- Main Window
	local Main = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Rayfield.Themes.Default.Background,
		BorderSizePixel = 0
	})
	
	-- Topbar
	local Topbar = Create("Frame", {
		Name = "Topbar",
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Rayfield.Themes.Default.Topbar,
		BorderSizePixel = 0
	})
	
	Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 0)})
	
	local TopbarDivider = Create("Frame", {
		Name = "Divider",
		Parent = Topbar,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Rayfield.Themes.Default.Divider,
		BorderSizePixel = 0
	})
	
	-- Logo/Name
	local Logo = Create("TextLabel", {
		Name = "Logo",
		Parent = Topbar,
		Size = UDim2.new(0, 200, 1, -10),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = Name,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Rayfield.Themes.Default.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Search Bar
	local SearchBar = Create("TextBox", {
		Name = "SearchBar",
		Parent = Topbar,
		Size = UDim2.new(0, 200, 0, 25),
		Position = UDim2.new(0.5, -100, 0.5, -12.5),
		BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
		TextColor3 = Rayfield.Themes.Default.Text,
		PlaceholderText = "Search components...",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		Text = ""
	})
	Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
	
	-- Window Controls
	local Controls = Create("Frame", {
		Name = "Controls",
		Parent = Topbar,
		Size = UDim2.new(0, 120, 1, 0),
		Position = UDim2.new(1, -120, 0, 0),
		BackgroundTransparency = 1
	})
	
	local MinimizeBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = Controls,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 10, 0.5, -15),
		BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Rayfield.Themes.Default.Text
	})
	Create("UICorner", {Parent = MinimizeBtn, CornerRadius = UDim.new(0, 6)})
	
	local FullscreenBtn = Create("TextButton", {
		Name = "Fullscreen",
		Parent = Controls,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 45, 0.5, -15),
		BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
		Text = "⬜",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Rayfield.Themes.Default.Text
	})
	Create("UICorner", {Parent = FullscreenBtn, CornerRadius = UDim.new(0, 6)})
	
	local CloseBtn = Create("TextButton", {
		Name = "Close",
		Parent = Controls,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 80, 0.5, -15),
		BackgroundColor3 = Rayfield.Themes.Default.Negative,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Color3.fromRGB(255, 255, 255)
	})
	Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0, 6)})
	
	-- Tab Section
	local TabSection = Create("Frame", {
		Name = "TabSection",
		Parent = Main,
		Size = UDim2.new(0, 200, 1, -80),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundColor3 = Rayfield.Themes.Default.TabBackground,
		BorderSizePixel = 0
	})
	
	local TabDivider = Create("Frame", {
		Name = "Divider",
		Parent = TabSection,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Rayfield.Themes.Default.Divider,
		BorderSizePixel = 0
	})
	
	local TabList = Create("ScrollingFrame", {
		Name = "TabList",
		Parent = TabSection,
		Size = UDim2.new(1, -10, 1, -80),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Rayfield.Themes.Default.Divider,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	
	Create("UIListLayout", {
		Parent = TabList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})
	
	-- Player Info
	local PlayerInfo = Create("Frame", {
		Name = "PlayerInfo",
		Parent = TabSection,
		Size = UDim2.new(1, -10, 0, 70),
		Position = UDim2.new(0, 5, 1, -75),
		BackgroundTransparency = 1
	})
	
	local PlayerIcon = Create("ImageLabel", {
		Name = "PlayerIcon",
		Parent = PlayerInfo,
		Size = UDim2.new(0, 40, 0, 40),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundColor3 = Rayfield.Themes.Default.TertiaryBackground,
		Image = game.Players:GetUserThumbnailAsync(game.Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	})
	Create("UICorner", {Parent = PlayerIcon, CornerRadius = UDim.new(0, 8)})
	Create("UIStroke", {Parent = PlayerIcon, Color = Rayfield.Themes.Default.Divider, Thickness = 1})
	
	local Crown = Create("ImageLabel", {
		Name = "Crown",
		Parent = PlayerIcon,
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0.5, -10, 0, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3926305904",
		Rotation = -15,
		Visible = Premium
	})
	
	local DisplayName = Create("TextLabel", {
		Name = "DisplayName",
		Parent = PlayerInfo,
		Size = UDim2.new(1, -70, 0, 20),
		Position = UDim2.new(0, 60, 0, 10),
		BackgroundTransparency = 1,
		Text = game.Players.LocalPlayer.DisplayName,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Rayfield.Themes.Default.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local Username = Create("TextLabel", {
		Name = "Username",
		Parent = PlayerInfo,
		Size = UDim2.new(1, -70, 0, 20),
		Position = UDim2.new(0, 60, 0, 35),
		BackgroundTransparency = 1,
		Text = "@" .. game.Players.LocalPlayer.Name,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Rayfield.Themes.Default.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Main Content Area
	local Content = Create("Frame", {
		Name = "Content",
		Parent = Main,
		Size = UDim2.new(1, -201, 1, -40),
		Position = UDim2.new(0, 200, 0, 40),
		BackgroundTransparency = 1
	})
	
	local Pages = Create("Frame", {
		Name = "Pages",
		Parent = Content,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	})
	
	-- Window State
	local isMinimized = false
	local isFullscreen = false
	local originalSize = Main.Size
	local originalPosition = Main.Position
	
	-- Window Control Functions
	MinimizeBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			Tween(Main, {Size = UDim2.new(0, 800, 0, 40)}, 0.3)
			Content.Visible = false
			TabSection.Visible = false
		else
			Tween(Main, {Size = originalSize}, 0.3)
			Content.Visible = true
			TabSection.Visible = true
		end
	end)
	
	FullscreenBtn.MouseButton1Click:Connect(function()
		isFullscreen = not isFullscreen
		if isFullscreen then
			originalSize = Main.Size
			originalPosition = Main.Position
			Tween(Main, {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0)
			}, 0.3)
		else
			Tween(Main, {
				Size = originalSize,
				Position = originalPosition
			}, 0.3)
		end
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)
	
	-- Tab Management
	local Tabs = {}
	local CurrentTab = nil
	
	-- Component Library
	local ComponentLibrary = {}
	
	function ComponentLibrary:CreateButton(options)
		options = options or {}
		local Name = options.Name or "Button"
		local Callback = options.Callback or function() end
		local Icon = options.Icon
		local IconSet = options.IconSet or "Symbols"
		
		local Button = Create("TextButton", {
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			AutoButtonColor = false,
			Text = "",
			Parent = options.Parent
		})
		Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 6)})
		
		local ButtonText = Create("TextLabel", {
			Size = UDim2.new(1, Icon and -40 or -10, 1, 0),
			Position = UDim2.new(0, Icon and 35 or 5, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Button
		})
		
		if Icon then
			local IconImage = Create("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 10, 0.5, -10),
				BackgroundTransparency = 1,
				Image = IconLibrary:GetIcon(Icon, IconSet),
				Parent = Button
			})
		end
		
		Button.MouseButton1Click:Connect(Callback)
		
		Button.MouseEnter:Connect(function()
			Tween(Button, {BackgroundColor3 = Rayfield.Themes.Default.TertiaryBackground}, 0.2)
		end)
		
		Button.MouseLeave:Connect(function()
			Tween(Button, {BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground}, 0.2)
		end)
		
		return Button
	end
	
	function ComponentLibrary:CreateToggle(options)
		options = options or {}
		local Name = options.Name or "Toggle"
		local Default = options.Default or false
		local Callback = options.Callback or function() end
		local Icon = options.Icon
		local IconSet = options.IconSet or "Symbols"
		
		local Toggle = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			Parent = options.Parent
		})
		Create("UICorner", {Parent = Toggle, CornerRadius = UDim.new(0, 6)})
		
		local ToggleText = Create("TextLabel", {
			Size = UDim2.new(1, Icon and -80 or -50, 1, 0),
			Position = UDim2.new(0, Icon and 35 or 5, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Toggle
		})
		
		if Icon then
			local IconImage = Create("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 10, 0.5, -10),
				BackgroundTransparency = 1,
				Image = IconLibrary:GetIcon(Icon, IconSet),
				Parent = Toggle
			})
		end
		
		local ToggleButton = Create("TextButton", {
			Size = UDim2.new(0, 40, 0, 20),
			Position = UDim2.new(1, -45, 0.5, -10),
			BackgroundColor3 = Default and Rayfield.Themes.Default.Positive or Rayfield.Themes.Default.Divider,
			Text = "",
			Parent = Toggle
		})
		Create("UICorner", {Parent = ToggleButton, CornerRadius = UDim.new(0, 10)})
		
		local ToggleIndicator = Create("Frame", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 2, 0.5, -8),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = ToggleButton
		})
		Create("UICorner", {Parent = ToggleIndicator, CornerRadius = UDim.new(1, 0)})
		
		local isToggled = Default
		if isToggled then
			ToggleIndicator.Position = UDim2.new(1, -18, 0.5, -8)
		end
		
		ToggleButton.MouseButton1Click:Connect(function()
			isToggled = not isToggled
			Tween(ToggleButton, {
				BackgroundColor3 = isToggled and Rayfield.Themes.Default.Positive or Rayfield.Themes.Default.Divider
			}, 0.2)
			Tween(ToggleIndicator, {
				Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			}, 0.2)
			Callback(isToggled)
		end)
		
		return Toggle
	end
	
	function ComponentLibrary:CreateSlider(options)
		options = options or {}
		local Name = options.Name or "Slider"
		local Min = options.Min or 0
		local Max = options.Max or 100
		local Default = options.Default or 50
		local Callback = options.Callback or function() end
		
		local Slider = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 55),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			Parent = options.Parent
		})
		Create("UICorner", {Parent = Slider, CornerRadius = UDim.new(0, 6)})
		
		local SliderText = Create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			Text = Name,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Slider
		})
		
		local ValueText = Create("TextLabel", {
			Size = UDim2.new(0, 50, 0, 20),
			Position = UDim2.new(1, -55, 0, 5),
			BackgroundTransparency = 1,
			Text = tostring(Default),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.SubText,
			Parent = Slider
		})
		
		local SliderBar = Create("Frame", {
			Size = UDim2.new(1, -20, 0, 6),
			Position = UDim2.new(0, 10, 0, 35),
			BackgroundColor3 = Rayfield.Themes.Default.Divider,
			Parent = Slider
		})
		Create("UICorner", {Parent = SliderBar, CornerRadius = UDim.new(0, 3)})
		
		local SliderProgress = Create("Frame", {
			Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0),
			BackgroundColor3 = Rayfield.Themes.Default.Accent,
			Parent = SliderBar
		})
		Create("UICorner", {Parent = SliderProgress, CornerRadius = UDim.new(0, 3)})
		
		local SliderButton = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundTransparency = 1,
			Text = "",
			Parent = Slider
		})
		
		local value = Default
		SliderButton.MouseButton1Down:Connect(function()
			local connection
			connection = game:GetService("RunService").RenderStepped:Connect(function()
				local mouse = game:GetService("Players").LocalPlayer:GetMouse()
				local percent = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				value = math.floor(Min + (Max - Min) * percent)
				ValueText.Text = tostring(value)
				SliderProgress.Size = UDim2.new(percent, 0, 1, 0)
				Callback(value)
			end)
			
			local ended
			ended = game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					connection:Disconnect()
					ended:Disconnect()
				end
			end)
		end)
		
		return Slider
	end
	
	function ComponentLibrary:CreateTextbox(options)
		options = options or {}
		local Name = options.Name or "Textbox"
		local Default = options.Default or ""
		local Placeholder = options.Placeholder or ""
		local Callback = options.Callback or function() end
		
		local Textbox = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			Parent = options.Parent
		})
		Create("UICorner", {Parent = Textbox, CornerRadius = UDim.new(0, 6)})
		
		local TextboxInput = Create("TextBox", {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 5, 0, 0),
			BackgroundTransparency = 1,
			Text = Default,
			PlaceholderText = Placeholder,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Textbox
		})
		
		TextboxInput.FocusLost:Connect(function()
			Callback(TextboxInput.Text)
		end)
		
		return Textbox
	end
	
	function ComponentLibrary:CreateDropdown(options)
		options = options or {}
		local Name = options.Name or "Dropdown"
		local Options = options.Options or {}
		local Default = options.Default or Options[1]
		local Callback = options.Callback or function() end
		
		local Dropdown = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			Parent = options.Parent
		})
		Create("UICorner", {Parent = Dropdown, CornerRadius = UDim.new(0, 6)})
		
		local DropdownButton = Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = Dropdown
		})
		
		local DropdownText = Create("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Default or Name,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Dropdown
		})
		
		local DropdownIcon = Create("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, -25, 0.5, -10),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3926305904",
			Rotation = 90,
			Parent = Dropdown
		})
		
		local DropdownList = Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 1, 5),
			BackgroundColor3 = Rayfield.Themes.Default.TertiaryBackground,
			Visible = false,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Rayfield.Themes.Default.Divider,
			Parent = Dropdown
		})
		Create("UICorner", {Parent = DropdownList, CornerRadius = UDim.new(0, 6)})
		Create("UIListLayout", {Parent = DropdownList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
		
		local isOpen = false
		
		for _, option in pairs(Options) do
			local OptionButton = Create("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Rayfield.Themes.Default.TertiaryBackground,
				AutoButtonColor = false,
				Text = option,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Rayfield.Themes.Default.Text,
				Parent = DropdownList
			})
			
			OptionButton.MouseButton1Click:Connect(function()
				DropdownText.Text = option
				Callback(option)
				isOpen = false
				DropdownList.Visible = false
				Tween(DropdownIcon, {Rotation = 90}, 0.2)
			end)
			
			OptionButton.MouseEnter:Connect(function()
				Tween(OptionButton, {BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground}, 0.2)
			end)
			
			OptionButton.MouseLeave:Connect(function()
				Tween(OptionButton, {BackgroundColor3 = Rayfield.Themes.Default.TertiaryBackground}, 0.2)
			end)
		end
		
		DropdownList.CanvasSize = UDim2.new(0, 0, 0, #Options * 32)
		
		DropdownButton.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			DropdownList.Visible = isOpen
			Tween(DropdownIcon, {Rotation = isOpen and 270 or 90}, 0.2)
		end)
		
		return Dropdown
	end
	
	function ComponentLibrary:CreateColorPicker(options)
		options = options or {}
		local Name = options.Name or "Color Picker"
		local Default = options.Default or Color3.fromRGB(255, 255, 255)
		local Callback = options.Callback or function() end
		
		local ColorPicker = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 35),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			Parent = options.Parent
		})
		Create("UICorner", {Parent = ColorPicker, CornerRadius = UDim.new(0, 6)})
		
		local ColorText = Create("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = ColorPicker
		})
		
		local ColorPreview = Create("Frame", {
			Size = UDim2.new(0, 30, 0, 20),
			Position = UDim2.new(1, -35, 0.5, -10),
			BackgroundColor3 = Default,
			Parent = ColorPicker
		})
		Create("UICorner", {Parent = ColorPreview, CornerRadius = UDim.new(0, 4)})
		Create("UIStroke", {Parent = ColorPreview, Color = Rayfield.Themes.Default.Divider, Thickness = 1})
		
		local ColorModal = Create("Frame", {
			Size = UDim2.new(0, 200, 0, 200),
			Position = UDim2.new(0.5, -100, 0.5, -100),
			BackgroundColor3 = Rayfield.Themes.Default.SecondaryBackground,
			Visible = false,
			Parent = ScreenGui
		})
		Create("UICorner", {Parent = ColorModal, CornerRadius = UDim.new(0, 8)})
		
		local ColorCanvas = Create("ImageButton", {
			Size = UDim2.new(0, 180, 0, 180),
			Position = UDim2.new(0.5, -90, 0.5, -90),
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			Image = "rbxassetid://4155801252",
			Parent = ColorModal
		})
		
		ColorPreview.MouseButton1Click:Connect(function()
			ColorModal.Visible = not ColorModal.Visible
		end)
		
		ColorCanvas.MouseButton1Down:Connect(function()
			local connection
			connection = game:GetService("RunService").RenderStepped:Connect(function()
				local mouse = game:GetService("Players").LocalPlayer:GetMouse()
				local x = math.clamp((mouse.X - ColorCanvas.AbsolutePosition.X) / ColorCanvas.AbsoluteSize.X, 0, 1)
				local y = math.clamp((mouse.Y - ColorCanvas.AbsolutePosition.Y) / ColorCanvas.AbsoluteSize.Y, 0, 1)
				local color = Color3.fromHSV(x, 1 - y, 1)
				ColorPreview.BackgroundColor3 = color
				Callback(color)
			end)
			
			local ended
			ended = game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					connection:Disconnect()
					ended:Disconnect()
				end
			end)
		end)
		
		return ColorPicker
	end
	
	function ComponentLibrary:CreateParagraph(options)
		options = options or {}
		local Title = options.Title or "Paragraph"
		local Content = options.Content or ""
		
		local Paragraph = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 60),
			BackgroundTransparency = 1,
			Parent = options.Parent
		})
		
		local TitleText = Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = Title,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Paragraph
		})
		
		local ContentText = Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = Content,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Rayfield.Themes.Default.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Parent = Paragraph
		})
		
		return Paragraph
	end
	
	function ComponentLibrary:CreateSection(options)
		options = options or {}
		local Name = options.Name or "Section"
		
		local Section = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Parent = options.Parent
		})
		
		local SectionTitle = Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = Name,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = Rayfield.Themes.Default.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Section
		})
		
		return Section
	end
	
	function ComponentLibrary:CreateDivider(options)
		options = options or {}
		
		local Divider = Create("Frame", {
			Size = UDim2.new(1, -10, 0, 1),
			BackgroundColor3 = Rayfield.Themes.Default.Divider,
			Parent = options.Parent
		})
		
		return Divider
	end
	
	-- Tab Creator
	local function CreateTab(options)
		options = options or {}
		local Name = options.Name or "Tab"
		local Icon = options.Icon
		local IconSet = options.IconSet or "Symbols"
		
		local TabButton = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Text = "",
			Parent = TabList
		})
		
		local TabButtonText = Create("TextLabel", {
			Size = UDim2.new(1, Icon and -50 or -10, 1, 0),
			Position = UDim2.new(0, Icon and 35 or 5, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = Rayfield.Themes.Default.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = TabButton
		})
		
		if Icon then
			local TabIcon = Create("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 10, 0.5, -10),
				BackgroundTransparency = 1,
				Image = IconLibrary:GetIcon(Icon, IconSet),
				Parent = TabButton
			})
		end
		
		local TabPage = Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Rayfield.Themes.Default.Divider,
			Parent = Pages
		})
		
		Create("UIListLayout", {
			Parent = TabPage,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10)
		})
		
		TabButton.MouseButton1Click:Connect(function()
			if CurrentTab then
				CurrentTab.Page.Visible = false
				Tween(CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
			end
			CurrentTab = {Button = TabButton, Page = TabPage}
			TabPage.Visible = true
			Tween(TabButton, {BackgroundTransparency = 0.5}, 0.2)
		end)
		
		if not CurrentTab then
			CurrentTab = {Button = TabButton, Page = TabPage}
			TabPage.Visible = true
			Tween(TabButton, {BackgroundTransparency = 0.5}, 0.2)
		end
		
		return {
			Name = Name,
			Button = TabButton,
			Page = TabPage,
			CreateButton = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateButton(options)
			end,
			CreateToggle = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateToggle(options)
			end,
			CreateSlider = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateSlider(options)
			end,
			CreateTextbox = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateTextbox(options)
			end,
			CreateDropdown = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateDropdown(options)
			end,
			CreateColorPicker = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateColorPicker(options)
			end,
			CreateParagraph = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateParagraph(options)
			end,
			CreateSection = function(self, options)
				options.Parent = TabPage
				return ComponentLibrary:CreateSection(options)
			end,
			CreateDivider = function(self)
				return ComponentLibrary:CreateDivider({Parent = TabPage})
			end
		}
	end
	
	-- Search Functionality
	SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		local query = SearchBar.Text
		if query == "" then
			for _, tab in pairs(Tabs) do
				tab.Button.Visible = true
				for _, child in pairs(tab.Page:GetChildren() do
					if child:IsA("GuiObject") then
						child.Visible = true
					end
				end
			end
		else
			for _, tab in pairs(Tabs) do
				local tabHasMatch = false
				for _, child in pairs(tab.Page:GetChildren() do
					if child:IsA("GuiObject") then
						local hasMatch = false
						for _, descendant in pairs(child:GetDescendants() do
							if descendant:IsA("TextLabel") or descendant:IsA("TextBox") then
								if string.find(string.lower(descendant.Text), string.lower(query)) then
									hasMatch = true
									tabHasMatch = true
									break
								end
							end
						end
						child.Visible = hasMatch
					end
				end
				tab.Button.Visible = tabHasMatch
			end
		end
	end)
	
	-- Return Window API
	return {
		CreateTab = function(self, name, icon, iconSet)
			local tab = CreateTab({
				Name = name,
				Icon = icon,
				IconSet = iconSet or "Symbols"
			})
			Tabs[name] = tab
			return tab
		end,
		SetTheme = function(self, theme)
			Rayfield.Themes.Current = theme
			-- Apply theme colors
			Main.BackgroundColor3 = theme.Background
			Topbar.BackgroundColor3 = theme.Topbar
			TabSection.BackgroundColor3 = theme.TabBackground
			-- etc...
		end,
		Destroy = function()
			ScreenGui:Destroy()
		end
	}
end

-- Return Library
return Rayfield
