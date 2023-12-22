local infobox = {}
local kickbox = {}
local interiorbox = false

local boxSize = respc(32)
local iconSize = respc(24)
local boxSize2 = respc(64)

function showInteriorBox(text, text2, isLocked, interiorType, gameInterior)
	interiorbox = {}

	interiorbox.text = text
	interiorbox.text2 = text2

	if isLocked == "Y" then
		interiorbox.doorState = "close"
	else
		interiorbox.doorState = "open"
	end

	interiorbox.interiorType = interiorType
	interiorbox.gameInterior = gameInterior

	if gameInterior then
		if not fileExists(":cosmo_interiors/files/pics/" .. gameInterior .. ".jpg") then
			interiorbox.gameInterior = false
		end
	end

	local textWidth = dxGetTextWidth(text, 0.55, Interiorfont)
	local textWidth2 = dxGetTextWidth(text2, 0.85, Roboto)

	interiorbox.tileWidth = textWidth

	if textWidth2 > textWidth then
		interiorbox.tileWidth = textWidth2
	end

	interiorbox.alphaGetStart = getTickCount()
	interiorbox.openTileTick = interiorbox.alphaGetStart + 500
	interiorbox.closeTileTick = false
	interiorbox.alphaGetInverse = false
end

function setInteriorDoorState(isLocked, interiorType)
	if interiorbox then
		if isLocked == "Y" then
			interiorbox.doorState = "close"
		else
			interiorbox.doorState = "open"
		end

		interiorbox.interiorType = interiorType
	end
end

function endInteriorBox()
	if interiorbox then
		interiorbox.closeTileTick = getTickCount()
		interiorbox.alphaGetInverse = interiorbox.closeTileTick + 500
	end
end

local interiorW, interiorH = respc(350), respc(130)
local interiorX = screenX / 2 - interiorW / 2

local interiorButtons = {
	[1] = {
		name = "Kopogás",
		action = "kopogtat"
	},

	[2] = {
		name = "Csengetés",
		action = "csenget"
	}
}

local buttonM = 3

addEventHandler("onClientClick", getRootElement(),
	function(sourceKey, keyState)
		if sourceKey == "left" and keyState == "down" then
			if activeButtonC then
				if activeButtonC then
					if activeButtonC == "csenget" or activeButtonC == "kopogtat" then
						executeCommandHandler(activeButtonC)
					end
				end
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if interiorbox then
			local now = getTickCount()
			local alpha = 0
			local sx = 0
			local sy = 0
			local interiorY = screenY + interiorH

			buttonsC = {}

			if interiorbox.alphaGetStart and now >= interiorbox.alphaGetStart then
				alpha = interpolateBetween(
					0, 0, 0,
					1, 0, 0,
					(now - interiorbox.alphaGetStart) / 300,
					"Linear"
				)
			end

			if interiorbox.openTileTick and now >= interiorbox.openTileTick then
				sx = interpolateBetween(boxSize2, 0, 0, interiorbox.tileWidth + boxSize2 * 2, 0, 0, (now - interiorbox.openTileTick) / 300, "Linear")
				sy = interpolateBetween(0, 0, 0, boxSize2, 0, 0, (now - interiorbox.openTileTick) / 300, "Linear")
				interiorY = interpolateBetween(screenY + interiorH, 0, 0, screenY - interiorH - respc(80), 0, 0, (now - interiorbox.openTileTick) / 1000, "Linear")
			end

			if interiorbox.closeTileTick and now >= interiorbox.closeTileTick then
				sx = interpolateBetween(sx, 0, 0, boxSize2, 0, 0, (now - interiorbox.closeTileTick) / 300, "Linear")
				sy = interpolateBetween(0, 0, 0, boxSize2, 0, 0, (now - interiorbox.closeTileTick) / 300, "Linear")
			end

			if interiorbox.alphaGetInverse and now >= interiorbox.alphaGetInverse then
				local progress = (now - interiorbox.alphaGetInverse) / 1000

				alpha = 1

				interiorY = interpolateBetween(screenY - interiorH - respc(80), 0, 0, screenY + interiorH, 0, 0, progress, "Linear")

				if progress >= 1 then
					interiorbox = false
					return
				end
			end

			local x = (screenX - respc(512)) / 2 + (respc(512) - (interiorbox.tileWidth + boxSize2 * 2) / 2) / 2
			local y = screenY - respc(176)

			dxDrawRoundedRectangle(interiorX, interiorY, interiorW, interiorH, tocolor(0, 0, 0, 170))
			dxDrawRoundedRectangle(interiorX + 3, interiorY + 3, interiorW - 6, respc(30) - 3, tocolor(0, 0, 0, 130))
			dxDrawText(interiorbox.text, interiorX + 3 + (interiorW - 6) / 2, interiorY + 3 + (respc(30) - 3) / 2, nil, nil, tocolor(255, 148, 40, alpha * 200), 0.55, Interiorfont, "center", "center", false, false, false, true)
			dxDrawText(interiorbox.text2, interiorX - 30 + (interiorW - 6) - 3, interiorY + interiorH / 2, nil, nil, tocolor(255, 255, 255, alpha * 200), 0.55, Interiorfont, "right", "center", false, false, false, true)

			local buttonH = (interiorW - buttonM * (#interiorButtons + 1)) / #interiorButtons

			for i, intB in pairs(interiorButtons) do
				local buttonX = interiorX + ((i - 1) * buttonH + (i * buttonM))
		
				drawButton3(intB.action, intB.name, buttonX, interiorY + interiorH - respc(35), buttonH, respc(35) - 3, {255, 148, 40}, false, Interiorfont, true, 0.45)
			end

			if interiorbox.interiorType == "duty" then
				dxDrawImage(interiorX + 3, interiorY + respc(40) - 3, respc(60), respc(60), "intbox/duty.png", 0, 0, 0, tocolor(200, 200, 200, alpha * 200))
			elseif interiorbox.interiorType == "carshop" then
				dxDrawImage(interiorX + 3, interiorY + respc(40) - 3, respc(60), respc(60), "intbox/carshop.png", 0, 0, 0, tocolor(200, 200, 200, alpha * 200))
			elseif interiorbox.interiorType == "garage" then
				dxDrawImage(interiorX + 3, interiorY + respc(40) - 3, respc(60), respc(60), "intbox/garage" .. interiorbox.doorState .. ".png", 0, 0, 0, tocolor(200, 200, 200, alpha * 200))
			else
				dxDrawImage(interiorX + 3, interiorY + respc(40) - 3, respc(60), respc(60), "intbox/door" .. interiorbox.doorState .. ".png", 0, 0, 0, tocolor(200, 200, 200, alpha * 200))
			end
			if sy >= boxSize2 then
				--dxDrawText(interiorbox.text, x + boxSize2, y + resp(10), x + sx, y + resp(10) + boxSize2 - resp(20), tocolor(255, 148, 40, alpha * 200), 0.55, Interiorfont, "center", "top", true)
				--dxDrawText(interiorbox.text2, x + boxSize2, y + resp(10), x + sx, y + resp(10) + boxSize2 - resp(20), tocolor(200, 200, 200, alpha * 200), 0.85, Roboto, "center", "bottom", true)
			end
		
			if interiorbox.gameInterior then
				local sx, sy = respc(259.2), respc(145.8)
				local x = math.floor(screenX / 2 - sx / 2)
				local y = math.floor(screenY - respc(176) - respc(155.8))
				
				dxDrawRoundedRectangle(x, interiorY - sy - respc(5), sx, sy, tocolor(0, 0, 0, 200 * alpha))
				dxDrawImage(x + 3, interiorY - sy + 3 - respc(5), sx - 6, sy - 6, ":cosmo_interiors/files/pics/" .. interiorbox.gameInterior .. ".jpg", 0, 0, 0, tocolor(255, 255, 255, alpha * 255))
			end
		end

		local cx, cy = getCursorPosition()

		if tonumber(cx) and tonumber(cy) then
			cx = cx * screenX
			cy = cy * screenY
	
			activeButtonC = false
			
			if not buttonsC then
				return
			end
			
			for k,v in pairs(buttonsC) do
				if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
					activeButtonC = k
					break
				end
			end
		else
			activeButtonC = false
		end
	end
)