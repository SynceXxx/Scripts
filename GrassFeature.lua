-- feature.lua
-- SynceHub - Feature Functions for Cut Grass

local Feature = {}

local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local W = game:GetService("Workspace")
local P = game:GetService("Players")
local L = P.LocalPlayer

local C, S
local Connections = {}

-- Initialize module
function Feature.init(config, state)
    C = config
    S = state
end

-- Notification system
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

-- Cut Grass Features

-- Auto Swing Tool
function Feature.toggleAutoSwing(enabled)
    if enabled then
        if Connections.AutoSwing then return end
        
        Connections.AutoSwing = R.Heartbeat:Connect(function()
            pcall(function()
                local tool = L.Character and L.Character:FindFirstChildWhichIsA('Tool')
                if tool then
                    tool:Activate()
                end
            end)
        end)
        
        Feature.showNotification("Auto Swing enabled!", true)
    else
        if Connections.AutoSwing then
            Connections.AutoSwing:Disconnect()
            Connections.AutoSwing = nil
        end
        Feature.showNotification("Auto Swing disabled!", false)
    end
end

-- Tool Size
function Feature.updateToolSize(size)
    pcall(function()
        local tool = L.Character and L.Character:FindFirstChildWhichIsA('Tool')
        if tool and tool:FindFirstChild('Hitbox') then
            tool.Hitbox.Size = Vector3.new(size, size, size)
            tool.Hitbox.Transparency = 0.5
        end
    end)
end

-- Hide Grass
function Feature.toggleHideGrass(enabled)
    if enabled then
        if Connections.HideGrass then return end
        
        Connections.HideGrass = R.Heartbeat:Connect(function()
            pcall(function()
                if W:FindFirstChild("Grass") then
                    for _, grass in pairs(W.Grass:GetChildren()) do
                        grass.Transparency = 1
                        grass.CanCollide = false
                    end
                end
            end)
        end)
        
        Feature.showNotification("Grass hidden!", true)
    else
        if Connections.HideGrass then
            Connections.HideGrass:Disconnect()
            Connections.HideGrass = nil
        end
        
        -- Restore grass visibility
        pcall(function()
            if W:FindFirstChild("Grass") then
                for _, grass in pairs(W.Grass:GetChildren()) do
                    grass.Transparency = 0
                    grass.CanCollide = true
                end
            end
        end)
        
        Feature.showNotification("Grass visible!", false)
    end
end

-- Auto Chest
function Feature.toggleAutoChest(enabled)
    if enabled then
        if Connections.AutoChest then return end
        
        Connections.AutoChest = R.Heartbeat:Connect(function()
            task.wait(0.5)
            pcall(function()
                if not C.ChestTier or C.ChestTier == "::Select Tier::" then return end
                
                if W:FindFirstChild("LootZones") then
                    for _, descendant in pairs(W.LootZones:GetDescendants()) do
                        if descendant.Name == C.ChestTier then
                            local hrp = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
                            local hitbox = descendant:FindFirstChild("Hitbox")
                            
                            if hrp and hitbox then
                                hrp.CFrame = hitbox.CFrame
                                task.wait(0.2)
                                
                                local prompt = hitbox:FindFirstChild("ChestPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end)
        
        Feature.showNotification("Auto Chest enabled!", true)
    else
        if Connections.AutoChest then
            Connections.AutoChest:Disconnect()
            Connections.AutoChest = nil
        end
        Feature.showNotification("Auto Chest disabled!", false)
    end
end

-- Walk Speed
function Feature.updateWalkSpeed(speed)
    pcall(function()
        local humanoid = L.Character and L.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end)
end

-- Get available chest tiers
function Feature.getChestTiers()
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
    return tiers
end

-- Cleanup function
function Feature.cleanup()
    for name, conn in pairs(Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    Connections = {}
end

return Feature
