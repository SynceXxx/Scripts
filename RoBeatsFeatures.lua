-- SynceHub - RoBeats Features

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local RS = game:GetService("ReplicatedStorage")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local W = game:GetService("Workspace")
local P = game:GetService("Players")
local L = P.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections = {}

-- Autoplayer variables
local track_system
local old_track_system_new
local autoplayer_active = false

local accuracy_bounds = {
    Perfect = -0, 
    Great = -100,
    Okay = -100
}

local accuracy_names = {"Perfect", "Great", "Okay"}
local accuracy = "Perfect"
local note_time_target = accuracy_bounds[accuracy]

-- ============================================
-- INITIALIZE
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
    
    -- Get track system on init
    pcall(function()
        for index, module in next, getloadedmodules() do 
            local module_value = require(module)
            
            if type(module_value) == "table" then 
                local new_function = rawget(module_value, "new")
                
                if new_function then 
                    local first_upvalue = getupvalues(new_function)[1]
                    
                    if type(first_upvalue) == "table" and rawget(first_upvalue, "twister") then 
                        track_system = module_value
                        old_track_system_new = track_system.new
                        break
                    end
                end
            end
        end
    end)
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
function Feature.showNotification(m, s)
    if not S.G then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = s and "rbxassetid://6026984224" or "rbxassetid://6026984224"
    sound.Volume = s and 0.5 or 0.4
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
    
    spawn(function()
        local n = S.G:FindFirstChild("NotifContainer")
        if not n then
            n = Instance.new("Frame")
            n.Name = "NotifContainer"
            n.Size = UDim2.new(0, 280, 1, 0)
            n.Position = UDim2.new(1, -290, 0, 10)
            n.BackgroundTransparency = 1
            n.ZIndex = 1000
            n.Parent = S.G
            
            local l = Instance.new("UIListLayout")
            l.Padding = UDim.new(0, 8)
            l.SortOrder = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Top
            l.Parent = n
        end
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel = 0
        f.ZIndex = 1001
        f.LayoutOrder = #S.NotifQueue + 1
        f.Parent = n
        
        table.insert(S.NotifQueue, f)
        
        local c = Instance.new("UICorner", f)
        c.CornerRadius = UDim.new(0, 12)
        
        local st = Instance.new("UIStroke", f)
        st.Color = Color3.fromRGB(200, 200, 210)
        st.Thickness = 2
        st.Transparency = 0.5
        
        local i = Instance.new("ImageLabel")
        i.Size = UDim2.new(0, 24, 0, 24)
        i.Position = UDim2.new(0, 12, 0, 12)
        i.BackgroundTransparency = 1
        i.Image = s and "rbxassetid://140507950554297" or "rbxassetid://118025272389341"
        i.ImageColor3 = Color3.fromRGB(200, 200, 210)
        i.ZIndex = 1002
        i.Parent = f
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -52, 1, 0)
        t.Position = UDim2.new(0, 44, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = m
        t.TextColor3 = Color3.fromRGB(240, 240, 245)
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.ZIndex = 1002
        t.Parent = f
        
        local h = 48
        f.Position = UDim2.new(1, 20, 0, 0)
        T:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, h),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.4)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
        task.wait(2.5)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        T:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        T:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
        T:Create(st, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        task.wait(0.3)
        T:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        f:Destroy()
        
        for i, v in ipairs(S.NotifQueue) do
            if v == f then
                table.remove(S.NotifQueue, i)
                break
            end
        end
    end)
end

-- ============================================
-- ROBEATS AUTOPLAYER HELPER FUNCTIONS
-- ============================================

local function get_track_action_functions(track_system_instance)
    local press_track, release_track
    
    for index, track_function in next, track_system_instance do 
        if type(track_function) == "function" then 
            local constants = getconstants(track_function)
            
            if table.find(constants, "press") then 
                press_track = track_function
                
                if release_track then 
                    break
                end
            elseif table.find(constants, "release") then 
                release_track = track_function
                
                if press_track then 
                    break
                end
            end
        end
    end
    
    return press_track, release_track
end

local function get_local_track_system(session)
    local local_slot_index = getupvalue(session.set_local_game_slot, 1)
    
    for index, session_function in next, session do 
        if type(session_function) == "function" then 
            local object = getupvalues(session_function)[1]
            
            if type(object) == "table" and rawget(object, "count") and object:count() <= 4 then 
                return object:get(local_slot_index)
            end
        end
    end
end

-- ============================================
-- ROBEATS FEATURES
-- ============================================

-- Walk Speed
function Feature.updateWalkSpeed(speed)
    pcall(function()
        local humanoid = L.Character and L.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end)
end

-- Autoplayer Perfect+S (Toggle)
function Feature.toggleAutoplayer(enabled)
    if enabled then
        if autoplayer_active then return end
        
        if not track_system or not old_track_system_new then
            Feature.showNotification("Track system not found!", false)
            return
        end
        
        autoplayer_active = true
        
        -- Hook the track system
        track_system.new = function(...)
            local track_functions = old_track_system_new(...)
            local arguments = {...}
            
            if arguments[2]._players._slots:get(arguments[3])._name == L.Name then
                for index, track_function in next, track_functions do 
                    local upvalues = getupvalues(track_function)
                    
                    if type(upvalues[1]) == "table" and rawget(upvalues[1], "profilebegin") then 
                        local notes_table = upvalues[2]
                        
                        track_functions[index] = function(self, slot, session)
                            local local_track_system = get_local_track_system(session)
                            local press_track, release_track = get_track_action_functions(local_track_system)
                            
                            local test_press_name = getconstant(press_track, 10)
                            local test_release_name = getconstant(release_track, 6)
            
                            for note_index = 1, notes_table:count() do 
                                local note = notes_table:get(note_index)
                                
                                if note then 
                                    local test_press, test_release = note[test_press_name], note[test_release_name]
                                    
                                    local note_track_index = note:get_track_index(note_index)
                                    local pressed, press_result, press_delay = test_press(note)
                                    
                                    if pressed and press_delay >= note_time_target then
                                        press_track(local_track_system, session, note_track_index)
                                        
                                        session:debug_any_press()
                                        
                                        if rawget(note, "get_time_to_end") then
                                            delay(math.random(5, 18) / 100, function()
                                                release_track(local_track_system, session, note_track_index)
                                            end)
                                        end
                                    end
                                    
                                    if test_release then 
                                        local released, release_result, release_delay = test_release(note)
                                        
                                        if released and release_delay >= note_time_target then 
                                            delay(math.random(2, 5) / 100, function()
                                                release_track(local_track_system, session, note_track_index)
                                            end)
                                        end
                                    end
                                end
                            end
                            
                            return track_function(self, slot, session)
                        end
                    end
                end
            end
            
            return track_functions
        end
        
        Feature.showNotification("Autoplayer enabled! (Perfect+S)", true)
    else
        if not autoplayer_active then return end
        
        -- Restore original function
        if track_system and old_track_system_new then
            track_system.new = old_track_system_new
        end
        
        autoplayer_active = false
        Feature.showNotification("Autoplayer disabled!", false)
    end
end

-- Player ESP (Red Highlight)
function Feature.togglePlayerESP(enabled)
    if enabled then
        if Connections.PlayerESP then return end
        
        local function addESP(player)
            if player == L then return end
            
            local char = player.Character
            if not char then return end
            
            if char:FindFirstChild("ESPHighlight") then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
        end
        
        for _, player in pairs(P:GetPlayers()) do
            if player.Character then
                addESP(player)
            end
            
            player.CharacterAdded:Connect(function(char)
                if C.PlayerESP then
                    task.wait(0.5)
                    addESP(player)
                end
            end)
        end
        
        Connections.PlayerESP = P.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                if C.PlayerESP then
                    task.wait(0.5)
                    addESP(player)
                end
            end)
        end)
        
        Connections.PlayerESPMonitor = R.Heartbeat:Connect(function()
            if not C.PlayerESP then return end
            
            for _, player in pairs(P:GetPlayers()) do
                if player ~= L and player.Character then
                    if not player.Character:FindFirstChild("ESPHighlight") then
                        addESP(player)
                    end
                end
            end
        end)
        
        Feature.showNotification("Player ESP enabled!", true)
    else
        for _, player in pairs(P:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        
        if Connections.PlayerESP then
            Connections.PlayerESP:Disconnect()
            Connections.PlayerESP = nil
        end
        
        if Connections.PlayerESPMonitor then
            Connections.PlayerESPMonitor:Disconnect()
            Connections.PlayerESPMonitor = nil
        end
        
        Feature.showNotification("Player ESP disabled!", false)
    end
end

-- Anti-AFK
function Feature.toggleAntiAFK(enabled)
    if enabled then
        if Connections.AntiAFK then return end
        
        Connections.AntiAFK = R.Heartbeat:Connect(function()
            task.wait(60)
            
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
        
        Feature.showNotification("Anti-AFK enabled!", true)
    else
        if Connections.AntiAFK then
            Connections.AntiAFK:Disconnect()
            Connections.AntiAFK = nil
        end
        Feature.showNotification("Anti-AFK disabled!", false)
    end
end

-- ============================================
-- CLEANUP FUNCTION
-- ============================================
function Feature.cleanup()
    -- Restore autoplayer
    if autoplayer_active and track_system and old_track_system_new then
        track_system.new = old_track_system_new
    end
    
    for name, conn in pairs(Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    Connections = {}
end

return Feature
