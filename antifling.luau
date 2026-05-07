--// Services
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui", plr.PlayerGui)
gui.Name = "AntiFling_Hub_Pro"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,320)
frame.Position = UDim2.new(0.5,-160,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Anti-Fling System"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-10,1,-45)
scroll.Position = UDim2.new(0,5,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

--// Variáveis de Controle
local AntiFlingEnabled = false
local GodAntiFling = false -- Modo agressivo

--// Função de Toggle (O mesmo estilo que você gosta)
local function makeToggle(text, targetState, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-8,0,45)
    local state = targetState
    btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = text.." "..(state and "ON" or "OFF")

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
    
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    return btn
end

--// Lógica Principal de Anti-Fling
-- Este é o sistema que simula o que scripts avançados do GitHub fazem
RunService.Stepped:Connect(function()
    if AntiFlingEnabled then
        local char = plr.Character
        if char then
            -- 1. Desativa colisão interna para evitar ser jogado pelo próprio corpo
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    -- Se a velocidade subir demais (tentativa de fling), ele trava
                    if part.Velocity.Magnitude > 40 then
                        part.Velocity = Vector3.new(0,0,0)
                        part.RotVelocity = Vector3.new(0,0,0)
                    end
                end
            end
            
            -- 2. Anti-Fling Agressivo (Lida com outros players)
            for _, other in pairs(game:GetService("Players"):GetPlayers()) do
                if other ~= plr and other.Character then
                    for _, otherPart in pairs(other.Character:GetDescendants()) do
                        if otherPart:IsA("BasePart") then
                            otherPart.CanCollide = false
                            -- Se o modo God estiver on, removemos a força de quem chega perto
                            if GodAntiFling then
                                otherPart.Velocity = Vector3.new(0,0,0)
                                otherPart.RotVelocity = Vector3.new(0,0,0)
                            end
                        end
                    end
                end
            end
        end
    end
end)

--// Controles
makeToggle("Anti-Fling Base", false, function(s)
    AntiFlingEnabled = s
end)

makeToggle("God Mode Anti-Fling", false, function(s)
    GodAntiFling = s
end)

-- Botão fechar
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,25,0,25)
close.Position = UDim2.new(1,-28,0,4)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
