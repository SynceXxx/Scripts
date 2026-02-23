-- Sidebar.lua
-- SynceHub - Sidebar untuk Potato Idle
-- Sidebar child dari g (ScreenGui), posisi sync otomatis via AbsolutePosition listener

local Sidebar = {}

local T = game:GetService("TweenService")

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

-- Tab definitions
local tabDefs = {
    { name = "Home",     icon = "rbxassetid://121784593769436" },
    { name = "Player",   icon = "rbxassetid://96643249108385"  },
    { name = "Themes",   icon = "rbxassetid://104337285697355" },
    { name = "Settings", icon = "rbxassetid://140063609720900" },
}

-- ============================================
-- CREATE SIDEBAR
-- ============================================
function Sidebar.create(g, m, Co, onTabSwitch)

    local activeTabIndex = 1

    -- ============================================
    -- SIDEBAR PANEL (child dari g)
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
    tabBtnContainer.Name                   = "TabBtnContainer"
    tabBtnContainer.Size                   = UDim2.new(1, -8, 0, (#tabDefs * (SB_BTN_SIZE + SB_BTN_GAP)) - SB_BTN_GAP)
    tabBtnContainer.Position               = UDim2.new(0, 4, 0, SB_BTN_TOP)
    tabBtnContainer.BackgroundTransparency = 1
    tabBtnContainer.ZIndex                 = 3
    tabBtnContainer.Parent                 = sidebar

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
        tabIcon.Size                   = UDim2.new(0, 22, 0, 22)
        tabIcon.Position               = UDim2.new(0.5, -11, 0.5, -11)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image                  = def.icon
        tabIcon.ImageColor3            = isActive and Co.tx or Co.ts
        tabIcon.ZIndex                 = 5
        tabIcon:SetAttribute("ThemeTag", isActive and "tx" or "ts")
        tabIcon.Parent                 = tabBtn

        local tabScale = Instance.new("UIScale")
        tabScale.Scale  = 1
        tabScale.Parent = tabBtn

        tabButtons[i] = { btn = tabBtn, icon = tabIcon, scale = tabScale }
    end

    -- ============================================
    -- SYNC POSISI — ikut AbsolutePosition m
    -- Dipanggil setiap kali m bergerak
    -- ============================================
    local function syncPositions()
        if not m or not m.Parent then return end
        local mPos  = m.AbsolutePosition
        local mSize = m.AbsoluteSize
        sidebar.Position = UDim2.new(0, mPos.X - SB_W - SB_GAP, 0, mPos.Y + SB_Y_OFFSET)
        sidebar.Size     = UDim2.new(0, SB_W, 0, mSize.Y - SB_Y_OFFSET * 2)
    end

    -- Listener: setiap kali m pindah (drag, animate, resize), sidebar ikut
    m:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if sidebar.Visible then
            syncPositions()
        end
    end)

    m:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if sidebar.Visible then
            syncPositions()
        end
    end)

    -- ============================================
    -- LOCK / UNLOCK INTERAKSI (saat confirm dialog)
    -- ============================================
    local function lockInteraction()
        sidebar.Active = false
        for _, tb in ipairs(tabButtons) do
            tb.btn.Active = false
        end
    end

    local function unlockInteraction()
        sidebar.Active = true
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
    -- RETURN API
    -- ============================================
    return {
        sidebar           = sidebar,
        sidebarStroke     = sidebarStroke,
        tabButtons        = tabButtons,
        tabDefs           = tabDefs,
        tabCount          = #tabDefs,
        syncPositions     = syncPositions,
        lockInteraction   = lockInteraction,
        unlockInteraction = unlockInteraction,
        getSidebarOpen    = function() return true end,
        getActiveTab      = function() return activeTabIndex end,
        -- Stubs
        showPill      = function() end,
        hidePill      = function() end,
        toggleSidebar = function() end,
    }
end

return Sidebar
