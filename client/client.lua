local animalHashList = {}
local isPlayerAnimal = false
local playerMaxHealth = 200
local runOnce = false
local walkSpeed = GetResourceKvpFloat('AnythingAnimal_WalkSpeed_Float')
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
        walkSpeed = Config.WalkSpeedMin
    end
    if not insideRunSpeed then
        insideRunSpeed = Config.InsideRunSpeedMin
    end
    if not outsideRunSpeed then
        outsideRunSpeed = Config.OutsideRunSpeedMin
    end
    if not swimSpeed then
        swimSpeed = Config.SwimSpeedMin
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
                SetPedMoveRateOverride(ped, swimSpeed)
                if IsControlPressed(0, 96) then
                    if canRequestSpeedSwim and adjustDirectionSwim ~= "NotMax" and swimSpeed <= Config.SwimSpeedMax then
                        canRequestSpeedSwim = false
                        swimSpeed += 0.01
                        TriggerServerEvent('VerifyEmoteSpeed', swimSpeed, isPlayerAnimal, "swim")
                    end
                elseif IsControlPressed(0, 97) then
                    if canRequestSpeedSwim and adjustDirectionSwim ~= "NotMin" and swimSpeed >= Config.SwimSpeedMin then
                        canRequestSpeedSwim = false
                        swimSpeed -= 0.01
                        TriggerServerEvent('VerifyEmoteSpeed', swimSpeed, isPlayerAnimal, "swim")
                    end
                end
            else
                if runOnce then -- If Not In Water
                    SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                    runOnce = false
                end
                if IsPedWalking(ped) and IsPedOnFoot(ped) and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
                    -- Use / adjust general walk speed
                    SetPedMoveRateOverride(ped, walkSpeed)
                    if IsControlPressed(0, 96) then
                        if canRequestSpeedWalk and adjustDirectionWalk ~= "NotMax" and walkSpeed <= Config.WalkSpeedMax then
                            canRequestSpeedWalk = false
                            walkSpeed += 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', walkSpeed, isPlayerAnimal, "walk")
                        end
                    elseif IsControlPressed(0, 97) then
                        if canRequestSpeedWalk and adjustDirectionWalk ~= "NotMin" and walkSpeed >= Config.WalkSpeedMin then
                            canRequestSpeedWalk = false
                            walkSpeed -= 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', walkSpeed, isPlayerAnimal, "walk")
                        end
                    end
                elseif not IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                    -- If inside (in MLO/underground) and shift (sprint) is pressed
                    SetPedMoveRateOverride(ped, insideRunSpeed)
                    if IsControlPressed(0, 96) then
                        if canRequestSpeedInsideRun and adjustDirectionInsideRun ~= "NotMax" and insideRunSpeed <= Config.InsideRunSpeedMax then
                            canRequestSpeedInsideRun = false
                            insideRunSpeed += 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', insideRunSpeed, isPlayerAnimal, "inrun")
                        end
                    elseif IsControlPressed(0, 97) then
                        if canRequestSpeedInsideRun and adjustDirectionInsideRun ~= "NotMin" and insideRunSpeed >= Config.InsideRunSpeedMin then
                            canRequestSpeedInsideRun = false
                            insideRunSpeed -= 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', insideRunSpeed, isPlayerAnimal, "inrun")
                        end
                    end
                elseif IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                    -- If outside and shift (sprint) is pressed
                    SetPedMoveRateOverride(ped, outsideRunSpeed)
                    if IsControlPressed(0, 96) then
                        if canRequestSpeedOutsideRun and adjustDirectionOutsideRun ~= "NotMax" and outsideRunSpeed <= Config.OutsideRunSpeedMax then
                            canRequestSpeedOutsideRun = false
                            outsideRunSpeed += 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', outsideRunSpeed, isPlayerAnimal, "outrun")
                        end
                    elseif IsControlPressed(0, 97) then
                        if canRequestSpeedOutsideRun and adjustDirectionOutsideRun ~= "NotMin" and outsideRunSpeed >= Config.OutsideRunSpeedMin then
                            canRequestSpeedOutsideRun = false
                            outsideRunSpeed -= 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', outsideRunSpeed, isPlayerAnimal, "outrun")
                        end
                    end
                end
                if IsControlPressed(0, 22) then
                    if true then
                        TriggerServerEvent('JumpPED', isPlayerAnimal, false)
                        Wait(1500)
                    end
                end
            end
            Wait(0)
        else
            Wait(5000)
        end
    end
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
        SetResourceKvpFloat("AnythingAnimal_InsideRunSpeed_Float", insideRunSpeed)
        canRequestSpeedInsideRun = allowReq
    elseif typeAdjust == "outrun" then
        outsideRunSpeed = speed
        adjustDirectionOutsideRun = adjDir
        SetResourceKvpFloat("AnythingAnimal_OutsideRunSpeed_Float", outsideRunSpeed)
        canRequestSpeedOutsideRun = allowReq
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
end)

-- Exports
exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
    -- print(exports['AnythingAnimal']:getIsPlayerAnimal())

-- DEBUG COMMAND
--[[ RegisterCommand('aadebug', function(source, args, raw)
    local player = PlayerId()
    local ped = PlayerPedId()
    local xyz = GetEntityCoords(ped)
    local playerRotation = GetEntityRotation(ped, 2)
    print("-------------------------")
    print("--------| DEBUG |--------")
    print("-------------------------")
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
 ]]