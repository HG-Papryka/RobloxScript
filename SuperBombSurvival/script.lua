local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotThere = ReplicatedStorage:WaitForChild("NotThere")

local autoFarmEnabled = false
local teleportToPickupsEnabled = true
local antiAfkEnabled = true 
local autoLoopSkillEnabled = false
local currentLoop = nil
local noclipConnection = nil
local antiAfkConnection = nil
local skillLoopConnection = nil
local movementConnection = nil
local ragdollConnection = nil
local connections = {}

local fixedY = 273
local points = {
    Vector3.new(121, fixedY, 181),
    Vector3.new(120, fixedY, 28),
    Vector3.new(-34, fixedY, 29),
    Vector3.new(-34, fixedY, 183)
}

local buffer = 20
local platformY = fixedY - 2
local respawnInterval = 4

local pickupCategories = {
    ["Heals"] = {
        enabled = true,
        items = {
            ["Pizza"] = true,
            ["PizzaBox"] = true,			
            ["HeartPickup"] = true,
		    ["DrumstickBig"] = true	
        }
    },
    ["Candy (Halloween exclusive)"] = {
        enabled = false,
        items = {
            ["HalloweenCandy"] = false
        }
    },
    ["Shield(i'll fix it)"] = {
        enabled = false,
        items = {
            ["CrystalShield"] = false,
			["FireShield"] = false
        }		
    },
    ["Coins/Gems"] = {
        enabled = true,
        items = {
            ["Coin_copper"] = true,
            ["Coin_silver"] = true,
            ["Coin_gold"] = true,
            ["Coin_gold2"] = true,
		    ["Coin_purple"] = true,	
            ["Gem"] = true
        }
    },
    ["Events"] = {
        enabled = false,
        items = {
            ["EventIcon"] = false
        }
    },
    ["Sodas"] = {
        enabled = false,
        items = {
            ["SuperSoda"] = false,		
            ["ChargeSoda"] = false
        }
    }
}

local pickupSettings = {}
for categoryName, category in pairs(pickupCategories) do
    for itemName, enabled in pairs(category.items) do
        pickupSettings[itemName] = enabled and category.enabled
    end
end

local statusLabel = nil

local function updateStatus(text, color)
    if statusLabel then
        statusLabel.Text = "Status: " .. text
        statusLabel.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    end
end

local function isCharacterValid(character)
    return character 
        and character.Parent 
        and character:FindFirstChild("HumanoidRootPart") 
        and character:FindFirstChild("Humanoid")
        and character.Humanoid.Health > 0
end

local function safeTP(rootPart, position)
    local success = pcall(function()
        rootPart.CFrame = CFrame.new(position.X, position.Y + 0.9, position.Z)
    end)
    return success
end

local function startAntiAfk()
    if antiAfkConnection then
        pcall(function() task.cancel(antiAfkConnection) end)
    end
    if movementConnection then
        pcall(function() task.cancel(movementConnection) end)
    end
    
    antiAfkConnection = task.spawn(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        
        while antiAfkEnabled do
            local keys = {
                Enum.KeyCode.W,
                Enum.KeyCode.A,
                Enum.KeyCode.S,
                Enum.KeyCode.D
            }
            
            local randomKey = keys[math.random(1, #keys)]
            
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, randomKey, false, game)
                task.wait(math.random(1, 3))
                VirtualInputManager:SendKeyEvent(false, randomKey, false, game)
            end)
            
            task.wait(math.random(20, 40))
        end
    end)

    movementConnection = task.spawn(function()
        while antiAfkEnabled do
            task.wait(300)
            
            if not autoFarmEnabled then
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
                local startTime = tick()
                
                while tick() - startTime < 15 do
                    local randomKey = keys[math.random(1, #keys)]
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, randomKey, false, game)
                        task.wait(math.random(1, 3))
                        VirtualInputManager:SendKeyEvent(false, randomKey, false, game)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end)
    
    task.spawn(function()
        while antiAfkEnabled do
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(120)
        end
    end)
    
    Player.Idled:Connect(function()
        if antiAfkEnabled then
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end

local function stopAntiAfk()
    if antiAfkConnection then
        pcall(function() task.cancel(antiAfkConnection) end)
        antiAfkConnection = nil
    end
    if movementConnection then
        pcall(function() task.cancel(movementConnection) end)
        movementConnection = nil
    end
end

local function startSkillLoop()
    if skillLoopConnection then
        pcall(function() task.cancel(skillLoopConnection) end)
    end
 
    skillLoopConnection = task.spawn(function()
        while autoLoopSkillEnabled do
            task.wait(0.3)
            pcall(function()
                local args = {
                    [1] = 31,
                    [2] = 300,
                    [3] = "skillScript"
                }
                local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if Remotes then
                    local skillUse = Remotes:FindFirstChild("skillUse")
                    if skillUse then
                        skillUse:FireServer(unpack(args))
                    end
                end
            end)
        end
    end)
end

local function stopSkillLoop()
    if skillLoopConnection then
        pcall(function() task.cancel(skillLoopConnection) end)
        skillLoopConnection = nil
    end
end

local function cleanupConnections()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

local function createPotetHubGUI()
    local existing = PlayerGui:FindFirstChild("SBSAutoFarm")
    if existing then
        existing:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SBSAutoFarm"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = UDim2.new(0, 300, 0, 500)
    mainWindow.Position = UDim2.new(0, 50, 0, 50)
    mainWindow.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    mainWindow.BorderSizePixel = 1
    mainWindow.BorderColor3 = Color3.fromRGB(30, 35, 50)
    mainWindow.Active = true
    mainWindow.Parent = screenGui
    
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 2)
    windowCorner.Parent = mainWindow
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(55, 65, 85)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 2)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -35, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "PotetHub - SBS"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.Gotham
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 20)
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 2)
    closeCorner.Parent = closeButton
    
    table.insert(connections, closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    end))
    table.insert(connections, closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
    end))
    
    table.insert(connections, closeButton.MouseButton1Click:Connect(function()
        if autoFarmEnabled then
            autoFarmEnabled = false
            stopAutoFarm()
        end
        if antiAfkEnabled then
            antiAfkEnabled = false
            stopAntiAfk()
        end
        if autoLoopSkillEnabled then
            autoLoopSkillEnabled = false
            stopSkillLoop()
        end
        cleanupConnections()
        screenGui:Destroy()
    end))
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    table.insert(connections, titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainWindow.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))
    
    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainWindow
    
    local farmHeader = Instance.new("TextLabel")
    farmHeader.Size = UDim2.new(1, 0, 0, 20)
    farmHeader.Position = UDim2.new(0, 0, 0, 0)
    farmHeader.BackgroundTransparency = 1
    farmHeader.Text = "Farming"
    farmHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmHeader.TextSize = 13
    farmHeader.Font = Enum.Font.GothamBold
    farmHeader.TextXAlignment = Enum.TextXAlignment.Left
    farmHeader.Parent = contentFrame
    
    local farmButton = Instance.new("TextButton")
    farmButton.Size = UDim2.new(1, 0, 0, 32)
    farmButton.Position = UDim2.new(0, 0, 0, 25)
    farmButton.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    farmButton.BorderSizePixel = 0
    farmButton.Text = "▷ Autofarm"
    farmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmButton.TextSize = 12
    farmButton.Font = Enum.Font.Gotham
    farmButton.TextXAlignment = Enum.TextXAlignment.Left
    farmButton.Parent = contentFrame
    
    local farmCorner = Instance.new("UICorner")
    farmCorner.CornerRadius = UDim.new(0, 3)
    farmCorner.Parent = farmButton
    
    local farmPadding = Instance.new("UIPadding")
    farmPadding.PaddingLeft = UDim.new(0, 12)
    farmPadding.Parent = farmButton
    
    local farmCheckmark = Instance.new("TextLabel")
    farmCheckmark.Size = UDim2.new(0, 20, 1, 0)
    farmCheckmark.Position = UDim2.new(1, -25, 0, 0)
    farmCheckmark.BackgroundTransparency = 1
    farmCheckmark.Text = ""
    farmCheckmark.TextColor3 = Color3.fromRGB(120, 220, 120)
    farmCheckmark.TextSize = 14
    farmCheckmark.Font = Enum.Font.GothamBold
    farmCheckmark.Parent = farmButton
    
    local settingsHeader = Instance.new("TextLabel")
    settingsHeader.Size = UDim2.new(1, 0, 0, 20)
    settingsHeader.Position = UDim2.new(0, 0, 0, 75)
    settingsHeader.BackgroundTransparency = 1
    settingsHeader.Text = "Farm Settings"
    settingsHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsHeader.TextSize = 13
    settingsHeader.Font = Enum.Font.GothamBold
    settingsHeader.TextXAlignment = Enum.TextXAlignment.Left
    settingsHeader.Parent = contentFrame
    
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
    dropdownArrow.Position = UDim2.new(1, -20, 0, 75)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Text = "▼"
    dropdownArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdownArrow.TextSize = 10
    dropdownArrow.Font = Enum.Font.Gotham
    dropdownArrow.Parent = contentFrame
    
    local pickupListFrame = Instance.new("Frame")
    pickupListFrame.Size = UDim2.new(1, 0, 0, 180)
    pickupListFrame.Position = UDim2.new(0, 0, 0, 100)
    pickupListFrame.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    pickupListFrame.BorderSizePixel = 0
    pickupListFrame.Parent = contentFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 3)
    listCorner.Parent = pickupListFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 90, 110)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.Parent = pickupListFrame
    
    local yPos = 5
    
    for categoryName, category in pairs(pickupCategories) do
        local hasItems = false
        for _, _ in pairs(category.items) do
            hasItems = true
            break
        end
        
        if hasItems then
            local categoryButton = Instance.new("TextButton")
            categoryButton.Size = UDim2.new(1, -10, 0, 32)
            categoryButton.Position = UDim2.new(0, 5, 0, yPos)
            categoryButton.BackgroundColor3 = category.enabled and Color3.fromRGB(65, 75, 95) or Color3.fromRGB(50, 60, 80)
            categoryButton.BorderSizePixel = 0
            categoryButton.Text = ""
            categoryButton.Parent = scrollFrame
            
            local categoryCorner = Instance.new("UICorner")
            categoryCorner.CornerRadius = UDim.new(0, 3)
            categoryCorner.Parent = categoryButton
            
            table.insert(connections, categoryButton.MouseEnter:Connect(function()
                if not category.enabled then
                    categoryButton.BackgroundColor3 = Color3.fromRGB(55, 65, 85)
                end
            end))
            table.insert(connections, categoryButton.MouseLeave:Connect(function()
                categoryButton.BackgroundColor3 = category.enabled and Color3.fromRGB(65, 75, 95) or Color3.fromRGB(50, 60, 80)
            end))
            
            local categoryCheckmark = Instance.new("TextLabel")
            categoryCheckmark.Size = UDim2.new(0, 20, 1, 0)
            categoryCheckmark.Position = UDim2.new(0, 10, 0, 0)
            categoryCheckmark.BackgroundTransparency = 1
            categoryCheckmark.Text = category.enabled and "✓" or ""
            categoryCheckmark.TextColor3 = Color3.fromRGB(120, 220, 120)
            categoryCheckmark.TextSize = 14
            categoryCheckmark.Font = Enum.Font.GothamBold
            categoryCheckmark.Parent = categoryButton
            
            local categoryLabel = Instance.new("TextLabel")
            categoryLabel.Size = UDim2.new(1, -40, 1, 0)
            categoryLabel.Position = UDim2.new(0, 35, 0, 0)
            categoryLabel.BackgroundTransparency = 1
            categoryLabel.Text = categoryName
            categoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            categoryLabel.TextSize = 12
            categoryLabel.Font = Enum.Font.GothamBold
            categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
            categoryLabel.Parent = categoryButton
            
            table.insert(connections, categoryButton.MouseButton1Click:Connect(function()
                category.enabled = not category.enabled
                
                for itemName, _ in pairs(category.items) do
                    pickupSettings[itemName] = category.enabled
                end
                
                if category.enabled then
                    categoryCheckmark.Text = "✓"
                    categoryButton.BackgroundColor3 = Color3.fromRGB(65, 75, 95)
                else
                    categoryCheckmark.Text = ""
                    categoryButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
                end
            end))
            
            yPos = yPos + 38
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    
    local otherHeader = Instance.new("TextLabel")
    otherHeader.Size = UDim2.new(1, 0, 0, 20)
    otherHeader.Position = UDim2.new(0, 0, 0, 290)
    otherHeader.BackgroundTransparency = 1
    otherHeader.Text = "Other"
    otherHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    otherHeader.TextSize = 13
    otherHeader.Font = Enum.Font.GothamBold
    otherHeader.TextXAlignment = Enum.TextXAlignment.Left
    otherHeader.Parent = contentFrame
    
    local otherFrame = Instance.new("Frame")
    otherFrame.Size = UDim2.new(1, 0, 0, 80)
    otherFrame.Position = UDim2.new(0, 0, 0, 315)
    otherFrame.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    otherFrame.BorderSizePixel = 0
    otherFrame.Parent = contentFrame
    
    local otherCorner = Instance.new("UICorner")
    otherCorner.CornerRadius = UDim.new(0, 3)
    otherCorner.Parent = otherFrame
    
    local antiAfkButton = Instance.new("TextButton")
    antiAfkButton.Size = UDim2.new(1, -10, 0, 32)
    antiAfkButton.Position = UDim2.new(0, 5, 0, 5)
    antiAfkButton.BackgroundColor3 = antiAfkEnabled and Color3.fromRGB(65, 75, 95) or Color3.fromRGB(50, 60, 80)
    antiAfkButton.BorderSizePixel = 0
    antiAfkButton.Text = ""
    antiAfkButton.Parent = otherFrame
    
    local antiAfkCorner = Instance.new("UICorner")
    antiAfkCorner.CornerRadius = UDim.new(0, 3)
    antiAfkCorner.Parent = antiAfkButton
    
    local antiAfkCheckmark = Instance.new("TextLabel")
    antiAfkCheckmark.Size = UDim2.new(0, 20, 1, 0)
    antiAfkCheckmark.Position = UDim2.new(0, 10, 0, 0)
    antiAfkCheckmark.BackgroundTransparency = 1
    antiAfkCheckmark.Text = antiAfkEnabled and "✓" or ""
    antiAfkCheckmark.TextColor3 = Color3.fromRGB(120, 220, 120)
    antiAfkCheckmark.TextSize = 14
    antiAfkCheckmark.Font = Enum.Font.GothamBold
    antiAfkCheckmark.Parent = antiAfkButton
    
    local antiAfkLabel = Instance.new("TextLabel")
    antiAfkLabel.Size = UDim2.new(1, -40, 1, 0)
    antiAfkLabel.Position = UDim2.new(0, 35, 0, 0)
    antiAfkLabel.BackgroundTransparency = 1
    antiAfkLabel.Text = "Anti AFK"
    antiAfkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiAfkLabel.TextSize = 12
    antiAfkLabel.Font = Enum.Font.GothamBold
    antiAfkLabel.TextXAlignment = Enum.TextXAlignment.Left
    antiAfkLabel.Parent = antiAfkButton
    
    table.insert(connections, antiAfkButton.MouseButton1Click:Connect(function()
        antiAfkEnabled = not antiAfkEnabled
        
        if antiAfkEnabled then
            antiAfkCheckmark.Text = "✓"
            antiAfkButton.BackgroundColor3 = Color3.fromRGB(65, 75, 95)
            startAntiAfk()
        else
            antiAfkCheckmark.Text = ""
            antiAfkButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            stopAntiAfk()
        end
    end))
    
    local skillLoopButton = Instance.new("TextButton")
    skillLoopButton.Size = UDim2.new(1, -10, 0, 32)
    skillLoopButton.Position = UDim2.new(0, 5, 0, 42)
    skillLoopButton.BackgroundColor3 = autoLoopSkillEnabled and Color3.fromRGB(65, 75, 95) or Color3.fromRGB(50, 60, 80)
    skillLoopButton.BorderSizePixel = 0
    skillLoopButton.Text = ""
    skillLoopButton.Parent = otherFrame
    
    local skillLoopCorner = Instance.new("UICorner")
    skillLoopCorner.CornerRadius = UDim.new(0, 3)
    skillLoopCorner.Parent = skillLoopButton
    
    local skillLoopCheckmark = Instance.new("TextLabel")
    skillLoopCheckmark.Size = UDim2.new(0, 20, 1, 0)
    skillLoopCheckmark.Position = UDim2.new(0, 10, 0, 0)
    skillLoopCheckmark.BackgroundTransparency = 1
    skillLoopCheckmark.Text = autoLoopSkillEnabled and "✓" or ""
    skillLoopCheckmark.TextColor3 = Color3.fromRGB(120, 220, 120)
    skillLoopCheckmark.TextSize = 14
    skillLoopCheckmark.Font = Enum.Font.GothamBold
    skillLoopCheckmark.Parent = skillLoopButton
    
    local skillLoopLabel = Instance.new("TextLabel")
    skillLoopLabel.Size = UDim2.new(1, -40, 1, 0)
    skillLoopLabel.Position = UDim2.new(0, 35, 0, 0)
    skillLoopLabel.BackgroundTransparency = 1
    skillLoopLabel.Text = "Skill Loop (i'll fix it)"
    skillLoopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    skillLoopLabel.TextSize = 12
    skillLoopLabel.Font = Enum.Font.GothamBold
    skillLoopLabel.TextXAlignment = Enum.TextXAlignment.Left
    skillLoopLabel.Parent = skillLoopButton
    
    table.insert(connections, skillLoopButton.MouseButton1Click:Connect(function()
        autoLoopSkillEnabled = not autoLoopSkillEnabled
        
        if autoLoopSkillEnabled then
            skillLoopCheckmark.Text = "✓"
            skillLoopButton.BackgroundColor3 = Color3.fromRGB(65, 75, 95)
            startSkillLoop()
        else
            skillLoopCheckmark.Text = ""
            skillLoopButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            stopSkillLoop()
        end
    end))
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 16)
    status.Position = UDim2.new(0, 0, 1, -20)
    status.BackgroundTransparency = 1
    status.Text = "Status: Inactive"
    status.TextColor3 = Color3.fromRGB(180, 180, 180)
    status.TextSize = 10
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = contentFrame
    
    return screenGui, farmButton, status, farmCheckmark
end

local function calculateBounds()
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    
    for _, pos in ipairs(points) do
        minX = math.min(minX, pos.X)
        maxX = math.max(maxX, pos.X)
        minZ = math.min(minZ, pos.Z)
        maxZ = math.max(maxZ, pos.Z)
    end
    
    return minX, maxX, minZ, maxZ
end

local function createPlatform()
    local minX, maxX, minZ, maxZ = calculateBounds()
    local sizeX = (maxX - minX) + buffer * 2
    local sizeZ = (maxZ - minZ) + buffer * 2
    local centerX = (minX + maxX) / 2
    local centerZ = (minZ + maxZ) / 2
    
    local existing = Workspace:FindFirstChild("AutoFarmPlatform")
    if existing then
        existing:Destroy()
    end
    
    local platform = Instance.new("Part")
    platform.Name = "AutoFarmPlatform"
    platform.Size = Vector3.new(sizeX, 1, sizeZ)
    platform.Position = Vector3.new(centerX, platformY, centerZ)
    platform.Anchored = true
    platform.Transparency = 0.7
    platform.CanCollide = true
    platform.BrickColor = BrickColor.new("Bright green")
    platform.Parent = Workspace
end

local function setupNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        local character = Player.Character
        if character and autoFarmEnabled then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function waitForCharacter()
    local character = Player.Character
    while not isCharacterValid(character) do
        character = Player.Character
        task.wait(1)
    end
    return character
end

local function teleportToPickups(character)
    if not teleportToPickupsEnabled then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not character.Parent then return end
    
    local bombsFolder = Workspace:FindFirstChild("Bombs")
    if not bombsFolder then return end
    
    for _, obj in ipairs(bombsFolder:GetChildren()) do
        if not character.Parent or not rootPart.Parent or not autoFarmEnabled then
            break
        end
        
        if obj:IsA("BasePart") and pickupSettings[obj.Name] then
            local distance = (rootPart.Position - obj.Position).Magnitude
            if distance < 300 then
                safeTP(rootPart, obj.Position)
                task.wait(0.3)
            end
        end
    end
end

local function startAutoFarm()
    if currentLoop then
        pcall(function() task.cancel(currentLoop) end)
    end
    
    if ragdollConnection then
        pcall(function() task.cancel(ragdollConnection) end)
    end
    
    ragdollConnection = task.spawn(function()
        while autoFarmEnabled do
            task.wait(0.1)
            pcall(function()
                local ragdollRemote = ReplicatedStorage:FindFirstChild("Remotes")
                if ragdollRemote then
                    ragdollRemote = ragdollRemote:FindFirstChild("Ragdoll")
                    if ragdollRemote then
                        ragdollRemote:FireServer("off")
                    end
                end
            end)
        end
    end)
    
    currentLoop = task.spawn(function()
        local loopCount = 0
        
        while autoFarmEnabled do
            local character = waitForCharacter()
            if not autoFarmEnabled then break end
            
            local rootPart = character:WaitForChild("HumanoidRootPart")
            
            loopCount = loopCount + 1
            
            if loopCount % respawnInterval == 1 then
                createPlatform()
            end
            
            for _, point in ipairs(points) do
                if not character.Parent or not autoFarmEnabled then break end
                
                safeTP(rootPart, point)
                task.wait(0.25)
            end
            
            if autoFarmEnabled and character.Parent then
                teleportToPickups(character)
            end
            
            task.wait(0.1)
        end
    end)
end

function stopAutoFarm()
    if currentLoop then
        pcall(function() task.cancel(currentLoop) end)
        currentLoop = nil
    end
    
    if ragdollConnection then
        pcall(function() task.cancel(ragdollConnection) end)
        ragdollConnection = nil
    end
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local platform = Workspace:FindFirstChild("AutoFarmPlatform")
    if platform then
        platform:Destroy()
    end
end

local gui, farmButton, status, farmCheckmark = createPotetHubGUI()
statusLabel = status

if antiAfkEnabled then
    startAntiAfk()
end

table.insert(connections, farmButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    
    if autoFarmEnabled then
        farmButton.Text = "▷ Autofarm"
        farmButton.BackgroundColor3 = Color3.fromRGB(65, 75, 95)
        farmCheckmark.Text = "✓"
        updateStatus("Active - Farming...", Color3.fromRGB(120, 220, 120))
        
        setupNoclip()
        startAutoFarm()
    else
        farmButton.Text = "▷ Autofarm"
        farmButton.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
        farmCheckmark.Text = ""
        updateStatus("Inactive", Color3.fromRGB(180, 180, 180))
        
        stopAutoFarm()
    end
end))
