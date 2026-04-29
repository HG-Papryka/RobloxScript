--[[ 
    by potet
    tower heroes autofarm
    needs: Spectre / Lemonade Cat / Scientist
    run in lobby first, teleports to game automatically
    ~180 coins per hour with autoskip
]]

if game.PlaceId == 4646477729 then
    local RS = game:GetService("ReplicatedStorage")
    task.spawn(function()
        task.wait(3)
        local Remote = RS:WaitForChild("Events"):WaitForChild("PrivateServerEvent")
        Remote:FireServer("Create", true)
        task.wait()
        Remote:FireServer("Mode", "Challenge Mode")
        task.wait()
        Remote:FireServer("Update", {
            Map = RS:WaitForChild("Maps"):WaitForChild("DoorsMap")
        })
        task.wait()
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

local function getTroopObject(name)
    local troops = RS:FindFirstChild("Troops")
    return troops and troops:FindFirstChild(name)
end

local places = {
    { name="Lemonade Cat", x=-18.5899, y=63.3495, z=-6.1482, rot=0 },
    { name="Lemonade Cat", x=-18.7611, y=63.3495, z=-3.9044, rot=0 },
    { name="Lemonade Cat", x=-15.6175, y=63.3495, z=-6.4101, rot=0 },
    { name="Lemonade Cat", x=-15.8413, y=63.3495, z=-4.1890, rot=0 },
    { name="Spectre",      x=10.3954, y=63.3995, z=5.1573,  rot=0 },
    { name="Scientist",    x=13.5157, y=63.3995, z=5.1524,  rot=0 },
    { name="Scientist",    x=13.2889, y=63.3995, z=2.1035,  rot=0 },
    { name="Scientist",    x=9.8361,  y=63.3995, z=2.0316,  rot=0 },
    { name="Scientist",    x=16.3228, y=63.3995, z=2.6596,  rot=0 },
    { name="Scientist",    x=7.3166,  y=63.3995, z=5.5371,  rot=0 },
}

for _, v in ipairs(workspace:GetChildren()) do
    if v.Name == "AutoFarmPlatform" then v:Destroy() end
end

local platform = Instance.new("Part")
platform.Name = "AutoFarmPlatform"
platform.Size = Vector3.new(10, 1, 10)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 1
platform.CFrame = CFrame.new(9, 247, -10)
platform.Parent = workspace

task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(9, 248, -10)
        end
        task.wait(0.1)
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
    pcall(function()
        for _, v in pairs(getconnections(btn.MouseButton1Click)) do
            v:Fire()
        end
    end)
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

local function getRetryButton()
    return LocalPlayer.PlayerGui:FindFirstChild("Menu")
        and LocalPlayer.PlayerGui.Menu:FindFirstChild("ResultScreen")
        and LocalPlayer.PlayerGui.Menu.ResultScreen:FindFirstChild("Retry")
end

local function waitForButton(getBtn, timeout)
    timeout = timeout or 60
    local t = 0
    while t < timeout do
        local btn = getBtn()
        if btn and btn.Visible then
            return btn
        end
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
        local retry = waitForButton(getRetryButton, 10)
        if retry then task.wait(0.2) smartClick(retry) end
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
