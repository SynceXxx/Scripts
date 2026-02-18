-- SLoader.lua
-- SynceHub Loader — Neon Glow Theme
-- With player profile icon & typing welcome text

local CONFIG = {
    HubName        = "SynceHub",
    HubSubtitle    = "Premium Script Hub",
    ContainerWidth = 400,
    ContainerHeight= 240,
    BarHeight      = 6,
    BarPaddingX    = 24,
    BarLerpSpeed   = 0.55,
    FadeInSpeed    = 0.45,
    FadeOutSpeed   = 0.3,

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
}

-- ─────────────────────────────────────────────
-- Services & Player
-- ─────────────────────────────────────────────
local TweenService  = game:GetService("TweenService")
local Players       = game:GetService("Players")
local SoundService  = game:GetService("SoundService")
local LocalPlayer   = Players.LocalPlayer
local thumbType     = Enum.ThumbnailType.HeadShot
local thumbSize     = Enum.ThumbnailSize.Size100x100

local loader = {}

-- ─────────────────────────────────────────────
-- Sound System
-- ─────────────────────────────────────────────
local function createSound(id, volume, pitch)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. id
    s.Volume = volume or 0.5
    s.PlaybackSpeed = pitch or 1
    s.RollOffMaxDistance = 0
    s.Parent = SoundService
    return s
end

-- Pre-load sounds
local sndOpen    = createSound("9118389739", 0.4, 1.0)   -- sci-fi boot up
local sndClose   = createSound("4337543671", 0.5, 1.0)   -- soft complete chime
local sndTick    = createSound("6895079853", 0.08, 1.8)  -- tick kecil tiap progress
local sndReady   = createSound("6026984224", 0.4, 1.2)   -- success saat 100%

local lastTickProgress = 0
local function playTickIfNeeded(progress)
    -- Bunyi tick tiap 10%
    if progress >= lastTickProgress + 10 then
        lastTickProgress = math.floor(progress / 10) * 10
        pcall(function() sndTick:Play() end)
    end
end

-- ─────────────────────────────────────────────
-- ScreenGui
-- ─────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SynceLoader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999

local ok = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
if not ok then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ─────────────────────────────────────────────
-- Main container
-- ─────────────────────────────────────────────
local container = Instance.new("Frame")
container.Name = "LoaderContainer"
container.Size = UDim2.new(0, CONFIG.ContainerWidth, 0, CONFIG.ContainerHeight)
container.Position = UDim2.new(0.5, -CONFIG.ContainerWidth / 2, 0.5, -CONFIG.ContainerHeight / 2 - 20)
container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- putih biar gradient keliatan
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ZIndex = 2
container.Parent = screenGui

Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)

-- Gradient bg (hitam ke ungu)
local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 5, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 10, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 15, 80)),
}
bgGrad.Rotation = 135
bgGrad.Parent = container

-- Border glow
local containerStroke = Instance.new("UIStroke")
containerStroke.Color = CONFIG.Border
containerStroke.Thickness = 1.5
containerStroke.Transparency = 1
containerStroke.Parent = container


-- ─────────────────────────────────────────────
-- Matrix Rain — Recycle System (ringan)
-- ─────────────────────────────────────────────
container.ClipsDescendants = true

local matrixChars = {"0","1","<",">","/","|","#","@","$","%","?","ア","カ","コ"}
local matrixActive = true
local COLS = 8
local TRAIL = 5  -- karakter per kolom (fixed, recycle)
local colWidth = CONFIG.ContainerWidth / COLS
local charHeight = 18
local H = CONFIG.ContainerHeight

local matrixContainer = Instance.new("Frame")
matrixContainer.Size = UDim2.new(1, 0, 1, 0)
matrixContainer.BackgroundTransparency = 1
matrixContainer.ZIndex = 1
matrixContainer.ClipsDescendants = true
matrixContainer.Parent = container

Instance.new("UICorner", matrixContainer).CornerRadius = UDim.new(0, 16)

-- Buat semua label SEKALI, recycle posisinya
for col = 1, COLS do
    task.spawn(function()
        local colX = (col - 1) * colWidth
        local speed = math.random(3, 7)  -- pixel per tick
        local labels = {}

        -- Buat TRAIL label untuk kolom ini, posisi awal tersebar
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
            -- Kepala paling terang, ekor makin fade
            local fade = (t - 1) / TRAIL
            lbl.TextColor3 = t == 1 and Color3.fromRGB(240, 200, 255) or CONFIG.Accent
            lbl.TextTransparency = t == 1 and 0 or (fade * 0.8)
            lbl.Parent = matrixContainer
            table.insert(labels, lbl)
        end

        -- Loop: gerakkan ke bawah, recycle kalau udah keluar
        while matrixActive do
            for _, lbl in ipairs(labels) do
                local newY = lbl.Position.Y.Offset + speed
                -- Reset ke atas kalau udah keluar bawah
                if newY > H + charHeight then
                    newY = -charHeight * TRAIL - math.random(0, 40)
                    lbl.Text = matrixChars[math.random(#matrixChars)]
                end
                lbl.Position = UDim2.new(0, colX, 0, newY)
                -- Ganti karakter sesekali
                if math.random() < 0.08 then
                    lbl.Text = matrixChars[math.random(#matrixChars)]
                end
            end
            task.wait(0.06)
        end

        -- Cleanup saat stop
        for _, lbl in ipairs(labels) do
            if lbl and lbl.Parent then lbl:Destroy() end
        end
    end)
end



-- ─────────────────────────────────────────────
-- Profile icon
-- ─────────────────────────────────────────────
local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 64, 0, 64)
avatarFrame.Position = UDim2.new(0.5, -32, 0, 16)
avatarFrame.BackgroundColor3 = CONFIG.BG2
avatarFrame.BackgroundTransparency = 1  -- selalu transparan
avatarFrame.ZIndex = 3
avatarFrame.Parent = container

Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke", avatarFrame)
avatarStroke.Color = CONFIG.Accent
avatarStroke.Thickness = 2
avatarStroke.Transparency = 1

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(1, 0, 1, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.Image = "rbxassetid://0"
avatarImg.ImageTransparency = 1
avatarImg.ZIndex = 4
avatarImg.Parent = avatarFrame

Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

-- Load avatar async
task.spawn(function()
    local ok2, img = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
    end)
    if ok2 and img then
        avatarImg.Image = img
    else
        avatarImg.Image = "rbxassetid://4003186083"
    end
end)

-- ─────────────────────────────────────────────
-- Label 1: "Welcome, [nama]" — fade in smooth
-- ─────────────────────────────────────────────
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 24)
nameLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 92)  -- sedikit ke bawah
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Welcome, " .. LocalPlayer.DisplayName
nameLabel.TextColor3 = CONFIG.Accent
nameLabel.TextSize = 16  -- lebih besar
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Center
nameLabel.TextTransparency = 1
nameLabel.ZIndex = 3
nameLabel.Parent = container

-- Accent gradient pada nama
local nameGrad = Instance.new("UIGradient")
nameGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Accent),
    ColorSequenceKeypoint.new(1, CONFIG.AccentGlow),
}
nameGrad.Rotation = 0
nameGrad.Parent = nameLabel

-- ─────────────────────────────────────────────
-- Label 2: sisa text — typing effect
-- ─────────────────────────────────────────────
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 40)
welcomeLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 118)  -- di bawah nama
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = ""
welcomeLabel.TextColor3 = CONFIG.TextSub
welcomeLabel.TextSize = 13  -- lebih besar dari sebelumnya
welcomeLabel.Font = Enum.Font.GothamMedium
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Center
welcomeLabel.TextWrapped = true
welcomeLabel.TextYAlignment = Enum.TextYAlignment.Top
welcomeLabel.TextTransparency = 1
welcomeLabel.ZIndex = 3
welcomeLabel.Parent = container

-- ─────────────────────────────────────────────
-- Status text
-- ─────────────────────────────────────────────
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 16)
statusLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 168)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Initializing hub..."
statusLabel.TextColor3 = CONFIG.TextDim
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextTransparency = 1
statusLabel.ZIndex = 3
statusLabel.Parent = container

-- ─────────────────────────────────────────────
-- Progress bar
-- ─────────────────────────────────────────────
local barBackground = Instance.new("Frame")
barBackground.Name = "BarBackground"
barBackground.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, CONFIG.BarHeight)
barBackground.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 196)
barBackground.BackgroundColor3 = CONFIG.BarBg
barBackground.BorderSizePixel = 0
barBackground.BackgroundTransparency = 1
barBackground.ZIndex = 3
barBackground.Parent = container

Instance.new("UICorner", barBackground).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = CONFIG.Accent
barFill.BorderSizePixel = 0
barFill.BackgroundTransparency = 1
barFill.ZIndex = 4
barFill.Parent = barBackground

Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local barGradient = Instance.new("UIGradient")
barGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Border),
    ColorSequenceKeypoint.new(0.5, CONFIG.Accent),
    ColorSequenceKeypoint.new(1, CONFIG.AccentGlow),
}
barGradient.Rotation = 0
barGradient.Parent = barFill

-- Percent label
local percentLabel = Instance.new("TextLabel")
percentLabel.Name = "PercentLabel"
percentLabel.Size = UDim2.new(0, 36, 0, 14)
percentLabel.Position = UDim2.new(1, -CONFIG.BarPaddingX - 36, 0, 211)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = CONFIG.TextSub
percentLabel.TextSize = 10
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextXAlignment = Enum.TextXAlignment.Right
percentLabel.TextTransparency = 1
percentLabel.ZIndex = 3
percentLabel.Parent = container

-- ─────────────────────────────────────────────
-- Tween helper
-- ─────────────────────────────────────────────
local function tw(obj, props, t, style, dir)
    t = t or CONFIG.FadeInSpeed
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

-- ─────────────────────────────────────────────
-- Typing effect (plain text, no RichText)
-- ─────────────────────────────────────────────
local function typeText(label, fullText, speed)
    speed = speed or 0.035
    label.Text = ""
    label.TextTransparency = 0
    for i = 1, #fullText do
        label.Text = string.sub(fullText, 1, i)
        task.wait(speed)
    end
end

-- ─────────────────────────────────────────────
-- Fade-in sequence
-- ─────────────────────────────────────────────
local function fadeInAll()
    -- Sound opening
    pcall(function() sndOpen:Play() end)

    -- Container
    tw(container, {BackgroundTransparency = 0.08}):Play()
    tw(containerStroke, {Transparency = 0.3}):Play()

    -- Avatar (frame selalu transparan, cuma image & stroke yang muncul)
    task.wait(0.1)
    tw(avatarStroke, {Transparency = 0}):Play()
    tw(avatarImg, {ImageTransparency = 0}, 0.5):Play()

    -- Nama player fade in smooth
    task.wait(0.35)
    tw(nameLabel, {TextTransparency = 0}, 0.5):Play()

    -- Status & bar muncul barengan sama typing
    task.wait(0.6)
    tw(statusLabel, {TextTransparency = 0}):Play()
    tw(barBackground, {BackgroundTransparency = 0}):Play()
    tw(barFill, {BackgroundTransparency = 0}):Play()
    tw(percentLabel, {TextTransparency = 0}):Play()

    -- Typing jalan paralel barengan progress bar
    task.spawn(function()
        local restText = "SynceHub is here to deliver the best experience — free, professional, and powerful."
        typeText(welcomeLabel, restText, 0.03)
    end)
end

task.spawn(fadeInAll)

-- ─────────────────────────────────────────────
-- updateLoader(status, progress)
-- ─────────────────────────────────────────────
function updateLoader(status, progress)
    progress = math.clamp(progress, 0, 100)
    statusLabel.Text = status
    percentLabel.Text = math.floor(progress) .. "%"
    playTickIfNeeded(progress)
    -- Sound ready saat 100%
    if progress >= 100 then
        pcall(function() sndReady:Play() end)
    end

    tw(barFill,
        {Size = UDim2.new(progress / 100, 0, 1, 0)},
        CONFIG.BarLerpSpeed,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    ):Play()
end

-- ─────────────────────────────────────────────
-- loader:Remove()
-- ─────────────────────────────────────────────
function loader:Remove()
    local t = CONFIG.FadeOutSpeed

    -- Sound closing
    pcall(function() sndClose:Play() end)

    -- Semua isi + container slide turun bareng, lalu fade sekaligus
    local slideDist = 180
    local slideTime = t * 1.2

    -- Stop matrix rain
    matrixActive = false

    -- Slide semua elemen turun bareng container
    tw(container, {
        Position = UDim2.new(0.5, -CONFIG.ContainerWidth / 2, 0.5, -CONFIG.ContainerHeight / 2 + slideDist),
    }, slideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()

    -- Fade semua isi + container bersamaan
    tw(container, {BackgroundTransparency = 1}, slideTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
    tw(containerStroke, {Transparency = 1}, slideTime):Play()
    tw(avatarStroke, {Transparency = 1}, slideTime):Play()
    tw(avatarImg, {ImageTransparency = 1}, slideTime):Play()
    tw(nameLabel, {TextTransparency = 1}, slideTime):Play()
    tw(welcomeLabel, {TextTransparency = 1}, slideTime):Play()
    tw(statusLabel, {TextTransparency = 1}, slideTime):Play()
    tw(percentLabel, {TextTransparency = 1}, slideTime):Play()
    tw(barBackground, {BackgroundTransparency = 1}, slideTime):Play()
    tw(barFill, {BackgroundTransparency = 1}, slideTime):Play()

    task.delay(slideTime + 0.1, function()
        screenGui:Destroy()
        -- Cleanup sounds
        pcall(function()
            sndOpen:Destroy()
            sndClose:Destroy()
            sndTick:Destroy()
            sndReady:Destroy()
        end)
    end)
end

-- ─────────────────────────────────────────────
-- Global hooks
-- ─────────────────────────────────────────────
_G.updateLoader = updateLoader
_G.removeLoader = function() loader:Remove() end
