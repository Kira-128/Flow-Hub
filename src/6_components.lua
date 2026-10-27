--[[
============================================================
  [6] COMPONENTS (Flow Hub v2.3 - Final Layout)
  - Jarak Item 3px
  - Button Solid + Flash Putih
  - Dropdown Panah ▼
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Comp = {}

local CARD_PADDING = 6
local CARD_BG = C.bg3
local CARD_TRANS = 0.15
local DIVIDER_TRANS = 0.8
local ITEM_H = 34
local HEADER_H = 32

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
    if layout then
        totalH = layout.AbsoluteContentSize.Y
    end
    card.Size = UDim2.new(1, 0, 0, HEADER_H + totalH + 8)
end

-- ============================================================
-- HELPER: Auto recalc
-- ============================================================
local function hookAutoRecalc(card, content)
    content.ChildAdded:Connect(function()
        task.defer(function()
            task.wait(0.02)
            if content.Visible then
                recalcSection(card, content)
            end
        end)
    end)
end

-- ============================================================
-- HELPER: Divider
-- ============================================================
local function makeDivider(parent)
    local d = Instance.new("Frame")
    d.Name = "Divider"
    d.Size = UDim2.new(1, -24, 0, 1)
    d.Position = UDim2.new(0, 12, 0, 0)
    d.BackgroundColor3 = C.stroke
    d.BackgroundTransparency = DIVIDER_TRANS
    d.BorderSizePixel = 0
    d.Parent = parent
    return d
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
        S.Services.TS:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = state and C.accent or C.bg4
        }):Play()
        S.Services.TS:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        if not skipCallback then
            pcall(callback, state)
        end
    end

    b.MouseButton1Click:Connect(function()
        setState(not state, false)
    end)

    return setState
end

-- ============================================================
-- INPUT
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
    b.Size = UDim2.new(0, 55, 0, 22)
    b.Position = UDim2.new(1, -67, 0.5, -11)
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
-- BUTTON (Solid Box + Flash Putih Infinity)
-- ============================================================
function Comp.makeButton(parent, name, callback)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "BtnWrapper_" .. name
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_H)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, -12, 0, ITEM_H - 6) -- Margin 6px kiri kanan
    b.Position = UDim2.new(0, 6, 0.5, -(ITEM_H-6)/2)
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

    -- Efek Flash Putih
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

    b.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    b.MouseEnter:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg3,
            BackgroundTransparency = 0.1
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg4,
            BackgroundTransparency = 0.3
        }):Play()
    end)
end

-- ============================================================
-- DROPDOWN (Dengan Panah ▼)
-- ============================================================
function Comp.makeDropdown(parent, name, options, callback)
    local f = Instance.new("Frame")
    f.Name = "Dropdown_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ClipsDescendants = false
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

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0.45, -12, 0, 22)
    selected.Position = UDim2.new(0.52, 0, 0.5, -11)
    selected.Text = ""
    selected.BackgroundColor3 = C.bg4
    selected.BorderSizePixel = 0
    selected.AutoButtonColor = false
    selected.Parent = f
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 4)

    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -24, 1, 0)
    selectedText.Position = UDim2.new(0, 8, 0, 0)
    selectedText.Text = options[1] or "None"
    selectedText.TextColor3 = C.text
    selectedText.TextSize = 11
    selectedText.Font = F.norm
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.BackgroundTransparency = 1
    selectedText.Parent = selected

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = C.textDim
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.Parent = selected

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

    for i, opt in ipairs(options) do
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
            selectedText.Text = opt
            popup.Visible = false
            pcall(callback, opt)
        end)
    end
    popup.Size = UDim2.new(1, -8, 0, #options * 28 + 4)

    local isOpen = false
    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        popup.Visible = isOpen
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
    arrow.TextColor3 = C.textDim
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
    contentLayout.Padding = UDim.new(0, 3) -- JARAK 3 PIXEL
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
        task.defer(function()
            task.wait(0.02)
            recalcSection(card, content)
        end)
    end)

    task.defer(function()
        task.wait(0.15)
        if defaultOpen then recalcSection(card, content) end
    end)

    return content, function() recalcSection(card, content) end, card, makeDivider
end

S.Comp = Comp
