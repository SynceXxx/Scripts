-- SynceHub - UI Creation and Tab Content
-- Layout: Sidebar (logo + tabs) | Topbar (search, minimize, close) | Card grid | Footer

local TabContent = {}

local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local R = game:GetService("RunService")
local Stats = game:GetService("Stats")
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

local function corner(inst, r)
    local c = Instance.new("UICorner", inst)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke", inst)
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName, gameName)
    C = config
    S = state
    Feature = featureModule
    gKN = getKeyName

    if S.G then S.G:Destroy() end

    local sS = workspace.CurrentCamera.ViewportSize
    local w = isMobile and math.min(560, sS.X - 24) or 640
    local h = isMobile and math.min(360, sS.Y - 60) or 440
    local sideW = isMobile and 130 or 150
    local topH = 56
    local footH = 30
    local rowH = isMobile and 40 or 38
    local fS = isMobile and 13 or 13
    local twoCol = w >= 560

    -- Color scheme (navy / blue)
    local Co = {
        bg     = Color3.fromRGB(21, 29, 43),   -- window
        side   = Color3.fromRGB(16, 23, 35),   -- sidebar
        card   = Color3.fromRGB(26, 36, 52),   -- section card
        row    = Color3.fromRGB(33, 45, 66),   -- row inside card
        rowH   = Color3.fromRGB(40, 54, 78),   -- row hover
        ac     = Color3.fromRGB(56, 120, 240), -- accent blue
        acH    = Color3.fromRGB(78, 140, 255),
        acDim  = Color3.fromRGB(28, 52, 96),   -- active tab bg
        tx     = Color3.fromRGB(240, 244, 250),
        ts     = Color3.fromRGB(140, 152, 175),
        br     = Color3.fromRGB(46, 60, 84),
        off    = Color3.fromRGB(52, 64, 88),
        warn   = Color3.fromRGB(88, 101, 242)
    }

    -- ScreenGui
    local g = Instance.new("ScreenGui")
    g.Name = "SynceHub"
    g.ResetOnSpawn = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main window
    local m = Instance.new("Frame")
    m.Name = "Main"
    m.Size = UDim2.new(0, w, 0, h)
    m.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3 = Co.bg
    m.BorderSizePixel = 0
    m.ClipsDescendants = true
    m.Parent = g
    corner(m, 14)
    stroke(m, Co.br, 1, 0.4)

    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 30, 1, 30)
    sh.Position = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxassetid://5554236805"
    sh.ImageColor3 = Color3.new(0, 0, 0)
    sh.ImageTransparency = 0.35
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(23, 23, 277, 277)
    sh.ZIndex = 0
    sh.Parent = m

    -- ============================================
    -- SIDEBAR
    -- ============================================
    local side = Instance.new("Frame")
    side.Name = "Sidebar"
    side.Size = UDim2.new(0, sideW, 1, 0)
    side.BackgroundColor3 = Co.side
    side.BorderSizePixel = 0
    side.Parent = m

    -- square off the right side of the sidebar so only outer corners are rounded
    corner(side, 14)
    local sideFill = Instance.new("Frame")
    sideFill.Size = UDim2.new(0, 14, 1, 0)
    sideFill.Position = UDim2.new(1, -14, 0, 0)
    sideFill.BackgroundColor3 = Co.side
    sideFill.BorderSizePixel = 0
    sideFill.Parent = side

    -- Logo block
    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(1, 0, 0, 78)
    logo.BackgroundTransparency = 1
    logo.Parent = side

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.Size = UDim2.new(0, 34, 0, 34)
    logoIcon.Position = UDim2.new(0, 12, 0, 14)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Image = "rbxassetid://118025272389341"
    logoIcon.ImageColor3 = Co.tx
    logoIcon.Parent = logo

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 20)
    title.Position = UDim2.new(0, 54, 0, 12)
    title.BackgroundTransparency = 1
    title.RichText = true
    title.Text = "Synce<font color=\"#3A7EF5\">Hub</font>"
    title.TextColor3 = Co.tx
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = logo

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -60, 0, 30)
    subtitle.Position = UDim2.new(0, 54, 0, 32)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = gameName or "Coordinate Tracker"
    subtitle.TextColor3 = Co.ts
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextWrapped = true
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Top
    subtitle.Parent = logo

    local logoDiv = Instance.new("Frame")
    logoDiv.Size = UDim2.new(1, -24, 0, 1)
    logoDiv.Position = UDim2.new(0, 12, 0, 78)
    logoDiv.BackgroundColor3 = Co.br
    logoDiv.BackgroundTransparency = 0.4
    logoDiv.BorderSizePixel = 0
    logoDiv.Parent = side

    -- Tab list
    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(1, -16, 1, -(78 + 12 + footH))
    tabList.Position = UDim2.new(0, 8, 0, 90)
    tabList.BackgroundTransparency = 1
    tabList.Parent = side

    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- ============================================
    -- TOP BAR
    -- ============================================
    local top = Instance.new("Frame")
    top.Name = "TopBar"
    top.Size = UDim2.new(1, -sideW, 0, topH)
    top.Position = UDim2.new(0, sideW, 0, 0)
    top.BackgroundTransparency = 1
    top.Parent = m

    local btnW = 44
    local search = Instance.new("Frame")
    search.Size = UDim2.new(1, -(12 + 12 + btnW * 2 + 8 + 8), 0, 36)
    search.Position = UDim2.new(0, 12, 0, 10)
    search.BackgroundColor3 = Co.card
    search.BorderSizePixel = 0
    search.Parent = top
    corner(search, 10)
    stroke(search, Co.br, 1, 0.3)

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 12, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://3926305904"
    searchIcon.ImageRectOffset = Vector2.new(964, 324)
    searchIcon.ImageRectSize = Vector2.new(36, 36)
    searchIcon.ImageColor3 = Co.ts
    searchIcon.Parent = search

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -46, 1, 0)
    searchBox.Position = UDim2.new(0, 36, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search"
    searchBox.PlaceholderColor3 = Co.ts
    searchBox.TextColor3 = Co.tx
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.ClearTextOnFocus = false
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = search

    local function topBtn(text, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, btnW, 0, 36)
        b.Position = UDim2.new(1, x, 0, 10)
        b.BackgroundColor3 = Co.card
        b.Text = text
        b.TextColor3 = Co.tx
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16
        b.AutoButtonColor = false
        b.Parent = top
        corner(b, 10)
        stroke(b, Co.br, 1, 0.3)
        b.MouseEnter:Connect(function()
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.rowH}):Play()
        end)
        b.MouseLeave:Connect(function()
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.card}):Play()
        end)
        return b
    end

    local clBtn = topBtn("×", -12 - btnW)
    local cb = topBtn("−", -12 - btnW * 2 - 8)

    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -sideW, 1, -(topH + footH))
    content.Position = UDim2.new(0, sideW, 0, topH)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = m

    -- ============================================
    -- FOOTER
    -- ============================================
    local foot = Instance.new("Frame")
    foot.Name = "Footer"
    foot.Size = UDim2.new(1, 0, 0, footH)
    foot.Position = UDim2.new(0, 0, 1, -footH)
    foot.BackgroundColor3 = Co.side
    foot.BorderSizePixel = 0
    foot.Parent = m

    local footDiv = Instance.new("Frame")
    footDiv.Size = UDim2.new(1, 0, 0, 1)
    footDiv.BackgroundColor3 = Co.br
    footDiv.BackgroundTransparency = 0.4
    footDiv.BorderSizePixel = 0
    footDiv.Parent = foot

    local footText = Instance.new("TextLabel")
    footText.Size = UDim2.new(1, 0, 1, 0)
    footText.BackgroundTransparency = 1
    footText.Text = ""
    footText.TextColor3 = Co.ac
    footText.Font = Enum.Font.Gotham
    footText.TextSize = 12
    footText.Parent = foot

    local function refreshFooter(fps, ping)
        footText.Text = string.format(
            "%s  ·  FPS %d  ·  %d ms  ·  %s hide  ·  %s",
            gameName or "Coordinate Tracker",
            fps, ping, gKN(C.Keybind), version
        )
    end
    refreshFooter(0, 0)

    -- FPS / ping tracking
    do
        local frames, acc = 0, 0
        S.Co.FpsTrack = R.RenderStepped:Connect(function(dt)
            frames = frames + 1
            acc = acc + dt
            if acc >= 0.5 then
                local fps = math.floor(frames / acc + 0.5)
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                refreshFooter(fps, ping)
                frames, acc = 0, 0
            end
        end)
    end

    -- ============================================
    -- TAB SYSTEM
    -- ============================================
    local tabs = {}        -- name -> { btn, page, cols, searchables }
    local currentTab = nil
    local searchables = {} -- { row=frame, label=string, card=frame, tab=name }

    local function setTab(name)
        if currentTab == name then return end
        for n, t in pairs(tabs) do
            local active = (n == name)
            t.page.Visible = active
            T:Create(t.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = active and Co.acDim or Co.side,
                BackgroundTransparency = active and 0 or 1
            }):Play()
            T:Create(t.icon, TweenInfo.new(0.15), {ImageColor3 = active and Co.acH or Co.ts}):Play()
            T:Create(t.label, TweenInfo.new(0.15), {TextColor3 = active and Co.tx or Co.ts}):Play()
            t.bar.Visible = active
        end
        currentTab = name
    end

    local function Tab(name, iconId)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Co.side
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = #tabList:GetChildren()
        btn.Parent = tabList
        corner(btn, 10)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 0, 22)
        bar.Position = UDim2.new(0, 0, 0.5, -11)
        bar.BackgroundColor3 = Co.ac
        bar.BorderSizePixel = 0
        bar.Visible = false
        bar.Parent = btn
        corner(bar, 2)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 12, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. iconId
        icon.ImageColor3 = Co.ts
        icon.Parent = btn

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -44, 1, 0)
        label.Position = UDim2.new(0, 40, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Co.ts
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        -- page: scrolling frame with columns
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Co.br
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = content

        local pad = Instance.new("UIPadding", page)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.PaddingTop = UDim.new(0, 2)
        pad.PaddingBottom = UDim.new(0, 12)

        local cols = {}
        local colCount = twoCol and 2 or 1
        local gap = 10
        for i = 1, colCount do
            local col = Instance.new("Frame")
            col.BackgroundTransparency = 1
            col.AutomaticSize = Enum.AutomaticSize.Y
            if colCount == 2 then
                col.Size = UDim2.new(0.5, -gap/2, 0, 0)
                col.Position = UDim2.new(i == 1 and 0 or 0.5, i == 1 and 0 or gap/2, 0, 0)
            else
                col.Size = UDim2.new(1, 0, 0, 0)
            end
            col.Parent = page
            local ly = Instance.new("UIListLayout", col)
            ly.Padding = UDim.new(0, gap)
            ly.SortOrder = Enum.SortOrder.LayoutOrder
            cols[i] = col
        end

        tabs[name] = { btn = btn, page = page, cols = cols, icon = icon, label = label, bar = bar }

        btn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.3)
            setTab(name)
        end)
        btn.MouseEnter:Connect(function()
            if currentTab ~= name then
                T:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.6, BackgroundColor3 = Co.card}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= name then
                T:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end
        end)

        return name
    end

    -- ============================================
    -- CARD + ROW BUILDERS
    -- ============================================
    local cardOrder = 0

    -- Card(tabName, title, columnIndex) -> body frame to put rows in
    local function Card(tabName, title, colIdx)
        local t = tabs[tabName]
        local col = t.cols[math.min(colIdx or 1, #t.cols)]

        cardOrder = cardOrder + 1
        local card = Instance.new("Frame")
        card.Name = "Card_" .. title
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = Co.card
        card.BorderSizePixel = 0
        card.LayoutOrder = cardOrder
        card.Parent = col
        corner(card, 12)
        stroke(card, Co.br, 1, 0.5)

        local head = Instance.new("Frame")
        head.Size = UDim2.new(1, 0, 0, 38)
        head.BackgroundTransparency = 1
        head.Parent = card

        local ht = Instance.new("TextLabel")
        ht.Size = UDim2.new(1, -50, 1, 0)
        ht.Position = UDim2.new(0, 14, 0, 0)
        ht.BackgroundTransparency = 1
        ht.Text = title
        ht.TextColor3 = Co.tx
        ht.Font = Enum.Font.GothamBold
        ht.TextSize = 14
        ht.TextXAlignment = Enum.TextXAlignment.Left
        ht.Parent = head

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = UDim2.new(1, -24, 0.5, -5)
        dot.BackgroundColor3 = Co.ac
        dot.BorderSizePixel = 0
        dot.Rotation = 45
        dot.Parent = head
        corner(dot, 2)

        local body = Instance.new("Frame")
        body.Name = "Body"
        body.Size = UDim2.new(1, -16, 0, 0)
        body.Position = UDim2.new(0, 8, 0, 38)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.BackgroundTransparency = 1
        body.Parent = card

        local bl = Instance.new("UIListLayout", body)
        bl.Padding = UDim.new(0, 6)
        bl.SortOrder = Enum.SortOrder.LayoutOrder

        local bp = Instance.new("UIPadding", body)
        bp.PaddingBottom = UDim.new(0, 8)

        body:SetAttribute("Tab", tabName)
        body:SetAttribute("Card", true)
        return body, card
    end

    local rowOrder = 0
    local function baseRow(body, height, label)
        rowOrder = rowOrder + 1
        local r = Instance.new("Frame")
        r.Size = UDim2.new(1, 0, 0, height)
        r.BackgroundColor3 = Co.row
        r.BorderSizePixel = 0
        r.LayoutOrder = rowOrder
        r.Parent = body
        corner(r, 10)
        table.insert(searchables, {row = r, label = string.lower(label or ""), card = body.Parent})
        return r
    end

    -- Blue action button (full width)
    local function Bt(body, n, cl)
        local b = Instance.new("TextButton")
        rowOrder = rowOrder + 1
        b.Size = UDim2.new(1, 0, 0, rowH)
        b.BackgroundColor3 = Co.ac
        b.Text = n
        b.TextColor3 = Co.tx
        b.Font = Enum.Font.GothamBold
        b.TextSize = fS
        b.AutoButtonColor = false
        b.LayoutOrder = rowOrder
        b.Parent = body
        corner(b, 10)
        table.insert(searchables, {row = b, label = string.lower(n), card = body.Parent})

        b.MouseEnter:Connect(function()
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.acH}):Play()
        end)
        b.MouseLeave:Connect(function()
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.ac}):Play()
        end)
        b.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            cl()
        end)
        return b
    end

    -- Checkbox toggle row
    local function Tg(body, n, cK, callback)
        local r = baseRow(body, rowH, n)

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -60, 1, 0)
        lb.Position = UDim2.new(0, 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.Parent = r

        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0, 26, 0, 26)
        box.Position = UDim2.new(1, -38, 0.5, -13)
        box.BackgroundColor3 = C[cK] and Co.ac or Co.off
        box.Text = ""
        box.AutoButtonColor = false
        box.Parent = r
        corner(box, 7)
        local bs = stroke(box, Co.acH, 1.5, C[cK] and 0.2 or 1)

        local check = Instance.new("TextLabel")
        check.Size = UDim2.new(1, 0, 1, 0)
        check.BackgroundTransparency = 1
        check.Text = "✓"
        check.TextColor3 = Co.tx
        check.Font = Enum.Font.GothamBold
        check.TextSize = 16
        check.TextTransparency = C[cK] and 0 or 1
        check.Parent = box

        local function apply()
            T:Create(box, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                BackgroundColor3 = C[cK] and Co.ac or Co.off
            }):Play()
            T:Create(bs, TweenInfo.new(0.2), {Transparency = C[cK] and 0.2 or 1}):Play()
            T:Create(check, TweenInfo.new(0.2), {TextTransparency = C[cK] and 0 or 1}):Play()
        end

        local function flip()
            playSound(Sounds.Toggle, 0.3)
            C[cK] = not C[cK]
            apply()
            if callback then callback(C[cK]) end
        end

        box.MouseButton1Click:Connect(flip)

        -- whole row clickable
        local hit = Instance.new("TextButton")
        hit.Size = UDim2.new(1, -50, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.Parent = r
        hit.MouseButton1Click:Connect(flip)

        return r
    end

    -- Slider row: label + value top, track bottom
    local function Sl(body, n, min, max, cK, callback)
        local r = baseRow(body, rowH + 30, n)

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.7, 0, 0, 20)
        lb.Position = UDim2.new(0, 14, 0, 10)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.Parent = r

        local vL = Instance.new("TextBox")
        vL.Size = UDim2.new(0, 60, 0, 20)
        vL.Position = UDim2.new(1, -74, 0, 10)
        vL.BackgroundTransparency = 1
        vL.Text = tostring(C[cK])
        vL.TextColor3 = Co.acH
        vL.Font = Enum.Font.GothamBold
        vL.TextSize = fS
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.ClearTextOnFocus = false
        vL.Parent = r

        local sB = Instance.new("Frame")
        sB.Size = UDim2.new(1, -28, 0, 6)
        sB.Position = UDim2.new(0, 14, 1, -22)
        sB.BackgroundColor3 = Co.off
        sB.BorderSizePixel = 0
        sB.Parent = r
        corner(sB, 3)

        local sF = Instance.new("Frame")
        sF.Size = UDim2.new((C[cK] - min) / (max - min), 0, 1, 0)
        sF.BackgroundColor3 = Co.ac
        sF.BorderSizePixel = 0
        sF.Parent = sB
        corner(sF, 3)

        local sN = Instance.new("Frame")
        sN.Size = UDim2.new(0, 20, 0, 20)
        sN.Position = UDim2.new((C[cK] - min) / (max - min), -10, 0.5, -10)
        sN.BackgroundColor3 = Co.tx
        sN.BorderSizePixel = 0
        sN.Parent = sB
        corner(sN, 10)
        stroke(sN, Co.ac, 2, 0)

        local function updateSlider(val)
            val = math.clamp(val, min, max)
            C[cK] = val
            vL.Text = tostring(val)
            local pct = (val - min) / (max - min)
            sF.Size = UDim2.new(pct, 0, 1, 0)
            sN.Position = UDim2.new(pct, -10, 0.5, -10)
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
        local function fromInput(i)
            local pct = math.clamp((i.Position.X - sB.AbsolutePosition.X) / sB.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            updateSlider(val)
            if callback then callback(val) end
        end

        local function isPress(i)
            return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
        end

        -- larger hit area for the track
        local hit = Instance.new("TextButton")
        hit.Size = UDim2.new(1, 0, 0, 24)
        hit.Position = UDim2.new(0, 0, 0.5, -12)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.Parent = sB

        hit.InputBegan:Connect(function(i)
            if isPress(i) then
                dG = true
                playSound(Sounds.Click, 0.2)
                fromInput(i)
            end
        end)
        hit.InputEnded:Connect(function(i) if isPress(i) then dG = false end end)

        U.InputChanged:Connect(function(i)
            if dG and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                fromInput(i)
            end
        end)
        U.InputEnded:Connect(function(i) if isPress(i) then dG = false end end)

        return r
    end

    -- Coordinate textbox row
    local coordTextBox
    local function Tb(body, n)
        local r = baseRow(body, rowH + 34, n)

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -28, 0, 20)
        lb.Position = UDim2.new(0, 14, 0, 8)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.Parent = r

        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -28, 0, 32)
        tb.Position = UDim2.new(0, 14, 0, 32)
        tb.BackgroundColor3 = Co.card
        tb.Text = C.CoordinateText or ""
        tb.TextColor3 = Co.tx
        tb.Font = Enum.Font.GothamMedium
        tb.TextSize = fS - 1
        tb.PlaceholderText = "X: 0.00 | Y: 0.00 | Z: 0.00"
        tb.PlaceholderColor3 = Co.ts
        tb.ClearTextOnFocus = false
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.Parent = r
        corner(tb, 8)
        stroke(tb, Co.br, 1, 0.4)
        local tp = Instance.new("UIPadding", tb)
        tp.PaddingLeft = UDim.new(0, 10)
        tp.PaddingRight = UDim.new(0, 10)

        tb:GetPropertyChangedSignal("Text"):Connect(function()
            C.CoordinateText = tb.Text
        end)

        coordTextBox = tb
        return tb
    end

    -- ============================================
    -- SEARCH FILTER
    -- ============================================
    local function applySearch(q)
        q = string.lower(q or "")
        local visibleInCard = {}
        for _, e in ipairs(searchables) do
            local show = (q == "") or string.find(e.label, q, 1, true) ~= nil
            e.row.Visible = show
            if show then visibleInCard[e.card] = true end
            visibleInCard[e.card] = visibleInCard[e.card] or false
        end
        for card, hasVisible in pairs(visibleInCard) do
            card.Visible = hasVisible
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        applySearch(searchBox.Text)
    end)

    -- ============================================
    -- CLOSE CONFIRM DIALOG
    -- ============================================
    local mn = false
    local fSz = m.Size

    local function showConfirmDialog()
        if m:FindFirstChild("ConfirmBlur") then return end

        if mn then
            mn = false
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
            cb.Text = "−"
            task.wait(0.3)
        end

        local blur = Instance.new("Frame")
        blur.Name = "ConfirmBlur"
        blur.Size = UDim2.new(1, 0, 1, 0)
        blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blur.BackgroundTransparency = 1
        blur.BorderSizePixel = 0
        blur.ZIndex = 2000
        blur.Parent = m
        corner(blur, 14)

        local blocker = Instance.new("TextButton")
        blocker.Size = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text = ""
        blocker.ZIndex = 2000
        blocker.AutoButtonColor = false
        blocker.Parent = blur

        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 280, 0, 140)
        dialog.Position = UDim2.new(0.5, -140, 0.5, -70)
        dialog.BackgroundColor3 = Co.card
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 2001
        dialog.Parent = blur
        corner(dialog, 12)
        local dialogStroke = stroke(dialog, Co.br, 1, 0.3)

        local dTitle = Instance.new("TextLabel")
        dTitle.Size = UDim2.new(1, -32, 0, 24)
        dTitle.Position = UDim2.new(0, 16, 0, 12)
        dTitle.BackgroundTransparency = 1
        dTitle.Text = "Close Window"
        dTitle.TextColor3 = Co.tx
        dTitle.Font = Enum.Font.GothamBold
        dTitle.TextSize = 16
        dTitle.TextXAlignment = Enum.TextXAlignment.Left
        dTitle.ZIndex = 2002
        dTitle.Parent = dialog

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -32, 0, 36)
        desc.Position = UDim2.new(0, 16, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Text = "Do you want to close this window?\nYou will not be able to open it again."
        desc.TextColor3 = Co.ts
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 13
        desc.TextWrapped = true
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.ZIndex = 2002
        desc.Parent = dialog

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0.48, 0, 0, 36)
        cancelBtn.Position = UDim2.new(0, 16, 1, -48)
        cancelBtn.BackgroundColor3 = Co.row
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = Co.tx
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.TextSize = 13
        cancelBtn.AutoButtonColor = false
        cancelBtn.ZIndex = 2003
        cancelBtn.Parent = dialog
        corner(cancelBtn, 8)

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0.48, -32, 0, 36)
        confirmBtn.Position = UDim2.new(0.52, 16, 1, -48)
        confirmBtn.BackgroundColor3 = Co.ac
        confirmBtn.Text = "Close Window"
        confirmBtn.TextColor3 = Co.tx
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.TextSize = 13
        confirmBtn.AutoButtonColor = false
        confirmBtn.ZIndex = 2003
        confirmBtn.Parent = dialog
        corner(confirmBtn, 8)

        -- fade in
        dialog.BackgroundTransparency = 1
        dialogStroke.Transparency = 1
        dTitle.TextTransparency = 1
        desc.TextTransparency = 1
        cancelBtn.BackgroundTransparency = 1
        cancelBtn.TextTransparency = 1
        confirmBtn.BackgroundTransparency = 1
        confirmBtn.TextTransparency = 1

        T:Create(blur, TweenInfo.new(0.25), {BackgroundTransparency = 0.5}):Play()
        T:Create(dialog, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
        T:Create(dialogStroke, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
        T:Create(dTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        T:Create(desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        T:Create(cancelBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        T:Create(confirmBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        playSound(Sounds.Click, 0.3)

        local function fadeOut()
            T:Create(blur, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            T:Create(dialog, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            T:Create(dialogStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            T:Create(dTitle, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            T:Create(desc, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            T:Create(cancelBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            T:Create(confirmBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.2)
            blur:Destroy()
        end

        cancelBtn.MouseEnter:Connect(function() T:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.rowH}):Play() end)
        cancelBtn.MouseLeave:Connect(function() T:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.row}):Play() end)
        confirmBtn.MouseEnter:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.acH}):Play() end)
        confirmBtn.MouseLeave:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ac}):Play() end)

        cancelBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.3)
            fadeOut()
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            fadeOut()

            if Feature and Feature.resetAllFeatures then
                pcall(Feature.resetAllFeatures)
            end

            S.U = true
            _G.SynceHubCoordinateLoaded = false
            for _, conn in pairs(S.Co) do
                pcall(function() conn:Disconnect() end)
            end
            Feature.cleanup()
            if S.G then S.G:Destroy() end
            if S.Mb then S.Mb:Destroy() end
        end)
    end

    clBtn.MouseButton1Click:Connect(showConfirmDialog)

    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.3)
        mn = not mn
        local tS = mn and UDim2.new(0, w, 0, topH) or fSz
        T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = tS}):Play()
        cb.Text = mn and "+" or "−"
    end)

    -- ============================================
    -- TABS & CONTENT
    -- ============================================
    local TAB_TELEPORT = Tab("Teleport", "97702274768362")
    local TAB_PLAYER   = Tab("Player",   "131354680051916")
    local TAB_MISC     = Tab("Misc",     "105330233440321")

    -- Teleport tab
    local coordBody = Card(TAB_TELEPORT, "Coordinates", 1)
    Tb(coordBody, "Position")
    Bt(coordBody, "Get Position", function()
        local pos = Feature.getPosition()
        if coordTextBox and pos then
            coordTextBox.Text = pos
        end
    end)
    Bt(coordBody, "Teleport to Coordinates", function()
        Feature.teleportToCoordinates()
    end)
    Bt(coordBody, "Clear", function()
        Feature.clearCoordinates()
        if coordTextBox then coordTextBox.Text = "" end
    end)

    local copyBody = Card(TAB_TELEPORT, "Export", 2)
    Bt(copyBody, "Copy Coordinates", function()
        Feature.copyCoordinates()
    end)
    Bt(copyBody, "Copy Teleport Script", function()
        Feature.copyTeleportScript()
    end)

    -- Player tab
    local moveBody = Card(TAB_PLAYER, "Movement", 1)
    Sl(moveBody, "Walk Speed", 16, 200, "WalkSpeed", function(v)
        Feature.setWalkSpeed(v)
    end)

    -- Misc tab
    local ctrlBody = Card(TAB_MISC, "Controls", 1)
    kB = Bt(ctrlBody, "Set Keybind: " .. gKN(C.Keybind), function()
        if S.WaitingKey then return end
        S.WaitingKey = true
        kB.Text = "Press any key..."
        kB.BackgroundColor3 = Co.warn

        local conn
        local timeout

        timeout = task.delay(8, function()
            if S.WaitingKey then
                S.WaitingKey = false
                kB.Text = "Set Keybind: " .. gKN(C.Keybind)
                kB.BackgroundColor3 = Co.ac
                if conn then conn:Disconnect() end
                Feature.showNotification("Keybind timeout!", false)
            end
        end)

        conn = U.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.UserInputType == Enum.UserInputType.Keyboard then
                task.cancel(timeout)
                C.Keybind = i.KeyCode
                kB.Text = "Set Keybind: " .. gKN(C.Keybind)
                kB.BackgroundColor3 = Co.ac
                S.WaitingKey = false
                conn:Disconnect()
                Feature.showNotification("Keybind set to " .. gKN(C.Keybind), true)
            end
        end)
    end)

    local sessBody = Card(TAB_MISC, "Session", 2)
    Bt(sessBody, "Rejoin Server", function()
        Feature.rejoinServer()
    end)
    Bt(sessBody, "Destroy UI", function()
        S.U = true
        _G.SynceHubCoordinateLoaded = false
        for _, conn in pairs(S.Co) do
            pcall(function() conn:Disconnect() end)
        end
        Feature.cleanup()
        if S.G then S.G:Destroy() end
        if S.Mb then S.Mb:Destroy() end
    end)

    setTab(TAB_TELEPORT)

    -- ============================================
    -- DRAG (topbar + logo area)
    -- ============================================
    local dragStart, startPos
    local function beginDrag(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragStart = i.Position
            startPos = m.Position
        end
    end
    local function endDrag(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
        end
    end
    top.InputBegan:Connect(beginDrag)
    top.InputEnded:Connect(endDrag)
    logo.InputBegan:Connect(beginDrag)
    logo.InputEnded:Connect(endDrag)

    S.Co.Drag = U.InputChanged:Connect(function(i)
        if dragStart and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dt = i.Position - dragStart
            m.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + dt.X,
                startPos.Y.Scale, startPos.Y.Offset + dt.Y
            )
        end
    end)

    m.Position = UDim2.new(1, 20, 0.5, -h/2)

    pcall(function()
        g.Parent = game:GetService("CoreGui")
    end)
    if not g.Parent then
        g.Parent = L:WaitForChild("PlayerGui")
    end

    S.G = g

    -- ============================================
    -- MOBILE SHOW/HIDE BUTTON
    -- ============================================
    if isMobile then
        local BUTTON_TRANSPARENCY = 0.10

        local mB = Instance.new("Frame")
        mB.Size = UDim2.new(0, 100, 0, 32)
        mB.Position = UDim2.new(0, 10, 0, 10)
        mB.BackgroundColor3 = Co.side
        mB.BackgroundTransparency = BUTTON_TRANSPARENCY
        mB.BorderSizePixel = 0
        mB.Parent = g
        corner(mB, 16)
        local mStroke = stroke(mB, Co.br, 1.5, 0.3)

        local mI = Instance.new("ImageLabel")
        mI.Size = UDim2.new(0, 20, 0, 20)
        mI.Position = UDim2.new(0, 8, 0.5, -10)
        mI.BackgroundTransparency = 1
        mI.Image = "rbxassetid://114167695335193"
        mI.ImageColor3 = Co.tx
        mI.Parent = mB

        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -36, 1, 0)
        btnText.Position = UDim2.new(0, 32, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = "Hide"
        btnText.TextColor3 = Co.tx
        btnText.Font = Enum.Font.GothamBold
        btnText.TextSize = 15
        btnText.Parent = mB

        local mT = Instance.new("TextButton")
        mT.Size = UDim2.new(1, 0, 1, 0)
        mT.BackgroundTransparency = 1
        mT.Text = ""
        mT.Parent = mB

        local dragging, dStart, sPos, wasDragged = false, nil, nil, false

        mT.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dStart = input.Position
                sPos = mB.Position
                wasDragged = false
            end
        end)

        mT.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if not wasDragged then
                    m.Visible = not m.Visible
                    playSound(Sounds.Click, 0.4)
                    btnText.Text = m.Visible and "Hide" or "Show"
                    mI.Image = m.Visible and "rbxassetid://114167695335193" or "rbxassetid://99334701468696"
                    T:Create(mB, TweenInfo.new(0.1), {Size = UDim2.new(0, 95, 0, 30)}):Play()
                    task.wait(0.1)
                    T:Create(mB, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size = UDim2.new(0, 100, 0, 32)}):Play()
                end
            end
        end)

        U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dStart
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then wasDragged = true end
                mB.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
            end
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

    task.wait(0.2)
    Feature.showNotification("SynceHub initialized successfully!", true)
end

return TabContent
