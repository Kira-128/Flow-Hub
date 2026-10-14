--[[
============================================================
  [5] GUI (Flow Hub Style)
  Header: Flow [icon] | Command An Army
  Content title sejajar search
  Background transparan
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local gui = Instance.new("ScreenGui")
gui.Name = "FlowHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ============================================================
-- FLOAT BUTTON
-- ============================================================
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 48, 0, 48)
floatBtn.Position = UDim2.new(0, 30, 0.5, -24)
floatBtn.Text = ""
floatBtn.BackgroundTransparency = 1
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = false
floatBtn.Parent = gui

local fIcon = Instance.new("ImageLabel")
fIcon.Name = "FloatLogo"
fIcon.Size = UDim2.new(1, 0, 1, 0)
fIcon.Position = UDim2.new(0, 0, 0, 0)
fIcon.BackgroundTransparency = 1
fIcon.BorderSizePixel = 0
fIcon.Image = I.logo
fIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
fIcon.ScaleType = Enum.ScaleType.Fit
fIcon.Parent = floatBtn

-- DRAG
local dragging, dragStart, startPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = floatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
floatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- ============================================================
-- MAIN FRAME
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 460, 0, 320)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -160)
mainFrame.BackgroundColor3 = C.panel
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local mStroke = Instance.new("UIStroke")
mStroke.Color = C.stroke
mStroke.Thickness = 1
mStroke.Transparency = 0.3
mStroke.Parent = mainFrame

-- ============================================================
-- HEADER — Flow [icon] | Command An Army
-- ============================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = C.bg2
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 15)
hFix.Position = UDim2.new(0, 0, 1, -15)
hFix.BackgroundColor3 = C.bg2
hFix.BackgroundTransparency = 0.1
hFix.BorderSizePixel = 0
hFix.Parent = header

-- TEXT "Flow" (di kiri)
local lText = Instance.new("TextLabel")
lText.Size = UDim2.new(0, 60, 1, 0)
lText.Position = UDim2.new(0, 12, 0, 0)
lText.Text = "Flow"
lText.TextColor3 = C.accent
lText.TextSize = 13
lText.Font = F.bold
lText.TextXAlignment = Enum.TextXAlignment.Left
lText.BackgroundTransparency = 1
lText.Parent = header

-- ICON (setelah text)
local logoBox = Instance.new("Frame")
logoBox.Name = "LogoBox"
logoBox.Size = UDim2.new(0, 22, 0, 22)
logoBox.Position = UDim2.new(0, 52, 0.5, -11)
logoBox.BackgroundColor3 = C.bg3
logoBox.BackgroundTransparency = 0.2
logoBox.BorderSizePixel = 0
logoBox.Parent = header
Instance.new("UICorner", logoBox).CornerRadius = UDim.new(0, 4)

local lIcon = Instance.new("ImageLabel")
lIcon.Name = "LogoHeader"
lIcon.Size = UDim2.new(1, -4, 1, -4)
lIcon.Position = UDim2.new(0, 2, 0, 2)
lIcon.BackgroundTransparency = 1
lIcon.BorderSizePixel = 0
lIcon.Image = I.icon
lIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
lIcon.ScaleType = Enum.ScaleType.Fit
lIcon.Parent = logoBox

-- SEPARATOR
local sep = Instance.new("Frame")
sep.Size = UDim2.new(0, 1, 0, 18)
sep.Position = UDim2.new(0, 84, 0.5, -9)
sep.BackgroundColor3 = C.stroke
sep.BorderSizePixel = 0
sep.Parent = header

-- GAME NAME
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(0, 200, 1, 0)
sub.Position = UDim2.new(0, 94, 0, 0)
sub.Text = "Command An Army"
sub.TextColor3 = C.textDim
sub.TextSize = 10
sub.Font = F.norm
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.BackgroundTransparency = 1
sub.Parent = header

-- MINIMIZE BUTTON (cuma − )
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -30, 0.5, -11)
minBtn.Text = "−"
minBtn.TextColor3 = C.textDim
minBtn.TextSize = 14
minBtn.Font = F.bold
minBtn.BackgroundColor3 = C.bg3
minBtn.BackgroundTransparency = 0.2
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-- ============================================================
-- SEARCH + CONTENT TITLE (sejajar)
-- ============================================================
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0, 160, 0, 26)
searchFrame.Position = UDim2.new(0, 10, 0, 44)
searchFrame.BackgroundColor3 = C.bg2
searchFrame.BackgroundTransparency = 0.1
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame
Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 5)

local sIcon = Instance.new("ImageLabel")
sIcon.Size = UDim2.new(0, 10, 0, 10)
sIcon.Position = UDim2.new(0, 9, 0.5, -5)
sIcon.BackgroundTransparency = 1
sIcon.Image = I.search
sIcon.ImageColor3 = C.textDim
sIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -30, 1, 0)
searchBox.Position = UDim2.new(0, 26, 0, 0)
searchBox.Text = ""
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = C.textDim2
searchBox.TextColor3 = C.text
searchBox.TextSize = 10
searchBox.Font = F.norm
searchBox.BackgroundTransparency = 1
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

-- CONTENT TITLE (sejajar search, di kanan)
local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -180, 0, 26)
cTitle.Position = UDim2.new(0, 180, 0, 44)
cTitle.Text = "Combat"
cTitle.TextColor3 = C.text
cTitle.TextSize = 12
cTitle.Font = F.bold
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.BackgroundTransparency = 1
cTitle.Parent = mainFrame

local tLine = Instance.new("Frame")
tLine.Size = UDim2.new(0, 25, 0, 2)
tLine.Position = UDim2.new(0, 180, 0, 68)
tLine.BackgroundColor3 = C.accent
tLine.BorderSizePixel = 0
tLine.Parent = mainFrame
Instance.new("UICorner", tLine).CornerRadius = UDim.new(1, 0)

-- ============================================================
-- SIDEBAR
-- ============================================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 120, 1, -110)
sidebar.Position = UDim2.new(0, 10, 0, 78)
sidebar.BackgroundColor3 = C.bg2
sidebar.BackgroundTransparency = 0.1
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local sLayout = Instance.new("UIListLayout")
sLayout.Padding = UDim.new(0, 2)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.Parent = sidebar

local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0, 6)
sPad.PaddingBottom = UDim.new(0, 6)
sPad.Parent = sidebar

-- ============================================================
-- CONTENT PANEL
-- ============================================================
local contentPanel = Instance.new("Frame")
contentPanel.Size = UDim2.new(1, -140, 1, -110)
contentPanel.Position = UDim2.new(0, 130, 0, 78)
contentPanel.BackgroundColor3 = C.bg2
contentPanel.BackgroundTransparency = 0.1
contentPanel.BorderSizePixel = 0
contentPanel.Parent = mainFrame
Instance.new("UICorner", contentPanel).CornerRadius = UDim.new(0, 6)

-- ============================================================
-- EXPORT
-- ============================================================
S.GUI = {
    Screen = gui,
    FloatBtn = floatBtn,
    MainFrame = mainFrame,
    Sidebar = sidebar,
    Content = contentPanel,
    ContentTitle = cTitle,
    TitleLine = tLine,
    MinBtn = minBtn,
    CloseBtn = nil,  -- close dihapus
}
