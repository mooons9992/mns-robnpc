# MNS NPC Robbery Script

An enhanced NPC robbery script with qb-target and ox_target integration. Rob random NPCs for cash and items with realistic reactions.

## Features
* Rob NPCs using target systems (qb-target or ox_target)
* NPCs put their hands up during robbery
* Surrounding pedestrians flee from robbery scene
* Configurable cooldowns, success rates, and rewards
* Random cash and item rewards from an extensive item pool
* Police alerts via ps-dispatch or native system
* Dangerous NPCs (police, security guards, gang members) will fight back
* Weapon requirement for intimidation
* Clean animations for both player and NPCs
* Detailed configuration options

## Dependencies
* [qb-core](https://github.com/qbcore-framework/qb-core)
* Target system (choose one):
    * [qb-target](https://github.com/qbcore-framework/qb-target)
    * [ox_target](https://github.com/overextended/ox_target)
* Optional: [ps-dispatch](https://github.com/Project-Sloth/ps-dispatch) for police alerts

## Installation
1. Download the script
2. Extract to your resources folder
3. Configure settings in `config.lua`
4. Ensure you have a compatible target system installed
5. Add `ensure mns-robnpc` to your server.cfg
6. Restart your server

### PS-Dispatch Integration (Optional)
If you're using ps-dispatch, add this function to your alerts.lua:

```lua
local function Robnpc()
    local coords = GetEntityCoords(cache.ped)

    local dispatchData = {
            message = locale('npcrob'),
            codeName = '911call',
            code = '10-31',
            icon = 'fas fa-mask',
            priority = 3,
            coords = coords,
            gender = GetPlayerGender(),
            street = GetStreetAndZone(coords),
            information = "Armed robbery of citizen in progress",
            alertTime = 3,
            jobs = { 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('Robnpc', Robnpc)
```

## Configuration
The script is highly configurable through the config.lua file:

```lua
Config = {}

-- General Settings
Config.Debug = false -- Set to true for debugging messages
Config.ShouldWaitBetweenRobbing = true -- if the player should wait between robberies 
Config.Cooldown = 60 -- the cooldown between robberies in seconds
Config.MinDistance = 3.0 -- the distance between the player and the NPC to execute the robbery 
Config.RobAnimationSeconds = 10000 -- Time to rob an NPC (in ms)
Config.SuccessChance = 70 -- percentage chance for successful robbery
Config.MinMoney = 100 -- minimum money to receive
Config.MaxMoney = 500 -- maximum money to receive

-- Target System Configuration
Config.TargetSystem = 'ox_target' -- Options: 'qb-target', 'ox_target'

-- Police Alert Settings
Config.EnablePoliceAlerts = true -- Set to false to disable police alerts
Config.AlertChance = 80 -- percentage chance for alerting police
Config.RequiredCops = 0 -- minimum cops required online to rob NPCs

-- Witness behavior
Config.WitnessReporting = false -- Set to true if you want witnesses to call police
Config.FleeRadius = 15.0 -- How far surrounding peds will notice and flee
```

## Items Configuration
The script includes a comprehensive list of items that can be obtained from robbing NPCs:

* Medical supplies (bandages, painkillers, first aid kits)
* Electronics (phones, laptops, tablets)
* Valuable jewelry (watches, diamonds, gold chains)
* Various tools and miscellaneous items

You can customize the item list in the config file to match your server's economy.

## Usage
1. Approach any NPC on foot
2. Use your target system (aim at the NPC)
3. Select the "Rob Citizen" option (only appears when armed)
4. Wait for the robbery to complete
5. Collect your reward or face consequences if the NPC fights back!

## Important Notes
* You must be armed with a weapon to rob NPCs
* Some NPCs will fight back rather than surrender
* Surrounding pedestrians will flee when they witness a robbery
* After a successful robbery, the victim will run away
* Police may be notified based on your configuration

## Command
* `/checknpcrobbery` - Check if you're armed and can rob NPCs

## Credits
* Original script by R1nZox-dev
* Enhanced by Mooons