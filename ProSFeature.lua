-- Features.lua
-- SynceHub - Pro Soccer Simulator
-- Game-specific features

local Feature = {}

-- ============================================
-- SERVICES (JANGAN DIUBAH)
-- ============================================
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local W = game:GetService("Workspace")
local P = game:GetService("Players")
local L = P.LocalPlayer

-- ============================================
-- VARIABLES (JANGAN DIUBAH)
-- ============================================
local C, S
local Connections = {}

-- ============================================
-- INITIALIZE (JANGAN DIUBAH)
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
end

-- ============================================
-- NOTIFICATION SYSTEM (JANGAN DIUBAH)
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
-- PRO SOCCER SIMULATOR FEATURES
-- ============================================

-- Feature 1: Auto Train OP with Dropdown (G3/G5)
function Feature.getTrainModes()
    return {"::Select Mode::", "G3", "G5"}
end

function Feature.toggleAutoTrainOP(enabled)
    if enabled then
        if Connections.AutoTrain then return end
        
        -- Check if training mode is selected
        if not C.TrainMode or C.TrainMode == "::Select Mode::" then
            Feature.showNotification("Please select training mode first!", false)
            return
        end
        
        Connections.AutoTrain = R.Heartbeat:Connect(function()
            pcall(function()
                task.wait(0.5) -- Delay to prevent spam
                
                local Event = RS:FindFirstChild("Events")
                if Event and Event:FindFirstChild("Train") and Event.Train:FindFirstChild("Complete") then
                    Event.Train.Complete:FireServer(C.TrainMode)
                end
            end)
        end)
        
        Feature.showNotification("Auto Train OP (" .. C.TrainMode .. ") enabled!", true)
    else
        if Connections.AutoTrain then
            Connections.AutoTrain:Disconnect()
            Connections.AutoTrain = nil
        end
        Feature.showNotification("Auto Train OP disabled!", false)
    end
end

-- Feature 2: Buy OP Ball with Dropdown (3 options)
function Feature.getBallTypes()
    return {"::Select Ball::", "BallGhostShip", "BallAurora", "BallUFO"}
end

function Feature.buyOPBall()
    pcall(function()
        if not C.BallType or C.BallType == "::Select Ball::" then
            Feature.showNotification("Please select a ball type first!", false)
            return
        end
        
        local Event = RS:FindFirstChild("Events")
        if Event and Event:FindFirstChild("Ball") and Event.Ball:FindFirstChild("Request") then
            Event.Ball.Request:FireServer(C.BallType)
            Feature.showNotification("Purchasing " .. C.BallType .. "...", true)
        else
            Feature.showNotification("Ball event not found!", false)
        end
    end)
end

-- Feature 3: Buy Pet OP (Hydra Egg x3)
function Feature.buyPetOP()
    pcall(function()
        local Event = RS:FindFirstChild("Events")
        if Event and Event:FindFirstChild("Egg") and Event.Egg:FindFirstChild("Hatching") then
            Event.Egg.Hatching:FireServer("HydraEgg", 3, {})
            Feature.showNotification("Purchasing Hydra Pet x3...", true)
        else
            Feature.showNotification("Egg hatching event not found!", false)
        end
    end)
end

-- ============================================
-- RESET ALL FEATURES (AUTO OFF SEMUA)
-- ============================================
function Feature.resetAllFeatures()
    -- Turn off Auto Train OP if active
    if Connections.AutoTrain then
        Connections.AutoTrain:Disconnect()
        Connections.AutoTrain = nil
    end
    
    -- Reset config to default
    if C then
        C.AutoTrainOP = false
        C.TrainMode = "::Select Mode::"
        C.BallType = "::Select Ball::"
    end
    
    -- Show notification
    Feature.showNotification("All features reset!", false)
end

-- ============================================
-- CLEANUP FUNCTION (JANGAN DIUBAH)
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
