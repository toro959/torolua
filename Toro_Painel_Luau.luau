--==============================================================
-- TORO PANEL - Roblox Studio / LocalScript
-- Sistema de teste para o seu próprio jogo
--==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==============================================================
-- CONFIG
--==============================================================

local Config = {
    Aimbot = false,
    FOV = 120,
    Smoothness = 0.15,
    AimKey = Enum.KeyCode.Q,

    ESPBox = true,
    ESPHealth = true,

    Speed = false,
    WalkSpeed = 16,

    Theme = Color3.fromRGB(255, 45, 120)
}

--==============================================================
-- GUI
--==============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ToroPanel"
Gui.ResetOnSpawn = false
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(720, 460)
Main.Position = UDim2.new(0.5, -360, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

--==============================================================
-- TOP BAR
--==============================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 60)
Top.BackgroundColor3 = Color3.fromRGB(19, 19, 24)
Top.BorderSizePixel = 0
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "TORO"
Title.TextColor3 = Config.Theme
Title.TextSize = 25
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.fromOffset(300, 25)
Subtitle.Position = UDim2.fromOffset(20, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "CONTROL PANEL"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 130)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Top

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -60)
Sidebar.Position = UDim2.fromOffset(0, 60)
Sidebar.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local Tabs = {}

local function CreateTab(name, icon)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 42)
    Button.Position = UDim2.fromOffset(10, 10 + (#Tabs * 48))
    Button.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
    Button.BorderSizePixel = 0
    Button.Text = "  " .. icon .. "   " .. name
    Button.TextColor3 = Color3.fromRGB(150, 150, 160)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Sidebar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    table.insert(Tabs, Button)

    return Button
end

local CombatTab = CreateTab("Combat", "◈")
local VisualTab = CreateTab("Visuals", "□")
local LocalTab = CreateTab("Local", "●")
local ConfigTab = CreateTab("Config", "⚙")

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -60)
Content.Position = UDim2.fromOffset(150, 60)
Content.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Content.BorderSizePixel = 0
Content.Parent = Main

local Pages = {}

local function CreatePage()
    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, -30, 1, -30)
    Page.Position = UDim2.fromOffset(15, 15)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Content

    table.insert(Pages, Page)

    return Page
end

local CombatPage = CreatePage()
local VisualPage = CreatePage()
local LocalPage = CreatePage()
local ConfigPage = CreatePage()

local function ShowPage(Page, Button)
    for _, P in ipairs(Pages) do
        P.Visible = false
    end

    for _, B in ipairs(Tabs) do
        B.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
        B.TextColor3 = Color3.fromRGB(150, 150, 160)
    end

    Page.Visible = true
    Button.BackgroundColor3 = Color3.fromRGB(45, 25, 35)
    Button.TextColor3 = Config.Theme
end

CombatTab.MouseButton1Click:Connect(function()
    ShowPage(CombatPage, CombatTab)
end)

VisualTab.MouseButton1Click:Connect(function()
    ShowPage(VisualPage, VisualTab)
end)

LocalTab.MouseButton1Click:Connect(function()
    ShowPage(LocalPage, LocalTab)
end)

ConfigTab.MouseButton1Click:Connect(function()
    ShowPage(ConfigPage, ConfigTab)
end)

ShowPage(CombatPage, CombatTab)

--==============================================================
-- UI HELPERS
--==============================================================

local function CreateSection(Page, Text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(220, 220, 225)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Page

    return Label
end

local function CreateToggle(Page, Text, Y, Callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.Position = UDim2.fromOffset(5, Y)
    Button.BackgroundColor3 = Color3.fromRGB(23, 23, 29)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.Parent = Page

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(215, 215, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.fromOffset(45, 25)
    Status.Position = UDim2.new(1, -55, 0.5, -12)
    Status.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(130, 130, 140)
    Status.TextSize = 10
    Status.Font = Enum.Font.GothamBold
    Status.Parent = Button

    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = Status

    local Enabled = false

    Button.MouseButton1Click:Connect(function()
        Enabled = not Enabled

        if Enabled then
            Status.Text = "ON"
            Status.TextColor3 = Config.Theme
        else
            Status.Text = "OFF"
            Status.TextColor3 = Color3.fromRGB(130, 130, 140)
        end

        Callback(Enabled)
    end)

    return Button
end

local function CreateSlider(Page, Text, Y, Min, Max, Default, Callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 65)
    Container.Position = UDim2.fromOffset(5, Y)
    Container.BackgroundColor3 = Color3.fromRGB(23, 23, 29)
    Container.BorderSizePixel = 0
    Container.Parent = Page

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0, 25)
    Label.Position = UDim2.fromOffset(15, 5)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.fromOffset(60, 25)
    Value.Position = UDim2.new(1, -70, 5/65, 0)
    Value.BackgroundTransparency = 1
    Value.Text = tostring(Default)
    Value.TextColor3 = Config.Theme
    Value.TextSize = 12
    Value.Font = Enum.Font.GothamBold
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Container

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -30, 0, 5)
    Bar.Position = UDim2.fromOffset(15, 43)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    Bar.BorderSizePixel = 0
    Bar.Parent = Container

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Config.Theme
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Dragging = false

    local function Update(X)
        local Relative = math.clamp(
            (X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
            0,
            1
        )

        local Number = Min + ((Max - Min) * Relative)

        if Max - Min >= 10 then
            Number = math.floor(Number)
        else
            Number = math.floor(Number * 100) / 100
        end

        Fill.Size = UDim2.new(Relative, 0, 1, 0)
        Value.Text = tostring(Number)

        Callback(Number)
    end

    Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Update(Input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(Input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    return Container
end

--==============================================================
-- KEYBIND
--==============================================================

local function CreateKeybind(Page, Text, Y, Default, Callback)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.Position = UDim2.fromOffset(5, Y)
    Button.BackgroundColor3 = Color3.fromRGB(23, 23, 29)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.Parent = Page

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -110, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(215, 215, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.fromOffset(80, 28)
    KeyLabel.Position = UDim2.new(1, -90, 0.5, -14)
    KeyLabel.BackgroundColor3 = Color3.fromRGB(42, 42, 49)
    KeyLabel.Text = Default.Name
    KeyLabel.TextColor3 = Config.Theme
    KeyLabel.TextSize = 11
    KeyLabel.Font = Enum.Font.GothamBold
    KeyLabel.Parent = Button

    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 6)
    KeyCorner.Parent = KeyLabel

    local Waiting = false

    Button.MouseButton1Click:Connect(function()
        Waiting = true
        KeyLabel.Text = "PRESS KEY"
        KeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Waiting then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        Waiting = false

        Config.AimKey = Input.KeyCode

        KeyLabel.Text = Input.KeyCode.Name
        KeyLabel.TextColor3 = Config.Theme

        Callback(Input.KeyCode)
    end)

    return Button
end

--==============================================================
-- COMBAT PAGE
--==============================================================

CreateSection(CombatPage, "AIM ASSIST")

CreateToggle(
    CombatPage,
    "Aim Assist",
    35,
    function(Value)
        Config.Aimbot = Value
    end
)

CreateSlider(
    CombatPage,
    "FOV",
    85,
    20,
    300,
    Config.FOV,
    function(Value)
        Config.FOV = Value
    end
)

CreateSlider(
    CombatPage,
    "Smoothness",
    160,
    0.01,
    1,
    Config.Smoothness,
    function(Value)
        Config.Smoothness = Value
    end
)

CreateKeybind(
    CombatPage,
    "Aim Key",
    235,
    Config.AimKey,
    function(Key)
        Config.AimKey = Key
    end
)

--==============================================================
-- VISUAL PAGE
--==============================================================

CreateSection(VisualPage, "PLAYER ESP")

CreateToggle(
    VisualPage,
    "ESP Box",
    35,
    function(Value)
        Config.ESPBox = Value
    end
)

CreateToggle(
    VisualPage,
    "Health Bar",
    85,
    function(Value)
        Config.ESPHealth = Value
    end
)

--==============================================================
-- LOCAL PAGE
--==============================================================

CreateSection(LocalPage, "LOCAL PLAYER")

CreateToggle(
    LocalPage,
    "Custom Speed",
    35,
    function(Value)
        Config.Speed = Value

        if LocalPlayer.Character then
            local Humanoid =
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

            if Humanoid then
                Humanoid.WalkSpeed =
                    Value and Config.WalkSpeed or 16
            end
        end
    end
)

CreateSlider(
    LocalPage,
    "WalkSpeed",
    85,
    16,
    100,
    Config.WalkSpeed,
    function(Value)
        Config.WalkSpeed = Value

        if Config.Speed and LocalPlayer.Character then
            local Humanoid =
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

            if Humanoid then
                Humanoid.WalkSpeed = Value
            end
        end
    end
)

--==============================================================
-- CONFIG PAGE
--==============================================================

CreateSection(ConfigPage, "THEME")

local Colors = {
    Pink = Color3.fromRGB(255, 45, 120),
    Red = Color3.fromRGB(255, 65, 65),
    Purple = Color3.fromRGB(160, 80, 255),
    Blue = Color3.fromRGB(70, 140, 255),
    Green = Color3.fromRGB(50, 220, 130)
}

local Y = 35

for Name, Color in pairs(Colors) do

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 38)
    Button.Position = UDim2.fromOffset(5, Y)
    Button.BackgroundColor3 = Color3.fromRGB(23, 23, 29)
    Button.BorderSizePixel = 0
    Button.Text = Name
    Button.TextColor3 = Color
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ConfigPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()

        Config.Theme = Color

        Title.TextColor3 = Color

        for _, Tab in ipairs(Tabs) do
            Tab.TextColor3 = Color3.fromRGB(150, 150, 160)
        end

        CombatTab.TextColor3 = Color

    end)

    Y += 45
end

--==============================================================
-- ESP SYSTEM
--==============================================================

local ESPObjects = {}

local function CreateESP(Player)

    if Player == LocalPlayer then
        return
    end

    if ESPObjects[Player] then
        return
    end

    local Data = {}

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ToroESP"
    Billboard.Size = UDim2.fromOffset(80, 110)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = true
    Billboard.Parent = Gui

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1, 0, 1, 0)
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 2
    Box.BorderColor3 = Config.Theme
    Box.Parent = Billboard

    -- Barras laterais do Box para ficar visualmente mais claro
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 0, 0)
    TopLine.BackgroundColor3 = Config.Theme
    TopLine.BorderSizePixel = 0
    TopLine.Parent = Box

    local BottomLine = TopLine:Clone()
    BottomLine.Position = UDim2.new(0, 0, 1, -2)
    BottomLine.Parent = Box

    local LeftLine = TopLine:Clone()
    LeftLine.Size = UDim2.new(0, 2, 1, 0)
    LeftLine.Parent = Box

    local RightLine = LeftLine:Clone()
    RightLine.Position = UDim2.new(1, -2, 0, 0)
    RightLine.Parent = Box

    -- Health bar
    local HealthBackground = Instance.new("Frame")
    HealthBackground.Size = UDim2.fromOffset(5, 110)
    HealthBackground.Position = UDim2.fromOffset(-9, 0)
    HealthBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    HealthBackground.BorderSizePixel = 0
    HealthBackground.Parent = Billboard

    local HealthFill = Instance.new("Frame")
    HealthFill.AnchorPoint = Vector2.new(0, 1)
    HealthFill.Position = UDim2.new(0, 0, 1, 0)
    HealthFill.Size = UDim2.new(1, 0, 1, 0)
    HealthFill.BackgroundColor3 = Color3.fromRGB(60, 230, 110)
    HealthFill.BorderSizePixel = 0
    HealthFill.Parent = HealthBackground

    Data.Billboard = Billboard
    Data.Box = Box
    Data.HealthBackground = HealthBackground
    Data.HealthFill = HealthFill

    ESPObjects[Player] = Data
end

local function RemoveESP(Player)

    local Data = ESPObjects[Player]

    if Data then
        if Data.Billboard then
            Data.Billboard:Destroy()
        end

        ESPObjects[Player] = nil
    end
end

for _, Player in ipairs(Players:GetPlayers()) do
    CreateESP(Player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--==============================================================
-- ESP UPDATE
--==============================================================

RunService.RenderStepped:Connect(function()

    for Player, Data in pairs(ESPObjects) do

        local Character = Player.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if not Root or not Humanoid or Humanoid.Health <= 0 then

            Data.Billboard.Enabled = false

        else

            local Position, Visible =
                Camera:WorldToViewportPoint(Root.Position)

            if Visible then

                Data.Billboard.Enabled = true

                Data.Billboard.Position =
                    UDim2.fromOffset(
                        Position.X - 40,
                        Position.Y - 55
                    )

                Data.Box.Visible = Config.ESPBox

                Data.HealthBackground.Visible = Config.ESPHealth

                local HealthPercent =
                    math.clamp(
                        Humanoid.Health / Humanoid.MaxHealth,
                        0,
                        1
                    )

                Data.HealthFill.Size =
                    UDim2.new(
                        1,
                        0,
                        HealthPercent,
                        0
                    )

                Data.Box.BorderColor3 = Config.Theme
                Data.HealthFill.BackgroundColor3 =
                    Color3.fromRGB(
                        math.floor(255 * (1 - HealthPercent)),
                        math.floor(220 * HealthPercent),
                        70
                    )

            else

                Data.Billboard.Enabled = false

            end
        end
    end
end)

--==============================================================
-- AIM ASSIST
--==============================================================

local function GetClosestPlayer()

    local Closest = nil
    local ClosestDistance = Config.FOV

    local MousePosition =
        UserInputService:GetMouseLocation()

    for _, Player in ipairs(Players:GetPlayers()) do

        if Player ~= LocalPlayer then

            local Character = Player.Character
            local Root =
                Character and Character:FindFirstChild("HumanoidRootPart")

            local Humanoid =
                Character and Character:FindFirstChildOfClass("Humanoid")

            if Root and Humanoid and Humanoid.Health > 0 then

                local ScreenPosition, Visible =
                    Camera:WorldToViewportPoint(Root.Position)

                if Visible then

                    local Distance =
                        (
                            Vector2.new(
                                ScreenPosition.X,
                                ScreenPosition.Y
                            )
                            - MousePosition
                        ).Magnitude

                    if Distance < ClosestDistance then
                        ClosestDistance = Distance
                        Closest = Root
                    end
                end
            end
        end
    end

    return Closest
end

RunService.RenderStepped:Connect(function()

    if not Config.Aimbot then
        return
    end

    if not UserInputService:IsKeyDown(Config.AimKey) then
        return
    end

    local Target = GetClosestPlayer()

    if Target then

        local TargetCFrame =
            CFrame.lookAt(
                Camera.CFrame.Position,
                Target.Position
            )

        Camera.CFrame =
            Camera.CFrame:Lerp(
                TargetCFrame,
                Config.Smoothness
            )
    end
end)

--==============================================================
-- MENU TOGGLE
-- INSERT
--==============================================================

local MenuOpen = true

UserInputService.InputBegan:Connect(function(Input, Processed)

    if Processed then
        return
    end

    if Input.KeyCode == Enum.KeyCode.Insert then

        MenuOpen = not MenuOpen
        Main.Visible = MenuOpen

    end
end)

--==============================================================
-- DRAG MENU
--==============================================================

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if Dragging and
        Input.UserInputType == Enum.UserInputType.MouseMovement then

        local Delta = Input.Position - DragStart

        Main.Position =
            UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
    end
end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end

end)

print("[TORO] Panel carregado.")
