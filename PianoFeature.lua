-- SyncePiano_features.lua
-- SynceHub Piano Edition - Features & Engine

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local R = game:GetService("RunService")
local T = game:GetService("TweenService")
local P = game:GetService("Players")
local L = P.LocalPlayer
local W = game:GetService("Workspace")

local Remote = W:FindFirstChild("GlobalPianoConnector")

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections = {}
local UserLibrary = {}
local fileName = "SyncePianoVault.json"

-- ============================================
-- FILE SYSTEM
-- ============================================
local function saveToDisk()
    pcall(function() 
        writefile(fileName, HttpService:JSONEncode(UserLibrary)) 
    end)
end

local function loadFromDisk()
    if isfile(fileName) then
        local success, data = pcall(function() 
            return HttpService:JSONDecode(readfile(fileName)) 
        end)
        if success then UserLibrary = data end
    end
end

-- ============================================
-- KEY TRANSLATOR
-- ============================================
local NumMap = {
    ["0"]="Zero", ["1"]="One", ["2"]="Two", ["3"]="Three", ["4"]="Four", 
    ["5"]="Five", ["6"]="Six", ["7"]="Seven", ["8"]="Eight", ["9"]="Nine"
}

local ShiftMap = {
    ["!"]="1", ["@"]="2", ["#"]="3", ["$"]="4", ["%"]="5", ["^"]="6", 
    ["&"]="7", ["*"]="8", ["("]="9", [")"]="0", ["_"]="-", ["+"]="=", 
    ["{"]="[", ["}"]="]", ["|"]="\\", [":"]=";", ["\""]="'", 
    ["<"]=",", [">"]=".", ["?"]="/"
}

local ALL_KEYS = [[!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~]]

-- ============================================
-- INITIALIZE
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
    
    -- Load library from disk
    loadFromDisk()
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
-- PIANO ENGINE
-- ============================================
local function press(char)
    if not char or char == "" then return end
    
    -- Audio (Server)
    if Remote then
        local n = ALL_KEYS:find(char, 1, true)
        if n then 
            task.spawn(function() 
                Remote:FireServer("play", n + 23) 
            end) 
        end
    end

    -- Physical (Visuals)
    task.spawn(function()
        local isShift = false
        local k = char:upper()
        
        if NumMap[char] then 
            k = NumMap[char]
        elseif ShiftMap[char] then 
            isShift = true 
            local mapped = ShiftMap[char]
            k = NumMap[mapped] or mapped 
        elseif char:match("%u") then 
            isShift = true 
        end
        
        local vk = Enum.KeyCode[k] or Enum.KeyCode[char:upper()]
        if vk then
            if isShift then 
                VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game) 
            end
            VIM:SendKeyEvent(true, vk, false, game)
            
            task.delay(0.005, function()
                VIM:SendKeyEvent(false, vk, false, game)
                if isShift then 
                    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) 
                end
            end)
        end
    end)
end

-- ============================================
-- PLAYBACK CONTROL
-- ============================================
function Feature.togglePlayback(enabled)
    if enabled then
        if Connections.Playback then return end
        
        if C.CurrentSheet == "" then
            Feature.showNotification("Please paste a sheet first!", false)
            return false
        end
        
        C.IsPlaying = true
        
        Connections.Playback = task.spawn(function()
            local s = C.CurrentSheet:gsub("\n", " "):gsub("\r", " ")
            local i = 1
            local len = #s
            
            while i <= len and C.IsPlaying do
                local bpm = tonumber(C.BPM) or 160
                local waitT = 60 / bpm
                local char = s:sub(i, i)
                
                if char == "[" or char == "{" or char == "(" then
                    local endC = (char == "[") and "]" or (char == "{") and "}" or ")"
                    local close = s:find(endC, i)
                    if close then
                        local chord = s:sub(i+1, close-1)
                        for j=1, #chord do 
                            local c = chord:sub(j, j)
                            if ALL_KEYS:find(c, 1, true) then press(c) end
                        end
                        i = close
                        task.wait(waitT)
                    end
                elseif char == " " or char == "-" or char == "|" then
                    task.wait(waitT)
                elseif ALL_KEYS:find(char, 1, true) then
                    press(char)
                    task.wait(waitT)
                end
                i = i + 1
            end
            
            C.IsPlaying = false
            Feature.showNotification("Performance finished!", true)
        end)
        
        Feature.showNotification("Performance started!", true)
        return true
    else
        C.IsPlaying = false
        if Connections.Playback then
            task.cancel(Connections.Playback)
            Connections.Playback = nil
        end
        Feature.showNotification("Performance stopped!", false)
        return false
    end
end

-- ============================================
-- LIBRARY FUNCTIONS
-- ============================================
function Feature.addSong()
    if C.SongName == "" or C.CurrentSheet == "" then
        Feature.showNotification("Please enter song name and sheet!", false)
        return false
    end
    
    table.insert(UserLibrary, {
        Name = C.SongName,
        Sheet = C.CurrentSheet
    })
    
    C.SongName = ""
    saveToDisk()
    Feature.showNotification("Song saved to library!", true)
    return true
end

function Feature.loadSong(index)
    if UserLibrary[index] then
        C.CurrentSheet = UserLibrary[index].Sheet
        Feature.showNotification("Song loaded: " .. UserLibrary[index].Name, true)
        return UserLibrary[index].Sheet
    end
    return nil
end

function Feature.deleteSong(index)
    if UserLibrary[index] then
        local name = UserLibrary[index].Name
        table.remove(UserLibrary, index)
        saveToDisk()
        Feature.showNotification("Deleted: " .. name, false)
        return true
    end
    return false
end

function Feature.getLibrary()
    return UserLibrary
end

-- ============================================
-- CLEANUP FUNCTION
-- ============================================
function Feature.cleanup()
    C.IsPlaying = false
    for name, conn in pairs(Connections) do
        if conn then
            pcall(function() 
                if type(conn) == "thread" then
                    task.cancel(conn)
                else
                    conn:Disconnect() 
                end
            end)
        end
    end
    Connections = {}
end

return Feature
