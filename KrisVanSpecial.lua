--[[
	WARNING: KrisVan Script (Special Ed.) - Step-by-Step Waypoint Flight Fixed & Anti-Outlaw Escape (100m / 5s Drop / Teleport to End) + Transparency Buttons + Close Button + Double Confirmation + Simplified/Traditional Chinese + Persistent JumpHeight & WalkSpeed + Infinite Jump
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isAutoDriving = false
local isDeliveryRunning = false
local isAntiCriminalEnabled = false
local isAntiAfkEnabled = false
local isWalkSpeedEnabled = false
local isJumpPowerEnabled = false
local isInfiniteJumpEnabled = false
local activeConnections = {}

local function stopAllRoutines()
    isAutoDriving = false
    isDeliveryRunning = false
    isAntiCriminalEnabled = false
    isAntiAfkEnabled = false
    isWalkSpeedEnabled = false
    isJumpPowerEnabled = false
    isInfiniteJumpEnabled = false
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

local runMainScript

-- 通用雙重確認彈窗函式
local function showConfirmDialog(titleText, msgText, yesText, noText, onYes, onNo)
    if CoreGui:FindFirstChild("KrisVanConfirmDialog") then
        CoreGui.KrisVanConfirmDialog:Destroy()
    end

    local confirmGui = Instance.new("ScreenGui")
    confirmGui.Name = "KrisVanConfirmDialog"
    confirmGui.ResetOnSpawn = false
    confirmGui.IgnoreGuiInset = true
    confirmGui.Parent = CoreGui

    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0, 260, 0, 130)
    confirmFrame.Position = UDim2.new(0.5, -130, 0.5, -65)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    confirmFrame.BorderSizePixel = 0
    confirmFrame.Parent = confirmGui

    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 12)
    confirmCorner.Parent = confirmFrame

    local confirmStroke = Instance.new("UIStroke")
    confirmStroke.Color = Color3.fromRGB(220, 80, 80)
    confirmStroke.Thickness = 2.5
    confirmStroke.Parent = confirmFrame

    local confirmTitle = Instance.new("TextLabel")
    confirmTitle.Size = UDim2.new(1, -20, 0, 30)
    confirmTitle.Position = UDim2.new(0, 10, 0, 10)
    confirmTitle.BackgroundTransparency = 1
    confirmTitle.Text = titleText
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 13
    confirmTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    confirmTitle.Parent = confirmFrame

    local confirmMsg = Instance.new("TextLabel")
    confirmMsg.Size = UDim2.new(1, -20, 0, 30)
    confirmMsg.Position = UDim2.new(0, 10, 0, 42)
    confirmMsg.BackgroundTransparency = 1
    confirmMsg.Text = msgText
    confirmMsg.Font = Enum.Font.Gotham
    confirmMsg.TextSize = 12
    confirmMsg.TextColor3 = Color3.fromRGB(220, 220, 220)
    confirmMsg.Parent = confirmFrame

    local btnNo = Instance.new("TextButton")
    btnNo.Size = UDim2.new(0.44, 0, 0, 32)
    btnNo.Position = UDim2.new(0.04, 0, 0, 84)
    btnNo.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    btnNo.Text = noText
    btnNo.Font = Enum.Font.GothamBold
    btnNo.TextSize = 11
    btnNo.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNo.Parent = confirmFrame
    Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 6)

    local btnYes = Instance.new("TextButton")
    btnYes.Size = UDim2.new(0.44, 0, 0, 32)
    btnYes.Position = UDim2.new(0.52, 0, 0, 84)
    btnYes.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btnYes.Text = yesText
    btnYes.Font = Enum.Font.GothamBold
    btnYes.TextSize = 11
    btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnYes.Parent = confirmFrame
    Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 6)

    btnNo.Activated:Connect(function()
        confirmGui:Destroy()
        if onNo then onNo() end
    end)

    btnYes.Activated:Connect(function()
        confirmGui:Destroy()
        if onYes then onYes() end
    end)
end

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
    langFrame.Size = UDim2.new(0, 280, 0, 205)
    langFrame.Position = UDim2.new(0.5, -140, 0.5, -102.5)
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
    langTitle.Size = UDim2.new(1, -40, 0, 40)
    langTitle.Position = UDim2.new(0, 10, 0, 10)
    langTitle.BackgroundTransparency = 1
    langTitle.Text = "Select Language / 選擇語言"
    langTitle.Font = Enum.Font.GothamBold
    langTitle.TextSize = 13
    langTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    langTitle.Parent = langFrame

    local langCloseBtn = Instance.new("TextButton")
    langCloseBtn.Size = UDim2.new(0, 24, 0, 24)
    langCloseBtn.Position = UDim2.new(1, -30, 0, 8)
    langCloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    langCloseBtn.Text = "❌"
    langCloseBtn.Font = Enum.Font.GothamBold
    langCloseBtn.TextSize = 11
    langCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    langCloseBtn.Parent = langFrame

    local langCloseCorner = Instance.new("UICorner")
    langCloseCorner.CornerRadius = UDim.new(0, 6)
    langCloseCorner.Parent = langCloseBtn

    langCloseBtn.Activated:Connect(function()
        showConfirmDialog(
            "⚠️ 關閉確認 / Confirm Close",
            "確定要關閉輔助腳本嗎？",
            "是 (關閉)",
            "否 (返回)",
            function()
                stopAllRoutines()
                if CoreGui:FindFirstChild("KrisVanLangSelector") then
                    CoreGui.KrisVanLangSelector:Destroy()
                end
            end,
            nil
        )
    end)

    local btnZh = Instance.new("TextButton")
    btnZh.Size = UDim2.new(0.85, 0, 0, 32)
    btnZh.Position = UDim2.new(0.075, 0, 0, 55)
    btnZh.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
    btnZh.Text = "🇹🇼 繁體中文"
    btnZh.Font = Enum.Font.GothamBold
    btnZh.TextSize = 12
    btnZh.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnZh.Parent = langFrame
    Instance.new("UICorner", btnZh).CornerRadius = UDim.new(0, 6)

    local btnCn = Instance.new("TextButton")
    btnCn.Size = UDim2.new(0.85, 0, 0, 32)
    btnCn.Position = UDim2.new(0.075, 0, 0, 95)
    btnCn.BackgroundColor3 = Color3.fromRGB(40, 150, 180)
    btnCn.Text = "🇨🇳 简体中文"
    btnCn.Font = Enum.Font.GothamBold
    btnCn.TextSize = 12
    btnCn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCn.Parent = langFrame
    Instance.new("UICorner", btnCn).CornerRadius = UDim.new(0, 6)

    local btnEn = Instance.new("TextButton")
    btnEn.Size = UDim2.new(0.85, 0, 0, 32)
    btnEn.Position = UDim2.new(0.075, 0, 0, 135)
    btnEn.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    btnEn.Text = "🇺🇸 English"
    btnEn.Font = Enum.Font.GothamBold
    btnEn.TextSize = 12
    btnEn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnEn.Parent = langFrame
    Instance.new("UICorner", btnEn).CornerRadius = UDim.new(0, 6)

    local clicked = false
    btnZh.Activated:Connect(function()
        if clicked then return end
        clicked = true
        langGui:Destroy()
        runMainScript("ZH")
    end)

    btnCn.Activated:Connect(function()
        if clicked then return end
        clicked = true
        langGui:Destroy()
        runMainScript("CN")
    end)

    btnEn.Activated:Connect(function()
        if clicked then return end
        clicked = true
        langGui:Destroy()
        runMainScript("EN")
    end)
end

runMainScript = function(selectedLanguage)
    if playerGui:FindFirstChild("MultiDriveGui") then
        playerGui.MultiDriveGui:Destroy()
    end
    if CoreGui:FindFirstChild("KrisVanLangSelector") then
        CoreGui.KrisVanLangSelector:Destroy()
    end

    local L = {}
    if selectedLanguage == "ZH" then
        L = {
            Title = "⚔️KrisVan遊戲輔助(特供版)⚔️",
            AutoDrive = "🚗 自動駕駛 (Auto Drive)",
            Delivery = "💵 送貨功能 (Delivery)",
            SwitchOff = "[ 關閉 ]",
            SwitchOn = "[ 開啟 ]",
            TargetSpeed = "目標車速: 300 km/h",
            FlySpeed = "飛行速度: 300",
            AntiCriminalOff = "🚨 躲Outlaw搶劫(100m): [ 關閉 ]",
            AntiCriminalOn = "🚨 躲Outlaw搶劫(100m): [ 開啟 ]",
            WalkSpeedTip = "💡 移動速度設定 (16~200)",
            JumpPowerTip = "💡 跳躍高度設定 (50~100)",
            WalkSpeedToggleOff = "🏃 移動速度: [ 關閉 ]",
            WalkSpeedToggleOn = "🏃 移動速度: [ 開啟 ]",
            JumpPowerToggleOff = "🦘 跳躍高度: [ 關閉 ]",
            JumpPowerToggleOn = "🦘 跳躍高度: [ 開啟 ]",
            InfiniteJumpOff = "🚀 跳躍無冷卻: [ 關閉 ]",
            InfiniteJumpOn = "🚀 跳躍無冷卻: [ 開啟 ]",
            SetA = "📍 1. 記錄當前位置為【起點 (A)】",
            SetB = "🏁 2. 記錄當前位置為【終點 (B)】",
            AfkOff = "🛡️ 防掛機: [ 關閉 ]",
            AfkOn = "🛡️ 防掛機: [ 開啟 ]",
            LangBtn = "🌐 切換語言",
            StatusWaitAB = "狀態: 請設定 A 點與 B 點",
            ErrSeat = "錯誤: 請先坐在駕駛座上！",
            ErrNoJob = "⚠️ 偵測失敗：未加入 [Delivery Driver] 職業隊伍！",
            FlyStart = "狀態: 啟動強力穿牆與分段飛行！",
            Stopped = "狀態: 已停止",
            NoTarget = "狀態: 找不到送貨目標，請確認任務狀態",
            Phase1 = "階段 1: 垂直上升中...",
            Phase2 = "階段 2: 高空平移中...",
            Phase3 = "階段 3: 下降至終點上方 5m...",
            Phase4 = "階段 4: 移動至終點完成...",
            Success = "狀態: 順利送達！",
            ConfirmTitle = "⚠️ 關閉確認",
            ConfirmMsg = "確定要關閉輔助腳本嗎？",
            ConfirmYes = "是 (關閉)",
            ConfirmNo = "否 (返回)"
        }
    elseif selectedLanguage == "CN" then
        L = {
            Title = "⚔️KrisVan游戏辅助(特供版)⚔️",
            AutoDrive = "🚗 自动驾驶 (Auto Drive)",
            Delivery = "💵 送货功能 (Delivery)",
            SwitchOff = "[ 关闭 ]",
            SwitchOn = "[ 开启 ]",
            TargetSpeed = "目标车速: 300 km/h",
            FlySpeed = "飞行速度: 300",
            AntiCriminalOff = "🚨 躲Outlaw抢劫(100m): [ 关闭 ]",
            AntiCriminalOn = "🚨 躲Outlaw抢劫(100m): [ 开启 ]",
            WalkSpeedTip = "💡 移动速度设定 (16~200)",
            JumpPowerTip = "💡 跳跃高度设定 (50~100)",
            WalkSpeedToggleOff = "🏃 移动速度: [ 关闭 ]",
            WalkSpeedToggleOn = "🏃 移动速度: [ 开启 ]",
            JumpPowerToggleOff = "🦘 跳跃高度: [ 关闭 ]",
            JumpPowerToggleOn = "🦘 跳跃高度: [ 开启 ]",
            InfiniteJumpOff = "🚀 跳跃无冷却: [ 关闭 ]",
            InfiniteJumpOn = "🚀 跳跃无冷却: [ 开启 ]",
            SetA = "📍 1. 记录当前位置为【起点 (A)】",
            SetB = "🏁 2. 记录当前位置为【终点 (B)】",
            AfkOff = "🛡️ 防挂机: [ 关闭 ]",
            AfkOn = "🛡️ 防挂机: [ 开启 ]",
            LangBtn = "🌐 切换语言",
            StatusWaitAB = "状态: 请设置 A 点与 B 点",
            ErrSeat = "错误: 请先坐在驾驶座上！",
            ErrNoJob = "⚠️ 检测失败：未加入 [Delivery Driver] 职业队伍！",
            FlyStart = "状态: 启动强力穿墙与分段飞行！",
            Stopped = "状态: 已停止",
            NoTarget = "状态: 找不到送货目标，请确认任务状态",
            Phase1 = "阶段 1: 垂直上升中...",
            Phase2 = "阶段 2: 高空平移中...",
            Phase3 = "阶段 3: 下降至终点上方 5m...",
            Phase4 = "阶段 4: 移动至终点完成...",
            Success = "状态: 顺利送达！",
            ConfirmTitle = "⚠️ 关闭确认",
            ConfirmMsg = "确定要关闭辅助脚本吗？",
            ConfirmYes = "是 (关闭)",
            ConfirmNo = "否 (返回)"
        }
    else
        L = {
            Title = "⚔️KrisVan Script (Special Ed.)⚔️",
            AutoDrive = "🚗 Auto Drive",
            Delivery = "💵 Delivery",
            SwitchOff = "[ OFF ]",
            SwitchOn = "[ ON ]",
            TargetSpeed = "Target Speed: 300 km/h",
            FlySpeed = "Fly Speed: 300",
            AntiCriminalOff = "🚨 Anti-Outlaw(100m): [ OFF ]",
            AntiCriminalOn = "🚨 Anti-Outlaw(100m): [ ON ]",
            WalkSpeedTip = "💡 Walk Speed Setting (16~200)",
            JumpPowerTip = "💡 Jump Power Setting (50~100)",
            WalkSpeedToggleOff = "🏃 Walk Speed: [ OFF ]",
            WalkSpeedToggleOn = "🏃 Walk Speed: [ ON ]",
            JumpPowerToggleOff = "🦘 Jump Power: [ OFF ]",
            JumpPowerToggleOn = "🦘 Jump Power: [ ON ]",
            InfiniteJumpOff = "🚀 Infinite Jump: [ OFF ]",
            InfiniteJumpOn = "🚀 Infinite Jump: [ ON ]",
            SetA = "📍 1. Set Current as [Point A]",
            SetB = "🏁 2. Set Current as [Point B]",
            AfkOff = "🛡️ Anti AFK: [ OFF ]",
            AfkOn = "🛡️ Anti AFK: [ ON ]",
            LangBtn = "🌐 Change Lang",
            StatusWaitAB = "Status: Please set Point A & B",
            ErrSeat = "Error: Please sit in a vehicle seat first!",
            ErrNoJob = "⚠️ Error: Not in [Delivery Driver] team/profession!",
            FlyStart = "Status: Noclip & Step-by-step flight started!",
            Stopped = "Status: Stopped",
            NoTarget = "Status: Target not found, check job status",
            Phase1 = "Phase 1: Ascending...",
            Phase2 = "Phase 2: High altitude cruising...",
            Phase3 = "Phase 3: Descending to +5m...",
            Phase4 = "Phase 4: Moving to destination...",
            Success = "Status: Successfully Delivered!",
            ConfirmTitle = "⚠️ Confirm Close",
            ConfirmMsg = "Are you sure to close script?",
            ConfirmYes = "Yes (Close)",
            ConfirmNo = "No (Return)"
        }
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MultiDriveGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 355)
    frame.Position = UDim2.new(0.5, -160, 0.5, -177.5)
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
    title.Size = UDim2.new(1, -65, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = L.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = frame

    local dragging, dragInput, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -60, 0, 4)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeBtn.Parent = frame

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn

    local closeScriptBtn = Instance.new("TextButton")
    closeScriptBtn.Size = UDim2.new(0, 26, 0, 26)
    closeScriptBtn.Position = UDim2.new(1, -30, 0, 4)
    closeScriptBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    closeScriptBtn.Text = "❌"
    closeScriptBtn.Font = Enum.Font.GothamBold
    closeScriptBtn.TextSize = 12
    closeScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeScriptBtn.Parent = frame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeScriptBtn

    closeScriptBtn.Activated:Connect(function()
        showConfirmDialog(
            L.ConfirmTitle,
            L.ConfirmMsg,
            L.ConfirmYes,
            L.ConfirmNo,
            function()
                stopAllRoutines()
                if playerGui:FindFirstChild("MultiDriveGui") then
                    playerGui.MultiDriveGui:Destroy()
                end
            end,
            nil
        )
    end)

    -- 主按鈕 1：自動駕駛
    local autoDriveBtn = Instance.new("TextButton")
    autoDriveBtn.Size = UDim2.new(1, -20, 0, 32)
    autoDriveBtn.Position = UDim2.new(0, 10, 0, 36)
    autoDriveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    autoDriveBtn.Text = L.AutoDrive
    autoDriveBtn.Font = Enum.Font.GothamBold
    autoDriveBtn.TextSize = 12
    autoDriveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoDriveBtn.Parent = frame
    Instance.new("UICorner", autoDriveBtn).CornerRadius = UDim.new(0, 6)

    local autoDrivePanel = Instance.new("Folder", frame)

    local adToggleBtn = Instance.new("TextButton")
    adToggleBtn.Size = UDim2.new(1, -20, 0, 26)
    adToggleBtn.Position = UDim2.new(0, 10, 0, 72)
    adToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    adToggleBtn.Text = ((selectedLanguage == "EN") and "Auto Drive Switch: " or ((selectedLanguage == "CN") and "自动驾驶开关: " or "自動駕駛開關: ")) .. L.SwitchOff
    adToggleBtn.Font = Enum.Font.GothamBold
    adToggleBtn.TextSize = 11
    adToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    adToggleBtn.Parent = autoDrivePanel
    Instance.new("UICorner", adToggleBtn).CornerRadius = UDim.new(0, 4)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.65, 0, 0, 18)
    speedLabel.Position = UDim2.new(0, 10, 0, 102)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = L.TargetSpeed
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = autoDrivePanel

    local speedInputBox = Instance.new("TextBox")
    speedInputBox.Size = UDim2.new(0.28, 0, 0, 22)
    speedInputBox.Position = UDim2.new(0.72, -10, 0, 100)
    speedInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    speedInputBox.Text = "300"
    speedInputBox.Font = Enum.Font.GothamBold
    speedInputBox.TextSize = 12
    speedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInputBox.ClearTextOnFocus = false
    speedInputBox.Parent = autoDrivePanel
    Instance.new("UICorner", speedInputBox).CornerRadius = UDim.new(0, 4)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 5)
    sliderBar.Position = UDim2.new(0, 10, 0, 130)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = autoDrivePanel
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame", sliderBar)
    sliderFill.Size = UDim2.new(0.2, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderKnob = Instance.new("TextButton", sliderBar)
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(0.2, -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Text = ""
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    local setPointABtn = Instance.new("TextButton")
    setPointABtn.Size = UDim2.new(1, -20, 0, 26)
    setPointABtn.Position = UDim2.new(0, 10, 0, 142)
    setPointABtn.BackgroundColor3 = Color3.fromRGB(60, 100, 140)
    setPointABtn.Text = L.SetA
    setPointABtn.Font = Enum.Font.GothamBold
    setPointABtn.TextSize = 12
    setPointABtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointABtn.Parent = autoDrivePanel
    Instance.new("UICorner", setPointABtn).CornerRadius = UDim.new(0, 6)

    local setPointBBtn = Instance.new("TextButton")
    setPointBBtn.Size = UDim2.new(1, -20, 0, 26)
    setPointBBtn.Position = UDim2.new(0, 10, 0, 174)
    setPointBBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 60)
    setPointBBtn.Text = L.SetB
    setPointBBtn.Font = Enum.Font.GothamBold
    setPointBBtn.TextSize = 12
    setPointBBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointBBtn.Parent = autoDrivePanel
    Instance.new("UICorner", setPointBBtn).CornerRadius = UDim.new(0, 6)

    -- 主按鈕 2：送貨功能
    local deliveryBtn = Instance.new("TextButton")
    deliveryBtn.Size = UDim2.new(1, -20, 0, 32)
    deliveryBtn.Position = UDim2.new(0, 10, 0, 74)
    deliveryBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    deliveryBtn.Text = L.Delivery
    deliveryBtn.Font = Enum.Font.GothamBold
    deliveryBtn.TextSize = 12
    deliveryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deliveryBtn.Parent = frame
    Instance.new("UICorner", deliveryBtn).CornerRadius = UDim.new(0, 6)

    local deliveryPanel = Instance.new("Folder", frame)

    local dlToggleBtn = Instance.new("TextButton")
    dlToggleBtn.Size = UDim2.new(1, -20, 0, 24)
    dlToggleBtn.Position = UDim2.new(0, 10, 0, 110)
    dlToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    dlToggleBtn.Text = ((selectedLanguage == "EN") and "Delivery Switch: " or ((selectedLanguage == "CN") and "送货功能开关: " or "送貨功能開關: ")) .. L.SwitchOff
    dlToggleBtn.Font = Enum.Font.GothamBold
    dlToggleBtn.TextSize = 11
    dlToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dlToggleBtn.Parent = deliveryPanel
    Instance.new("UICorner", dlToggleBtn).CornerRadius = UDim.new(0, 4)

    local antiCriminalBtn = Instance.new("TextButton")
    antiCriminalBtn.Size = UDim2.new(1, -20, 0, 24)
    antiCriminalBtn.Position = UDim2.new(0, 10, 0, 137)
    antiCriminalBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    antiCriminalBtn.Text = L.AntiCriminalOff
    antiCriminalBtn.Font = Enum.Font.GothamBold
    antiCriminalBtn.TextSize = 11
    antiCriminalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiCriminalBtn.Parent = deliveryPanel
    Instance.new("UICorner", antiCriminalBtn).CornerRadius = UDim.new(0, 4)

    local walkSpeedLabel = Instance.new("TextLabel")
    walkSpeedLabel.Size = UDim2.new(0.65, 0, 0, 18)
    walkSpeedLabel.Position = UDim2.new(0, 10, 0, 163)
    walkSpeedLabel.BackgroundTransparency = 1
    walkSpeedLabel.Text = L.FlySpeed
    walkSpeedLabel.Font = Enum.Font.Gotham
    walkSpeedLabel.TextSize = 11
    walkSpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    walkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    walkSpeedLabel.Parent = deliveryPanel

    local flyInputBox = Instance.new("TextBox")
    flyInputBox.Size = UDim2.new(0.28, 0, 0, 20)
    flyInputBox.Position = UDim2.new(0.72, -10, 0, 162)
    flyInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    flyInputBox.Text = "300"
    flyInputBox.Font = Enum.Font.GothamBold
    flyInputBox.TextSize = 11
    flyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyInputBox.ClearTextOnFocus = false
    flyInputBox.Parent = deliveryPanel
    Instance.new("UICorner", flyInputBox).CornerRadius = UDim.new(0, 4)

    local walkSliderBar = Instance.new("Frame")
    walkSliderBar.Size = UDim2.new(1, -20, 0, 4)
    walkSliderBar.Position = UDim2.new(0, 10, 0, 187)
    walkSliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    walkSliderBar.BorderSizePixel = 0
    walkSliderBar.Parent = deliveryPanel
    Instance.new("UICorner", walkSliderBar).CornerRadius = UDim.new(1, 0)

    local walkSliderFill = Instance.new("Frame", walkSliderBar)
    walkSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    walkSliderFill.BackgroundColor3 = Color3.fromRGB(255, 175, 30)
    walkSliderFill.BorderSizePixel = 0
    Instance.new("UICorner", walkSliderFill).CornerRadius = UDim.new(1, 0)

    local walkSliderKnob = Instance.new("TextButton", walkSliderBar)
    walkSliderKnob.Size = UDim2.new(0, 14, 0, 14)
    walkSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
    walkSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    walkSliderKnob.Text = ""
    Instance.new("UICorner", walkSliderKnob).CornerRadius = UDim.new(1, 0)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 16)
    statusLabel.Position = UDim2.new(0, 10, 0, 194)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = L.StatusWaitAB
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 10
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.Parent = deliveryPanel

    -- 常駐功能列 0A（移動速度小提示）
    local walkSpeedTipLabel = Instance.new("TextLabel")
    walkSpeedTipLabel.Size = UDim2.new(1, -20, 0, 16)
    walkSpeedTipLabel.Position = UDim2.new(0, 10, 0, 112)
    walkSpeedTipLabel.BackgroundTransparency = 1
    walkSpeedTipLabel.Text = L.WalkSpeedTip
    walkSpeedTipLabel.Font = Enum.Font.Gotham
    walkSpeedTipLabel.TextSize = 11
    walkSpeedTipLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    walkSpeedTipLabel.TextXAlignment = Enum.TextXAlignment.Left
    walkSpeedTipLabel.Parent = frame

    -- 常駐功能列 1A（移動速度設定框 + 開關）
    local walkSpeedBarFrame = Instance.new("Frame")
    walkSpeedBarFrame.Size = UDim2.new(1, -20, 0, 30)
    walkSpeedBarFrame.Position = UDim2.new(0, 10, 0, 130)
    walkSpeedBarFrame.BackgroundTransparency = 1
    walkSpeedBarFrame.Parent = frame

    local walkSpeedBox = Instance.new("TextBox")
    walkSpeedBox.Size = UDim2.new(0.48, 0, 1, 0)
    walkSpeedBox.Position = UDim2.new(0, 0, 0, 0)
    walkSpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    walkSpeedBox.Text = "50"
    walkSpeedBox.Font = Enum.Font.GothamBold
    walkSpeedBox.TextSize = 11
    walkSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    walkSpeedBox.ClearTextOnFocus = false
    walkSpeedBox.Parent = walkSpeedBarFrame
    Instance.new("UICorner", walkSpeedBox).CornerRadius = UDim.new(0, 6)

    local walkSpeedToggleBtn = Instance.new("TextButton")
    walkSpeedToggleBtn.Size = UDim2.new(0.48, 0, 1, 0)
    walkSpeedToggleBtn.Position = UDim2.new(0.52, 0, 0, 0)
    walkSpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    walkSpeedToggleBtn.Text = L.WalkSpeedToggleOff
    walkSpeedToggleBtn.Font = Enum.Font.GothamBold
    walkSpeedToggleBtn.TextSize = 10
    walkSpeedToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    walkSpeedToggleBtn.Parent = walkSpeedBarFrame
    Instance.new("UICorner", walkSpeedToggleBtn).CornerRadius = UDim.new(0, 6)

    -- 常駐功能列 0B（跳躍高度小提示）
    local jumpPowerTipLabel = Instance.new("TextLabel")
    jumpPowerTipLabel.Size = UDim2.new(1, -20, 0, 16)
    jumpPowerTipLabel.Position = UDim2.new(0, 10, 0, 164)
    jumpPowerTipLabel.BackgroundTransparency = 1
    jumpPowerTipLabel.Text = L.JumpPowerTip
    jumpPowerTipLabel.Font = Enum.Font.Gotham
    jumpPowerTipLabel.TextSize = 11
    jumpPowerTipLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    jumpPowerTipLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpPowerTipLabel.Parent = frame

    -- 常駐功能列 1B（跳躍高度設定框 + 開關）
    local jumpPowerBarFrame = Instance.new("Frame")
    jumpPowerBarFrame.Size = UDim2.new(1, -20, 0, 30)
    jumpPowerBarFrame.Position = UDim2.new(0, 10, 0, 182)
    jumpPowerBarFrame.BackgroundTransparency = 1
    jumpPowerBarFrame.Parent = frame

    local jumpPowerBox = Instance.new("TextBox")
    jumpPowerBox.Size = UDim2.new(0.48, 0, 1, 0)
    jumpPowerBox.Position = UDim2.new(0, 0, 0, 0)
    jumpPowerBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    jumpPowerBox.Text = "50"
    jumpPowerBox.Font = Enum.Font.GothamBold
    jumpPowerBox.TextSize = 11
    jumpPowerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpPowerBox.ClearTextOnFocus = false
    jumpPowerBox.Parent = jumpPowerBarFrame
    Instance.new("UICorner", jumpPowerBox).CornerRadius = UDim.new(0, 6)

    local jumpPowerToggleBtn = Instance.new("TextButton")
    jumpPowerToggleBtn.Size = UDim2.new(0.48, 0, 1, 0)
    jumpPowerToggleBtn.Position = UDim2.new(0.52, 0, 0, 0)
    jumpPowerToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    jumpPowerToggleBtn.Text = L.JumpPowerToggleOff
    jumpPowerToggleBtn.Font = Enum.Font.GothamBold
    jumpPowerToggleBtn.TextSize = 10
    jumpPowerToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpPowerToggleBtn.Parent = jumpPowerBarFrame
    Instance.new("UICorner", jumpPowerToggleBtn).CornerRadius = UDim.new(0, 6)

    -- 常駐功能列 1C（跳躍無冷卻開關）
    local infiniteJumpBarFrame = Instance.new("Frame")
    infiniteJumpBarFrame.Size = UDim2.new(1, -20, 0, 30)
    infiniteJumpBarFrame.Position = UDim2.new(0, 10, 0, 218)
    infiniteJumpBarFrame.BackgroundTransparency = 1
    infiniteJumpBarFrame.Parent = frame

    local infiniteJumpToggleBtn = Instance.new("TextButton")
    infiniteJumpToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    infiniteJumpToggleBtn.Position = UDim2.new(0, 0, 0, 0)
    infiniteJumpToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    infiniteJumpToggleBtn.Text = L.InfiniteJumpOff
    infiniteJumpToggleBtn.Font = Enum.Font.GothamBold
    infiniteJumpToggleBtn.TextSize = 11
    infiniteJumpToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    infiniteJumpToggleBtn.Parent = infiniteJumpBarFrame
    Instance.new("UICorner", infiniteJumpToggleBtn).CornerRadius = UDim.new(0, 6)

    -- 常駐功能列 2（防掛機、語言切換）
    local persistentBarFrame = Instance.new("Frame")
    persistentBarFrame.Size = UDim2.new(1, -20, 0, 30)
    persistentBarFrame.Position = UDim2.new(0, 10, 0, 254)
    persistentBarFrame.BackgroundTransparency = 1
    persistentBarFrame.Parent = frame

    local afkBtn = Instance.new("TextButton")
    afkBtn.Size = UDim2.new(0.48, 0, 1, 0)
    afkBtn.Position = UDim2.new(0, 0, 0, 0)
    afkBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    afkBtn.Text = L.AfkOff
    afkBtn.Font = Enum.Font.GothamBold
    afkBtn.TextSize = 11
    afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    afkBtn.Parent = persistentBarFrame
    Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0, 6)

    local changeLangBtn = Instance.new("TextButton")
    changeLangBtn.Size = UDim2.new(0.48, 0, 1, 0)
    changeLangBtn.Position = UDim2.new(0.52, 0, 0, 0)
    changeLangBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
    changeLangBtn.Text = L.LangBtn
    changeLangBtn.Font = Enum.Font.GothamBold
    changeLangBtn.TextSize = 11
    changeLangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    changeLangBtn.Parent = persistentBarFrame
    Instance.new("UICorner", changeLangBtn).CornerRadius = UDim.new(0, 6)

    -- 常駐功能列 3：透明度控制
    local alphaBarFrame = Instance.new("Frame")
    alphaBarFrame.Size = UDim2.new(1, -20, 0, 26)
    alphaBarFrame.Position = UDim2.new(0, 10, 0, 290)
    alphaBarFrame.BackgroundTransparency = 1
    alphaBarFrame.Parent = frame

    local alphaLevels = {
        {name = "100%", trans = 0.0},
        {name = "75%", trans = 0.25},
        {name = "50%", trans = 0.5},
        {name = "20%", trans = 0.8}
    }

    local alphaButtons = {}
    local btnWidth = 0.235
    local spacing = 0.02

    for i, data in ipairs(alphaLevels) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(btnWidth, 0, 1, 0)
        btn.Position = UDim2.new((i - 1) * (btnWidth + spacing), 0, 0, 0)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(50, 120, 200) or Color3.fromRGB(60, 60, 75)
        btn.Text = data.name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = alphaBarFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        table.insert(alphaButtons, btn)

        local tValue = data.trans
        btn.Activated:Connect(function()
            frame.BackgroundTransparency = tValue
            for _, b in ipairs(alphaButtons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            end
            btn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
        end)
    end

    changeLangBtn.Activated:Connect(function()
        showLanguageSelector()
    end)

    local currentActiveTab = nil 

    local function updatePanelsVisibility()
        if currentActiveTab == "AutoDrive" then
            frame.Size = UDim2.new(0, 320, 0, 236)
            deliveryBtn.Position = UDim2.new(0, 10, 0, 236)
            deliveryBtn.Visible = false
            walkSpeedTipLabel.Visible = false
            walkSpeedBarFrame.Visible = false
            jumpPowerTipLabel.Visible = false
            jumpPowerBarFrame.Visible = false
            infiniteJumpBarFrame.Visible = false
            persistentBarFrame.Visible = false
            alphaBarFrame.Visible = false
            for _, obj in ipairs(autoDrivePanel:GetChildren()) do obj.Visible = true end
            for _, obj in ipairs(deliveryPanel:GetChildren()) do obj.Visible = false end

        elseif currentActiveTab == "Delivery" then
            frame.Size = UDim2.new(0, 320, 0, 255)
            deliveryBtn.Position = UDim2.new(0, 10, 0, 74)
            deliveryBtn.Visible = true
            walkSpeedTipLabel.Visible = false
            walkSpeedBarFrame.Visible = false
            jumpPowerTipLabel.Visible = false
            jumpPowerBarFrame.Visible = false
            infiniteJumpBarFrame.Visible = false
            persistentBarFrame.Visible = false
            alphaBarFrame.Visible = false
            for _, obj in ipairs(autoDrivePanel:GetChildren()) do obj.Visible = false end
            for _, obj in ipairs(deliveryPanel:GetChildren()) do obj.Visible = true end

        else
            frame.Size = UDim2.new(0, 320, 0, 355)
            deliveryBtn.Position = UDim2.new(0, 10, 0, 74)
            deliveryBtn.Visible = true
            
            walkSpeedTipLabel.Position = UDim2.new(0, 10, 0, 112)
            walkSpeedTipLabel.Visible = true
            walkSpeedBarFrame.Position = UDim2.new(0, 10, 0, 130)
            walkSpeedBarFrame.Visible = true

            jumpPowerTipLabel.Position = UDim2.new(0, 10, 0, 164)
            jumpPowerTipLabel.Visible = true
            jumpPowerBarFrame.Position = UDim2.new(0, 10, 0, 182)
            jumpPowerBarFrame.Visible = true

            infiniteJumpBarFrame.Position = UDim2.new(0, 10, 0, 218)
            infiniteJumpBarFrame.Visible = true

            persistentBarFrame.Position = UDim2.new(0, 10, 0, 254)
            persistentBarFrame.Visible = true
            alphaBarFrame.Position = UDim2.new(0, 10, 0, 290)
            alphaBarFrame.Visible = true
            
            for _, obj in ipairs(autoDrivePanel:GetChildren()) do obj.Visible = false end
            for _, obj in ipairs(deliveryPanel:GetChildren()) do obj.Visible = false end
        end
    end

    local isMinimized = false
    minimizeBtn.Activated:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            autoDriveBtn.Visible = false
            deliveryBtn.Visible = false
            walkSpeedTipLabel.Visible = false
            walkSpeedBarFrame.Visible = false
            jumpPowerTipLabel.Visible = false
            jumpPowerBarFrame.Visible = false
            infiniteJumpBarFrame.Visible = false
            persistentBarFrame.Visible = false
            alphaBarFrame.Visible = false
            for _, obj in ipairs(autoDrivePanel:GetChildren()) do obj.Visible = false end
            for _, obj in ipairs(deliveryPanel:GetChildren()) do obj.Visible = false end
            frame.Size = UDim2.new(0, 260, 0, 34)
            minimizeBtn.Text = "+"
        else
            autoDriveBtn.Visible = true
            minimizeBtn.Text = "-"
            updatePanelsVisibility()
        end
    end)

    local targetSpeedKmh = 300
    local customFlySpeed = 300
    local sliding, walkSliding = false, false

    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    walkSliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then walkSliding = true end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
            walkSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (sliding or walkSliding) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if sliding then
                local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderKnob.Position = UDim2.new(relativeX, -8, 0.5, -8)
                targetSpeedKmh = math.floor(200 + (relativeX * 500))
                speedLabel.Text = (selectedLanguage == "EN") and string.format("Target Speed: %d km/h", targetSpeedKmh) or string.format("目标车速: %d km/h", targetSpeedKmh)
                speedInputBox.Text = tostring(targetSpeedKmh)
            elseif walkSliding then
                local relativeX = math.clamp((input.Position.X - walkSliderBar.AbsolutePosition.X) / walkSliderBar.AbsoluteSize.X, 0, 1)
                walkSliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                walkSliderKnob.Position = UDim2.new(relativeX, -7, 0.5, -7)
                customFlySpeed = math.floor(50 + (relativeX * 550))
                walkSpeedLabel.Text = (selectedLanguage == "EN") and string.format("Fly Speed: %d", customFlySpeed) or string.format("飞行速度: %d", customFlySpeed)
                flyInputBox.Text = tostring(customFlySpeed)
            end
        end
    end)

    speedInputBox.FocusLost:Connect(function()
        local val = tonumber(speedInputBox.Text)
        if val then
            targetSpeedKmh = math.clamp(val, 200, 700)
            speedInputBox.Text = tostring(targetSpeedKmh)
            speedLabel.Text = (selectedLanguage == "EN") and string.format("Target Speed: %d km/h", targetSpeedKmh) or string.format("目标车速: %d km/h", targetSpeedKmh)
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
            walkSpeedLabel.Text = (selectedLanguage == "EN") and string.format("Fly Speed: %d", customFlySpeed) or string.format("飞行速度: %d", customFlySpeed)
            local ratio = math.clamp((customFlySpeed - 50) / 550, 0, 1)
            walkSliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            walkSliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
        else
            flyInputBox.Text = tostring(customFlySpeed)
        end
    end)

    walkSpeedBox.FocusLost:Connect(function()
        local val = tonumber(walkSpeedBox.Text)
        if val then
            if val < 16 then val = 16 elseif val > 200 then val = 200 end
            walkSpeedBox.Text = tostring(val)
        else
            walkSpeedBox.Text = "50"
        end
    end)

    jumpPowerBox.FocusLost:Connect(function()
        local val = tonumber(jumpPowerBox.Text)
        if val then
            if val < 50 then val = 50 elseif val > 100 then val = 100 end
            jumpPowerBox.Text = tostring(val)
        else
            jumpPowerBox.Text = "50"
        end
    end)

    walkSpeedToggleBtn.Activated:Connect(function()
        isWalkSpeedEnabled = not isWalkSpeedEnabled
        local val = tonumber(walkSpeedBox.Text) or 50
        if val < 16 then val = 16 elseif val > 200 then val = 200 end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if isWalkSpeedEnabled then
            walkSpeedToggleBtn.Text = L.WalkSpeedToggleOn
            walkSpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
            if hum then hum.WalkSpeed = val end
        else
            walkSpeedToggleBtn.Text = L.WalkSpeedToggleOff
            walkSpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            if hum then hum.WalkSpeed = 16 end
        end
    end)

    jumpPowerToggleBtn.Activated:Connect(function()
        isJumpPowerEnabled = not isJumpPowerEnabled
        local val = tonumber(jumpPowerBox.Text) or 50
        if val < 50 then val = 50 elseif val > 100 then val = 100 end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if isJumpPowerEnabled then
            jumpPowerToggleBtn.Text = L.JumpPowerToggleOn
            jumpPowerToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val
            end
        else
            jumpPowerToggleBtn.Text = L.JumpPowerToggleOff
            jumpPowerToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = 50
            end
        end
    end)

    infiniteJumpToggleBtn.Activated:Connect(function()
        isInfiniteJumpEnabled = not isInfiniteJumpEnabled
        if isInfiniteJumpEnabled then
            infiniteJumpToggleBtn.Text = L.InfiniteJumpOn
            infiniteJumpToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        else
            infiniteJumpToggleBtn.Text = L.InfiniteJumpOff
            infiniteJumpToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end
    end)

    table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
        if isInfiniteJumpEnabled then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if isWalkSpeedEnabled then
            local val = tonumber(walkSpeedBox.Text) or 50
            if val < 16 then val = 16 elseif val > 200 then val = 200 end
            if hum.WalkSpeed ~= val then
                hum.WalkSpeed = val
            end
        end

        if isJumpPowerEnabled then
            local val = tonumber(jumpPowerBox.Text) or 50
            if val < 50 then val = 50 elseif val > 100 then val = 100 end
            hum.UseJumpPower = true
            if hum.JumpPower ~= val then
                hum.JumpPower = val
            end
        end
    end))

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
                if string.find(nameText, "job") or string.find(nameText, "profession") or string.find(nameText, "职业") or string.find(nameText, "職業") or string.find(nameText, "team") then
                    if string.find(valText, "delivery driver") or string.find(valText, "delivery") or string.find(valText, "driver") then
                        isDriver = true
                    end
                end
            end
        end
        return isDriver
    end

    local pointA, pointB, headingToB = nil, nil, true

    setPointABtn.Activated:Connect(function()
        local seat = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            pointA = seat.Position
            autoDriveBtn.Text = (selectedLanguage == "EN") and "🚗 Auto Drive (Point A Set)" or ((selectedLanguage == "CN") and "🚗 自动驾驶 (📍 已设置A点)" or "🚗 自動駕駛 (📍 已設定A點)")
        else
            autoDriveBtn.Text = L.ErrSeat
        end
    end)

    setPointBBtn.Activated:Connect(function()
        local seat = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            pointB = seat.Position
            autoDriveBtn.Text = (selectedLanguage == "EN") and "🚗 Auto Drive (Point B Set)" or ((selectedLanguage == "CN") and "🚗 自动驾驶 (🏁 已设置B点)" or "🚗 自動駕駛 (🏁 已設定B點)")
        else
            autoDriveBtn.Text = L.ErrSeat
        end
    end)

    autoDriveBtn.Activated:Connect(function()
        if currentActiveTab == "AutoDrive" then
            currentActiveTab = nil
            autoDriveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        else
            currentActiveTab = "AutoDrive"
            autoDriveBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            deliveryBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end
        updatePanelsVisibility()
    end)

    deliveryBtn.Activated:Connect(function()
        if currentActiveTab == "Delivery" then
            currentActiveTab = nil
            deliveryBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        else
            currentActiveTab = "Delivery"
            deliveryBtn.BackgroundColor3 = Color3.fromRGB(255, 175, 30)
            autoDriveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end
        updatePanelsVisibility()
    end)

    adToggleBtn.Activated:Connect(function()
        if not isAutoDriving then
            if not pointA or not pointB then
                speedLabel.Text = (selectedLanguage == "EN") and "Error: Set Point A & B first" or ((selectedLanguage == "CN") and "错误: 请先设置 A 与 B 点" or "錯誤: 請先設定 A 與 B 點")
                return
            end
        end
        isAutoDriving = not isAutoDriving
        if isAutoDriving then
            adToggleBtn.Text = ((selectedLanguage == "EN") and "Auto Drive Switch: " or ((selectedLanguage == "CN") and "自动驾驶开关: " or "自動駕駛開關: ")) .. L.SwitchOn
            adToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        else
            adToggleBtn.Text = ((selectedLanguage == "EN") and "Auto Drive Switch: " or ((selectedLanguage == "CN") and "自动驾驶开关: " or "自動駕駛開關: ")) .. L.SwitchOff
            adToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end
    end)

    antiCriminalBtn.Activated:Connect(function()
        isAntiCriminalEnabled = not isAntiCriminalEnabled
        if isAntiCriminalEnabled then
            antiCriminalBtn.Text = L.AntiCriminalOn
            antiCriminalBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        else
            antiCriminalBtn.Text = L.AntiCriminalOff
            antiCriminalBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        end
    end)

    local isAvoidingOutlaw = false
    table.insert(activeConnections, task.spawn(function()
        while true do
            task.wait(0.2)
            if isAntiCriminalEnabled and not isAvoidingOutlaw then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local outbreakFound = false
                    for _, otherPlayer in ipairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character then
                            local otherHrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if otherHrp then
                                local dist = (otherHrp.Position - hrp.Position).Magnitude
                                if dist <= 100 then
                                    if otherPlayer.Team then
                                        local tName = otherPlayer.Team.Name
                                        if tName == "Outlaw" or string.lower(tName) == "outlaw" then
                                            outbreakFound = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if outbreakFound then
                        isAvoidingOutlaw = true
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 180, 0)
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
                        
                        local startTime = tick()
                        local stillOutlaw = false
                        while tick() - startTime < 5 do
                            task.wait(0.5)
                            local currentOutlawCheck = false
                            local cChar = player.Character
                            local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
                            if cHrp then
                                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                                    if otherPlayer ~= player and otherPlayer.Character then
                                        local otherHrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                                        if otherHrp then
                                            if (otherHrp.Position - cHrp.Position).Magnitude <= 100 then
                                                if otherPlayer.Team then
                                                    local tName = otherPlayer.Team.Name
                                                    if tName == "Outlaw" or string.lower(tName) == "outlaw" then
                                                        currentOutlawCheck = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if currentOutlawCheck then
                                stillOutlaw = true
                            end
                        end

                        local finalChar = player.Character
                        local finalHrp = finalChar and finalChar:FindFirstChild("HumanoidRootPart")
                        if finalHrp then
                            if stillOutlaw then
                                local anchor = workspace:FindFirstChild("DeliveryTargetAnchor", true)
                                if not anchor then
                                    for _, obj in ipairs(workspace:GetDescendants()) do
                                        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "target") or string.find(string.lower(obj.Name), "delivery") or string.find(string.lower(obj.Name), "destination") or string.find(string.lower(obj.Name), "drop")) then
                                            anchor = obj
                                            break
                                        end
                                    end
                                end
                                if anchor then
                                    local destPos = anchor:IsA("BasePart") and anchor.Position or anchor.PrimaryPart.Position
                                    finalHrp.CFrame = CFrame.new(destPos + Vector3.new(0, 3, 0))
                                    finalHrp.AssemblyLinearVelocity = Vector3.zero
                                    statusLabel.Text = (selectedLanguage == "EN") and "Status: Outlaw still near, teleported to end!" or ((selectedLanguage == "CN") and "状态: Outlaw仍存在，已直接瞬移至终点！" or "狀態: Outlaw仍存在，已直接瞬移至終點！")
                                else
                                    finalHrp.CFrame = finalHrp.CFrame - Vector3.new(0, 150, 0)
                                    finalHrp.AssemblyLinearVelocity = Vector3.zero
                                end
                            else
                                finalHrp.CFrame = finalHrp.CFrame - Vector3.new(0, 150, 0)
                                finalHrp.AssemblyLinearVelocity = Vector3.zero
                            end
                        end
                        
                        task.wait(1)
                        isAvoidingOutlaw = false
                    end
                end
            end
        end
    end))

    dlToggleBtn.Activated:Connect(function()
        if not isDeliveryRunning then
            if not checkDeliveryJobAndProfession() then
                statusLabel.Text = L.ErrNoJob
                return
            end
        end
        isDeliveryRunning = not isDeliveryRunning
        
        if isDeliveryRunning then
            dlToggleBtn.Text = ((selectedLanguage == "EN") and "Delivery Switch: " or ((selectedLanguage == "CN") and "送货功能开关: " or "送貨功能開關: ")) .. L.SwitchOn
            dlToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 175, 30)
            statusLabel.Text = L.FlyStart
            
            local noclipConn
            noclipConn = RunService.Stepped:Connect(function()
                if not isDeliveryRunning then
                    if noclipConn then noclipConn:Disconnect() end
                    return
                end
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            table.insert(activeConnections, noclipConn)
            
            task.spawn(function()
                while isDeliveryRunning do
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if not rootPart or not humanoid then 
                        task.wait(0.1)
                        continue 
                    end

                    humanoid.Health = humanoid.MaxHealth
                    if rootPart.Position.Y < -50 then
                        rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 150, 0)
                        rootPart.AssemblyLinearVelocity = Vector3.zero
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
                        break
                    end

                    local finalTargetPos = anchor:IsA("BasePart") and anchor.Position or anchor.PrimaryPart.Position

                    statusLabel.Text = L.Phase1
                    local highY = finalTargetPos.Y + 150
                    while isDeliveryRunning and rootPart.Position.Y < highY do
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, customFlySpeed, 0)
                        rootPart.CFrame = rootPart.CFrame + Vector3.new(0, customFlySpeed * 0.016, 0)
                        task.wait()
                    end
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.5)

                    statusLabel.Text = L.Phase2
                    while isDeliveryRunning do
                        local currentPos = rootPart.Position
                        local targetHorizontalPos = Vector3.new(finalTargetPos.X, highY, finalTargetPos.Z)
                        local horizDir = (Vector3.new(finalTargetPos.X, 0, finalTargetPos.Z) - Vector3.new(currentPos.X, 0, currentPos.Z))
                        local dist = horizDir.Magnitude
                        
                        if dist <= 100 then
                            break
                        end
                        
                        local moveDir = horizDir.Unit
                        rootPart.AssemblyLinearVelocity = Vector3.new(moveDir.X * customFlySpeed, 0, moveDir.Z * customFlySpeed)
                        rootPart.CFrame = CFrame.new(currentPos + (moveDir * math.min(customFlySpeed * 0.016, dist - 100)), targetHorizontalPos)
                        task.wait()
                    end
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.5)

                    statusLabel.Text = L.Phase3
                    local targetHeightY = finalTargetPos.Y + 5
                    while isDeliveryRunning and math.abs(rootPart.Position.Y - targetHeightY) > 2 do
                        local currentPos = rootPart.Position
                        local yDir = targetHeightY > currentPos.Y and 1 or -1
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, yDir * customFlySpeed, 0)
                        rootPart.CFrame = CFrame.new(Vector3.new(currentPos.X, currentPos.Y + (yDir * math.min(customFlySpeed * 0.016, math.abs(targetHeightY - currentPos.Y))), currentPos.Z), finalTargetPos)
                        task.wait()
                    end
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.5)

                    statusLabel.Text = L.Phase4
                    while isDeliveryRunning do
                        local currentPos = rootPart.Position
                        local finalDestXZ = Vector3.new(finalTargetPos.X, currentPos.Y, finalTargetPos.Z)
                        local distToFinal = (finalTargetPos - currentPos).Magnitude
                        
                        if distToFinal <= 2 then
                            break
                        end
                        
                        local moveDir = (finalTargetPos - currentPos).Unit
                        rootPart.AssemblyLinearVelocity = moveDir * math.min(customFlySpeed, distToFinal * 10)
                        rootPart.CFrame = CFrame.new(currentPos + (moveDir * math.min(customFlySpeed * 0.016, distToFinal)), finalTargetPos)
                        task.wait()
                    end
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    
                    statusLabel.Text = L.Success
                    isDeliveryRunning = false
                    task.wait(0.5)
                    break
                end
                
                dlToggleBtn.Text = ((selectedLanguage == "EN") and "Delivery Switch: " or ((selectedLanguage == "CN") and "送货功能开关: " or "送貨功能開關: ")) .. L.SwitchOff
                dlToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            end)
        else
            dlToggleBtn.Text = ((selectedLanguage == "EN") and "Delivery Switch: " or ((selectedLanguage == "CN") and "送货功能开关: " or "送貨功能開關: ")) .. L.SwitchOff
            dlToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            statusLabel.Text = L.Stopped
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
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
        if not isAntiAfkEnabled then return end
        local vu = game:GetService("VirtualUser")
        pcall(function()
            vu:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            vu:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end))

    table.insert(activeConnections, RunService.RenderStepped:Connect(function()
        if not isAutoDriving then return end
        local seat = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.SeatPart
        if not seat or not seat:IsA("VehicleSeat") then
            isAutoDriving = false
            adToggleBtn.Text = ((selectedLanguage == "EN") and "Auto Drive Switch: " or ((selectedLanguage == "CN") and "自动驾驶开关: " or "自動駕駛開關: ")) .. L.SwitchOff
            adToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
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

    updatePanelsVisibility()
end

showLanguageSelector()
