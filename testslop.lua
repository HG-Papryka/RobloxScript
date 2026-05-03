-- PLATFORM COMMAND
local platformPart = nil
local platformConn = nil

addcmd('platform', {'plat'}, function(args, speaker)
    if platformPart then return notify('Platform', 'Already active, use unplatform to stop') end
    local char = speaker.Character
    if not char then return end
    local hrp = getRoot(char)
    
    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(20, 1, 20)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.CastShadow = false
    platformPart.Material = Enum.Material.SmoothPlastic
    platformPart.BrickColor = BrickColor.new("Medium stone grey")
    platformPart.TopSurface = Enum.SurfaceType.Smooth
    platformPart.Parent = workspace

    platformConn = RunService.Heartbeat:Connect(function()
        if not char or not hrp then return end
        platformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
    end)
    notify('Platform', 'Platform enabled')
end)

addcmd('unplatform', {'unplat'}, function(args, speaker)
    if platformConn then platformConn:Disconnect() platformConn = nil end
    if platformPart then platformPart:Destroy() platformPart = nil end
    notify('Platform', 'Platform disabled')
end)

-- FPS BOOSTER COMMAND
addcmd('fpson', {'boostfps'}, function(args, speaker)
    local cap = tonumber(args[1]) or 60
    pcall(function() setfpscap(cap) end)
    game.Lighting.GlobalShadows = false
    game.Lighting:ClearAllChildren()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") 
        or obj:IsA("Trail") or obj:IsA("Smoke")
        or obj:IsA("Fire") or obj:IsA("Sparkles") then
            pcall(function() obj.Enabled = false end)
        end
    end
    if workspace:FindFirstChild("Particles") then
        workspace.Particles:ClearAllChildren()
    end
    if workspace:FindFirstChild("Clouds") then
        workspace.Clouds:Destroy()
    end
    notify('FPS Booster', 'Boosted! FPS cap: ' .. cap)
end)

addcmd('fpsoff', {'unboostfps'}, function(args, speaker)
    pcall(function() setfpscap(0) end)
    game.Lighting.GlobalShadows = true
    notify('FPS Booster', 'Restored')
end)
