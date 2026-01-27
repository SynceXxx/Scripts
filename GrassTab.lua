-- tabcontent.lua
-- SynceHub - UI Creation and Tab Content (HORIZONTAL LAYOUT)

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

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName)
    C = config
    S = state
    Feature = featureModule
    gKN = getKeyName
    
    if S.G then S.G:Destroy() end
    
    local sS = workspace.CurrentCamera.ViewportSize
    -- HORIZONTAL LAYOUT: Width lebih besar, height lebih kecil
    local w = isMobile and math.min(450, sS.X - 24) or 650
    local h = isMobile and math.min(380, sS.Y - 100) or 400
    local bH = isMobile and 46 or 44
    local p = 12
    local fS = isMobile and 14 or 13
    
    -- Sidebar width
    local sidebarWidth = isMobile and 100 or 140
    
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
        warn = Color3.fromRGB(88, 101, 242),
        sidebar = Color3.fromRGB(25, 25, 30)
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
    m.ClipsDescendants = true
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
    st.Text = "Cut Grass | " .. version
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
        
        local blur = Instance.new("Frame")
        blur.Name = "ConfirmBlur"
        blur.Size = UDim2.new(1, 0, 1, 0)
        blur.Position = UDim2.new(0, 0, 0, 0)
        blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blur.BackgroundTransparency = 0.5
        blur.BorderSizePixel = 0
        blur.ZIndex = 2000
        blur.Parent = m
        
        Instance.new("UICorner", blur).CornerRadius = UDim.new(0, 16)
        
        local blocker = Instance.new("TextButton")
        blocker.Size = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text = ""
        blocker.ZIndex = 2000
        blocker.Parent = blur
        blocker.Active = true
        blocker.AutoButtonColor = false
        
        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 280, 0, 140)
        dialog.Position = UDim2.new(0.5, -140, 0.5, -70)
        dialog.BackgroundColor3 = Co.cd
        dialog.BackgroundTransparency = 0.3
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 2001
        dialog.Parent = blur
        
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)
        
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
        
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = 1999
        shadow.Parent = dialog
        
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0.5, -20, 0, 18)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://118025272389341"
        icon.ImageColor3 = Co.warn
        icon.ZIndex = 2002
        icon.Parent = dialog
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 60)
        title.BackgroundTransparency = 1
        title.Text = "Close SynceHub?"
        title.TextColor3 = Co.tx
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.ZIndex = 2002
        title.Parent = dialog
        
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0, 115, 0, 32)
        yesBtn.Position = UDim2.new(0, 15, 1, -42)
        yesBtn.BackgroundColor3 = Co.warn
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextSize = 13
        yesBtn.ZIndex = 2002
        yesBtn.Parent = dialog
        
        Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 8)
        
        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0, 115, 0, 32)
        noBtn.Position = UDim2.new(1, -130, 1, -42)
        noBtn.BackgroundColor3 = Co.ch
        noBtn.Text = "No"
        noBtn.TextColor3 = Co.tx
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextSize = 13
        noBtn.ZIndex = 2002
        noBtn.Parent = dialog
        
        Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 8)
        
        dialog.Size = UDim2.new(0, 0, 0, 0)
        dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
        T:Create(dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 280, 0, 140),
            Position = UDim2.new(0.5, -140, 0.5, -70)
        }):Play()
        
        yesBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.5)
            m.Visible = false
            task.wait(0.1)
            blur:Destroy()
        end)
        
        noBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            T:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            task.wait(0.2)
            blur:Destroy()
        end)
        
        yesBtn.MouseEnter:Connect(function()
            T:Create(yesBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 115, 255)}):Play()
        end)
        
        yesBtn.MouseLeave:Connect(function()
            T:Create(yesBtn, TweenInfo.new(0.2), {BackgroundColor3 = Co.warn}):Play()
        end)
        
        noBtn.MouseEnter:Connect(function()
            T:Create(noBtn, TweenInfo.new(0.2), {BackgroundColor3 = Co.br}):Play()
        end)
        
        noBtn.MouseLeave:Connect(function()
            T:Create(noBtn, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
        end)
    end

    clBtn.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.5)
        showConfirmDialog()
    end)

    clBtn.MouseEnter:Connect(function()
        T:Create(clBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 53, 69),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    clBtn.MouseLeave:Connect(function()
        T:Create(clBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Co.ch,
            TextColor3 = Co.ts
        }):Play()
    end)

    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.4)
        mn = not mn
        if mn then
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, w, 0, 52)}):Play()
            cb.Text = "+"
        else
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
            cb.Text = "−"
        end
    end)

    cb.MouseEnter:Connect(function()
        T:Create(cb, TweenInfo.new(0.2), {BackgroundColor3 = Co.br}):Play()
    end)

    cb.MouseLeave:Connect(function()
        T:Create(cb, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
    end)
    
    -- SIDEBAR CONTAINER
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -52)
    sidebar.Position = UDim2.new(0, 0, 0, 52)
    sidebar.BackgroundColor3 = Co.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = m
    
    -- Rounded corner only for bottom-left
    local sidebarCorner = Instance.new("UICorner", sidebar)
    sidebarCorner.CornerRadius = UDim.new(0, 0)
    
    -- Sidebar stroke/border on right side
    local sidebarStroke = Instance.new("Frame")
    sidebarStroke.Size = UDim2.new(0, 1, 1, 0)
    sidebarStroke.Position = UDim2.new(1, 0, 0, 0)
    sidebarStroke.BackgroundColor3 = Co.br
    sidebarStroke.BorderSizePixel = 0
    sidebarStroke.Parent = sidebar
    
    -- CONTENT CONTAINER
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -sidebarWidth, 1, -52)
    contentContainer.Position = UDim2.new(0, sidebarWidth, 0, 52)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = m
    
    -- Tab system
    local tabs = {}
    local activeTab = nil
    
    local function createTab(name, icon)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(1, -10, 0, isMobile and 42 or 44)
        tabButton.BackgroundColor3 = Co.cd
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = sidebar
        
        Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 10)
        
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Size = UDim2.new(0, isMobile and 20 or 22, 0, isMobile and 20 or 22)
        tabIcon.Position = UDim2.new(0, isMobile and 8 or 12, 0.5, isMobile and -10 or -11)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = icon
        tabIcon.ImageColor3 = Co.ts
        tabIcon.Parent = tabButton
        
        local tabText = Instance.new("TextLabel")
        tabText.Size = UDim2.new(1, isMobile and -36 or -44, 1, 0)
        tabText.Position = UDim2.new(0, isMobile and 32 or 40, 0, 0)
        tabText.BackgroundTransparency = 1
        tabText.Text = name
        tabText.TextColor3 = Co.ts
        tabText.Font = Enum.Font.GothamMedium
        tabText.TextSize = isMobile and 12 or 13
        tabText.TextXAlignment = Enum.TextXAlignment.Left
        tabText.Parent = tabButton
        
        -- Active indicator
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 0)
        indicator.Position = UDim2.new(0, 0, 0.5, 0)
        indicator.AnchorPoint = Vector2.new(0, 0.5)
        indicator.BackgroundColor3 = Co.ac
        indicator.BorderSizePixel = 0
        indicator.Parent = tabButton
        
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
        
        -- Content page
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Position = UDim2.new(0, 0, 0, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Co.sc
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = contentContainer
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page
        
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingTop = UDim.new(0, 12)
        pagePadding.PaddingBottom = UDim.new(0, 12)
        pagePadding.PaddingLeft = UDim.new(0, 12)
        pagePadding.PaddingRight = UDim.new(0, 12)
        
        tabs[name] = {
            button = tabButton,
            icon = tabIcon,
            text = tabText,
            indicator = indicator,
            page = page
        }
        
        local function setActive(active)
            if active then
                activeTab = name
                T:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                T:Create(tabIcon, TweenInfo.new(0.2), {ImageColor3 = Co.ac}):Play()
                T:Create(tabText, TweenInfo.new(0.2), {TextColor3 = Co.tx}):Play()
                T:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 3, 0, 28)
                }):Play()
                page.Visible = true
            else
                T:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                T:Create(tabIcon, TweenInfo.new(0.2), {ImageColor3 = Co.ts}):Play()
                T:Create(tabText, TweenInfo.new(0.2), {TextColor3 = Co.ts}):Play()
                T:Create(indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
                page.Visible = false
            end
        end
        
        tabButton.MouseButton1Click:Connect(function()
            if activeTab ~= name then
                playSound(Sounds.Click, 0.4)
                for tabName, tab in pairs(tabs) do
                    if tabName == name then
                        setActive(true)
                    else
                        setActive(false)
                    end
                end
            end
        end)
        
        tabButton.MouseEnter:Connect(function()
            if activeTab ~= name then
                playSound(Sounds.Hover, 0.2)
                T:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if activeTab ~= name then
                T:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end)
        
        return page
    end
    
    -- Create tabs
    local mainPage = createTab("Main", "rbxassetid://114167695335193")
    local settingsPage = createTab("Settings", "rbxassetid://105330233440321")
    
    -- Layout tabs in sidebar
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebar
    
    local sidebarPadding = Instance.new("UIPadding", sidebar)
    sidebarPadding.PaddingTop = UDim.new(0, 12)
    sidebarPadding.PaddingLeft = UDim.new(0, 5)
    sidebarPadding.PaddingRight = UDim.new(0, 5)
    
    tabs.Main.button.LayoutOrder = 1
    tabs.Settings.button.LayoutOrder = 2
    
    -- Activate first tab
    for tabName, tab in pairs(tabs) do
        if tabName == "Main" then
            tab.button.BackgroundTransparency = 0
            tab.icon.ImageColor3 = Co.ac
            tab.text.TextColor3 = Co.tx
            tab.indicator.Size = UDim2.new(0, 3, 0, 28)
            tab.page.Visible = true
            activeTab = tabName
        end
    end
    
    -- Helper function to create elements in pages
    local function createSection(parent, title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.BackgroundTransparency = 1
        section.Parent = parent
        
        if title then
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Size = UDim2.new(1, 0, 0, 24)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = title
            sectionTitle.TextColor3 = Co.tx
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextSize = fS + 1
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = section
        end
        
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Padding = UDim.new(0, 8)
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Parent = section
        
        return section
    end
    
    -- Toggle function
    local function Tg(parent, tx, st, cb, ic)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, bH)
        f.BackgroundColor3 = Co.cd
        f.BorderSizePixel = 0
        f.Parent = parent
        
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", f)
        stroke.Color = Co.br
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        
        if ic then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, p, 0.5, -10)
            icon.BackgroundTransparency = 1
            icon.Image = ic
            icon.ImageColor3 = Co.tx
            icon.Parent = f
        end
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, ic and -90 or -70, 1, 0)
        t.Position = UDim2.new(0, ic and p+28 or p, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = tx
        t.TextColor3 = Co.tx
        t.Font = Enum.Font.GothamMedium
        t.TextSize = fS
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 26)
        btn.Position = UDim2.new(1, -p-50, 0.5, -13)
        btn.BackgroundColor3 = st and Co.ac or Co.ch
        btn.Text = ""
        btn.Parent = f
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 20, 0, 20)
        knob.Position = st and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = btn
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 4, 1, 4)
        shadow.Position = UDim2.new(0, -2, 0, -2)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.7
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = 0
        shadow.Parent = knob
        
        btn.MouseButton1Click:Connect(function()
            st = not st
            playSound(Sounds.Toggle, st and 0.5 or 0.4)
            
            T:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = st and Co.ac or Co.ch
            }):Play()
            
            T:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = st and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
            
            if cb then cb(st) end
        end)
        
        btn.MouseEnter:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.ac, Transparency = 0.3}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.cd}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.br, Transparency = 0.5}):Play()
        end)
        
        return f
    end
    
    -- Slider function
    local function Sl(parent, tx, mn, mx, df, cb, ic)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, bH + 8)
        f.BackgroundColor3 = Co.cd
        f.BorderSizePixel = 0
        f.Parent = parent
        
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", f)
        stroke.Color = Co.br
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        
        if ic then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, p, 0, 8)
            icon.BackgroundTransparency = 1
            icon.Image = ic
            icon.ImageColor3 = Co.tx
            icon.Parent = f
        end
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -90, 0, 20)
        t.Position = UDim2.new(0, ic and p+28 or p, 0, 8)
        t.BackgroundTransparency = 1
        t.Text = tx
        t.TextColor3 = Co.tx
        t.Font = Enum.Font.GothamMedium
        t.TextSize = fS
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f
        
        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(0, 60, 0, 20)
        v.Position = UDim2.new(1, -p-60, 0, 8)
        v.BackgroundColor3 = Co.ch
        v.Text = tostring(df)
        v.TextColor3 = Co.ac
        v.Font = Enum.Font.GothamBold
        v.TextSize = fS
        v.Parent = f
        
        Instance.new("UICorner", v).CornerRadius = UDim.new(0, 8)
        
        local sF = Instance.new("Frame")
        sF.Size = UDim2.new(1, -2*p, 0, 6)
        sF.Position = UDim2.new(0, p, 1, -14)
        sF.BackgroundColor3 = Co.ch
        sF.BorderSizePixel = 0
        sF.Parent = f
        
        Instance.new("UICorner", sF).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((df-mn)/(mx-mn), 0, 1, 0)
        fill.BackgroundColor3 = Co.ac
        fill.BorderSizePixel = 0
        fill.Parent = sF
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(1, -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = fill
        
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 6, 1, 6)
        shadow.Position = UDim2.new(0, -3, 0, -3)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = 0
        shadow.Parent = knob
        
        local dragging = false
        
        local function update(input)
            local pos = (input.Position.X - sF.AbsolutePosition.X) / sF.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            local val = math.floor(mn + (mx - mn) * pos)
            
            v.Text = tostring(val)
            T:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
            
            if cb then cb(val) end
        end
        
        sF.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
                playSound(Sounds.Click, 0.3)
            end
        end)
        
        sF.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                            input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        
        f.MouseEnter:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.ac, Transparency = 0.3}):Play()
        end)
        
        f.MouseLeave:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.cd}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.br, Transparency = 0.5}):Play()
        end)
        
        return f
    end
    
    -- Dropdown function
    local function Dd(parent, tx, opts, df, cb, ic)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, bH)
        f.BackgroundColor3 = Co.cd
        f.BorderSizePixel = 0
        f.Parent = parent
        
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", f)
        stroke.Color = Co.br
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        
        if ic then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, p, 0.5, -10)
            icon.BackgroundTransparency = 1
            icon.Image = ic
            icon.ImageColor3 = Co.tx
            icon.Parent = f
        end
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(0.5, ic and -p-28 or -p, 1, 0)
        t.Position = UDim2.new(0, ic and p+28 or p, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = tx
        t.TextColor3 = Co.tx
        t.Font = Enum.Font.GothamMedium
        t.TextSize = fS
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -p-5, 0, 32)
        btn.Position = UDim2.new(0.5, 5, 0.5, -16)
        btn.BackgroundColor3 = Co.ch
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = f
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -30, 1, 0)
        btnText.Position = UDim2.new(0, 10, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = df
        btnText.TextColor3 = Co.ts
        btnText.Font = Enum.Font.Gotham
        btnText.TextSize = fS - 1
        btnText.TextXAlignment = Enum.TextXAlignment.Left
        btnText.TextTruncate = Enum.TextTruncate.AtEnd
        btnText.Parent = btn
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -24, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Co.ts
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 10
        arrow.Parent = btn
        
        local opened = false
        local dropdown
        
        btn.MouseButton1Click:Connect(function()
            opened = not opened
            playSound(Sounds.Dropdown, 0.4)
            
            T:Create(arrow, TweenInfo.new(0.2), {
                Rotation = opened and 180 or 0
            }):Play()
            
            if opened then
                if dropdown then dropdown:Destroy() end
                
                dropdown = Instance.new("Frame")
                dropdown.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, math.min(#opts * 32 + 8, 200))
                dropdown.Position = UDim2.new(0, btn.AbsolutePosition.X - f.AbsolutePosition.X, 
                                             0, f.AbsoluteSize.Y + 4)
                dropdown.BackgroundColor3 = Co.cd
                dropdown.BorderSizePixel = 0
                dropdown.ZIndex = 100
                dropdown.Parent = f
                
                Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 10)
                
                local ddStroke = Instance.new("UIStroke", dropdown)
                ddStroke.Color = Co.br
                ddStroke.Thickness = 1
                ddStroke.Transparency = 0.3
                
                local scroll = Instance.new("ScrollingFrame")
                scroll.Size = UDim2.new(1, -8, 1, -8)
                scroll.Position = UDim2.new(0, 4, 0, 4)
                scroll.BackgroundTransparency = 1
                scroll.BorderSizePixel = 0
                scroll.ScrollBarThickness = 4
                scroll.ScrollBarImageColor3 = Co.sc
                scroll.CanvasSize = UDim2.new(0, 0, 0, #opts * 32)
                scroll.Parent = dropdown
                
                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0, 0)
                layout.Parent = scroll
                
                for _, opt in ipairs(opts) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, 32)
                    optBtn.BackgroundColor3 = Co.cd
                    optBtn.BackgroundTransparency = 1
                    optBtn.Text = opt
                    optBtn.TextColor3 = Co.tx
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = fS - 1
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.Parent = scroll
                    
                    local optPadding = Instance.new("UIPadding", optBtn)
                    optPadding.PaddingLeft = UDim.new(0, 10)
                    
                    optBtn.MouseButton1Click:Connect(function()
                        btnText.Text = opt
                        playSound(Sounds.Click, 0.3)
                        opened = false
                        T:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        dropdown:Destroy()
                        if cb then cb(opt) end
                    end)
                    
                    optBtn.MouseEnter:Connect(function()
                        T:Create(optBtn, TweenInfo.new(0.15), {
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Co.ch
                        }):Play()
                    end)
                    
                    optBtn.MouseLeave:Connect(function()
                        T:Create(optBtn, TweenInfo.new(0.15), {
                            BackgroundTransparency = 1
                        }):Play()
                    end)
                end
                
                dropdown.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
                T:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, btn.AbsoluteSize.X, 0, math.min(#opts * 32 + 8, 200))
                }):Play()
            else
                if dropdown then
                    T:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)
                    }):Play()
                    task.wait(0.2)
                    dropdown:Destroy()
                end
            end
        end)
        
        btn.MouseEnter:Connect(function()
            T:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Co.br}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            T:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
        end)
        
        f.MouseEnter:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.ac, Transparency = 0.3}):Play()
        end)
        
        f.MouseLeave:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.cd}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.br, Transparency = 0.5}):Play()
        end)
        
        return f
    end
    
    -- Button function
    local function Bt(tx, cb, ic)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, bH)
        f.BackgroundColor3 = Co.cd
        f.BorderSizePixel = 0
        f.Parent = settingsPage
        
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", f)
        stroke.Color = Co.br
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = f
        
        if ic then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, p, 0.5, -10)
            icon.BackgroundTransparency = 1
            icon.Image = ic
            icon.ImageColor3 = Co.tx
            icon.Parent = f
        end
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, ic and -p-28 or -2*p, 1, 0)
        t.Position = UDim2.new(0, ic and p+28 or p, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = tx
        t.TextColor3 = Co.tx
        t.Font = Enum.Font.GothamMedium
        t.TextSize = fS
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f
        
        btn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.5)
            
            T:Create(f, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, bH-4)}):Play()
            task.wait(0.1)
            T:Create(f, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, bH)}):Play()
            
            if cb then cb() end
        end)
        
        btn.MouseEnter:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.ch}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.ac, Transparency = 0.3}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            T:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = Co.cd}):Play()
            T:Create(stroke, TweenInfo.new(0.2), {Color = Co.br, Transparency = 0.5}):Play()
        end)
        
        return f
    end
    
    -- MAIN TAB CONTENT
    local mainSection = createSection(mainPage, "Auto Features")
    
    Tg(mainSection, "Auto Swing", C.AutoSwing, function(v)
        C.AutoSwing = v
        Feature.toggleAutoSwing(v)
    end, "rbxassetid://89502555190532")
    
    Tg(mainSection, "Hide Grass", C.HideGrass, function(v)
        C.HideGrass = v
        Feature.toggleHideGrass(v)
    end, "rbxassetid://112306057797735")
    
    Tg(mainSection, "Auto Chest", C.AutoChest, function(v)
        C.AutoChest = v
        Feature.toggleAutoChest(v)
    end, "rbxassetid://96127205211701")
    
    local toolSection = createSection(mainPage, "Tool Settings")
    
    Sl(toolSection, "Tool Size", 2, 20, C.ToolSize, function(v)
        C.ToolSize = v
        Feature.updateToolSize(v)
    end, "rbxassetid://107338599816625")
    
    local moveSection = createSection(mainPage, "Movement")
    
    Sl(moveSection, "Walk Speed", 16, 100, C.WalkSpeed, function(v)
        C.WalkSpeed = v
        Feature.updateWalkSpeed(v)
    end, "rbxassetid://76428587343143")
    
    local chestSection = createSection(mainPage, "Chest Settings")
    
    local tiers = Feature.getChestTiers()
    if #tiers == 0 then
        table.insert(tiers, "::Select Tier::")
    else
        table.insert(tiers, 1, "::Select Tier::")
    end
    
    Dd(chestSection, "Chest Tier", tiers, C.ChestTier, function(v)
        C.ChestTier = v
        Feature.showNotification("Chest tier set to: " .. v, true)
    end, "rbxassetid://96127205211701")
    
    -- SETTINGS TAB CONTENT
    local keybindSection = createSection(settingsPage, "Controls")
    
    kB = Bt("Set Keybind: " .. gKN(C.Keybind), function()
        S.WaitingKey = true
        kB.BackgroundColor3 = Co.warn
        playSound(Sounds.Click, 0.5)
        
        local tx = kB:FindFirstChild("TextLabel")
        if tx then
            tx.Text = "Press any key..."
        end
        
        local conn
        local timeout = task.delay(5, function()
            S.WaitingKey = false
            if tx then
                tx.Text = "Set Keybind: " .. gKN(C.Keybind)
            end
            kB.BackgroundColor3 = Co.cd
            if conn then conn:Disconnect() end
            Feature.showNotification("Keybind timeout!", false)
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
    
    local dangerSection = createSection(settingsPage, "Danger Zone")
    
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
    
    task.wait(0.2)
    Feature.showNotification("SynceHub initialized successfully!", true)
end

return TabContent
