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
    Minimize = "rbxassetid://6895079853",
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

function TabContent.createUI(config, state, version, isMobile, featureModule, getKeyName, gameName)
    C = config
    S = state
    Feature = featureModule
    gKN = getKeyName

    if S.G then S.G:Destroy() end

    local sS = workspace.CurrentCamera.ViewportSize
    local w  = isMobile and math.min(310, sS.X - 24) or 320
    -- UI lebih kecil karena cuma 1 fitur
    local h  = isMobile and math.min(260, sS.Y - 100) or 240
    local bH = isMobile and 46 or 44
    local p  = 12
    local fS = isMobile and 14 or 13

    -- Color scheme
    local Co = {
        bg   = Color3.fromRGB(20, 20, 25),
        cd   = Color3.fromRGB(30, 30, 35),
        ch   = Color3.fromRGB(40, 40, 45),
        ac   = Color3.fromRGB(0, 122, 255),
        tx   = Color3.fromRGB(240, 240, 245),
        ts   = Color3.fromRGB(150, 150, 160),
        br   = Color3.fromRGB(50, 50, 55),
        sc   = Color3.fromRGB(120, 120, 130),
    }

    -- ScreenGui
    local g = Instance.new("ScreenGui")
    g.Name = "SynceHub"
    g.ResetOnSpawn = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    local m = Instance.new("Frame")
    m.Name = "Main"
    m.Size = UDim2.new(0, w, 0, h)
    m.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    m.BackgroundColor3 = Co.bg
    m.BorderSizePixel = 0
    m.ClipsDescendants = true
    m.Parent = g

    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 16)

    -- Drop shadow
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
    st.Text = (gameName or "Potato Idle") .. " | " .. version
    st.TextColor3 = Co.ts
    st.Font = Enum.Font.Gotham
    st.TextSize = 11
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = hd

    -- Close button
    local clBtn = Instance.new("TextButton")
    clBtn.Size = UDim2.new(0, 32, 0, 32)
    clBtn.Position = UDim2.new(1, -p - 32, 0, 10)
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
    cb.Position = UDim2.new(1, -p - 70, 0, 10)
    cb.BackgroundColor3 = Co.ch
    cb.Text = "−"
    cb.TextColor3 = Co.ts
    cb.Font = Enum.Font.GothamBold
    cb.TextSize = 16
    cb.Parent = hd
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 10)

    local mn = false
    local fSz = m.Size

    -- Confirm dialog saat close
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
        dialog.Size = UDim2.new(0, 260, 0, 130)
        dialog.Position = UDim2.new(0.5, -130, 0.5, -65)
        dialog.BackgroundColor3 = Co.cd
        dialog.BackgroundTransparency = 0.2
        dialog.BorderSizePixel = 0
        dialog.ZIndex = 2001
        dialog.Parent = blur
        Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 14)

        local dStroke = Instance.new("UIStroke", dialog)
        dStroke.Color = Co.br
        dStroke.Thickness = 1
        dStroke.Transparency = 0.3

        local dTitle = Instance.new("TextLabel")
        dTitle.Size = UDim2.new(1, -32, 0, 24)
        dTitle.Position = UDim2.new(0, 16, 0, 12)
        dTitle.BackgroundTransparency = 1
        dTitle.Text = "Close Window"
        dTitle.TextColor3 = Co.tx
        dTitle.Font = Enum.Font.GothamBold
        dTitle.TextSize = 15
        dTitle.TextXAlignment = Enum.TextXAlignment.Left
        dTitle.ZIndex = 2002
        dTitle.Parent = dialog

        local dDesc = Instance.new("TextLabel")
        dDesc.Size = UDim2.new(1, -32, 0, 32)
        dDesc.Position = UDim2.new(0, 16, 0, 40)
        dDesc.BackgroundTransparency = 1
        dDesc.Text = "Do you want to close this window?\nYou will not be able to open it again."
        dDesc.TextColor3 = Co.ts
        dDesc.Font = Enum.Font.Gotham
        dDesc.TextSize = 12
        dDesc.TextWrapped = true
        dDesc.TextXAlignment = Enum.TextXAlignment.Left
        dDesc.TextYAlignment = Enum.TextYAlignment.Top
        dDesc.ZIndex = 2002
        dDesc.Parent = dialog

        local btnC = Instance.new("Frame")
        btnC.Size = UDim2.new(1, -32, 0, 34)
        btnC.Position = UDim2.new(0, 16, 1, -42)
        btnC.BackgroundTransparency = 1
        btnC.ZIndex = 2002
        btnC.Parent = dialog

        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
        cancelBtn.BackgroundColor3 = Co.ch
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = Co.tx
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.TextSize = 13
        cancelBtn.ZIndex = 2003
        cancelBtn.Parent = btnC
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
        confirmBtn.Position = UDim2.new(0.52, 0, 0, 0)
        confirmBtn.BackgroundColor3 = Co.ac
        confirmBtn.Text = "Close"
        confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.TextSize = 13
        confirmBtn.ZIndex = 2003
        confirmBtn.Parent = btnC
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

        playSound(Sounds.Click, 0.3)

        cancelBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.3)
            blur:Destroy()
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            blur:Destroy()
            S.U = true
            _G.SynceHubLoaded = false
            for _, conn in pairs(S.Co) do
                pcall(function() conn:Disconnect() end)
            end
            Feature.cleanup()
            if S.G then S.G:Destroy() end
            if S.Mb then S.Mb:Destroy() end
        end)

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
    end

    -- Close & minimize events
    clBtn.MouseButton1Click:Connect(showConfirmDialog)
    clBtn.MouseEnter:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
    clBtn.MouseLeave:Connect(function() T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)

    cb.MouseButton1Click:Connect(function()
        playSound(Sounds.Minimize, 0.3)
        mn = not mn
        T:Create(m, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Size = mn and UDim2.new(0, w, 0, 52) or fSz
        }):Play()
        cb.Text = mn and "+" or "−"
    end)
    cb.MouseEnter:Connect(function() T:Create(cb, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
    cb.MouseLeave:Connect(function() T:Create(cb, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)

    -- Scrolling content area
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
    sP.PaddingLeft  = UDim.new(0, p - 2)
    sP.PaddingRight = UDim.new(0, p + 2)
    sP.PaddingTop   = UDim.new(0, 2)
    sP.PaddingBottom = UDim.new(0, p)
    sP.Parent = sc

    local ly = Instance.new("UIListLayout")
    ly.Padding = UDim.new(0, 6)
    ly.SortOrder = Enum.SortOrder.LayoutOrder
    ly.Parent = sc

    local ord = 0
    local function nO() ord = ord + 1 return ord end

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

    -- Toggle
    local function Tg(n, cK, callback)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()
        ca.Parent = sc
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -100, 1, 0)
        lb.Position = UDim2.new(0, 14, 0, 0)
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
            if callback then callback(C[cK]) end
        end)
    end

    -- Button
    local function Bt(n, cl)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, bH)
        b.BackgroundColor3 = Co.cd
        b.Text = ""
        b.LayoutOrder = nO()
        b.Parent = sc
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", b).Color = Co.br

        local tx = Instance.new("TextLabel")
        tx.Size = UDim2.new(1, -28, 1, 0)
        tx.Position = UDim2.new(0, 14, 0, 0)
        tx.BackgroundTransparency = 1
        tx.Text = n
        tx.TextColor3 = Co.tx
        tx.Font = Enum.Font.GothamBold
        tx.TextSize = fS
        tx.TextXAlignment = Enum.TextXAlignment.Left
        tx.Parent = b

        b.MouseEnter:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play() end)
        b.MouseLeave:Connect(function() T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play() end)
        b.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.4)
            cl()
        end)
    end

    -- ============================================
    -- CONTENT: POTATO IDLE - AUTO CLICK
    -- ============================================
    Se("Auto Click")
    Tg("Auto Click (Brutal Spam)", "AutoClick", function(v)
        Feature.toggleAutoClick(v)
    end)

    -- ============================================
    -- SETTINGS SECTION
    -- ============================================
    Se("Settings")

    -- Keybind button
    kB = nil
    Bt("Set Keybind: " .. gKN(C.Keybind), function()
        -- dummy, di-overwrite di bawah
    end)
    -- Overwrite dengan keybind logic
    do
        local lastBtn = sc:GetChildren()[#sc:GetChildren()]
        if lastBtn and lastBtn:IsA("TextButton") then
            local tx = lastBtn:FindFirstChildWhichIsA("TextLabel")
            local conn
            local timeout

            lastBtn.MouseButton1Click:Connect(function()
                if S.WaitingKey then return end
                S.WaitingKey = true
                lastBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                if tx then tx.Text = "Press any key..." end

                timeout = task.delay(5, function()
                    S.WaitingKey = false
                    if tx then tx.Text = "Set Keybind: " .. gKN(C.Keybind) end
                    lastBtn.BackgroundColor3 = Co.cd
                    if conn then conn:Disconnect() end
                    Feature.showNotification("Keybind timeout!", false)
                end)

                conn = U.InputBegan:Connect(function(i, gp)
                    if gp then return end
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        task.cancel(timeout)
                        C.Keybind = i.KeyCode
                        if tx then tx.Text = "Set Keybind: " .. gKN(C.Keybind) end
                        lastBtn.BackgroundColor3 = Co.cd
                        S.WaitingKey = false
                        conn:Disconnect()
                        Feature.showNotification("Keybind set to " .. gKN(C.Keybind), true)
                    end
                end)
            end)
            kB = lastBtn
        end
    end

    Bt("Destroy UI", function()
        S.U = true
        _G.SynceHubLoaded = false
        for _, conn in pairs(S.Co) do
            pcall(function() conn:Disconnect() end)
        end
        Feature.cleanup()
        if S.G then S.G:Destroy() end
        if S.Mb then S.Mb:Destroy() end
    end)

    -- ============================================
    -- DRAGGING SYSTEM
    -- ============================================
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

    -- ============================================
    -- PARENT & ANIMATE IN
    -- ============================================
    pcall(function() g.Parent = game:GetService("CoreGui") end)
    if not g.Parent then g.Parent = L:WaitForChild("PlayerGui") end
    S.G = g

    -- Mobile toggle button
    if isMobile then
        local TRANS = 0.10
        local mB = Instance.new("Frame")
        mB.Size = UDim2.new(0, 100, 0, 32)
        mB.Position = UDim2.new(0, 10, 0, 10)
        mB.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        mB.BackgroundTransparency = TRANS
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

        local dragging, dragStart, startPos, wasDragged = false, nil, nil, false
        mT.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position
                startPos = mB.Position; wasDragged = false
            end
        end)
        mT.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if not wasDragged then
                    m.Visible = not m.Visible
                    btnText.Text = m.Visible and "Hide" or "Show"
                    mI.Image = m.Visible and "rbxassetid://114167695335193" or "rbxassetid://99334701468696"
                end
            end
        end)
        U.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                             input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then wasDragged = true end
                mB.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
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
            Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = TRANS
        }):Play()
        T:Create(btnText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
        T:Create(mI, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
        T:Create(mStroke, TweenInfo.new(0.4), {Transparency = 0.3}):Play()
    end

    -- Slide-in animation
    m.Position = UDim2.new(1, 20, 0.5, -h/2)
    task.wait(0.1)
    T:Create(m, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    }):Play()

    task.wait(0.5)
    playSound(Sounds.Success, 0.4)
    Feature.showNotification("SynceHub initialized successfully!", true)
end

return TabContent
