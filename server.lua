
previousSongs, CurrentBooths = {}, {}
local Locations = Locations

createCallback("jim-djbooth:server:syncLocations", function(source) return Locations end)

local function DestroyAll()
	for i = 1, #Locations do
		local Booth = Locations[i]
		if Booth.playing then local zoneLabel = ""..(Booth.gang or Booth.job)..i exports["xsound"]:Destroy(-1, zoneLabel) end
	end
end

RegisterNetEvent('jim-djbooth:server:AddLocation', function(data)
	DestroyAll()
	Locations[#Locations+1] = data
	if debugMode then
		local coords = { string.format("%.2f", data.coords.x), string.format("%.2f", data.coords.y), string.format("%.2f", data.coords.z), (string.format("%.2f", data.coords.w or 0.0)) }
		print("^5Debug^7: ^2Adding new ^3Booth^2 location^7: ^5vec4^7(^6"..(coords[1]).."^7, ^6"..(coords[2]).."^7, ^6"..(coords[3]).."^7, ^6"..(coords[4]).."^7)")
	end
	TriggerClientEvent("jim-djbooth:client:syncLocations", -1, Locations)
end)

RegisterNetEvent("jim-djbooth:server:syncLocations", function() TriggerClientEvent("jim-jobgarage:client:syncLocations", -1, Locations) end)

RegisterNetEvent('jim-djbooth:server:playMusic', function(song, zoneNum)
    local src, Booth = source, Locations[zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..zoneNum
	if not previousSongs[zoneLabel] then
		previousSongs[zoneLabel] = { [1] = song, }
	elseif previousSongs[zoneLabel] then
		local songList = previousSongs[zoneLabel]
		songList[#songList+1] = song
		previousSongs[zoneLabel] = songList
	end
	print(zoneLabel..": Playing song: "..song)
	exports["xsound"]:PlayUrlPos(-1, zoneLabel, song, (Booth.CurrentVolume or Booth.DefaultVolume), (Booth.soundLoc or Booth.coords))
	exports["xsound"]:Distance(-1, zoneLabel, Booth.radius)
	Locations[zoneNum].playing = true
	TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = zoneNum })
end)

RegisterNetEvent('jim-djbooth:server:stopMusic', function(data)
    local src, Booth = source, Locations[data.zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..data.zoneNum
    if Booth.playing then
		Locations[data.zoneNum].playing = nil
		Locations[data.zoneNum].CurrentVolume = nil
		exports["xsound"]:Destroy(-1, zoneLabel)
	end
    TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = data.zoneNum })
end)

RegisterNetEvent("jim-djbooth:server:PauseResume", function(data)
    local src, Booth = source, Locations[data.zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..data.zoneNum
	if Booth.playing then
		Booth.playing = nil
		exports["xsound"]:Pause(-1, zoneLabel)
	elseif not Locations[data.zoneNum].playing then
		Locations[data.zoneNum].playing = true
		exports["xsound"]:Resume(-1, zoneLabel)
	end
    TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = data.zoneNum })
end)

RegisterNetEvent('jim-djbooth:server:changeVolume', function(volume, zoneNum)
    local src, Booth = source, Locations[zoneNum]
	local zoneLabel = ""..(Booth.gang or Booth.job)..zoneNum
    if not tonumber(volume) then return end
    if Booth.playing then exports["xsound"]:setVolume(-1, zoneLabel, volume) Locations[zoneNum].CurrentVolume = volume end
    TriggerClientEvent('jim-djbooth:client:playMusic', src, { zoneNum = zoneNum })
end)

createCallback("jim-djbooth:songInfo", function(source) return previousSongs end)

onResourceStop(function() DestroyAll() end, true)

--[[ local documents = {
	["boombox"] = "jim-djbooth:client:playMusic",
}

for docName, eventName in pairs(documents) do
	Core.Functions.CreateUseableItem(docName, function(source, item)
		TriggerClientEvent(eventName, source)
	end)
end ]]