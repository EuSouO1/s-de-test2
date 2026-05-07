--// GUI
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui_V3_WL_Fix"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 450, 0, 320)
frame.Position = UDim2.new(0.5, -225, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Fling Player Pro + Whitelist"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.9, 0, 0, 35)
box.Position = UDim2.new(0.05, 0, 0.12, 0)
box.PlaceholderText = "Nome do alvo"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.TextColor3 = Color3.new(1, 1, 1)

-- LISTA DE ALVOS (ESQUERDA)
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.44, 0, 0, 100)
listFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- LISTA DE WHITELIST (DIREITA)
local wlFrame = Instance.new("ScrollingFrame", frame)
wlFrame.Size = UDim2.new(0.44, 0, 0, 100)
wlFrame.Position = UDim2.new(0.51, 0, 0.25, 0)
wlFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 20)
wlFrame.BorderSizePixel = 0
wlFrame.ScrollBarThickness = 6
wlFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 4)
Instance.new("UIListLayout", wlFrame).Padding = UDim.new(0, 4)

-- BOTÕES
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9, 0, 0, 35)
toggle.Position = UDim2.new(0.05, 0, 0.62, 0)
toggle.Text = "Fling OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1, 1, 1)

local allToggle = Instance.new("TextButton", frame)
allToggle.Size = UDim2.new(0.9, 0, 0, 35)
allToggle.Position = UDim2.new(0.05, 0, 0.76, 0)
allToggle.Text = "Fling All OFF"
allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
allToggle.TextScaled = true
allToggle.TextColor3 = Color3.new(1, 1, 1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ESTADOS E VARIAVEIS
local running = false
local flingAllActive = false
local whitelist = {}
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- REFRESH DAS LISTAS (OS MESMOS PLAYERS NAS DUAS)
local function refreshLists()
    for _, v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, v in ipairs(wlFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            -- Botão na lista de Alvos
            local btnTarget = Instance.new("TextButton")
            btnTarget.Size = UDim2.new(1, -6, 0, 24)
            btnTarget.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btnTarget.TextColor3 = Color3.new(1, 1, 1)
            btnTarget.TextScaled = true
            btnTarget.Text = p.Name
            btnTarget.Parent = listFrame
            btnTarget.MouseButton1Click:Connect(function() box.Text = p.Name end)

            -- Botão na lista de Whitelist
            local btnWL = Instance.new("TextButton")
            btnWL.Size = UDim2.new(1, -6, 0, 24)
            btnWL.BackgroundColor3 = whitelist[p.Name] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
            btnWL.TextColor3 = Color3.new(1, 1, 1)
            btnWL.TextScaled = true
            btnWL.Text = whitelist[p.Name] and "[SAFE] " .. p.Name or p.Name
            btnWL.Parent = wlFrame
            btnWL.MouseButton1Click:Connect(function()
                whitelist[p.Name] = not whitelist[p.Name]
                refreshLists() -- Atualiza as cores
            end)
        end
    end
end

refreshLists()
game.Players.PlayerAdded:Connect(refreshLists)
game.Players.PlayerRemoving:Connect(refreshLists)

-- FUNÇÃO CORE (MÉTODO SKID ORIGINAL)
local function SkidFling(TargetPlayer)
    if not TargetPlayer or whitelist[TargetPlayer.Name] then return end

    local Character = plr.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter or not Character or not RootPart then return end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    if not TRootPart then return end

    if RootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end

    workspace.FallenPartsDestroyHeight = 0/0
    
    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local function FPos(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local Time = tick()
    local Angle = 0
    repeat
        if RootPart and THumanoid and TRootPart and not whitelist[TargetPlayer.Name] then
            Angle = Angle + 100
            FPos(TRootPart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * TRootPart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
            task.wait()
            FPos(TRootPart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * TRootPart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
            task.wait()
        else
            break
        end
    until Time + 2 < tick() or not (running or flingAllActive)

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    if getgenv().OldPos then
        RootPart.CFrame = getgenv().OldPos
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

-- LOGICA FLING ALL
allToggle.MouseButton1Click:Connect(function()
    flingAllActive = not flingAllActive
    allToggle.Text = flingAllActive and "Fling All ON" or "Fling All OFF"
    allToggle.BackgroundColor3 = flingAllActive and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 85, 127)
    
    if flingAllActive then
        running = false
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        
        task.spawn(function()
            while flingAllActive do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if not flingAllActive then break end
                    if p ~= plr and not whitelist[p.Name] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        SkidFling(p)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

-- LOGICA FLING INDIVIDUAL
toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        flingAllActive = false
        allToggle.Text = "Fling All OFF"
        allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)

        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end
        
        if target and not whitelist[target.Name] then
            toggle.Text = "Flinging..."
            toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
            task.spawn(function()
                while running do
                    if not target or whitelist[target.Name] then break end
                    SkidFling(target)
                    task.wait(0.1)
                end
                toggle.Text = "Fling OFF"
                toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
                running = false
            end)
        else
            running = false
            toggle.Text = "Protegido/Off"
            task.wait(1)
            toggle.Text = "Fling OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        end
    else
        toggle.Text = "Fling OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
