-- Intro.lua
-- SynceHub Loader Animation
-- Made by SynceXxx

local Intro = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Intro.show()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SynceHubIntro"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Try CoreGui first, fallback to PlayerGui
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Background (Full screen black overlay)
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Position = UDim2.new(0, 0, 0, 0)
    Background.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Background.BorderSizePixel = 0
    Background.ZIndex = 10000
    Background.Parent = ScreenGui
    
    -- Gradient effect
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
    }
    Gradient.Rotation = 45
    Gradient.Parent = Background
    
    -- Particles Container (for moving dots)
    local ParticlesContainer = Instance.new("Frame")
    ParticlesContainer.Size = UDim2.new(1, 0, 1, 0)
    ParticlesContainer.BackgroundTransparency = 1
    ParticlesContainer.ZIndex = 10001
    ParticlesContainer.Parent = Background
    
    -- Create floating particles
    for i = 1, 15 do
        local Particle = Instance.new("Frame")
        Particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        Particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Particle.BackgroundColor3 = Color3.fromRGB(100, 120, 255)
        Particle.BackgroundTransparency = math.random(50, 80) / 100
        Particle.BorderSizePixel = 0
        Particle.ZIndex = 10001
        Particle.Parent = ParticlesContainer
        
        Instance.new("UICorner", Particle).CornerRadius = UDim.new(1, 0)
        
        -- Animate particles
        local duration = math.random(3, 6)
        local endPos = UDim2.new(math.random(), 0, math.random(), 0)
        TweenService:Create(Particle, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
            Position = endPos,
            BackgroundTransparency = 1
        }):Play()
    end
    
    -- Logo Container
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(0, 400, 0, 200)
    LogoContainer.Position = UDim2.new(0.5, -200, 0.5, -150)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.ZIndex = 10002
    LogoContainer.Parent = Background
    
    -- Logo Circle (Animated ring)
    local LogoCircle = Instance.new("Frame")
    LogoCircle.Size = UDim2.new(0, 100, 0, 100)
    LogoCircle.Position = UDim2.new(0.5, -50, 0, 20)
    LogoCircle.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    LogoCircle.BackgroundTransparency = 0.8
    LogoCircle.BorderSizePixel = 0
    LogoCircle.ZIndex = 10003
    LogoCircle.Rotation = 0
    LogoCircle.Parent = LogoContainer
    
    Instance.new("UICorner", LogoCircle).CornerRadius = UDim.new(1, 0)
    
    local CircleStroke = Instance.new("UIStroke", LogoCircle)
    CircleStroke.Color = Color3.fromRGB(0, 140, 255)
    CircleStroke.Thickness = 3
    CircleStroke.Transparency = 0
    
    -- Logo Icon (S letter)
    local LogoIcon = Instance.new("TextLabel")
    LogoIcon.Size = UDim2.new(1, 0, 1, 0)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Text = "S"
    LogoIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoIcon.Font = Enum.Font.GothamBold
    LogoIcon.TextSize = 60
    LogoIcon.TextTransparency = 0
    LogoIcon.ZIndex = 10004
    LogoIcon.Parent = LogoCircle
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 130)
    Title.BackgroundTransparency = 1
    Title.Text = "SynceHub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 42
    Title.TextTransparency = 1
    Title.ZIndex = 10003
    Title.Parent = LogoContainer
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Position = UDim2.new(0, 0, 0, 180)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Premium Script Hub"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 14
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 10003
    Subtitle.Parent = LogoContainer
    
    -- Loading Bar Container
    local LoadingContainer = Instance.new("Frame")
    LoadingContainer.Size = UDim2.new(0, 300, 0, 60)
    LoadingContainer.Position = UDim2.new(0.5, -150, 0.5, 100)
    LoadingContainer.BackgroundTransparency = 1
    LoadingContainer.ZIndex = 10002
    LoadingContainer.Parent = Background
    
    -- Loading Bar Background
    local LoadingBarBg = Instance.new("Frame")
    LoadingBarBg.Size = UDim2.new(1, 0, 0, 4)
    LoadingBarBg.Position = UDim2.new(0, 0, 0, 25)
    LoadingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    LoadingBarBg.BorderSizePixel = 0
    LoadingBarBg.ZIndex = 10003
    LoadingBarBg.Parent = LoadingContainer
    
    Instance.new("UICorner", LoadingBarBg).CornerRadius = UDim.new(1, 0)
    
    -- Loading Bar Fill
    local LoadingBarFill = Instance.new("Frame")
    LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingBarFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    LoadingBarFill.BorderSizePixel = 0
    LoadingBarFill.ZIndex = 10004
    LoadingBarFill.Parent = LoadingBarBg
    
    Instance.new("UICorner", LoadingBarFill).CornerRadius = UDim.new(1, 0)
    
    -- Loading Text
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(1, 0, 0, 20)
    LoadingText.Position = UDim2.new(0, 0, 0, 0)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "Initializing..."
    LoadingText.TextColor3 = Color3.fromRGB(200, 200, 210)
    LoadingText.Font = Enum.Font.Gotham
    LoadingText.TextSize = 12
    LoadingText.TextTransparency = 1
    LoadingText.ZIndex = 10003
    LoadingText.Parent = LoadingContainer
    
    -- Percentage
    local Percentage = Instance.new("TextLabel")
    Percentage.Size = UDim2.new(1, 0, 0, 20)
    Percentage.Position = UDim2.new(0, 0, 0, 35)
    Percentage.BackgroundTransparency = 1
    Percentage.Text = "0%"
    Percentage.TextColor3 = Color3.fromRGB(255, 255, 255)
    Percentage.Font = Enum.Font.GothamBold
    Percentage.TextSize = 14
    Percentage.TextTransparency = 1
    Percentage.ZIndex = 10003
    Percentage.Parent = LoadingContainer
    
    -- ============================================
    -- ANIMATION SEQUENCE
    -- ============================================
    
    spawn(function()
        -- Phase 1: Logo appears (0.5s)
        TweenService:Create(LogoCircle, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 100, 0, 100)
        }):Play()
        
        TweenService:Create(LogoIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        }):Play()
        
        task.wait(0.5)
        
        -- Phase 2: Title & Subtitle fade in (0.5s)
        TweenService:Create(Title, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        }):Play()
        
        task.wait(0.5)
        
        -- Phase 3: Loading elements fade in (0.3s)
        TweenService:Create(LoadingText, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(Percentage, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        }):Play()
        
        task.wait(0.3)
        
        -- Phase 4: Loading simulation (2s)
        local loadingSteps = {
            {percent = 20, text = "Loading modules...", duration = 0.3},
            {percent = 45, text = "Connecting to services...", duration = 0.4},
            {percent = 70, text = "Initializing features...", duration = 0.5},
            {percent = 90, text = "Finalizing...", duration = 0.4},
            {percent = 100, text = "Complete!", duration = 0.3},
        }
        
        for _, step in ipairs(loadingSteps) do
            LoadingText.Text = step.text
            Percentage.Text = step.percent .. "%"
            
            TweenService:Create(LoadingBarFill, TweenInfo.new(step.duration, Enum.EasingStyle.Quad), {
                Size = UDim2.new(step.percent / 100, 0, 1, 0)
            }):Play()
            
            task.wait(step.duration)
        end
        
        -- Rotate logo during loading
        TweenService:Create(LogoCircle, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
            Rotation = 360
        }):Play()
        
        task.wait(0.5)
        
        -- Phase 5: Fade out (0.5s)
        TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(LogoIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(CircleStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            Transparency = 1
        }):Play()
        
        TweenService:Create(Title, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(LoadingText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(Percentage, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        }):Play()
        
        task.wait(0.5)
        
        -- Destroy intro
        ScreenGui:Destroy()
        print("✅ SynceHub Intro Complete!")
    end)
end

return Intro
