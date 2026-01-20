local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ShootEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Shoot")

getgenv().lt = {
	["_ammo"] = 1e9999999999999999999999999999999999,
	["magazineSize"] = 1e9999999999999999999999999999999999,
	["damage"] = 1e9999999999999999999999999999999999,
	["spread"] = 0,
	["recoilMax"] = Vector2.new(0,0),
	["recoilMin"] = Vector2.new(0,0),
	["equipTime"] = 0,
	["eyeToSightDistance"] = 50,
	["fireMode"] = "Auto",
	["class"] = "Assault Rifle",
	["movementSpeedFactor"] = 10,
	["spreadADS"] = 0,
	["supressionFactor"] = 1e9999999999999999999999999999999999,
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
	while task.wait(60) do
		local char = LocalPlayer.Character
		if not char then continue end
		
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		
		local targetsFolder = Workspace:FindFirstChild("Targets")
		if not targetsFolder then continue end
		
		local matchTargets = targetsFolder:FindFirstChild("MatchTargets")
		if not matchTargets then continue end
		
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

RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	
	local targets = getTargets()
	
	for _, tgt in ipairs(targets) do
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
		end)
	end
end)
