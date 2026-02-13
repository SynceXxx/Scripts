local CONFIG = {
    HubName = "SynceHub",
    HubSubtitle = "Premium Script Hub",
    ContainerWidth = 380,
    ContainerHeight = 140,
    BarHeight = 8,
    BarPaddingX = 32,
    BarLerpSpeed = 0.6,
    FadeInSpeed = 0.4,
    FadeOutSpeed = 0.3,
}

local loader = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GraphiteLoader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local success = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local container = Instance.new("Frame")
container.Name = "LoaderContainer"
container.Size = UDim2.new(0, CONFIG.ContainerWidth, 0, CONFIG.ContainerHeight)
container.Position = UDim2.new(0.5, 0, 0.5, -CONFIG.ContainerHeight / 2)
container.AnchorPoint = Vector2.new(0.5, 0)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = container

local containerStroke = Instance.new("UIStroke")
containerStroke.Color = Color3.fromRGB(68, 68, 72)
containerStroke.Thickness = 1
containerStroke.Transparency = 1
containerStroke.Parent = container

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
}
gradient.Rotation = 145
gradient.Parent = container

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 24)
titleLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 18)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.HubName
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextTransparency = 1
titleLabel.Parent = container

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "SubtitleLabel"
subtitleLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 16)
subtitleLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 42)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = CONFIG.HubSubtitle
subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
subtitleLabel.TextSize = 12
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
subtitleLabel.TextTransparency = 1
subtitleLabel.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 20)
statusLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 68)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Initializing hub..."
statusLabel.TextColor3 = Color3.fromRGB(176, 176, 176)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextTransparency = 1
statusLabel.Parent = container

local barBackground = Instance.new("Frame")
barBackground.Name = "BarBackground"
barBackground.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, CONFIG.BarHeight)
barBackground.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 100)
barBackground.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
barBackground.BorderSizePixel = 0
barBackground.BackgroundTransparency = 1
barBackground.Parent = container

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(0, 3)
barBgCorner.Parent = barBackground

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
barFill.BorderSizePixel = 0
barFill.BackgroundTransparency = 1
barFill.Parent = barBackground

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(0, 3)
barFillCorner.Parent = barFill

local barGradient = Instance.new("UIGradient")
barGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 150, 255))
}
barGradient.Rotation = 90
barGradient.Parent = barFill

local percentLabel = Instance.new("TextLabel")
percentLabel.Name = "PercentLabel"
percentLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 16)
percentLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 115)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentLabel.TextSize = 11
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextXAlignment = Enum.TextXAlignment.Center
percentLabel.TextTransparency = 1
percentLabel.Parent = container

local TweenService = game:GetService("TweenService")

local containerFadeIn = TweenService:Create(
    container,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0.3}
)
local strokeFadeIn = TweenService:Create(
    containerStroke,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Transparency = 0}
)
local titleFadeIn = TweenService:Create(
    titleLabel,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)
local subtitleFadeIn = TweenService:Create(
    subtitleLabel,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)
local textFadeIn = TweenService:Create(
    statusLabel,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)
local barBgFadeIn = TweenService:Create(
    barBackground,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0}
)
local barFillFadeIn = TweenService:Create(
    barFill,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0}
)
local percentFadeIn = TweenService:Create(
    percentLabel,
    TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {TextTransparency = 0}
)

containerFadeIn:Play()
strokeFadeIn:Play()
titleFadeIn:Play()
subtitleFadeIn:Play()
textFadeIn:Play()
barBgFadeIn:Play()
barFillFadeIn:Play()
percentFadeIn:Play()

function updateLoader(status, progress)
    progress = math.clamp(progress, 0, 100)
    statusLabel.Text = status
    percentLabel.Text = math.floor(progress) .. "%"
    
    local targetSize = UDim2.new(progress / 100, 0, 1, 0)
    local barTween = TweenService:Create(
        barFill,
        TweenInfo.new(CONFIG.BarLerpSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    barTween:Play()
end

function loader:Remove()
    local slideDownTween = TweenService:Create(
        container,
        TweenInfo.new(CONFIG.FadeOutSpeed * 1.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {
            Position = UDim2.new(0.5, 0, 0.5, -CONFIG.ContainerHeight / 2 + 100),
            BackgroundTransparency = 1
        }
    )
    local strokeFadeOut = TweenService:Create(
        containerStroke,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Transparency = 1}
    )
    local titleFadeOut = TweenService:Create(
        titleLabel,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    local subtitleFadeOut = TweenService:Create(
        subtitleLabel,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    local textFadeOut = TweenService:Create(
        statusLabel,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    local barBgFadeOut = TweenService:Create(
        barBackground,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    local barFillFadeOut = TweenService:Create(
        barFill,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    local percentFadeOut = TweenService:Create(
        percentLabel,
        TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    
    slideDownTween:Play()
    strokeFadeOut:Play()
    titleFadeOut:Play()
    subtitleFadeOut:Play()
    textFadeOut:Play()
    barBgFadeOut:Play()
    barFillFadeOut:Play()
    percentFadeOut:Play()
    
    slideDownTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

_G.updateLoader = updateLoader
_G.removeLoader = function() loader:Remove() end

task.spawn(function()
    task.wait(0.5)
    updateLoader("Loading script modules...", 15)
    task.wait(0.8)
    updateLoader("Connecting to services...", 30)
    task.wait(0.8)
    updateLoader("Initializing features...", 50)
    task.wait(0.8)
    updateLoader("Loading UI components...", 70)
    task.wait(0.8)
    updateLoader("Bypassing security checks...", 85)
    task.wait(0.8)
    updateLoader("Finalizing hub setup...", 95)
    task.wait(0.5)
    updateLoader("Complete!", 100)
    task.wait(1)
    loader:Remove()
end)
