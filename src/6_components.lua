--[[
============================================================
  [6] COMPONENTS (Flow Hub v2.6 FIXED)
  - Dropdown Panah (▼) + UpdateOptions
  - makeText
  - makeSearchDropdown (Floating Panel + Search + UpdateOptions)
  - FIX: makeButton return btn
  - FIX: makeDropdown return updater
  - FIX: makeSearchDropdown return updater
  - FIX: recalcSection hardening
  - FIX: dropdown popup auto-close on outside click
  - FIX: makeSection recalc via return
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

-- Safety fallback warna (buat C.yellow yg mungkin gak ada)
local FALLBACK_YELLOW = C.yellow or Color3.fromRGB(255, 170, 0)
Comp.FallbackYellow = FALLBACK_YELLOW

-- ============================================================
-- HELPER: Recalculate
-- ============================================================
local function recalcSection(card, content)
    if not card or not card.Parent then return end
    if not content.Visible then
        card.Size = UDim2.new(1, 0, 0, HEADER_H)
        return
    end
    local layout = content:FindFirstChildOfClass("UIListLayout")
    local pad = content:FindFirstChildOfClass("UIPadding")
    local padY = 0
    if pad then
        padY = pad.PaddingTop.Offset + pad.PaddingBottom.Offset
    else
        padY = 8
    end
    local totalH = 0
    if layout then totalH = layout.AbsoluteContentSize.Y end
    card.Size = UDim2.new(1, 0, 0, HEADER_H + totalH + padY)
end

local function hookAutoRecalc(card, content)
    content.ChildAdded:Connect(function()
        task.defer(function()
            task.wait(0.02)
            if content.Visible then recalcSection(card, content) end
        end)
    end)
    content.ChildRemoved:Connect(function()
        task.defer(function()
            task.wait(0.02)
            if content.Visible then recalcSection(card, content) end
        end)
    end)
end

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
-- GLOBAL OUTSIDE-CLICK HANDLER (buat nutup dropdown)
-- ============================================================
local openDropdowns = {}

local function closeAllDropdowns(except)
    for popup, closer in pairs(openDropdowns) do
        if popup ~= except and popup.Parent and popup.Visible then
            popup.Visible = false
            if type(closer) == "function" then pcall(closer) end
        end
    end
end

-- Dengarkan klik di luar via UIS (sekali saja)
local uisConn
local function ensureOutsideClickHandler()
    if uisConn then return end
    uisConn = S.Services.UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton2 then
            -- Klik di luar semua dropdown yang terbuka → tutup
            for popup, info in pairs(openDropdowns) do
                if popup.Parent and popup.Visible then
                    local pos = input.Position
                    local popupPos = popup.AbsolutePosition
                    local popupSize = popup.AbsoluteSize
                    local insidePopup =
                        pos.X >= popupPos.X and pos.X <= popupPos.X + popupSize.X and
                        pos.Y >= popupPos.Y and pos.Y <= popupPos.Y + popupSize.Y
                    local btn = info.button
                    local insideBtn = false
                    if btn and btn.Parent then
                        local bPos = btn.AbsolutePosition
                        local bSize = btn.AbsoluteSize
                        insideBtn =
                            pos.X >= bPos.X and pos.X <= bPos.X + bSize.X and
                            pos.Y >= bPos.Y and pos.Y <= bPos.Y + bSize.Y
                    end
                    if not insidePopup and not insideBtn then
                        popup.Visible = false
                        if type(info.onClose) == "function" then pcall(info.onClose) end
                    end
                end
            end
        end
    end)
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
        if not skipCallback then pcall(callback, state) end
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

    return b
end

-- ============================================================
-- BUTTON  ← FIX: sekarang return btn
-- ============================================================
function Comp.makeButton(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, 0, 0, ITEM_H)
    b.Text = name
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent

    b.MouseButton1Click:Connect(function() pcall(callback) end)
    b.MouseEnter:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg4, BackgroundTransparency = 0.6
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
    end)

    return b  -- ← FIX
end

-- ============================================================
-- DROPDOWN (PANAH ▼)  ← FIX: return UpdateOptions
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

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.stroke
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = popup

    local popLayout = Instance.new("UIListLayout")
    popLayout.Padding = UDim.new(0, 2)
    popLayout.Parent = popup

    local popPad = Instance.new("UIPadding")
    popPad.PaddingTop = UDim.new(0, 2)
    popPad.PaddingBottom = UDim.new(0, 2)
    popPad.Parent = popup

    local currentOptions = options
    local currentValue = options[1] or "None"

    local function renderOptions()
        for _, child in pairs(popup:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(currentOptions) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -8, 0, 26)
            optBtn.Text = opt
            optBtn.TextColor3 = (opt == currentValue) and C.accent or C.text
            optBtn.TextSize = 11
            optBtn.Font = F.norm
            optBtn.BackgroundColor3 = C.bg4
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 51
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                selectedText.Text = opt
                popup.Visible = false
                if openDropdowns[popup] then openDropdowns[popup] = nil end
                renderOptions()
                pcall(callback, opt)
            end)
        end
        popup.Size = UDim2.new(1, -8, 0, #currentOptions * 28 + 8)
    end

    renderOptions()

    local isOpen = false
    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            ensureOutsideClickHandler()
            closeAllDropdowns(popup)
            openDropdowns[popup] = { button = selected }
        else
            openDropdowns[popup] = nil
        end
        popup.Visible = isOpen
    end)

    -- Return updater: UpdateOptions(newOptions, keepSelection)
    return function(newOptions, keepSelection)
        if newOptions then
            currentOptions = newOptions
            renderOptions()
        end
        if not keepSelection then
            currentValue = currentOptions[1] or "None"
            selectedText.Text = currentValue
        else
            -- cek apakah currentValue masih ada di list
            local found = false
            for _, o in ipairs(currentOptions) do
                if o == currentValue then found = true break end
            end
            if not found then
                currentValue = currentOptions[1] or "None"
                selectedText.Text = currentValue
            end
        end
    end
end

-- ============================================================
-- SECTION (Bawaan Lama)  ← FIX: recalc return lebih stabil
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
    contentLayout.Padding = UDim.new(0, 0)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 4)
    cPad.PaddingBottom = UDim.new(0, 4)
    cPad.Parent = content

    local isOpen = defaultOpen
    hookAutoRecalc(card, content)

    local function recalc()
        task.defer(function()
            task.wait(0.02)
            recalcSection(card, content)
        end)
    end

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
        recalc()
    end)

    task.defer(function()
        task.wait(0.15)
        if defaultOpen then recalcSection(card, content) end
    end)

    return content, recalc, card, makeDivider
end

-- ============================================================
-- CUSTOM CARD
-- ============================================================
function Comp.makeCustomCard(parent, title)
    local card = Instance.new("Frame")
    card.Name = "CustomCard_" .. title
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = CARD_BG
    card.BackgroundTransparency = CARD_TRANS
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 12)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.Parent = content

    return content
end

-- ============================================================
-- CUSTOM BUTTON  (sudah return btn dari awal)
-- ============================================================
function Comp.makeCustomBtn(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = C.bg4
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Click:Connect(function() pcall(callback) end)
    return b
end

-- ============================================================
-- CUSTOM WARNING BOX
-- ============================================================
function Comp.makeCustomWarn(parent, text)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 0)
    box.BackgroundColor3 = C.bg2
    box.BackgroundTransparency = 0.5
    box.BorderSizePixel = 0
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.stroke
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.textDim
    lbl.TextSize = 10
    lbl.Font = F.norm
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Parent = box

    return box
end

-- ============================================================
-- MAKE TEXT (Buat Deskripsi)
-- ============================================================
function Comp.makeText(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "TextDesc"
    lbl.Size = UDim2.new(1, -24, 0, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or C.textDim2
    lbl.TextSize = 9
    lbl.Font = F.norm
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Parent = parent

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = lbl

    return lbl
end

-- ============================================================
-- SEARCH DROPDOWN (Floating Panel + Search)  ← FIX: return updater
-- ============================================================
function Comp.makeSearchDropdown(parent, name, options, callback)
    local f = Instance.new("Frame")
    f.Name = "SearchDropdown_" .. name
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

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, -12, 0, 22)
    btn.Position = UDim2.new(0.52, 0, 0.5, -11)
    btn.BackgroundColor3 = C.bg4
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local btnText = Instance.new("TextLabel")
    btnText.Size = UDim2.new(1, -24, 1, 0)
    btnText.Position = UDim2.new(0, 8, 0, 0)
    btnText.Text = options[1] or "None"
    btnText.TextColor3 = C.text
    btnText.TextSize = 11
    btnText.Font = F.norm
    btnText.TextXAlignment = Enum.TextXAlignment.Left
    btnText.BackgroundTransparency = 1
    btnText.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = C.textDim
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.Parent = btn

    -- Panel Melayang
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 180, 0, 200)
    panel.Position = UDim2.new(1, -190, 0, 0)
    panel.BackgroundColor3 = C.bg2
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = 100
    panel.Parent = f
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 5)

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.stroke
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = panel

    -- Search Box
    local searchBx = Instance.new("TextBox")
    searchBx.Size = UDim2.new(1, -16, 0, 24)
    searchBx.Position = UDim2.new(0, 8, 0, 8)
    searchBx.BackgroundColor3 = C.bg3
    searchBx.BorderSizePixel = 0
    searchBx.PlaceholderText = "Search..."
    searchBx.Text = ""
    searchBx.TextColor3 = C.text
    searchBx.TextSize = 11
    searchBx.Font = F.norm
    searchBx.ClearTextOnFocus = false
    searchBx.ZIndex = 101
    searchBx.Parent = panel
    Instance.new("UICorner", searchBx).CornerRadius = UDim.new(0, 4)

    -- List Container
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -16, 1, -40)
    listFrame.Position = UDim2.new(0, 8, 0, 36)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 3
    listFrame.ScrollBarImageColor3 = C.accent
    listFrame.ZIndex = 101
    listFrame.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame

    local currentOptions = options
    local currentValue = options[1] or "None"

    local function renderOptions(filter)
        filter = filter or ""
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(currentOptions) do
            if filter == "" or string.find(string.lower(opt), string.lower(filter), 1, true) then
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.Text = opt
                optBtn.TextColor3 = (opt == currentValue) and C.accent or C.text
                optBtn.TextSize = 11
                optBtn.Font = F.norm
                optBtn.BackgroundColor3 = C.bg3
                optBtn.BorderSizePixel = 0
                optBtn.ZIndex = 102
                optBtn.Parent = listFrame
                Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

                optBtn.MouseButton1Click:Connect(function()
                    currentValue = opt
                    btnText.Text = opt
                    panel.Visible = false
                    if openDropdowns[panel] then openDropdowns[panel] = nil end
                    pcall(callback, opt)
                end)
            end
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end

    renderOptions("")

    searchBx:GetPropertyChangedSignal("Text"):Connect(function()
        renderOptions(searchBx.Text)
    end)

    btn.MouseButton1Click:Connect(function()
        local willOpen = not panel.Visible
        if willOpen then
            ensureOutsideClickHandler()
            closeAllDropdowns(panel)
            openDropdowns[panel] = { button = btn }
            searchBx.Text = ""
            renderOptions("")
        else
            openDropdowns[panel] = nil
        end
        panel.Visible = willOpen
    end)

    -- Return updater
    return function(newOptions, keepSelection)
        if newOptions then
            currentOptions = newOptions
            renderOptions(searchBx.Text)
        end
        if not keepSelection then
            currentValue = currentOptions[1] or "None"
            btnText.Text = currentValue
        else
            local found = false
            for _, o in ipairs(currentOptions) do
                if o == currentValue then found = true break end
            end
            if not found then
                currentValue = currentOptions[1] or "None"
                btnText.Text = currentValue
            end
        end
    end
end

S.Comp = Comp
