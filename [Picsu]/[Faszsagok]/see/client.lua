local components = {
    [502] = 'display',
    [559] = 'engine',
    [516] = 'rs7_body',
};

addEventHandler('onClientResourceStart', resourceRoot, function()
	setTimer(function()
		for i, veh in ipairs(getElementsByType("vehicle", root, true)) do
			delLogo(veh)
		end
	end, 2000, 0)
end);

addEventHandler('onClientElementStreamIn', root, function()
    delLogo(source)
end);

function delLogo(vehicle)
    if (getElementType(vehicle) ~= 'vehicle') then return; end
    if (components[getElementModel(vehicle)]) then 
        local comp = components[getElementModel(vehicle)];
        if (comp and getVehicleComponentVisible(vehicle, comp)) then 
			--outputChatBox("asd")
            setVehicleComponentVisible(vehicle, comp, false); 
        end
    end
end


-- Kocsi komponent render
local showComps = false;

addCommandHandler('showcomps', function()
    showComps = not showComps;
	local vehicle = getPedOccupiedVehicle(localPlayer);
	if (vehicle) then
		local tabla = {}
		outputChatBox("--------------")
		for component in pairs(getVehicleComponents(vehicle)) do
			table.insert(tabla, component)
			outputChatBox(component)
		end
		outputChatBox("--------------")
		
		local index = 0
		setTimer(function()
			index = index + 1
			outputChatBox(tabla[index])
			setVehicleComponentVisible(vehicle, tabla[index], false)
		end, 1500, #tabla)
	end
end);

addEventHandler('onClientRender', root, function()
    if (showComps) then 
        local vehicle = getPedOccupiedVehicle(localPlayer);
        if (vehicle) then 
            for component in pairs(getVehicleComponents(vehicle)) do 
               -- local x, y, z = getVehicleComponentPosition(vehicle, component, 'world');
              --  local sx, sy = getScreenFromWorldPosition(x, y, z);
               -- if (sx and sy) then 
                  --  dxDrawText(component, sx, sy, _, _, tocolor(255, 0, 0), 1, 'arial', 'center', 'center');
               -- end
            end
        end
    end
end);