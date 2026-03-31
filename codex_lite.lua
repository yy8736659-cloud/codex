-- // CODEX LITE — ESP + Aimbot Only (~450 lines vs ~4070)
-- // Максимальная производительность, минимальная нагрузка
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

if not game:IsLoaded() then game.Loaded:Wait() end
local LP = Players.LocalPlayer
while not LP do task.wait(); LP = Players.LocalPlayer end
local Camera = Workspace.CurrentCamera
while not Camera do task.wait(); Camera = Workspace.CurrentCamera end
local Mouse = LP:GetMouse()

local guiParent
pcall(function() guiParent = game:GetService("CoreGui") end)
if not guiParent then guiParent = LP:WaitForChild("PlayerGui") end

local supportDrawing = pcall(function() return Drawing.new("Line") end)

-- ═══════════════════════════════════════════
-- SETTINGS (только ESP + Aimbot)
-- ═══════════════════════════════════════════
local S = {
    TeamCheck = false,
    TPtoMouse = false,
    TPBind = {type = "key", key = Enum.KeyCode.X},
    ESP = {
        On = false,
        Name = true, HP = true, Dist = true,
        Chams = false, Tracers = false, Glow = false,
        RainbowChams = false,
        VisibleCol = Color3.fromRGB(0, 255, 150),
        HiddenCol = Color3.fromRGB(255, 50, 50),
        Crosshair = false, CrosshairSize = 8,
        MaxDist = 600,
    },
    Aim = {
        On = false,
        ShowFOV = true, Radius = 150, Smooth = 5,
        Part = "Head",
        SmartAim = false, WallCheck = true,
        Prediction = false, PredictFactor = 0.15,
        SilentAim = false,
    },
}

-- ═══════════════════════════════════════════
-- TP BIND
-- ═══════════════════════════════════════════
local listeningTPBind = nil -- ссылка на кнопку GUI когда ждём нажатия

local function GetBindName()
    local b = S.TPBind
    if b.type == "key" then return b.key.Name end
    return b.input.Name
end

local function IsTPBindPressed(input)
    local b = S.TPBind
    if b.type == "key" then
        return input.KeyCode == b.key
    else
        return input.UserInputType == b.input
    end
end

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════
local espData = {}            -- player -> {bg, hl, glow, tracer, ...}
local visCache = {}           -- player -> bool
local smartCache = {}         -- player -> BasePart
local rainbowHue = 0
local isRMB = false
local menuOpen = true

local smartParts = {
    {"Head"},
    {"UpperTorso","Torso","LowerTorso"},
    {"RightUpperArm","RightLowerArm","RightHand","Right Arm"},
    {"LeftUpperArm","LeftLowerArm","LeftHand","Left Arm"},
    {"RightUpperLeg","RightLowerLeg","RightFoot","Right Leg"},
    {"LeftUpperLeg","LeftLowerLeg","LeftFoot","Left Leg"},
}

local aimRayParams = RaycastParams.new()
aimRayParams.FilterType = Enum.RaycastFilterType.Exclude

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function IsEnemy(p)
    if not p then return false end
    if S.TeamCheck and LP.Team and p.Team == LP.Team then return false end
    return true
end

local function Notify(msg)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Codex Lite", Text=msg, Duration=2.5}) end)
end

-- ═══════════════════════════════════════════
-- BACKGROUND: Visibility + SmartAim cache (optimized)
-- ═══════════════════════════════════════════
task.spawn(function()
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local filterTable = {} -- переиспользуемая таблица
    while true do
        local players = Players:GetPlayers()
        local n = #players
        task.wait(n > 15 and 0.2 or (n > 8 and 0.12 or 0.08))
        if not S.ESP.On and not S.Aim.On then continue end
        local ch = LP.Character
        if not ch then continue end
        local myHead = ch:FindFirstChild("Head")
        if not myHead then continue end
        local myHeadPos = myHead.Position
        
        -- Обновляем фильтр один раз за цикл
        filterTable[1] = ch
        filterTable[2] = Camera
        rp.FilterDescendantsInstances = filterTable
        
        local doSmartAim = S.Aim.SmartAim
        local doWallCheck = S.ESP.On or S.Aim.WallCheck

        for _, p in ipairs(players) do
            if p == LP then continue end
            local ec = p.Character
            if not ec then
                visCache[p] = nil
                smartCache[p] = nil
                continue
            end
            
            -- Visibility check
            if doWallCheck then
                local head = ec:FindFirstChild("Head")
                if head then
                    local dir = head.Position - myHeadPos
                    local res = Workspace:Raycast(myHeadPos, dir, rp)
                    visCache[p] = not res or res.Instance:IsDescendantOf(ec)
                else
                    visCache[p] = false
                end
            end
            
            -- SmartAim: поиск видимой части тела
            if doSmartAim then
                local best = nil
                for _, grp in ipairs(smartParts) do
                    for _, name in ipairs(grp) do
                        local part = ec:FindFirstChild(name)
                        if part and part:IsA("BasePart") then
                            local dir = part.Position - myHeadPos
                            local r = Workspace:Raycast(myHeadPos, dir, rp)
                            if not r or r.Instance:IsDescendantOf(ec) then
                                best = part
                                break
                            end
                        end
                    end
                    if best then break end
                end
                smartCache[p] = best
            end
        end
    end
end)

-- Rainbow hue
task.spawn(function()
    while task.wait(0.15) do
        if S.ESP.RainbowChams then rainbowHue = (rainbowHue + 0.02) % 1 end
    end
end)

-- Anti-AFK
pcall(function()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        VU:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VU:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ═══════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════
local screenGui = Instance.new("ScreenGui", guiParent)
screenGui.Name = "CodexLite"
screenGui.ResetOnSpawn = false

local function ClearESP(p)
    local d = espData[p]
    if not d then return end
    pcall(function() if d.bg then d.bg:Destroy() end end)
    pcall(function() if d.hl then d.hl:Destroy() end end)
    pcall(function() if d.glow then d.glow:Destroy() end end)
    pcall(function() if d.tracer then d.tracer:Remove() end end)
    pcall(function() if d.tracerLine then d.tracerLine:Destroy() end end)
    espData[p] = nil
end

local function FullCleanup(p)
    ClearESP(p)
    visCache[p] = nil
    smartCache[p] = nil
end
Players.PlayerRemoving:Connect(FullCleanup)

local function UpdateESP()
    if not S.ESP.On then
        for p in pairs(espData) do ClearESP(p) end
        return
    end
    local myPos = Camera.CFrame.Position
    local maxDist = S.ESP.MaxDist
    local showName = S.ESP.Name
    local showDist = S.ESP.Dist
    local showHP = S.ESP.HP
    local showChams = S.ESP.Chams
    local showGlow = S.ESP.Glow
    local showTracers = S.ESP.Tracers
    local isRainbow = S.ESP.RainbowChams
    local visCl = S.ESP.VisibleCol
    local hidCl = S.ESP.HiddenCol
    local showBG = showName or showHP or showDist
    local vpX = Camera.ViewportSize.X
    local vpY = Camera.ViewportSize.Y

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP or not IsEnemy(p) then ClearESP(p); continue end
        local ch = p.Character
        if not ch then ClearESP(p); continue end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local root = ch:FindFirstChild("HumanoidRootPart")
        if not (hum and root and hum.Health > 0) then ClearESP(p); continue end
        
        local dist = (myPos - root.Position).Magnitude
        if dist > maxDist then ClearESP(p); continue end

        -- Recreate if character changed
        if espData[p] and espData[p]._ch ~= ch then ClearESP(p) end

        if not espData[p] then
            local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0,160,0,52); bg.StudsOffset = Vector3.new(0,3.2,0); bg.AlwaysOnTop = true
            local panel = Instance.new("Frame", bg); panel.Size = UDim2.new(1,0,1,0); panel.BackgroundColor3 = Color3.fromRGB(10,10,15); panel.BackgroundTransparency = 0.45; panel.BorderSizePixel = 0
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0,6)
            local ps = Instance.new("UIStroke", panel); ps.Thickness = 1; ps.Transparency = 0.5
            local acc = Instance.new("Frame", panel); acc.Size = UDim2.new(1,0,0,2); acc.BackgroundTransparency = 0; acc.BorderSizePixel = 0
            Instance.new("UICorner", acc).CornerRadius = UDim.new(0,6)
            local nm = Instance.new("TextLabel", panel); nm.Size = UDim2.new(1,-8,0,16); nm.Position = UDim2.new(0,4,0,4); nm.BackgroundTransparency = 1; nm.Font = Enum.Font.GothamBold; nm.TextSize = 12; nm.TextStrokeTransparency = 0.4; nm.TextXAlignment = Enum.TextXAlignment.Left
            local dl = Instance.new("TextLabel", panel); dl.Size = UDim2.new(1,-8,0,12); dl.BackgroundTransparency = 1; dl.Font = Enum.Font.GothamSemibold; dl.TextSize = 10; dl.TextStrokeTransparency = 0.5; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.TextColor3 = Color3.fromRGB(180,180,200)
            local hpBg = Instance.new("Frame", panel); hpBg.Size = UDim2.new(1,-8,0,5); hpBg.BackgroundColor3 = Color3.fromRGB(30,30,40); hpBg.BackgroundTransparency = 0.3; hpBg.BorderSizePixel = 0
            Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1,0)
            local hpF = Instance.new("Frame", hpBg); hpF.Size = UDim2.new(1,0,1,0); hpF.BackgroundColor3 = Color3.fromRGB(0,255,100); hpF.BorderSizePixel = 0
            Instance.new("UICorner", hpF).CornerRadius = UDim.new(1,0)
            local hpT = Instance.new("TextLabel", hpBg); hpT.Size = UDim2.new(1,0,1,8); hpT.Position = UDim2.new(0,0,0,-1); hpT.BackgroundTransparency = 1; hpT.Font = Enum.Font.GothamBold; hpT.TextSize = 8; hpT.TextColor3 = Color3.new(1,1,1); hpT.TextStrokeTransparency = 0.3
            local hl = Instance.new("Highlight"); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            local gw = Instance.new("Highlight"); gw.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; gw.FillTransparency = 0.7; gw.OutlineTransparency = 0
            espData[p] = {_ch=ch, bg=bg, panel=panel, ps=ps, acc=acc, nm=nm, dl=dl, hpBg=hpBg, hpF=hpF, hpT=hpT, hl=hl, glow=gw}
        end

        local d = espData[p]
        local vis = visCache[p] or false
        local col = vis and visCl or hidCl
        d.acc.BackgroundColor3 = col; d.ps.Color = col

        local y, h = 4, 6
        if showName then
            d.nm.Visible = true; d.nm.Position = UDim2.new(0,4,0,y)
            d.nm.Text = p.DisplayName ~= p.Name and (p.DisplayName.."  ·  "..p.Name) or p.Name
            d.nm.TextColor3 = col; y += 16; h += 16
        else d.nm.Visible = false end
        if showDist then
            d.dl.Visible = true; d.dl.Position = UDim2.new(0,4,0,y)
            d.dl.Text = "📏 "..math.floor(dist).." m"
            y += 14; h += 14
        else d.dl.Visible = false end
        if showHP then
            d.hpBg.Visible = true; d.hpT.Visible = true; d.hpBg.Position = UDim2.new(0,4,0,y)
            local f = math.clamp(hum.Health/hum.MaxHealth,0,1)
            d.hpF.Size = UDim2.new(f,0,1,0)
            d.hpF.BackgroundColor3 = f > 0.5 and Color3.fromRGB(math.floor((1-f)*510),255,50) or Color3.fromRGB(255,math.floor(f*510),50)
            d.hpT.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
            y += 10; h += 10
        else d.hpBg.Visible = false; d.hpT.Visible = false end

        d.bg.Size = UDim2.new(0,160,0,h)
        if showBG then d.bg.Parent = root; d.bg.Enabled = true
        else d.bg.Parent = nil end

        -- Chams
        if showChams then
            local cc = isRainbow and Color3.fromHSV(rainbowHue,1,1) or col
            d.hl.Parent = ch; d.hl.FillColor = cc; d.hl.OutlineColor = cc; d.hl.FillTransparency = 0.5; d.hl.OutlineTransparency = 0
        else d.hl.Parent = nil end

        -- Glow
        if showGlow then
            local gc = isRainbow and Color3.fromHSV(rainbowHue,1,1) or col
            d.glow.Parent = ch; d.glow.FillColor = gc; d.glow.OutlineColor = gc; d.glow.FillTransparency = 0.85; d.glow.OutlineTransparency = 0.2
        else d.glow.Parent = nil end

        -- Tracers
        if showTracers then
            local pos, on = Camera:WorldToViewportPoint(root.Position)
            if on then
                if supportDrawing then
                    if not d.tracer then d.tracer = Drawing.new("Line"); d.tracer.Thickness = 1.5; d.tracer.Transparency = 1 end
                    d.tracer.Visible = true; d.tracer.From = Vector2.new(vpX/2, vpY); d.tracer.To = Vector2.new(pos.X, pos.Y); d.tracer.Color = col
                else
                    if not d.tracerLine then local tl = Instance.new("Frame", screenGui); tl.BorderSizePixel=0; tl.AnchorPoint=Vector2.new(0.5,0.5); d.tracerLine = tl end
                    local fr = Vector2.new(vpX/2, vpY); local to = Vector2.new(pos.X, pos.Y); local ln = (fr-to).Magnitude
                    d.tracerLine.Size = UDim2.new(0,2,0,ln); d.tracerLine.Position = UDim2.new(0,(fr.X+to.X)/2,0,(fr.Y+to.Y)/2); d.tracerLine.Rotation = math.deg(math.atan2(to.Y-fr.Y,to.X-fr.X))+90; d.tracerLine.Visible = true; d.tracerLine.BackgroundColor3 = col
                end
            else
                if d.tracer then d.tracer.Visible = false end
                if d.tracerLine then d.tracerLine.Visible = false end
            end
        else
            if d.tracer then d.tracer.Visible = false end
            if d.tracerLine then d.tracerLine.Visible = false end
        end
    end
end

-- ═══════════════════════════════════════════
-- AIMBOT
-- ═══════════════════════════════════════════
local function GetTarget()
    local tgt, aimPart = nil, nil
    local bestDist = math.huge
    local fov = S.Aim.Radius
    local mLoc = UIS:GetMouseLocation()
    local myChar = LP.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not myHead then return nil, nil end
    local myHeadPos = myHead.Position
    aimRayParams.FilterDescendantsInstances = {myChar, Camera}

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP or not IsEnemy(p) then continue end
        local ch = p.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if not (ch and hum and hum.Health > 0 and root) then continue end

        local dist3D = (myHeadPos - root.Position).Magnitude
        if dist3D > S.ESP.MaxDist then continue end

        -- Quick screen/FOV check before expensive raycasts
        local rootScreen, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        if (Vector2.new(rootScreen.X, rootScreen.Y) - mLoc).Magnitude > fov then continue end

        -- Real-time wall check (inline raycast, no stale cache)
        local part = nil
        if S.Aim.SmartAim then
            for _, grp in ipairs(smartParts) do
                for _, name in ipairs(grp) do
                    local bp = ch:FindFirstChild(name)
                    if bp and bp:IsA("BasePart") then
                        local res = Workspace:Raycast(myHeadPos, bp.Position - myHeadPos, aimRayParams)
                        if not res or res.Instance:IsDescendantOf(ch) then
                            part = bp; break
                        end
                    end
                end
                if part then break end
            end
        else
            part = ch:FindFirstChild(S.Aim.Part)
            if part and S.Aim.WallCheck then
                local res = Workspace:Raycast(myHeadPos, part.Position - myHeadPos, aimRayParams)
                if res and not res.Instance:IsDescendantOf(ch) then
                    part = nil
                end
            end
        end

        -- Nearest target by 3D distance (within FOV)
        if part and dist3D < bestDist then
            bestDist = dist3D
            tgt = p; aimPart = part
        end
    end
    return tgt, aimPart
end

-- ═══════════════════════════════════════════
-- FOV Circle + Crosshair
-- ═══════════════════════════════════════════
local fovCircle, chL, chR, chT, chB
if supportDrawing then
    fovCircle = Drawing.new("Circle"); fovCircle.Thickness = 1.5; fovCircle.Color = Color3.new(1,1,1); fovCircle.Filled = false
    chL = Drawing.new("Line"); chL.Thickness = 1.5; chL.Color = Color3.new(1,1,1)
    chR = Drawing.new("Line"); chR.Thickness = 1.5; chR.Color = Color3.new(1,1,1)
    chT = Drawing.new("Line"); chT.Thickness = 1.5; chT.Color = Color3.new(1,1,1)
    chB = Drawing.new("Line"); chB.Thickness = 1.5; chB.Color = Color3.new(1,1,1)
end

-- ═══════════════════════════════════════════
-- GUI — Infinite Yield style, slide-in from left
-- ═══════════════════════════════════════════
local UI = {}
local toggleButtons = {} -- для обновления визуала при ESP ON

do
    local accent = Color3.fromRGB(160,90,255)
    local accentDark = Color3.fromRGB(100,55,180)
    local bg = Color3.fromRGB(15,12,25)
    local soft = Color3.fromRGB(22,18,38)
    local softer = Color3.fromRGB(30,25,50)
    local txtM = Color3.fromRGB(235,230,255)
    local txtS = Color3.fromRGB(155,145,190)
    local onCol = Color3.fromRGB(100,220,120)
    local offCol = Color3.fromRGB(180,60,60)

    -- Main frame — starts off-screen left
    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.new(0, 260, 0, 500)
    main.Position = UDim2.new(0, -270, 0.5, -250)
    main.BackgroundColor3 = bg; main.BackgroundTransparency = 0.02
    main.Active = true; main.ClipsDescendants = true; main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local ms = Instance.new("UIStroke", main); ms.Color = accentDark; ms.Transparency = 0.3; ms.Thickness = 1.2
    UI.main = main

    -- Slide-in / slide-out animation
    local OPEN_POS = UDim2.new(0, 8, 0.5, -250)
    local CLOSED_POS = UDim2.new(0, -270, 0.5, -250)
    local slideInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local function SlideIn()
        TweenService:Create(main, slideInfo, {Position = OPEN_POS}):Play()
    end
    local function SlideOut()
        TweenService:Create(main, slideInfo, {Position = CLOSED_POS}):Play()
    end
    UI.SlideIn = SlideIn
    UI.SlideOut = SlideOut

    -- Initial slide-in
    task.delay(0.3, SlideIn)

    -- Dragging (only from header)
    local dragging, dragStart, startPos

    -- ── Header ──
    local hdr = Instance.new("Frame", main)
    hdr.Size = UDim2.new(1, 0, 0, 34); hdr.BackgroundColor3 = Color3.fromRGB(20, 16, 35); hdr.BorderSizePixel = 0
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 10)
    local hdrLine = Instance.new("Frame", hdr)
    hdrLine.Size = UDim2.new(1, 0, 0, 2); hdrLine.Position = UDim2.new(0, 0, 1, -2)
    hdrLine.BackgroundColor3 = accent; hdrLine.BackgroundTransparency = 0.5; hdrLine.BorderSizePixel = 0
    local hdrTxt = Instance.new("TextLabel", hdr)
    hdrTxt.Size = UDim2.new(1, -10, 1, 0); hdrTxt.Position = UDim2.new(0, 10, 0, 0)
    hdrTxt.BackgroundTransparency = 1; hdrTxt.Text = "CODEX LITE"
    hdrTxt.TextColor3 = accent; hdrTxt.Font = Enum.Font.GothamBlack; hdrTxt.TextSize = 13
    hdrTxt.TextXAlignment = Enum.TextXAlignment.Left

    hdr.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ── Scroll ──
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -6, 1, -42); scroll.Position = UDim2.new(0, 3, 0, 38)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = accent
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 2)

    local idx = 0

    -- ── Tooltip system ──
    local tooltip = Instance.new("Frame", screenGui)
    tooltip.Size = UDim2.new(0, 200, 0, 0); tooltip.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
    tooltip.BackgroundTransparency = 0.05; tooltip.BorderSizePixel = 0; tooltip.Visible = false; tooltip.ZIndex = 100
    tooltip.AutomaticSize = Enum.AutomaticSize.Y; tooltip.ClipsDescendants = false
    Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 6)
    local tts = Instance.new("UIStroke", tooltip); tts.Color = accent; tts.Transparency = 0.4; tts.Thickness = 1
    local ttp = Instance.new("UIPadding", tooltip); ttp.PaddingTop = UDim.new(0,5); ttp.PaddingBottom = UDim.new(0,5); ttp.PaddingLeft = UDim.new(0,8); ttp.PaddingRight = UDim.new(0,8)
    local ttLabel = Instance.new("TextLabel", tooltip)
    ttLabel.Size = UDim2.new(1, 0, 0, 0); ttLabel.AutomaticSize = Enum.AutomaticSize.Y
    ttLabel.BackgroundTransparency = 1; ttLabel.TextColor3 = Color3.fromRGB(210, 200, 240)
    ttLabel.Font = Enum.Font.GothamSemibold; ttLabel.TextSize = 10; ttLabel.TextWrapped = true
    ttLabel.TextXAlignment = Enum.TextXAlignment.Left; ttLabel.ZIndex = 101

    local tooltipHideThread = nil
    local function ShowTooltip(guiObj, text)
        if not text or text == "" then return end
        if tooltipHideThread then task.cancel(tooltipHideThread); tooltipHideThread = nil end
        ttLabel.Text = text
        local absPos = guiObj.AbsolutePosition
        local absSize = guiObj.AbsoluteSize
        tooltip.Position = UDim2.new(0, absPos.X + absSize.X + 6, 0, absPos.Y)
        tooltip.Visible = true
    end
    local function HideTooltip()
        tooltipHideThread = task.delay(0.15, function()
            tooltip.Visible = false
            tooltipHideThread = nil
        end)
    end

    -- ── Section header ──
    local function Section(text)
        idx += 1
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -4, 0, 22); f.BackgroundTransparency = 1; f.LayoutOrder = idx
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -8, 1, 0); l.Position = UDim2.new(0, 4, 0, 0)
        l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = txtS
        l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- ── Toggle with pill switch + tooltip ──
    local function Toggle(text, get, set, trackKey, desc)
        idx += 1
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1, -4, 0, 28); row.BackgroundColor3 = soft; row.BackgroundTransparency = 0.1
        row.BorderSizePixel = 0; row.LayoutOrder = idx
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -56, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = txtM
        lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Pill background
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 36, 0, 18); pill.Position = UDim2.new(1, -46, 0.5, -9)
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        -- Pill knob
        local knob = Instance.new("Frame", pill)
        knob.Size = UDim2.new(0, 14, 0, 14); knob.BorderSizePixel = 0
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function refresh()
            local on = get()
            pill.BackgroundColor3 = on and onCol or offCol
            knob.Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        end
        refresh()

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
        btn.MouseButton1Click:Connect(function()
            set(not get()); refresh()
        end)

        -- hover + tooltip
        btn.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            if desc then ShowTooltip(row, desc) end
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
            HideTooltip()
        end)

        if trackKey then
            toggleButtons[trackKey] = refresh
        end

        return refresh
    end

    -- ── Slider with text input ──
    local function Slider(text, min, max, cur, cb)
        idx += 1
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1, -4, 0, 38); row.BackgroundColor3 = soft; row.BackgroundTransparency = 0.1
        row.BorderSizePixel = 0; row.LayoutOrder = idx
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        -- Label
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.55, -6, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 2)
        lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = txtS
        lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Text input box
        local inputBox = Instance.new("TextBox", row)
        inputBox.Size = UDim2.new(0, 44, 0, 16); inputBox.Position = UDim2.new(1, -54, 0, 2)
        inputBox.BackgroundColor3 = softer; inputBox.BorderSizePixel = 0
        inputBox.TextColor3 = txtM; inputBox.Font = Enum.Font.GothamBold; inputBox.TextSize = 10
        inputBox.Text = tostring(cur); inputBox.ClearTextOnFocus = false; inputBox.ClipsDescendants = true
        Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
        local is = Instance.new("UIStroke", inputBox); is.Color = accentDark; is.Transparency = 0.6; is.Thickness = 1

        -- Slider bar
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -20, 0, 6); bar.Position = UDim2.new(0, 10, 0, 24)
        bar.BackgroundColor3 = Color3.fromRGB(35, 28, 55); bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(math.clamp((cur - min) / (max - min), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = accent; fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        -- Knob on slider
        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 10, 0, 10); knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(math.clamp((cur - min) / (max - min), 0, 1), 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function setVal(v)
            v = math.clamp(math.floor(v), min, max)
            local rel = (v - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            inputBox.Text = tostring(v)
            cb(v)
        end

        -- Drag slider
        local hitArea = Instance.new("TextButton", bar)
        hitArea.Size = UDim2.new(1, 0, 1, 10); hitArea.Position = UDim2.new(0, 0, 0, -5)
        hitArea.BackgroundTransparency = 1; hitArea.Text = ""
        local isD = false
        local function updFromInput(input)
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            setVal(min + rel * (max - min))
        end
        hitArea.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isD = true; updFromInput(i) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isD = false end end)
        UIS.InputChanged:Connect(function(i) if isD and i.UserInputType == Enum.UserInputType.MouseMovement then updFromInput(i) end end)

        -- Manual text input
        inputBox.FocusLost:Connect(function(enter)
            local n = tonumber(inputBox.Text)
            if n then
                setVal(n)
            else
                inputBox.Text = tostring(math.floor(min + (fill.Size.X.Scale) * (max - min)))
            end
        end)
    end

    -- ── Button (for target switch etc) ──
    local function Btn(text, cb, desc)
        idx += 1
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, -4, 0, 26); b.BackgroundColor3 = softer; b.BackgroundTransparency = 0.1
        b.TextColor3 = txtM; b.Font = Enum.Font.GothamSemibold; b.TextSize = 11; b.Text = text; b.LayoutOrder = idx
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            if desc then ShowTooltip(b, desc) end
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
            HideTooltip()
        end)
        b.MouseButton1Click:Connect(function() cb(b) end)
        return b
    end

    -- ═══════════════════════════════════
    -- ESP section
    -- ═══════════════════════════════════
    Section("▸ ESP")

    -- ESP master toggle — turns on Name, Dist, HP, Chams together
    local espSubRefreshers = {}
    Toggle("ВХ (ESP)", function() return S.ESP.On end, function(v)
        S.ESP.On = v
        if v then
            S.ESP.Name = true; S.ESP.Dist = true; S.ESP.HP = true; S.ESP.Chams = true
            for _, rf in pairs(espSubRefreshers) do rf() end
            Notify("ESP ВКЛ — все функции активны")
        else
            Notify("ESP ВЫКЛ")
        end
    end, nil, "Включает ВСЁ: имена, ХП, дистанцию и чамсы. Главный переключатель ESP.")

    espSubRefreshers.name = Toggle("  Имена", function() return S.ESP.Name end, function(v) S.ESP.Name = v end, "espName", "Показывает имя игрока над головой")
    espSubRefreshers.dist = Toggle("  Дистанция", function() return S.ESP.Dist end, function(v) S.ESP.Dist = v end, "espDist", "Показывает расстояние до игрока в метрах")
    espSubRefreshers.hp   = Toggle("  ХП", function() return S.ESP.HP end, function(v) S.ESP.HP = v end, "espHP", "Полоска здоровья игрока")
    espSubRefreshers.chams= Toggle("  Чамсы", function() return S.ESP.Chams end, function(v) S.ESP.Chams = v end, "espChams", "Подсветка модели игрока через стены")
    Toggle("  Трейсеры", function() return S.ESP.Tracers end, function(v) S.ESP.Tracers = v end, nil, "Линии от низа экрана к игрокам")
    Toggle("  Свечение", function() return S.ESP.Glow end, function(v) S.ESP.Glow = v end, nil, "Мягкое свечение вокруг модели")
    Toggle("  Радужные чамсы", function() return S.ESP.RainbowChams end, function(v) S.ESP.RainbowChams = v end, nil, "Чамсы и свечение переливаются радугой")
    Toggle("  Прицел", function() return S.ESP.Crosshair end, function(v) S.ESP.Crosshair = v end, nil, "Рисует крестик прицела в центре экрана")

    -- ═══════════════════════════════════
    -- AIMBOT section
    -- ═══════════════════════════════════
    Section("▸ AIMBOT")
    Toggle("Аимбот (ПКМ)", function() return S.Aim.On end, function(v) S.Aim.On = v end, nil, "Зажми ПКМ — прицел наводится на ближайшего врага")
    Toggle("  Тихий прицел", function() return S.Aim.SilentAim end, function(v) S.Aim.SilentAim = v end, nil, "Камера мгновенно наводится, без плавности")
    Toggle("  Проверка стен", function() return S.Aim.WallCheck end, function(v) S.Aim.WallCheck = v end, nil, "Не целится в игроков за стенами")
    Toggle("  Умный прицел", function() return S.Aim.SmartAim end, function(v) S.Aim.SmartAim = v end, nil, "Выбирает видимую часть тела, если голова скрыта")
    Toggle("  Предсказание", function() return S.Aim.Prediction end, function(v) S.Aim.Prediction = v end, nil, "Компенсирует движение цели, стреляет на опережение")
    Toggle("  Круг FOV", function() return S.Aim.ShowFOV end, function(v) S.Aim.ShowFOV = v end, nil, "Рисует радиус захвата аимбота вокруг курсора")
    Btn("  Цель: Голова", function(b)
        if S.Aim.Part == "Head" then S.Aim.Part = "HumanoidRootPart"; b.Text = "  Цель: Тело"
        else S.Aim.Part = "Head"; b.Text = "  Цель: Голова" end
    end, "Переключает точку наведения: голова или торс")
    Slider("Скорость", 1, 50, 5, function(v) S.Aim.Smooth = v end)
    Slider("FOV Радиус", 10, 1000, 150, function(v) S.Aim.Radius = v end)
    Slider("Предсказание", 1, 100, 15, function(v) S.Aim.PredictFactor = v / 100 end)

    -- ═══════════════════════════════════
    -- MISC section
    -- ═══════════════════════════════════
    Section("▸ ПРОЧЕЕ")
    Toggle("ТимЧек", function() return S.TeamCheck end, function(v) S.TeamCheck = v end, nil, "Не показывает и не целится в союзников (тиммейтов)")
    Toggle("ТП к курсору", function() return S.TPtoMouse end, function(v) S.TPtoMouse = v end, nil, "Телепортирует к позиции курсора по нажатию бинда")
    local tpBindBtn = Btn("  Бинд: "..GetBindName(), function(b)
        listeningTPBind = b
        b.Text = "  [Нажми любую клавишу...]"
    end, "Нажми, затем нажми любую клавишу или кнопку мыши для назначения бинда")

    -- Auto-resize
    local function resizeMain()
        local h = 42 + layout.AbsoluteContentSize.Y + 8
        main.Size = UDim2.new(0, 260, 0, math.min(h, 520))
    end
    resizeMain()
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeMain)
end

-- ═══════════════════════════════════════════
-- INPUT
-- ═══════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gp)
    -- Перехват бинда: ждём любую клавишу/кнопку
    if listeningTPBind then
        local name = nil
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            S.TPBind = {type = "key", key = input.KeyCode}
            name = input.KeyCode.Name
        elseif input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Keyboard then
            S.TPBind = {type = "mouse", input = input.UserInputType}
            name = input.UserInputType.Name
        end
        if name then
            listeningTPBind.Text = "  Бинд: "..name
            listeningTPBind = nil
            Notify("Бинд ТП: "..name)
            return
        end
    end
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        if menuOpen then UI.SlideIn() else UI.SlideOut() end
    end
    if not gp and S.TPtoMouse and IsTPBindPressed(input) then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local mouseHit = Mouse.Hit
            if mouseHit then
                hrp.CFrame = mouseHit + Vector3.new(0, 3, 0)
            end
        end
    end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isRMB = true end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isRMB = false end
end)

-- ═══════════════════════════════════════════
-- MAIN LOOP (RenderStepped) — optimized
-- ═══════════════════════════════════════════
local lastEspUpdate = 0
local ESP_INTERVAL = 0.045 -- ~22 fps ESP update, плавнее чем 15 кадров

-- Кэш для избежания аллокаций каждый кадр
local _crosshairVisible = false
local _fovVisible = false
local _lastAimTarget = nil

RunService.RenderStepped:Connect(function(dt)
    local clockNow = os.clock()

    -- ESP: обновление по таймеру (стабильная частота вне зависимости от FPS)
    if clockNow - lastEspUpdate >= ESP_INTERVAL then
        lastEspUpdate = clockNow
        local ok, err = pcall(UpdateESP)
        if not ok then warn("[Codex Lite] ESP error:", err) end
    end

    -- Ранний выход если нет Drawing
    local aimOn = S.Aim.On
    local espCrosshair = S.ESP.Crosshair

    -- FOV Circle + Crosshair: обновляем только если нужно
    if supportDrawing then
        local showFov = aimOn and S.Aim.ShowFOV
        if showFov or espCrosshair then
            local mLoc = UIS:GetMouseLocation()

            if showFov ~= _fovVisible then
                fovCircle.Visible = showFov
                _fovVisible = showFov
            end
            if showFov then
                fovCircle.Position = mLoc
                fovCircle.Radius = S.Aim.Radius
            end

            if espCrosshair then
                if not _crosshairVisible then
                    chL.Visible = true; chR.Visible = true; chT.Visible = true; chB.Visible = true
                    _crosshairVisible = true
                end
                local sz = S.ESP.CrosshairSize
                local gap = 4
                local mx, my = mLoc.X, mLoc.Y
                chL.From = Vector2.new(mx - sz, my); chL.To = Vector2.new(mx - gap, my)
                chR.From = Vector2.new(mx + gap, my); chR.To = Vector2.new(mx + sz, my)
                chT.From = Vector2.new(mx, my - sz); chT.To = Vector2.new(mx, my - gap)
                chB.From = Vector2.new(mx, my + gap); chB.To = Vector2.new(mx, my + sz)
            elseif _crosshairVisible then
                chL.Visible = false; chR.Visible = false; chT.Visible = false; chB.Visible = false
                _crosshairVisible = false
            end
        else
            if _fovVisible then fovCircle.Visible = false; _fovVisible = false end
            if _crosshairVisible then
                chL.Visible = false; chR.Visible = false; chT.Visible = false; chB.Visible = false
                _crosshairVisible = false
            end
        end
    end

    -- Aimbot: frame-rate independent smoothing
    if aimOn and isRMB then
        local _, part = GetTarget()
        if part then
            local aimPos = part.Position
            local parent = part.Parent
            if S.Aim.Prediction and parent then
                local hrp = parent:FindFirstChild("HumanoidRootPart")
                if hrp then
                    aimPos = aimPos + hrp.AssemblyLinearVelocity * S.Aim.PredictFactor
                end
            end
            if S.Aim.SilentAim then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPos)
            else
                -- dt-based smoothing: плавность не зависит от FPS
                local smoothFactor = math.clamp(dt * 60 / S.Aim.Smooth, 0.001, 1)
                local mLoc = UIS:GetMouseLocation()
                local pos = Camera:WorldToViewportPoint(aimPos)
                local dx, dy = pos.X - mLoc.X, pos.Y - mLoc.Y
                if typeof(mousemoverel) == "function" then
                    mousemoverel(dx * smoothFactor, dy * smoothFactor)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), smoothFactor)
                end
            end
        end
    end
end)

Notify("Codex Lite загружен! [Insert] — меню")
