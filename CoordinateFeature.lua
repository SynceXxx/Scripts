-- CoordinateFeature.lua
-- SynceHub - Coordinate Tracker Features
-- Universal features for any game

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
-- COORDINATE TRACKER FEATURES
-- ============================================

-- Feature 1: Get Current Position
function Feature.getPosition()
    pcall(function()
        local character = L.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position
                local coordText = string.format("X: %.2f | Y: %.2f | Z: %.2f", pos.X, pos.Y, pos.Z)
                C.CoordinateText = coordText
                Feature.showNotification("Position captured!", true)
                return coordText
            end
        end
        Feature.showNotification("HumanoidRootPart not found!", false)
        return "HumanoidRootPart not found"
    end)
end

-- Feature 2: Copy Coordinates to Clipboard
function Feature.copyCoordinates()
    pcall(function()
        if C.CoordinateText == "" or C.CoordinateText == "Coordinates: " then
            Feature.showNotification("No coordinates to copy!", false)
            return
        end
        
        if setclipboard then
            local cleanCoords = C.CoordinateText:gsub("X: ", ""):gsub("Y: ", ""):gsub("Z: ", ""):gsub(" | ", ", ")
            setclipboard(cleanCoords)
            Feature.showNotification("Coordinates copied!", true)
        else
            Feature.showNotification("Clipboard not supported!", false)
        end
    end)
end

-- Feature 3: Clear Coordinates
function Feature.clearCoordinates()
    C.CoordinateText = ""
    Feature.showNotification("Coordinates cleared!", true)
end

-- Feature 4: Teleport to Coordinates
function Feature.teleportToCoordinates()
    pcall(function()
        if C.CoordinateText == "" or C.CoordinateText == "Coordinates: " then
            Feature.showNotification("No coordinates to teleport!", false)
            return
        end
        
        -- Parse coordinates from text
        local coords = {}
        for num in C.CoordinateText:gmatch("[-+]?%d*%.?%d+") do
            table.insert(coords, tonumber(num))
        end
        
        if #coords ~= 3 then
            Feature.showNotification("Invalid coordinates format!", false)
            return
        end
        
        local character = L.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(coords[1], coords[2], coords[3])
                Feature.showNotification("Teleported successfully!", true)
            else
                Feature.showNotification("HumanoidRootPart not found!", false)
            end
        else
            Feature.showNotification("Character not found!", false)
        end
    end)
end

-- Feature 5: Copy Teleport Script
function Feature.copyTeleportScript()
    pcall(function()
        if C.CoordinateText == "" or C.CoordinateText == "Coordinates: " then
            Feature.showNotification("No coordinates to copy script!", false)
            return
        end
        
        -- Parse coordinates from text
        local coords = {}
        for num in C.CoordinateText:gmatch("[-+]?%d*%.?%d+") do
            table.insert(coords, tonumber(num))
        end
        
        if #coords ~= 3 then
            Feature.showNotification("Invalid coordinates format!", false)
            return
        end
        
        if setclipboard then
            local script = string.format([[
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")
root.CFrame = CFrame.new(%f, %f, %f)
]], coords[1], coords[2], coords[3])
            
            setclipboard(script)
            Feature.showNotification("Teleport script copied!", true)
        else
            Feature.showNotification("Clipboard not supported!", false)
        end
    end)
end

-- Feature 6: Rejoin Server
function Feature.rejoinServer()
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        
        Feature.showNotification("Rejoining server...", true)
        task.wait(1)
        
        TeleportService:Teleport(PlaceId, L)
    end)
end

-- Feature 7: Walk Speed
function Feature.setWalkSpeed(speed)
    if Connections.WalkSpeed then
        Connections.WalkSpeed:Disconnect()
        Connections.WalkSpeed = nil
    end
    
    local function updateWalkSpeed()
        pcall(function()
            local character = L.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = speed
                end
            end
        end)
    end
    
    -- Set initial walk speed
    updateWalkSpeed()
    
    -- Keep updating (in case character respawns)
    Connections.WalkSpeed = R.Heartbeat:Connect(function()
        updateWalkSpeed()
    end)
    
    Feature.showNotification("Walk Speed set to " .. tostring(speed), true)
end

-- ============================================
-- RESET ALL FEATURES
-- ============================================
function Feature.resetAllFeatures()
    -- Turn off Walk Speed if active
    if Connections.WalkSpeed then
        Connections.WalkSpeed:Disconnect()
        Connections.WalkSpeed = nil
        -- Reset to default walk speed
        pcall(function()
            local character = L.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end)
    end
    
    -- Reset config to default
    if C then
        C.CoordinateText = ""
        C.WalkSpeed = 16
    end
    
    -- Show notification
    Feature.showNotification("All features reset!", false)
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
