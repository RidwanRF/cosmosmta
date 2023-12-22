
local con = exports.cosmo_database:getConnection()

addAdminCommand("rtc2", 1, "Jármű áthelyezése játék területen kívülre.")
function rtcVehicle2(thePlayer, commandName)
	if getElementData(thePlayer, "acc.adminLevel") >= 1 then
	
	local px, py, pz = getElementPosition(thePlayer)

	------- discord log
	exports.cosmo_dclog:sendDiscordMessage("**".. getElementData(thePlayer, "acc.adminNick") .."** használta az rtc2 parancsot.", "adminlog")
	exports.cosmo_core:sendMessageToAdmins("".. getElementData(thePlayer, "acc.adminNick") .." használta az rtc2 parancsot.", 1)
	------- discord log
	
	for k, v in ipairs(getElementsByType("vehicle")) do 
		vx, vy, vz = getElementPosition(v)
		local dist = getDistanceBetweenPoints3D ( px, py, pz, vx, vy, vz )
		if dist <= 5 then
		
			local vehicleQ = dbQuery(con,"SELECT * FROM vehicles WHERE vehicleID='" .. getElementData(v, "vehicle.dbID") .. "'")
			local vehicleH,vehszam = dbPoll(vehicleQ,-1)
			if vehicleH then
				for k1,v1 in ipairs(vehicleH) do
					setElementDimension(v, 2)
					local x, y, z =  -2319.1916503906, -1637.2742919922, 483.703125
					setElementPosition(v, x, y, z)
					setVehicleRespawnPosition(v, x, y, z, 0, 0, 0)
					dbExec(con, "UPDATE vehicles SET position='" .. toJSON({x, y, z, 0, 2, 0}) .. "' WHERE vehicleID='" .. getElementData(v, "vehicle.dbID") .. "'")

					--<<SAVE>>--
					setElementData(thePlayer, 'admin.rtc', (getElementData(thePlayer, 'admin.rtc') or 0)+1)
					dbExec(connection, "UPDATE accounts SET rtc = ? WHERE accountID = ?", getElementData(thePlayer,"admin.rtc"), getElementData(thePlayer, "acc.dbID"))
					--<<SAVE>>--

					end
				end
			end
		end
	end
end
addCommandHandler("rtc2", rtcVehicle2, false, false)
