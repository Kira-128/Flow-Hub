--[[
============================================================
  [6] LIBRARY (Flow Hub - Components v4.0)
  - 100% Mengikuti Logika vd.lua (AnchorPoint + Scale)
  - Dropdown Automize & Rapi
  - Resize Handle
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Comp = {}
local ITEM_H = 30
local HEADER_H = 30
local CARD_BG = C.bg2
local CARD_TRANS = 0.3

-- ============================================================
-- HELPER: Recalculate section height
-- ============================================================
local function recalcSection(card, content)
    if not card or not card.Parent then return end
    if not content.Visible then
        card.Size = UDim2.new(1, 0, 0, HEADER_H)
        return
    end
    local layout = content:FindFirstChildOfClass("UIListLayout")
    local totalH = 0
    if layout then totalH = layout.AbsoluteContentSize.Y end
    card.Size = UDim2.new(1, 0, 0, HEADER_H + totalH + 6)
end

local function hookAutoRecalc(card, content)
    local layout = content:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            recalcSection(card, content)
        end)
    end
    content.ChildAdded:Connect(function()
        task.defer(function() recalcSection(card, content) end)
    end)
    content.ChildRemoved:Connect(function()
        task.defer(function() recalcSection(card, content) end)
    end)
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        recalcSection(card, content)
    end)
end

-- ============================================================
-- SECTION
-- ============================================================
function Comp.makeSection(parent, title, defaultOpen)
    local card = Instance.new("Frame")
    card.Name = "Section_" .. title
    card.Size = UDim2.new(1, 0, 0, HEADER_H)
    card.BackgroundColor3 = CARD_BG
    card.BackgroundTransparency = CARD_TRANS
    card.BorderSizePixel = 0
    card.ClipsDescendants = false
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HEADER_H)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Text = ""
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.ZIndex = 2
    header.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -32, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = C.text
    titleLbl.TextSize = 12
    titleLbl.Font = F.bold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.ZIndex = 3
    titleLbl.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 18, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = C.accent
    arrow.TextSize = 11
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.Rotation = defaultOpen and 180 or 0
    arrow.ZIndex = 3
    arrow.Parent = header

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, HEADER_H)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = false
    content.Visible = defaultOpen
    content.ZIndex = 2
    content.Parent = card

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 3)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 2)
    cPad.PaddingBottom = UDim.new(0, 4)
    cPad.PaddingLeft = UDim.new(0, 10)
    cPad.PaddingRight = UDim.new(0, 10)
    cPad.Parent = content

    local isOpen = defaultOpen
    hookAutoRecalc(card, content)

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Rotation = isOpen and 180 or 0
        content.Visible = isOpen
        task.defer(function() recalcSection(card, content) end)
    end)

    task.defer(function()
        task.wait(0.15)
        if defaultOpen then recalcSection(card, content) end
    end)

    return content, function() recalcSection(card, content) end, card
end

-- ============================================================
-- TOGGLE (Full Width 1, 0)
-- ============================================================
function Comp.makeToggle(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Toggle_" .. name
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -45, 1, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.bold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, 34, 0, 18)
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, 0, 0.5, 0) -- Nempel kanan mentok
    b.BackgroundColor3 = default and C.accent or C.bg3
    b.BorderSizePixel = 0
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = default and C.text or C.textDim
    knob.BorderSizePixel = 0
    knob.Parent = b
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = b

    local state = default

    local function setState(newState, skipCallback)
        if state == newState then return end
        state = newState
        S.Services.TS:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = state and C.accent or C.bg3 }):Play()
        S.Services.TS:Create(knob, TweenInfo.new(0.2), { 
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = state and C.text or C.textDim
        }):Play()
        if not skipCallback then pcall(callback, state) end
    end

    btn.MouseButton1Click:Connect(function() setState(not state, false) end)
    return setState
end

-- ============================================================
-- INPUT (Scale 0.48 - Persis vd.lua)
-- ============================================================
function Comp.makeInput(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Input_" .. name
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.bold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, 0, 0.5, 0)
    b.Size = UDim2.new(0.48, 0, 0, 22) -- 🔥 Lebar 48% (Seperti vd.lua)
    b.Text = tostring(default)
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.bold
    b.BackgroundColor3 = C.bg2
    b.BackgroundTransparency = CARD_TRANS
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border or Color3.fromRGB(80, 50, 25)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = b

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then pcall(callback, v) else b.Text = tostring(default) end
    end)
end

-- ============================================================
-- TEXT INPUT (Scale 0.48 - Persis vd.lua)
-- ============================================================
function Comp.makeTextInput(parent, name, default, placeholder, callback)
    local f = Instance.new("Frame")
    f.Name = "TextInput_" .. name
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.bold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Name = "TextBox"
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, 0, 0.5, 0)
    b.Size = UDim2.new(0.48, 0, 0, 22) -- 🔥 Lebar 48% (Seperti vd.lua)
    b.Text = tostring(default or "")
    b.PlaceholderText = placeholder or ""
    b.PlaceholderColor3 = C.textDim2 or C.textDim
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.bold
    b.BackgroundColor3 = C.bg2
    b.BackgroundTransparency = CARD_TRANS
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border or Color3.fromRGB(80, 50, 25)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = b

    b.FocusLost:Connect(function() pcall(callback, b.Text) end)
    return b
end

-- ============================================================
-- BUTTON
-- ============================================================
function Comp.makeButton(parent, name, callback)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "BtnWrapper_" .. name
    wrapper.Size = UDim2.new(1, 0, 0, 26)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, 0, 1, 0)
    b.Text = name
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.bold
    b.BackgroundColor3 = C.bg3
    b.BackgroundTransparency = 0.3
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = wrapper
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.MouseButton1Click:Connect(function() pcall(callback) end)
    b.MouseEnter:Connect(function() S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg4 }):Play() end)
    b.MouseLeave:Connect(function() S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3 }):Play() end)
    
    return b
end

-- ============================================================
-- DROPDOWN (Scale 0.48 - Persis vd.lua + Popup Automize)
-- ============================================================
function Comp.makeDropdown(parent, name, initialOptions, callback)
    local f = Instance.new("Frame")
    f.Name = "Dropdown_" .. name
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.Parent = parent

    -- Label kiri
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Text = name
    lbl.TextColor3 = C.text
    lbl.TextSize = 11
    lbl.Font = F.bold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = f

    -- 🔥 TOMBOL SELECT (Persis vd.lua: AnchorPoint Kanan, Size 0.48)
    local selected = Instance.new("TextButton")
    selected.AnchorPoint = Vector2.new(1, 0.5)
    selected.Position = UDim2.new(1, 0, 0.5, 0)
    selected.Size = UDim2.new(0.48, 0, 0, 22) 
    selected.BackgroundColor3 = C.bg2
    selected.BackgroundTransparency = CARD_TRANS
    selected.BorderSizePixel = 0
    selected.AutoButtonColor = false
    selected.Parent = f
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.border or Color3.fromRGB(80, 50, 25)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = selected

    -- Teks selected
    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -24, 1, 0)
    selectedText.Position = UDim2.new(0, 8, 0, 0)
    selectedText.Text = initialOptions[1] or "Select Option"
    selectedText.TextColor3 = C.textDim
    selectedText.TextSize = 11
    selectedText.Font = F.bold
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.BackgroundTransparency = 1
    selectedText.Parent = selected

    -- Ikon Panah
    local arrow = Instance.new("ImageLabel")
    arrow.Image = "rbxassetid://6031091004"
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.Size = UDim2.new(0, 11, 0, 11)
    arrow.BackgroundTransparency = 1
    arrow.ImageColor3 = C.accent
    arrow.Parent = selected

    -- ========================================
    -- POPUP
    -- ========================================
    local popup = Instance.new("ScrollingFrame")
    popup.Name = "DropdownPopup_" .. name
    popup.BackgroundColor3 = C.bg2
    popup.BackgroundTransparency = 0.1
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 500
    popup.ScrollBarThickness = 2
    popup.ScrollBarImageColor3 = C.accent
    popup.CanvasSize = UDim2.new(0, 0, 0, 0)
    popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popup.ScrollingDirection = Enum.ScrollingDirection.Y
    popup.ClipsDescendants = true
    popup.Parent = S.GUI.MainFrame
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 4)
    
    local popupStroke = Instance.new("UIStroke")
    popupStroke.Color = C.border or Color3.fromRGB(80, 50, 25)
    popupStroke.Thickness = 1
    popupStroke.Transparency = 0.3
    popupStroke.Parent = popup

    local popLayout = Instance.new("UIListLayout")
    popLayout.Padding = UDim.new(0, 2)
    popLayout.Parent = popup

    local popPad = Instance.new("UIPadding")
    popPad.PaddingTop = UDim.new(0, 4)
    popPad.PaddingBottom = UDim.new(0, 4)
    popPad.PaddingLeft = UDim.new(0, 4)
    popPad.PaddingRight = UDim.new(0, 4)
    popPad.Parent = popup

    local currentValue = initialOptions[1] or "None"
    local isOpen = false

    local function updatePopupPosition()
        local pos = selected.AbsolutePosition
        local size = selected.AbsoluteSize
        local popupH = popup.AbsoluteSize.Y
        local mfPos = S.GUI.MainFrame.AbsolutePosition

        if size.X == 0 or size.Y == 0 then return false end

        -- Kunci lebar popup = lebar tombol
        popup.Size = UDim2.new(0, size.X, 0, popupH)

        -- Posisi X (Kanan)
        local localX = pos.X - mfPos.X
        -- Posisi Y (Otomatis ke bawah/atas)
        local localY = pos.Y - mfPos.Y - popupH - 4
        if localY < 0 then
            localY = pos.Y - mfPos.Y + size.Y + 4
        end

        if localX < 0 then localX = 0 end
        if localX + size.X > S.GUI.MainFrame.AbsoluteSize.X then
            localX = S.GUI.MainFrame.AbsoluteSize.X - size.X
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
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.LayoutOrder = i
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = C.text
            optBtn.TextSize = 11
            optBtn.Font = F.bold
            optBtn.BackgroundColor3 = C.bg3
            optBtn.BackgroundTransparency = 0.5
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 501
            optBtn.AutoButtonColor = false
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            optBtn.MouseEnter:Connect(function()
                S.Services.TS:Create(optBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.bg4, BackgroundTransparency = 0.2 }):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                S.Services.TS:Create(optBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.bg3, BackgroundTransparency = 0.5 }):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                selectedText.Text = tostring(opt)
                currentValue = opt
                isOpen = false
                popup.Visible = false
                pcall(callback, opt)
            end)
        end
        local maxH = 150
        local contentH = #options * 28 + 8
        popup.Size = UDim2.new(0, selected.AbsoluteSize.X, 0, math.min(contentH, maxH))
    end

    rebuildOptions(initialOptions)

    local function animatePopup(show)
        if show then
            popup.Visible = true
            updatePopupPosition()
            
            popup.BackgroundTransparency = 1
            local startY = popup.Position.Y.Offset + 6
            popup.Position = UDim2.new(popup.Position.X.Scale, popup.Position.X.Offset, 0, startY)
            
            S.Services.TS:Create(popup, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.1,
                Position = UDim2.new(popup.Position.X.Scale, popup.Position.X.Offset, 0, startY - 6)
            }):Play()
        else
            S.Services.TS:Create(popup, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
            task.delay(0.1, function() popup.Visible = false end)
        end
    end

    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            animatePopup(true)
        else
            animatePopup(false)
        end
    end)

    S.Services.Run.RenderStepped:Connect(function()
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
        if not stillVisible then isOpen = false popup.Visible = false return end
        updatePopupPosition()
    end)

    S.Services.UIS.InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local popPos = popup.AbsolutePosition
            local popSize = popup.AbsoluteSize
            local selPos = selected.AbsolutePosition
            local selSize = selected.AbsoluteSize

            local inPopup = mousePos.X >= popPos.X and mousePos.X <= popPos.X + popSize.X and mousePos.Y >= popPos.Y and mousePos.Y <= popPos.Y + popSize.Y
            local inSelected = mousePos.X >= selPos.X and mousePos.X <= selPos.X + selSize.X and mousePos.Y >= selPos.Y and mousePos.Y <= selPos.Y + selSize.Y

            if not inPopup and not inSelected then
                isOpen = false
                animatePopup(false)
            end
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
                selectedText.Text = options[1]
                pcall(callback, options[1])
            end
            rebuildOptions(options)
        end,
        SetValue = function(v)
            currentValue = v
            selectedText.Text = v
        end,
        GetValue = function() return currentValue end,
        ClosePopup = function() isOpen = false popup.Visible = false end
    }
end

-- ============================================================
-- RESIZE HANDLE (Mengikuti gaya vd.lua)
-- ============================================================
function Comp.attachResizeHandle(mainFrame)
    local handle = Instance.new("TextButton")
    handle.Name = "ResizeHandle"
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new(1, 0, 1, 0)
    handle.AnchorPoint = Vector2.new(1, 1)
    handle.BackgroundTransparency = 1
    handle.Text = ""
    handle.ZIndex = 100
    handle.Parent = mainFrame

    -- 3 Garis diagonal (seperti vd.lua)
    local function addLine(offsetX, offsetY, len)
        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(1, 1)
        line.Position = UDim2.new(1, offsetX, 1, offsetY)
        line.Size = UDim2.new(0, len, 0, 2)
        line.Rotation = -45
        line.BackgroundColor3 = C.textDim
        line.BackgroundTransparency = 0.35
        line.BorderSizePixel = 0
        line.ZIndex = 101
        line.Parent = handle
        Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
    end
    addLine(-3, -3, 6)
    addLine(-7, -3, 6)
    addLine(-3, -7, 6)

    local dragging = false
    local startPos, startSize

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            startSize = mainFrame.AbsoluteSize
        end
    end)
    S.Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            local newW = math.clamp(startSize.X + delta.X, 380, 800) -- Batas minimal & maksimal (seperti vd.lua)
            local newH = math.clamp(startSize.Y + delta.Y, 250, 600)
            mainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
    S.Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return handle
end

S.Comp = Comp
