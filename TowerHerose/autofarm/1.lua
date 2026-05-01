--[[
    by potet
    tower heroes autofarm
    needs: Spectre / Lemonade Cat / Scientist / Dumpster Child / Balloon Pal
    run in lobby first, teleports to game automatically
    ~200 coins a hour 







other versions


needs: Chef / Wizard
https://github.com/HG-Papryka/RobloxScript/blob/main/TowerHerose/autofarm/0.lua

needs: Spectre / Lemonade Cat / Scientist 
https://github.com/HG-Papryka/RobloxScript/blob/main/TowerHerose/autofarm/0.5.lua







]]

if game.PlaceId==4646477729 then
local RS=game:GetService("ReplicatedStorage")
task.spawn(function()
task.wait(3)
local Remote=RS:WaitForChild("Events"):WaitForChild("PrivateServerEvent")
Remote:FireServer("Create",true)
task.wait(0.05)
Remote:FireServer("Mode","Challenge Mode")
task.wait(0.05)
Remote:FireServer("Update",{Map=RS:WaitForChild("Maps"):WaitForChild("DoorsMap")})
task.wait(0.05)
Remote:FireServer("Difficulty",2)
task.wait(0.05)
Remote:FireServer("Start")
end)
return
end

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local TroopPlace = RS:WaitForChild("Events"):WaitForChild("TroopPlace")
local TroopEvent = RS:WaitForChild("Events"):WaitForChild("TroopEvent")
local TroopFolder = workspace:WaitForChild("Troop")
local UpdateTargeting = RS:WaitForChild("Events"):WaitForChild("UpdateTargeting")

LocalPlayer:GetMouse().Icon = "rbxasset://textures/Blank.png"

local function getTroopObject(name)
    local troops = RS:FindFirstChild("Troops")
    return troops and troops:FindFirstChild(name)
end

local places = {
    { name="Lemonade Cat",   x=6.9262,  y=66.3995, z=-22.2864, rot=6 },
    { name="Lemonade Cat",   x=10.7466, y=66.3995, z=-22.0326, rot=2 },
    { name="Lemonade Cat",   x=11.1159, y=66.3995, z=-18.5232, rot=2 },
    { name="Lemonade Cat",   x=7.1062,  y=66.3995, z=-18.9530, rot=6 },
    { name="Dumpster Child", x=6.7865,  y=63.3995, z=38.4688,  rot=0 },
    { name="Balloon Pal",    x=7.8769,  y=63.3995, z=26.4574,  rot=0 },
    { name="Spectre",        x=7.9000,  y=63.3995, z=24.2849,  rot=0 },
    { name="Scientist",      x=7.6592,  y=63.3995, z=29.5420,  rot=0 },
    { name="Scientist",      x=4.7852,  y=63.3995, z=26.1879,  rot=0 },
    { name="Scientist",      x=4.2734,  y=63.3995, z=29.2454,  rot=0 },
    { name="Scientist",      x=5.1716,  y=63.3995, z=22.8176,  rot=0 },
    { name="Scientist",      x=7.7010,  y=63.3995, z=20.9999,  rot=0 },
}

local TOWER_DATA = {
    { name="Spectre",        max=1, texture="rbxassetid://8273607953" },
    { name="Balloon Pal",    max=1, texture="rbxassetid://8275379669" },
    { name="Scientist",      max=5, texture="rbxassetid://7118338906" },
    { name="Dumpster Child", max=1, texture="rbxassetid://16597907208", optional=true },
    { name="Lemonade Cat",   max=4, texture="rbxassetid://8273477941" },
}

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.DisplayOrder = -1
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 130, 0, 0)
panel.Position = UDim2.new(0, 8, 0.5, 0)
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
panel.BorderSizePixel = 0
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local panelPad = Instance.new("UIPadding", panel)
panelPad.PaddingTop = UDim.new(0, 8)
panelPad.PaddingBottom = UDim.new(0, 8)
panelPad.PaddingLeft = UDim.new(0, 6)
panelPad.PaddingRight = UDim.new(0, 6)
local panelList = Instance.new("UIListLayout", panel)
panelList.Padding = UDim.new(0, 6)
panelList.FillDirection = Enum.FillDirection.Vertical

local cardRefs = {}

for _, td in ipairs(TOWER_DATA) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    card.BorderSizePixel = 0
    card.Parent = panel
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
    nameLabel.Text = td.name .. (td.optional and " ?" or "")
    nameLabel.Parent = card

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -56, 0, 14)
    countLabel.Position = UDim2.new(0, 54, 0, 24)
    countLabel.BackgroundTransparency = 1
    countLabel.TextColor3 = Color3.fromRGB(120, 220, 160)
    countLabel.TextSize = 11
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Text = "0 / " .. td.max
    countLabel.Parent = card

    local lvlLabel = Instance.new("TextLabel")
    lvlLabel.Size = UDim2.new(1, -56, 0, 12)
    lvlLabel.Position = UDim2.new(0, 54, 0, 40)
    lvlLabel.BackgroundTransparency = 1
    lvlLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
    lvlLabel.TextSize = 10
    lvlLabel.Font = Enum.Font.Gotham
    lvlLabel.TextXAlignment = Enum.TextXAlignment.Left
    lvlLabel.Text = "lvl: todo"
    lvlLabel.Parent = card

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

local function clickGuiObject(obj)
    if not obj then return end
    local inset = GuiService:GetGuiInset()
    local pos = obj.AbsolutePosition
    local size = obj.AbsoluteSize
    local x = pos.X + size.X / 2
    local y = pos.Y + size.Y / 2 + inset.Y
    VIM:SendMouseMoveEvent(x, y, game)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function smartClick(btn)
    if not btn then return end
    pcall(function() btn.MouseButton1Click:Fire() end)
    clickGuiObject(btn)
end

local function getReadyButton()
    return LocalPlayer.PlayerGui:FindFirstChild("Menu")
        and LocalPlayer.PlayerGui.Menu:FindFirstChild("HeroFrame")
        and LocalPlayer.PlayerGui.Menu.HeroFrame:FindFirstChild("ServerFrame")
        and LocalPlayer.PlayerGui.Menu.HeroFrame.ServerFrame:FindFirstChild("Ready")
end

local function getLeaveButton()
    return LocalPlayer.PlayerGui:FindFirstChild("Menu")
        and LocalPlayer.PlayerGui.Menu:FindFirstChild("ResultScreen")
        and LocalPlayer.PlayerGui.Menu.ResultScreen:FindFirstChild("Leave")
end

local function waitForButton(getBtn, timeout)
    timeout = timeout or 60
    local t = 0
    while t < timeout do
        local btn = getBtn()
        if btn and btn.Visible then return btn end
        task.wait(0.5)
        t = t + 0.5
    end
    return nil
end

task.spawn(function()
    while true do
        local ready = waitForButton(getReadyButton, 60)
        if ready then task.wait(0.2) smartClick(ready) end
        local leave = waitForButton(getLeaveButton, 300)
        if leave then task.wait(0.2) smartClick(leave) end
    end
end)

task.spawn(function()
    while true do
        for _, move in ipairs(places) do
            local troopObj = getTroopObject(move.name)
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
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
                task.wait(15)
            end
        end
        task.wait(15)
    end
end)

task.spawn(function()
    while true do
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Balloon Pal" then
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
                task.wait(15)
            end
        end
        task.wait(15)
    end
end)

task.spawn(function()
    while true do
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Dumpster Child" then
                pcall(function()
                    UpdateTargeting:FireServer(troop, "Random")
                    TroopEvent:FireServer("Upgrade", troop)
                end)
                task.wait(0.5)
            end
        end
        task.wait(0.5)
    end
end)
