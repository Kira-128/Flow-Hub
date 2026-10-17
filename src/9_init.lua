--[[
============================================================
  [9] INIT
============================================================
]]

local S = _G.STHAIN

-- Ubah jadi true kalau lagi ngetes (biar muncul di console)
-- Biarin false kalau mau publish (console 100% bersih)
local DEBUG = false

local function log(msg)
    if DEBUG then print("[FLOW] " .. tostring(msg)) end
end

local function logWarn(msg)
    if DEBUG then warn("[FLOW] " .. tostring(msg)) end
end

if S and S.GUI then
    log("Initialized successfully!")
    log("Platform: " .. (S.IsMobile and "Mobile" or "PC"))
else
    logWarn("Init failed - check modules")
end
