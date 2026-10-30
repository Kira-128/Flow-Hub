--[[
============================================================
  [6] LIBRARY (Flow Hub v3.0 - AUTOMIZE)
  - Realtime Section Height (no forceFixSection)
  - UIScale support (buat pembesar UI)
  - Resize Handle (pojok kanan bawah)
  - Layout Consistency (semua item ITEM_H)
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
-- HELPER: Realtime Section Height
-- ============================================================
local function updateSectionHeight(card, content)
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

local function bindRealtimeHeight(card, content)
    local layout = content:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            updateSectionHeight(card, content)
        end)
    end
    content.ChildAdded:Connect(function()
        task.defer(function() updateSectionHeight(card, content) end)
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
    bindRealtimeHeight(card, content)

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
        task.defer(function() updateSectionHeight(card, content) end)
    end)

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
-- TEXT INPUT (Bebas Teks, Full Width Sejajar Tombol)
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
-- BUTTON (Kotak + Flash Putih)
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
-- DROPDOWN (Sama persis dengan v2.1, no changes)
-- ============================================================
function Library.makeDropdown(parent, name, initialOptions, callback)
    local f = Library.new("Frame", {
        Name = "Dropdown_" .. name,
        Size = UDim2.new(1, 0, 0, ITEM_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
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

    local DROPDOWN_W = 130

    local selected = Library.new("TextButton", {
        Size = UDim2.new(0, DROPDOWN_W, 0, 22),
        Position = UDim2.new(1, -(DROPDOWN_W + 12), 0.5, -11),
        Text = "",
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 10,
        Parent = f
    })
    Library.new("UICorner", { Parent = selected, CornerRadius = UDim.new(0, 4) })

    Library.new("Frame", {
        Size = UDim2.new(0, 2, 0, 14),
        Position = UDim2.new(0, 6, 0.5, -7),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = selected
    })
    Library.new("UICorner", { Parent = selected:FindFirstChildWhichIsA("Frame"), CornerRadius = UDim.new(1, 0) })

    local selectedText = Library.new("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Text = initialOptions[1] or "None",
        TextColor3 = C.text,
        TextSize = 11,
        Font = F.norm,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = selected
    })

    local arrow = Library.new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        Text = "▼",
        TextColor3 = C.accent,
        TextSize = 10,
        Font = F.bold,
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = selected
    })

    local overlay = Library.new("TextButton", {
        Name = "DropdownOverlay_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        Visible = false,
        ZIndex = 5,
        Parent = S.GUI.MainFrame
    })

    local popup = Library.new("ScrollingFrame", {
        Name = "DropdownPopup_" .. name,
        Size = UDim2.new(0, POPUP_W, 0, POPUP_MAX_H),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = S.GUI.MainFrame
    })
    Library.new("UICorner", { Parent = popup, CornerRadius = UDim.new(0, 5) })
    Library.new("UIListLayout", { Padding = UDim.new(0, 2), Parent = popup })
    Library.new("UIPadding", {
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        Parent = popup
    })

    local currentValue = initialOptions[1] or "None"
    local isOpen = false
    local openTween = nil
    local closeTween = nil

    local function updatePopupPosition()
        local selPos = selected.AbsolutePosition
        local selSize = selected.AbsoluteSize
        local mfPos = S.GUI.MainFrame.AbsolutePosition
        local mfSize = S.GUI.MainFrame.AbsoluteSize
        local popupH = popup.AbsoluteSize.Y

        if popupH == 0 then popupH = POPUP_MAX_H end

        local localX = selPos.X - mfPos.X
        local localY = selPos.Y - mfPos.Y + selSize.Y + 4

        if localY + popupH > mfSize.Y then
            localY = selPos.Y - mfPos.Y - popupH - 4
        end

        if localX + POPUP_W > mfSize.X then
            localX = mfSize.X - POPUP_W - 4
        end
        if localX < 4 then localX = 4 end
        if localY < 4 then localY = 4 end

        popup.Position = UDim2.new(0, localX, 0, localY)
        return true
    end

    local function rebuildOptions(options)
        for _, child in pairs(popup:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(options) do
            local optBtn = Library.new("TextButton", {
                Size = UDim2.new(1, -8, 0, 30),
                LayoutOrder = i,
                Text = "",
                BackgroundColor3 = C.bg4,
                BorderSizePixel = 0,
                ZIndex = 21,
                AutoButtonColor = false,
                Parent = popup
            })
            Library.new("UICorner", { Parent = optBtn, CornerRadius = UDim.new(0, 4) })

            local optAccent = Library.new("Frame", {
                Size = UDim2.new(0, 2, 0, 16),
                Position = UDim2.new(0, 8, 0.5, -8),
                BackgroundColor3 = C.accent,
                BorderSizePixel = 0,
                ZIndex = 22,
                Visible = false,
                Parent = optBtn
            })
            Library.new("UICorner", { Parent = optAccent, CornerRadius = UDim.new(1, 0) })

            local optText = Library.new("TextLabel", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Text = opt,
                TextColor3 = C.text,
                TextSize = 11,
                Font = F.norm,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = 22,
                Parent = optBtn
            })

            optBtn.MouseEnter:Connect(function()
                optAccent.Visible = true
                optText.TextColor3 = C.accent
            end)
            optBtn.MouseLeave:Connect(function()
                if currentValue ~= opt then
                    optAccent.Visible = false
                    optText.TextColor3 = C.text
                end
            end)

            optBtn.MouseButton1Click:Connect(function()
                for _, c in pairs(popup:GetChildren()) do
                    if c:IsA("TextButton") then
                        local acc = c:FindFirstChildWhichIsA("Frame")
                        local txt = c:FindFirstChildWhichIsA("TextLabel")
                        if acc then acc.Visible = false end
                        if txt then txt.TextColor3 = C.text end
                    end
                end
                optAccent.Visible = true
                optText.TextColor3 = C.accent

                selectedText.Text = opt
                currentValue = opt
                closePopup(false)
                pcall(callback, opt)
            end)
        end

        local contentH = #options * 32 + 8
        popup.Size = UDim2.new(0, POPUP_W, 0, math.min(contentH, POPUP_MAX_H))
    end

    local function cancelTweens()
        if openTween then openTween:Cancel() openTween = nil end
        if closeTween then closeTween:Cancel() closeTween = nil end
    end

    function openPopup()
        if isOpen and popup.Visible then return end
        isOpen = true
        cancelTweens()

        updatePopupPosition()
        overlay.Visible = true
        popup.Visible = true
        overlay.BackgroundTransparency = 1
        popup.BackgroundTransparency = 1

        local startY = popup.Position.Y.Offset + 6
        popup.Position = UDim2.new(0, popup.Position.X.Offset, 0, startY)

        openTween = S.Services.TS:Create(popup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, popup.Position.X.Offset, 0, startY - 6)
        })
        openTween:Play()

        S.Services.TS:Create(overlay, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 }):Play()
    end

    function closePopup(instant)
        if not isOpen and not popup.Visible then return end
        isOpen = false
        cancelTweens()

        if instant then
            popup.Visible = false
            overlay.Visible = false
            overlay.BackgroundTransparency = 1
            popup.BackgroundTransparency = 0
        else
            closeTween = S.Services.TS:Create(popup, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1
            })
            closeTween:Play()
            S.Services.TS:Create(overlay, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
            task.delay(0.1, function()
                if not isOpen then
                    popup.Visible = false
                    overlay.Visible = false
                end
            end)
        end
    end

    overlay.MouseButton1Click:Connect(function()
        closePopup(false)
    end)

    selected.MouseButton1Click:Connect(function()
        if isOpen then
            closePopup(false)
        else
            openPopup()
        end
    end)

    S.Services.UIS.InputBegan:Connect(function(input)
        if not isOpen then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local mousePos = input.Position
        local popPos = popup.AbsolutePosition
        local popSize = popup.AbsoluteSize
        local selPos = selected.AbsolutePosition
        local selSize = selected.AbsoluteSize

        local inPopup = mousePos.X >= popPos.X and mousePos.X <= popPos.X + popSize.X
            and mousePos.Y >= popPos.Y and mousePos.Y <= popPos.Y + popSize.Y
        local inSelected = mousePos.X >= selPos.X and mousePos.X <= selPos.X + selSize.X
            and mousePos.Y >= selPos.Y and mousePos.Y <= selPos.Y + selSize.Y

        if not inPopup and not inSelected then closePopup(false) end
    end)

    S.GUI.MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if not S.GUI.MainFrame.Visible then closePopup(true) end
    end)

    rebuildOptions(initialOptions)

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
        ClosePopup = function() closePopup(true) end
    }
end

-- ============================================================
-- RESIZE HANDLE (pojok kanan bawah MainFrame)
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
