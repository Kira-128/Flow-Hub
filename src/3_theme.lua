--[[
============================================================
  [3] THEME — Flow Hub (Mint Accent)
============================================================
]]

local Theme = {
    Colors = {
        -- Background hierarchy (dark grey dari logo)
        bg       = Color3.fromRGB(20, 20, 22),
        bg2      = Color3.fromRGB(26, 26, 28),
        bg3      = Color3.fromRGB(32, 32, 35),
        bg4      = Color3.fromRGB(38, 38, 42),
        panel    = Color3.fromRGB(24, 24, 26),

        -- Accent (mint dari logo Flow Hub)
        accent   = Color3.fromRGB(110, 231, 183),  -- #6EE7B7

        -- Text hierarchy
        text     = Color3.fromRGB(245, 245, 245),
        textDim  = Color3.fromRGB(160, 160, 165),
        textDim2 = Color3.fromRGB(110, 110, 115),

        -- Status colors
        green    = Color3.fromRGB(80, 220, 130),
        red      = Color3.fromRGB(230, 70, 70),
        yellow   = Color3.fromRGB(255, 200, 80),
        blue     = Color3.fromRGB(80, 160, 240),

        -- Border / stroke
        stroke   = Color3.fromRGB(45, 45, 50),
        stroke2  = Color3.fromRGB(58, 58, 64),
    },

    Icons = {
        combat   = "rbxassetid://99199363807265",
        visual   = "rbxassetid://127234874352422",
        settings = "rbxassetid://106205298246017",
        config   = "rbxassetid://112330254035751",
        teleport = "rbxassetid://90293255250749",
        search   = "rbxassetid://72296609649861",

        -- Flow Hub assets
        logo     = "rbxassetid://101516376369531",   -- logo Flow Hub
        icon     = "rbxassetid://80944443292236",    -- icon header
    },

    Font = {
        bold   = Enum.Font.GothamBold,
        norm   = Enum.Font.Gotham,
        medium = Enum.Font.GothamMedium,
    },

    Radius = {
        small  = UDim.new(0, 4),
        medium = UDim.new(0, 6),
        large  = UDim.new(0, 10),
        round  = UDim.new(1, 0),
    },
}

_G.STHAIN.Theme = Theme

print("[FLOW] Theme loaded (Mint Accent)")
