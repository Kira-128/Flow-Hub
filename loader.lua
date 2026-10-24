--[[
============================================================
  FLOW HUB - LOADER (TESTER)
  Author  : Cabu
  Version : 1.3 (Config Safe + Clean Console)
============================================================
]]

local BASE = "https://raw.githubusercontent.com/Kira-128/Flow-Hub/main/src/"

local Modules = {
    "1_services",
    "2_config",
    "3_theme",
    "4_utils",
    "5_gui",
    "6_components",
    "7_pages",
    "8_logic",
    "9_init",
}

-- JANGAN reset _G.STHAIN kalau udah ada (biar config ga ilang)
_G.STHAIN = _G.STHAIN or {}
_G.STHAIN.Modules = {}

local DEBUG = false

local function log(msg)
    if DEBUG then print("[FLOW] " .. tostring(msg)) end
end

local CoreGui = game:GetService("CoreGui")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Bersihin GUI lama
local oldGui1 = CoreGui:FindFirstChild("FlowHub")
if oldGui1 then oldGui1:Destroy() end

local oldGui2 = PlayerGui:FindFirstChild("FlowHub")
if oldGui2 then oldGui2:Destroy() end

-- Bersihin Connections lama
if _G.FlowHubConnections then
    for _, conn in pairs(_G.FlowHubConnections) do
        pcall(function() conn:Disconnect() end)
    end
    _G.FlowHubConnections = nil
end

local function fetch(name)
    local ok, src = pcall(game.HttpGet, game, BASE .. name .. ".lua")
    if ok and src and #src > 0 then
        log(("[OK] %s (%d bytes)"):format(name, #src))
        return src
    end
    log(("[FAIL] fetch %s"):format(name))
    return nil
end

log("=== LOAD START ===")

for _, mod in ipairs(Modules) do
    local src = fetch(mod)
    if src then
        local fn, cerr = loadstring(src, "@" .. mod .. ".lua")
        if not fn then
            log(("[COMPILE-ERR] %s -> %s"):format(mod, tostring(cerr)))
        else
            local ok, rerr = pcall(fn)
            if not ok then
                log(("[RUNTIME-ERR] %s -> %s"):format(mod, tostring(rerr)))
            else
                _G.STHAIN.Modules[mod] = true
                log(("[EXEC-OK] %s"):format(mod))
            end
        end
    end
    task.wait()
end

log("=== LOAD END ===")
