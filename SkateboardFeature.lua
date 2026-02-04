-- SynceHub - Skateboard Training Features

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local W = game:GetService("Workspace")
local P = game:GetService("Players")
local L = P.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections = {}

-- Remotes
local Remotes = {
    LuckyWheelTicket = nil,
    TrainStart = nil,
    DailyGacha = nil
}

-- ============================================
-- INITIALIZE
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
    
    -- Get remotes
    pcall(function()
        Remotes.LuckyWheelTicket = RS:WaitForChild("RemoteFunction")
        Remotes.TrainStart = RS:WaitForChild("RemoteEvent")
        Remotes.DailyGacha = RS:WaitForChild("RemoteFunction")
    end)
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
function Feature.showNotification(m, s)
    if not S.G then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = s and "rbxassetid://6026984224" or "rbxassetid://6026984224"
    sound.Volume = s and 0.5 or 0.4
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
    
    spawn(function()
        local n = S.G:FindFirstChild("NotifContainer")
        if not n then
            n = Instance.new("Frame")
            n.Name = "NotifContainer"
            n.Size = UDim2.new(0, 280, 1, 0)
            n.Position = UDim2.new(1, -290, 0, 10)
            n.BackgroundTransparency = 1
            n.ZIndex = 1000
            n.Parent = S.G
            
            local l = Instance.new("UIListLayout")
            l.Padding = UDim.new(0, 8)
            l.SortOrder = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Top
            l.Parent = n
        end
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel = 0
        f.ZIndex = 1001
        f.LayoutOrder = #S.NotifQueue + 1
        f.Parent = n
        
        table.insert(S.NotifQueue, f)
        
        local c = Instance.new("UICorner", f)
        c.CornerRadius = UDim.new(0, 12)
        
        local st = Instance.new("UIStroke", f)
        st.Color = Color3.fromRGB(200, 200, 210)
        st.Thickness = 2
        st.Transparency = 0.5
        
        local i = Instance.new("ImageLabel")
        i.Size = UDim2.new(0, 24, 0, 24)
        i.Position = UDim2.new(0, 12, 0, 12)
        i.BackgroundTransparency = 1
        i.Image = s and "rbxassetid://140507950554297" or "rbxassetid://118025272389341"
        i.ImageColor3 = Color3.fromRGB(200, 200, 210)
        i.ZIndex = 1002
        i.Parent = f
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -52, 1, 0)
        t.Position = UDim2.new(0, 44, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = m
        t.TextColor3 = Color3.fromRGB(240, 240, 245)
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.ZIndex = 1002
        t.Parent = f
        
        local h = 48
        f.Position = UDim2.new(1, 20, 0, 0)
        T:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, h),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.4)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
        task.wait(2.5)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        T:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        T:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
        T:Create(st, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        task.wait(0.3)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        f:Destroy()
        
        for i, v in ipairs(S.NotifQueue) do
            if v == f then
                table.remove(S.NotifQueue, i)
                break
            end
        end
    end)
end

-- ============================================
-- SKATEBOARD TRAINING FEATURES
-- ============================================

-- Walk Speed
function Feature.updateWalkSpeed(speed)
    pcall(function()
        local humanoid = L.Character and L.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end)
end

-- Auto Get Lucky Wheel Ticket (Toggle - Spam)
function Feature.toggleLuckyTicket(enabled)
    if enabled then
        if Connections.LuckyTicket then return end
        
        if not Remotes.LuckyWheelTicket then
            Feature.showNotification("Lucky Wheel remote not found!", false)
            return
        end
        
        Connections.LuckyTicket = R.Heartbeat:Connect(function()
            pcall(function()
                Remotes.LuckyWheelTicket:InvokeServer("lucky_wheel_get_ticket", {["1"] = 6})
            end)
        end)
        
        Feature.showNotification("Lucky Wheel Ticket spam enabled!", true)
    else
        if Connections.LuckyTicket then
            Connections.LuckyTicket:Disconnect()
            Connections.LuckyTicket = nil
        end
        Feature.showNotification("Lucky Wheel Ticket spam disabled!", false)
    end
end

-- Start Train (Button - Single Fire)
function Feature.startTrain()
    if not Remotes.TrainStart then
        Feature.showNotification("Train Start remote not found!", false)
        return
    end
    
    pcall(function()
        Remotes.TrainStart:FireServer("train_start", true, {["1"] = 42})
        Feature.showNotification("Train started!", true)
    end)
end

-- Auto Spin (Toggle - Loop dengan custom amount)
function Feature.toggleAutoSpin(enabled)
    if enabled then
        if Connections.AutoSpin then return end
        
        if not Remotes.DailyGacha then
            Feature.showNotification("Daily Gacha remote not found!", false)
            return
        end
        
        -- Get spin amount dari config
        local spinAmount = C.SpinAmount or 10
        
        Connections.AutoSpin = R.Heartbeat:Connect(function()
            task.wait(0.1) -- Delay kecil biar ga spam banget
            
            pcall(function()
                Remotes.DailyGacha:InvokeServer("client_daily_gacha_reward", {["1"] = spinAmount})
            end)
        end)
        
        Feature.showNotification("Auto Spin enabled! (Amount: " .. spinAmount .. ")", true)
    else
        if Connections.AutoSpin then
            Connections.AutoSpin:Disconnect()
            Connections.AutoSpin = nil
        end
        Feature.showNotification("Auto Spin disabled!", false)
    end
end

-- Player ESP (Red Highlight)
function Feature.togglePlayerESP(enabled)
    if enabled then
        if Connections.PlayerESP then return end
        
        -- Function to add ESP to a player
        local function addESP(player)
            if player == L then return end -- Skip local player
            
            local char = player.Character
            if not char then return end
            
            -- Check if ESP already exists
            if char:FindFirstChild("ESPHighlight") then return end
            
            -- Create Highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Red
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end
        
        -- Function to remove ESP from a player
        local function removeESP(player)
            local char = player.Character
            if char then
                local highlight = char:FindFirstChild("ESPHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        
        -- Add ESP to existing players
        for _, player in pairs(P:GetPlayers()) do
            if player.Character then
                addESP(player)
            end
            
            -- Handle character respawn
            player.CharacterAdded:Connect(function(char)
                if C.PlayerESP then
                    task.wait(0.5) -- Wait for character to load
                    addESP(player)
                end
            end)
        end
        
        -- Add ESP to new players
        Connections.PlayerESP = P.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                if C.PlayerESP then
                    task.wait(0.5)
                    addESP(player)
                end
            end)
        end)
        
        -- Monitor for character changes
        Connections.PlayerESPMonitor = R.Heartbeat:Connect(function()
            if not C.PlayerESP then return end
            
            for _, player in pairs(P:GetPlayers()) do
                if player ~= L and player.Character then
                    if not player.Character:FindFirstChild("ESPHighlight") then
                        addESP(player)
                    end
                end
            end
        end)
        
        Feature.showNotification("Player ESP enabled!", true)
    else
        -- Remove all ESP
        for _, player in pairs(P:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        
        if Connections.PlayerESP then
            Connections.PlayerESP:Disconnect()
            Connections.PlayerESP = nil
        end
        
        if Connections.PlayerESPMonitor then
            Connections.PlayerESPMonitor:Disconnect()
            Connections.PlayerESPMonitor = nil
        end
        
        Feature.showNotification("Player ESP disabled!", false)
    end
end

-- Anti-AFK
function Feature.toggleAntiAFK(enabled)
    if enabled then
        if Connections.AntiAFK then return end
        
        -- Prevent idle kick by sending small movements
        Connections.AntiAFK = R.Heartbeat:Connect(function()
            task.wait(60) -- Every 60 seconds
            
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
        
        Feature.showNotification("Anti-AFK enabled!", true)
    else
        if Connections.AntiAFK then
            Connections.AntiAFK:Disconnect()
            Connections.AntiAFK = nil
        end
        Feature.showNotification("Anti-AFK disabled!", false)
    end
end

-- ============================================
-- CLEANUP FUNCTION
-- ============================================
function Feature.cleanup()
    for name, conn in pairs(Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    Connections = {}
end

return Feature
