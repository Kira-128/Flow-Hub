--[[
============================================================
  [6] COMPONENTS (v3.0 Lynx Style - Modern & Solid)
  - Tombol Solid (Nggak transparan)
  - Dropdown Overlay (Nggak bocor)
  - Auto-Recalc via AutomaticSize (Nggak pusing ngitung manual)
  - Kotak Perhatian (Warning Box) persis Lynx
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font
local TS = S.Services.TS
local UIS = S.Services.UIS

local Comp = {}

-- Warna & Font fallback biar mirip Lynx
local BG_CARD = C.bg3 or Color3.fromRGB(28, 28, 28)
local BG_ITEM = C.bg4 or Color3.fromRGB(38, 38, 38)
local STROKE_COLOR = C.stroke or Color3.fromRGB(60, 60, 60)
local TEXT_COLOR = C.text or Color3.fromRGB(255, 255, 255)
local TEXT_DIM = C.textDim or Color3.fromRGB(200, 200, 200)
local ACCENT = C.accent or Color3.fromRGB(255, 140, 0)

local ITEM_H = 32

-- ============================================================
-- SECTION (Mirip Lynx Category)
-- ============================================================
function Comp.makeSection(parent, title, defaultOpen)
    local card = Instance.new("Frame")
    card.Name = "Section_" .. title
    card.BackgroundColor3 = BG_CARD
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y -- KUNCI: Biar tinggi otomatis nyesuain isi!
    card.ClipsDescendants = false -- Biarin false biar dropdown bisa keluar
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    -- Garis border tipis (UIStroke) kayak Lynx
    local stroke = Instance.new("UIStroke")
    stroke.Color = STROKE_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = card

    -- Header
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 34)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = TEXT_COLOR
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.Text = defaultOpen and "▼" or "▶"
    arrow.TextColor3 = ACCENT
    arrow.TextSize = 10
    arrow.Font = Enum.Font.GothamBold
    arrow.BackgroundTransparency = 1
    arrow.Parent = header

    -- Content Container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 34)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y -- Biar ikut tinggi isi
    content.Visible = defaultOpen
    content.Parent = card

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content
    
    -- Padding bawah biar gak nempel garis
    local cPad = Instance.new("UIPadding")
    cPad.PaddingBottom = UDim.new(0, 8)
    cPad.Parent = content

    local isOpen = defaultOpen
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
    end)

    return content
end

-- ============================================================
-- TOGGLE (Solid & Rapi)
-- ============================================================
function Comp.makeToggle(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 4, 0, 0)
    l.Text = name
    l.TextColor3 = TEXT_COLOR
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 34, 0, 18)
    b.Position = UDim2.new(1, -34, 0.5, -9)
    b.BackgroundColor3 = default and ACCENT or BG_ITEM
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = TEXT_COLOR
    knob.Parent = b
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local function setState(newState, skipCallback)
        if state == newState then return end
        state = newState
        TS:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = state and ACCENT or BG_ITEM}):Play()
        TS:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        if not skipCallback then pcall(callback, state) end
    end

    b.MouseButton1Click:Connect(function() setState(not state, false) end)
    return setState
end

-- ============================================================
-- BUTTON (Solid background & Efek Klik)
-- ============================================================
function Comp.makeButton(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = BG_ITEM
    b.BackgroundTransparency = 0.2
    b.Text = name
    b.TextColor3 = TEXT_COLOR
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    -- Efek Animasi Klik (Persis Lynx)
    b.MouseButton1Click:Connect(function()
        TS:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0, Size = UDim2.new(0.98, 0, 0, 28)}):Play()
        task.wait(0.1)
        pcall(callback)
        TS:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.2, Size = UDim2.new(1, 0, 0, 30)}):Play()
    end)
    
    b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = ACCENT}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play() end)

    return b
end

-- ============================================================
-- INPUT
-- ============================================================
function Comp.makeInput(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 4, 0, 0)
    l.Text = name
    l.TextColor3 = TEXT_COLOR
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0.45, 0, 0, 24)
    b.Position = UDim2.new(0.55, 0, 0.5, -12)
    b.Text = tostring(default)
    b.TextColor3 = TEXT_COLOR
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = BG_ITEM
    b.BackgroundTransparency = 0.3
    b.TextXAlignment = Enum.TextXAlignment.Center
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then pcall(callback, v) else b.Text = tostring(default) end
    end)
    return b
end

-- ============================================================
-- DROPDOWN (Panel Overlay biar gak bocor)
-- ============================================================
function Comp.makeDropdown(parent, name, options, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.ClipsDescendants = false
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 4, 0, 0)
    l.Text = name
    l.TextColor3 = TEXT_COLOR
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0.45, 0, 0, 24)
    selected.Position = UDim2.new(0.55, 0, 0.5, -12)
    selected.BackgroundColor3 = BG_ITEM
    selected.BackgroundTransparency = 0.3
    selected.Text = ""
    selected.AutoButtonColor = false
    selected.Parent = f
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0, 6)

    local selectedText = Instance.new("TextLabel")
    selectedText.Size = UDim2.new(1, -24, 1, 0)
    selectedText.Position = UDim2.new(0, 8, 0, 0)
    selectedText.Text = options[1] or "None"
    selectedText.TextColor3 = TEXT_DIM
    selectedText.TextSize = 11
    selectedText.Font = Enum.Font.GothamBold
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.BackgroundTransparency = 1
    selectedText.Parent = selected

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = ACCENT
    arrow.TextSize = 10
    arrow.BackgroundTransparency = 1
    arrow.Parent = selected

    -- POPUP PANEL
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0.45, 0, 0, 0)
    popup.Position = UDim2.new(0.55, 0, 1, 4)
    popup.BackgroundColor3 = BG_CARD
    popup.Visible = false
    popup.ZIndex = 50
    popup.Parent = f
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color = ACCENT
    stroke.Thickness = 1
    stroke.Parent = popup

    local popLayout = Instance.new("UIListLayout")
    popLayout.Padding = UDim.new(0, 2)
    popLayout.Parent = popup
    
    local popPad = Instance.new("UIPadding")
    popPad.PaddingTop = UDim.new(0, 4)
    popPad.PaddingBottom = UDim.new(0, 4)
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
            optBtn.TextColor3 = (opt == currentValue) and ACCENT or TEXT_COLOR
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.GothamBold
            optBtn.BackgroundColor3 = BG_ITEM
            optBtn.BackgroundTransparency = (opt == currentValue) and 0.5 or 0.2
            optBtn.ZIndex = 51
            optBtn.Parent = popup
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                selectedText.Text = opt
                selectedText.TextColor3 = TEXT_COLOR
                popup.Visible = false
                renderOptions()
                pcall(callback, opt)
            end)
        end
        popup.Size = UDim2.new(0.45, 0, 0, #currentOptions * 28 + 8)
    end

    renderOptions()

    selected.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
    end)

    return function(newOptions, keepSelection)
        if newOptions then currentOptions = newOptions; renderOptions() end
        if not keepSelection then currentValue = currentOptions[1] or "None"; selectedText.Text = currentValue end
    end
end

-- ============================================================
-- MAKE TEXT (Buat Deskripsi / Perhatian)
-- ============================================================
function Comp.makeText(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or TEXT_DIM
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Parent = parent
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = lbl
    return lbl
end

-- ============================================================
-- CUSTOM WARNING BOX (Kotak Perhatian Persis Lynx)
-- ============================================================
function Comp.makeCustomWarn(parent, titleText, contentText)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 0)
    box.BackgroundColor3 = C.bg2 or Color3.fromRGB(20, 20, 20)
    box.BackgroundTransparency = 0.5
    box.BorderSizePixel = 0
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = STROKE_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = box

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ " .. titleText
    title.TextColor3 = Color3.fromRGB(255, 170, 0) -- Kuning
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = box

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Text = contentText
    content.TextColor3 = TEXT_COLOR
    content.TextSize = 10
    content.Font = Enum.Font.Gotham
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Position = UDim2.new(0, 0, 0, 22) -- Jarak dari judul
    content.Parent = box

    return box
end

S.Comp = Comp
