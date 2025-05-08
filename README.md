# jim-djbooth
Play music at configured coords!

It handles creation of props and targets to allow players to play music that other players can hear nearby

Targets are generated as "Circle Zones" from the coords set for each location.

Uses dynamically create menus that changes depending on state of music.

## Dependencies
- [xsound](https://github.com/Xogy/xsound) -  https://github.com/Xogy/xsound

# Installation
    - Download the zip and extract the folder
    - If needed, rename the folder to from "jim-djbooth-master" to "jim-djbooth"
    - Place in a folder called [jimextras]
    - Make sure it starts AFTER `xsound` and BEFORE any scripts that make use of it

Example of my load order:
```
# QBCore & Extra stuff
ensure qb-core
ensure [qb]
ensure [standalone] # xsound here
ensure [voice]
ensure [defaultmaps]
ensure [vehicles]

# Extra Jim Stuff
ensure [jimextras] # jim-djbooth here
ensure [jim]
```

## Adding new locations
- You can manually add locations in the config.lua
- For example:
```lua
{ -- Sisyphus Theater
    job = "public",                                     -- "public" or nil makes it so anyone can add music.
    enableBooth = true,                                 -- option to disable rather than deleting code
    DefaultVolume = 0.15,                               -- 0.01 is lowest, 1.0 is max
    radius = 200,                                       -- The radius of the sound from the booth
    coords = vec3(206.9, 1181.04, 226.51),              -- Where the booth target is located
    soundLoc = vec3(212.32, 1155.87, 227.01),           -- Add sound origin location (optional)
    prop = {                                            -- Add an optional prop for players to target
        model = "prop_radio_01",                        -- the prop model
        coords = vec4(-1190.22, -897.46, 14.83, 40),    -- the prop location and heading
    }
},
```
- You can also add them from other scripts with the server sided event:
```lua
TriggerEvent("jim-djbooth:server:AddLocation",
    { -- Sisyphus Theater
        job = "public",
        enableBooth = true,
        DefaultVolume = 0.15, radius = 200,
        coords = vec3(206.9, 1181.04, 226.51),
        soundLoc = vec3(212.32, 1155.87, 227.01),
        prop = {
            model = "prop_radio_01",
            coords = vec4(-1190.22, -897.46, 14.83, 40),
        }
    }
)
```

# Changelog
## v1.4:
    - Redesign to use `jim_bridge` for better optization and features
    - Add more visuals for debug mode so its easier to visualize placements
    - Added ability to spawn a prop in a specific location for players to target
    - Better organisations of music playing code

## v1.3.2:
    - Now with less errors and real setup info

## v1.3.1:
    - Fix syncing locations at players load in
    - Fix the version check html link

## v1.3:
    - Add support for creating DJ-booth's from other scripts

## v1.2:
    - Rewrite
    - Support for OX_lib context menus
