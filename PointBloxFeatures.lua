-- PointBloxFeatures.lua
-- SynceHub - Point Blox ESP Features

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local R  = game:GetService("RunService")
local T  = game:GetService("TweenService")
local P  = game:GetService("Players")
local L  = P.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections = {}
local ESPObjects  = {}  -- { [player] = { highlight, billboard, ... } }

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
    sound.SoundId = "rbxassetid://6026984224"
    sound.Volume   = s and 0.5 or 0.4
    sound.Parent   = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)

    spawn(function()
        local n = S.G:FindFirstChild("NotifContainer")
        if not n then
            n          = Instance.new("Frame")
            n.Name     = "NotifContainer"
            n.Size     = UDim2.new(0, 280, 1, 0)
            n.Position = UDim2.new(1, -290, 0, 10)
            n.BackgroundTransparency = 1
            n.ZIndex   = 1000
            n.Parent   = S.G

            local l = Instance.new("UIListLayout")
            l.Padding           = UDim.new(0, 8)
            l.SortOrder         = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Top
            l.Parent = n
        end

        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3    = Color3.fromRGB(30, 30, 35)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel     = 0
        f.ZIndex       = 1001
        f.LayoutOrder  = #S.NotifQueue + 1
        f.Parent       = n

        table.insert(S.NotifQueue, f)

        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

        local st = Instance.new("UIStroke", f)
        st.Color       = Color3.fromRGB(200, 200, 210)
        st.Thickness   = 2
        st.Transparency = 0.5

        local i = Instance.new("ImageLabel")
        i.Size  = UDim2.new(0, 24, 0, 24)
        i.Position = UDim2.new(0, 12, 0, 12)
        i.BackgroundTransparency = 1
        i.Image  = s and "rbxassetid://140507950554297" or "rbxassetid://118025272389341"
        i.ImageColor3 = Color3.fromRGB(200, 200, 210)
        i.ZIndex = 1002
        i.Parent = f

        local t = Instance.new("TextLabel")
        t.Size   = UDim2.new(1, -52, 1, 0)
        t.Position = UDim2.new(0, 44, 0, 0)
        t.BackgroundTransparency = 1
        t.Text   = m
        t.TextColor3  = Color3.fromRGB(240, 240, 245)
        t.Font        = Enum.Font.GothamMedium
        t.TextSize    = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.ZIndex = 1002
        t.Parent = f

        local h = 48
        f.Position = UDim2.new(1, 20, 0, 0)
        T:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, h), Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        task.wait(0.4)
        T:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
        task.wait(2.5)
        T:Create(f,  TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        T:Create(t,  TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        T:Create(i,  TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        T:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.3)
        T:Create(f, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        f:Destroy()

        for idx, v in ipairs(S.NotifQueue) do
            if v == f then table.remove(S.NotifQueue, idx) break end
        end
    end)
end

-- ============================================
-- INTERNAL HELPERS
-- ============================================

-- Warna ESP berdasarkan config
local function getESPColor()
    local colors = {
        Red    = Color3.fromRGB(255, 70,  70),
        Blue   = Color3.fromRGB(70,  140, 255),
        Green  = Color3.fromRGB(70,  220, 100),
        Yellow = Color3.fromRGB(255, 220, 50),
        Purple = Color3.fromRGB(180, 80,  255),
        White  = Color3.fromRGB(240, 240, 245),
    }
    return colors[C.ESPColor] or colors.Red
end

-- Apakah player satu team
local function isSameTeam(player)
    if not C.ESPTeamCheck then return false end
    return player.Team ~= nil and player.Team == L.Team
end

-- Hapus ESP object untuk satu player
local function removeESP(player)
    local obj = ESPObjects[player]
    if not obj then return end

    pcall(function()
        if obj.Highlight  then obj.Highlight:Destroy()  end
        if obj.Billboard  then obj.Billboard:Destroy()  end
    end)

    ESPObjects[player] = nil
end

-- Buat ESP object untuk satu player
local function createESP(player)
    if player == L then return end
    if isSameTeam(player) then return end

    removeESP(player)

    local char = player.Character
    if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local obj = {}

    -- ── Highlight (box ESP lewat tembok) ──────────────────────────────
    if C.ESPBox then
        local hl = Instance.new("Highlight")
        hl.Name              = "SynceESP_Highlight"
        hl.FillColor         = getESPColor()
        hl.OutlineColor      = getESPColor()
        hl.FillTransparency  = C.ESPFillTransparency  -- configurable
        hl.OutlineTransparency = 0
        hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee           = char
        hl.Parent            = char
        obj.Highlight = hl
    end

    -- ── Billboard (name / HP / distance) ─────────────────────────────
    if C.ESPName or C.ESPHealth or C.ESPDistance then
        local bb = Instance.new("BillboardGui")
        bb.Name            = "SynceESP_BB"
        bb.Size            = UDim2.new(0, 200, 0, 60)
        bb.StudsOffset     = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop     = true
        bb.ResetOnSpawn    = false
        bb.Adornee         = hrp
        bb.Parent          = hrp

        local frame = Instance.new("Frame")
        frame.Size                 = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent               = bb

        local layout = Instance.new("UIListLayout", frame)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment   = Enum.VerticalAlignment.Center
        layout.Padding             = UDim.new(0, 1)

        -- Name label
        if C.ESPName then
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name               = "NameLabel"
            nameLbl.Size               = UDim2.new(1, 0, 0, 18)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text               = player.Name
            nameLbl.TextColor3         = getESPColor()
            nameLbl.Font               = Enum.Font.GothamBold
            nameLbl.TextSize           = 13
            nameLbl.TextStrokeTransparency = 0.4
            nameLbl.TextStrokeColor3   = Color3.new(0, 0, 0)
            nameLbl.Parent             = frame
            obj.NameLabel = nameLbl
        end

        -- Health label
        if C.ESPHealth then
            local hpLbl = Instance.new("TextLabel")
            hpLbl.Name               = "HPLabel"
            hpLbl.Size               = UDim2.new(1, 0, 0, 15)
            hpLbl.BackgroundTransparency = 1
            hpLbl.Text               = "HP: ?"
            hpLbl.TextColor3         = Color3.fromRGB(100, 255, 120)
            hpLbl.Font               = Enum.Font.GothamMedium
            hpLbl.TextSize           = 11
            hpLbl.TextStrokeTransparency = 0.4
            hpLbl.TextStrokeColor3   = Color3.new(0, 0, 0)
            hpLbl.Parent             = frame
            obj.HPLabel = hpLbl
        end

        -- Distance label
        if C.ESPDistance then
            local distLbl = Instance.new("TextLabel")
            distLbl.Name               = "DistLabel"
            distLbl.Size               = UDim2.new(1, 0, 0, 15)
            distLbl.BackgroundTransparency = 1
            distLbl.Text               = "? studs"
            distLbl.TextColor3         = Color3.fromRGB(200, 200, 210)
            distLbl.Font               = Enum.Font.Gotham
            distLbl.TextSize           = 11
            distLbl.TextStrokeTransparency = 0.4
            distLbl.TextStrokeColor3   = Color3.new(0, 0, 0)
            distLbl.Parent             = frame
            obj.DistLabel = distLbl
        end

        obj.Billboard = bb
        obj.Frame     = frame
    end

    ESPObjects[player] = obj
end

-- Update HP + Distance setiap frame
local function updateESP(player)
    local obj  = ESPObjects[player]
    if not obj then return end

    local char = player.Character
    if not char then removeESP(player) return end

    local hrp      = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local lhrp     = L.Character and L.Character:FindFirstChild("HumanoidRootPart")

    -- Update warna jika berubah
    if obj.Highlight then
        obj.Highlight.FillColor    = getESPColor()
        obj.Highlight.OutlineColor = getESPColor()
        obj.Highlight.FillTransparency = C.ESPFillTransparency
    end

    if obj.NameLabel then
        obj.NameLabel.TextColor3 = getESPColor()
    end

    -- HP
    if obj.HPLabel and humanoid then
        local hp    = math.floor(humanoid.Health)
        local maxhp = math.floor(humanoid.MaxHealth)
        obj.HPLabel.Text = "HP: " .. hp .. "/" .. maxhp

        -- Warna HP: hijau → kuning → merah
        local pct = hp / math.max(maxhp, 1)
        obj.HPLabel.TextColor3 = Color3.fromRGB(
            math.floor(255 * (1 - pct)),
            math.floor(255 * pct),
            60
        )
    end

    -- Distance
    if obj.DistLabel and hrp and lhrp then
        local dist = math.floor((hrp.Position - lhrp.Position).Magnitude)
        obj.DistLabel.Text = dist .. " studs"
    end
end

-- ============================================
-- ESP ON / OFF
-- ============================================
function Feature.startESP()
    if Connections.ESP then return end

    -- Buat ESP untuk semua player yang ada
    for _, player in ipairs(P:GetPlayers()) do
        if player ~= L then createESP(player) end
    end

    -- Player baru masuk
    Connections.ESPAdded = P.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if C.ESPEnabled then createESP(player) end
        end)
    end)

    -- Character respawn
    for _, player in ipairs(P:GetPlayers()) do
        if player ~= L then
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if C.ESPEnabled then createESP(player) end
            end)
        end
    end

    -- Player keluar
    Connections.ESPRemoving = P.PlayerRemoving:Connect(function(player)
        removeESP(player)
    end)

    -- Update loop
    Connections.ESP = R.RenderStepped:Connect(function()
        for _, player in ipairs(P:GetPlayers()) do
            if player ~= L then
                local obj = ESPObjects[player]
                if obj then
                    updateESP(player)
                else
                    -- kalau character baru ada tapi belum dibuat
                    if player.Character then createESP(player) end
                end
            end
        end
    end)

    Feature.showNotification("ESP Enabled!", true)
end

function Feature.stopESP()
    -- Putus semua koneksi ESP
    for key, conn in pairs(Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
        Connections[key] = nil
    end

    -- Hapus semua ESP object
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
    end
    ESPObjects = {}

    Feature.showNotification("ESP Disabled!", false)
end

function Feature.toggleESP(state)
    C.ESPEnabled = state
    if state then
        Feature.startESP()
    else
        Feature.stopESP()
    end
end

-- Refresh ESP (dipanggil saat setting berubah)
function Feature.refreshESP()
    if not C.ESPEnabled then return end

    -- Hapus semua, buat ulang
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
    end
    ESPObjects = {}

    for _, player in ipairs(P:GetPlayers()) do
        if player ~= L then createESP(player) end
    end
end

-- ============================================
-- RESET ALL FEATURES
-- ============================================
function Feature.resetAllFeatures()
    Feature.stopESP()
    C.ESPEnabled          = false
    C.ESPBox              = true
    C.ESPName             = true
    C.ESPHealth           = true
    C.ESPDistance         = true
    C.ESPTeamCheck        = true
    C.ESPColor            = "Red"
    C.ESPFillTransparency = 0.7
    Feature.showNotification("All features reset!", false)
end

-- ============================================
-- CLEANUP
-- ============================================
function Feature.cleanup()
    Feature.stopESP()
    for k, conn in pairs(Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    Connections = {}
end

return Feature
