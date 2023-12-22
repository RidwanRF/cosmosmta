function resourceStart ( res )
	createBoxes()
	setTimer(function()
		boxDestroy()
		createBoxes()
		print("létrehozva")
	end, 1000*60*60, 0)	
end
addEventHandler ( "onResourceStart", resourceRoot, resourceStart )

local dobozok = {
	{1170.9012451172, -1748.8419189453, 13.3984375,},
}

local chatElotag = "#4287f5Faszfej Gaming:#ffffff"

local obj = {}

function createBoxes()
	for k,v in pairs(dobozok) do 
		local x,y,z = unpack(v);
		local obj = createObject(2358,x,y,z);
		setElementData(obj,"event.box",true);
		setElementFrozen(obj,true);
	end
end

function boxDestroy(obj)
	for i,v in pairs(getElementsByType("object")) do
		if getElementModel(v) == 2358 and getElementData(v, "event.box") then
			destroyElement(v)
			destroyElement(marker)
		end
	end
end

function serverOldaliClick(mouseButton, buttonState, clickedElement)
	if (mouseButton == "left") and (buttonState == "down") then
		if clickedElement then -- objectre kattol
			if getElementModel(clickedElement) == 2358 and getElementData(clickedElement, "event.box") then
				local ul = getPedOccupiedVehicle(source)
				if not ul then -- ha nem ül járműben
					local pX, pY, pZ = getElementPosition(source)
					local dX, dY, dZ = getElementPosition(clickedElement)
					local tavolsag = getDistanceBetweenPoints3D(pX, pY, pZ, dX, dY, dZ)
					if (tavolsag < 2) then
						destroyElement(clickedElement)
						addingItemId = math.random (235,237)
						exports.cosmo_inventory:giveItem(source, addingItemId, 1, nil, nil, nil)
						outputChatBox(chatElotag.."Kaptál egy: #4287f5"..exports.cosmo_inventory:getItemName(addingItemId).."#ffffff-(o)t.", source, 255, 255, 255, true)
					end
				else -- ha járműben ül
					outputChatBox(chatElotag.."Járműben ülve nem tudod felvenni a ládát!", source, 255, 255, 255, true)
				end
			end
		end
	end
end
addEventHandler("onPlayerClick", root, serverOldaliClick)



