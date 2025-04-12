Config = {
	Lan = "en",
	System = {
		Debug = false, -- Set to true to show target locations
		EventDebug = false,

		Menu = "ox",
		Notify = "gta",
	},
}

function locale(section, string)
	if not string then
		print(section, "string is nil")
	end
    if not Config.Lan or Config.Lan == "" then return print("Error, no langauge set") end
    local localTable = Loc[Config.Lan]
    if not localTable then return "Locale Table Not Found" end
    if not localTable[section] then return "["..section.."] Invalid" end
    if not localTable[section][string] then return "["..string.."] Invalid" end
    return localTable[section][string]
end