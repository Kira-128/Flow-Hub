--[[
============================================================
  [2] CONFIG — Command An Army
============================================================
]]

local Config = {
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

    Spawn = {
        UnitSlot = 1,
    },

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

    Teleport = {
        OffsetY = 5,
        SupplyTarget = "Enemy",
    },

    Movement = {
        WalkSpeed = 16,
        Noclip = false,
        Fly = false,
        InfJump = false,
        FlySpeed = 60,
        HipHeight = 0,
        JumpPower = 50,
    },

    Misc = {
        AutoJoinTeam = "none",
        AntiAFK = true,
    },

    Config = {
        AutoSave = false,
    },
}

_G.STHAIN.Config = Config
print("[FLOW] Config loaded")
