--========================================================--
--                    TORO PANEL V4                       --
--        Roblox Studio - LocalScript / Own Game          --
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================--
-- CONFIG
--========================================================--

local CFG = {
    Theme = Color3.fromRGB(255, 55, 125),

    Aim = false,
    AimFOV = 120,
    Smooth = 0.18,
    AimKey = Enum.KeyCode.Q,

    Box = true,
    Health = true,
    Name = true,
    Distance = true,
    Tracer = false,
    HeadDot = false,
    Skeleton = false,
    TeamCheck = false,

    Speed = false,
    WalkSpeed = 16,

    Jump = false,
    JumpPower = 50,
}

--========================================================--
-- GUI
--========================================================--

local GUI = Instance.new("ScreenGui")
GUI.Name = "TORO_PANEL"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = LP:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(760, 500)
Main.Position = UDim2.new(.5, -380, .5, -250)
Main.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
Main.BorderSizePixel = 0
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(40, 40, 48)
Stroke.Thickness = 1
Stroke.Parent = Main

--========================================================--
-- TOP
--========================================================--

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 62)
Top.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
Top.BorderSizePixel = 0
Top.Parent = Main

Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.fromOffset(180, 30)
Logo.Position = UDim2.fromOffset(22, 10)
Logo.BackgroundTransparency = 1
Logo.Text = "TORO"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 24
Logo.TextColor3 = CFG.Theme
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = Top

local Version = Instance.new("TextLabel")
Version.Size = UDim2.fromOffset(150, 18)
Version.Position = UDim2.fromOffset(24, 37)
Version.BackgroundTransparency = 1
Version.Text = "CONTROL PANEL  •  V4"
Version.Font = Enum.Font.Gotham
Version.TextSize = 9
Version.TextColor3 = Color3.fromRGB(110, 110, 120)
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Top

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 170, 1, -62)
Sidebar.Position = UDim2.fromOffset(0, 62)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 17, 21)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, -20, 1, -25)
TabHolder.Position = UDim2.fromOffset(10, 15)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabHolder

local Tabs = {}
local Pages = {}

local function CreatePage()
    local P = Instance.new("ScrollingFrame")
    P.Size = UDim2.new(1, -20, 1, -20)
    P.Position = UDim2.fromOffset(10, 10)
    P.BackgroundTransparency = 1
    P.BorderSizePixel = 0
    P.ScrollBarThickness = 3
    P.ScrollBarImageColor3 = CFG.Theme
    P.CanvasSize = UDim2.new(0, 0, 0, 0)
    P.Visible = false
    P.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 9)
    Layout.Parent = P

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        P.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 20)
    end)

    table.insert(Pages, P)

    return P
end

local function CreateTab(Name, Icon, Page)

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 42)
    B.BackgroundColor3 = Color3.fromRGB(16, 17, 21)
    B.BorderSizePixel = 0
    B.Text = "   "..Icon.."   "..Name
    B.Font = Enum.Font.GothamMedium
    B.TextSize = 12
    B.TextColor3 = Color3.fromRGB(145,145,155)
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.AutoButtonColor = false
    B.Parent = TabHolder

    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 7)

    Tabs[B] = Page

    B.MouseButton1Click:Connect(function()

        for Button, OtherPage in pairs(Tabs) do
            Button.BackgroundColor3 = Color3.fromRGB(16,17,21)
            Button.TextColor3 = Color3.fromRGB(145,145,155)
            OtherPage.Visible = false
        end

        B.BackgroundColor3 = Color3.fromRGB(45,25,35)
        B.TextColor3 = CFG.Theme
        Page.Visible = true
    end)

    return B
end

--========================================================--
-- PAGES
--========================================================--

local Combat = CreatePage()
local Visuals = CreatePage()
local PlayerPage = CreatePage()
local ConfigPage = CreatePage()

local CombatTab = CreateTab("Combat","◈",Combat)
local VisualTab = CreateTab("Visuals","□",Visuals)
local PlayerTab = CreateTab("Player","●",PlayerPage)
local ConfigTab = CreateTab("Config","⚙",ConfigPage)

Combat.Visible = true
CombatTab.BackgroundColor3 = Color3.fromRGB(45,25,35)
CombatTab.TextColor3 = CFG.Theme

--========================================================--
-- COMPONENTS
--========================================================--

local function Header(Page, Text)

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,-10,0,28)
    L.BackgroundTransparency = 1
    L.Text = Text
    L.TextColor3 = Color3.fromRGB(235,235,240)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 15
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Page

end

local function Toggle(Page, Text, Default, Callback)

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,-10,0,45)
    B.BackgroundColor3 = Color3.fromRGB(22,23,29)
    B.BorderSizePixel = 0
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = Page

    Instance.new("UICorner",B).CornerRadius = UDim.new(0,8)

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,-80,1,0)
    L.Position = UDim2.fromOffset(14,0)
    L.BackgroundTransparency = 1
    L.Text = Text
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 12
    L.TextColor3 = Color3.fromRGB(215,215,220)
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = B

    local State = Default

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(38,20)
    Indicator.Position = UDim2.new(1,-52,.5,-10)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = B

    Instance.new("UICorner",Indicator).CornerRadius = UDim.new(1,0)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.fromOffset(14,14)
    Dot.Position = UDim2.fromOffset(3,3)
    Dot.BorderSizePixel = 0
    Dot.Parent = Indicator

    Instance.new("UICorner",Dot).CornerRadius = UDim.new(1,0)

    local function Update()

        if State then
            Indicator.BackgroundColor3 = CFG.Theme
            Dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Dot.Position = UDim2.fromOffset(21,3)
        else
            Indicator.BackgroundColor3 = Color3.fromRGB(48,49,57)
            Dot.BackgroundColor3 = Color3.fromRGB(130,130,140)
            Dot.Position = UDim2.fromOffset(3,3)
        end

        Callback(State)
    end

    B.MouseButton1Click:Connect(function()
        State = not State
        Update()
    end)

    Update()

    return B
end

local function Slider(Page, Text, Min, Max, Default, Callback)

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1,-10,0,68)
    Box.BackgroundColor3 = Color3.fromRGB(22,23,29)
    Box.BorderSizePixel = 0
    Box.Parent = Page

    Instance.new("UICorner",Box).CornerRadius = UDim.new(0,8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,-90,0,25)
    Label.Position = UDim2.fromOffset(14,7)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(215,215,220)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Box

    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.fromOffset(70,25)
    Value.Position = UDim2.new(1,-84,0,7)
    Value.BackgroundTransparency = 1
    Value.TextColor3 = CFG.Theme
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 11
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Box

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1,-30,0,6)
    Track.Position = UDim2.fromOffset(15,46)
    Track.BackgroundColor3 = Color3.fromRGB(48,49,57)
    Track.BorderSizePixel = 0
    Track.Parent = Box

    Instance.new("UICorner",Track).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame")
    Fill.BorderSizePixel = 0
    Fill.BackgroundColor3 = CFG.Theme
    Fill.Size = UDim2.new(0,0,1,0)
    Fill.Parent = Track

    Instance.new("UICorner",Fill).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(14,14)
    Knob.AnchorPoint = Vector2.new(.5,.5)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track

    Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

    local Dragging = false

    local function SetValue(X)

        local Ratio = math.clamp(
            (X - Track.AbsolutePosition.X) /
            Track.AbsoluteSize.X,
            0,1
        )

        local Number = Min + ((Max-Min)*Ratio)

        if (Max-Min) >= 10 then
            Number = math.floor(Number)
        else
            Number = math.floor(Number*100)/100
        end

        Fill.Size = UDim2.new(Ratio,0,1,0)
        Knob.Position = UDim2.new(Ratio,0,.5,0)

        Value.Text = tostring(Number)

        Callback(Number)
    end

    Track.InputBegan:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            SetValue(Input.Position.X)
        end

    end)

    UIS.InputChanged:Connect(function(Input)

        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            SetValue(Input.Position.X)
        end

    end)

    UIS.InputEnded:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end

    end)

    task.defer(function()
        local Ratio = (Default-Min)/(Max-Min)
        Fill.Size = UDim2.new(Ratio,0,1,0)
        Knob.Position = UDim2.new(Ratio,0,.5,0)
        Value.Text = tostring(Default)
    end)

    return Box
end

local function Keybind(Page, Text, Default, Callback)

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,-10,0,45)
    B.BackgroundColor3 = Color3.fromRGB(22,23,29)
    B.BorderSizePixel = 0
    B.Text = ""
    B.Parent = Page

    Instance.new("UICorner",B).CornerRadius = UDim.new(0,8)

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,-120,1,0)
    L.Position = UDim2.fromOffset(14,0)
    L.BackgroundTransparency = 1
    L.Text = Text
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 12
    L.TextColor3 = Color3.fromRGB(215,215,220)
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = B

    local Key = Instance.new("TextLabel")
    Key.Size = UDim2.fromOffset(90,27)
    Key.Position = UDim2.new(1,-103,.5,-13)
    Key.BackgroundColor3 = Color3.fromRGB(43,44,52)
    Key.Text = Default.Name
    Key.TextColor3 = CFG.Theme
    Key.Font = Enum.Font.GothamBold
    Key.TextSize = 10
    Key.Parent = B

    Instance.new("UICorner",Key).CornerRadius = UDim.new(0,6)

    local Waiting = false

    B.MouseButton1Click:Connect(function()
        Waiting = true
        Key.Text = "PRESS KEY"
    end)

    UIS.InputBegan:Connect(function(Input)

        if not Waiting then return end

        if Input.UserInputType == Enum.UserInputType.Keyboard then
            Waiting = false
            Key.Text = Input.KeyCode.Name
            Callback(Input.KeyCode)
        end

    end)

end

--========================================================--
-- COMBAT
--========================================================--

Header(Combat,"COMBAT")

Toggle(Combat,"Aim Assist",CFG.Aim,function(v)
    CFG.Aim = v
end)

Slider(Combat,"FOV",20,300,CFG.AimFOV,function(v)
    CFG.AimFOV = v
end)

Slider(Combat,"Smoothness",0.01,1,CFG.Smooth,function(v)
    CFG.Smooth = v
end)

Keybind(Combat,"Aim Key",CFG.AimKey,function(Key)
    CFG.AimKey = Key
end)

--========================================================--
-- VISUALS
--========================================================--

Header(Visuals,"ESP")

Toggle(Visuals,"Box ESP",CFG.Box,function(v)
    CFG.Box = v
end)

Toggle(Visuals,"Health Bar",CFG.Health,function(v)
    CFG.Health = v
end)

Toggle(Visuals,"Player Name",CFG.Name,function(v)
    CFG.Name = v
end)

Toggle(Visuals,"Distance",CFG.Distance,function(v)
    CFG.Distance = v
end)

Toggle(Visuals,"Tracer",CFG.Tracer,function(v)
    CFG.Tracer = v
end)

Toggle(Visuals,"Head Dot",CFG.HeadDot,function(v)
    CFG.HeadDot = v
end)

Toggle(Visuals,"Skeleton",CFG.Skeleton,function(v)
    CFG.Skeleton = v
end)

Toggle(Visuals,"Team Check",CFG.TeamCheck,function(v)
    CFG.TeamCheck = v
end)

--========================================================--
-- PLAYER
--========================================================--

Header(PlayerPage,"PLAYER")

Toggle(PlayerPage,"Custom WalkSpeed",CFG.Speed,function(v)

    CFG.Speed = v

    local Char = LP.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

    if Hum then
        Hum.WalkSpeed = v and CFG.WalkSpeed or 16
    end

end)

Slider(PlayerPage,"WalkSpeed",16,100,CFG.WalkSpeed,function(v)

    CFG.WalkSpeed = v

    if CFG.Speed then

        local Char = LP.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

        if Hum then
            Hum.WalkSpeed = v
        end

    end

end)

Toggle(PlayerPage,"Custom JumpPower",CFG.Jump,function(v)

    CFG.Jump = v

    local Char = LP.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

    if Hum then
        Hum.UseJumpPower = true
        Hum.JumpPower = v and CFG.JumpPower or 50
    end

end)

Slider(PlayerPage,"JumpPower",50,120,CFG.JumpPower,function(v)

    CFG.JumpPower = v

    if CFG.Jump then

        local Char = LP.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

        if Hum then
            Hum.UseJumpPower = true
            Hum.JumpPower = v
        end

    end

end)

--========================================================--
-- CONFIG
--========================================================--

Header(ConfigPage,"THEME")

local Themes = {
    {"Pink",Color3.fromRGB(255,55,125)},
    {"Red",Color3.fromRGB(255,65,65)},
    {"Purple",Color3.fromRGB(170,80,255)},
    {"Blue",Color3.fromRGB(70,140,255)},
    {"Green",Color3.fromRGB(50,220,130)},
    {"Orange",Color3.fromRGB(255,145,50)}
}

for _,Data in ipairs(Themes) do

    local Name = Data[1]
    local Color = Data[2]

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,-10,0,42)
    B.BackgroundColor3 = Color3.fromRGB(22,23,29)
    B.BorderSizePixel = 0
    B.Text = Name
    B.TextColor3 = Color
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    B.Parent = ConfigPage

    Instance.new("UICorner",B).CornerRadius = UDim.new(0,8)

    B.MouseButton1Click:Connect(function()

        CFG.Theme = Color

        Logo.TextColor3 = Color

        for Button in pairs(Tabs) do
            Button.TextColor3 = Color3.fromRGB(145,145,155)
        end

        CombatTab.TextColor3 = Color

    end)

end

--========================================================--
-- DRAG
--========================================================--

local Dragging = false
local DragStart
local StartPos

Top.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then

        Dragging = true
        DragStart = Input.Position
        StartPos = Main.Position

    end

end)

UIS.InputChanged:Connect(function(Input)

    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )

    end

end)

UIS.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end

end)

--========================================================--
-- INSERT
--========================================================--

local Open = true

UIS.InputBegan:Connect(function(Input,Processed)

    if Processed then return end

    if Input.KeyCode == Enum.KeyCode.Insert then

        Open = not Open
        Main.Visible = Open

    end

end)

--========================================================--
-- BASIC AIM ASSIST
--========================================================--

local function GetTarget()

    local Mouse = UIS:GetMouseLocation()

    local Best = nil
    local BestDistance = CFG.AimFOV

    for _,Player in ipairs(Players:GetPlayers()) do

        if Player ~= LP then

            if CFG.TeamCheck and Player.Team == LP.Team then
                continue
            end

            local Char = Player.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

            if Root and Hum and Hum.Health > 0 then

                local Pos,Visible =
                    Camera:WorldToViewportPoint(Root.Position)

                if Visible then

                    local Distance =
                        (
                            Vector2.new(Pos.X,Pos.Y) -
                            Vector2.new(Mouse.X,Mouse.Y)
                        ).Magnitude

                    if Distance < BestDistance then
                        BestDistance = Distance
                        Best = Root
                    end

                end

            end

        end

    end

    return Best
end

RunService.RenderStepped:Connect(function()

    if not CFG.Aim then return end

    if not UIS:IsKeyDown(CFG.AimKey) then return end

    local Target = GetTarget()

    if Target then

        local Goal =
            CFrame.lookAt(
                Camera.CFrame.Position,
                Target.Position
            )

        Camera.CFrame =
            Camera.CFrame:Lerp(
                Goal,
                CFG.Smooth
            )

    end

end)

--========================================================--
-- ESP
--========================================================--

local ESP = {}

local function RemoveESP(Player)

    local Data = ESP[Player]

    if Data then

        for _,Obj in pairs(Data) do

            if typeof(Obj) == "Instance" then
                Obj:Destroy()
            end

        end

        ESP[Player] = nil

    end

end

local function CreateESP(Player)

    if Player == LP then return end
    if ESP[Player] then return end

    local Data = {}

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "TORO_ESP"
    Billboard.Size = UDim2.fromOffset(90,120)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false
    Billboard.Parent = GUI

    Data.Billboard = Billboard

    -- BOX
    local Box = Instance.new("Frame")
    Box.Size = UDim2.fromScale(1,1)
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 2
    Box.BorderColor3 = CFG.Theme
    Box.Parent = Billboard

    Data.Box = Box

    -- HEALTH BACKGROUND
    local HealthBG = Instance.new("Frame")
    HealthBG.Size = UDim2.fromOffset(5,120)
    HealthBG.Position = UDim2.fromOffset(-9,0)
    HealthBG.BackgroundColor3 = Color3.fromRGB(35,35,40)
    HealthBG.BorderSizePixel = 0
    HealthBG.Parent = Billboard

    local Health = Instance.new("Frame")
    Health.AnchorPoint = Vector2.new(0,1)
    Health.Position = UDim2.new(0,0,1,0)
    Health.Size = UDim2.new(1,0,1,0)
    Health.BackgroundColor3 = Color3.fromRGB(60,220,100)
    Health.BorderSizePixel = 0
    Health.Parent = HealthBG

    Data.HealthBG = HealthBG
    Data.Health = Health

    -- NAME
    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1,0,0,18)
    Name.Position = UDim2.fromOffset(0,-21)
    Name.BackgroundTransparency = 1
    Name.TextColor3 = Color3.fromRGB(255,255,255)
    Name.TextStrokeTransparency = .5
    Name.Font = Enum.Font.GothamBold
    Name.TextSize = 10
    Name.Parent = Billboard

    Data.Name = Name

    -- DISTANCE
    local Distance = Instance.new("TextLabel")
    Distance.Size = UDim2.new(1,0,0,16)
    Distance.Position = UDim2.new(0,0,1,2)
    Distance.BackgroundTransparency = 1
    Distance.TextColor3 = Color3.fromRGB(180,180,190)
    Distance.Font = Enum.Font.Gotham
    Distance.TextSize = 9
    Distance.Parent = Billboard

    Data.Distance = Distance

    ESP[Player] = Data
end

for _,Player in ipairs(Players:GetPlayers()) do
    CreateESP(Player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()

    for Player,Data in pairs(ESP) do

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

        if not Root or not Hum or Hum.Health <= 0 then

            Data.Billboard.Enabled = false

        elseif CFG.TeamCheck and Player.Team == LP.Team then

            Data.Billboard.Enabled = false

        else

            local Pos,Visible =
                Camera:WorldToViewportPoint(Root.Position)

            Data.Billboard.Enabled = Visible

            if Visible then

                Data.Billboard.Position =
                    UDim2.fromOffset(
                        Pos.X - 45,
                        Pos.Y - 60
                    )

                Data.Box.Visible = CFG.Box
                Data.HealthBG.Visible = CFG.Health
                Data.Name.Visible = CFG.Name
                Data.Distance.Visible = CFG.Distance

                Data.Name.Text = Player.DisplayName

                local Distance =
                    (Camera.CFrame.Position - Root.Position).Magnitude

                Data.Distance.Text =
                    math.floor(Distance).." studs"

                local HP =
                    math.clamp(
                        Hum.Health / Hum.MaxHealth,
                        0,1
                    )

                Data.Health.Size =
                    UDim2.new(1,0,HP,0)

                Data.Box.BorderColor3 = CFG.Theme

            end

        end

    end

end)

print("TORO PANEL V4 carregado.")
