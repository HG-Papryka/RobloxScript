local x1 = game:GetService("TeleportService")
local x2 = game:GetService("GuiService")
local x3 = game:GetService("Players")
local x4 = game:GetService("RunService")
local x5 = game:GetService("VirtualInputManager")
local x6 = game:GetService("CoreGui")
local x7 = x3.LocalPlayer
local x8 = "https://raw.githubusercontent.com/HG-Papryka/RobloxScript/refs/heads/main/Universal%20/rejoin/autoexecute%2Brejoin.lua"
local x9 = tick()

local function a1()
    local q = ""
    if _G.userScript then
        q = ('_G.userScript = [==[\n' .. _G.userScript .. '\n]==]\n')
    end
    if queueteleport then
        queueteleport(q .. ([[loadstring(game:HttpGet("%s"))()]]):format(x8))
    end
    task.wait(1)
    pcall(function() x1:Teleport(game.PlaceId, x7) end)
end

local function b1()
    x2.ErrorMessageChanged:Connect(function(msg)
        if msg and msg ~= "" then
            task.wait(8)
            a1()
        end
    end)
end

local function b2()
    x7.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Failed then
            task.wait(3)
            a1()
        end
    end)
end

local function b3()
    x4.Heartbeat:Connect(function() x9 = tick() end)
    task.spawn(function()
        while true do
            task.wait(5)
            if tick() - x9 > 15 then a1() end
        end
    end)
end

local function c1()
    task.spawn(function()
        while true do
            pcall(function() -- yes i like my slot with quality of over complicating stuff
                for _, v in pairs(x6:GetDescendants()) do
                    if v:IsA("TextButton") and (
                        v.Text == "Reconnect" or
                        v.Text == "Rejoin" or
                        v.Text == "OK"
                    ) and v.Visible then
                        task.wait(0.5)
                        local inset = x2:GetGuiInset()
                        local pos, size = v.AbsolutePosition, v.AbsoluteSize
                        local cx = pos.X + size.X / 2
                        local cy = pos.Y + size.Y / 2 + inset.Y
                        x5:SendMouseMoveEvent(cx, cy, game)
                        task.wait(0.02)
                        x5:SendMouseButtonEvent(cx, cy, 0, true,  game, 0)
                        task.wait(0.05)
                        x5:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

b1()
b2()
b3()
c1()

if _G.userScript then
    loadstring(_G.userScript)()
end
