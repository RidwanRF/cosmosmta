local connection = exports.cosmo_database:getConnection()

function addegg ( playerSource, commandName )
	if ( playerSource ) then
		outputChatBox("[COSMOMTA] Pozíció lementve.", playerSource, 255, 255, 255, true)
		local x, y, z = getElementPosition ( playerSource )
	--	createBlip( x, y, z, 1, 2, 255, 0, 255 )
		local fileHandle = fileOpen("eggs.txt")
		if not fileHandle then fileHandle = fileCreate("eggs.txt") end
		if fileHandle then
			local size = fileGetSize(fileHandle)
			fileSetPos(fileHandle, size)
		    fileWrite(fileHandle, "{"..x..", "..y..", "..z.."},\n")
		    fileFlush(fileHandle)
		    fileClose(fileHandle)
		end
	end
end
addCommandHandler ( "addchest", addegg )

local _ran = {}
addEventHandler("onResourceStart", getResourceRootElement(), function()
    setTimer(everyHours, 1*60*60*1000, 0)
    setTimer(halfHours, 30*60*1000, 0)
    spawnEggs()
    everyHours()
    halfHours()
end)

everyHours = function()
	local datetime = getRealTime()
	--if not _ran[(datetime.year-100)..(datetime.month+1)..(datetime.monthday)..(datetime.hour)] then
	--	_ran[(datetime.year-100)..(datetime.month+1)..(datetime.monthday)..(datetime.hour)] = true
	--	if datetime.hour >= 8 and datetime.hour <= 23 then
			spawnEggs()

	--	end
	-- end
end

halfHours = function(source)
	outputChatBox("#f4425fEvent: #f7f4f5A játéktérben ládák vannak elrejtve. Ha találsz egyet, kattints rá.", source, 255, 255, 255, true)
	outputChatBox("#f4425fFigyelem! #f7f4f5A ládák értelmes jutalmakat rejthetnek.", source, 255, 255, 255, true)
end

addEvent("clickChest", true)
addEventHandler("clickChest", getRootElement(), function(eggId)
	if isElement(getElementByID(eggId)) then
		destroyElement(getElementByID(eggId))
		local randomDatas = {
			[1] = {1, 94, "", ""} -- láda geci kurva anyád
		}
		local total = 0
		for i=1, 1 do
			total = total+randomDatas[i][1]
		end
		local random = math.random(1, total)
		local total = 0
		for i=1, 1 do
			local prev = total
			total = total+randomDatas[i][1]
			if prev+1 <= random and total >= random then
				random = i
				break
			end
		end
		outputChatBox("#f4425fEvent: #FFFFFFFelvettél egy ládát a földről. (Inventoryban megtalálod)", source, 255, 255, 255, true)
		exports.cosmo_inventory:giveItem(source, randomDatas[random][2], 1)
		triggerClientEvent ( source, "allowChest", source, eggId )
	end
end)

function spawnEggs()
	for i=1, 35 do
		local random = math.random(1, #eggs)
		local tries = 0
		while (getElementByID("chest:"..random) and tries <= 35) do
			random = math.random(1, #eggs)
			tries = tries+1
		end
		if not getElementByID("chest:"..random) then
			local egg = createObject(2969, eggs[random][1], eggs[random][2], eggs[random][3]-0.8)
			setElementID(egg, "chest:"..random)
			setElementData(egg, "specialChest", true)
		end
	end
end