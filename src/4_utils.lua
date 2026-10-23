--[[
============================================================
  [4] UTILS — Command An Army
============================================================
]]

local S = _G.STHAIN
local LP = S.LP

local Utils = {}

function Utils.getChar() return LP.Character end
function Utils.getHRP() local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart") end
function Utils.getHum() local c = LP.Character return c and c:FindFirstChildOfClass("Humanoid") end

function Utils.isEnemy(model)
    if not model or model == LP.Character then return false end
    if not model:IsA("Model") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    if model.Team and LP.Team then
        if model.Team == LP.Team then return false end
    end
    
    return true
end

function Utils.sendKey(k, hold)
    local delay = hold or 0.02
    
    if keypress and keyrelease then
        local keyStr = k.Name:lower()
        local ok = pcall(function() keypress(keyStr) end)
        if ok then
            task.wait(delay)
            pcall(function() keyrelease(keyStr) end)
            return true
        end
    end

    local VIM = S.Services.VIM
    if VIM then
        local ok = pcall(function() VIM:SendKeyEvent(true, k, false, game) end)
        if ok then
            task.wait(delay)
            pcall(function() VIM:SendKeyEvent(false, k, false, game) end)
            return true
        end
    end
    
    return false
end

function Utils.worldToScreen(worldPos)
    local cam = workspace.CurrentCamera
    if not cam then return Vector2.new(0,0), false, 0 end
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local CONFIG_FOLDER = "FlowHub_Configs"
local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"

function Utils.SaveConfig()
    if not writefile then return false end
    if not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
    
    local Http = game:GetService("HttpService")
    local ok = pcall(function()
        writefile(CONFIG_FILE, Http:JSONEncode(_G.STHAIN.Config))
    end)
    return ok
end

function Utils.LoadConfig()
    if not readfile or not isfile then return false end
    if not isfile(CONFIG_FILE) then return false end
    
    local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
    if ok and data and #data > 0 then
        local Http = game:GetService("HttpService")
        local ok2, decoded = pcall(function() return Http:JSONDecode(data) end)
        
        if ok2 and type(decoded) == "table" then
            local savedVersion = decoded.ConfigVersion or 1
            local currentVersion = _G.STHAIN.Config.ConfigVersion or 2
            
            if savedVersion < currentVersion then
                pcall(function() delfile(CONFIG_FILE) end)
                return false
            end
            
            for category, values in pairs(decoded) do
                if _G.STHAIN.Config[category] and type(values) == "table" then
                    for key, val in pairs(values) do
                        if _G.STHAIN.Config[category][key] ~= nil then
                            _G.STHAIN.Config[category][key] = val
                        end
                    end
                end
            end
            return true
        end
    end
    return false
end

function Utils.DeleteConfig()
    local deleted = false
    if delfile and isfile then
        local ok, exist = pcall(isfile, CONFIG_FILE)
        if ok and exist then
            local success = pcall(function() delfile(CONFIG_FILE) end)
            if success then deleted = true end
        end
    end
    if delfolder and isfolder then
        local ok, exist = pcall(isfolder, CONFIG_FOLDER)
        if ok and exist then pcall(function() delfolder(CONFIG_FOLDER) end) end
    end
    return deleted
end

S.Utils = Utils
