-- tabcontent.lua
-- SynceHub - UI Creation and Tab Content

local TabContent = {}

local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

local C, S, Feature, gKN
local kB

-- Sound effects
local Sounds = {
    Click = "rbxassetid://6895079853",
    Toggle = "rbxassetid://6895079853", 
    Hover = "rbxassetid://10066931761",
    Minimize = "rbxassetid://6895079853",
    Dropdown = "rbxassetid://6895079853",
    Success = "rbxassetid://6026984224",
    Error = "rbxassetid://6026984224"
}

local function playSound(soundId, volume)
    volume = volume or 0.5
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName, gameName)
    C = config
    S = state
    Feature = featureModule
    gKN = getKeyName
    
    if S.G then S.G:Destroy() end
    
    local sS = workspace.CurrentCamera.ViewportSize
    local w = isMobile and math.min(310, sS.X - 24) or 320
    local h = isMobile and math.min(480, sS.Y - 100) or 460
    local bH = isMobile and 46 or 44
    local p = 12
    local fS = isMobile and 14 or 13
    
    -- Color scheme
    local Co = {
        bg = Color3.fromRGB(20, 20, 25),
        cd = Color3.fromRGB(30, 30, 35),
        ch = Color3.fromRGB(40, 40, 45),
        ac = Color3.fromRGB(0, 122, 255),
        al = Color3.fromRGB(25, 45, 70),
        tx = Color3.fromRGB(240, 240, 245),
        ts = Color3.fromRGB(150, 150, 160),
        br = Color3.fromRGB(50, 50, 55),
        sc = Color3.fromRGB(120, 120, 130),
        warn = Color3.fromRGB(88, 101, 242)
    }
    
    -- Create main GUI container
    local g = Instance.new("ScreenGui")
    g.Name = "SynceHub"
    g.ResetOnSpawn = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main frame with rounded corners
    local m = Instance.new("Frame")
    m.Name = "Main"
    m.Size = UDim2.new(0, w, 0, h)
    m.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3 = Co.bg
    m.BorderSizePixel = 0
    m.ClipsDescendants = true  -- Clips content within rounded corners
    m.BackgroundTransparency = 0
    m.Parent = g
    
    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16)
    
    -- Drop shadow for depth effect
    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 30, 1, 30)
    sh.Position = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxassetid://5554236805"
    sh.ImageColor3 = Color3.new(0, 0, 0)
    sh.ImageTransparency = 0.3
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(23, 23, 277, 277)
    sh.ZIndex = 0
    sh.Parent = m
    
    -- Header
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 52)
    hd.BackgroundTransparency = 1
    hd.Parent = m
    
    local tL = Instance.new("TextLabel")
    tL.Size = UDim2.new(1, -60, 0, 20)
    tL.Position = UDim2.new(0, p, 0, 12)
    tL.BackgroundTransparency = 1
    tL.Text = "SynceHub"
    tL.TextColor3 = Co.tx
    tL.Font = Enum.Font.GothamBold
    tL.TextSize = 18
    tL.TextXAlignment = Enum.TextXAlignment.Left
    tL.Parent = hd
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -60, 0, 14)
    st.Position = UDim2.new(0, p, 0, 33)
    st.BackgroundTransparency = 1
    st.Text = (gameName or "Cut Grass") .. " | " .. version
    st.TextColor3 = Co.ts
    st.Font = Enum.Font.Gotham
    st.TextSize = 11
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = hd
    

    -- Close button
    local clBtn = Instance.new("TextButton")
    clBtn.Size = UDim2.new(0, 32, 0, 32)
    clBtn.Position = UDim2.new(1, -p-32, 0, 10)
    clBtn.BackgroundColor3 = Co.ch
    clBtn.Text = "×"
    clBtn.TextColor3 = Co.ts
    clBtn.Font = Enum.Font.GothamBold
    clBtn.TextSize = 20
    clBtn.Parent = hd

    Instance.new("UICorner", clBtn).CornerRadius = UDim.new(0, 10)

    -- Minimize button
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 32, 0, 32)
    cb.Position = UDim2.new(1, -p-70, 0, 10)
    cb.BackgroundColor3 = Co.ch
    cb.Text = "−"
    cb.TextColor3 = Co.ts
    cb.Font = Enum.Font.GothamBold
    cb.TextSize = 16
    cb.Parent = hd

    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 10)
    
    local mn = false
    local fSz = m.Size
-- Confirmation dialog untuk close window
local function showConfirmDialog()
    if m:FindFirstChild("ConfirmBlur") then return end
    
    -- Auto-maximize UI jika sedang minimized
    if mn then
        mn = false
        T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
        cb.Text = "−"
        task.wait(0.3)
    end
    
    -- Overlay blur untuk block interaksi
    local blur = Instance.new("Frame")
    blur.Name = "ConfirmBlur"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.Position = UDim2.new(0, 0, 0, 0)
    blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blur.BackgroundTransparency = 0.5
    blur.BorderSizePixel = 0
    blur.ZIndex = 2000
    blur.Parent = m
    
    -- Rounded corners untuk blur (ikutin bentuk Main frame)
    Instance.new("UICorner", blur).CornerRadius = UDim.new(0, 16)
    
    -- Block semua input kecuali dialog
    local blocker = Instance.new("TextButton")
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.BackgroundTransparency = 1
    blocker.Text = ""
    blocker.ZIndex = 2000
    blocker.Parent = blur
    blocker.Active = true
    blocker.AutoButtonColor = false
    
    -- Dialog container - COMPACT & FLAT
    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0, 280, 0, 140)
    dialog.Position = UDim2.new(0.5, -140, 0.5, -70)
    dialog.BackgroundColor3 = Co.cd
    dialog.BackgroundTransparency = 0.3
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 2001
    dialog.Parent = blur
    
    Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)
    
    -- Blur effect yang ikutin bentuk dialog
    local blurEffect = Instance.new("ImageLabel")
    blurEffect.Size = UDim2.new(1, 0, 1, 0)
    blurEffect.Position = UDim2.new(0, 0, 0, 0)
    blurEffect.BackgroundTransparency = 1
    blurEffect.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    blurEffect.ImageTransparency = 1
    blurEffect.ScaleType = Enum.ScaleType.Stretch
    blurEffect.ZIndex = 2000
    blurEffect.Parent = dialog
    
    Instance.new("UICorner", blurEffect).CornerRadius = UDim.new(0, 14)
    
    -- Glassmorphism effect
    local glassLayer = Instance.new("Frame")
    glassLayer.Size = UDim2.new(1, 0, 1, 0)
    glassLayer.Position = UDim2.new(0, 0, 0, 0)
    glassLayer.BackgroundColor3 = Co.cd
    glassLayer.BackgroundTransparency = 0.4
    glassLayer.BorderSizePixel = 0
    glassLayer.ZIndex = 2000
    glassLayer.Parent = dialog
    
    Instance.new("UICorner", glassLayer).CornerRadius = UDim.new(0, 14)
    
    local dialogStroke = Instance.new("UIStroke", dialog)
    dialogStroke.Color = Co.br
    dialogStroke.Thickness = 1
    dialogStroke.Transparency = 0.3
    
    -- Shadow untuk depth (ganti blur hitam)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = 2000
    shadow.Parent = dialog
    
    -- Icon - MOVED TO TOP RIGHT (small)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(1, -26, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://101745201658882"
    icon.ImageColor3 = Co.ts
    icon.ZIndex = 2002
    icon.Parent = dialog
    
    -- Title - "Close Window"
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -45, 0, 24)
    title.Position = UDim2.new(0, 16, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "Close Window"
    title.TextColor3 = Co.tx
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 2002
    title.Parent = dialog
    
    -- Description - Updated text dari foto
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -32, 0, 36)
    desc.Position = UDim2.new(0, 16, 0, 40)
    desc.BackgroundTransparency = 1
    desc.Text = "Do you want to close this window?\nYou will not be able to open it again."
    desc.TextColor3 = Co.tx
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.ZIndex = 2002
    desc.Parent = dialog
    
    -- Buttons container
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -32, 0, 36)
    btnContainer.Position = UDim2.new(0, 16, 1, -44)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 2002
    btnContainer.Parent = dialog
    
    -- Cancel button
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
    cancelBtn.Position = UDim2.new(0, 0, 0, 0)
    cancelBtn.BackgroundColor3 = Co.ch
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Co.tx
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 13
    cancelBtn.ZIndex = 2003
    cancelBtn.Parent = btnContainer
    
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)
    
    -- Confirm button - "Close Window"
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
    confirmBtn.Position = UDim2.new(0.52, 0, 0, 0)
    confirmBtn.BackgroundColor3 = Co.ac
    confirmBtn.Text = "Close Window"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 13
    confirmBtn.ZIndex = 2003
    confirmBtn.Parent = btnContainer
    
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)
    
    -- Animations - SMOOTH FADE IN
    blur.BackgroundTransparency = 1
    dialog.BackgroundTransparency = 1
    glassLayer.BackgroundTransparency = 1
    icon.ImageTransparency = 1
    title.TextTransparency = 1
    desc.TextTransparency = 1
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.TextTransparency = 1
    confirmBtn.BackgroundTransparency = 1
    confirmBtn.TextTransparency = 1
    dialogStroke.Transparency = 1
    shadow.ImageTransparency = 1
    
    T:Create(blur, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5
    }):Play()
    T:Create(dialog, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.3
    }):Play()
    T:Create(glassLayer, TweenInfo.new(0.25), {
        BackgroundTransparency = 0.4
    }):Play()
    T:Create(dialogStroke, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
    T:Create(shadow, TweenInfo.new(0.25), {ImageTransparency = 0.6}):Play()
    T:Create(icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
    T:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    T:Create(desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    T:Create(cancelBtn, TweenInfo.new(0.3), {
        BackgroundTransparency = 0,
        TextTransparency = 0
    }):Play()
    T:Create(confirmBtn, TweenInfo.new(0.3), {
        BackgroundTransparency = 0,
        TextTransparency = 0
    }):Play()
    
    playSound(Sounds.Click, 0.3)
    
    -- Button hover effects
    cancelBtn.MouseEnter:Connect(function()
        T:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
    end)
    
    cancelBtn.MouseLeave:Connect(function()
        T:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
    end)
    
    confirmBtn.MouseEnter:Connect(function()
        T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 144, 255)}):Play()
    end)
    
    confirmBtn.MouseLeave:Connect(function()
        T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ac}):Play()
    end)
    
    -- Cancel action - SMOOTH FADE OUT
    cancelBtn.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.3)
        T:Create(blur, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        T:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        T:Create(glassLayer, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        T:Create(dialogStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        T:Create(shadow, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        T:Create(icon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        T:Create(title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        T:Create(desc, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        T:Create(cancelBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        T:Create(confirmBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        task.wait(0.2)
        blur:Destroy()
    end)
    
    -- Confirm action - SMOOTH FADE OUT
    confirmBtn.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.4)
        T:Create(blur, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        T:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        T:Create(glassLayer, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        T:Create(dialogStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        T:Create(shadow, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        T:Create(icon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        T:Create(title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        T:Create(desc, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        T:Create(cancelBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        T:Create(confirmBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        task.wait(0.2)
        blur:Destroy()
        
        -- Destroy UI
        S.U = true
        _G.SynceHubLoaded = false
        for _, conn in pairs(S.Co) do
            pcall(function() conn:Disconnect() end)
        end
        if S.G then S.G:Destroy() end
        if S.Mb then S.Mb:Destroy() end
    end)
end
    
    -- Close button click
    clBtn.MouseButton1Click:Connect(function()
        showConfirmDialog()
    end)
    
    -- Close button hover
    clBtn.MouseEnter:Connect(function()
        T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
    end)
    
    clBtn.MouseLeave:Connect(function()
        T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
    end)
    
    -- Minimize button click
    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.3)
        mn = not mn
        local tS = mn and UDim2.new(0, w, 0, 52) or fSz
        T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = tS}):Play()
        cb.Text = mn and "+" or "−"
    end)
    
    -- Divider
    local dv = Instance.new("Frame")
    dv.Size = UDim2.new(1, -p*2, 0, 1)
    dv.Position = UDim2.new(0, p, 0, 51)
    dv.BackgroundColor3 = Co.br
    dv.BorderSizePixel = 0
    dv.Parent = m
    
    -- Scroll container - FIXED: scrollbar stays inside rounded corners
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -4, 1, -60) 
    sc.Position = UDim2.new(0, 2, 0, 56)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 2
    sc.ScrollBarImageColor3 = Co.br
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.ClipsDescendants = true
    sc.Parent = m
    
    local sP = Instance.new("UIPadding")
    sP.PaddingLeft = UDim.new(0, p - 2)
    sP.PaddingRight = UDim.new(0, p + 2)
    sP.PaddingTop = UDim.new(0, 2)
    sP.PaddingBottom = UDim.new(0, p)
    sP.Parent = sc
    
    local ly = Instance.new("UIListLayout")
    ly.Padding = UDim.new(0, 6)
    ly.SortOrder = Enum.SortOrder.LayoutOrder
    ly.Parent = sc
    
    local ord = 0
    local function nO()
        ord = ord + 1
        return ord
    end
    
    local oD = {}
    local function cD()
        for _, d in pairs(oD) do
            if d and d.Visible then
                d.Visible = false
            end
        end
    end
    
    sc:GetPropertyChangedSignal("CanvasPosition"):Connect(cD)
    
    -- UI Element creators
    local function Se(n)
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, 0, 0, 24)
        s.BackgroundTransparency = 1
        s.Text = string.upper(n)
        s.TextColor3 = Co.sc
        s.Font = Enum.Font.GothamBold
        s.TextSize = 10
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.LayoutOrder = nO()
        s.Parent = sc
    end
    
    local function Bt(n, cl, ico)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, bH)
        b.BackgroundColor3 = Co.cd
        b.Text = ""
        b.LayoutOrder = nO()
        b.Parent = sc
        
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", b).Color = Co.br
        
        if ico then
            local ic = Instance.new("ImageLabel")
            ic.Size = UDim2.new(0, 20, 0, 20)
            ic.Position = UDim2.new(1, -34, 0.5, -10)
            ic.BackgroundTransparency = 1
            ic.Image = ico
            ic.ImageColor3 = Co.ts
            ic.Parent = b
        end
        
        local tx = Instance.new("TextLabel")
        tx.Size = UDim2.new(1, -50, 1, 0)
        tx.Position = UDim2.new(0, 14, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text = n
        tx.TextColor3 = Co.tx
        tx.Font = Enum.Font.GothamBold
        tx.TextSize = fS
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx.Parent = b
        
        b.MouseEnter:Connect(function()
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
        end)
        
        b.MouseLeave:Connect(function()
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
        end)
        
        b.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            cl()
        end)
        return b
    end
    
    -- Slider creation function
    local function Sl(n, min, max, cK, callback)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH + 10)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()
        ca.Parent = sc
        
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br
        
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.6, 0, 0, 20)
        lb.Position = UDim2.new(0, 14, 0, 8)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.Parent = ca
        
        -- Editable value box
        local vL = Instance.new("TextBox")
        vL.Size = UDim2.new(0, 60, 0, 24)
        vL.Position = UDim2.new(1, -74, 0, 6)
        vL.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        vL.Text = tostring(C[cK])
        vL.TextColor3 = Co.tx
        vL.Font = Enum.Font.GothamBold
        vL.TextSize = fS
        vL.TextXAlignment = Enum.TextXAlignment.Center
        vL.ClearTextOnFocus = false
        vL.Parent = ca
        
        Instance.new("UICorner", vL).CornerRadius = UDim.new(0, 8)
        
        local sB = Instance.new("Frame")
        sB.Size = UDim2.new(1, -28, 0, 6)
        sB.Position = UDim2.new(0, 14, 1, -16)
        sB.BackgroundColor3 = Co.ch
        sB.BorderSizePixel = 0
        sB.Parent = ca
        
        Instance.new("UICorner", sB).CornerRadius = UDim.new(1, 0)
        
        local sF = Instance.new("Frame")
        sF.Size = UDim2.new((C[cK] - min) / (max - min), 0, 1, 0)
        sF.BackgroundColor3 = Co.ac
        sF.BorderSizePixel = 0
        sF.Parent = sB
        
        Instance.new("UICorner", sF).CornerRadius = UDim.new(1, 0)
        
        local sN = Instance.new("Frame")
        sN.Size = UDim2.new(0, 16, 0, 16)
        sN.Position = UDim2.new((C[cK] - min) / (max - min), -8, 0.5, -8)
        sN.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sN.BorderSizePixel = 0
        sN.Parent = sB
        
        Instance.new("UICorner", sN).CornerRadius = UDim.new(1, 0)
        
        -- Update slider visual
        local function updateSlider(val)
            val = math.clamp(val, min, max)
            C[cK] = val
            vL.Text = tostring(val)
            local pct = (val - min) / (max - min)
            sF.Size = UDim2.new(pct, 0, 1, 0)
            sN.Position = UDim2.new(pct, -8, 0.5, -8)
        end
        
        -- TextBox edit support
        vL.FocusLost:Connect(function()
            local val = tonumber(vL.Text)
            if val then
                val = math.clamp(math.floor(val), min, max)
                updateSlider(val)
                if callback then callback(val) end
            else
                vL.Text = tostring(C[cK])
            end
        end)
        
        -- Dragging logic - MORE RESPONSIVE
        local dG = false
        
        -- Click on slider bar directly
        sB.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = true
                playSound(Sounds.Click, 0.2)
                
                local mP = i.Position.X
                local sP = sB.AbsolutePosition.X
                local sW = sB.AbsoluteSize.X
                local pct = math.clamp((mP - sP) / sW, 0, 1)
                local val = math.floor(min + (max - min) * pct)
                
                updateSlider(val)
                if callback then callback(val) end
            end
        end)
        
        sB.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = false
            end
        end)
        
        -- Drag knob
        sN.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = true
                playSound(Sounds.Click, 0.2)
            end
        end)
        
        sN.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = false
            end
        end)
        
        U.InputChanged:Connect(function(i)
            if dG and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local mP = i.Position.X
                local sP = sB.AbsolutePosition.X
                local sW = sB.AbsoluteSize.X
                local pct = math.clamp((mP - sP) / sW, 0, 1)
                local val = math.floor(min + (max - min) * pct)
                
                updateSlider(val)
                if callback then callback(val) end
            end
        end)
        
        return ca
    end
    
    local function Tg(n, cK, callback, ico)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()
        ca.Parent = sc
        
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br
        
        -- Icon support
        if ico then
            local ic = Instance.new("ImageLabel")
            ic.Size = UDim2.new(0, 22, 0, 22)
            ic.Position = UDim2.new(0, 14, 0.5, -11)
            ic.BackgroundTransparency = 1
            ic.Image = "rbxassetid://" .. ico
            ic.ImageColor3 = Co.ts
            ic.Parent = ca
        end
        
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -100, 1, 0)
        lb.Position = UDim2.new(0, ico and 44 or 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb.Parent = ca
        
        local tg = Instance.new("TextButton")
        tg.Size = UDim2.new(0, 44, 0, 24)
        tg.Position = UDim2.new(1, -56, 0.5, -12)
        tg.BackgroundColor3 = C[cK] and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 65)
        tg.Text = ""
        tg.Parent = ca
        
        Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)
        
        local tb = Instance.new("Frame")
        tb.Size = UDim2.new(0, 20, 0, 20)
        tb.Position = C[cK] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        tb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tb.Parent = tg
        
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
        
        tg.MouseButton1Click:Connect(function()
            playSound(Sounds.Toggle, 0.3)
            C[cK] = not C[cK]
            T:Create(tg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                BackgroundColor3 = C[cK] and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 65)
            }):Play()
            T:Create(tb, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = C[cK] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            }):Play()
            
            if callback then
                callback(C[cK])
            end
        end)
        
        return ca
    end
    
    -- Input box creation function
    local function Ib(n, cK)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()
        ca.Parent = sc
        
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br
        
        -- Label untuk nama input
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.48, 0, 1, 0)
        lb.Position = UDim2.new(0, 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb.Parent = ca
        
        -- Text input box dengan placeholder
        local ib = Instance.new("TextBox")
        ib.Size = UDim2.new(0.48, -14, 0, 32)
        ib.Position = UDim2.new(0.52, 0, 0.5, -16)
        ib.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        ib.Text = ""
        ib.TextColor3 = Co.tx
        ib.Font = Enum.Font.GothamMedium
        ib.TextSize = fS
        ib.PlaceholderText = "Enter amount..."
        ib.PlaceholderColor3 = Co.ts
        ib.ClearTextOnFocus = false
        ib.TextXAlignment = Enum.TextXAlignment.Center
        ib.Parent = ca
        
        Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 8)
        
        -- Load nilai awal jika valid (lebih dari 0)
        if C[cK] and C[cK] > 0 then
            ib.Text = tostring(C[cK])
        end
        
        -- Validasi input saat user selesai mengetik
        ib.FocusLost:Connect(function()
            local v = tonumber(ib.Text)
            
            if v and v >= 1 then
                -- Valid: angka 1 ke atas
                C[cK] = v
            elseif v and v < 0 then
                -- Error: angka negatif
                Feature.showNotification("Amount cannot be negative!", false)
                playSound(Sounds.Error, 0.3)
                C[cK] = 0
                ib.Text = ""
            elseif v and v == 0 then
                -- Error: angka 0
                Feature.showNotification("Amount must be greater than 0!", false)
                playSound(Sounds.Error, 0.3)
                C[cK] = 0
                ib.Text = ""
            else
                -- Error: bukan angka
                C[cK] = 0
                ib.Text = ""
            end
        end)
    end
    
    -- Dropdown menu creation function
    local function Dd(n, op, cK)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.ClipsDescendants = false
        ca.LayoutOrder = nO()
        ca.Parent = sc
        
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br
        
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.42, 0, 1, 0)
        lb.Position = UDim2.new(0, 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb.Parent = ca
        
        local db = Instance.new("TextButton")
        db.Size = UDim2.new(0.54, -14, 0, 32)
        db.Position = UDim2.new(0.46, 0, 0.5, -16)
        db.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        db.Text = ""
        db.Parent = ca
        
        local D = {
            ["Robux Cart1"] = "Crocodile Cart",
            ["Robux Cart2"] = "F1 Cart",
            ["Robux Cart3"] = "Rocket Cart",
            ["Robux Cart4"] = "Jet Plane Cart"
        }
        
        Instance.new("UICorner", db).CornerRadius = UDim.new(0, 8)
        
        -- Dropdown text (without arrow)
        local dN = D[C[cK]] or C[cK]
        local dbText = Instance.new("TextLabel")
        dbText.Size = UDim2.new(1, -36, 1, 0)
        dbText.Position = UDim2.new(0, 10, 0, 0)
        dbText.BackgroundTransparency = 1
        dbText.Text = dN
        dbText.TextColor3 = Co.tx
        dbText.Font = Enum.Font.GothamMedium
        dbText.TextSize = fS - 1
        dbText.TextTruncate = Enum.TextTruncate.AtEnd
        dbText.TextXAlignment = Enum.TextXAlignment.Left
        dbText.Parent = db
        
        -- Dropdown icon (ganti arrow)
        local dbIcon = Instance.new("ImageLabel")
        dbIcon.Size = UDim2.new(0, 16, 0, 16)
        dbIcon.Position = UDim2.new(1, -22, 0.5, -8)
        dbIcon.BackgroundTransparency = 1
        dbIcon.Image = "rbxassetid://91662102247848"  -- Placeholder chevron down icon
        dbIcon.ImageColor3 = Co.ts
        dbIcon.Parent = db
        
        local dL = Instance.new("Frame")
        dL.Name = "DropList"
        dL.Size = UDim2.new(0, 0, 0, 0)
        dL.BackgroundColor3 = Co.cd
        dL.Visible = false
        dL.ZIndex = 999
        dL.ClipsDescendants = true
        dL.Parent = m
        
        Instance.new("UICorner", dL).CornerRadius = UDim.new(0, 10)
        
        local dLs = Instance.new("UIStroke", dL)
        dLs.Color = Co.br
        dLs.Thickness = 1.5
        dLs.Transparency = 0.3
        
        -- Add padding to dropdown container
        local dLPad = Instance.new("UIPadding", dL)
        dLPad.PaddingLeft = UDim.new(0, 4)
        dLPad.PaddingRight = UDim.new(0, 4)
        
        table.insert(oD, dL)
        
        local dS = Instance.new("ScrollingFrame")
        dS.Size = UDim2.new(1, 0, 1, 0)
        dS.BackgroundTransparency = 1
        dS.ScrollBarThickness = 2
        dS.ScrollBarImageColor3 = Co.br
        dS.CanvasSize = UDim2.new(0, 0, 0, (#op * 40) + (#op - 1) * 2 + 12)
        dS.ZIndex = 1000
        dS.ClipsDescendants = false
        dS.Parent = dL
        
        -- Add padding for cleaner look
        local dPad = Instance.new("UIPadding", dS)
        dPad.PaddingTop = UDim.new(0, 6)
        dPad.PaddingBottom = UDim.new(0, 6)
        
        local dLy = Instance.new("UIListLayout", dS)
        dLy.Padding = UDim.new(0, 2)
        
        for i, opt in ipairs(op) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, -8, 0, 40)  -- Reduced from 48 to 40
            ob.BackgroundColor3 = Co.cd
            ob.Text = ""
            ob.TextColor3 = Co.tx
            ob.Font = Enum.Font.GothamMedium
            ob.TextSize = fS
            ob.ZIndex = 1001
            ob.ClipsDescendants = false  -- FIXED: Changed to false to prevent clipping
            ob.AutoButtonColor = false  -- Disable default button color change
            ob.Parent = dS
            
            -- Add UICorner for all items with consistent rounding
            local itemCorner = Instance.new("UICorner", ob)
            itemCorner.CornerRadius = UDim.new(0, 8)  -- Slightly rounded for all items
            
            -- Check if this option is currently selected
            local function isSelected()
                if cK == "CartSelect" then
                    local N = {
                        ["Crocodile Cart"] = "Robux Cart1",
                        ["F1 Cart"] = "Robux Cart2",
                        ["Rocket Cart"] = "Robux Cart3",
                        ["Jet Plane Cart"] = "Robux Cart4"
                    }
                    return C[cK] == (N[opt] or opt)
                else
                    return C[cK] == opt
                end
            end
            
            -- Set initial background for selected item
            if isSelected() then
                ob.BackgroundColor3 = Co.al
            end
            
            -- Option text - NO CHECKMARK, CENTERED IN COLUMN
            local optText = Instance.new("TextLabel")
            optText.Size = UDim2.new(1, -24, 1, 0)  -- Full width dengan padding
            optText.Position = UDim2.new(0, 12, 0, 0)  -- Centered dengan padding kiri
            optText.BackgroundTransparency = 1
            optText.Text = tostring(opt)
            optText.TextColor3 = isSelected() and Co.ac or Co.tx
            optText.Font = isSelected() and Enum.Font.GothamBold or Enum.Font.GothamMedium
            optText.TextSize = fS
            optText.TextXAlignment = Enum.TextXAlignment.Left
            optText.ZIndex = 1002
            optText.Parent = ob
            
            -- Divider line (except for last item) - FIXED POSITIONING
            if i < #op then
                local divider = Instance.new("Frame")
                divider.Size = UDim2.new(1, -28, 0, 1)  -- Adjusted margin
                divider.Position = UDim2.new(0, 14, 1, -1)  -- Adjusted position
                divider.BackgroundColor3 = Co.br
                divider.BackgroundTransparency = 0.6  -- More subtle from 0.5 to 0.6
                divider.BorderSizePixel = 0
                divider.ZIndex = 1002
                divider.Parent = ob
            end
            
            -- Hover effect - IMPROVED
            ob.MouseEnter:Connect(function()
                if not isSelected() then
                    playSound(Sounds.Hover, 0.2)
                    T:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
                    T:Create(optText, TweenInfo.new(0.15), {TextColor3 = Co.ac}):Play()
                end
            end)
            
            ob.MouseLeave:Connect(function()
                if not isSelected() then
                    T:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
                    T:Create(optText, TweenInfo.new(0.15), {TextColor3 = Co.tx}):Play()
                end
            end)
            
            -- Click handler
            ob.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.3)
                local N = {
                    ["Crocodile Cart"] = "Robux Cart1",
                    ["F1 Cart"] = "Robux Cart2",
                    ["Rocket Cart"] = "Robux Cart3",
                    ["Jet Plane Cart"] = "Robux Cart4"
                }
                
                if cK == "CartSelect" then
                    C[cK] = N[opt] or opt
                else
                    C[cK] = opt
                end
                
                local dT = opt
                if cK == "CartSelect" then
                    dT = D[C[cK]] or C[cK]
                end
                
                -- Update dropdown text via TextLabel
                dbText.Text = dT
                
                -- Update all text colors and backgrounds in dropdown
                for _, child in ipairs(dS:GetChildren()) do
                    if child:IsA("TextButton") then
                        local childText = child:FindFirstChildWhichIsA("TextLabel")
                        if childText then
                            local childSelected = child == ob
                            
                            -- Update text with smooth tween
                            T:Create(childText, TweenInfo.new(0.15), {
                                TextColor3 = childSelected and Co.ac or Co.tx
                            }):Play()
                            childText.Font = childSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium
                            
                            -- Update background with smooth tween
                            T:Create(child, TweenInfo.new(0.2), {
                                BackgroundColor3 = childSelected and Co.al or Co.cd
                            }):Play()
                        end
                    end
                end
                
                -- Smooth close animation
                T:Create(dL, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, dL.Size.X.Offset, 0, 0)
                }):Play()
                task.wait(0.2)
                dL.Visible = false
            end)
        end
        
        db.MouseButton1Click:Connect(function()
            playSound(Sounds.Dropdown, 0.3)
            local wV = dL.Visible
            cD()
            if not wV then
                local bP = db.AbsolutePosition
                local bS = db.AbsoluteSize
                local mP = m.AbsolutePosition
                local tH = math.min(#op * 40 + 12, 180)  -- Reduced max height from 250 to 180, items 40px
                dL.Position = UDim2.new(0, bP.X - mP.X, 0, bP.Y - mP.Y + bS.Y + 4)
                dL.Size = UDim2.new(0, bS.X, 0, 0)
                dL.Visible = true
                
                -- Smooth open animation
                T:Create(dL, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, bS.X, 0, tH)
                }):Play()
            end
        end)
    end
    
    -- Build UI content for Blade Spin
    Se("Currency Boost")
    
    -- Coins Boost Toggle
    Tg("Coins Boost", "CoinsBoost", function(enabled)
        Feature.toggleCoinsBoost(enabled)
    end, "112391267091944")
    
    -- XP Boost Toggle
    Tg("XP Boost", "XPBoost", function(enabled)
        Feature.toggleXPBoost(enabled)
    end, "94281315192376")
    
    Se("Auto Features")
    
    -- Auto Upgrade Toggle
    Tg("Auto Upgrade All", "AutoUpgrade", function(enabled)
        Feature.toggleAutoUpgrade(enabled)
    end, "72330905287991")
    
    Se("Player Settings")
    
    -- Walk Speed Slider
    Sl("Walk Speed", 16, 200, "WalkSpeed", function(val)
        Feature.updateWalkSpeed(val)
    end)
    
    -- Player ESP Toggle
    Tg("Player ESP", "PlayerESP", function(enabled)
        Feature.togglePlayerESP(enabled)
    end, "104072842422977")
    
    Se("Actions")
    
    -- Anti-AFK Toggle
    Tg("Anti-AFK", "AntiAFK", function(enabled)
        Feature.toggleAntiAFK(enabled)
    end, "128279462726358")
    
    kB = Bt("Set Keybind: " .. gKN(C.Keybind), function()
        if S.WaitingKey then return end
        S.WaitingKey = true
        
        local tx = kB:FindFirstChild("TextLabel")
        if tx then tx.Text = "Press any key..." end
        kB.BackgroundColor3 = Co.warn
        
        local conn
        local timeout
        
        timeout = task.delay(8, function()
            if S.WaitingKey then
                S.WaitingKey = false
                if tx then
                    tx.Text = "Set Keybind: " .. gKN(C.Keybind)
                end
                kB.BackgroundColor3 = Co.cd
                if conn then conn:Disconnect() end
                Feature.showNotification("Keybind timeout!", false)
            end
        end)
        
        conn = U.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.UserInputType == Enum.UserInputType.Keyboard then
                task.cancel(timeout)
                C.Keybind = i.KeyCode
                if tx then
                    tx.Text = "Set Keybind: " .. gKN(C.Keybind)
                end
                kB.BackgroundColor3 = Co.cd
                S.WaitingKey = false
                conn:Disconnect()
                Feature.showNotification("Keybind set to " .. gKN(C.Keybind), true)
            end
        end)
    end, "rbxassetid://105330233440321")
    
    Bt("Destroy UI", function()
        S.U = true
        _G.SynceHubLoaded = false
        for _, conn in pairs(S.Co) do
            pcall(function() conn:Disconnect() end)
        end
        Feature.cleanup()
        if S.G then S.G:Destroy() end
        if S.Mb then S.Mb:Destroy() end
    end, "rbxassetid://137032142339509")
    
    -- Dragging system untuk move UI
    local dS, sPos
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or 
           i.UserInputType == Enum.UserInputType.Touch then
            dS = i.Position
            sPos = m.Position
        end
    end)
    
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or 
           i.UserInputType == Enum.UserInputType.Touch then
            dS = nil
        end
    end)
    
    S.Co.Drag = U.InputChanged:Connect(function(i)
        if dS and (i.UserInputType == Enum.UserInputType.MouseMovement or 
                   i.UserInputType == Enum.UserInputType.Touch) then
            local dt = i.Position - dS
            m.Position = UDim2.new(
                sPos.X.Scale, sPos.X.Offset + dt.X,
                sPos.Y.Scale, sPos.Y.Offset + dt.Y
            )
        end
    end)
    
    m.Position = UDim2.new(1, 20, 0.5, -h/2)
    m.BackgroundTransparency = 0
    
    -- Parent GUI
    pcall(function()
        g.Parent = game:GetService("CoreGui")
    end)
    
    if not g.Parent then
        g.Parent = L:WaitForChild("PlayerGui")
    end
    
    S.G = g
    
    -- Mobile button
    if isMobile then
        local BUTTON_TRANSPARENCY = 0.10
        
        local mB = Instance.new("Frame")
        mB.Size = UDim2.new(0, 100, 0, 32)
        mB.Position = UDim2.new(0, 10, 0, 10)
        mB.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        mB.BackgroundTransparency = BUTTON_TRANSPARENCY
        mB.BorderSizePixel = 0
        mB.Parent = g
        
        Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 16)
        
        local mStroke = Instance.new("UIStroke", mB)
        mStroke.Color = Color3.fromRGB(60, 60, 70)
        mStroke.Thickness = 1.5
        mStroke.Transparency = 0.3
        
        local mI = Instance.new("ImageLabel")
        mI.Size = UDim2.new(0, 20, 0, 20)
        mI.Position = UDim2.new(0, 8, 0.5, -10)
        mI.BackgroundTransparency = 1
        mI.Image = "rbxassetid://114167695335193"
        mI.ImageColor3 = Color3.fromRGB(255, 255, 255)
        mI.Parent = mB
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -36, 1, 0)
        btnText.Position = UDim2.new(0, 32, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = "Hide"
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.Font = Enum.Font.GothamBold
        btnText.TextSize = 15
        btnText.TextXAlignment = Enum.TextXAlignment.Center
        btnText.TextYAlignment = Enum.TextYAlignment.Center
        btnText.Parent = mB
        
        local mT = Instance.new("TextButton")
        mT.Size = UDim2.new(1, 0, 1, 0)
        mT.BackgroundTransparency = 1
        mT.Text = ""
        mT.Parent = mB
        
        -- Draggable system with click detection
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local wasDragged = false
        
        mT.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mB.Position
                wasDragged = false
            end
        end)
        
        mT.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                
                if not wasDragged then
                    m.Visible = not m.Visible
                    
                    if m.Visible then
                        playSound(Sounds.Click, 0.5)
                        btnText.Text = "Hide"
                        mI.Image = "rbxassetid://114167695335193"
                    else
                        playSound(Sounds.Click, 0.4)
                        btnText.Text = "Show"
                        mI.Image = "rbxassetid://99334701468696"
                    end
                    
                    T:Create(mB, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(0, 95, 0, 30)
                    }):Play()
                    task.wait(0.1)
                    T:Create(mB, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
                        Size = UDim2.new(0, 100, 0, 32)
                    }):Play()
                end
            end
        end)
        
        U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                    wasDragged = true
                end
                
                mB.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        mT.MouseEnter:Connect(function()
            if not dragging then
                T:Create(mB, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
                    BackgroundTransparency = BUTTON_TRANSPARENCY - 0.1
                }):Play()
                T:Create(mStroke, TweenInfo.new(0.2), {
                    Color = Color3.fromRGB(100, 100, 120)
                }):Play()
            end
        end)
        
        mT.MouseLeave:Connect(function()
            T:Create(mB, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BackgroundTransparency = BUTTON_TRANSPARENCY
            }):Play()
            T:Create(mStroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(60, 60, 70)
            }):Play()
        end)
        
        S.Mb = mB
        
        mB.Position = UDim2.new(0, -110, 0, 10)
        mB.BackgroundTransparency = 1
        btnText.TextTransparency = 1
        mI.ImageTransparency = 1
        mStroke.Transparency = 1
        
        task.wait(0.3)
        T:Create(mB, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = BUTTON_TRANSPARENCY
        }):Play()
        T:Create(btnText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        T:Create(mI, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
        T:Create(mStroke, TweenInfo.new(0.4), {Transparency = 0.3}):Play()
    end
    
    task.wait(0.1)
    
    T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    }):Play()
    
    task.wait(0.3)
    playSound(Sounds.Success, 0.4)
    
    -- Loading notification - NO EXTRA SOUND
    task.wait(0.2)
    Feature.showNotification("SynceHub initialized successfully!", true)
end

return TabContent