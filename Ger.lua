-- Wuk.lua
-- SynceHub - UI Creation for Potato Idle

local TabContent = {}

local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

local C, S, Feature, gKN
local kB

-- Sound effects
local Sounds = {
    Click    = "rbxassetid://6895079853",
    Toggle   = "rbxassetid://6895079853",
    Hover    = "rbxassetid://10066931761",
    Dropdown = "rbxassetid://6895079853",
    Success  = "rbxassetid://6026984224",
    Error    = "rbxassetid://4590662766"
}

local function playSound(soundId, volume)
    volume = volume or 0.5
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume  = volume
    sound.Parent  = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName, gameName, themesModule, sidebarModule)
    C       = config
    S       = state
    Feature = featureModule
    gKN     = getKeyName

    if S.G then S.G:Destroy() end

    local sS = workspace.CurrentCamera.ViewportSize
    local w  = isMobile and math.min(310, sS.X - 24) or 320
    local h  = isMobile and math.min(480, sS.Y - 100) or 460
    local bH = isMobile and 46 or 44
    local p  = 12
    local fS = isMobile and 14 or 13

    -- Color scheme (default: Neon Purple)
    local Co = {
        bg   = Color3.fromRGB(18, 10, 40),
        cd   = Color3.fromRGB(28, 15, 58),
        ch   = Color3.fromRGB(38, 20, 75),
        ac   = Color3.fromRGB(150, 80, 255),
        al   = Color3.fromRGB(28, 15, 58),
        tx   = Color3.fromRGB(255, 255, 255),
        ts   = Color3.fromRGB(180, 150, 220),
        br   = Color3.fromRGB(80, 40, 130),
        sc   = Color3.fromRGB(153, 127, 187),
        ach  = Color3.fromRGB(180, 110, 255),
        warn = Color3.fromRGB(255, 200, 50)
    }
    S.CurrentColors = Co

    -- ============================================
    -- SCREEN GUI
    -- ============================================
    local g = Instance.new("ScreenGui")
    g.Name           = "SynceHub"
    g.ResetOnSpawn   = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ============================================
    -- MAIN FRAME
    -- ============================================
    local m = Instance.new("Frame")
    m.Name             = "Main"
    m.Size             = UDim2.new(0, w, 0, h)
    m.Position         = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    m.BorderSizePixel  = 0
    m.ClipsDescendants = true
    m.ZIndex           = 2
    m:SetAttribute("ThemeTag", "bg")
    m.Parent           = g
    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16)

    -- Gradient Neon Purple
    local neonPurpleGrad = Instance.new("UIGradient")
    neonPurpleGrad.Name     = "NeonPurpleGrad"
    neonPurpleGrad.Color    = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(15, 5, 35)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 10, 80)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 25, 140)),
    }
    neonPurpleGrad.Rotation = 135
    neonPurpleGrad.Parent   = m

    -- Drop shadow
    local sh = Instance.new("ImageLabel")
    sh.Size                  = UDim2.new(1, 30, 1, 30)
    sh.Position              = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image                 = "rbxassetid://5554236805"
    sh.ImageColor3           = Color3.new(0, 0, 0)
    sh.ImageTransparency     = 0.3
    sh.ScaleType             = Enum.ScaleType.Slice
    sh.SliceCenter           = Rect.new(23, 23, 277, 277)
    sh.ZIndex                = 0
    sh.Parent                = m

    -- ============================================
    -- TAB SCROLL FRAMES (1 per tab, 4 total)
    -- ============================================
    local tabScrollFrames = {}

    local function makeTabScroll()
        local sc = Instance.new("ScrollingFrame")
        sc.Size                  = UDim2.new(1, -4, 1, -60)
        sc.Position              = UDim2.new(0, 2, 0, 56)
        sc.BackgroundTransparency = 1
        sc.ScrollBarThickness    = 2
        sc.ScrollBarImageColor3  = Co.br
        sc.CanvasSize            = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        sc.ClipsDescendants      = true
        sc.ScrollingDirection    = Enum.ScrollingDirection.Y
        sc.Visible               = false
        sc.Parent                = m

        local sP = Instance.new("UIPadding")
        sP.PaddingLeft   = UDim.new(0, p - 2)
        sP.PaddingRight  = UDim.new(0, p + 2)
        sP.PaddingTop    = UDim.new(0, 2)
        sP.PaddingBottom = UDim.new(0, p)
        sP.Parent        = sc

        local ly = Instance.new("UIListLayout")
        ly.Padding   = UDim.new(0, 6)
        ly.SortOrder = Enum.SortOrder.LayoutOrder
        ly.Parent    = sc

        return sc
    end

    for i = 1, 4 do
        tabScrollFrames[i] = makeTabScroll()
    end
    tabScrollFrames[1].Visible = true

    -- ============================================
    -- SIDEBAR MODULE
    -- ============================================
    local sb = sidebarModule.create(g, m, Co, function(index)
        for i, sc in ipairs(tabScrollFrames) do
            sc.Visible = (i == index)
        end
    end)

    local sidebar       = sb.sidebar
    local tabButtons    = sb.tabButtons
    local syncPositions = sb.syncPositions

    -- ============================================
    -- HEADER
    -- ============================================
    local hd = Instance.new("Frame")
    hd.Size                  = UDim2.new(1, 0, 0, 52)
    hd.BackgroundTransparency = 1
    hd.ZIndex                = 10
    hd.Parent                = m

    local tL = Instance.new("TextLabel")
    tL.Size                  = UDim2.new(1, -60, 0, 20)
    tL.Position              = UDim2.new(0, p, 0, 12)
    tL.BackgroundTransparency = 1
    tL.Text                  = "SynceHub"
    tL.TextColor3            = Co.tx
    tL.Font                  = Enum.Font.GothamBold
    tL.TextSize              = 18
    tL.TextXAlignment        = Enum.TextXAlignment.Left
    tL.ZIndex                = 11
    tL:SetAttribute("ThemeTag", "tx")
    tL.Parent                = hd

    local st = Instance.new("TextLabel")
    st.Size                  = UDim2.new(1, -60, 0, 14)
    st.Position              = UDim2.new(0, p, 0, 33)
    st.BackgroundTransparency = 1
    st.Text                  = (gameName or "Potato Idle") .. " | " .. version
    st.TextColor3            = Co.ts
    st.Font                  = Enum.Font.Gotham
    st.TextSize              = 11
    st.TextXAlignment        = Enum.TextXAlignment.Left
    st.ZIndex                = 11
    st:SetAttribute("ThemeTag", "ts")
    st.Parent                = hd

    -- Close button
    local clBtn = Instance.new("TextButton")
    clBtn.Size             = UDim2.new(0, 32, 0, 32)
    clBtn.Position         = UDim2.new(1, -p-32, 0, 10)
    clBtn.BackgroundColor3 = Co.ch
    clBtn.Text             = "×"
    clBtn.TextColor3       = Co.ts
    clBtn.Font             = Enum.Font.GothamBold
    clBtn.TextSize         = 20
    clBtn.ZIndex           = 11
    clBtn:SetAttribute("ThemeTag", "ch")
    clBtn:SetAttribute("TextTag", "ts")
    clBtn.Parent           = hd
    Instance.new("UICorner", clBtn).CornerRadius = UDim.new(0, 10)

    local dv  = nil

    -- ============================================
    -- CONFIRM DIALOG
    -- ============================================
    local function showConfirmDialog()
        if m:FindFirstChild("ConfirmBlur") then return end

        local blur = Instance.new("Frame")
        blur.Name                   = "ConfirmBlur"
        blur.Size                   = UDim2.new(1, 0, 1, 0)
        blur.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        blur.BackgroundTransparency = 1
        blur.BorderSizePixel        = 0
        blur.ZIndex                 = 2000
        blur.Parent                 = m
        Instance.new("UICorner", blur).CornerRadius = UDim.new(0, 16)

        local blocker = Instance.new("TextButton")
        blocker.Size                  = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text                  = ""
        blocker.ZIndex                = 2000
        blocker.Active                = true
        blocker.AutoButtonColor       = false
        blocker.Parent                = blur

        local dialog = Instance.new("Frame")
        dialog.Size                   = UDim2.new(0, 280, 0, 140)
        dialog.Position               = UDim2.new(0.5, -140, 0.5, -70)
        dialog.BackgroundColor3       = Co.cd
        dialog.BackgroundTransparency = 1
        dialog.BorderSizePixel        = 0
        dialog.ZIndex                 = 2001
        dialog.Parent                 = blur
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)

        local dialogStroke = Instance.new("UIStroke", dialog)
        dialogStroke.Color        = Co.br
        dialogStroke.Thickness    = 1
        dialogStroke.Transparency = 1

        local shadow = Instance.new("ImageLabel")
        shadow.Size                  = UDim2.new(1, 20, 1, 20)
        shadow.Position              = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image                 = "rbxassetid://5554236805"
        shadow.ImageColor3           = Color3.new(0, 0, 0)
        shadow.ImageTransparency     = 1
        shadow.ScaleType             = Enum.ScaleType.Slice
        shadow.SliceCenter           = Rect.new(23, 23, 277, 277)
        shadow.ZIndex                = 2000
        shadow.Parent                = dialog

        local icon = Instance.new("ImageLabel")
        icon.Size                  = UDim2.new(0, 18, 0, 18)
        icon.Position              = UDim2.new(1, -26, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image                 = "rbxassetid://101745201658882"
        icon.ImageColor3           = Co.ts
        icon.ImageTransparency     = 1
        icon.ZIndex                = 2002
        icon.Parent                = dialog

        local title = Instance.new("TextLabel")
        title.Size                  = UDim2.new(1, -45, 0, 24)
        title.Position              = UDim2.new(0, 16, 0, 12)
        title.BackgroundTransparency = 1
        title.Text                  = "Close Window"
        title.TextColor3            = Co.tx
        title.Font                  = Enum.Font.GothamBold
        title.TextSize              = 16
        title.TextXAlignment        = Enum.TextXAlignment.Left
        title.TextTransparency      = 1
        title.ZIndex                = 2002
        title.Parent                = dialog

        local desc = Instance.new("TextLabel")
        desc.Size                  = UDim2.new(1, -32, 0, 36)
        desc.Position              = UDim2.new(0, 16, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Text                  = "Do you want to close this window?\nYou will not be able to open it again."
        desc.TextColor3            = Co.tx
        desc.Font                  = Enum.Font.Gotham
        desc.TextSize              = 14
        desc.TextWrapped           = true
        desc.TextXAlignment        = Enum.TextXAlignment.Left
        desc.TextYAlignment        = Enum.TextYAlignment.Top
        desc.TextTransparency      = 1
        desc.ZIndex                = 2002
        desc.Parent                = dialog

        local btnContainer = Instance.new("Frame")
        btnContainer.Size                   = UDim2.new(1, -32, 0, 36)
        btnContainer.Position               = UDim2.new(0, 16, 1, -44)
        btnContainer.BackgroundTransparency = 1
        btnContainer.ZIndex                 = 2002
        btnContainer.Parent                 = dialog

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size                  = UDim2.new(0.48, 0, 1, 0)
        cancelBtn.BackgroundColor3      = Co.ch
        cancelBtn.BackgroundTransparency = 1
        cancelBtn.Text                  = "Cancel"
        cancelBtn.TextColor3            = Co.tx
        cancelBtn.TextTransparency      = 1
        cancelBtn.Font                  = Enum.Font.GothamBold
        cancelBtn.TextSize              = 13
        cancelBtn.ZIndex                = 2003
        cancelBtn.Parent                = btnContainer
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size                  = UDim2.new(0.48, 0, 1, 0)
        confirmBtn.Position              = UDim2.new(0.52, 0, 0, 0)
        confirmBtn.BackgroundColor3      = Co.ac
        confirmBtn.BackgroundTransparency = 1
        confirmBtn.Text                  = "Close Window"
        confirmBtn.TextColor3            = Color3.fromRGB(255, 255, 255)
        confirmBtn.TextTransparency      = 1
        confirmBtn.Font                  = Enum.Font.GothamBold
        confirmBtn.TextSize              = 13
        confirmBtn.ZIndex                = 2003
        confirmBtn.Parent                = btnContainer
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

        -- Overlay gelap sidebar
        local sidebarOverlay = Instance.new("Frame")
        sidebarOverlay.Name                   = "SidebarOverlay"
        sidebarOverlay.Size                   = UDim2.new(1, 0, 1, 0)
        sidebarOverlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        sidebarOverlay.BackgroundTransparency = 1
        sidebarOverlay.BorderSizePixel        = 0
        sidebarOverlay.ZIndex                 = 2000
        sidebarOverlay.Parent                 = sb.sidebar
        Instance.new("UICorner", sidebarOverlay).CornerRadius = UDim.new(0, 12)
        local sbB = Instance.new("TextButton", sidebarOverlay)
        sbB.Size = UDim2.new(1,0,1,0); sbB.BackgroundTransparency=1; sbB.Text=""; sbB.ZIndex=2001; sbB.Active=true; sbB.AutoButtonColor=false

        -- Fade in
        T:Create(blur,          TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
        T:Create(dialog,        TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
        T:Create(dialogStroke,  TweenInfo.new(0.25), {Transparency = 0.3}):Play()
        T:Create(shadow,        TweenInfo.new(0.25), {ImageTransparency = 0.6}):Play()
        T:Create(icon,          TweenInfo.new(0.3),  {ImageTransparency = 0}):Play()
        T:Create(title,         TweenInfo.new(0.3),  {TextTransparency = 0}):Play()
        T:Create(desc,          TweenInfo.new(0.3),  {TextTransparency = 0}):Play()
        T:Create(cancelBtn,     TweenInfo.new(0.3),  {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        T:Create(confirmBtn,    TweenInfo.new(0.3),  {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        T:Create(sidebarOverlay,TweenInfo.new(0.25), {BackgroundTransparency = 0.5}):Play()
        playSound(Sounds.Click, 0.3)

        sb.lockInteraction()

        cancelBtn.MouseEnter:Connect(function()  T:Create(cancelBtn,  TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()  end)
        cancelBtn.MouseLeave:Connect(function()  T:Create(cancelBtn,  TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()  end)
        confirmBtn.MouseEnter:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ach}):Play() end)
        confirmBtn.MouseLeave:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ac}):Play()  end)

        local function closeDialog()
            T:Create(blur,          TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            T:Create(dialog,        TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            T:Create(dialogStroke,  TweenInfo.new(0.2), {Transparency = 1}):Play()
            T:Create(shadow,        TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
            T:Create(icon,          TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
            T:Create(title,         TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            T:Create(desc,          TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            T:Create(cancelBtn,     TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            T:Create(confirmBtn,    TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            T:Create(sidebarOverlay,TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            blur:Destroy()
            sidebarOverlay:Destroy()
            sb.unlockInteraction()
        end

        cancelBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.3)
            closeDialog()
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            closeDialog()
            if Feature and Feature.resetAllFeatures then
                pcall(function() Feature.resetAllFeatures() end)
            end
            S.U = true
            _G.SynceHubLoaded = false
            for _, conn in pairs(S.Co) do
                pcall(function() conn:Disconnect() end)
            end
            Feature.cleanup()
            if S.G  then S.G:Destroy()  end
            if S.Mb then S.Mb:Destroy() end
        end)
    end

    -- ============================================
    -- ============================================
    -- CLOSE WIRING
    -- ============================================
    clBtn.MouseButton1Click:Connect(showConfirmDialog)
    clBtn.MouseEnter:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
    clBtn.MouseLeave:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)

    -- ============================================
    -- THEME SYSTEM
    -- ============================================
    local themeApplying = false

    local function applyTheme(theme)
        if not theme or not theme.Colors then return end
        themeApplying = true
        local colors  = theme.Colors

        Co.bg  = colors.bg;  Co.cd  = colors.cd;  Co.ch  = colors.ch
        Co.br  = colors.br;  Co.tx  = colors.tx;  Co.ts  = colors.ts
        Co.ac  = colors.ac;  Co.ach = colors.ach
        Co.sc  = Color3.new(colors.ts.R*0.85, colors.ts.G*0.85, colors.ts.B*0.85)
        Co.warn = colors.warn or Co.warn
        Co.al  = Color3.new(
            colors.ac.R*0.25 + colors.cd.R*0.75,
            colors.ac.G*0.25 + colors.cd.G*0.75,
            colors.ac.B*0.25 + colors.cd.B*0.75
        )
        config.CurrentTheme = theme.ID
        S.CurrentColors     = colors

        local function applyToElement(element)
            if not element or not element.Parent then return end
            pcall(function()
                if element:IsA("TextButton") and element.Name == "ToggleBtn" then
                    local ck = element:GetAttribute("ConfigKey")
                    element.BackgroundColor3 = (ck and C[ck]) and colors.ac or colors.ch
                end
                local tag = element:GetAttribute("ThemeTag")
                if tag then
                    if element:IsA("Frame") or element:IsA("ScrollingFrame") then
                        if     tag=="bg"        then element.BackgroundColor3=colors.bg
                        elseif tag=="cd"        then element.BackgroundColor3=colors.cd
                        elseif tag=="ch"        then element.BackgroundColor3=colors.ch
                        elseif tag=="ac"        then element.BackgroundColor3=colors.ac
                        elseif tag=="br_divider" then element.BackgroundColor3=colors.br
                        end
                        local s2 = element:FindFirstChildOfClass("UIStroke")
                        if s2 then s2.Color = colors.br end
                        if element:IsA("ScrollingFrame") then element.ScrollBarImageColor3 = colors.br end
                    elseif element:IsA("TextLabel") then
                        if     tag=="tx" then element.TextColor3=colors.tx
                        elseif tag=="ts" then element.TextColor3=colors.ts
                        elseif tag=="sc" then element.TextColor3=Co.sc
                        elseif tag=="ac" then element.TextColor3=colors.ac
                        end
                    elseif element:IsA("TextButton") then
                        if     tag=="cd" then element.BackgroundColor3=colors.cd
                        elseif tag=="ch" then element.BackgroundColor3=colors.ch
                        elseif tag=="ac" then element.BackgroundColor3=colors.ac
                        elseif tag=="al" then element.BackgroundColor3=Co.al
                        end
                        local tc = element:GetAttribute("TextTag")
                        if     tc=="tx" then element.TextColor3=colors.tx
                        elseif tc=="ts" then element.TextColor3=colors.ts
                        end
                    elseif element:IsA("TextBox") then
                        if tag=="ch" then element.BackgroundColor3=colors.ch end
                        element.TextColor3=colors.tx; element.PlaceholderColor3=colors.ts
                    elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
                        if     tag=="ts" then element.ImageColor3=colors.ts
                        elseif tag=="tx" then element.ImageColor3=colors.tx
                        elseif tag=="ac" then element.ImageColor3=colors.ac
                        end
                    elseif element:IsA("UIStroke") then
                        element.Color = colors.br
                    end
                end
            end)
            for _, child in ipairs(element:GetChildren()) do applyToElement(child) end
        end

        applyToElement(m)
        applyToElement(sb.sidebar)

        for i, tb in ipairs(tabButtons) do
            local isActive = (i == sb.getActiveTab())
            tb.btn.BackgroundColor3 = isActive and colors.ac or colors.ch
            tb.icon.ImageColor3     = isActive and colors.tx or colors.ts
        end

        local existingGrad = m:FindFirstChild("NeonPurpleGrad")
        if theme.ID == "neon_purple" then
            local grad = existingGrad or Instance.new("UIGradient")
            grad.Name="NeonPurpleGrad"; grad.Rotation=135; grad.Parent=m
            grad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(15, 5, 35)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 10, 80)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 25, 140)),
            }
            m.BackgroundColor3 = Color3.fromRGB(255,255,255)
        else
            if existingGrad then existingGrad:Destroy() end
            m.BackgroundColor3 = colors.bg
        end

        if dv then dv.BackgroundColor3 = colors.br end
        if S.Mb then
            S.Mb.BackgroundColor3 = colors.cd
            local mbS = S.Mb:FindFirstChildOfClass("UIStroke")
            if mbS then mbS.Color = colors.br end
            local mbT = S.Mb:FindFirstChildOfClass("TextLabel")
            if mbT then mbT.TextColor3 = colors.tx end
            local mbI = S.Mb:FindFirstChildOfClass("ImageLabel")
            if mbI then mbI.ImageColor3 = colors.tx end
        end

        themeApplying = false
        Feature.showNotification("Theme: " .. theme.Name, true)
    end

    local currentThemeIndex = 1
    if themesModule and config.CurrentTheme then
        for i, theme in ipairs(themesModule.List) do
            if theme.ID == config.CurrentTheme then currentThemeIndex = i; break end
        end
    end

    -- ============================================
    -- DIVIDER
    -- ============================================
    dv = Instance.new("Frame")
    dv.Size             = UDim2.new(1, -p*2, 0, 1)
    dv.Position         = UDim2.new(0, p, 0, 51)
    dv.BackgroundColor3 = Co.br
    dv.BorderSizePixel  = 0
    dv.Parent           = m

    -- ============================================
    -- UI ELEMENT HELPERS
    -- ============================================
    local currentSc  = tabScrollFrames[1]
    local currentOrd = 0
    local oD         = {}

    local function nO() currentOrd = currentOrd + 1; return currentOrd end

    local function useTab(idx)
        currentSc  = tabScrollFrames[idx]
        currentOrd = 0
    end

    local function cD()
        for _, d in pairs(oD) do
            if d and d.Visible then d.Visible = false end
        end
    end

    for _, sc in ipairs(tabScrollFrames) do
        sc:GetPropertyChangedSignal("CanvasPosition"):Connect(cD)
    end

    local function Se(n)
        local s = Instance.new("TextLabel")
        s.Size=UDim2.new(1,0,0,24); s.BackgroundTransparency=1
        s.Text=string.upper(n); s.TextColor3=Co.sc
        s.Font=Enum.Font.GothamBold; s.TextSize=10
        s.TextXAlignment=Enum.TextXAlignment.Left
        s.LayoutOrder=nO(); s:SetAttribute("ThemeTag","sc")
        s.Parent=currentSc
    end

    local function Ds(text, isWarning)
        local card = Instance.new("Frame")
        card.Size             = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize    = Enum.AutomaticSize.Y
        card.BackgroundColor3 = isWarning and Color3.fromRGB(60, 35, 10) or Co.cd
        card.BorderSizePixel  = 0
        card.LayoutOrder      = nO()
        card:SetAttribute("ThemeTag", isWarning and "cd" or "cd")
        card.Parent           = currentSc
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke", card)
        stroke.Color     = isWarning and Color3.fromRGB(255, 200, 50) or Co.br
        stroke.Thickness = 1.5
        stroke.Transparency = isWarning and 0.3 or 0

        local pad = Instance.new("UIPadding", card)
        pad.PaddingLeft   = UDim.new(0, 14)
        pad.PaddingRight  = UDim.new(0, 14)
        pad.PaddingTop    = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)

        local d = Instance.new("TextLabel")
        d.Size             = UDim2.new(1, 0, 0, 0)
        d.AutomaticSize    = Enum.AutomaticSize.Y
        d.BackgroundTransparency = 1
        d.Text             = text
        d.TextColor3       = isWarning and Color3.fromRGB(255, 200, 100) or Co.tx
        d.Font             = Enum.Font.GothamMedium
        d.TextSize         = 13
        d.TextXAlignment   = Enum.TextXAlignment.Left
        d.TextYAlignment   = Enum.TextYAlignment.Top
        d.TextWrapped      = true
        d:SetAttribute("ThemeTag", isWarning and "warn" or "tx")
        d.Parent           = card

        return card
    end

    local function Bt(n, cl, ico)
        local b = Instance.new("TextButton")
        b.Size=UDim2.new(1,0,0,bH); b.BackgroundColor3=Co.cd
        b.Text=""; b.LayoutOrder=nO(); b:SetAttribute("ThemeTag","cd"); b.Parent=currentSc
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,12)
        Instance.new("UIStroke",b).Color=Co.br
        if ico then
            local ic=Instance.new("ImageLabel")
            ic.Size=UDim2.new(0,20,0,20); ic.Position=UDim2.new(1,-34,0.5,-10)
            ic.BackgroundTransparency=1; ic.Image=ico; ic.ImageColor3=Co.ts
            ic:SetAttribute("ThemeTag","ts"); ic.Parent=b
        end
        local tx=Instance.new("TextLabel")
        tx.Size=UDim2.new(1,-50,1,0); tx.Position=UDim2.new(0,14,0,0)
        tx.BackgroundTransparency=1; tx.Text=n; tx.TextColor3=Co.tx
        tx.Font=Enum.Font.GothamBold; tx.TextSize=fS
        tx.TextXAlignment=Enum.TextXAlignment.Left
        tx:SetAttribute("ThemeTag","tx"); tx.Parent=b
        b.MouseEnter:Connect(function() b.BackgroundColor3=Co.ch end)
        b.MouseLeave:Connect(function() b.BackgroundColor3=Co.cd end)
        b.MouseButton1Click:Connect(function() playSound(Sounds.Click,0.4); cl() end)
        return b, tx
    end

    local function Sl(n, min, max, cK, callback)
        local ca=Instance.new("Frame")
        ca.Size=UDim2.new(1,0,0,bH+10); ca.BackgroundColor3=Co.cd
        ca.LayoutOrder=nO(); ca:SetAttribute("ThemeTag","cd"); ca.Parent=currentSc
        Instance.new("UICorner",ca).CornerRadius=UDim.new(0,12)
        Instance.new("UIStroke",ca).Color=Co.br
        local lb=Instance.new("TextLabel")
        lb.Size=UDim2.new(0.6,0,0,20); lb.Position=UDim2.new(0,14,0,8)
        lb.BackgroundTransparency=1; lb.Text=n; lb.TextColor3=Co.tx
        lb.Font=Enum.Font.GothamBold; lb.TextSize=fS
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb:SetAttribute("ThemeTag","tx"); lb.Parent=ca
        local vL=Instance.new("TextBox")
        vL.Size=UDim2.new(0,60,0,24); vL.Position=UDim2.new(1,-74,0,6)
        vL.BackgroundColor3=Co.ch; vL.Text=tostring(C[cK]); vL.TextColor3=Co.tx
        vL.Font=Enum.Font.GothamBold; vL.TextSize=fS
        vL.TextXAlignment=Enum.TextXAlignment.Center; vL.ClearTextOnFocus=false
        vL:SetAttribute("ThemeTag","ch"); vL.Parent=ca
        Instance.new("UICorner",vL).CornerRadius=UDim.new(0,8)
        local sB=Instance.new("Frame")
        sB.Size=UDim2.new(1,-28,0,6); sB.Position=UDim2.new(0,14,1,-16)
        sB.BackgroundColor3=Co.ch; sB.BorderSizePixel=0
        sB:SetAttribute("ThemeTag","ch"); sB.Parent=ca
        Instance.new("UICorner",sB).CornerRadius=UDim.new(1,0)
        local sF=Instance.new("Frame")
        sF.Size=UDim2.new((C[cK]-min)/(max-min),0,1,0); sF.BackgroundColor3=Co.ac
        sF.BorderSizePixel=0; sF:SetAttribute("ThemeTag","ac"); sF.Parent=sB
        Instance.new("UICorner",sF).CornerRadius=UDim.new(1,0)
        local sN=Instance.new("Frame")
        sN.Size=UDim2.new(0,16,0,16); sN.Position=UDim2.new((C[cK]-min)/(max-min),-8,0.5,-8)
        sN.BackgroundColor3=Color3.fromRGB(255,255,255); sN.BorderSizePixel=0; sN.Parent=sB
        Instance.new("UICorner",sN).CornerRadius=UDim.new(1,0)
        local function upd(val)
            val=math.clamp(val,min,max); C[cK]=val; vL.Text=tostring(val)
            local pct=(val-min)/(max-min)
            sF.Size=UDim2.new(pct,0,1,0); sN.Position=UDim2.new(pct,-8,0.5,-8)
        end
        vL.FocusLost:Connect(function()
            local val=tonumber(vL.Text)
            if val then val=math.clamp(math.floor(val),min,max); upd(val); if callback then callback(val) end
            else vL.Text=tostring(C[cK]) end
        end)
        local dG=false
        local function hSI(ix)
            local pct=math.clamp((ix-sB.AbsolutePosition.X)/sB.AbsoluteSize.X,0,1)
            local val=math.floor(min+(max-min)*pct); upd(val); if callback then callback(val) end
        end
        sB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dG=true; playSound(Sounds.Click,0.2); hSI(i.Position.X) end end)
        sB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dG=false end end)
        sN.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dG=true; playSound(Sounds.Click,0.2) end end)
        sN.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dG=false end end)
        U.InputChanged:Connect(function(i) if dG and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then hSI(i.Position.X) end end)
        return ca
    end

    local function Tg(n, cK, callback, ico)
        local ca=Instance.new("Frame")
        ca.Size=UDim2.new(1,0,0,bH); ca.BackgroundColor3=Co.cd
        ca.LayoutOrder=nO(); ca:SetAttribute("ThemeTag","cd"); ca.Parent=currentSc
        Instance.new("UICorner",ca).CornerRadius=UDim.new(0,12)
        Instance.new("UIStroke",ca).Color=Co.br
        if ico then
            local ic=Instance.new("ImageLabel")
            ic.Size=UDim2.new(0,22,0,22); ic.Position=UDim2.new(0,14,0.5,-11)
            ic.BackgroundTransparency=1; ic.Image="rbxassetid://"..ico; ic.ImageColor3=Co.ts
            ic:SetAttribute("ThemeTag","ts"); ic.Parent=ca
        end
        local lb=Instance.new("TextLabel")
        lb.Size=UDim2.new(1,-100,1,0); lb.Position=UDim2.new(0,ico and 44 or 14,0,0)
        lb.BackgroundTransparency=1; lb.Text=n; lb.TextColor3=Co.tx
        lb.Font=Enum.Font.GothamBold; lb.TextSize=fS
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextYAlignment=Enum.TextYAlignment.Center
        lb:SetAttribute("ThemeTag","tx"); lb.Parent=ca
        local tg=Instance.new("TextButton")
        tg.Size=UDim2.new(0,44,0,24); tg.Position=UDim2.new(1,-56,0.5,-12)
        tg.BackgroundColor3=C[cK] and Co.ac or Co.ch; tg.Text=""
        tg.Name="ToggleBtn"; tg:SetAttribute("ConfigKey",cK); tg.Parent=ca
        Instance.new("UICorner",tg).CornerRadius=UDim.new(1,0)
        local tb=Instance.new("Frame")
        tb.Size=UDim2.new(0,20,0,20)
        tb.Position=C[cK] and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
        tb.BackgroundColor3=Color3.fromRGB(255,255,255); tb.Parent=tg
        Instance.new("UICorner",tb).CornerRadius=UDim.new(1,0)
        tg.MouseButton1Click:Connect(function()
            playSound(Sounds.Toggle,0.3); C[cK]=not C[cK]
            T:Create(tg,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{BackgroundColor3=C[cK] and Co.ac or Co.ch}):Play()
            T:Create(tb,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{Position=C[cK] and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)}):Play()
            if callback then callback(C[cK]) end
        end)
        return ca
    end

    local function Ib(n, cK)
        local ca=Instance.new("Frame")
        ca.Size=UDim2.new(1,0,0,bH); ca.BackgroundColor3=Co.cd
        ca.LayoutOrder=nO(); ca:SetAttribute("ThemeTag","cd"); ca.Parent=currentSc
        Instance.new("UICorner",ca).CornerRadius=UDim.new(0,12)
        Instance.new("UIStroke",ca).Color=Co.br
        local lb=Instance.new("TextLabel")
        lb.Size=UDim2.new(0.48,0,1,0); lb.Position=UDim2.new(0,14,0,0)
        lb.BackgroundTransparency=1; lb.Text=n; lb.TextColor3=Co.tx
        lb.Font=Enum.Font.GothamBold; lb.TextSize=fS
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextYAlignment=Enum.TextYAlignment.Center
        lb:SetAttribute("ThemeTag","tx"); lb.Parent=ca
        local ib=Instance.new("TextBox")
        ib.Size=UDim2.new(0.48,-14,0,32); ib.Position=UDim2.new(0.52,0,0.5,-16)
        ib.BackgroundColor3=Co.ch; ib.Text=""; ib.TextColor3=Co.tx
        ib.Font=Enum.Font.GothamMedium; ib.TextSize=fS
        ib.PlaceholderText="Enter amount..."; ib.PlaceholderColor3=Co.ts
        ib.ClearTextOnFocus=false; ib.TextXAlignment=Enum.TextXAlignment.Center; ib.Parent=ca
        Instance.new("UICorner",ib).CornerRadius=UDim.new(0,8)
        if C[cK] and C[cK]>0 then ib.Text=tostring(C[cK]) end
        ib.FocusLost:Connect(function()
            local v=tonumber(ib.Text)
            if v and v>=1 then C[cK]=v
            elseif v and v<=0 then Feature.showNotification("Amount must be greater than 0!",false); playSound(Sounds.Error,0.3); C[cK]=0; ib.Text=""
            else C[cK]=0; ib.Text="" end
        end)
    end

    local function Dd(n, op, cK)
        local ca=Instance.new("Frame")
        ca.Size=UDim2.new(1,0,0,bH); ca.BackgroundColor3=Co.cd
        ca.ClipsDescendants=false; ca.LayoutOrder=nO()
        ca:SetAttribute("ThemeTag","cd"); ca.Parent=currentSc
        Instance.new("UICorner",ca).CornerRadius=UDim.new(0,12)
        Instance.new("UIStroke",ca).Color=Co.br
        local lb=Instance.new("TextLabel")
        lb.Size=UDim2.new(0.42,0,1,0); lb.Position=UDim2.new(0,14,0,0)
        lb.BackgroundTransparency=1; lb.Text=n; lb.TextColor3=Co.tx
        lb.Font=Enum.Font.GothamBold; lb.TextSize=fS
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextYAlignment=Enum.TextYAlignment.Center
        lb:SetAttribute("ThemeTag","tx"); lb.Parent=ca
        local db=Instance.new("TextButton")
        db.Size=UDim2.new(0.54,-14,0,32); db.Position=UDim2.new(0.46,0,0.5,-16)
        db.BackgroundColor3=Co.ch; db.Text=""; db:SetAttribute("ThemeTag","ch"); db.Parent=ca
        Instance.new("UICorner",db).CornerRadius=UDim.new(0,8)
        local D={["Robux Cart1"]="Crocodile Cart",["Robux Cart2"]="F1 Cart",["Robux Cart3"]="Rocket Cart",["Robux Cart4"]="Jet Plane Cart"}
        local dN=D[C[cK]] or C[cK]
        local dbText=Instance.new("TextLabel")
        dbText.Size=UDim2.new(1,-36,1,0); dbText.Position=UDim2.new(0,10,0,0)
        dbText.BackgroundTransparency=1; dbText.Text=dN; dbText.TextColor3=Co.tx
        dbText.Font=Enum.Font.GothamMedium; dbText.TextSize=fS-1
        dbText.TextTruncate=Enum.TextTruncate.AtEnd; dbText.TextXAlignment=Enum.TextXAlignment.Left
        dbText:SetAttribute("ThemeTag","tx"); dbText.Parent=db
        local dbIcon=Instance.new("ImageLabel")
        dbIcon.Size=UDim2.new(0,16,0,16); dbIcon.Position=UDim2.new(1,-22,0.5,-8)
        dbIcon.BackgroundTransparency=1; dbIcon.Image="rbxassetid://91662102247848"
        dbIcon.ImageColor3=Co.ts; dbIcon:SetAttribute("ThemeTag","ts"); dbIcon.Parent=db
        local dL=Instance.new("Frame")
        dL.Name="DropList"; dL.Size=UDim2.new(0,0,0,0); dL.BackgroundColor3=Co.cd
        dL.Visible=false; dL.ZIndex=999; dL.ClipsDescendants=true
        dL:SetAttribute("ThemeTag","cd"); dL.Parent=m
        Instance.new("UICorner",dL).CornerRadius=UDim.new(0,10)
        local dLs=Instance.new("UIStroke",dL); dLs.Color=Co.br; dLs.Thickness=1.5; dLs.Transparency=0.3
        local dLPad=Instance.new("UIPadding",dL)
        dLPad.PaddingLeft=UDim.new(0,4); dLPad.PaddingRight=UDim.new(0,4)
        table.insert(oD,dL)
        local dS=Instance.new("ScrollingFrame")
        dS.Size=UDim2.new(1,0,1,0); dS.BackgroundTransparency=1
        dS.ScrollBarThickness=2; dS.ScrollBarImageColor3=Co.br
        dS.CanvasSize=UDim2.new(0,0,0,(#op*40)+(#op-1)*2+12)
        dS.ZIndex=1000; dS.ClipsDescendants=false; dS.Parent=dL
        local dPad=Instance.new("UIPadding",dS)
        dPad.PaddingTop=UDim.new(0,6); dPad.PaddingBottom=UDim.new(0,6)
        Instance.new("UIListLayout",dS).Padding=UDim.new(0,2)
        for i,opt in ipairs(op) do
            local ob=Instance.new("TextButton")
            ob.Size=UDim2.new(1,-8,0,40); ob.BackgroundColor3=Co.cd; ob.Text=""
            ob.ZIndex=1001; ob.ClipsDescendants=false; ob.AutoButtonColor=false
            ob:SetAttribute("ThemeTag","cd"); ob.Parent=dS
            Instance.new("UICorner",ob).CornerRadius=UDim.new(0,8)
            local function isSel()
                if cK=="CartSelect" then local N={["Crocodile Cart"]="Robux Cart1",["F1 Cart"]="Robux Cart2",["Rocket Cart"]="Robux Cart3",["Jet Plane Cart"]="Robux Cart4"}; return C[cK]==(N[opt] or opt) else return C[cK]==opt end
            end
            if isSel() then ob.BackgroundColor3=Co.al end
            local optText=Instance.new("TextLabel")
            optText.Size=UDim2.new(1,-24,1,0); optText.Position=UDim2.new(0,12,0,0)
            optText.BackgroundTransparency=1; optText.Text=tostring(opt)
            optText.TextColor3=isSel() and Co.ac or Co.tx
            optText.Font=isSel() and Enum.Font.GothamBold or Enum.Font.GothamMedium
            optText.TextSize=fS; optText.TextXAlignment=Enum.TextXAlignment.Left; optText.ZIndex=1002
            optText:SetAttribute("ThemeTag",isSel() and "ac" or "tx"); optText.Parent=ob
            if i<#op then
                local div=Instance.new("Frame")
                div.Size=UDim2.new(1,-28,0,1); div.Position=UDim2.new(0,14,1,-1)
                div.BackgroundColor3=Co.br; div.BackgroundTransparency=0.6; div.BorderSizePixel=0
                div.ZIndex=1002; div:SetAttribute("ThemeTag","br_divider"); div.Parent=ob
            end
            ob.MouseEnter:Connect(function() if not isSel() then playSound(Sounds.Hover,0.2); T:Create(ob,TweenInfo.new(0.15),{BackgroundColor3=Co.ch}):Play(); T:Create(optText,TweenInfo.new(0.15),{TextColor3=Co.ac}):Play() end end)
            ob.MouseLeave:Connect(function() if not isSel() then T:Create(ob,TweenInfo.new(0.15),{BackgroundColor3=Co.cd}):Play(); T:Create(optText,TweenInfo.new(0.15),{TextColor3=Co.tx}):Play() end end)
            ob.MouseButton1Click:Connect(function()
                playSound(Sounds.Click,0.3)
                local N={["Crocodile Cart"]="Robux Cart1",["F1 Cart"]="Robux Cart2",["Rocket Cart"]="Robux Cart3",["Jet Plane Cart"]="Robux Cart4"}
                C[cK]=(cK=="CartSelect") and (N[opt] or opt) or opt
                dbText.Text=(cK=="CartSelect") and (D[C[cK]] or C[cK]) or opt
                for _,child in ipairs(dS:GetChildren()) do
                    if child:IsA("TextButton") then
                        local ct=child:FindFirstChildWhichIsA("TextLabel")
                        if ct then local sel=child==ob; T:Create(ct,TweenInfo.new(0.15),{TextColor3=sel and Co.ac or Co.tx}):Play(); ct.Font=sel and Enum.Font.GothamBold or Enum.Font.GothamMedium; ct:SetAttribute("ThemeTag",sel and "ac" or "tx"); T:Create(child,TweenInfo.new(0.2),{BackgroundColor3=sel and Co.al or Co.cd}):Play(); child:SetAttribute("ThemeTag",sel and "al" or "cd") end
                    end
                end
                T:Create(dL,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size=UDim2.new(0,dL.Size.X.Offset,0,0)}):Play()
                task.wait(0.2); dL.Visible=false
            end)
        end
        db.MouseButton1Click:Connect(function()
            playSound(Sounds.Dropdown,0.3); local wV=dL.Visible; cD()
            if not wV then
                local bP=db.AbsolutePosition; local bSz=db.AbsoluteSize; local mP=m.AbsolutePosition
                local tH=math.min(#op*40+12,180)
                dL.Position=UDim2.new(0,bP.X-mP.X,0,bP.Y-mP.Y+bSz.Y+4)
                dL.Size=UDim2.new(0,bSz.X,0,0); dL.Visible=true
                T:Create(dL,TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.new(0,bSz.X,0,tH)}):Play()
            end
        end)
    end

    -- ============================================
    -- CONTENT: TAB 1 — HOME
    -- ============================================
    useTab(1)

    Se("ABOUT")

    Ds("SynceHub v" .. version .. "\nMade for Potato Idle.\nJoin our Discord for updates and support.")

    Bt("Join Discord", function()
        -- setclipboard("https://discord.gg/yourlink")
        Feature.showNotification("Discord link copied!", true)
    end, "rbxassetid://103765114837028")

    -- ============================================
    -- CONTENT: TAB 2 — PLAYER
    -- ============================================
    useTab(2)

    Se("AUTO CLICK")
    Tg("Auto Click (Brutal Spam)", "AutoClick", function(v)
        Feature.toggleAutoClick(v)
    end)

    -- ============================================
    -- CONTENT: TAB 3 — THEMES
    -- ============================================
    useTab(3)

    Se("THEMES")

    if themesModule and themesModule.List and #themesModule.List > 0 then

        local listContainer = Instance.new("Frame")
        listContainer.Size                = UDim2.new(1, 0, 0, 0)
        listContainer.AutomaticSize       = Enum.AutomaticSize.Y
        listContainer.BackgroundTransparency = 1
        listContainer.BorderSizePixel     = 0
        listContainer.LayoutOrder         = nO()
        listContainer.Parent              = currentSc

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding    = UDim.new(0, 6)
        listLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        listLayout.Parent     = listContainer

        for i, theme in ipairs(themesModule.List) do
            local isActive = theme.ID == config.CurrentTheme
            local ac  = theme.Colors and theme.Colors.ac  or Color3.fromRGB(150, 80, 255)
            local bg  = theme.Colors and theme.Colors.bg  or Color3.fromRGB(18, 10, 40)
            local cd  = theme.Colors and theme.Colors.cd  or Color3.fromRGB(28, 15, 58)
            local tx  = theme.Colors and theme.Colors.tx  or Color3.fromRGB(255, 255, 255)
            local ts  = theme.Colors and theme.Colors.ts  or Color3.fromRGB(180, 150, 220)

            -- Row card
            local row = Instance.new("TextButton")
            row.Size             = UDim2.new(1, 0, 0, bH)
            row.BackgroundColor3 = Co.cd
            row.Text             = ""
            row.AutoButtonColor  = false
            row.LayoutOrder      = i
            row:SetAttribute("ThemeTag", "cd")
            row.Parent           = listContainer
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

            -- Stroke — accent color kalau aktif, br kalau tidak
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color       = isActive and ac or Co.br
            rowStroke.Thickness   = isActive and 2 or 1.5
            rowStroke.Transparency = 0

            -- Color swatch kiri (2 kotak bertumpuk: bg + ac)
            local swatchBg = Instance.new("Frame")
            swatchBg.Size             = UDim2.new(0, 36, 0, 36)
            swatchBg.Position         = UDim2.new(0, 10, 0.5, -18)
            swatchBg.BackgroundColor3 = bg
            swatchBg.BorderSizePixel  = 0
            swatchBg.Parent           = row
            Instance.new("UICorner", swatchBg).CornerRadius = UDim.new(0, 8)

            local swatchAc = Instance.new("Frame")
            swatchAc.Size             = UDim2.new(0, 18, 0, 18)
            swatchAc.AnchorPoint      = Vector2.new(1, 1)
            swatchAc.Position         = UDim2.new(1, 4, 1, 4)
            swatchAc.BackgroundColor3 = ac
            swatchAc.BorderSizePixel  = 0
            swatchAc.Parent           = swatchBg
            Instance.new("UICorner", swatchAc).CornerRadius = UDim.new(0, 5)

            local swatchAcStroke = Instance.new("UIStroke", swatchAc)
            swatchAcStroke.Color     = Co.bg
            swatchAcStroke.Thickness = 2

            -- Nama theme
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size                  = UDim2.new(1, -80, 1, 0)
            nameLabel.Position              = UDim2.new(0, 58, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text                  = theme.Name or theme.ID
            nameLabel.TextColor3            = isActive and ac or Co.tx
            nameLabel.Font                  = isActive and Enum.Font.GothamBold or Enum.Font.Gotham
            nameLabel.TextSize              = fS
            nameLabel.TextXAlignment        = Enum.TextXAlignment.Left
            nameLabel.TextYAlignment        = Enum.TextYAlignment.Center
            nameLabel.Parent                = row

            -- Dot aktif di kanan
            local dot = Instance.new("Frame")
            dot.Size             = UDim2.new(0, 8, 0, 8)
            dot.AnchorPoint      = Vector2.new(1, 0.5)
            dot.Position         = UDim2.new(1, -14, 0.5, 0)
            dot.BackgroundColor3 = ac
            dot.BorderSizePixel  = 0
            dot.BackgroundTransparency = isActive and 0 or 1
            dot.Parent           = row
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            -- UIScale press effect
            local rowScale = Instance.new("UIScale")
            rowScale.Scale  = 1
            rowScale.Parent = row

            row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    T:Create(rowScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Scale = 0.97 }):Play()
                end
            end)
            row.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    T:Create(rowScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
                end
            end)

            row.MouseEnter:Connect(function()
                if theme.ID ~= config.CurrentTheme then
                    T:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = Co.ch }):Play()
                end
            end)
            row.MouseLeave:Connect(function()
                T:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = Co.cd }):Play()
            end)

            row.MouseButton1Click:Connect(function()
                if theme.ID == config.CurrentTheme then return end
                playSound(Sounds.Click, 0.3)
                applyTheme(theme)
                currentThemeIndex = i

                -- Update semua row
                for _, ch in ipairs(listContainer:GetChildren()) do
                    if ch:IsA("TextButton") then
                        local chStroke = ch:FindFirstChildOfClass("UIStroke")
                        local chName   = ch:FindFirstChildWhichIsA("TextLabel")
                        local chDot    = ch:FindFirstChild("dot") or (function()
                            for _, c in ipairs(ch:GetChildren()) do
                                if c:IsA("Frame") and c.Size == UDim2.new(0,8,0,8) then return c end
                            end
                        end)()
                        local sel = ch == row
                        local chAc = sel and ac or Co.br

                        if chStroke then
                            T:Create(chStroke, TweenInfo.new(0.25), {
                                Color     = sel and ac or Co.br,
                                Thickness = sel and 2 or 1.5,
                            }):Play()
                        end
                        if chName then
                            T:Create(chName, TweenInfo.new(0.2), {
                                TextColor3 = sel and ac or Co.tx
                            }):Play()
                            chName.Font = sel and Enum.Font.GothamBold or Enum.Font.Gotham
                        end
                        if chDot then
                            T:Create(chDot, TweenInfo.new(0.2), {
                                BackgroundTransparency = sel and 0 or 1
                            }):Play()
                        end
                    end
                end
            end)
        end
    else
        Ds("No themes available.")
    end

    -- ============================================
    -- CONTENT: TAB 4 — SETTINGS
    -- ============================================
    useTab(4)

    Se("SETTINGS")

    kB = Bt("Set Keybind: " .. gKN(C.Keybind), function()
        if S.WaitingKey then return end
        S.WaitingKey = true
        local tx = kB:FindFirstChild("TextLabel")
        if tx then tx.Text = "Press any key..." end
        kB.BackgroundColor3 = Co.warn
        local conn
        local timeout = task.delay(8, function()
            if S.WaitingKey then
                S.WaitingKey = false
                if tx then tx.Text = "Set Keybind: " .. gKN(C.Keybind) end
                kB.BackgroundColor3 = Co.cd
                if conn then conn:Disconnect() end
                Feature.showNotification("Keybind timeout!", false)
            end
        end)
        conn = U.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.UserInputType == Enum.UserInputType.Keyboard then
                task.cancel(timeout); C.Keybind = i.KeyCode
                if tx then tx.Text = "Set Keybind: " .. gKN(C.Keybind) end
                kB.BackgroundColor3 = Co.cd; S.WaitingKey = false; conn:Disconnect()
                Feature.showNotification("Keybind set to " .. gKN(C.Keybind), true)
            end
        end)
    end, "rbxassetid://105330233440321")

    Bt("Destroy UI", function()
        S.U = true; _G.SynceHubLoaded = false
        for _, conn in pairs(S.Co) do pcall(function() conn:Disconnect() end) end
        Feature.cleanup()
        if S.G  then S.G:Destroy()  end
        if S.Mb then S.Mb:Destroy() end
    end, "rbxassetid://137032142339509")

    -- ============================================
    -- DRAG SYSTEM
    -- ============================================
    local dragStart, startPos, startAbsPos
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragStart   = i.Position
            startPos    = m.Position
            -- Resolve posisi absolut m sekarang (piksel nyata di layar)
            local vp = workspace.CurrentCamera.ViewportSize
            startAbsPos = Vector2.new(
                vp.X * startPos.X.Scale + startPos.X.Offset,
                vp.Y * startPos.Y.Scale + startPos.Y.Offset
            )
        end
    end)
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
        end
    end)

    S.Co.Drag = U.InputChanged:Connect(function(i)
        if dragStart and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dt   = i.Position - dragStart
            local newX = startPos.X.Offset + dt.X
            local newY = startPos.Y.Offset + dt.Y
            m.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            -- Hitung posisi absolut m saat ini dari startAbsPos + delta
            -- Tidak bergantung pada AbsolutePosition Roblox sama sekali
            local mAbsX = startAbsPos.X + dt.X
            local mAbsY = startAbsPos.Y + dt.Y
            sidebar.Position = UDim2.new(0, mAbsX - 48 - 6, 0, mAbsY + 10)
        end
    end)

    -- ============================================
    -- PARENT GUI
    -- ============================================
    m.BackgroundTransparency = 0
    m.Visible       = false
    sidebar.Visible = false

    pcall(function() g.Parent = game:GetService("CoreGui") end)
    if not g.Parent then g.Parent = L:WaitForChild("PlayerGui") end

    S.G = g

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        task.spawn(function()
            m.Position = UDim2.new(0.5, -m.AbsoluteSize.X/2, 0.5, -m.AbsoluteSize.Y/2)
            task.wait(0.1)
            m.Position = UDim2.new(0.5, -m.AbsoluteSize.X/2, 0.5, -m.AbsoluteSize.Y/2)
            -- Sidebar otomatis ikut karena child dari m
        end)
    end)

    -- ============================================
    -- FUNGSI SHOW / HIDE ANIMASI (main frame + sidebar bareng)
    -- ============================================
    local hubVisible  = true
    local hubAnimating = false

    local function showHub()
        if hubAnimating then return end
        hubAnimating = true
        playSound(Sounds.Click, 0.5)

        local vp    = workspace.CurrentCamera.ViewportSize
        local offX  = vp.X + 50
        local mAbsY = vp.Y * 0.5 - h / 2

        sidebar.Position = UDim2.new(0, offX - 48 - 6, 0, mAbsY + 10)
        sidebar.Size     = UDim2.new(0, 48, 0, h - 20)
        sidebar.Visible  = true
        m.Position       = UDim2.new(0, offX, 0.5, -h/2)
        m.Visible        = true

        T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
        }):Play()
        T:Create(sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, vp.X/2 - w/2 - 48 - 6, 0, mAbsY + 10)
        }):Play()

        task.delay(0.5, function()
            hubVisible   = true
            hubAnimating = false
        end)
    end

    local function hideHub()
        if hubAnimating then return end
        hubAnimating = true
        playSound(Sounds.Click, 0.4)

        local offX = workspace.CurrentCamera.ViewportSize.X + 50
        T:Create(m, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0, offX, 0.5, -h/2)
        }):Play()

        task.delay(0.4, function()
            m.Visible       = false
            sidebar.Visible = false
            hubVisible      = false
            hubAnimating    = false
        end)
    end

    -- ============================================
    -- MOBILE BUTTON
    -- ============================================
    if isMobile then
        local BT = 0.10
        local mB = Instance.new("Frame")
        mB.Size=UDim2.new(0,100,0,32); mB.Position=UDim2.new(0,10,0,10)
        mB.BackgroundColor3=Co.cd; mB.BackgroundTransparency=BT
        mB.BorderSizePixel=0; mB.Parent=g
        Instance.new("UICorner",mB).CornerRadius=UDim.new(0,16)
        local mStroke=Instance.new("UIStroke",mB)
        mStroke.Color=Co.br; mStroke.Thickness=1.5; mStroke.Transparency=0.3
        local mI=Instance.new("ImageLabel")
        mI.Size=UDim2.new(0,20,0,20); mI.Position=UDim2.new(0,8,0.5,-10)
        mI.BackgroundTransparency=1; mI.Image="rbxassetid://114167695335193"; mI.ImageColor3=Co.tx; mI.Parent=mB
        local btnText=Instance.new("TextLabel")
        btnText.Size=UDim2.new(1,-36,1,0); btnText.Position=UDim2.new(0,32,0,0)
        btnText.BackgroundTransparency=1; btnText.Text="Hide"; btnText.TextColor3=Co.tx
        btnText.Font=Enum.Font.GothamBold; btnText.TextSize=15
        btnText.TextXAlignment=Enum.TextXAlignment.Center; btnText.TextYAlignment=Enum.TextYAlignment.Center; btnText.Parent=mB
        local mT=Instance.new("TextButton")
        mT.Size=UDim2.new(1,0,1,0); mT.BackgroundTransparency=1; mT.Text=""; mT.Parent=mB
        local dragging,dragStart2,startPos2,wasDragged=false,nil,nil,false
        mT.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart2=input.Position; startPos2=mB.Position; wasDragged=false
            end
        end)
        mT.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=false
                if not wasDragged then
                    if hubVisible then
                        hideHub()
                        btnText.Text = "Show"
                        mI.Image = "rbxassetid://99334701468696"
                    else
                        showHub()
                        btnText.Text = "Hide"
                        mI.Image = "rbxassetid://114167695335193"
                    end
                    T:Create(mB,TweenInfo.new(0.1,Enum.EasingStyle.Quad),{Size=UDim2.new(0,95,0,30)}):Play()
                    task.wait(0.1); T:Create(mB,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Size=UDim2.new(0,100,0,32)}):Play()
                end
            end
        end)
        U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                local delta=input.Position-dragStart2
                if math.abs(delta.X)>5 or math.abs(delta.Y)>5 then wasDragged=true end
                mB.Position=UDim2.new(startPos2.X.Scale,startPos2.X.Offset+delta.X,startPos2.Y.Scale,startPos2.Y.Offset+delta.Y)
            end
        end)
        mT.MouseEnter:Connect(function() if not dragging then T:Create(mB,TweenInfo.new(0.2),{BackgroundColor3=Co.ch,BackgroundTransparency=BT-0.05}):Play(); T:Create(mStroke,TweenInfo.new(0.2),{Color=Co.ac}):Play() end end)
        mT.MouseLeave:Connect(function() T:Create(mB,TweenInfo.new(0.2),{BackgroundColor3=Co.cd,BackgroundTransparency=BT}):Play(); T:Create(mStroke,TweenInfo.new(0.2),{Color=Co.br}):Play() end)
        S.Mb=mB
        mB.Position=UDim2.new(0,-110,0,10); mB.BackgroundTransparency=1
        btnText.TextTransparency=1; mI.ImageTransparency=1; mStroke.Transparency=1
        task.wait(0.3)
        T:Create(mB,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,10,0,10),BackgroundTransparency=BT}):Play()
        T:Create(btnText,TweenInfo.new(0.4),{TextTransparency=0}):Play()
        T:Create(mI,TweenInfo.new(0.4),{ImageTransparency=0}):Play()
        T:Create(mStroke,TweenInfo.new(0.4),{Transparency=0.3}):Play()
    end

    -- ============================================
    -- ANIMATE IN PERTAMA KALI
    -- ============================================
    task.wait()
    task.wait()

    local sS2  = workspace.CurrentCamera.ViewportSize
    local offX = sS2.X + 50
    local mAbsY = sS2.Y * 0.5 - h / 2  -- posisi Y absolut m di tengah layar

    -- Set posisi sidebar manual (tidak pakai syncPositions karena AbsolutePosition belum valid)
    sidebar.Position = UDim2.new(0, offX - 48 - 6, 0, mAbsY + 10)
    sidebar.Size     = UDim2.new(0, 48, 0, h - 20)
    sidebar.Visible  = true

    m.Position = UDim2.new(0, offX, 0.5, -h/2)
    m.Visible  = true

    T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    }):Play()
    T:Create(sidebar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, sS2.X/2 - w/2 - 48 - 6, 0, mAbsY + 10)
    }):Play()

    task.wait(0.3)

    if themesModule and themesModule.List and #themesModule.List > 0 then
        local startTheme = themesModule.getTheme(config.CurrentTheme) or themesModule.List[1]
        applyTheme(startTheme)
    end

    task.wait(0.2)
    Feature.showNotification("SynceHub initialized successfully!", true)
end

return TabContent
