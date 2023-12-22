local dbConnection = exports.cosmo_database:getConnection()
local loadedobjects = {}

addEventHandler("onResourceStart", getResourceRootElement(), function()
	loadobjects()
end)

function loadobjects()
	local query = dbQuery(dbConnection, "SELECT * FROM object")
	if query then
		local result, rows = dbPoll(query, -1 )
		if result then
			for k, v in ipairs(result) do
				local position = fromJSON(v["position"])
				loadedobjects[v["dbID"]] = createObject(v["object"], position[1], position[2], position[3], position[4], position[5], position[6])
				setElementData(loadedobjects[v["dbID"]], "object.id", v["dbID"])
				setElementData(loadedobjects[v["dbID"]], "object.position", position)
				setElementInterior(loadedobjects[v["dbID"]], v["interior"])
				setElementDimension(loadedobjects[v["dbID"]], v["dimension"])
				setElementData(loadedobjects[v["dbID"]], "object.timer", 0)
				setElementData(loadedobjects[v["dbID"]], "object.state", false)
			end
		end
	end
end

function createobject(objID, position, interior, dimension)
	if objID then
		dbExecution = dbQuery(dbConnection, "INSERT INTO object (object, position, interior, dimension) VALUES (?,?,?,?)",objID, toJSON(position), interior, dimension)
		if dbExecution then
			local result, rows, lastid = dbPoll(dbExecution, -1)
			if lastid then
				loadedobjects[lastid] = createObject(objID, position[1], position[2], position[3], position[4], position[5], position[6])
				setElementData(loadedobjects[lastid], "object.id", lastid)
				setElementData(loadedobjects[lastid], "object.position", position)
				setElementInterior(loadedobjects[lastid], "interior", tonumber(interior))
				setElementDimension(loadedobjects[lastid], "dimension", tonumber(dimension))
				setElementData(loadedobjects[lastid], "object.timer", 0)
				setElementInterior(loadedobjects[lastid], tonumber(interior))
                setElementDimension(loadedobjects[lastid], tonumber(dimension))
			end
		end
	end
end
addEvent("createobject", true)
addEventHandler("createobject", root, createobject)

function deleteobject(objectID)
	if objectID then
		local dbExecution = dbExec(dbConnection, "DELETE FROM object WHERE dbID = ?", objectID)
		if dbExecution then
			if destroyElement(loadedobjects[objectID]) then
				outputChatBox("object : " .. objectID .. " azonosítójú object törölve!", source, 0, 0, 0, true)
			end
		end
	end
end
addEvent("deleteobject", true)
addEventHandler("deleteobject", root, deleteobject)