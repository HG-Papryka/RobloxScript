--[[
    by potet
    tower heroes autofarm
    needs: Spectre / Lemonade Cat / Scientist
    run in lobby first, teleports to game automatically
    ~200 coins a hour (AUTOSKIP - ON)

Chef / Wizard (~105C/H)
https://github.com/HG-Papryka/RobloxScript/blob/main/TowerHerose/autofarm/0.lua
]]

_G.Spin = _G.Spin or false

local TeleportService = game:GetService("TeleportService")
local GuiService      = game:GetService("GuiService")
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")

local LOBBY_ID = 4646477729

local function doRejoin()
    local targetId = (game.PlaceId ~= LOBBY_ID) and LOBBY_ID or game.PlaceId
    if queueteleport then
        queueteleport(([[
            game:GetService("TeleportService"):Teleport(%d)
        ]]):format(targetId))
    end
    task.wait(1)
    pcall(function()
        TeleportService:Teleport(targetId, Players.LocalPlayer)
    end)
end

GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        task.wait(8)
        doRejoin()
    end
end)

Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(3)
        doRejoin()
    end
end)

local lastHB = tick()
RunService.Heartbeat:Connect(function() lastHB = tick() end)
task.spawn(function()
    while true do
        task.wait(5)
        if tick() - lastHB > 15 then
            doRejoin()
        end
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local sources = {
                game:GetService("CoreGui"),
                Players.LocalPlayer:WaitForChild("PlayerGui"),
            }
            for _, root in ipairs(sources) do
                for _, v in pairs(root:GetDescendants()) do
                    if v:IsA("TextButton") and (
                        v.Text == "Reconnect" or
                        v.Text == "Rejoin" or
                        v.Text == "OK"
                    ) and v.Visible then
                        task.wait(0.5)
                        local inset = GuiService:GetGuiInset()
                        local pos  = v.AbsolutePosition
                        local size = v.AbsoluteSize
                        local x = pos.X + size.X / 2
                        local y = pos.Y + size.Y / 2 + inset.Y
                        game:GetService("VirtualInputManager"):SendMouseMoveEvent(x, y, game)
                        task.wait(0.02)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, true, game, 0)
                        task.wait(0.05)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, false, game, 0)
                    end
                end
            end
        end)
        task.wait(2)
    end
end)

if game.PlaceId == LOBBY_ID then
    local RS = game:GetService("ReplicatedStorage")

    local function a1()
        local list = {
            "Chef", "Hotdog Frank", "Volt", "Yasuke", "Mako", "Wizard",
            "Scientist", "Fracture", "Bunny", "Beebo", "Voca", "Branch",
            "Wafer", "Sparks Kilowatt", "Keith", "Soda Pop", "Quinn", "Lure",
            "Slime King", "Kart Kid", "Jester", "Hayes", "Buzzer",
            --"Oddport",
            "Stella", "El Goblino", "Nuki Launcher", "Byte", "Dumpster Child",
            "Lemonade Cat", "Maitake", "Spectre", "Discount Dog", "Balloon Pal",
        }
        for _, name in pairs(list) do
            local troop = RS.Troops:FindFirstChild(name)
            if troop then
                pcall(function() RS.Events.EquipTroop:InvokeServer(troop) end)
            end
        end
    end

    local function a2()
        local loadout = {
            --{ name="Oddport",      slot=1 },
            { name="Lemonade Cat", slot=2 },
            { name="Scientist",    slot=3 },
            { name="Spectre",      slot=4 },
        }
        for _, entry in pairs(loadout) do
            local troop = RS.Troops:FindFirstChild(entry.name)
            if troop then
                pcall(function() RS.Events.EquipTroop:InvokeServer(troop, entry.slot) end)
            end
        end
    end

    local function a3()
        local Remote = RS:WaitForChild("Events"):WaitForChild("PrivateServerEvent")
        Remote:FireServer("Create", true)
        task.wait(0.05)
        Remote:FireServer("Mode", "Challenge Mode")
        task.wait(0.05)
        Remote:FireServer("Update", {Map=RS:WaitForChild("Maps"):WaitForChild("DoorsMap")})
        task.wait(0.05)
        Remote:FireServer("Difficulty", 2)
        task.wait(0.05)
        Remote:FireServer("Start")
    end

    task.spawn(function()
        task.wait(3)
        a1()
        a2()
        a3()
    end)
    return
end

local RS              = game:GetService("ReplicatedStorage")
local VIM             = game:GetService("VirtualInputManager")
local LocalPlayer     = Players.LocalPlayer
local TroopPlace      = RS:WaitForChild("Events"):WaitForChild("TroopPlace")
local TroopEvent      = RS:WaitForChild("Events"):WaitForChild("TroopEvent")
local TroopFolder     = workspace:WaitForChild("Troop")
local UpdateTargeting = RS:WaitForChild("Events"):WaitForChild("UpdateTargeting")

LocalPlayer:GetMouse().Icon = "rbxasset://textures/Blank.png"

local function getTroop(name)
    local troops = RS:FindFirstChild("Troops")
    return troops and troops:FindFirstChild(name)
end

local places = {
    { name="Spectre",      x=10.2540, y=63.3995, z=5.0784,  rot=4 },
    { name="Scientist",    x=13.3558, y=63.3995, z=4.9185,  rot=0 },
    { name="Scientist",    x=10.2099, y=63.3995, z=8.3131,  rot=0 },
    { name="Scientist",    x=10.9268, y=63.3995, z=2.1417,  rot=0 },
    { name="Scientist",    x=7.0622,  y=63.3995, z=5.6291,  rot=0 },
    { name="Scientist",    x=13.3136, y=63.3995, z=8.2517,  rot=0 },
    --{ name="Oddport",      x=7.8896,  y=63.3995, z=26.5347, rot=5 },
    { name="Lemonade Cat", x=19.5783, y=63.3495, z=14.2713, rot=2 },
    { name="Lemonade Cat", x=19.5856, y=63.3495, z=18.2217, rot=2 },
    { name="Lemonade Cat", x=19.7608, y=63.3495, z=22.0081, rot=2 },
    { name="Lemonade Cat", x=19.5466, y=63.3495, z=10.7319, rot=2 },
}

local TOWER_DATA = {
    { name="Spectre",      max=1, texture="rbxassetid://8273607953" },
    { name="Scientist",    max=5, texture="rbxassetid://7118338906" },
    { name="Lemonade Cat", max=4, texture="rbxassetid://8273477941" },
    --{ name="Oddport",      max=1, texture="rbxassetid://8273332230", optional=true },
}

local b = Instance.new("ScreenGui")
b.ResetOnSpawn = false
b.DisplayOrder = -1
b.Parent = LocalPlayer:WaitForChild("PlayerGui")

local b1 = Instance.new("Frame")
b1.Size = UDim2.new(0, 130, 0, 0)
b1.Position = UDim2.new(0, 8, 0.5, 0)
b1.AnchorPoint = Vector2.new(0, 0.5)
b1.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
b1.BorderSizePixel = 0
b1.AutomaticSize = Enum.AutomaticSize.Y
b1.Parent = b
Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 10)
local b1pad = Instance.new("UIPadding", b1)
b1pad.PaddingTop    = UDim.new(0, 8)
b1pad.PaddingBottom = UDim.new(0, 8)
b1pad.PaddingLeft   = UDim.new(0, 6)
b1pad.PaddingRight  = UDim.new(0, 6)
local b1list = Instance.new("UIListLayout", b1)
b1list.Padding = UDim.new(0, 6)
b1list.FillDirection = Enum.FillDirection.Vertical

local b2 = Instance.new("TextLabel")
b2.Size = UDim2.new(1, 0, 0, 18)
b2.BackgroundTransparency = 1
b2.Text = "Potetnium"
b2.TextColor3 = Color3.fromRGB(80, 200, 255)
b2.TextSize = 13
b2.Font = Enum.Font.GothamBold
b2.TextXAlignment = Enum.TextXAlignment.Center
b2.Parent = b1

local cardRefs = {}
for _, td in ipairs(TOWER_DATA) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    card.BorderSizePixel = 0
    card.Parent = b1
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 44, 0, 44)
    img.Position = UDim2.new(0, 6, 0.5, 0)
    img.AnchorPoint = Vector2.new(0, 0.5)
    img.BackgroundTransparency = 1
    img.Image = td.texture
    img.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -56, 0, 16)
    nameLabel.Position = UDim2.new(0, 54, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Text = td.name
    nameLabel.Parent = card

    local optLabel = Instance.new("TextLabel")
    optLabel.Size = UDim2.new(1, -56, 0, 11)
    optLabel.Position = UDim2.new(0, 54, 0, 22)
    optLabel.BackgroundTransparency = 1
    optLabel.TextColor3 = Color3.fromRGB(255, 180, 60)
    optLabel.TextSize = 10
    optLabel.Font = Enum.Font.Gotham
    optLabel.TextXAlignment = Enum.TextXAlignment.Left
    optLabel.Text = td.optional and "optional" or ""
    optLabel.Parent = card

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -56, 0, 14)
    countLabel.Position = UDim2.new(0, 54, 0, td.optional and 34 or 26)
    countLabel.BackgroundTransparency = 1
    countLabel.TextColor3 = Color3.fromRGB(120, 220, 160)
    countLabel.TextSize = 11
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Text = "0 / " .. td.max
    countLabel.Parent = card

    cardRefs[td.name] = { card=card, countLabel=countLabel, img=img, max=td.max }
end

task.spawn(function()
    while true do
        local counts = {}
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            counts[troop.Name] = (counts[troop.Name] or 0) + 1
        end
        for name, ref in pairs(cardRefs) do
            local n = counts[name] or 0
            ref.countLabel.Text = n .. " / " .. ref.max
            local isEmpty = n == 0
            ref.card.BackgroundColor3 = isEmpty and Color3.fromRGB(18, 18, 22) or Color3.fromRGB(24, 24, 32)
            ref.img.ImageTransparency = isEmpty and 0.6 or 0
            ref.countLabel.TextColor3 = isEmpty and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(120, 220, 160)
        end
        task.wait(0.5)
    end
end)

local function c1(obj)
    if not obj then return end
    if not obj.Visible then return end
    local inset = GuiService:GetGuiInset()
    local pos   = obj.AbsolutePosition
    local size  = obj.AbsoluteSize
    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2 + inset.Y
    VIM:SendMouseMoveEvent(x, y, game)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(x, y, 0, true,  game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function c2(btn)
    if not btn then return end
    pcall(function() btn.MouseButton1Click:Fire() end)
    c1(btn)
end

local function d1()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    return menu
        and menu:FindFirstChild("HeroFrame")
        and menu.HeroFrame:FindFirstChild("ServerFrame")
        and menu.HeroFrame.ServerFrame:FindFirstChild("Ready")
end

local function d2()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    return menu
        and menu:FindFirstChild("ResultScreen")
        and menu.ResultScreen:FindFirstChild("Leave")
end

local function d3()
    local menu = LocalPlayer.PlayerGui:FindFirstChild("Menu")
    return menu
        and menu:FindFirstChild("Skip")
        and menu.Skip:FindFirstChild("Skip")
end

local function waitForButton(getBtn, timeout)
    timeout = timeout or 60
    local t = 0
    while t < timeout do
        local btn = getBtn()
        if btn and btn.Visible and btn.AbsoluteSize ~= Vector2.zero then return btn end
        task.wait(0.5)
        t = t + 0.5
    end
    return nil
end

task.spawn(function()
    while true do
        local skip = d3()
        if skip and skip.Visible then
            pcall(function() c2(skip) end)
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        local ready = waitForButton(d1, 60)
        if ready then task.wait(0.2) c2(ready) end
        local leave = waitForButton(d2, 300)
        if leave then task.wait(0.2) c2(leave) end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        for _, move in ipairs(places) do
            local troopObj = getTroop(move.name)
            if troopObj then
                pcall(function()
                    TroopPlace:FireServer(troopObj, Vector3.new(move.x, move.y, move.z), move.rot)
                end)
            end
            task.wait(0.5)
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        local count = 0
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Lemonade Cat" and count < 4 then
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
                count = count + 1
                task.wait(0.1)
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        local count = 0
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Scientist" and count < 5 then
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
                count = count + 1
                task.wait(1)
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Spectre" then
                --if troop.Name == "Oddport" then
                --    UpdateTargeting:FireServer(troop, "Random")
                --end
                pcall(function()
                    TroopEvent:FireServer("Upgrade", troop)
                end)
            end
        end
        task.wait(15)
    end
end)

if _G.Spin then
    local function applySpin()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, 10, 0)
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.Parent = root
    end
    applySpin()
    LocalPlayer.CharacterAdded:Connect(applySpin)
end

--[[
this code is
stolen, vibecoded, skidded, leaked, obfuscated, deobfuscated, reobfuscated,
copy pasted from v3rmillion, reuploaded, re-reuploaded, grabbed from some
random pastebin from 2019, has 47 unresolved bugs, was made at 3am, untested,
shipped anyway, has memory leaks, probably rats u, definitely logs ur hwid,
sends ur ip to some discord server, written by a 9 year old, reviewed by nobody,
documented by accident, optimized never, refactored once and made worse,
originally for a different game, adapted badly, stolen again after that,
and if ur reading this ur already cooked
]]
