addEventHandler("onResourceStart", resourceRoot, function()
	local object_workTable = createObject(941, 889.92, -21.7197, 63.2926 - 0.5, 0, 0, 270)

	setElementData(object_workTable, "factionScript > drugLab_workTable", true)
	setElementData(object_workTable, "factionScript > drugLab_workTableInUse", false)

	local object_suppliesBag = createObject(2694,  889.92, -21.7197, 63.2926 + 0.1, 0, 0, 180)

	for i = 1, 4 do
		local object_bottle = createObject(1950, 889.92, -21.7197 - 1.5 + (i*0.5), 63.2926 - 0.8, 0, 0, 180)

		setElementFrozen(object_bottle, true)
	end 

	local tent = createObject(14812, 888.1587 + 1, -18.7021 - 2, 63.3363 - 1.2, 0, 0, - 25)
	local crate = createObject(3576, 886.7311, -25.3742, 63.2451, 0, 0, 40)
	local gasoline = createObject(3633, 887.2808, -20.5247, 63.3125 - 0.5)
end)

addEvent("attach > drugLaborBottle", true)
addEventHandler("attach > drugLaborBottle", getRootElement(), function(player, state)
	if state == "give" then
		local x,y,z = getElementPosition(player)
        obj = createObject(1950, x, y, z)
        attached_bottle = exports.cosmo_boneattach:attachElementToBone(obj, player, 12, 0, 0, 0.1, 0, -90, 0)
        setObjectScale(obj, 0.8)
        setPedAnimation(player, "heist9", "use_swipecard", -1, true, false, false)
	elseif state == "take" then
		if attached_bottle and isElement(obj) then
            exports.cosmo_boneattach:detachElementFromBone(obj)
            destroyElement(obj)
        end
        setPedAnimation(player, nil, nil)
	end
end)

addEvent("anim > drugLabor", true)
addEventHandler("anim > drugLabor", getRootElement(), function(player)
	setPedAnimation(player, "crack", "crckdeth1", -1, false, false, false)
	setTimer(function()
		setPedAnimation(player, nil, nil)
	end, 5000, 1)
end)

addEvent("giveitem", true)
addEventHandler("giveitem", getRootElement(), function(player)
	exports.cosmo_inventory:addItem(player, 254, 1, false, data1, data2, data3)
end)

addEvent("animki", true)
addEventHandler("animki", getRootElement(),
function ()
	if isElement(source) then
		setPedAnimation(source, "CASINO", "Roulette_out", -1, false, false, false, false)
	end
end)

addEvent("animbe", true)
addEventHandler("animbe", getRootElement(),
function ()
	if isElement(source) then
		setPedAnimation(source, "CASINO", "Roulette_loop", -1, true, false, false, false)
	end
end)

