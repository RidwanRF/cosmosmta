local storedHiFis = {}

function placeRadio(thePlayer, itemId)
	if isElement(thePlayer) then
		if itemId then
			local calculateState = true

			for k, hifiOBJ in ipairs(getElementsByType("object", resourceRoot)) do
				if getElementModel(hifiOBJ) == 2103 then
					local x, y, z = getElementPosition(thePlayer)
					if getDistanceBetweenPoints3D(x, y, z, getElementPosition(hifiOBJ)) < 15 then
						calculateState = false
						break
					end
				end
			end


			if calculateState then
				local playerPosX, playerPosY, playerPosZ = getElementPosition(thePlayer)
				local playerRotX, playerRotY, playerRotZ = getElementRotation(thePlayer)
				local objectElement = createObject(2103, playerPosX, playerPosY, playerPosZ - 1, 0, 0, playerRotZ + 180)

				if isElement(objectElement) then
					local radioId = 1

					for i = 1, #storedHiFis + 1 do
						if not storedHiFis[i] then
							radioId = i
							break
						end
					end

					storedHiFis[radioId] = objectElement

					setElementInterior(objectElement, getElementInterior(thePlayer))
					setElementDimension(objectElement, getElementDimension(thePlayer))
					setElementData(objectElement, "radioId", radioId)
					setElementCollisionsEnabled(objectElement, true)

					exports.cosmo_chat:sendLocalMeAction(thePlayer, "lerak egy rádiót a földre.")

					exports.cosmo_dclog:sendDiscordMessage("**" .. getPlayerName(thePlayer) .. "** **(ID: ".. getElementData(thePlayer, "playerID") ..")** lerakott egy rádiót. Pozíció: X = **".. playerPosX .. "** Y = **" .. playerPosY .. "** Z = **" .. playerPosZ .."**.", "itemlog")
				end
			else
				outputChatBox("#ff9428[CosmoMTA]: #ffffffMár van hifi a körzetedben!", thePlayer, 255, 255, 255, true)
			end
		end
	end
end

addEvent("pickupRadio", true)
addEventHandler("pickupRadio", getRootElement(),
	function (hifiElement)
		if isElement(hifiElement) then
			local radioId = getElementData(hifiElement, "radioId")

			if radioId then
					exports.cosmo_inventory:giveItem(source, 82, 1)

					if storedHiFis[radioId] then
						if isElement(storedHiFis[radioId]) then
							destroyElement(storedHiFis[radioId])
						end

						storedHiFis[radioId] = nil
					end
			end
		end
	end)