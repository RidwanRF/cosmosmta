--script by lennon
addEventHandler('onClientResourceStart', resourceRoot, function(res)
	if res == 'cosmo_core' or res == getThisResource() then
		font = exports.cosmo_assets:loadFont("BebasNeue-Regular.ttf", respc(13), false, "antialiased")
		smallfont = exports.cosmo_assets:loadFont("BebasNeue-Regular.ttf", respc(10), false, "antialiased")
		setElementData(localPlayer, "inDrugLab", false)
	end
end)

txd = engineLoadTXD("files/tent.txd")
engineImportTXD(txd, 14812)
col = engineLoadCOL("files/tent.col")
engineReplaceCOL(col, 14812)
dff = engineLoadDFF("files/tent.dff", 14812)
engineReplaceModel(dff, 14812)
engineSetModelLODDistance(14812, 900)

local sX, sY = guiGetScreenSize()
local panelW, panelH = 200, 35
local panelX, panelY = sX/2 - panelW/2, sX/2 - panelH/2 - 150

local makeW, makeH = 300, 300
local makeX, makeY = sX/2 - makeW/2, sY/2 - makeH/2
local showProgress = false
local progressNumber = 0


function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

screenX, screenY = guiGetScreenSize()
responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
	return responsiveMultipler
end

local variables = {
	showDrugLabPanel = false,
	showMakingPanel = false,
	bottlePng = "files/bottle.png",
}

local ingredients = {
	{"Kémiai képlet:", "#D55757C10H15N"},
	{"Moláris tömeg:", "#ff9428149,233 g/mol"},
	{"Összetevő:", "#D3C873Lítium akkumulátor"},
	{"Összetevő ára:", "#8BAF6C$#ffffff10.000"},
	{"Előállítás:", "Az üvegre kattintva!"},
}

addEventHandler("onClientRender", getRootElement(), function()
	if variables.showMakingPanel then
		local pX, pY, pZ = getElementPosition(localPlayer)
		local eX, eY, eZ = getElementPosition(drugLabTable)
		if getDistanceBetweenPoints3D(pX, pY, pZ, eX, eY, eZ) > 3 then
			variables.showMakingPanel = false
			if showProgress then
				showProgress = false
				progressNumber = 0
				setElementData(drugLabTable, "factionScript > drugLab_workTableInUse", false)
				triggerServerEvent("attach > drugLaborBottle", localPlayer, localPlayer, "take")
				setPedAnimation(localPlayer, nil, nil)
				exports.cosmo_hud:showInfobox("warning", "Droggyártás folyamat megszakítva!")
				setElementFrozen(localPlayer, false)
			end
			return 
		end
		dxDrawRectangle(makeX, makeY, makeW, makeH, tocolor(0, 0, 0, 200))
		centerText("Metamfetamin #ff9428készítés", makeX, makeY - 135, makeW, makeH, tocolor(255, 255, 255, 255), 1, smallfont)		
		setElementFrozen(localPlayer, true)
		if exports.cosmo_core:isInSlot(makeX, makeY + 210, 64, 64) then
			dxDrawImage(makeX, makeY + 210, 64, 64, variables.bottlePng, 0, 0, 0, tocolor(255, 255, 255, 255))
		else
			dxDrawImage(makeX, makeY + 210, 64, 64, variables.bottlePng, 0, 0, 0, tocolor(155, 155, 155, 255))
		end
		for k, v in pairs(ingredients) do
			dxDrawRectangle(makeX + 5, makeY + (k*32), makeW - 10, 25, tocolor(0, 0, 0, 150))
			centerText(v[1].." "..v[2], makeX + 5, makeY + (k*32), makeW - 10, 25, tocolor(255, 255, 255, 255), 1, font)
		end
		dxDrawRectangle(makeX + 60, makeY + 230, 200, 25, tocolor(0, 0, 0, 150))
		if showProgress then
			local bottleAnim = interpolateBetween(0, 0, 0, 255, 255, 255, (getTickCount() - tick) / 15550, "Linear")
			dxDrawRectangle(makeX + 60 + 5, makeY + 230 + 5, (200 - 10) * (progressNumber/2500), 25 - 10, tocolor(112, 152, 207, bottleAnim))
		end
		centerText("Előállitás állapota", makeX + 60, makeY + 230, 200, 25, tocolor(255, 255, 255, 255), 1, font)
	end
end)

addEventHandler("onClientClick", getRootElement(), function(button, state)
	if button == "left" and state == "down" then
		if variables.showMakingPanel then
			if exports.cosmo_core:isInSlot(makeX, makeY + 210, 64, 64) then
				if showProgress then
					return
				end
				exports.cosmo_core:takeMoney(localPlayer, 10000)
				tick = getTickCount()
				showProgress = true
				triggerServerEvent("attach > drugLaborBottle", localPlayer, localPlayer, "give")
				exports.cosmo_chat:sendLocalMeAction(localPlayer, "elkezdi rázni a vegyszerekkel teli üveget.")
			end
		end 
	end
end)

addEventHandler("onClientRender", getRootElement(),function()
	if not (showProgress) then
		return
	end
	if (progressNumber >= 2500) then
		showProgress = false
		progressNumber = 0
		setElementData(drugLabTable, "factionScript > drugLab_workTableInUse", false)
		triggerServerEvent("attach > drugLaborBottle", localPlayer, localPlayer, "take")
		setPedAnimation(localPlayer, nil, nil)
		exports.cosmo_hud:showInfobox("info", "Sikeres droggyártás!")
		setElementFrozen(localPlayer, false)
		triggerServerEvent("giveitem", localPlayer, localPlayer)
		variables.showMakingPanel = false
	end
	progressNumber = progressNumber + 1
	setTimer(function()
		checkMakingProcess(progressNumber)
	end, 5000, 1)
end)

function checkMakingProcess(process)
	if process > 1000 then
		local odds = math.random(70, 100)
		if odds < 70 then
			progressNumber = 0
			showProgress = false
			variables.showMakingPanel = false			
			setElementData(drugLabTable, "factionScript > drugLab_workTableInUse", false)
			triggerServerEvent("attach > drugLaborBottle", localPlayer, localPlayer, "take")
			exports.cosmo_hud:showInfobox("warning", "Az üveg szétrobbant! Sürgős ellátásra van szükséged!")
			setElementFrozen(localPlayer, false)
			local pX, pY, pZ = getElementPosition(localPlayer)
			local effect = createEffect("explosion_tiny", pX, pY, pZ)
			local playerHealth = getElementHealth(localPlayer)
			setElementHealth(localPlayer, playerHealth - math.random(5, 15))
			triggerServerEvent("anim > drugLabor", localPlayer, localPlayer)
			setTimer(function()
				setPedAnimation(localPlayer, nil, nil)
			end, 5000, 1)
			exports.cosmo_chat:sendLocalDoAction(localPlayer, "Szétrobban a methes üveg.")
		end
		--iprint(odds)
	end
end

addEventHandler("onClientClick", getRootElement(), function(button, state, _, _, _, _, _, element)
	if button == "left" and state == "down" then
		if not variables.showMakingPanel then
			if element and getElementType(element) == "object" then
				if getElementData(element, "factionScript > drugLab_workTable") then
					local pX, pY, pZ = getElementPosition(localPlayer)
					local eX, eY, eZ = getElementPosition(element)
					if getElementData(element, "factionScript > drugLab_workTableInUse") then
						return exports.cosmo_hud:showInfobox("warning", "Valaki már használja az asztalt!")
					end
					if getDistanceBetweenPoints3D(pX, pY, pZ, eX, eY, eZ) < 2 then
						variables.showMakingPanel = true
						drugLabTable = element
						setElementData(element, "factionScript > drugLab_workTableInUse", true)
					end
				end
			end
		end
	end
end)

bindKey("backspace", "down", function()
	if variables.showMakingPanel then
		if not showProgress then
			variables.showMakingPanel = false
			setElementData(drugLabTable, "factionScript > drugLab_workTableInUse", false)
			triggerServerEvent("attach > drugLaborBottle", localPlayer, localPlayer, "take")
			setElementFrozen(localPlayer, false)
		end
	end
end)

addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), function()
	if variables.showMakingPanel then
		variables.showMakingPanel = false
	end
	if variables.showDrugLabPanel then
		variables.showDrugLabPanel = false
	end
	if showProgress then 
		showProgress = false
		progressNumber = 0
	end
	triggerServerEvent("attach > drugLaborBottle", localPlayer, localPlayer, "take")
	setElementData(drugLabTable, "factionScript > drugLab_workTableInUse", false)
end)

function centerText(text, x, y, w, h, color, fontS, font)
    dxDrawText(text, x+w/2, y+h/2, x+w/2, y+h/2, color, fontS, font, "center", "center", false, false, false, true)
end 

function leftText(text, x, y, w, h, color, fontS, font)
    dxDrawText(text, x+w/2, y+h/2, x+w/2, y+h/2, color, fontS, font, "left", "center", false, false, false, true)
end 

function rightText(text, x, y, w, h, color, fontS, font)
    dxDrawText(text, x+w/2, y+h/2, x+w/2, y+h/2, color, fontS, font, "right", "center", false, false, false, true)
end 