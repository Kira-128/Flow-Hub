--[[
============================================================
  [7] PAGES — Command An Army
  Author  : Cabu
  Version : 1.0
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local pages = {}
local tabs = {}

local function save()
    if _G.STHAIN.SaveConfig then
        task.spawn(_G.STHAIN.SaveConfig)
    end
end

-- ============================================================
-- CREATE PAGE
-- ============================================================
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.ScrollBarImageTransparency = 0.5
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = S.GUI.ContentScroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = page

    pages[name] = page
    return page
end

local function switchPage(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
    S.GUI.ContentTitle.Text = name
end

-- ============================================================
-- MAKE TAB
-- ============================================================
local function makeTab(iconId, name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = ""
    btn.BackgroundColor3 = C.bg2
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = S.GUI.Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local acc = Instance.new("Frame")
    acc.Name = "AccentLine"
    acc.Size = UDim2.new(0, 3, 0, 0)
    acc.Position = UDim2.new(0, 6, 0.5, 0)
    acc.AnchorPoint = Vector2.new(0, 0.5)
    acc.BackgroundColor3 = C.accent
    acc.BorderSizePixel = 0
    acc.Visible = false
    acc.Parent = btn
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)

    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.new(0, 14, 0, 14)
    ic.Position = UDim2.new(0, 16, 0.5, -7)
    ic.BackgroundTransparency = 1
    ic.Image = iconId
    ic.ImageColor3 = C.textDim
    ic.Parent = btn

    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, -40, 1, 0)
    tx.Position = UDim2.new(0, 38, 0, 0)
    tx.Text = name
    tx.TextColor3 = C.textDim
    tx.TextSize = 10
    tx.Font = F.norm
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.BackgroundTransparency = 1
    tx.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = C.bg2
            t.btn.BackgroundTransparency = 1
            t.icon.ImageColor3 = C.textDim
            t.text.TextColor3 = C.textDim
            t.bar.Visible = false
        end
        btn.BackgroundColor3 = C.bg3
        btn.BackgroundTransparency = 0.3
        ic.ImageColor3 = C.accent
        tx.TextColor3 = C.text
        acc.Visible = true
        acc.Size = UDim2.new(0, 3, 0, 0)
        S.Services.TS:Create(acc, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 3, 0, 18)
        }):Play()
        switchPage(name)
    end)

    table.insert(tabs, {btn = btn, icon = ic, text = tx, bar = acc})
end

-- ============================================================
-- CUSTOM DYNAMIC DROPDOWN (buat Supply Target)
-- ============================================================
local function makeDynamicDropdown(parent, name, initialOptions, callback)
    local f = Instance.new("Frame")
    f.Name = "Dropdown_" .. name
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ClipsDescendants = false
    f.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C.text
    lbl.TextSize = 11
    lbl.Font = F.norm
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = f

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0, 130, 0, 22)
    selected.Position = UDim2.new(1, -142, 0.5, -11)
    selected.Text = initialOptions[1] or "None"
    selected.TextColor3 = C.accent
    selected.TextSize = 11
    selected.Font = F.norm
    selected.BackgroundColor3 = C.bg4
    selected.BackgroundTransparency = 0
    selected.BorderSizePixel = 0
    selected.AutoButtonColor = false
    selected.Parent = f
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 4)

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(1, -8, 0, 0)
    popup.Position = UDim2.new(0, 4, 1, 4)
    popup.BackgroundColor3 = C.bg4
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 50
    popup.Parent = f
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 5)

    local popLayout = Instance.new("UIListLayout")
    popLayout.Padding = UDim.new(0, 2)
    popLayout.Parent = popup

    local currentValue = initialOptions[1] or "None"

    local function rebuildOptions(options)
        for _, child in pairs(popup:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -8, 0, 26)
            optBtn.Text = opt
            optBtn.TextColor3 = C.text
            optBtn.TextSize = 11
            optBtn.Font = F.norm
            optBtn.BackgroundColor3 = C.bg4
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 51
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
            optBtn.MouseButton1Click:Connect(function()
                selected.Text = opt
                currentValue = opt
                popup.Visible = false
                pcall(callback, opt)
            end)
        end
        popup.Size = UDim2.new(1, -8, 0, #options * 28 + 4)
    end

    rebuildOptions(initialOptions)

    local isOpen = false
    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        popup.Visible = isOpen
    end)

    return {
        UpdateOptions = function(options)
            -- Cek apakah current value masih ada di options baru
            local stillValid = false
            for _, opt in ipairs(options) do
                if opt == currentValue then stillValid = true break end
            end
            -- Kalau ga valid, ganti ke option pertama
            if not stillValid and #options > 0 then
                currentValue = options[1]
                selected.Text = options[1]
                pcall(callback, options[1])
            end
            rebuildOptions(options)
        end,
        GetValue = function() return currentValue end,
    }
end

-- ============================================================
-- BUAT PAGES + TABS
-- ============================================================
createPage("Combat")
createPage("Esp")
createPage("Teleport")
createPage("Settings")
createPage("Config")

makeTab(I.combat, "Combat")
makeTab(I.visual, "Esp")
makeTab(I.teleport, "Teleport")
makeTab(I.settings, "Settings")
makeTab(I.config, "Config")

-- ============================================================
-- TAB COMBAT — Auto Combat
-- ============================================================
local CC = S.Config.Combat
local SS = S.Config.Spawn

local autoCombat = S.Comp.makeSection(pages["Combat"], "Auto Combat", false)
S.Comp.makeToggle(autoCombat, "Auto Attack (V)", CC.AutoAttack, function(v) CC.AutoAttack = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Rush (B)", CC.AutoRush, function(v) CC.AutoRush = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Follow (C)", CC.AutoFollow, function(v) CC.AutoFollow = v save() end)

-- ============================================================
-- TAB COMBAT — Spawn Unit
-- ============================================================
local spawnSection = S.Comp.makeSection(pages["Combat"], "Spawn Unit", false)
S.Comp.makeDropdown(spawnSection, "Unit Slot", {"1", "2", "3", "4"}, function(v)
    SS.UnitSlot = tonumber(v) or 1
    save()
end)

local spawnBtn = Instance.new("TextButton")
spawnBtn.Name = "SpawnBtn"
spawnBtn.Size = UDim2.new(1, 0, 0, 32)
spawnBtn.BackgroundColor3 = C.bg4
spawnBtn.BackgroundTransparency = 0
spawnBtn.BorderSizePixel = 0
spawnBtn.Text = "Spawn Unit"
spawnBtn.TextColor3 = C.accent
spawnBtn.TextSize = 11
spawnBtn.Font = F.norm
spawnBtn.AutoButtonColor = false
spawnBtn.Parent = spawnSection
Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 6)

spawnBtn.MouseButton1Click:Connect(function()
    if _G.STHAIN.SpawnUnit then _G.STHAIN.SpawnUnit(SS.UnitSlot) end
end)

-- ============================================================
-- TAB COMBAT — PvP
-- ============================================================
local pvpSection = S.Comp.makeSection(pages["Combat"], "PvP", false)
S.Comp.makeToggle(pvpSection, "Kill Aura", CC.KillAura, function(v) CC.KillAura = v save() end)
S.Comp.makeToggle(pvpSection, "Target Lock", CC.TargetLock, function(v) CC.TargetLock = v save() end)
S.Comp.makeToggle(pvpSection, "Auto Heal", CC.AutoHeal, function(v) CC.AutoHeal = v save() end)
S.Comp.makeToggle(pvpSection, "Anti-Stun", CC.AntiStun, function(v) CC.AntiStun = v save() end)

-- ============================================================
-- TAB COMBAT — Delay Settings
-- ============================================================
local combatDelay = S.Comp.makeSection(pages["Combat"], "Delay Settings", false)
S.Comp.makeInput(combatDelay, "Attack Delay", CC.AttackDelay, function(v) CC.AttackDelay = v save() end)
S.Comp.makeInput(combatDelay, "Rush Delay", CC.RushDelay, function(v) CC.RushDelay = v save() end)
S.Comp.makeInput(combatDelay, "Follow Delay", CC.FollowDelay, function(v) CC.FollowDelay = v save() end)

-- ============================================================
-- TAB ESP
-- ============================================================
local VV = S.Config.Visual

local enableEsp = S.Comp.makeSection(pages["Esp"], "Enable Esp", false)
S.Comp.makeToggle(enableEsp, "Enable Esp", VV.Chams, function(v) VV.Chams = v save() end)

local espSetting = S.Comp.makeSection(pages["Esp"], "Esp Setting", false)
S.Comp.makeToggle(espSetting, "Show Distance", VV.ESPShowDistance, function(v) VV.ESPShowDistance = v save() end)
S.Comp.makeToggle(espSetting, "Show Health", VV.ESPHealth, function(v) VV.ESPHealth = v save() end)
S.Comp.makeToggle(espSetting, "Show Name", VV.ESPName, function(v) VV.ESPName = v save() end)

local espObject = S.Comp.makeSection(pages["Esp"], "Esp Object", false)
S.Comp.makeToggle(espObject, "Esp Supply", VV.ESPSupply, function(v) VV.ESPSupply = v save() end)
S.Comp.makeToggle(espObject, "Esp Capture", VV.ESPCapture, function(v) VV.ESPCapture = v save() end)

-- ============================================================
-- TAB TELEPORT — Capture Point
-- ============================================================
local TT = S.Config.Teleport

local tpCapture = S.Comp.makeSection(pages["Teleport"], "Capture Point", false)
S.Comp.makeButton(tpCapture, "TP to Nearest Capture", function()
    if _G.STHAIN.TeleportToNearestCapture then _G.STHAIN.TeleportToNearestCapture() end
end)
S.Comp.makeButton(tpCapture, "TP to Base", function()
    if _G.STHAIN.TeleportToBase then _G.STHAIN.TeleportToBase() end
end)
S.Comp.makeButton(tpCapture, "TP to Point A", function()
    if _G.STHAIN.TeleportToPointA then _G.STHAIN.TeleportToPointA() end
end)
S.Comp.makeButton(tpCapture, "TP to Point B", function()
    if _G.STHAIN.TeleportToPointB then _G.STHAIN.TeleportToPointB() end
end)

-- ============================================================
-- TAB TELEPORT — Player
-- ============================================================
local tpPlayer = S.Comp.makeSection(pages["Teleport"], "Player", false)
S.Comp.makeButton(tpPlayer, "TP to Nearest Enemy", function()
    if _G.STHAIN.TeleportToNearestEnemy then _G.STHAIN.TeleportToNearestEnemy() end
end)
S.Comp.makeButton(tpPlayer, "TP to Teammate", function()
    if _G.STHAIN.TeleportToTeammate then _G.STHAIN.TeleportToTeammate() end
end)

-- ============================================================
-- TAB TELEPORT — Supply Enemy
-- ============================================================
local supplyEnemySection = S.Comp.makeSection(pages["Teleport"], "Supply Enemy", false)

local enemyDropdown = makeDynamicDropdown(supplyEnemySection, "Supply Target", {"AttackerSupply1"}, function(v)
    TT.EnemySupplyTarget = v
    save()
end)

local enemyBtn = Instance.new("TextButton")
enemyBtn.Name = "SupplyEnemyBtn"
enemyBtn.Size = UDim2.new(1, 0, 0, 32)
enemyBtn.BackgroundColor3 = C.bg4
enemyBtn.BackgroundTransparency = 0
enemyBtn.BorderSizePixel = 0
enemyBtn.Text = "TP Supply Enemy"
enemyBtn.TextColor3 = C.accent
enemyBtn.TextSize = 11
enemyBtn.Font = F.norm
enemyBtn.AutoButtonColor = false
enemyBtn.Parent = supplyEnemySection
Instance.new("UICorner", enemyBtn).CornerRadius = UDim.new(0, 6)

enemyBtn.MouseButton1Click:Connect(function()
    if _G.STHAIN.TeleportToSupplyEnemy then 
        _G.STHAIN.TeleportToSupplyEnemy(TT.EnemySupplyTarget or "") 
    end
end)

-- ============================================================
-- TAB TELEPORT — Supply Owner
-- ============================================================
local supplyOwnerSection = S.Comp.makeSection(pages["Teleport"], "Supply Owner", false)

local ownerDropdown = makeDynamicDropdown(supplyOwnerSection, "Supply Target", {"DefenderSupply1"}, function(v)
    TT.OwnerSupplyTarget = v
    save()
end)

local ownerBtn = Instance.new("TextButton")
ownerBtn.Name = "SupplyOwnerBtn"
ownerBtn.Size = UDim2.new(1, 0, 0, 32)
ownerBtn.BackgroundColor3 = C.bg4
ownerBtn.BackgroundTransparency = 0
ownerBtn.BorderSizePixel = 0
ownerBtn.Text = "TP Supply Owner"
ownerBtn.TextColor3 = C.accent
ownerBtn.TextSize = 11
ownerBtn.Font = F.norm
ownerBtn.AutoButtonColor = false
ownerBtn.Parent = supplyOwnerSection
Instance.new("UICorner", ownerBtn).CornerRadius = UDim.new(0, 6)

ownerBtn.MouseButton1Click:Connect(function()
    if _G.STHAIN.TeleportToSupplyOwner then 
        _G.STHAIN.TeleportToSupplyOwner(TT.OwnerSupplyTarget or "") 
    end
end)

-- ============================================================
-- DYNAMIC DROPDOWN UPDATE LOOP
-- ============================================================
task.spawn(function()
    while task.wait(3) do
        if _G.STHAIN.GetSupplyList then
            local ok, data = pcall(_G.STHAIN.GetSupplyList)
            if ok and data then
                if data.enemySupplies and #data.enemySupplies > 0 then
                    enemyDropdown.UpdateOptions(data.enemySupplies)
                end
                if data.ownerSupplies and #data.ownerSupplies > 0 then
                    ownerDropdown.UpdateOptions(data.ownerSupplies)
                end
            end
        end
    end
end)

-- ============================================================
-- TAB SETTINGS — Player Utility
-- ============================================================
local MM = S.Config.Movement
local XX = S.Config.Misc

local utilityContent = S.Comp.makeSection(pages["Settings"], "Player Utility", false)
S.Comp.makeInput(utilityContent, "Speed Value", MM.WalkSpeed, function(v) MM.WalkSpeed = v save() end)
S.Comp.makeToggle(utilityContent, "No Clip", MM.Noclip, function(v) MM.Noclip = v save() end)
S.Comp.makeToggle(utilityContent, "Fly", MM.Fly, function(v) MM.Fly = v save() end)
S.Comp.makeToggle(utilityContent, "Infinite Jump", MM.InfJump, function(v) MM.InfJump = v save() end)
S.Comp.makeInput(utilityContent, "Fly Speed", MM.FlySpeed, function(v) MM.FlySpeed = v save() end)
S.Comp.makeInput(utilityContent, "Hip Height", MM.HipHeight, function(v) MM.HipHeight = v save() end)
S.Comp.makeInput(utilityContent, "Jump Power", MM.JumpPower, function(v) MM.JumpPower = v save() end)
S.Comp.makeToggle(utilityContent, "Anti-AFK", XX.AntiAFK, function(v) XX.AntiAFK = v save() end)

-- ============================================================
-- TAB SETTINGS — Visuals
-- ============================================================
local visualContent = S.Comp.makeSection(pages["Settings"], "Visuals", false)
S.Comp.makeToggle(visualContent, "Full Bright", VV.Fullbright, function(v) VV.Fullbright = v save() end)
S.Comp.makeToggle(visualContent, "No Fog", VV.NoFog, function(v) VV.NoFog = v save() end)

-- ============================================================
-- TAB SETTINGS — Auto Claim
-- ============================================================
local autoClaimContent = S.Comp.makeSection(pages["Settings"], "Auto Claim", false)
S.Comp.makeButton(autoClaimContent, "Claim Quest Now", function()
    if _G.STHAIN.ClaimQuests then _G.STHAIN.ClaimQuests() end
end)
S.Comp.makeButton(autoClaimContent, "Claim All Code Now", function()
    if _G.STHAIN.RedeemAllCodes then _G.STHAIN.RedeemAllCodes() end
end)

-- ============================================================
-- TAB SETTINGS — Auto Join Team
-- ============================================================
local autoJoinContent = S.Comp.makeSection(pages["Settings"], "Auto Join Team", false)
local setJoinDefender, setJoinAttacker

local initialTeam = XX.AutoJoinTeam or "none"
local initDef = (initialTeam == "defender")
local initAtt = (initialTeam == "attacker")

setJoinDefender = S.Comp.makeToggle(autoJoinContent, "Auto Join Defenders", initDef, function(v)
    if v then
        XX.AutoJoinTeam = "defender"
        if setJoinAttacker then setJoinAttacker(false, true) end
        save()
    elseif XX.AutoJoinTeam == "defender" then
        XX.AutoJoinTeam = "none"
        save()
    end
end)

setJoinAttacker = S.Comp.makeToggle(autoJoinContent, "Auto Join Attackers", initAtt, function(v)
    if v then
        XX.AutoJoinTeam = "attacker"
        if setJoinDefender then setJoinDefender(false, true) end
        save()
    elseif XX.AutoJoinTeam == "attacker" then
        XX.AutoJoinTeam = "none"
        save()
    end
end)

-- ============================================================
-- TAB SETTINGS — Server
-- ============================================================
local serverContent = S.Comp.makeSection(pages["Settings"], "Server", false)
S.Comp.makeButton(serverContent, "Rejoin Server", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, S.LP)
    end)
end)
S.Comp.makeButton(serverContent, "Server Hop", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TS = game:GetService("TeleportService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        local data = Http:JSONDecode(game:HttpGet(url))
        local best = nil
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                if not best or server.playing < best.playing then
                    best = server
                end
            end
        end
        if best then TS:TeleportToPlaceInstance(game.PlaceId, best.id, S.LP) end
    end)
end)

-- ============================================================
-- TAB CONFIG
-- ============================================================
local cfg = S.Config.Config

local autoSaveSection = S.Comp.makeSection(pages["Config"], "Auto Save", false)
S.Comp.makeToggle(autoSaveSection, "Auto Save Config", cfg.AutoSave, function(v)
    cfg.AutoSave = v
end)

local configMgmt = S.Comp.makeSection(pages["Config"], "Config Management", false)
S.Comp.makeButton(configMgmt, "Save Config Now", function()
    if _G.STHAIN.SaveConfig then _G.STHAIN.SaveConfig() end
end)
S.Comp.makeButton(configMgmt, "Delete Config", function()
    if _G.STHAIN.DeleteConfig then _G.STHAIN.DeleteConfig() end
end)

-- ============================================================
-- DRAG MAIN FRAME
-- ============================================================
local mainDrag, mainStart, mainPos
S.GUI.MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = true
        mainStart = input.Position
        mainPos = S.GUI.MainFrame.Position
    end
end)
S.GUI.MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and mainDrag then
        local delta = input.Position - mainStart
        S.GUI.MainFrame.Position = UDim2.new(
            mainPos.X.Scale, mainPos.X.Offset + delta.X,
            mainPos.Y.Scale, mainPos.Y.Offset + delta.Y
        )
    end
end)
S.GUI.MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = false
    end
end)

-- ============================================================
-- MINIMIZE / OPEN
-- ============================================================
switchPage("Combat")

S.GUI.MinBtn.MouseButton1Click:Connect(function()
    S.GUI.MainFrame.Visible = false
    S.GUI.FloatBtn.Visible = true
end)
S.GUI.FloatBtn.MouseButton1Click:Connect(function()
    S.GUI.FloatBtn.Visible = false
    S.GUI.MainFrame.Visible = true
end)

S.GUI.FloatBtn.Visible = true
S.GUI.MainFrame.Visible = false

print("[FLOW] Pages loaded")
