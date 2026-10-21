--[[
============================================================
  [2] CONFIG — Command An Army
  Author  : Cabu
  Version : 1.1
============================================================
]]

local Config = {
    -- ========================================================
    -- COMBAT
    -- ========================================================
    Combat = {
        AutoAttack = false,
        AutoRush = false,
        AutoFollow = false,

        KillAura = false,
        TargetLock = false,
        AutoHeal = false,
        AntiStun = false,

        AttackDelay = 0.35,
        RushDelay = 0.5,
        FollowDelay = 0.35,

        KillAuraRange = 20,
        HealThreshold = 30,
    },

    -- ========================================================
    -- SPAWN
    -- ========================================================
    Spawn = {
        UnitSlot = 1,
    },

    -- ========================================================
    -- VISUAL
    -- ========================================================
    Visual = {
        Chams = false,
        ESPSupply = false,
        ESPCapture = false,
        ESPShowDistance = false,
        ESPHealth = false,
        ESPName = false,
        Fullbright = false,
        NoFog = false,
    },

    -- ========================================================
    -- TELEPORT
    -- ========================================================
    Teleport = {
        OffsetY = 5,
        EnemySupplyTarget = "AttackerSupply1",
        OwnerSupplyTarget = "DefenderSupply1",
    },

    -- ========================================================
    -- MOVEMENT
    -- ========================================================
    Movement = {
        WalkSpeed = 16,
        EnableRunSpeed = false, -- ✅ FITUR BARU
        Noclip = false,
        Fly = false,
        InfJump = false,

        FlySpeed = 60,
        -- HipHeight = 0, -- ❌ DIHAPUS
        JumpPower = 50,
    },

    -- ========================================================
    -- MISC
    -- ========================================================
    Misc = {
        AutoJoinTeam = "none",
        AntiAFK = true,
    },

    -- ========================================================
    -- CONFIG
    -- ========================================================
    Config = {
        AutoSave = true, 
    },
}

_G.STHAIN.Config = Config
