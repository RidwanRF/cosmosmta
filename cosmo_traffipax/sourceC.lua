function getVehicleSpeed(veh)
	if not veh then 
		veh = getPedOccupiedVehicle(localPlayer);
	end
	if veh then
		local x, y, z = getElementVelocity (veh)
		return math.sqrt( x^2 + y^2 + z^2 ) * 187.5
	end
end
local traffiPos = {--X, Y, Z, Rot[1,2,3], speedLimit, colshape elheleyzekédes X, Y
    {-155.03274536133, -1288.578125, 3.0390625,0, 0, 130, 90,  -143.23539733887, -1267.6221923828, 2.6953125, 7},--SF-Flint Intersection
	{375.88943481445, -1709.4959716797, 7.4898753166199,0, 0, 90, 70, 381.85366821289, -1709.8363037109, 7.8282375335693, 15},--Santa Maria Beach
	{902.98486328125, -1797.5991210938, 13.602427482605,0, 0, 140, 60, 915.69488525391, -1780.5633544922, 13.554653167725, 14},--Verona beach
	{1236.8638916016, -1858.0030517578, 13.546875,0, 0, 140, 80, 1244.0766601562, -1852.3198242188, 13.3828125, 5},--Verdant Bluffs
	{1913.9978027344, -1741.4368896484, 13.511259078979,0, 0, 50, 50, 1919.7661132812, -1752.3541259766, 13.3828125, 5},-- Déli benzinkút
    {1858.1114501953, -1422.2537841797, 13.5625,0, 0, 210, 50, 1849.4138183594, -1406.4018554688, 13.390625, 7},--Glen Park
	{2164.0771484375, -1108.7385253906, 25.551704406738,0, 0, 80, 50, 2200.6811523438, -1121.921875, 25.332704544067, 10},--Las Colinas
	{2585.7858886719, -1160.935546875, 48.877319335938,0, 0, 140, 50, 2597.271484375, -1152.8439941406, 49.409671783447, 8},--Los Flores
	{2901.6032714844, -1219.7116699219, 11.070335388184,0, 0, 230, 120, 2883.0576171875, -1203.8211669922, 10.875, 15},--East Beach
	{2526.5942382812, -2150.0185546875, 13.538179397583,0, 0, 320, 120, 2508.8461914062, -2163.2165527344, 13.554285049438, 15},--Ocean Docks
	{1352.2725830078, -2359.4721679688, 13.546875,0, 0, 340, 90, 1346.0211181641, -2378.8588867188, 13.382152557373, 5},--Los Santos International
	{2175.6667480469, -1390.7452392578, 23.984375,0, 0, 140, 50, 2184.4626464844, -1384.35546875, 23.832447052002, 5},--Jefferson
	{2377.7556152344, -1739.4040527344, 13.546875,0, 0, 220, 50, 2371.6713867188, -1732.3154296875, 13.3828125, 5},--Ganton
	{1881.2482910156, -2160.3559570312, 13.546875,0, 0, 80, 50, 1894.9465332031, -2166.5834960938, 13.3828125, 5},--El Corona
	{1421.1942138672, -1738.1392822266, 13.546875,0, 0, 140, 50, 1428.5131835938, -1732.453125, 13.3828125, 5},--commerce
	{1304.9578857422, -1720.62890625, 13.546875,0, 0, 180, 50, 1304.9578857422, -1720.62890625, 13.546875, 13},--conference center
	{1336.5617675781, -1260.5594482422, 13.546875,0, 0, 140, 50, 1349.8259277344, -1244.1707763672, 13.391826629639, 13},--Market
	{1228.2221679688, -1033.3289794922, 31.931446075439,0, 0, -30, 50, 1222.650390625, -1039.2296142578, 31.730171203613, 7},--Temple
	{915.77355957031, -1135.7127685547, 23.832809448242,0, 0, 140+180, 50,  909.81726074219, -1144.9739990234, 23.88477897644, 10},--Vinewood



}

local disableVehs = {
    [596] = true,
    [598] = true,
    [597] = true,
    [575] = true,
}
white = "#FFFFFF";
local Traffis = {}
local colShape = {}

local trafiBlip = {}
local blipState = false
 
function createTraffi ()
	for i,v in ipairs (traffiPos) do
		Traffis[i] = createObject(1337, v[1],v[2],v[3]-1.04,v[4], v[5], v[6])
		--colShape[i] = createColCuboid(v[1]-15, v[2]-15, v[3]-1.5, 40, 40, 3)
		colShape[i] = createColSphere(v[8],v[9],v[10]-1,v[11])
		setElementData(colShape[i], "colshape.ID", i)

		txd = engineLoadTXD("files/traffi_allo.txd") 
        col = engineLoadCOL("files/traffi_allo.col") 
        dff = engineLoadDFF("files/traffi_allo.dff", 0) 
        
        engineImportTXD(txd, 1337) 
        engineReplaceCOL(col, 1337) 
        engineReplaceModel(dff, 1337) 
	end
 end
 addEventHandler ( "onClientResourceStart", resourceRoot, createTraffi)

addEventHandler("onClientColShapeHit",getRootElement(), function (colShapePlayer)
	if colShapePlayer ~= localPlayer then return end
	if not isPedInVehicle(localPlayer) then return end
	if disableVehs[getElementModel(getPedOccupiedVehicle(localPlayer))] then return end
	if getPedOccupiedVehicleSeat(localPlayer) == 0 then 
     if getElementData(getPedOccupiedVehicle(localPlayer), "sirenInVeh") then return end
		local colshapeID = getElementData(source, "colshape.ID") or 0
		if colshapeID > 0 then 
			if getVehicleType(getPedOccupiedVehicle(localPlayer)) == "Automobile" or getVehicleType(getPedOccupiedVehicle(localPlayer)) == "Bike" then
				end
				local vehicle = getPedOccupiedVehicle(localPlayer)
				local occupants = getVehicleOccupants(vehicle) or {}
				local ticket = calculateTicket(getVehicleSpeed(vehicle) - traffiPos[colshapeID][7])*0.6*2
				local serverColor = "#ff9428"
				local speed = getVehicleSpeed(vehicle) - traffiPos[colshapeID][7]
				for seat, occupant in pairs(occupants) do 
					if speed > 0 and seat==0 then 
						--outputChatBox("Traffipax","#3F75D3".."Átlépted sebességhatárt, megengedett sebesség: "..serverColor..traffiPos[colshapeID][7].."#ffffff km/h!",255,255,true)
						--outputChatBox("Traffipax","#3F75D3".."A túllépés mértéke: "..serverColor..math.ceil(speed)..white.." km/h. #ffffffBirság: "..serverColor..formatMoney(math.ceil(ticket)) ..white.. " Ft",255,255,true)
						outputChatBox ("#ff9428[Traffipax] #ffffffÁtlépted a sebességhatárt, megengedett sebesség: "..serverColor..traffiPos[colshapeID][7].."#ffffff km/h!",255,255,255,true)
						outputChatBox ("#ff9428[Traffipax] #ffffffA túllépés mértéke: " .. math.ceil(speed) .. "km/h #ffffffBirság: "..serverColor..formatMoney(math.ceil(ticket)) ..white.. " $",255,255,255,true)
						triggerServerEvent("setGroupBalance", localPlayer, 1, ticket)
						setElementData(localPlayer, "char.Money", getElementData(localPlayer, "char.Money") - tonumber(ticket))
					end
				end
				if ticket > 0 then 
						
					playSound("files/shutter.mp3")
					outputDebugString(ticket)
				end
			end
		end
end)

function calculateTicket(a)
	local mul = 800
	if getElementData(localPlayer, "char.Money") > 100 then
		if math.ceil(a) > 2 then
			mul = 20
		else
			mul = 20
		end
	elseif getElementData(localPlayer, "char.Money") < 0 then
		if math.ceil(a) > 2 then
			mul = 20
		else
			mul = 20
		end
	else 
		if math.ceil(a) > 2 then
			mul = 20
		else
			mul = 20
		end
	end

	return math.ceil(a*mul*20)
end

function formatMoney(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

addEvent("getBlipFromWantedVehicle", true)
addEventHandler("getBlipFromWantedVehicle", root, function(player)
	local veh = getPedOccupiedVehicle(player)
	local blip = createBlipAttachedTo(veh, 1)
	 setElementData(blip,"blipIcon","target")
	setElementData(blip, "blipTooltipText", "Körözött jármű | "..exports.cosmo_mods_veh:getVehicleName(veh) .."(" ..getVehiclePlateText(veh) ..")")
    --setElementData(blip, "blip >> maxVisible",true);
    setElementData(blip,"blipColor",tocolor(235,85,85,255))
    setElementData(blip,"blipFarShow",true)
	setTimer(function()
		destroyElement(blip)
	end, 10000, 1)
end)