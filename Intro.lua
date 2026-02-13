-- SynceHub Intro Animation
-- Modern blur intro with smooth animations

local Intro = {}

function Intro.show()
    local P = game:GetService("Players")
    local T = game:GetService("TweenService")
    local L = P.LocalPlayer
    
    -- Create ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SynceHubIntro"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    
    -- Parent to CoreGui (works on both PC & Mobile)
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not gui.Parent then
        gui.Parent = L:WaitForChild("PlayerGui")
    end
    
    -- Blur Background
    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.Position = UDim2.new(0, 0, 0, 0)
    blur.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    blur.BackgroundTransparency = 1
    blur.BorderSizePixel = 0
    blur.ZIndex = 1000
    blur.Parent = gui
    
    -- Gradient overlay for depth
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 45
    gradient.Parent = blur
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 400, 0, 200)
    container.Position = UDim2.new(0.5, -200, 0.5, -100)
    container.BackgroundTransparency = 1
    container.ZIndex = 1001
    container.Parent = blur
    
    -- Logo/Title Container
    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(1, 0, 0, 80)
    logoContainer.Position = UDim2.new(0, 0, 0.5, -40)
    logoContainer.BackgroundTransparency = 1
    logoContainer.ZIndex = 1002
    logoContainer.Parent = container
    
    -- "SynceHub" Text - Modern Font
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SynceHub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 56
    title.TextTransparency = 1
    title.TextStrokeTransparency = 1
    title.TextStrokeColor3 = Color3.fromRGB(0, 122, 255)
    title.ZIndex = 1003
    title.Parent = logoContainer
    
    -- Glow effect behind text
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 100, 1, 100)
    glow.Position = UDim2.new(0.5, -50, 0.5, -50)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5554236805"
    glow.ImageColor3 = Color3.fromRGB(0, 122, 255)
    glow.ImageTransparency = 1
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(23, 23, 277, 277)
    glow.ZIndex = 1002
    glow.Parent = logoContainer
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 1, 10)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Loading Experience..."
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.TextTransparency = 1
    subtitle.ZIndex = 1003
    subtitle.Parent = logoContainer
    
    -- Loading Bar Container
    local loadBarBg = Instance.new("Frame")
    loadBarBg.Size = UDim2.new(0, 300, 0, 4)
    loadBarBg.Position = UDim2.new(0.5, -150, 1, 50)
    loadBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    loadBarBg.BorderSizePixel = 0
    loadBarBg.BackgroundTransparency = 1
    loadBarBg.ZIndex = 1003
    loadBarBg.Parent = container
    
    local loadBarBgCorner = Instance.new("UICorner")
    loadBarBgCorner.CornerRadius = UDim.new(1, 0)
    loadBarBgCorner.Parent = loadBarBg
    
    -- Loading Bar Fill
    local loadBar = Instance.new("Frame")
    loadBar.Size = UDim2.new(0, 0, 1, 0)
    loadBar.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    loadBar.BorderSizePixel = 0
    loadBar.ZIndex = 1004
    loadBar.Parent = loadBarBg
    
    local loadBarCorner = Instance.new("UICorner")
    loadBarCorner.CornerRadius = UDim.new(1, 0)
    loadBarCorner.Parent = loadBar
    
    -- Particles effect (optional decorative elements)
    local function createParticle(delay)
        task.wait(delay)
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, 6, 0, 6)
        particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
        particle.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        particle.BackgroundTransparency = 0.5
        particle.BorderSizePixel = 0
        particle.ZIndex = 1002
        particle.Parent = blur
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        
        -- Animate particle
        T:Create(particle, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(2)
        particle:Destroy()
    end
    
    -- Spawn multiple particles
    for i = 1, 8 do
        spawn(function()
            createParticle(i * 0.15)
        end)
    end
    
    -- ============================================
    -- ANIMATION SEQUENCE
    -- ============================================
    
    -- Sound effect (optional)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6895079853"
    sound.Volume = 0.3
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
    
    -- Phase 1: Fade in blur background (0.5s)
    T:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
    
    task.wait(0.3)
    
    -- Phase 2: Scale in title with glow (0.8s)
    title.TextScaled = false
    title.Size = UDim2.new(0.5, 0, 0.5, 0)
    title.Position = UDim2.new(0.25, 0, 0.25, 0)
    
    T:Create(title, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextTransparency = 0,
        TextStrokeTransparency = 0.7
    }):Play()
    
    T:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0.7
    }):Play()
    
    task.wait(0.5)
    
    -- Phase 3: Fade in subtitle (0.4s)
    T:Create(subtitle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    -- Phase 4: Show loading bar background (0.3s)
    T:Create(loadBarBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
    
    task.wait(0.3)
    
    -- Phase 5: Fill loading bar (1.2s)
    T:Create(loadBar, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
    
    task.wait(1.4)
    
    -- Phase 6: Fade out everything (0.5s)
    T:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1,
        TextStrokeTransparency = 1,
        Position = UDim2.new(0, 0, -0.2, 0)
    }):Play()
    
    T:Create(subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    T:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        ImageTransparency = 1
    }):Play()
    
    T:Create(loadBarBg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    T:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.6)
    
    -- Destroy GUI
    gui:Destroy()
end

return Intro
