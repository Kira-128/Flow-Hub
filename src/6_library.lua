--[[
============================================================
  [1] LIBB (Flow Hub - Components v3.4 STABIL)
  - Item Height: 30px
  - Header Height: 32px
  - Dropdown Auto-Scale
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Comp = {}
local ITEM_H = 30
local HEADER_H = 32
local CARD_BG = C.bg3
local CARD_TRANS = 0.15

-- ============================================================
-- HELPER: Recalculate Section Height
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
    card.Size = UDim2.new(1, 0, 0, HEADER_H + totalH + 8)
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
    card.ClipsDescendants = true
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

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
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = C.text
    titleLbl.TextSize = 11
    titleLbl.Font = F.bold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.ZIndex = 3
    titleLbl.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.AnchorPoint = Vector2.new(1, 0) 
    arrow.Text = defaultOpen and "▼" or "▶"
    arrow.TextColor3 = C.accent
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
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
    contentLayout.Padding = UDim.new(0, 2)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 4)
    cPad.PaddingBottom = UDim.new(0, 4)
    cPad.Parent = content

    local isOpen = defaultOpen
    hookAutoRecalc(card, content)

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
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
-- TOGGLE
-- ============================================================
function Comp.makeToggle(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Toggle_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 18)
    b.Position = UDim2.new(1, -42, 0.5, -9)
    b.Text = ""
    b.BackgroundColor3 = default and C.accent or C.bg4
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    knob.Parent = b
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default

    local function setState(newState, skipCallback)
        if state == newState then return end
        state = newState
        S.Services.TS:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = state and C.accent or C.bg4 }):Play()
        S.Services.TS:Create(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) }):Play()
        if not skipCallback then pcall(callback, state) end
    end

    b.MouseButton1Click:Connect(function() setState(not state, false) end)
    return setState
end

-- ============================================================
-- INPUT (Angka)
-- ============================================================
function Comp.makeInput(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Input_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 55, 0, 20)
    b.Position = UDim2.new(1, -67, 0.5, -10)
    b.Text = tostring(default)
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then pcall(callback, v) else b.Text = tostring(default) end
    end)
end

-- ============================================================
-- TEXT INPUT
-- ============================================================
function Comp.makeTextInput(parent, name, default, placeholder, callback)
    local f = Instance.new("Frame")
    f.Name = "TextInput_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Name = "TextBox"
    b.Size = UDim2.new(0, 130, 0, 20)
    b.Position = UDim2.new(1, -142, 0.5, -10)
    b.Text = tostring(default or "")
    b.PlaceholderText = placeholder or ""
    b.PlaceholderColor3 = C.textDim2
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.FocusLost:Connect(function() pcall(callback, b.Text) end)
    return b
end

-- ============================================================
-- BUTTON
-- ============================================================
function Comp.makeButton(parent, name, callback)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "BtnWrapper_" .. name
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_H)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, -12, 1, -4)
    b.Position = UDim2.new(0, 6, 0.5, -((ITEM_H-4)/2))
    b.Text = name
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BackgroundTransparency = 0.3
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = wrapper
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.ZIndex = 5
    flash.Parent = b
    Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Down:Connect(function()
        S.Services.TS:Create(flash, TweenInfo.new(0.1), { BackgroundTransparency = 0.8 }):Play()
    end)
    b.MouseButton1Up:Connect(function()
        S.Services.TS:Create(flash, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(flash, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    end)

    b.MouseButton1Click:Connect(function() pcall(callback) end)
    
    b.MouseEnter:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1 }):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg4, BackgroundTransparency = 0.3 }):Play()
    end)
    
    return b
end

-- ============================================================
-- DROPDOWN (AUTOMIZE)
-- ============================================================
function Comp.makeDropdown(parent, name, initialOptions, callback)
    local f = Instance.new("Frame")
    f.Name = "Dropdown_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
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

    local DROPDOWN_SCALE = 0.2889 

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(DROPDOWN_SCALE, 0, 0, 20) 
    selected.Position = UDim2.new(1, -12, 0.5, -10)
    selected.Text = ""
    selected.BackgroundColor3 = C.bg4
    selected.BorderSizePixel = 0
    selected.AutoButtonColor = false
    selected.ZIndex = 10
    selected.Parent = f
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 4)

    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -24, 1, 0)
    selectedText.Position = UDim2.new(0, 8, 0, 0)
    selectedText.Text = initialOptions[1] or "None"
    selectedText.TextColor3 = C.text
    selectedText.TextSize = 11
    selectedText.Font = F.norm
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.BackgroundTransparency = 1
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.ZIndex = 11
    selectedText.Parent = selected

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = C.accent
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.ZIndex = 11
    arrow.Parent = selected

    local popup = Instance.new("ScrollingFrame")
    popup.Name = "DropdownPopup_" .. name
    popup.Size = UDim2.new(DROPDOWN_SCALE, 0, 0, 150) 
    popup.BackgroundColor3 = C.bg4
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 200
    popup.ScrollBarThickness = 2
    popup.ScrollBarImageColor3 = C.accent
    popup.CanvasSize = UDim2.new(0, 0, 0, 0)
    popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popup.ClipsDescendants = true
    popup.Parent = S.GUI.MainFrame
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 5)

    local popLayout = Instance.new("UIListLayout")
    popLayout.Padding = UDim.new(0, 2)
    popLayout.Parent = popup

    local currentValue = initialOptions[1] or "None"
    local isOpen = false

    local function updatePopupPosition()
        local pos = selected.AbsolutePosition
        local size = selected.AbsoluteSize
        local popupH = popup.AbsoluteSize.Y
        local mfPos = S.GUI.MainFrame.AbsolutePosition
        local popupW = popup.AbsoluteSize.X 

        if size.X == 0 or size.Y == 0 then return false end

        local localX = pos.X - mfPos.X
        local localY = pos.Y - mfPos.Y - popupH - 4

        if pos.Y - popupH - 4 < 0 then
            localY = pos.Y - mfPos.Y + size.Y + 4
        end

        if localX < 0 then localX = 0 end
        if localX + popupW > S.GUI.MainFrame.AbsoluteSize.X then
            localX = S.GUI.MainFrame.AbsoluteSize.X - popupW - 4
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
            optBtn.Size = UDim2.new(1, -8, 0, 24)
            optBtn.LayoutOrder = i
            optBtn.Text = opt
            optBtn.TextColor3 = C.text
            optBtn.TextSize = 11
            optBtn.Font = F.norm
            optBtn.BackgroundColor3 = C.bg4
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 201
            optBtn.AutoButtonColor = false
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            optBtn.MouseEnter:Connect(function()
                S.Services.TS:Create(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3 }):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                S.Services.TS:Create(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = C.bg4 }):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                selectedText.Text = opt
                currentValue = opt
                isOpen = false
                popup.Visible = false
                arrow.Text = "▼"
                pcall(callback, opt)
            end)
        end
        local contentH = #options * 26 + 8
        popup.Size = UDim2.new(DROPDOWN_SCALE, 0, 0, math.min(contentH, 150))
    end

    rebuildOptions(initialOptions)

    selected.MouseButton1Click:Connect(function()
        if isOpen then
            isOpen = false
            popup.Visible = false
            arrow.Text = "▼"
        else
            isOpen = true
            if not updatePopupPosition() then isOpen = false return end
            popup.Visible = true
            arrow.Text = "▶"
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
            end
            anc = anc.Parent
        end
        if not stillVisible then
            isOpen = false
            popup.Visible = false
            arrow.Text = "▼"
            return
        end
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
                popup.Visible = false
                arrow.Text = "▼"
            end
        end
    end)

    return {
        UpdateOptions = function(options)
            if isOpen then return end
            rebuildOptions(options)
        end,
        SetValue = function(v)
            currentValue = v
            selectedText.Text = v
        end,
        GetValue = function() return currentValue end,
        ClosePopup = function() isOpen = false popup.Visible = false arrow.Text = "▼" end
    }
end

-- ============================================================
-- RESIZE HANDLE
-- ============================================================
function Comp.attachResizeHandle(mainFrame)
    local handle = Instance.new("TextButton")
    handle.Name = "ResizeHandle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(1, -16, 1, -16)
    handle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    handle.BorderSizePixel = 0
    handle.Text = "◢"
    handle.TextColor3 = C.accent
    handle.TextSize = 10
    handle.Font = F.bold
    handle.ZIndex = 100
    handle.Parent = mainFrame
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 3)

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
            local newW = math.max(300, startSize.X + delta.X)
            local newH = math.max(200, startSize.Y + delta.Y)
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
