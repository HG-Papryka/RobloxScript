--[[
    FIXES:
    - pq/hi1 queue: DISABLED -> task.defer
    - game.DescendantAdded -> workspace.DescendantAdded
    - hi4 Decal+Texture moved BEFORE FaceInstance (bug: decals got transparency=1 instead of Destroy)
    - hi4 MeshPart: +Transparency = 1
    - hi4 BasePart: +Transparency = 1
    - transparency loop after hi12: DISABLED (redundant after hi4 fix)
    - PhysicsSteppingMethod: Fixed -> Adaptive
    - RunService GetConnections disconnect: DISABLED (breaks engine internals)
    - closeLoadingGui(): standalone function, click anywhere to close
    TOGGLES (_G):
    - _G.cam           = 1          -- 1=normal  2=topdown  3=firstperson
    - _G.Gui           = false       -- true = keep game GUI visible
    - _G.fpsCap        = 1e6        -- fps cap value
    - _G.sweepTextures = false       -- periodic texture sweep every 5s (expensive, off by default)
    - _G.sweepLights   = false       -- periodic light sweep every 3s (expensive, off by default)
    - _G.noStreaming   = false       -- force disable workspace streaming (dangerous in streaming games)
]]

_G.cam           = _G.cam                        or 1
_G.Gui           = (_G.Gui ~= nil) and _G.Gui    or false
_G.fpsCap        = _G.fpsCap                     or 1e6
_G.sweepTextures = (_G.sweepTextures ~= nil) and _G.sweepTextures or false
_G.sweepLights   = (_G.sweepLights   ~= nil) and _G.sweepLights   or false
_G.noStreaming   = (_G.noStreaming   ~= nil) and _G.noStreaming   or false

if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local MaterialService  = game:GetService("MaterialService")
local RunService       = game:GetService("RunService")
local SoundService     = game:GetService("SoundService")
local StarterGui       = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local bye1 = Players.LocalPlayer
local bye2 = game.PlaceId == 1537690962
local bye3 = Color3.fromRGB(163, 162, 165)
local bye4 = {"ParticleEmitter","Trail","Smoke","Fire","Sparkles"}
local bye5 = workspace.CurrentCamera

local bye8, bye9

--[[
local pq  = {}
local pqr = false

local function hi1(fn, inst)
    table.insert(pq, {fn, inst})
    if pqr then return end
    pqr = true
    task.spawn(function()
        while #pq > 0 do
            local batch = pq
            pq = {}
            for _, item in pairs(batch) do
                pcall(item[1], item[2])
            end
            task.wait()
        end
        pqr = false
    end)
end
]]

local function hi2(inst)
    if not bye2 then return false end
    if not (inst:IsA("Decal") or inst:IsA("Texture")) then return false end
    local col = workspace:FindFirstChild("Collectibles")
    return col ~= nil and inst:IsDescendantOf(col)
end

local function hi3(inst)
    return inst:IsDescendantOf(bye1.PlayerGui)
        or inst:IsA("ScreenGui") or inst:IsA("BillboardGui") or inst:IsA("SurfaceGui")
        or inst:IsA("Frame") or inst:IsA("ScrollingFrame") or inst:IsA("ViewportFrame")
        or inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")
        or inst:IsA("ImageLabel") or inst:IsA("ImageButton")
        or inst:IsA("UIStroke") or inst:IsA("UIGradient") or inst:IsA("UICorner")
        or inst:IsA("UIListLayout") or inst:IsA("UIGridLayout")
        or inst:IsA("UITableLayout") or inst:IsA("UIPageLayout")
        or inst:IsA("UIAspectRatioConstraint") or inst:IsA("UISizeConstraint")
        or inst:IsA("UITextSizeConstraint") or inst:IsA("VideoFrame")
end

local function hi4(inst)
    if not inst or not inst.Parent then return end
    if hi2(inst) then return end
    if _G.Gui and hi3(inst) then return end

    if inst:IsA("SpecialMesh") then
        inst:Destroy()
    elseif inst:IsA("DataModelMesh") then
        inst:Destroy()
    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        inst:Destroy()
    elseif inst:IsA("FaceInstance") then
        inst.Transparency = 1
        inst.Shiny        = 0
    elseif inst:IsA("ShirtGraphic") then
        inst.Graphic = ""
    elseif table.find(bye4, inst.ClassName) then
        pcall(function() inst.Enabled = false end)
    elseif inst:IsA("PostEffect") then
        inst.Enabled = false
    elseif inst:IsA("Explosion") then
        inst.BlastPressure = 0
        inst.BlastRadius   = 0
        inst.Visible       = false
    elseif inst:IsA("Sound") then
        inst:Destroy()
    elseif inst:IsA("BillboardGui") or inst:IsA("SurfaceGui") then
        inst.Enabled = false
    elseif inst:IsA("Beam") then
        inst.Enabled = false
    elseif inst:IsA("Highlight") or inst:IsA("SelectionHighlight") then
        inst:Destroy()
    elseif inst:IsA("ViewportFrame") then
        inst.Visible = false
    elseif inst:IsA("Humanoid") then
        inst.HealthDisplayDistance = 0
        inst.NameDisplayDistance   = 0
        inst.DisplayDistanceType   = Enum.HumanoidDisplayDistanceType.None
    elseif inst:IsA("MeshPart") then
        inst.RenderFidelity = Enum.RenderFidelity.Automatic
        inst.Reflectance    = 0
        inst.Material       = Enum.Material.Plastic
        inst.TextureID      = ""
        inst.Transparency   = 1
        pcall(function() inst.CastShadow = false end)
    elseif inst:IsA("BasePart") then
        inst.Material       = Enum.Material.Plastic
        inst.Reflectance    = 0
        inst.Color          = bye3
        inst.Transparency   = 1
        inst.RenderFidelity = Enum.RenderFidelity.Automatic
        pcall(function() inst.CastShadow = false end)
    elseif inst:IsA("Model") then
        inst.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
    elseif inst:IsA("Sky") or inst:IsA("Atmosphere") then
        inst:Destroy()
    elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
        inst:Destroy()
    elseif inst:IsA("SelectionBox") or inst:IsA("SelectionSphere") then
        inst:Destroy()
    elseif inst:IsA("BoxHandleAdornment") or inst:IsA("SphereHandleAdornment")
        or inst:IsA("ConeHandleAdornment") or inst:IsA("CylinderHandleAdornment")
        or inst:IsA("LineHandleAdornment") or inst:IsA("ImageHandleAdornment") then
        inst:Destroy()
    elseif inst:IsA("Constraint") or inst:IsA("RopeConstraint")
        or inst:IsA("SpringConstraint") or inst:IsA("RodConstraint") then
        pcall(function() inst:Destroy() end)
    elseif inst:IsA("Clothing") or inst:IsA("SurfaceAppearance") or inst:IsA("BaseWrap") then
        inst:Destroy()
    elseif inst:IsA("Animation") then
        inst:Destroy()
    elseif inst:IsA("AnimationController") then
        local an = inst:FindFirstChildOfClass("Animator")
        if an then
            pcall(function()
                for _, t in pairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
            end)
        end
    elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
        inst.Image            = ""
        inst.BackgroundColor3 = Color3.new(0,0,0)
    elseif inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        inst.TextScaled = false
        inst.RichText   = false
        inst.TextSize   = 8
        inst.Font       = Enum.Font.SourceSans
    elseif inst:IsA("UIStroke") or inst:IsA("UIGradient") or inst:IsA("UICorner") then
        inst:Destroy()
    elseif inst:IsA("UIListLayout") or inst:IsA("UIGridLayout")
        or inst:IsA("UITableLayout") or inst:IsA("UIPageLayout") then
        inst:Destroy()
    elseif inst:IsA("UIAspectRatioConstraint") or inst:IsA("UISizeConstraint")
        or inst:IsA("UITextSizeConstraint") then
        inst:Destroy()
    end
end

local function hi5(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Accessory") or v:IsA("Hat") then
            v:Destroy()
        elseif v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            v:Destroy()
        elseif v:IsA("SurfaceAppearance") or v:IsA("BaseWrap") then
            v:Destroy()
        elseif v:IsA("SpecialMesh") then
            v:Destroy()
        elseif v:IsA("BasePart") then
            v.Material    = Enum.Material.Plastic
            v.Reflectance = 0
            v.Color       = bye3
            pcall(function() v.CastShadow = false end)
        end
    end
end

local function hi6(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local an  = hum and hum:FindFirstChildOfClass("Animator")
    if an then
        pcall(function()
            for _, t in pairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
        end)
    end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Animation") or v:IsA("AnimationTrack") then
            pcall(function() v:Destroy() end)
        elseif v:IsA("Animator") then
            pcall(function()
                for _, t in pairs(v:GetPlayingAnimationTracks()) do
                    t:Stop(0)
                    t:Destroy()
                end
            end)
        end
    end
end

local function hi7(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.Transparency = 1 end)
        end
    end
    char.DescendantAdded:Connect(function(v)
        if v:IsA("BasePart") then
            pcall(function() v.Transparency = 1 end)
        end
    end)
end

local function hi8()
    pcall(function()
        Lighting.Technology               = Enum.Technology.Compatibility
        Lighting.Brightness               = 2
        Lighting.Ambient                  = Color3.new(1,1,1)
        Lighting.OutdoorAmbient           = Color3.new(1,1,1)
        Lighting.ClockTime                = 14
        Lighting.GeographicLatitude       = 0
        Lighting.EnvironmentDiffuseScale  = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ExposureCompensation     = 0
        Lighting.ColorShift_Bottom        = Color3.new(0,0,0)
        Lighting.ColorShift_Top           = Color3.new(0,0,0)
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("PostEffect") then
                v:Destroy()
            end
        end
    end)
end

local function hi9()
    pcall(function()
        SoundService.AmbientReverb  = Enum.ReverbType.NoReverb
        SoundService.DistanceFactor = 1e9
        SoundService.RolloffScale   = 0
    end)
end

local function hi10()
    task.spawn(function()
        while true do
            task.wait(5)
            local i = 0
            for _, v in pairs(game:GetDescendants()) do
                if (v:IsA("Decal") or v:IsA("Texture")) and not hi2(v) then
                    pcall(function() v:Destroy() end)
                end
                i += 1
                if i % 100 == 0 then task.wait() end
            end
        end
    end)
end

local function hi11()
    task.spawn(function()
        while true do
            task.wait(3)
            local i = 0
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    pcall(function() v:Destroy() end)
                end
                i += 1
                if i % 100 == 0 then task.wait() end
            end
            pcall(function()
                Lighting.Ambient        = Color3.new(1,1,1)
                Lighting.OutdoorAmbient = Color3.new(1,1,1)
                Lighting.Brightness     = 2
            end)
        end
    end)
end

local function closeLoadingGui()
    if not bye8 then return end
    local sg = bye8
    bye8 = nil
    bye9 = nil
    task.spawn(function()
        pcall(function()
            local bg = sg:FindFirstChildOfClass("Frame")
            if bg then
                for t = 1, 20 do
                    bg.BackgroundTransparency = 0.3 + (0.7 * (t / 20))
                    for _, lbl in pairs(bg:GetChildren()) do
                        if lbl:IsA("TextLabel") then
                            lbl.TextTransparency = t / 20
                        end
                    end
                    task.wait(0.03)
                end
            end
            sg:Destroy()
        end)
    end)
end

local function hi12(fn)
    task.spawn(function()
        local i = 0
        local all = game:GetDescendants()
        for _, v in pairs(all) do
            pcall(fn, v)
            i += 1
            if i % 500 == 0 then
                if bye9 then
                    pcall(function()
                        bye9.Text = "del " .. (v.Name or "???")
                    end)
                end
                task.wait()
            end
        end

        if bye9 then pcall(function() bye9.Text = "done!" end) end
        task.wait(0.3)
        closeLoadingGui()

        if not _G.Gui then
            for _, sg in pairs(bye1.PlayerGui:GetChildren()) do
                if sg:IsA("ScreenGui") and sg.Name ~= "p_load" then
                    sg.Enabled = false
                end
            end
            pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
            pcall(function() UserInputService.MouseIconEnabled = false end)
        end

        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,       false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,     false)
        end)
    end)
end

local function hi13()
    task.spawn(function()
        while true do
            task.wait(30)
            pcall(function() collectgarbage("collect") end)
        end
    end)
end

local function hi14(p)
    if p == bye1 then return end
    pcall(hi5, p.Character)
    pcall(hi6, p.Character)
    pcall(hi7, p.Character)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.1)
        pcall(hi5, c)
        pcall(hi6, c)
        pcall(hi7, c)
    end)
end

local function hi15()
    if not bye2 then return end

    local bye6 = {
        workspace:FindFirstChild("Balloons") and workspace.Balloons:FindFirstChild("FieldBalloons"),
        workspace:FindFirstChild("Bees"),
        workspace:FindFirstChild("Cave"),
        workspace:FindFirstChild("Clouds"),
        workspace:FindFirstChild("Cubs"),
        workspace:FindFirstChild("FieldDecos"),
        workspace:FindFirstChild("Flowers"),
        workspace:FindFirstChild("Frogs"),
        workspace:FindFirstChild("Gates"),
        workspace:FindFirstChild("HiveDeco"),
        workspace:FindFirstChild("Honeycombs"),
        workspace:FindFirstChild("Leaderboards"),
        workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Boundary"),
        workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Fences"),
        workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Walls"),
        workspace:FindFirstChild("Happenings"),
        workspace:FindFirstChild("HivePlatforms"),
        workspace:FindFirstChild("Planters"),
    }

    for _, v in pairs(bye6) do
        if v then pcall(function() v:Destroy() end) end
    end
end

local function hi16(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    local gyro = root:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(0, 1e5, 0)
    gyro.D         = 100
    gyro.P         = 1e4
    gyro.CFrame    = root.CFrame
    gyro.Parent    = root
end

local function hi17()
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name            = "p_load"
        sg.ResetOnSpawn    = false
        sg.DisplayOrder    = 9999
        sg.IgnoreGuiInset  = true
        sg.Parent          = bye1.PlayerGui

        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.fromScale(1, 1)
        bg.Position               = UDim2.fromScale(0, 0)
        bg.BackgroundColor3       = Color3.new(0, 0, 0)
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel        = 0
        bg.Parent                 = sg

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size                   = UDim2.fromScale(1, 1)
        closeBtn.Position               = UDim2.fromScale(0, 0)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Text                   = ""
        closeBtn.ZIndex                 = 10
        closeBtn.Parent                 = bg
        closeBtn.MouseButton1Click:Connect(closeLoadingGui)

        local title = Instance.new("TextLabel")
        title.Size                   = UDim2.new(1, 0, 0, 120)
        title.Position               = UDim2.new(0, 0, 0.25, 0)
        title.BackgroundTransparency = 1
        title.Text                   = "Potetium"
        title.TextColor3             = Color3.fromRGB(58, 100, 214)
        title.Font                   = Enum.Font.GothamBlack
        title.TextScaled             = true
        title.Parent                 = bg

        local loading = Instance.new("TextLabel")
        loading.Size                   = UDim2.new(1, 0, 0, 50)
        loading.Position               = UDim2.new(0, 0, 0.52, 0)
        loading.BackgroundTransparency = 1
        loading.Text                   = "LOADING..."
        loading.TextColor3             = Color3.new(1, 1, 1)
        loading.Font                   = Enum.Font.GothamBold
        loading.TextScaled             = true
        loading.Parent                 = bg

        local status = Instance.new("TextLabel")
        status.Size                   = UDim2.new(0.8, 0, 0, 30)
        status.Position               = UDim2.new(0.1, 0, 0.64, 0)
        status.BackgroundTransparency = 1
        status.Text                   = ""
        status.TextColor3             = Color3.fromRGB(180, 180, 180)
        status.Font                   = Enum.Font.Gotham
        status.TextScaled             = true
        status.Parent                 = bg

        bye8 = sg
        bye9 = status

        task.spawn(function()
            local dots = {"LOADING.", "LOADING..", "LOADING..."}
            local d = 1
            while bye8 do
                pcall(function() loading.Text = dots[d] end)
                d = d % #dots + 1
                task.wait(0.4)
            end
        end)
    end)
end

pcall(function()
    if setfpscap then setfpscap(_G.fpsCap) end
end)

task.wait()

pcall(function()
    Lighting.GlobalShadows  = false
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd         = 9e9
    Lighting.FogStart       = 9e9
end)

task.wait()

pcall(function()
    settings().Rendering.QualityLevel        = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    settings().Rendering.EagerBulkExecution  = true
end)

task.wait()

pcall(function()
    for _, v in pairs(MaterialService:GetChildren()) do v:Destroy() end
    MaterialService.Use2022Materials = false
end)

task.wait()

pcall(function()
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterWaveSize     = 0
        t.WaterWaveSpeed    = 0
        t.WaterReflectance  = 0
        t.WaterTransparency = 0
        t.Decoration        = false
        t.Transparency      = 1
    end
end)

task.wait()

pcall(function()
    workspace.GlobalWind              = Vector3.new(0,0,0)
    workspace.MeshUnionsEnabled       = false
    workspace.PhysicsSteppingMethod   = Enum.PhysicsSteppingMethod.Adaptive
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
    workspace.Gravity                 = 196.2
    workspace.SignalBehavior          = Enum.SignalBehavior.Immediate
    workspace:SetAttribute("LevelOfDetailEnabled", false)
    if _G.noStreaming then
        workspace.StreamingEnabled = false
        workspace:SetAttribute("StreamingMinRadius", 0)
    end
end)

task.wait()

hi8()
task.wait()
hi9()
task.wait()

hi17()
hi12(hi4)

--[[
task.spawn(function()
    local i = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.Transparency = 1 end)
        end
        i += 1
        if i % 100 == 0 then task.wait() end
    end
end)
]]

workspace.DescendantAdded:Connect(function(v)
    if not v or not v.Parent then return end
    task.defer(hi4, v)
    if v:IsA("BasePart") then
        pcall(function() v.Transparency = 1 end)
    end
end)

pcall(hi5, bye1.Character)
bye1.CharacterAdded:Connect(function(c)
    task.wait(0.1)
    pcall(hi5, c)
    if _G.cam == 3 then pcall(hi16, c) end
end)

for _, p in pairs(Players:GetPlayers()) do
    hi14(p)
end

Players.PlayerAdded:Connect(hi14)

bye1.PlayerGui.ChildAdded:Connect(function(sg)
    if not _G.Gui and sg:IsA("ScreenGui") and sg.Name ~= "p_load" then
        if not bye8 then
            sg.Enabled = false
        end
    end
end)

--[[
pcall(function()
    for _, conn in pairs(RunService:GetConnections()) do
        pcall(function() conn:Disconnect() end)
    end
end)
]]

if _G.sweepTextures then hi10() end
if _G.sweepLights   then hi11() end

hi13()
hi15()

if _G.cam == 1 then

    bye5.HeadLocked = false

elseif _G.cam == 2 then

    bye1.CameraMaxZoomDistance = 676767

    RunService.RenderStepped:Connect(function()
        local root = bye1.Character and bye1.Character:FindFirstChild("HumanoidRootPart")
        if root then
            bye5.CameraType = Enum.CameraType.Scriptable
            bye5.CFrame = CFrame.new(
                root.Position + Vector3.new(0, 100, 0),
                root.Position
            )
        end
    end)

elseif _G.cam == 3 then

    bye5.FieldOfView = 10
    bye5.HeadLocked  = false
    pcall(function() bye5.CameraSubject = nil end)

    pcall(hi16, bye1.Character)

    RunService.RenderStepped:Connect(function()
        local root = bye1.Character and bye1.Character:FindFirstChild("HumanoidRootPart")
        if root then
            bye5.CameraType = Enum.CameraType.Scriptable
            bye5.CFrame = CFrame.new(
                root.Position + Vector3.new(0, 5, 0),
                root.Position + Vector3.new(0, 5 + 999, 0)
            )
            local gyro = root:FindFirstChildOfClass("BodyGyro")
            if gyro then
                local flat = Vector3.new(bye5.CFrame.LookVector.X, 0, bye5.CFrame.LookVector.Z)
                if flat.Magnitude > 0 then
                    gyro.CFrame = CFrame.new(root.Position, root.Position + flat)
                end
            end
        end
    end)

end
