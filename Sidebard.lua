-- Sidebar.lua
-- SynceHub - Sidebar & Pill System for Potato Idle

local Sidebar = {}

local T = game:GetService("TweenService")
local U = game:GetService("UserInputService")

local Sounds = {
    Click = "rbxassetid://6895079853",
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

-- ============================================
-- CONSTANTS
-- ============================================
local SB_W        = 48
local SB_GAP      = 6
local SB_Y_OFFSET = 10
local SB_BTN_SIZE = 40
local SB_BTN_GAP  = 8
local SB_BTN_TOP  = 12

local PILL_W      = 22
local PILL_H      = 72
local PILL_OVERLAP = -4

-- Tab definitions — tambah/kurangi di sini
local tabDefs = {
    { name = "Home",     icon = "rbxassetid://121784593769436" },
    { name = "Player",   icon = "rbxassetid://96643249108385"  },
    { name = "Themes",   icon = "rbxassetid://104337285697355" },
    { name = "Settings", icon = "rbxassetid://140063609720900" },
}

-- ============================================
-- CREATE SIDEBAR
-- Params:
--   g   = ScreenGui
--   m   = Main Frame
--   Co  = Color table
--   onTabSwitch(index) = callback saat tab diganti
-- Returns:
--   {
--     sidebar, pill, tabButtons, tabDefs,
--     syncPositions, toggleSidebar,
--     sidebarOpen (getter), activeTabIndex (getter),
--     showPill, hidePill,
--     lockInteraction, unlockInteraction,
--   }
-- ============================================
function Sidebar.create(g, m, Co, onTabSwitch)

    local sidebarOpen      = false
    local sidebarAnimating = false
    local activeTabIndex   = 1

    -- ============================================
    -- SIDEBAR PANEL
    -- ============================================
    local sidebar = Instance.new("Frame")
    sidebar.Name             = "Sidebar"
    sidebar.Size             = UDim2.new(0, SB_W, 0, 400)
    sidebar.Position         = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundColor3 = Co.bg
    sidebar.BorderSizePixel  = 0
    sidebar.ZIndex           = 1
    sidebar.Visible          = false
    sidebar:SetAttribute("ThemeTag", "bg")
    sidebar.Parent           = g
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

    local sidebarStroke = Instance.new("UIStroke", sidebar)
    sidebarStroke.Color        = Co.br
    sidebarStroke.Thickness    = 1.5
    sidebarStroke.Transparency = 0.3
    sidebarStroke:SetAttribute("ThemeTag", "br")

    -- Tab buttons container
    local tabBtnContainer = Instance.new("Frame")
    tabBtnContainer.Name                  = "TabBtnContainer"
    tabBtnContainer.Size                  = UDim2.new(1, -8, 0, (#tabDefs * (SB_BTN_SIZE + SB_BTN_GAP)) - SB_BTN_GAP)
    tabBtnContainer.Position              = UDim2.new(0, 4, 0, SB_BTN_TOP)
    tabBtnContainer.BackgroundTransparency = 1
    tabBtnContainer.ZIndex                = 3
    tabBtnContainer.Parent                = sidebar

    local tabBtnLayout = Instance.new("UIListLayout")
    tabBtnLayout.Padding             = UDim.new(0, SB_BTN_GAP)
    tabBtnLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    tabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabBtnLayout.Parent              = tabBtnContainer

    -- Tab icon buttons
    local tabButtons = {}
    for i, def in ipairs(tabDefs) do
        local isActive = i == activeTabIndex

        local tabWrap = Instance.new("Frame")
        tabWrap.Size                   = UDim2.new(1, 0, 0, SB_BTN_SIZE)
        tabWrap.BackgroundTransparency = 1
        tabWrap.BorderSizePixel        = 0
        tabWrap.ZIndex                 = 3
        tabWrap.LayoutOrder            = i
        tabWrap.Parent                 = tabBtnContainer

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size             = UDim2.new(1, 0, 1, 0)
        tabBtn.AnchorPoint      = Vector2.new(0.5, 0.5)
        tabBtn.Position         = UDim2.new(0.5, 0, 0.5, 0)
        tabBtn.BackgroundColor3 = isActive and Co.ac or Co.ch
        tabBtn.Text             = ""
        tabBtn.ZIndex           = 4
        tabBtn:SetAttribute("ThemeTag", isActive and "ac" or "ch")
        tabBtn.Parent           = tabWrap
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size                  = UDim2.new(0, 22, 0, 22)
        tabIcon.Position              = UDim2.new(0.5, -11, 0.5, -11)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image                 = def.icon
        tabIcon.ImageColor3           = isActive and Co.tx or Co.ts
        tabIcon.ZIndex                = 5
        tabIcon:SetAttribute("ThemeTag", isActive and "tx" or "ts")
        tabIcon.Parent                = tabBtn

        local tabScale = Instance.new("UIScale")
        tabScale.Scale  = 1
        tabScale.Parent = tabBtn

        tabButtons[i] = { btn = tabBtn, icon = tabIcon, scale = tabScale }
    end

    -- ============================================
    -- PILL HANDLE
    -- ============================================
    local pill = Instance.new("Frame")
    pill.Name             = "PillHandle"
    pill.Size             = UDim2.new(0, PILL_W, 0, PILL_H)
    pill.Position         = UDim2.new(0, 0, 0, 0)
    pill.BackgroundColor3 = Co.bg
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 3
    pill.Visible          = false
    pill:SetAttribute("ThemeTag", "bg")
    pill.Parent           = g
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0.5, 0)

    local pillStroke = Instance.new("UIStroke", pill)
    pillStroke.Color        = Co.br
    pillStroke.Thickness    = 1.5
    pillStroke.Transparency = 0.3
    pillStroke:SetAttribute("ThemeTag", "br")

    local pillLabel = Instance.new("TextLabel")
    pillLabel.Size                  = UDim2.new(0, PILL_H - 8, 0, PILL_W - 4)
    pillLabel.AnchorPoint           = Vector2.new(0.5, 0.5)
    pillLabel.Position              = UDim2.new(0.5, 0, 0.5, 0)
    pillLabel.BackgroundTransparency = 1
    pillLabel.Text                  = "OPEN"
    pillLabel.TextColor3            = Co.tx
    pillLabel.Font                  = Enum.Font.GothamBold
    pillLabel.TextSize              = 10
    pillLabel.Rotation              = 90
    pillLabel.ZIndex                = 4
    pillLabel:SetAttribute("ThemeTag", "tx")
    pillLabel.Parent                = pill

    local pillBtn = Instance.new("TextButton")
    pillBtn.Size                  = UDim2.new(1, 0, 1, 0)
    pillBtn.BackgroundTransparency = 1
    pillBtn.Text                  = ""
    pillBtn.ZIndex                = 5
    pillBtn.Parent                = pill

    -- ============================================
    -- POSITION SYNC
    -- ============================================
    local function syncPositions()
        if not m or not m.Parent then return end
        local mX   = m.AbsolutePosition.X
        local mY   = m.AbsolutePosition.Y
        local mH   = m.AbsoluteSize.Y
        local pillY = mY + (mH / 2) - (PILL_H / 2)

        if sidebarOpen then
            local sbX = mX - SB_W - SB_GAP
            local sbY = mY + SB_Y_OFFSET
            local sbH = mH - SB_Y_OFFSET * 2
            sidebar.Position = UDim2.new(0, sbX, 0, sbY)
            sidebar.Size     = UDim2.new(0, SB_W, 0, sbH)
            pill.Position    = UDim2.new(0, sbX - PILL_W + PILL_OVERLAP, 0, pillY)
        else
            pill.Position = UDim2.new(0, mX - PILL_W + PILL_OVERLAP, 0, pillY)
        end
    end

    -- ============================================
    -- PILL STATE (deklarasi di sini biar visibility handler bisa akses)
    -- ============================================
    local pillShouldShow = false
    local pillShowId     = 0
    local pillHideThread = nil

    -- Sync visibility pill & sidebar dengan m
    m:GetPropertyChangedSignal("Visible"):Connect(function()
        if not m.Visible then
            pill.Visible    = false
            sidebar.Visible = false
        else
            if pillShouldShow then
                task.wait()
                task.wait()
                local mX    = m.AbsolutePosition.X
                local mY    = m.AbsolutePosition.Y
                local mH    = m.AbsoluteSize.Y
                local pillY = mY + (mH / 2) - (PILL_H / 2)
                pill.Position = UDim2.new(0, mX - PILL_W + PILL_OVERLAP, 0, pillY)
                pill.Visible  = true
                pill.ZIndex   = 3
            end
            sidebar.Visible = sidebarOpen
        end
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

            sidebar.Position             = UDim2.new(0, mX - PILL_W, 0, sbY)
            sidebar.Size                 = UDim2.new(0, SB_W, 0, sbH)
            sidebar.BackgroundTransparency = 0
            sidebar.Visible              = true

            T:Create(sidebar, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, sbX, 0, sbY),
            }):Play()
            T:Create(pill, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, sbX - PILL_W + PILL_OVERLAP, 0, pillY)
            }):Play()

            task.delay(0.15, function()
                T:Create(pillLabel, TweenInfo.new(0.12), {TextTransparency = 1}):Play()
                task.wait(0.12)
                pillLabel.Text = "CLOSE"
                T:Create(pillLabel, TweenInfo.new(0.12), {TextTransparency = 0}):Play()
            end)
        else
            local targetPillX = mX - PILL_W + PILL_OVERLAP

            T:Create(sidebar, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(0, mX - PILL_W, 0, sidebar.Position.Y.Offset),
            }):Play()
            T:Create(pill, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.new(0, targetPillX, 0, pillY)
            }):Play()

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

    -- ============================================
    -- PILL ANIMASI MUNCUL / SEMBUNYI
    -- ============================================
    local function showPill()
        -- Cancel pending hide
        if pillHideThread then
            task.cancel(pillHideThread)
            pillHideThread = nil
        end

        pillShouldShow = true
        pillShowId     = pillShowId + 1
        local myId     = pillShowId

        -- Tunggu 2 frame biar AbsoluteSize m sudah final
        task.wait()
        task.wait()

        -- Kalau sudah di-cancel oleh showPill baru atau hidePill, skip
        if myId ~= pillShowId then return end
        if not pillShouldShow then return end

        local mX    = m.AbsolutePosition.X
        local mY    = m.AbsolutePosition.Y
        local mH    = m.AbsoluteSize.Y
        local pillY = mY + (mH / 2) - (PILL_H / 2)
        local finalPos = UDim2.new(0, mX - PILL_W + PILL_OVERLAP, 0, pillY)

        -- Start dari dalam tepi kanan main frame
        pill.Position = UDim2.new(0, mX + 10, 0, pillY)
        pill.ZIndex   = 1
        pill.Visible  = true

        T:Create(pill, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = finalPos
        }):Play()

        task.delay(0.35, function()
            if myId == pillShowId then
                pill.ZIndex = 3
            end
        end)
    end

    local function hidePill()
        pillShouldShow = false
        pillShowId     = pillShowId + 1  -- invalidate showPill yang pending

        -- Cancel pending hide thread sebelumnya
        if pillHideThread then
            task.cancel(pillHideThread)
        end

        local mX = m.AbsolutePosition.X
        T:Create(pill, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0, mX + 10, pill.Position.Y.Scale, pill.Position.Y.Offset)
        }):Play()
        pillHideThread = task.delay(0.25, function()
            pill.Visible    = false
            sidebar.Visible = false
            pillHideThread  = nil
        end)
    end

    -- ============================================
    -- LOCK / UNLOCK INTERAKSI (saat confirm dialog)
    -- ============================================
    local function lockInteraction()
        pillBtn.Active  = false
        sidebar.Active  = false
        for _, tb in ipairs(tabButtons) do
            tb.btn.Active = false
        end
    end

    local function unlockInteraction()
        pillBtn.Active  = true
        sidebar.Active  = true
        for _, tb in ipairs(tabButtons) do
            tb.btn.Active = true
        end
    end

    -- ============================================
    -- TAB SWITCHING
    -- ============================================
    local tabSwitching = false
    local function switchTab(index)
        if tabSwitching then return end
        if index == activeTabIndex then return end
        tabSwitching   = true
        activeTabIndex = index
        playSound(Sounds.Click, 0.3)

        if onTabSwitch then onTabSwitch(index) end

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

        task.delay(0.2, function() tabSwitching = false end)
    end

    -- ============================================
    -- CONNECT TAB BUTTONS
    -- ============================================
    for i, tb in ipairs(tabButtons) do
        tb.btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                T:Create(tb.scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Scale = 0.88 }):Play()
            end
        end)
        tb.btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                T:Create(tb.scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
            end
        end)
        tb.btn.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
        tb.btn.MouseEnter:Connect(function()
            if activeTabIndex ~= i then
                T:Create(tb.btn, TweenInfo.new(0.15), { BackgroundColor3 = Co.ch }):Play()
            end
        end)
        tb.btn.MouseLeave:Connect(function()
            if activeTabIndex ~= i then
                T:Create(tb.btn, TweenInfo.new(0.15), { BackgroundColor3 = Co.ch }):Play()
            else
                T:Create(tb.btn, TweenInfo.new(0.15), { BackgroundColor3 = Co.ac }):Play()
            end
        end)
    end

    -- ============================================
    -- PILL HOVER + CLICK
    -- ============================================
    pillBtn.MouseButton1Click:Connect(toggleSidebar)
    pillBtn.MouseEnter:Connect(function()
        T:Create(pill,       TweenInfo.new(0.15), { BackgroundColor3 = Co.ch }):Play()
        T:Create(pillStroke, TweenInfo.new(0.15), { Color = Co.ac }):Play()
    end)
    pillBtn.MouseLeave:Connect(function()
        T:Create(pill,       TweenInfo.new(0.15), { BackgroundColor3 = Co.bg }):Play()
        T:Create(pillStroke, TweenInfo.new(0.15), { Color = Co.br }):Play()
    end)

    -- ============================================
    -- RETURN API
    -- ============================================
    return {
        sidebar          = sidebar,
        sidebarStroke    = sidebarStroke,
        pill             = pill,
        pillStroke       = pillStroke,
        pillLabel        = pillLabel,
        pillBtn          = pillBtn,
        tabButtons       = tabButtons,
        tabDefs          = tabDefs,
        tabCount         = #tabDefs,
        syncPositions    = syncPositions,
        toggleSidebar    = toggleSidebar,
        showPill         = showPill,
        hidePill         = hidePill,
        lockInteraction  = lockInteraction,
        unlockInteraction = unlockInteraction,
        getSidebarOpen   = function() return sidebarOpen end,
        getActiveTab     = function() return activeTabIndex end,
    }
end

return Sidebar
