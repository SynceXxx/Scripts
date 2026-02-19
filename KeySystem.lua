-- KeySystem.lua
-- SynceHub - Key System (Simple Permanent Key)

local KeySystem = {}

-- ============================================
-- !! RAHASIA !! JANGAN DIBAGIKAN !!
-- Ini key permanen kamu. Ganti kalau bocor.
-- ============================================
local VALID_KEY = "SYNCEHUB-2026"

-- ============================================
-- CONFIG
-- ============================================
local CONFIG = {
    HubName         = "SynceHub",
    LinkvertiseURL  = "https://link-center.net/3682024/vdBxkLffHdMN",
    MaxRetries      = 3,
    ContainerWidth  = 400,
    ContainerHeight = 270,
    BarPaddingX     = 24,
    FadeInSpeed     = 0.45,
    FadeOutSpeed    = 0.3,

    -- Neon Glow palette
    BG         = Color3.fromRGB(10, 10, 15),
    BG2        = Color3.fromRGB(15, 15, 22),
    Border     = Color3.fromRGB(100, 50, 150),
    Accent     = Color3.fromRGB(200, 50, 255),
    AccentGlow = Color3.fromRGB(220, 80, 255),
    TextMain   = Color3.fromRGB(255, 255, 255),
    TextSub    = Color3.fromRGB(180, 150, 220),
    TextDim    = Color3.fromRGB(130, 100, 170),
    BarBg      = Color3.fromRGB(20, 20, 28),
    Err        = Color3.fromRGB(255, 80, 100),
    Succ       = Color3.fromRGB(100, 220, 150),
}

-- ============================================
-- SERVICES
-- ============================================
local TweenService  = game:GetService("TweenService")
local Players       = game:GetService("Players")
local SoundService  = game:GetService("SoundService")
local GuiService    = game:GetService("GuiService")
local LocalPlayer   = Players.LocalPlayer

-- ============================================
-- KEY VALIDATION (simpel banget sekarang)
-- ============================================
local function validateKey(input)
    local cleaned = input:upper():match("^%s*(.-)%s*$")
    return cleaned == VALID_KEY
end

-- ============================================
-- CACHE — biar ga input ulang tiap rejoin
-- ============================================
local function isCacheValid()
    return _G.SynceKeyValid == true
end

-- ============================================
-- SOUNDS
-- ============================================
local function createSound(id, volume, pitch)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. id
    s.Volume = volume or 0.5
    s.PlaybackSpeed = pitch or 1
    s.RollOffMaxDistance = 0
    s.Parent = SoundService
    return s
end

-- ============================================
-- TWEEN HELPER
-- ============================================
local function tw(obj, props, t, style, dir)
    return TweenService:Create(
        obj,
        TweenInfo.new(t or CONFIG.FadeInSpeed, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
end

-- ============================================
-- BUILD UI
-- ============================================
local function buildUI(onSuccess)
    local W = CONFIG.ContainerWidth
    local H = CONFIG.ContainerHeight

    local sndOpen  = createSound("85240253037283", 0.5, 1.0)
    local sndClose = createSound("85240253037283", 0.5, 1.0)
    local sndReady = createSound("6026984224",     0.5, 1.0)
    local sndErr   = createSound("4590662766",     0.4, 1.0)

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SynceKeySystem"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 9999

    local ok = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not ok then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Container
    local container = Instance.new("Frame")
    container.Name = "KeyContainer"
    container.Size = UDim2.new(0, W, 0, H)
    container.Position = UDim2.new(0.5, -W/2, 0.5, -H/2 - 20)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 2
    container.Parent = screenGui
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)

    -- Gradient background
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(8, 5, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 10, 45)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(55, 15, 80)),
    }
    bgGrad.Rotation = 135
    bgGrad.Parent = container

    -- Spinning border
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = CONFIG.Border
    containerStroke.Thickness = 2.5
    containerStroke.Transparency = 1
    containerStroke.Parent = container

    local borderGradient = Instance.new("UIGradient")
    borderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(220, 80, 255)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(100, 0, 180)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(20, 0, 40)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 255, 255)),
    }
    borderGradient.Parent = containerStroke

    -- Matrix Rain
    container.ClipsDescendants = true
    local matrixChars  = {"0","1","<",">","/","|","#","@","$","%","?","ア","カ","コ"}
    local matrixActive = true
    local COLS         = 8
    local TRAIL        = 5
    local colWidth     = W / COLS
    local charHeight   = 18

    local matrixContainer = Instance.new("Frame")
    matrixContainer.Size = UDim2.new(1, 0, 1, 0)
    matrixContainer.BackgroundTransparency = 1
    matrixContainer.ZIndex = 1
    matrixContainer.ClipsDescendants = true
    matrixContainer.Parent = container
    Instance.new("UICorner", matrixContainer).CornerRadius = UDim.new(0, 16)

    for col = 1, COLS do
        task.spawn(function()
            local colX  = (col - 1) * colWidth
            local speed = math.random(3, 7)
            local labels = {}
            for t = 1, TRAIL do
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0, colWidth, 0, charHeight)
                lbl.Position = UDim2.new(0, colX, 0, -t * charHeight - math.random(0, H))
                lbl.BackgroundTransparency = 1
                lbl.Text = matrixChars[math.random(#matrixChars)]
                lbl.Font = Enum.Font.Code
                lbl.TextSize = 11
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                lbl.ZIndex = 1
                local fade = (t - 1) / TRAIL
                lbl.TextColor3 = t == 1 and Color3.fromRGB(240, 200, 255) or CONFIG.Accent
                lbl.TextTransparency = t == 1 and 0 or (fade * 0.8)
                lbl.Parent = matrixContainer
                table.insert(labels, lbl)
            end
            while matrixActive do
                for _, lbl in ipairs(labels) do
                    local newY = lbl.Position.Y.Offset + speed
                    if newY > H + charHeight then
                        newY = -charHeight * TRAIL - math.random(0, 40)
                        lbl.Text = matrixChars[math.random(#matrixChars)]
                    end
                    lbl.Position = UDim2.new(0, colX, 0, newY)
                    if math.random() < 0.08 then
                        lbl.Text = matrixChars[math.random(#matrixChars)]
                    end
                end
                task.wait(0.06)
            end
            for _, lbl in ipairs(labels) do
                if lbl and lbl.Parent then lbl:Destroy() end
            end
        end)
    end

    -- Avatar
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 56, 0, 56)
    avatarFrame.Position = UDim2.new(0.5, -28, 0, 14)
    avatarFrame.BackgroundTransparency = 1
    avatarFrame.ZIndex = 3
    avatarFrame.Parent = container
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)

    local avatarStroke = Instance.new("UIStroke", avatarFrame)
    avatarStroke.Color = CONFIG.Accent
    avatarStroke.Thickness = 2.5
    avatarStroke.Transparency = 1

    local avatarGradient = Instance.new("UIGradient")
    avatarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(220, 80, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(140, 0, 200)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 255, 255)),
    }
    avatarGradient.Parent = avatarStroke

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxassetid://0"
    avatarImg.ImageTransparency = 1
    avatarImg.ZIndex = 6
    avatarImg.Parent = avatarFrame
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        local ok2, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        avatarImg.Image = (ok2 and img) and img or "rbxassetid://4003186083"
    end)

    -- Nama player
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX*2, 0, 20)
    nameLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 78)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Welcome, " .. LocalPlayer.DisplayName
    nameLabel.TextColor3 = CONFIG.Accent
    nameLabel.TextSize = 15
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.TextTransparency = 1
    nameLabel.ZIndex = 3
    nameLabel.Parent = container

    local nameGrad = Instance.new("UIGradient")
    nameGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, CONFIG.Accent),
        ColorSequenceKeypoint.new(1, CONFIG.AccentGlow),
    }
    nameGrad.Parent = nameLabel

    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX*2, 0, 14)
    subtitleLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 102)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "🔑  Masukkan key untuk melanjutkan"
    subtitleLabel.TextColor3 = CONFIG.TextSub
    subtitleLabel.TextSize = 11
    subtitleLabel.Font = Enum.Font.GothamMedium
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.TextTransparency = 1
    subtitleLabel.ZIndex = 3
    subtitleLabel.Parent = container

    -- Input box
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -CONFIG.BarPaddingX*2, 0, 36)
    inputFrame.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 124)
    inputFrame.BackgroundColor3 = CONFIG.BG2
    inputFrame.BackgroundTransparency = 1
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 3
    inputFrame.Parent = container
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

    local inputStroke = Instance.new("UIStroke", inputFrame)
    inputStroke.Color = CONFIG.Border
    inputStroke.Thickness = 1.5
    inputStroke.Transparency = 1

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -16, 1, 0)
    inputBox.Position = UDim2.new(0, 8, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.PlaceholderText = "Masukkan key disini..."
    inputBox.PlaceholderColor3 = CONFIG.TextDim
    inputBox.TextColor3 = CONFIG.TextMain
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.TextSize = 13
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 4
    inputBox.Parent = inputFrame

    inputBox.Focused:Connect(function()
        tw(inputStroke, {Color = CONFIG.Accent, Transparency = 0.3}):Play()
    end)
    inputBox.FocusLost:Connect(function()
        tw(inputStroke, {Color = CONFIG.Border, Transparency = 0}):Play()
    end)

    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX*2, 0, 14)
    statusLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 168)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Key bisa didapat di Discord atau Linkvertise kami"
    statusLabel.TextColor3 = CONFIG.TextDim
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextTransparency = 1
    statusLabel.ZIndex = 3
    statusLabel.Parent = container

    -- Buttons
    local btnW = (W - CONFIG.BarPaddingX*2 - 10) / 2

    local function makeBtn(text, posX, bgColor, accentColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnW, 0, 34)
        btn.Position = UDim2.new(0, posX, 0, 188)
        btn.BackgroundColor3 = bgColor
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = CONFIG.TextMain
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.ZIndex = 3
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Color = accentColor
        bStroke.Thickness = 1.5
        bStroke.Transparency = 1

        return btn, bStroke
    end

    local getKeyBtn, getStroke = makeBtn("🔗  Get Key", CONFIG.BarPaddingX, CONFIG.BG2, CONFIG.Border)
    local submitBtn, subStroke = makeBtn("✔  Submit",  CONFIG.BarPaddingX + btnW + 10, CONFIG.Accent, CONFIG.AccentGlow)

    -- Retry label
    local retryLabel = Instance.new("TextLabel")
    retryLabel.Size = UDim2.new(1, 0, 0, 14)
    retryLabel.Position = UDim2.new(0, 0, 0, 230)
    retryLabel.BackgroundTransparency = 1
    retryLabel.Text = ""
    retryLabel.TextColor3 = CONFIG.TextDim
    retryLabel.TextSize = 10
    retryLabel.Font = Enum.Font.Gotham
    retryLabel.TextXAlignment = Enum.TextXAlignment.Center
    retryLabel.ZIndex = 3
    retryLabel.Parent = container

    -- Spinning border + avatar gradient
    task.spawn(function()
        task.wait(0.5)
        local rot = 0
        while matrixActive do
            rot = (rot + 4) % 360
            borderGradient.Rotation = rot
            avatarGradient.Rotation = rot
            task.wait(0.03)
        end
    end)

    -- Fade in
    local function fadeInAll()
        pcall(function() sndOpen:Play() end)

        tw(container, {BackgroundTransparency = 0.08}):Play()
        tw(containerStroke, {Transparency = 0.3}):Play()
        task.wait(0.1)
        tw(avatarStroke, {Transparency = 0}):Play()
        tw(avatarImg, {ImageTransparency = 0}, 0.5):Play()
        task.wait(0.25)
        tw(nameLabel, {TextTransparency = 0}, 0.5):Play()
        task.wait(0.2)
        tw(subtitleLabel, {TextTransparency = 0}, 0.4):Play()
        task.wait(0.15)
        tw(inputFrame, {BackgroundTransparency = 0}, 0.35):Play()
        tw(inputStroke, {Transparency = 0}, 0.35):Play()
        task.wait(0.1)
        tw(statusLabel, {TextTransparency = 0}, 0.3):Play()
        task.wait(0.1)
        tw(getKeyBtn, {BackgroundTransparency = 0}, 0.3):Play()
        tw(getStroke, {Transparency = 0}, 0.3):Play()
        tw(submitBtn, {BackgroundTransparency = 0}, 0.3):Play()
        tw(subStroke, {Transparency = 0.4}, 0.3):Play()
    end

    task.spawn(fadeInAll)

    -- Fade out
    local function fadeOutAndClose(cb)
        matrixActive = false
        pcall(function() sndClose:Play() end)

        local slideTime = CONFIG.FadeOutSpeed * 1.2
        tw(container, {
            Position = UDim2.new(0.5, -W/2, 0.5, -H/2 + 180),
        }, slideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()

        tw(container,       {BackgroundTransparency = 1}, slideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        tw(containerStroke, {Transparency = 1}, slideTime):Play()
        tw(avatarStroke,    {Transparency = 1}, slideTime):Play()
        tw(avatarImg,       {ImageTransparency = 1}, slideTime):Play()
        tw(nameLabel,       {TextTransparency = 1}, slideTime):Play()
        tw(subtitleLabel,   {TextTransparency = 1}, slideTime):Play()
        tw(statusLabel,     {TextTransparency = 1}, slideTime):Play()
        tw(inputFrame,      {BackgroundTransparency = 1}, slideTime):Play()
        tw(getKeyBtn,       {BackgroundTransparency = 1}, slideTime):Play()
        tw(submitBtn,       {BackgroundTransparency = 1}, slideTime):Play()

        task.delay(slideTime + 0.1, function()
            screenGui:Destroy()
            pcall(function()
                sndOpen:Destroy(); sndClose:Destroy()
                sndReady:Destroy(); sndErr:Destroy()
            end)
            if cb then cb() end
        end)
    end

    -- Button logic
    local retries    = 0
    local submitting = false

    local function setStatus(msg, color)
        statusLabel.TextColor3 = color
        statusLabel.Text = msg
    end

    -- Get Key button
    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() GuiService:OpenBrowserWindow(CONFIG.LinkvertiseURL) end)
        setStatus("Selesaikan Linkvertise, lalu paste key!", CONFIG.TextSub)
    end)

    getKeyBtn.MouseEnter:Connect(function()
        tw(getKeyBtn, {BackgroundColor3 = CONFIG.BG}):Play()
        tw(getStroke, {Color = CONFIG.Accent, Transparency = 0.2}):Play()
    end)
    getKeyBtn.MouseLeave:Connect(function()
        tw(getKeyBtn, {BackgroundColor3 = CONFIG.BG2}):Play()
        tw(getStroke, {Color = CONFIG.Border, Transparency = 0}):Play()
    end)

    submitBtn.MouseEnter:Connect(function()
        if not submitting then
            tw(submitBtn, {BackgroundColor3 = CONFIG.AccentGlow}):Play()
        end
    end)
    submitBtn.MouseLeave:Connect(function()
        tw(submitBtn, {BackgroundColor3 = CONFIG.Accent}):Play()
    end)

    -- Submit button
    submitBtn.MouseButton1Click:Connect(function()
        if submitting then return end
        local key = inputBox.Text
        if not key or key:match("^%s*$") then
            setStatus("⚠  Key tidak boleh kosong!", CONFIG.Err)
            tw(inputStroke, {Color = CONFIG.Err}):Play()
            task.wait(1)
            tw(inputStroke, {Color = CONFIG.Border}):Play()
            return
        end

        submitting = true
        submitBtn.Text = "⏳  Checking..."
        setStatus("Memvalidasi key...", CONFIG.TextDim)
        task.wait(0.4)

        if validateKey(key) then
            -- Key valid! Simpan ke cache
            _G.SynceKeyValid = true

            pcall(function() sndReady:Play() end)
            setStatus("✅  Key valid! Memuat hub...", CONFIG.Succ)
            tw(inputStroke, {Color = CONFIG.Succ}):Play()
            task.wait(0.8)
            fadeOutAndClose(onSuccess)
        else
            retries = retries + 1
            local remaining = CONFIG.MaxRetries - retries

            pcall(function() sndErr:Play() end)
            tw(inputStroke, {Color = CONFIG.Err}):Play()
            task.wait(0.15)
            tw(inputStroke, {Color = CONFIG.Border}, 0.5):Play()

            if remaining <= 0 then
                setStatus("❌  Terlalu banyak percobaan. Script dihentikan.", CONFIG.Err)
                retryLabel.Text = ""
                task.wait(2)
                fadeOutAndClose()
                error("SynceHub: Key validation failed")
            else
                setStatus("❌  Key salah!", CONFIG.Err)
                retryLabel.Text = "Sisa percobaan: " .. remaining .. "x"
                submitBtn.Text = "✔  Submit"
                submitting = false
            end
        end
    end)
end

-- ============================================
-- PUBLIC API
-- ============================================
function KeySystem.check(onSuccess)
    -- Kalau sudah pernah input key benar (dalam sesi yang sama), skip UI
    if isCacheValid() then
        onSuccess()
        return
    end
    buildUI(onSuccess)
end

return KeySystem
