--[[
============================================================
  [2] CONFIG — Command An Army (v2.2 Fixed Sync)
============================================================
]]

local Config = {
    ConfigVersion = 2,

    Combat = {
        AutoAttack = false, AutoRush = false, AutoFollow = false,
        KillAura = false, TargetLock = false, AutoHeal = false, AntiStun = false,
        AttackDelay = 0.35, RushDelay = 0.5, FollowDelay = 0.35,
        KillAuraRange = 20, HealThreshold = 30,
    },

    Spawn = {
        UnitSlot = 1, AutoSpawn = false,
    },

    Visual = {
        Chams = false, ESPSupply = false, ESPCapture = false,
        ESPShowDistance = false, ESPHealth = false, ESPName = false,
        Fullbright = false, NoFog = false,
    },

    Teleport = {
        OffsetY = 5,
        EnemySupplyTarget = "AttackerSupply1",
        OwnerSupplyTarget = "DefenderSupply1",
    },

    Movement = {
        WalkSpeed = 16, EnableRunSpeed = false, Noclip = false,
        Fly = false, InfJump = false, FlySpeed = 60, JumpPower = 50,
    },

    -- UPDATE: Tambahan buat Tab Automation
    Automation = {
        AutoSummon = false,
        SummonAmount = "1x", -- "1x" atau "10x"
        KeepGems = 0,
        AutoAscend = false,
        AutoEvolve = false,
        AutoReward = false,
    },

    Misc = {
        AutoJoinTeam = "none", AntiAFK = true,
    },

    Config = {
        AutoSave = true,
    },
}

-- ============================================================
-- LOAD CONFIG DULUAN SEBELUM UI DIBIKIN (FIX RACE CONDITION)
-- ============================================================
if readfile and isfile then
    local CONFIG_FOLDER = "FlowHub_Configs"
    local CONFIG_FILE = CONFIG_FOLDER .. "/config.json"
    
    if isfile(CONFIG_FILE) then
        local ok, data = pcall(readfile, CONFIG_FILE)
        if ok and data and #data > 0 then
            local Http = game:GetService("HttpService")
            local ok2, decoded = pcall(function() return Http:JSONDecode(data) end)
            
            if ok2 and type(decoded) == "table" then
                local savedVersion = decoded.ConfigVersion or 1
                local currentVersion = Config.ConfigVersion or 2
                
                -- Kalau versi save-an lama, hapus aja biar reset ke default
                if savedVersion < currentVersion then
                    pcall(function() delfile(CONFIG_FILE) end)
                else
                    -- Merge config dari file JSON ke tabel default
                    for category, values in pairs(decoded) do
                        if Config[category] and type(values) == "table" then
                            for key, val in pairs(values) do
                                -- Cek biar ga ada key aneh/typo yang masuk
                                if Config[category][key] ~= nil then
                                    Config[category][key] = val
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Export ke Global SETELAH config ke-load semua
_G.STHAIN.Config = Config
