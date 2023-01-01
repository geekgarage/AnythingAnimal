---------------------------------------------------------
--| List all the animal PEDs you have on your server. |--
--|      All basic GTA animals are listed below!      |--
--|   Anyone with a model listed below will be able   |--
--|       to use animal emotes but not human          |--
---------------------------------------------------------

AnimalPed = {
    "a_c_chop",
    "a_c_coyote",
    "a_c_husky",
    "a_c_mtlion",
    "a_c_poodle",
    "a_c_pug",
    "a_c_retriever",
    "a_c_rottweiler",
    "a_c_shepherd",
    "a_c_westy",
    "ig_geek"
}

Config = {
    -- Health
    UseHealthRegen = true,       -- Enable health regeneration?
    HealthPointsRegenerated = 1, -- Health Points regenerated per second?
    HealthPointsTimer = 2,    -- How often to regenerate in seconds? (no negative values)

    -- Speed 
    SwimMultiplier = 1.00, -- Any value below 1.0 or above 1.49 will be ignored by GTA native functions
    RunSprintMultiplier = 1.00, -- Any value below 1.0 or above 1.49 will be ignored by GTA native functions

    WalkSpeedMin = 0.00, -- Set the adjustable walk speed minimum value
    WalkSpeedMax = 1.20, -- Set the adjustable walk speed maximum value

    InsideRunSpeedMin = 1.20, -- Set the adjustable walk speed minimum value
    InsideRunSpeedMax = 1.90, -- Set the adjustable walk speed maximum value

    OutsideRunSpeedMin = 1.20, -- Set the adjustable walk speed minimum value
    OutsideRunSpeedMax = 1.90, -- Set the adjustable walk speed maximum value


    -- Idle Camera
    DisableIdleCamera = true -- Will disable idle camera for listed PEDs
}