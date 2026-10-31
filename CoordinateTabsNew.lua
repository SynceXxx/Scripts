-- CoordinateTabs.lua
-- SynceHub - UI Creation and Tab Content

local TabContent = {}

local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

local C, S, Feature, gKN

local SOUND_CLICK = "rbxassetid://6895079853"

local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch
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
        tx = Color3.fromRGB(240, 240, 245),
        ts = Color3.fromRGB(150, 150, 160),
        br = Color3.fromRGB(50, 50, 55),
        sc = Color3.fromRGB(120, 120, 130),
        warn = Color3.fromRGB(88, 101, 242)
    }

    -- ============================================
    -- HELPERS
    -- ============================================

    -- Hover: warna berubah saat kursor masuk/keluar
    local function addHover(obj, normal, hover)
        obj.MouseEnter:Connect(function()
            T:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
        end)
        obj.MouseLeave:Connect(function()
            T:Create(obj, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play()
        end)
    end

    -- Drag manager: SATU listener InputChanged + SATU InputEnded untuk semua
    -- (window, slider, tombol mobile). Handler drag hanya terdaftar selama
    -- jari/mouse ditekan, jadi saat idle tidak ada kerja sama sekali.
    local drags = {}

    S.Co.DragMove = U.InputChanged:Connect(function(i)
        local t = i.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local pos = i.Position
            for _, fn in pairs(drags) do
                fn(pos)
            end
        end
    end)

    S.Co.DragEnd = U.InputEnded:Connect(function(i)
        if isPress(i) then
            for k in pairs(drags) do
                drags[k] = nil
            end
        end
    end)

    -- ============================================
    -- MAIN WINDOW
    -- ============================================
    local g = Instance.new("ScreenGui")
    g.Name = "SynceHub"
    g.ResetOnSpawn = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local m = Instance.new("Frame")
    m.Name = "Main"
    m.Size = UDim2.new(0, w, 0, h)
    m.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3 = Co.bg
    m.BorderSizePixel = 0
    m.ClipsDescendants = true
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

    -- ============================================
    -- CONFIRM DIALOG (close window)
    -- ============================================
    local function showConfirmDialog()
        if m:FindFirstChild("ConfirmBlur") then return end

        -- Auto-maximize UI jika sedang minimized
        if mn then
            mn = false
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
            cb.Text = "−"
            task.wait(0.3)
            if m:FindFirstChild("ConfirmBlur") then return end
        end

        -- Overlay untuk block interaksi
        local blur = Instance.new("Frame")
        blur.Name = "ConfirmBlur"
        blur.Size = UDim2.new(1, 0, 1, 0)
        blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blur.BorderSizePixel = 0
        blur.ZIndex = 2000
        Instance.new("UICorner", blur).CornerRadius = UDim.new(0, 16)

        local blocker = Instance.new("TextButton")
        blocker.Size = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text = ""
        blocker.ZIndex = 2000
        blocker.Active = true
        blocker.AutoButtonColor = false
        blocker.Parent = blur

        -- Dialog container
        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 280, 0, 140)
        dialog.Position = UDim2.new(0.5, -140, 0.5, -70)
        dialog.BackgroundColor3 = Co.cd
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 2001
        dialog.Parent = blur

        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)

        -- Glassmorphism layer
        local glass = Instance.new("Frame")
        glass.Size = UDim2.new(1, 0, 1, 0)
        glass.BackgroundColor3 = Co.cd
        glass.BorderSizePixel = 0
        glass.ZIndex = 2000
        glass.Parent = dialog

        Instance.new("UICorner", glass).CornerRadius = UDim.new(0, 14)

        local dialogStroke = Instance.new("UIStroke", dialog)
        dialogStroke.Color = Co.br
        dialogStroke.Thickness = 1

        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = 2000
        shadow.Parent = dialog

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(1, -26, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://101745201658882"
        icon.ImageColor3 = Co.ts
        icon.ZIndex = 2002
        icon.Parent = dialog

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

        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -32, 0, 36)
        btnContainer.Position = UDim2.new(0, 16, 1, -44)
        btnContainer.BackgroundTransparency = 1
        btnContainer.ZIndex = 2002
        btnContainer.Parent = dialog

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

        -- Fade in/out: {object, property, nilai saat tampil}
        local fades = {
            {blur, "BackgroundTransparency", 0.5},
            {dialog, "BackgroundTransparency", 0.3},
            {glass, "BackgroundTransparency", 0.4},
            {dialogStroke, "Transparency", 0.3},
            {shadow, "ImageTransparency", 0.6},
            {icon, "ImageTransparency", 0},
            {title, "TextTransparency", 0},
            {desc, "TextTransparency", 0},
            {cancelBtn, "BackgroundTransparency", 0},
            {cancelBtn, "TextTransparency", 0},
            {confirmBtn, "BackgroundTransparency", 0},
            {confirmBtn, "TextTransparency", 0},
        }

        local function fadeDialog(show, dur)
            local info = TweenInfo.new(dur, Enum.EasingStyle.Quint,
                show and Enum.EasingDirection.Out or Enum.EasingDirection.In)
            for _, f in ipairs(fades) do
                T:Create(f[1], info, {[f[2]] = show and f[3] or 1}):Play()
            end
        end

        -- Mulai dari transparan penuh, lalu fade in
        for _, f in ipairs(fades) do
            f[1][f[2]] = 1
        end
        blur.Parent = m
        fadeDialog(true, 0.25)
        Feature.playSound(SOUND_CLICK, 0.3)

        addHover(cancelBtn, Co.ch, Co.cd)
        addHover(confirmBtn, Co.ac, Color3.fromRGB(30, 144, 255))

        local closing = false
        local function closeDialog(after)
            if closing then return end
            closing = true
            Feature.playSound(SOUND_CLICK, 0.3)
            fadeDialog(false, 0.2)
            task.delay(0.2, function()
                blur:Destroy()
                if after then after() end
            end)
        end

        cancelBtn.MouseButton1Click:Connect(function()
            closeDialog()
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            closeDialog(function()
                if S.Destroy then S.Destroy() end
            end)
        end)
    end

    -- Close button
    clBtn.MouseButton1Click:Connect(showConfirmDialog)
    addHover(clBtn, Co.ch, Co.cd)

    -- Minimize button
    cb.MouseButton1Click:Connect(function()
        Feature.playSound(SOUND_CLICK, 0.3)
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

    -- Scroll container
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -4, 1, -60)
    sc.Position = UDim2.new(0, 2, 0, 56)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 2
    sc.ScrollBarImageColor3 = Co.br
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.ClipsDescendants = true

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

    sc.Parent = m

    local ord = 0
    local function nO()
        ord = ord + 1
        return ord
    end

    -- ============================================
    -- UI ELEMENT CREATORS
    -- ============================================

    -- Section label
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

    -- Button. Return: tombol, label teksnya
    local function Bt(n, cl, ico)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, bH)
        b.BackgroundColor3 = Co.cd
        b.Text = ""
        b.LayoutOrder = nO()

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

        addHover(b, Co.cd, Co.ch)

        b.MouseButton1Click:Connect(function()
            Feature.playSound(SOUND_CLICK, 0.4)
            cl()
        end)

        b.Parent = sc
        return b, tx
    end

    -- Slider (integer). callback dipanggil hanya kalau nilainya berubah.
    local function Sl(n, min, max, cK, callback)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH + 10)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()

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

        local startPct = (C[cK] - min) / (max - min)

        local sF = Instance.new("Frame")
        sF.Size = UDim2.new(startPct, 0, 1, 0)
        sF.BackgroundColor3 = Co.ac
        sF.BorderSizePixel = 0
        sF.Parent = sB

        Instance.new("UICorner", sF).CornerRadius = UDim.new(1, 0)

        local sN = Instance.new("Frame")
        sN.Size = UDim2.new(0, 16, 0, 16)
        sN.Position = UDim2.new(startPct, -8, 0.5, -8)
        sN.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sN.BorderSizePixel = 0
        sN.Parent = sB

        Instance.new("UICorner", sN).CornerRadius = UDim.new(1, 0)

        -- Update tampilan slider
        local function updateSlider(val)
            val = math.clamp(val, min, max)
            C[cK] = val
            vL.Text = tostring(val)
            local pct = (val - min) / (max - min)
            sF.Size = UDim2.new(pct, 0, 1, 0)
            sN.Position = UDim2.new(pct, -8, 0.5, -8)
        end

        -- Geser ke posisi X layar; abaikan kalau nilainya tidak berubah
        local function slideTo(x)
            local width = sB.AbsoluteSize.X
            if width <= 0 then return end
            local pct = math.clamp((x - sB.AbsolutePosition.X) / width, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            if val == C[cK] then return end
            updateSlider(val)
            if callback then callback(val) end
        end

        -- TextBox edit support
        vL.FocusLost:Connect(function()
            local val = tonumber(vL.Text)
            if not val then
                vL.Text = tostring(C[cK])
                return
            end
            val = math.clamp(math.floor(val), min, max)
            local changed = val ~= C[cK]
            updateSlider(val)
            if changed and callback then callback(val) end
        end)

        -- Klik/tahan di bar atau knob mulai drag
        local function beginSlide(i)
            if not isPress(i) then return end
            if not drags[sB] then
                Feature.playSound(SOUND_CLICK, 0.2)
            end
            slideTo(i.Position.X)
            drags[sB] = function(pos)
                slideTo(pos.X)
            end
        end

        sB.InputBegan:Connect(beginSlide)
        sN.InputBegan:Connect(beginSlide)

        ca.Parent = sc
        return ca
    end

    -- Toggle
    local function Tg(n, cK, callback, ico)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br

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
            Feature.playSound(SOUND_CLICK, 0.3)
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

        ca.Parent = sc
        return ca
    end

    -- TextBox for coordinate display/input
    local coordTextBox
    local function Tb(n)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH + 40)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.35, 0, 0, 20)
        lb.Position = UDim2.new(0, 14, 0, 10)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.Parent = ca

        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -28, 0, 36)
        tb.Position = UDim2.new(0, 14, 0, 38)
        tb.BackgroundColor3 = Co.ch
        tb.Text = C.CoordinateText or ""
        tb.TextColor3 = Co.tx
        tb.Font = Enum.Font.GothamMedium
        tb.TextSize = fS - 1
        tb.PlaceholderText = "   X: 0.00 | Y: 0.00 | Z: 0.00"
        tb.PlaceholderColor3 = Co.ts
        tb.ClearTextOnFocus = false
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.Parent = ca

        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

        -- Update Config when text changes
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            C.CoordinateText = tb.Text
        end)

        coordTextBox = tb
        ca.Parent = sc
        return tb
    end

    -- ============================================
    -- COORDINATE TRACKER CONTENT
    -- ============================================

    Se("TELEPORT")

    Tb("Coordinates")

    Bt("Get Position", function()
        local pos = Feature.getPosition()
        if coordTextBox and pos then
            coordTextBox.Text = pos
        end
    end, "rbxassetid://131354680051916")

    Bt("Teleport to Coordinates", function()
        Feature.teleportToCoordinates()
    end, "rbxassetid://97702274768362")

    Bt("Copy Coordinates", function()
        Feature.copyCoordinates()
    end, "rbxassetid://122433689534467")

    Bt("Copy Teleport Script", function()
        Feature.copyTeleportScript()
    end, "rbxassetid://116940961775460")

    Bt("Clear", function()
        Feature.clearCoordinates()
        if coordTextBox then
            coordTextBox.Text = ""
        end
    end, "rbxassetid://119532706729140")

    Se("PLAYER")

    Sl("Walk Speed", 16, 200, "WalkSpeed", function(v)
        Feature.setWalkSpeed(v)
    end)

    Se("Actions")

    Bt("Rejoin Server", function()
        Feature.rejoinServer()
    end, "rbxassetid://106554243135514")

    local kB, kTx
    kB, kTx = Bt("Set Keybind: " .. gKN(C.Keybind), function()
        if S.WaitingKey then return end
        S.WaitingKey = true

        kTx.Text = "Press any key..."
        kB.BackgroundColor3 = Co.warn

        local conn
        local timeout

        timeout = task.delay(8, function()
            if S.WaitingKey then
                S.WaitingKey = false
                kTx.Text = "Set Keybind: " .. gKN(C.Keybind)
                kB.BackgroundColor3 = Co.cd
                if conn then conn:Disconnect() end
                S.Co.KeyCapture = nil
                Feature.showNotification("Keybind timeout!", false)
            end
        end)

        conn = U.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.UserInputType == Enum.UserInputType.Keyboard then
                task.cancel(timeout)
                C.Keybind = i.KeyCode
                kTx.Text = "Set Keybind: " .. gKN(C.Keybind)
                kB.BackgroundColor3 = Co.cd
                conn:Disconnect()
                S.Co.KeyCapture = nil
                -- Tunda sebentar: handler toggle UI (Main.lua) menerima tombol yang sama,
                -- jangan sampai window ikut ke-hide saat keybind baru diset.
                task.delay(0.15, function()
                    S.WaitingKey = false
                end)
                Feature.showNotification("Keybind set to " .. gKN(C.Keybind), true)
            end
        end)
        S.Co.KeyCapture = conn
    end, "rbxassetid://105330233440321")

    Bt("Destroy UI", function()
        if S.Destroy then S.Destroy() end
    end, "rbxassetid://137032142339509")

    -- Drag window lewat header
    hd.InputBegan:Connect(function(i)
        if not isPress(i) then return end
        local origin = i.Position
        local startPos = m.Position
        drags[hd] = function(pos)
            local dt = pos - origin
            m.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + dt.X,
                startPos.Y.Scale, startPos.Y.Offset + dt.Y
            )
        end
    end)

    -- ============================================
    -- SHOW UI
    -- ============================================
    m.Position = UDim2.new(1, 20, 0.5, -h/2)

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
        mB.Position = UDim2.new(0, -110, 0, 10)
        mB.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        mB.BackgroundTransparency = 1
        mB.BorderSizePixel = 0
        mB.Parent = g

        Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 16)

        local mStroke = Instance.new("UIStroke", mB)
        mStroke.Color = Color3.fromRGB(60, 60, 70)
        mStroke.Thickness = 1.5
        mStroke.Transparency = 1

        local mI = Instance.new("ImageLabel")
        mI.Size = UDim2.new(0, 20, 0, 20)
        mI.Position = UDim2.new(0, 8, 0.5, -10)
        mI.BackgroundTransparency = 1
        mI.Image = "rbxassetid://114167695335193"
        mI.ImageColor3 = Color3.fromRGB(255, 255, 255)
        mI.ImageTransparency = 1
        mI.Parent = mB

        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -36, 1, 0)
        btnText.Position = UDim2.new(0, 32, 0, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = "Hide"
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.TextTransparency = 1
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

        -- Draggable, dengan deteksi klik vs drag
        local wasDragged = false

        mT.InputBegan:Connect(function(input)
            if not isPress(input) then return end
            local origin = input.Position
            local startPos = mB.Position
            wasDragged = false
            drags[mT] = function(pos)
                local delta = pos - origin
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                    wasDragged = true
                end
                mB.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        mT.InputEnded:Connect(function(input)
            if not isPress(input) then return end
            drags[mT] = nil

            if not wasDragged then
                m.Visible = not m.Visible
                Feature.playSound(SOUND_CLICK, m.Visible and 0.5 or 0.4)

                if m.Visible then
                    btnText.Text = "Hide"
                    mI.Image = "rbxassetid://114167695335193"
                else
                    btnText.Text = "Show"
                    mI.Image = "rbxassetid://99334701468696"
                end

                T:Create(mB, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 95, 0, 30)
                }):Play()
                task.delay(0.1, function()
                    T:Create(mB, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
                        Size = UDim2.new(0, 100, 0, 32)
                    }):Play()
                end)
            end
        end)

        mT.MouseEnter:Connect(function()
            if not drags[mT] then
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

        -- Animasi masuk
        T:Create(mB, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = BUTTON_TRANSPARENCY
        }):Play()
        T:Create(btnText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        T:Create(mI, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
        T:Create(mStroke, TweenInfo.new(0.4), {Transparency = 0.3}):Play()
    end

    -- Animasi masuk window
    T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    }):Play()

    task.delay(0.4, function()
        Feature.showNotification("SynceHub initialized successfully!", true)
    end)
end

return TabContent
