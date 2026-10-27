--[[
============================================================
  [7] PAGES (Flow Hub v3.3)
============================================================
]]

local S = _G.STHAIN
repeat task.wait() until S.Config and S.Config.Combat 

local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local UIS = S.Services.UIS or game:GetService("UserInputService")
local Run = S.Services.Run or game:GetService("RunService")
local TS = S.Services.TS or game:GetService("TweenService")

local pages = {}
local tabs = {}

local function save()
    if _G.STHAIN.MarkDirty then
        _G.STHAIN.MarkDirty()
    elseif S.Utils and S.Utils.SaveConfig then
        task.spawn(S.Utils.SaveConfig)
    end
end

local function forceFixSection(sectionFrame)
    if not sectionFrame then return end
    pcall(function()
        if sectionFrame:IsA("Frame") or sectionFrame:IsA("ScrollingFrame") then
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.ClipsDescendants = false
        end
        for _, child in pairs(sectionFrame:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                if not child.Name:find("Popup") and not child.Name:find("Dropdown") then
                    pcall(function()
                        child.AutomaticSize = Enum.AutomaticSize.Y
                    end)
                end
            end
        end
    end)
end

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
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ElasticBehavior = Enum.ElasticBehavior.Never
    page.ClipsDescendants = false
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
    if S.GUI.ContentTitle then
        S.GUI.ContentTitle.Text = name
    end
end

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
        TS:Create(acc, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 3, 0, 18)
        }):Play()
        switchPage(name)
    end)

    table.insert(tabs, {btn = btn, icon = ic, text = tx, bar = acc})
end

local function makeSectionButton(parent, text, callback)
    return S.Comp.makeButton(parent, text, callback)
end

createPage("Combat")
createPage("Esp")
createPage("Teleport")
createPage("Automation")
createPage("Settings")
createPage("Config")

makeTab(I.combat, "Combat")
makeTab(I.visual, "Esp")
makeTab(I.teleport, "Teleport")
makeTab(I.automation, "Automation")
makeTab(I.settings, "Settings")
makeTab(I.config, "Config")

-- COMBAT
local CC = S.Config.Combat
local SS = S.Config.Spawn

local autoCombat = S.Comp.makeSection(pages["Combat"], "Auto Combat", false)
S.Comp.makeToggle(autoCombat, "Auto Attack (V)", CC.AutoAttack == true, function(v) CC.AutoAttack = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Rush (B)", CC.AutoRush == true, function(v) CC.AutoRush = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Follow (C)", CC.AutoFollow == true, function(v) CC.AutoFollow = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(autoCombat) end)

local spawnSection = S.Comp.makeSection(pages["Combat"], "Spawn Unit", false)
S.Comp.makeDropdown(spawnSection, "Unit Slot", {"1", "2", "3", "4"}, function(v)
    SS.UnitSlot = tonumber(v) or 1
    save()
end)
S.Comp.makeButton(spawnSection, "Spawn Unit", function()
    if _G.STHAIN.SpawnUnit then _G.STHAIN.SpawnUnit(SS.UnitSlot) end
end)
S.Comp.makeToggle(spawnSection, "Auto Respawn [BETA]", SS.AutoSpawn == true, function(v) 
    SS.AutoSpawn = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(spawnSection) end)

local pvpSection = S.Comp.makeSection(pages["Combat"], "PvP", false)
S.Comp.makeToggle(pvpSection, "Kill Aura", CC.KillAura == true, function(v) CC.KillAura = v save() end)
S.Comp.makeToggle(pvpSection, "Target Lock", CC.TargetLock == true, function(v) CC.TargetLock = v save() end)
S.Comp.makeToggle(pvpSection, "Auto Heal", CC.AutoHeal == true, function(v) CC.AutoHeal = v save() end)
S.Comp.makeToggle(pvpSection, "Anti-Stun", CC.AntiStun == true, function(v) CC.AntiStun = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(pvpSection) end)

local combatDelay = S.Comp.makeSection(pages["Combat"], "Delay Settings", false)
S.Comp.makeInput(combatDelay, "Attack Delay", CC.AttackDelay, function(v) CC.AttackDelay = v save() end)
S.Comp.makeInput(combatDelay, "Rush Delay", CC.RushDelay, function(v) CC.RushDelay = v save() end)
S.Comp.makeInput(combatDelay, "Follow Delay", CC.FollowDelay, function(v) CC.FollowDelay = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(combatDelay) end)

-- ESP
local VV = S.Config.Visual

local enableEsp = S.Comp.makeSection(pages["Esp"], "Enable Esp", false)
S.Comp.makeToggle(enableEsp, "Enable Esp", VV.Chams == true, function(v) VV.Chams = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(enableEsp) end)

local espSetting = S.Comp.makeSection(pages["Esp"], "Esp Setting", false)
S.Comp.makeToggle(espSetting, "Show Distance", VV.ESPShowDistance == true, function(v) VV.ESPShowDistance = v save() end)
S.Comp.makeToggle(espSetting, "Show Health", VV.ESPHealth == true, function(v) VV.ESPHealth = v save() end)
S.Comp.makeToggle(espSetting, "Show Name", VV.ESPName == true, function(v) VV.ESPName = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(espSetting) end)

local espObject = S.Comp.makeSection(pages["Esp"], "Esp Object", false)
S.Comp.makeToggle(espObject, "Esp Supply", VV.ESPSupply == true, function(v) VV.ESPSupply = v save() end)
S.Comp.makeToggle(espObject, "Esp Capture", VV.ESPCapture == true, function(v) VV.ESPCapture = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(espObject) end)

-- TELEPORT
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
task.defer(function() task.wait(0.1) forceFixSection(tpCapture) end)

local tpPlayer = S.Comp.makeSection(pages["Teleport"], "Player", false)
S.Comp.makeButton(tpPlayer, "TP to Nearest Enemy", function()
    if _G.STHAIN.TeleportToNearestEnemy then _G.STHAIN.TeleportToNearestEnemy() end
end)
S.Comp.makeButton(tpPlayer, "TP to Teammate", function()
    if _G.STHAIN.TeleportToTeammate then _G.STHAIN.TeleportToTeammate() end
end)
task.defer(function() task.wait(0.1) forceFixSection(tpPlayer) end)

local supplyEnemySection = S.Comp.makeSection(pages["Teleport"], "Supply Enemy", false)
local enemyDropdown = S.Comp.makeDropdown(supplyEnemySection, "Supply Target", {TT.EnemySupplyTarget or "None"}, function(v)
    TT.EnemySupplyTarget = v
    save()
end)
S.Comp.makeButton(supplyEnemySection, "TP Supply Enemy", function()
    if _G.STHAIN.TeleportToSupplyEnemy then _G.STHAIN.TeleportToSupplyEnemy(TT.EnemySupplyTarget or "") end
end)
task.defer(function() task.wait(0.1) forceFixSection(supplyEnemySection) end)

local supplyOwnerSection = S.Comp.makeSection(pages["Teleport"], "Supply Owner", false)
local ownerDropdown = S.Comp.makeDropdown(supplyOwnerSection, "Supply Target", {TT.OwnerSupplyTarget or "None"}, function(v)
    TT.OwnerSupplyTarget = v
    save()
end)
S.Comp.makeButton(supplyOwnerSection, "TP Supply Owner", function()
    if _G.STHAIN.TeleportToSupplyOwner then _G.STHAIN.TeleportToSupplyOwner(TT.OwnerSupplyTarget or "") end
end)
task.defer(function() task.wait(0.1) forceFixSection(supplyOwnerSection) end)

task.spawn(function()
    while task.wait(2) do
        if _G.STHAIN.GetSupplyList then
            local ok, data = pcall(_G.STHAIN.GetSupplyList)
            local hasAnySupply = false
            if ok and data then
                hasAnySupply = (#(data.enemySupplies or {}) > 0) or (#(data.ownerSupplies or {}) > 0)
            end
            
            if hasAnySupply then
                if #data.enemySupplies > 0 then enemyDropdown.UpdateOptions(data.enemySupplies) else enemyDropdown.UpdateOptions({"None"}) end
                if #data.ownerSupplies > 0 then ownerDropdown.UpdateOptions(data.ownerSupplies) else ownerDropdown.UpdateOptions({"None"}) end
            else
                enemyDropdown.UpdateOptions({"None"})
                ownerDropdown.UpdateOptions({"None"})
            end
        end
    end
end)

-- AUTOMATION
local AA = S.Config.Automation or {}

local summonSection = S.Comp.makeSection(pages["Automation"], "Summon", false)
S.Comp.makeToggle(summonSection, "Auto Summon", AA.AutoSummon == true, function(v) 
    AA.AutoSummon = v 
    save() 
end)
S.Comp.makeDropdown(summonSection, "Summon Amount", {"1x", "10x"}, function(val)
    AA.SummonAmount = val
    save()
end)
S.Comp.makeInput(summonSection, "Keep Gems", AA.KeepGems or 0, function(v)
    AA.KeepGems = v
    save()
end)
task.defer(function() task.wait(0.1) forceFixSection(summonSection) end)

local ascendSection = S.Comp.makeSection(pages["Automation"], "Ascend", false)
S.Comp.makeToggle(ascendSection, "Auto Ascend", AA.AutoAscend == true, function(v) 
    AA.AutoAscend = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(ascendSection) end)

local evolveSection = S.Comp.makeSection(pages["Automation"], "Evolve", false)
S.Comp.makeToggle(evolveSection, "Auto Evolve", AA.AutoEvolve == true, function(v) 
    AA.AutoEvolve = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(evolveSection) end)

local rewardSection = S.Comp.makeSection(pages["Automation"], "Rewards", false)
S.Comp.makeToggle(rewardSection, "Auto Daily/Weekly Reward", AA.AutoReward == true, function(v) 
    AA.AutoReward = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(rewardSection) end)

local codeSection = S.Comp.makeSection(pages["Automation"], "Claim Code", false)
local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -24, 0, 24)
codeBox.BackgroundColor3 = C.bg4
codeBox.BorderSizePixel = 0
codeBox.Text = ""
codeBox.PlaceholderText = "Enter A Code..."
codeBox.TextColor3 = C.text
codeBox.PlaceholderColor3 = C.textDim2
codeBox.TextSize = 11
codeBox.Font = F.norm
codeBox.ClearTextOnFocus = false
codeBox.Parent = codeSection
Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 4)
codeBox.Position = UDim2.new(0, 12, 0, 0)
S.Comp.makeButton(codeSection, "Claim Code", function()
    local code = codeBox.Text
    if code ~= "" then
        local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Shared") and game:GetService("ReplicatedStorage").Shared:FindFirstChild("Remotes")
        local RedeemCode = Remotes and Remotes:FindFirstChild("RedeemCode")
        if RedeemCode then
            pcall(function() RedeemCode:InvokeServer(code) end)
        end
    end
end)
task.defer(function() task.wait(0.1) forceFixSection(codeSection) end)

-- SETTINGS
local MM = S.Config.Movement
local XX = S.Config.Misc

local utilityContent = S.Comp.makeSection(pages["Settings"], "Player Utility", false)
S.Comp.makeInput(utilityContent, "Speed Value", MM.WalkSpeed, function(v) MM.WalkSpeed = v save() end)
S.Comp.makeToggle(utilityContent, "Enable Run Speed", MM.EnableRunSpeed == true, function(v) 
    MM.EnableRunSpeed = v 
    save() 
end)
S.Comp.makeToggle(utilityContent, "No Clip", MM.Noclip == true, function(v) MM.Noclip = v save() end)
S.Comp.makeToggle(utilityContent, "Fly", MM.Fly == true, function(v) MM.Fly = v save() end)
S.Comp.makeToggle(utilityContent, "Infinite Jump", MM.InfJump == true, function(v) MM.InfJump = v save() end)
S.Comp.makeInput(utilityContent, "Fly Speed", MM.FlySpeed, function(v) MM.FlySpeed = v save() end)
S.Comp.makeInput(utilityContent, "Jump Power", MM.JumpPower, function(v) MM.JumpPower = v save() end)
S.Comp.makeToggle(utilityContent, "Anti-AFK", XX.AntiAFK == true, function(v) XX.AntiAFK = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(utilityContent) end)

local visualContent = S.Comp.makeSection(pages["Settings"], "Visuals", false)
S.Comp.makeToggle(visualContent, "Full Bright", VV.Fullbright == true, function(v) VV.Fullbright = v save() end)
S.Comp.makeToggle(visualContent, "No Fog", VV.NoFog == true, function(v) VV.NoFog = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(visualContent) end)

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
task.defer(function() task.wait(0.1) forceFixSection(autoJoinContent) end)

local serverContent = S.Comp.makeSection(pages["Settings"], "Server", false)
S.Comp.makeButton(serverContent, "Rejoin Server", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, S.LP)
    end)
end)
S.Comp.makeButton(serverContent, "Server Hop (Find Small Server)", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
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
        if best then TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, S.LP) end
    end)
end)
task.defer(function() task.wait(0.1) forceFixSection(serverContent) end)

-- CONFIG
local cfg = S.Config.Config

local autoSaveSection = S.Comp.makeSection(pages["Config"], "Auto Save", false)
S.Comp.makeToggle(autoSaveSection, "Auto Save Config", cfg.AutoSave == true, function(v)
    cfg.AutoSave = v
    save()
end)
task.defer(function() task.wait(0.1) forceFixSection(autoSaveSection) end)

local configMgmt = S.Comp.makeSection(pages["Config"], "Config Management", false)

local resetBtn = S.Comp.makeButton(configMgmt, "Reset to Default", function()
    if resetBtn.Text == "Reset to Default" then
        resetBtn.Text = "Click Again to Confirm"
        resetBtn.BackgroundColor3 = Color3.fromRGB(255, 136, 0)
        resetBtn.BackgroundTransparency = 0.1
        task.delay(3, function()
            if resetBtn.Text == "Click Again to Confirm" then
                resetBtn.Text = "Reset to Default"
                resetBtn.BackgroundColor3 = C.bg4
                resetBtn.BackgroundTransparency = 0.3
            end
        end)
    elseif resetBtn.Text == "Click Again to Confirm" then
        if _G.STHAIN.Utils and _G.STHAIN.Utils.DeleteConfig then 
            _G.STHAIN.Utils.DeleteConfig()
        end
        resetBtn.Text = "Reset to Default"
        resetBtn.BackgroundColor3 = C.bg4
        resetBtn.BackgroundTransparency = 0.3
    end
end)

local deleteBtn = S.Comp.makeButton(configMgmt, "Delete Config File", function()
    if deleteBtn.Text == "Delete Config File" then
        deleteBtn.Text = "Click Again to Confirm"
        deleteBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        deleteBtn.BackgroundTransparency = 0.1
        task.delay(3, function()
            if deleteBtn.Text == "Click Again to Confirm" then
                deleteBtn.Text = "Delete Config File"
                deleteBtn.BackgroundColor3 = C.bg4
                deleteBtn.BackgroundTransparency = 0.3
            end
        end)
    elseif deleteBtn.Text == "Click Again to Confirm" then
        if _G.STHAIN.Utils and _G.STHAIN.Utils.DeleteConfig then 
            _G.STHAIN.Utils.DeleteConfig()
        end
        deleteBtn.Text = "Delete Config File"
        deleteBtn.BackgroundColor3 = C.bg4
        deleteBtn.BackgroundTransparency = 0.3
    end
end)

task.defer(function() task.wait(0.1) forceFixSection(configMgmt) end)

-- DRAG
local mainDrag, mainStart, mainPos
S.GUI.Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainDrag = true
        mainStart = input.Position
        mainPos = S.GUI.MainFrame.Position
    end
end)
S.GUI.Header.InputChanged:Connect(function(input)
    if mainDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - mainStart
        S.GUI.MainFrame.Position = UDim2.new(
            mainPos.X.Scale, mainPos.X.Offset + delta.X,
            mainPos.Y.Scale, mainPos.Y.Offset + delta.Y
        )
    end
end)
S.GUI.Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainDrag = false
    end
end)

-- MINIMIZE
switchPage("Combat")

for _, t in pairs(tabs) do
    if t.text.Text == "Combat" then
        t.btn.BackgroundColor3 = C.bg3
        t.btn.BackgroundTransparency = 0.3
        t.icon.ImageColor3 = C.accent
        t.text.TextColor3 = C.text
        t.bar.Visible = true
        t.bar.Size = UDim2.new(0, 3, 0, 18)
        break
    end
end

S.GUI.MinBtn.MouseButton1Click:Connect(function()
    S.GUI.MainFrame.Visible = false
    S.GUI.FloatBtn.Visible = true
end)
S.GUI.FloatBtn.MouseButton1Click:Connect(function()
    S.GUI.FloatBtn.Visible = false
    S.GUI.MainFrame.Visible = true
end)

S.GUI.MainFrame.Visible = true
S.GUI.FloatBtn.Visible = false

-- SEARCH
if S.GUI.SearchBox then
    S.GUI.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(S.GUI.SearchBox.Text)
        if query == "" then return end

        for pageName, page in pairs(pages) do
            for _, section in pairs(page:GetChildren()) do
                if section.Name:find("Section_") then
                    local sectionName = string.lower(section.Name:gsub("Section_", ""))
                    local matchFound = false

                    if string.find(sectionName, query) then
                        matchFound = true
                    end

                    local content = section:FindFirstChild("Content")
                    if content then
                        for _, item in pairs(content:GetChildren()) do
                            local itemName = ""
                            if item:IsA("Frame") then
                                local lbl = item:FindFirstChildWhichIsA("TextLabel")
                                if lbl then itemName = string.lower(lbl.Text) end
                            end
                            if string.find(itemName, query) then
                                matchFound = true
                                break
                            end
                        end
                    end

                    if matchFound then
                        switchPage(pageName)
                        if S.GUI.ContentTitle then 
                            S.GUI.ContentTitle.Text = pageName 
                        end
                        
                        for _, t in pairs(tabs) do
                            if t.text.Text == pageName then
                                t.btn.BackgroundColor3 = S.Theme.Colors.bg3
                                t.btn.BackgroundTransparency = 0.3
                                t.icon.ImageColor3 = S.Theme.Colors.accent
                                t.text.TextColor3 = S.Theme.Colors.text
                                t.bar.Visible = true
                            else
                                t.btn.BackgroundColor3 = S.Theme.Colors.bg2
                                t.btn.BackgroundTransparency = 1
                                t.icon.ImageColor3 = S.Theme.Colors.textDim
                                t.text.TextColor3 = S.Theme.Colors.textDim
                                t.bar.Visible = false
                            end
                        end

                        task.defer(function()
                            if page:IsA("ScrollingFrame") then
                                page.CanvasPosition = Vector2.new(0, section.Position.Y.Offset)
                            end
                        end)
                        return
                    end
                end
            end
        end
    end)
end
