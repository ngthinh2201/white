local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function setLowestGraphicsQuality()
    local success = pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.EnableFRM = false
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsA("Terrain") then
                part.Material = Enum.Material.SmoothPlastic
                if part:IsA("MeshPart") then
                    part.TextureID = ""
                end
            elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then
                part.Enabled = false
            end
        end
    end)
    if not success then
        warn("Error setting graphics quality")
    end
end
setLowestGraphicsQuality()

if not getgenv().disable_ui then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 1000

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    Frame.BackgroundTransparency = 1

    local Labels = {
        Name = Instance.new("TextLabel"),
        FPS = Instance.new("TextLabel"),
        Ping = Instance.new("TextLabel")
    }
    for name, label in pairs(Labels) do
        label.Parent = Frame
        label.Font = Enum.Font.SourceSans
        label.TextScaled = true
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.Size = UDim2.new(1, 0, 0, 33)
        label.Position = UDim2.new(0, 0, 0, name == "Name" and 0 or name == "FPS" and 33 or 66)
    end

    local State = {
        FrameCount = 0,
        LastUpdate = tick(),
        Hue = 0,
        UpdateInterval = 2,
        ShowFullName = false
    }

    local function updateNameDisplay()
        local name = LocalPlayer.Name
        Labels.Name.Text = State.ShowFullName and name or (#name > 3 and string.sub(name, 1, #name - 3) .. "***" or "***" .. name)
    end
    updateNameDisplay()

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.N then
            State.ShowFullName = not State.ShowFullName
            updateNameDisplay()
        end
    end)

    RunService.Heartbeat:Connect(function(deltaTime)
        State.FrameCount += 1
        State.Hue = (State.Hue + deltaTime * 0.3) % 1
        local currentTime = tick()
        if currentTime - State.LastUpdate < State.UpdateInterval then return end

        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
        local fps = math.floor(State.FrameCount / (currentTime - State.LastUpdate))
        Labels.FPS.Text = "FPS: " .. fps
        Labels.Ping.Text = "Ping: " .. ping .. " ms"

        local color = Color3.fromHSV(State.Hue, 0.8, 0.8)
        for _, label in pairs(Labels) do
            label.TextColor3 = color
        end

        State.FrameCount = 0
        State.LastUpdate = currentTime
        State.UpdateInterval = fps < 30 and 3 or 2
    end)
end

RunService:SetPhysicsThrottle(0.033)
