local animalHashList = {}
local isPlayerAnimal = false
local playerMaxHealth = 200
local runOnce = false
local walkSpeed = GetResourceKvpFloat('AnythingAnimal_WalkSpeed_Float')
local jogSpeed = GetResourceKvpFloat('AnythingAnimal_JogSpeed_Float')
local insideRunSpeed = GetResourceKvpFloat('AnythingAnimal_InsideRunSpeed_Float')
local outsideRunSpeed = GetResourceKvpFloat('AnythingAnimal_OutsideRunSpeed_Float')
local swimSpeed = GetResourceKvpFloat('AnythingAnimal_SwimSpeed_Float')
local canRequestSpeedWalk = true
local canRequestSpeedInsideRun = true
local canRequestSpeedOutsideRun = true
local canRequestSpeedSwim = true
local adjustDirectionWalk = "Both"
local adjustDirectionInsideRun = "Both"
local adjustDirectionOutsideRun = "Both"
local adjustDirectionSwim = "Both"
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
        walkSpeed = Config.JogSpeedMax
    end
    if not insideRunSpeed then
        insideRunSpeed = Config.InsideRunSpeedMax
    end
    if not outsideRunSpeed then
        outsideRunSpeed = Config.OutsideRunSpeedMax
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
            local speedType = nil
            local speedValue = nil

            if IsPedOnFoot(ped) then
                if IsControlPressed(0, 21) then -- sprinting
                    speedType = "sprint"
                    sprintSpeed = UpdateSpeed(sprintSpeed, "sprint")
                    speedValue = sprintSpeed
                elseif IsControlPressed(0, 19) then -- jogging
                    speedType = "jog"
                    jogSpeed = UpdateSpeed(jogSpeed, "jog")
                    speedValue = jogSpeed
                else -- walking
                    speedType = "walk"
                    walkSpeed = UpdateSpeed(walkSpeed, "walk")
                    speedValue = walkSpeed
                end
                
                if IsControlPressed(0, 22) then
                    TriggerServerEvent('JumpPED', isPlayerAnimal, false)
                    Wait(2000)
                end

                -- Send the speed change event to the server to synchronize with other players
                TriggerServerEvent('syncPlayerMovement', speedType, speedValue)
            end

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
               
            
            
            if IsPedWalking(ped) and IsPedOnFoot(ped) and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
                -- Use / adjust general walk speed
            elseif not IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                -- If inside (in MLO/underground) and shift (sprint) is pressed
            elseif IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                -- If outside and shift (sprint) is pressed
            end
        end
    end
end)

function UpdateSpeed(speed, speedType)
    local newSpeed = speed
    local increment = 0.01

    if IsControlPressed(0, 96) then -- scroll up
        newSpeed = newSpeed + increment
    elseif IsControlPressed(0, 97) then -- scroll down
        newSpeed = newSpeed - increment
    end

    -- Clamp speed to minimum and maximum values
    if speedType == "walk" then
        TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "walk")
    elseif speedType == "jog" then
        TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "jog")
    elseif speedType == "sprint" then
        TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "sprint")
    elseif speedType == "swim" then
        TriggerServerEvent('VerifyEmoteSpeed', newSpeed, isPlayerAnimal, "swim")
    end

    -- Apply the new speed
    if speedType == "walk" then
        SetWalkSpeedMultiplier(newSpeed)
    elseif speedType == "jog" then
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
    elseif speedType == "sprint" then
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(PlayerPedId(), newSpeed)
    elseif speedType == "swim" then
        SetRunSprintMultiplierForPlayer(PlayerId(), newSpeed)
        SetPedMoveRateOverride(PlayerPedId(), newSpeed)
    end

    return newSpeed
end)



-- Add Chat commands
RegisterCommand('aaws', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "walk")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aaws", "Set walk speed " .. Config.WalkSpeedMin .. " to " .. Config.WalkSpeedMax)

RegisterCommand('aais', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "inrun")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aais", "Set inside run speed " .. Config.InsideRunSpeedMin .. " to " .. Config.InsideRunSpeedMax)

RegisterCommand('aaos', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "outrun")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aaos", "Set outside run speed " .. Config.OutsideRunSpeedMin .. " to " .. Config.OutsideRunSpeedMax)

RegisterCommand('aass', function(source, args, raw)
    if isPlayerAnimal then
        TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "swim")
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aass", "Set swim speed " .. Config.SwimSpeedMin .. " to " .. Config.SwimSpeedMax)

RegisterCommand('aaspeeds', function(source, args, raw)
    if isPlayerAnimal then
        print("Walk: " .. walkSpeed)
        print("Inside Run: " .. insideRunSpeed)
        print("Outside Run: " .. outsideRunSpeed)
        print("Swim: " .. swimSpeed)
    end
end, false)
TriggerEvent("chat:addSuggestion", "/aaspeeds", "Show set speeds")

-- CB from server
RegisterNetEvent('UpdMovementSpeed', function(speed, adjDir, typeAdjust, allowReq)
    if typeAdjust == "walk" then
        walkSpeed = speed
        adjustDirectionWalk = adjDir
        SetResourceKvpFloat("AnythingAnimal_WalkSpeed_Float", walkSpeed)
        canRequestSpeedWalk = allowReq
    elseif typeAdjust == "inrun" then
        insideRunSpeed = speed
        adjustDirectionInsideRun = adjDir
        SetResourceKvpFloat("AnythingAnimal_JogSpeed_Float", jogSpeed)
        canRequestSpeedInsideRun = allowReq
    elseif typeAdjust == "inrun" then
        insideRunSpeed = speed
        adjustDirectionInsideRun = adjDir
        SetResourceKvpFloat("AnythingAnimal_SprintSpeed_Float", sprintSpeed)
        canRequestSpeedInsideRun = allowReq
    elseif typeAdjust == "swim" then
        swimSpeed = speed
        adjustDirectionSwim = adjDir
        SetResourceKvpFloat("AnythingAnimal_SwimSpeed_Float", swimSpeed)
        canRequestSpeedSwim = allowReq
    end
end)


RegisterNetEvent('GetOffsetInWorld', function()
    local ped = PlayerPedId()
    local offsetPEDCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, Config.JumpDistance, Config.JumpHeight)
    TriggerServerEvent('JumpPED', isPlayerAnimal, offsetPEDCoords)
    --ClearPedTasks(ped)
    --LoadAnim(dict)
    --TaskPlayAnim(ped, ChosenDict, ChosenAnimation, AnimationBlendSpeed, AnimationBlendSpeed, AnimationDuration, MovementType, 0, false, false, false)
    --RemoveAnimDict(ChosenDict)
end)

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