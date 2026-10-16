local S = _G.STHAIN
if not S then warn("[FLOW] _G.STHAIN nil!") return end

local Config = S.Config
local Utils = S.Utils
local Run = S.Services.Run
local Lighting = S.Services.Lighting
local Cam = S.Cam
local LP = S.LP
local VIM = S.Services.VIM
local VU = S.Services.VU
local UIS = S.Services.UIS
local Players = S.Services.Players
local RS = game:GetService("ReplicatedStorage")

print("[FLOW] Logic starting...")

local State = {
    Fly = false, Noclip = false, Invisible = false,
    Fullbright = false, NoFog = false,
    ESP = false, TargetLock = false,
}

local function getChar() return LP.Character end
local function getHRP() local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = LP.Character return c and c:FindFirstChildOfClass("Humanoid") end

task.spawn(function()
    repeat task.wait(0.1) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    print("[FLOW] Character loaded!")
end)

Run.RenderStepped:Connect(function()
    local hum = getHum()
    if not hum then return end
    local mv = Config.Movement
    pcall(function()
        if mv.WalkSpeed and mv.WalkSpeed > 0 then hum.WalkSpeed = mv.WalkSpeed end
        if mv.HipHeight and mv.HipHeight >= 0 then hum.HipHeight = mv.HipHeight end
        if mv.JumpPower and mv.JumpPower > 0 then
            hum.UseJumpPower = true
            hum.JumpPower = mv.JumpPower
        end
    end)
end)

local noclipOriginal = {}
local function cleanupNoclip()
    for part, orig in pairs(noclipOriginal) do
        if part and part.Parent then
            pcall(function() part.CanCollide = orig end)
        end
    end
    noclipOriginal = {}
end

Run.Heartbeat:Connect(function()
    local char = getChar()
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

local flyConn, flyBV, flyBG = nil, nil, nil
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local hrp = getHRP()
    if hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CanCollide = true
        for _, c in pairs(hrp:GetChildren()) do
            if c:IsA("BodyVelocity") or c:IsA("BodyGyro") or c:IsA("BodyPosition") then
                pcall(function() c:Destroy() end)
            end
        end
    end
    local hum = getHum()
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

local function startFly()
    stopFly()
    local hrp, hum = getHRP(), getHum()
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
        local h, hm = getHRP(), getHum()
        if not (h and hm and flyBV and flyBG) then return end
        flyBG.CFrame = Cam.CFrame
        local d = hm.MoveDirection
        local f = Vector3.zero
        if d.Magnitude > 0.1 then f = Cam.CFrame.LookVector * d.Z + Cam.CFrame.RightVector * d.X end
        flyBV.Velocity = f * Config.Movement.FlySpeed
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

task.spawn(function()
    while task.wait(0.1) do
        if Config.Movement.InfJump then
            local hum = getHum()
            if hum then
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.Combat.AntiStun then
            local hum = getHum()
            if hum then
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end)
            end
        end
    end
end)

local atkTimer, rushTimer, followTimer = 0, 0, 0
task.spawn(function()
    while task.wait(0.1) do
        local now = tick()
        local hum = getHum()
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
        if Config.Combat.AutoFollow and now - followTimer >= Config.Combat.FollowDelay then
            followTimer = now
            Utils.sendKey(Enum.KeyCode.C, 0.05)
        end
    end
end)

local killAuraCD = 0
task.spawn(function()
    while task.wait(0.1) do
        if Config.Combat.KillAura then
            local char = getChar()
            local hrp = getHRP()
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
            if nearest and tick() - killAuraCD >= 0.3 then
                killAuraCD = tick()
                Utils.sendKey(Enum.KeyCode.V, 0.05)
            end
        end
    end
end)

local healCD = 0
task.spawn(function()
    while task.wait(0.5) do
        if Config.Combat.AutoHeal then
            local hum = getHum()
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

local aimLock, aimLostAt, aimSmoothCF = nil, 0, nil
local aimbotConn = nil

local function aimAlive(p)
    if not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return p.Character:FindFirstChild("Head") ~= nil
end

local function aimValid(p)
    if not p or not aimAlive(p) then return false end
    if p.Team == LP.Team and p.Team ~= nil then return false end
    local part = p.Character:FindFirstChild("Head")
    if not part then return false end
    if (part.Position - Cam.CFrame.Position).Magnitude > 500 then return false end
    return true
end

local function aimClosest()
    local best, bd = nil, math.huge
    local ctr = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    local list = Players:GetPlayers()
    for i = 1, #list do
        local p = list[i]
        if p ~= LP and aimValid(p) then
            local part = p.Character:FindFirstChild("Head")
            if part then
                local sp, on = Cam:WorldToViewportPoint(part.Position)
                if on then
                    local dx, dy = sp.X - ctr.X, sp.Y - ctr.Y
                    local m = math.sqrt(dx*dx + dy*dy)
                    if m < 300 and m < bd then best = p bd = m end
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
            if obj and typeof(obj) == "Instance" then
                pcall(function() obj:Destroy() end)
            end
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
            local myChar = getChar()
            local cam = workspace.CurrentCamera
            local myHRP = getHRP()

            for _, model in pairs(workspace:GetChildren()) do
                if model == myChar or not model:IsA("Model") then continue end
                local hum = model:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local isTeam = isTeammate(model)
                local markerColor = isTeam and COLOR_TEAM or COLOR_ENEMY

                if not espCache[model] then
                    espCache[model] = {}
                    espCache[model].isTeam = isTeam
                    local hl = Instance.new("Highlight")
                    hl.Name = "CA_ESP_HL"
                    hl.FillColor = markerColor
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Adornee = model
                    hl.Parent = espGuiParent
                    espCache[model].hl = hl
                end

                local anySetting = Config.Visual.ESPShowDistance or Config.Visual.ESPHealth or Config.Visual.ESPName

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

                if not anySetting and espCache[model].infoBB then
                    pcall(function() espCache[model].infoBB:Destroy() end)
                    espCache[model].infoBB = nil
                    espCache[model].infoLbl = nil
                end

                local cachedTeam = espCache[model].isTeam
                if cachedTeam ~= isTeam and espCache[model].hl then
                    espCache[model].hl.FillColor = markerColor
                    espCache[model].isTeam = isTeam
                end

                if espCache[model].infoLbl and myHRP then
                    local parts = {}
                    if Config.Visual.ESPName then table.insert(parts, model.Name) end
                    if Config.Visual.ESPHealth then table.insert(parts, "[ "..math.floor(hum.Health).." HP ]") end
                    if Config.Visual.ESPShowDistance then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        table.insert(parts, "[ "..math.floor(dist).." M ]")
                    end
                    espCache[model].infoLbl.Text = table.concat(parts, " ")
                    espCache[model].infoLbl.TextColor3 = markerColor
                end
            end

            local activeMap = workspace:FindFirstChild("ActiveMap")
            if activeMap then
                for _, mapChild in pairs(activeMap:GetChildren()) do
                    local inter = mapChild:FindFirstChild("Interactable")
                    if inter then
                        local supplies = inter:FindFirstChild("Supplies")
                        if supplies then
                            for _, obj in pairs(supplies:GetChildren()) do
                                if obj:IsA("Model") then
                                    if Config.Visual.ESPSupply then
                                        if not espCache[obj] then
                                            espCache[obj] = { isObject = true }
                                            local hl = Instance.new("Highlight")
                                            hl.Name = "CA_ESP_Supply"
                                            hl.FillColor = COLOR_SUPPLY
                                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            hl.FillTransparency = 0.6
                                            hl.Adornee = obj
                                            hl.Parent = espGuiParent
                                            espCache[obj].hl = hl
                                        end
                                    else
                                        if espCache[obj] and espCache[obj].isObject then
                                            if espCache[obj].hl then
                                                pcall(function() espCache[obj].hl:Destroy() end)
                                            end
                                            espCache[obj] = nil
                                        end
                                    end
                                end
                            end
                        end
                        local points = inter:FindFirstChild("Points")
                        if points then
                            for _, obj in pairs(points:GetChildren()) do
                                if obj:IsA("Model") then
                                    if Config.Visual.ESPCapture then
                                        if not espCache[obj] then
                                            espCache[obj] = { isObject = true }
                                            local hl = Instance.new("Highlight")
                                            hl.Name = "CA_ESP_Capture"
                                            hl.FillColor = COLOR_SUPPLY
                                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                            hl.FillTransparency = 0.6
                                            hl.Adornee = obj
                                            hl.Parent = espGuiParent
                                            espCache[obj].hl = hl
                                        end
                                    else
                                        if espCache[obj] and espCache[obj].isObject then
                                            if espCache[obj].hl then
                                                pcall(function() espCache[obj].hl:Destroy() end)
                                            end
                                            espCache[obj] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for model, objs in pairs(espCache) do
                if not model.Parent then
                    for _, obj in pairs(objs) do
                        if obj and typeof(obj) == "Instance" then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                    espCache[model] = nil
                end
            end
        end
    end
end)

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

task.spawn(function()
    while task.wait(120) do
        if Config.Misc.AntiAFK then
            pcall(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- SPAWN UNIT
local function getTroopRemote()
    local shared = RS:FindFirstChild("Shared")
    if not shared then return nil end
    local remotes = shared:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("RespawnUnitRequest")
end

function _G.STHAIN.SpawnUnit(slot)
    slot = tonumber(slot) or 1
    if slot < 1 or slot > 4 then slot = 1 end
    local remote = getTroopRemote()
    if not remote then
        print("[FLOW][Spawn] RespawnUnitRequest ga ketemu")
        return false
    end
    local ok = pcall(function()
        remote:FireServer(slot)
    end)
    if ok then
        print("[FLOW][Spawn] Unit slot " .. slot)
        return true
    end
    return false
end

-- AUTO JOIN TEAM (pakai remote)
local function getTeamRemote()
    local shared = RS:FindFirstChild("Shared")
    if not shared then return nil end
    local remotes = shared:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("TeamRequest")
end

function _G.STHAIN.JoinTeam(teamName)
    local remote = getTeamRemote()
    if not remote then
        print("[FLOW][Team] TeamRequest remote ga ketemu")
        return false
    end
    local teamStr = "Attackers"
    if teamName == "defender" or teamName == "Defenders" then
        teamStr = "Defenders"
    end
    local ok = pcall(function()
        remote:FireServer(teamStr)
    end)
    if ok then
        print("[FLOW][Team] Fire: " .. teamStr)
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(1) do
        local team = Config.Misc.AutoJoinTeam
        if team and team ~= "none" then
            local targetName = (team == "defender") and "Defenders" or "Attackers"
            if LP.Team and LP.Team.Name == targetName then
                Config.Misc.AutoJoinTeam = "none"
                print("[FLOW][Team] Udah di tim, reset")
            else
                _G.STHAIN.JoinTeam(team)
            end
        end
    end
end)

-- CLAIM QUEST
function _G.STHAIN.ClaimQuests()
    local PG = LP:FindFirstChild("PlayerGui")
    if not PG then return 0 end
    local hud = PG:FindFirstChild("HUD")
    if hud then
        local rightBar = hud:FindFirstChild("RightBar")
        if rightBar then
            local questBtn = rightBar:FindFirstChild("Quest")
            if questBtn then
                pcall(function()
                    if firesignal then firesignal(questBtn.MouseButton1Click) else questBtn:Activate() end
                end)
                task.wait(1.2)
            end
        end
    end
    local interactable = PG:FindFirstChild("Interactable")
    if not interactable then
        warn("[FLOW][Quest] Interactable ga ketemu")
        return 0
    end
    local questUI = interactable:FindFirstChild("QuestUI")
    if not questUI then
        warn("[FLOW][Quest] QuestUI ga ketemu")
        return 0
    end
    local claimed = 0
    local found = 0
    local function scanClaim(r, depth)
        if depth > 10 then return end
        for _, c in pairs(r:GetChildren()) do
            if c.Name == "Claim" and (c:IsA("ImageButton") or c:IsA("TextButton")) then
                found = found + 1
                if c.Visible then
                    local ok = pcall(function()
                        if firesignal then firesignal(c.MouseButton1Click) else c:Activate() end
                    end)
                    if ok then
                        claimed = claimed + 1
                        print(("[FLOW][Quest] Claim: %s"):format(c.Parent.Parent.Name))
                        task.wait(0.5)
                    end
                end
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
    print(("[FLOW][Quest] Found: %d | Claimed: %d"):format(found, claimed))
    task.wait(0.3)
    local exitBtn = questUI:FindFirstChild("Exit")
    if exitBtn then
        pcall(function()
            if firesignal then firesignal(exitBtn.MouseButton1Click) else exitBtn:Activate() end
        end)
    end
    return claimed
end

-- REDEEM CODE
local function ambilCode()
    local url = "https://www.radiotimes.com/technology/gaming/command-an-army-codes/"
    local ok, html = pcall(game.HttpGet, game, url)
    if not ok or not html or #html < 500 then
        warn("[FLOW][Code] Fetch gagal")
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
    print(("[FLOW][Code] Dapet %d code"):format(#codes))
    return codes
end

local function cariCodeUI()
    local PG = LP:FindFirstChild("PlayerGui")
    if not PG then return nil, nil end
    local interactable = PG:FindFirstChild("Interactable")
    if not interactable then return nil, nil end
    local codeUI = interactable:FindFirstChild("CodeUI")
    if not codeUI then return nil, nil end
    return codeUI:FindFirstChild("TextBox"), codeUI:FindFirstChild("Claim")
end

function _G.STHAIN.RedeemAllCodes()
    local codes = ambilCode()
    if #codes == 0 then return 0 end
    local PG = LP:FindFirstChild("PlayerGui")
    if PG then
        local hud = PG:FindFirstChild("HUD")
        if hud then
            local rightBar = hud:FindFirstChild("RightBar")
            if rightBar then
                local codeBtn = rightBar:FindFirstChild("Code")
                if codeBtn and codeBtn.Visible then
                    pcall(function()
                        if firesignal then firesignal(codeBtn.MouseButton1Click) else codeBtn:Activate() end
                    end)
                    task.wait(1)
                end
            end
        end
    end
    local tb, btn = cariCodeUI()
    if not tb then
        warn("[FLOW][Code] TextBox ga ketemu")
        return 0
    end
    local sukses = 0
    for i, code in ipairs(codes) do
        pcall(function()
            tb:CaptureFocus()
            task.wait(0.15)
            tb.Text = code
            task.wait(0.15)
            tb:ReleaseFocus()
        end)
        task.wait(0.4)
        local fired = false
        if btn then
            fired = pcall(function()
                if firesignal then firesignal(btn.MouseButton1Click) else btn:Activate() end
            end)
        end
        if fired then
            sukses = sukses + 1
            print(("[FLOW][Code] [%d/%d] OK: %s"):format(i, #codes, code))
        else
            print(("[FLOW][Code] [%d/%d] FAIL: %s"):format(i, #codes, code))
        end
        task.wait(1.5)
    end
    print(("[FLOW][Code] Redeem done: %d/%d"):format(sukses, #codes))
    return sukses
end

-- TELEPORT
local function godmodeOn()
    local char = getChar()
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local original = { MaxHealth = hum.MaxHealth, Health = hum.Health }
    local GOD_HP = 1000000
    pcall(function()
        hum.MaxHealth = GOD_HP
        hum.Health = GOD_HP
    end)
    local lockConn = Run.Stepped:Connect(function()
        if hum and hum.Parent then
            pcall(function()
                if hum.MaxHealth < GOD_HP then hum.MaxHealth = GOD_HP end
                if hum.Health < GOD_HP then hum.Health = GOD_HP end
            end)
        end
    end)
    return {
        restore = function()
            if lockConn then lockConn:Disconnect() end
            if hum and hum.Parent then
                pcall(function()
                    hum.MaxHealth = original.MaxHealth
                    hum.Health = original.MaxHealth
                end)
            end
        end
    }
end

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
    local char = getChar()
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
    local god = godmodeOn()
    local savedCollide = {}
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            savedCollide[p] = p.CanCollide
            p.CanCollide = false
        end
    end
    pcall(function()
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    pcall(function()
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, offY, 0))
    end)
    task.wait(1.5)
    pcall(function()
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    task.wait(1)
    for p, cc in pairs(savedCollide) do
        if p and p.Parent then
            pcall(function() p.CanCollide = cc end)
        end
    end
    if god then god.restore() end
    return true
end

function _G.STHAIN.TeleportToSupply(mode)
    mode = mode or "Enemy"
    local hrp = getHRP()
    if not hrp then return false end
    local results = _G.STHAIN.TeleportScan()
    if #results.supplies == 0 then return false end
    local myTeam = _G.STHAIN.GetMyTeam()
    local enemyTeam = (myTeam == "attacker") and "defender" or "attacker"
    local candidates = {}
    for _, sup in ipairs(results.supplies) do
        if mode == "Enemy" and sup.team == enemyTeam then
            table.insert(candidates, sup)
        elseif mode == "Own" and sup.team == myTeam then
            table.insert(candidates, sup)
        elseif mode == "Nearest" then
            table.insert(candidates, sup)
        end
    end
    if #candidates == 0 then
        for _, sup in ipairs(results.supplies) do
            table.insert(candidates, sup)
        end
    end
    if #candidates == 0 then return false end
    local nearest, nd = nil, math.huge
    for _, sup in ipairs(candidates) do
        local part = sup.capturePart or sup.instance
        if part and part.Parent then
            local d = (part.Position - hrp.Position).Magnitude
            if d < nd then
                nearest = sup
                nd = d
            end
        end
    end
    if nearest then
        _G.STHAIN.TeleportTo(nearest.capturePart or nearest.instance)
        print("[FLOW] TP Supply (" .. mode .. "): " .. nearest.name)
        return true
    end
    return false
end

function _G.STHAIN.TeleportToOwnSupply()
    return _G.STHAIN.TeleportToSupply("Own")
end

function _G.STHAIN.TeleportToEnemySupply()
    return _G.STHAIN.TeleportToSupply("Enemy")
end

function _G.STHAIN.TeleportToNearestCapture()
    local hrp = getHRP()
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
    local char = getChar()
    local hrp = getHRP()
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
    local char = getChar()
    local hrp = getHRP()
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

local CONFIG_FILE = "flow_caa_config.json"

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

LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    State.Invisible = false
    State.Noclip = false
    State.Fly = false
    if flyConn then stopFly() end
    cleanupESP()
    cleanupNoclip()
    aimLock = nil
    aimSmoothCF = nil
end)

print("[FLOW] Logic loaded")
