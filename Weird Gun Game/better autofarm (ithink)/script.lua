local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ShootEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Shoot")

local BLACKLIST = {"izgak3140DIt"} -- oop

getgenv().lt = {
	["damage"] = 67
}

if not(getgenv().work) then
	LocalPlayer.CharacterAdded:Connect(function(char)
		local tool
		while not(tool) and task.wait() do tool = char:FindFirstChildWhichIsA("Tool") end
		for i,v in getgenv().lt do tool:SetAttribute(i,v) end
	end)
	getgenv().work = true
end

local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

local Noclip = nil
local Clip = nil

function noclip()
	Clip = false
	local function Nocl()
		if Clip == false and LocalPlayer.Character ~= nil then
			for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
				if v:IsA('BasePart') and v.CanCollide then
					v.CanCollide = false
				end
			end
		end
	end
	Noclip = RunService.Stepped:Connect(Nocl)
end

function clip()
	if Noclip then Noclip:Disconnect() end
	Clip = true
end

noclip()

local scriptEnabled = true
local statusText = "Initializing..."
local lastImportantStatus = 0
local importantStatusDuration = 3

local COLOR1 = Color3.fromHex("447294")
local COLOR2 = Color3.fromHex("8fbcdb")
local COLOR3 = Color3.fromHex("f4d6bc")

local gui = Instance.new("ScreenGui")
gui.Name = "FarmStatusGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 150)
frame.Position = UDim2.new(0.5, -200, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local bgText = Instance.new("TextLabel")
bgText.Size = UDim2.new(1, 0, 1, 0)
bgText.Position = UDim2.new(0, 0, 0, 0)
bgText.BackgroundTransparency = 1
bgText.Text = "Potetium+"
bgText.TextColor3 = Color3.fromRGB(255, 255, 255)
bgText.TextTransparency = 0.75
bgText.Font = Enum.Font.GothamBold
bgText.TextSize = 52
bgText.ZIndex = 1
bgText.Parent = frame

local workingLabel = Instance.new("TextLabel")
workingLabel.Size = UDim2.new(1, 0, 0.5, 0)
workingLabel.Position = UDim2.new(0, 0, 0, 0)
workingLabel.BackgroundTransparency = 1
workingLabel.Text = "WORKING"
workingLabel.TextColor3 = COLOR1
workingLabel.Font = Enum.Font.GothamBold
workingLabel.TextSize = 45
workingLabel.ZIndex = 2
workingLabel.Parent = frame

local orNotLabel = Instance.new("TextLabel")
orNotLabel.Size = UDim2.new(1, 0, 0.15, 0)
orNotLabel.Position = UDim2.new(0, 0, 0.45, 0)
orNotLabel.BackgroundTransparency = 1
orNotLabel.Text = "or not working"
orNotLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
orNotLabel.Font = Enum.Font.GothamBold
orNotLabel.TextSize = 18
orNotLabel.ZIndex = 2
orNotLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0.25, 0)
statusLabel.Position = UDim2.new(0, 10, 0.72, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusLabel.Text = "status: Initializing..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 2
statusLabel.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

local clickDetector = Instance.new("TextButton")
clickDetector.Size = UDim2.new(1, 0, 0.6, 0)
clickDetector.Position = UDim2.new(0, 0, 0, 0)
clickDetector.BackgroundTransparency = 1
clickDetector.Text = ""
clickDetector.ZIndex = 3
clickDetector.Parent = frame

clickDetector.MouseButton1Click:Connect(function()
	scriptEnabled = not scriptEnabled
	if scriptEnabled then
		workingLabel.Text = "WORKING"
		orNotLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	else
		workingLabel.Text = "NOT WORKING"
		orNotLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

task.spawn(function()
	local colors = {COLOR1, COLOR2, COLOR3, COLOR2, COLOR1}
	local idx = 1
	while true do
		local nextIdx = (idx % #colors) + 1
		local tween = TweenService:Create(workingLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = colors[nextIdx]})
		tween:Play()
		tween.Completed:Wait()
		idx = nextIdx
	end
end)

local dotCount = 0
local shootingTarget = ""
local isShootingState = false

task.spawn(function()
	while true do
		task.wait(0.4)
		if isShootingState and scriptEnabled then
			dotCount = (dotCount % 3) + 1
			local dots = string.rep(".", dotCount)
			local spaces = string.rep(" ", 3 - dotCount)
			statusLabel.Text = "shooting " .. shootingTarget .. " " .. dots .. spaces
		end
	end
end)

local importantStatusActive = false

local function updateStatus(text, important)
	if importantStatusActive then return end
	
	if important then
		importantStatusActive = true
		isShootingState = false
		statusLabel.Text = "status: " .. text
		statusLabel.TextColor3 = Color3.fromHex("f4d6bc")
		task.spawn(function()
			task.wait(importantStatusDuration)
			statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			importantStatusActive = false
		end)
	else
		isShootingState = false
		statusLabel.Text = "status: " .. text
	end
end

local function setShootingStatus(targetName)
	if importantStatusActive then return end
	isShootingState = true
	shootingTarget = targetName
end

local function equipTool()
	local char = LocalPlayer.Character
	if not char then return end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then 
		for i,v in getgenv().lt do 
			tool:SetAttribute(i,v) 
		end
		return 
	end
	
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				char.Humanoid:EquipTool(item)
				for i,v in getgenv().lt do 
					item:SetAttribute(i,v) 
				end
				break
			end
		end
	end
end

task.spawn(function()
	while task.wait(1) do
		pcall(function()
			local spawnButton = LocalPlayer.PlayerGui.BoardGui.Customize.BottomButtons.SPAWN
			if spawnButton and spawnButton.Visible then
				for i = 1, 3 do
					task.wait(0.1)
					firesignal(spawnButton.MouseButton1Click)
				end
			end
		end)
	end
end)

task.spawn(function()
	while task.wait(2) do
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.1)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
	end
end)

task.spawn(function()
	task.wait(180)
	updateStatus("auto server hopping...", true)
	task.wait(3)
	TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

local function isBlacklisted(username)
	for _, blacklisted in ipairs(BLACKLIST) do
		if string.lower(username) == string.lower(blacklisted) then
			return true
		end
	end
	return false
end

local function getTargets()
	local targets = {}
	local char = LocalPlayer.Character
	if not char then return targets end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return targets end
	
	local targetsFolder = Workspace:FindFirstChild("Targets")
	if not targetsFolder then return targets end
	
	local matchTargets = targetsFolder:FindFirstChild("MatchTargets")
	if not matchTargets then return targets end
	
	for _, target in ipairs(matchTargets:GetChildren()) do
		local h = target:FindFirstChild("Humanoid")
		local head = target:FindFirstChild("Head")
		
		if h and head and h.Health > 0 then
			local player = Players:GetPlayerFromCharacter(target)
			if not player or (player and not isBlacklisted(player.Name)) then
				local distance = (hrp.Position - head.Position).Magnitude
				table.insert(targets, {hum = h, part = head, dist = distance, char = target, player = player})
			end
		end
	end
	
	table.sort(targets, function(a, b) return a.dist < b.dist end)
	
	return targets
end

local function detectMapAndGetSpot()
	local mapFolder = Workspace:FindFirstChild("Map")
	if not mapFolder then return nil end
	
	local trussesFolder = mapFolder:FindFirstChild("Trusses")
	
	if not trussesFolder then
		return {pos = Vector3.new(-416, 1267, -274), noclip = false}
	end
	
	local trusses = trussesFolder:GetChildren()
	local trussCount = #trusses
	
	if trussCount == 1 then
		return {pos = Vector3.new(-55, 1133, -270), noclip = true}
	elseif trussCount == 4 then
		local hasNeonRed = false
		for _, truss in ipairs(trusses) do
			if truss:IsA("BasePart") then
				if truss.Material == Enum.Material.Neon and truss.Color == Color3.fromRGB(107, 0, 0) then
					hasNeonRed = true
					break
				end
			end
		end
		if hasNeonRed then
			return {pos = Vector3.new(-2279, 678, -1174), noclip = true}
		else
			return {pos = Vector3.new(-11, 93, 15), noclip = true}
		end
	elseif trussCount == 7 then
		return {pos = Vector3.new(-381, 668, -456), noclip = false}
	elseif trussCount == 9 then
		return {pos = Vector3.new(-416, 1267, -274), noclip = false}
	elseif trussCount == 11 then
		return {pos = Vector3.new(-680, 39, -489), noclip = true}
	elseif trussCount == 14 then
		return {pos = Vector3.new(375, 765, 346), noclip = false}
	elseif trussCount == 28 then
		return {pos = Vector3.new(100, 1677, 339), noclip = false}
	elseif trussCount >= 40 then
		return {pos = Vector3.new(-8, 308, 2515), noclip = true}
	else
		return nil
	end
end

task.spawn(function()
	while task.wait(2) do
		if scriptEnabled then equipTool() end
	end
end)

task.spawn(function()
	while task.wait(5) do
		if not scriptEnabled then continue end
		pcall(function()
			local mapData = detectMapAndGetSpot()
			
			if not mapData then
				updateStatus("bad map - server hopping...", true)
				task.wait(3)
				TeleportService:Teleport(game.PlaceId, LocalPlayer)
				return
			end
			
			local char = LocalPlayer.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			updateStatus("map detected - teleporting...", true)
			hrp.CFrame = CFrame.new(mapData.pos)
			hrp.Velocity = Vector3.new(0, 0, 0)
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end)
	end
end)

local lastShot = 0
local shotsOnTarget = {}
local currentTarget = nil

RunService.RenderStepped:Connect(function()
	if not scriptEnabled then return end
	
	local fireDelay = math.random(50, 100) / 1000
	if os.clock() - lastShot < fireDelay then return end
	
	local char = LocalPlayer.Character
	if not char then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Velocity = Vector3.new(0, 0, 0)
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	
	local targets = getTargets()
	if #targets == 0 then
		currentTarget = nil
		updateStatus("no targets found...")
		return
	end
	
	local tgt = targets[1]
	
	if currentTarget ~= tgt.hum then
		currentTarget = tgt.hum
		shotsOnTarget[tgt.hum] = 0
	end
	
	if shotsOnTarget[tgt.hum] >= 5 then
		shotsOnTarget[tgt.hum] = 0
		currentTarget = nil
		task.wait(0.2)
		return
	end
	
	pcall(function()
		local targetName = tgt.player and tgt.player.Name or "target"
		setShootingStatus(targetName)
		
		local pos = tgt.part.Position + Vector3.new(
			math.random(-5, 5) / 10,
			math.random(-5, 5) / 10,
			math.random(-5, 5) / 10
		)
		
		local dir = (pos - Camera.CFrame.Position).Unit
		local cf = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
		
		local args = {
			os.clock(),
			tool,
			cf,
			true,
			{
				["1"] = {
					tgt.hum,
					false,
					true,
					100
				}
			}
		}
		
		ShootEvent:FireServer(unpack(args))
		shotsOnTarget[tgt.hum] = shotsOnTarget[tgt.hum] + 1
		lastShot = os.clock()
	end)
end)
