-- [6] LIBRARY (Flow Hub - Components v6.1 FINAL)
-- Fixes: Renamed to Lib, Poco Resize Handle (FIXED), Slider Lag, Section Height

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Lib = {}
local ITEM_H = 34 
local HEADER_H = 30
local CARD_BG = C.bg3
local CARD_TRANS = 0.15

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
function Lib.makeSection(parent, title, defaultOpen)
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
    contentLayout.Padding = UDim.new(0, 1)
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
function Lib.makeToggle(parent, name, default, callback)
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
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -12, 0.5, 0)
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
-- INPUT
-- ============================================================
function Lib.makeInput(parent, name, default, callback)
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
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -12, 0.5, 0)
    b.Size = UDim2.new(0.20, 0, 0, 22)
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
function Lib.makeTextInput(parent, name, default, placeholder, callback)
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
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -12, 0.5, 0)
    b.Size = UDim2.new(0.48, 0, 0, 22)
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
-- SLIDER
-- ============================================================
function Lib.makeSlider(parent, name, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Slider_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.6, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local valLabel = Instance.new("TextLabel")
    valLabel.AnchorPoint = Vector2.new(1, 0.5)
    valLabel.Position = UDim2.new(1, -12, 0.5, 0)
    valLabel.Size = UDim2.new(0, 30, 1, 0)
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = C.accent
    valLabel.TextSize = 11
    valLabel.Font = F.bold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.BackgroundTransparency = 1
    valLabel.Parent = f

    local barBG = Instance.new("Frame")
    barBG.AnchorPoint = Vector2.new(1, 0.5)
    barBG.Position = UDim2.new(1, -50, 0.5, 0)
    barBG.Size = UDim2.new(0.4, 0, 0, 6)
    barBG.BackgroundColor3 = C.bg4
    barBG.BorderSizePixel = 0
    barBG.Parent = f
    Instance.new("UICorner", barBG).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = barBG
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = barBG
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 3
    sliderBtn.Parent = barBG

    local isDragging = false
    local currentVal = default

    local function updateValue(x, triggerCallback)
        local relX = math.clamp((x - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * relX + 0.5)
        valLabel.Text = tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, 0, 0.5, 0)
        currentVal = val
        if triggerCallback then pcall(callback, val) end
    end

    sliderBtn.MouseButton1Down:Connect(function() 
        isDragging = true 
        updateValue(S.Services.UIS:GetMouseLocation().X, false) 
    end)
    
    sliderBtn.MouseButton1Up:Connect(function() 
        isDragging = false 
        pcall(callback, currentVal) 
    end)
    
    S.Services.UIS.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X, false)
        end
    end)
    
    S.Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            if isDragging then
                isDragging = false 
                pcall(callback, currentVal)
            end
        end
    end)
end

-- ============================================================
-- BUTTON
-- ============================================================
function Lib.makeButton(parent, name, callback, noHover)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "BtnWrapper_" .. name
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_H)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, -12, 0, ITEM_H - 8)
    b.Position = UDim2.new(0, 6, 0.5, -(ITEM_H-8)/2)
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
    flash.ZIndex = 1
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
    
    if not noHover then
        b.MouseEnter:Connect(function()
            S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1 }):Play()
        end)
        b.MouseLeave:Connect(function()
            S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg4, BackgroundTransparency = 0.3 }):Play()
        end)
    end
    
    return b
end

-- ============================================================
-- DROPDOWN (TIDAK DIUBAH)
-- ============================================================
function Lib.makeDropdown(parent, name, initialOptions, callback)
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
    lbl.TextStrokeTransparency = 1
    lbl.Parent = f

    local selected = Instance.new("TextButton")
    selected.AnchorPoint = Vector2.new(1, 0.5)
    selected.Position = UDim2.new(1, -12, 0.5, 0)
    selected.Size = UDim2.new(0.48, 0, 0, 22)
    selected.Text = ""
    selected.BackgroundColor3 = C.bg4
    selected.BackgroundTransparency = 0
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
    selectedText.ZIndex = 11
    selectedText.Parent = selected

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Text = "▶"
    arrow.TextColor3 = C.accent
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.ZIndex = 11
    arrow.Parent = selected

    local selOverlay = Instance.new("Frame")
    selOverlay.Name = "ClickOverlay"
    selOverlay.Size = UDim2.new(1, 0, 1, 0)
    selOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    selOverlay.BackgroundTransparency = 1
    selOverlay.BorderSizePixel = 0
    selOverlay.ZIndex = 12
    selOverlay.Parent = selected
    Instance.new("UICorner", selOverlay).CornerRadius = UDim.new(0, 4)

    selected.MouseButton1Down:Connect(function() selOverlay.BackgroundTransparency = 0.85 end)
    selected.MouseButton1Up:Connect(function()
        S.Services.TS:Create(selOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
    end)
    selected.MouseLeave:Connect(function()
        S.Services.TS:Create(selOverlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
    end)

    local popup = Instance.new("ScrollingFrame")
    popup.Name = "DropdownPopup_" .. name
    popup.BackgroundColor3 = C.bg4
    popup.BackgroundTransparency = 0
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 500
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

    local function updatePopupPosition()
        local pos = selected.AbsolutePosition
        local size = selected.AbsoluteSize
        local popupH = popup.AbsoluteSize.Y
        local mfPos = S.GUI.MainFrame.AbsolutePosition

        if size.X == 0 or size.Y == 0 then return false end

        popup.Size = UDim2.new(0, size.X, 0, popupH)
        local localX = pos.X - mfPos.X
        
        -- SELALU KE ATAS
        local localY = pos.Y - mfPos.Y - popupH - 4

        if localX < 0 then localX = 0 end
        if localX + size.X > S.GUI.MainFrame.AbsoluteSize.X then localX = S.GUI.MainFrame.AbsoluteSize.X - size.X end

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
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = C.text
            optBtn.TextSize = 11
            optBtn.Font = F.norm
            optBtn.TextStrokeTransparency = 1
            optBtn.BackgroundColor3 = C.bg4
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 501
            optBtn.AutoButtonColor = false
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            local optOverlay = Instance.new("Frame")
            optOverlay.Name = "ClickOverlay"
            optOverlay.Size = UDim2.new(1, 0, 1, 0)
            optOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            optOverlay.BackgroundTransparency = 1
            optOverlay.BorderSizePixel = 0
            optOverlay.ZIndex = 502
            optOverlay.Parent = optBtn
            Instance.new("UICorner", optOverlay).CornerRadius = UDim.new(0, 4)

            optBtn.MouseButton1Down:Connect(function() optOverlay.BackgroundTransparency = 0.85 end)
            optBtn.MouseButton1Up:Connect(function()
                S.Services.TS:Create(optOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
            end)
            optBtn.MouseLeave:Connect(function()
                S.Services.TS:Create(optOverlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
            end)

            optBtn.MouseButton1Click:Connect(function()
                selectedText.Text = tostring(opt)
                currentValue = opt
                isOpen = false
                popup.Visible = false
                arrow.Text = "▶"
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
                BackgroundTransparency = 0,
                Position = UDim2.new(popup.Position.X.Scale, popup.Position.X.Offset, 0, startY - 6)
            }):Play()
            arrow.Text = "▼"
        else
            S.Services.TS:Create(popup, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
            task.delay(0.1, function() popup.Visible = false end)
            arrow.Text = "▶"
        end
    end

    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then animatePopup(true) else animatePopup(false) end
    end)

    -- Optimasi RenderStepped
    local renderConn = S.Services.Run.RenderStepped:Connect(function()
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
        if not stillVisible then 
            isOpen = false 
            popup.Visible = false 
            arrow.Text = "▶" 
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
        SetValue = function(v) currentValue = v; selectedText.Text = v end,
        GetValue = function() return currentValue end,
        ClosePopup = function() isOpen = false; popup.Visible = false; arrow.Text = "▼" end
    }
end

-- ============================================================
-- RESIZE HANDLE (LAYER OVERLAY + RESPONSIVE MIN/MAX)
-- ============================================================
function Lib.attachResizeHandle(mainFrame)
    if not mainFrame or not mainFrame.Parent then return end

    local UIS = S.Services.UIS
    local TS = S.Services.TS
    local RunService = S.Services.Run

    -- 🔥 LOGIKA BATAS RESIZE (Dihitung sekali di awal)
    local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
    local minW, minH, maxW, maxH

    if isMobile then
        minW, minH = 380, 250
        maxW, maxH = 800, 600
    else
        minW, minH = 440, 300
        maxW, maxH = 1100, 760
    end

    -- hapus handle lama & layer lama kalau ada
    local oldHandle = mainFrame:FindFirstChild("ResizeHandle")
    if oldHandle then oldHandle:Destroy() end
    local oldLayer = mainFrame.Parent and mainFrame.Parent:FindFirstChild("ResizeHandleLayer")
    if oldLayer then oldLayer:Destroy() end

    -- ============================================================
    -- LAYER OVERLAY (parent = ScreenGui, tidak ke-clip MainFrame)
    -- ============================================================
    local handleLayer = Instance.new("Frame")
    handleLayer.Name = "ResizeHandleLayer"
    handleLayer.Size = UDim2.new(1, 0, 1, 0)
    handleLayer.BackgroundTransparency = 1
    handleLayer.BorderSizePixel = 0
    handleLayer.ClipsDescendants = false
    handleLayer.ZIndex = 9998
    handleLayer.Parent = mainFrame.Parent   -- ScreenGui

    -- ============================================================
    -- HANDLE
    -- ============================================================
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 44, 0, 44)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(0, 0, 0, 0)   -- di-update tiap frame
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 9999
    resizeHandle.Visible = true
    resizeHandle.Parent = handleLayer

    -- arc container 24 (stroke tidak terpotong)
    local arcContainer = Instance.new("Frame")
    arcContainer.Size = UDim2.new(0, 24, 0, 24)
    arcContainer.AnchorPoint = Vector2.new(1, 1)
    arcContainer.Position = UDim2.new(1, 0, 1, 0)
    arcContainer.BackgroundTransparency = 1
    arcContainer.ClipsDescendants = true
    arcContainer.ZIndex = 10000
    arcContainer.Parent = resizeHandle

    -- ring 34x34, anchor (0,0), posisi (-17,-17) → arc muncul di pojok
    local curvedRing = Instance.new("Frame")
    curvedRing.Size = UDim2.new(0, 34, 0, 34)
    curvedRing.AnchorPoint = Vector2.new(0, 0)
    curvedRing.Position = UDim2.new(0, -17, 0, -17)
    curvedRing.BackgroundTransparency = 1
    curvedRing.ZIndex = 10000
    curvedRing.Parent = arcContainer

    local ringStroke = Instance.new("UIStroke")
    ringStroke.Color = Color3.fromRGB(220, 220, 220)
    ringStroke.Thickness = 2.8
    ringStroke.Transparency = 0.45
    ringStroke.Parent = curvedRing

    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = curvedRing

    -- ============================================================
    -- UPDATE POSISI HANDLE (ikut pojok kanan-bawah MainFrame)
    -- ============================================================
    local GAP = 14

    local function updateHandlePosition()
        local mfPos = mainFrame.AbsolutePosition
        local mfSize = mainFrame.AbsoluteSize
        local layerPos = handleLayer.AbsolutePosition

        local localX = (mfPos.X + mfSize.X) - layerPos.X + GAP
        local localY = (mfPos.Y + mfSize.Y) - layerPos.Y + GAP

        resizeHandle.Position = UDim2.new(0, localX, 0, localY)
    end

    local updateConn = RunService.RenderStepped:Connect(updateHandlePosition)
    updateHandlePosition()

    -- ============================================================
    -- AUTO-HIDE (fade stroke, JANGAN set Visible=false)
    -- ============================================================
    local isShowing = true
    local hideTimer = nil
    local IDLE_TIME = 5
    local resizing = false
    local destroyed = false

    local function applyVisualState(show)
        isShowing = show
        if show then
            resizeHandle.Visible = true
            TS:Create(ringStroke, TweenInfo.new(0.2), { Transparency = 0.45 }):Play()
        else
            TS:Create(ringStroke, TweenInfo.new(0.3), { Transparency = 0.85 }):Play()
        end
    end

    local function showHandle()
        if not mainFrame.Visible then return end
        if not isShowing then applyVisualState(true) end
        if hideTimer then pcall(task.cancel, hideTimer) end
        hideTimer = task.delay(IDLE_TIME, function()
            if not resizing and isShowing then applyVisualState(false) end
        end)
    end

    -- ============================================================
    -- RESIZE LOGIC (FIXED)
    -- ============================================================
    local activeInput = nil
    local resizeStart = nil
    local startSize = nil

    resizeHandle.InputBegan:Connect(function(input)
        if destroyed or not mainFrame.Visible then return end
        local it = input.UserInputType
        if it == Enum.UserInputType.MouseButton1 or it == Enum.UserInputType.Touch then
            resizing = true
            activeInput = input
            resizeStart = input.Position
            startSize = mainFrame.AbsoluteSize
            showHandle()
        end
    end)

    local inputChangedConn = UIS.InputChanged:Connect(function(input)
        if not resizing or not activeInput then return end
        local isMouse = activeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = activeInput.UserInputType == Enum.UserInputType.Touch and input == activeInput
        if not isMouse and not isTouch then return end

        local delta = input.Position - resizeStart

        -- Hitung ukuran baru pakai min/max yang udah ditentuin di atas
        local newW = math.clamp(startSize.X + delta.X, minW, maxW)
        local newH = math.clamp(startSize.Y + delta.Y, minH, maxH)

        -- 🔥 EKSEKUSI PERUBAHAN UKURAN (INI YANG TADI HILANG)
        mainFrame.Size = UDim2.new(0, newW, 0, newH)
        updateHandlePosition()
        showHandle()
    end)

    local inputEndedConn = UIS.InputEnded:Connect(function(input)
        if not resizing or not activeInput then return end
        local isMouse = activeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = activeInput.UserInputType == Enum.UserInputType.Touch and input == activeInput
        if isMouse or isTouch then
            resizing = false
            activeInput = nil
            resizeStart = nil
            startSize = nil
            showHandle()
        end
    end)

    local moveConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            showHandle()
        end
    end)

    -- render loop: cek visibility MainFrame
    local renderConn = RunService.RenderStepped:Connect(function()
    if destroyed then return end
    if not mainFrame.Parent then
        resizeHandle.Visible = false
        return
    end
    
    if not mainFrame.Visible then
        resizeHandle.Visible = false
        isShowing = false
        if hideTimer then pcall(task.cancel, hideTimer) hideTimer = nil end
    else
        updateHandlePosition()
    end
end)

    -- cleanup
    local function cleanup()
        if destroyed then return end
        destroyed = true
        resizing = false
        activeInput = nil
        if hideTimer then pcall(task.cancel, hideTimer) end
        updateConn:Disconnect()
        renderConn:Disconnect()
        inputChangedConn:Disconnect()
        inputEndedConn:Disconnect()
        moveConn:Disconnect()
        if handleLayer.Parent then handleLayer:Destroy() end
    end

    resizeHandle.Destroying:Connect(cleanup)
    mainFrame.Destroying:Connect(cleanup)

    applyVisualState(true)

    return resizeHandle
end

-- Tetep export ke S.Comp biar 7_pages.lua ga error
S.Comp = Lib
S.Lib = Lib
