local RS = game:GetService("ReplicatedStorage")
local TroopPlace = RS:WaitForChild("Events"):WaitForChild("TroopPlace")
local recorded = {}

local WATCHED = {
    ["Chef"]=true,["Hotdog Frank"]=true,["Volt"]=true,["Yasuke"]=true,
    ["Mako"]=true,["Wizard"]=true,["Scientist"]=true,["Fracture"]=true,
    ["Bunny"]=true,["Beebo"]=true,["Voca"]=true,["Branch"]=true,
    ["Wafer"]=true,["Keith"]=true,["Sparks Kilowatt"]=true,["Soda Pop"]=true,
    ["Quinn"]=true,["Lure"]=true,["Slime King"]=true,["Kart Kid"]=true,
    ["Jester"]=true,["Hayes"]=true,["Buzzer"]=true,["Oddport"]=true,
    ["Stella"]=true,["El Goblino"]=true,["Nuki Launcher"]=true,["Byte"]=true,
    ["Dumpster Child"]=true,["Lemonade Cat"]=true,["Maitake"]=true,
    ["Spectre"]=true,["Balloon Pal"]=true,["Discount Dog"]=true,
}

local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0.25, 0, 0.3, 0)
frame.Position = UDim2.new(0.375, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local out = Instance.new("TextBox", frame)
out.Size = UDim2.new(1, -10, 0.8, 0)
out.Position = UDim2.new(0, 5, 0, 5)
out.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
out.TextColor3 = Color3.fromRGB(100, 255, 150)
out.TextSize = 11
out.Font = Enum.Font.Code
out.MultiLine = true
out.TextWrapped = true
out.TextXAlignment = Enum.TextXAlignment.Left
out.TextYAlignment = Enum.TextYAlignment.Top
out.ClearTextOnFocus = false
out.Text = "place towers..."
Instance.new("UICorner", out).CornerRadius = UDim.new(0, 6)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -10, 0.15, 0)
btn.Position = UDim2.new(0, 5, 0.83, 0)
btn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
btn.TextColor3 = Color3.new(1,1,1)
btn.Text = "Copy"
btn.TextScaled = true
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local function rebuild()
    local lines = {"local moves = {"}
    for _, m in ipairs(recorded) do
        table.insert(lines, string.format('    { "%s", %.4f, %.4f, %.4f, %d },', m.name, m.pos.X, m.pos.Y, m.pos.Z, m.rot))
    end
    table.insert(lines, "}")
    out.Text = table.concat(lines, "\n")
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "FireServer" and self == TroopPlace then
        local a = {...}
        if a[1] and WATCHED[a[1].Name] then
            table.insert(recorded, {name=a[1].Name, pos=a[2], rot=a[3] or 0})
            rebuild()
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

btn.MouseButton1Click:Connect(function()
    setclipboard(out.Text)
    btn.Text = "Copied!"
    task.wait(1.5)
    btn.Text = "Copy"
end)
