local player = game:GetService("Players").LocalPlayer
local gearFolder = player:WaitForChild("GearFolder")
local shopEvent = player:WaitForChild("PlayerGui"):WaitForChild("InfoMenu"):WaitForChild("ShopUI"):WaitForChild("InfoTab"):WaitForChild("ItemStats"):WaitForChild("Purchase"):WaitForChild("LocalScript"):WaitForChild("BuyEvent")

for _, gear in ipairs(gearFolder:GetChildren()) do
    if gear.Name ~= "Coins" then
        shopEvent:FireServer(gear.Name, gearFolder:WaitForChild("Coins"), -999999999999999999999999999999999)
    end
end
