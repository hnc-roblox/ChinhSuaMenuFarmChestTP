-- 🌌 HNC Hub - Full Pack: Banner + Aura + NameTag + Chest TP + ServerHop + Toggles + STOP
-- By HNC Hub (fix STOP hiển thị + dừng sạch mọi thứ)

repeat task.wait(0.1) until game:IsLoaded()

--// Services & Shortcuts
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId

--// Global state
local STOP_ALL = false
local AllConnections = {}
local AllThreads = {}
local UIS_TO_CLEAN = {
    "HNC_Purple_UI","HN_MiniUI","HNC_Hub_HopUI","HNC_STOP_GUI"
}

--// Helpers
local function SafeConnect(signal, fn)
    local ok, con = pcall(function() return signal:Connect(fn) end)
    if ok and con then table.insert(AllConnections, con) end
    return con
end

local function TrackThread(th)
    table.insert(AllThreads, th)
    return th
end

local function getCharacter()
    if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
    LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    return LocalPlayer.Character
end

local function clearOldUIs()
    for _,n in ipairs(UIS_TO_CLEAN) do
        local g = CoreGui:FindFirstChild(n)
        if g then pcall(function() g:Destroy() end) end
    end
end

local function disconnectAll()
    for _,c in ipairs(AllConnections) do
        pcall(function() c:Disconnect() end)
    end
end

local function removeAuraAndLabels()
    local ch = LocalPlayer.Character
    if ch then
        local a = ch:FindFirstChild("PurpleAura")
        if a then pcall(function() a:Destroy() end) end
        local head = ch:FindFirstChild("Head") or ch:FindFirstChildWhichIsA("BasePart")
        if head then
            local b = head:FindFirstChild("HNC_FastAttack_Label")
            if b then pcall(function() b:Destroy() end) end
        end
    end
end

-- Invisible control (player + map) so ta có thể trả về mặc định khi STOP
local Invisible = false
local function setInvisible(state)
    local ch = LocalPlayer.Character
    if not ch then return end
    for _,part in ipairs(ch:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.LocalTransparencyModifier = state and 1 or 0
        end
    end
end

local function setMapInvisible(state)
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            if not LocalPlayer.Character or not obj:IsDescendantOf(LocalPlayer.Character) then
                obj.LocalTransparencyModifier = state and 1 or 0
            end
        end
    end
end

--// STOP: dừng sạch mọi thứ + trả UI/world về bình thường
local function StopEverything()
    if STOP_ALL then return end
    STOP_ALL = true

    -- Tắt invis & clear map về mặc định
    pcall(function() setInvisible(false) end)
    pcall(function() setMapInvisible(false) end)

    -- Gỡ aura/label
    removeAuraAndLabels()

    -- Ngắt toàn bộ connection / loop
    disconnectAll()

    -- Xoá toàn bộ UI của script
    clearOldUIs()
end

--// Dọn UI cũ trước khi tạo mới
clearOldUIs()

--// ===== STOP BUTTON (tròn, tím, góc trái) =====
do
    local stopGui = Instance.new("ScreenGui")
    stopGui.Name = "HNC_STOP_GUI"
    stopGui.IgnoreGuiInset = true
    stopGui.ResetOnSpawn = false
    stopGui.DisplayOrder = 9999 -- nổi trên cùng
    stopGui.Parent = CoreGui

    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "STOP"
    stopBtn.Size = UDim2.new(0, 50, 0, 50)
    stopBtn.Position = UDim2.new(0, 20, 0, 20)
    stopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    stopBtn.Text = "STOP"
    stopBtn.TextScaled = true
    stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    stopBtn.Font = Enum.Font.GothamBlack
    stopBtn.Parent = stopGui
    Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(1, 0)

    SafeConnect(stopBtn.MouseButton1Click, function()
        StopEverything()
        pcall(function() stopGui:Destroy() end)
    end)
end

--// ===== Banner UI =====
do
    local gui = Instance.new("ScreenGui")
    gui.Name = "HNC_Purple_UI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.45, 0, 0.1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.15, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = gui
    frame.Visible = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 25)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(170, 0, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.4, 0, 2, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.5, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970"
    glow.ImageColor3 = Color3.fromRGB(170, 0, 255)
    glow.ImageTransparency = 0.55
    glow.ZIndex = -1
    glow.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 0, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 25))
    }
    gradient.Rotation = 45
    gradient.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "HNC Hub - Auto Collect Chest"
    text.TextColor3 = Color3.fromRGB(200, 0, 255)
    text.Font = Enum.Font.GothamBlack
    text.TextScaled = true
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.Parent = frame

    -- Animate in
    frame.Visible = true
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(0.2, 0, 0.05, 0)
    text.TextTransparency = 1
    stroke.Thickness = 0
    glow.ImageTransparency = 1

    TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.3, Size = UDim2.new(0.45, 0, 0.1, 0)
    }):Play()
    TweenService:Create(text, TweenInfo.new(1, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    TweenService:Create(stroke, TweenInfo.new(1, Enum.EasingStyle.Quad), {Thickness = 2}):Play()
    TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Quad), {ImageTransparency = 0.55}):Play()
end

--// ===== Aura tím + NameTag rainbow =====
do
    local function applyPurpleAura(char)
        if STOP_ALL or not char then return end
        if char:FindFirstChild("PurpleAura") then
            char.PurpleAura:Destroy()
        end
        local aura = Instance.new("Highlight")
        aura.Name = "PurpleAura"
        aura.FillColor = Color3.fromRGB(170, 0, 255)
        aura.OutlineColor = Color3.fromRGB(200, 100, 255)
        aura.FillTransparency = 0.3
        aura.OutlineTransparency = 0
        aura.Parent = char
    end

    local function createBillboardFor(character)
        if STOP_ALL or not character then return end
        local head = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")
        if not head then return end

        local existing = head:FindFirstChild("HNC_FastAttack_Label")
        if existing then existing:Destroy() end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HNC_FastAttack_Label"
        billboard.Adornee = head
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.Parent = head

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Label"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = "HNC Hub"
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 18
        textLabel.TextStrokeTransparency = 0.6
        textLabel.TextTransparency = 0
        textLabel.Parent = billboard

        local hue = 0
        local con = RunService.RenderStepped:Connect(function(dt)
            if STOP_ALL then con:Disconnect() return end
            hue = (hue + dt * 1) % 1
            local rgb = Color3.fromHSV(hue, 0.9, 1)
            if textLabel.Parent then
                textLabel.TextColor3 = rgb
            else
                con:Disconnect()
            end
        end)
        table.insert(AllConnections, con)
    end

    if LocalPlayer.Character then
        applyPurpleAura(LocalPlayer.Character)
        createBillboardFor(LocalPlayer.Character)
    end
    SafeConnect(LocalPlayer.CharacterAdded, function(char)
        char:WaitForChild("HumanoidRootPart")
        task.wait(1)
        if STOP_ALL then return end
        applyPurpleAura(char)
        createBillboardFor(char)
    end)
end

--// ===== Đổi team liên tục sang Marines (có thể tắt bằng STOP) =====
TrackThread(task.spawn(function()
    while not STOP_ALL do
        pcall(function()
            local rem = ReplicatedStorage:FindFirstChild("Remotes")
            if rem and rem:FindFirstChild("CommF_") then
                rem.CommF_:InvokeServer("SetTeam", "Marines")
            end
        end)
        task.wait(1)
    end
end))

--// ===== Auto Chest TP =====
do
    local UncheckedChests, FirstRun = {}, true

    local function getChestsSorted()
        if FirstRun then
            FirstRun = false
            for _, obj in pairs(game:GetDescendants()) do
                if obj.ClassName == "Part" and obj.Name:find("Chest") then
                    table.insert(UncheckedChests, obj)
                end
            end
        end
        local list = {}
        for _, c in ipairs(UncheckedChests) do
            if c and c.Parent and c:FindFirstChild("TouchInterest") then
                table.insert(list, c)
            end
        end
        local root = getCharacter():WaitForChild("HumanoidRootPart")
        table.sort(list, function(a,b)
            return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
        end)
        return list
    end

    local function Teleport(cf)
        if STOP_ALL then return end
        local root = getCharacter():WaitForChild("HumanoidRootPart")
        root.CFrame = cf
    end

    local function runChestLoop()
        TrackThread(task.spawn(function()
            while not STOP_ALL and LocalPlayer.Character and LocalPlayer.Character.Parent do
                local chests = getChestsSorted()
                if #chests > 0 then
                    Teleport(chests[1].CFrame)
                end
                task.wait()
            end
        end))
    end

    runChestLoop()
    SafeConnect(LocalPlayer.CharacterAdded, function()
        if not STOP_ALL then getCharacter() runChestLoop() end
    end)
end

--// ===== Mini Toggles: Anti Kick (Auto Reset), Invisible, Clear Map =====
do
    local gui = Instance.new("ScreenGui")
    gui.Name = "HN_MiniUI"
    gui.Parent = CoreGui

    local function createToggle(name, posY, default, callback)
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 140, 0, 15)
        title.Position = UDim2.new(1, -160, 0.1, posY)
        title.BackgroundTransparency = 1
        title.Text = name
        title.TextColor3 = Color3.fromRGB(170, 0, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 12
        title.Parent = gui

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.Position = UDim2.new(1, -80, 0.1, posY + 18)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = gui
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local state = default
        local function update()
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
                btn.Text = "✓"
            else
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                btn.Text = ""
            end
        end
        update()

        SafeConnect(btn.MouseButton1Click, function()
            if STOP_ALL then return end
            state = not state
            update()
            callback(state)
        end)
        return function() return state end, function(s) state = s update() callback(state) end
    end

    -- Anti Kick (Auto Reset)
    local AutoReset = true
    createToggle("Anti Kick", 0, true, function(s) AutoReset = s end)
    TrackThread(task.spawn(function()
        while not STOP_ALL do
            task.wait(13)
            if STOP_ALL then break end
            if AutoReset and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    end))

    -- Invisible (giữ khi respawn)
    createToggle("Invisible", 60, false, function(s)
        Invisible = s
        setInvisible(s)
    end)
    SafeConnect(LocalPlayer.CharacterAdded, function(char)
        char:WaitForChild("HumanoidRootPart")
        task.wait(0.2)
        if STOP_ALL then return end
        if Invisible then setInvisible(true) end
    end)

    -- Clear Map
    createToggle("Clear Map", 120, false, function(s)
        setMapInvisible(s)
    end)
end

--// ===== Server Hop (có STOP) =====
do
    local foundAnything = ""
    local AllIDs = {}
    local actualHour = os.date("!*t").hour

    -- đọc file id đã join
    pcall(function()
        AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
    end)
    if type(AllIDs) ~= "table" or #AllIDs == 0 then
        AllIDs = {actualHour}
        pcall(function()
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
        end)
    end

    local function ShowBlackScreen()
        if STOP_ALL then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "HNC_Hub_HopUI"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = CoreGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.new(0,0,0)
        bg.BorderSizePixel = 0
        bg.Parent = gui

        local t1 = Instance.new("TextLabel")
        t1.Size = UDim2.new(1,0,0.2,0)
        t1.Position = UDim2.new(0,0,0.35,0)
        t1.BackgroundTransparency = 1
        t1.Text = "HNC Hub - Auto Collect Chest"
        t1.TextColor3 = Color3.new(1,1,1)
        t1.Font = Enum.Font.SourceSansBold
        t1.TextScaled =  true
        t1.Parent = bg

        local t2 = Instance.new("TextLabel")
        t2.Size = UDim2.new(1,0,0.2,0)
        t2.Position = UDim2.new(0,0,0.5,0)
        t2.BackgroundTransparency = 1
        t2.Text = "Hopping"
        t2.TextColor3 = Color3.fromRGB(255,170,0)
        t2.Font = Enum.Font.SourceSansBold
        t2.TextScaled = true
        t2.Parent = bg
    end

    local function TPReturner()
        if STOP_ALL then return end
        local Site
        if foundAnything == "" then
            Site = HttpService:JSONDecode(game:HttpGet(
                'https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100'
            ))
        else
            Site = HttpService:JSONDecode(game:HttpGet(
                'https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100&cursor='..foundAnything
            ))
        end
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
            foundAnything = Site.nextPageCursor
        end

        local num = 0
        for _,v in pairs(Site.data) do
            if STOP_ALL then return end
            local ID = tostring(v.id)
            local Possible = true
            if tonumber(v.playing) < tonumber(v.maxPlayers) then
                for _,Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            pcall(function()
                                delfile("NotSameServers.json")
                            end)
                            AllIDs = {actualHour}
                        end
                    end
                    num = num + 1
                end
                if Possible then
                    table.insert(AllIDs, ID)
                    pcall(function()
                        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                        ShowBlackScreen()
                        task.wait(3)
                        if not STOP_ALL then
                            TeleportService:TeleportToPlaceInstance(PlaceID, ID, LocalPlayer)
                        end
                    end)
                    task.wait(4)
                end
            end
        end
    end

    local function TeleportLoop()
        while not STOP_ALL do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
            task.wait()
        end
    end

    -- đổi từ 60 -> 180 như bản bạn gửi; vẫn tôn trọng STOP
    task.delay(180, function()
        if not STOP_ALL then TeleportLoop() end
    end)
end
