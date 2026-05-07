--// GUI
local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "FlingGui_V3_Whitelist"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 450, 0, 350) -- Aumentei a largura para caber as duas listas
frame.Position = UDim2.new(0.5, -225, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Fling Player Pro + Whitelist"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

-- Colunas de Listas
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.45, 0, 0, 150)
listFrame.Position = UDim2.new(0.03, 0, 0.15, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.ScrollBarThickness = 4
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local whitelistFrame = Instance.new("ScrollingFrame", frame)
whitelistFrame.Size = UDim2.new(0.45, 0, 0, 150)
whitelistFrame.Position = UDim2.new(0.52, 0, 0.15, 0)
whitelistFrame.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
whitelistFrame.ScrollBarThickness = 4
whitelistFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local label1 = Instance.new("TextLabel", frame)
label1.Text = "Alvos"
label1.Size = UDim2.new(0.45, 0, 0, 20)
label1.Position = UDim2.new(0.03, 0, 0.08, 0)
label1.BackgroundTransparency = 1
label1.TextColor3 = Color3.new(1,1,1)

local label2 = Instance.new("TextLabel", frame)
label2.Text = "Whitelist (Seguros)"
label2.Size = UDim2.new(0.45, 0, 0, 20)
label2.Position = UDim2.new(0.52, 0, 0.08, 0)
label2.BackgroundTransparency = 1
label2.TextColor3 = Color3.new(0.5, 1, 0.5)

Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 2)
Instance.new("UIListLayout", whitelistFrame).Padding = UDim.new(0, 2)

-- Input e Botões
local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.94, 0, 0, 30)
box.Position = UDim2.new(0.03, 0, 0.62, 0)
box.PlaceholderText = "Nome do alvo..."
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.TextColor3 = Color3.new(1, 1, 1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.45, 0, 0, 35)
toggle.Position = UDim2.new(0.03, 0, 0.75, 0)
toggle.Text = "Fling OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggle.TextColor3 = Color3.new(1, 1, 1)

local allToggle = Instance.new("TextButton", frame)
allToggle.Size = UDim2.new(0.45, 0, 0, 35)
allToggle.Position = UDim2.new(0.52, 0, 0.75, 0)
allToggle.Text = "Fling All OFF"
allToggle.BackgroundColor3 = Color3.fromRGB(0, 85, 127)
allToggle.TextColor3 = Color3.new(1, 1, 1)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ESTADOS E LOGICA DE WHITELIST
local running = false
local flingAllActive = false
local whitelist = {}

local function updateWhitelistUI()
    for _, v in ipairs(whitelistFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for name, _ in pairs(whitelist) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 20)
        btn.Text = name .. " (Remover)"
        btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Parent = whitelistFrame
        btn.MouseButton1Click:Connect(function()
            whitelist[name] = nil
            updateWhitelistUI()
        end)
    end
end

local function refreshPlayers()
    for _, v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 20)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Text = p.Name
            btn.Parent = listFrame
            
            -- Clique esquerdo seleciona pra fling, clique direito (ou segurar) manda pra whitelist
            btn.MouseButton1Click:Connect(function() box.Text = p.Name end)
            btn.MouseButton2Click:Connect(function() 
                whitelist[p.Name] = true
                updateWhitelistUI()
            end)
        end
    end
end

refreshPlayers()
game.Players.PlayerAdded:Connect(refreshPlayers)
game.Players.PlayerRemoving:Connect(refreshPlayers)

-- CORE FLING (Com checagem de Whitelist)
local function SkidFling(TargetPlayer)
    if whitelist[TargetPlayer.Name] then return end -- CANCELA SE TIVER NA LISTA
    
    local Character = plr.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local TCharacter = TargetPlayer.Character
    local TRootPart = TCharacter and TCharacter:FindFirstChild("HumanoidRootPart")
    local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")

    if not RootPart or not TRootPart or not THumanoid then return end

    getgenv().OldPos = RootPart.CFrame
    workspace.FallenPartsDestroyHeight = 0/0
    
    local BV = Instance.new("BodyVelocity", RootPart)
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    local Time = tick()
    repeat
        if not whitelist[TargetPlayer.Name] and TRootPart then
            RootPart.CFrame = TRootPart.CFrame * CFrame.Angles(math.rad(tick()*500), 0, 0)
            RootPart.Velocity = Vector3.new(9e7, 9e7, 9e7)
            task.wait()
        end
    until tick() > Time + 1.5 or not (running or flingAllActive) or whitelist[TargetPlayer.Name]

    BV:Destroy()
    RootPart.CFrame = getgenv().OldPos
    workspace.FallenPartsDestroyHeight = -500
end

-- LOGICA DOS BOTOES
allToggle.MouseButton1Click:Connect(function()
    flingAllActive = not flingAllActive
    allToggle.Text = flingAllActive and "Fling All ON" or "Fling All OFF"
    allToggle.BackgroundColor3 = flingAllActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(0, 85, 127)
    
    if flingAllActive then
        task.spawn(function()
            while flingAllActive do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= plr and not whitelist[p.Name] then
                        SkidFling(p)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "Flinging..." or "Fling OFF"
    toggle.BackgroundColor3 = running and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if running then
        local target = nil
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Name:lower():find(box.Text:lower()) then target = p break end
        end
        if target and not whitelist[target.Name] then
            task.spawn(function()
                while running do SkidFling(target) task.wait(0.1) end
            end)
        else
            running = false
            toggle.Text = "Alvo Inválido/Safe"
            task.wait(1)
            toggle.Text = "Fling OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        end
    end
end)
