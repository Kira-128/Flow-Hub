--[[
============================================================
  [5] GUI (Flow Hub v3.7)
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font
local UIS = game:GetService("UserInputService")

-- Deteksi Platform
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Anti-Crash gethui
local parentGui
local ok, hui = pcall(function() return gethui and gethui() end)
if ok and hui then parentGui = hui else parentGui = game:GetService("CoreGui") end

local oldGui = parentGui:FindFirstChild("FlowHub")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FlowHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui

-- ============================================================
-- FLOAT BUTTON (KOTAK 48x48 + LOGO FULL)
-- ============================================================
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "FloatBtn"
floatBtn.Size = UDim2.new(0, 48, 0, 48)
floatBtn.Position = UDim2.new(0, 30, 0.5, -24)
floatBtn.Text = ""
floatBtn.BackgroundTransparency = 1
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = false
floatBtn.Active = true
floatBtn.ZIndex = 100
floatBtn.Parent = gui

local fBg = Instance.new("Frame")
fBg.Name = "FloatBg"
fBg.Size = UDim2.new(1, 0, 1, 0)
fBg.BackgroundColor3 = C.bg2
fBg.BackgroundTransparency = 0.1
fBg.BorderSizePixel = 0
fBg.Active = false
fBg.ZIndex = 100
fBg.Parent = floatBtn
Instance.new("UICorner", fBg).CornerRadius = UDim.new(0, 12)

local fIcon = Instance.new("ImageLabel")
fIcon.Name = "FloatLogo"
fIcon.Size = UDim2.new(1, 0, 1, 0) 
fIcon.Position = UDim2.new(0, 0, 0, 0) 
fIcon.BackgroundTransparency = 1
fIcon.BorderSizePixel = 0
fIcon.Image = I.logo
fIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
fIcon.ScaleType = Enum.ScaleType.Fit
fIcon.Active = false
fIcon.ZIndex = 101
fIcon.Parent = fBg

-- ============================================================
-- FLOAT BUTTON DRAG LOGIC
-- ============================================================
local iconConns = {}
local savedIconPos = floatBtn.Position
local iconDragging = false
local iconDragStart = nil
local iconStartPos = nil
local iconDragMoved = false
local dragThreshold = 6

local function disconnectIconConns()
    for i = #iconConns, 1, -1 do
        local c = iconConns[i]
        iconConns[i] = nil
        pcall(function() c:Disconnect() end)
    end
end

-- 1. DETEKSI AWAL
iconConns[#iconConns + 1] = floatBtn.InputBegan:Connect(function(input)
    if iconDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconDragMoved = false
        iconDragStart = input.Position
        iconStartPos = floatBtn.Position
    end
end)

-- 2. DETEKSI PERGERAKAN
iconConns[#iconConns + 1] = UIS.InputChanged:Connect(function(input)
    if not iconDragging or not floatBtn or not floatBtn.Parent or not iconStartPos or not iconDragStart then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - iconDragStart
        if delta.Magnitude > dragThreshold then
            iconDragMoved = true
        end
        floatBtn.Position = UDim2.new(
            iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X,
            iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y
        )
    end
end)

-- 3. DETEKSI LEPAS
iconConns[#iconConns + 1] = UIS.InputEnded:Connect(function(input)
    if not iconDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = false
        if floatBtn and floatBtn.Parent then
            savedIconPos = floatBtn.Position
            if not iconDragMoved then
                floatBtn.Visible = false
                if S.GUI and S.GUI.MainFrame then
                    S.GUI.MainFrame.Visible = true
                end
            end
        end
    end
end)

_G.FlowHubSavedIconPos = savedIconPos

-- ============================================================
-- MAIN FRAME (RESPONSIVE SIZE)
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"

-- 🔥 UKURAN KHUSUS PC & HP
if isMobile then
    mainFrame.Size = UDim2.new(0, 450, 0, 300) -- Ukuran HP
else
    mainFrame.Size = UDim2.new(0, 560, 0, 360) -- Ukuran PC
end

-- Biar posisinya selalu di tengah
local startSize = mainFrame.Size
mainFrame.Position = UDim2.new(0.5, -(startSize.X.Offset / 2), 0.5, -(startSize.Y.Offset / 2))

mainFrame.BackgroundColor3 = C.panel
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local mStroke = Instance.new("UIStroke")
mStroke.Color = C.stroke
mStroke.Thickness = 1
mStroke.Transparency = 0.3
mStroke.Parent = mainFrame

-- ============================================================
-- HEADER
-- ============================================================
local HEADER_H = 36

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = C.bg2
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Active = true
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 15)
hFix.Position = UDim2.new(0, 0, 1, -15)
hFix.BackgroundColor3 = C.bg2
hFix.BackgroundTransparency = 0.1
hFix.BorderSizePixel = 0
hFix.Parent = header

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

local lIcon = Instance.new("ImageLabel")
lIcon.Name = "LogoHeader"
lIcon.Size = UDim2.new(0, 18, 0, 18)
lIcon.Position = UDim2.new(0, 52, 0.5, -9)
lIcon.BackgroundTransparency = 1
lIcon.BorderSizePixel = 0
lIcon.Image = I.icon
lIcon.ImageColor3 = C.accent
lIcon.ScaleType = Enum.ScaleType.Fit
lIcon.Parent = header

local sep = Instance.new("Frame")
sep.Size = UDim2.new(0, 1, 0, 18)
sep.Position = UDim2.new(0, 78, 0.5, -9)
sep.BackgroundColor3 = C.stroke
sep.BorderSizePixel = 0
sep.Parent = header

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(0, 200, 1, 0)
sub.Position = UDim2.new(0, 88, 0, 0)
sub.Text = "Command An Army"
sub.TextColor3 = C.textDim
sub.TextSize = 10
sub.Font = F.norm
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.BackgroundTransparency = 1
sub.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -30, 0.5, -11)
minBtn.Text = "−"
minBtn.TextColor3 = C.accent
minBtn.TextSize = 14
minBtn.Font = F.bold
minBtn.BackgroundColor3 = C.bg3
minBtn.BackgroundTransparency = 0.2
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-- ============================================================
-- GARIS 1
-- ============================================================
local line1 = Instance.new("Frame")
line1.Name = "HeaderLine"
line1.Size = UDim2.new(1, 0, 0, 1)
line1.Position = UDim2.new(0, 0, 0, HEADER_H)
line1.BackgroundColor3 = C.stroke
line1.BackgroundTransparency = 0.3
line1.BorderSizePixel = 0
line1.Parent = mainFrame

-- ============================================================
-- SEARCH + TITLE + ACCENT LINE + GARIS 2
-- ============================================================
local ROW_Y = HEADER_H + 8

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0.35, 0, 0, 26)
searchFrame.Position = UDim2.new(0, 10, 0, ROW_Y)
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
searchBox.PlaceholderText = "Search feature.."
searchBox.PlaceholderColor3 = C.textDim2
searchBox.TextColor3 = C.text
searchBox.TextSize = 10
searchBox.Font = F.norm
searchBox.BackgroundTransparency = 1
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

local vDivider = Instance.new("Frame")
vDivider.Name = "TitleDivider"
vDivider.Size = UDim2.new(0, 2, 0, 18)
vDivider.Position = UDim2.new(0.35, 10, 0, ROW_Y + 4)
vDivider.BackgroundColor3 = C.accent
vDivider.BorderSizePixel = 0
vDivider.Parent = mainFrame
Instance.new("UICorner", vDivider).CornerRadius = UDim.new(1, 0)

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -200, 0, 26)
cTitle.Position = UDim2.new(0.35, 20, 0, ROW_Y)
cTitle.Text = "Combat"
cTitle.TextColor3 = C.text
cTitle.TextSize = 12
cTitle.Font = F.bold
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.BackgroundTransparency = 1
cTitle.Parent = mainFrame

local line2 = Instance.new("Frame")
line2.Name = "TitleLine"
line2.Size = UDim2.new(1, -200, 0, 1)
line2.Position = UDim2.new(0.35, 20, 0, ROW_Y + 28)
line2.BackgroundColor3 = C.stroke
line2.BackgroundTransparency = 0.3
line2.BorderSizePixel = 0
line2.Parent = mainFrame

-- ============================================================
-- SIDEBAR
-- ============================================================
local SIDEBAR_Y = ROW_Y + 38

local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 120, 1, -(SIDEBAR_Y + 10))
sidebar.Position = UDim2.new(0, 10, 0, SIDEBAR_Y)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 2
sidebar.ScrollBarImageColor3 = C.accent
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
sidebar.ClipsDescendants = true
sidebar.Parent = mainFrame

local sLayout = Instance.new("UIListLayout")
sLayout.Padding = UDim.new(0, 4)
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sLayout.VerticalAlignment = Enum.VerticalAlignment.Top
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Parent = sidebar

local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0, 0)
sPad.PaddingBottom = UDim.new(0, 4)
sPad.Parent = sidebar

-- ============================================================
-- CONTENT PANEL
-- ============================================================
local contentPanel = Instance.new("Frame")
contentPanel.Name = "ContentPanel"
contentPanel.Size = UDim2.new(1, -140, 1, -(SIDEBAR_Y + 10)) 
contentPanel.Position = UDim2.new(0, 130, 0, SIDEBAR_Y)
contentPanel.BackgroundTransparency = 1
contentPanel.BorderSizePixel = 0
contentPanel.ClipsDescendants = true
contentPanel.Parent = mainFrame

local contentScroll = Instance.new("Frame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.Position = UDim2.new(0, 0, 0, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ClipsDescendants = true
contentScroll.Parent = contentPanel

-- ============================================================
-- EXPORT
-- ============================================================
S.GUI = {
    Screen = gui,
    FloatBtn = floatBtn,
    MainFrame = mainFrame,
    Header = header,
    Sidebar = sidebar,
    Content = contentPanel,
    ContentScroll = contentScroll,
    ContentTitle = cTitle,
    TitleLine = line2,
    HeaderLine = line1,
    TitleDivider = vDivider,
    SearchBox = searchBox,
    MinBtn = minBtn,
    CloseBtn = nil,
    IsMobile = isMobile,
}
