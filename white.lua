local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

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
        label.Font = Enum.Font.FredokaOne
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
        IsTouchActive = false
    }

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

    Labels.Name.Text = LocalPlayer.Name

    RunService.RenderStepped:Connect(function(deltaTime)
        State.FrameCount += 1
        State.Hue = (State.Hue + deltaTime * 0.5) % 1

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

        local color = Color3.fromHSV(State.Hue, 1, 1)
        for _, label in pairs(Labels) do
            label.TextColor3 = color
        end

        State.FrameCount = 0
        State.LastUpdate = CurrentTime
        State.UpdateInterval = FPS < 30 and 2 or 1
    end)
end
