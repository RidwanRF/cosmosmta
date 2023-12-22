availablePositions = {
	[1] = {
		-- x, y, z, rotx, roty, rotz
		{1374.4195556641, -1822.3547363281, 13.561688423157, 0, 0, 0},
		{1369.1887207031, -1822.3481445312, 13.573728561401, 0, 0, 0},
		{1363.9958496094, -1822.4467773438, 13.578038215637, 0, 0, 0},
		{1357.1320800781, -1822.7639160156, 13.574657440186, 0, 0, 0},
		{1350.4820556641, -1822.7733154297, 13.563049316406, 0, 0, 0},
		{1345.4182128906, -1822.7045898438, 13.548716545105, 0, 0, 0},
		{1340.4460449219, -1822.6174316406, 13.56548500061, 0, 0, 0},
		{1343.6253662109, -1811.9117431641, 13.499113082886, 0, 0, 0},
		{1351.2370605469, -1811.7473144531, 13.53927230835, 0, 0, 0},
		
	},
	[2] = {
		{1812.0697021484, -1400.6875, 13.422028541565, 0, 0, 275},
		{1812.1539306641, -1409.9128417969, 13.422090530396, 0, 0, 275},
		{1832.6490478516, -1398.6420898438, 13.4296875, 0, 0, 90},
		{1833.392578125, -1407.8216552734, 13.6015625, 0, 0, 90},
		{1833.7145996094, -1413.6667480469, 13.6015625, 0, 0, 90},
		{1833.8627929688, -1432.5301513672, 13.6015625, 0, 0, 90},
		{1833.5854492188, -1438.8686523438, 13.594079971313, 0, 0, 90},
		{1830.8771972656, -1446.4055175781, 13.592095375061, 0, 0, 0},
		{1823.6511230469, -1446.8881835938, 13.592756271362, 0, 0, 0},
	},
}

-- for i=0, 15 do
--     table.insert(availablePositions[13], {2148.8662597656 - (3.2 * i), 1397.9228515625, 10.812517166138, 0, 0, 180})
--     table.insert(availablePositions[13], {2148.8662597656 - (3.2 * i), 1408.9228515625, 10.812517166138, 0, 0, 0})
-- end

-- for i=0, 9 do
--     table.insert(availablePositions[13], {2146.7290039063 - (3.2 * i), 1418.87109375, 10.8203125, 0, 0, 180})
-- end

-- for i=0, 8 do
--     table.insert(availablePositions[13], {2143.4873046875 - (3.2 * i), 1426.7933349609, 10.8203125, 0, 0, 0})
-- end
-- table.insert(availablePositions[13], {2108.7578125, 1439.2762451172, 11.0203125, 0, 0, 90})


local _getPlayerName = getPlayerName
local getPlayerName = function(p)
	return getElementData(p, "char.Name") or _getPlayerName(p)
end

local _createBlip = createBlip
function createBlip(x,y,z,i,tooltip)
	local blip = _createBlip(x,y,z,i)
	setBlipOrdering(blip,  -1)
	setElementData(blip, "tooltip", tooltip)
	return blip
end

local blips = {}
--table.insert(blips, {2337.453125, -1373.2292480469, 24.01282119751, 36, "Használtautókereskedés"}) -- 1
--table.insert(blips, {2125.7958984375, -1136.9814453125, 25.392635345459, 36, "Használtautókereskedés"}) -- 2
--table.insert(blips, {1836.3807373047, -1426.0048828125, 13.6015625, 36, "Használtautókereskedés"}) -- 3
--table.insert(blips, {2224.4138183594, -2007.8271484375, 13.546875, 36, "Használtautókereskedés"}) -- 4
-- table.insert(blips, {604.390625, -1509.578125, 14.958490371704, 36}) -- 5
--table.insert(blips, {1110.0567626953, -967.35412597656, 42.719890594482, 36, "Használtautókereskedés"}) -- 6
--table.insert(blips, {1117.2993164063, -1222.7404785156, 17.94303894043, 36, "Használtautókereskedés"}) -- 7
--table.insert(blips, {1377.2338867188, -1796.39453125, 13.487300872803, 36}) -- 8
-- table.insert(blips, {226.86796569824, -1431.9613037109, 13.328748703003, 36}) -- 9
--table.insert(blips, {2071.4169921875, -1867.50390625, 13.546875, 36, "Használtautókereskedés"}) -- 10
--table.insert(blips, {2200.90234375, 1393.1755371094, 10.8203125, 36, "Használtautókereskedés [Inaktív]"}) -- 13

for i, k in pairs(blips) do
    local blip = createBlip(k[1], k[2], k[3], k[4], k[5])
    setElementData(blip, "blipIcon", "cp")
    setElementData(blip, "blipTooltipText", k[5])
    setElementData(blip, "blipColor", tocolor(255,255,255))
end

local vehiclesInCarshop = {}
local vehiclesAddedToCarshop = {}
local carshopVehicles = {}

local freeSlots = {}

for i, v in pairs(availablePositions) do
    freeSlots[i] = {}
    for j, k in pairs(v) do
        freeSlots[i][j] = true
    end
end

function getFreeSlots(cid)
    return freeSlots[cid] or {}
end

function addVehicleToCarshop(veh, cid, cpos, player, price, save)
	local pos = availablePositions[cid]
	if pos then
		local dbid = tonumber(veh:getData("vehicle.dbID")) or 0

		setElementVelocity(veh, 0, 0, 0)
		if not vehiclesAddedToCarshop[cid] then
			vehiclesAddedToCarshop[cid] = 0
		end
		if vehiclesAddedToCarshop[cid] < carshopMaxVehicles[cid] then
            freeSlots[cid][cpos] = false
			local marker = getElementByID("carshopMarker:"..cid..":"..cpos)

			--print(" cid : " .. cid)

			if isElement(marker) then
				if not getElementData(marker, "available") or false then return end
				local x,y,z = getElementPosition(marker)
				setElementPosition(marker,x,y,z-5)
				marker:setData("available", false)
			end
			local tbl = pos[cpos] or false
			if(not tbl)then
				outputDebugString("failed to add: " .. dbid)
				return
			end

			setElementPosition(veh, tbl[1], tbl[2], tbl[3])
			setElementRotation(veh, tbl[4] or 0, tbl[5] or 0, tbl[6] or 0)

			vehiclesInCarshop[veh] = true
			
			veh:setData("veh:CarshopID", cid)
			veh:setData("veh:CarshopPos", cpos)
				
			veh:setData("vehicle.locked", false)
			
			veh:setLocked(false)
			
			veh:setData("vehicle.engine", false)
			setVehicleEngineState(veh, false)

			veh:setData("vehicle.owner", 0)
			veh:setData("vehicle.light", false)
            veh:setData("veh:Enterprise", cid)

            
			setVehicleOverrideLights(veh,1)
				
			veh:setDimension(0)
			veh:setInterior(0)
				
			veh:setCollisionsEnabled(true)
			veh:setDamageProof(true)
			
			veh:setFrozen(false)
			setTimer(function(veh)
				veh:setFrozen(true)
			end, 2000, 1, veh)
	
			veh:setRespawnPosition(tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6])
			veh:setData("veh:Dim", 0)
			veh:setData("veh:Int", 0)

			vehiclesAddedToCarshop[cid] = vehiclesAddedToCarshop[cid] + 1

			if isElement(player) then
				local pdbid = tonumber(player:getData("char.ID")) or 0
                setElementData( player, "log:vehicle:22", {player=getElementData(player, "char.ID"), vid=dbid, vcid=cid, pos=cpos}, false)
			
				triggerClientEvent(player, "acceptedTrigger", player, veh, price, cid)
			end
				
			if price then
				if (tonumber(price) or 0) < 0 then
					price = 0
				end
				veh:setData("veh:Price", tonumber(price))
			end
			
			if save then
				if dbid > 0 then
                    local time = getRealTime()
                    local hour = time.hour
                    local minute = time.minute
                    local day = time.monthday
                    local month = time.month + 1
                    local year = time.year + 1900
                    local second = time.second

                    if hour < 10 then
                        hour = "0"..hour
                    end

                    if minute < 10 then
                        minute = "0"..minute
                    end

                    if month < 10 then
                        month = "0"..month
                    end  

                    if day < 10 then
                        day = "0"..day
                    end

                    if second < 10 then
                        second = "0"..second
                    end
                    veh:setData("veh:carshop_added", year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second)
                    --print("ELVILEG_UPDATE 02 " .. dbid .. " -> " .. cid .. " -> " .. tostring(cpos) .. " ")
					mysql:getConnection():exec("UPDATE vehicles SET carshop_id = ?, carshop_pos = ?, carshop_price = ?, owner = 0, carshop_added=NOW() WHERE vehicleID = ?", cid, cpos, tonumber(price), dbid)
				end
			end
		else
			if isElement(player) then
				triggerClientEvent(player, "showCarshopPremium", player, cid, carshopMaxVehicles[cid])
			end
		end
	end
end

function getCarshopVehicles()
    return vehiclesInCarshop
end

addEvent("addVehicleToCarshop", true)
addEventHandler("addVehicleToCarshop", root, function(veh, cid, cpos, player, price, save)
	local co = coroutine.create(addVehicleToCarshop)
	coroutine.resume(co, veh, cid, cpos, player, price, save)
end)

function removeVehicleFromCarshop(veh, newOwner, updateBalance, out)
	local vehID = tonumber(getElementData(veh, "vehicle.dbID")) or 0
	local cid = tonumber(getElementData(veh, "veh:CarshopID")) or 0
	local cpos = tonumber(getElementData(veh, "veh:CarshopPos")) or 0
	if cid > 0 and cpos > 0 then
        freeSlots[cid][cpos] = true
		vehiclesInCarshop[veh] = false
		veh:setData("veh:CarshopID", 0)
		veh:setData("veh:CarshopPos", 0)

		--local vehOwnerID = getElementData()
        if updateBalance then
            veh:setData("vehicle.owner", newOwner)
            veh:setData("veh:Enterprise", 0)
        else
            if out then
                veh:setData("vehicle.owner", newOwner)
                veh:setData("veh:Enterprise", 0)
            else
                veh:setData("vehicle.owner", 0)
                veh:setData("veh:Enterprise", carshopIDToEnterPriseID[cid])
            end
        end
        --[[ exports.ex_vehicle:changeOwner(0, newOwner, vehID) ]]
		
		veh:setDamageProof(false)
		
		if vehiclesAddedToCarshop[cid] then
			vehiclesAddedToCarshop[cid] = vehiclesAddedToCarshop[cid] - 1
		end
		
		local marker = getElementByID("carshopMarker:"..cid..":"..cpos)
		if isElement(marker) then
			local newPosition = Vector3(marker:getPosition())
			newPosition["z"] = newPosition["z"] + 5
			marker:setPosition(newPosition)
			marker:setData("available", true)
		end

		local pdbid = tonumber(client:getData("char.ID")) or 0
        setElementData( client, "log:vehicle:23", {player=getElementData(client, "char.ID"), vid=vehID, vcid=cid, pos=cpos}, false)
		
		veh:setRespawnPosition(-4125.1044921875, -1482.158203125, 6.2468748092651, 0, 0, 0)
		--print("ELVILEG_UPDATE " .. vehID .. " -> " .. tostring(newOwner))
		mysql:getConnection():exec("UPDATE vehicles SET carshop_id = '0', owner = ? WHERE vehicleID = ?", newOwner, vehID)
		
	end
end

addEvent("removeVehicleFromCarshop", true)
addEventHandler("removeVehicleFromCarshop", root, function(veh, newOwner, updateBalance)
	local co = coroutine.create(removeVehicleFromCarshop)
	coroutine.resume(co, veh, newOwner, updateBalance)
end)

addEvent("saveCarshopConfig", true)
addEventHandler("saveCarshopConfig", root, function(name, open_hour, open_minute, close_hour, close_minute, id)
	mysql:getConnection():exec("UPDATE vallalkozasok SET name = ?, open_hour = ?, open_minute = ?, close_hour = ?, close_minute = ? WHERE id = ?", name, open_hour, open_minute, close_hour, close_minute, id)
end)

addEvent("giveCarshopSlot", true)
addEventHandler("giveCarshopSlot", root, function(id)
	carshopMaxVehicles[id] = carshopMaxVehicles[id] + 1
	mysql:getConnection():exec("UPDATE vallalkozasok SET maxslot = maxslot + 1, lastactive = NOW() WHERE id = ?", id)
end)

addEventHandler("onTrailerAttach", getRootElement(), function(truck)
	if vehiclesInCarshop[source] then
		setElementFrozen(source, true)
	end
end)

addEvent("initCarshopTax", true)
addEventHandler("initCarshopTax", root, function(id)
    for i=1, #availablePositions do
        		local element = getElementsByType("carshop:"..i)[1]
		if isElement(element) then
			local owner = tonumber(getElementData(element, "owner")) or 0
			if owner == id then
				local balance = tonumber(math.floor(getElementData(element, "balance"))) or 0
				if balance >= 50000000 then
					balance = balance/1.1
				elseif balance >= 100000000 then
					balance = balance/1.2
				elseif balance >= 150000000 then
					balance = balance/1.3
				elseif balance >= 200000000 then
					balance = balance/1.4
				elseif balance >= 250000000 then
					balance = balance/1.5
				elseif balance >= 300000000 then
					balance = balance/1.6
				else
					balance = balance/1.05
				end
				setElementData(element, "balance", math.floor(balance))
			end
		end  
    end
end)

addEvent("entCarshopGiveKey", true)
addEventHandler("entCarshopGiveKey", getRootElement(), function(vehID)
	if client and client == source then
		--giveItem(sourceElement, itemId, amount, data1, data2, data3)
		exports.sarp_inventory:giveItem(client, 2, 1, vehID)
	end
end)

addEvent("server->deleteKey", true)
addEventHandler("server->deleteKey", getRootElement(), function(itemid, datatype, vehID)
	if client and client == source then
		exports.sarp_inventory:removeItemByData(client, tonumber(itemid), tostring(datatype), tonumber(vehID))
		--print(itemid .. " -|- " .. datatype .. " -|- " .. vehID)
		--giveItem(sourceElement, itemId, amount, data1, data2, data3)
		--exports.sarp_inventory:giveItem(client, 2, 1, vehID)
	end
end)