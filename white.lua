local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local EoBVWnUPxyC = http_request or request or (syn and syn.request)
if not EoBVWnUPxyC then return end

if not getgenv().disable_ui then
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 1000 

    local Background = Instance.new("Frame", ScreenGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Position = UDim2.new(0, 0, 0, 0)
    Background.BackgroundColor3 = Color3.new(0, 0, 0)
    Background.BackgroundTransparency = 0
    Background.ZIndex = 0
    local isBackgroundVisible = true

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 1

    local Labels = {
        Name = Instance.new("TextLabel", Frame),
        FPS = Instance.new("TextLabel", Frame),
        Ping = Instance.new("TextLabel", Frame)
    }
    for name, label in pairs(Labels) do
        label.Font = Enum.Font.FredokaOne
        label.TextScaled = true
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.ZIndex = 2
        if name == "Name" then
            label.Size, label.Position = UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 0)
        elseif name == "FPS" then
            label.Size, label.Position = UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 50)
        elseif name == "Ping" then
            label.Size, label.Position = UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 100)
        end
    end

    local State = {
        FrameCount = 0,
        LastUpdate = tick(),
        Hue = 0,
        UpdateInterval = 1,
        ColorCache = Color3.new(1, 1, 1)
    }

    
    UserInputService.TouchStarted:Connect(function(input)
        if isBackgroundVisible then
            Background.Visible = false
            isBackgroundVisible = false
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not isBackgroundVisible and input.UserInputType == Enum.UserInputType.Touch then
            Background.Visible = true
            isBackgroundVisible = true
        end
    end)

    
    RunService.Heartbeat:Connect(function(deltaTime)
        State.FrameCount = State.FrameCount + 1
        State.Hue = (State.Hue + deltaTime * 0.5) % 1
        State.ColorCache = Color3.fromHSV(State.Hue, 1, 1)

        local CurrentTime = tick()
        if CurrentTime - State.LastUpdate >= State.UpdateInterval then
            local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
            local FPS = math.floor(State.FrameCount / (CurrentTime - State.LastUpdate))
            Labels.Name.Text = LocalPlayer.Name
            Labels.FPS.Text = "FPS: " .. FPS
            Labels.Ping.Text = "Ping: " .. Ping .. " ms"
            State.FrameCount, State.LastUpdate = 0, CurrentTime

    
            if FPS < 30 then State.UpdateInterval = 2 else State.UpdateInterval = 1 end
        end

        for _, label in pairs(Labels) do
            label.TextColor3 = State.ColorCache
        end
    end)
end
