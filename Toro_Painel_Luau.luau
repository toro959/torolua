-- TORO - Painel de desenvolvimento/debug para Roblox
-- Coloque como LocalScript em StarterPlayerScripts.
-- Use apenas no seu próprio jogo.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ============================================================
-- ESTADO
-- ============================================================

local AimbotOn = false
local ShowFOV = false
local Smooth = 5
local FOVRadius = 100
local AimKey = Enum.UserInputType.MouseButton2
local TargetPart = "Head"

local ESPBox = false
local ESPSkeleton = false
local ESPHealth = false

local espObjects = {}
local skeletonObjects = {}

local function isEnemy(player)
    if player == LocalPlayer then
        return false
    end

    if not LocalPlayer.Team or not player.Team then
        return true
    end

    return LocalPlayer.Team ~= player.Team
end

-- ============================================================
-- GUI
-- ============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "Toro"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(650, 390)
main.Position = UDim2.new(0.5, -325, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(230, 0, 120)
stroke.Thickness = 1
stroke.Transparency = 0.25
stroke.Parent = main

-- arrastar janela
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- logo
local logo = Instance.new("TextLabel")
logo.BackgroundTransparency = 1
logo.Position = UDim2.fromOffset(18, 8)
logo.Size = UDim2.fromOffset(100, 42)
logo.Text = "TORO"
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 25
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.TextColor3 = Color3.fromRGB(245, 245, 245)
logo.Parent = main

local logoAccent = Instance.new("TextLabel")
logoAccent.BackgroundTransparency = 1
logoAccent.Position = UDim2.fromOffset(74, 8)
logoAccent.Size = UDim2.fromOffset(45, 42)
logoAccent.Text = "•"
logoAccent.Font = Enum.Font.GothamBlack
logoAccent.TextSize = 28
logoAccent.TextColor3 = Color3.fromRGB(255, 0, 130)
logoAccent.Parent = main

-- fechar
local close = Instance.new("TextButton")
close.BackgroundTransparency = 1
close.Position = UDim2.new(1, -38, 0, 8)
close.Size = UDim2.fromOffset(28, 28)
close.Text = "×"
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.TextColor3 = Color3.fromRGB(180, 180, 180)
close.Parent = main
close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- sidebar
local sidebar = Instance.new("Frame")
sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.fromOffset(8, 52)
sidebar.Size = UDim2.fromOffset(125, 325)
sidebar.Parent = main

local sideStroke = Instance.new("UIStroke")
sideStroke.Color = Color3.fromRGB(30, 30, 34)
sideStroke.Parent = sidebar

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Position = UDim2.fromOffset(145, 52)
content.Size = UDim2.fromOffset(492, 325)
content.Parent = main

local pages = {}
local tabs = {}

local function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.BackgroundTransparency = 1
    page.Size = UDim2.fromScale(1, 1)
    page.Visible = false
    page.Parent = content
    pages[name] = page
    return page
end

local function tabButton(text, y, pageName)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = Color3.fromRGB(17, 17, 20)
    b.BackgroundTransparency = 1
    b.Position = UDim2.fromOffset(8, y)
    b.Size = UDim2.fromOffset(109, 32)
    b.Text = "  " .. text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextColor3 = Color3.fromRGB(145, 145, 150)
    b.AutoButtonColor = false
    b.Parent = sidebar

    local indicator = Instance.new("Frame")
    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 130)
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.fromOffset(0, 5)
    indicator.Size = UDim2.fromOffset(3, 22)
    indicator.Visible = false
    indicator.Parent = b

    b.MouseButton1Click:Connect(function()
        for n, p in pairs(pages) do
            p.Visible = (n == pageName)
        end

        for _, info in pairs(tabs) do
            info.button.TextColor3 = Color3.fromRGB(145, 145, 150)
            info.indicator.Visible = false
        end

        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        indicator.Visible = true
    end)

    tabs[#tabs + 1] = {button = b, indicator = indicator}
    return b
end

local combat = makePage("Combat")
local visuals = makePage("Visuals")
local playerPage = makePage("Player")
local localPage = makePage("Local")
local config = makePage("Config")
local misc = makePage("Misc")

tabButton("⚔  Combat", 10, "Combat")
tabButton("◉  Visuals", 47, "Visuals")
tabButton("♙  Player", 84, "Player")
tabButton("ϟ  Local", 121, "Local")
tabButton("⚙  Config", 158, "Config")
tabButton("▤  Misc", 195, "Misc")

pages.Combat.Visible = true
tabs[1].button.TextColor3 = Color3.fromRGB(255,255,255)
tabs[1].indicator.Visible = true

-- ============================================================
-- COMPONENTES
-- ============================================================

local function panel(parent, pos, size, title)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
    f.BorderSizePixel = 0
    f.Position = pos
    f.Size = size
    f.Parent = parent

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(30, 30, 34)
    s.Parent = f

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(12, 8)
    t.Size = UDim2.new(1, -24, 0, 22)
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextColor3 = Color3.fromRGB(235,235,235)
    t.Parent = f

    return f
end

local function toggle(parent, text, y, default, callback)
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.Position = UDim2.fromOffset(12, y)
    b.Size = UDim2.new(1, -24, 0, 28)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextColor3 = Color3.fromRGB(190,190,195)
    b.AutoButtonColor = false
    b.Parent = parent

    local box = Instance.new("Frame")
    box.Position = UDim2.new(1, -28, 0.5, -7)
    box.Size = UDim2.fromOffset(28, 14)
    box.BackgroundColor3 = Color3.fromRGB(45,45,49)
    box.BorderSizePixel = 0
    box.Parent = b

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(10,10)
    knob.Position = UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = Color3.fromRGB(180,180,185)
    knob.BorderSizePixel = 0
    knob.Parent = box

    local state = default

    local function update()
        if state then
            box.BackgroundColor3 = Color3.fromRGB(255, 0, 130)
            knob.Position = UDim2.fromOffset(16,2)
            knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        else
            box.BackgroundColor3 = Color3.fromRGB(45,45,49)
            knob.Position = UDim2.fromOffset(2,2)
            knob.BackgroundColor3 = Color3.fromRGB(180,180,185)
        end
        callback(state)
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    update()
    return b
end

local function slider(parent, text, y, minValue, maxValue, value, callback)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, y)
    label.Size = UDim2.new(1, -24, 0, 20)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(190,190,195)
    label.Parent = parent

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, y)
    valueLabel.Size = UDim2.fromOffset(48, 20)
    valueLabel.Text = tostring(value)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextColor3 = Color3.fromRGB(180,180,185)
    valueLabel.Parent = parent

    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = Color3.fromRGB(45,45,49)
    bar.BorderSizePixel = 0
    bar.Position = UDim2.fromOffset(12, y + 23)
    bar.Size = UDim2.new(1, -24, 0, 4)
    bar.Parent = parent

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(255,0,130)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((value-minValue)/(maxValue-minValue), 0, 1, 0)
    fill.Parent = bar

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Size = UDim2.fromOffset(8,8)
    knob.Position = UDim2.new((value-minValue)/(maxValue-minValue),0,0.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = bar

    local draggingSlider = false

    local function setFromX(x)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local newValue = minValue + (maxValue-minValue)*alpha
        if maxValue-minValue > 20 then
            newValue = math.floor(newValue + 0.5)
        else
            newValue = math.floor(newValue*10 + 0.5)/10
        end
        fill.Size = UDim2.new(alpha,0,1,0)
        knob.Position = UDim2.new(alpha,0,0.5,0)
        valueLabel.Text = tostring(newValue)
        callback(newValue)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            setFromX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
end

local function label(parent, text, pos)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = pos
    l.Size = UDim2.new(1, -24, 0, 20)
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Color3.fromRGB(150,150,155)
    l.Parent = parent
    return l
end

-- ============================================================
-- COMBAT
-- ============================================================

local aimPanel = panel(combat, UDim2.fromOffset(0,0), UDim2.fromOffset(245,310), "Aimbot")
local settingsPanel = panel(combat, UDim2.fromOffset(255,0), UDim2.fromOffset(237,310), "Settings")

toggle(aimPanel, "Enable Aimbot", 38, false, function(v)
    AimbotOn = v
end)

toggle(aimPanel, "Show FOV", 70, false, function(v)
    ShowFOV = v
end)

label(aimPanel, "Target Part", UDim2.fromOffset(12, 106))

local targetButton = Instance.new("TextButton")
targetButton.BackgroundColor3 = Color3.fromRGB(24,24,28)
targetButton.BorderSizePixel = 0
targetButton.Position = UDim2.fromOffset(12,130)
targetButton.Size = UDim2.new(1,-24,0,30)
targetButton.Text = "Head"
targetButton.Font = Enum.Font.Gotham
targetButton.TextSize = 11
targetButton.TextColor3 = Color3.fromRGB(230,230,235)
targetButton.Parent = aimPanel

targetButton.MouseButton1Click:Connect(function()
    TARGET_PART = TARGET_PART == "Head" and "HumanoidRootPart" or "Head"
    targetButton.Text = TARGET_PART
end)

label(aimPanel, "Keybind", UDim2.fromOffset(12, 170))

local keyButton = Instance.new("TextButton")
keyButton.BackgroundColor3 = Color3.fromRGB(24,24,28)
keyButton.BorderSizePixel = 0
keyButton.Position = UDim2.fromOffset(12,194)
keyButton.Size = UDim2.new(1,-24,0,30)
keyButton.Text = "Right Mouse"
keyButton.Font = Enum.Font.Gotham
keyButton.TextSize = 11
keyButton.TextColor3 = Color3.fromRGB(230,230,235)
keyButton.Parent = aimPanel

local waitingKey = false
keyButton.MouseButton1Click:Connect(function()
    waitingKey = true
    keyButton.Text = "Press a key..."
end)

UIS.InputBegan:Connect(function(input, processed)
    if waitingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            AimKey = input.KeyCode
            keyButton.Text = input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            AimKey = Enum.UserInputType.MouseButton2
            keyButton.Text = "Right Mouse"
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            AimKey = Enum.UserInputType.MouseButton1
            keyButton.Text = "Left Mouse"
        end
        waitingKey = false
    end
end)

slider(settingsPanel, "FOV Radius", 42, 20, 300, FOVRadius, function(v)
    FOVRadius = v
end)

slider(settingsPanel, "Smoothing", 105, 1, 10, Smooth, function(v)
    Smooth = v
end)

label(settingsPanel, "Aim target: " .. TARGET_PART, UDim2.fromOffset(12, 168))

-- FOV visual
local fovGui = Instance.new("Frame")
fovGui.Name = "FOV"
fovGui.AnchorPoint = Vector2.new(0.5,0.5)
fovGui.BackgroundTransparency = 1
fovGui.Size = UDim2.fromOffset(FOVRadius*2,FOVRadius*2)
fovGui.Position = UDim2.fromScale(0.5,0.5)
fovGui.Visible = false
fovGui.Parent = gui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1,0)
fovCorner.Parent = fovGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255,0,130)
fovStroke.Thickness = 1
fovStroke.Parent = fovGui

-- ============================================================
-- ESP
-- ============================================================

local boxPanel = panel(visuals, UDim2.fromOffset(0,0), UDim2.fromOffset(245,310), "Visuals")
local espSettings = panel(visuals, UDim2.fromOffset(255,0), UDim2.fromOffset(237,310), "ESP")

toggle(boxPanel, "ESP Box", 38, false, function(v)
    ESPBox = v
end)

toggle(boxPanel, "ESP Skeleton", 70, false, function(v)
    ESPSkeleton = v
end)

toggle(boxPanel, "ESP Health", 102, false, function(v)
    ESPHealth = v
end)

label(boxPanel, "Visuals update automatically.", UDim2.fromOffset(12, 150))
label(boxPanel, "Only other players are displayed.", UDim2.fromOffset(12, 174))

label(espSettings, "Box color: Pink", UDim2.fromOffset(12, 42))
label(espSettings, "Skeleton color: White", UDim2.fromOffset(12, 70))
label(espSettings, "Health: Green → Red", UDim2.fromOffset(12, 98))

-- ============================================================
-- PÁGINAS RESTANTES
-- ============================================================

local pPanel = panel(playerPage, UDim2.fromOffset(0,0), UDim2.fromOffset(492,310), "Player")
label(pPanel, "Player tools can be added here for your game.", UDim2.fromOffset(12,45))
label(localPage, "Local tools can be added here.", UDim2.fromOffset(12,45))
label(config, "Config", UDim2.fromOffset(12,45))
label(misc, "Misc", UDim2.fromOffset(12,45))

-- ============================================================
-- ESP STANDARD ROBLOX (BillboardGui)
-- ============================================================

local function clearESP(player)
    local data = espObjects[player]
    if data then
        for _, obj in pairs(data) do
            if obj and obj.Destroy then
                obj:Destroy()
            end
        end
    end
    espObjects[player] = nil

    local sk = skeletonObjects[player]
    if sk then
        for _, obj in pairs(sk) do
            if obj and obj.Destroy then
                obj:Destroy()
            end
        end
    end
    skeletonObjects[player] = nil
end

local function makeBox(player, character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ToroBox"
    bb.Adornee = root
    bb.Size = UDim2.fromOffset(70,95)
    bb.StudsOffset = Vector3.new(0,0,0)
    bb.AlwaysOnTop = true
    bb.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.fromScale(1,1)
    frame.Parent = bb

    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(255,0,130)
    st.Thickness = 1
    st.Parent = frame

    return bb
end

local function makeHealth(player, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ToroHealth"
    bb.Adornee = root
    bb.Size = UDim2.fromOffset(8,95)
    bb.StudsOffset = Vector3.new(-2.2,0,0)
    bb.AlwaysOnTop = true
    bb.Parent = PlayerGui

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bg.BorderSizePixel = 0
    bg.Size = UDim2.fromScale(1,1)
    bg.Parent = bb

    local fill = Instance.new("Frame")
    fill.BorderSizePixel = 0
    fill.AnchorPoint = Vector2.new(0,1)
    fill.Position = UDim2.fromScale(0,1)
    fill.Size = UDim2.fromScale(1,1)
    fill.Parent = bg

    local function update()
        local hp = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth,1),0,1)
        fill.Size = UDim2.fromScale(1,hp)
        fill.BackgroundColor3 = Color3.new(1-hp,hp,0)
    end

    humanoid.HealthChanged:Connect(update)
    update()

    return bb
end

-- skeleton usando Beams entre partes R15/R6
local skeletonPairs = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
    -- R6 fallback
    {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
    {"Torso","Left Leg"}, {"Torso","Right Leg"}
}

local function makeSkeleton(player, character)
    local result = {}

    for _, pair in ipairs(skeletonPairs) do
        local a = character:FindFirstChild(pair[1])
        local b = character:FindFirstChild(pair[2])

        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            local a0 = Instance.new("Attachment")
            a0.Parent = a

            local a1 = Instance.new("Attachment")
            a1.Parent = b

            local beam = Instance.new("Beam")
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Width0 = 0.035
            beam.Width1 = 0.035
            beam.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
            beam.FaceCamera = true
            beam.Parent = a

            table.insert(result, a0)
            table.insert(result, a1)
            table.insert(result, beam)
        end
    end

    return result
end

local function updatePlayerESP(player)
    if player == LocalPlayer then return end
    clearESP(player)

    if not isEnemy(player) then return end
    local char = player.Character
    if not char then return end

    local data = {}

    if ESPBox then
        local x = makeBox(player,char)
        if x then table.insert(data,x) end
    end

    if ESPHealth then
        local x = makeHealth(player,char)
        if x then table.insert(data,x) end
    end

    if #data > 0 then
        espObjects[player] = data
    end

    if ESPSkeleton then
        skeletonObjects[player] = makeSkeleton(player,char)
    end
end

local function refreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updatePlayerESP(player)
        end
    end
end

local function hookPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function()
        task.wait(0.25)
        updatePlayerESP(player)
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        updatePlayerESP(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    hookPlayer(player)
end

Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(player)
    clearESP(player)
end)

task.spawn(function()
    while gui.Parent do
        refreshESP()
        task.wait(0.5)
    end
end)

-- ============================================================
-- AIMBOT / AIM ASSIST PARA TESTE DO SEU JOGO
-- ============================================================

local function getClosestTarget()
    local mousePos = UIS:GetMouseLocation()
    local closest = nil
    local closestDistance = FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = player.Character:FindFirstChild(TARGET_PART)

            if humanoid and humanoid.Health > 0 and part then
                local screenPos, visible = Camera:WorldToViewportPoint(part.Position)

                if visible then
                    local distance = (Vector2.new(screenPos.X,screenPos.Y) - mousePos).Magnitude

                    if distance <= closestDistance then
                        closestDistance = distance
                        closest = part
                    end
                end
            end
        end
    end

    return closest
end

local function aimKeyDown()
    if AimKey == Enum.UserInputType.MouseButton1 then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif AimKey == Enum.UserInputType.MouseButton2 then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif AimKey == Enum.UserInputType.MouseButton3 then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
    elseif typeof(AimKey) == "EnumItem" and AimKey.EnumType == Enum.KeyCode then
        return UIS:IsKeyDown(AimKey)
    end

    return false
end

RunService.RenderStepped:Connect(function(dt)
    fovGui.Visible = ShowFOV
    fovGui.Size = UDim2.fromOffset(FOVRadius*2,FOVRadius*2)

    if not AimbotOn or not aimKeyDown() then
        return
    end

    local target = getClosestTarget()
    if not target then return end

    local cameraPos = Camera.CFrame.Position
    local desired = CFrame.lookAt(cameraPos, target.Position)

    local factor = math.clamp((Smooth * 8) * dt, 0.02, 1)
    Camera.CFrame = Camera.CFrame:Lerp(desired, factor)
end)

-- tecla Insert mostra/esconde o painel
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)
