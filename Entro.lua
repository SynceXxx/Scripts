-- SynceHub Intro Animation
-- Clean blur intro with smooth white/gray blur effect

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
    
    -- Full Screen Blur Background (White/Gray smooth blur)
    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.Position = UDim2.new(0, 0, 0, 0)
    blur.BackgroundColor3 = Color3.fromRGB(240, 240, 245) -- Light gray/white
    blur.BackgroundTransparency = 1
    blur.BorderSizePixel = 0
    blur.ZIndex = 1000
    blur.Parent = gui
    
    -- Add subtle texture with gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 250, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 240, 245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 250, 255))
    }
    gradient.Rotation = 90
    gradient.Parent = blur
    
    -- "SynceHub" Text - Centered, Modern Font
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 600, 0, 120)
    title.Position = UDim2.new(0.5, -300, 0.5, -60)
    title.BackgroundTransparency = 1
    title.Text = "SynceHub"
    title.TextColor3 = Color3.fromRGB(20, 20, 25) -- Dark text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 72
    title.TextTransparency = 1
    title.ZIndex = 1003
    title.Parent = blur
    
    -- Subtle shadow for depth (optional)
    local shadow = Instance.new("TextLabel")
    shadow.Size = title.Size
    shadow.Position = UDim2.new(0, 2, 0, 2)
    shadow.BackgroundTransparency = 1
    shadow.Text = "SynceHub"
    shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    shadow.Font = Enum.Font.GothamBold
    shadow.TextSize = 72
    shadow.TextTransparency = 1
    shadow.ZIndex = 1002
    shadow.Parent = title
    
    -- ============================================
    -- ANIMATION SEQUENCE (SLOWER & SMOOTHER)
    -- ============================================
    
    -- Sound effect
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6895079853"
    sound.Volume = 0.2
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
    
    -- Phase 1: Blur background fade in (1s - SLOWER)
    T:Create(blur, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15 -- Semi-transparent blur effect
    }):Play()
    
    task.wait(0.8)
    
    -- Phase 2: Title fade in with scale (1.2s - SLOWER)
    title.Size = UDim2.new(0, 500, 0, 100)
    title.Position = UDim2.new(0.5, -250, 0.5, -50)
    
    -- Shadow fade in
    T:Create(shadow, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0.85
    }):Play()
    
    -- Title scale & fade in
    T:Create(title, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 120),
        Position = UDim2.new(0.5, -300, 0.5, -60),
        TextTransparency = 0
    }):Play()
    
    task.wait(2) -- Hold the title for 2 seconds so players can see it
    
    -- Phase 3: Fade out (0.8s - SLOWER)
    T:Create(title, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1,
        Position = UDim2.new(0.5, -300, 0.3, -60) -- Slide up slightly
    }):Play()
    
    T:Create(shadow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    
    T:Create(blur, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(1)
    
    -- Destroy GUI
    gui:Destroy()
end

return Intro
