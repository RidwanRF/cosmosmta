function thaResourceStarting( ) 
	local cigany = createWater(1315, 70, 25, 1332, 70, 25, 1318, 103, 25, 1355, 110, 25)
	setWaterLevel(cigany, 28.3)
end 
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), thaResourceStarting)  