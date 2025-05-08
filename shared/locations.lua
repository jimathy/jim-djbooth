Locations = {
    { -- Sisyphus Theater
        job = "public", -- "public" makes it so anyone can add music.
        enableBooth = true,
        DefaultVolume = 0.15, radius = 200,
        coords = vec3(206.9, 1181.04, 226.51),
        soundLoc = vec3(212.32, 1155.87, 227.01), -- Add sound origin location if you don't want the music to play from the dj booth
    },

    { -- GabzTuners Radio Prop
        job = "mechanic",
        enableBooth = true,
        DefaultVolume = 0.1, radius = 30,
        coords = vec3(127.04, -3030.65, 6.80),
        prop = { model = "prop_radio_01", coords = vec3(127.04, -3030.65, 6.80) },
                                -- Prop to spawn at location, if the location doesn't have one already
                                -- (can be changed to any prop, coords determine wether its placed correctly)
    },

    { -- Gabz Popsdiner Radio Prop
        job = "public",
        enableBooth = true,
        DefaultVolume = 0.1, radius = 30,
        coords = vec3(1595.53, 6453.02, 26.165),
        prop = { model = "prop_boombox_01", coords = vec3(1595.53, 6453.02, 26.165) },
    },
}