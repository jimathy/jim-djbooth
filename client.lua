local CircleTargets, Props = {}, {}
local Locations, previousSongs = {}, {}
local function removeTargets()
	for _, v in pairs(CircleTargets) do removeZoneTarget(v) end
	for i = 1, #Props do destroyProp(Props[i]) end
	Props = {} CircleTargets = {}
end

local function makeTargets()
	removeTargets()
	for i = 1, #Locations do
		local target = Locations[i]
		if target.enableBooth then
			local RequireJob, RequireGang = nil, nil
			if target.job then
				RequireJob = target.job
				if RequireJob == "public" then
					RequireJob = nil
				end
			end
			if target.gang then
				RequireGang = target.RequireGang
			end
			local options = {
				{ 	action = function()
						TriggerEvent(getScript()..":client:playMusic", { zoneNum = i, job = RequireJob, gang = RequireGang, })
					end,
					icon = "fab fa-youtube",
					label = locale("target", "dj_booth"),
					job = RequireJob,
					gang = RequireGang,
			}, }
			if target.prop then -- If spawning a prop, make entity target instead (ignores depth and width stuff)
				Props[#Props+1] = makeDistProp( { prop = target.prop.model, coords = target.prop.coords }, true, false)
			end
			local name = "Booth"..i
			CircleTargets[name] =
				createCircleTarget({name, target.coords.xyz, 0.6, { name = name, debugPoly = debugMode, useZ = true }}, options, 2.0)

			if debugMode then	-- LETS DEBUG THIS BRO
				CreateThread(function()
					local sphereCoord = target.soundLoc or target.coords or target.prop.coords
					while true do
						DrawMarker(28, sphereCoord.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100)
						DrawMarker(28, sphereCoord.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, target.radius + 0.0, target.radius + 0.0, target.radius + 0.0, 255, 255, 255, 100)
						Wait(0)
					end
				end)
			end
		end
	end
	print("^3makeTargets^7: ^2Total DJBooth Targets Created^7: ^6"..#Locations.."^7")
end

local function syncLocations()
	Wait(1000)
	Locations = triggerCallback(getScript()..":server:syncLocations")
	jsonPrint(Locations)
	Wait(1000)
	makeTargets()
end

onPlayerLoaded(function()
	if not isStarted("xsound") then
		print("^1xSound not started, script won't function^7")
		return
	end
	syncLocations()
end, true)

RegisterNetEvent(getScript()..":client:syncLocations", function(newLocations)
	Locations = newLocations
	makeTargets()
end)

RegisterNetEvent(getScript()..":client:playMusic", function(data)
	jsonPrint(data)
	local booth = ""
	for k, v in pairs(Locations) do
		local playerCoords = GetEntityCoords(PlayerPedId())
		local targetCoords = v.coords
		local dx = playerCoords.x - targetCoords.x
		local dy = playerCoords.y - targetCoords.y
		local dz = playerCoords.z - targetCoords.z
		local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

		if distance <= v.radius then
			booth = v.job and v.job..k or v.gang..k
		end
	end

	local song = { playing = "", duration = "", timeStamp = "", url = "", icon = "", header = locale("menu", "no_song"), txt = "", volume = "" }
	previousSongs = triggerCallback(getScript()..":songInfo")

	-- Grab song info and build table
	if exports["xsound"]:soundExists(booth) then
		song = {
			playing = exports["xsound"]:isPlaying(booth),
			timeStamp = "",
			url = exports["xsound"]:getLink(booth),
			icon = "https://img.youtube.com/vi/"..string.sub(exports["xsound"]:getLink(booth), - 11).."/mqdefault.jpg",
			header = "",
			txt = exports["xsound"]:getLink(booth),
			volume = math.ceil(exports["xsound"]:getVolume(booth)*100)
		}

		if exports["xsound"]:isPlaying(booth) then
			song.header = locale("menu", "cur_playing")
		end

		if exports["xsound"]:isPaused(booth) then
			song.header = locale("menu", "cur_paused")
		end

		if exports["xsound"]:getMaxDuration(booth) == 0 then
			song.timeStamp = locale("menu", "live")
		end

		if exports["xsound"]:getMaxDuration(booth) > 0 then
			local timestamp = (exports["xsound"]:getTimeStamp(booth) * 10)
			local mm = (timestamp // (60 * 10)) % 60.
			local ss = (timestamp // 10) % 60.
			timestamp = string.format("%02d:%02d", mm, ss)
			local duration = (exports["xsound"]:getMaxDuration(booth) * 10)
			mm = (duration // (60 * 10)) % 60.
			ss = (duration // 10) % 60.
			duration = string.format("%02d:%02d", mm, ss)
			song.timeStamp = "("..timestamp.."/"..duration..")"
			if exports["xsound"]:isPlaying(booth) then
				song.timeStamp = "🔊 "..song.timeStamp
			else
				song.timeStamp = "🔇 "..song.timeStamp
			end
		end
	end

	local musicMenu = {}
	local header = "https://cdn-icons-png.flaticon.com/512/1384/1384060.png"
	header = 	(
					(
						Config.System.Menu == "qb" and "<img src=https://cdn-icons-png.flaticon.com/512/1384/1384060.png width=20px></img>&nbsp; "..locale("target", "dj_booth") or
						Config.System.Menu == "ox" and "![](https://pngimg.com/uploads/youtube/youtube_PNG12.png)"..locale("target", "dj_booth")
					)
				) or locale("target", "dj_booth")

	musicMenu[#musicMenu + 1] = {
		disabled = true,
		image = song.icon,
		icon = song.icon,
		header = song.header,
		txt = song.txt ~= "" and song.txt..br..song.timeStamp or nil,
	}
	musicMenu[#musicMenu+1] = {
		icon = "fab fa-youtube",
		header = locale("menu", "play"), txt = locale("menu", "youtube_url"),
		onSelect = function()
			TriggerEvent(getScript()..":client:musicMenu", { zoneNum = data.zoneNum })
		end,
	}
	if previousSongs[booth] then
		musicMenu[#musicMenu+1] = {
			icon = "fas fa-clock-rotate-left",
			header = locale("menu", "history"),
			onSelect = function()
				TriggerEvent(getScript()..":client:history", { history = previousSongs[booth], zoneNum = data.zoneNum })
			end,
		}
	end
	if exports["xsound"]:soundExists(booth) then
		local isPlaying = exports["xsound"]:isPlaying(booth)
		musicMenu[#musicMenu+1] = {
			icon = isPlaying and "fas fa-pause" or "fas fa-play",
			header = locale("menu", isPlaying and "text_pause" or "text_resume"),
			onSelect = function()
				TriggerServerEvent(getScript()..":server:PauseResume", { zoneNum = data.zoneNum })
			end,
		}

		local volume = song and song.volume or 1
		musicMenu[#musicMenu+1] = {
			icon = "fas fa-volume-off",
			header = locale("menu", "volume")..volume.."%",
			progress = tonumber(volume),
			onSelect = function()
				TriggerEvent(getScript()..":client:changeVolume", { zoneNum = data.zoneNum, currVol = volume })
			end,
		}
		musicMenu[#musicMenu+1] = {
			icon = "fas fa-stop",
			header = locale("menu", "stop"),
			onSelect = function()
				TriggerServerEvent(getScript()..":server:stopMusic", { zoneNum = data.zoneNum })
			end,
		}
	end
	openMenu(musicMenu, {
		header = header
	})
	song = nil
end)

RegisterNetEvent(getScript()..":client:history", function(data)
	local musicMenu = {}
	for i = #data.history, 1, -1 do
		local img = "https://img.youtube.com/vi/"..string.sub(data.history[i], - 11).."/mqdefault.jpg"
		musicMenu[#musicMenu+1] = {
			image = img, icon = img,
			header = data.history[i],
			onSelect = function()
				TriggerServerEvent(getScript()..":server:playMusic", data.history[i], data.zoneNum)
			end,
		}
	end
	openMenu(musicMenu, {
		header = locale("menu", "history"),
		onBack = function()
			TriggerEvent(getScript()..":client:playMusic", {
				job = data.job,
				zone = data.zoneNum
			})
		end,
	})
end)

RegisterNetEvent(getScript()..":client:musicMenu", function(data)

    local dialog = createInput(locale("menu", "select"), {
		{
			type = "text",
			isRequired = true,
			name = "song",
			text = locale("menu", "youtube_url")
		},
    })

    if dialog then
        if not dialog.song and not dialog[1] then return end

		-- Attempt to correct link if missing "youtube" as some scripts use just the video id at the end
		if not string.find((dialog.song or dialog[1]), "youtu") then
			dialog.song = "https://www.youtube.com/watch?v="..(dialog.song or dialog[1])
		end

		triggerNotify(nil, locale("notify", "load_link")..(dialog.song or dialog[1]))
        TriggerServerEvent(getScript()..":server:playMusic", (dialog.song or dialog[1]), data.zoneNum)
    end
end)

RegisterNetEvent(getScript()..":client:changeVolume", function(data)
    local dialog = createInput(locale("menu", "music_volume"), {
		(Config.System.Menu == "ox" or Config.System.Menu == "lation" and {
			type = "slider",
			label = locale("menu", "range"),
			required = true,
			default = data.currVol,
			min = 1,
			max = 100
		}) or nil,
		(Config.System.Menu == "qb" and {
			header = locale("menu", "music_volume"),
			submitText = locale("menu", "suubmit"),
			inputs = {
				{ type = "text", isRequired = true, name = "volume", text = locale("menu", "range") }
			}
		}) or nil,
    })
    if dialog then
        if not dialog.volume and not dialog[1] then return end
		-- Automatically correct from numbers to be numbers xsound understands
		dialog.volume = ((dialog.volume or dialog[1]) / 100)
		-- Don't let numbers go too high or too low
		if dialog.volume <= 0.01 then dialog.volume = 0.01 end
		if dialog.volume > 1.0 then dialog.volume = 1.0 end
		triggerNotify(nil, locale("notify", "new_volume")..math.ceil(dialog.volume * 100).."%", "success")
        TriggerServerEvent(getScript()..":server:changeVolume", dialog.volume, data.zoneNum)
    end
end)