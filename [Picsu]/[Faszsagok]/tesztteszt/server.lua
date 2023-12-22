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
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
	{1786.0093994141, -2044.5202636719, 13.544051170349,},
}

local chatElotag = "#4287f5Faszfej Gaming:#ffffff"

local obj = {}

function createBoxes()
	for k,v in pairs(dobozok) do 
		local x,y,z = unpack(v);
		local obj = createObject(964,x,y,z);
		setElementData(obj,"train.weapon.box",true);
		setElementFrozen(obj,true);
		setElementDoubleSided (obj, true )
	end
end

function boxDestroy(obj)
	for i,v in pairs(getElementsByType("object")) do
		if getElementModel(v) == 964 and getElementData(v, "train.weapon.box") then
			destroyElement(v)
			destroyElement(marker)
		end
	end
end

function serverOldaliClick(mouseButton, buttonState, clickedElement)
	if (mouseButton == "left") and (buttonState == "down") then
		if clickedElement then -- objectre kattol
			if getElementModel(clickedElement) == 964 and getElementData(clickedElement, "train.weapon.box") then
				local ul = getPedOccupiedVehicle(source)
				if not ul then -- ha nem ül járműben
					local pX, pY, pZ = getElementPosition(source)
					local dX, dY, dZ = getElementPosition(clickedElement)
					local tavolsag = getDistanceBetweenPoints3D(pX, pY, pZ, dX, dY, dZ)
					if (tavolsag < 2) then
						if not getElementData(clickedElement,"train.attached.veh") then
							if not getElementData(source, "hasBox") then
								setElementData(source, "hasBox", true)
								outputChatBox(chatElotag.."Felvettél egy ládát! Most vidd át a szomszéd épületbe, hogy ki tudd bontani!", source, 255, 255, 255, true)
								setElementData(source, "kezebenBox", clickedElement)
								exports.cosmo_boneattach:attachElementToBone(clickedElement, source, 3, 0, 0.7, 0, 0, 0, 90)
								
								setPedAnimation(source, "CARRY", "crry_prtial", 0, true, false, true, true)

							else
								outputChatBox(chatElotag.."Már van nálad egy láda.", source, 255, 255, 255, true)
							end
						else
							print("Attacholva van")
						end
					end
				else -- ha járműben ül
					outputChatBox(chatElotag.."Járműben ülve nem tudod felvenni a ládát!", source, 255, 255, 255, true)
				end
			end
		end
	end
end
addEventHandler("onPlayerClick", root, serverOldaliClick)


addEvent("ladaFelrakasServer", true)
addEventHandler("ladaFelrakasServer", getRootElement(),
	function (clickedVehicleElement)
		
	local objectBox = getElementData(source, "kezebenBox")
	exports.cosmo_boneattach:detachElementFromBone(objectBox)
		
	
	attachElements(objectBox, clickedVehicleElement, 0,-1.3,-0.5)

	setElementData(objectBox, "train.attached.veh", true)
		
	setElementData(source,"hasBox",false)

	end
)

function serverOldaliClickVehicle(mouseButton, buttonState, clickedVehicleElement)
	if (mouseButton == "left") and (buttonState == "down") then
		if clickedVehicleElement then -- objectre kattol
			if getElementModel(clickedVehicleElement) == 422 then
				local pX, pY, pZ = getElementPosition(source)
				local dX, dY, dZ = getElementPosition(clickedVehicleElement)
				local tavolsag = getDistanceBetweenPoints3D(pX, pY, pZ, dX, dY, dZ)
				if (tavolsag < 2) then
					if getElementData(source,"hasBox")	then
						if not getElementData(clickedVehicleElement,"train.boxinplato") then
							triggerEvent("ladaFelrakasServer", source, clickedVehicleElement)
							setElementData(clickedVehicleElement, "train.boxinplato",true)
						end
					print("Van nala box")
					end
				end	
			end	
		end
	end
end
addEventHandler("onPlayerClick", root, serverOldaliClickVehicle)

function serverOldaliClickBoxLevetel(mouseButton, buttonState, clickedElement)
	if (mouseButton == "left") and (buttonState == "down") then
		if clickedElement then -- objectre kattol
			if getElementModel(clickedElement) == 964 and getElementData(clickedElement, "train.weapon.box") then
				local ul = getPedOccupiedVehicle(source)
				if not ul then -- ha nem ül járműben
					local pX, pY, pZ = getElementPosition(source)
					local dX, dY, dZ = getElementPosition(clickedElement)
					local tavolsag = getDistanceBetweenPoints3D(pX, pY, pZ, dX, dY, dZ)
					if (tavolsag < 2) then
						if getElementData(clickedElement,"train.attached.veh") then
							if not getElementData(source, "hasBox") then
								detachElements ( clickedElement, source )
							end
						else
							print("Attacholva van")
						end
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerClick", root, serverOldaliClickBoxLevetel)