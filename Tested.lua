-- ========== CAR FLY MOBILE (NITRO FLY) — СКОРОСТЬ КАК МНОЖИТЕЛЬ ==========
-- 1 = обычная скорость, 100 = максимальная. Шаг: 1.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ========== НАСТРОЙКИ ==========
local flySpeed = 1            -- множитель скорости (1 = обычная, 100 = макс)
local baseSpeed = 60          -- базовая скорость при множителе 1 (настрой под себя)
local verticalSpeed = 70
local arrowSpeed = 40
local deadzone = 0.25
local isFlying = false
local vehicleSeat = nil
local vehicleModel = nil
local rootPart = nil
local bodyVelocity = nil
local bodyGyro = nil

-- Состояние стрелок
local arrowUp = false
local arrowDown = false

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarFlyGui"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- Кнопка открытия
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = UDim2.new(0, 15, 0.5, -15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.Text = "🚗"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 2
toggleBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = ScreenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Перетаскивание кнопки
local draggingToggle = false
local dragStartToggle = nil
local startPosToggle = nil

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingToggle = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingToggle then
            local delta = input.Position - dragStartToggle
            toggleBtn.Position = UDim2.new(
                startPosToggle.X.Scale,
                startPosToggle.X.Offset + delta.X,
                startPosToggle.Y.Scale,
                startPosToggle.Y.Offset + delta.Y
            )
        end
    end
end)

-- ========== МЕНЮ ==========
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.Visible = false
mainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local function showMenu()
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 1, 0, 1)
    mainFrame.BackgroundTransparency = 1
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 250, 0, 200),
        BackgroundTransparency = 0
    }):Play()
end

local function hideMenu()
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        mainFrame.Visible = false
    end)
end

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.Text = "NITRO FLY"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.BorderSizePixel = 0
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    hideMenu()
    toggleBtn.Text = "🚗"
end)

-- Перетаскивание меню
local draggingMain = false
local dragStartMain = nil
local startPosMain = nil

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)

titleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingMain then
            local delta = input.Position - dragStartMain
            mainFrame.Position = UDim2.new(
                startPosMain.X.Scale,
                startPosMain.X.Offset + delta.X,
                startPosMain.Y.Scale,
                startPosMain.Y.Offset + delta.Y
            )
        end
    end
end)

-- Кнопка FLY
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.8, 0, 0, 45)
flyBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
flyBtn.Text = "FLY"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 16
flyBtn.Font = Enum.Font.GothamBold
flyBtn.BorderSizePixel = 0
flyBtn.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyBtn

-- Панель скорости
local speedPanel = Instance.new("Frame")
speedPanel.Size = UDim2.new(0.8, 0, 0, 35)
speedPanel.Position = UDim2.new(0.1, 0, 0.48, 0)
speedPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
speedPanel.BorderSizePixel = 0
speedPanel.Parent = mainFrame

local speedPanelCorner = Instance.new("UICorner")
speedPanelCorner.CornerRadius = UDim.new(0, 6)
speedPanelCorner.Parent = speedPanel

-- Кнопка минус
local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 30, 0, 30)
minusBtn.Position = UDim2.new(0, 2, 0.5, -15)
minusBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
minusBtn.Text = "−"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.TextSize = 18
minusBtn.Font = Enum.Font.GothamBold
minusBtn.BorderSizePixel = 0
minusBtn.Parent = speedPanel

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 6)
minusCorner.Parent = minusBtn

-- Текст скорости (показывает множитель)
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.Position = UDim2.new(0.25, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = speedPanel

-- Кнопка плюс
local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 30, 0, 30)
plusBtn.Position = UDim2.new(1, -32, 0.5, -15)
plusBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.TextSize = 18
plusBtn.Font = Enum.Font.GothamBold
plusBtn.BorderSizePixel = 0
plusBtn.Parent = speedPanel

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 6)
plusCorner.Parent = plusBtn

-- Обработчики: шаг 1, минимум 1, максимум 100
minusBtn.MouseButton1Click:Connect(function()
    if flySpeed > 1 then
        flySpeed = flySpeed - 1
        speedLabel.Text = "SPEED: " .. flySpeed
    end
end)

plusBtn.MouseButton1Click:Connect(function()
    if flySpeed < 100 then
        flySpeed = flySpeed + 1
        speedLabel.Text = "SPEED: " .. flySpeed
    end
end)

-- Кнопка DESTROY
local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(0.8, 0, 0, 30)
destroyBtn.Position = UDim2.new(0.1, 0, 0.8, 0)
destroyBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
destroyBtn.Text = "DESTROY"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.TextSize = 12
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.BorderSizePixel = 0
destroyBtn.Parent = mainFrame

local destroyCorner = Instance.new("UICorner")
destroyCorner.CornerRadius = UDim.new(0, 8)
destroyCorner.Parent = destroyBtn

destroyBtn.MouseButton1Click:Connect(function()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if vehicleModel then
        for _, part in pairs(vehicleModel:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    ScreenGui:Destroy()
    print("[CAR FLY] Скрипт уничтожен.")
end)

-- Маленькие стрелки ▲/▼
local arrowUpBtn = Instance.new("TextButton")
arrowUpBtn.Size = UDim2.new(0, 25, 0, 25)
arrowUpBtn.Position = UDim2.new(1, -35, 0.35, 0)
arrowUpBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
arrowUpBtn.Text = "▲"
arrowUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
arrowUpBtn.TextSize = 12
arrowUpBtn.Font = Enum.Font.GothamBold
arrowUpBtn.BorderSizePixel = 1
arrowUpBtn.BorderColor3 = Color3.fromRGB(60, 120, 60)
arrowUpBtn.AutoButtonColor = false
arrowUpBtn.Visible = false
arrowUpBtn.Parent = ScreenGui

local arrowUpCorner = Instance.new("UICorner")
arrowUpCorner.CornerRadius = UDim.new(0, 5)
arrowUpCorner.Parent = arrowUpBtn

local arrowDownBtn = Instance.new("TextButton")
arrowDownBtn.Size = UDim2.new(0, 25, 0, 25)
arrowDownBtn.Position = UDim2.new(1, -35, 0.5, 0)
arrowDownBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
arrowDownBtn.Text = "▼"
arrowDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
arrowDownBtn.TextSize = 12
arrowDownBtn.Font = Enum.Font.GothamBold
arrowDownBtn.BorderSizePixel = 1
arrowDownBtn.BorderColor3 = Color3.fromRGB(120, 60, 60)
arrowDownBtn.AutoButtonColor = false
arrowDownBtn.Visible = false
arrowDownBtn.Parent = ScreenGui

local arrowDownCorner = Instance.new("UICorner")
arrowDownCorner.CornerRadius = UDim.new(0, 5)
arrowDownCorner.Parent = arrowDownBtn

arrowUpBtn.MouseButton1Down:Connect(function() arrowUp = true end)
arrowUpBtn.MouseButton1Up:Connect(function() arrowUp = false end)
arrowUpBtn.MouseLeave:Connect(function() arrowUp = false end)

arrowDownBtn.MouseButton1Down:Connect(function() arrowDown = true end)
arrowDownBtn.MouseButton1Up:Connect(function() arrowDown = false end)
arrowDownBtn.MouseLeave:Connect(function() arrowDown = false end)

-- ========== ЛОГИКА ПОЛЁТА ==========
local flyConnection = nil

local function getVehicle()
    local char = player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        return humanoid.SeatPart
    end
    return nil
end

local function startFlying()
    vehicleSeat = getVehicle()
    if not vehicleSeat then
        flyBtn.Text = "НЕТ МАШИНЫ"
        task.wait(1)
        flyBtn.Text = "FLY"
        return
    end

    vehicleModel = vehicleSeat.Parent
    if not vehicleModel then return end

    rootPart = vehicleModel:FindFirstChild("HumanoidRootPart") or vehicleModel:FindFirstChild("VehicleSeat") or vehicleSeat
    if not rootPart then return end

    for _, part in pairs(vehicleModel:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.D = 50
    bodyGyro.P = 3000
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart

    flyConnection = RunService.Heartbeat:Connect(function()
        if not isFlying or not bodyVelocity or not bodyGyro then return end

        local camCFrame = camera.CFrame
        bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + camCFrame.LookVector)

        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        local moveDir = Vector3.zero
        if humanoid then
            moveDir = humanoid.MoveDirection
        end

        local flatMove = Vector3.new(moveDir.X, 0, moveDir.Z)
        local inputMagnitude = flatMove.Magnitude

        local velocity = Vector3.zero
        local actualSpeed = baseSpeed * (flySpeed / 10)  -- при flySpeed=10 скорость = baseSpeed

        local arrowVelocity = 0
        if arrowUp then
            arrowVelocity = arrowSpeed
        elseif arrowDown then
            arrowVelocity = -arrowSpeed
        end

        if inputMagnitude > 0.1 then
            local horizontalVelocity = flatMove.Unit * actualSpeed
            local camPitch = camCFrame.LookVector.Y
            local camVertical = 0
            if math.abs(camPitch) > deadzone then
                local sign = camPitch > 0 and 1 or -1
                local magnitude = (math.abs(camPitch) - deadzone) / (1 - deadzone)
                camVertical = sign * magnitude * verticalSpeed * inputMagnitude
            end
            velocity = Vector3.new(horizontalVelocity.X, camVertical + arrowVelocity, horizontalVelocity.Z)
        else
            velocity = Vector3.new(0, arrowVelocity, 0)
        end

        bodyVelocity.Velocity = velocity
    end)
end

local function stopFlying()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if vehicleModel then
        for _, part in pairs(vehicleModel:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    vehicleSeat = nil
    vehicleModel = nil
    rootPart = nil
    arrowUp = false
    arrowDown = false
end

-- Обработчик FLY
flyBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    if isFlying then
        flyBtn.Text = "STOP"
        flyBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
        arrowUpBtn.Visible = true
        arrowDownBtn.Visible = true
        startFlying()
    else
        flyBtn.Text = "FLY"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        arrowUpBtn.Visible = false
        arrowDownBtn.Visible = false
        stopFlying()
    end
end)

-- Открытие/закрытие меню
local isOpen = false
toggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        showMenu()
        toggleBtn.Text = "✕"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    else
        hideMenu()
        toggleBtn.Text = "🚗"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- Защита при смерти
player.CharacterAdded:Connect(function()
    if isFlying then
        isFlying = false
        flyBtn.Text = "FLY"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        arrowUpBtn.Visible = false
        arrowDownBtn.Visible = false
        stopFlying()
    end
end)

print("[CAR FLY] Загружен. Скорость: 1 = обычная, 100 = макс. Шаг: 1.")
