availableModels = {
	["primo"] = 547,
	["sentinel"] = 405,
	-- ["premier"] = 426,
	["glendale"] = 466,
}

function getModelIdFromName(name)
	if availableModels[name] then
		return availableModels[name]
	end
	return false
end

function splitEx(inputstr, sep)
	if not sep then
		sep = "%s"
	end

	local t = {}
	local i = 1

	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end