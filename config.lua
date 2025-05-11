Config = {}

-- General Settings
Config.Debug = false  -- Change to true temporarily for debugging
Config.ShouldWaitBetweenRobbing = true -- if the player should wait between robberies 
Config.Cooldown = 60 -- the cooldown between robberies in seconds
Config.MinDistance = 3.0 -- the distance between the player and the NPC to execute the robbery 
Config.RobAnimationSeconds = 10000 -- 1000 = 1 second (time to rob an NPC)
Config.SuccessChance = 50 -- percentage chance for successful robbery
Config.MinMoney = 100 -- minimum money to receive
Config.MaxMoney = 500 -- maximum money to receive

-- Target System Configuration
Config.TargetSystem = 'ox_target' -- Options: 'qb-target', 'ox_target'

-- Police Alert Settings
Config.EnablePoliceAlerts = true -- Set to false to disable police alerts
Config.AlertChance = 80 -- percentage chance for alerting police (only if EnablePoliceAlerts is true)
Config.RequiredCops = 0 -- minimum cops required online to rob NPCs

-- Witness behavior
Config.WitnessReporting = false -- Set to true if you want witnesses to also call police
Config.WitnessPoliceCallChance = 30 -- Chance for a witness to call police if WitnessReporting is true
Config.FleeRadius = 15.0 -- How far surrounding peds will notice and flee from a robbery

-- Peds that will fight back when robbed
Config.DangerousPeds = {
    -- Security personnel
    1669696074, -- Security guard
    2119136831, -- FIB Agent
    1456041926, -- Military personnel
    368603149,  -- Security guard (IAA)
    1581098148, -- Police officer
    1650288984, -- Highway patrol officer
    
    -- Gang members
    810804565,  -- Gang member
    3344783829, -- Ballas gang member
    1226102803, -- Vagos gang member
    2119136831, -- Lost MC member
    1682622302, -- Mafia
    2374966032, -- Drug dealer
    
    -- Tough citizens
    1641334641, -- Bodybuilder 
    921110016,  -- Military veteran
    1161072059, -- Bouncer
    1244939171, -- Bar owner
    2992445106, -- Bounty hunter
    921110016,  -- Ex-military
    
    -- Armed NPCs
    994527967,  -- Hunter
    3696858125, -- Ammu-Nation owner
    921328393,  -- Rural gun owner
    
    -- Special
    3462393972, -- Merryweather security
    2506301981, -- Armed yacht crew
    1349953339, -- Epsilon guard
    3880743438, -- Clown (surprisingly dangerous)
}

-- Items Configuration
Config.MaxItemAmount = 5 -- maximum number of items given per robbery
Config.Items = { 
    -- Original items
    lockpick = { name = 'lockpick', label = 'Lockpick' },
    trojan_usb = { name = 'trojan_usb', label = 'Trojan USB' },
    phone = { name = 'phone', label = 'Phone' },
    wallet = { name = 'wallet', label = 'Wallet' },
    
    -- Medication items
    firstaid = { name = 'firstaid', label = 'First Aid' },
    bandage = { name = 'bandage', label = 'Bandage' },
    ifaks = { name = 'ifaks', label = 'ifaks' },
    painkillers = { name = 'painkillers', label = 'Painkillers' },
    walkstick = { name = 'walkstick', label = 'Walking Stick' },
    
    -- Communication items
    radio = { name = 'radio', label = 'Radio' },
    iphone = { name = 'iphone', label = 'iPhone' },
    samsungphone = { name = 'samsungphone', label = 'Samsung S10' },
    laptop = { name = 'laptop', label = 'Laptop' },
    tablet = { name = 'tablet', label = 'Tablet' },
    fitbit = { name = 'fitbit', label = 'Fitbit' },
    radioscanner = { name = 'radioscanner', label = 'Radio Scanner' },
    pinger = { name = 'pinger', label = 'Pinger' },
    cryptostick = { name = 'cryptostick', label = 'Crypto Stick' },
    
    -- Theft and Jewelry items
    rolex = { name = 'rolex', label = 'Golden Watch' },
    diamond_ring = { name = 'diamond_ring', label = 'Diamond Ring' },
    diamond = { name = 'diamond', label = 'Diamond' },
    goldchain = { name = 'goldchain', label = 'Golden Chain' },
    tenkgoldchain = { name = 'tenkgoldchain', label = '10k Gold Chain' },
    goldbar = { name = 'goldbar', label = 'Gold Bar' },
}