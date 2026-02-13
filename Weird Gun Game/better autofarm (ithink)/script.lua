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

local COLOR1 = Color3.fromHex("447294")
local COLOR2 = Color3.fromHex("8fbcdb")
local COLOR3 = Color3.fromHex("f4d6bc")

local gui = Instance.new("ScreenGui")
gui.Name = "FarmStatusGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 110)
frame.Position = UDim2.new(0.5, -200, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local mainLabel = Instance.new("TextLabel")
mainLabel.Size = UDim2.new(1, 0, 0.6, 0)
mainLabel.Position = UDim2.new(0, 0, 0.02, 0)
mainLabel.BackgroundTransparency = 1
mainLabel.Text = "Potetium+"
mainLabel.TextColor3 = COLOR1
mainLabel.Font = Enum.Font.GothamBold
mainLabel.TextSize = 48
mainLabel.ZIndex = 2
mainLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0.3, 0)
statusLabel.Position = UDim2.new(0, 10, 0.67, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusLabel.Text = "status: initializing..."
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

clickDetector.MouseButton1Click:Connect(funct
