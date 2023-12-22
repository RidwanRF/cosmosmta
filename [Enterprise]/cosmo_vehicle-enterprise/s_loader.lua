carshopMaxVehicles = {}
mysql = exports.sarp_database
local carshopPickups = {
	[1] = {
		--{2126.3864746094, -1123.1916503906, 25.412078857422},
		{1378.8499755859, -1796.1346435547, 13.540603637695},
	},
	[2] = {
		{1836.5095214844, -1425.7612304688, 13.6015625},
	},
}

local carshopPickupsData = {} -- [id] =

addEventHandler("onResourceStart", resourceRoot, function()
	mysql:getConnection():query(function(qh)
		local res, rows, err = qh:poll(0)
		if rows > 0 then
			for _, row in pairs(res) do
				if row.type == 1 then -- CARSHOP
					
					local id = tonumber(row.id)
					local parent = Element("carshop:"..id)
					
					local open_hour = tonumber(row.open_hour) or 0
					local open_minute = tonumber(row.open_minute) or 0
					local close_hour = tonumber(row.close_hour) or 0
					local close_minute = tonumber(row.close_minute) or 0
					local owner = tonumber(row.owner) or 0
					local balance = tonumber(row.balance) or 0
					
					local name = tostring(row.name) or "Használtautó kereskedés"
					
					parent:setData("open_hour", open_hour)
					parent:setData("open_minute", open_minute)
					parent:setData("close_hour", close_hour)
					parent:setData("close_minute", close_minute)
					parent:setData("name", name)
					parent:setData("id", id)
					parent:setData("balance", balance)
					
					parent:setData("owner", owner)
					
					if carshopPickups[id] then
						if open_hour < 10 then
							open_hour = "0"..open_hour
						end
						if open_minute < 10 then
							open_minute = "0"..open_minute
						end
						if close_hour < 10 then
							close_hour = "0"..close_hour
						end
						if close_minute < 10 then
							close_minute = "0"..close_minute
						end

						carshopPickupsData[id] = {}
						for k,v in ipairs(carshopPickups[id]) do
							--print(k)
							--[[ if not carshopPickupsData[id].pickups then
								carshopPickupsData[id].pickups = {}
							end
							if not carshopPickupsData[id].pickups[k] then
								carshopPickupsData[id].pickups[k] = v
							end ]]
							--table.insert(carshopPickups[row.id].pickups, v)

							if not carshopPickupsData[id].pickupsData then
								carshopPickupsData[id].pickupsData = {}
							end
							if not carshopPickupsData[id].pickupsData[k] then
								carshopPickupsData[id].pickupsData[k] = {
									["position"] = v,
									["name"] = "Nyitvatartás: "..open_hour..":"..open_minute.." - "..close_hour..":"..close_minute.."",
									["owner"] = owner,
									["parent"] = parent,
									["id"] = id,
									["setID"] = "carshopPickup:"..id..":"..k,
								}
							end

							--[[ local pickup = createPickup(v[1], v[2], v[3], 3, 1274)
							pickup:setData("name", "Nyitvatartás: "..open_hour..":"..open_minute.." - "..close_hour..":"..close_minute.."")
							pickup:setData("owner", owner)
							pickup:setData("parent", parent)
							pickup:setData("id", id)
							parent:setID("carshopPickup:"..id..":"..k) ]]
							--outputConsole(inspect(carshopPickupsData))
						end
					end

					if availablePositions[row.id] then
						for k,v in ipairs(availablePositions[row.id]) do
							local marker = createMarker(v[1], v[2], v[3]-1, "cylinder", 3, 255, 255, 255, 20)
							marker:setData("parent", parent)
							marker:setData("type", 1)
							marker:setData("owner", owner)
							marker:setData("carshopID", id)
							marker:setData("carshopPos", k)
							marker:setID("carshopMarker:"..id..":"..k)
							marker:setData("available", true)
						end
					end
					
					local maxSlot = tonumber(row.maxslot) or 0
					--print(maxSlot)
					carshopMaxVehicles[row.id] = maxSlot
				end
			end
			
            for i, k in pairs(getElementsByType("vehicle")) do
                local carshop = tonumber(getElementData(k, "veh:CarshopID")) or 0
				if carshop > 0 then
					local carshopPos = tonumber(getElementData(k, "veh:CarshopPos")) or 0
					
					local co = coroutine.create(addVehicleToCarshop)
					coroutine.resume(co, k, carshop, carshopPos)

					outputDebugString("added car " .. k:getData("vehicle.dbID") .. " to " .. carshop .. " carshop")
				end       
            end
		end
		if getRandomPlayer() then
			triggerClientEvent(root, "carshop:reloadMarkers", root)
		end
	end, "SELECT * FROM vallalkozasok")
end, true, "high")

addEvent("clientQuery", true)
addEventHandler("clientQuery", root, function(query)
	dbExec(mysql:getConnection(), query)
end)

addEvent("vehEnt_RequestPickups", true)
addEventHandler("vehEnt_RequestPickups", getRootElement(), function()
	if client and source == client then
		triggerClientEvent(client, "vehEnt_ReceivePickups", client, carshopPickupsData)
	end
end)