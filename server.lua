previousSongs, CurrentBooths = {}, {}
local Locations = Locations

createCallback(getScript()..":server:syncLocations", function(source)
	return Locations
end)

local function DestroyAll()
	for i = 1, #Locations do
		local Booth = Locations[i]
		if Booth.playing then
			local zoneLabel = ""..(Booth.gang or Booth.job)..i
			exports["xsound"]:Destroy(-1, zoneLabel)
		end
	end
end

RegisterNetEvent(getScript()..":server:AddLocation", function(data)
	DestroyAll()
	table.insert(Locations, data)
	debugPrint("^5Debug^7: ^2Adding new ^3Booth^2 location^7: "..formatCoord(data.coords))
	TriggerClientEvent(getScript()..":client:syncLocations", -1, Locations)
end)

exports("AddLocation", function(data)
	TriggerServerEvent(getScript()..":server:AddLocation", data)
end)

RegisterNetEvent(getScript()..":server:syncLocations", function()
	TriggerClientEvent("jim-jobgarage:client:syncLocations", -1, Locations)
end)

RegisterNetEvent(getScript()..":server:playMusic", function(song, zoneNum)
    local src, Booth = source, Locations[zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..zoneNum
	if not previousSongs[zoneLabel] then
		previousSongs[zoneLabel] = {
			[1] = song,
		}
	elseif previousSongs[zoneLabel] then
		local songList = previousSongs[zoneLabel]
		songList[#songList+1] = song
		previousSongs[zoneLabel] = songList
	end
	print(zoneLabel..": Playing song: "..song)
	exports["xsound"]:PlayUrlPos(-1, zoneLabel, song, (Booth.CurrentVolume or Booth.DefaultVolume), (Booth.soundLoc or Booth.coords))
	exports["xsound"]:Distance(-1, zoneLabel, Booth.radius)
	Locations[zoneNum].playing = true
	TriggerClientEvent(getScript()..":client:playMusic", src, {
		zoneNum = zoneNum
	})
end)

RegisterNetEvent(getScript()..":server:stopMusic", function(data)
    local src, Booth = source, Locations[data.zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..data.zoneNum
    if Booth.playing then
		Locations[data.zoneNum].playing = nil
		Locations[data.zoneNum].CurrentVolume = nil
		exports["xsound"]:Destroy(-1, zoneLabel)
	end
    TriggerClientEvent(getScript()..":client:playMusic", src, {
		zoneNum = data.zoneNum
	})
end)

RegisterNetEvent(getScript()..":server:PauseResume", function(data)
    local src, Booth = source, Locations[data.zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..data.zoneNum

	if Booth.playing then
		Booth.playing = nil
		exports["xsound"]:Pause(-1, zoneLabel)

	elseif not Locations[data.zoneNum].playing then
		Locations[data.zoneNum].playing = true
		exports["xsound"]:Resume(-1, zoneLabel)

	end
    TriggerClientEvent(getScript()..":client:playMusic", src, {
		zoneNum = data.zoneNum
	})
end)

RegisterNetEvent(getScript()..":server:changeVolume", function(volume, zoneNum)
    local src, Booth = source, Locations[zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..zoneNum
    if not tonumber(volume) then return end
    if Booth.playing then exports["xsound"]:setVolume(-1, zoneLabel, volume) Locations[zoneNum].CurrentVolume = volume end
    TriggerClientEvent(getScript()..":client:playMusic", src, {
		zoneNum = zoneNum
	})
end)

onResourceStart(function()
	createCallback(getScript()..":songInfo", function(source)
		return previousSongs
	end)
end, true)

onResourceStop(function()
	DestroyAll()
end, true)