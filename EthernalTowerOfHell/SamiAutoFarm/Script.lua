local player=game.Players.LocalPlayer
local character=player.Character or player.CharacterAdded:Wait()
local hrp=character:WaitForChild("HumanoidRootPart")
local RunService=game:GetService("RunService")
local gearNames={"Toxic Wings","Heavenly Orb","Candy Cane Grappling Hook","Heavenly Coil"}
for _,name in ipairs(gearNames)do local tool=Instance.new("Tool")tool.Name=name tool.Parent=character task.wait(0.2)end
task.wait(0.75)
RunService.Stepped:Connect(function()for _,part in pairs(character:GetDescendants())do if part:IsA("BasePart")then part.CanCollide=false end end end)
local winpadFolder=game.Workspace:FindFirstChild("WinPads",true)
if not winpadFolder then return end
local remoteBasePos=Vector3.new(9999,9999,9999)
local movedWinpads={}
local spread=5
local index=0
for _,pad in ipairs(winpadFolder:GetChildren())do if pad:IsA("BasePart")then local offset=Vector3.new((index%10)*spread,0,math.floor(index/10)*spread)pad.CFrame=CFrame.new(remoteBasePos+offset) table.insert(movedWinpads,pad)index+=1 end end
task.wait(0.5)
for _=1,3 do for _,pad in ipairs(movedWinpads)do hrp.CFrame=pad.CFrame*CFrame.new(0,2,0)task.wait()end end
task.wait(2)
local restartBrick=game.Workspace:FindFirstChild("RestartBrick",true)
if restartBrick then character:SetPrimaryPartCFrame(restartBrick.CFrame) end
game:GetService("StarterGui"):SetCore("SendNotification",{Title="Done!",Text="thanks to chatgpt and potet",Duration=2})
