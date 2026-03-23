-- AreYouSmartTabs.lua
-- SynceHub - UI Creation (Are You Smart? Auto Answer)

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
    Minimize = "rbxassetid://6895079853",
    Success  = "rbxassetid://6026984224",
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

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName, gameName)
    C       = config
    S       = state
    Feature = featureModule
    gKN     = getKeyName

    if S.G then S.G:Destroy() end

    local sS = workspace.CurrentCamera.ViewportSize
    local w  = isMobile and math.min(310, sS.X - 24) or 320
    local h  = isMobile and math.min(500, sS.Y - 100) or 460
    local bH = isMobile and 46 or 44
    local p  = 12
    local fS = isMobile and 14 or 13

    -- Color scheme
    local Co = {
        bg   = Color3.fromRGB(20,  20,  25),
        cd   = Color3.fromRGB(30,  30,  35),
        ch   = Color3.fromRGB(40,  40,  45),
        ac   = Color3.fromRGB(0,   122, 255),
        al   = Color3.fromRGB(25,  45,  70),
        tx   = Color3.fromRGB(240, 240, 245),
        ts   = Color3.fromRGB(150, 150, 160),
        br   = Color3.fromRGB(50,  50,  55),
        sc   = Color3.fromRGB(120, 120, 130),
        warn = Color3.fromRGB(88,  101, 242),
        ok   = Color3.fromRGB(100, 220, 140),
    }

    -- ── ScreenGui ─────────────────────────────────────────────────────
    local g = Instance.new("ScreenGui")
    g.Name           = "SynceHub"
    g.ResetOnSpawn   = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ── Main Frame ────────────────────────────────────────────────────
    local m = Instance.new("Frame")
    m.Name               = "Main"
    m.Size               = UDim2.new(0, w, 0, h)
    m.Position           = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3   = Co.bg
    m.BorderSizePixel    = 0
    m.ClipsDescendants   = true
    m.Parent             = g

    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16)

    local sh = Instance.new("ImageLabel")
    sh.Size               = UDim2.new(1, 30, 1, 30)
    sh.Position           = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image              = "rbxassetid://5554236805"
    sh.ImageColor3        = Color3.new(0, 0, 0)
    sh.ImageTransparency  = 0.3
    sh.ScaleType          = Enum.ScaleType.Slice
    sh.SliceCenter        = Rect.new(23, 23, 277, 277)
    sh.ZIndex             = 0
    sh.Parent             = m

    -- ── Header ────────────────────────────────────────────────────────
    local hd = Instance.new("Frame")
    hd.Size                  = UDim2.new(1, 0, 0, 52)
    hd.BackgroundTransparency = 1
    hd.Parent                = m

    local tL = Instance.new("TextLabel")
    tL.Size               = UDim2.new(1, -100, 0, 20)
    tL.Position           = UDim2.new(0, p, 0, 12)
    tL.BackgroundTransparency = 1
    tL.Text               = "SynceHub"
    tL.TextColor3         = Co.tx
    tL.Font               = Enum.Font.GothamBold
    tL.TextSize           = 18
    tL.TextXAlignment     = Enum.TextXAlignment.Left
    tL.Parent             = hd

    local st = Instance.new("TextLabel")
    st.Size               = UDim2.new(1, -100, 0, 14)
    st.Position           = UDim2.new(0, p, 0, 33)
    st.BackgroundTransparency = 1
    st.Text               = (gameName or "Are You Smart?") .. " | " .. version
    st.TextColor3         = Co.ts
    st.Font               = Enum.Font.Gotham
    st.TextSize           = 11
    st.TextXAlignment     = Enum.TextXAlignment.Left
    st.Parent             = hd

    -- Close button
    local clBtn = Instance.new("TextButton")
    clBtn.Size            = UDim2.new(0, 32, 0, 32)
    clBtn.Position        = UDim2.new(1, -p-32, 0, 10)
    clBtn.BackgroundColor3 = Co.ch
    clBtn.Text            = "×"
    clBtn.TextColor3      = Co.ts
    clBtn.Font            = Enum.Font.GothamBold
    clBtn.TextSize        = 20
    clBtn.Parent          = hd
    Instance.new("UICorner", clBtn).CornerRadius = UDim.new(0, 10)

    -- Minimize button
    local cb = Instance.new("TextButton")
    cb.Size               = UDim2.new(0, 32, 0, 32)
    cb.Position           = UDim2.new(1, -p-70, 0, 10)
    cb.BackgroundColor3   = Co.ch
    cb.Text               = "−"
    cb.TextColor3         = Co.ts
    cb.Font               = Enum.Font.GothamBold
    cb.TextSize           = 16
    cb.Parent             = hd
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 10)

    local mn  = false
    local fSz = m.Size

    -- ── Confirm Dialog ────────────────────────────────────────────────
    local function showConfirmDialog()
        if m:FindFirstChild("ConfirmBlur") then return end

        if mn then
            mn = false
            T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = fSz}):Play()
            cb.Text = "−"
            task.wait(0.3)
        end

        local blur = Instance.new("Frame")
        blur.Name            = "ConfirmBlur"
        blur.Size            = UDim2.new(1, 0, 1, 0)
        blur.BackgroundColor3 = Color3.new(0, 0, 0)
        blur.BackgroundTransparency = 0.5
        blur.BorderSizePixel = 0
        blur.ZIndex          = 2000
        blur.Parent          = m
        Instance.new("UICorner", blur).CornerRadius = UDim.new(0, 16)

        local blocker = Instance.new("TextButton")
        blocker.Size               = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text               = ""
        blocker.ZIndex             = 2000
        blocker.Active             = true
        blocker.AutoButtonColor    = false
        blocker.Parent             = blur

        local dialog = Instance.new("Frame")
        dialog.Size               = UDim2.new(0, 280, 0, 140)
        dialog.Position           = UDim2.new(0.5, -140, 0.5, -70)
        dialog.BackgroundColor3   = Co.cd
        dialog.BackgroundTransparency = 0.3
        dialog.BorderSizePixel    = 0
        dialog.ZIndex             = 2001
        dialog.Parent             = blur
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)

        local glassLayer = Instance.new("Frame")
        glassLayer.Size             = UDim2.new(1, 0, 1, 0)
        glassLayer.BackgroundColor3 = Co.cd
        glassLayer.BackgroundTransparency = 0.4
        glassLayer.BorderSizePixel  = 0
        glassLayer.ZIndex           = 2000
        glassLayer.Parent           = dialog
        Instance.new("UICorner", glassLayer).CornerRadius = UDim.new(0, 14)

        local dialogStroke = Instance.new("UIStroke", dialog)
        dialogStroke.Color       = Co.br
        dialogStroke.Thickness   = 1
        dialogStroke.Transparency = 0.3

        local shadow = Instance.new("ImageLabel")
        shadow.Size               = UDim2.new(1, 20, 1, 20)
        shadow.Position           = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image              = "rbxassetid://5554236805"
        shadow.ImageColor3        = Color3.new(0, 0, 0)
        shadow.ImageTransparency  = 0.6
        shadow.ScaleType          = Enum.ScaleType.Slice
        shadow.SliceCenter        = Rect.new(23, 23, 277, 277)
        shadow.ZIndex             = 2000
        shadow.Parent             = dialog

        local icon = Instance.new("ImageLabel")
        icon.Size                = UDim2.new(0, 18, 0, 18)
        icon.Position            = UDim2.new(1, -26, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image               = "rbxassetid://101745201658882"
        icon.ImageColor3         = Co.ts
        icon.ZIndex              = 2002
        icon.Parent              = dialog

        local title = Instance.new("TextLabel")
        title.Size               = UDim2.new(1, -45, 0, 24)
        title.Position           = UDim2.new(0, 16, 0, 12)
        title.BackgroundTransparency = 1
        title.Text               = "Close Window"
        title.TextColor3         = Co.tx
        title.Font               = Enum.Font.GothamBold
        title.TextSize           = 16
        title.TextXAlignment     = Enum.TextXAlignment.Left
        title.ZIndex             = 2002
        title.Parent             = dialog

        local desc = Instance.new("TextLabel")
        desc.Size                = UDim2.new(1, -32, 0, 36)
        desc.Position            = UDim2.new(0, 16, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Text                = "Do you want to close this window?\nYou will not be able to open it again."
        desc.TextColor3          = Co.tx
        desc.Font                = Enum.Font.Gotham
        desc.TextSize            = 14
        desc.TextWrapped         = true
        desc.TextXAlignment      = Enum.TextXAlignment.Left
        desc.TextYAlignment      = Enum.TextYAlignment.Top
        desc.ZIndex              = 2002
        desc.Parent              = dialog

        local btnContainer = Instance.new("Frame")
        btnContainer.Size                = UDim2.new(1, -32, 0, 36)
        btnContainer.Position            = UDim2.new(0, 16, 1, -44)
        btnContainer.BackgroundTransparency = 1
        btnContainer.ZIndex              = 2002
        btnContainer.Parent              = dialog

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size            = UDim2.new(0.48, 0, 1, 0)
        cancelBtn.BackgroundColor3 = Co.ch
        cancelBtn.Text            = "Cancel"
        cancelBtn.TextColor3      = Co.tx
        cancelBtn.Font            = Enum.Font.GothamBold
        cancelBtn.TextSize        = 13
        cancelBtn.ZIndex          = 2003
        cancelBtn.Parent          = btnContainer
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size            = UDim2.new(0.48, 0, 1, 0)
        confirmBtn.Position        = UDim2.new(0.52, 0, 0, 0)
        confirmBtn.BackgroundColor3 = Co.ac
        confirmBtn.Text            = "Close Window"
        confirmBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
        confirmBtn.Font            = Enum.Font.GothamBold
        confirmBtn.TextSize        = 13
        confirmBtn.ZIndex          = 2003
        confirmBtn.Parent          = btnContainer
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

        -- Fade in
        blur.BackgroundTransparency   = 1
        dialog.BackgroundTransparency = 1
        glassLayer.BackgroundTransparency = 1
        dialogStroke.Transparency     = 1
        shadow.ImageTransparency      = 1
        icon.ImageTransparency        = 1
        title.TextTransparency        = 1
        desc.TextTransparency         = 1
        cancelBtn.BackgroundTransparency = 1
        cancelBtn.TextTransparency    = 1
        confirmBtn.BackgroundTransparency = 1
        confirmBtn.TextTransparency   = 1

        T:Create(blur,       TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.5}):Play()
        T:Create(dialog,     TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.3}):Play()
        T:Create(glassLayer, TweenInfo.new(0.25), {BackgroundTransparency = 0.4}):Play()
        T:Create(dialogStroke, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
        T:Create(shadow,     TweenInfo.new(0.25), {ImageTransparency = 0.6}):Play()
        T:Create(icon,       TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
        T:Create(title,      TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        T:Create(desc,       TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        T:Create(cancelBtn,  TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        T:Create(confirmBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        playSound(Sounds.Click, 0.3)

        cancelBtn.MouseEnter:Connect(function()  T:Create(cancelBtn,  TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
        cancelBtn.MouseLeave:Connect(function()  T:Create(cancelBtn,  TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)
        confirmBtn.MouseEnter:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 144, 255)}):Play() end)
        confirmBtn.MouseLeave:Connect(function() T:Create(confirmBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ac}):Play() end)

        local function fadeOut(cb)
            T:Create(blur,       TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            T:Create(dialog,     TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            T:Create(glassLayer, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            T:Create(cancelBtn,  TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            T:Create(confirmBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.2)
            blur:Destroy()
            if cb then cb() end
        end

        cancelBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.3)
            fadeOut()
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            fadeOut(function()
                if Feature and Feature.resetAllFeatures then
                    pcall(Feature.resetAllFeatures)
                end
                S.U = true
                _G.SynceHubAreYouSmartLoaded = false
                for _, conn in pairs(S.Co) do pcall(function() conn:Disconnect() end) end
                Feature.cleanup()
                if S.G  then S.G:Destroy()  end
                if S.Mb then S.Mb:Destroy() end
            end)
        end)
    end

    clBtn.MouseButton1Click:Connect(showConfirmDialog)
    clBtn.MouseEnter:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
    clBtn.MouseLeave:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)

    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.3)
        mn = not mn
        T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = mn and UDim2.new(0, w, 0, 52) or fSz}):Play()
        cb.Text = mn and "+" or "−"
    end)

    -- ── Divider ───────────────────────────────────────────────────────
    local dv = Instance.new("Frame")
    dv.Size            = UDim2.new(1, -p*2, 0, 1)
    dv.Position        = UDim2.new(0, p, 0, 51)
    dv.BackgroundColor3 = Co.br
    dv.BorderSizePixel = 0
    dv.Parent          = m

    -- ── Scroll Container ──────────────────────────────────────────────
    local sc = Instance.new("ScrollingFrame")
    sc.Size                  = UDim2.new(1, -4, 1, -60)
    sc.Position              = UDim2.new(0, 2, 0, 56)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness    = 2
    sc.ScrollBarImageColor3  = Co.br
    sc.CanvasSize            = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sc.ClipsDescendants      = true
    sc.Parent                = m

    local sP = Instance.new("UIPadding", sc)
    sP.PaddingLeft   = UDim.new(0, p - 2)
    sP.PaddingRight  = UDim.new(0, p + 2)
    sP.PaddingTop    = UDim.new(0, 2)
    sP.PaddingBottom = UDim.new(0, p)

    local ly = Instance.new("UIListLayout", sc)
    ly.Padding    = UDim.new(0, 6)
    ly.SortOrder  = Enum.SortOrder.LayoutOrder

    local ord = 0
    local function nO() ord = ord + 1 return ord end

    -- ── UI Element Helpers ────────────────────────────────────────────

    -- Section label
    local function Se(n)
        local s = Instance.new("TextLabel")
        s.Size               = UDim2.new(1, 0, 0, 22)
        s.BackgroundTransparency = 1
        s.Text               = string.upper(n)
        s.TextColor3         = Co.sc
        s.Font               = Enum.Font.GothamBold
        s.TextSize           = 10
        s.TextXAlignment     = Enum.TextXAlignment.Left
        s.LayoutOrder        = nO()
        s.Parent             = sc
    end

    -- Toggle
    local function Tg(n, cK, callback)
        local ca = Instance.new("Frame")
        ca.Size            = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder     = nO()
        ca.Parent          = sc

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color        = Co.br

        local lb = Instance.new("TextLabel")
        lb.Size               = UDim2.new(1, -100, 1, 0)
        lb.Position           = UDim2.new(0, 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text               = n
        lb.TextColor3         = Co.tx
        lb.Font               = Enum.Font.GothamBold
        lb.TextSize           = fS
        lb.TextXAlignment     = Enum.TextXAlignment.Left
        lb.TextYAlignment     = Enum.TextYAlignment.Center
        lb.Parent             = ca

        local tg = Instance.new("TextButton")
        tg.Size            = UDim2.new(0, 44, 0, 24)
        tg.Position        = UDim2.new(1, -56, 0.5, -12)
        tg.BackgroundColor3 = C[cK] and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(60, 60, 65)
        tg.Text            = ""
        tg.Parent          = ca
        Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)

        local tb = Instance.new("Frame")
        tb.Size            = UDim2.new(0, 20, 0, 20)
        tb.Position        = C[cK] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        tb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tb.Parent          = tg
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
            if callback then callback(C[cK]) end
        end)

        return ca
    end

    -- Button
    local function Bt(n, cl, ico)
        local b = Instance.new("TextButton")
        b.Size            = UDim2.new(1, 0, 0, bH)
        b.BackgroundColor3 = Co.cd
        b.Text            = ""
        b.LayoutOrder     = nO()
        b.Parent          = sc

        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", b).Color        = Co.br

        if ico then
            local ic = Instance.new("ImageLabel")
            ic.Size               = UDim2.new(0, 20, 0, 20)
            ic.Position           = UDim2.new(1, -34, 0.5, -10)
            ic.BackgroundTransparency = 1
            ic.Image              = ico
            ic.ImageColor3        = Co.ts
            ic.Parent             = b
        end

        local tx = Instance.new("TextLabel")
        tx.Size               = UDim2.new(1, -50, 1, 0)
        tx.Position           = UDim2.new(0, 14, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text               = n
        tx.TextColor3         = Co.tx
        tx.Font               = Enum.Font.GothamBold
        tx.TextSize           = fS
        tx.TextXAlignment     = Enum.TextXAlignment.Left
        tx.Parent             = b

        b.MouseEnter:Connect(function()  T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)
        b.MouseLeave:Connect(function()  T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
        b.MouseButton1Click:Connect(function() playSound(Sounds.Click, 0.4); cl() end)
        return b
    end

    -- Info row (read-only display, stores label ref in S[sKey])
    local function Inf(label, sKey, defaultVal, defaultColor)
        local ca = Instance.new("Frame")
        ca.Size            = UDim2.new(1, 0, 0, 40)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder     = nO()
        ca.Parent          = sc

        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color        = Co.br

        local lbl = Instance.new("TextLabel")
        lbl.Size               = UDim2.new(0.42, 0, 1, 0)
        lbl.Position           = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = label
        lbl.TextColor3         = Co.ts
        lbl.Font               = Enum.Font.GothamBold
        lbl.TextSize           = fS - 1
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.TextYAlignment     = Enum.TextYAlignment.Center
        lbl.Parent             = ca

        local val = Instance.new("TextLabel")
        val.Size               = UDim2.new(0.58, -14, 1, 0)
        val.Position           = UDim2.new(0.42, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text               = defaultVal or "—"
        val.TextColor3         = defaultColor or Co.tx
        val.Font               = Enum.Font.GothamMedium
        val.TextSize           = fS - 1
        val.TextXAlignment     = Enum.TextXAlignment.Right
        val.TextTruncate       = Enum.TextTruncate.AtEnd
        val.Parent             = ca

        if sKey then S[sKey] = val end
        return ca, val
    end

    -- ── CONTENT ───────────────────────────────────────────────────────

    Se("AUTO ANSWER")

    Tg("Auto Answer", "AutoAnswerEnabled", function(val)
        Feature.toggleAutoAnswer(val)
    end)

    Se("LIVE STATUS")

    Inf("Status",   "StatusLabel",   "Idle",  Color3.fromRGB(140, 140, 160))
    Inf("Answer",   "AnswerLabel",   "—",     Co.tx)
    Inf("Question", "QuestionLabel", "—",     Co.ts)

    -- Progress bar (visual only, animated by Features)
    local progRow = Instance.new("Frame")
    progRow.Size            = UDim2.new(1, 0, 0, 36)
    progRow.BackgroundColor3 = Co.cd
    progRow.LayoutOrder     = nO()
    progRow.Parent          = sc
    Instance.new("UICorner", progRow).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", progRow).Color        = Co.br

    local progLbl = Instance.new("TextLabel")
    progLbl.Size               = UDim2.new(0.4, 0, 1, 0)
    progLbl.Position           = UDim2.new(0, 14, 0, 0)
    progLbl.BackgroundTransparency = 1
    progLbl.Text               = "AI Timer"
    progLbl.TextColor3         = Co.ts
    progLbl.Font               = Enum.Font.GothamBold
    progLbl.TextSize           = fS - 1
    progLbl.TextXAlignment     = Enum.TextXAlignment.Left
    progLbl.TextYAlignment     = Enum.TextYAlignment.Center
    progLbl.Parent             = progRow

    local timerBg = Instance.new("Frame")
    timerBg.Size            = UDim2.new(0.56, -14, 0, 6)
    timerBg.Position        = UDim2.new(0.44, 0, 0.5, -3)
    timerBg.BackgroundColor3 = Co.ch
    timerBg.BorderSizePixel = 0
    timerBg.Parent          = progRow
    Instance.new("UICorner", timerBg).CornerRadius = UDim.new(1, 0)

    local timerFill = Instance.new("Frame")
    timerFill.Name           = "TimerFill"
    timerFill.Size           = UDim2.new(0, 0, 1, 0)
    timerFill.BackgroundColor3 = Co.ok
    timerFill.BorderSizePixel = 0
    timerFill.Parent         = timerBg
    Instance.new("UICorner", timerFill).CornerRadius = UDim.new(1, 0)

    -- Store timer fill ref in S for Features to animate
    S.TimerFill = timerFill

    Se("API KEY")

    -- Show API key status (not the key itself)
    local apiRow = Instance.new("Frame")
    apiRow.Size            = UDim2.new(1, 0, 0, 40)
    apiRow.BackgroundColor3 = Co.cd
    apiRow.LayoutOrder     = nO()
    apiRow.Parent          = sc
    Instance.new("UICorner", apiRow).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", apiRow).Color        = Co.br

    local apiLbl = Instance.new("TextLabel")
    apiLbl.Size               = UDim2.new(0.42, 0, 1, 0)
    apiLbl.Position           = UDim2.new(0, 14, 0, 0)
    apiLbl.BackgroundTransparency = 1
    apiLbl.Text               = "Groq Key"
    apiLbl.TextColor3         = Co.ts
    apiLbl.Font               = Enum.Font.GothamBold
    apiLbl.TextSize           = fS - 1
    apiLbl.TextXAlignment     = Enum.TextXAlignment.Left
    apiLbl.TextYAlignment     = Enum.TextYAlignment.Center
    apiLbl.Parent             = apiRow

    local apiStatus = Instance.new("TextLabel")
    apiStatus.Size               = UDim2.new(0.58, -14, 1, 0)
    apiStatus.Position           = UDim2.new(0.42, 0, 0, 0)
    apiStatus.BackgroundTransparency = 1
    apiStatus.TextXAlignment     = Enum.TextXAlignment.Right
    apiStatus.Font               = Enum.Font.GothamMedium
    apiStatus.TextSize           = fS - 1
    apiStatus.TextTruncate       = Enum.TextTruncate.AtEnd
    apiStatus.Parent             = apiRow

    -- Set API key status display
    if C.APIKey and C.APIKey ~= "" and C.APIKey ~= "YOUR_GROQ_API_KEY_HERE" then
        apiStatus.Text       = "✓ Configured"
        apiStatus.TextColor3 = Co.ok
    else
        apiStatus.Text       = "✗ Not set"
        apiStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end

    local apiHint = Instance.new("TextLabel")
    apiHint.Size               = UDim2.new(1, 0, 0, 20)
    apiHint.BackgroundTransparency = 1
    apiHint.Text               = "Set via: getgenv().API_KEY = \"your-key\""
    apiHint.TextColor3         = Color3.fromRGB(90, 90, 100)
    apiHint.Font               = Enum.Font.Gotham
    apiHint.TextSize           = 10
    apiHint.TextXAlignment     = Enum.TextXAlignment.Left
    apiHint.LayoutOrder        = nO()
    apiHint.Parent             = sc

    Se("ACTIONS")

    kB = Bt("Set Keybind: " .. gKN(C.Keybind), function()
        if S.WaitingKey then return end
        S.WaitingKey = true

        local tx = kB:FindFirstChild("TextLabel")
        if tx then tx.Text = "Press any key..." end
        kB.BackgroundColor3 = Co.warn

        local conn, timeout

        timeout = task.delay(8, function()
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
        _G.SynceHubAreYouSmartLoaded = false
        for _, conn in pairs(S.Co) do pcall(function() conn:Disconnect() end) end
        Feature.cleanup()
        if S.G  then S.G:Destroy()  end
        if S.Mb then S.Mb:Destroy() end
    end, "rbxassetid://137032142339509")

    -- ── Dragging ──────────────────────────────────────────────────────
    local dSt, sPo
    hd.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dSt = i.Position; sPo = m.Position
        end
    end)
    hd.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dSt = nil
        end
    end)
    S.Co.Drag = U.InputChanged:Connect(function(i)
        if dSt and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dt = i.Position - dSt
            m.Position = UDim2.new(sPo.X.Scale, sPo.X.Offset + dt.X, sPo.Y.Scale, sPo.Y.Offset + dt.Y)
        end
    end)

    -- ── Spawn animation ───────────────────────────────────────────────
    m.Position = UDim2.new(1, 20, 0.5, -h/2)

    pcall(function() g.Parent = game:GetService("CoreGui") end)
    if not g.Parent then g.Parent = L:WaitForChild("PlayerGui") end

    S.G = g

    -- ── Mobile button ─────────────────────────────────────────────────
    if isMobile then
        local BT = 0.10
        local mB = Instance.new("Frame")
        mB.Size            = UDim2.new(0, 100, 0, 32)
        mB.Position        = UDim2.new(0, 10, 0, 10)
        mB.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        mB.BackgroundTransparency = BT
        mB.BorderSizePixel = 0
        mB.Parent          = g
        Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 16)

        local mStroke = Instance.new("UIStroke", mB)
        mStroke.Color = Color3.fromRGB(60, 60, 70); mStroke.Thickness = 1.5; mStroke.Transparency = 0.3

        local mI = Instance.new("ImageLabel")
        mI.Size = UDim2.new(0, 20, 0, 20); mI.Position = UDim2.new(0, 8, 0.5, -10)
        mI.BackgroundTransparency = 1; mI.Image = "rbxassetid://114167695335193"
        mI.ImageColor3 = Color3.fromRGB(255, 255, 255); mI.Parent = mB

        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -36, 1, 0); btnText.Position = UDim2.new(0, 32, 0, 0)
        btnText.BackgroundTransparency = 1; btnText.Text = "Hide"
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255); btnText.Font = Enum.Font.GothamBold
        btnText.TextSize = 15; btnText.TextXAlignment = Enum.TextXAlignment.Center
        btnText.TextYAlignment = Enum.TextYAlignment.Center; btnText.Parent = mB

        local mT = Instance.new("TextButton")
        mT.Size = UDim2.new(1, 0, 1, 0); mT.BackgroundTransparency = 1; mT.Text = ""; mT.Parent = mB

        local dragging, dragStart, startPos, wasDragged = false, nil, nil, false

        mT.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = mB.Position; wasDragged = false
            end
        end)
        mT.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if not wasDragged then
                    m.Visible = not m.Visible
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
                local delta = input.Position - dragStart
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then wasDragged = true end
                mB.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        S.Mb = mB

        mB.Position = UDim2.new(0, -110, 0, 10)
        mB.BackgroundTransparency = 1
        btnText.TextTransparency = 1; mI.ImageTransparency = 1; mStroke.Transparency = 1
        task.wait(0.3)
        T:Create(mB,      TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = BT}):Play()
        T:Create(btnText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        T:Create(mI,      TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
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
