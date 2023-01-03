---------------------------------------------------------
--| List all the animal PEDs you have on your server. |--
--|      All basic GTA animals are listed below!      |--
--|   Anyone with a model listed below will be able   |--
--|       to use animal emotes but not human          |--
---------------------------------------------------------

AnimalPed = {
    "a_c_chop",
    "a_c_husky",
    "a_c_poodle",
    "a_c_pug",
    "a_c_retriever",
    "a_c_rottweiler",
    "a_c_shepherd",
    "a_c_westy",
    "ig_geek",
    "ig_geek_k9",
    "ig_geek_gangdog"
}

Config = {
    -- Health
    UseHealthRegen = true,       -- Enable health regeneration?
    HealthPointsRegenerated = 1, -- Health Points regenerated per second?
    HealthPointsTimer = 2,    -- How often to regenerate in seconds? (no negative values)

    --Stamina
    UseStaminaReset = true, -- Resets stamina to full every second

    -- Speed 
    WalkSpeedMin = 0.00, -- Set the adjustable walk speed minimum value
    WalkSpeedMax = 1.20, -- Set the adjustable walk speed maximum value

    InsideRunSpeedMin = 0.60, -- Set the adjustable walk speed minimum value
    InsideRunSpeedMax = 1.60, -- Set the adjustable walk speed maximum value

    OutsideRunSpeedMin = 0.50, -- Set the adjustable walk speed minimum value
    OutsideRunSpeedMax = 1.30, -- Set the adjustable walk speed maximum value

    SwimSpeedMin = 0.20, -- Set the adjustable swim speed minimum value
    SwimSpeedMax = 0.65, -- Set the adjustable swim speed maximum value

    -- Idle Camera
    DisableIdleCamera = true -- Will disable idle camera for listed PEDs
}