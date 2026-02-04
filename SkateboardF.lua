-- Features.lua
-- SynceHub Template - Feature Functions
-- Copy this file and modify for your game!

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
-- YOUR GAME FEATURES (UBAH & TAMBAH DI SINI!)
-- ============================================

--[[
    CONTOH STRUKTUR FEATURE:
    
    1. Slider Feature:
    function Feature.updateSomething(value)
        -- Your code here
    end
    
    2. Toggle Feature:
    function Feature.toggleSomething(enabled)
        if enabled then
            -- Enable code
            if Connections.SomeName then return end
            Connections.SomeName = R.Heartbeat:Connect(function()
                -- Loop code
            end)
        else
            -- Disable code
            if Connections.SomeName then
                Connections.SomeName:Disconnect()
                Connections.SomeName = nil
            end
        end
    end
    
    3. Button Feature:
    function Feature.doSomething()
        -- Your code here
    end
    
    4. Dropdown Get Options:
    function Feature.getSomethingList()
        local list = {}
        -- Get list from game
        return list
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

-- Ticket Lucky Wheel (Toggle - Loop spam)
function Feature.toggleTicketLuckyWheel(enabled)
    if enabled then
        if Connections.TicketLuckyWheel then return end
        
        Connections.TicketLuckyWheel = R.Heartbeat:Connect(function()
            task.wait(0.1) -- Delay to prevent spam
            
            pcall(function()
                local Event = RS:FindFirstChild("RemoteFunction")
                if Event then
                    Event:InvokeServer(
                        "lucky_wheel_get_ticket",
                        {
                            ["1"] = 6
                        }
                    )
                end
            end)
        end)
        
        Feature.showNotification("Ticket Lucky Wheel enabled!", true)
    else
        if Connections.TicketLuckyWheel then
            Connections.TicketLuckyWheel:Disconnect()
            Connections.TicketLuckyWheel = nil
        end
        Feature.showNotification("Ticket Lucky Wheel disabled!", false)
    end
end

-- OP Auto Train (Button - One click)
function Feature.opAutoTrain()
    pcall(function()
        local Event = RS:FindFirstChild("RemoteEvent")
        if Event then
            Event:FireServer(
                "train_start",
                true,
                {
                    ["1"] = 42
                }
            )
            Feature.showNotification("OP Auto Train activated!", true)
        else
            Feature.showNotification("RemoteEvent not found!", false)
        end
    end)
end

-- Auto Spin (Toggle - Loop dengan amount dari input)
function Feature.toggleAutoSpin(enabled)
    if enabled then
        if Connections.AutoSpin then return end
        
        -- Validate spin amount
        if not C.SpinAmount or C.SpinAmount <= 0 then
            Feature.showNotification("Please set Spin Amount first!", false)
            return
        end
        
        Connections.AutoSpin = R.Heartbeat:Connect(function()
            task.wait(0.5) -- Delay to prevent spam
            
            pcall(function()
                local Event = RS:FindFirstChild("RemoteFunction")
                if Event then
                    Event:InvokeServer(
                        "client_daily_gacha_reward",
                        {
                            ["1"] = C.SpinAmount
                        }
                    )
                end
            end)
        end)
        
        Feature.showNotification("Auto Spin enabled! (" .. C.SpinAmount .. " spins)", true)
    else
        if Connections.AutoSpin then
            Connections.AutoSpin:Disconnect()
            Connections.AutoSpin = nil
        end
        Feature.showNotification("Auto Spin disabled!", false)
    end
end
    local tiers = {}
    local tierSet = {}
    
    pcall(function()
        if W:FindFirstChild("LootZones") then
            for _, descendant in pairs(W.LootZones:GetDescendants()) do
                if descendant.Name == "ChestPrompt" then
                    local tierName = descendant.Parent.Parent.Name
                    if not tierSet[tierName] then
                        tierSet[tierName] = true
                        table.insert(tiers, tierName)
                    end
                end
            end
        end
    end)
    
    table.sort(tiers)
    table.insert(tiers, 1, "::Select Tier::")
    return tiers
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
