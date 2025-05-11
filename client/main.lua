local QBCore = exports['qb-core']:GetCoreObject()
local cooldownActive = false
local isRobbing = false

-- Helper function for debugging
local function DebugPrint(msg)
    if Config.Debug then
        print("[MNS-ROBNPC] " .. msg)
    end
end

-- Check if player is armed
local function IsArmed()
    local ped = PlayerPedId()
    if IsPedArmed(ped, 7) then -- Check for any weapon
        return true
    end
    return false
end

-- Add this command for testing
RegisterCommand('checknpcrobbery', function()
    local hasWeapon = IsArmed()
    if hasWeapon then
        QBCore.Functions.Notify('You are armed and can rob NPCs', 'success')
    else
        QBCore.Functions.Notify('You need a weapon to rob NPCs', 'error')
    end
end, false)

-- Check if enough cops are online
local function CheckCopCount(cb)
    if Config.RequiredCops <= 0 then
        -- Skip the check if no cops are required
        return cb(true)
    end
    
    -- First try the QBCore callback
    QBCore.Functions.TriggerCallback('police:GetCopCount', function(count)
        if count ~= nil then
            DebugPrint("Police count: " .. count)
            cb(count >= Config.RequiredCops)
        else
            -- Fallback to our own callback if the QBCore one fails
            QBCore.Functions.TriggerCallback('mns-robnpc:server:getCopCount', function(count)
                DebugPrint("Police count (fallback): " .. count)
                cb(count >= Config.RequiredCops)
            end)
        end
    end)
end

-- Function to set cooldown
local function SetCooldown()
    if Config.ShouldWaitBetweenRobbing then
        cooldownActive = true
        local timer = Config.Cooldown
        
        Citizen.CreateThread(function()
            while timer > 0 do
                Citizen.Wait(1000)
                timer = timer - 1
            end
            cooldownActive = false
            QBCore.Functions.Notify('You can rob citizens again', 'success')
        end)
    end
end

-- Function to animate the player for robbery
local function PlayRobberyAnimation()
    local ped = PlayerPedId()
    local animDict = "mp_missheist_ornatebank"
    local animName = "stand_cash_in_bag_loop"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
end

-- Function to animate the NPC to put hands up (renamed for clarity)
local function MakeNPCHandsUp(targetPed)
    if not IsPedDeadOrDying(targetPed) then
        -- Set as mission entity to prevent despawning
        SetEntityAsMissionEntity(targetPed, true, true)
        
        -- Clear any existing tasks first
        ClearPedTasksImmediately(targetPed)
        
        -- Block the NPC from responding to other events
        SetBlockingOfNonTemporaryEvents(targetPed, true)
        
        -- Completely freeze the NPC in place
        FreezeEntityPosition(targetPed, true)
        
        -- Use a more neutral hands-up animation
        local animDict = "missminuteman_1ig_2"
        local animName = "handsup_base" -- This is a calmer hands-up pose
        
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(10)
        end
        
        -- Play the hands-up animation with flag 50 (loop + don't move)
        TaskPlayAnim(targetPed, animDict, animName, 8.0, -8.0, -1, 50, 0, false, false, false)
        
        -- Disable movement completely
        DisablePedPainAudio(targetPed, true)
        
        -- Don't set a scared facial expression
        -- Don't play frightened speech
    end
end

-- Function to check if NPC will fight back
local function WillPedFightBack(pedModel)
    for _, model in ipairs(Config.DangerousPeds) do
        if pedModel == model then
            return true
        end
    end
    return false
end

-- Function to make surrounding pedestrians react and flee
local function MakeSurroundingPedsFlee()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local radius = 15.0 -- Radius to check for nearby peds
    
    -- Find all nearby peds
    local peds = GetGamePool('CPed')
    
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            -- If ped is within radius and is not the one being robbed
            if distance <= radius and not isEntityTarget then
                -- Make ped flee from the player
                TaskReactAndFleePed(ped, playerPed)
                
                -- Add a chance for pedestrians to call the police
                if Config.EnablePoliceAlerts and not Config.WitnessReporting then
                    -- Skip this to avoid too many police calls
                else
                    -- Add code here if you want some witnesses to report crimes
                end
            end
        end
    end
end

-- Function to make the robbed NPC flee after the robbery
local function MakeNPCFleeAfterRobbery(targetPed)
    if DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed) then
        -- Clear any existing tasks
        ClearPedTasksImmediately(targetPed)
        
        -- Make sure to unfreeze the NPC so they can flee
        FreezeEntityPosition(targetPed, false)
        
        -- Re-enable pain audio
        DisablePedPainAudio(targetPed, false)
        
        -- Allow the NPC to respond to events again
        SetBlockingOfNonTemporaryEvents(targetPed, false)
        
        -- Make the NPC run away from the player in a panic
        TaskReactAndFleePed(targetPed, PlayerPedId())
        
        -- Set a scared facial expression as they flee
        SetFacialIdleAnimOverride(targetPed, "mood_stressed_1")
        
        -- Add frightened speech
        PlayPedAmbientSpeechNative(targetPed, "GENERIC_FRIGHTENED_HIGH", "SPEECH_PARAMS_FORCE_SHOUTED")
        
        -- Keep the NPC as a mission entity for a bit longer so they don't disappear instantly
        SetEntityAsMissionEntity(targetPed, true, true)
        
        -- Release the entity after some time to prevent memory leaks
        Citizen.SetTimeout(20000, function()
            if DoesEntityExist(targetPed) then
                SetEntityAsNoLongerNeeded(targetPed)
            end
        end)
    end
end

-- Main robbery function
local function RobNPC(targetPed)
    if not targetPed or not DoesEntityExist(targetPed) then return end
    
    -- Check if player is already robbing
    if isRobbing then
        QBCore.Functions.Notify('You are already robbing someone!', 'error')
        return
    end
    
    -- Check if cooldown is active
    if cooldownActive then
        QBCore.Functions.Notify('You need to wait before robbing again!', 'error')
        return
    end
    
    -- Check if player is armed
    if not IsArmed() then
        QBCore.Functions.Notify('You need a weapon to intimidate citizens!', 'error')
        return
    end
    
    -- Check distance to target
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(playerCoords - targetCoords)
    
    if distance > Config.MinDistance then
        QBCore.Functions.Notify('You are too far away!', 'error')
        return
    end
    
    -- Check if NPC will fight back
    local pedModel = GetEntityModel(targetPed)
    if WillPedFightBack(pedModel) then
        -- Make NPC fight back
        QBCore.Functions.Notify('This person is fighting back!', 'error')
        TaskCombatPed(targetPed, playerPed, 0, 16)
        SetPedCombatAttributes(targetPed, 46, true)
        return
    end
    
    -- Start robbery process
    isRobbing = true
    
    -- Make NPC put hands up (using the renamed function)
    MakeNPCHandsUp(targetPed)
    
    -- Make surrounding pedestrians flee
    MakeSurroundingPedsFlee()
    
    -- Player animation
    PlayRobberyAnimation()
    
    -- Alert police with chance
    if Config.EnablePoliceAlerts and math.random(100) <= Config.AlertChance then
        -- Check which dispatch system is being used
        if GetResourceState('ps-dispatch') == 'started' then
            exports['ps-dispatch']:Robnpc()
        else
            -- Fallback to default QB police alert
            TriggerServerEvent('police:server:policeAlert', 'NPC being robbed')
        end
    end
    
    QBCore.Functions.Notify('Robbing citizen...', 'primary', Config.RobAnimationSeconds)
    
    QBCore.Functions.Progressbar("robbing_npc", "Robbing Citizen...", Config.RobAnimationSeconds, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        -- Success chance check
        if math.random(100) <= Config.SuccessChance then
            TriggerServerEvent('mns-robnpc:server:giveReward')
            QBCore.Functions.Notify('Robbery successful!', 'success')
        else
            QBCore.Functions.Notify('They have nothing valuable!', 'error')
        end
        
        -- Clear animations
        ClearPedTasks(playerPed)
        
        -- Make the NPC flee after robbery
        MakeNPCFleeAfterRobbery(targetPed)
        
        -- Set cooldown
        SetCooldown()
        isRobbing = false
    end, function() -- Cancel
        ClearPedTasks(playerPed)
        
        -- Make the NPC flee after cancelled robbery too
        MakeNPCFleeAfterRobbery(targetPed)
        
        QBCore.Functions.Notify('Robbery canceled!', 'error')
        isRobbing = false
    end)
end

-- Initialize target system
Citizen.CreateThread(function()
    if Config.TargetSystem == 'qb-target' then
        -- Setup qb-target
        exports['qb-target']:AddGlobalPed({
            options = {
                {
                    type = "client",
                    event = "mns-robnpc:client:checkRobbery",
                    icon = "fas fa-mask",
                    label = "Rob Citizen",
                    canInteract = function(entity)
                        -- Add weapon check here for visual feedback
                        if not IsArmed() then
                            return false
                        end
                        
                        if not IsPedAPlayer(entity) and IsEntityAPed(entity) and not IsPedInAnyVehicle(entity) and not IsPedDeadOrDying(entity) then
                            return true
                        end
                        return false
                    end,
                },
            },
            distance = 2.5,
        })
    elseif Config.TargetSystem == 'ox_target' then
        -- Setup ox_target
        exports.ox_target:addGlobalPed({
            {
                name = 'mns-robnpc:robCitizen',
                icon = 'fas fa-mask',
                label = 'Rob Citizen',
                canInteract = function(entity, distance, coords, name)
                    -- Add weapon check here for visual feedback
                    if not IsArmed() then
                        return false
                    end
                    
                    if not IsPedAPlayer(entity) and not IsPedInAnyVehicle(entity) and not IsPedDeadOrDying(entity) then
                        return true
                    end
                    return false
                end,
                onSelect = function(data)
                    -- Debug to verify this is triggered
                    DebugPrint("ox_target onSelect triggered")
                    
                    CheckCopCount(function(enoughCops)
                        if enoughCops then
                            RobNPC(data.entity)
                        else
                            QBCore.Functions.Notify('Not enough police in the city!', 'error')
                        end
                    end)
                end
            }
        })
    else
        print("^1ERROR^7: Invalid target system specified in config. Use 'qb-target' or 'ox_target'")
    end
end)

-- Event handler for qb-target
RegisterNetEvent('mns-robnpc:client:checkRobbery')
AddEventHandler('mns-robnpc:client:checkRobbery', function(data)
    -- Debug to verify this is triggered
    DebugPrint("qb-target event triggered")
    
    local targetPed = data.entity
    
    CheckCopCount(function(enoughCops)
        if enoughCops then
            RobNPC(targetPed)
        else
            QBCore.Functions.Notify('Not enough police in the city!', 'error')
        end
    end)
end)

-- Event for starting robbery (can be triggered from other scripts if needed)
RegisterNetEvent('mns-robnpc:client:startRobbery')
AddEventHandler('mns-robnpc:client:startRobbery', function(targetPed)
    RobNPC(targetPed)
end)

