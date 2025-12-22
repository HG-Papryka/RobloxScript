local player = game.Players.LocalPlayer
local waitTime = 2
local teleportLoopRunning = false

local function teleportTo(part)
    if part and part.Position then
        local character = player.Character
        if character then
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,20,0))
            end
        end
    end
end

local function teleportLoop()
    if teleportLoopRunning then return end
    teleportLoopRunning = true

    while player.Character do
        local middleFolder = game.Workspace:FindFirstChild("Lobby")
        middleFolder = middleFolder and middleFolder:FindFirstChild("Model")
        middleFolder = middleFolder and middleFolder:FindFirstChild("Middle")

        if middleFolder then
            for _, winPad in ipairs(middleFolder:GetChildren()) do
                if winPad:IsA("BasePart") and winPad.Name == "WinPad" then
                    teleportTo(winPad)
                    task.wait(waitTime)
                end
            end
        else
            task.wait(1) -- Retry if folder not found
        end
    end

    teleportLoopRunning = false
end

task.spawn(teleportLoop)

player.CharacterAdded:Connect(function()
    task.wait(1)
    task.spawn(teleportLoop)
end)
