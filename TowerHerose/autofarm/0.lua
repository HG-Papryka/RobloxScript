--[[ 
    by potet
    tower heroes autofarm
    needs: Chef / Wizard
    run in lobby first, teleports to game automatically
    ~120 coins per hour
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
    { name="Chef", x=19.9020, y=-88.6375, z=-37.2161, rot=0 },
    { name="Chef", x=17.5330, y=-88.6375, z=-37.1212, rot=0 },
    { name="Chef", x=18.7385, y=-88.6375, z=-35.2801, rot=0 },
    { name="Chef", x=17.8371, y=-88.6372, z=-41.1753, rot=0 },
    { name="Chef", x=20.2852, y=-88.6372, z=-41.3248, rot=0 },
    { name="Chef", x=21.3576, y=-88.6371, z=-43.3006, rot=0 },
    { name="Chef", x=18.6947, y=-88.6373, z=-43.1837, rot=0 },
    { name="Chef", x=23.6420, y=-88.5699, z=19.9108,  rot=0 },
    { name="Wizard", x=17.6678, y=-88.6375, z=-39.1189, rot=0 },
    { name="Wizard", x=19.7986, y=-88.6374, z=-39.2873, rot=0 },
    { name="Wizard", x=18.4204, y=-85.7315, z=-34.3399, rot=0 },
    { name="Wizard", x=16.6382, y=-85.7109, z=-33.6433, rot=0 },
    { name="Wizard", x=14.8039, y=-85.7188, z=-32.9943, rot=0 },
    { name="Wizard", x=14.6685, y=-84.6178, z=-31.4516, rot=0 },
    { name="Wizard", x=15.2967, y=-85.7251, z=-30.0240, rot=0 },
    { name="Wizard", x=17.1145, y=-85.7332, z=-30.6428, rot=0 },
    { name="Wizard", x=18.9747, y=-85.7554, z=-31.2765, rot=0 },
    { name="Wizard", x=17.2861, y=-84.6178, z=-32.2075, rot=0 },
    { name="Wizard", x=19.3187, y=-88.6375, z=-32.9403, rot=0 },
    { name="Wizard", x=17.1369, y=-88.6375, z=-33.7733, rot=0 },
    { name="Wizard", x=15.5430, y=-88.6375, z=-36.3740, rot=0 },
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
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Wizard" then
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
                task.wait(0.1)
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Chef" then
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
                task.wait(1)
            end
        end
        task.wait(1)
    end
end)
