local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ShootEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Shoot")

getgenv().lt = {
	["_ammo"] = 9999,
	["magazineSize"] = 9999,
	["damage"] = 9999,
	["spread"] = 0,
	["recoilMax"] = Vector2.new(0,0),
	["recoilMin"] = Vector2.new(0,0),
	["equipTime"] = 0,
	["eyeToSightDistance"] = 50,
	["fireMode"] = "Auto",
	["class"] = "Assault Rifle",
	["movementSpeedFactor"] = 10,
	["spreadADS"] = 0,
	["supressionFactor"] = 9999,
	["timeToAim"] = 0,
	["zoom"] = 10,
	["isShotgun"] = false
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
	while task.wait(3) do
		pcall(function()
			local spawnButton = LocalPlayer.PlayerGui.BoardGui.Customize.BottomButtons.SPAWN
			if spawnButton and spawnButton.Visible then
				task.wait(0.2)
				firesignal(spawnButton.MouseButton1Click)
			end
		end)
	end
end)

task.spawn(function()
	while task.wait(5) do
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.1)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
	end
end)

task.spawn(function()
	while task.wait(120) do
		pcall(function()
			local char = LocalPlayer.Character
			if not char then return end
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			local targetsFolder = Workspace:FindFirstChild("Targets")
			if not targetsFolder then return end
			
			local matchTargets = targetsFolder:FindFirstChild("MatchTargets")
			if not matchTargets then return end
			
			local targetList = matchTargets:GetChildren()
			if #targetList > 0 then
				local randomTarget = targetList[math.random(1, #targetList)]
				local targetPos = randomTarget:FindFirstChild("HumanoidRootPart") or randomTarget:FindFirstChild("Torso")
				
				if targetPos then
					local offset = Vector3.new(
						math.random(-5, 5),
						0,
						math.random(-5, 5)
					)
					hrp.CFrame = CFrame.new(targetPos.Position + offset)
				end
			end
		end)
	end
end)

local function getTargets()
	local targets = {}
	local targetsFolder = Workspace:FindFirstChild("Targets")
	if not targetsFolder then return targets end
	
	local matchTargets = targetsFolder:FindFirstChild("MatchTargets")
	if not matchTargets then return targets end
	
	for _, target in ipairs(matchTargets:GetChildren()) do
		local h = target:FindFirstChild("Humanoid")
		local torso = target:FindFirstChild("Torso") or target:FindFirstChild("HumanoidRootPart")
		
		if h and torso and h.Health > 0 then
			table.insert(targets, {hum = h, part = torso})
		end
	end
	
	return targets
end

task.spawn(function()
	while task.wait(2) do
		equipTool()
	end
end)

local lastShot = 0
local SHOOT_COOLDOWN = 0.15

RunService.RenderStepped:Connect(function()
	if os.clock() - lastShot < SHOOT_COOLDOWN then return end
	
	local char = LocalPlayer.Character
	if not char then return end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	
	local targets = getTargets()
	if #targets == 0 then return end
	
	local tgt = targets[1]
	
	pcall(function()
		local pos = tgt.part.Position
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
		lastShot = os.clock()
	end)
end)
