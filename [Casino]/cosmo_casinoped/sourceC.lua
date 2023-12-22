local screenX, screenY = guiGetScreenSize()
local responsiveMultipler = exports.cosmo_hud:getResponsiveMultipler()

pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));addEventHandler("onCoreStarted",root,function(functions) for k,v in ipairs(functions) do _G[v]=nil;end;collectgarbage();pcall(loadstring(base64Decode(exports.cosmo_core:getInterfaceElements())));end)

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function loadFonts()
	Roboto = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(12), false, "antialiased")
	Raleway14 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(14), false, "antialiased")
	Raleway18 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(18), false, "antialiased")
	Raleway24 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(24), false, "antialiased")
	Raleway12 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(12), false, "antialiased")
end

loadFonts()

addEventHandler("onAssetsLoaded", getRootElement(),
	function ()
		loadFonts()
	end
)

local panelState = false
local panelWidth = respc(400)
local panelHeight = respc(240)
local panelPosX = screenX / 2 - panelWidth / 2
local panelPosY = screenY / 2 - panelHeight / 2

local activeButton = false
local buttons = {
	buycoin = {
		panelPosX + respc(5),
		panelPosY + panelHeight - respc(80),
		panelWidth / 2 - respc(10),
		respc(30)
	},
	sellcoin = {
		panelPosX + panelWidth / 2 + respc(5),
		panelPosY + panelHeight - respc(80),
		panelWidth / 2 - respc(10),
		respc(30)
	},
	exit = {
		panelPosX + respc(5),
		panelPosY + panelHeight - respc(40),
		panelWidth - respc(10),
		respc(30)
	}
}

local currentBalance = 0
local selectedAmount = ""

local cursorState = false
local cursorStateChange = 0

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
		if button == "right" then
			if state == "up" then
				if not panelState then
					if isElement(clickedElement) then
						if getElementData(clickedElement, "currencyPed") then
							local playerX, playerY, playerZ = getElementPosition(localPlayer)
							local targetX, targetY, targetZ = getElementPosition(clickedElement)

							if getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ) <= 5 then
								if not isPedInVehicle(localPlayer) then
									if getElementData(localPlayer, "coinTransaction") then
										exports.cosmo_hud:showInfobox("error", "Kérlek várj egy kicsit!")
										return
									end

									togglePanel(true)
								end
							end
						end
					end
				end
			end
		end
	end)

function togglePanel(state)
	if state ~= panelState then
		panelState = state

		if panelState then

			currentBalance = getElementData(localPlayer, "char.ucoin") or 0
			selectedAmount = ""

			addEventHandler("onClientRender", getRootElement(), renderPanel)
			addEventHandler("onClientClick", getRootElement(), clickPanel)
			addEventHandler("onClientCharacter", getRootElement(), processInputCharacter)
			addEventHandler("onClientKey", getRootElement(), processInputKey)
			addEventHandler("onClientElementDataChange", localPlayer, onSlotCoinChange)
		else
			removeEventHandler("onClientElementDataChange", localPlayer, onSlotCoinChange)
			removeEventHandler("onClientKey", getRootElement(), processInputKey)
			removeEventHandler("onClientCharacter", getRootElement(), processInputCharacter)
			removeEventHandler("onClientClick", getRootElement(), clickPanel)
			removeEventHandler("onClientRender", getRootElement(), renderPanel)

		end
	end
end

function onSlotCoinChange(dataName)
	if dataName == "char.ucoin" then
		currentBalance = getElementData(localPlayer, dataName) or 0
	end
end

function clickPanel(button, state)
	if button == "left" then
		if state == "down" then
			if activeButton == "exit" then
				togglePanel(false)
			elseif activeButton == "buycoin" then
				local amount = tonumber(selectedAmount) or 0

				if amount > 0 then
					triggerServerEvent("buySlotCoin", localPlayer, amount)
					togglePanel(false)
				else
					exports.cosmo_hud:showInfobox("error", "Minimum 1db zsetont kell venned.")
				end
			elseif activeButton == "sellcoin" then
				local amount = tonumber(selectedAmount) or 0

				if amount > 0 then
					triggerServerEvent("sellSlotCoin", localPlayer, amount)
					togglePanel(false)
				else
					exports.cosmo_hud:showInfobox("error", "Minimum 1db zsetont kell eladnod.")
				end
			end
		end
	end
end

function processInputCharacter(character)
	if utfLen(selectedAmount) < 10 then
		if string.find(character, "[0-9]") then
			selectedAmount = selectedAmount .. character
		end
	end
end

function processInputKey(key, press)
	if press then
		if key == "backspace" then
			if utfLen(selectedAmount) >= 1 then
				selectedAmount = utfSub(selectedAmount, 1, -2)
			end
		elseif key ~= "escape" then
			cancelEvent()
		end
	end
end

function renderPanel()
	-- ** Háttér
	buttonsC = {}

	dxDrawRectangle(panelPosX, panelPosY, panelWidth, panelHeight, tocolor(0, 0, 0, 170))
	dxDrawRectangle(panelPosX + 3, panelPosY + 3, panelWidth - 6, respc(30), tocolor(0, 0, 0, 130))

	dxDrawText("#ff9428Cosmo#ffffffMTA - Zseton váltó", panelPosX + 3 + 5, panelPosY + respc(30) / 2 + 3, nil, nil, tocolor(255, 255, 255, 230), 1, Roboto, "left", "center", false, false, false, true)

	-- ** Content
	local amount = tonumber(selectedAmount) or 0

	-- Egyenleg
	dxDrawText("Jelenlegi egyenleg: #ff9428" .. formatNumberEx(currentBalance) .. " Zseton\n#ffffffÁr: #ff9428250 $/Zseton\n#ffffffÖsszesen: #ff9428" .. formatNumberEx(amount * 250) .. " $",
		panelPosX + panelWidth / 2, panelPosY + 3 + respc(40), nil, nil, tocolor(255, 255, 255, 230), 0.9, Roboto, "center", "top", false, false, false, true)

	-- Mennyiség
	dxDrawRectangle(panelPosX + respc(5), panelPosY + panelHeight - respc(130), panelWidth - respc(10), respc(40), tocolor(0, 0, 0, 160))

	local inputText = "Mennyiség: " .. formatNumberEx(selectedAmount)

	dxDrawText(inputText, panelPosX + respc(10), panelPosY + panelHeight - respc(130), 0, panelPosY + panelHeight - respc(90), tocolor(255, 255, 255, 230), 1, Roboto, "left", "center")

	if cursorStateChange + 500 <= getTickCount() then
		cursorState = not cursorState
		cursorStateChange = getTickCount()
	end

	if cursorState then
		dxDrawRectangle(panelPosX + respc(12) + dxGetTextWidth(inputText, 1, Roboto), panelPosY + panelHeight - respc(120), 1, respc(20), tocolor(255, 255, 255, 230))
	end

	drawButton3("buycoin", "Vásárlás", buttons.buycoin[1], buttons.buycoin[2], buttons.buycoin[3], buttons.buycoin[4], {255, 148, 40}, false, Roboto, true)

	drawButton3("sellcoin", "Eladás", buttons.sellcoin[1], buttons.sellcoin[2], buttons.sellcoin[3], buttons.sellcoin[4], {255, 148, 40}, false, Roboto, true)

	drawButton3("exit", "Kilépés", buttons.exit[1], buttons.exit[2], buttons.exit[3], buttons.exit[4], {215, 89, 89}, false, Roboto, true)

	-- ** Hovering
	local cx, cy = getCursorPosition()

	activeButton = false
	activeButtonC = false

	if cx then
		cx = cx * screenX
		cy = cy * screenY

		for k, v in pairs(buttons) do
			if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
				activeButton = k
				break
			end
		end

		for k, v in pairs(buttonsC) do
			if cx >= v[1] and cx <= v[1] + v[3] and cy >= v[2] and cy <= v[2] + v[4] then
				activeButtonC = k
				break
			end
		end
	end
end

function formatNumberEx(amount, stepper)
	amount = tonumber(amount)

	if not amount then
		return ""
	end

	local left, center, right = string.match(math.floor(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. string.reverse(string.gsub(string.reverse(center), "(%d%d%d)", "%1" .. (stepper or " "))) .. right
end