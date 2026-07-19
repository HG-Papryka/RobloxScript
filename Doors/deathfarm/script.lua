while not game:IsLoaded() do
	task.wait(1)
end

print("WeLovePotet death farm for DOORS")
print("heavily inspired by abbys death farm")

local Services = setmetatable({}, {
	__index = function(self, Key)
		return game:GetService(Key)
	end
})

local QueueTeleport = queue_on_teleport or queueonteleport
local TeleportCode = [==[
	loadstring(game:HttpGet("https://raw.githubusercontent.com/HG-Papryka/RobloxScript/refs/heads/main/Doors/deathfarm/script.lua"))()
]==]

local LocalPlayer = Services.Players.LocalPlayer
local RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local CurrentRooms = Services.Workspace:FindFirstChild("CurrentRooms")
local GameData = Services.ReplicatedStorage:FindFirstChild("GameData")

local function SendCaption(Text)
	local Msg = "[WeLovePotet] " .. Text
	print(Msg)
	pcall(function()
		if firesignal then
			firesignal(RemotesFolder.Caption.OnClientEvent, Msg)
		else
			RemotesFolder.CaptionClient:Fire(Msg)
		end
	end)
end

if game.PlaceId == 6516141723 then
	SendCaption("Joining a run...")
	QueueTeleport(TeleportCode)
	RemotesFolder.CreateElevator:FireServer({
		Mods = {},
		Settings = {},
		Destination = "Hotel",
		FriendsOnly = false,
		MaxPlayers = "1"
	})
	return
end

if GameData and GameData.Floor.Value ~= "Hotel" then
	QueueTeleport([==[
		local RemotesFolder = game:GetService("ReplicatedStorage").RemotesFolder
		local function SendCaption(Text)
			if firesignal then
				firesignal(RemotesFolder.Caption.OnClientEvent, "[WeLovePotet] " .. Text)
			else
				RemotesFolder.CaptionClient:Fire("[WeLovePotet] " .. Text)
			end
		end
		local QueueTeleport = queue_on_teleport or queueonteleport
		QueueTeleport([=[loadstring(game:HttpGet("PASTE_YOUR_RAW_URL_HERE"))()]=])
		SendCaption("Joining a run...")
		RemotesFolder.CreateElevator:FireServer({
			Mods = {},
			Settings = {},
			Destination = "Hotel",
			FriendsOnly = false,
			MaxPlayers = "1"
		})
	]==])
	RemotesFolder.Lobby:FireServer()
	return
end

if game.PlaceId ~= 6839171747 then
	QueueTeleport([==[
		local RemotesFolder = game:GetService("ReplicatedStorage").RemotesFolder
		local function SendCaption(Text)
			if firesignal then
				firesignal(RemotesFolder.Caption.OnClientEvent, "[WeLovePotet] " .. Text)
			else
				RemotesFolder.CaptionClient:Fire("[WeLovePotet] " .. Text)
			end
		end
		local QueueTeleport = queue_on_teleport or queueonteleport
		QueueTeleport([=[loadstring(game:HttpGet("PASTE_YOUR_RAW_URL_HERE"))()]=])
		SendCaption("Joining a run...")
		RemotesFolder.CreateElevator:FireServer({
			Mods = {},
			Settings = {},
			Destination = "Hotel",
			FriendsOnly = false,
			MaxPlayers = "1"
		})
	]==])
	Services.TeleportService:Teleport(6516141723)
	return
end

while #CurrentRooms:GetChildren() < 1 or not LocalPlayer.Character do
	task.wait(1)
end

local MainUI = LocalPlayer.PlayerGui:WaitForChild("MainUI", 9e9)

if MainUI:FindFirstChild("ItemShop") then
	MainUI.ItemShop.Visible = false
	RemotesFolder.PreRunShop:FireServer({}, true)
end

task.wait(1)

local SkipPrompt = Services.Workspace:FindFirstChild("SkipPrompt", true)
if SkipPrompt then
	fireproximityprompt(SkipPrompt)
end

local Room0 = CurrentRooms:WaitForChild("0", 9e9)
local Assets = Room0:WaitForChild("Assets", 9e9)
local Parts = Room0:FindFirstChild("Parts")
local RiftSpawn = Room0:FindFirstChild("RiftSpawn")

local Kill = {
	Assets:FindFirstChild("Luggage_Cart_Crouch"),
	Parts and Parts:FindFirstChild("FrontDesk"),
	RiftSpawn and RiftSpawn:FindFirstChild("Rift"),
}

for _, Object in ipairs(Kill) do
	if Object then
		Object:Destroy()
	end
end

for _, Object in pairs(Assets:GetChildren()) do
	if Object.Name == "Potted_Plant" then
		local Collision = Object:FindFirstChild("Collision")
		if Collision then
			Collision.CanCollide = false
		end
	end
end

local Reach = 2

local function TouchPrompt(Prompt)
	if not Prompt or not Prompt:IsA("ProximityPrompt") then return end
	if not Prompt:GetAttribute("HoldDuration_Old") then
		Prompt:SetAttribute("HoldDuration_Old", Prompt.HoldDuration)
	end
	if not Prompt:GetAttribute("MaxActivationDistance_Old") then
		Prompt:SetAttribute("MaxActivationDistance_Old", Prompt.MaxActivationDistance)
	end
	Prompt.HoldDuration = 0
	Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") * Reach
end

for _, Object in ipairs(Services.Workspace:GetDescendants()) do
	if Object:IsA("ProximityPrompt") then
		TouchPrompt(Object)
	end
end

Services.Workspace.DescendantAdded:Connect(function(Object)
	if Object:IsA("ProximityPrompt") then
		task.defer(TouchPrompt, Object)
	end
end)

task.spawn(function()
	while task.wait(0.05) do
		local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not Root then continue end
		for _, Prompt in ipairs(Services.Workspace:GetDescendants()) do
			if Prompt:IsA("ProximityPrompt") and Prompt.Enabled then
				local Parent = Prompt.Parent
				local Name = Parent and Parent.Name or ""
				if Name == "KeyObtain" or Name == "GoldPile" or Name == "Lock" or Prompt.Name == "ModulePrompt" or Prompt.Name == "UnlockPrompt" then
					local Anchor = Parent:IsA("BasePart") and Parent or Parent:FindFirstChildWhichIsA("BasePart", true)
					if not Anchor and Name == "KeyObtain" then
						Anchor = Parent:FindFirstChild("Hitbox")
					end
					if Anchor and (Root.Position - Anchor.Position).Magnitude <= Prompt.MaxActivationDistance then
						fireproximityprompt(Prompt)
					end
				end
			end
		end
	end
end)

local function WalkPosition(TargetPosition)
	local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid", 9e9)

	local Finished = false
	local Connection = Services.RunService.RenderStepped:Connect(function()
		Humanoid:MoveTo(TargetPosition)
		if LocalPlayer:DistanceFromCharacter(TargetPosition) < 8 then
			Finished = true
		end
	end)

	while task.wait() do
		if Finished then
			Connection:Disconnect()
			break
		end
	end
	task.wait()
	return true
end

task.wait(1)

SendCaption("Getting the key...")
local Door = Room0:FindFirstChild("Door")
Door.Lock.CanCollide = false

local Key = Assets:WaitForChild("KeyObtain", 9e9)
WalkPosition(Key.Hitbox.Position)
fireproximityprompt(Key:FindFirstChild("ModulePrompt", true))

SendCaption("Got the key, opening the door...")
WalkPosition(Door.Lock.Position)
fireproximityprompt(Door:FindFirstChild("UnlockPrompt", true))

while not CurrentRooms:FindFirstChild("2") do
	task.wait()
end

if replicatesignal then
	replicatesignal(LocalPlayer.Kill)
else
	SendCaption("Please wait around 20 seconds to die")
	RemotesFolder.Underwater:FireServer(true)
end

LocalPlayer:GetAttributeChangedSignal("Alive"):Wait()
SendCaption("Player has died, joining a new run...")

RemotesFolder.PlayAgain:FireServer()
QueueTeleport(TeleportCode)
