--[[
============================================================
  [9] INIT
============================================================
]]

local S = _G.STHAIN

if S and S.GUI then
    print("[FLOW] Initialized successfully!")
    print("[FLOW] Platform: " .. (S.IsMobile and "Mobile" or "PC"))
else
    warn("[FLOW] Init failed - check modules")
end
