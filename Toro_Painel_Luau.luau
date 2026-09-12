from pathlib import Path

code = r'''--// TORO PANEL - versão corrigida
--// Use como LocalScript em StarterPlayer > StarterPlayerScripts
--// Feito para testar no seu próprio jogo Roblox.
--//
--// Correções principais:
--// 1) Drag usa UserInputService/InputChanged corretamente.
--// 2) Sliders de FOV e Smoothness respondem ao mouse inteiro.
--// 3) Health Bar é desenhada em ScreenGui e acompanha o personagem.
--// 4) ESP Box usa WorldToViewportPoint, então fica realmente na tela.
--// 5) FOV é aplicado ao cálculo do alvo.
--// 6) Smoothness é aplicado ao movimento da câmera.
--// 7) Insert mostra/esconde o painel.

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
    AccentDark = Color3.fromRGB(190, 40, 110),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(145, 145, 155),
    Stroke = Color3.fromRGB(45, 45, 55),
    Green = Color3.fromRGB(80, 220, 130),
    Red = Color3.fromRGB(240, 80, 90),
}

--==================================================
-- HELPERS
--==================================================

local function New(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, parent)
end

local function Label(parent, text, size, pos, textSize, color)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Size = size,
        Position = pos,
        Text = text,
        TextColor3 = color or Theme.Text,
        TextSize = textSize or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function SetText(label, text)
    if label and label.Parent then
        label.Text = text
    end
end

--==================================================
-- GUI
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

local Top = New("Frame", {
    Name = "Top",
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1,
    Active = true,
}, Main)

local Title = Label(
    Top,
    "TORO",
    UDim2.fromOffset(180, 30),
    UDim2.fromOffset(22, 9),
    22,
    Theme.Text
)
Title.Font = Enum.Font.GothamBold

local SubTitle = Label(
    Top,
    "CONTROL PANEL",
    UDim2.fromOffset(180, 20),
    UDim2.fromOffset(23, 32),
    10,
    Theme.SubText
)

local StatusDot = New("Frame", {
    Size = UDim2.fromOffset(8, 8),
    Position = UDim2.new(1, -100, 0, 25),
    BackgroundColor3 = Theme.Green,
    BorderSizePixel = 0,
}, Top)
Corner(StatusDot, 10)

local StatusText = Label(
    Top,
    "ONLINE",
    UDim2.fromOffset(65, 20),
    UDim2.new(1, -87, 0, 19),
    10,
    Theme.SubText
)
StatusText.TextXAlignment = Enum.TextXAlignment.Right

-- Sidebar
local Sidebar = New("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 175, 1, -58),
    Position = UDim2.fromOffset(0, 58),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
}, Main)

local SideList = New("UIListLayout", {
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
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, Content)

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
        for tabName, data in pairs(TabButtons) do
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

    TabButtons[name] = {
        button = b,
        accent = accent,
        text = txt
    }

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
-- CONTROLS
--==================================================

local function Section(parent, title)
    local holder = New("Frame", {
        Size = UDim2.new(1, -5, 0, 40),
        BackgroundTransparency = 1,
    }, parent)

    Label(holder, title, UDim2.new(1, 0, 1, 0), UDim2.fromOffset(2, 0), 12, Theme.SubText).Font =
        Enum.Font.GothamBold

    return holder
end

local function Toggle(parent, title, initial, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, -5, 0, 48),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
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
        callback(state)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()
    return row
end

-- Robust slider: click or drag anywhere on the track.
local function Slider(parent, title, minValue, maxValue, initial, decimals, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, -5, 0, 70),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Active = true,
    }, parent)
    Corner(row, 8)

    local titleLabel = Label(
        row,
        title,
        UDim2.new(1, -90, 0, 25),
        UDim2.fromOffset(14, 5),
        13,
        Theme.Text
    )

    local valueLabel = Label(
        row,
        "",
        UDim2.fromOffset(70, 25),
        UDim2.new(1, -84, 0, 5),
        12,
        Theme.Accent
    )
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
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Active = false,
    }, track)
    Corner(fill, 8)

    local knob = New("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Active = false,
    }, track)
    Corner(knob, 20)

    -- Transparent hit area makes the slider much easier to grab.
    local hit = New("TextButton", {
        Size = UDim2.new(1, 18, 0, 30),
        Position = UDim2.fromOffset(-9, 32),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        Active = true,
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

    local function setFromX(x)
        local left = track.AbsolutePosition.X
        local width = math.max(track.AbsoluteSize.X, 1)
        local alpha = math.clamp((x - left) / width, 0, 1)

        value = roundValue(minValue + (maxValue - minValue) * alpha)

        local a = math.clamp(
            (value - minValue) / math.max(maxValue - minValue, 0.0001),
            0,
            1
        )

        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)

        if decimals == 0 then
            valueLabel.Text = tostring(value)
        else
            valueLabel.Text = string.format("%." .. decimals .. "f", value)
        end

        callback(value)
    end

    hit.MouseButton1Down:Connect(function(x)
        dragging = true
        setFromX(x)
    end)

    hit.MouseButton1Up:Connect(function()
        dragging = false
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

    task.defer(function()
        setFromX(track.AbsolutePosition.X + track.AbsoluteSize.X * 0.5)
        value = initial
        local a = (initial - minValue) / math.max(maxValue - minValue, 0.0001)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        if decimals == 0 then
            valueLabel.Text = tostring(initial)
        else
            valueLabel.Text = string.format("%." .. decimals .. "f", initial)
        end
        callback(initial)
    end)

    return row
end

local function Keybind(parent, title, initial, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, -5, 0, 48),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
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
        if not waiting then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        waiting = false
        Config.AimKey = input.KeyCode
        keyButton.Text = input.KeyCode.Name
        keyButton.TextColor3 = Theme.Text
        callback(input.KeyCode)
    end)

    return row
end

local function Gap(parent, h)
    New("Frame", {
        Size = UDim2.new(1, 0, 0, h or 5),
        BackgroundTransparency = 1,
    }, parent)
end

--==================================================
-- COMBAT PAGE
--==================================================

Section(Combat, "AIM ASSIST")

Toggle(Combat, "Aim Assist", Config.AimEnabled, function(v)
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
-- VISUALS PAGE
--==================================================

Section(Visuals, "ESP")

Toggle(Visuals, "Box", Config.ESPBox, function(v)
    Config.ESPBox = v
end)

Toggle(Visuals, "Health Bar", Config.ESPHealth, function(v)
    Config.ESPHealth = v
end)

Toggle(Visuals, "Name", Config.ESPName, function(v)
    Config.ESPName = v
end)

Toggle(Visuals, "Distance", Config.ESPDistance, function(v)
    Config.ESPDistance = v
end)

Toggle(Visuals, "Tracer", Config.ESPTracer, function(v)
    Config.ESPTracer = v
end)

Toggle(Visuals, "Head Dot", Config.ESPHeadDot, function(v)
    Config.ESPHeadDot = v
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
    {"Pink", Color3.fromRGB(255, 70, 150)},
    {"Red", Color3.fromRGB(245, 70, 80)},
    {"Purple", Color3.fromRGB(155, 90, 255)},
    {"Blue", Color3.fromRGB(80, 145, 255)},
    {"Green", Color3.fromRGB(75, 215, 135)},
    {"Orange", Color3.fromRGB(255, 145, 65)},
}

local function ApplyAccent(color)
    Theme.Accent = color

    for _, data in pairs(TabButtons) do
        data.accent.BackgroundColor3 = Theme.Accent
    end

    StatusDot.BackgroundColor3 = Theme.Green

    for _, obj in ipairs(Gui:GetDescendants()) do
        if obj:IsA("Frame") and obj.Name == "Fill" then
            obj.BackgroundColor3 = Theme.Accent
        elseif obj:IsA("TextLabel") and obj.TextColor3 == Theme.Accent then
            obj.TextColor3 = Theme.Accent
        elseif obj:IsA("UIStroke") and obj.Color == Theme.Accent then
            obj.Color = Theme.Accent
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
    }, ConfigPage)
    Corner(b, 8)

    b.MouseButton1Click:Connect(function()
        ApplyAccent(color)
    end)
end

local insertInfo = New("TextLabel", {
    Size = UDim2.new(1, -5, 0, 48),
    BackgroundTransparency = 1,
    Text = "INSERT  •  mostrar / esconder menu",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
}, ConfigPage)

--==================================================
-- TAB INICIAL
--==================================================

TabButtons["Combat"].button:Activate()
TabButtons["Combat"].button.BackgroundColor3 = Theme.Card
TabButtons["Combat"].accent.Visible = true
TabButtons["Combat"].text.TextColor3 = Theme.Text
Combat.Visible = true
currentPage = "Combat"

--==================================================
-- DRAG CORRIGIDO
--==================================================

local draggingMenu = false
local dragStart = nil
local startPos = nil
local dragInput = nil

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
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingMenu = true
        dragStart = input.Position
        startPos = Main.Position

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragInput = Enum.UserInputType.MouseMovement
        else
            dragInput = Enum.UserInputType.Touch
        end
    end
end)

Top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input.UserInputType
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingMenu and input.UserInputType == dragInput then
        updateMenuDrag(input)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = false
        dragInput = nil
    end
end)

--==================================================
-- INSERT
--==================================================

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        Config.MenuVisible = not Config.MenuVisible
        Main.Visible = Config.MenuVisible
    end
end)

--==================================================
-- ESP SCREEN-SPACE
--==================================================

local ESPFolder = New("Folder", {
    Name = "ToroESP"
}, Gui)

local ESPObjects = {}

local function RemoveESP(player)
    local data = ESPObjects[player]
    if data then
        for _, obj in pairs(data) do
            if typeof(obj) == "Instance" and obj.Parent then
                obj:Destroy()
            end
        end
        ESPObjects[player] = nil
    end
end

local function MakeESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local root = New("Frame", {
        Name = player.Name,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(100, 100),
        Position = UDim2.fromOffset(0, 0),
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
        BackgroundColor3 = Theme.Green,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 53,
    }, hpBack)
    Corner(hpFill, 3)

    local name = Label(
        root,
        player.DisplayName,
        UDim2.fromOffset(250, 20),
        UDim2.fromOffset(-75, -25),
        12,
        Theme.Text
    )
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.ZIndex = 54

    local distance = Label(
        root,
        "",
        UDim2.fromOffset(250, 18),
        UDim2.fromOffset(-75, 4),
        10,
        Theme.SubText
    )
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

    ESPObjects[player] = {
        root = root,
        box = box,
        hpBack = hpBack,
        hpFill = hpFill,
        name = name,
        distance = distance,
        tracer = tracer,
        headDot = headDot,
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

    if a.Team ~= nil and b.Team ~= nil then
        return a.Team == b.Team
    end

    return false
end

local function GetCharacterParts(player)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if not hum or not head or not rootPart then
        return
    end

    if hum.Health <= 0 then
        return
    end

    return char, hum, head, rootPart
end

local function ProjectPart(part)
    local p, visible = Camera:WorldToViewportPoint(part.Position)
    return Vector2.new(p.X, p.Y), p.Z, visible
end

local function UpdateESP()
    for player, data in pairs(ESPObjects) do
        local char, hum, head, rootPart = GetCharacterParts(player)

        local shouldShow = true
        if Config.TeamCheck and SameTeam(LocalPlayer, player) then
            shouldShow = false
        end

        if not char or not shouldShow then
            data.root.Visible = false
            continue
        end

        local headPos, headZ, headVisible = ProjectPart(head)
        local rootPos, rootZ, rootVisible = ProjectPart(rootPart)

        if not headVisible and not rootVisible then
            data.root.Visible = false
            continue
        end

        local height = math.abs(rootPos.Y - headPos.Y) * 1.25
        height = math.clamp(height, 30, 500)

        local width = math.clamp(height * 0.55, 20, 280)

        local topY = headPos.Y - height * 0.12
        local leftX = rootPos.X - width / 2

        data.root.Position = UDim2.fromOffset(leftX, topY)
        data.root.Size = UDim2.fromOffset(width, height)
        data.root.Visible = true

        -- BOX
        data.box.Position = UDim2.fromOffset(0, 0)
        data.box.Size = UDim2.fromOffset(width, height)
        data.box.Visible = Config.ESPBox

        -- HEALTH BAR
        data.hpBack.Position = UDim2.fromOffset(-7, 0)
        data.hpBack.Size = UDim2.fromOffset(4, height)
        data.hpBack.Visible = Config.ESPHealth

        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        data.hpFill.Size = UDim2.new(1, 0, hp, 0)

        if hp > 0.6 then
            data.hpFill.BackgroundColor3 = Theme.Green
        elseif hp > 0.3 then
            data.hpFill.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
        else
            data.hpFill.BackgroundColor3 = Theme.Red
        end

        -- NAME
        data.name.Visible = Config.ESPName
        data.name.Text = player.DisplayName

        -- DISTANCE
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local d = (myRoot.Position - rootPart.Position).Magnitude
            data.distance.Text = string.format("%dm", math.floor(d))
        else
            data.distance.Text = ""
        end
        data.distance.Visible = Config.ESPDistance

        -- HEAD DOT
        data.headDot.Position = UDim2.fromOffset(
            headPos.X - leftX,
            headPos.Y - topY
        )
        data.headDot.Visible = Config.ESPHeadDot

        -- TRACER
        if Config.ESPTracer then
            local viewport = Camera.ViewportSize
            local start = Vector2.new(viewport.X / 2, viewport.Y)
            local finish = rootPos

            local delta = finish - start
            local length = delta.Magnitude

            data.tracer.Position = UDim2.fromOffset(
                start.X - leftX,
                start.Y - topY
            )
            data.tracer.Size = UDim2.fromOffset(length, 1)
            data.tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
            data.tracer.Visible = true
        else
            data.tracer.Visible = false
        end
    end
end

--==================================================
-- AIM ASSIST - PARA TESTE NO PRÓPRIO JOGO
--==================================================

local function IsAimKeyDown()
    return UIS:IsKeyDown(Config.AimKey)
end

local function GetClosestTarget()
    local mousePos = UIS:GetMouseLocation()
    local bestPlayer = nil
    local bestDistance = Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char, hum, head = GetCharacterParts(player)

            if char and hum and head then
                if not (Config.TeamCheck and SameTeam(LocalPlayer, player)) then
                    local screen, depth, visible = ProjectPart(head)

                    if visible and depth > 0 then
                        local dist = (screen - mousePos).Magnitude

                        if dist <= bestDistance then
                            bestDistance = dist
                            bestPlayer = player
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

local function UpdateAim()
    if not Config.AimEnabled then
        return
    end

    if not IsAimKeyDown() then
        return
    end

    local target = GetClosestTarget()
    if not target then
        return
    end

    local char, hum, head = GetCharacterParts(target)
    if not char or not head then
        return
    end

    local camPos = Camera.CFrame.Position
    local targetCFrame = CFrame.lookAt(camPos, head.Position)

    -- Quanto maior o Smooth, mais suave/lento.
    local alpha = math.clamp(1 / math.max(Config.Smooth, 1), 0.01, 1)

    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
end

--==================================================
-- SPEED
--==================================================

local function UpdateSpeed()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        if Config.SpeedEnabled then
            hum.WalkSpeed = Config.Speed
        else
            hum.WalkSpeed = 16
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateSpeed()
end)

--==================================================
-- RENDER LOOP
--==================================================

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateAim()
    UpdateSpeed()
end)

--==================================================
-- FINAL
--==================================================

print("[TORO] Panel carregado.")
print("[TORO] Drag, FOV, Smoothness e Health Bar corrigidos.")
'''
path = Path("/mnt/data/Toro_Panel_CORRIGIDO_v5.luau")
path.write_text(code, encoding="utf-8")
print(f"Arquivo criado: {path}")
