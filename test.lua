--[[
    PotatoMod — Universal FPS Booster
    by potet
    ──────────────────────────────────────────────────────────────────
    OPTIONS (paste ABOVE the script):

    _G.PotetMod = 1     -- 1 = Polygon (playable), 2 = Ugly (farming), 3 = Void (AFK max fps)
    _G.fpsCap   = 1e6   -- fps cap, 1e6 = unlimited

    MODE 1 — Polygon
        Blocky/polygon look, no shadows/particles/post effects.
        Other players untouched. UI untouched. Camera untouched.

    MODE 2 — Ugly
        Mode 1 + flat color, textures stripped, accessories gone,
        remote animations stopped, FOV 30. UI degraded (not hidden).

    MODE 3 — Void
        Mode 2 + world invisible (except Collectibles + your char),
        all UI disabled, scriptable cam overhead FOV 1.

    Only visual changes. No physics. No collision. No anchoring.
    ──────────────────────────────────────────────────────────────────
]]

_G.PotetMod = _G.PotetMod or 1
_G.fpsCap   = _G.fpsCap   or 1e6

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

local ME         = Players.LocalPlayer
local LVL        = _G.PotetMod
local IS_BSS     = game.PlaceId == 1537690962
local FLAT_COLOR = Color3.fromRGB(163, 162, 165)
local PARTICLES  = {"ParticleEmitter","Trail","Smoke","Fire","Sparkles"}

local function IsOtherChar(inst)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= ME and p.Character and inst:IsDescendantOf(p.Character) then
            return true
        end
    end
    return false
end

local function IsProtectedDecal(inst)
    if not IS_BSS then return false end
    if not (inst:IsA("Decal") or inst:IsA("Texture")) then return false end
    local col = workspace:FindFirstChild("Collectibles")
    return col ~= nil and inst:IsDescendantOf(col)
end

pcall(function()
    if setfpscap then setfpscap(_G.fpsCap) end
end)

pcall(function()
    Lighting.GlobalShadows  = false
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd         = 9e9
    Lighting.FogStart       = 9e9
end)

pcall(function()
    settings().Rendering.QualityLevel        = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    settings().Rendering.EagerBulkExecution  = true
end)

pcall(function()
    for _, v in pairs(MaterialService:GetChildren()) do v:Destroy() end
    MaterialService.Use2022Materials = false
end)

pcall(function()
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterWaveSize     = 0
        t.WaterWaveSpeed    = 0
        t.WaterReflectance  = 0
        t.WaterTransparency = 0
        t.Decoration        = false
    end
end)

pcall(function()
    workspace.GlobalWind = Vector3.new(0, 0, 0)
end)

local function OptimizeMode1(inst)
    if IsOtherChar(inst) then return end
    if IsProtectedDecal(inst) then return end
    if inst:IsDescendantOf(Players) and not inst:IsDescendantOf(ME.Backpack) then return end

    if inst:IsA("SpecialMesh") then
        inst:Destroy()

    elseif inst:IsA("DataModelMesh") then
        inst:Destroy()

    elseif inst:IsA("FaceInstance") then
        inst.Transparency = 1
        inst.Shiny        = 0

    elseif inst:IsA("ShirtGraphic") then
        inst.Graphic = ""

    elseif table.find(PARTICLES, inst.ClassName) then
        pcall(function() inst.Enabled = false end)

    elseif inst:IsA("PostEffect") then
        inst.Enabled = false

    elseif inst:IsA("Explosion") then
        inst.BlastPressure = 0
        inst.BlastRadius   = 0
        inst.Visible       = false

    elseif inst:IsA("Sound") then
        inst.Volume = 0
        inst:Stop()

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
        pcall(function() inst.CastShadow = false end)

    elseif inst:IsA("BasePart") then
        inst.Material       = Enum.Material.Plastic
        inst.Reflectance    = 0
        inst.RenderFidelity = Enum.RenderFidelity.Automatic
        pcall(function() inst.CastShadow = false end)

    elseif inst:IsA("Model") then
        inst.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled

    elseif inst:IsA("Sky") or inst:IsA("Atmosphere") then
        inst:Destroy()

    elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
        inst.Enabled = false

    elseif inst:IsA("SelectionBox") or inst:IsA("SelectionSphere") then
        inst:Destroy()

    elseif inst:IsA("BoxHandleAdornment") or inst:IsA("SphereHandleAdornment")
        or inst:IsA("ConeHandleAdornment") or inst:IsA("CylinderHandleAdornment")
        or inst:IsA("LineHandleAdornment") or inst:IsA("ImageHandleAdornment") then
        inst:Destroy()
    end
end

local function OptimizeMode2Extra(inst)
    if IsProtectedDecal(inst) then return end

    if inst:IsA("BasePart") or inst:IsA("MeshPart") then
        inst.Color = FLAT_COLOR
        pcall(function() inst.TextureID = "" end)

    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        inst.Transparency = 1

    elseif inst:IsA("Clothing") or inst:IsA("SurfaceAppearance") or inst:IsA("BaseWrap") then
        inst:Destroy()

    elseif inst:IsA("VideoFrame") then
        inst:Destroy()

    elseif inst:IsA("Sound") then
        inst:Destroy()

    elseif inst:IsA("Animation") then
        inst:Destroy()

    elseif inst:IsA("AnimationController") then
        local anim = inst:FindFirstChildOfClass("Animator")
        if anim then
            pcall(function()
                for _, track in pairs(anim:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end)
        end

    elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
        inst.Image            = ""
        inst.BackgroundColor3 = Color3.new(0, 0, 0)

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

local function OptimizeMode2(inst)
    OptimizeMode1(inst)
    OptimizeMode2Extra(inst)
end

local function StripPlayer(char)
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
            v.Color       = FLAT_COLOR
            pcall(function() v.CastShadow = false end)
        end
    end
end

local function FreezeAnims(char)
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local anim = hum and hum:FindFirstChildOfClass("Animator")
    if anim then
        pcall(function()
            for _, track in pairs(anim:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end)
    end
end

local function HideChar(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.Transparency = 1 end)
        end
    end
end

local function NukeLighting()
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

local function NukeSound()
    pcall(function()
        SoundService.AmbientReverb  = Enum.ReverbType.NoReverb
        SoundService.DistanceFactor = 1e9
        SoundService.RolloffScale   = 0
    end)
end

if LVL == 1 then

    task.spawn(function()
        for _, v in pairs(game:GetDescendants()) do pcall(OptimizeMode1, v) end
    end)
    game.DescendantAdded:Connect(function(v)
        pcall(OptimizeMode1, v)
    end)

elseif LVL == 2 then

    NukeLighting()
    NukeSound()

    task.spawn(function()
        for _, v in pairs(game:GetDescendants()) do pcall(OptimizeMode2, v) end
    end)
    game.DescendantAdded:Connect(function(v)
        pcall(OptimizeMode2, v)
    end)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= ME then
            pcall(StripPlayer, p.Character)
            pcall(FreezeAnims, p.Character)
            p.CharacterAdded:Connect(function(c)
                task.wait(0.5)
                pcall(StripPlayer, c)
                pcall(FreezeAnims, c)
            end)
        end
    end

    workspace.CurrentCamera.FieldOfView = 30

    pcall(function() workspace.SignalBehavior   = Enum.SignalBehavior.Immediate end)
    pcall(function() workspace.StreamingEnabled = false end)
    pcall(function() workspace:SetAttribute("StreamingMinRadius", 0) end)

    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,       false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,     false)
    end)

elseif LVL == 3 then

    NukeLighting()
    NukeSound()

    task.spawn(function()
        for _, v in pairs(game:GetDescendants()) do pcall(OptimizeMode2, v) end
    end)

    task.spawn(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function() v.Transparency = 1 end)
            end
        end
    end)

    game.DescendantAdded:Connect(function(v)
        pcall(OptimizeMode2, v)
        if v:IsA("BasePart") then
            pcall(function() v.Transparency = 1 end)
        end
    end)

    pcall(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then t.Transparency = 1 end
    end)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= ME then
            pcall(StripPlayer, p.Character)
            pcall(FreezeAnims, p.Character)
            pcall(HideChar, p.Character)
            p.CharacterAdded:Connect(function(c)
                task.wait(0.5)
                pcall(StripPlayer, c)
                pcall(FreezeAnims, c)
                pcall(HideChar, c)
            end)
        end
    end

    for _, sg in pairs(ME.PlayerGui:GetChildren()) do
        if sg:IsA("ScreenGui") then sg.Enabled = false end
    end
    ME.PlayerGui.ChildAdded:Connect(function(sg)
        if sg:IsA("ScreenGui") then sg.Enabled = false end
    end)

    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
    pcall(function() UserInputService.MouseIconEnabled = false end)

    pcall(function() workspace.SignalBehavior   = Enum.SignalBehavior.Immediate end)
    pcall(function() workspace.StreamingEnabled = false end)
    pcall(function() workspace:SetAttribute("StreamingMinRadius", 0) end)

    local cam = workspace.CurrentCamera
    cam.FieldOfView  = 1
    cam.HeadLocked   = false
    pcall(function() cam.CameraSubject = nil end)

    RunService.RenderStepped:Connect(function()
        local root = ME.Character and ME.Character:FindFirstChild("HumanoidRootPart")
        if root then
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(
                root.Position + Vector3.new(0, 5, 0),
                root.Position + Vector3.new(0, 5 + 999, 0)
            )
        end
    end)

end
