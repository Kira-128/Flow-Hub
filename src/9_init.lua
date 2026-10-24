--[[
============================================================
  [9] INIT — Command An Army
============================================================
]]

local S = _G.STHAIN
if not S then return end

-- Load config kalau ada
task.spawn(function()
    task.wait(0.5)
    if S.Utils and S.Utils.LoadConfig then
        S.Utils.LoadConfig()
    end
end)
