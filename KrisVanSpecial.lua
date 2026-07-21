--[[
	WARNING: KrisVan Script (Special Ed.) - Numerical Secured Edition
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 🔒 核心數值加密
local _Sec = {
    enc = function(v) return (v * 3) - 150 end,
    dec = function(v) return (v + 150) / 3 end,
    s1 = function() return (900 - 450) / 1.5 end, 
    s2 = function() return (360 - 180) / 1.5 end, 
    s3 = function() return (48 - 24) / 1.5 end    
}

-- 宣告全域連線與狀態變數
local isAutoDriving = false
local isDeliveryRunning = false
local isAntiAfkEnabled = false
local activeConnections = {}

local function stopAllRoutines()
    isAutoDriving = false
    isDeliveryRunning = false
    isAntiAfkEnabled = false
    for _, conn in ipairs(activeConnections) do
        if conn then
            pcall(function()
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                elseif typeof(conn) == "thread" then
                    task.cancel(conn)
                end
            end)
        end
    end
    activeConnections = {}
end

-- 前置宣告主腳本函數
local runMainScript

-- ==========================================
-- 第一階段：語言選擇介面 (Language Selector)
-- ==========================================
local function showLanguageSelector()
    stopAllRoutines()
    
    if playerGui:FindFirstChild("MultiDriveGui") then
        playerGui.MultiDriveGui:Destroy()
    end
    if CoreGui:FindFirstChild("KrisVanLangSelector") then
        CoreGui.KrisVanLangSelector:Destroy()
    end

    local langGui = Instance.new("ScreenGui")
    langGui.Name = "KrisVanLangSelector"
    langGui.ResetOnSpawn = false
    langGui.IgnoreGuiInset = true
    langGui.Parent = CoreGui

    local langFrame = Instance.new("Frame")
    langFrame.Size = UDim2.new(0, 280, 0, 160)
    langFrame.Position = UDim2.new(0.5, -140, 0.5, -80)
    langFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    langFrame.BorderSizePixel = 0
    langFrame.Parent = langGui

    local langCorner = Instance.new("UICorner")
    langCorner.CornerRadius = UDim.new(0, 12)
    langCorner.Parent = langFrame

    local langStroke = Instance.new("UIStroke")
    langStroke.Color = Color3.fromRGB(50, 150, 255)
    langStroke.Thickness = 2.5
    langStroke.Parent = langFrame

    local langTitle = Instance.new("TextLabel")
    langTitle.Size = UDim2.new(1, 0, 0, 40)
    langTitle.Position = UDim2.new(0, 0, 0, 10)
    langTitle.BackgroundTransparency = 1
    langTitle.Text = "Select Language / 選擇語言"
    langTitle.Font = Enum.Font.GothamBold
    langTitle.TextSize = 14
    langTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    langTitle.Parent = langFrame

    local btnZh = Instance.new("TextButton")
    btnZh.Size = UDim2.new(0.85, 0, 0, 35)
    btnZh.Position = UDim2.new(0.075, 0, 0, 60)
    btnZh.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
    btnZh.Text = "🇹🇼 繁體中文 (Traditional Chinese)"
    btnZh.Font = Enum.Font.GothamBold
    btnZh.TextSize = 12
    btnZh.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnZh.Parent = langFrame

    local zhCorner = Instance.new("UICorner")
    zhCorner.CornerRadius = UDim.new(0, 6)
    zhCorner.Parent = btnZh

    local btnEn = Instance.new("TextButton")
    btnEn.Size = UDim2.new(0.85, 0, 0, 35)
    btnEn.Position = UDim2.new(0.075, 0, 0, 105)
    btnEn.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    btnEn.Text = "🇺🇸 English"
    btnEn.Font = Enum.Font.GothamBold
    btnEn.TextSize = 12
    btnEn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnEn.Parent = langFrame

    local enCorner = Instance.new("UICorner")
    enCorner.CornerRadius = UDim.new(0, 6)
    enCorner.Parent = btnEn

    local clicked = false

    btnZh.Activated:Connect(function()
        if clicked then return end
        clicked = true
        langGui:Destroy()
        runMainScript("ZH")
    end)

    btnEn.Activated:Connect(function()
        if clicked then return end
        clicked = true
        langGui:Destroy()
        runMainScript("EN")
    end)
end

-- ==========================================
-- 主腳本邏輯封裝函數
-- ==========================================
runMainScript = function(selectedLanguage)
    -- 清理可能殘留的介面
    if playerGui:FindFirstChild("MultiDriveGui") then
        playerGui.MultiDriveGui:Destroy()
    end
    if CoreGui:FindFirstChild("KrisVanLangSelector") then
        CoreGui.KrisVanLangSelector:Destroy()
    end

    -- ==========================================
    -- 第二階段：多國語系字典檔 (Localization Dictionary)
    -- ==========================================
    local L = {}
    if selectedLanguage == "ZH" then
        L = {
            Title = "⚔️KrisVan遊戲輔助(特供版)⚔️",
            Mode1 = "目前模式: [ 1. 車輛自動來回 ]",
            Mode2 = "目前模式: [ 2. 💵送貨💵 ]",
            TargetSpeed = "目標車速: 300 km/h",
            FlySpeed = "飛行速度: 300",
            DistNote = "狀態: 100米內平高降落送貨",
            SetA = "📍 1. 記錄當前位置為【起點 (A)】",
            SetB = "🏁 2. 記錄當前位置為【終點 (B)】",
            Start = "開始執行",
            Stop = "停止執行",
            DeliveryBtn = "⚔️點我啟用⚔️",
            DeliveryStop = "停止送貨中...",
            AfkOff = "🛡️ 防掛機 (Anti AFK): [ 關閉 ]",
            AfkOn = "🛡️ 防掛機 (Anti AFK): [ 開啟 ]",
            WalkSpeed = "🏃 人物移速: 16",
            LangBtn = "🌐 切換語言",
            StatusWaitAB = "狀態: 請設定 A 點與 B 點",
            TimePrefix = "🕒 當前時間: ",
            ErrSeat = "錯誤: 請先坐在駕駛座上！",
            SetASuccess = "狀態: 已成功記錄【起點 (A)】",
            SetBSuccess = "狀態: 已成功記錄【終點 (B)】",
            ErrNoJob = "⚠️ 偵測失敗：未加入 [Delivery Driver] 職業隊伍！",
            FlyStart = "狀態: 啟動高空極速飛行！",
            Stopped = "狀態: 已停止",
            NoTarget = "狀態: 找不到送貨目標，請確認任務狀態",
            Rising = "狀態: 正在上升...",
            Flying = "狀態: 飛行中 (距目標: %.0fm)",
            Approaching = "狀態: 平高接近中 (剩餘: %.0fm)",
            Delivering = "狀態: 定點送達中...",
            Success = "狀態: 順利送達！"
        }
    else
        L = {
            Title = "⚔️KrisVan Script (Special Ed.)⚔️",
            Mode1 = "Current Mode: [ 1. Auto Drive A-B ]",
            Mode2 = "Current Mode: [ 2. 💵Delivery Mode💵 ]",
            TargetSpeed = "Target Speed: 300 km/h",
            FlySpeed = "Fly Speed: 300",
            DistNote = "Status: 100m Drop Delivery",
            SetA = "📍 1. Set Current as [Point A]",
            SetB = "🏁 2. Set Current as [Point B]",
            Start = "Start Execution",
            Stop = "Stop Execution",
            DeliveryBtn = "⚔️Click to Enable⚔️",
            DeliveryStop = "Stopping Delivery...",
            AfkOff = "🛡️ Anti AFK: [ OFF ]",
            AfkOn = "🛡️ Anti AFK: [ ON ]",
            WalkSpeed = "🏃 Walk Speed: 16",
            LangBtn = "🌐 Change Lang",
            StatusWaitAB = "Status: Please set Point A & B",
            TimePrefix = "🕒 Time: ",
            ErrSeat = "Error: Please sit in a vehicle seat first!",
            SetASuccess = "Status: Point A recorded successfully!",
            SetBSuccess = "Status: Point B recorded successfully!",
            ErrNoJob = "⚠️ Error: Not in [Delivery Driver] team/profession!",
            FlyStart = "Status: High-altitude flight started!",
            Stopped = "Status: Stopped",
            NoTarget = "Status: Target not found, check job status",
            Rising = "Status: Ascending...",
            Flying = "Status: Flying (Dist: %.0fm)",
            Approaching = "Status: Approaching level (Left: %.0fm)",
            Delivering = "Status: Delivering...",
            Success = "Status: Successfully Delivered!"
        }
    end

    -- ==========================================
    -- 第三階段：載入主功能介面
    -- ==========================================
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MultiDriveGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 362) 
    frame.Position = UDim2.new(0.5, -160, 0.5, -181)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 150, 255)
    stroke.Thickness = 2.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -35, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = L.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = frame

    -- === 視窗拖動功能 ===
    local dragging, dragInput, dragStart, startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- 收起 / 展開按鈕
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 4)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeBtn.Parent = frame

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn

    local container = Instance.new("Folder")
    container.Name = "Container"
    container.Parent = frame

    -- 模式切換按鈕
    local modeBtn = Instance.new("TextButton")
    modeBtn.Size = UDim2.new(1, -20, 0, 28)
    modeBtn.Position = UDim2.new(0, 10, 0, 34)
    modeBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
    modeBtn.Text = L.Mode1
    modeBtn.Font = Enum.Font.GothamBold
    modeBtn.TextSize = 12
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeBtn.Parent = container

    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 6)
    modeCorner.Parent = modeBtn

    -- === 模式 1 元件 ===
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.65, 0, 0, 18)
    speedLabel.Position = UDim2.new(0, 10, 0, 68)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = L.TargetSpeed
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = container

    local speedInputBox = Instance.new("TextBox")
    speedInputBox.Size = UDim2.new(0.28, 0, 0, 22)
    speedInputBox.Position = UDim2.new(0.72, -10, 0, 66)
    speedInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    speedInputBox.Text = tostring(_Sec.s1())
    speedInputBox.Font = Enum.Font.GothamBold
    speedInputBox.TextSize = 12
    speedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInputBox.ClearTextOnFocus = false
    speedInputBox.Parent = container

    local sInputCorner = Instance.new("UICorner")
    sInputCorner.CornerRadius = UDim.new(0, 4)
    sInputCorner.Parent = speedInputBox

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 5)
    sliderBar.Position = UDim2.new(0, 10, 0, 96)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = sliderBar

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.2, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local sliderKnob = Instance.new("TextButton")
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(0.2, -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Text = ""
    sliderKnob.Parent = sliderBar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob

    local setPointABtn = Instance.new("TextButton")
    setPointABtn.Size = UDim2.new(1, -20, 0, 26)
    setPointABtn.Position = UDim2.new(0, 10, 0, 108)
    setPointABtn.BackgroundColor3 = Color3.fromRGB(60, 100, 140)
    setPointABtn.Text = L.SetA
    setPointABtn.Font = Enum.Font.GothamBold
    setPointABtn.TextSize = 12
    setPointABtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointABtn.Parent = container

    local saCorner = Instance.new("UICorner")
    saCorner.CornerRadius = UDim.new(0, 6)
    saCorner.Parent = setPointABtn

    local setPointBBtn = Instance.new("TextButton")
    setPointBBtn.Size = UDim2.new(1, -20, 0, 26)
    setPointBBtn.Position = UDim2.new(0, 10, 0, 140)
    setPointBBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 60)
    setPointBBtn.Text = L.SetB
    setPointBBtn.Font = Enum.Font.GothamBold
    setPointBBtn.TextSize = 12
    setPointBBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointBBtn.Parent = container

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = setPointBBtn

    -- === 模式 2 元件 ===
    local walkSpeedLabel = Instance.new("TextLabel")
    walkSpeedLabel.Size = UDim2.new(0.65, 0, 0, 18)
    walkSpeedLabel.Position = UDim2.new(0, 10, 0, 68)
    walkSpeedLabel.BackgroundTransparency = 1
    walkSpeedLabel.Text = L.FlySpeed
    walkSpeedLabel.Font = Enum.Font.Gotham
    walkSpeedLabel.TextSize = 12
    walkSpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    walkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    walkSpeedLabel.Visible = false
    walkSpeedLabel.Parent = container

    local flyInputBox = Instance.new("TextBox")
    flyInputBox.Size = UDim2.new(0.28, 0, 0, 22)
    flyInputBox.Position = UDim2.new(0.72, -10, 0, 66)
    flyInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    flyInputBox.Text = tostring(_Sec.s1())
    flyInputBox.Font = Enum.Font.GothamBold
    flyInputBox.TextSize = 12
    flyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyInputBox.ClearTextOnFocus = false
    flyInputBox.Visible = false
    flyInputBox.Parent = container

    local fInputCorner = Instance.new("UICorner")
    fInputCorner.CornerRadius = UDim.new(0, 4)
    fInputCorner.Parent = flyInputBox

    local walkSliderBar = Instance.new("Frame")
    walkSliderBar.Size = UDim2.new(1, -20, 0, 5)
    walkSliderBar.Position = UDim2.new(0, 10, 0, 96)
    walkSliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    walkSliderBar.BorderSizePixel = 0
    walkSliderBar.Visible = false
    walkSliderBar.Parent = container

    local wBarCorner = Instance.new("UICorner")
    wBarCorner.CornerRadius = UDim.new(1, 0)
    wBarCorner.Parent = walkSliderBar

    local walkSliderFill = Instance.new("Frame")
    walkSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    walkSliderFill.BackgroundColor3 = Color3.fromRGB(255, 175, 30)
    walkSliderFill.BorderSizePixel = 0
    walkSliderFill.Parent = walkSliderBar

    local wFillCorner = Instance.new("UICorner")
    wFillCorner.CornerRadius = UDim.new(1, 0)
    wFillCorner.Parent = walkSliderFill

    local walkSliderKnob = Instance.new("TextButton")
    walkSliderKnob.Size = UDim2.new(0, 16, 0, 16)
    walkSliderKnob.Position = UDim2.new(0.5, -8, 0.5, -8)
    walkSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    walkSliderKnob.Text = ""
    walkSliderKnob.Parent = walkSliderBar

    local wKnobCorner = Instance.new("UICorner")
    wKnobCorner.CornerRadius = UDim.new(1, 0)
    wKnobCorner.Parent = walkSliderKnob

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, -20, 0, 18)
    distLabel.Position = UDim2.new(0, 10, 0, 108)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = L.DistNote
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    distLabel.Visible = false
    distLabel.Parent = container

    -- 共用按鈕
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, 174)
    btn.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    btn.Text = L.Start
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    -- === Anti AFK ===
    local afkBtn = Instance.new("TextButton")
    afkBtn.Size = UDim2.new(1, -20, 0, 28)
    afkBtn.Position = UDim2.new(0, 10, 0, 214)
    afkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    afkBtn.Text = L.AfkOff
    afkBtn.Font = Enum.Font.GothamBold
    afkBtn.TextSize = 12
    afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    afkBtn.Parent = container

    local afkCorner = Instance.new("UICorner")
    afkCorner.CornerRadius = UDim.new(0, 6)
    afkCorner.Parent = afkBtn

    -- === 返回選擇語言按鈕 (Change Language) ===
    local changeLangBtn = Instance.new("TextButton")
    changeLangBtn.Size = UDim2.new(1, -20, 0, 28)
    changeLangBtn.Position = UDim2.new(0, 10, 0, 248)
    changeLangBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
    changeLangBtn.Text = L.LangBtn
    changeLangBtn.Font = Enum.Font.GothamBold
    changeLangBtn.TextSize = 12
    changeLangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    changeLangBtn.Parent = container

    local clCorner = Instance.new("UICorner")
    clCorner.CornerRadius = UDim.new(0, 6)
    clCorner.Parent = changeLangBtn

    changeLangBtn.Activated:Connect(function()
        showLanguageSelector()
    end)

    -- === 人物移速 ===
    local speedTitleLabel = Instance.new("TextLabel")
    speedTitleLabel.Size = UDim2.new(0.65, 0, 0, 18)
    speedTitleLabel.Position = UDim2.new(0, 10, 0, 284)
    speedTitleLabel.BackgroundTransparency = 1
    speedTitleLabel.Text = L.WalkSpeed
    speedTitleLabel.Font = Enum.Font.Gotham
    speedTitleLabel.TextSize = 12
    speedTitleLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    speedTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedTitleLabel.Parent = container

    local walkInputBox = Instance.new("TextBox")
    walkInputBox.Size = UDim2.new(0.28, 0, 0, 22)
    walkInputBox.Position = UDim2.new(0.72, -10, 0, 282)
    walkInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    walkInputBox.Text = tostring(_Sec.s3())
    walkInputBox.Font = Enum.Font.GothamBold
    walkInputBox.TextSize = 12
    walkInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    walkInputBox.ClearTextOnFocus = false
    walkInputBox.Parent = container

    local wInputCorner = Instance.new("UICorner")
    wInputCorner.CornerRadius = UDim.new(0, 4)
    wInputCorner.Parent = walkInputBox

    local speedSliderBar = Instance.new("Frame")
    speedSliderBar.Size = UDim2.new(1, -20, 0, 5)
    speedSliderBar.Position = UDim2.new(0, 10, 0, 310)
    speedSliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    speedSliderBar.BorderSizePixel = 0
    speedSliderBar.Parent = container

    local sBarCorner = Instance.new("UICorner")
    sBarCorner.CornerRadius = UDim.new(1, 0)
    sBarCorner.Parent = speedSliderBar

    local speedSliderFill = Instance.new("Frame")
    speedSliderFill.Size = UDim2.new(0, 0, 1, 0)
    speedSliderFill.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
    speedSliderFill.BorderSizePixel = 0
    speedSliderFill.Parent = speedSliderBar

    local sFillCorner = Instance.new("UICorner")
    sFillCorner.CornerRadius = UDim.new(1, 0)
    sFillCorner.Parent = speedSliderFill

    local speedSliderKnob = Instance.new("TextButton")
    speedSliderKnob.Size = UDim2.new(0, 16, 0, 16)
    speedSliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
    speedSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    speedSliderKnob.Text = ""
    speedSliderKnob.Parent = speedSliderBar

    local sKnobCorner = Instance.new("UICorner")
    sKnobCorner.CornerRadius = UDim.new(1, 0)
    sKnobCorner.Parent = speedSliderKnob

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 320)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = L.StatusWaitAB
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.Parent = container

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -20, 0, 20)
    timeLabel.Position = UDim2.new(0, 10, 0, 340)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = L.TimePrefix .. "00:00:00"
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 11
    timeLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
    timeLabel.Parent = container

    table.insert(activeConnections, task.spawn(function()
        while screenGui.Parent do
            timeLabel.Text = L.TimePrefix .. os.date("%H:%M:%S")
            task.wait(1)
        end
    end))

    local currentMode = 1

    local function updateModeUI()
        if currentMode == 1 then
            modeBtn.Text = L.Mode1
            modeBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
            speedLabel.Visible = true
            speedInputBox.Visible = true
            sliderBar.Visible = true
            setPointABtn.Visible = true
            setPointBBtn.Visible = true
            walkSpeedLabel.Visible = false
            flyInputBox.Visible = false
            walkSliderBar.Visible = false
            distLabel.Visible = false
        else
            modeBtn.Text = L.Mode2
            modeBtn.BackgroundColor3 = Color3.fromRGB(255, 175, 30)
            speedLabel.Visible = false
            speedInputBox.Visible = false
            sliderBar.Visible = false
            setPointABtn.Visible = false
            setPointBBtn.Visible = false
            walkSpeedLabel.Visible = true
            flyInputBox.Visible = true
            walkSliderBar.Visible = true
            distLabel.Visible = true
        end
    end

    local isMinimized = false
    minimizeBtn.Activated:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("GuiObject") then obj.Visible = false end
            end
            frame.Size = UDim2.new(0, 260, 0, 34)
            minimizeBtn.Text = "+"
        else
            frame.Size = UDim2.new(0, 320, 0, 362)
            minimizeBtn.Text = "-"
            updateModeUI()
            modeBtn.Visible = true
            btn.Visible = true
            afkBtn.Visible = true
            changeLangBtn.Visible = true
            speedTitleLabel.Visible = true
            walkInputBox.Visible = true
            speedSliderBar.Visible = true
            statusLabel.Visible = true
            timeLabel.Visible = true
        end
    end)

    local targetSpeedKmh = _Sec.s1()
    local customFlySpeed = _Sec.s1()
    local customWalkSpeed = _Sec.s3()
    local targetHeight = _Sec.s2()

    local sliding, walkSliding, speedSliding = false, false, false

    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    walkSliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then walkSliding = true end
    end)
    speedSliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then speedSliding = true end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
            walkSliding = false
            speedSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (sliding or walkSliding or speedSliding) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if sliding then
                local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderKnob.Position = UDim2.new(relativeX, -8, 0.5, -8)
                targetSpeedKmh = math.floor(200 + (relativeX * 500))
                speedLabel.Text = (selectedLanguage == "ZH") and string.format("目標車速: %d km/h", targetSpeedKmh) or string.format("Target Speed: %d km/h", targetSpeedKmh)
                speedInputBox.Text = tostring(targetSpeedKmh)
            elseif walkSliding then
                local relativeX = math.clamp((input.Position.X - walkSliderBar.AbsolutePosition.X) / walkSliderBar.AbsoluteSize.X, 0, 1)
                walkSliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                walkSliderKnob.Position = UDim2.new(relativeX, -8, 0.5, -8)
                customFlySpeed = math.floor(50 + (relativeX * 550))
                walkSpeedLabel.Text = (selectedLanguage == "ZH") and string.format("飛行速度: %d", customFlySpeed) or string.format("Fly Speed: %d", customFlySpeed)
                flyInputBox.Text = tostring(customFlySpeed)
            elseif speedSliding then
                local relativeX = math.clamp((input.Position.X - speedSliderBar.AbsolutePosition.X) / speedSliderBar.AbsoluteSize.X, 0, 1)
                speedSliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                speedSliderKnob.Position = UDim2.new(relativeX, -8, 0.5, -8)
                customWalkSpeed = math.floor(16 + (relativeX * 184))
                speedTitleLabel.Text = (selectedLanguage == "ZH") and string.format("🏃 人物移速: %d", customWalkSpeed) or string.format("🏃 Walk Speed: %d", customWalkSpeed)
                walkInputBox.Text = tostring(customWalkSpeed)
            end
        end
    end)

    speedInputBox.FocusLost:Connect(function()
        local val = tonumber(speedInputBox.Text)
        if val then
            targetSpeedKmh = math.clamp(val, 200, 700)
            speedInputBox.Text = tostring(targetSpeedKmh)
            speedLabel.Text = (selectedLanguage == "ZH") and string.format("目標車速: %d km/h", targetSpeedKmh) or string.format("Target Speed: %d km/h", targetSpeedKmh)
            local ratio = math.clamp((targetSpeedKmh - 200) / 500, 0, 1)
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            sliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
        else
            speedInputBox.Text = tostring(targetSpeedKmh)
        end
    end)

    flyInputBox.FocusLost:Connect(function()
        local val = tonumber(flyInputBox.Text)
        if val then
            customFlySpeed = math.clamp(val, 50, 600)
            flyInputBox.Text = tostring(customFlySpeed)
            walkSpeedLabel.Text = (selectedLanguage == "ZH") and string.format("飛行速度: %d", customFlySpeed) or string.format("Fly Speed: %d", customFlySpeed)
            local ratio = math.clamp((customFlySpeed - 50) / 550, 0, 1)
            walkSliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            walkSliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
        else
            flyInputBox.Text = tostring(customFlySpeed)
        end
    end)

    walkInputBox.FocusLost:Connect(function()
        local val = tonumber(walkInputBox.Text)
        if val then
            customWalkSpeed = math.clamp(val, 16, 200)
            walkInputBox.Text = tostring(customWalkSpeed)
            speedTitleLabel.Text = (selectedLanguage == "ZH") and string.format("🏃 人物移速: %d", customWalkSpeed) or string.format("🏃 Walk Speed: %d", customWalkSpeed)
            local ratio = math.clamp((customWalkSpeed - 16) / 184, 0, 1)
            speedSliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            speedSliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
        else
            walkInputBox.Text = tostring(customWalkSpeed)
        end
    end)

    local function checkDeliveryJobAndProfession()
        local isDriver = false
        if player.Team then
            local teamNameLower = string.lower(player.Team.Name)
            if string.find(teamNameLower, "delivery driver") or string.find(teamNameLower, "delivery") or string.find(teamNameLower, "driver") then
                isDriver = true
            end
        end
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in ipairs(leaderstats:GetChildren()) do
                local valText = string.lower(tostring(stat.Value))
                local nameText = string.lower(stat.Name)
                if string.find(nameText, "job") or string.find(nameText, "profession") or string.find(nameText, "職業") or string.find(nameText, "team") then
                    if string.find(valText, "delivery driver") or string.find(valText, "delivery") or string.find(valText, "driver") then
                        isDriver = true
                    end
                end
            end
        end
        return isDriver
    end

    local pointA, pointB, headingToB = nil, nil, true
    local flightPhase = 1

    local function updateMainBtnState()
        if currentMode == 1 then
            btn.Text = isAutoDriving and L.Stop or L.Start
            btn.BackgroundColor3 = isAutoDriving and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(50, 120, 255)
        else
            btn.Text = isDeliveryRunning and L.DeliveryStop or L.DeliveryBtn
            btn.BackgroundColor3 = isDeliveryRunning and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(255, 175, 30)
        end
    end

    modeBtn.Activated:Connect(function()
        if isAutoDriving or isDeliveryRunning then return end
        currentMode = currentMode == 1 and 2 or 1
        updateModeUI()
        updateMainBtnState()
    end)

    setPointABtn.Activated:Connect(function()
        local seat = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            pointA = seat.Position
            statusLabel.Text = L.SetASuccess
        else
            statusLabel.Text = L.ErrSeat
        end
    end)

    setPointBBtn.Activated:Connect(function()
        local seat = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            pointB = seat.Position
            statusLabel.Text = L.SetBSuccess
        else
            statusLabel.Text = L.ErrSeat
        end
    end)

    btn.Activated:Connect(function()
        if currentMode == 1 then
            if not pointA or not pointB then
                statusLabel.Text = L.StatusWaitAB
                return
            end
            isAutoDriving = not isAutoDriving
            updateMainBtnState()
        else
            if not isDeliveryRunning then
                if not checkDeliveryJobAndProfession() then
                    statusLabel.Text = L.ErrNoJob
                    return
                end
            end
            isDeliveryRunning = not isDeliveryRunning
            flightPhase = 1
            if isDeliveryRunning then
                statusLabel.Text = L.FlyStart
            else
                statusLabel.Text = L.Stopped
            end
            updateMainBtnState()
        end
    end)

    afkBtn.Activated:Connect(function()
        isAntiAfkEnabled = not isAntiAfkEnabled
        if isAntiAfkEnabled then
            afkBtn.Text = L.AfkOn
            afkBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
        else
            afkBtn.Text = L.AfkOff
            afkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end
    end)

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = customWalkSpeed
            end
        end
    end))

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        if not isAutoDriving or currentMode ~= 1 then return end
        local seat = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.SeatPart
        if not seat or not seat:IsA("VehicleSeat") then
            isAutoDriving = false
            updateMainBtnState()
            return
        end
        if not pointA or not pointB then return end
        
        local lookVector = (pointB - pointA).Unit
        local speedStudsPerSec = targetSpeedKmh * 0.78
        local targetPos = headingToB and pointB or pointA
        if (Vector3.new(targetPos.X, seat.Position.Y, targetPos.Z) - seat.Position).Magnitude < 20 then
            headingToB = not headingToB
        end
        
        seat.CFrame = CFrame.new(seat.Position, seat.Position + lookVector)
        seat.ThrottleFloat = headingToB and 1 or -1 
        seat.SteerFloat = 0
        local moveDir = headingToB and lookVector or -lookVector
        seat.AssemblyLinearVelocity = Vector3.new(moveDir.X * speedStudsPerSec, seat.AssemblyLinearVelocity.Y, moveDir.Z * speedStudsPerSec)
    end))

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        if not isDeliveryRunning or currentMode ~= 2 then return end
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        local anchor = workspace:FindFirstChild("DeliveryTargetAnchor", true)
        if not anchor then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "target") or string.find(string.lower(obj.Name), "delivery") or string.find(string.lower(obj.Name), "destination") or string.find(string.lower(obj.Name), "drop")) then
                    anchor = obj
                    break
                end
            end
        end

        if not anchor then
            statusLabel.Text = L.NoTarget
            isDeliveryRunning = false
            updateMainBtnState()
            return
        end

        local finalTargetPos = anchor:IsA("BasePart") and anchor.Position or anchor.PrimaryPart.Position
        local dt = RunService.RenderStepped:Wait()

        if flightPhase == 1 then
            local highPos = Vector3.new(rootPart.Position.X, finalTargetPos.Y + targetHeight, rootPart.Position.Z)
            local distUp = (highPos - rootPart.Position).Magnitude
            if distUp > 5 then
                rootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, math.min(customFlySpeed * dt, distUp), 0))
                rootPart.AssemblyLinearVelocity = Vector3.zero
                statusLabel.Text = L.Rising
            else
                flightPhase = 2
            end

        elseif flightPhase == 2 then
            local hoverTarget = Vector3.new(finalTargetPos.X, finalTargetPos.Y + targetHeight, finalTargetPos.Z)
            local horizDist = (Vector3.new(finalTargetPos.X, 0, finalTargetPos.Z) - Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)).Magnitude
            
            if horizDist > 100 then
                local dir = (Vector3.new(hoverTarget.X, hoverTarget.Y, hoverTarget.Z) - rootPart.Position).Unit
                rootPart.CFrame = CFrame.new(rootPart.Position + (dir * math.min(customFlySpeed * dt, horizDist)), hoverTarget)
                rootPart.AssemblyLinearVelocity = Vector3.zero
                statusLabel.Text = string.format(L.Flying, horizDist)
            else
                flightPhase = 3
            end

        elseif flightPhase == 3 then
            local sameHeightTarget = Vector3.new(finalTargetPos.X, finalTargetPos.Y, finalTargetPos.Z)
            local totalDist = (sameHeightTarget - rootPart.Position).Magnitude
            
            if totalDist > 4 then
                local dir = (sameHeightTarget - rootPart.Position).Unit
                rootPart.CFrame = CFrame.new(rootPart.Position + (dir * math.min(customFlySpeed * dt, totalDist)), sameHeightTarget)
                rootPart.AssemblyLinearVelocity = Vector3.zero
                statusLabel.Text = string.format(L.Approaching, totalDist)
            else
                flightPhase = 4
            end

        elseif flightPhase == 4 then
            local finalDist = (finalTargetPos - rootPart.Position).Magnitude
            if finalDist > 2 then
                local dir = (finalTargetPos - rootPart.Position).Unit
                rootPart.CFrame = CFrame.new(rootPart.Position + (dir * math.min(customFlySpeed * dt, finalDist)), finalTargetPos)
                rootPart.AssemblyLinearVelocity = Vector3.zero
                statusLabel.Text = L.Delivering
            else
                statusLabel.Text = L.Success
                isDeliveryRunning = false
                task.wait(0.5)
                updateMainBtnState()
            end
        end
    end))

    updateModeUI()
    updateMainBtnState()
end

-- 啟動時先呼叫語言選擇器
showLanguageSelector()

