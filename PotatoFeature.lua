-- PotatoFeature.lua
-- SynceHub - Potato Idle Features

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

-- ============================================
-- INITIALIZE
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
    sound.SoundId = s and "rbxassetid://6026984224" or "rbxassetid://4590662766"
    sound.Volume = s and 0.5 or 0.4
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
    
    task.spawn(function()
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
-- POTATO IDLE FEATURES
-- ============================================

-- Counter untuk track clicks per second (opsional, untuk display)
local clickCount = 0
local cpsThread = nil

-- Feature: Auto Click Brutal Spam (Toggle)
-- Pakai task.spawn + loop, BUKAN Heartbeat, agar tidak ada accumulated connections
function Feature.toggleAutoClick(enabled)
    if enabled then
        if Connections.AutoClick then return end

        -- Loop terpisah dengan task.spawn — jauh lebih bersih dan brutal
        Connections.AutoClick = true
        task.spawn(function()
            local Event = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("PerformClick")
            if not Event then
                Feature.showNotification("RemoteEvent PerformClick not found!", false)
                Connections.AutoClick = nil
                C.AutoClick = false
                return
            end

            Feature.showNotification("Auto Click BRUTAL enabled!", true)

            while Connections.AutoClick do
                pcall(function()
                    Event:FireServer()
                end)
                clickCount = clickCount + 1

                -- ClickDelay = 0 → pakai task.wait() minimal (1 frame)
                -- ClickDelay > 0 → pakai delay custom
                if C.ClickDelay and C.ClickDelay > 0 then
                    task.wait(C.ClickDelay)
                else
                    task.wait() -- 1 frame = ~0.016s, paling brutal bisa dilakukan
                end
            end
        end)

        -- CPS counter (opsional, reset tiap detik)
        cpsThread = task.spawn(function()
            while Connections.AutoClick do
                task.wait(1)
                clickCount = 0
            end
        end)

    else
        Connections.AutoClick = nil
        if cpsThread then
            task.cancel(cpsThread)
            cpsThread = nil
        end
        clickCount = 0
        Feature.showNotification("Auto Click disabled!", false)
    end
end

-- ============================================
-- CLEANUP FUNCTION (JANGAN DIUBAH)
-- ============================================
function Feature.cleanup()
    -- Stop auto click loop
    Connections.AutoClick = nil
    if cpsThread then
        pcall(function() task.cancel(cpsThread) end)
        cpsThread = nil
    end
    Connections = {}
end

return Feature
