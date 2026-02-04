-- Features.lua
-- SynceHub - Skateboard Training Features

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
-- SKATEBOARD TRAINING FEATURES
-- ============================================

-- Feature 1: Auto Ticket Lucky Wheel (Toggle)
function Feature.toggleAutoTicket(enabled)
    if enabled then
        if Connections.AutoTicket then return end
        
        Connections.AutoTicket = R.Heartbeat:Connect(function()
            task.wait(C.TicketDelay or 0.1)
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
        
        Feature.showNotification("Auto Ticket Lucky Wheel enabled!", true)
    else
        if Connections.AutoTicket then
            Connections.AutoTicket:Disconnect()
            Connections.AutoTicket = nil
        end
        Feature.showNotification("Auto Ticket Lucky Wheel disabled!", false)
    end
end

-- Feature 2: OP Auto Train (Button)
function Feature.doAutoTrain()
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
            Feature.showNotification("OP Auto Train executed!", true)
        else
            Feature.showNotification("RemoteEvent not found!", false)
        end
    end)
end

-- Feature 3: Update Spin Amount (Input)
function Feature.updateSpinAmount(amount)
    local num = tonumber(amount)
    if num and num > 0 then
        C.SpinAmount = num
        Feature.showNotification("Spin amount set to " .. num, true)
    else
        Feature.showNotification("Invalid spin amount!", false)
    end
end

-- Feature 4: Auto Spin (Toggle)
function Feature.toggleAutoSpin(enabled)
    if enabled then
        if Connections.AutoSpin then return end
        
        Connections.AutoSpin = R.Heartbeat:Connect(function()
            task.wait(C.SpinDelay or 0.5)
            pcall(function()
                local Event = RS:FindFirstChild("RemoteFunction")
                if Event then
                    Event:InvokeServer(
                        "client_daily_gacha_reward",
                        {
                            ["1"] = C.SpinAmount or 10
                        }
                    )
                end
            end)
        end)
        
        Feature.showNotification("Auto Spin enabled with " .. (C.SpinAmount or 10) .. " spins!", true)
    else
        if Connections.AutoSpin then
            Connections.AutoSpin:Disconnect()
            Connections.AutoSpin = nil
        end
        Feature.showNotification("Auto Spin disabled!", false)
    end
end

-- Feature 5: Manual Spin (Button) - Spin sekali dengan jumlah yang ditentukan
function Feature.doManualSpin()
    pcall(function()
        local Event = RS:FindFirstChild("RemoteFunction")
        if Event then
            Event:InvokeServer(
                "client_daily_gacha_reward",
                {
                    ["1"] = C.SpinAmount or 10
                }
            )
            Feature.showNotification("Manual spin executed (" .. (C.SpinAmount or 10) .. " spins)!", true)
        else
            Feature.showNotification("RemoteFunction not found!", false)
        end
    end)
end

-- Feature 6: Update Ticket Delay (Slider)
function Feature.updateTicketDelay(delay)
    C.TicketDelay = delay
    -- No notification needed for slider updates
end

-- Feature 7: Update Spin Delay (Slider)
function Feature.updateSpinDelay(delay)
    C.SpinDelay = delay
    -- No notification needed for slider updates
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
