local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ShootEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Shoot")

local BLACKLIST = {"donadosPL", "krzys123six"}

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

local gui = Instance.new("ScreenGui")
gui.Name = "FarmStatusGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 150)
frame.Position = UDim2.new(0.5, -200, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local workingLabel = Instance.new("TextLabel")
workingLabel.Size = UDim2.new(1, 0, 0.5, 0)
workingLabel.Position = UDim2.new(0, 0, 0, 0)
workingLabel.BackgroundTransparency = 1
workingLabel.Text = "WORKING"
workingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
workingLabel.Font = Enum.Font.GothamBold
workingLabel.TextSize = 45
workingLabel.Parent = frame

local orNotLabel = Instance.new("TextLabel")
orNotLabel.Size = UDim2.new(1, 0, 0.15, 0)
orNotLabel.Position = UDim2.new(0, 0, 0.45, 0)
orNotLabel.BackgroundTransparency = 1
orNotLabel.Text = "or not working"
orNotLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
orNotLabel.Font = Enum.Font.GothamBold
orNotLabel.TextSize = 18
orNotLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0.25, 0)
statusLabel.Position = UDim2.new(0, 10, 0.7, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
statusLabel.Text = "status: Initializing..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

local clickDetector = Instance.new("TextButton")
clickDetector.Size = UDim2.new(1, 0, 0.5, 0)
clickDetector.Position = UDim2.new(0, 0, 0, 0)
clickDetector.BackgroundTransparency = 1
clickDetector.Text = ""
clickDetector.Parent = frame

clickDetector.MouseButton1Click:Connect(function()
	scriptEnabled = not scriptEnabled
	if scriptEnabled then
		workingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		workingLabel.Text = "WORKING"
		statusText = "Script enabled"
	else
		workingLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		workingLabel.Text = "NOT WORKING"
		statusText = "Script disabled"
	end
	statusLabel.Text = "status: " .. statusText
end)

local function updateStatus(text)
	statusText = text
	statusLabel.Text = "status: " .. statusText
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
	updateStatus("Auto server hop (3min)")
	task.wait(2)
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
	if not mapFolder then
		return nil
	end
	
	local trussesFolder = mapFolder:FindFirstChild("Trusses")
	
	if not trussesFolder then
		return {pos = Vector3.new(-416, 1267, -274), noclip = false}
	end
	
	local trusses = trussesFolder:GetChildren()
	local trussCount = #trusses
	
	if trussCount == 1 then
		return nil
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
		if scriptEnabled then
			equipTool()
		end
	end
end)

task.spawn(function()
	while task.wait(5) do
		if not scriptEnabled then continue end
		
		pcall(function()
			local mapData = detectMapAndGetSpot()
			
			if not mapData then
				updateStatus("Bad map detected - server hopping...")
				task.wait(2)
				TeleportService:Teleport(game.PlaceId, LocalPlayer)
				return
			end
			
			local char = LocalPlayer.Character
			if not char then return end
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			updateStatus("Teleporting to hiding spot...")
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
		updateStatus("No targets found...")
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
		local targetName = "Target"
		if tgt.player then
			targetName = tgt.player.Name
		end
		
		updateStatus("Shooting " .. targetName .. " (" .. shotsOnTarget[tgt.hum] .. "/5)")
		
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
