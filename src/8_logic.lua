--[[
============================================================
  [8] LOGIC LOOPS (FLOW v8)
  - ESP: setting langsung aktif tanpa OFF-ON Enable Esp
  - Aimbot: smooth + prediction + team check
  - TP: godmode biar ga kena damage
  - Auto Join Team: path fix (Root.PickTeam)
  - Claim Quest: pakai firesignal + filter visible
  - Redeem Code: path fix + firesignal
============================================================
]]

local S = _G.STHAIN
if not S then
    warn("[FLOW] _G.STHAIN nil! Stop logic.")
    return
end

local Config = S.Config
local Utils = S.Utils
local Run = S.Services.Run
local Lighting = S.Services.Lighting
local Cam = S.Cam
local LP = S.LP

print("[FLOW] Logic starting...")

local State = {
    Fly = false, Noclip = false, Invisible = false,
    Fullbright = false, NoFog = false,
    SelfHitbox = false, EnemyHitbox = false,
    ESP = false, TargetLock = false,
}

-- ============================================================
-- GODMODE (buat TP aman)
-- ============================================================
local function godmodeOn()
    local char = Utils.getChar()
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    
    local original = {
        MaxHealth = hum.MaxHealth,
        Health = hum.Health,
    }
    
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end)
    
    local lockConn
    lockConn = Run.Heartbeat:Connect(function()
        if hum and hum.Parent then
            pcall(function()
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end)
        end
    end)
    
    return {
        restore = function()
            if lockConn then lockConn:Disconnect() end
            if hum and hum.Parent then
                pcall(function()
                    hum.MaxHealth = original.MaxHealth
                    hum.Health = math.min(original.Health, original.MaxHealth)
                end)
            end
        end
    }
end

task.spawn(function()
    repeat task.wait(0.1) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    print("[FLOW] Character loaded!")
end)

-- ============================================================
-- MOVEMENT
-- ============================================================
Run.RenderStepped:Connect(function()
    local hum = Utils.getHum()
    if not hum then return end
    local mv = Config.Movement
    pcall(function()
        if mv.WalkSpeed and mv.WalkSpeed > 0 then
            hum.WalkSpeed = mv.WalkSpeed
        end
        if mv.HipHeight and mv.HipHeight >= 0 then
            hum.HipHeight = mv.HipHeight
        end
        if mv.JumpPower and mv.JumpPower > 0 then
            hum.UseJumpPower = true
            hum.JumpPower = mv.JumpPower
        end
    end)
end)

-- ============================================================
-- NOCLIP
-- ============================================================
local noclipOriginal = {}
local function cleanupNoclip()
    for part, origVal in pairs(noclipOriginal) do
        if part and part.Parent then
            pcall(function() part.CanCollide = origVal end)
        end
    end
    noclipOriginal = {}
end

Run.Heartbeat:Connect(function()
    local char = Utils.getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if Config.Movement.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if noclipOriginal[part] == nil then
                    noclipOriginal[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
        State.Noclip = true
    elseif State.Noclip then
        cleanupNoclip()
        hrp.CanCollide = true
        State.Noclip = false
    end
end)

-- ============================================================
-- FLY
-- ============================================================
local flyConn, flyBV, flyBG = nil, nil, nil
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local hrp = Utils.getHRP()
    if hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CanCollide = true
    end
    local hum = Utils.getHum()
    if hum then pcall(function() hum.PlatformStand = false end) end
end

local function startFly()
    stopFly()
    local hrp = Utils.getHRP()
    local hum = Utils.getHum()
    if not (hrp and hum) then return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 10000
    flyBG.D = 100
    flyBG.Parent = hrp
    flyConn = Run.RenderStepped:Connect(function()
        if not Config.Movement.Fly then return end
        local hrp2 = Utils.getHRP()
        local hum2 = Utils.getHum()
        if not (hrp2 and hum2 and flyBV and flyBG) then return end
        flyBG.CFrame = Cam.CFrame
        local camCF = Cam.CFrame
        local moveDir = hum2.MoveDirection
        local finalDir = Vector3.zero
        if moveDir.Magnitude > 0.1 then
            finalDir = camCF.LookVector * moveDir.Z + camCF.RightVector * moveDir.X
        end
        flyBV.Velocity = finalDir * Config.Movement.FlySpeed
    end)
end

task.spawn(function()
    while task.wait(0.3) do
        if Config.Movement.Fly and not State.Fly then
            startFly(); State.Fly = true
        elseif not Config.Movement.Fly and State.Fly then
            stopFly(); State.Fly = false
        end
    end
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
task.spawn(function()
    while task.wait(0.1) do
        if Config.Movement.InfJump then
            local hum = Utils.getHum()
            if hum then
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
            end
        end
    end
end)

-- ============================================================
-- ANTI-STUN
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if Config.Combat.AntiStun then
            local hum = Utils.getHum()
            if hum then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end)
            end
        end
    end
end)

-- ============================================================
-- AUTO ATTACK / RUSH
-- ============================================================
local atkTimer, rushTimer = 0, 0
task.spawn(function()
    while task.wait(0.1) do
        local now = tick()
        local hum = Utils.getHum()
        if not hum then continue end
        local moving = hum.MoveDirection.Magnitude > 0.1
        if Config.Combat.AutoAttack and not moving and now - atkTimer >= Config.Combat.AttackDelay then
            atkTimer = now
            Utils.sendKey(Enum.KeyCode.V, 0.05)
        end
        if Config.Combat.AutoRush and not moving and now - rushTimer >= Config.Combat.RushDelay then
            rushTimer = now
            Utils.sendKey(Enum.KeyCode.B, 0.05)
        end
    end
end)

-- ============================================================
-- KILL AURA
-- ============================================================
local killAuraCD = 0
task.spawn(function()
    while task.wait(0.1) do
        if Config.Combat.KillAura then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end
            local nearest, nearestDist = nil, Config.Combat.KillAuraRange
            for _, model in pairs(workspace:GetChildren()) do
                if model == char or not model:IsA("Model") then continue end
                local mhum = model:FindFirstChildOfClass("Humanoid")
                if not mhum or mhum.Health <= 0 then continue end
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if not thrp then continue end
                local dist = (thrp.Position - hrp.Position).Magnitude
                if dist < 5 then continue end
                if dist < nearestDist then
                    nearest = thrp
                    nearestDist = dist
                end
            end
            if nearest then
                if tick() - killAuraCD >= 0.3 then
                    killAuraCD = tick()
                    Utils.sendKey(Enum.KeyCode.V, 0.05)
                end
            end
        end
    end
end)

-- ============================================================
-- TARGET LOCK (SMOOTH AIMBOT)
-- ============================================================
local aimLock, aimLostAt, aimSmoothCF = nil, 0, nil

local function aimAlive(p)
    if not p.Character then return false end
    local hum = p.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return p.Character:FindFirstChild("Head") ~= nil
end

local function aimValid(p)
    if not p or not aimAlive(p) then return false end
    if p.Team == LP.Team and p.Team ~= nil then return false end
    local part = p.Character:FindFirstChild("Head")
    if not part then return false end
    local d = (part.Position - Cam.CFrame.Position).Magnitude
    if d > 500 then return false end
    return true
end

local function aimClosest()
    local best, bd = nil, math.huge
    local ctr = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= LP and aimValid(p) then
            local part = p.Character:FindFirstChild("Head")
            local sp, on = Cam:WorldToViewportPoint(part.Position)
            if on then
                local m = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
                if m < 300 and m < bd then
                    best = p
                    bd = m
                end
            end
        end
    end
    return best
end

local function aimPredict(part)
    local v = part.AssemblyLinearVelocity or Vector3.new()
    return part.Position + (v * 0.18)
end

Run.RenderStepped:Connect(function(dt)
    if not Config.Combat.TargetLock then
        if State.TargetLock then
            aimLock = nil
            aimSmoothCF = nil
            State.TargetLock = false
        end
        return
    end

    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end

    if not aimSmoothCF then aimSmoothCF = Cam.CFrame end

    if aimLock then
        if aimValid(aimLock) then
            -- keep lock
        else
            aimLock = nil
            aimLostAt = tick()
        end
    end
    if not aimLock and (tick() - aimLostAt) >= 0.5 then
        local t = aimClosest()
        if t then aimLock = t end
    end

    if not aimLock then return end

    local part = aimLock.Character and aimLock.Character:FindFirstChild("Head")
    if not part then return end

    local target = CFrame.lookAt(Cam.CFrame.Position, aimPredict(part))
    local a = 1 - math.pow(0.15, dt * 60)
    a = math.clamp(a, 0, 1)

    aimSmoothCF = aimSmoothCF:Lerp(target, a)
    Cam.CFrame = aimSmoothCF
    State.TargetLock = true
end)

LP.CharacterAdded:Connect(function()
    aimSmoothCF = nil
    aimLock = nil
    aimLostAt = 0
end)

-- ============================================================
-- AUTO HEAL
-- ============================================================
local healCD = 0
task.spawn(function()
    while task.wait(0.5) do
        if Config.Combat.AutoHeal then
            local hum = Utils.getHum()
            if hum and hum.Health > 0 then
                local pct = (hum.Health / hum.MaxHealth) * 100
                if pct <= Config.Combat.HealThreshold and tick() - healCD >= 2 then
                    healCD = tick()
                    Utils.sendKey(Enum.KeyCode.H, 0.05)
                end
            end
        end
    end
end)

-- ============================================================
-- INF AMMO
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        if Config.Combat.InfAmmo then
            local char = Utils.getChar()
            if not char then continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local n = string.lower(obj.Name)
                        if n:find("ammo") or n:find("bullet") or n:find("mag") or n:find("clip") or n:find("round") then
                            pcall(function() obj.Value = 999 end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- WEAPON RANGE
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        local char = Utils.getChar()
        if not char then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            if Config.Misc.WeaponRange then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        local n = string.lower(obj.Name)
                        if n:find("range") or n:find("distance") or n:find("reach") then
                            if not obj:GetAttribute("CA_Orig") then
                                obj:SetAttribute("CA_Orig", obj.Value)
                            end
                            local orig = obj:GetAttribute("CA_Orig")
                            pcall(function() obj.Value = orig * Config.Misc.RangeMultiplier end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- ESP (MASTER SWITCH: Chams)
-- ============================================================
local espCache = {}
local espGuiParent = (gethui and gethui()) or game:GetService("CoreGui")

local COLOR_ENEMY = Color3.fromRGB(255, 60, 60)
local COLOR_TEAM = Color3.fromRGB(74, 158, 255)
local COLOR_SUPPLY = Color3.fromRGB(144, 238, 144)

local function isTeammate(model)
    local plr = game.Players:GetPlayerFromCharacter(model)
    if not plr then return false end
    local myTeam = LP:GetAttribute("SelectedTeam") or (LP.Team and LP.Team.Name)
    local theirTeam = plr:GetAttribute("SelectedTeam") or (plr.Team and plr.Team.Name)
    if myTeam and theirTeam then
        return myTeam == theirTeam
    end
    return false
end

local function cleanupESP()
    for _, objs in pairs(espCache) do
        for _, obj in pairs(objs) do
            if obj then pcall(function() obj:Destroy() end) end
        end
    end
    espCache = {}
end

task.spawn(function()
    while task.wait(0.25) do
        local masterOn = Config.Visual.Chams
        
        if not masterOn then
            if next(espCache) then cleanupESP() end
        else
            local myChar = Utils.getChar()
            local cam = workspace.CurrentCamera
            local myHRP = Utils.getHRP()
            
            -- ============================================
            -- ESP PLAYER
            -- ============================================
            for _, model in pairs(workspace:GetChildren()) do
                if model == myChar or not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                
                local isTeam = isTeammate(model)
                local markerColor = isTeam and COLOR_TEAM or COLOR_ENEMY
                
                -- Init cache kalau belum ada
                if not espCache[model] then
                    espCache[model] = {}
                    espCache[model].isTeam = isTeam
                    
                    -- Chams (Highlight)
                    local hl = Instance.new("Highlight")
                    hl.Name = "CA_ESP_HL"
                    hl.FillColor = markerColor
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Adornee = model
                    hl.Parent = espGuiParent
                    espCache[model].hl = hl
                end
                
                local anySetting = Config.Visual.ESPShowDistance 
                    or Config.Visual.ESPHealth 
                    or Config.Visual.ESPName
                
                -- Bikin BillboardGui kalau setting ON tapi belum ada
                if anySetting and not espCache[model].infoBB then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "CA_ESP_Info"
                    bb.Size = UDim2.new(0, 200, 0, 24)
                    bb.StudsOffset = Vector3.new(0, 3.5, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp
                    bb.Parent = espGuiParent
                    
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.Text = ""
                    lbl.TextColor3 = markerColor
                    lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.TextSize = 13
                    lbl.Font = Enum.Font.GothamBold
                    lbl.BackgroundTransparency = 1
                    lbl.Parent = bb
                    
                    espCache[model].infoBB = bb
                    espCache[model].infoLbl = lbl
                end
                
                -- Destroy BillboardGui kalau setting OFF semua
                if not anySetting and espCache[model].infoBB then
                    pcall(function() espCache[model].infoBB:Destroy() end)
                    espCache[model].infoBB = nil
                    espCache[model].infoLbl = nil
                end
                
                -- Update warna Highlight (kalau team berubah)
                local cachedTeam = espCache[model].isTeam
                if cachedTeam ~= isTeam and espCache[model].hl then
                    espCache[model].hl.FillColor = markerColor
                    espCache[model].isTeam = isTeam
                end
                
                -- Update text
                if espCache[model].infoLbl and myHRP then
                    local parts = {}
                    if Config.Visual.ESPName then
                        table.insert(parts, model.Name)
                    end
                    if Config.Visual.ESPHealth then
                        table.insert(parts, "[ "..math.floor(hum.Health).." HP ]")
                    end
                    if Config.Visual.ESPShowDistance then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        table.insert(parts, "[ "..math.floor(dist).." M ]")
                    end
                    espCache[model].infoLbl.Text = table.concat(parts, " ")
                    espCache[model].infoLbl.TextColor3 = markerColor
                end
            end
            
            -- ============================================
            -- ESP OBJECT (Supply + Capture)
            -- ============================================
            local activeMap = workspace:FindFirstChild("ActiveMap")
            if activeMap then
                for _, mapChild in pairs(activeMap:GetChildren()) do
                    if mapChild:IsA("Folder") or mapChild:IsA("Model") then
                        local interactable = mapChild:FindFirstChild("Interactable")
                        if interactable then
                            if Config.Visual.ESPSupply then
                                local suppliesFolder = interactable:FindFirstChild("Supplies")
                                if suppliesFolder then
                                    for _, obj in pairs(suppliesFolder:GetChildren()) do
                                        if obj:IsA("Model") and not espCache[obj] then
                                            espCache[obj] = {}
                                            local hl = Instance.new("Highlight")
                                            hl.Name = "CA_ESP_Supply"
                                            hl.FillColor = COLOR_SUPPLY
                                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            hl.FillTransparency = 0.6
                                            hl.Adornee = obj
                                            hl.Parent = espGuiParent
                                            espCache[obj].hl = hl
                                        end
                                    end
                                end
                            end
                            if Config.Visual.ESPCapture then
                                local pointsFolder = interactable:FindFirstChild("Points")
                                if pointsFolder then
                                    for _, obj in pairs(pointsFolder:GetChildren()) do
                                        if obj:IsA("Model") and not espCache[obj] then
                                            espCache[obj] = {}
                                            local hl = Instance.new("Highlight")
                                            hl.Name = "CA_ESP_Capture"
                                            hl.FillColor = COLOR_SUPPLY
                                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            hl.FillTransparency = 0.6
                                            hl.Adornee = obj
                                            hl.Parent = espGuiParent
                                            espCache[obj].hl = hl
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Cleanup ESP objects yang parent hilang
            for model, objs in pairs(espCache) do
                if not model.Parent then
                    for _, obj in pairs(objs) do
                        if obj then pcall(function() obj:Destroy() end) end
                    end
                    espCache[model] = nil
                end
            end
        end
    end
end)

-- ============================================================
-- FULLBRIGHT / NO FOG
-- ============================================================
local savedLighting = { Brightness=nil, Ambient=nil, OutdoorAmbient=nil, FogEnd=nil, FogStart=nil }
task.spawn(function()
    while task.wait(0.5) do
        if Config.Visual.Fullbright then
            if savedLighting.Brightness == nil then
                savedLighting.Brightness = Lighting.Brightness
                savedLighting.Ambient = Lighting.Ambient
                savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient
            end
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            State.Fullbright = true
        elseif State.Fullbright then
            if savedLighting.Brightness then
                Lighting.Brightness = savedLighting.Brightness
                Lighting.Ambient = savedLighting.Ambient
                Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
                savedLighting.Brightness = nil
            end
            State.Fullbright = false
        end
        if Config.Visual.NoFog then
            if savedLighting.FogEnd == nil then
                savedLighting.FogEnd = Lighting.FogEnd
                savedLighting.FogStart = Lighting.FogStart
            end
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            State.NoFog = true
        elseif State.NoFog then
            if savedLighting.FogEnd then
                Lighting.FogEnd = savedLighting.FogEnd
                Lighting.FogStart = savedLighting.FogStart
                savedLighting.FogEnd = nil
            end
            State.NoFog = false
        end
    end
end)

-- ============================================================
-- INVISIBLE
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        local char = Utils.getChar()
        if not char then continue end
        if Config.Visual.Invisible then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part:GetAttribute("CA_Invis") then
                    part:SetAttribute("CA_Invis", true)
                    part:SetAttribute("CA_OrigTrans", part.Transparency)
                    part.Transparency = 1
                end
            end
            State.Invisible = true
        elseif State.Invisible then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("CA_Invis") then
                    part.Transparency = part:GetAttribute("CA_OrigTrans") or 0
                    part:SetAttribute("CA_Invis", nil)
                    part:SetAttribute("CA_OrigTrans", nil)
                end
            end
            State.Invisible = false
        end
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
task.spawn(function()
    while task.wait(120) do
        if Config.Misc.AntiAFK then
            pcall(function()
                S.Services.VU:CaptureController()
                S.Services.VU:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ============================================================
-- AUTO TP
-- ============================================================
task.spawn(function()
    while task.wait(1) do
        if Config.Misc.AutoTP then
            local char = Utils.getChar()
            local hrp = Utils.getHRP()
            if not (char and hrp) then continue end
            local nearest, nearestDist = nil, Config.Misc.AutoTPRange
            for _, model in pairs(workspace:GetChildren()) do
                if model == char or not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist > 5 and dist < nearestDist then
                        nearest = thrp
                        nearestDist = dist
                    end
                end
            end
            if nearest then
                hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- ============================================================
-- AUTO CLAIM QUEST (FIXED)
-- ============================================================
function _G.STHAIN.ClaimQuests()
    local PG = LP:FindFirstChild("PlayerGui")
    if not PG then return 0 end
    
    -- Buka Quest UI (pakai HUD.RightBar.Quest)
    local root = PG:FindFirstChild("Root")
    if root then
        local hud = root:FindFirstChild("HUD")
        if hud then
            local rightBar = hud:FindFirstChild("RightBar")
            if rightBar then
                local questBtn = rightBar:FindFirstChild("Quest")
                if questBtn then
                    pcall(function()
                        if firesignal then
                            firesignal(questBtn.MouseButton1Click)
                        else
                            questBtn:Activate()
                        end
                    end)
                    task.wait(0.8)
                end
            end
        end
    end
    
    local interactable = root and root:FindFirstChild("Interactable")
    if not interactable then return 0 end
    local questUI = interactable:FindFirstChild("QuestUI")
    if not questUI then return 0 end
    
    local claimed = 0
    local function scanClaim(r, depth)
        if depth > 10 then return end
        for _, c in pairs(r:GetChildren()) do
            if (c:IsA("ImageButton") or c:IsA("TextButton"))
               and c.Name == "Claim"
               and c.Visible
               and c.Parent
               and not c.Parent.Name:find("Template") then
                pcall(function()
                    if firesignal then
                        firesignal(c.MouseButton1Click)
                    else
                        c:Activate()
                    end
                end)
                claimed = claimed + 1
                print(("[FLOW] Claim: %s"):format(c.Parent.Parent.Name))
                task.wait(0.4)
            end
            if c:IsA("Frame") or c:IsA("ScrollingFrame") or c:IsA("CanvasGroup") then
                scanClaim(c, depth + 1)
            end
        end
    end
    
    local list = questUI:FindFirstChild("List")
    if list then scanClaim(list, 0) end
    
    local invUI = interactable:FindFirstChild("InventoryUI")
    if invUI then
        local bpTab = invUI:FindFirstChild("BattlepassTab")
        if bpTab then
            local bpQuest = bpTab:FindFirstChild("Quest")
            if bpQuest then scanClaim(bpQuest, 0) end
        end
    end
    
    -- Tutup Quest UI
    task.wait(0.3)
    local exitBtn = questUI:FindFirstChild("Exit")
    if exitBtn then
        pcall(function()
            if firesignal then
                firesignal(exitBtn.MouseButton1Click)
            else
                exitBtn:Activate()
            end
        end)
    end
    
    print(("[FLOW] Claim Quest done: %d"):format(claimed))
    return claimed
end

-- ============================================================
-- AUTO REDEEM CODE (FIXED)
-- ============================================================
local function ambilCode()
    local url = "https://www.radiotimes.com/technology/gaming/command-an-army-codes/"
    local ok, html = pcall(game.HttpGet, game, url)
    if not ok or not html or #html < 500 then
        warn("[FLOW] Fetch code gagal")
        return {}
    end
    local startPos = html:find("Active codes")
    local endPos = html:find("expired codes")
    if not startPos then return {} end
    local section = html:sub(startPos, endPos or #html)
    local codes = {}
    local seen = {}
    for li in section:gmatch("<li[^>]*>(.-)</li>") do
        local code = li:match("<strong>([A-Z][A-Z0-9]+)</strong>")
            or li:match("^%s*([A-Z][A-Z0-9]+)")
        if code and #code >= 3 and #code <= 20 and not seen[code] then
            seen[code] = true
            table.insert(codes, code)
        end
    end
    print(("[FLOW] Dapet %d code"):format(#codes))
    return codes
end

local function cariCodeUI()
    local PG = LP:FindFirstChild("PlayerGui")
    if not PG then return nil, nil end
    local root = PG:FindFirstChild("Root")
    if not root then return nil, nil end
    local interactable = root:FindFirstChild("Interactable")
    if not interactable then return nil, nil end
    local codeUI = interactable:FindFirstChild("CodeUI")
    if not codeUI then return nil, nil end
    return codeUI:FindFirstChild("TextBox"), codeUI:FindFirstChild("Claim")
end

function _G.STHAIN.RedeemAllCodes()
    local codes = ambilCode()
    if #codes == 0 then warn("[FLOW] Ga ada code") return 0 end
    
    -- Buka CodeUI dulu (kalau ketutup)
    local PG = LP:FindFirstChild("PlayerGui")
    if PG then
        local root = PG:FindFirstChild("Root")
        if root then
            local hud = root:FindFirstChild("HUD")
            if hud then
                local rightBar = hud:FindFirstChild("RightBar")
                if rightBar then
                    local codeBtn = rightBar:FindFirstChild("Code")
                    if codeBtn and codeBtn.Visible then
                        pcall(function()
                            if firesignal then
                                firesignal(codeBtn.MouseButton1Click)
                            else
                                codeBtn:Activate()
                            end
                        end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
    
    local tb, btn = cariCodeUI()
    if not tb then warn("[FLOW] TextBox ga ketemu") return 0 end
    
    local sukses = 0
    for i, code in ipairs(codes) do
        pcall(function()
            tb:CaptureFocus()
            task.wait(0.1)
            tb.Text = code
            task.wait(0.1)
            tb:ReleaseFocus()
        end)
        task.wait(0.3)
        
        local fired = false
        if btn then
            fired = pcall(function()
                if firesignal then
                    firesignal(btn.MouseButton1Click)
                else
                    btn:Activate()
                end
            end)
        end
        
        if fired then
            sukses = sukses + 1
            print(("[FLOW] Code [%d/%d] OK: %s"):format(i, #codes, code))
        else
            print(("[FLOW] Code [%d/%d] FAIL: %s"):format(i, #codes, code))
        end
        task.wait(1.5)
    end
    print(("[FLOW] Redeem done: %d"):format(sukses))
    return sukses
end

-- ============================================================
-- AUTO JOIN TEAM (FIXED PATH)
-- ============================================================
function _G.STHAIN.JoinTeam(teamName)
    local PG = LP:FindFirstChild("PlayerGui")
    if not PG then return false end
    
    -- Cari PickTeam di PlayerGui atau di Root
    local pickTeam = PG:FindFirstChild("PickTeam")
    if not pickTeam then
        local root = PG:FindFirstChild("Root")
        if root then
            pickTeam = root:FindFirstChild("PickTeam")
        end
    end
    
    if not pickTeam then return false end
    if not pickTeam.Visible then return false end
    
    local target = nil
    if teamName == "attacker" then
        target = pickTeam:FindFirstChild("Attacker")
    elseif teamName == "defender" then
        target = pickTeam:FindFirstChild("Defender")
    end
    
    if not target or not target.Visible then return false end
    
    local ok = pcall(function()
        if firesignal then
            firesignal(target.MouseButton1Click)
        else
            target:Activate()
        end
    end)
    
    if ok then
        print("[FLOW] Join request: "..tostring(teamName))
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(2) do
        local team = Config.Misc.AutoJoinTeam
        if team and team ~= "none" then
            local ok = pcall(function() 
                return _G.STHAIN.JoinTeam(team) 
            end)
            if ok == true then
                task.wait(2)
                Config.Misc.AutoJoinTeam = "none"
                print("[FLOW] AutoJoinTeam reset ke none")
            end
        end
    end
end)

-- ============================================================
-- TELEPORT SYSTEM (GODMODE SAFE)
-- ============================================================
local function getMapFolder()
    local activeMap = workspace:FindFirstChild("ActiveMap")
    if not activeMap then return nil end
    for _, child in pairs(activeMap:GetChildren()) do
        if (child:IsA("Folder") or child:IsA("Model")) and child:FindFirstChild("Interactable") then
            return child
        end
    end
    return nil
end

function _G.STHAIN.TeleportScan()
    local results = { supplies = {}, captures = {} }
    local mapFolder = getMapFolder()
    if not mapFolder then return results end
    local interactable = mapFolder:FindFirstChild("Interactable")
    if not interactable then return results end
    local suppliesFolder = interactable:FindFirstChild("Supplies")
    if suppliesFolder then
        for _, obj in pairs(suppliesFolder:GetChildren()) do
            if obj:IsA("Model") then
                local n = string.lower(obj.Name)
                local teamType = "unknown"
                if n:find("attacker") then teamType = "attacker"
                elseif n:find("defender") then teamType = "defender" end
                table.insert(results.supplies, {name = obj.Name, instance = obj, capturePart = obj:FindFirstChild("CapturePoint"), team = teamType})
            end
        end
    end
    local pointsFolder = interactable:FindFirstChild("Points")
    if pointsFolder then
        for _, obj in pairs(pointsFolder:GetChildren()) do
            if obj:IsA("Model") then
                local cp = obj:FindFirstChild("CapturePoint")
                if cp then
                    table.insert(results.captures, {name = obj.Name, instance = cp, model = obj})
                end
            end
        end
    end
    return results
end

function _G.STHAIN.GetMyTeam()
    local sel = LP:GetAttribute("SelectedTeam")
    if sel then
        local n = string.lower(tostring(sel))
        if n:find("attacker") then return "attacker" end
        if n:find("defender") then return "defender" end
    end
    if LP.Team then
        local n = string.lower(LP.Team.Name)
        if n:find("attacker") then return "attacker" end
        if n:find("defender") then return "defender" end
    end
    return "unknown"
end

function _G.STHAIN.TeleportTo(part)
    local char = Utils.getChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hrp and part) then return false end
    
    local targetPos
    if typeof(part) == "Vector3" then targetPos = part
    else
        if not part.Parent then return false end
        targetPos = part.Position
    end
    local offY = (Config.Teleport and Config.Teleport.OffsetY) or 5
    
    -- Godmode ON
    local god = godmodeOn()
    
    -- Reset velocity
    pcall(function()
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    
    -- TP
    pcall(function() 
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, offY, 0)) 
    end)
    
    -- Tunggu sync
    task.wait(0.5)
    
    -- Reset velocity lagi
    pcall(function()
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    
    -- Godmode OFF
    task.wait(0.5)
    if god then god.restore() end
    
    return true
end

function _G.STHAIN.TeleportToEnemySupply()
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then return false end
    local results = _G.STHAIN.TeleportScan()
    local enemyTeam = (myTeam == "attacker") and "defender" or "attacker"
    local enemySupplies = {}
    for _, sup in ipairs(results.supplies) do
        if sup.team == enemyTeam then table.insert(enemySupplies, sup) end
    end
    if #enemySupplies == 0 then return false end
    if not _G.STHAIN._tpSupplyIndex then _G.STHAIN._tpSupplyIndex = 0 end
    _G.STHAIN._tpSupplyIndex = _G.STHAIN._tpSupplyIndex + 1
    if _G.STHAIN._tpSupplyIndex > #enemySupplies then _G.STHAIN._tpSupplyIndex = 1 end
    local target = enemySupplies[_G.STHAIN._tpSupplyIndex]
    _G.STHAIN.TeleportTo(target.capturePart or target.instance)
    print("[FLOW] TP Enemy supply:", target.name)
    return true
end

function _G.STHAIN.TeleportToOwnSupply()
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then return false end
    local results = _G.STHAIN.TeleportScan()
    for _, sup in ipairs(results.supplies) do
        if sup.team == myTeam then
            _G.STHAIN.TeleportTo(sup.capturePart or sup.instance)
            return true
        end
    end
    return false
end

function _G.STHAIN.TeleportToNearestCapture()
    local hrp = Utils.getHRP()
    if not hrp then return false end
    local results = _G.STHAIN.TeleportScan()
    local nearest, nd = nil, math.huge
    for _, cap in ipairs(results.captures) do
        if cap.instance and cap.instance.Parent then
            local d = (cap.instance.Position - hrp.Position).Magnitude
            if d < nd then nearest = cap nd = d end
        end
    end
    if nearest then _G.STHAIN.TeleportTo(nearest.instance) return true end
    return false
end

local function tpToNamed(name)
    local results = _G.STHAIN.TeleportScan()
    for _, cap in ipairs(results.captures) do
        if string.lower(cap.name) == string.lower(name) then
            _G.STHAIN.TeleportTo(cap.instance)
            return true
        end
    end
    return false
end

function _G.STHAIN.TeleportToBase()
    if tpToNamed("base") then return true end
    if tpToNamed("pointa") then return true end
    if tpToNamed("pointb") then return true end
    return false
end

function _G.STHAIN.TeleportToPointA() return tpToNamed("pointa") end
function _G.STHAIN.TeleportToPointB() return tpToNamed("pointb") end

function _G.STHAIN.TeleportToNearestEnemy()
    local char = Utils.getChar()
    local hrp = Utils.getHRP()
    if not (char and hrp) then return false end
    local nearest, nd = nil, math.huge
    for _, model in pairs(workspace:GetChildren()) do
        if model ~= char and model:IsA("Model") then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local thrp = model:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local d = (thrp.Position - hrp.Position).Magnitude
                    if d > 5 and d < nd then nearest = thrp nd = d end
                end
            end
        end
    end
    if nearest then _G.STHAIN.TeleportTo(nearest) return true end
    return false
end

function _G.STHAIN.TeleportToTeammate()
    local char = Utils.getChar()
    local hrp = Utils.getHRP()
    if not (char and hrp) then return false end
    local myTeam = _G.STHAIN.GetMyTeam()
    if myTeam == "unknown" then return false end
    local nearest, nd = nil, math.huge
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local pTeam = ""
            if player:GetAttribute("SelectedTeam") then
                pTeam = string.lower(tostring(player:GetAttribute("SelectedTeam")))
            elseif player.Team then
                pTeam = string.lower(player.Team.Name)
            end
            if pTeam:find(myTeam) then
                local thrp = player.Character:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local d = (thrp.Position - hrp.Position).Magnitude
                    if d < nd then nearest = thrp nd = d end
                end
            end
        end
    end
    if nearest then _G.STHAIN.TeleportTo(nearest) return true end
    return false
end

-- ============================================================
-- CONFIG SAVE / LOAD / DELETE
-- ============================================================
local CONFIG_FILE = "sthain_config.json"

function _G.STHAIN.SaveConfig()
    if not writefile then return false end
    local ok = pcall(function()
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(_G.STHAIN.Config))
    end)
    return ok
end

function _G.STHAIN.LoadConfig()
    if not readfile then return false end
    local ok, data = pcall(readfile, CONFIG_FILE)
    if ok and data and #data > 0 then
        local ok2, dec = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if ok2 and type(dec) == "table" then
            for k, v in pairs(dec) do _G.STHAIN.Config[k] = v end
            return true
        end
    end
    return false
end

function _G.STHAIN.DeleteConfig()
    if not delfile then return false end
    pcall(function() delfile(CONFIG_FILE) end)
    return true
end

-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    State.Invisible = false
    State.Noclip = false
    State.Fly = false
    if flyConn then stopFly() end
    cleanupESP()
    cleanupNoclip()
end)

print("[FLOW] Logic loaded - v8")
