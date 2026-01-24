-- add skins that missing bc i might not update ts for long long time u can see it in something something yourcharacter.inventory.homer and bart i think
local e = game:GetService("ReplicatedStorage").eventFolders.store.buyItem
local b = {"1M","2D Bart","700k","Bart","Bart Bash","Bart Bash 3D","Beart","Beauty","CPT","Emo","Frozen Bart","Ghost Bart","Jacob Bart","Lisa","MLG Bart","Millhouse","Nerd","Ralph","Realistic","Reverse","Santa Bart","Smarf","Spongebob","The Dud","Witch Bart"}
local h = {"2D Homer","Ao Oni","Apu","Bear","Bootleg","Domer","Fancy Homer","Graggle","Homer","Homero","Marge","Moe","Neddy","Nettspend","Newears","Peter","Reverse","Rhonda","Toemer","Ucha","XRAY","Zomber"}

local allCombinations = {}
for ,n in ipairs(b) do table.insert(allCombinations, {"Bart", n}) end
for ,n in ipairs(h) do table.insert(allCombinations, {"Homer", n}) end

while task.wait() do
    for id = 1, 10000 do
        for ,combo in ipairs(allCombinations) do
            coroutine.wrap(function()
                e:FireServer(combo[1], combo[2], id)
            end)()
        end
    end
end
