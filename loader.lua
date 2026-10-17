--[[
============================================================
  FLOW HUB - LOADER
  Author  : Cabu
  Version : 1.1 (Clean Console)
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

_G.STHAIN = _G.STHAIN or {}
_G.STHAIN.Modules = _G.STHAIN.Modules or {}

-- ✅ Set true kalau lu mau debug (muncul di console)
-- ✅ Set false buat publish (console 100% bersih)
local DEBUG = false

local function log(msg)
    if DEBUG then print("[FLOW] " .. tostring(msg)) end
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
