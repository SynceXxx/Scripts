-- SynceHub - UI Creation and Tab Content (Skateboard Training)

local TabContent = {}

local U = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer

local C, S, Feature, gKN, V, GAME_NAME
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
    V = version
    GAME_NAME = gameName
    
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
    st.Text = (gameName or "Skateboard Training") .. " | " .. version
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

    -- Confirmation dialog (continued in next part due to length)
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
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -32, 0, 24)
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
            if S.G then S.G:Destroy() end
            if S.Mb then S.Mb:Destroy() end
        end)
    end
    
    clBtn.MouseButton1Click:Connect(function()
        showConfirmDialog()
    end)
    
    clBtn.MouseEnter:Connect(function()
        T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.cd}):Play()
    end)
    
    clBtn.MouseLeave:Connect(function()
        T:Create(clBtn, TweenInfo.new(0.15), {BackgroundColor3 = Co.ch}):Play()
    end)
    
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
        tx.Name = "Label"
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
    
    -- Slider function
    local function Sl(n, cK, min, max, callback)
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
        
        local vL = Instance.new("TextBox")
        vL.Size = UDim2.new(0, 60, 0, 24)
        vL.Position = UDim2.new(1, -74, 0, 6)
        vL.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        vL.Text = tostring(cK)
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
        sF.Size = UDim2.new((cK - min) / (max - min), 0, 1, 0)
        sF.BackgroundColor3 = Co.ac
        sF.BorderSizePixel = 0
        sF.Parent = sB
        
        Instance.new("UICorner", sF).CornerRadius = UDim.new(1, 0)
        
        local sN = Instance.new("Frame")
        sN.Size = UDim2.new(0, 16, 0, 16)
        sN.Position = UDim2.new((cK - min) / (max - min), -8, 0.5, -8)
        sN.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sN.BorderSizePixel = 0
        sN.Parent = sB
        
        Instance.new("UICorner", sN).CornerRadius = UDim.new(1, 0)
        
        local function updateSlider(val)
            val = math.clamp(val, min, max)
            vL.Text = tostring(val)
            local pct = (val - min) / (max - min)
            sF.Size = UDim2.new(pct, 0, 1, 0)
            sN.Position = UDim2.new(pct, -8, 0.5, -8)
        end
        
        vL.FocusLost:Connect(function()
            local val = tonumber(vL.Text)
            if val then
                val = math.clamp(val, min, max)
                updateSlider(val)
                if callback then callback(val) end
            else
                vL.Text = tostring(cK)
            end
        end)
        
        local dG = false
        sB.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dG = true
            end
        end)
        
        sB.InputEnded:Connect(function(i)
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
    
    -- Helper functions for tabs
    local function Tb(n)
        Se(n)
        return n
    end
    
    local function La(n)
        Se(n)
    end
    
    local function Txt(t, v)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, 36)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()
        ca.Parent = sc
        
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br
        
        local tL = Instance.new("TextLabel")
        tL.Size = UDim2.new(0.4, 0, 1, 0)
        tL.Position = UDim2.new(0, 14, 0, 0)
        tL.BackgroundTransparency = 1
        tL.Text = t
        tL.TextColor3 = Co.ts
        tL.Font = Enum.Font.GothamBold
        tL.TextSize = fS - 1
        tL.TextXAlignment = Enum.TextXAlignment.Left
        tL.TextYAlignment = Enum.TextYAlignment.Center
        tL.Parent = ca
        
        local vL = Instance.new("TextLabel")
        vL.Size = UDim2.new(0.55, 0, 1, 0)
        vL.Position = UDim2.new(0.45, 0, 0, 0)
        vL.BackgroundTransparency = 1
        vL.Text = v
        vL.TextColor3 = Co.tx
        vL.Font = Enum.Font.Gotham
        vL.TextSize = fS - 1
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.TextWrapped = true
        vL.TextYAlignment = Enum.TextYAlignment.Center
        vL.Parent = ca
        
        return ca
    end
    
    local function Sp()
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, 0, 0, 8)
        s.BackgroundTransparency = 1
        s.LayoutOrder = nO()
        s.Parent = sc
    end
    
    local function In(n, defaultVal, callback, ico)
        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, bH)
        ca.BackgroundColor3 = Co.cd
        ca.LayoutOrder = nO()
        ca.Parent = sc
        
        Instance.new("UICorner", ca).CornerRadius = UDim.new(0, 12)
        Instance.new("UIStroke", ca).Color = Co.br
        
        if ico then
            local ic = Instance.new("ImageLabel")
            ic.Size = UDim2.new(0, 22, 0, 22)
            ic.Position = UDim2.new(0, 14, 0.5, -11)
            ic.BackgroundTransparency = 1
            ic.Image = ico
            ic.ImageColor3 = Co.ts
            ic.Parent = ca
        end
        
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0.45, 0, 1, 0)
        lb.Position = UDim2.new(0, ico and 44 or 14, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text = n
        lb.TextColor3 = Co.tx
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = fS
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.TextYAlignment = Enum.TextYAlignment.Center
        lb.Parent = ca
        
        local ib = Instance.new("TextBox")
        ib.Size = UDim2.new(0.4, 0, 0, 32)
        ib.Position = UDim2.new(0.55, 0, 0.5, -16)
        ib.BackgroundColor3 = Co.ch
        ib.Text = defaultVal
        ib.TextColor3 = Co.tx
        ib.Font = Enum.Font.Gotham
        ib.TextSize = fS
        ib.TextXAlignment = Enum.TextXAlignment.Center
        ib.ClearTextOnFocus = false
        ib.PlaceholderText = "Enter value..."
        ib.Parent = ca
        
        Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 8)
        
        ib.FocusLost:Connect(function(enterPressed)
            if callback then
                callback(ib.Text)
            end
        end)
        
        return ca
    end
    
    -- ============================================
    -- SKATEBOARD TRAINING TAB CONTENT
    -- ============================================
    
    -- HOME TAB
    local function Se1()
        Tb("Home")
        
        Txt("Welcome!", "Skateboard Training Script")
        
        La("Quick Settings")
        
        Sl("Walk Speed", C.WalkSpeed, 16, 250, function(v)
            C.WalkSpeed = v
            Feature.updateWalkSpeed(v)
        end)
        
        Sp()
        
        La("Information")
        Txt("Developer", "SynceXxx")
        Txt("Version", V)
        Txt("Game", GAME_NAME)
        
        Sp()
    end
    
    -- LUCKY WHEEL TAB
    local function Se2()
        Tb("Lucky Wheel")
        
        La("Lucky Wheel Features")
        
        Tg("Auto Get Ticket", "LuckyTicket", function(v)
            Feature.toggleLuckyTicket(v)
        end, "81568695036839")
        
        Txt("Info", "Spams lucky_wheel_get_ticket")
        
        Sp()
    end
    
    -- TRAINING TAB
    local function Se3()
        Tb("Training")
        
        La("Training Features")
        
        Bt("Start Training", function()
            Feature.startTrain()
        end, "rbxassetid://99334698991677")
        
        Txt("Info", "Click to start training")
        
        Sp()
    end
    
    -- GACHA TAB
    local function Se4()
        Tb("Gacha Spin")
        
        La("Auto Spin Settings")
        
        In("Spin Amount", tostring(C.SpinAmount), function(v)
            local num = tonumber(v)
            if num and num >= 1 and num <= 999999 then
                C.SpinAmount = num
                Feature.showNotification("Spin amount set to " .. num, true)
            else
                Feature.showNotification("Invalid! Use 1-999999", false)
            end
        end, "rbxassetid://103451652006296")
        
        Sp()
        
        La("Auto Spin")
        
        Tg("Auto Spin", "AutoSpin", function(v)
            Feature.toggleAutoSpin(v)
        end, "113924612849076")
        
        Txt("Amount", tostring(C.SpinAmount) .. " per loop")
        
        Sp()
    end
    
    -- VISUAL TAB
    local function Se5()
        Tb("Visual")
        
        La("ESP Features")
        
        Tg("Player ESP", "PlayerESP", function(v)
            Feature.togglePlayerESP(v)
        end, "90630467986809")
        
        Txt("Info", "Red highlight on players")
        
        Sp()
    end
    
    -- SETTINGS TAB
    local function Se6()
        Tb("Settings")
        
        La("Misc")
        
        Tg("Anti-AFK", "AntiAFK", function(v)
            Feature.toggleAntiAFK(v)
        end, "107463064252998")
        
        Sp()
        
        La("Keybind")
        local tx
        kB = Bt("Set Keybind: " .. gKN(C.Keybind), function()
            if S.WaitingKey then return end
            S.WaitingKey = true
            
            kB.BackgroundColor3 = Co.warn
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
        
        tx = kB:FindFirstChild("Label")
        
        Sp()
        
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
        
        Sp()
    end
    
    -- Initialize all tabs
    Se1()
    Se2()
    Se3()
    Se4()
    Se5()
    Se6()
    
    -- Dragging system
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
    Feature.showNotification("SynceHub loaded!", true)
end

return TabContent
