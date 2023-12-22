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

local Roboto = exports.cosmo_assets:loadFont("Raleway.ttf", 15, false, "antialiased")

local loadingStarted = false
local loadingStartTime = false
local loadingLogoGetStart = false
local loadingLogoGetInverse = false
local loadingTime = false
local currLoadingText = false
local loadingTexts = false
local logoMoveDifferenceX, logoMoveDifferenceY = 0, 0
local loadingSound = false
local loadingBackground = false

function showTheLoadScreen(loadTime, texts, music)
	local now = getTickCount()

	currLoadingText = 1
	loadingTexts = {}

	for i = 1, #texts do
		loadingTexts[i] = {
			texts[i],
			now + loadTime / #texts * (i - 1),
			now + loadTime / #texts * i
		}
	end

	loadingStarted = true
	loadingLogoGetStart = now + 750
	loadingLogoGetInverse = false
	loadingTime = loadTime
	loadingStartTime = now
	logoMoveDifferenceX, logoMoveDifferenceY = 0, 0

	if isElement(loadingSound) then
		destroyElement(loadingSound)
	end
	if music == 1 then
		loadingSound = playSound("files/loading1.mp3")
	else
		loadingSound = playSound("files/loading2.mp3")
	end
	setSoundVolume(loadingSound,1)
	loadingBackground = math.random(1, 6)

	addEventHandler("onClientRender", getRootElement(), renderTheLoadingScreen, true, "low")
end

-- addCommandHandler("loadingtest",function()
--  	showTheLoadScreen(math.floor(10000, 15000), {"Adatok betöltése...", "Szinkronizációk folyamatban...", "Belépés Los Santosba..."})
-- end)

--local bgPng = dxCreateTexture("files/images/5.png")


local sX,sY = guiGetScreenSize()

function renderTheLoadingScreen()
	if loadingStarted then
		local now = getTickCount()
		local progress = (now - loadingStartTime) / loadingTime

		dxDrawImage(0, 0, screenX * (1 + progress / 4), screenY * (1 + progress / 4), "files/" .. loadingBackground .. ".png")
		--dxDrawImage(0, 0, sX,sY, bgPng, 0, 0, 0, tocolor(255, 255, 255))

		if loadingLogoGetStart then
			local progress = (now - loadingLogoGetStart) / 400

			if progress < 0 then
				progress = 0
			end

			if progress >= 1 then
				loadingLogoGetInverse = now + 3000
				loadingLogoGetStart = false
			end

			logoMoveDifferenceX, logoMoveDifferenceY = interpolateBetween(respc(27), respc(13), 0, 0, 0, 0, progress, "OutQuad")
		end

		if loadingLogoGetInverse then
			local progress = (now - loadingLogoGetInverse) / 400

			if progress < 0 then
				progress = 0
			end

			if progress >= 1 then
				loadingLogoGetStart = now + 750
				loadingLogoGetInverse = false
			end

			logoMoveDifferenceX, logoMoveDifferenceY = interpolateBetween(0, 0, 0, respc(27), respc(13), 0, progress, "OutQuad")
		end

		local logoSize = respc(128)
		local x = screenX / 2 - logoSize / 2
		local y = screenY / 2 - logoSize

		dxDrawImage(x, y, logoSize, logoSize, "files/logo.png")
		--dxDrawImage(x + logoMoveDifferenceX, y + logoMoveDifferenceY, logoSize, logoSize, ":sm_accounts/files/logo1.png")
		--dxDrawImage(x - logoMoveDifferenceX, y + logoMoveDifferenceY, logoSize, logoSize, ":sm_accounts/files/logo3.png")

		if loadingTexts[currLoadingText] then
			if now > loadingTexts[currLoadingText][3] then
				if loadingTexts[currLoadingText + 1] then
					currLoadingText = currLoadingText + 1
				end
			end

			local timediff = loadingTexts[currLoadingText][3] - loadingTexts[currLoadingText][2]
			local progress = loadingTexts[currLoadingText][2] + timediff / 2
			local alpha = 255

			if now >= progress then
				alpha = interpolateBetween(255, 0, 0, 0, 0, 0, (now - progress) / timediff * 2, "Linear")
			else
				alpha = interpolateBetween(0, 0, 0, 255, 0, 0, (now - loadingTexts[currLoadingText][2]) / timediff * 2, "Linear")
			end

			dxDrawText(loadingTexts[currLoadingText][1], 0, y + logoSize, screenX, y + respc(160), tocolor(200, 200, 200, alpha), 1, Roboto, "center", "center")
		end

		if progress >= 1 then
			loadingStarted = false

			if isElement(loadingSound) then
				destroyElement(loadingSound)
			end

			removeEventHandler("onClientRender", getRootElement(), renderTheLoadingScreen)
		end

		dxDrawText("Betöltés...", 0, 0, screenX - respc(32) - 2, screenY - respc(32) - 2, tocolor(200, 200, 200, 200), 0.8, Roboto, "right", "bottom")

		local progress = interpolateBetween(0, 0, 0, 100, 0, 0, progress, "Linear")

		dxDrawSeeBar(respc(32), screenY - respc(32), screenX - respc(64), 8, 0, tocolor(255, 148, 40), progress, false, tocolor(25, 25, 25))
	end
end


function dxDrawSeeBar(x, y, sx, sy, margin, colorOfProgress, value, key, bgcolor, bordercolor)
	sx, sy = math.ceil(sx), math.ceil(sy)

	if value > 100 then
		value = 100
	end

	local interpolatedValue = false

	if key then
		if renderData.lastBarValue[key] then
			if renderData.lastBarValue[key] ~= value then
				renderData.barInterpolation[key] = getTickCount()
				renderData.interpolationStartValue[key] = renderData.lastBarValue[key]
				renderData.lastBarValue[key] = value
			end
		else
			renderData.lastBarValue[key] = value
		end

		if renderData.barInterpolation[key] then
			interpolatedValue = interpolateBetween(renderData.interpolationStartValue[key], 0, 0, value, 0, 0, (getTickCount() - renderData.barInterpolation[key]) / 250, "Linear")
		end
	end

	if interpolatedValue then
		value = interpolatedValue
	end

	bordercolor = bordercolor or tocolor(0, 0, 0, 200)

	dxDrawRectangle(x, y, sx, margin, bordercolor) -- felső
	dxDrawRectangle(x, y + sy - margin, sx, margin, bordercolor) -- alsó
	dxDrawRectangle(x, y + margin, margin, sy - margin * 2, bordercolor) -- bal
	dxDrawRectangle(x + sx - margin, y + margin, margin, sy - margin * 2, bordercolor) -- jobb

	dxDrawRectangle(x + margin, y + margin, sx - margin * 2, sy - margin * 2, bgcolor or tocolor(0, 0, 0, 155)) -- háttér
	dxDrawRectangle(x + margin, y + margin, (sx - margin * 2) * (value / 100), sy - margin * 2, colorOfProgress) -- állapot
end

local bordercolor = tocolor(0, 0, 0, 200)

function dxDrawImageSectionBorder(x, y, w, h, ux, uy, uw, uh, image, r, rx, ry, color, postGUI)
	dxDrawImageSection(x - 1, y - 1, w, h, ux, uy, uw, uh, image, r, ry, rz, bordercolor, postGUI)
	dxDrawImageSection(x - 1, y + 1, w, h, ux, uy, uw, uh, image, r, ry, rz, bordercolor, postGUI)
	dxDrawImageSection(x + 1, y - 1, w, h, ux, uy, uw, uh, image, r, ry, rz, bordercolor, postGUI)
	dxDrawImageSection(x + 1, y + 1, w, h, ux, uy, uw, uh, image, r, ry, rz, bordercolor, postGUI)
	dxDrawImageSection(x, y, w, h, ux, uy, uw, uh, image, r, ry, rz, color, postGUI)
end

bordercolor = tocolor(0, 0, 0)

function dxDrawBorderText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	local text2 = string.gsub(text, "#......", "")
	dxDrawText(text2, x + 1, y + 1, w + 1, h + 1, bordercolor, scale, font, alignX, alignY, clip, wordBreak, postGUI, false, true)
	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end