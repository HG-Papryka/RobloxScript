getgenv().autofarm = getgenv().autofarm or true
getgenv().collect_HalloweenCandy = getgenv().collect_HalloweenCandy or false
getgenv().collect_EventIcon = getgenv().collect_EventIcon or false
getgenv().collect_Coins = getgenv().collect_Coins or false
getgenv().collect_HeartPickup = getgenv().collect_HeartPickup or true

local TweenService, Player, isPaused, Remotes = game:GetService("TweenService"), game.Players.LocalPlayer, false, game:GetService("ReplicatedStorage").Remotes
local targetNames, fixedYPosition = {"Coin_copper", "Coin_silver", "Coin_gold", "Coin_red", "Coin_purple", "EventIcon", "HalloweenCandy", "HeartPickup"}, 272

local function antiAFK()
    while true do
        pcall(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = Player.Character.HumanoidRootPart.Position
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0.05, 0, 0)) wait(0.2)
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        end)
        wait(300)
    end
end

local function teleportWithTween(partPosition)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = Player.Character.HumanoidRootPart

        -- Tworzymy ustawienia Tweena dla płynnego ruchu
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) 
        local targetPosition = CFrame.new(partPosition.X, fixedYPosition, partPosition.Z)

        -- Tworzymy Tween
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPosition})
        tween:Play()
        tween.Completed:Wait()
    end
end

local function teleportToParts()
    pcall(function()
        for _, part in ipairs(workspace.Bombs:GetChildren()) do
            if table.find(targetNames, part.Name) and ((part.Name == "HalloweenCandy" and getgenv().collect_HalloweenCandy) or (part.Name == "EventIcon" and getgenv().collect_EventIcon) or ((part.Name == "Coin_copper" or part.Name == "Coin_silver" or part.Name == "Coin_gold" or part.Name == "Coin_red" or part.Name == "Coin_purple") and getgenv().collect_Coins) or (part.Name == "HeartPickup" and getgenv().collect_HeartPickup)) then
                teleportWithTween(part.Position)
                wait(math.random(0.1, 0.5))
            end
        end
    end)
end

local function loopTween()
    local positions = {CFrame.new(121, fixedYPosition, 181), CFrame.new(120, fixedYPosition, 28), CFrame.new(-34, fixedYPosition, 29), CFrame.new(-34, fixedYPosition, 183)}
    while true do
        if isPaused then
            while isPaused do wait() end
        end

        pcall(function()
            Remotes.chooseOption:FireServer("afk", false)
            for _, pos in ipairs(positions) do
                teleportWithTween(pos.Position)
                wait(math.random(0.1, 0.5))
                if getgenv().autofarm then teleportToParts() end
            end
        end)
        wait(math.random(0.2, 0.5))
    end
end

spawn(antiAFK)
if getgenv().autofarm then spawn(loopTween) end
