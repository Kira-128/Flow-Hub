--[[
============================================================
  [2] CONFIG — Command An Army
  Author  : Cabu
  Version : 1.0
============================================================

  Struktur:
    Combat     → setting auto attack, rush, follow, pvp
    Spawn      → setting spawn unit (slot 1-4)
    Visual     → setting ESP + visual (fullbright, no fog)
    Teleport   → setting teleport (offset, supply target)
    Movement   → setting gerak (speed, fly, noclip, dll)
    Misc       → setting auto join team, anti-afk
    Config     → setting auto save config
============================================================
]]

local Config = {
    -- ========================================================
    -- COMBAT — Setting Combat & PvP
    -- ========================================================
    Combat = {
        -- Auto Combat (spam key)
        AutoAttack = false,   -- Spam V — unit nyerang musuh
        AutoRush   = false,   -- Spam B — unit rush ke point
        AutoFollow = false,   -- Spam C — unit ngikutin player

        -- PvP (spam/trigger otomatis)
        KillAura   = false,   -- Auto attack musuh dalam range
        TargetLock = false,   -- Aimbot — camera lock ke musuh
        AutoHeal   = false,   -- Auto spam H kalau HP rendah
        AntiStun   = false,   -- Cegah stun / ragdoll

        -- Delay (interval spam key, satuan detik)
        AttackDelay = 0.35,   -- Interval spam V
        RushDelay   = 0.5,    -- Interval spam B
        FollowDelay = 0.35,   -- Interval spam C

        -- Parameter PvP
        KillAuraRange = 20,   -- Range Kill Aura (stud)
        HealThreshold = 30,   -- Trigger Auto Heal (% HP)
    },

    -- ========================================================
    -- SPAWN — Setting Spawn Unit
    -- ========================================================
    Spawn = {
        UnitSlot = 1,   -- Slot unit (1-4), dipilih dari dropdown
    },

    -- ========================================================
    -- VISUAL — Setting ESP & Visual
    -- ========================================================
    Visual = {
        -- ESP Master Switch
        Chams = false,   -- Toggle utama ESP (Highlight)

        -- ESP Object (Highlight hijau muda)
        ESPSupply  = false,   -- Highlight supply
        ESPCapture = false,   -- Highlight capture point

        -- ESP Player Setting (Billboard info)
        ESPShowDistance = false,   -- Tampilin jarak (M)
        ESPHealth       = false,   -- Tampilin HP
        ESPName         = false,   -- Tampilin nama player

        -- Visual lain
        Fullbright = false,   -- Lighting terang
        NoFog      = false,   -- Hilangin fog
    },

    -- ========================================================
    -- TELEPORT — Setting Teleport
    -- ========================================================
    Teleport = {
        OffsetY = 5,   -- Offset Y saat TP (biar ga nyangkut)

        -- Target supply (di-populate otomatis dari scan)
        EnemySupplyTarget = "AttackerSupply1",   -- Supply musuh
        OwnerSupplyTarget = "DefenderSupply1",   -- Supply sendiri
    },

    -- ========================================================
    -- MOVEMENT — Setting Gerak
    -- ========================================================
    Movement = {
        WalkSpeed = 16,   -- Kecepatan jalan (default 16)
        Noclip    = false,   -- Tembus dinding
        Fly       = false,   -- Terbang
        InfJump   = false,   -- Infinite jump

        FlySpeed  = 60,   -- Kecepatan fly
        HipHeight = 0,    -- Ketinggian karakter
        JumpPower = 50,   -- Kekuatan lompat
    },

    -- ========================================================
    -- MISC — Setting Misc
    -- ========================================================
    Misc = {
        AutoJoinTeam = "none",   -- "attacker" / "defender" / "none"
        AntiAFK      = true,     -- Anti kick AFK (default ON)
    },

    -- ========================================================
    -- CONFIG — Setting Config
    -- ========================================================
    Config = {
        AutoSave = false,   -- Auto save config ke file
    },
}

_G.STHAIN.Config = Config
print("[FLOW] Config loaded")
