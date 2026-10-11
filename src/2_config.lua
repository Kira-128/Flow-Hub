--[[
============================================================
  [2] CONFIG
============================================================
]]

local Config = {
    Combat = {
        AutoAttack     = false,
        AutoRush       = false,
        InfAmmo        = false,
        KillAura       = false,
        TargetLock     = false,
        AutoHeal       = false,
        AntiStun       = false,
        AttackDelay    = 0.35,
        RushDelay      = 0.5,
        KillAuraRange  = 20,
        HealThreshold  = 30,
    },
    Movement = {
        Fly       = false,
        Noclip    = false,
        InfJump   = false,
        WalkSpeed = 16,
        HipHeight = 2,
        FlySpeed  = 60,
        JumpPower = 50,
    },
    Visual = {
        -- Master switch
        Chams            = false,

        -- Esp Object (section baru)
        ESPSupply        = false,
        ESPCapture       = false,

        -- Esp Setting (section baru)
        ESPShowDistance  = false,
        ESPHealth        = false,
        ESPName          = false,

        -- Visual lain
        Fullbright       = false,
        NoFog            = false,
        Invisible        = false,
        SelfHitbox       = false,
        EnemyHitbox      = false,
        SelfHitboxSize   = 15,
        EnemyHitboxSize  = 20,
    },
    Misc = {
        WeaponRange     = false,
        AutoTP          = false,
        AntiAFK         = true,
        AutoJoinTeam    = "none",
        RangeMultiplier = 3,
        AutoTPRange     = 100,
    },
    Teleport = {
        Enabled        = false,
        SelectedPoint  = nil,
        SelectedSupply = nil,
        SmoothSteps    = 10,
        OffsetY        = 5,
    },
    Config = {
        AutoSave = false,
    },
}

_G.STHAIN.Config = Config
