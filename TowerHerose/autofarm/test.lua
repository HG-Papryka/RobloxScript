--[[
    by potet
    tower heroes mimic farm
    needs: Oddport / Kart Kid / Slime King
    run in lobby first, teleports to game automatically
    dont use it yet 
]]

_G.Webhook = _G.Webhook or "WEBHOOK_URL_HERE"
_G.Spin    = _G.Spin    or false

local TeleportService = game:GetService("TeleportService")
local GuiService      = game:GetService("GuiService")
local HttpService     = game:GetService("HttpService")
local Players         = game:GetService("Players")

GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        task.wait(10)
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end
end)

if game.PlaceId == 4646477729 then
    local RS = game:GetService("ReplicatedStorage")

    local function a1()
        local list = {
            "Chef", "Hotdog Frank", "Volt", "Yasuke", "Mako", "Wizard",
            "Scientist", "Fracture", "Bunny", "Beebo", "Voca", "Branch",
            "Wafer", "Sparks Kilowatt", "Keith", "Soda Pop", "Quinn", "Lure",
            "Slime King", "Kart Kid", "Jester", "Hayes", "Buzzer", "Oddport",
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
            { name="Oddport",   slot=1 },
            { name="Kart Kid",  slot=2 },
            { name="Slime King",slot=3 },
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
        Remote:FireServer("Mode", "Casual Mode")
        task.wait(0.05)
        Remote:FireServer("Update", {Map=RS:WaitForChild("Maps"):WaitForChild("TidalTakedown")})
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

local MIMIC_IDS = {
    "Mimic", "MimicBig", "MimicGiant",
    "MimicBusiness", "MimicCrab", "MimicMinecart",
    "MimicFish", "MimicBee", "BlastMimic",
    "Wicky", "MimicMeta", "MimicFairy",
    "MimicCAT", "MimicBattle", "MimicBot",
    "MimicEaster", "MimicCandy", "MimicGift", "MimicXmas",
}

local function getTroop(name)
    local troops = RS:FindFirstChild("Troops")
    return troops and troops:FindFirstChild(name)
end

local places = {
    { name="Oddport",   x=-10.3184, y=-72.3741, z=-61.7986, rot=3 },
    { name="Kart Kid",  x=-8.1837,  y=-71.1884, z=-58.1483, rot=3 },
    { name="Slime King",x=-9.7390,  y=-73.4591, z=-56.8585, rot=3 },
}

local function sendWebhook(mimicName)
    pcall(function()
        request({
            Url    = _G.Webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                content = "🚨 **mimic detected** `" .. mimicName .. "` on tidal takedown — rejoining in 2min"
            })
        })
    end)
end

task.spawn(function()
    while true do
        local enemy = workspace:FindFirstChild("Enemy")
        if enemy then
            for _, v in ipairs(enemy:GetChildren()) do
                if table.find(MIMIC_IDS, v.Name) then
                    sendWebhook(v.Name)
                    task.wait(120)
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    return
                end
            end
        end
        task.wait(1)
    end
end)

local function c1(obj)
    if not obj then return end
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
        if btn and btn.Visible then return btn end
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
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Oddport" then
                pcall(function()
                    UpdateTargeting:FireServer(troop, "Random")
                    TroopEvent:FireServer("Upgrade", troop)
                end)
                task.wait(0.1)
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        for _, troop in ipairs(TroopFolder:GetChildren()) do
            if troop.Name == "Kart Kid" then
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
            if troop.Name == "Slime King" then
                pcall(function() TroopEvent:FireServer("Upgrade", troop) end)
            end
        end
        task.wait(15)
    end
end)

if _G.Spin then
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, 10, 0)
        bav.MaxTorque = Vector3.new(0, math.huge, 0)
        bav.Parent = root
    end)
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
