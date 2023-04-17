local animalHashList = {}
local isPlayerAnimal = false
local playerMaxHealth = 200
local runOnce = false
local speedType = nil
local speedValue = nil
local oldSpeedValue = nil
local oldSpeedType = nil

local walkSpeed = GetResourceKvpFloat('AnythingAnimal_WalkSpeed_Float')
local jogSpeed = GetResourceKvpFloat('AnythingAnimal_JogSpeed_Float')
local sprintSpeed = GetResourceKvpFloat('AnythingAnimal_SprintSpeed_Float')
local swimSpeed = GetResourceKvpFloat('AnythingAnimal_SwimSpeed_Float')

if not walkSpeed then
    walkSpeed = Config.WalkSpeedMax
end
if not jogSpeed then
    jogSpeed = Config.JogSpeedMax
end
if not sprintSpeed then
    sprintSpeed = Config.SprintSpeedMax
end
if not swimSpeed then
    swimSpeed = Config.SwimSpeedMax
end

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end
listToNil(AnimalPed)

-- Is Player Animal & Static Updates
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local PlayerPedHash = GetEntityModel(ped)
        local tempAnimalStatus = false

        for _, ListedPedHash in ipairs(animalHashList) do
            if ListedPedHash == PlayerPedHash then
                tempAnimalStatus = true
                break
            end
        end
        isPlayerAnimal = tempAnimalStatus
        if isPlayerAnimal then
            -- Static Updates
            local player = PlayerId()
            SetPlayerLockonRangeOverride(player, 100.0)
            SetPedCombatRange(ped, 2)
            if Config.UseStaminaReset then
                ResetPlayerStamina(player)
            end
        end
        if IsEntityInWater(ped) then -- If In Water
            if not runOnce then
                SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly
                SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
                runOnce = true
            end
        else
            if runOnce then -- If Not In Water
                Wait(1000)
                if not IsEntityInWater(ped) then
                    SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                end
                runOnce = false
            end
        end
        Wait(1000)
    end
end)

-- Health Fixes
CreateThread(function()
    while Config.UseHealthRegen do
        if isPlayerAnimal then
            local ped = PlayerPedId()
            local pedCurrentHealth = GetEntityHealth(ped)
            if pedCurrentHealth < playerMaxHealth and not IsEntityDead(ped) then
                local tempHealth = pedCurrentHealth + Config.HealthPointsRegenerated
                if tempHealth > playerMaxHealth then
                    tempHealth = playerMaxHealth
                end
                SetEntityHealth(ped, tempHealth)
            end
        end
        Wait(Config.HealthPointsTimer*1000)
    end
end)

-- Idlecam
CreateThread(function()
    while Config.DisableIdleCamera do
        if isPlayerAnimal then
            InvalidateIdleCam()
            InvalidateVehicleIdleCam()
        end
        Wait(10000)
    end
end)

-- Main Thread
CreateThread(function()
    while true do
        -- Land and Water speeds
        if isPlayerAnimal then
            local ped = PlayerPedId()
            local player = PlayerId()

            if IsPedOnFoot(ped) then
                if IsEntityInWater(ped) then -- swim
                    speedType = "swim"
                    swimSpeed = UpdateSpeed(swimSpeed, "swim", ped)
                    SetResourceKvpFloat("AnythingAnimal_SwimSpeed_Float", swimSpeed)
                    speedValue = swimSpeed                    
                elseif IsPedSprinting(ped) then -- sprinting
                    speedType = "sprint"
                    sprintSpeed = UpdateSpeed(sprintSpeed, "sprint", ped)
                    SetResourceKvpFloat("AnythingAnimal_SprintSpeed_Float", sprintSpeed)
                    speedValue = sprintSpeed
                elseif IsPedRunning(ped) then -- jogging
                    speedType = "jog"
                    jogSpeed = UpdateSpeed(jogSpeed, "jog", ped)
                    SetResourceKvpFloat("AnythingAnimal_JogSpeed_Float", jogSpeed)
                    speedValue = jogSpeed
                else -- walking
                    speedType = "walk"
                    walkSpeed = UpdateSpeed(walkSpeed, "walk", ped)
                    SetResourceKvpFloat("AnythingAnimal_WalkSpeed_Float", walkSpeed)
                    speedValue = walkSpeed
                end
            end
        end
        Wait(0)
    end
end)


CreateThread(function() --Sync Animation Speed to server and detect player jump
    while true do
        -- Send the speed change event to the server to synchronize with other players
        if (oldSpeedValue ~= speedValue) or (oldSpeedType ~= speedType) and isPlayerAnimal then
            oldSpeedValue = speedValue
            oldSpeedType = speedType
            TriggerServerEvent('AnythingAnimal:syncPlayerMovement', speedType, speedValue, isPlayerAnimal)
            Wait(250)
        end
/*
        --local xyz = GetEntityCoords(ped)
        if IsControlPressed(0, 22) then
            --TriggerServerEvent('JumpPED', isPlayerAnimal, false)
            TaskJump(ped, true)
            Wait(2000)
        end
*/
        Wait(0)
    end
end)

-- Handle the speed change event received from the server
RegisterNetEvent('AnythingAnimal:syncPlayerMovement', function(playerId, speedType, speedValue)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    if DoesEntityExist(targetPed) then
        if speedType == "walk" then
            SetEntityMaxSpeed(targetPed, speedValue)
        elseif speedType == "jog" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
        elseif speedType == "sprint" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
            SetPedMoveRateOverride(targetPed, speedValue)
        elseif speedType == "swim" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
            SetPedMoveRateOverride(targetPed, speedValue)
        end
    end
end)

function UpdateSpeed(speed, speedType, ped)
    local newSpeed = speed
    local increment = 0.01

    if IsControlPressed(0, 96) then -- scroll up / NUM +
        newSpeed += increment
        print(newSpeed)
    elseif IsControlPressed(0, 97) then -- scroll down / NUM -
        newSpeed -= increment
        print(newSpeed)
    end

    -- Clamp and apply speed between min & max
    if speedType == "walk" then
        newSpeed = math.min(math.max(newSpeed, Config.WalkSpeedMin), Config.WalkSpeedMax)
        --SetEntityMaxSpeed(newSpeed)
        SetPedMoveRateOverride(ped, newSpeed)
    elseif speedType == "jog" then
        newSpeed = math.min(math.max(newSpeed, Config.JogSpeedMin), Config.JogSpeedMax)
        --SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(ped, newSpeed)
    elseif speedType == "sprint" then
        newSpeed = math.min(math.max(newSpeed, Config.SprintSpeedMin), Config.SprintSpeedMax)
        --SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(ped, newSpeed)
    elseif speedType == "swim" then
        newSpeed = math.min(math.max(newSpeed, Config.SwimSpeedMin), Config.SwimSpeedMax)
        --SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(ped, newSpeed)
    end

    return newSpeed
end

-- Add Chat commands
RegisterCommand('aawalk', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "walk")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aawalk", "Set walk speed " .. Config.WalkSpeedMin .. " to " .. Config.WalkSpeedMax)

RegisterCommand('aajog', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "jog")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aajog", "Set jog speed " .. Config.JogSpeedMin .. " to " .. Config.JogSpeedMax)

RegisterCommand('aasprint', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "sprint")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aasprint", "Set sprint speed " .. Config.SprintSpeedMin .. " to " .. Config.SprintSpeedMax)


RegisterCommand('aaswim', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "swim")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aaswim", "Set swim speed " .. Config.SwimSpeedMin .. " to " .. Config.SwimSpeedMax)

RegisterCommand('aaspeeds', function(source, args, raw)
    if isPlayerAnimal then
        print("Walk: " .. walkSpeed)
        print("Jog: " .. jogSpeed)
        print("Sprint: " .. sprintSpeed)
        print("Swim: " .. swimSpeed)
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aaspeeds", "Show set speeds")


/*
RegisterNetEvent('GetOffsetInWorld', function()
    local ped = PlayerPedId()
    local offsetPEDCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, Config.JumpDistance, Config.JumpHeight)
    TriggerServerEvent('JumpPED', isPlayerAnimal, offsetPEDCoords)
    --ClearPedTasks(ped)
    --LoadAnim(dict)
    --TaskPlayAnim(ped, ChosenDict, ChosenAnimation, AnimationBlendSpeed, AnimationBlendSpeed, AnimationDuration, MovementType, 0, false, false, false)
    --RemoveAnimDict(ChosenDict)
end)
*/

-- CB from server
RegisterNetEvent('AnythingAnimal:UpdMovementSpeed', function(speed, speedType)
    -- Clamp and apply speed between min & max
    if speedType == "walk" then
        walkSpeed = speed
        SetResourceKvpFloat("AnythingAnimal_WalkSpeed_Float", walkSpeed)
    elseif speedType == "jog" then
        jogSpeed = speed
        SetResourceKvpFloat("AnythingAnimal_JogSpeed_Float", jogSpeed)
    elseif speedType == "sprint" then
        sprintSpeed = speed
        SetResourceKvpFloat("AnythingAnimal_SprintSpeed_Float", sprintSpeed)
    elseif speedType == "swim" then
        swimSpeed = speed
        SetResourceKvpFloat("AnythingAnimal_SwimSpeed_Float", swimSpeed)
    end
end)

-- Exports
exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
    -- print(exports['AnythingAnimal']:getIsPlayerAnimal())

-- Functions
/*
function LoadAnim(dict)
    if not DoesAnimDictExist(dict) then
        return false
    end

    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end

    return true
end
*/

-- DEBUG COMMAND
/*
RegisterCommand('aadebug', function(source, args, raw)
    local player = PlayerId()
    local ped = PlayerPedId()
    local xyz = GetEntityCoords(ped)
    local playerRotation = GetEntityRotation(ped, 2)
    local scriptVersion = GetResourceMetadata("AnythingAnimal", "version", 0)
    print("-------------------------")
    print("--------| DEBUG |--------")
    print("-------------------------")
    print("Version: " .. scriptVersion)
    print(playerRotation)
    print(xyz.z)
    print(currentWaterHeight)
    print((xyz.z-currentWaterHeight))
    print("-------------------------")
    print("---------| END |---------")
    print("-------------------------")
    print(" ")
end, false)
TriggerEvent("chat:addSuggestion", "/aadebug", "No Args")
*/