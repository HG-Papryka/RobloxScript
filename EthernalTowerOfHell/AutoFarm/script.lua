local player=game.Players.LocalPlayer
local character=player.Character or player.CharacterAdded:Wait()
local hrp=character:WaitForChild("HumanoidRootPart")
local RunService=game:GetService("RunService")
local gearNames={"Toxic Wings","Heavenly Orb","Candy Cane Grappling Hook","Heavenly Coil"}
local function equipGear()for _,name in ipairs(gearNames)do local tool=Instance.new("Tool")tool.Name=name tool.Parent=character task.wait(0.2)end end
RunService.Stepped:Connect(function()for _,part in pairs(character:GetDescendants())do if part:IsA("BasePart")then part.CanCollide=false end end end)
local avoid={"ToRoMW","ToTHT","ToBP","ToCaV","ToRT","ToPB","ToHR","ToWWW","ToEMP","TT","ToBT","ToC","ToCA","ToDC","ToDT","ToEH","ToFaCT","ToHA","ToIB","ToIF","ToMB","ToPZ","ToRER","ToTL","ToUH","ToAAA","ToAE","ToBK","ToEI","ToFM","ToHH","ToSM","ToSO","ToTB","ToTDA","ToWF","ToAR","ToFN","ToI","ToIM","ToMM","ToNS","ToUA","ToAM","ToCP","ToCR","ToDIE","ToER","ToGF"}
local towersFolder=game.Workspace:FindFirstChild("Towers")
local teleportersFolder=game.Workspace:FindFirstChild("Teleporters")
local winpadFolder=game.Workspace:FindFirstChild("WinPads",true)
local restartBricks={}
for _,obj in pairs(game.Workspace:GetDescendants())do if obj:IsA("BasePart")and obj.Name=="RestartBrick"then table.insert(restartBricks,obj)end end
local remoteBasePos=Vector3.new(9999,9999,9999)
local spread=30
local allWinpads={}
local index=0
for _,pad in ipairs(winpadFolder:GetChildren())do if pad:IsA("BasePart")then local offset=Vector3.new((index%10)*spread,0,math.floor(index/10)*spread)pad.CFrame=CFrame.new(remoteBasePos+offset)table.insert(allWinpads,pad)index+=1 end end
task.wait(0.5)
for _,tower in ipairs(towersFolder:GetChildren())do if not table.find(avoid,tower.Name)then local teleporter=teleportersFolder:FindFirstChild(tower.Name)if teleporter and teleporter:FindFirstChild("Teleporter")and teleporter.Teleporter:FindFirstChild("TPFRAME")then character:SetPrimaryPartCFrame(teleporter.Teleporter.TPFRAME.CFrame)task.wait(0.75)equipGear()task.wait(1)for _=1,3 do for _,pad in ipairs(allWinpads)do hrp.CFrame=pad.CFrame*CFrame.new(0,1,0)task.wait()end end task.wait(2)for _,rb in ipairs(restartBricks)do character:SetPrimaryPartCFrame(rb.CFrame)
task.wait(3) --here change it if u shit laggy
end
game:GetService("StarterGui"):SetCore("SendNotification",{Title="By Potet/ChatGPT",Text=tower.Name.." Done!",Duration=4})
character=player.Character or player.CharacterAdded:Wait()
hrp=character:WaitForChild("HumanoidRootPart")
end end end
-- it might be very outdated so dont exepect much 07/07/2025
