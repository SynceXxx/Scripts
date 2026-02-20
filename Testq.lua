-- PotatoTab.lua
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
    Minimize = "rbxassetid://6895079853",
    Dropdown = "rbxassetid://6895079853",
    Success  = "rbxassetid://6026984224",
    Error    = "rbxassetid://4590662766"
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

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName, gameName, themesModule)
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

    -- Color scheme (default: Neon Purple) — identik dengan Themen.lua neon_purple
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
    g.Name            = "SynceHub"
    g.ResetOnSpawn    = false
    g.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling

    -- ============================================
    -- SIDEBAR CONSTANTS
    -- ============================================
    local SB_W          = 58    -- lebar panel sidebar
    local SB_GAP        = 6     -- jarak sidebar panel ke m
    local SB_Y_OFFSET   = 10    -- offset atas/bawah sidebar vs m
    local SB_BTN_SIZE   = 40    -- ukuran tab button
    local SB_BTN_GAP    = 8     -- jarak antar tab button
    local SB_BTN_TOP    = 12    -- margin atas tab buttons

    local PILL_W        = 22    -- lebar pill handle
    local PILL_H        = 72    -- tinggi pill handle
    local PILL_OVERLAP  = 8     -- seberapa pill masuk ke belakang m/sidebar

    local sidebarOpen      = false
    local sidebarAnimating = false
    local activeTabIndex   = 1

    -- Tab definitions
    local tabDefs = {
        { name = "Auto",     icon = "rbxassetid://118025272389341" },
        { name = "Settings", icon = "rbxassetid://104337285697355" },
    }

    -- ============================================
    -- MAIN FRAME  (ZIndex 2)
    -- ============================================
    local m = Instance.new("Frame")
    m.Name                = "Main"
    m.Size                = UDim2.new(0, w, 0, h)
    m.Position            = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3    = Co.bg
    m.BorderSizePixel     = 0
    m.ClipsDescendants    = true
    m.ZIndex              = 2
    m:SetAttribute("ThemeTag", "bg")
    m.Parent              = g

    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16)

    -- Gradient Neon Purple
    m.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local neonPurpleGrad = Instance.new("UIGradient")
    neonPurpleGrad.Name  = "NeonPurpleGrad"
    neonPurpleGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(15, 5, 35)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 10, 80)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 25, 140)),
    }
    neonPurpleGrad.Rotation = 135
    neonPurpleGrad.Parent   = m

    -- Drop shadow
    local sh = Instance.new("ImageLabel")
    sh.Size             = UDim2.new(1, 30, 1, 30)
    sh.Position         = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image            = "rbxassetid://5554236805"
    sh.ImageColor3      = Color3.new(0, 0, 0)
    sh.ImageTransparency = 0.3
    sh.ScaleType        = Enum.ScaleType.Slice
    sh.SliceCenter      = Rect.new(23, 23, 277, 277)
    sh.ZIndex           = 0
    sh.Parent           = m

    -- ============================================
    -- SIDEBAR PANEL  (ZIndex 1, tersembunyi defaultnya)
    -- Muncul ke kiri m saat open
    -- ============================================
    local sidebar = Instance.new("Frame")
    sidebar.Name            = "Sidebar"
    sidebar.Size            = UDim2.new(0, SB_W, 0, h - SB_Y_OFFSET * 2)
    sidebar.Position        = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = Co.cd
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex          = 1
    sidebar.Visible         = false
    sidebar:SetAttribute("ThemeTag", "cd")
    sidebar.Parent          = g

    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    local sidebarStroke = Instance.new("UIStroke", sidebar)
    sidebarStroke.Color       = Co.br
    sidebarStroke.Thickness   = 1.5
    sidebarStroke.Transparency = 0.3
    sidebarStroke:SetAttribute("ThemeTag", "br")

    -- Tab buttons container (di dalam sidebar)
    local tabBtnContainer = Instance.new("Frame")
    tabBtnContainer.Name             = "TabBtnContainer"
    tabBtnContainer.Size             = UDim2.new(1, -8, 0, (#tabDefs * (SB_BTN_SIZE + SB_BTN_GAP)) - SB_BTN_GAP)
    tabBtnContainer.Position         = UDim2.new(0, 4, 0, SB_BTN_TOP)
    tabBtnContainer.BackgroundTransparency = 1
    tabBtnContainer.ZIndex           = 3
    tabBtnContainer.Parent           = sidebar

    local tabBtnLayout = Instance.new("UIListLayout")
    tabBtnLayout.Padding            = UDim.new(0, SB_BTN_GAP)
    tabBtnLayout.SortOrder          = Enum.SortOrder.LayoutOrder
    tabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabBtnLayout.Parent             = tabBtnContainer

    -- Tab icon buttons
    local tabButtons = {}
    for i, def in ipairs(tabDefs) do
        local isActive = i == activeTabIndex

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size             = UDim2.new(1, 0, 0, SB_BTN_SIZE)
        tabBtn.BackgroundColor3 = isActive and Co.ac or Co.ch
        tabBtn.Text             = ""
        tabBtn.ZIndex           = 4
        tabBtn.LayoutOrder      = i
        tabBtn:SetAttribute("ThemeTag", isActive and "ac" or "ch")
        tabBtn.Parent           = tabBtnContainer
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size            = UDim2.new(0, 22, 0, 22)
        tabIcon.Position        = UDim2.new(0.5, -11, 0.5, -11)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image           = def.icon
        tabIcon.ImageColor3     = isActive and Co.tx or Co.ts
        tabIcon.ZIndex          = 5
        tabIcon:SetAttribute("ThemeTag", isActive and "tx" or "ts")
        tabIcon.Parent          = tabBtn

        tabButtons[i] = { btn = tabBtn, icon = tabIcon }
    end

    -- ============================================
    -- PILL HANDLE (selalu visible, nempel di kiri m/sidebar)
    -- ============================================
    local pill = Instance.new("Frame")
    pill.Name             = "PillHandle"
    pill.Size             = UDim2.new(0, PILL_W, 0, PILL_H)
    pill.Position         = UDim2.new(0, 0, 0, 0)
    pill.BackgroundColor3 = Co.cd
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 3
    pill:SetAttribute("ThemeTag", "cd")
    pill.Parent           = g

    Instance.new("UICorner", pill).CornerRadius = UDim.new(0.5, 0)

    local pillStroke = Instance.new("UIStroke", pill)
    pillStroke.Color       = Co.br
    pillStroke.Thickness   = 1.5
    pillStroke.Transparency = 0.3
    pillStroke:SetAttribute("ThemeTag", "br")

    local pillLabel = Instance.new("TextLabel")
    pillLabel.Size             = UDim2.new(0, PILL_H - 8, 0, PILL_W - 4)
    pillLabel.AnchorPoint      = Vector2.new(0.5, 0.5)
    pillLabel.Position         = UDim2.new(0.5, 0, 0.5, 0)
    pillLabel.BackgroundTransparency = 1
    pillLabel.Text             = "OPEN"
    pillLabel.TextColor3       = Co.ts
    pillLabel.Font             = Enum.Font.GothamBold
    pillLabel.TextSize         = 10
    pillLabel.Rotation         = 90
    pillLabel.ZIndex           = 4
    pillLabel:SetAttribute("ThemeTag", "ts")
    pillLabel.Parent           = pill

    local pillBtn = Instance.new("TextButton")
    pillBtn.Size              = UDim2.new(1, 0, 1, 0)
    pillBtn.BackgroundTransparency = 1
    pillBtn.Text              = ""
    pillBtn.ZIndex            = 5
    pillBtn.Parent            = pill

    -- ============================================
    -- POSITION SYNC  (pill & sidebar ikut m saat drag)
    -- ============================================
    local function syncPositions()
        if not m or not m.Parent then return end
        local mX  = m.AbsolutePosition.X
        local mY  = m.AbsolutePosition.Y
        local mH  = m.AbsoluteSize.Y
        local pillY = mY + (mH / 2) - (PILL_H / 2)

        if sidebarOpen then
            local sbX = mX - SB_W - SB_GAP
            local sbY = mY + SB_Y_OFFSET
            local sbH = mH - SB_Y_OFFSET * 2
            sidebar.Position = UDim2.new(0, sbX, 0, sbY)
            sidebar.Size     = UDim2.new(0, SB_W, 0, sbH)
            pill.Position    = UDim2.new(0, sbX - PILL_W + PILL_OVERLAP, 0, pillY)
        else
            pill.Position    = UDim2.new(0, mX - PILL_W + PILL_OVERLAP, 0, pillY)
        end
    end

    -- Sync visibility pill & sidebar dengan m
    m:GetPropertyChangedSignal("Visible"):Connect(function()
        pill.Visible    = m.Visible
        sidebar.Visible = m.Visible and sidebarOpen
    end)

    -- ============================================
    -- SIDEBAR TOGGLE
    -- ============================================
    local function toggleSidebar()
        if sidebarAnimating then return end
        sidebarAnimating = true
        sidebarOpen      = not sidebarOpen
        playSound(Sounds.Click, 0.3)

        local mX   = m.AbsolutePosition.X
        local mY   = m.AbsolutePosition.Y
        local mH   = m.AbsoluteSize.Y
        local pillY = mY + (mH / 2) - (PILL_H / 2)

        if sidebarOpen then
            local sbX = mX - SB_W - SB_GAP
            local sbY = mY + SB_Y_OFFSET
            local sbH = mH - SB_Y_OFFSET * 2

            -- Sidebar mulai tersembunyi di balik m, lalu slide keluar
            sidebar.Position = UDim2.new(0, mX - PILL_W, 0, sbY)
            sidebar.Size     = UDim2.new(0, SB_W, 0, sbH)
            sidebar.BackgroundTransparency = 0.6
            sidebar.Visible  = true

            T:Create(sidebar, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, sbX, 0, sbY),
                BackgroundTransparency = 0
            }):Play()

            -- Pill geser ke kiri sidebar
            T:Create(pill, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, sbX - PILL_W + PILL_OVERLAP, 0, pillY)
            }):Play()

            -- Label ganti OPEN → CLOSE
            task.delay(0.15, function()
                T:Create(pillLabel, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
                task.wait(0.12)
                pillLabel.Text = "CLOSE"
                T:Create(pillLabel, TweenInfo.new(0.12), {TextTransparency = 0}):Play()
            end)
        else
            local targetPillX = mX - PILL_W + PILL_OVERLAP

            -- Sidebar slide masuk ke belakang m
            T:Create(sidebar, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(0, mX - PILL_W, 0, sidebar.Position.Y.Offset),
                BackgroundTransparency = 0.6
            }):Play()

            -- Pill balik ke kiri m
            T:Create(pill, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(0, targetPillX, 0, pillY)
            }):Play()

            -- Label ganti CLOSE → OPEN
            task.delay(0.08, function()
                T:Create(pillLabel, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
                task.wait(0.12)
                pillLabel.Text = "OPEN"
                T:Create(pillLabel, TweenInfo.new(0.12), {TextTransparency = 0}):Play()
            end)

            task.delay(0.28, function()
                sidebar.Visible = false
            end)
        end

        task.delay(0.38, function() sidebarAnimating = false end)
    end

    pillBtn.MouseButton1Click:Connect(toggleSidebar)

    pillBtn.MouseEnter:Connect(function()
        T:Create(pill,       TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
        T:Create(pillStroke, TweenInfo.new(0.15), {Color = Co.ac}):Play()
    end)
    pillBtn.MouseLeave:Connect(function()
        T:Create(pill,       TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
        T:Create(pillStroke, TweenInfo.new(0.15), {Color = Co.br}):Play()
    end)

    -- ============================================
    -- TAB SCROLL FRAMES (one per tab)
    -- ============================================
    local tabScrollFrames = {}

    local function makeTabScroll()
        local sc = Instance.new("ScrollingFrame")
        sc.Size               = UDim2.new(1, -4, 1, -60)
        sc.Position           = UDim2.new(0, 2, 0, 56)
        sc.BackgroundTransparency = 1
        sc.ScrollBarThickness  = 2
        sc.ScrollBarImageColor3 = Co.br
        sc.CanvasSize          = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ClipsDescendants    = true
        sc.Visible             = false
        sc.Parent              = m

        local sP = Instance.new("UIPadding")
        sP.PaddingLeft   = UDim.new(0, p - 2)
        sP.PaddingRight  = UDim.new(0, p + 2)
        sP.PaddingTop    = UDim.new(0, 2)
        sP.PaddingBottom = UDim.new(0, p)
        sP.Parent        = sc

        local ly = Instance.new("UIListLayout")
        ly.Padding    = UDim.new(0, 6)
        ly.SortOrder  = Enum.SortOrder.LayoutOrder
        ly.Parent     = sc

        return sc
    end

    for i = 1, #tabDefs do
        tabScrollFrames[i] = makeTabScroll()
    end
    tabScrollFrames[1].Visible = true   -- first tab visible by default

    -- ============================================
    -- TAB SWITCHING
    -- ============================================
    local function switchTab(index)
        if index == activeTabIndex then
            -- Close sidebar when same tab tapped
            if sidebarOpen then toggleSidebar() end
            return
        end
        activeTabIndex = index
        playSound(Sounds.Click, 0.3)

        for i, sc in ipairs(tabScrollFrames) do
            sc.Visible = (i == index)
        end

        for i, tb in ipairs(tabButtons) do
            local isActive = (i == index)
            T:Create(tb.btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                BackgroundColor3 = isActive and Co.ac or Co.ch
            }):Play()
            T:Create(tb.icon, TweenInfo.new(0.2), {
                ImageColor3 = isActive and Co.tx or Co.ts
            }):Play()
            tb.btn:SetAttribute("ThemeTag", isActive and "ac" or "ch")
            tb.icon:SetAttribute("ThemeTag", isActive and "tx" or "ts")
        end
    end

    -- Connect tab buttons
    for i, tb in ipairs(tabButtons) do
        tb.btn.MouseButton1Click:Connect(function()
            switchTab(i)
        end)

        tb.btn.MouseEnter:Connect(function()
            if activeTabIndex ~= i then
                T:Create(tb.btn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
            end
        end)
        tb.btn.MouseLeave:Connect(function()
            if activeTabIndex ~= i then
                T:Create(tb.btn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
            end
        end)
    end

    -- ============================================
    -- HEADER
    -- ============================================
    local hd = Instance.new("Frame")
    hd.Size                = UDim2.new(1, 0, 0, 52)
    hd.BackgroundTransparency = 1
    hd.ZIndex              = 10
    hd.Parent              = m

    local tL = Instance.new("TextLabel")
    tL.Size             = UDim2.new(1, -60, 0, 20)
    tL.Position         = UDim2.new(0, p, 0, 12)
    tL.BackgroundTransparency = 1
    tL.Text             = "SynceHub"
    tL.TextColor3       = Co.tx
    tL.Font             = Enum.Font.GothamBold
    tL.TextSize         = 18
    tL.TextXAlignment   = Enum.TextXAlignment.Left
    tL.ZIndex           = 11
    tL:SetAttribute("ThemeTag", "tx")
    tL.Parent           = hd

    local st = Instance.new("TextLabel")
    st.Size             = UDim2.new(1, -60, 0, 14)
    st.Position         = UDim2.new(0, p, 0, 33)
    st.BackgroundTransparency = 1
    st.Text             = (gameName or "Potato Idle") .. " | " .. version
    st.TextColor3       = Co.ts
    st.Font             = Enum.Font.Gotham
    st.TextSize         = 11
    st.TextXAlignment   = Enum.TextXAlignment.Left
    st.ZIndex           = 11
    st:SetAttribute("ThemeTag", "ts")
    st.Parent           = hd

    -- Close button
    local clBtn = Instance.new("TextButton")
    clBtn.Size           = UDim2.new(0, 32, 0, 32)
    clBtn.Position       = UDim2.new(1, -p-32, 0, 10)
    clBtn.BackgroundColor3 = Co.ch
    clBtn.Text           = "×"
    clBtn.TextColor3     = Co.ts
    clBtn.Font           = Enum.Font.GothamBold
    clBtn.TextSize       = 20
    clBtn.ZIndex         = 11
    clBtn:SetAttribute("ThemeTag", "ch")
    clBtn:SetAttribute("TextTag", "ts")
    clBtn.Parent         = hd
    Instance.new("UICorner", clBtn).CornerRadius = UDim.new(0, 10)

    -- Minimize button
    local cb = Instance.new("TextButton")
    cb.Size            = UDim2.new(0, 32, 0, 32)
    cb.Position        = UDim2.new(1, -p-70, 0, 10)
    cb.BackgroundColor3 = Co.ch
    cb.Text            = "−"
    cb.TextColor3      = Co.ts
    cb.Font            = Enum.Font.GothamBold
    cb.TextSize        = 16
    cb.ZIndex          = 11
    cb:SetAttribute("ThemeTag", "ch")
    cb:SetAttribute("TextTag", "ts")
    cb.Parent          = hd
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 10)

    -- Theme button
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size            = UDim2.new(0, 32, 0, 32)
    themeBtn.Position        = UDim2.new(1, -p-108, 0, 10)
    themeBtn.BackgroundColor3 = Co.ch
    themeBtn.Text            = ""
    themeBtn.ZIndex          = 11
    themeBtn:SetAttribute("ThemeTag", "ch")
    themeBtn.Parent          = hd
    Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 10)

    local themeIcon = Instance.new("ImageLabel")
    themeIcon.Size             = UDim2.new(0, 20, 0, 20)
    themeIcon.Position         = UDim2.new(0.5, -10, 0.5, -10)
    themeIcon.BackgroundTransparency = 1
    themeIcon.Image            = "rbxassetid://104337285697355"
    themeIcon.ImageColor3      = Co.ts
    themeIcon.ZIndex           = 12
    themeIcon:SetAttribute("ThemeTag", "ts")
    themeIcon.Parent           = themeBtn

    local mn  = false
    local fSz = m.Size
    local dv  = nil

    -- ============================================
    -- CONFIRM DIALOG
    -- ============================================
    local function showConfirmDialog()
        if m:FindFirstChild("ConfirmBlur") then return end

        if mn then
            mn = false
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
            cb.Text = "−"
            task.wait(0.3)
        end

        local blur = Instance.new("Frame")
        blur.Name                = "ConfirmBlur"
        blur.Size                = UDim2.new(1, 0, 1, 0)
        blur.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
        blur.BackgroundTransparency = 0.5
        blur.BorderSizePixel     = 0
        blur.ZIndex              = 2000
        blur.Parent              = m
        Instance.new("UICorner", blur).CornerRadius = UDim.new(0, 16)

        local blocker = Instance.new("TextButton")
        blocker.Size             = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text             = ""
        blocker.ZIndex           = 2000
        blocker.Active           = true
        blocker.AutoButtonColor  = false
        blocker.Parent           = blur

        local dialog = Instance.new("Frame")
        dialog.Size              = UDim2.new(0, 280, 0, 140)
        dialog.Position          = UDim2.new(0.5, -140, 0.5, -70)
        dialog.BackgroundColor3  = Co.cd
        dialog.BackgroundTransparency = 0.3
        dialog.BorderSizePixel   = 0
        dialog.ZIndex            = 2001
        dialog.Parent            = blur
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)

        local dialogStroke = Instance.new("UIStroke", dialog)
        dialogStroke.Color       = Co.br
        dialogStroke.Thickness   = 1
        dialogStroke.Transparency = 0.3

        local shadow = Instance.new("ImageLabel")
        shadow.Size              = UDim2.new(1, 20, 1, 20)
        shadow.Position          = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image             = "rbxassetid://5554236805"
        shadow.ImageColor3       = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.ScaleType         = Enum.ScaleType.Slice
        shadow.SliceCenter       = Rect.new(23, 23, 277, 277)
        shadow.ZIndex            = 2000
        shadow.Parent            = dialog

        local icon = Instance.new("ImageLabel")
        icon.Size             = UDim2.new(0, 18, 0, 18)
        icon.Position         = UDim2.new(1, -26, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image            = "rbxassetid://101745201658882"
        icon.ImageColor3      = Co.ts
        icon.ZIndex           = 2002
        icon.Parent           = dialog

        local title = Instance.new("TextLabel")
        title.Size             = UDim2.new(1, -45, 0, 24)
        title.Position         = UDim2.new(0, 16, 0, 12)
        title.BackgroundTransparency = 1
        title.Text             = "Close Window"
        title.TextColor3       = Co.tx
        title.Font             = Enum.Font.GothamBold
        title.TextSize         = 16
        title.TextXAlignment   = Enum.TextXAlignment.Left
        title.ZIndex           = 2002
        title.Parent           = dialog

        local desc = Instance.new("TextLabel")
        desc.Size              = UDim2.new(1, -32, 0, 36)
        desc.Position          = UDim2.new(0, 16, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Text              = "Do you want to close this window?\nYou will not be able to open it again."
        desc.TextColor3        = Co.tx
        desc.Font              = Enum.Font.Gotham
        desc.TextSize          = 14
        desc.TextWrapped       = true
        desc.TextXAlignment    = Enum.TextXAlignment.Left
        desc.TextYAlignment    = Enum.TextYAlignment.Top
        desc.ZIndex            = 2002
        desc.Parent            = dialog

        local btnContainer = Instance.new("Frame")
        btnContainer.Size        = UDim2.new(1, -32, 0, 36)
        btnContainer.Position    = UDim2.new(0, 16, 1, -44)
        btnContainer.BackgroundTransparency = 1
        btnContainer.ZIndex      = 2002
        btnContainer.Parent      = dialog

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size           = UDim2.new(0.48, 0, 1, 0)
        cancelBtn.BackgroundColor3 = Co.ch
        cancelBtn.Text           = "Cancel"
        cancelBtn.TextColor3     = Co.tx
        cancelBtn.Font           = Enum.Font.GothamBold
        cancelBtn.TextSize       = 13
        cancelBtn.ZIndex         = 2003
        cancelBtn.Parent         = btnContainer
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size          = UDim2.new(0.48, 0, 1, 0)
        confirmBtn.Position      = UDim2.new(0.52, 0, 0, 0)
        confirmBtn.BackgroundColor3 = Co.ac
        confirmBtn.Text          = "Close Window"
        confirmBtn.TextColor3    = Color3.fromRGB(255, 255, 255)
        confirmBtn.Font          = Enum.Font.GothamBold
        confirmBtn.TextSize      = 13
        confirmBtn.ZIndex        = 2003
        confirmBtn.Parent        = btnContainer
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

        -- Fade-in
        blur.BackgroundTransparency    = 1
        dialog.BackgroundTransparency  = 1
        icon.ImageTransparency         = 1
        title.TextTransparency         = 1
        desc.TextTransparency          = 1
        cancelBtn.BackgroundTransparency  = 1
        cancelBtn.TextTransparency        = 1
        confirmBtn.BackgroundTransparency = 1
        confirmBtn.TextTransparency       = 1
        dialogStroke.Transparency         = 1
        shadow.ImageTransparency          = 1

        T:Create(blur,        TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
        T:Create(dialog,      TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
        T:Create(dialogStroke,TweenInfo.new(0.25), {Transparency = 0.3}):Play()
        T:Create(shadow,      TweenInfo.new(0.25), {ImageTransparency = 0.6}):Play()
        T:Create(icon,        TweenInfo.new(0.3),  {ImageTransparency = 0}):Play()
        T:Create(title,       TweenInfo.new(0.3),  {TextTransparency = 0}):Play()
        T:Create(desc,        TweenInfo.new(0.3),  {TextTransparency = 0}):Play()
        T:Create(cancelBtn,   TweenInfo.new(0.3),  {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        T:Create(confirmBtn,  TweenInfo.new(0.3),  {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        playSound(Sounds.Click, 0.3)

        cancelBtn.MouseEnter:Connect(function()  T:Create(cancelBtn,  TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()  end)
        cancelBtn.MouseLeave:Connect(function()  T:Create(cancelBtn,  TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()  end)
        confirmBtn.MouseEnter:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ach}):Play() end)
        confirmBtn.MouseLeave:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ac}):Play()  end)

        local function closeDialog()
            T:Create(blur,        TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            T:Create(dialog,      TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            T:Create(dialogStroke,TweenInfo.new(0.2), {Transparency = 1}):Play()
            T:Create(shadow,      TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
            T:Create(icon,        TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
            T:Create(title,       TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            T:Create(desc,        TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            T:Create(cancelBtn,   TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            T:Create(confirmBtn,  TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.2)
            blur:Destroy()
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
            if S.G then S.G:Destroy() end
            if S.Mb then S.Mb:Destroy() end
        end)
    end

    -- Close / minimize button wiring
    clBtn.MouseButton1Click:Connect(showConfirmDialog)
    clBtn.MouseEnter:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
    clBtn.MouseLeave:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)

    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.3)
        mn = not mn
        T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = mn and UDim2.new(0, w, 0, 52) or fSz}):Play()
        cb.Text = mn and "+" or "−"
    end)

    themeBtn.MouseEnter:Connect(function() T:Create(themeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
    themeBtn.MouseLeave:Connect(function() T:Create(themeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)

    -- ============================================
    -- THEME SYSTEM
    -- ============================================
    local themeApplying = false

    local function applyTheme(theme)
        if not theme or not theme.Colors then return end
        themeApplying = true
        local colors = theme.Colors

        Co.bg  = colors.bg
        Co.cd  = colors.cd
        Co.ch  = colors.ch
        Co.br  = colors.br
        Co.tx  = colors.tx
        Co.ts  = colors.ts
        Co.ac  = colors.ac
        Co.ach = colors.ach
        Co.sc  = Color3.new(colors.ts.R * 0.85, colors.ts.G * 0.85, colors.ts.B * 0.85)
        Co.warn = colors.warn or Co.warn
        Co.al  = Color3.new(
            colors.ac.R * 0.25 + colors.cd.R * 0.75,
            colors.ac.G * 0.25 + colors.cd.G * 0.75,
            colors.ac.B * 0.25 + colors.cd.B * 0.75
        )

        config.CurrentTheme = theme.ID
        S.CurrentColors     = colors

        local function applyToElement(element)
            if not element or not element.Parent then return end
            pcall(function()
                if element:IsA("TextButton") and element.Name == "ToggleBtn" then
                    local ck = element:GetAttribute("ConfigKey")
                    local isOn = ck and C[ck] or false
                    element.BackgroundColor3 = isOn and colors.ac or colors.ch
                end

                local tag = element:GetAttribute("ThemeTag")
                if tag then
                    if element:IsA("Frame") or element:IsA("ScrollingFrame") then
                        if     tag == "bg"       then element.BackgroundColor3 = colors.bg
                        elseif tag == "cd"       then element.BackgroundColor3 = colors.cd
                        elseif tag == "ch"       then element.BackgroundColor3 = colors.ch
                        elseif tag == "ac"       then element.BackgroundColor3 = colors.ac
                        elseif tag == "br_divider" then element.BackgroundColor3 = colors.br
                        end
                        local stroke = element:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = colors.br end
                        if element:IsA("ScrollingFrame") then
                            element.ScrollBarImageColor3 = colors.br
                        end
                    elseif element:IsA("TextLabel") then
                        if     tag == "tx" then element.TextColor3 = colors.tx
                        elseif tag == "ts" then element.TextColor3 = colors.ts
                        elseif tag == "sc" then element.TextColor3 = Co.sc
                        elseif tag == "ac" then element.TextColor3 = colors.ac
                        end
                    elseif element:IsA("TextButton") then
                        if     tag == "cd" then element.BackgroundColor3 = colors.cd
                        elseif tag == "ch" then element.BackgroundColor3 = colors.ch
                        elseif tag == "ac" then element.BackgroundColor3 = colors.ac
                        elseif tag == "al" then element.BackgroundColor3 = Co.al
                        end
                        local tc = element:GetAttribute("TextTag")
                        if     tc == "tx" then element.TextColor3 = colors.tx
                        elseif tc == "ts" then element.TextColor3 = colors.ts
                        end
                    elseif element:IsA("TextBox") then
                        if tag == "ch" then element.BackgroundColor3 = colors.ch end
                        element.TextColor3      = colors.tx
                        element.PlaceholderColor3 = colors.ts
                    elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
                        if     tag == "ts" then element.ImageColor3 = colors.ts
                        elseif tag == "tx" then element.ImageColor3 = colors.tx
                        elseif tag == "ac" then element.ImageColor3 = colors.ac
                        end
                    elseif element:IsA("UIStroke") then
                        element.Color = colors.br
                    end
                end
            end)
            for _, child in ipairs(element:GetChildren()) do
                applyToElement(child)
            end
        end

        -- Apply to main frame
        if m then applyToElement(m) end

        -- Apply to sidebar (not child of m, so separate traversal)
        if sidebar then applyToElement(sidebar) end

        -- Apply to pill
        if pill then
            pill.BackgroundColor3  = colors.cd
            pillStroke.Color       = colors.br
            pillLabel.TextColor3   = colors.ts
        end

        -- Update active tab button colors explicitly
        for i, tb in ipairs(tabButtons) do
            local isActive = (i == activeTabIndex)
            tb.btn.BackgroundColor3  = isActive and colors.ac or colors.ch
            tb.icon.ImageColor3      = isActive and colors.tx or colors.ts
        end

        -- Gradient for neon_purple
        local existingGrad = m:FindFirstChild("NeonPurpleGrad")
        if theme.ID == "neon_purple" then
            local grad = existingGrad or Instance.new("UIGradient")
            grad.Name   = "NeonPurpleGrad"
            grad.Color  = ColorSequence.new{
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(15, 5, 35)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 10, 80)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 25, 140)),
            }
            grad.Rotation = 135
            grad.Parent   = m
            m.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            if existingGrad then existingGrad:Destroy() end
            m.BackgroundColor3 = colors.bg
        end

        if dv then dv.BackgroundColor3 = colors.br end

        if S.Mb then
            S.Mb.BackgroundColor3 = colors.cd
            local mbStroke = S.Mb:FindFirstChildOfClass("UIStroke")
            if mbStroke then mbStroke.Color = colors.br end
            local mbText = S.Mb:FindFirstChildOfClass("TextLabel")
            if mbText then mbText.TextColor3 = colors.tx end
            local mbIcon = S.Mb:FindFirstChildOfClass("ImageLabel")
            if mbIcon then mbIcon.ImageColor3 = colors.tx end
        end

        themeApplying = false
        Feature.showNotification("Theme: " .. theme.Name, true)
    end

    -- Theme cycling
    local currentThemeIndex = 1
    if themesModule and config.CurrentTheme then
        for i, theme in ipairs(themesModule.List) do
            if theme.ID == config.CurrentTheme then
                currentThemeIndex = i
                break
            end
        end
    end

    themeBtn.MouseButton1Click:Connect(function()
        if not themesModule or not themesModule.List or #themesModule.List == 0 then return end
        playSound(Sounds.Click, 0.3)
        currentThemeIndex = currentThemeIndex + 1
        if currentThemeIndex > #themesModule.List then currentThemeIndex = 1 end
        local nextTheme = themesModule.List[currentThemeIndex]
        if nextTheme then applyTheme(nextTheme) end
    end)

    -- ============================================
    -- DIVIDER
    -- ============================================
    dv = Instance.new("Frame")
    dv.Size           = UDim2.new(1, -p*2, 0, 1)
    dv.Position       = UDim2.new(0, p, 0, 51)
    dv.BackgroundColor3 = Co.br
    dv.BorderSizePixel = 0
    dv.Parent         = m

    -- ============================================
    -- UI ELEMENT HELPERS
    -- Uses `currentSc` as the parent scroll frame
    -- ============================================
    local currentSc  = tabScrollFrames[1]
    local currentOrd = 0
    local oD         = {}

    local function nO()
        currentOrd = currentOrd + 1
        return currentOrd
    end

    -- Switch which scroll frame new elements go into
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

    -- Section header
    local function Se(n)
        local s = Instance.new("TextLabel")
        s.Size             = UDim2.new(1, 0, 0, 24)
        s.BackgroundTransparency = 1
        s.Text             = string.upper(n)
        s.TextColor3       = Co.sc
        s.Font             = Enum.Font.GothamBold
        s.TextSize         = 10
        s.TextXAlignment   = Enum.TextXAlignment.Left
        s.LayoutOrder      = nO()
        s:SetAttribute("ThemeTag", "sc")
        s.Parent           = currentSc
    end

    -- Description label
    local function Ds(text, isWarning)
        local desc = Instance.new("TextLabel")
        desc.Size             = UDim2.new(1, -8, 0, 0)
        desc.BackgroundTransparency = 1
        desc.Text             = text
        desc.TextColor3       = isWarning and Color3.fromRGB(255, 200, 100) or Co.ts
        desc.Font             = Enum.Font.GothamMedium
        desc.TextSize         = 11
        desc.TextXAlignment   = Enum.TextXAlignment.Left
        desc.TextWrapped      = true
        desc.TextYAlignment   = Enum.TextYAlignment.Top
        desc.LayoutOrder      = nO()
        desc.AutomaticSize    = Enum.AutomaticSize.Y
        desc.Parent           = currentSc
        local pad = Instance.new("UIPadding", desc)
        pad.PaddingLeft   = UDim.new(0, 14)
        pad.PaddingRight  = UDim.new(0, 14)
        pad.PaddingTop    = UDim.new(0, 2)
        pad.PaddingBottom = UDim.new(0, 6)
        return desc
    end

    -- Button
    local function Bt(n, cl, ico)
        local b = Instance.new("TextButton")
        b.Size           = UDim2.new(1, 0, 0, bH)
        b.BackgroundColor3 = Co.cd
        b.Text           = ""
        b.LayoutOrder    = nO()
        b:SetAttribute("ThemeTag", "cd")
        b.Parent         = currentSc

        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        local bStroke = Instance.new("UIStroke", b)
        bStroke.Color = Co.br

        if ico then
            local ic = Instance.new("ImageLabel")
            ic.Size             = UDim2.new(0, 20, 0, 20)
            ic.Position         = UDim2.new(1, -34, 0.5, -10)
            ic.BackgroundTransparency = 1
            ic.Image            = ico
            ic.ImageColor3      = Co.ts
            ic:SetAttribute("ThemeTag", "ts")
            ic.Parent           = b
        end

        local tx = Instance.new("TextLabel")
        tx.Size           = UDim2.new(1, -50, 1, 0)
        tx.Position       = UDim2.new(0, 14, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text           = n
        tx.TextColor3     = Co.tx
        tx.Font           = Enum.Font.GothamBold
        tx.TextSize       = fS
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx:SetAttribute("ThemeTag", "tx")
        tx.Parent         = b

        b.MouseEnter:Connect(function()  b.BackgroundColor3 = Co.ch end)
        b.MouseLeave:Connect(function()  b.BackgroundColor3 = Co.cd end)
        b.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            cl()
        end)
        return b, tx
    end

    -- Slider
    local function Sl(n, min, max, cK, callback)
        local ca = Instance.new("Frame")
        ca.Size           = UDim2.new(1, 0, 0, bH + 10)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder    = nO()
        ca:SetAttribute("ThemeTag", "cd")
        ca.Parent         = currentSc

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br

        local lb = Instance.new("TextLabel")
        lb.Size           = UDim2.new(0.6, 0, 0, 20)
        lb.Position       = UDim2.new(0, 14, 0, 8)
        lb.BackgroundTransparency = 1
        lb.Text           = n
        lb.TextColor3     = Co.tx
        lb.Font           = Enum.Font.GothamBold
        lb.TextSize       = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb:SetAttribute("ThemeTag", "tx")
        lb.Parent         = ca

        local vL = Instance.new("TextBox")
        vL.Size            = UDim2.new(0, 60, 0, 24)
        vL.Position        = UDim2.new(1, -74, 0, 6)
        vL.BackgroundColor3 = Co.ch
        vL.Text            = tostring(C[cK])
        vL.TextColor3      = Co.tx
        vL.Font            = Enum.Font.GothamBold
        vL.TextSize        = fS
        vL.TextXAlignment  = Enum.TextXAlignment.Center
        vL.ClearTextOnFocus = false
        vL:SetAttribute("ThemeTag", "ch")
        vL.Parent          = ca
        Instance.new("UICorner", vL).CornerRadius = UDim.new(0, 8)

        local sB = Instance.new("Frame")
        sB.Size           = UDim2.new(1, -28, 0, 6)
        sB.Position       = UDim2.new(0, 14, 1, -16)
        sB.BackgroundColor3 = Co.ch
        sB.BorderSizePixel = 0
        sB:SetAttribute("ThemeTag", "ch")
        sB.Parent         = ca
        Instance.new("UICorner", sB).CornerRadius = UDim.new(1, 0)

        local sF = Instance.new("Frame")
        sF.Size           = UDim2.new((C[cK] - min) / (max - min), 0, 1, 0)
        sF.BackgroundColor3 = Co.ac
        sF.BorderSizePixel = 0
        sF:SetAttribute("ThemeTag", "ac")
        sF.Parent         = sB
        Instance.new("UICorner", sF).CornerRadius = UDim.new(1, 0)

        local sN = Instance.new("Frame")
        sN.Size           = UDim2.new(0, 16, 0, 16)
        sN.Position       = UDim2.new((C[cK] - min) / (max - min), -8, 0.5, -8)
        sN.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sN.BorderSizePixel = 0
        sN.Parent         = sB
        Instance.new("UICorner", sN).CornerRadius = UDim.new(1, 0)

        local function updateSlider(val)
            val    = math.clamp(val, min, max)
            C[cK]  = val
            vL.Text = tostring(val)
            local pct = (val - min) / (max - min)
            sF.Size     = UDim2.new(pct, 0, 1, 0)
            sN.Position = UDim2.new(pct, -8, 0.5, -8)
        end

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

        local dG = false

        local function handleSliderInput(inputX)
            local sP = sB.AbsolutePosition.X
            local sW = sB.AbsoluteSize.X
            local pct = math.clamp((inputX - sP) / sW, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            updateSlider(val)
            if callback then callback(val) end
        end

        sB.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = true
                playSound(Sounds.Click, 0.2)
                handleSliderInput(i.Position.X)
            end
        end)
        sB.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dG = false end
        end)
        sN.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = true; playSound(Sounds.Click, 0.2)
            end
        end)
        sN.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dG = false end
        end)
        U.InputChanged:Connect(function(i)
            if dG and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                handleSliderInput(i.Position.X)
            end
        end)

        return ca
    end

    -- Toggle
    local function Tg(n, cK, callback, ico)
        local ca = Instance.new("Frame")
        ca.Size           = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder    = nO()
        ca:SetAttribute("ThemeTag", "cd")
        ca.Parent         = currentSc

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        local caStroke = Instance.new("UIStroke", ca)
        caStroke.Color = Co.br

        if ico then
            local ic = Instance.new("ImageLabel")
            ic.Size             = UDim2.new(0, 22, 0, 22)
            ic.Position         = UDim2.new(0, 14, 0.5, -11)
            ic.BackgroundTransparency = 1
            ic.Image            = "rbxassetid://" .. ico
            ic.ImageColor3      = Co.ts
            ic:SetAttribute("ThemeTag", "ts")
            ic.Parent           = ca
        end

        local lb = Instance.new("TextLabel")
        lb.Size           = UDim2.new(1, -100, 1, 0)
        lb.Position       = UDim2.new(0, ico and 44 or 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text           = n
        lb.TextColor3     = Co.tx
        lb.Font           = Enum.Font.GothamBold
        lb.TextSize       = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb:SetAttribute("ThemeTag", "tx")
        lb.Parent         = ca

        local tg = Instance.new("TextButton")
        tg.Size           = UDim2.new(0, 44, 0, 24)
        tg.Position       = UDim2.new(1, -56, 0.5, -12)
        tg.BackgroundColor3 = C[cK] and Co.ac or Co.ch
        tg.Text           = ""
        tg.Name           = "ToggleBtn"
        tg:SetAttribute("ConfigKey", cK)
        tg.Parent         = ca
        Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)

        local tb = Instance.new("Frame")
        tb.Size           = UDim2.new(0, 20, 0, 20)
        tb.Position       = C[cK] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        tb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tb.Parent         = tg
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)

        tg.MouseButton1Click:Connect(function()
            playSound(Sounds.Toggle, 0.3)
            C[cK] = not C[cK]
            T:Create(tg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                BackgroundColor3 = C[cK] and Co.ac or Co.ch
            }):Play()
            T:Create(tb, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = C[cK] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            }):Play()
            if callback then callback(C[cK]) end
        end)

        return ca
    end

    -- Input box
    local function Ib(n, cK)
        local ca = Instance.new("Frame")
        ca.Size           = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder    = nO()
        ca:SetAttribute("ThemeTag", "cd")
        ca.Parent         = currentSc

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br

        local lb = Instance.new("TextLabel")
        lb.Size           = UDim2.new(0.48, 0, 1, 0)
        lb.Position       = UDim2.new(0, 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text           = n
        lb.TextColor3     = Co.tx
        lb.Font           = Enum.Font.GothamBold
        lb.TextSize       = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb:SetAttribute("ThemeTag", "tx")
        lb.Parent         = ca

        local ib = Instance.new("TextBox")
        ib.Size            = UDim2.new(0.48, -14, 0, 32)
        ib.Position        = UDim2.new(0.52, 0, 0.5, -16)
        ib.BackgroundColor3 = Co.ch
        ib.Text            = ""
        ib.TextColor3      = Co.tx
        ib.Font            = Enum.Font.GothamMedium
        ib.TextSize        = fS
        ib.PlaceholderText = "Enter amount..."
        ib.PlaceholderColor3 = Co.ts
        ib.ClearTextOnFocus = false
        ib.TextXAlignment  = Enum.TextXAlignment.Center
        ib.Parent          = ca
        Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 8)

        if C[cK] and C[cK] > 0 then ib.Text = tostring(C[cK]) end

        ib.FocusLost:Connect(function()
            local v = tonumber(ib.Text)
            if v and v >= 1 then
                C[cK] = v
            elseif v and v <= 0 then
                Feature.showNotification("Amount must be greater than 0!", false)
                playSound(Sounds.Error, 0.3)
                C[cK] = 0; ib.Text = ""
            else
                C[cK] = 0; ib.Text = ""
            end
        end)
    end

    -- Dropdown
    local function Dd(n, op, cK)
        local ca = Instance.new("Frame")
        ca.Size              = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3  = Co.cd
        ca.ClipsDescendants  = false
        ca.LayoutOrder       = nO()
        ca:SetAttribute("ThemeTag", "cd")
        ca.Parent            = currentSc

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br

        local lb = Instance.new("TextLabel")
        lb.Size           = UDim2.new(0.42, 0, 1, 0)
        lb.Position       = UDim2.new(0, 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text           = n
        lb.TextColor3     = Co.tx
        lb.Font           = Enum.Font.GothamBold
        lb.TextSize       = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb:SetAttribute("ThemeTag", "tx")
        lb.Parent         = ca

        local db = Instance.new("TextButton")
        db.Size           = UDim2.new(0.54, -14, 0, 32)
        db.Position       = UDim2.new(0.46, 0, 0.5, -16)
        db.BackgroundColor3 = Co.ch
        db.Text           = ""
        db:SetAttribute("ThemeTag", "ch")
        db.Parent         = ca
        Instance.new("UICorner", db).CornerRadius = UDim.new(0, 8)

        local D = {
            ["Robux Cart1"] = "Crocodile Cart",
            ["Robux Cart2"] = "F1 Cart",
            ["Robux Cart3"] = "Rocket Cart",
            ["Robux Cart4"] = "Jet Plane Cart"
        }

        local dN = D[C[cK]] or C[cK]
        local dbText = Instance.new("TextLabel")
        dbText.Size           = UDim2.new(1, -36, 1, 0)
        dbText.Position       = UDim2.new(0, 10, 0, 0)
        dbText.BackgroundTransparency = 1
        dbText.Text           = dN
        dbText.TextColor3     = Co.tx
        dbText.Font           = Enum.Font.GothamMedium
        dbText.TextSize       = fS - 1
        dbText.TextTruncate   = Enum.TextTruncate.AtEnd
        dbText.TextXAlignment = Enum.TextXAlignment.Left
        dbText:SetAttribute("ThemeTag", "tx")
        dbText.Parent         = db

        local dbIcon = Instance.new("ImageLabel")
        dbIcon.Size             = UDim2.new(0, 16, 0, 16)
        dbIcon.Position         = UDim2.new(1, -22, 0.5, -8)
        dbIcon.BackgroundTransparency = 1
        dbIcon.Image            = "rbxassetid://91662102247848"
        dbIcon.ImageColor3      = Co.ts
        dbIcon:SetAttribute("ThemeTag", "ts")
        dbIcon.Parent           = db

        local dL = Instance.new("Frame")
        dL.Name             = "DropList"
        dL.Size             = UDim2.new(0, 0, 0, 0)
        dL.BackgroundColor3 = Co.cd
        dL.Visible          = false
        dL.ZIndex           = 999
        dL.ClipsDescendants = true
        dL:SetAttribute("ThemeTag", "cd")
        dL.Parent           = m
        Instance.new("UICorner", dL).CornerRadius = UDim.new(0, 10)

        local dLs = Instance.new("UIStroke", dL)
        dLs.Color       = Co.br
        dLs.Thickness   = 1.5
        dLs.Transparency = 0.3

        local dLPad = Instance.new("UIPadding", dL)
        dLPad.PaddingLeft  = UDim.new(0, 4)
        dLPad.PaddingRight = UDim.new(0, 4)
        table.insert(oD, dL)

        local dS = Instance.new("ScrollingFrame")
        dS.Size             = UDim2.new(1, 0, 1, 0)
        dS.BackgroundTransparency = 1
        dS.ScrollBarThickness = 2
        dS.ScrollBarImageColor3 = Co.br
        dS.CanvasSize       = UDim2.new(0, 0, 0, (#op * 40) + (#op - 1) * 2 + 12)
        dS.ZIndex           = 1000
        dS.ClipsDescendants = false
        dS.Parent           = dL

        local dPad = Instance.new("UIPadding", dS)
        dPad.PaddingTop    = UDim.new(0, 6)
        dPad.PaddingBottom = UDim.new(0, 6)

        local dLy = Instance.new("UIListLayout", dS)
        dLy.Padding = UDim.new(0, 2)

        for i, opt in ipairs(op) do
            local ob = Instance.new("TextButton")
            ob.Size             = UDim2.new(1, -8, 0, 40)
            ob.BackgroundColor3 = Co.cd
            ob.Text             = ""
            ob.ZIndex           = 1001
            ob.ClipsDescendants = false
            ob.AutoButtonColor  = false
            ob:SetAttribute("ThemeTag", "cd")
            ob.Parent           = dS
            Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 8)

            local function isSelected()
                if cK == "CartSelect" then
                    local N = {
                        ["Crocodile Cart"] = "Robux Cart1",
                        ["F1 Cart"]        = "Robux Cart2",
                        ["Rocket Cart"]    = "Robux Cart3",
                        ["Jet Plane Cart"] = "Robux Cart4"
                    }
                    return C[cK] == (N[opt] or opt)
                else
                    return C[cK] == opt
                end
            end

            if isSelected() then ob.BackgroundColor3 = Co.al end

            local optText = Instance.new("TextLabel")
            optText.Size           = UDim2.new(1, -24, 1, 0)
            optText.Position       = UDim2.new(0, 12, 0, 0)
            optText.BackgroundTransparency = 1
            optText.Text           = tostring(opt)
            optText.TextColor3     = isSelected() and Co.ac or Co.tx
            optText.Font           = isSelected() and Enum.Font.GothamBold or Enum.Font.GothamMedium
            optText.TextSize       = fS
            optText.TextXAlignment = Enum.TextXAlignment.Left
            optText.ZIndex         = 1002
            optText:SetAttribute("ThemeTag", isSelected() and "ac" or "tx")
            optText.Parent         = ob

            if i < #op then
                local divider = Instance.new("Frame")
                divider.Size           = UDim2.new(1, -28, 0, 1)
                divider.Position       = UDim2.new(0, 14, 1, -1)
                divider.BackgroundColor3 = Co.br
                divider.BackgroundTransparency = 0.6
                divider.BorderSizePixel = 0
                divider.ZIndex         = 1002
                divider:SetAttribute("ThemeTag", "br_divider")
                divider.Parent         = ob
            end

            ob.MouseEnter:Connect(function()
                if not isSelected() then
                    playSound(Sounds.Hover, 0.2)
                    T:Create(ob,      TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
                    T:Create(optText, TweenInfo.new(0.15), {TextColor3 = Co.ac}):Play()
                end
            end)
            ob.MouseLeave:Connect(function()
                if not isSelected() then
                    T:Create(ob,      TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
                    T:Create(optText, TweenInfo.new(0.15), {TextColor3 = Co.tx}):Play()
                end
            end)

            ob.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.3)
                local N = {
                    ["Crocodile Cart"] = "Robux Cart1",
                    ["F1 Cart"]        = "Robux Cart2",
                    ["Rocket Cart"]    = "Robux Cart3",
                    ["Jet Plane Cart"] = "Robux Cart4"
                }
                C[cK] = (cK == "CartSelect") and (N[opt] or opt) or opt
                local dT = (cK == "CartSelect") and (D[C[cK]] or C[cK]) or opt
                dbText.Text = dT

                for _, child in ipairs(dS:GetChildren()) do
                    if child:IsA("TextButton") then
                        local ct = child:FindFirstChildWhichIsA("TextLabel")
                        if ct then
                            local sel = child == ob
                            T:Create(ct,    TweenInfo.new(0.15), {TextColor3 = sel and Co.ac or Co.tx}):Play()
                            ct.Font = sel and Enum.Font.GothamBold or Enum.Font.GothamMedium
                            ct:SetAttribute("ThemeTag", sel and "ac" or "tx")
                            T:Create(child, TweenInfo.new(0.2),  {BackgroundColor3 = sel and Co.al or Co.cd}):Play()
                            child:SetAttribute("ThemeTag", sel and "al" or "cd")
                        end
                    end
                end

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
                local bP  = db.AbsolutePosition
                local bSz = db.AbsoluteSize
                local mP  = m.AbsolutePosition
                local tH  = math.min(#op * 40 + 12, 180)
                dL.Position = UDim2.new(0, bP.X - mP.X, 0, bP.Y - mP.Y + bSz.Y + 4)
                dL.Size     = UDim2.new(0, bSz.X, 0, 0)
                dL.Visible  = true
                T:Create(dL, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, bSz.X, 0, tH)
                }):Play()
            end
        end)
    end

    -- ============================================
    -- CONTENT: TAB 1 — AUTO
    -- ============================================
    useTab(1)

    Se("AUTO CLICK")
    Tg("Auto Click (Brutal Spam)", "AutoClick", function(v)
        Feature.toggleAutoClick(v)
    end)

    -- ============================================
    -- CONTENT: TAB 2 — SETTINGS
    -- ============================================
    useTab(2)

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
                task.cancel(timeout)
                C.Keybind = i.KeyCode
                if tx then tx.Text = "Set Keybind: " .. gKN(C.Keybind) end
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
        if S.G  then S.G:Destroy()  end
        if S.Mb then S.Mb:Destroy() end
    end, "rbxassetid://137032142339509")

    -- ============================================
    -- DRAG SYSTEM
    -- ============================================
    local dS, sPos
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dS   = i.Position
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
            local dt   = i.Position - dS
            local newX = sPos.X.Offset + dt.X
            local newY = sPos.Y.Offset + dt.Y
            m.Position = UDim2.new(sPos.X.Scale, newX, sPos.Y.Scale, newY)

            -- Langsung update pill & sidebar tanpa delay
            local mH   = m.AbsoluteSize.Y
            local pillY = newY + (mH / 2) - (PILL_H / 2)
            if sidebarOpen then
                local sbX = newX - SB_W - SB_GAP
                local sbY = newY + SB_Y_OFFSET
                sidebar.Position = UDim2.new(0, sbX, 0, sbY)
                pill.Position    = UDim2.new(0, sbX - PILL_W + PILL_OVERLAP, 0, pillY)
            else
                pill.Position    = UDim2.new(0, newX - PILL_W + PILL_OVERLAP, 0, pillY)
            end
        end
    end)

    -- ============================================
    -- PARENT GUI & ANIMATE IN
    -- ============================================
    m.Position = UDim2.new(1, 20, 0.5, -h/2)
    m.BackgroundTransparency = 0

    pcall(function() g.Parent = game:GetService("CoreGui") end)
    if not g.Parent then g.Parent = L:WaitForChild("PlayerGui") end

    S.G = g

    -- Sync pill & sidebar setiap kali m bergerak (drag, animasi, dll)
    m:GetPropertyChangedSignal("AbsolutePosition"):Connect(syncPositions)
    m:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncPositions)

    -- Initial position sync setelah GUI di-parent
    task.wait()
    syncPositions()

    -- ============================================
    -- MOBILE BUTTON
    -- ============================================
    if isMobile then
        local BUTTON_TRANSPARENCY = 0.10

        local mB = Instance.new("Frame")
        mB.Size           = UDim2.new(0, 100, 0, 32)
        mB.Position       = UDim2.new(0, 10, 0, 10)
        mB.BackgroundColor3 = Co.cd
        mB.BackgroundTransparency = BUTTON_TRANSPARENCY
        mB.BorderSizePixel = 0
        mB.Parent         = g
        Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 16)

        local mStroke = Instance.new("UIStroke", mB)
        mStroke.Color       = Co.br
        mStroke.Thickness   = 1.5
        mStroke.Transparency = 0.3

        local mI = Instance.new("ImageLabel")
        mI.Size             = UDim2.new(0, 20, 0, 20)
        mI.Position         = UDim2.new(0, 8, 0.5, -10)
        mI.BackgroundTransparency = 1
        mI.Image            = "rbxassetid://114167695335193"
        mI.ImageColor3      = Co.tx
        mI.Parent           = mB

        local btnText = Instance.new("TextLabel")
        btnText.Size          = UDim2.new(1, -36, 1, 0)
        btnText.Position      = UDim2.new(0, 32, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text          = "Hide"
        btnText.TextColor3    = Co.tx
        btnText.Font          = Enum.Font.GothamBold
        btnText.TextSize      = 15
        btnText.TextXAlignment = Enum.TextXAlignment.Center
        btnText.TextYAlignment = Enum.TextYAlignment.Center
        btnText.Parent        = mB

        local mT = Instance.new("TextButton")
        mT.Size             = UDim2.new(1, 0, 1, 0)
        mT.BackgroundTransparency = 1
        mT.Text             = ""
        mT.Parent           = mB

        local dragging, dragStart, startPos, wasDragged = false, nil, nil, false

        mT.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = mB.Position
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
                    T:Create(mB, TweenInfo.new(0.1,  Enum.EasingStyle.Quad), {Size = UDim2.new(0, 95, 0, 30)}):Play()
                    task.wait(0.1)
                    T:Create(mB, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size = UDim2.new(0, 100, 0, 32)}):Play()
                end
            end
        end)

        U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then wasDragged = true end
                mB.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        mT.MouseEnter:Connect(function()
            if not dragging then
                T:Create(mB,     TweenInfo.new(0.2), {BackgroundColor3 = Co.ch, BackgroundTransparency = BUTTON_TRANSPARENCY - 0.05}):Play()
                T:Create(mStroke,TweenInfo.new(0.2), {Color = Co.ac}):Play()
            end
        end)
        mT.MouseLeave:Connect(function()
            T:Create(mB,     TweenInfo.new(0.2), {BackgroundColor3 = Co.cd, BackgroundTransparency = BUTTON_TRANSPARENCY}):Play()
            T:Create(mStroke,TweenInfo.new(0.2), {Color = Co.br}):Play()
        end)

        S.Mb = mB

        mB.Position = UDim2.new(0, -110, 0, 10)
        mB.BackgroundTransparency = 1
        btnText.TextTransparency  = 1
        mI.ImageTransparency      = 1
        mStroke.Transparency      = 1

        task.wait(0.3)
        T:Create(mB,      TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = BUTTON_TRANSPARENCY}):Play()
        T:Create(btnText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        T:Create(mI,      TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
        T:Create(mStroke, TweenInfo.new(0.4), {Transparency = 0.3}):Play()
    end

    task.wait(0.1)

    -- Slide main frame in
    T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    }):Play()

    -- Sync pill setelah animasi masuk selesai
    task.delay(0.6, syncPositions)

    task.wait(0.3)

    -- Apply starting theme
    if themesModule and themesModule.List and #themesModule.List > 0 then
        local startTheme = themesModule.getTheme(config.CurrentTheme) or themesModule.List[1]
        applyTheme(startTheme)
    end

    task.wait(0.2)
    Feature.showNotification("SynceHub initialized successfully!", true)
end

return TabContent
