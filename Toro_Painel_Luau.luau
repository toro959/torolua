-- ============================================================
-- TORO MENU - versão com abas funcionais
-- Coloque como LocalScript no seu próprio jogo/projeto Roblox.
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- ESTADO
-- ============================================================

local AimbotOn = false
local AimSmooth = 0.15
local AimKey = Enum.KeyCode.LeftAlt
local AimFOV = 120

local ESPBoxOn = false
local ESPSkeletonOn = false
local ESPHealthOn = false
local LocalESPOn = false
local SpeedOn = false
local WalkSpeedValue = 24

local ThemeColor = Color3.fromRGB(255, 55, 120)

local espObjects = {}
local skeletonObjects = {}

-- ============================================================
-- FUNÇÕES
-- ============================================================

local function isEnemy(plr)
    if not LocalPlayer.Team or not plr.Team then
        return true
    end
    return LocalPlayer.Team ~= plr.Team
end

local function getCharacter(plr)
    return plr.Character
end

local function removeESP(plr)
    if espObjects[plr] then
        for _, obj in pairs(espObjects[plr]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        espObjects[plr] = nil
    end

    if skeletonObjects[plr] then
        for _, obj in pairs(skeletonObjects[plr]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        skeletonObjects[plr] = nil
    end
end

local function createBoxESP(plr)
    if plr == LocalPlayer or not isEnemy(plr) then return end
    local char = getCharacter(plr)
    if not char then return end

    removeESP(plr)

    local hl = Instance.new("Highlight")
    hl.Name = "ToroBoxESP"
    hl.Adornee = char
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = ThemeColor
    hl.Parent = char

    local items = {hl}

    if ESPHealthOn then
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if head and hum then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ToroHealth"
            bb.Adornee = head
            bb.Size = UDim2.fromOffset(90, 18)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent = PlayerGui

            local text = Instance.new("TextLabel")
            text.Size = UDim2.fromScale(1, 1)
            text.BackgroundTransparency = 1
            text.TextColor3 = Color3.fromRGB(80, 255, 100)
            text.TextStrokeTransparency = 0
            text.TextScaled = true
            text.Font = Enum.Font.GothamBold
            text.Text = string.format("HP: %d/%d", hum.Health, hum.MaxHealth)
            text.Parent = bb

            table.insert(items, bb)

            table.insert(items, hum.HealthChanged:Connect(function()
                if bb.Parent and hum.Parent then
                    text.Text = string.format("HP: %d/%d", hum.Health, hum.MaxHealth)
                end
            end))
        end
    end

    espObjects[plr] = items
end

local function createSkeletonESP(plr)
    if plr == LocalPlayer or not isEnemy(plr) then return end
    local char = getCharacter(plr)
    if not char then return end

    local parts = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }

    local created = {}

    for _, pair in ipairs(parts) do
        local p0 = char:FindFirstChild(pair[1])
        local p1 = char:FindFirstChild(pair[2])

        if p0 and p1 then
            local a0 = Instance.new("Attachment")
            a0.Parent = p0

            local a1 = Instance.new("Attachment")
            a1.Parent = p1

            local beam = Instance.new("Beam")
            beam.Name = "ToroSkeleton"
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Width0 = 0.045
            beam.Width1 = 0.045
            beam.FaceCamera = true
            beam.Color = ColorSequence.new(ThemeColor)
            beam.Parent = p0

            table.insert(created, a0)
            table.insert(created, a1)
            table.insert(created, beam)
        end
    end

    skeletonObjects[plr] = created
end

local function refreshESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            removeESP(plr)

            if ESPBoxOn or ESPHealthOn then
                createBoxESP(plr)
            end

            if ESPSkeletonOn then
                createSkeletonESP(plr)
            end
        end
    end
end

local function clearAllVisuals()
    for _, plr in ipairs(Players:GetPlayers()) do
        removeESP(plr)
    end
end

-- ============================================================
-- GUI
-- ============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ToroMenu"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(640, 420)
main.Position = UDim2.new(0.5, -320, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 55)
top.BackgroundColor3 = Color3.fromRGB(24, 24, 31)
top.BorderSizePixel = 0
top.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 7)
title.Size = UDim2.fromOffset(300, 40)
title.Text = "TORO"
title.TextColor3 = ThemeColor
title.TextSize = 23
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(90, 9)
subtitle.Size = UDim2.fromOffset(200, 35)
subtitle.Text = "CONTROL PANEL"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -45, 0, 12)
close.Text = "×"
close.TextSize = 20
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
close.BorderSizePixel = 0
close.Parent = top

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(0, 55)
sidebar.Size = UDim2.fromOffset(145, 365)
sidebar.BackgroundColor3 = Color3.fromRGB(21, 21, 27)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(145, 55)
content.Size = UDim2.new(1, -145, 1, -55)
content.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
content.BorderSizePixel = 0
content.Parent = main

local pages = {}
local tabButtons = {}

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Position = UDim2.fromOffset(0, 0)
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.fromOffset(0, 650)
    page.Visible = false
    page.Parent = content
    pages[name] = page
    return page
end

local function makeTab(name, icon, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -18, 0, 42)
    b.Position = UDim2.fromOffset(9, 10 + (order - 1) * 48)
    b.BackgroundColor3 = Color3.fromRGB(21, 21, 27)
    b.Text = "  " .. icon .. "   " .. name
    b.TextColor3 = Color3.fromRGB(175, 175, 185)
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    b.Parent = sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    tabButtons[name] = b
    return b
end

local combat = makePage("Combat")
local visuals = makePage("Visuals")
local playerPage = makePage("Player")
local localPage = makePage("Local")
local config = makePage("Config")
local misc = makePage("Misc")

local tabs = {
    {"Combat", "⚔", 1},
    {"Visuals", "◉", 2},
    {"Player", "●", 3},
    {"Local", "◆", 4},
    {"Config", "⚙", 5},
    {"Misc", "⋯", 6},
}

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end

    for tabName, b in pairs(tabButtons) do
        b.BackgroundColor3 = tabName == name and ThemeColor or Color3.fromRGB(21, 21, 27)
        b.TextColor3 = tabName == name and Color3.new(1, 1, 1) or Color3.fromRGB(175, 175, 185)
    end
end

for _, data in ipairs(tabs) do
    local b = makeTab(data[1], data[2], data[3])
    b.MouseButton1Click:Connect(function()
        showPage(data[1])
    end)
end

-- ============================================================
-- COMPONENTES
-- ============================================================

local function section(page, text, y)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(22, y)
    label.Size = UDim2.new(1, -44, 0, 28)
    label.Text = text
    label.TextColor3 = ThemeColor
    label.TextSize = 15
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = page
end

local function toggle(page, text, y, initial, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(22, y)
    b.Size = UDim2.new(1, -44, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.fromRGB(230, 230, 235)
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = page

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    local state = initial or false

    local function update()
        b.Text = "   " .. text .. "   [" .. (state and "ON" or "OFF") .. "]"
        b.BackgroundColor3 = state and ThemeColor or Color3.fromRGB(30, 30, 38)
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        update()
        callback(state)
    end)

    update()
    return b
end

local function button(page, text, y, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(22, y)
    b.Size = UDim2.new(1, -44, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 235)
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.Parent = page

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    b.MouseButton1Click:Connect(callback)
    return b
end

-- ============================================================
-- COMBAT
-- ============================================================

section(combat, "AIM ASSIST", 18)

toggle(combat, "Aimbot", 55, false, function(v)
    AimbotOn = v
end)

toggle(combat, "FOV", 105, true, function(v)
    -- FOV visual permanece simples nesta versão.
end)

button(combat, "Aim key: LEFT ALT", 155, function()
    AimKey = Enum.KeyCode.LeftAlt
end)

section(combat, "SMOOTH", 220)

button(combat, "Smooth: " .. tostring(AimSmooth), 257, function()
    AimSmooth = AimSmooth + 0.05
    if AimSmooth > 0.5 then AimSmooth = 0.05 end
end)

button(combat, "FOV: " .. tostring(AimFOV), 307, function()
    AimFOV = AimFOV + 20
    if AimFOV > 240 then AimFOV = 60 end
end)

-- ============================================================
-- VISUALS
-- ============================================================

section(visuals, "ESP", 18)

toggle(visuals, "ESP Box", 55, false, function(v)
    ESPBoxOn = v
    refreshESP()
end)

toggle(visuals, "ESP Skeleton", 105, false, function(v)
    ESPSkeletonOn = v
    refreshESP()
end)

toggle(visuals, "ESP Health", 155, false, function(v)
    ESPHealthOn = v
    refreshESP()
end)

button(visuals, "Refresh ESP", 205, function()
    refreshESP()
end)

button(visuals, "Clear ESP", 255, function()
    clearAllVisuals()
end)

-- ============================================================
-- PLAYER
-- ============================================================

section(playerPage, "PLAYER", 18)

button(playerPage, "Reset Character", 55, function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

button(playerPage, "Respawn", 105, function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

-- ============================================================
-- LOCAL
-- ============================================================

section(localPage, "LOCAL PLAYER", 18)

toggle(localPage, "Speed", 55, false, function(v)
    SpeedOn = v
end)

button(localPage, "Speed +", 105, function()
    WalkSpeedValue = math.min(WalkSpeedValue + 4, 100)
end)

button(localPage, "Speed -", 155, function()
    WalkSpeedValue = math.max(WalkSpeedValue - 4, 8)
end)

button(localPage, "Speed = " .. tostring(WalkSpeedValue), 205, function()
end)

toggle(localPage, "Local ESP", 255, false, function(v)
    LocalESPOn = v
end)

-- ============================================================
-- CONFIG
-- ============================================================

section(config, "THEME COLOR", 18)

local colorPresets = {
    {"Pink", Color3.fromRGB(255, 55, 120)},
    {"Red", Color3.fromRGB(255, 60, 60)},
    {"Purple", Color3.fromRGB(165, 90, 255)},
    {"Blue", Color3.fromRGB(70, 130, 255)},
    {"Green", Color3.fromRGB(70, 220, 130)},
    {"Orange", Color3.fromRGB(255, 145, 55)},
}

local function applyTheme(c)
    ThemeColor = c
    title.TextColor3 = c

    for name, b in pairs(tabButtons) do
        if pages[name] and pages[name].Visible then
            b.BackgroundColor3 = c
        end
    end

    for _, page in pairs(pages) do
        for _, obj in ipairs(page:GetChildren()) do
            if obj:IsA("TextLabel") and obj.TextColor3 ~= Color3.fromRGB(150,150,160) then
                -- Atualiza somente títulos de seção.
                if obj.Font == Enum.Font.GothamBold then
                    obj.TextColor3 = c
                end
            end
        end
    end

    refreshESP()
end

for i, preset in ipairs(colorPresets) do
    button(config, "Cor: " .. preset[1], 55 + (i - 1) * 50, function()
        applyTheme(preset[2])
    end)
end

-- ============================================================
-- MISC
-- ============================================================

section(misc, "MISC", 18)

button(misc, "Hide Panel", 55, function()
    main.Visible = false
end)

button(misc, "Show Panel", 105, function()
    main.Visible = true
end)

button(misc, "Clear Visuals", 155, function()
    clearAllVisuals()
    ESPBoxOn = false
    ESPSkeletonOn = false
    ESPHealthOn = false
end)

-- ============================================================
-- LOCAL ESP
-- ============================================================

local localHighlight

local function updateLocalESP()
    if localHighlight then
        localHighlight:Destroy()
        localHighlight = nil
    end

    if LocalESPOn and LocalPlayer.Character then
        localHighlight = Instance.new("Highlight")
        localHighlight.Name = "ToroLocalESP"
        localHighlight.Adornee = LocalPlayer.Character
        localHighlight.FillTransparency = 0.8
        localHighlight.OutlineColor = ThemeColor
        localHighlight.Parent = LocalPlayer.Character
    end
end

-- ============================================================
-- SPEED
-- ============================================================

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        if SpeedOn then
            hum.WalkSpeed = WalkSpeedValue
        else
            hum.WalkSpeed = 16
        end
    end

    if LocalESPOn then
        updateLocalESP()
    elseif localHighlight then
        localHighlight:Destroy()
        localHighlight = nil
    end
end)

-- Atualiza ESP quando jogadores entram/renascem.
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPBoxOn or ESPHealthOn or ESPSkeletonOn then
            refreshESP()
        end
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ESPBoxOn or ESPHealthOn or ESPSkeletonOn then
                refreshESP()
            end
        end)
    end
end

-- ============================================================
-- AIM LOOP
-- ============================================================

RunService.RenderStepped:Connect(function()
    if not AimbotOn then return end
    if not UIS:IsKeyDown(AimKey) then return end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    local closestPart
    local closestDistance = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and isEnemy(plr) then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local screenPos, visible = camera:WorldToViewportPoint(head.Position)

                if visible then
                    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                    if distance <= AimFOV and distance < closestDistance then
                        closestDistance = distance
                        closestPart = head
                    end
                end
            end
        end
    end

    if closestPart then
        local target = CFrame.new(camera.CFrame.Position, closestPart.Position)
        camera.CFrame = camera.CFrame:Lerp(target, AimSmooth)
    end
end)

-- Tecla INSERT mostra/esconde.
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)

-- Estado inicial.
showPage("Combat")
