local platformPart = nil
local platformConn = nil

addcmd('platform', {'plat'}, function(args, speaker)
    if platformPart then return notify('Platform', 'Already active, use ;unplatform to stop') end

    -- nuke workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name ~= "Camera" 
        and obj.Name ~= "Terrain" 
        and obj.Name ~= speaker.Name
        and not obj:IsA("Script") then
            pcall(function() obj:Destroy() end)
        end
    end
    pcall(function() workspace.Terrain:Clear() end)

    local char = speaker.Character
    if not char then return notify('Platform', 'No character found') end
    local hrp = getRoot(char)
    if not hrp then return notify('Platform', 'No root found') end

    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(20, 1, 20)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.CastShadow = false
    platformPart.Material = Enum.Material.SmoothPlastic
    platformPart.BrickColor = BrickColor.new("Medium stone grey")
    platformPart.TopSurface = Enum.SurfaceType.Smooth
    platformPart.BottomSurface = Enum.SurfaceType.Smooth
    platformPart.Parent = workspace

    platformConn = RunService.Heartbeat:Connect(function()
        if not char or not hrp then return end
        platformPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
    end)

    notify('Platform', 'Workspace cleared + platform enabled')
end)

addcmd('unplatform', {'unplat', 'noplatform'}, function(args, speaker)
    if platformConn then platformConn:Disconnect() platformConn = nil end
    if platformPart then platformPart:Destroy() platformPart = nil end
    notify('Platform', 'Platform disabled')
end)
