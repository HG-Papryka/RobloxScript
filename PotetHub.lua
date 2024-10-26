getgenv().autofarm = getgenv().autofarm or true
getgenv().collect_HalloweenCandy = getgenv().collect_HalloweenCandy or false
getgenv().collect_EventIcon = getgenv().collect_EventIcon or false
getgenv().collect_Coins = getgenv().collect_Coins or false
getgenv().collect_HeartPickup = getgenv().collect_HeartPickup or true

local TweenService, Player, isPaused, tween, Remotes = game:GetService("TweenService"), game.Players.LocalPlayer, false, nil, game:GetService("ReplicatedStorage").Remotes
local targetNames, fixedYPosition = {"Coin_copper", "Coin_silver", "EventIcon", "HalloweenCandy", "HeartPickup"}, 272

local function antiAFK()
    while true do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = Player.Character.HumanoidRootPart.Position
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0.1, 0, 0)) wait(0.1)
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
        wait(300)
    end
end

local function createTween(part, goalPos)
    return TweenService:Create(part, TweenInfo.new(1.69, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = CFrame.new(goalPos.X, fixedYPosition, goalPos.Z)})
end

local function teleportToParts()
    for _, part in ipairs(workspace.Bombs:GetChildren()) do
        if table.find(targetNames, part.Name) and ((part.Name == "HalloweenCandy" and getgenv().collect_HalloweenCandy) or (part.Name == "EventIcon" and getgenv().collect_EventIcon) or ((part.Name == "Coin_copper" or part.Name == "Coin_silver") and getgenv().collect_Coins) or (part.Name == "HeartPickup" and getgenv().collect_HeartPickup)) then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(part.Position.X, fixedYPosition, part.Position.Z) wait(0.1)
            end
        end
    end
end

local function loopTween()
    local positions = {CFrame.new(121, fixedYPosition, 181), CFrame.new(120, fixedYPosition, 28), CFrame.new(-34, fixedYPosition, 29), CFrame.new(-34, fixedYPosition, 183)}
    while true do
        if isPaused then while isPaused do wait() end end
        Remotes.chooseOption:FireServer("afk", false)
        for _, pos in ipairs(positions) do
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                tween = createTween(Player.Character.HumanoidRootPart, pos) tween:Play() tween.Completed:Wait()
                if getgenv().autofarm then teleportToParts() end
            end
        end
        wait(0.09)
    end
end

spawn(antiAFK)
if getgenv().autofarm then loopTween() end
