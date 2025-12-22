local players = game:GetService("Players")
local self = players.LocalPlayer
local char = self.Character
local root = char.HumanoidRootPart
local mouse = self:GetMouse()
local value = game:GetService("Players").LocalPlayer.Rebirths

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheAbsolutionism/Wally-GUI-Library-V2-Remastered/main/Library%20Code", true))()
library.options.underlinecolor = 'rainbow'
library.options.toggledisplay = 'Fill'
local mainW = library:CreateWindow("Miner's Haven")
local Section = mainW:Section('Farm',true)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   task.wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local reFarm = mainW:Toggle('Rebirth Farm',{flag = "rebfarm"},function()
    if mainW.flags.rebfarm then
        task.spawn(function()
            while mainW.flags.rebfarm do
                loadLayouts()
                task.wait(10)
            end
        end)
        farmRebirth()
    end
end)

local loopUpgraders = mainW:Toggle('Orbs Upgrade',{flag = "orbsUpgrade"},function()
    if mainW.flags.orbsUpgrade then
        autoLoopUpgraders()
    end
end)

local tFarm = mainW:Toggle('Enable Second Layout?',{flag = "seclayout"},function()
end)

local autoReb = mainW:Toggle('Auto Rebirth',{flag = "aReb"},function()
    farmRebirth()
end)

local timeBox = mainW:Box('Time Between Lays',{
        default = 0;
        type = 'number';
        min = 0;
        max = 60;
        flag = 'duration';
        location = {getgenv()};
},function(new)
    getgenv().duration = new
end)

mainW:Dropdown("First Layout", {
    default = 'First Layout';
    location = getgenv();
    flag = "layoutone";
    list = {
        "Layout1";
        "Layout2";
        "Layout3";
    }
}, function()
    print("Selected: ".. getgenv().layoutone)
end)

mainW:Dropdown("Second Layout", {
    default = 'Second Layout';
    location = getgenv();
    flag = "layoutwo";
    list = {
        "Layout1";
        "Layout2";
        "Layout3";
    }
}, function()
    print("Selected: ".. getgenv().layoutwo)
end)

function loadLayouts()
    task.spawn(function()
        game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load",getgenv().layoutone)
        task.wait(getgenv().duration)
        if mainW.flags.seclayout then
            game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load",getgenv().layoutwo)
        end
    end)
end

function farmRebirth()
    task.spawn(function()
        while mainW.flags.aReb do
            game:GetService("ReplicatedStorage").Rebirth:InvokeServer(26)
            task.wait(10)
        end
    end)
end

value:GetPropertyChangedSignal("Value"):Connect(function()
    task.wait(0.75)
    if mainW.flags.rebfarm then
        loadLayouts()
    end
end)

local MyTycoon = game:GetService("Players").LocalPlayer.PlayerTycoon.Value

local function GetUpgraders()
    local tbl = {}
    for i,v in pairs(MyTycoon:GetChildren()) do
        if v:FindFirstChild("Model") and v.Model:FindFirstChild("Upgrade") then
            table.insert(tbl,v)
        elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Upgrader") then
            table.insert(tbl,v)
        elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Cannon") then
            table.insert(tbl,v)
        elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Copy") then
            table.insert(tbl,v)
        end
    end
    return tbl
end

local function GetDropped()
    local tbl = {}
    for i,v in pairs(workspace.DroppedParts[MyTycoon.Name]:GetChildren()) do
        if not string.find(v.Name,"Coal") then 
            table.insert(tbl,v)        
        end
    end
    return tbl
end

function autoLoopUpgraders()
    task.spawn(function()
        while mainW.flags.orbsUpgrade do
            for _, ore in pairs(GetDropped()) do
                task.spawn(function()
                    for _, upgrader in pairs(GetUpgraders()) do
                        if upgrader:FindFirstChild("Model") and upgrader.Model:FindFirstChild("Upgrade") then
                            firetouchinterest(ore,upgrader.Model.Upgrade,0)
                            task.wait()
                            firetouchinterest(ore,upgrader.Model.Upgrade,1)
                        elseif upgrader:FindFirstChild("Model") and upgrader.Model:FindFirstChild("Upgrader") then
                            firetouchinterest(ore,upgrader.Model.Upgrader,0)
                            task.wait()
                            firetouchinterest(ore,upgrader.Model.Upgrader,1)
                        elseif upgrader:FindFirstChild("Model") and upgrader.Model:FindFirstChild("Cannon") then
                            firetouchinterest(ore,upgrader.Model.Cannon,0)
                            task.wait()
                            firetouchinterest(ore,upgrader.Model.Cannon,1)
                        elseif upgrader:FindFirstChild("Model") and upgrader.Model:FindFirstChild("Copy") then
                            firetouchinterest(ore,upgrader.Model.Copy,0)
                            task.wait()
                            firetouchinterest(ore,upgrader.Model.Copy,1)
                        end
                    end
                end)
            end
            task.wait(0.4)
        end
    end)
end
