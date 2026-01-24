local Players = game:GetService("Players")
local player = Players.LocalPlayer

while true do
    pcall(function()
        local winpad = workspace.lobbyCage.obby.landawnObby.winpad
        if winpad and player.Character then
            local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = winpad.CFrame + Vector3.new(0, 8, 0)
            end
        end
    end)
    wait(1)
end
