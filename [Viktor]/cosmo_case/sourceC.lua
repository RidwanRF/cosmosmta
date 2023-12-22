local screenX,screenY = guiGetScreenSize()
local panelState = false
local itemSize = 45
local rollSizeX = screenX
local rollSizeY = itemSize
local renderTarget = false
local shuffledItems = {}
local raffleState = false
local itemStartX = 0
local itemStopX = 0
local winnedItem = false
local buttons = {}
local activeButton = false
local selectedCase = false

addEvent("showTheRaffle",true)
addEventHandler("showTheRaffle",root,
	function (case)
		togglePanel(true)
		if case == "defaultEgg" or case == "redEgg" or case == "goldEgg" then
			easter = true
		end
		selectedCase = case
		startRaffle(selectedCase)
	end
)

function togglePanel(state)
	if state ~= panelState then
		if state then
			addEventHandler("onClientRender",root,renderTheRaffle)
			panelState = true
			winnedItem = false
			raffleState = false
			selectedCase = false
			showGetButton = false
		else
			removeEventHandler("onClientRender",root,renderTheRaffle)
			panelState = false
			winnedItem = false
			raffleState = false
			selectedCase = false
			easter = false
			showGetButton = false
			if isElement(renderTarget) then
				destroyElement(renderTarget)
				renderTarget = nil
			end
		end
	end
end

function startRaffle(case)
	shuffledItems = {}
	math.randomseed(getTickCount()+math.random(getTickCount()))
	while #shuffledItems <= 100 do
		local item = availableCases[case][math.random(#availableCases[case])]
		if math.random(1,100) <= item[2] then
			table.insert(shuffledItems,item)
		end
		shuffleTable(availableCases[case])
	end
	itemStartX = 0
	itemStopX =  math.ceil(#shuffledItems/2)*(itemSize+10)
	raffleState = getTickCount()
end

local lastItem = false
local itemTick = false

function renderTheRaffle()
	if panelState then
		buttons = {}
		local now = getTickCount()
		local moveX = itemStartX
		if tonumber(raffleState) and now >= raffleState then
			local elapsedTime = now-raffleState
			local duration = 10000
			local progress = elapsedTime/duration
			moveX = interpolateBetween(
				itemStartX,0,0,
				-itemStopX,0,0,
				progress,"InOutQuad"
			)
			if progress >= 1 then
				raffleState = "endRaffle"
				itemStartX = -itemStopX
				itemTick = getTickCount()
			end
		end
		local imageSize = itemSize-20
		local y = screenY/2-itemSize
		dxDrawRectangle(0,y-10,screenX,itemSize+20,tocolor(25,25,25))
		dxDrawRectangle(0,y-10,screenX,2,tocolor(255, 148, 40))
		dxDrawRectangle(0,y-10+itemSize+18,screenX,2,tocolor(255, 148, 40))
		for i = 1,#shuffledItems do
			local x = moveX+(i-1)*(itemSize+10)
			local image = ":cosmo_inventory/files/items/"  ..  shuffledItems[i][1] .. ".png"
			dxDrawImage(x,y,itemSize,itemSize,image)
			if raffleState == "endRaffle" and not winnedItem then
				if (screenX-2)/2 >= x and (screenX-2)/2 <= x+itemSize then
					winnedItem = shuffledItems[i]
				end
			elseif (screenX-2)/2 >= x and (screenX-2)/2 <= x+itemSize then
				if lastItem ~= i then
					playSound("files/roll.mp3")
					lastItem = i
				end
			end
		end
		dxDrawRectangle((screenX-2)/2,y-10,2,itemSize+20,tocolor(255, 148, 40)) 
		if easter then
		end
		if winnedItem then
			local elapsedTime = now-itemTick
			local duration = 1000
			local progress = elapsedTime/duration

			imageSize = interpolateBetween(
				0,0,0,
				1,0,0,
				progress,"InOutQuad"
			)
			if progress >= 1 then
				showGetButton = true
			end
		end
		local absX,absY = getCursorPosition()
		if isCursorShowing() then
			absX,absY = absX*screenX,absY*screenY
		else
			absX,absY = -1,-1
		end
		local buttonW,buttonH = 300,40
		local buttonX,buttonY = (screenX-buttonW)*0.5,y+itemSize+20
		if winnedItem and showGetButton then
			local itemName = exports.cosmo_inventory:getItemName(winnedItem[1])

			outputChatBox("#ff9428[CosmoMTA - Láda Nyitás]:#ffffff Sikeresen #ff9428kinyitottad #ffffffa ládát!", 255, 255, 255, true)
			outputChatBox("#ff9428[CosmoMTA - Láda Nyitás]:#ffffff Nyitott item: #ff9428" .. itemName, 255, 255, 255, true)

			triggerServerEvent("giveWinnedItem", localPlayer, localPlayer, selectedCase, winnedItem)
			togglePanel(false)
		end
		activeButton = false
		if isCursorShowing() then
			for k,v in pairs(buttons) do
				if absX >= v[1] and absX <= v[1]+v[3] and absY >= v[2] and absY <= v[2]+v[4] then
					activeButton = k
					break
				end
			end
		end
	end
end