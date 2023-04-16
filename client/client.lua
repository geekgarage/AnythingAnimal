local animalHashList = {}
local isPlayerAnimal = false
local playerMaxHealth = 200
local runOnce = false
local walkSpeed = GetResourceKvpFloat('AnythingAnimal_WalkSpeed_Float')
local jogSpeed = GetResourceKvpFloat('AnythingAnimal_JogSpeed_Float')
local sprintSpeed = GetResourceKvpFloat('AnythingAnimal_InsideRunSpeed_Float')
local swimSpeed = GetResourceKvpFloat('AnythingAnimal_SwimSpeed_Float')
local speedType = nil
local speedValue = nil

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
            SetPlayerLockonRangeOverride(player, 50.0)
            SetPedCombatRange(ped, 2)
            if Config.UseStaminaReset then
                ResetPlayerStamina(player)
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


    while true do
        -- Land and Water fixes
        if isPlayerAnimal then
            local ped = PlayerPedId()
            local player = PlayerId()
            local xyz = GetEntityCoords(ped)

            if IsEntityInWater(ped) then -- If In Water
                if not runOnce then
                    SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly
                    SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
                    runOnce = true
                end
            else
                if runOnce then -- If Not In Water
                    SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                    runOnce = false
                end
            end

            if IsPedOnFoot(ped) then
                if IsEntityInWater(ped) then -- swim
                    speedType = "swim"
                    sprintSpeed = UpdateSpeed(swimSpeed, "swim")
                    --TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "swim")
                    speedValue = swimSpeed                    
                elseif IsControlPressed(0, 21) then -- sprinting
                    speedType = "sprint"
                    sprintSpeed = UpdateSpeed(sprintSpeed, "sprint")
                    --TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "sprint")
                    speedValue = sprintSpeed
                elseif IsControlPressed(0, 19) then -- jogging
                    speedType = "jog"
                    jogSpeed = UpdateSpeed(jogSpeed, "jog")
                    --TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "jog")
                    speedValue = jogSpeed
                else -- walking
                    speedType = "walk"
                    walkSpeed = UpdateSpeed(walkSpeed, "walk")
                    --TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "walk")
                    speedValue = walkSpeed
                end
                
                if IsControlPressed(0, 22) then
                    --TriggerServerEvent('JumpPED', isPlayerAnimal, false)
                    TaskJump(ped, true)
                    Wait(2000)
                end

                -- Send the speed change event to the server to synchronize with other players
                TriggerServerEvent('syncPlayerMovement', speedType, speedValue, isPlayerAnimal)
            end

            /*
            if IsPedWalking(ped) and IsPedOnFoot(ped) and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
                -- Use / adjust general walk speed
            elseif not IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                -- If inside (in MLO/underground) and shift (sprint) is pressed
            elseif IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                -- If outside and shift (sprint) is pressed
            end
            */
        end
    end
end)

function UpdateSpeed(speed, speedType)
    local newSpeed = speed
    local increment = 0.01

    if IsControlPressed(0, 96) then -- scroll up
        newSpeed += increment
    elseif IsControlPressed(0, 97) then -- scroll down
        newSpeed -= increment
    end

    -- Clamp and apply speed between min & max
    if speedType == "walk" then
        newSpeed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
        SetWalkSpeedMultiplier(newSpeed)
    elseif speedType == "jog" then
        newSpeed = math.min(math.max(speed, Config.JogSpeedMax), Config.JogSpeedMin)
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
    elseif speedType == "sprint" then
        newSpeed = math.min(math.max(speed, Config.SprintSpeedMax), Config.SprintSpeedMin)
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(PlayerPedId(), newSpeed)
    elseif speedType == "swim" then
        newSpeed = math.min(math.max(speed, Config.SwimSpeedMax), Config.SwimSpeedMin)
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(PlayerPedId(), newSpeed)
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
        print("Inside Run: " .. insideRunSpeed)
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

-- Handle the speed change event received from the server
RegisterNetEvent('syncPlayerMovement', function(playerId, speedType, speedValue)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    if DoesEntityExist(targetPed) then
        if speedType == "walk" then
            SetEntitySpeed(targetPed, speedValue)
        elseif speedType == "jog" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
        elseif speedType == "sprintInside" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
            SetPedMoveRateOverride(targetPed, speedValue)
        elseif speedType == "sprintOutside" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
            SetPedMoveRateOverride(targetPed, speedValue)
        elseif speedType == "swim" then
            SetRunSprintMultiplierForPlayer(GetPlayerFromServerId(playerId), speedValue)
            SetPedMoveRateOverride(targetPed, speedValue)
        end
    end
end)

-- CB from server
RegisterNetEvent('UpdMovementSpeed', function(speed, speedType)
    -- Clamp and apply speed between min & max
    if speedType == "walk" then
        newSpeed = math.min(math.max(speed, Config.WalkSpeedMax), Config.WalkSpeedMin)
        SetWalkSpeedMultiplier(newSpeed)
    elseif speedType == "jog" then
        newSpeed = math.min(math.max(speed, Config.JogSpeedMax), Config.JogSpeedMin)
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
    elseif speedType == "sprint" then
        newSpeed = math.min(math.max(speed, Config.SprintSpeedMax), Config.SprintSpeedMin)
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(PlayerPedId(), newSpeed)
    elseif speedType == "swim" then
        newSpeed = math.min(math.max(speed, Config.SwimSpeedMax), Config.SwimSpeedMin)
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(PlayerPedId(), newSpeed)
    end
end)

-- Exports
exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
    -- print(exports['AnythingAnimal']:getIsPlayerAnimal())

-- Functions
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


-- DEBUG COMMAND
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