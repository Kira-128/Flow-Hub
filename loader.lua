--[[
  FLOW HUB - LOADER (MULTI-REPO FINAL FIX)
============================================================
]]

local BASE_GUI   = "https://raw.githubusercontent.com/Kira-128/Flow-GUI/main/src/"
local BASE_LOGIC = "https://raw.githubusercontent.com/Kira-128/Flow/main/src/"

local Modules = {
    -- URUTAN 1 SAMPAI 9 (BIAR AMAN & GAK ERROR)
    { name = "1_services",   url = BASE_GUI },
    { name = "2_config",     url = BASE_LOGIC }, -- ✅ Config naik ke atas
    { name = "3_theme",      url = BASE_GUI },
    { name = "4_utils",      url = BASE_GUI },
    { name = "5_gui",        url = BASE_GUI },
    { name = "6_components", url = BASE_GUI },
    { name = "7_pages",      url = BASE_GUI },
    { name = "8_logic",      url = BASE_LOGIC },
    { name = "9_init",       url = BASE_LOGIC },
}

_G.STHAIN = _G.STHAIN or {}
_G.STHAIN.Modules = _G.STHAIN.Modules or {}

local DEBUG = false

local function log(msg)
    if DEBUG then print("[FLOW] " .. tostring(msg)) end
end

-- Bersihin GUI Lama
local CoreGui = game:GetService("CoreGui")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local oldGui1 = CoreGui:FindFirstChild("FlowHub")
if oldGui1 then oldGui1:Destroy() end

local oldGui2 = PlayerGui:FindFirstChild("FlowHub")
if oldGui2 then oldGui2:Destroy() end

_G.STHAIN = nil
_G.STHAIN = { Modules = {} }

local function fetch(url, name)
    local ok, src = pcall(game.HttpGet, game, url .. name .. ".lua")
    if ok and src and #src > 0 then
        log(("[OK] %s (%d bytes)"):format(name, #src))
        return src
    end
    log(("[FAIL] fetch %s"):format(name))
    return nil
end

log("=== LOAD START ===")

for _, mod in ipairs(Modules) do
    local src = fetch(mod.url, mod.name)
    if src then
        local fn, cerr = loadstring(src, "@" .. mod.name .. ".lua")
        if not fn then
            log(("[COMPILE-ERR] %s -> %s"):format(mod.name, tostring(cerr)))
        else
            local ok, rerr = pcall(fn)
            if not ok then
                log(("[RUNTIME-ERR] %s -> %s"):format(mod.name, tostring(rerr)))
            else
                _G.STHAIN.Modules[mod.name] = true
                log(("[EXEC-OK] %s"):format(mod.name))
            end
        end
    end
    task.wait()
end

log("=== LOAD END ===")
