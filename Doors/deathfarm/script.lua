while not game:IsLoaded() do
	task.wait(1)
end

print("WeLovePotet death farm for DOORS")
print("heavily inspired by abbys death farm")

local a = setmetatable({}, {
	__index = function(self, b)
		return game:GetService(b)
	end
})

local c = queue_on_teleport or queueonteleport
local d = [==[
	loadstring(game:HttpGet("https://raw.githubusercontent.com/HG-Papryka/RobloxScript/refs/heads/main/Doors/deathfarm/script.lua"))()
]==]

local e = a.Players.LocalPlayer
local f = a.ReplicatedStorage:FindFirstChild("RemotesFolder")
local g = a.Workspace:FindFirstChild("CurrentRooms")
local h = a.ReplicatedStorage:FindFirstChild("GameData")

local function i(j) -- dont look :(
	if math.random(1, 100000) == 1 then
		j = "Meow :3"
		task.spawn(function()
			local sfx = Instance.new("Sound")
			sfx.SoundId = "rbxassetid://134881862056957"
			sfx.Volume = 1
			sfx.Parent = a.SoundService
			sfx:Play()
			sfx.Ended:Connect(function()
				sfx:Destroy()
			end)
		end)
	end
	local k = "[WeLovePotet] " .. j
	print(k)
	pcall(function()
		if firesignal then
			firesignal(f.Caption.OnClientEvent, k)
		else
			f.CaptionClient:Fire(k)
		end
	end)
end

if game.PlaceId == 6516141723 then
	i("Joining a run...")
	c(d)
	f.CreateElevator:FireServer({
		Mods = {},
		Settings = {},
		Destination = "Hotel",
		FriendsOnly = false,
		MaxPlayers = "1"
	})
	return
end

if h and h.Floor.Value ~= "Hotel" then
	c([==[
		local RemotesFolder = game:GetService("ReplicatedStorage").RemotesFolder
		local function SendCaption(Text)
			if math.random(1, 100000) == 1 then
				Text = "Meow :3"
				task.spawn(function()
					local sfx = Instance.new("Sound")
					sfx.SoundId = "rbxassetid://134881862056957"
					sfx.Volume = 1
					sfx.Parent = game:GetService("SoundService")
					sfx:Play()
					sfx.Ended:Connect(function() sfx:Destroy() end)
				end)
			end
			if firesignal then
				firesignal(RemotesFolder.Caption.OnClientEvent, "[WeLovePotet] " .. Text)
			else
				RemotesFolder.CaptionClient:Fire("[WeLovePotet] " .. Text)
			end
		end
		local QueueTeleport = queue_on_teleport or queueonteleport
		QueueTeleport([=[loadstring(game:HttpGet("https://raw.githubusercontent.com/HG-Papryka/RobloxScript/refs/heads/main/Doors/deathfarm/script.lua"))()]=])
		SendCaption("Joining a run...")
		RemotesFolder.CreateElevator:FireServer({
			Mods = {},
			Settings = {},
			Destination = "Hotel",
			FriendsOnly = false,
			MaxPlayers = "1"
		})
	]==])
	f.Lobby:FireServer()
	return
end

if game.PlaceId ~= 6839171747 then
	c([==[
		local RemotesFolder = game:GetService("ReplicatedStorage").RemotesFolder
		local function SendCaption(Text)
			if math.random(1, 100000) == 1 then
				Text = "Meow :3"
				task.spawn(function()
					local sfx = Instance.new("Sound")
					sfx.SoundId = "rbxassetid://134881862056957"
					sfx.Volume = 1
					sfx.Parent = game:GetService("SoundService")
					sfx:Play()
					sfx.Ended:Connect(function() sfx:Destroy() end)
				end)
			end
			if firesignal then
				firesignal(RemotesFolder.Caption.OnClientEvent, "[WeLovePotet] " .. Text)
			else
				RemotesFolder.CaptionClient:Fire("[WeLovePotet] " .. Text)
			end
		end
		local QueueTeleport = queue_on_teleport or queueonteleport
		QueueTeleport([=[loadstring(game:HttpGet("https://raw.githubusercontent.com/HG-Papryka/RobloxScript/refs/heads/main/Doors/deathfarm/script.lua"))()]=])
		SendCaption("Joining a run...")
		RemotesFolder.CreateElevator:FireServer({
			Mods = {},
			Settings = {},
			Destination = "Hotel",
			FriendsOnly = false,
			MaxPlayers = "1"
		})
	]==])
	a.TeleportService:Teleport(6516141723)
	return
end

while #g:GetChildren() < 1 or not e.Character do
	task.wait(1)
end

local l = e.PlayerGui:WaitForChild("MainUI", 9e9)

if l:FindFirstChild("ItemShop") then
	l.ItemShop.Visible = false
	f.PreRunShop:FireServer({}, true)
end

task.wait(1)

local m = a.Workspace:FindFirstChild("SkipPrompt", true)
if m then
	fireproximityprompt(m)
end

local n = g:WaitForChild("0", 9e9)
local o = n:WaitForChild("Assets", 9e9)
local p = n:FindFirstChild("Parts")
local q = n:FindFirstChild("RiftSpawn")

local r = {
	o:FindFirstChild("Luggage_Cart_Crouch"),
	o:FindFirstChild("Desk_Bell"),
	p and p:FindFirstChild("FrontDesk"),
	p and p:GetChildren()[52],
	p and p:GetChildren()[51],
	p and p:GetChildren()[50],
	p and p:GetChildren()[49],
	p and p:GetChildren()[48],
	p and p:GetChildren()[46],
	p and p:GetChildren()[53],
}

for _, s in ipairs(r) do
	if s then
		if s:IsA("BasePart") then
			s.CanCollide = false
		end
		for _, t in ipairs(s:GetDescendants()) do
			if t:IsA("BasePart") then
				t.CanCollide = false
			end
		end
	end
end

if q and q:FindFirstChild("Rift") then
	q.Rift:Destroy()
end

for _, s in pairs(o:GetChildren()) do
	if s.Name == "Potted_Plant" then
		local u = s:FindFirstChild("Collision")
		if u then
			u.CanCollide = false
		end
	end
end

local v = 2

local function w(x)
	if not x or not x:IsA("ProximityPrompt") then return end
	if not x:GetAttribute("HoldDuration_Old") then
		x:SetAttribute("HoldDuration_Old", x.HoldDuration)
	end
	if not x:GetAttribute("MaxActivationDistance_Old") then
		x:SetAttribute("MaxActivationDistance_Old", x.MaxActivationDistance)
	end
	x.HoldDuration = 0
	x.MaxActivationDistance = x:GetAttribute("MaxActivationDistance_Old") * v
end

for _, s in ipairs(a.Workspace:GetDescendants()) do
	if s:IsA("ProximityPrompt") then
		w(s)
	end
end

a.Workspace.DescendantAdded:Connect(function(s)
	if s:IsA("ProximityPrompt") then
		task.defer(w, s)
	end
end)

task.spawn(function()
	while task.wait(0.05) do
		local y = e.Character and e.Character:FindFirstChild("HumanoidRootPart")
		if not y then continue end
		for _, x in ipairs(a.Workspace:GetDescendants()) do
			if x:IsA("ProximityPrompt") and x.Enabled then
				local z = x.Parent
				local ab = z and z.Name or ""
				if ab == "KeyObtain" or ab == "GoldPile" or ab == "Lock" or x.Name == "ModulePrompt" or x.Name == "UnlockPrompt" then
					local ac = z:IsA("BasePart") and z or z:FindFirstChildWhichIsA("BasePart", true)
					if not ac and ab == "KeyObtain" then
						ac = z:FindFirstChild("Hitbox")
					end
					if ac and (y.Position - ac.Position).Magnitude <= x.MaxActivationDistance then
						fireproximityprompt(x)
					end
				end
			end
		end
	end
end)

local ad = {}
ad.a1 = function(ae)
	local af = e.Character:WaitForChild("Humanoid", 9e9)
	local ag = false
	local ah = a.RunService.RenderStepped:Connect(function()
		af:MoveTo(ae)
		if e:DistanceFromCharacter(ae) < 8 then
			ag = true
		end
	end)
	while task.wait() do
		if ag then
			ah:Disconnect()
			break
		end
	end
	task.wait()
	return true
end

task.wait(1)

local am = false
task.delay(30, function()
	if not am then
		f.PlayAgain:FireServer()
		c(d)
	end
end)

i("Getting the key...")
local ai = n:FindFirstChild("Door")
ai.Lock.CanCollide = false

if o:FindFirstChild("Light_Fixtures") then
	local aj = o.Light_Fixtures:GetChildren()
	if aj[6] then
		local ak = aj[6]:IsA("BasePart") and aj[6] or aj[6]:FindFirstChildWhichIsA("BasePart", true)
		if ak then
			ad.a1(ak.Position)
		end
	end
end

local al = o:WaitForChild("KeyObtain", 9e9)
ad.a1(al.Hitbox.Position)
fireproximityprompt(al:FindFirstChild("ModulePrompt", true))

i("Got the key, opening the door...")
ad.a1(ai.Lock.Position)
fireproximityprompt(ai:FindFirstChild("UnlockPrompt", true))

while not g:FindFirstChild("2") do
	task.wait()
end

if replicatesignal then
	replicatesignal(e.Kill)
else
	i("Please wait around 20 seconds to die")
	f.Underwater:FireServer(true)
end

e:GetAttributeChangedSignal("Alive"):Wait()
am = true

f.PlayAgain:FireServer()
c(d)
