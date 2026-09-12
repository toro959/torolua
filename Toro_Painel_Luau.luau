--// TORO PANEL v6 - Admin Panel (seu jogo)
--// LocalScript → StarterPlayer > StarterPlayerScripts
--//
--// Correções desta versão:
--// • UIListLayout em todas as páginas (menu não fica mais bugado)
--// • Aimbot + FOV + Smoothness na aba Combat
--// • ESP Box, Health Bar funcional, Name, Distance, Tracer, Head Dot, Skeleton
--// • Team Check, Speed, Themes, Insert para mostrar/esconder

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local Config = {
	AimEnabled = false,
	FOV = 180,
	Smooth = 8,
	AimKey = Enum.KeyCode.Q,

	ESPBox = true,
	ESPHealth = true,
	ESPName = true,
	ESPDistance = true,
	ESPTracer = false,
	ESPHeadDot = false,
	ESPSkeleton = false,
	TeamCheck = true,

	SpeedEnabled = false,
	Speed = 16,

	MenuVisible = true,
}

local Theme = {
	Background = Color3.fromRGB(14, 14, 18),
	Sidebar = Color3.fromRGB(10, 10, 14),
	Card = Color3.fromRGB(21, 21, 27),
	Card2 = Color3.fromRGB(27, 27, 34),
	Accent = Color3.fromRGB(255, 70, 150),
	Text = Color3.fromRGB(240, 240, 245),
	SubText = Color3.fromRGB(145, 145, 155),
	Stroke = Color3.fromRGB(45, 45, 55),
	Green = Color3.fromRGB(80, 220, 130),
	Red = Color3.fromRGB(240, 80, 90),
	Yellow = Color3.fromRGB(255, 190, 60),
}

--==================================================
-- HELPERS
--==================================================
local function New(className, props, parent)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function Corner(parent, radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function Stroke(parent, color, thickness)
	return New("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
	}, parent)
end

local function Label(parent, text, size, pos, textSize, color, font)
	return New("TextLabel", {
		BackgroundTransparency = 1,
		Size = size or UDim2.new(1, 0, 1, 0),
		Position = pos or UDim2.fromOffset(0, 0),
		Text = text or "",
		TextColor3 = color or Theme.Text,
		TextSize = textSize or 14,
		Font = font or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, parent)
end

--==================================================
-- GUI BASE
--==================================================
local old = PlayerGui:FindFirstChild("ToroPanel")
if old then
	old:Destroy()
end

local Gui = New("ScreenGui", {
	Name = "ToroPanel",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local Main = New("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(780, 520),
	Position = UDim2.new(0.5, -390, 0.5, -260),
	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,
	Active = true,
}, Gui)
Corner(Main, 12)
Stroke(Main, Theme.Stroke, 1)

-- Top bar (drag)
local Top = New("Frame", {
	Name = "Top",
	Size = UDim2.new(1, 0, 0, 58),
	BackgroundTransparency = 1,
	Active = true,
}, Main)

local Title = Label(Top, "TORO", UDim2.fromOffset(180, 30), UDim2.fromOffset(22, 9), 22, Theme.Text, Enum.Font.GothamBold)
local SubTitle = Label(Top, "ADMIN CONTROL PANEL", UDim2.fromOffset(220, 20), UDim2.fromOffset(23, 32), 10, Theme.SubText)

local StatusDot = New("Frame", {
	Size = UDim2.fromOffset(8, 8),
	Position = UDim2.new(1, -100, 0, 25),
	BackgroundColor3 = Theme.Green,
	BorderSizePixel = 0,
}, Top)
Corner(StatusDot, 10)

local StatusText = Label(Top, "ONLINE", UDim2.fromOffset(65, 20), UDim2.new(1, -87, 0, 19), 10, Theme.SubText)
StatusText.TextXAlignment = Enum.TextXAlignment.Right

-- Sidebar
local Sidebar = New("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 175, 1, -58),
	Position = UDim2.fromOffset(0, 58),
	BackgroundColor3 = Theme.Sidebar,
	BorderSizePixel = 0,
}, Main)

New("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, Sidebar)

New("UIPadding", {
	PaddingTop = UDim.new(0, 18),
	PaddingLeft = UDim.new(0, 12),
	PaddingRight = UDim.new(0, 12),
}, Sidebar)

local Content = New("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -175, 1, -58),
	Position = UDim2.new(0, 175, 0, 58),
	BackgroundTransparency = 1,
}, Main)

local Pages = {}
local TabButtons = {}
local currentPage = nil

local function MakePage(name)
	local page = New("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, -30, 1, -25),
		Position = UDim2.fromOffset(15, 12),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, Content)

	New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, page)

	New("UIPadding", {
		PaddingBottom = UDim.new(0, 18),
		PaddingRight = UDim.new(0, 8),
	}, page)

	Pages[name] = page
	return page
end

local function MakeTab(name, icon)
	local b = New("TextButton", {
		Name = name .. "Tab",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Sidebar,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
	}, Sidebar)
	Corner(b, 8)

	local accent = New("Frame", {
		Size = UDim2.fromOffset(3, 24),
		Position = UDim2.fromOffset(0, 9),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Visible = false,
	}, b)
	Corner(accent, 4)

	local ico = Label(b, icon, UDim2.fromOffset(28, 30), UDim2.fromOffset(13, 6), 15, Theme.SubText)
	ico.TextXAlignment = Enum.TextXAlignment.Center

	local txt = Label(b, name, UDim2.new(1, -48, 1, 0), UDim2.fromOffset(48, 0), 13, Theme.SubText)

	b.MouseEnter:Connect(function()
		if currentPage ~= name then
			b.BackgroundColor3 = Theme.Card
		end
	end)
	b.MouseLeave:Connect(function()
		if currentPage ~= name then
			b.BackgroundColor3 = Theme.Sidebar
		end
	end)

	b.MouseButton1Click:Connect(function()
		for _, data in pairs(TabButtons) do
			data.button.BackgroundColor3 = Theme.Sidebar
			data.accent.Visible = false
			data.text.TextColor3 = Theme.SubText
		end
		b.BackgroundColor3 = Theme.Card
		accent.Visible = true
		txt.TextColor3 = Theme.Text

		for pageName, page in pairs(Pages) do
			page.Visible = (pageName == name)
		end
		currentPage = name
	end)

	TabButtons[name] = { button = b, accent = accent, text = txt }
	return b
end

local Combat = MakePage("Combat")
local Visuals = MakePage("Visuals")
local PlayerPage = MakePage("Player")
local ConfigPage = MakePage("Config")

MakeTab("Combat", "⚔")
MakeTab("Visuals", "◉")
MakeTab("Player", "◆")
MakeTab("Config", "⚙")

--==================================================
-- CONTROLS (agora com LayoutOrder correto)
--==================================================
local function Section(parent, title)
	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = #parent:GetChildren(),
	}, parent)
	local lbl = Label(holder, title, UDim2.new(1, 0, 1, 0), UDim2.fromOffset(2, 0), 12, Theme.SubText, Enum.Font.GothamBold)
	return holder
end

local function Toggle(parent, title, initial, callback)
	local row = New("Frame", {
		Size = UDim2.new(1, -5, 0, 48),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		LayoutOrder = #parent:GetChildren(),
	}, parent)
	Corner(row, 8)

	Label(row, title, UDim2.new(1, -75, 1, 0), UDim2.fromOffset(14, 0), 13, Theme.Text)

	local button = New("TextButton", {
		Size = UDim2.fromOffset(44, 24),
		Position = UDim2.new(1, -58, 0.5, -12),
		BackgroundColor3 = Color3.fromRGB(45, 45, 53),
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
	}, row)
	Corner(button, 20)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Color3.fromRGB(220, 220, 225),
		BorderSizePixel = 0,
	}, button)
	Corner(knob, 20)

	local state = initial

	local function update()
		if state then
			button.BackgroundColor3 = Theme.Accent
			knob.Position = UDim2.new(1, -21, 0, 3)
		else
			button.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
			knob.Position = UDim2.fromOffset(3, 3)
		end
		if callback then
			callback(state)
		end
	end

	button.MouseButton1Click:Connect(function()
		state = not state
		update()
	end)

	update()
	return row
end

local function Slider(parent, title, minValue, maxValue, initial, decimals, callback)
	local row = New("Frame", {
		Size = UDim2.new(1, -5, 0, 70),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Active = true,
		LayoutOrder = #parent:GetChildren(),
	}, parent)
	Corner(row, 8)

	Label(row, title, UDim2.new(1, -90, 0, 25), UDim2.fromOffset(14, 5), 13, Theme.Text)

	local valueLabel = Label(row, "", UDim2.fromOffset(70, 25), UDim2.new(1, -84, 0, 5), 12, Theme.Accent)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local track = New("Frame", {
		Size = UDim2.new(1, -28, 0, 8),
		Position = UDim2.fromOffset(14, 43),
		BackgroundColor3 = Color3.fromRGB(42, 42, 50),
		BorderSizePixel = 0,
		Active = true,
	}, row)
	Corner(track, 8)

	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	}, track)
	Corner(fill, 8)

	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, track)
	Corner(knob, 20)

	local hit = New("TextButton", {
		Size = UDim2.new(1, 18, 0, 30),
		Position = UDim2.fromOffset(-9, 32),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 10,
	}, row)

	local value = initial
	local dragging = false

	local function roundValue(v)
		if decimals == 0 then
			return math.floor(v + 0.5)
		end
		local p = 10 ^ decimals
		return math.floor(v * p + 0.5) / p
	end

	local function applyValue(v)
		value = math.clamp(roundValue(v), minValue, maxValue)
		local a = (value - minValue) / math.max(maxValue - minValue, 0.0001)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		if decimals == 0 then
			valueLabel.Text = tostring(value)
		else
			valueLabel.Text = string.format("%." .. decimals .. "f", value)
		end
		if callback then
			callback(value)
		end
	end

	local function setFromX(x)
		local left = track.AbsolutePosition.X
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - left) / width, 0, 1)
		applyValue(minValue + (maxValue - minValue) * alpha)
	end

	hit.MouseButton1Down:Connect(function(x)
		dragging = true
		setFromX(x)
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- valor inicial
	task.defer(function()
		applyValue(initial)
	end)

	return row
end

local function Keybind(parent, title, initial, callback)
	local row = New("Frame", {
		Size = UDim2.new(1, -5, 0, 48),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		LayoutOrder = #parent:GetChildren(),
	}, parent)
	Corner(row, 8)

	Label(row, title, UDim2.new(1, -120, 1, 0), UDim2.fromOffset(14, 0), 13, Theme.Text)

	local keyButton = New("TextButton", {
		Size = UDim2.fromOffset(88, 30),
		Position = UDim2.new(1, -100, 0.5, -15),
		BackgroundColor3 = Theme.Card2,
		BorderSizePixel = 0,
		Text = initial.Name,
		TextColor3 = Theme.Text,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, row)
	Corner(keyButton, 7)
	Stroke(keyButton, Theme.Stroke)

	local waiting = false

	keyButton.MouseButton1Click:Connect(function()
		waiting = true
		keyButton.Text = "PRESS KEY"
		keyButton.TextColor3 = Theme.Accent
	end)

	UIS.InputBegan:Connect(function(input)
		if not waiting then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		waiting = false
		Config.AimKey = input.KeyCode
		keyButton.Text = input.KeyCode.Name
		keyButton.TextColor3 = Theme.Text
		if callback then
			callback(input.KeyCode)
		end
	end)

	return row
end

--==================================================
-- COMBAT PAGE (Aimbot)
--==================================================
Section(Combat, "AIMBOT")

Toggle(Combat, "Aimbot", Config.AimEnabled, function(v)
	Config.AimEnabled = v
end)

Slider(Combat, "FOV", 30, 500, Config.FOV, 0, function(v)
	Config.FOV = v
end)

Slider(Combat, "Smoothness", 1, 30, Config.Smooth, 1, function(v)
	Config.Smooth = v
end)

Keybind(Combat, "Aim Key", Config.AimKey, function(v)
	Config.AimKey = v
end)

--==================================================
-- VISUALS PAGE (ESP)
--==================================================
Section(Visuals, "ESP")

Toggle(Visuals, "ESP Box", Config.ESPBox, function(v)
	Config.ESPBox = v
end)

Toggle(Visuals, "ESP Health", Config.ESPHealth, function(v)
	Config.ESPHealth = v
end)

Toggle(Visuals, "ESP Name", Config.ESPName, function(v)
	Config.ESPName = v
end)

Toggle(Visuals, "ESP Distance", Config.ESPDistance, function(v)
	Config.ESPDistance = v
end)

Toggle(Visuals, "ESP Tracer", Config.ESPTracer, function(v)
	Config.ESPTracer = v
end)

Toggle(Visuals, "ESP Head Dot", Config.ESPHeadDot, function(v)
	Config.ESPHeadDot = v
end)

Toggle(Visuals, "ESP Skeleton", Config.ESPSkeleton, function(v)
	Config.ESPSkeleton = v
end)

Toggle(Visuals, "Team Check", Config.TeamCheck, function(v)
	Config.TeamCheck = v
end)

--==================================================
-- PLAYER PAGE
--==================================================
Section(PlayerPage, "MOVEMENT")

Toggle(PlayerPage, "Custom Speed", Config.SpeedEnabled, function(v)
	Config.SpeedEnabled = v
end)

Slider(PlayerPage, "WalkSpeed", 16, 100, Config.Speed, 0, function(v)
	Config.Speed = v
end)

local resetButton = New("TextButton", {
	Size = UDim2.new(1, -5, 0, 48),
	BackgroundColor3 = Theme.Card,
	BorderSizePixel = 0,
	Text = "Reset Character",
	TextColor3 = Theme.Text,
	TextSize = 13,
	Font = Enum.Font.Gotham,
	AutoButtonColor = false,
	LayoutOrder = #PlayerPage:GetChildren(),
}, PlayerPage)
Corner(resetButton, 8)

resetButton.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Health = 0
	end
end)

--==================================================
-- CONFIG PAGE
--==================================================
Section(ConfigPage, "THEME")

local themeNames = {
	{ "Pink", Color3.fromRGB(255, 70, 150) },
	{ "Red", Color3.fromRGB(245, 70, 80) },
	{ "Purple", Color3.fromRGB(155, 90, 255) },
	{ "Blue", Color3.fromRGB(80, 145, 255) },
	{ "Green", Color3.fromRGB(75, 215, 135) },
	{ "Orange", Color3.fromRGB(255, 145, 65) },
}

local function ApplyAccent(color)
	Theme.Accent = color
	for _, data in pairs(TabButtons) do
		data.accent.BackgroundColor3 = Theme.Accent
	end
	for _, obj in ipairs(Gui:GetDescendants()) do
		if obj:IsA("Frame") and obj.Name == "Fill" then
			obj.BackgroundColor3 = Theme.Accent
		end
	end
end

for _, item in ipairs(themeNames) do
	local name, color = item[1], item[2]
	local b = New("TextButton", {
		Size = UDim2.new(1, -5, 0, 42),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false,
		LayoutOrder = #ConfigPage:GetChildren(),
	}, ConfigPage)
	Corner(b, 8)
	b.MouseButton1Click:Connect(function()
		ApplyAccent(color)
	end)
end

New("TextLabel", {
	Size = UDim2.new(1, -5, 0, 48),
	BackgroundTransparency = 1,
	Text = "INSERT  •  mostrar / esconder menu",
	TextColor3 = Theme.SubText,
	TextSize = 11,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	LayoutOrder = #ConfigPage:GetChildren(),
}, ConfigPage)

--==================================================
-- TAB INICIAL
--==================================================
TabButtons["Combat"].button.BackgroundColor3 = Theme.Card
TabButtons["Combat"].accent.Visible = true
TabButtons["Combat"].text.TextColor3 = Theme.Text
Combat.Visible = true
currentPage = "Combat"

--==================================================
-- DRAG
--==================================================
local draggingMenu = false
local dragStart, startPos, dragInput

local function updateMenuDrag(input)
	if not draggingMenu or not dragStart or not startPos then
		return
	end
	local delta = input.Position - dragStart
	Main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingMenu = true
		dragStart = input.Position
		startPos = Main.Position
		dragInput = (input.UserInputType == Enum.UserInputType.MouseButton1)
			and Enum.UserInputType.MouseMovement
			or Enum.UserInputType.Touch
	end
end)

UIS.InputChanged:Connect(function(input)
	if draggingMenu and input.UserInputType == dragInput then
		updateMenuDrag(input)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingMenu = false
		dragInput = nil
	end
end)

--==================================================
-- INSERT
--==================================================
UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Insert then
		Config.MenuVisible = not Config.MenuVisible
		Main.Visible = Config.MenuVisible
	end
end)

--==================================================
-- ESP (Screen-space + Skeleton)
--==================================================
local ESPFolder = New("Folder", { Name = "ToroESP" }, Gui)
local ESPObjects = {}

-- Bones do skeleton (R15 + fallback R6)
local SKELETON_CONNECTIONS = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
	-- R6 fallback
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local function RemoveESP(player)
	local data = ESPObjects[player]
	if not data then
		return
	end
	if data.root and data.root.Parent then
		data.root:Destroy()
	end
	if data.skeletonLines then
		for _, line in pairs(data.skeletonLines) do
			if line and line.Parent then
				line:Destroy()
			end
		end
	end
	ESPObjects[player] = nil
end

local function MakeESP(player)
	if player == LocalPlayer or ESPObjects[player] then
		return
	end

	local root = New("Frame", {
		Name = player.Name,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(100, 100),
		Visible = false,
		ZIndex = 50,
	}, ESPFolder)

	local box = New("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 51,
	}, root)
	Stroke(box, Theme.Accent, 1.5)

	local hpBack = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(35, 35, 40),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 52,
	}, root)
	Corner(hpBack, 3)

	local hpFill = New("Frame", {
		Name = "HPFill",
		BackgroundColor3 = Theme.Green,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 53,
	}, hpBack)
	Corner(hpFill, 3)

	local name = Label(root, player.DisplayName, UDim2.fromOffset(250, 20), UDim2.fromOffset(-75, -25), 12, Theme.Text)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.ZIndex = 54

	local distance = Label(root, "", UDim2.fromOffset(250, 18), UDim2.fromOffset(-75, 4), 10, Theme.SubText)
	distance.TextXAlignment = Enum.TextXAlignment.Center
	distance.ZIndex = 54

	local tracer = New("Frame", {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Visible = false,
		ZIndex = 49,
	}, root)

	local headDot = New("Frame", {
		Size = UDim2.fromOffset(8, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 55,
	}, root)
	Corner(headDot, 20)

	-- Skeleton lines (criadas sob demanda)
	local skeletonLines = {}

	ESPObjects[player] = {
		root = root,
		box = box,
		hpBack = hpBack,
		hpFill = hpFill,
		name = name,
		distance = distance,
		tracer = tracer,
		headDot = headDot,
		skeletonLines = skeletonLines,
	}
end

for _, p in ipairs(Players:GetPlayers()) do
	MakeESP(p)
end
Players.PlayerAdded:Connect(MakeESP)
Players.PlayerRemoving:Connect(RemoveESP)

local function SameTeam(a, b)
	if not Config.TeamCheck then
		return false
	end
	if a.Team and b.Team then
		return a.Team == b.Team
	end
	return false
end

local function GetCharacterParts(player)
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local head = char:FindFirstChild("Head")
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if not hum or not head or not rootPart or hum.Health <= 0 then
		return
	end
	return char, hum, head, rootPart
end

local function ProjectPart(part)
	local p, onScreen = Camera:WorldToViewportPoint(part.Position)
	return Vector2.new(p.X, p.Y), p.Z, onScreen and p.Z > 0
end

local function GetOrCreateSkeletonLine(data, index)
	local line = data.skeletonLines[index]
	if not line or not line.Parent then
		line = New("Frame", {
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Visible = false,
			ZIndex = 48,
		}, data.root)
		data.skeletonLines[index] = line
	end
	return line
end

local function UpdateESP()
	for player, data in pairs(ESPObjects) do
		local char, hum, head, rootPart = GetCharacterParts(player)

		if not char or (Config.TeamCheck and SameTeam(LocalPlayer, player)) then
			data.root.Visible = false
			for _, line in pairs(data.skeletonLines) do
				if line then
					line.Visible = false
				end
			end
			continue
		end

		local headPos, _, headVisible = ProjectPart(head)
		local rootPos, _, rootVisible = ProjectPart(rootPart)

		if not headVisible and not rootVisible then
			data.root.Visible = false
			for _, line in pairs(data.skeletonLines) do
				if line then
					line.Visible = false
				end
			end
			continue
		end

		local height = math.clamp(math.abs(rootPos.Y - headPos.Y) * 1.35, 28, 520)
		local width = math.clamp(height * 0.55, 18, 280)
		local topY = headPos.Y - height * 0.15
		local leftX = rootPos.X - width / 2

		data.root.Position = UDim2.fromOffset(leftX, topY)
		data.root.Size = UDim2.fromOffset(width, height)
		data.root.Visible = true

		-- BOX
		data.box.Position = UDim2.fromOffset(0, 0)
		data.box.Size = UDim2.fromOffset(width, height)
		data.box.Visible = Config.ESPBox

		-- HEALTH
		data.hpBack.Position = UDim2.fromOffset(-8, 0)
		data.hpBack.Size = UDim2.fromOffset(4, height)
		data.hpBack.Visible = Config.ESPHealth

		local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
		data.hpFill.Size = UDim2.new(1, 0, hp, 0)
		if hp > 0.6 then
			data.hpFill.BackgroundColor3 = Theme.Green
		elseif hp > 0.3 then
			data.hpFill.BackgroundColor3 = Theme.Yellow
		else
			data.hpFill.BackgroundColor3 = Theme.Red
		end

		-- NAME
		data.name.Visible = Config.ESPName
		data.name.Text = player.DisplayName

		-- DISTANCE
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			data.distance.Text = string.format("%dm", math.floor((myRoot.Position - rootPart.Position).Magnitude))
		else
			data.distance.Text = ""
		end
		data.distance.Visible = Config.ESPDistance

		-- HEAD DOT
		data.headDot.Position = UDim2.fromOffset(headPos.X - leftX, headPos.Y - topY)
		data.headDot.Visible = Config.ESPHeadDot

		-- TRACER
		if Config.ESPTracer then
			local viewport = Camera.ViewportSize
			local start = Vector2.new(viewport.X / 2, viewport.Y)
			local delta = rootPos - start
			data.tracer.Position = UDim2.fromOffset(start.X - leftX, start.Y - topY)
			data.tracer.Size = UDim2.fromOffset(delta.Magnitude, 1.5)
			data.tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			data.tracer.Visible = true
		else
			data.tracer.Visible = false
		end

		-- SKELETON
		if Config.ESPSkeleton then
			local lineIndex = 0
			for _, pair in ipairs(SKELETON_CONNECTIONS) do
				local p1 = char:FindFirstChild(pair[1])
				local p2 = char:FindFirstChild(pair[2])
				if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
					local pos1, _, vis1 = ProjectPart(p1)
					local pos2, _, vis2 = ProjectPart(p2)
					if vis1 or vis2 then
						lineIndex += 1
						local line = GetOrCreateSkeletonLine(data, lineIndex)
						local delta = pos2 - pos1
						local length = delta.Magnitude
						if length > 1 then
							line.Position = UDim2.fromOffset(pos1.X - leftX, pos1.Y - topY)
							line.Size = UDim2.fromOffset(length, 1.5)
							line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
							line.Visible = true
						else
							line.Visible = false
						end
					end
				end
			end
			-- esconde linhas extras
			for i = lineIndex + 1, #data.skeletonLines do
				if data.skeletonLines[i] then
					data.skeletonLines[i].Visible = false
				end
			end
		else
			for _, line in pairs(data.skeletonLines) do
				if line then
					line.Visible = false
				end
			end
		end
	end
end

--==================================================
-- AIMBOT
--==================================================
local function IsAimKeyDown()
	return UIS:IsKeyDown(Config.AimKey)
end

local function GetClosestTarget()
	local mousePos = UIS:GetMouseLocation()
	local bestPlayer = nil
	local bestDist = Config.FOV

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char, hum, head = GetCharacterParts(player)
			if char and head and not (Config.TeamCheck and SameTeam(LocalPlayer, player)) then
				local screen, depth, visible = ProjectPart(head)
				if visible and depth > 0 then
					local dist = (screen - mousePos).Magnitude
					if dist <= bestDist then
						bestDist = dist
						bestPlayer = player
					end
				end
			end
		end
	end
	return bestPlayer
end

local function UpdateAim()
	if not Config.AimEnabled or not IsAimKeyDown() then
		return
	end

	local target = GetClosestTarget()
	if not target then
		return
	end

	local _, _, head = GetCharacterParts(target)
	if not head then
		return
	end

	local camPos = Camera.CFrame.Position
	local targetCF = CFrame.lookAt(camPos, head.Position)
	local alpha = math.clamp(1 / math.max(Config.Smooth, 1), 0.015, 1)
	Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
end

--==================================================
-- SPEED
--==================================================
local function UpdateSpeed()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Config.SpeedEnabled and Config.Speed or 16
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.4)
	UpdateSpeed()
end)

--==================================================
-- LOOP
--==================================================
RunService.RenderStepped:Connect(function()
	UpdateESP()
	UpdateAim()
	UpdateSpeed()
end)

print("[TORO] v6 carregado — menu, aimbot, ESP Box/Health/Skeleton corrigidos.")
