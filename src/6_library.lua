--[[
============================================================
  [6] LIBRARY (Flow Hub v3.2 - AUTOMIZE FIXED)
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Library = {}

local ITEM_H = 34
local HEADER_H = 32
local CARD_BG = C.bg3
local CARD_TRANS = 0.15
local POPUP_W = 180
local POPUP_MAX_H = 200

-- ============================================================
-- HELPER: new Instance
-- ============================================================
function Library.new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

-- ============================================================
-- HELPER: Realtime Section Height (v3.2)
-- ============================================================
local function updateSectionHeight(card, content)
    if not card or not card.Parent then return end
    if not content.Visible then
        card.Size = UDim2.new(1, 0, 0, HEADER_H)
        return
    end
    local layout = content:FindFirstChildOfClass("UIListLayout")
    local totalH = 0
    if layout then
        -- AbsoluteContentSize itu udah include UIScale, jadi akurat
        totalH = layout.AbsoluteContentSize.Y
    end
    -- Tambahin 8px buat padding atas-bawah (4px + 4px)
    card.Size = UDim2.new(1, 0, 0, HEADER_H + totalH + 8)
end

local function bindAutoHeight(card, content)
    -- 1. Pantau perubahan ukuran layout (resize, scale, new item)
    local layout = content:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            updateSectionHeight(card, content)
        end)
    end

    -- 2. Pantau perubahan UIScale (kalau window di-scale)
    local uiScale = card:FindFirstChildOfClass("UIScale")
    if uiScale then
        uiScale:GetPropertyChangedSignal("Scale"):Connect(function()
            updateSectionHeight(card, content)
        end)
    end

    -- 3. Pantau item baru
    content.ChildAdded:Connect(function()
        task.defer(function() updateSectionHeight(card, content) end)
    end)

    -- 4. Pantau item yang dihapus
    content.ChildRemoved:Connect(function()
        task.defer(function() updateSectionHeight(card, content) end)
    end)

    -- 5. Pantau perubahan ukuran content itu sendiri (window resize)
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        updateSectionHeight(card, content)
    end)
end

-- ============================================================
-- SECTION
-- ============================================================
function Library.makeSection(parent, title, defaultOpen)
    local card = Library.new("Frame", {
        Name = "Section_" .. title,
        Size = UDim2.new(1, 0, 0, HEADER_H),
        BackgroundColor3 = CARD_BG,
        BackgroundTransparency = CARD_TRANS,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = parent
    })
    Library.new("UICorner", { Parent = card, CornerRadius = UDim.new(0, 6) })

    local header = Library.new("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HEADER_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 2,
        Parent = card
    })

    Library.new("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = title,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = header
    })

    local arrow = Library.new("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        Text = defaultOpen and "▼" or "▶",
        TextColor3 = C.accent,
        TextSize = 10,
        Font = F.bold,
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = header
    })

    local content = Library.new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, HEADER_H),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Visible = defaultOpen,
        ZIndex = 2,
        Parent = card
    })

    Library.new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = content
    })

    Library.new("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = content
    })

    local isOpen = defaultOpen
    bindAutoHeight(card, content)

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
        task.defer(function() updateSectionHeight(card, content) end)
    end)

    -- Initial update
    task.defer(function()
        task.wait(0.15)
        if defaultOpen then updateSectionHeight(card, content) end
    end)

    return content
end

-- ============================================================
-- TOGGLE
-- ============================================================
function Library.makeToggle(parent, name, default, callback)
    local f = Library.new("Frame", {
        Name = "Toggle_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent
    })

    Library.new("TextLabel", {
        Size = UDim2.new(0.7, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = name,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = f
    })

    local b = Library.new("TextButton", {
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -42, 0.5, -9),
        Text = "",
        BackgroundColor3 = default and C.accent or C.bg4,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = f
    })
    Library.new("UICorner", { Parent = b, CornerRadius = UDim.new(1, 0) })

    local knob = Library.new("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
        BackgroundColor3 = C.text,
        BorderSizePixel = 0,
        Parent = b
    })
    Library.new("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local state = default

    local function setState(newState, skipCallback)
        if state == newState then return end
        state = newState
        S.Services.TS:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = state and C.accent or C.bg4 }):Play()
        S.Services.TS:Create(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) }):Play()
        if not skipCallback then pcall(callback, state) end
    end

    b.MouseButton1Click:Connect(function()
        setState(not state, false)
    end)

    return setState
end

-- ============================================================
-- INPUT (Angka)
-- ============================================================
function Library.makeInput(parent, name, default, callback)
    local f = Library.new("Frame", {
        Name = "Input_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent
    })

    Library.new("TextLabel", {
        Size = UDim2.new(0.55, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = name,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = f
    })

    local b = Library.new("TextBox", {
        Size = UDim2.new(0, 55, 0, 22),
        Position = UDim2.new(1, -67, 0.5, -11),
        Text = tostring(default),
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Parent = f
    })
    Library.new("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then pcall(callback, v) else b.Text = tostring(default) end
    end)
end

-- ============================================================
-- TEXT INPUT
-- ============================================================
function Library.makeTextInput(parent, name, default, placeholder, callback, isFullWidth)
    local f = Library.new("Frame", {
        Name = "TextInput_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent
    })

    local labelSize = isFullWidth and UDim2.new(0, 80, 1, 0) or UDim2.new(0.5, -12, 1, 0)
    Library.new("TextLabel", {
        Size = labelSize,
        Position = UDim2.new(0, 12, 0, 0),
        Text = name,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = f
    })

    local b
    if isFullWidth then
        b = Library.new("TextBox", {
            Size = UDim2.new(1, -12, 0, 22),
            Position = UDim2.new(0, 6, 0.5, -11),
            Text = tostring(default or ""),
            PlaceholderText = placeholder or "",
            PlaceholderColor3 = C.textDim2,
            TextColor3 = C.text,
            TextSize = 11,
            Font = F.norm,
            BackgroundColor3 = C.bg4,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Parent = f
        })
    else
        b = Library.new("TextBox", {
            Size = UDim2.new(0, 130, 0, 22),
            Position = UDim2.new(1, -142, 0.5, -11),
            Text = tostring(default or ""),
            PlaceholderText = placeholder or "",
            PlaceholderColor3 = C.textDim2,
            TextColor3 = C.text,
            TextSize = 11,
            Font = F.norm,
            BackgroundColor3 = C.bg4,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Parent = f
        })
    end
    Library.new("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })

    b.FocusLost:Connect(function()
        pcall(callback, b.Text)
    end)

    return b
end

-- ============================================================
-- BUTTON
-- ============================================================
function Library.makeButton(parent, name, callback)
    local wrapper = Library.new("Frame", {
        Name = "BtnWrapper_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local b = Library.new("TextButton", {
        Name = "Button_" .. name,
        Size = UDim2.new(1, -12, 1, -6),
        Position = UDim2.new(0, 6, 0, 3),
        Text = name,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        BackgroundColor3 = C.bg4,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = wrapper
    })
    Library.new("UICorner", { Parent = b, CornerRadius = UDim.new(0, 5) })

    local flash = Library.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = b
    })
    Library.new("UICorner", { Parent = flash, CornerRadius = UDim.new(0, 5) })

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
        S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1 }):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = C.bg4, BackgroundTransparency = 0.3 }):Play()
    end)

    return b
end

-- ============================================================
-- DROPDOWN (Lynx Style - v3.1)
-- ============================================================
Library._dropdownOverlay = nil
Library._dropdownPanel = nil
Library._dropdownFolder = nil
Library._dropdownPageLayout = nil
Library._dropdownCount = 0

function Library._initDropdownSystem()
    if Library._dropdownOverlay then return end
    Library._dropdownOverlay = Library.new("Frame", {
        Parent = S.GUI.MainFrame,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.bg,
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 150,
        Name = "DropdownOverlay"
    })

    local closeOverlay = Library.new("TextButton", {
        Parent = Library._dropdownOverlay,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 151
    })

    Library._dropdownPanel = Library.new("Frame", {
        Parent = Library._dropdownOverlay,
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 160, 1, -16),
        Position = UDim2.new(1, 172, 0.5, 0),
        BackgroundColor3 = C.bg2,
        BackgroundTransparency = 0.09,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 152,
        Name = "DropdownPanel"
    })
    Library.new("UICorner", { Parent = Library._dropdownPanel, CornerRadius = UDim.new(0, 6) })
    Library.new("UIStroke", { Parent = Library._dropdownPanel, Color = C.stroke, Thickness = 1, Transparency = 0.45 })

    Library._dropdownFolder = Library.new("Frame", {
        Parent = Library._dropdownPanel,
        Size = UDim2.new(1, -2, 1, 0),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 153,
        Name = "DropdownFolder"
    })

    Library._dropdownPageLayout = Library.new("UIPageLayout", {
        Parent = Library._dropdownFolder,
        EasingDirection = Enum.EasingDirection.InOut,
        EasingStyle = Enum.EasingStyle.Quad,
        TweenTime = 0.01,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Name = "DropdownPageLayout"
    })

    closeOverlay.Activated:Connect(function()
        if Library._dropdownOverlay.Visible then
            Library._dropdownOverlay.BackgroundTransparency = 0.95
            Library._dropdownPanel.Position = UDim2.new(1, 172, 0.5, 0)
            Library._dropdownOverlay.Visible = false
        end
    end)
end

function Library._showDropdown(dropdownContainer)
    Library._initDropdownSystem()
    Library._dropdownOverlay.Visible = true
    Library._dropdownPageLayout:JumpTo(dropdownContainer)
    Library._dropdownOverlay.BackgroundTransparency = 0.95
    Library._dropdownPanel.Position = UDim2.new(1, -11, 0.5, 0)
end

function Library._hideDropdown()
    if Library._dropdownOverlay and Library._dropdownOverlay.Visible then
        Library._dropdownOverlay.BackgroundTransparency = 0.95
        Library._dropdownPanel.Position = UDim2.new(1, 172, 0.5, 0)
        Library._dropdownOverlay.Visible = false
    end
end

function Library.makeDropdown(parent, name, initialOptions, callback)
    Library._initDropdownSystem()
    local dropdownLayoutOrder = Library._dropdownCount
    Library._dropdownCount = Library._dropdownCount + 1

    local f = Library.new("Frame", {
        Name = "Dropdown_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent
    })

    Library.new("TextLabel", {
        Size = UDim2.new(0.5, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = name,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = f
    })

    local selectFrame = Library.new("Frame", {
        Parent = f,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = C.bg2,
        BackgroundTransparency = CARD_TRANS,
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0.48, 0, 0, 22),
        LayoutOrder = dropdownLayoutOrder,
        ZIndex = 8
    })
    Library.new("UICorner", { Parent = selectFrame, CornerRadius = UDim.new(0, 4) })
    Library.new("UIStroke", { Parent = selectFrame, Color = C.stroke, Thickness = 1, Transparency = 0.5 })

    local optionLabel = Library.new("TextLabel", {
        Parent = selectFrame,
        Font = F.bold,
        Text = initialOptions[1] or "Select",
        TextColor3 = C.textDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(1, -24, 1, 0),
        ZIndex = 9
    })

    Library.new("ImageLabel", {
        Parent = selectFrame,
        Image = "rbxassetid://6031091004",
        ImageColor3 = C.accent,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.new(0, 11, 0, 11),
        ZIndex = 9
    })

    local dropdownButton = Library.new("TextButton", {
        Parent = selectFrame,
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 10
    })

    local dropdownContainer = Library.new("Frame", {
        Parent = Library._dropdownFolder,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        LayoutOrder = dropdownLayoutOrder
    })

    local searchBox = Library.new("TextBox", {
        Parent = dropdownContainer,
        PlaceholderText = "Search...",
        Font = F.bold,
        Text = "",
        TextSize = 11,
        TextColor3 = C.text,
        PlaceholderColor3 = C.textDim2,
        BackgroundColor3 = C.bg2,
        BackgroundTransparency = CARD_TRANS,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 24),
        Position = UDim2.new(0, 4, 0, 4),
        ClearTextOnFocus = false,
        ZIndex = 154
    })
    Library.new("UICorner", { Parent = searchBox, CornerRadius = UDim.new(0, 4) })
    Library.new("UIStroke", { Parent = searchBox, Color = C.stroke, Thickness = 1, Transparency = 0.5 })
    Library.new("UIPadding", { Parent = searchBox, PaddingLeft = UDim.new(0, 8) })

    local ROW_H, ROW_GAP = 26, 3
    local ROW_STRIDE = ROW_H + ROW_GAP
    local POOL_SIZE = 18

    local scrollSelect = Library.new("ScrollingFrame", {
        Parent = dropdownContainer,
        Size = UDim2.new(1, -8, 1, -36),
        Position = UDim2.new(0, 4, 0, 32),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 154
    })

    local allOptions, filteredOptions = {}, {}
    local selectedValue = initialOptions[1] or "None"
    local rowPool = {}
    local searchThread = nil
    local poolBuilt = false

    local function applyFilter(query)
        table.clear(filteredOptions)
        if not query or query == "" then
            for i = 1, #allOptions do filteredOptions[i] = allOptions[i] end
            return
        end
        local q = string.lower(query)
        for _, opt in ipairs(allOptions) do
            if string.find(opt.lower, q, 1, true) then
                filteredOptions[#filteredOptions + 1] = opt
            end
        end
    end

    local function ensureOptionsNormalized()
        if poolBuilt then return end
        table.clear(allOptions)
        for _, opt in ipairs(initialOptions) do
            local label = tostring(opt)
            allOptions[#allOptions + 1] = { label = label, value = label, lower = string.lower(label) }
        end
        applyFilter("")
        poolBuilt = true
    end

    local function updateClosedLabel()
        ensureOptionsNormalized()
        local found = nil
        for _, opt in ipairs(allOptions) do
            if opt.value == selectedValue then found = opt.label break end
        end
        optionLabel.Text = found or tostring(selectedValue)
    end

    local function paintRow(row, opt)
        local selected = (opt.value == selectedValue)
        row.ChooseFrame.Size = selected and UDim2.new(0, 3, 0, 16) or UDim2.new(0, 0, 0, 0)
        row.BackgroundColor3 = selected and C.bg3 or C.bg2
        row.BackgroundTransparency = selected and CARD_TRANS or 0.5
        row.OptionText.TextColor3 = selected and C.text or C.textDim
        row.OptionText.Text = opt.label
    end

    local function refreshVisible()
        if not poolBuilt then return end
        local list = filteredOptions
        local total = #list
        local viewH = scrollSelect.AbsoluteSize.Y
        if viewH <= 0 then return end

        local canvasH = total * ROW_STRIDE
        if total > 0 then canvasH = canvasH - ROW_GAP end
        scrollSelect.CanvasSize = UDim2.new(0, 0, 0, canvasH)

        local scrollY = scrollSelect.CanvasPosition.Y
        local firstVisible = math.floor(scrollY / ROW_STRIDE) + 1
        if firstVisible < 1 then firstVisible = 1 end
        local maxVisible = math.floor(viewH / ROW_STRIDE) + 2
        local lastVisible = math.min(total, firstVisible + maxVisible - 1)

        for i = 1, #rowPool do
            local row = rowPool[i]
            local optIndex = firstVisible + i - 1
            if optIndex <= lastVisible then
                local opt = list[optIndex]
                row.Frame.Position = UDim2.new(0, 0, 0, (optIndex - 1) * ROW_STRIDE)
                paintRow(row, opt)
                row.Frame.Visible = true
                row.Index = optIndex
            else
                row.Frame.Visible = false
            end
        end
    end

    local function buildPool()
        if #rowPool > 0 then return end
        for i = 1, POOL_SIZE do
            local rowFrame = Library.new("TextButton", {
                Parent = scrollSelect,
                Size = UDim2.new(1, 0, 0, ROW_H),
                BackgroundColor3 = C.bg2,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Visible = false,
                ZIndex = 155
            })
            Library.new("UICorner", { Parent = rowFrame, CornerRadius = UDim.new(0, 4) })

            local chooseFrame = Library.new("Frame", {
                Parent = rowFrame,
                Size = UDim2.new(0, 0, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundColor3 = C.accent,
                BorderSizePixel = 0,
                ZIndex = 156
            })
            Library.new("UICorner", { Parent = chooseFrame, CornerRadius = UDim.new(1, 0) })

            local optionText = Library.new("TextLabel", {
                Parent = rowFrame,
                Text = "",
                Font = F.bold,
                TextSize = 11,
                TextColor3 = C.textDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -14, 1, 0),
                ZIndex = 156
            })

            rowFrame.MouseEnter:Connect(function()
                if rowFrame.Visible then
                    S.Services.TS:Create(rowFrame, TweenInfo.new(0.15), { BackgroundTransparency = CARD_TRANS - 0.05 }):Play()
                end
            end)
            rowFrame.MouseLeave:Connect(function()
                if rowFrame.Visible then
                    paintRow({ Frame = rowFrame, ChooseFrame = chooseFrame, OptionText = optionText, Index = nil }, filteredOptions[1] or {value = "None", label = "None"})
                end
            end)

            rowFrame.MouseButton1Click:Connect(function()
                local rowData = rowPool[i]
                if not rowData or not rowData.Index then return end
                local opt = filteredOptions[rowData.Index]
                if not opt then return end
                selectedValue = opt.value
                updateClosedLabel()
                Library._hideDropdown()
                pcall(callback, opt.value)
            end)

            table.insert(rowPool, {
                Frame = rowFrame,
                ChooseFrame = chooseFrame,
                OptionText = optionText,
                Index = nil,
            })
        end
    end

    scrollSelect:GetPropertyChangedSignal("CanvasPosition"):Connect(refreshVisible)
    scrollSelect:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshVisible)

    dropdownButton.MouseButton1Click:Connect(function()
        ensureOptionsNormalized()
        buildPool()
        updateClosedLabel()
        Library._showDropdown(dropdownContainer)
        task.defer(refreshVisible)
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = searchBox.Text
        if searchThread then pcall(task.cancel, searchThread) searchThread = nil end
        searchThread = task.delay(0.1, function()
            searchThread = nil
            applyFilter(text)
            refreshVisible()
        end)
    end)

    ensureOptionsNormalized()
    updateClosedLabel()

    task.defer(function()
        buildPool()
        refreshVisible()
    end)

    return {
        UpdateOptions = function(options)
            initialOptions = options
            table.clear(allOptions)
            for _, opt in ipairs(options) do
                local label = tostring(opt)
                allOptions[#allOptions + 1] = { label = label, value = label, lower = string.lower(label) }
            end
            updateClosedLabel()
            applyFilter(searchBox.Text)
            refreshVisible()
        end,
        SetValue = function(v)
            selectedValue = v
            updateClosedLabel()
            refreshVisible()
        end,
        GetValue = function() return selectedValue end,
        ClosePopup = function() Library._hideDropdown() end
    }
end

-- ============================================================
-- RESIZE HANDLE
-- ============================================================
function Library.attachResizeHandle(mainFrame)
    local handle = Library.new("TextButton", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderSizePixel = 0,
        Text = "◢",
        TextColor3 = C.accent,
        TextSize = 10,
        Font = F.bold,
        ZIndex = 100,
        Parent = mainFrame
    })
    Library.new("UICorner", { Parent = handle, CornerRadius = UDim.new(0, 3) })

    local dragging = false
    local startPos, startSize

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            startSize = mainFrame.AbsoluteSize
        end
    end)
    S.Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            local newW = math.max(300, startSize.X + delta.X)
            local newH = math.max(200, startSize.Y + delta.Y)
            mainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
    S.Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return handle
end

S.Comp = Library
