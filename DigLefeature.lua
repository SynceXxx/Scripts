-- DigLegends_fit.lua
-- SynceHub - Dig Legends Features

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections = {}

-- Knit Services
local knit = RS.Packages._Index["sleitnick_knit@1.5.1"].knit.Services

-- ============================================
-- INITIALIZE
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
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
-- DIG LEGENDS FEATURES
-- ============================================

-- Auto Trophy
function Feature.toggleAutoTrophy(enabled)
    if enabled then
        if Connections.AutoTrophy then return end
        
        Connections.AutoTrophy = R.Heartbeat:Connect(function()
            task.wait(0.1)
            
            pcall(function()
                knit.FightService.RE.GetTrophyEvent:FireServer()
            end)
        end)
        
        Feature.showNotification("Auto Trophy enabled!", true)
    else
        if Connections.AutoTrophy then
            Connections.AutoTrophy:Disconnect()
            Connections.AutoTrophy = nil
        end
        Feature.showNotification("Auto Trophy disabled!", false)
    end
end

-- Auto Rewards
function Feature.toggleAutoRewards(enabled)
    if enabled then
        if Connections.AutoRewards then return end
        
        Connections.AutoRewards = R.Heartbeat:Connect(function()
            task.wait(0.5)
            
            pcall(function()
                -- Reset rewards first
                knit.OnlineRewardService.RE.ResetOnlineRewards:FireServer()
                
                -- Claim all 15 rewards
                for i = 1, 15 do
                    knit.OnlineRewardService.RE.ClaimOnlineReward:FireServer(i)
                end
            end)
        end)
        
        Feature.showNotification("Auto Rewards enabled!", true)
    else
        if Connections.AutoRewards then
            Connections.AutoRewards:Disconnect()
            Connections.AutoRewards = nil
        end
        Feature.showNotification("Auto Rewards disabled!", false)
    end
end

-- Get Diamonds (Exploit)
function Feature.getDiamonds()
    pcall(function()
        knit.RandomPotionService.RE.BuyPotionEvent:FireServer(-500000)
        Feature.showNotification("Diamonds obtained!", true)
    end)
end

-- Claim Starter Pack
function Feature.claimStarterPack()
    local success, result = pcall(function()
        return knit.OnlineRewardService.RF.ClaimStarterPack:InvokeServer()
    end)
    
    if success then
        if result then
            Feature.showNotification("Starter Pack claimed!", true)
        else
            Feature.showNotification("Already claimed!", false)
        end
    else
        -- Error occurred (usually means already claimed)
        Feature.showNotification("Already claimed or error!", false)
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
