--[[
============================================================
  [6] LIBRARY (Flow Hub v7.5 - FINAL STABLE)
  - Dropdown System: 100% Logic Lynx (Anti-Double Highlight)
  - Anti-Cursor | (ReleaseFocus on Scroll/Drag)
  - Section Auto-Height FIXED (No more flicker)
  - Button Spacing Tweak (Lebih rapat)
  - Memory Leak FIXED
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

-- ============================================================
-- REGISTRY (Buat Refresh Config)
-- ============================================================
local ToggleRegistry = {}
local InputRegistry = {}
local DropdownRegistry = {}

function Library.RefreshAll()
    -- 1. Refresh Toggles
    for _, entry in pairs(ToggleRegistry) do
        local currentVal = nil
        if S.Config then
            local cat = S.Config[entry.path[1]]
            if cat then currentVal = cat[entry.path[2]] end
        end
        if currentVal ~= nil and entry.setState then
            entry.setState(currentVal == true, true)
        end
    end
    -- 2. Refresh Inputs
    for _, entry in pairs(InputRegistry) do
        local currentVal = nil
        if S.Config then
            local cat = S.Config[entry.path[1]]
            if cat then currentVal = cat[entry.path[2]] end
        end
        if currentVal ~= nil and entry.box then
            entry.box.Text = tostring(currentVal)
        end
    end
    -- 3. Refresh Dropdowns
    for _, entry in pairs(DropdownRegistry) do
        local currentVal = nil
        if S.Config then
            local cat = S.Config[entry.path[1]]
            if cat then currentVal = cat[entry.path[2]] end
        end
        if currentVal ~= nil and entry.setState then
            entry.setState(currentVal)
        end
    end
end

-- ============================================================
-- UI SCALE
-- ============================================================
function Library.setUIScale(scale)
    if not S.GUI or not S.GUI.MainFrame then return end
    local mainFrame = S.GUI.MainFrame
    local uiScale = mainFrame:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Parent = mainFrame
    end
    uiScale.Scale = math.clamp(scale, 0.5, 2.0)
end

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
-- SECTION (Auto-Height FIXED)
-- ============================================================
function Library.makeSection(parent, title, defaultOpen)
    local card = Library.new("Frame", {
        Name = "Section_" .. title,
        Size = UDim2.new(1, 0, 0, HEADER_H),
        BackgroundColor3 = CARD_BG,
        BackgroundTransparency = CARD_TRANS,
        BorderSizePixel = 0,
        ClipsDescendants = false, 
        Parent = parent
    })
    Library.new("UICorner", { Parent = card, CornerRadius = UDim.new(0, 6) })

    local categoryLayout = Library.new("UIListLayout", {
        Parent = card,
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local header = Library.new("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HEADER_H),
        LayoutOrder = 1,
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
        LayoutOrder = 2,
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
    
    local function updateCategoryHeight()
        if not card or not card.Parent then return end
        local contentLayout = content:FindFirstChildOfClass("UIListLayout")
        local contentH = 0
        if isOpen and content.Visible and contentLayout then
            contentH = contentLayout.AbsoluteContentSize.Y + 8
        end
        card.Size = UDim2.new(1, 0, 0, HEADER_H + contentH)
        content.Size = UDim2.new(1, 0, 0, contentH)
    end

    local function setOpen(state)
        isOpen = state
        content.Visible = isOpen
        arrow.Text = isOpen and "▼" or "▶"
        updateCategoryHeight()
    end

    local contentLayout = content:FindFirstChildOfClass("UIListLayout")
    if contentLayout then
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCategoryHeight)
    end
    
    task.defer(updateCategoryHeight)

    header.MouseButton1Click:Connect(function()
        setOpen(not isOpen)
    end)

    return content
end

-- ============================================================
-- TOGGLE
-- ============================================================
function Library.makeToggle(parent, name, default, callback, configPath)
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

    if configPath then
        table.insert(ToggleRegistry, { path = configPath, setState = setState })
    end

    return setState
end

-- ============================================================
-- INPUT
-- ============================================================
function Library.makeInput(parent, name, default, callback, configPath)
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

    if configPath then
        table.insert(InputRegistry, { path = configPath, box = b })
    end
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
-- SLIDER
-- ============================================================
function Library.makeSlider(parent, name, min, max, default, callback)
    local f = Library.new("Frame", {
        Name = "Slider_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent
    })

    Library.new("TextLabel", {
        Size = UDim2.new(0.6, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = name,
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = f
    })

    local valLabel = Library.new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Text = tostring(default),
        TextColor3 = C.accent,
        TextSize = 11,
        Font = F.bold,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Parent = f
    })

    local barBG = Library.new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -50, 0.5, 0),
        Size = UDim2.new(0.4, 0, 0, 6),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = f
    })
    Library.new("UICorner", { Parent = barBG, CornerRadius = UDim.new(1, 0) })

    local fill = Library.new("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = barBG
    })
    Library.new("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

    local knob = Library.new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
        BackgroundColor3 = C.text,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = barBG
    })
    Library.new("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local sliderBtn = Library.new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = barBG
    })

    local isDragging = false
    local currentVal = default
    local connChanged, connEnded

    local function updateValue(x, triggerCallback)
        if not barBG.Parent then return end
        local relX = math.clamp((x - barBG.AbsolutePosition.X) / math.max(barBG.AbsoluteSize.X, 1), 0, 1)
        local val = math.floor(min + (max - min) * relX + 0.5)
        valLabel.Text = tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, 0, 0.5, 0)
        currentVal = val
        if triggerCallback then pcall(callback, val) end
    end

    local function startDrag()
        isDragging = true
        updateValue(S.Services.UIS:GetMouseLocation().X, false)
    end

    local function stopDrag(fireCallback)
        if not isDragging then return end
        isDragging = false
        if fireCallback then pcall(callback, currentVal) end
    end

    sliderBtn.MouseButton1Down:Connect(startDrag)
    sliderBtn.MouseButton1Up:Connect(function() stopDrag(true) end)

    connChanged = S.Services.UIS.InputChanged:Connect(function(input)
        if not isDragging or not barBG.Parent then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            updateValue(input.Position.X, false)
        end
    end)

    connEnded = S.Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            stopDrag(true)
        end
    end)

    f.Destroying:Connect(function()
        if connChanged then connChanged:Disconnect() end
        if connEnded then connEnded:Disconnect() end
        isDragging = false
    end)
end

-- ============================================================
-- BUTTON (SPACING TWEAK - LEBIH RAPAT)
-- ============================================================
function Library.makeButton(parent, name, callback, noHover)
    -- 🔥 Wrapper 32px (jarak lebih rapat dari 34px, tapi tetap lega)
    local wrapper = Library.new("Frame", {
        Name = "BtnWrapper_" .. name,
        Size = UDim2.new(1, 0, 0, 32), 
        BackgroundTransparency = 1,
        Parent = parent
    })

    local b = Library.new("TextButton", {
        Name = "Button_" .. name,
        -- Tombol tetap besar (26px)
        Size = UDim2.new(1, -12, 0, ITEM_H - 8), 
        Position = UDim2.new(0, 6, 0.5, -(ITEM_H - 8)/2), 
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
-- DROPDOWN SYSTEM (PURE LYNX LOGIC)
-- ============================================================
Library._dropdownOverlay = nil
Library._dropdownPanel = nil
Library._dropdownFolder = nil
Library._dropdownPageLayout = nil
Library._dropdownCount = 0

function Library._initDropdownSystem()
    if Library._dropdownOverlay and Library._dropdownOverlay.Parent then return end
    
    Library._dropdownOverlay = Library.new("Frame", {
        Parent = S.GUI.MainFrame,
        Size = UDim2.new(1, 0, 1, -36),           
        Position = UDim2.new(0, 0, 0, 36),         
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
        Size = UDim2.new(0, 180, 1, -16),
        Position = UDim2.new(1, 192, 0.5, 0),
        BackgroundColor3 = C.bg3,              
        BackgroundTransparency = 0.05,
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

    closeOverlay.MouseButton1Click:Connect(function()
        Library._hideDropdown()
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
        Library._dropdownPanel.Position = UDim2.new(1, 192, 0.5, 0)
        Library._dropdownOverlay.Visible = false
    end
end

function Library.makeDropdown(parent, name, initialOptions, callback, configPath)
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
        BackgroundColor3 = C.bg4,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0.48, 0, 0, 22),
        LayoutOrder = dropdownLayoutOrder,
        ZIndex = 8
    })
    Library.new("UICorner", { Parent = selectFrame, CornerRadius = UDim.new(0, 4) })
    Library.new("UIStroke", { Parent = selectFrame, Color = C.stroke, Thickness = 1, Transparency = 0.5 })

    local optionLabel = Library.new("TextLabel", {
        Parent = selectFrame,
        Font = F.norm, 
        Text = initialOptions[1] or "Select",
        TextColor3 = C.text,
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
        LayoutOrder = dropdownLayoutOrder,
        ZIndex = 154
    })

    local searchBox = Library.new("TextBox", {
        Parent = dropdownContainer,
        PlaceholderText = "Search...",
        Font = F.norm, 
        Text = "",
        TextSize = 11,
        TextColor3 = C.text,
        PlaceholderColor3 = C.textDim2,
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 24),
        Position = UDim2.new(0, 4, 0, 4),
        ClearTextOnFocus = false,
        ZIndex = 155
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
        ZIndex = 155
    })

    local allOptions, filteredOptions = {}, {}
    local selectedValue = initialOptions[1] or "None"
    if configPath and S.Config then
        local cat = S.Config[configPath[1]]
        if cat and cat[configPath[2]] then selectedValue = cat[configPath[2]] end
    end

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
            if string.find(opt.lower, q, 1, true) ~= nil then
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
        if selected then
            row.BackgroundColor3 = C.bg3
            row.BackgroundTransparency = 0.1
            row.Highlight.Transparency = 0 
            row.ChooseFrame.Size = UDim2.new(0, 3, 0, 16)
            row.OptionText.TextColor3 = C.accent
        else
            row.BackgroundColor3 = C.bg3
            row.BackgroundTransparency = 1 
            row.Highlight.Transparency = 1 
            row.ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
            row.OptionText.TextColor3 = C.textDim
        end
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
                BackgroundColor3 = C.bg3,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Visible = false,
                ZIndex = 156
            })
            Library.new("UICorner", { Parent = rowFrame, CornerRadius = UDim.new(0, 4) })

            local highlight = Library.new("UIStroke", {
                Parent = rowFrame,
                Color = C.accent,
                Thickness = 1,
                Transparency = 1,
                ZIndex = 156
            })

            local chooseFrame = Library.new("Frame", {
                Parent = rowFrame,
                Size = UDim2.new(0, 0, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundColor3 = C.accent,
                BorderSizePixel = 0,
                ZIndex = 157
            })
            Library.new("UICorner", { Parent = chooseFrame, CornerRadius = UDim.new(1, 0) })

            local optionText = Library.new("TextLabel", {
                Parent = rowFrame,
                Text = "",
                Font = F.norm, 
                TextSize = 11,
                TextColor3 = C.textDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -14, 1, 0),
                ZIndex = 157
            })

            rowFrame.MouseButton1Click:Connect(function()
                local rowData = rowPool[i]
                if not rowData or not rowData.Index then return end
                local opt = filteredOptions[rowData.Index]
                if not opt then return end
                selectedValue = opt.value
                updateClosedLabel()
                Library._hideDropdown()
                
                if configPath and S.Config then
                    local cat = S.Config[configPath[1]]
                    if cat then cat[configPath[2]] = opt.value end
                end
                pcall(callback, opt.value)
                
                task.defer(refreshVisible)
            end)

            table.insert(rowPool, {
                Frame = rowFrame,
                Highlight = highlight,
                ChooseFrame = chooseFrame,
                OptionText = optionText,
                Index = nil,
            })
        end
    end

    -- 🔥 FIX KURSOR: LEPAS FOKUS SAAT SCROLL
    scrollSelect:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if searchBox:IsFocused() then searchBox:ReleaseFocus() end
        refreshVisible()
    end)
    
    scrollSelect:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshVisible)

    dropdownButton.MouseButton1Click:Connect(function()
        ensureOptionsNormalized()
        buildPool()
        updateClosedLabel()
        Library._showDropdown(dropdownContainer)
        if searchBox:IsFocused() then searchBox:ReleaseFocus() end
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

    local controller = {
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

    if configPath then
        table.insert(DropdownRegistry, { path = configPath, setState = controller.SetValue })
    end

    return controller
end

-- ============================================================
-- RESIZE HANDLE
-- ============================================================
function Library.attachResizeHandle(mainFrame)
    if not mainFrame or not mainFrame.Parent then return end

    local UIS = S.Services.UIS
    local TS = S.Services.TS
    local RunService = S.Services.Run

    local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
    local minW, minH, maxW, maxH

    if isMobile then
        minW, minH = 380, 250
        maxW, maxH = 800, 600
    else
        minW, minH = 440, 300
        maxW, maxH = 1100, 760
    end

    local oldHandle = mainFrame:FindFirstChild("ResizeHandle")
    if oldHandle then oldHandle:Destroy() end
    local oldLayer = mainFrame.Parent and mainFrame.Parent:FindFirstChild("ResizeHandleLayer")
    if oldLayer then oldLayer:Destroy() end

    local handleLayer = Instance.new("Frame")
    handleLayer.Name = "ResizeHandleLayer"
    handleLayer.Size = UDim2.new(1, 0, 1, 0)
    handleLayer.BackgroundTransparency = 1
    handleLayer.BorderSizePixel = 0
    handleLayer.ClipsDescendants = false
    handleLayer.ZIndex = 9998
    handleLayer.Active = false
    handleLayer.Parent = mainFrame.Parent

    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 44, 0, 44)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(0, 0, 0, 0)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 9999
    resizeHandle.Visible = true
    resizeHandle.Parent = handleLayer

    local arcContainer = Instance.new("Frame")
    arcContainer.Size = UDim2.new(0, 24, 0, 24)
    arcContainer.AnchorPoint = Vector2.new(1, 1)
    arcContainer.Position = UDim2.new(1, 0, 1, 0)
    arcContainer.BackgroundTransparency = 1
    arcContainer.ClipsDescendants = true
    arcContainer.ZIndex = 10000
    arcContainer.Parent = resizeHandle

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

        local newW = math.clamp(startSize.X + delta.X, minW, maxW)
        local newH = math.clamp(startSize.Y + delta.Y, minH, maxH)

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

S.Comp = Library
