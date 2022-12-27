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
    HealthPointsTimer = 1000,    -- How often to regenerate in milliseconds? (no negative values)

    -- Stamina
    StaminaRestoreAmount = 1.0, -- Restores 100% stamina
    SpeedMultiplierLand = 1.49, -- Any value below 1.0 or above 1.49 will be ignored by GTA native functions
    SpeedMultiplierWater = 1.00, -- Any value below 1.0 or above 1.49 will be ignored by GTA native functions

    -- Idle Camera
    DisableIdleCamera = true -- Will disable idle camera for listed PEDs
}