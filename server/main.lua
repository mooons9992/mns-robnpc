local QBCore = exports['qb-core']:GetCoreObject()

-- Function to give random items
local function GiveRandomItems(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local items = {}
    for k, v in pairs(Config.Items) do
        table.insert(items, v.name)
    end
    
    -- Determine how many items to give (random between 0 and max)
    local itemCount = math.random(0, Config.MaxItemAmount)
    
    -- If we're giving at least one item
    if itemCount > 0 then
        for i = 1, itemCount do
            -- Pick a random item
            if #items > 0 then
                local randomIndex = math.random(1, #items)
                local itemName = items[randomIndex]
                
                -- Add item to player inventory
                Player.Functions.AddItem(itemName, 1)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[itemName], 'add')
                
                -- Remove this item from the list to prevent duplicates
                table.remove(items, randomIndex)
                
                -- If no more items in the list, break out
                if #items == 0 then break end
            else
                break
            end
        end
    end
end

-- Give robbery rewards
RegisterNetEvent('mns-robnpc:server:giveReward')
AddEventHandler('mns-robnpc:server:giveReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Give random amount of money
    local moneyAmount = math.random(Config.MinMoney, Config.MaxMoney)
    Player.Functions.AddMoney('cash', moneyAmount)
    
    -- Give random items
    GiveRandomItems(src)
    
    -- Log the robbery
    if Config.Debug then
        print("Player ID " .. src .. " robbed a citizen and got $" .. moneyAmount)
    end
end)

-- Check cop count (Callback)
QBCore.Functions.CreateCallback('mns-robnpc:server:getCopCount', function(source, cb)
    local cops = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
            cops = cops + 1
        end
    end
    cb(cops)
end)