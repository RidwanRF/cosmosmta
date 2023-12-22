local connection = false

addEventHandler("onResourceStart", getRootElement(),
	function(startedResource)
        if getResourceName(startedResource) == "cosmo_database" then
            connection = exports.cosmo_database:getConnection()
        elseif source == getResourceRootElement() then
            if getResourceFromName("cosmo_database") and getResourceState(getResourceFromName("cosmo_database")) == "running" then
                connection = exports.cosmo_database:getConnection()
                loadAllATM()
            end
		end
	end
)


function createATM(position)
    assert(type(position) == "table", "Bad argument @ 'createNPC' [expected table at argument 1, got "..type(position) .. "]")

    dbQuery(
        function(queryHandle)
            local result, rows, lastID = dbPoll(queryHandle, 0)

            local atm = createObject(2942, position[1], position[2], position[3] - 0.35, 0, 0, position[4])

            if isElement(atm) then
                setElementInterior(atm, position[5])
                setElementDimension(atm, position[6])
                setElementFrozen(atm, true)
                setElementData(atm, "atm.id", lastID)
				
				setElementData(atm, "atm.robbery", false)
				setElementData(atm, "atm.health", tonumber(100))
            end
        end, connection, "INSERT INTO atm (position) VALUES (?)", toJSON(position)
    )
end

function deleteATM(id)
    assert(type(id) == "number", "Bad argument @ 'deleteNPC' [expected number at argument 1, got "..type(id) .. "]")

	if dbExec(connection, "DELETE FROM atm WHERE id = ?", id) then
		for i, v in pairs(getElementsByType("object")) do
			if getElementData(v, "atm.id") then
				if tonumber(getElementData(v, "atm.id")) == tonumber(id) then
					destroyElement(v)
					return true
				else
					return false
				end
			end
		end
	
	end

    return false
end

function loadAllATM()
	dbQuery(
		function(qh)
			local result, rows, lastID = dbPoll(qh, 0)
			
            for k, v in pairs(result) do
                local position = fromJSON(v["position"])
                local atm = createObject(2942, position[1], position[2], position[3] - 0.35, 0, 0, position[4])
                
                if isElement(atm) then
                    setElementInterior(atm, position[5])
                    setElementDimension(atm, position[6])
                    setElementFrozen(atm, true)
                    setElementData(atm, "atm.id", v["id"])
                end
            end
		end, connection, "SELECT * FROM atm"
	)
end