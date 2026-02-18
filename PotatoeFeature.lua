-- PotatoFeature.lua
-- SynceHub - Potato Idle
-- Game-specific features

local Feature = {}

-- ============================================
-- SERVICES (JANGAN DIUBAH)
-- ============================================
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

-- ============================================
-- VARIABLES (JANGAN DIUBAH)
-- ============================================
local C, S
local Connections = {}

-- Pre-load sounds supaya tidak ada delay saat pertama dipakai
local function preloadSounds()
    local ids = {"rbxassetid://6026984224", "rbxassetid://4590662766"}
    for _, id in ipairs(ids) do
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 0
        s.Parent = game:GetService("SoundService")
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end
end
task.spawn(preloadSounds)

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

    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = s and "rbxassetid://6026984224" or "rbxassetid://4590662766"
        sound.Volume = s and 0.5 or 0.4
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)

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

        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

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

-- Auto Click Brutal Spam (Toggle)
-- task.spawn loop — bukan Heartbeat
function Feature.toggleAutoClick(enabled)
    if enabled then
        if Connections.AutoClick then return end

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
                if C.ClickDelay and C.ClickDelay > 0 then
                    task.wait(C.ClickDelay)
                else
                    task.wait() -- 1 frame ~60x/detik, paling brutal
                end
            end
        end)
    else
        Connections.AutoClick = nil
        Feature.showNotification("Auto Click disabled!", false)
    end
end

-- ============================================
-- CLEANUP FUNCTION (JANGAN DIUBAH)
-- ============================================
function Feature.cleanup()
    Connections.AutoClick = nil
    Connections = {}
end

return Feature
