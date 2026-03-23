-- AreYouSmartFeatures.lua
-- SynceHub - Are You Smart? Auto Answer Features

local Feature = {}

-- ============================================
-- SERVICES
-- ============================================
local T   = game:GetService("TweenService")
local P   = game:GetService("Players")
local H   = game:GetService("HttpService")
local RS  = game:GetService("ReplicatedStorage")
local L   = P.LocalPlayer

-- ============================================
-- VARIABLES
-- ============================================
local C, S
local Connections   = {}
local lastQuestion  = ""
local answerFired   = false
local currentThread = nil
local listenersReady = false

-- Game paths
local answer1Text    = nil
local answer2Text    = nil
local answer3Text    = nil
local questionObject = nil
local remoteEvent    = nil

-- ============================================
-- INITIALIZE
-- ============================================
function Feature.init(config, state)
    C = config
    S = state
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
function Feature.showNotification(m, s)
    if not S.G then return end

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6026984224"
    sound.Volume   = s and 0.5 or 0.4
    sound.Parent   = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)

    spawn(function()
        local n = S.G:FindFirstChild("NotifContainer")
        if not n then
            n          = Instance.new("Frame")
            n.Name     = "NotifContainer"
            n.Size     = UDim2.new(0, 280, 1, 0)
            n.Position = UDim2.new(1, -290, 0, 10)
            n.BackgroundTransparency = 1
            n.ZIndex   = 1000
            n.Parent   = S.G

            local l = Instance.new("UIListLayout")
            l.Padding           = UDim.new(0, 8)
            l.SortOrder         = Enum.SortOrder.LayoutOrder
            l.VerticalAlignment = Enum.VerticalAlignment.Top
            l.Parent = n
        end

        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 0)
        f.BackgroundColor3    = Color3.fromRGB(30, 30, 35)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel     = 0
        f.ZIndex       = 1001
        f.LayoutOrder  = #S.NotifQueue + 1
        f.Parent       = n

        table.insert(S.NotifQueue, f)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

        local st = Instance.new("UIStroke", f)
        st.Color       = Color3.fromRGB(200, 200, 210)
        st.Thickness   = 2
        st.Transparency = 0.5

        local i = Instance.new("ImageLabel")
        i.Size  = UDim2.new(0, 24, 0, 24)
        i.Position = UDim2.new(0, 12, 0, 12)
        i.BackgroundTransparency = 1
        i.Image  = s and "rbxassetid://140507950554297" or "rbxassetid://118025272389341"
        i.ImageColor3 = Color3.fromRGB(200, 200, 210)
        i.ZIndex = 1002
        i.Parent = f

        local t = Instance.new("TextLabel")
        t.Size   = UDim2.new(1, -52, 1, 0)
        t.Position = UDim2.new(0, 44, 0, 0)
        t.BackgroundTransparency = 1
        t.Text   = m
        t.TextColor3  = Color3.fromRGB(240, 240, 245)
        t.Font        = Enum.Font.GothamMedium
        t.TextSize    = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Center
        t.ZIndex = 1002
        t.Parent = f

        local h = 48
        f.Position = UDim2.new(1, 20, 0, 0)
        T:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, h), Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        task.wait(0.4)
        T:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
        task.wait(2.5)
        T:Create(f,  TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        T:Create(t,  TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        T:Create(i,  TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
        T:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.3)
        T:Create(f, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.3)
        f:Destroy()

        for idx, v in ipairs(S.NotifQueue) do
            if v == f then table.remove(S.NotifQueue, idx) break end
        end
    end)
end

-- ============================================
-- INTERNAL HELPERS
-- ============================================

local skipPhrases = {
    "", " ", "...", "round over", "game over", "waiting", "get ready",
    "starting", "time's up", "times up", "correct", "wrong", "next round",
    "loading", "prepare", "intermission", "well done", "nice job"
}

local function shouldSkip(text)
    if not text then return true end
    local trimmed = text:match("^%s*(.-)%s*$")
    if #trimmed < 8 then return true end
    local lower = trimmed:lower()
    for _, phrase in ipairs(skipPhrases) do
        if lower == phrase then return true end
    end
    return false
end

local function setLiveStatus(text, color)
    if S.StatusLabel then
        S.StatusLabel.Text       = text
        S.StatusLabel.TextColor3 = color or Color3.fromRGB(140, 140, 160)
    end
end

local function setLiveAnswer(text, color)
    if S.AnswerLabel then
        S.AnswerLabel.Text       = text
        S.AnswerLabel.TextColor3 = color or Color3.fromRGB(240, 240, 245)
    end
end

local function setLiveQuestion(text)
    if S.QuestionLabel then
        S.QuestionLabel.Text = text or "—"
    end
end

-- ── Delta-compatible HTTP ─────────────────────────────────────────────
local function httpRequest(options)
    if syn and syn.request then
        return syn.request(options)
    elseif http and http.request then
        return http.request(options)
    elseif http_request then
        return http_request(options)
    elseif request then
        return request(options)
    else
        error("No HTTP function available!")
    end
end

-- ── Ask AI for the correct answer ────────────────────────────────────
local function askAI(question, a1, a2, a3)
    local apiKey = C.APIKey
    if not apiKey or apiKey == "" or apiKey == "YOUR_GROQ_API_KEY_HERE" then
        setLiveStatus("No API Key set!", Color3.fromRGB(255, 80, 80))
        return nil
    end

    local safe = question:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n"," "):gsub("\r","")
    local s1 = a1:gsub('"', '\\"')
    local s2 = a2:gsub('"', '\\"')
    local s3 = a3:gsub('"', '\\"')

    local prompt = "Question: "..safe..". Options: 1) "..s1.." 2) "..s2.." 3) "..s3..". Reply with ONLY the exact text of the correct answer, nothing else."
    local body = '{"model":"llama-3.1-8b-instant","max_tokens":50,"messages":[{"role":"system","content":"You are a quiz answer bot. Given a question and 3 options, reply with ONLY the exact text of the correct option. No punctuation, no explanation."},{"role":"user","content":"'..prompt..'"}]}'

    for attempt = 1, 2 do
        local success, response = pcall(function()
            return httpRequest({
                Url    = "https://api.groq.com/openai/v1/chat/completions",
                Method = "POST",
                Headers = {
                    ["Content-Type"]  = "application/json",
                    ["Authorization"] = "Bearer " .. apiKey
                },
                Body = body
            })
        end)

        if not success then
            setLiveStatus("HTTP Error", Color3.fromRGB(255, 80, 80))
            warn("[AutoAnswer] Error: " .. tostring(response))
            if attempt < 2 then task.wait(0.5) end
        elseif response.StatusCode ~= 200 then
            setLiveStatus("HTTP " .. tostring(response.StatusCode), Color3.fromRGB(255, 80, 80))
            warn("[AutoAnswer] Status " .. response.StatusCode)
            if attempt < 2 then task.wait(0.5) end
        else
            local ok, data = pcall(function()
                return H:JSONDecode(response.Body)
            end)
            if ok and data and data.choices and data.choices[1] then
                local answer = data.choices[1].message and data.choices[1].message.content
                if answer then
                    return answer:match("^%s*(.-)%s*$")
                end
            else
                setLiveStatus("Parse Error", Color3.fromRGB(255, 80, 80))
            end
        end
    end
    return nil
end

-- ── Handle incoming question ──────────────────────────────────────────
local function handleQuestion(text)
    if currentThread then
        task.cancel(currentThread)
        currentThread = nil
    end

    if not C.AutoAnswerEnabled then return end
    if shouldSkip(text) then
        setLiveStatus("Waiting...", Color3.fromRGB(140, 140, 160))
        return
    end
    if answerFired then return end
    if text == lastQuestion then return end
    lastQuestion = text

    currentThread = task.spawn(function()
        local trimmed = text:match("^%s*(.-)%s*$")
        local display = #trimmed > 40 and trimmed:sub(1, 40) .. "…" or trimmed
        setLiveQuestion(display)
        setLiveStatus("Asking AI...", Color3.fromRGB(255, 200, 80))
        setLiveAnswer("...", Color3.fromRGB(200, 200, 100))

        task.wait(0.3)

        local a1 = answer1Text and answer1Text.Text or ""
        local a2 = answer2Text and answer2Text.Text or ""
        local a3 = answer3Text and answer3Text.Text or ""

        if a1 == "" or a2 == "" or a3 == "" then
            setLiveStatus("Loading options...", Color3.fromRGB(255, 200, 80))
            task.wait(0.5)
            a1 = answer1Text and answer1Text.Text or ""
            a2 = answer2Text and answer2Text.Text or ""
            a3 = answer3Text and answer3Text.Text or ""
        end

        print("[AutoAnswer] Q: " .. text)
        print("[AutoAnswer] Options: " .. a1 .. " | " .. a2 .. " | " .. a3)

        local answer = askAI(text, a1, a2, a3)

        if not C.AutoAnswerEnabled then return end

        if answer and answer ~= "" then
            setLiveStatus("Fired! ✓", Color3.fromRGB(100, 220, 140))
            setLiveAnswer(answer, Color3.fromRGB(100, 220, 140))
            answerFired = true

            pcall(function()
                remoteEvent:FireServer("answer", answer)
            end)

            print("[AutoAnswer] Fired: " .. answer)
            Feature.showNotification("Answer: " .. answer, true)

            task.delay(12, function()
                answerFired   = false
                lastQuestion  = ""
                setLiveQuestion("—")
                if C.AutoAnswerEnabled then
                    setLiveStatus("Watching...", Color3.fromRGB(100, 220, 140))
                    setLiveAnswer("—", Color3.fromRGB(240, 240, 245))
                end
            end)
        else
            setLiveStatus("AI Failed ✗", Color3.fromRGB(255, 80, 80))
            setLiveAnswer("—", Color3.fromRGB(240, 240, 245))
        end
    end)
end

-- ── Setup game listeners ──────────────────────────────────────────────
local function setupListeners()
    if listenersReady then return end
    listenersReady = true

    task.spawn(function()
        setLiveStatus("Connecting...", Color3.fromRGB(255, 200, 80))

        local ok = pcall(function()
            remoteEvent = RS:WaitForChild("RemoteEvent", 10)
        end)
        if not ok or not remoteEvent then
            warn("[AutoAnswer] RemoteEvent not found")
            setLiveStatus("RemoteEvent missing!", Color3.fromRGB(255, 80, 80))
            return
        end

        local answeringUI = L:WaitForChild("PlayerGui")
            :WaitForChild("GameUI", 15)
            :WaitForChild("TheGame", 10)
            :WaitForChild("AnsweringUI", 10)

        answer1Text = answeringUI:WaitForChild("Answer1"):WaitForChild("AnswerText")
        answer2Text = answeringUI:WaitForChild("Answer2"):WaitForChild("AnswerText")
        answer3Text = answeringUI:WaitForChild("Answer3"):WaitForChild("AnswerText")

        questionObject = workspace:WaitForChild("Classroom", 15)
            :WaitForChild("Objects", 10)
            :WaitForChild("Chalkboard", 10)
            :WaitForChild("QuestionBox", 10)
            :WaitForChild("Questions", 10)
            :WaitForChild("Question", 10)

        setLiveStatus("Ready!", Color3.fromRGB(100, 220, 140))
        print("[AutoAnswer] Listeners ready!")

        if questionObject:IsA("StringValue") then
            handleQuestion(questionObject.Value)
            Connections.Question = questionObject:GetPropertyChangedSignal("Value"):Connect(function()
                handleQuestion(questionObject.Value)
            end)
        elseif questionObject:IsA("TextLabel") or questionObject:IsA("TextBox") then
            handleQuestion(questionObject.Text)
            Connections.Question = questionObject:GetPropertyChangedSignal("Text"):Connect(function()
                handleQuestion(questionObject.Text)
            end)
        else
            pcall(function()
                Connections.QuestionV = questionObject:GetPropertyChangedSignal("Value"):Connect(function()
                    handleQuestion(questionObject.Value)
                end)
            end)
            pcall(function()
                Connections.QuestionT = questionObject:GetPropertyChangedSignal("Text"):Connect(function()
                    handleQuestion(questionObject.Text)
                end)
            end)
        end

        if C.AutoAnswerEnabled then
            setLiveStatus("Watching...", Color3.fromRGB(100, 220, 140))
        else
            setLiveStatus("Idle", Color3.fromRGB(140, 140, 160))
        end
    end)
end

-- ============================================
-- AUTO ANSWER ON / OFF
-- ============================================
function Feature.startAutoAnswer()
    C.AutoAnswerEnabled = true
    setLiveStatus("Watching...", Color3.fromRGB(100, 220, 140))
    setupListeners()
    Feature.showNotification("Auto Answer Enabled!", true)
end

function Feature.stopAutoAnswer()
    C.AutoAnswerEnabled = false
    if currentThread then
        task.cancel(currentThread)
        currentThread = nil
    end
    answerFired  = false
    lastQuestion = ""
    setLiveStatus("Idle", Color3.fromRGB(140, 140, 160))
    setLiveAnswer("—", Color3.fromRGB(240, 240, 245))
    setLiveQuestion("—")
    Feature.showNotification("Auto Answer Disabled!", false)
end

function Feature.toggleAutoAnswer(state)
    if state then
        Feature.startAutoAnswer()
    else
        Feature.stopAutoAnswer()
    end
end

-- ============================================
-- RESET ALL FEATURES
-- ============================================
function Feature.resetAllFeatures()
    Feature.stopAutoAnswer()
    C.AutoAnswerEnabled = false
    Feature.showNotification("All features reset!", false)
end

-- ============================================
-- CLEANUP
-- ============================================
function Feature.cleanup()
    Feature.stopAutoAnswer()
    for k, conn in pairs(Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
        Connections[k] = nil
    end
end

return Feature
