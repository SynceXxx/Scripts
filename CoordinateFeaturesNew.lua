-- CoordinateFeatures.lua
-- SynceHub - Coordinate Tracker Features
-- Universal features for any game

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local L = P.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections = {}
local soundCache = {}
local notifSeq = 0

local NOTIF_MAX = 4 -- maksimal notifikasi tampil bersamaan
local NOTIF_SOUND = "rbxassetid://6026984224"

-- ============================================
-- INITIALIZE
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
end

-- ============================================
-- SOUND (satu Sound per ID, dipakai ulang)
-- ============================================
function Feature.playSound(id, volume)
    pcall(function()
        local snd = soundCache[id]
        if not snd or not snd.Parent then
            snd = Instance.new("Sound")
            snd.SoundId = id
            snd.Parent = SoundService
            soundCache[id] = snd
        end
        snd.Volume = volume or 0.5
        snd.TimePosition = 0
        snd:Play()
    end)
end

-- ============================================
-- NOTIFICATION SYSTEM
-- s: true = sukses, false = gagal, "warn" = peringatan (ungu)
-- ============================================
function Feature.showNotification(m, s)
    if not S or not S.G then return end

    Feature.playSound(NOTIF_SOUND, s and 0.5 or 0.4)

    task.spawn(function()
        local n = S.G:FindFirstChild("NotifContainer")
        if not n then
            n = Instance.new("Frame")
            n.Name = "NotifContainer"
            n.Size = UDim2.new(0, 280, 1, 0)
            n.Position = UDim2.new(1, -290, 0, 10)
            n.BackgroundTransparency = 1
            n.ZIndex = 1000

            local l = Instance.new("UIListLayout")
            l.Padding = UDim.new(0, 8)
            l.SortOrder = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Top
            l.Parent = n

            n.Parent = S.G
        end

        -- Batasi jumlah notifikasi: buang yang paling lama
        local queue = S.NotifQueue
        while #queue >= NOTIF_MAX do
            local old = table.remove(queue, 1)
            if old then old:Destroy() end
        end

        local warnStyle = (s == "warn")

        notifSeq = notifSeq + 1

        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3 = warnStyle and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(30, 30, 35)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel = 0
        f.ZIndex = 1001
        f.LayoutOrder = notifSeq

        local c = Instance.new("UICorner", f)
        c.CornerRadius = UDim.new(0, 12)

        local st = Instance.new("UIStroke", f)
        st.Color = warnStyle and Color3.fromRGB(110, 120, 255) or Color3.fromRGB(200, 200, 210)
        st.Thickness = 2
        st.Transparency = 0.5

        local i = Instance.new("ImageLabel")
        i.Size = UDim2.new(0, 24, 0, 24)
        i.Position = UDim2.new(0, 12, 0, 12)
        i.BackgroundTransparency = 1
        i.Image = (s == true) and "rbxassetid://140507950554297" or "rbxassetid://118025272389341"
        i.ImageColor3 = warnStyle and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
        i.ZIndex = 1002
        i.Parent = f

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -52, 1, 0)
        t.Position = UDim2.new(0, 44, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = m
        t.TextColor3 = warnStyle and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(240, 240, 245)
        t.Font = warnStyle and Enum.Font.GothamBold or Enum.Font.GothamMedium
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.ZIndex = 1002
        t.Parent = f

        f.Position = UDim2.new(1, 20, 0, 0)
        f.Parent = n
        table.insert(queue, f)

        T:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 48),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        task.wait(0.4)
        if not f.Parent then return end
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
        task.wait(2.5)
        if not f.Parent then return end

        local fade = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
        T:Create(f, fade, {BackgroundTransparency = 1}):Play()
        T:Create(t, fade, {TextTransparency = 1}):Play()
        T:Create(i, fade, {ImageTransparency = 1}):Play()
        T:Create(st, fade, {Transparency = 1}):Play()
        task.wait(0.3)
        if not f.Parent then return end
        T:Create(f, fade, {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        f:Destroy()

        for idx, v in ipairs(queue) do
            if v == f then
                table.remove(queue, idx)
                break
            end
        end
    end)
end

-- ============================================
-- HELPERS
-- ============================================
local function getRoot()
    local character = L.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function hasText()
    local text = C and C.CoordinateText
    return text ~= nil and text ~= ""
end

-- Ambil 3 angka (X, Y, Z) dari teks koordinat. Return nil kalau format salah.
local function parseCoords()
    local coords = {}
    for num in C.CoordinateText:gmatch("[-+]?%d*%.?%d+") do
        coords[#coords + 1] = tonumber(num)
    end
    if #coords ~= 3 then return nil end
    return coords
end

-- ============================================
-- COORDINATE TRACKER FEATURES
-- ============================================

-- Feature 1: Get Current Position
-- Return string koordinat, atau nil kalau karakter tidak ada
function Feature.getPosition()
    local ok, result = pcall(function()
        local hrp = getRoot()
        if not hrp then
            Feature.showNotification("Character not found!", false)
            return nil
        end
        local pos = hrp.Position
        local coordText = string.format("X: %.2f | Y: %.2f | Z: %.2f", pos.X, pos.Y, pos.Z)
        C.CoordinateText = coordText
        Feature.showNotification("Position captured!", true)
        return coordText
    end)
    if ok then return result end
    return nil
end

-- Feature 2: Copy Coordinates to Clipboard
function Feature.copyCoordinates()
    pcall(function()
        if not hasText() then
            Feature.showNotification("No coordinates to copy!", false)
            return
        end

        if setclipboard then
            local cleanCoords = C.CoordinateText:gsub("[XYZ]: ", ""):gsub(" | ", ", ")
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
        if not hasText() then
            Feature.showNotification("No coordinates to teleport!", false)
            return
        end

        local coords = parseCoords()
        if not coords then
            Feature.showNotification("Invalid coordinates format!", false)
            return
        end

        local hrp = getRoot()
        if not hrp then
            Feature.showNotification("Character not found!", false)
            return
        end

        hrp.CFrame = CFrame.new(coords[1], coords[2], coords[3])
        Feature.showNotification("Teleported successfully!", true)
    end)
end

-- Feature 5: Copy Teleport Script
function Feature.copyTeleportScript()
    pcall(function()
        if not hasText() then
            Feature.showNotification("No coordinates to copy script!", false)
            return
        end

        local coords = parseCoords()
        if not coords then
            Feature.showNotification("Invalid coordinates format!", false)
            return
        end

        if setclipboard then
            local script = string.format([[
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
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
        Feature.showNotification("Rejoining server...", true)
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, L)
    end)
end

-- Feature 7: Walk Speed
-- Tidak lagi pakai loop Heartbeat. Nilai target disimpan, lalu hanya
-- diterapkan ulang saat game mengubah WalkSpeed atau karakter respawn.
local walkTarget = nil
local walkDefault = nil
local walkNotifThread = nil

local function applyWalkSpeed()
    local character = L.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and walkTarget and humanoid.WalkSpeed ~= walkTarget then
        humanoid.WalkSpeed = walkTarget
    end
end

local function hookHumanoid(character)
    if Connections.WalkChanged then
        Connections.WalkChanged:Disconnect()
        Connections.WalkChanged = nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid or not walkTarget then return end

    Connections.WalkChanged = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(applyWalkSpeed)
    applyWalkSpeed()
end

function Feature.setWalkSpeed(speed)
    walkTarget = speed

    if not Connections.CharAdded then
        local character = L.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        walkDefault = humanoid and humanoid.WalkSpeed or 16

        Connections.CharAdded = L.CharacterAdded:Connect(hookHumanoid)
        if character then
            task.spawn(hookHumanoid, character)
        end
    end

    applyWalkSpeed()

    -- Notifikasi hanya muncul setelah slider berhenti digeser
    if walkNotifThread then task.cancel(walkNotifThread) end
    walkNotifThread = task.delay(0.5, function()
        walkNotifThread = nil
        Feature.showNotification("Walk Speed set to " .. tostring(speed), true)
    end)
end

-- ============================================
-- RESET ALL FEATURES
-- silent = true: tanpa notifikasi (dipakai saat destroy UI)
-- ============================================
function Feature.resetAllFeatures(silent)
    -- Matikan Walk Speed dan kembalikan ke nilai awal
    if Connections.WalkChanged then
        Connections.WalkChanged:Disconnect()
        Connections.WalkChanged = nil
    end
    if Connections.CharAdded then
        Connections.CharAdded:Disconnect()
        Connections.CharAdded = nil

        pcall(function()
            local character = L.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkDefault or 16
            end
        end)
    end
    walkTarget = nil
    walkDefault = nil
    if walkNotifThread then -- batalkan notifikasi yang tertunda
        task.cancel(walkNotifThread)
        walkNotifThread = nil
    end

    -- Reset config ke default
    if C then
        C.CoordinateText = ""
        C.WalkSpeed = 16
    end

    if not silent then
        Feature.showNotification("All features reset!", false)
    end
end

-- ============================================
-- CLEANUP FUNCTION
-- ============================================
function Feature.cleanup()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}

    for id, snd in pairs(soundCache) do
        pcall(function() snd:Destroy() end)
        soundCache[id] = nil
    end
end

return Feature
