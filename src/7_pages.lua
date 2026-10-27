--[[
============================================================
  [7] PAGES — Command An Army (v3.0 Final)
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

-- ============================================================
-- FORCE SECTION AUTO-SIZE
-- ============================================================
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
        TS:Create(acc, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 3, 0, 18)
        }):Play()
        switchPage(name)
    end)

    table.insert(tabs, {btn = btn, icon = ic, text = tx, bar = acc})
end

-- ============================================================
-- CUSTOM DYNAMIC DROPDOWN
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
    lbl.TextStrokeTransparency = 1
    lbl.Parent = f

    local DROPDOWN_W = 130

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0, DROPDOWN_W, 0, 22)
    selected.Position = UDim2.new(1, -(DROPDOWN_W + 12), 0.5, -11)
    selected.Text = initialOptions[1] or "None"
    selected.TextColor3 = C.text
    selected.TextSize = 11
    selected.Font = F.norm
    selected.BackgroundColor3 = C.bg4
    selected.BackgroundTransparency = 0
    selected.BorderSizePixel = 0
    selected.AutoButtonColor = false
    selected.TextStrokeTransparency = 1
    selected.ZIndex = 10
    selected.Parent = f
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 4)

    local selOverlay = Instance.new("Frame")
    selOverlay.Name = "ClickOverlay"
    selOverlay.Size = UDim2.new(1, 0, 1, 0)
    selOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selOverlay.BackgroundTransparency = 1
    selOverlay.BorderSizePixel = 0
    selOverlay.ZIndex = 11
    selOverlay.Parent = selected
    Instance.new("UICorner", selOverlay).CornerRadius = UDim.new(0, 4)

    selected.MouseButton1Down:Connect(function() selOverlay.BackgroundTransparency = 0.85 end)
    selected.MouseButton1Up:Connect(function()
        TS:Create(selOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
    end)
    selected.MouseLeave:Connect(function()
        TS:Create(selOverlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
    end)

    local popup = Instance.new("ScrollingFrame")
    popup.Name = "DropdownPopup_" .. name
    popup.Size = UDim2.new(0, DROPDOWN_W, 0, 150)
    popup.BackgroundColor3 = C.bg4
    popup.BackgroundTransparency = 0
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 200
    popup.ScrollBarThickness = 3
    popup.ScrollBarImageColor3 = C.accent
    popup.ScrollBarImageTransparency = 0.4
    popup.CanvasSize = UDim2.new(0, 0, 0, 0)
    popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popup.ScrollingDirection = Enum.ScrollingDirection.Y
    popup.ElasticBehavior = Enum.ElasticBehavior.Never
    popup.ClipsDescendants = true
    popup.Parent = S.GUI.MainFrame
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 5)

    local popLayout = Instance.new("UIListLayout")
    popLayout.Padding = UDim.new(0, 2)
    popLayout.SortOrder = Enum.SortOrder.LayoutOrder
    popLayout.Parent = popup

    local popPad = Instance.new("UIPadding")
    popPad.PaddingTop = UDim.new(0, 4)
    popPad.PaddingBottom = UDim.new(0, 4)
    popPad.PaddingLeft = UDim.new(0, 4)
    popPad.PaddingRight = UDim.new(0, 4)
    popPad.Parent = popup

    local currentValue = initialOptions[1] or "None"
    local isOpen = false
    local isAnimating = false

    local function updatePopupPosition()
        local pos = selected.AbsolutePosition
        local size = selected.AbsoluteSize
        local popupH = popup.AbsoluteSize.Y
        local mfPos = S.GUI.MainFrame.AbsolutePosition

        if size.X == 0 or size.Y == 0 then return false end

        local localX = pos.X - mfPos.X
        local localY = pos.Y - mfPos.Y - popupH - 4

        if pos.Y - popupH - 4 < 0 then
            localY = pos.Y - mfPos.Y + size.Y + 4
        end

        if localX < 0 then localX = 0 end
        if localX + DROPDOWN_W > S.GUI.MainFrame.AbsoluteSize.X then
            localX = S.GUI.MainFrame.AbsoluteSize.X - DROPDOWN_W
        end

        popup.Position = UDim2.new(0, localX, 0, localY)
        return true
    end

    local function rebuildOptions(options)
        for _, child in pairs(popup:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -8, 0, 26)
            optBtn.LayoutOrder = i
            optBtn.Text = opt
            optBtn.TextColor3 = C.text
            optBtn.TextSize = 11
            optBtn.Font = F.norm
            optBtn.TextStrokeTransparency = 1
            optBtn.BackgroundColor3 = C.bg4
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 201
            optBtn.AutoButtonColor = false
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            local optOverlay = Instance.new("Frame")
            optOverlay.Name = "ClickOverlay"
            optOverlay.Size = UDim2.new(1, 0, 1, 0)
            optOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            optOverlay.BackgroundTransparency = 1
            optOverlay.BorderSizePixel = 0
            optOverlay.ZIndex = 202
            optOverlay.Parent = optBtn
            Instance.new("UICorner", optOverlay).CornerRadius = UDim.new(0, 4)

            optBtn.MouseButton1Down:Connect(function() optOverlay.BackgroundTransparency = 0.85 end)
            optBtn.MouseButton1Up:Connect(function()
                TS:Create(optOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                TS:Create(optOverlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                selected.Text = opt
                currentValue = opt
                isOpen = false
                popup.Visible = false
                pcall(callback, opt)
            end)
        end
        local maxH = 150
        local contentH = #options * 28 + 8
        popup.Size = UDim2.new(0, DROPDOWN_W, 0, math.min(contentH, maxH))
    end

    rebuildOptions(initialOptions)

    local function animatePopup(show)
        if isAnimating then return end
        isAnimating = true

        if show then
            if not updatePopupPosition() then
                isAnimating = false
                isOpen = false
                return
            end
            popup.BackgroundTransparency = 1
            popup.Visible = true
            local startPos = UDim2.new(
                popup.Position.X.Scale, popup.Position.X.Offset,
                popup.Position.Y.Scale, popup.Position.Y.Offset + 6
            )
            popup.Position = startPos
            TS:Create(popup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                Position = UDim2.new(
                    popup.Position.X.Scale, popup.Position.X.Offset,
                    popup.Position.Y.Scale, popup.Position.Y.Offset - 6
                )
            }):Play()
            task.delay(0.15, function() isAnimating = false end)
        else
            TS:Create(popup, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
            task.delay(0.1, function()
                popup.Visible = false
                isAnimating = false
            end)
        end
    end

    local function closePopup(instant)
        if not isOpen then return end
        isOpen = false
        isAnimating = false

        if instant then
            popup.Visible = false
            popup.BackgroundTransparency = 0
        else
            animatePopup(false)
        end
    end

    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then animatePopup(true) else animatePopup(false) end
    end)

    Run.RenderStepped:Connect(function()
        if not isOpen then return end
        local anc = f
        local stillVisible = true
        while anc do
            if anc == S.GUI.MainFrame then break end
            if anc:IsA("GuiObject") then
                if not anc.Visible then stillVisible = false break end
                if anc.AbsoluteSize.X == 0 or anc.AbsoluteSize.Y == 0 then stillVisible = false break end
            end
            anc = anc.Parent
        end
        if not stillVisible then closePopup(true) return end
        updatePopupPosition()
    end)

    UIS.InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local popPos = popup.AbsolutePosition
            local popSize = popup.AbsoluteSize
            local selPos = selected.AbsolutePosition
            local selSize = selected.AbsoluteSize

            local inPopup = mousePos.X >= popPos.X and mousePos.X <= popPos.X + popSize.X and mousePos.Y >= popPos.Y and mousePos.Y <= popPos.Y + popSize.Y
            local inSelected = mousePos.X >= selPos.X and mousePos.X <= selPos.X + selSize.X and mousePos.Y >= selPos.Y and mousePos.Y <= selPos.Y + selSize.Y

            if not inPopup and not inSelected then closePopup(false) end
        end
    end)

    return {
        UpdateOptions = function(options)
            if isOpen then return end
            local stillValid = false
            for _, opt in ipairs(options) do
                if opt == currentValue then stillValid = true break end
            end
            if not stillValid and #options > 0 then
                currentValue = options[1]
                selected.Text = options[1]
                pcall(callback, options[1])
            end
            rebuildOptions(options)
        end,
        SetValue = function(v)
            currentValue = v
            selected.Text = v
        end,
        GetValue = function() return currentValue end,
        ClosePopup = function() closePopup(true) end,
    }
end

-- ============================================================
-- HELPER BUTTON
-- ============================================================
local function makeSectionButton(parent, text, callback)
    return S.Comp.makeButton(parent, text, callback)
end

-- ============================================================
-- BUAT PAGES + TABS
-- ============================================================
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

-- ============================================================
-- TAB COMBAT
-- ============================================================
local CC = S.Config.Combat
local SS = S.Config.Spawn

local autoCombat = S.Comp.makeSection(pages["Combat"], "Auto Combat", false)
S.Comp.makeToggle(autoCombat, "Auto Attack (V)", CC.AutoAttack == true, function(v) CC.AutoAttack = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Rush (B)", CC.AutoRush == true, function(v) CC.AutoRush = v save() end)
S.Comp.makeToggle(autoCombat, "Auto Follow (C)", CC.AutoFollow == true, function(v) CC.AutoFollow = v save() end)
task.defer(function() task.wait(0.1) forceFixSection(autoCombat) end)

local spawnSection = S.Comp.makeSection(pages["Combat"], "Spawn Unit", false)
local spawnContent = Instance.new("Frame")
spawnContent.Name = "Content"
spawnContent.Size = UDim2.new(1, 0, 0, 0)
spawnContent.BackgroundTransparency = 1
spawnContent.BorderSizePixel = 0
spawnContent.AutomaticSize = Enum.AutomaticSize.Y
spawnContent.Parent = spawnSection

local spawnLayout = Instance.new("UIListLayout")
spawnLayout.Padding = UDim.new(0, 6)
spawnLayout.SortOrder = Enum.SortOrder.LayoutOrder
spawnLayout.Parent = spawnContent

local spawnDropdown = makeDynamicDropdown(spawnContent, "Unit Slot", {"1", "2", "3", "4"}, function(v)
    SS.UnitSlot = tonumber(v) or 1
    save()
end)

makeSectionButton(spawnContent, "Spawn Unit", function()
    if _G.STHAIN.SpawnUnit then _G.STHAIN.SpawnUnit(SS.UnitSlot) end
end)

S.Comp.makeToggle(spawnContent, "Auto Respawn [BETA]", SS.AutoSpawn == true, function(v) 
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

-- ============================================================
-- TAB ESP
-- ============================================================
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

-- ============================================================
-- TAB TELEPORT
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
local supplyEnemyContent = Instance.new("Frame")
supplyEnemyContent.Name = "Content"
supplyEnemyContent.Size = UDim2.new(1, 0, 0, 0)
supplyEnemyContent.BackgroundTransparency = 1
supplyEnemyContent.BorderSizePixel = 0
supplyEnemyContent.AutomaticSize = Enum.AutomaticSize.Y
supplyEnemyContent.Parent = supplyEnemySection

local supplyEnemyLayout = Instance.new("UIListLayout")
supplyEnemyLayout.Padding = UDim.new(0, 6)
supplyEnemyLayout.SortOrder = Enum.SortOrder.LayoutOrder
supplyEnemyLayout.Parent = supplyEnemyContent

local enemyDropdown = makeDynamicDropdown(supplyEnemyContent, "Supply Target", {TT.EnemySupplyTarget or "None"}, function(v)
    TT.EnemySupplyTarget = v
    save()
end)

makeSectionButton(supplyEnemyContent, "TP Supply Enemy", function()
    if _G.STHAIN.TeleportToSupplyEnemy then _G.STHAIN.TeleportToSupplyEnemy(TT.EnemySupplyTarget or "") end
end)
task.defer(function() task.wait(0.1) forceFixSection(supplyEnemySection) end)

local supplyOwnerSection = S.Comp.makeSection(pages["Teleport"], "Supply Owner", false)
local supplyOwnerContent = Instance.new("Frame")
supplyOwnerContent.Name = "Content"
supplyOwnerContent.Size = UDim2.new(1, 0, 0, 0)
supplyOwnerContent.BackgroundTransparency = 1
supplyOwnerContent.BorderSizePixel = 0
supplyOwnerContent.AutomaticSize = Enum.AutomaticSize.Y
supplyOwnerContent.Parent = supplyOwnerSection

local supplyOwnerLayout = Instance.new("UIListLayout")
supplyOwnerLayout.Padding = UDim.new(0, 6)
supplyOwnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
supplyOwnerLayout.Parent = supplyOwnerContent

local ownerDropdown = makeDynamicDropdown(supplyOwnerContent, "Supply Target", {TT.OwnerSupplyTarget or "None"}, function(v)
    TT.OwnerSupplyTarget = v
    save()
end)

makeSectionButton(supplyOwnerContent, "TP Supply Owner", function()
    if _G.STHAIN.TeleportToSupplyOwner then _G.STHAIN.TeleportToSupplyOwner(TT.OwnerSupplyTarget or "") end
end)
task.defer(function() task.wait(0.1) forceFixSection(supplyOwnerSection) end)

-- ============================================================
-- DYNAMIC DROPDOWN UPDATE LOOP
-- ============================================================
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

-- ============================================================
-- TAB AUTOMATION
-- ============================================================
local AA = S.Config.Automation or {}

-- 1. SUMMON SECTION
local summonSection = S.Comp.makeSection(pages["Automation"], "Summon", false)
S.Comp.makeToggle(summonSection, "Auto Summon", AA.AutoSummon == true, function(v) 
    AA.AutoSummon = v 
    save() 
end)

local summonAmountDropdown = makeDynamicDropdown(summonSection, "Summon Amount", {"1x", "10x"}, function(val)
    AA.SummonAmount = val
    save()
end)

S.Comp.makeInput(summonSection, "Keep Gems", AA.KeepGems or 0, function(v)
    AA.KeepGems = v
    save()
end)
task.defer(function() task.wait(0.1) forceFixSection(summonSection) end)

-- 2. ASCEND SECTION
local ascendSection = S.Comp.makeSection(pages["Automation"], "Ascend", false)
S.Comp.makeToggle(ascendSection, "Auto Ascend", AA.AutoAscend == true, function(v) 
    AA.AutoAscend = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(ascendSection) end)

-- 3. EVOLVE SECTION
local evolveSection = S.Comp.makeSection(pages["Automation"], "Evolve", false)
S.Comp.makeToggle(evolveSection, "Auto Evolve", AA.AutoEvolve == true, function(v) 
    AA.AutoEvolve = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(evolveSection) end)

-- 4. REWARDS SECTION (Daily Login digabung ke Quest)
local rewardSection = S.Comp.makeSection(pages["Automation"], "Rewards", false)
S.Comp.makeToggle(rewardSection, "Auto Daily/Weekly Reward", AA.AutoReward == true, function(v) 
    AA.AutoReward = v 
    save() 
end)
task.defer(function() task.wait(0.1) forceFixSection(rewardSection) end)

-- 5. CLAIM CODE SECTION
local codeSection = S.Comp.makeSection(pages["Automation"], "Claim Code", false)

-- Input Code
local codeInputContainer = Instance.new("Frame")
codeInputContainer.Name = "CodeInputContainer"
codeInputContainer.Size = UDim2.new(1, 0, 0, 34)
codeInputContainer.BackgroundTransparency = 1
codeInputContainer.Parent = codeSection

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -12, 0, 22)
codeBox.Position = UDim2.new(0, 12, 0.5, -11)
codeBox.BackgroundColor3 = C.bg4
codeBox.BorderSizePixel = 0
codeBox.Text = ""
codeBox.PlaceholderText = "Enter A Code..."
codeBox.TextColor3 = C.text
codeBox.PlaceholderColor3 = C.textDim2
codeBox.TextSize = 11
codeBox.Font = F.norm
codeBox.ClearTextOnFocus = false
codeBox.Parent = codeInputContainer
Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 4)

-- Dropdown Available Codes (Otomatis Fetch)
local codeDropdown = makeDynamicDropdown(codeSection, "Available Codes", {"Fetching..."}, function(val)
    if val ~= "Fetching..." and val ~= "None" then
        codeBox.Text = val
    end
end)

-- Auto Fetch pas halaman dibuka
task.spawn(function()
    task.wait(2) -- Tunggu UI ready
    if _G.STHAIN.FetchCodesSmart then
        local codes = _G.STHAIN.FetchCodesSmart()
        if codes and #codes > 0 then
            codeDropdown.UpdateOptions(codes)
        else
            codeDropdown.UpdateOptions({"No Codes"})
        end
    end
end)

-- Button Claim
S.Comp.makeButton(codeSection, "Claim Code", function()
    local code = codeBox.Text
    if code ~= "" and code ~= "Fetching..." and code ~= "None" then
        local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Shared") and game:GetService("ReplicatedStorage").Shared:FindFirstChild("Remotes")
        local RedeemCode = Remotes and Remotes:FindFirstChild("RedeemCode")
        if RedeemCode then
            pcall(function() RedeemCode:InvokeServer(code) end)
        end
    end
end)
task.defer(function() task.wait(0.1) forceFixSection(codeSection) end)

-- ============================================================
-- TAB SETTINGS
-- ============================================================
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

-- ============================================================
-- TAB CONFIG
-- ============================================================
local cfg = S.Config.Config

local autoSaveSection = S.Comp.makeSection(pages["Config"], "Auto Save", false)
S.Comp.makeToggle(autoSaveSection, "Auto Save Config", cfg.AutoSave == true, function(v)
    cfg.AutoSave = v
    save()
end)
task.defer(function() task.wait(0.1) forceFixSection(autoSaveSection) end)

local configMgmt = S.Comp.makeSection(pages["Config"], "Config Management", false)

-- Tombol 1
S.Comp.makeButton(configMgmt, "Save Config Now", function()
    if _G.STHAIN.Utils and _G.STHAIN.Utils.SaveConfig then _G.STHAIN.Utils.SaveConfig() end
end)

-- Tombol 2
S.Comp.makeButton(configMgmt, "Reset to Default", function()
    if _G.STHAIN.Utils and _G.STHAIN.Utils.DeleteConfig then 
        _G.STHAIN.Utils.DeleteConfig()
    end
end)

-- Tombol 3
S.Comp.makeButton(configMgmt, "Delete Config File", function()
    if _G.STHAIN.Utils and _G.STHAIN.Utils.DeleteConfig then 
        _G.STHAIN.Utils.DeleteConfig()
    end
end)

task.defer(function() task.wait(0.1) forceFixSection(configMgmt) end)

-- ============================================================
-- DRAG MAIN FRAME (Pakai Header)
-- ============================================================
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

-- ============================================================
-- MINIMIZE / OPEN
-- ============================================================
switchPage("Combat")

-- FIX: Langsung highlight tab Combat pas start
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

-- ============================================================
-- SEARCH FEATURE (FIXED: NO LAG)
-- ============================================================
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
