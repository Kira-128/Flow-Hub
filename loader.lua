--[[
  FLOW HUB - X-RAY DEBUGGER
============================================================
]]

local BASE_GUI   = "https://raw.githubusercontent.com/Kira-128/Flow-GUI/main/src/"
local BASE_LOGIC = "https://raw.githubusercontent.com/Kira-128/Flow/main/src/"

local Modules = {
    { name = "1_services",   url = BASE_GUI },
    { name = "2_config",     url = BASE_LOGIC },
    { name = "3_theme",      url = BASE_GUI },
    { name = "4_utils",      url = BASE_GUI },
    { name = "5_gui",        url = BASE_GUI },
    { name = "6_components", url = BASE_GUI },
    { name = "7_pages",      url = BASE_GUI },
    { name = "8_logic",      url = BASE_LOGIC },
    { name = "9_init",       url = BASE_LOGIC },
}

-- Bikin GUI buat nampilin status
local PG = game.Players.LocalPlayer:WaitForChild("PlayerGui")
if PG:FindFirstChild("FlowXRay") then PG.FlowXRay:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "FlowXRay"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = PG

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(1, -20, 1, -20)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
frame.BackgroundTransparency = 0.1
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.Position = UDim2.new(0, 10, 0, 10)
scroll.BackgroundTransparency = 1
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4

local text = Instance.new("TextLabel", scroll)
text.Size = UDim2.new(1, -10, 0, 0)
text.AutomaticSize = Enum.AutomaticSize.Y
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextSize = 12
text.Font = Enum.Font.Code
text.TextXAlignment = Enum.TextXAlignment.Left
text.TextWrapped = true
text.Text = "=== X-RAY DEBUG START ===\n\n"

local function log(msg, isError)
    if isError then
        text.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    text.Text = text.Text .. msg .. "\n"
end

local function fetch(url, name)
    local fullUrl = url .. name .. ".lua"
    log("Fetching " .. name .. "...")
    
    local ok, src = pcall(game.HttpGet, game, fullUrl)
    if ok and src and #src > 0 then
        log("  -> OK (" .. #src .. " bytes)", false)
        return src
    end
    log("  -> FAILED! (Cek typo nama file / repo)", true)
    task.wait(1)
    return nil
end

_G.STHAIN = { Modules = {} }

for _, mod in ipairs(Modules) do
    local src = fetch(mod.url, mod.name)
    if src then
        local fn, cerr = loadstring(src, "@" .. mod.name .. ".lua")
        if not fn then
            log("  -> COMPILE ERROR: " .. tostring(cerr), true)
        else
            log("  -> Executing " .. mod.name .. "...")
            local ok, rerr = pcall(fn)
            if not ok then
                log("  -> RUNTIME ERROR: " .. tostring(rerr), true)
                task.wait(1)
            else
                log("  -> SUKSES!", false)
            end
        end
    end
    task.wait()
end

log("\n=== LOAD SELESAI ===")
log("Cek apakah GUI Flow Hub muncul & bisa diklik.")
if _G.STHAIN.GUI then
    log("GUI terdeteksi di memori.", false)
else
    log("GUI TIDAK terdeteksi. 5_gui gagal.", true)
end
if _G.STHAIN.Config then
    log("Config terdeteksi di memori.", false)
else
    log("Config TIDAK terdeteksi. 2_config gagal.", true)
end

log("\nLayar ini akan hilang dalam 15 detik...")
task.wait(15)
gui:Destroy()
