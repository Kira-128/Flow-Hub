--[[
============================================================
  [1] SERVICES + AUTO CONFIG LOADER
============================================================
]]

local Services = {
    Players  = game:GetService("Players"),
    Run      = game:GetService("RunService"),
    VIM      = game:GetService("VirtualInputManager"),
    UIS      = game:GetService("UserInputService"),
    TS       = game:GetService("TweenService"),
    Lighting = game:GetService("Lighting"),
    VU       = game:GetService("VirtualUser"),
}

local LP  = Services.Players.LocalPlayer
local Cam = workspace.CurrentCamera

local IsMobile = Services.UIS.TouchEnabled and not Services.UIS.KeyboardEnabled
local IsPC = Services.UIS.KeyboardEnabled and not Services.UIS.TouchEnabled

_G.STHAIN = _G.STHAIN or {}
_G.STHAIN.Services = Services
_G.STHAIN.LP = LP
_G.STHAIN.Cam = Cam
_G.STHAIN.IsMobile = IsMobile
_G.STHAIN.IsPC = IsPC

-- ============================================================
-- AUTO LOAD CONFIG (BIAR TOGGLE SINKRON PAS PERTAMA JALAN)
-- ============================================================
task.spawn(function()
    task.wait(0.1) -- Tunggu 2_config.lua selesai ke-load
    if not _G.STHAIN.Config then return end

    local CONFIG_FOLDER = "FlowHub_Configs"
    local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

    if readfile and isfile then
        if isfile(CONFIG_FILE) then
            local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
            if ok and data and #data > 0 then
                local Http = game:GetService("HttpService")
                local ok2, decoded = pcall(function() return Http:JSONDecode(data) end)
                
                if ok2 and type(decoded) == "table" then
                    -- Timpa Config Default dengan Config dari File
                    for category, values in pairs(decoded) do
                        if _G.STHAIN.Config[category] then
                            for key, val in pairs(values) do
                                _G.STHAIN.Config[category][key] = val
                            end
                        end
                    end
                end
            end
        end
    end
end)
