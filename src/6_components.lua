--[[
============================================================
  [6] COMPONENTS (Flow v5)
  Section = 1 kotak solid, item nyatu dengan divider tipis
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Comp = {}

local DIVIDER_COLOR = C.stroke
local DIVIDER_TRANSP = 0.5

-- Recalc section
local function recalcSection(content)
    if not content or not content.Parent then return end
    local section = content.Parent
    if not section:IsA("Frame") then return end

    if not content.Visible then
        content.Size = UDim2.new(1, 0, 0, 0)
        section.Size = UDim2.new(1, -4, 0, 36)
        return
    end

    local layout = content:FindFirstChildOfClass("UIListLayout")
    local totalH = 0
    if layout then
        totalH = layout.AbsoluteContentSize.Y
    else
        for _, child in pairs(content:GetChildren()) do
            if child:IsA("GuiObject") then
                totalH = totalH + child.Size.Y.Offset
            end
        end
    end

    content.Size = UDim2.new(1, 0, 0, totalH)
    section.Size = UDim2.new(1, -4, 0, 36 + totalH)
end

local function hookAutoRecalc(content)
    content.ChildAdded:Connect(function()
        task.defer(function()
            task.wait(0.02)
            recalcSection(content)
        end)
    end)
end

-- Divider tipis di bawah item
local function addDivider(parent, isLast)
    if isLast then return end
    local d = Instance.new("Frame")
    d.Name = "Divider"
    d.Size = UDim2.new(1, -24, 0, 1)
    d.Position = UDim2.new(0, 12, 1, -1)
    d.BackgroundColor3 = DIVIDER_COLOR
    d.BackgroundTransparency = DIVIDER_TRANSP
    d.BorderSizePixel = 0
    d.Parent = parent
end

-- ============================================================
-- TOGGLE
-- ============================================================
function Comp.makeToggle(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Toggle_" .. name
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 18)
    b.Position = UDim2.new(1, -44, 0.5, -9)
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
    b.MouseButton1Click:Connect(function()
        state = not state
        S.Services.TS:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = state and C.accent or C.bg4
        }):Play()
        S.Services.TS:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        pcall(callback, state)
    end)

    addDivider(f)
end

-- ============================================================
-- INPUT
-- ============================================================
function Comp.makeInput(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Input_" .. name
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 55, 0, 22)
    b.Position = UDim2.new(1, -69, 0.5, -11)
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

    addDivider(f)
end

-- ============================================================
-- BUTTON
-- ============================================================
function Comp.makeButton(parent, name, callback)
    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, 0, 0, 38)
    b.Text = name
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent

    b.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    b.MouseEnter:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg4,
            BackgroundTransparency = 0.7
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        S.Services.TS:Create(b, TweenInfo.new(0.15), {
            BackgroundTransparency = 1
        }):Play()
    end)

    addDivider(b)
end

-- ============================================================
-- DROPDOWN
-- ============================================================
function Comp.makeDropdown(parent, name, options, callback)
    local f = Instance.new("Frame")
    f.Name = "Dropdown_" .. name
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(0.45, 0, 1, 0)
    selected.Position = UDim2.new(0.52, -14, 0, 0)
    selected.Text = options[1] or "None"
    selected.TextColor3 = C.accent
    selected.TextSize = 11
    selected.Font = F.norm
    selected.TextXAlignment = Enum.TextXAlignment.Right
    selected.BackgroundTransparency = 1
    selected.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 1, 0)
    b.Text = ""
    b.BackgroundTransparency = 1
    b.Parent = f

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(1, -4, 0, 0)
    popup.Position = UDim2.new(0, 0, 1, 2)
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
            selected.Text = opt
            popup.Visible = false
            pcall(callback, opt)
        end)
    end
    popup.Size = UDim2.new(1, -4, 0, #options * 28 + 4)

    local isOpen = false
    b.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        popup.Visible = isOpen
    end)

    addDivider(f)
end

-- ============================================================
-- SECTION
-- ============================================================
function Comp.makeSection(parent, title, defaultOpen)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. title
    section.Size = UDim2.new(1, -4, 0, 36)
    section.BackgroundColor3 = C.bg2
    section.BackgroundTransparency = 0.15
    section.BorderSizePixel = 0
    section.Parent = parent
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = DIVIDER_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = section

    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 0)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = section

    -- Header section
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.LayoutOrder = 1
    header.Size = UDim2.new(1, 0, 0, 36)
    header.Text = ""
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Parent = section

    -- Accent line kiri section
    local accLine = Instance.new("Frame")
    accLine.Name = "AccentLine"
    accLine.Size = UDim2.new(0, 3, 0, 16)
    accLine.Position = UDim2.new(0, 12, 0.5, -8)
    accLine.BackgroundColor3 = C.accent
    accLine.BorderSizePixel = 0
    accLine.Parent = header
    Instance.new("UICorner", accLine).CornerRadius = UDim.new(1, 0)

    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.Text = defaultOpen and "▼" or "▶"
    arrow.TextColor3 = C.textDim
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.Parent = header

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -80, 1, 0)
    titleLbl.Position = UDim2.new(0, 24, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = C.text
    titleLbl.TextSize = 12
    titleLbl.Font = F.bold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = header

    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.LayoutOrder = 2
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = false
    content.Visible = defaultOpen
    content.Parent = section

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 0)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local isOpen = defaultOpen

    hookAutoRecalc(content)

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
        task.defer(function()
            task.wait(0.02)
            recalcSection(content)
        end)
    end)

    task.defer(function()
        task.wait(0.15)
        if defaultOpen then recalcSection(content) end
    end)

    return content, function() recalcSection(content) end, section
end

S.Comp = Comp
