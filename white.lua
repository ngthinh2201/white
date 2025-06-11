local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function setLowestGraphicsQuality()
    local success, error = pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.EnableFRM = false
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsA("Terrain") then
                part.Material = Enum.Material.SmoothPlastic
                if part:IsA("MeshPart") then
                    part.TextureID = ""
                end
            end
            if part:IsA("ParticleEmitter") or part:IsA("Trail") then
                part.Enabled = false
            end
        end
    end)
    if not success then
        warn("Error setting graphics quality: " .. error)
    end
end
setLowestGraphicsQuality()

local hiddenState = false
local originalPartsState = {} 
local hiddenPlayers = {}

local function toggleHidePlayersAndObjects()
    hiddenState = not hiddenState
    if hiddenState then

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                hiddenPlayers[player] = player.Character
                player.Character.Parent = nil
            end
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if not obj:IsA("Terrain") and obj:IsA("BasePart") and obj.Parent ~= LocalPlayer.Character then
                originalPartsState[obj] = { Transparency = obj.Transparency, Parent = obj.Parent }
                obj.Transparency = 1
                obj.Parent = nil
            elseif not obj:IsA("Terrain") and not obj:IsA("BasePart") and obj.Parent ~= LocalPlayer.Character then
                if obj:IsA("Model") or obj:IsA("Folder") then
                    originalPartsState[obj] = { Parent = obj.Parent }
                    obj.Parent = nil
                end
            end
        end
    else
    
        for player, character in pairs(hiddenPlayers) do
            if character and player.Parent then
                character.Parent = Workspace
            end
        end
        hiddenPlayers = {}
    
        for obj, state in pairs(originalPartsState) do
            if obj then
                if obj:IsA("BasePart") then
                    obj.Transparency = state.Transparency or 0
                end
                obj.Parent = state.Parent or Workspace
            end
        end
        originalPartsState = {}
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.H then
        toggleHidePlayersAndObjects()
    end
end)
Players.PlayerAdded:Connect(function(player)
    if hiddenState and player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            if hiddenState then
                hiddenPlayers[player] = character
                character.Parent = nil
            end
        end)
    end
end)

if not getgenv().disable_ui then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 1000

    local Background = Instance.new("Frame")
    Background.Parent = ScreenGui
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.new(0, 0, 0)
    Background.ZIndex = 0
    local isBackgroundVisible = true

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 1

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
        label.ZIndex = 2
        label.Size = UDim2.new(1, 0, 0, 50)
        label.Position = UDim2.new(0, 0, 0, (name == "Name" and 0) or (name == "FPS" and 50) or 100)
    end

    local State = {
        FrameCount = 0,
        LastUpdate = tick(),
        Hue = 0,
        LastTouchEnded = 0,
        UpdateInterval = 1,
        DelayTime = 5,
        IsTouchActive = false,
        ShowFullName = false 
    }

    local function updateNameDisplay()
        if State.ShowFullName then
            Labels.Name.Text = LocalPlayer.Name
        else
            local name = LocalPlayer.Name
            if #name > 3 then
                Labels.Name.Text = string.sub(name, 1, #name - 3) .. string.rep("*", 3)
            else
                Labels.Name.Text = string.rep("*", 3 - #name) .. name
            end
        end
    end

    updateNameDisplay()
    
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.N then
            State.ShowFullName = not State.ShowFullName
            updateNameDisplay()
        end
    end)

    UserInputService.TouchStarted:Connect(function()
        if isBackgroundVisible then
            Background.Visible = false
            isBackgroundVisible = false
            State.IsTouchActive = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            State.IsTouchActive = false
            State.LastTouchEnded = tick()
        end
    end)

    local lastFrameTime = tick()
    RunService.RenderStepped:Connect(function(deltaTime)
        if tick() - lastFrameTime < 0.033 then
            return
        end
        lastFrameTime = tick()

        State.FrameCount += 1
        State.Hue = (State.Hue + deltaTime * 0.3) % 1

        local CurrentTime = tick()
        if not isBackgroundVisible and not State.IsTouchActive and CurrentTime - State.LastTouchEnded >= State.DelayTime then
            Background.Visible = true
            isBackgroundVisible = true
        end

        if CurrentTime - State.LastUpdate < State.UpdateInterval then return end

        local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
        local FPS = math.floor(State.FrameCount / (CurrentTime - State.LastUpdate))
        Labels.FPS.Text = "FPS: " .. FPS
        Labels.Ping.Text = "Ping: " .. Ping .. " ms"

        local color = Color3.fromHSV(State.Hue, 0.8, 0.8)
        for _, label in pairs(Labels) do
            label.TextColor3 = color
        end

        State.FrameCount = 0
        State.LastUpdate = CurrentTime
        State.UpdateInterval = FPS < 30 and 2 or 1
    end)
end

RunService:SetPhysicsThrottle(0.033) 
