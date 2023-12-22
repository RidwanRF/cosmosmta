local screenX, screenY = guiGetScreenSize()
local theX, theY = screenX / 2, screenY / 2

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

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

function loadFonts()
	local fonts = {
		Roboto18 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", 18, false, "cleartype"),
		font2 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", 16, false, "cleartype"),
		font4 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", 12, false, "cleartype"),
		font3 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", 11, false, "cleartype"),
		Roboto18L = exports.cosmo_assets:loadFont("Roboto-Light.ttf", 18, false, "cleartype"),
		Roboto32B = exports.cosmo_assets:loadFont("Roboto-Bold.ttf", 32, false, "cleartype"),
		SARPFont = exports.cosmo_assets:loadFont("SARP.ttf", 32, false, "cleartype"),
		--FiraSans = exports.cosmo_assets:loadFont("FiraSans.ttf", 14, false, "cleartype"),
		FiraSans = dxCreateFont("files/fonts/FiraSans.ttf", 14, false, "cleartype")
	}

	for k,v in pairs(fonts) do
		_G[k] = v
		_G[k .. "H"] = dxGetFontHeight(1, _G[k])
	end
end

local renderData = {
	username = "",
	password = "",
	passwordHidden = "",
	email = "",
	password2 = "",
	password2Hidden = "",
	activeFakeInput = "username",
	canUseFakeInputs = false,
	buttons = {},
	activeButton = false,
	rememberMe = false
}

local banData = false
local banPanelWidth = 600
local banPanelHeight = 320
local banPanelPosX = (screenX - banPanelWidth) / 2
local banPanelPosY = (screenY - banPanelHeight) / 2

local cursorState = false
local lastChangeCursorState = 0

local repeatTimer = false
local repeatStartTimer = false

local characterMaking = {}
characterMaking.charName = ""
characterMaking.currentSkin = 1
characterMaking.selectedSkin = 1
characterMaking.charAge = false

local availableSkins = {15,28,160,51,95,30,33, --[[női következik]]11,13,31,55,64,69,78}

local monthNames = {
	[0] = "Január",
	[1] = "Február",
	[2] = "Március",
	[3] = "Április",
	[4] = "Május",
	[5] = "Június",
	[6] = "Július",
	[7] = "Augusztus",
	[8] = "Szeptember",
	[9] = "Október",
	[10] = "November",
	[11] = "December"
}

local dayNames = {
	[0] = "Vasárnap",
	[1] = "Hétfő",
	[2] = "Kedd",
	[3] = "Szerda",
	[4] = "Csütörtök",
	[5] = "Péntek",
	[6] = "Szombat"
}

local pedData = {}
local localCharacters = {}
local selectedChar = 1
local maxCreatableChar = 1 -- adatbázisból kéri le bejelentkezéskor, hogy mennyit hozhat létre (accounts)

local autoSaveTimer = false
local minuteTimer = false

local loginMusic = false

local forcePasswordChange = false

addEventHandler("onAssetsLoaded", getRootElement(),
	function ()
		loadFonts()
	end
)

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		loadFonts()
		

		if not getElementData(localPlayer, "loggedIn") then
			fadeCamera(false, 0)
			setElementInterior(localPlayer, 0)
			setCameraInterior(0)
			--spawnAIs(1)
		end

		triggerServerEvent("checkPlayerBanState", localPlayer)
	end
)

addEvent("receiveBanState", true)
addEventHandler("receiveBanState", getRootElement(),
	function (data)
		if data.isActive == "Y" then
			fadeCamera(true)
			setElementPosition(localPlayer, 3750, 3750, 1500)
			setElementFrozen(localPlayer, true)

			banData = data
			addEventHandler("onClientRender", getRootElement(), onClientBanRender)

			loginMusic = playSound("files/login.mp3", true)
			setSoundVolume(loginMusic, 0.5)
		elseif getElementData(localPlayer, "loggedIn") then
			if isTimer(autoSaveTimer) then
				killTimer(autoSaveTimer)
			end
			
			if isTimer(minuteTimer) then
				killTimer(minuteTimer)
			end

			autoSaveTimer = setTimer(
				function ()
					triggerServerEvent("autoSavePlayer", localPlayer)
				end,
			1800000, 0)
			
			minuteTimer = setTimer(processMinuteTimer, 60000, 0)
		else
			fadeCamera(true)
			setElementPosition(localPlayer, -3750, -3750, 1500)
			setElementFrozen(localPlayer, true)

			showLogin()

			loginMusic = playSound("files/login.mp3", true)
			setSoundVolume(loginMusic, 0.5)
		end
	end
)

function saveLoginFiles(username, password, remember)
	if fileExists("@cosmo_loginremember.xml") then
		fileDelete("@cosmo_loginremember.xml")
	end
	
	local loginRememberFile = xmlCreateFile("@cosmo_loginremember.xml", "logindatas")
	
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "username"), username)
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "password"), password)
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "remember"), remember)
	
	xmlSaveFile(loginRememberFile)
	xmlUnloadFile(loginRememberFile)
end

function loadLoginFiles()
	local loginRememberFile = xmlLoadFile("@cosmo_loginremember.xml")
	
	if loginRememberFile then
		renderData.username = xmlNodeGetValue(xmlFindChild(loginRememberFile, "username", 0))
		renderData.password = xmlNodeGetValue(xmlFindChild(loginRememberFile, "password", 0))
		
		for i = 1, utfLen(renderData.password) do
			renderData.passwordHidden = renderData.passwordHidden .. "•"
		end

		local rememberValue = xmlNodeGetValue(xmlFindChild(loginRememberFile, "remember", 0))
		if tonumber(rememberValue) and tonumber(rememberValue) == 1 then
			renderData.rememberMe = true
		else
			renderData.rememberMe = false
		end
		
		xmlUnloadFile(loginRememberFile)
	end
end

function showLogin()
	renderData.canUseFakeInputs = true
	showCursor(true)

	loadLoginFiles()

	addEventHandler("onClientClick", getRootElement(), onClientClick)
	addEventHandler("onClientKey", getRootElement(), onClientKey)
	addEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
	addEventHandler("onClientRender", getRootElement(), onClientRender)
end

function onClientBanRender()
	setCameraMatrix(1795.9743652344, -1642.5692138672, 27.004177093506, 1875.9656982422, -1699.5766601563, 8.2549839019775)

	dxDrawRectangle(0, 0, screenX, screenY, tocolor(26, 26, 26, 240))

	--local fftMul = 0
	-- if isElement(loginMusic) then
	-- 	local FFT = getSoundFFTData(loginMusic, 2048, 0)
		
	-- 	if FFT then
	-- 		FFT[1] = math.sqrt(FFT[1]) * 2

	-- 		if FFT[1] < 0 then
	-- 			FFT[1] = 0
	-- 		elseif FFT[1] > 1 then
	-- 			FFT[1] = 1
	-- 		end

	-- 		fftMul = FFT[1]

	-- 		dxDrawImage(0, 0, screenX, screenY, ":cosmo_hud/files/lights.png", 0, 0, 0, tocolor(255, 255, 255, 255 * FFT[1]))
	-- 	end
	-- end

	drawLogoAnimation(banPanelPosX + (banPanelWidth - 267) / 2, banPanelPosY - 128, fftMul)

	local y = banPanelPosY + 128

	dxDrawText("Ki lettél tiltva a szerverről!", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 50, tocolor(200, 50, 50), 1, Roboto18L, "center", "center")
	y = y + 50

	dxDrawRectangle(banPanelPosX + 10, y, banPanelWidth - 20, 2, tocolor(255, 255, 255, 50))
	y = y + 10

	dxDrawText("Felhasználónév", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(255, 255, 255), 0.75, Roboto18, "left", "center")
	dxDrawText(banData.playerName, banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(150, 150, 150), 0.65, Roboto18, "right", "center")
	y = y + 30

	dxDrawText("Serial", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(255, 255, 255), 0.75, Roboto18, "left", "center")
	dxDrawText(banData.playerSerial, banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(150, 150, 150), 0.65, Roboto18, "right", "center")
	y = y + 30

	dxDrawText("Admin", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(255, 255, 255), 0.75, Roboto18, "left", "center")
	dxDrawText(banData.adminName, banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(150, 150, 150), 0.65, Roboto18, "right", "center")
	y = y + 30

	dxDrawText("Indok", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(255, 255, 255), 0.75, Roboto18, "left", "center")
	dxDrawText(banData.banReason, banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(150, 150, 150), 0.65, Roboto18, "right", "center")
	y = y + 30

	dxDrawText("Időpont", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(255, 255, 255), 0.75, Roboto18, "left", "center")
	dxDrawText(exports.cosmo_core:formatDate("Y/m/d h:i:s", "'", tostring(banData.banTimestamp)), banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(150, 150, 150), 0.65, Roboto18, "right", "center")
	y = y + 30

	dxDrawText("Lejár", banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(255, 255, 255), 0.75, Roboto18, "left", "center")
	dxDrawText(exports.cosmo_core:formatDate("Y/m/d h:i:s", "'", tostring(banData.expireTimestamp)), banPanelPosX + 10, y, banPanelPosX + banPanelWidth - 10, y + 30, tocolor(150, 150, 150), 0.65, Roboto18, "right", "center")
	y = y + 30

	dxDrawRectangle(banPanelPosX + 10, y, banPanelWidth - 20, 2, tocolor(255, 255, 255, 50))
	y = y + 10

end

local roundtexture = dxCreateTexture(":cosmo_hud/files/images/round.png", "argb", true, "clamp")

function dxDrawRoundedRectangle(x, y, sx, sy, color, postGUI, subPixelPositioning)
	dxDrawImage(x, y, 5, 5, roundtexture, 0, 0, 0, color, postGUI)
	dxDrawRectangle(x, y + 5, 5, sy - 5 * 2, color, postGUI, subPixelPositioning)
	dxDrawImage(x, y + sy - 5, 5, 5, roundtexture, 270, 0, 0, color, postGUI)
	dxDrawRectangle(x + 5, y, sx - 5 * 2, sy, color, postGUI, subPixelPositioning)
	dxDrawImage(x + sx - 5, y, 5, 5, roundtexture, 90, 0, 0, color, postGUI)
	dxDrawRectangle(x + sx - 5, y + 5, 5, sy - 5 * 2, color, postGUI, subPixelPositioning)
	dxDrawImage(x + sx - 5, y + sy - 5, 5, 5, roundtexture, 180, 0, 0, color, postGUI)
end

function onClientRender()
	renderData.buttons = {}

	if not renderData.characterMakingActive then
		setCameraMatrix(1795.9743652344, -1642.5692138672, 27.004177093506, 1875.9656982422, -1699.5766601563, 8.2549839019775)
		--spawnAIs(1)
	end

	if renderData.characterMakingActive then
		if not characterMaking.bgAlpha then
			dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, 255))
		end
	elseif renderData.registerActive then
		local sx = 420
		local sy = 325
		local x = (screenX - sx) / 2
		local y = (screenY - sy) / 2

		 -- dxDrawImage(0, 0, screenX, screenY, "files/bg.png")


		-- local fftMul = 0
		-- if isElement(loginMusic) then
		-- 	local FFT = getSoundFFTData(loginMusic, 2048, 0)
			
		-- 	if FFT then
		-- 		FFT[1] = math.sqrt(FFT[1]) * 2

		-- 		if FFT[1] < 0 then
		-- 			FFT[1] = 0
		-- 		elseif FFT[1] > 1 then
		-- 			FFT[1] = 1
		-- 		end

		-- 		fftMul = FFT[1]

		-- 		--dxDrawImage(0, 0, screenX, screenY, ":cosmo_hud/files/lights.png", 0, 0, 0, tocolor(255, 255, 255, 255 * FFT[1]))
		-- 	end
		-- end

		drawLogoAnimation(x + (sx - 260) / 2, y - 50, fftMul)
		y = y + 128

		dxDrawRoundedRectangle(x - 8, y, sx + 15, 310, tocolor(0, 0, 0, 170))
		y = y + 10

		dxDrawText("CosmoMTA", x + 10, y, x + sx - 10, y + 20, tocolor(255, 255, 255), 1, FiraSans, "center", "center")
		y = y + 2
		
		dxDrawText("Regisztráció felület", x + 10, y + 15, x + sx - 10, y + 50, tocolor(255, 255, 255), 0.7, font4, "center", "center")
		y = y + 50

		--dxDrawRectangle(x + 10, y, sx - 20, 2, tocolor(255, 255, 255, 50))
		y = y + 10

		drawInput("username", "Felhasználónév", x + 10, y, sx - 20, 40)
		y = y + 45

		drawInput("password", "Jelszó", x + 10, y, sx - 20, 40)
		y = y + 45

		drawInput("password2", "Jelszó ismét", x + 10, y, sx - 20, 40)
		y = y + 45

		drawInput("email", "Valós e-mail címed", x + 10, y, sx - 20, 40)
		y = y + 45

		drawButton("registerEnd", "Regisztráció", x + 10, y, sx - 20, 40, {7, 112, 196})
		renderData.buttons["registerEnd"] = {x + 10, y, sx - 20, 40}
	else
		local sx = 420
		local sy = 325
		local x = (screenX - sx) / 2
		local y = (screenY - sy) / 2
 
         -- dxDrawImage(0, 0, screenX, screenY, "files/bg.png")

		-- local fftMul = 0
		-- if isElement(loginMusic) then
		-- 	local FFT = getSoundFFTData(loginMusic, 2048, 0)

		-- 	if FFT then
		-- 		FFT[1] = math.sqrt(FFT[1]) * 2

		-- 		if FFT[1] < 0 then
		-- 			FFT[1] = 0
		-- 		elseif FFT[1] > 1 then
		-- 			FFT[1] = 1
		-- 		end

		-- 		fftMul = FFT[1]

		-- 		--dxDrawImage(0, 0, screenX, screenY, ":cosmo_hud/files/lights.png", 0, 0, 0, tocolor(255, 255, 255, 255 * FFT[1]))
		-- 		local soundFFT = getSoundFFTData(loginMusic, 16384)
		-- 		if (soundFFT) then
		-- 			for i = 0, 100 do
		-- 				dxDrawRectangle(i * (screenX / 100 + 6), 0, screenX / 100, math.sqrt (soundFFT[i] ) * 256, tocolor(255, 148, 40, 120))

		-- 				dxDrawRectangle(i * (screenX / 100 + 6), screenY, screenX / 100, - 256 * math.sqrt(soundFFT[i]), tocolor(255, 148, 40, 120))
		-- 			end
		-- 		end
		-- 	end
		-- end

		drawLogoAnimation(x + (sx - 260) / 2, y - 50, fftMul)
		y = y + 128

		dxDrawRoundedRectangle(x - 8, y, sx + 15, 280, tocolor(0, 0, 0, 170))
		y = y + 10

		dxDrawText("CosmoMTA", x + 10, y, x + sx - 10, y + 20, tocolor(255, 255, 255), 1, FiraSans, "center", "center")
		y = y + 2

		dxDrawText("Bejelentkező felület", x + 10, y + 15, x + sx - 10, y + 50, tocolor(255, 255, 255), 0.7, font4, "center", "center")
		y = y + 50

		drawInput("username", "Felhasználónév", x + 10, y, sx - 20, 40)
		y = y + 45

		drawInput("password", "Jelszó", x + 10, y, sx - 20, 40)
		y = y + 45

		drawButtonSlider("rememberMe", renderData.rememberMe, x + 10, y, 35, {50, 50, 50, 255}, {255, 148, 40, 255})
		dxDrawText("Jegyezzen meg", x + 20 + 64, y, 0, y + 35, tocolor(255, 255, 255), 0.65, Roboto18, "left", "center")
		y = y + 40

		drawButton("login", "Bejelentkezés", x + 10, y, sx - 20, 40, {255, 148, 40})
		renderData.buttons["login"] = {x + 10, y, sx - 20, 40}
		y = y + 50

		dxDrawText("Még nem vagy regisztrálva? Kattints ide!", x + 10, y - 15, x + sx - 10, y + 50, tocolor(255, 255, 255), 0.6, Roboto18, "center", "center")
		renderData.buttons["register"] = {x + 10, y + 10, sx - 20, 10}
	end

	local cx, cy = getCursorPosition()

	if tonumber(cx) and tonumber(cy) then
		cx = cx * screenX
		cy = cy * screenY

		renderData.activeButton = false

		for k,v in pairs(renderData.buttons) do
			if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
				renderData.activeButton = k
				break
			end
		end
	else
		renderData.activeButton = false
	end
end

function onClientCharacter(character)
	if not characterMaking.started and renderData.activeFakeInput and renderData.canUseFakeInputs and not renderData.inputDisabled then
		local maxCharacter = 25
		local onlyNumbers = false

		if renderData.activeFakeInput == "username" or renderData.activeFakeInput == "password" or renderData.activeFakeInput == "password2" then
			maxCharacter = 32

			if not string.find(character, "[a-zA-Z0-9#]") then
				return
			end
		end

		if utfLen(renderData[renderData.activeFakeInput]) <= maxCharacter and ((onlyNumbers and tonumber(character)) or not onlyNumbers) then
			if renderData.activeFakeInput == "password" then
				renderData.password = renderData.password .. character
				renderData.passwordHidden = ""

				for i = 1, utfLen(renderData.password) do
					renderData.passwordHidden = renderData.passwordHidden .. "•"
				end
			elseif renderData.activeFakeInput == "password2" then
				renderData.password2 = renderData.password2 .. character
				renderData.password2Hidden = ""

				for i = 1, utfLen(renderData.password2) do
					renderData.password2Hidden = renderData.password2Hidden .. "•"
				end
			else
				renderData[renderData.activeFakeInput] = renderData[renderData.activeFakeInput] .. character
			end
		end
	end

	if not characterMaking.started then
		return
	end

	local tickCount = getTickCount()

	if characterMaking.nameInputStart and tickCount >= characterMaking.nameInputStart and not characterMaking.disableNameInput and (string.find(string.lower(character), "[a-z]") or character == " ") and utfLen(characterMaking.charName) <= 32 then
		characterMaking.charName = string.lower(characterMaking.charName .. character)

		local names = {}

		for k,v in ipairs(split(characterMaking.charName, " ")) do
			local name = utf8.gsub(v, "^%l", string.upper)

			if utfLen(name) >= 1 and #names < 3 then
				table.insert(names, name)
			end
		end

		characterMaking.charName = table.concat(names, " ")

		if character == " " and utfSub(characterMaking.charName, utfLen(characterMaking.charName) - 1, utfLen(characterMaking.charName)) ~= " " and #names < 3 then
			characterMaking.charName = characterMaking.charName .. " "
		end
	end

	if characterMaking.ageInputStart and tickCount >= characterMaking.ageInputStart and string.find(string.lower(character), "[0-9]") then
		characterMaking.charAge = tonumber((characterMaking.charAge or 0) .. character)
		
		if utfLen(characterMaking.charAge) < 1 or utfLen(characterMaking.charAge) > 2 then
			characterMaking.charAge = 18
			exports.cosmo_hud:showInfobox("warning", "A karaktered kora nem megfelelő! (18-90)")
		end
	end
end

function removeCharacterFromFakeInput(input, repeatTheTimer)
	if utf8.len(renderData[input]) >= 1 then
		renderData[input] = utf8.sub(renderData[input], 1, -2)

		if input == "password" then
			renderData.passwordHidden = ""

			for i = 1, utfLen(renderData.password) do
				renderData.passwordHidden = renderData.passwordHidden .. "•"
			end
		elseif input == "password2" then
			renderData.password2Hidden = ""

			for i = 1, utfLen(renderData.password2) do
				renderData.password2Hidden = renderData.password2Hidden .. "•"
			end
		end
	end

	if repeatTheTimer then
		repeatTimer = setTimer(removeCharacterFromFakeInput, 50, 1, renderData.activeFakeInput, repeatTheTimer)
	end
end

function onClientKey(key, press)
	if press then
		cancelEvent()

		if key == "backspace" and renderData.activeFakeInput and renderData.canUseFakeInputs and not renderData.inputDisabled then
			removeCharacterFromFakeInput(renderData.activeFakeInput)

			if getKeyState(key) then
				repeatStartTimer = setTimer(removeCharacterFromFakeInput, 500, 1, renderData.activeFakeInput, true)
			end
		end

		if key == "tab" and renderData.canUseFakeInputs and not renderData.inputDisabled then
			if renderData.activeFakeInput == "username" then
				renderData.activeFakeInput = "password"
			elseif renderData.activeFakeInput == "password" then
				if renderData.registerActive then
					if renderData.activeFakeInput == "password2" then
						renderData.activeFakeInput = "email"
					else
						renderData.activeFakeInput = "password2"
					end
				else
					renderData.activeFakeInput = "username"
				end
			else
				renderData.activeFakeInput = "username"
			end

			lastChangeCursorState = getTickCount()
			cursorState = true
		end

		if characterMaking.started then
			local tickCount = getTickCount()

			if key == "backspace" then
				if characterMaking.ageInputStart and tickCount >= characterMaking.ageInputStart and not characterMaking.finalFade then
					if not characterMaking.charAge then
						characterMaking.charAge = ""
					end
					
					if utfLen(characterMaking.charAge) > 0 then
						characterMaking.charAge = tonumber(utfSub(characterMaking.charAge, 1, utfLen(characterMaking.charAge) - 1))
					end
					
					if not characterMaking.charAge then
						characterMaking.charAge = ""
					end
					
					if utfLen(characterMaking.charAge) > 2 then
						characterMaking.charAge = 18
						exports.cosmo_hud:showInfobox("warning", "A karaktered kora nem megfelelő! (18-90)")
					end
				end

				if tickCount >= characterMaking.nameInputStart and not characterMaking.disableNameInput then
					characterMaking.charName = utf8.sub(characterMaking.charName, 1, -2)
				end
			elseif key == "enter" then
				if characterMaking.ageInputStart and tickCount >= characterMaking.ageInputStart and not characterMaking.finalFade then
					if characterMaking.charAge then
						if tonumber(characterMaking.charAge) then
							characterMaking.charAge = tonumber(characterMaking.charAge)
							
							if characterMaking.charAge >= 18 and characterMaking.charAge <= 90 then
								characterMaking.ageInputHide = getTickCount()
								characterMaking.finalFade = characterMaking.ageInputHide + 2000
							else
								exports.cosmo_hud:showInfobox("warning", "A karaktered kora nem megfelelő! (18-90)")
							end
						else
							exports.cosmo_hud:showInfobox("warning", "A karaktered kora nem megfelelő! (18-90)")
						end
					else
						exports.cosmo_hud:showInfobox("warning", "A karaktered kora nem megfelelő! (18-90)")
					end
				end

				if characterMaking.skinSelectStart and tickCount >= characterMaking.skinSelectStart and not characterMaking.skinSelectHide then
					characterMaking.skinSelectHide = getTickCount()
					characterMaking.ageInputStart = characterMaking.skinSelectHide + 1000
				end

				if tickCount >= characterMaking.nameInputStart and not characterMaking.disableNameInput and not characterMaking.skinSelectHide then
					if utfSub(characterMaking.charName, utfLen(characterMaking.charName), utfLen(characterMaking.charName)) == " " then
						characterMaking.charName = utfSub(characterMaking.charName, 1, -2)
					end

					characterMaking.disableNameInput = true
					triggerServerEvent("checkCharacterName", localPlayer, string.gsub(characterMaking.charName, " ", "_"))
				end
			elseif (key == "arrow_r" or key == "arrow_l") and characterMaking.skinSelectStart and tickCount >= characterMaking.skinSelectStart and not characterMaking.skinSelectHide then
				if string.gsub(key, "arrow_", "") == "l" then
					characterMaking.currentSkin = characterMaking.currentSkin - 1
				else
					characterMaking.currentSkin = characterMaking.currentSkin + 1
				end
				
				if characterMaking.currentSkin < 1 then
					characterMaking.currentSkin = #availableSkins
				end
				
				if characterMaking.currentSkin > #availableSkins then
					characterMaking.currentSkin = 1
				end
				
				setElementModel(characterMaking.myCharacter, availableSkins[characterMaking.currentSkin])
				characterMaking.selectedSkin = availableSkins[characterMaking.currentSkin]
			end
		end
	else
		if isTimer(repeatStartTimer) then
			killTimer(repeatStartTimer)
		end

		if isTimer(repeatTimer) then
			killTimer(repeatTimer)
		end
	end
end

function onClientClick(button, state)
	if button == "left" and state == "down" then
		renderData.activeFakeInput = false

		if renderData.activeButton then
			local selected = split(renderData.activeButton, ":")

			if selected[1] == "rememberMe" then
				renderData.rememberMe = not renderData.rememberMe
			elseif renderData[renderData.activeButton] and renderData.canUseFakeInputs and not renderData.inputDisabled then
				renderData.activeFakeInput = renderData.activeButton
			elseif selected[1] == "register" and not renderData.inputDisabled then
				renderData.inputDisabled = true

				triggerServerEvent("onClientRegisterRequest", localPlayer)
			elseif selected[1] == "registerEnd" and not renderData.inputDisabled then
				local username = renderData.username
				local password = renderData.password
				local password2 = renderData.password2
				local email = renderData.email

				if utfLen(username) >= 5 and utfLen(username) <= 18 then
					if checkPassword(password) then
						if password == password2 then
							if email and email ~= "" and utf8.find(email, "@") and utf8.find(email, ".") then
								triggerServerEvent("onClientTryToCreateAccount", localPlayer, username, password, email)
								
								renderData.inputDisabled = true
								setTimer(
									function()
										renderData.inputDisabled = false
									end,
								10000, 1)
							else
								exports.cosmo_hud:showInfobox("error", "Adj meg egy valós email címet!")
							end
						else
							exports.cosmo_hud:showInfobox("error", "A jelszavak nem egyeznek!")
						end
					else
						exports.cosmo_hud:showInfobox("error", "A jelszónak min. 6 karakter, Kis-és Nagybetű és legalább egy numerikus karaktert (szám 0-9) kell tartalmaznia!")
					end
				else
					exports.cosmo_hud:showInfobox("error", "A felhasználónévnek minimum 5, maximum 18 karakterből kell állnia!")
				end
			elseif selected[1] == "login" and not renderData.inputDisabled then
				local username = renderData.username
				local password = renderData.password

				if utfLen(username) >= 5 and utfLen(username) <= 18 then
					if utfLen(password) >= 6 and utfLen(password) <= 32 then
						triggerServerEvent("onClientLoginRequest", localPlayer, username, password)
						
						renderData.inputDisabled = true
						setTimer(
							function()
								renderData.inputDisabled = false
							end,
						10000, 1)
					else
						exports.cosmo_hud:showInfobox("error", "A jelszónak minimum 6, maximum 32 karakterből kell állnia!")
					end
				else
					exports.cosmo_hud:showInfobox("error", "A felhasználónévnek minimum 5, maximum 18 karakterből kell állnia!")
				end
			end
		end
	end
end

local afkMinutes = 0
local resetAFKTimer = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "afk") and getElementData(localPlayer, "loggedIn") then
			afkMinutes = 5

			if isTimer(resetAFKTimer) then
				killTimer(resetAFKTimer)
			end

			resetAFKTimer = false
		end
	end
)

addEventHandler("onClientElementDataChange", getLocalPlayer(),
	function (dataName)
		if dataName == "afk" and afkMinutes >= 1 then
			if getElementData(localPlayer, "afk") then
				if isTimer(resetAFKTimer) then
					killTimer(resetAFKTimer)
				end

				resetAFKTimer = false
			else
				if isTimer(resetAFKTimer) then
					killTimer(resetAFKTimer)
				end

				resetAFKTimer = setTimer(
					function ()
						afkMinutes = 0
					end,
				10000, 1)
			end
		end
	end
)

function processMinuteTimer()
	if (getElementData(localPlayer, "acc.adminJail") or 0) ~= 0 then
		return
	end
	
	if not getElementData(localPlayer, "adminDuty") then

	end

	if getElementData(localPlayer, "afk") and getElementData(localPlayer, "loggedIn") then
		afkMinutes = afkMinutes + 1

		if afkMinutes >= 5 then
			return
		end
	end

	local playedMinutes = getElementData(localPlayer, "char.playedMinutes") or 0
	setElementData(localPlayer, "char.playedMinutes", playedMinutes + 1)

	local playTimeForPayday = getElementData(localPlayer, "char.playTimeForPayday") or 0

	if playTimeForPayday + 1 == 60 then
		setElementData(localPlayer, "char.playTimeForPayday", 0)
		triggerServerEvent("onPayDay", localPlayer)
	else
		setElementData(localPlayer, "char.playTimeForPayday", playTimeForPayday + 1)
	end
end

addEvent("onClientLoggedIn", true)
addEventHandler("onClientLoggedIn", getRootElement(),
	function ()
		showChat(true)
		toggleAllControls(true)
		setElementFrozen(localPlayer, false)
		setCameraTarget(localPlayer)
		setElementData(localPlayer, "loggedIn", true)

		if isTimer(autoSaveTimer) then
			killTimer(autoSaveTimer)
		end
		
		if isTimer(minuteTimer) then
			killTimer(minuteTimer)
		end

		collectgarbage()

		autoSaveTimer = setTimer(
			function ()
				triggerServerEvent("autoSavePlayer", localPlayer)
			end,
		1800000, 0)
		
		minuteTimer = setTimer(processMinuteTimer, 60000, 0)

		--playSound("files/welcome.wav")
	end
)

addEvent("onSuccessLogin", true)
addEventHandler("onSuccessLogin", getRootElement(),
	function (characters, pwchange)
		exports.cosmo_hud:showInfobox("success", "Sikeresen bejelentkeztél!")

		forcePasswordChange = pwchange == "Y"

		if renderData.rememberMe then
			saveLoginFiles(renderData.username, renderData.password, 1)
		else
			saveLoginFiles("", "", 0)
		end
		
		renderData.username = ""
		renderData.password = ""

		maxCreatableChar = getElementData(localPlayer, "acc.maxCharacter") or 1
		
		if characters and #characters > 0 then
			loadCharacterSelector(characters)
		else
			startCharacterMaking()
		end
	end
)

function loadCharacterSelector(characters)
	removeEventHandler("onClientRender", getRootElement(), onClientRender)
	removeEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
	removeEventHandler("onClientKey", getRootElement(), onClientKey)
	removeEventHandler("onClientClick", getRootElement(), onClientClick)

	renderData.characterMakingActive = false

	selectedChar = 1
	pedData = characters

	local playerDimension = getElementDimension(localPlayer)
		
	for k, v in ipairs(pedData) do
		localCharacters[k] = createPed(v.skin, 1148.2672119141 - (k - 1) * 6, -1156.669921875, 23.828125, 0)

		setElementDimension(localCharacters[k], playerDimension)
	end

	setPedAnimation(localCharacters[1], "ON_LOOKERS", "wave_loop", -1, true, false, false)
	setCameraMatrix(1148.2672119141, -1150.2779541016, 31.311100006104, 1100.8375244141, -1150.2779541016, 31.311100006104)

	addEventHandler("onClientRender", getRootElement(), characterSelectRender)

	renderData.charCamX = 1148.2672119141
	renderData.charCamY = -1150.2779541016
	renderData.charCamZ = 31.311100006104
	renderData.charCamLX = 1148.2672119141
	renderData.charCamLY = -1150.2779541016
	renderData.charCamLZ = 31.311100006104

	renderData.charGotInterpolation = getTickCount()
end

--local logoTexture = dxCreateTexture("files/logo.png")
local logoSize = 128 * (1 / 75)

renderData.newPw = ""
renderData.newPwHidden = ""
local firstPw = ""

function characterSelectRender()
	local tickCount = getTickCount()

	if renderData.charSelectInterpolation then
		local progress = (tickCount - renderData.charSelectInterpolation) / 500

		renderData.charCamX = interpolateBetween(renderData.charCamStartX, 0, 0, renderData.charCamEndX, 0, 0, progress, "OutQuad")

		if progress >= 1 then
			renderData.charSelectInterpolation = false
		end
	end

	if renderData.charGotInterpolation and tickCount >= renderData.charGotInterpolation then
		local progress = (tickCount - renderData.charGotInterpolation) / 2000
		local pedX, pedY, pedZ = getElementPosition(localCharacters[1])

		renderData.charCamX, renderData.charCamY, renderData.charCamZ = interpolateBetween(1148.2672119141, -1150.2779541016, 31.311100006104, 1148.2672119141, -1150.2779541016, pedZ + 5, progress, "OutQuad")
		renderData.charCamLX, renderData.charCamLY, renderData.charCamLZ = interpolateBetween(1148.2672119141, -1150.2779541016, 31.311100006104, pedX, pedY, pedZ, progress, "OutQuad")

		if progress >= 1 then
			renderData.charGotInterpolation = false

			addEventHandler("onClientKey", getRootElement(), characterSelectKey)
			addEventHandler("onClientCharacter", getRootElement(), characterSelectCharacter)
		end
	end

	setCameraMatrix(renderData.charCamX, renderData.charCamY, renderData.charCamZ, renderData.charCamX, renderData.charCamLY, renderData.charCamLZ)

	if forcePasswordChange then
		local sx, sy = 500, 400
		local x, y = screenX / 2 - sx / 2, screenY / 2 - sy / 2

		dxDrawText("BIZTONSÁGI INTÉZKEDÉS", x + 1, y + 1, x + sx + 1, y + 30 + 1, tocolor(0, 0, 0), 1, Roboto32B, "center", "center")
		dxDrawText("BIZTONSÁGI INTÉZKEDÉS", x, y, x + sx, y + 30, tocolor(215, 89, 89), 1, Roboto32B, "center", "center")

		if forcePasswordChange == "waiting" then
			dxDrawText("Új jelszó feldolgozása...", x + 1, y + 30 + 1, x + sx + 1, y + sy - 60 + 1, tocolor(0, 0, 0), 1, Roboto18, "center", "center")
			dxDrawText("Új jelszó feldolgozása...", x, y + 30, x + sx, y + sy - 60, tocolor(255, 255, 255), 1, Roboto18, "center", "center", false, false, false, true)
		elseif forcePasswordChange == "again" then
			dxDrawText("Megerősítésként írd be újra\naz előzőleg megadott új jelszót.", x + 1, y + 30 + 1, x + sx + 1, y + sy - 60 + 1, tocolor(0, 0, 0), 1, Roboto18, "center", "center")
			dxDrawText("Megerősítésként írd be újra\naz előzőleg megadott új jelszót.", x, y + 30, x + sx, y + sy - 60, tocolor(255, 255, 255), 1, Roboto18, "center", "center", false, false, false, true)
		
			dxDrawText("Jelszó:", x + 5, y + sy - 40, x + sx - 10, y + sy, tocolor(255, 255, 255), 1, Roboto18, "left", "center")

			if firstPw == renderData.newPw then
				dxDrawText(renderData.newPwHidden, x + 5, y + sy - 40, x + sx - 10, y + sy, tocolor(50, 200, 50), 1, Roboto32B, "right", "center")
				dxDrawRectangle(x, y + sy, sx, 2, tocolor(50, 200, 50))
			else
				dxDrawText(renderData.newPwHidden, x + 5, y + sy - 40, x + sx - 10, y + sy, tocolor(200, 50, 50), 1, Roboto32B, "right", "center")
				dxDrawRectangle(x, y + sy, sx, 2, tocolor(200, 50, 50))
			end

			dxDrawText("Nyomj #00aaffENTER#ffffff-t a továbblépéshez.", x, y + sy + 30, x + sx, 0, tocolor(255, 255, 255), 1, Roboto18, "center", "top", false, false, false, true)
		else
			dxDrawText("Megváltozott a jelszó titkosítási algoritmusunk.\n\nKérlek írd be az új jelszavad, ami innentől\nfelváltja a régit, tehát jól jegyezd meg.\n\nA jelszó az alábbiakat kell, hogy tartalmazza:\nMin. 6 karakter, Kis-és Nagybetű és legalább\negy numerikus karaktert (szám 0-9)", x + 1, y + 30 + 1, x + sx + 1, y + sy - 60 + 1, tocolor(0, 0, 0), 1, Roboto18, "center", "center")
			dxDrawText("Megváltozott a jelszó titkosítási algoritmusunk.\n\nKérlek írd be az új jelszavad, ami innentől\nfelváltja a régit, tehát jól jegyezd meg.\n\nA jelszó az alábbiakat kell, hogy tartalmazza:\n#00aaffMin. 6 karakter, Kis-és Nagybetű és legalább\negy numerikus karaktert (szám 0-9)", x, y + 30, x + sx, y + sy - 60, tocolor(255, 255, 255), 1, Roboto18, "center", "center", false, false, false, true)
		
			dxDrawText("Új jelszó:", x + 5, y + sy - 40, x + sx - 10, y + sy, tocolor(255, 255, 255), 1, Roboto18, "left", "center")

			if checkPassword(renderData.newPw) then
				dxDrawText(renderData.newPwHidden, x + 5, y + sy - 40, x + sx - 10, y + sy, tocolor(50, 200, 50), 1, Roboto32B, "right", "center")
				dxDrawRectangle(x, y + sy, sx, 2, tocolor(50, 200, 50))
			else
				dxDrawText(renderData.newPwHidden, x + 5, y + sy - 40, x + sx - 10, y + sy, tocolor(200, 50, 50), 1, Roboto32B, "right", "center")
				dxDrawRectangle(x, y + sy, sx, 2, tocolor(200, 50, 50))
			end

			dxDrawText("Nyomj #00aaffENTER#ffffff-t a továbblépéshez.", x, y + sy + 30, x + sx, 0, tocolor(255, 255, 255), 1, Roboto18, "center", "top", false, false, false, true)
		end
	else
		local charName = string.gsub(pedData[selectedChar].name, "_", " ")
		local nameWidth = dxGetTextWidth(charName, 1, Roboto32B)

		dxDrawText(charName, 0, 0, screenX, screenY - 120, tocolor(255, 255, 255), 0.7, Roboto32B, "center", "bottom")
		dxDrawRectangle((screenX - nameWidth) / 2, screenY - 115, nameWidth, 1.5, tocolor(255, 255, 255))

		if #pedData > 1 then
			dxDrawText("Nyomj ENTER-t a kiválasztáshoz.", 0, 0, screenX, screenY - 80, tocolor(255, 255, 255), 1, Roboto18, "center", "bottom")

			local y = screenY - 80 + Roboto18H
			if maxCreatableChar > #pedData then
				dxDrawText("Nyomj SPACE-t egy új karakter létrehozásához.", 0, 0, screenX, y, tocolor(255, 255, 255), 1, Roboto18, "center", "bottom")
				y = y + Roboto18H
			end

			dxDrawText("Használd a nyilakat a karakterválasztáshoz.", 0, 0, screenX, y, tocolor(255, 255, 255), 1, Roboto18, "center", "bottom")
		else
			dxDrawText("Nyomj ENTER-t a bejelentkezéshez.", 0, 0, screenX, screenY - 80, tocolor(255, 255, 255), 0.7, Roboto18, "center", "bottom")

			if maxCreatableChar > #pedData then
				dxDrawText("Nyomj SPACE-t egy új karakter létrehozásához.", 0, 0, screenX, screenY - 80 + Roboto18H, tocolor(255, 255, 255), 1, Roboto18, "center", "bottom")
			end
		end
	end
end

addEvent("passwordChangeResult", true)
addEventHandler("passwordChangeResult", getRootElement(),
	function (ok)
		if ok then
			exports.cosmo_hud:showInfobox("success", "Sikeres jelszóváltás! Mostantól ezzel léphetsz be.")

			if renderData.rememberMe then
				local username = getElementData(localPlayer, "acc.Name")

				if username then
					saveLoginFiles(username, renderData.newPw, 1)
				else
					saveLoginFiles("", "", 0)
				end
			else
				saveLoginFiles("", "", 0)
			end

			firstPw = ""
			renderData.newPw = ""
			renderData.newPwHidden = ""
			forcePasswordChange = false
		else
			firstPw = ""
			renderData.newPw = ""
			renderData.newPwHidden = ""
			forcePasswordChange = true
			exports.cosmo_hud:showInfobox("error", "Nem adhatod meg a régi jelszavad!")
		end
	end
)

function checkPassword(str)
	if utf8.len(str) >= 6 and utf8.len(str) <= 32 then
		return utf8.find(str, "%d") and utf8.find(str, "%u") and utf8.find(str, "%l")
	end

	return false
end

function characterSelectCharacter(character)
	renderData.newPw = renderData.newPw .. character
	renderData.newPwHidden = renderData.newPwHidden .. "*"
end

function characterSelectKey(key, state)
	if state then
		cancelEvent()

		if forcePasswordChange then
			if key == "backspace" then
				renderData.newPw = utf8.sub(renderData.newPw, 1, -2)
				renderData.newPwHidden = utf8.sub(renderData.newPwHidden, 1, -2)
			elseif key ~= "enter" or forcePasswordChange == "waiting" then
			elseif forcePasswordChange == "again" then
				if firstPw == renderData.newPw then
					forcePasswordChange = "waiting"
					triggerServerEvent("onClientPasswordChangeForced", localPlayer, renderData.newPw)
				else
					firstPw = renderData.newPw
					renderData.newPw = ""
					renderData.newPwHidden = ""
					forcePasswordChange = true
					exports.cosmo_hud:showInfobox("error", "A két jelszó nem egyezik!")
				end
			elseif checkPassword(renderData.newPw) then
				firstPw = renderData.newPw
				renderData.newPw = ""
				renderData.newPwHidden = ""
				forcePasswordChange = "again"
			else
				exports.cosmo_hud:showInfobox("error", "A jelszó nem megfelelő!")
			end
		elseif not renderData.charSelectInterpolation then
			if key == "arrow_l" and selectedChar > 1 then
				renderData.charCamStartX = 1148.2672119141 - (selectedChar - 1) * 6

				setPedAnimation(localCharacters[selectedChar])
				selectedChar = selectedChar - 1
			
				if selectedChar < 1 then
					selectedChar = 1
				end
			
				setPedAnimation(localCharacters[selectedChar], "ON_LOOKERS", "wave_loop", -1, true, false, false)

				renderData.charCamEndX = 1148.2672119141 - (selectedChar - 1) * 6
				renderData.charSelectInterpolation = getTickCount()
			elseif key == "arrow_r" and selectedChar < #pedData then
				renderData.charCamStartX = 1148.2672119141 - (selectedChar - 1) * 6

				setPedAnimation(localCharacters[selectedChar])
				selectedChar = selectedChar + 1
			
				if selectedChar > #pedData then
					selectedChar = #pedData
				end
			
				setPedAnimation(localCharacters[selectedChar], "ON_LOOKERS", "wave_loop", -1, true, false, false)

				renderData.charCamEndX = 1148.2672119141 - (selectedChar - 1) * 6
				renderData.charSelectInterpolation = getTickCount()
			elseif key == "enter" and not renderData.charGotSelected and selectedChar then
				renderData.charGotSelected = true

				if pedData[selectedChar].charID then
					if isElement(loginMusic) then
						destroyElement(loginMusic)
					end
					loginMusic = nil
							
					local spawnTime = math.random(7500, 10000)

					exports.cosmo_loader:showTheLoadScreen(spawnTime, {"Adatok betöltése...", "Szinkronizációk folyamatban...", "Belépés Los Santosba..."}, 1)

					removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
					removeEventHandler("onClientKey", getRootElement(), characterSelectKey)
					removeEventHandler("onClientCharacter", getRootElement(), characterSelectCharacter)

					local charPos = split(pedData[selectedChar].position, ",")
					--setCameraMatrix(tonumber(charPos[1]), tonumber(charPos[2]), tonumber(charPos[3]))
					setCameraTarget(localPlayer)

					setTimer(
						function (charID, data)
							triggerServerEvent("onCharacterSelect", localPlayer, localPlayer, charID, data)

							showCursor(false)
						end,
					spawnTime, 1, pedData[selectedChar].charID, pedData[selectedChar])
					
					for k,v in pairs(localCharacters) do
						if isElement(v) then
							destroyElement(v)
						end
						localCharacters[k] = nil
					end
				else
					renderData.charGotSelected = false
				end
			elseif key == "space" and not renderData.charGotSelected and maxCreatableChar > #pedData then
				removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
				removeEventHandler("onClientKey", getRootElement(), characterSelectKey)
				removeEventHandler("onClientCharacter", getRootElement(), characterSelectCharacter)

				for k,v in pairs(localCharacters) do
					if isElement(v) then
						destroyElement(v)
					end
					localCharacters[k] = nil
				end

				renderData.canUseFakeInputs = false
				renderData.inputDisabled = false

				addEventHandler("onClientRender", getRootElement(), onClientRender)
				addEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
				addEventHandler("onClientKey", getRootElement(), onClientKey)
				addEventHandler("onClientClick", getRootElement(), onClientClick)

				startCharacterMaking()
			end
		end
	end
end

addEvent("onPlayerCharacterMade", true)
addEventHandler("onPlayerCharacterMade", getRootElement(),
	function (characters)
		if #pedData > 0 then -- ha új karakter létrehozására ment, tehát már volt fiókja
			loadCharacterSelector(characters)

			if not loginMusic then
				loginMusic = playSound("files/login.mp3", true)
				setSoundVolume(loginMusic, 0.5)
			end
		else
			exports.cosmo_hud:showInfobox("success", "Sikeres regisztráció! Mostmár bejelentkezhetsz.")
			
			renderData.registerActive = false
			renderData.inputDisabled = false
			renderData.canUseFakeInputs = true
		end
	end
)

addEvent("onRegisterFinish", true)
addEventHandler("onRegisterFinish", getRootElement(),
	function (accountId)
		triggerServerEvent("onClientTryToCreateCharacter", localPlayer, utf8.gsub(characterMaking.charName, " ", "_"), {
			accID = accountId,
			skin = characterMaking.selectedSkin,
			age = characterMaking.charAge
		})
	end
)

addEvent("checkNameCallback", true)
addEventHandler("checkNameCallback", getRootElement(),
	function (rows)
		if rows < 1 then
			local names = split(characterMaking.charName, " ")

			if characterMaking.charName and #names >= 2 and #names <= 3 then
				characterMaking.nameInputHide = getTickCount()
				characterMaking.skinSelectStart = characterMaking.nameInputHide + 1000
			end
		else
			exports.cosmo_hud:showInfobox("error", "Már van ilyen nevű karakter a szerveren!")
		end
		
		characterMaking.disableNameInput = false
	end
)

addEvent("onClientRegister", true)
addEventHandler("onClientRegister", getRootElement(),
	function (rows)
		if rows > 0 then
			exports.cosmo_hud:showInfobox("error", "Már létezik account ehhez a géphez társítva\nVárj 10 másodpercet az újrapróbálkozáshoz!")
		else
			renderData.canUseFakeInputs = false

			startCharacterMaking()

			if isElement(loginMusic) then
				destroyElement(loginMusic)
			end
			loginMusic = nil
		end
		
		setTimer(
			function()
				renderData.inputDisabled = false
			end,
		10000, 1)
	end
)

function destroyCharacterMaking()
	if isElement(characterMaking.cutsceneMusic) then
		destroyElement(characterMaking.cutsceneMusic)
	end

	if isElement(characterMaking.planeLanding) then
		destroyElement(characterMaking.planeLanding)
	end
	
	if isElement(characterMaking.planeLanding1) then
		destroyElement(characterMaking.planeLanding1)
	end
	
	if isElement(characterMaking.planeLanding2) then
		destroyElement(characterMaking.planeLanding2)
	end

	if isElement(characterMaking.taxiDriver) then
		destroyElement(characterMaking.taxiDriver)
	end

	if isElement(characterMaking.myCharacter) then
		destroyElement(characterMaking.myCharacter)
	end

	if isElement(characterMaking.taxiCar) then
		destroyElement(characterMaking.taxiCar)
	end

	if isElement(taxiStopColShape) then
		destroyElement(taxiStopColShape)
	end

	characterMaking.cutsceneMusic = nil
	characterMaking.planeLanding = nil
	characterMaking.taxiDriver = nil
	characterMaking.myCharacter = nil
	characterMaking.taxiCar = nil
	taxiStopColShape = nil
end

function startCharacterMaking()
	if not renderData.characterMakingActive then
		if isElement(loginMusic) then
			destroyElement(loginMusic)
			loginMusic = nil
		end

		characterMaking = {}
		characterMaking.charName = ""
		characterMaking.currentSkin = 1
		characterMaking.selectedSkin = 1
		characterMaking.charAge = false

		characterMaking.started = true
		renderData.characterMakingActive = true

		local localDimension = getElementDimension(localPlayer)

		characterMaking.cutsceneMusic = playSound("files/sanandreas.ogg")
		setSoundVolume(characterMaking.cutsceneMusic, 0)

		characterMaking.planeX = 1670
		characterMaking.planeY = -1957.900390625
		characterMaking.planeZ = 15.1
	
		characterMaking.planeLanding = createVehicle(538, 1670, -1957.900390625, 15.1)
		setElementFrozen(characterMaking.planeLanding, true)
		setElementDimension(characterMaking.planeLanding, localDimension)
		setVehicleColor(characterMaking.planeLanding,255,255,255,255,255,255)
		
		characterMaking.planeX1 = 1651.12
		characterMaking.planeY1 = -1957.900390625
		characterMaking.planeZ1 = 15.1
	
		characterMaking.planeLanding1 = createVehicle(570, 1651.12, -1957.900390625, 15.1)
		setElementFrozen(characterMaking.planeLanding1, true)
		setElementDimension(characterMaking.planeLanding1, localDimension)
		setVehicleColor(characterMaking.planeLanding1,255,255,255,255,255,255)
		
		characterMaking.planeX2 = 1630.3
		characterMaking.planeY2 = -1957.900390625
		characterMaking.planeZ2 = 15.1
	
		characterMaking.planeLanding2 = createVehicle(570, 1630.3, -1957.900390625, 15.1)
		setElementFrozen(characterMaking.planeLanding2, true)
		setElementDimension(characterMaking.planeLanding2, localDimension)
		setVehicleColor(characterMaking.planeLanding2,255,255,255,255,255,255)

		characterMaking.taxiCar = createVehicle(420, 1742.900390625+1, -1858.5, 13.3)
		setElementRotation(characterMaking.taxiCar, 0, 0, 270)
		setElementCollidableWith(characterMaking.taxiCar, getCamera(), false)
		setElementDimension(characterMaking.taxiCar, localDimension)
		setVehicleColor(characterMaking.taxiCar,254, 208, 1,255,255,255)
		setTimer(
			function ()
				setVehicleEngineState(characterMaking.taxiCar, false)
			end,
		50, 1)
		
		characterMaking.planeDriver = createPed(164, 1670, -1957.900390625, 15.1 + 5)
		warpPedIntoVehicle(characterMaking.planeDriver, characterMaking.planeLanding,1)
		setElementDimension(characterMaking.planeDriver, localDimension)
		
		characterMaking.Vonatvaro = createPed(20, 1734.79919, -1960.66272, 14.11719)
		setElementDimension(characterMaking.Vonatvaro, localDimension)
		setPedAnimation(characterMaking.Vonatvaro, "COP_AMBIENT", "Coplook_loop", 1, false, false, false)

		characterMaking.taxiDriver = createPed(164, 1670.7388916016, -2250.9565429688, 13.009739875793 + 5)
		warpPedIntoVehicle(characterMaking.taxiDriver, characterMaking.taxiCar)
		setElementDimension(characterMaking.taxiDriver, localDimension)

		characterMaking.myCharacter = createPed(1, 1670.7388916016 + 1, -2250.9565429688 + 1.5, 13.009739875793)
		warpPedIntoVehicle(characterMaking.myCharacter, characterMaking.taxiCar, 2)
		setElementDimension(characterMaking.myCharacter, localDimension)

		characterMaking.planeIsComing = true
		characterMaking.fadeStart = getTickCount() + 2000
		characterMaking.landingStart = characterMaking.fadeStart
		characterMaking.fade2Start = characterMaking.landingStart + 11000
	end
end

addEventHandler("onClientPreRender", getRootElement(),
	function ()
		if not characterMaking.started then
			return
		end

		local tickCount = getTickCount()

		if characterMaking.finalFade and tickCount >= characterMaking.finalFade then
		else
			dxDrawRectangle(0, 0, screenX, screenY / 7, tocolor(0, 0, 0))
			dxDrawRectangle(0, screenY - screenY / 7, screenX, screenY / 7, tocolor(0, 0, 0))
		end

		if characterMaking.planeIsComing then
			if not characterMaking.bgAlpha then
				characterMaking.bgAlpha = 255
				characterMaking.textAlpha = 255
			end

			if tickCount >= characterMaking.fadeStart then
				local progress = (tickCount - characterMaking.fadeStart) / 2000

				characterMaking.bgAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")
				characterMaking.textAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")

				if progress < 1 then
					if isElement(characterMaking.cutsceneMusic) then
						if progress > 0 and progress < 0.1 then
							setSoundPosition(characterMaking.cutsceneMusic, 0)
						end

						setSoundVolume(characterMaking.cutsceneMusic, progress)
					end
				end
			end

			if tickCount >= characterMaking.fade2Start then
				local fadeStartProgress = (tickCount - characterMaking.fade2Start) / 1000

				characterMaking.bgAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, fadeStartProgress, "Linear")
				characterMaking.textAlpha = 0

				if fadeStartProgress >= 1 then
					characterMaking.planeIsComing = false
					characterMaking.fade1StartTime = tickCount
					characterMaking.fade2StartTime = characterMaking.fade1StartTime + 1500
					characterMaking.nameInputStart = characterMaking.fade2StartTime + 1000
					characterMaking.bgAlpha = false
				end
			elseif tickCount >= characterMaking.landingStart then
				characterMaking.planeX, characterMaking.planeY, characterMaking.planeZ = interpolateBetween(1670, -1957.900390625, 15.1, 1750, -1957.900390625, 15.1, (tickCount - characterMaking.landingStart) / 10000, "OutQuad")
				characterMaking.planeX1, characterMaking.planeY1, characterMaking.planeZ1 = interpolateBetween(1651.12, -1957.900390625, 15.1, 1731.2001953125, -1957.900390625, 15.1, (tickCount - characterMaking.landingStart) / 10000, "OutQuad")
				characterMaking.planeX2, characterMaking.planeY2, characterMaking.planeZ2 = interpolateBetween(1630.3, -1957.900390625, 15.1, 1712.4-1.5, -1957.900390625, 15.1, (tickCount - characterMaking.landingStart) / 10000, "OutQuad")

				setCameraMatrix(1696.19202, -1942.17615, 13.55576, characterMaking.planeX, characterMaking.planeY, characterMaking.planeZ)
			end

			if characterMaking.bgAlpha and characterMaking.bgAlpha > 0 then
				dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, characterMaking.bgAlpha))
				dxDrawText("Los Santos Unity Station,", 0, 0, screenX, screenY, tocolor(255, 255, 255, characterMaking.textAlpha), 0.75, SARPFont, "center", "center")

				local realTime = getRealTime()

				dxDrawText(realTime.year + 1900 ..". " .. monthNames[realTime.month] .. " " .. realTime.monthday .. "., " .. dayNames[realTime.weekday], 0, 0, screenX, screenY + SARPFontH*1.5, tocolor(255, 255, 255, characterMaking.textAlpha), 0.75, SARPFont, "center", "center")
			end

			setElementPosition(characterMaking.planeLanding, characterMaking.planeX, characterMaking.planeY, characterMaking.planeZ)
			setElementRotation(characterMaking.planeLanding, 0, 0, 270)
			setElementPosition(characterMaking.planeLanding1, characterMaking.planeX1, characterMaking.planeY1, characterMaking.planeZ1)
			setElementRotation(characterMaking.planeLanding1, 0, 0, 270)
			setElementPosition(characterMaking.planeLanding2, characterMaking.planeX2, characterMaking.planeY2, characterMaking.planeZ2)
			setElementRotation(characterMaking.planeLanding2, 0, 0, 270)
		elseif not characterMaking.finalFadeEnd or tickCount < characterMaking.finalFadeEnd then
			if not characterMaking.bgAlpha then
				characterMaking.bgAlpha = 255
				characterMaking.textAlpha = 0
				setCameraMatrix(1766.14551, -1945.93591, 13.56114+2, 1746.57214, -1957.92542, 13.54688) --A repülő miután elment ide teszi a kamerát egy pillanatra
				spawnAIs(1)
			end

			if tickCount >= characterMaking.fade1StartTime and tickCount < characterMaking.fade2StartTime then
				characterMaking.bgAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, (tickCount - characterMaking.fade1StartTime) / 1000, "Linear")
			end

			if tickCount >= characterMaking.fade2StartTime and tickCount < characterMaking.nameInputStart then
				local progress = (tickCount - characterMaking.fade2StartTime) / 1500

				local cameraX, cameraY, cameraZ = interpolateBetween(1742.38623+3, -1856.74463+2, 13.41406, 1748.98975+0.1, -1852.68262, 13.41406, progress, "OutQuad") ----Itt van az emberen a kamera aki a taxiba ül
				local lookAtX, lookAtY, lookAtZ = interpolateBetween(1742.38623+2, -1856.74463, 13.41406, 1748.98975, -1852.68262, 13.41406, progress, "OutQuad") --Ezt nemtom
				
				setCameraMatrix(cameraX, cameraY, cameraZ, lookAtX, lookAtY, lookAtZ)
			end

			if tickCount >= characterMaking.nameInputStart then
				characterMaking.textAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, (tickCount - characterMaking.nameInputStart) / 1000, "Linear")
			end

			if characterMaking.skinSelectStart and tickCount >= characterMaking.nameInputHide and tickCount < characterMaking.skinSelectStart then
				characterMaking.textAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, (tickCount - characterMaking.nameInputHide) / 1000, "Linear")
			end

			if characterMaking.skinSelectStart and tickCount >= characterMaking.skinSelectStart then
				characterMaking.textAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, (tickCount - characterMaking.skinSelectStart) / 1000, "Linear")
			end

			if characterMaking.ageInputStart and tickCount >= characterMaking.skinSelectHide and tickCount < characterMaking.ageInputStart then
				characterMaking.textAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, (tickCount - characterMaking.skinSelectHide) / 1000, "Linear")
			end

			if characterMaking.ageInputStart and tickCount >= characterMaking.ageInputStart then
				characterMaking.textAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, (tickCount - characterMaking.ageInputStart) / 1000, "Linear")
			end

			if characterMaking.ageInputHide and characterMaking.finalFade and tickCount >= characterMaking.ageInputHide and tickCount < characterMaking.finalFade then
				local progress = (tickCount - characterMaking.ageInputHide) / 1500

				characterMaking.bgAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")
				characterMaking.textAlpha = 255 - characterMaking.bgAlpha

				if progress >= 0.25 then
					setVehicleEngineState(characterMaking.taxiCar, true)
					setPedControlState(characterMaking.taxiDriver, "accelerate", true)
				end

				if progress >= 1 then
					setElementVelocity(characterMaking.taxiCar, 0, 0, 0)
					setElementPosition(characterMaking.taxiCar, 1445.2677001953, -1734.1259765625, 13.017685890198)
					setElementRotation(characterMaking.taxiCar, 0, 0, 270)

					if not isElement(taxiStopColShape) then
						spawnAIs(2)
						taxiStopColShape = createColSphere(1481.7147216797, -1733.7055664063, 13.01765537262, 3)
					end
				end
			end

			if characterMaking.finalFade and tickCount >= characterMaking.finalFade then
				characterMaking.bgAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, (tickCount - characterMaking.finalFade) / 1500, "Linear")
				characterMaking.textAlpha = 0

				local taxiX, taxiY, taxiZ = getVehicleComponentPosition(characterMaking.taxiCar, "wheel_rb_dummy", "world")
				local _, _, taxiRotZ = getElementRotation(characterMaking.taxiCar)
				local cameraAngle = math.rad(75)

				setCameraMatrix(
					taxiX + (taxiX + 5 - taxiX) * math.cos(cameraAngle),
					taxiY + (taxiY + 2 - taxiY) * math.sin(cameraAngle),
					taxiZ + 6,
					taxiX,
					taxiY,
					taxiZ - 6
				)

				if getDistanceBetweenPoints3D(taxiX, taxiY, taxiZ, 1481.7147216797, -1733.7055664063, 13.01765537262) <= 20 then
					setPedControlState(characterMaking.taxiDriver, "accelerate", false)
				end
			end

			if characterMaking.cutsceneEndStart and tickCount >= characterMaking.cutsceneEndStart then
				local progress = (tickCount - characterMaking.cutsceneEndStart) / 2000

				if progress >= 0.25 then
					if not characterMaking.taxiCarDoorOpened then
						characterMaking.taxiCarDoorOpened = true
						setVehicleDoorOpenRatio(characterMaking.taxiCar, 5, 1, 500)
					end
				end

				characterMaking.bgAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")
				characterMaking.textAlpha = 0
			end

			if characterMaking.cutsceneEnd and tickCount >= characterMaking.cutsceneEnd then
				local progress = (tickCount - characterMaking.cutsceneEnd) / 500

				if isElement(characterMaking.cutsceneMusic) then
					setSoundVolume(characterMaking.cutsceneMusic, 1 - progress)
				end

				if progress >= 1 then
					if isElement(characterMaking.cutsceneMusic) then
						destroyElement(characterMaking.cutsceneMusic)
					end

					characterMaking.started = false

					if #pedData == 0 then -- ** ha még nincs karaktere, tehát most regisztrál
						renderData.registerActive = true
						renderData.canUseFakeInputs = true
						renderData.inputDisabled = false
						renderData.characterMakingActive = false

						exports.cosmo_hud:showInfobox("info", "Regisztrálj magadnak egy felhasználót a játék elkezdéséhez.")
					else -- ** ha új karaktert hoz létre
						triggerEvent("onRegisterFinish", localPlayer, getElementData(localPlayer, "acc.dbID"))
					end

					destroyCharacterMaking()
				end
			end

			dxDrawRectangle(0, 0, screenX, screenY, tocolor(0, 0, 0, characterMaking.bgAlpha))

			if characterMaking.ageInputStart and tickCount >= characterMaking.ageInputStart then
				dxDrawText("#BDBDBD" .. (characterMaking.charAge or "") .. " #fffffféves", 0, 0, screenX, screenY/7, tocolor(255, 255, 255, characterMaking.textAlpha), 1, SARPFont, "center", "center", false, false, false, true)
				dxDrawText("Írd be a karaktered életkorát, majd nyomd meg az ENTERT", 0, screenY - screenY/7, screenX, screenY, tocolor(255, 255, 255, characterMaking.textAlpha), 0.5, SARPFont, "center", "center", false, false, false, true)
			elseif characterMaking.skinSelectStart and tickCount >= characterMaking.skinSelectStart then
				dxDrawText("Válaszd ki a skinedet a balra-jobbra nyilakkal, majd nyomd meg az ENTERT", 0, screenY - screenY/7, screenX, screenY, tocolor(255, 255, 255, characterMaking.textAlpha), 0.5, SARPFont, "center", "center", false, false, false, true)
			elseif tickCount >= characterMaking.nameInputStart then
				dxDrawText("#BDBDBD" .. (characterMaking.charName or ""), 0, 0, screenX, screenY/7, tocolor(255, 255, 255, characterMaking.textAlpha), 1, SARPFont, "center", "center", false, false, false, true)
				dxDrawText("Írd be a karaktered nevét szóközzel elválasztva, majd nyomd meg az ENTERT", 0, screenY - screenY/7, screenX, screenY, tocolor(255, 255, 255, characterMaking.textAlpha), 0.5, SARPFont, "center", "center", false, false, false, true)
			end
		end
	end
)

addEventHandler("onClientColShapeHit", getRootElement(),
	function (hitElement)
		if taxiStopColShape then
			setElementFrozen(characterMaking.taxiCar, true)
			setPedControlState(characterMaking.taxiDriver, "accelerate", false)

			characterMaking.cutsceneEndStart = getTickCount()
			characterMaking.cutsceneEnd = characterMaking.cutsceneEndStart + 2000
		end
	end
)


local createdAIs = {}
local pedSkins = getValidPedModels()
local registeredVehicles = {}
local vehiclesWithPed = {}
local vehiclesMaxSpeed = {}

function spawnWalkingPed(x, y, z, rot)
	if not characterMaking.cutsceneEnd then
		local ped = createPed(pedSkins[math.random(1, #pedSkins)], x, y, z, rot)

		table.insert(createdAIs, ped)

		setPedControlState(ped, "walk", true)
		setPedControlState(ped, "forwards", true)

		setElementDimension(ped, getElementDimension(localPlayer))

		return ped
	end

	return false
end

function spawnPedDestroyerShape(x, y, z, radius)
	local sphere = createColSphere(x, y, z, radius)

	setElementData(sphere, "pedDestroyerShape", true, false)
	setElementDimension(sphere, getElementDimension(localPlayer))

	return sphere
end

function spawnPedSpawnerShape(x, y, z, radius, data)
	local sphere = createColSphere(x, y, z, radius)

	setElementData(sphere, "pedSpawnerDatas", data, false)
	setElementDimension(sphere, getElementDimension(localPlayer))

	return sphere
end

function registerVehicle(model, count)
	for i = 1, count do
		table.insert(registeredVehicles, model)
	end
end

function spawnMovingVehicle(x, y, z, rot, maxSpeed)
	local veh = createVehicle(registeredVehicles[math.random(1, #registeredVehicles)], x, y, z, 0, 0, rot)

	if isElement(veh) then
		setElementDimension(veh, getElementDimension(localPlayer))

		local ped = createPed(pedSkins[math.random(1, #pedSkins)], x, y, z + 2)
		warpPedIntoVehicle(ped, veh)
		setElementDimension(ped, getElementDimension(localPlayer))

		vehiclesWithPed[veh] = ped
		vehiclesMaxSpeed[veh] = maxSpeed
	else
		spawnMovingVehicle(x, y, z, rot, maxSpeed)
	end
end

function spawnVehicleDestroyerShape(x, y, z, radius)
	local sphere = createColSphere(x, y, z, radius)

	setElementData(sphere, "vehicleDestroyerShape", true, false)
	setElementDimension(sphere, getElementDimension(localPlayer))

	return sphere
end

function spawnVehicleSpawnerShape(x, y, z, radius, data)
	local sphere = createColSphere(x, y, z, radius)

	setElementData(sphere, "vehicleSpawnerDatas", data, false)
	setElementDimension(sphere, getElementDimension(localPlayer))

	return sphere
end

addEventHandler("onClientColShapeHit", getRootElement(),
	function (hitElement)
		if not characterMaking.cutsceneEnd and ((taxiStopColShape and source ~= taxiStopColShape) or not taxiStopColShape) then
			if isElement(hitElement) and getElementType(hitElement) == "vehicle" then
				if getElementData(source, "vehicleSpawnerDatas") then
					setTimer(
						function (data)
							spawnMovingVehicle(unpack(data))
						end,
					math.random(7500, 30000), 1, getElementData(source, "vehicleSpawnerDatas"))
				end

				if getElementData(source, "vehicleDestroyerShape") then
					destroyElement(hitElement)

					if vehiclesWithPed[hitElement] then
						destroyElement(vehiclesWithPed[hitElement])
					end
				end
			end
			if isElement(hitElement) and getElementType(hitElement) == "ped" then
				if getElementData(source, "pedDestroyerShape") then
					destroyElement(hitElement)
				end

				if getElementData(source, "pedSpawnerDatas") then
					setTimer(
						function (data)
							spawnWalkingPed(unpack(data))
						end,
					math.random(6000, 8000), 1, getElementData(source, "pedSpawnerDatas"))
				end
			end
		end
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		for k, v in pairs(vehiclesWithPed) do
			if not isElement(k) or not isElement(v) then
				vehiclesWithPed[k] = nil
			elseif tonumber((Vector3(getElementVelocity(k)) * 180).length) < vehiclesMaxSpeed[k] then
				setPedControlState(v, "accelerate", true)
			else
				setPedControlState(v, "accelerate", false)
			end
		end
	end
)

registerVehicle(549, 2)
registerVehicle(463, 5)
registerVehicle(581, 5)
registerVehicle(468, 5)
registerVehicle(522, 10)
registerVehicle(490, 1)
registerVehicle(596, 5)
registerVehicle(523, 1)
registerVehicle(498, 1)
registerVehicle(588, 5)
registerVehicle(422, 15)
registerVehicle(413, 10)
registerVehicle(482, 10)
registerVehicle(551, 10)
registerVehicle(439, 15)
registerVehicle(496, 10)
registerVehicle(445, 10)
registerVehicle(546, 10)
registerVehicle(411, 5)
registerVehicle(602, 5)
registerVehicle(451, 2)
registerVehicle(562, 5)
registerVehicle(560, 10)
registerVehicle(415, 7)

function destroyAIs()
	for k,v in pairs(createdAIs) do
		if isElement(v) then
			destroyElement(v)
		end
	end
	createdAIs = {}

	for k,v in pairs(vehiclesWithPed) do
		if isElement(k) then
			destroyElement(k)
		end

		vehiclesMaxSpeed[k] = nil

		if isElement(v) then
			destroyElement(v)
		end
	end

	vehiclesWithPed = {}
	vehiclesMaxSpeed = {}

	for k,v in ipairs(getElementsByType("colshape", resourceRoot, true)) do
		if isElement(v) then
			destroyElement(v)
		end
	end
end

function spawnAIs(cutscene)
	destroyAIs()

	if cutscene == 1 then
		spawnPedDestroyerShape(1813.8695068359, -1626.9422607422, 13.546875, 1.5)
		spawnPedSpawnerShape(1814.3854980469, -1720.7805175781, 13.546875, 1.5, {1814.3854980469, -1720.7805175781, 13.546875, 0})
		spawnWalkingPed(1814.3854980469, -1720.7805175781, 13.546875, 0)

		spawnMovingVehicle(1824.1156005859, -1739.2933349609, 13.3828125, 0, 50)
		spawnVehicleSpawnerShape(1824.1156005859, -1739.2933349609, 13.3828125, 2, {1824.1156005859, -1739.2933349609, 13.3828125, 0, 50})
		spawnVehicleDestroyerShape(1824.6151123047, -1615.2933349609, 13.384164810181, 2)
	elseif cutscene == 2 then
		spawnMovingVehicle(1509.7005615234, -1730.2673339844, 12.901854515076, 90, 50)
		spawnVehicleSpawnerShape(1509.7005615234, -1730.2673339844, 12.901854515076, 2, {1509.7005615234, -1730.2673339844, 12.901854515076, 90, 50})
		spawnVehicleDestroyerShape(1417.3262939453, -1730.2839355469, 12.909861564636, 2)
	end
end

function drawInput(key, label, x, y, w, h)
	if not renderData[key] then
		renderData[key] = ""
	end

	local value = renderData[key]
	if key == "password" then
		value = renderData.passwordHidden
	elseif key == "password2" then
		value = renderData.password2Hidden
	end

	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 160))
	renderData.buttons[key] = {x, y, w, h}

	if utf8.len(value) > 0 then
		dxDrawText(value, x + 10, y, x + 10 + w - 20, y + h, tocolor(255, 255, 255, 230), 1, font3, "left", "center")
	else
		dxDrawText(label, x + 10, y, x + 10 + w - 20, y + h, tocolor(100, 100, 100, 200), 1, font3, "left", "center")
	end

	if renderData.activeFakeInput == key then
		if cursorState then
			local w = dxGetTextWidth(value, 1, font3)
			dxDrawLine(x + 10 + w, y + 5, x + 10 + w, y + h - 5, tocolor(230, 230, 230, 255))
		end

		if getTickCount() - lastChangeCursorState >= 500 then
			cursorState = not cursorState
			lastChangeCursorState = getTickCount()
		end
	end
end

function drawButton(key, label, x, y, w, h, activeColor, icon, labelFont, iconFont, labelScale, iconScale)
	local buttonColor
	if renderData.activeButton == key then
		buttonColor = {processColorSwitchEffect(key, {activeColor[1], activeColor[2], activeColor[3], 175})}
	else
		buttonColor = {processColorSwitchEffect(key, {activeColor[1], activeColor[2], activeColor[3], 125})}
	end

	local alphaDifference = 175 - buttonColor[4]

	dxDrawRectangle(x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - alphaDifference))
	--dxDrawInnerBorder(2, x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 125 + alphaDifference))

	labelFont = labelFont or Roboto18L
	labelScale = labelScale or 0.85

	if icon then
		iconFont = iconFont or Themify18
		iconScale = iconScale or 0.75

		local iconWidth = dxGetTextWidth(icon, iconScale, iconFont) + 5
		local textWidth = dxGetTextWidth(label, labelScale, labelFont)
		local totalWidth = iconWidth + textWidth

		local x2 = x + (w - totalWidth) / 2

		dxDrawText(icon, x2, y, 0, y + h, tocolor(255, 255, 255, 255), iconScale, iconFont, "left", "center")
		dxDrawText(label, x2 + iconWidth, y, 0, y + h, tocolor(255, 255, 255, 255), labelScale, font2, "left", "center")
	else
		dxDrawText(label, x, y, x + w, y + h, tocolor(255, 255, 255, 255), labelScale, font2, "center", "center")
	end
	
	renderData.buttons[key] = {x, y, w, h}
end

function dxDrawInnerBorder(thickness, x, y, w, h, color, postGUI)
	thickness = thickness or 2

	dxDrawLine(x, y, x + w, y, color, thickness, postGUI)
	dxDrawLine(x, y + h, x + w, y + h, color, thickness, postGUI)
	dxDrawLine(x, y, x, y + h, color, thickness, postGUI)
	dxDrawLine(x + w, y, x + w, y + h, color, thickness, postGUI)
end

renderData.colorSwitches = {}
renderData.lastColorSwitches = {}
renderData.startColorSwitch = {}
renderData.lastColorConcat = {}

function processColorSwitchEffect(key, color, duration, type)
	if not renderData.colorSwitches[key] then
		if not color[4] then
			color[4] = 255
		end

		renderData.colorSwitches[key] = color
		renderData.lastColorSwitches[key] = color

		renderData.lastColorConcat[key] = table.concat(color)
	end

	duration = duration or 500
	type = type or "Linear"

	if renderData.lastColorConcat[key] ~= table.concat(color) then
		renderData.lastColorConcat[key] = table.concat(color)
		renderData.lastColorSwitches[key] = color
		renderData.startColorSwitch[key] = getTickCount()
	end

	if renderData.startColorSwitch[key] then
		local progress = (getTickCount() - renderData.startColorSwitch[key]) / duration

		local r, g, b = interpolateBetween(
			renderData.colorSwitches[key][1], renderData.colorSwitches[key][2], renderData.colorSwitches[key][3],
			color[1], color[2], color[3],
			progress, type
		)

		local a = interpolateBetween(renderData.colorSwitches[key][4], 0, 0, color[4], 0, 0, progress, type)

		renderData.colorSwitches[key][1] = r
		renderData.colorSwitches[key][2] = g
		renderData.colorSwitches[key][3] = b
		renderData.colorSwitches[key][4] = a

		if progress >= 1 then
			renderData.startColorSwitch[key] = false
		end
	end

	return renderData.colorSwitches[key][1], renderData.colorSwitches[key][2], renderData.colorSwitches[key][3], renderData.colorSwitches[key][4]
end

renderData.buttonSliderOffsets = {}
renderData.buttonStartSlider = {}
renderData.buttonSliderStates = {}

function drawButtonSlider(key, state, x, y, h, offColor, onColor)
	if not renderData.buttonSliderOffsets[key] then
		renderData.buttonSliderOffsets[key] = state and 32 or 0
		renderData.buttonSliderStates[key] = state
	end

	local buttonColor
	if state then
		buttonColor = {processColorSwitchEffect(key, {onColor[1], onColor[2], onColor[3], 0})}
	else
		buttonColor = {processColorSwitchEffect(key, {offColor[1], offColor[2], offColor[3], 255})}
	end

	if renderData.buttonSliderStates[key] ~= state then
		renderData.buttonSliderStates[key] = state
		renderData.buttonStartSlider[key] = {getTickCount(), state}
	end

	if renderData.buttonStartSlider[key] then
		local progress = (getTickCount() - renderData.buttonStartSlider[key][1]) / 500

		if  renderData.buttonStartSlider[key][2] then
			renderData.buttonSliderOffsets[key] = interpolateBetween(renderData.buttonSliderOffsets[key], 0, 0, 32, 0, 0, progress, "Linear")
		else
			renderData.buttonSliderOffsets[key] = interpolateBetween(renderData.buttonSliderOffsets[key], 0, 0, 0, 0, 0, progress, "Linear")
		end

		if progress >= 1 then
			renderData.buttonStartSlider[key] = false
		end
	end

	local alphaDifference = 255 - buttonColor[4]

	renderData.buttons[key] = {x, y, 64, 32}

	y = y + (h - 32) / 2

	dxDrawImage(x, y, 64, 32, "files/switch/off.png", 0, 0, 0, tocolor(255, 255, 255, 255 - alphaDifference))
	dxDrawImage(x, y, 64, 32, "files/switch/on.png", 0, 0, 0, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 0 + alphaDifference))
	dxDrawImage(x + renderData.buttonSliderOffsets[key], y, 64, 32, "files/switch/circle.png", 0, 0, 0, tocolor(255, 255, 255, 255))
end

--[[local logoNodes = {
	[1] = {
		[1] = {
			{129, 0, 18, 64},
			{18, 64, 18, 194},
			{18, 194, 129, 256}
		},
		[2] = {
			{129, 40, 56, 83},
			{56, 83, 56, 115},
			{56, 115, 129, 155}
		},
		[3] = {
			{129, 196, 70, 163},
			{70, 163, 70, 140},
			{70, 140, 56, 140},
			{56, 140, 56, 173},
			{56, 173, 129, 213}
		},
		[4] = {
			{129, 59, 70, 92},
			{70, 92, 70, 106},
			{70, 106, 135, 143},
			{135, 143, 129, 155}
		}
	},
	[2] = {
		[1] = {
			{129, 0, 239, 64},
			{239, 64, 239, 194},
			{239, 194, 129, 256}
		},
		[2] = {
			{129, 40, 201, 83},
			{201, 83, 201, 115},
			{201, 115, 187, 115},
			{187, 115, 187, 92},
			{187, 92, 129, 59}
		},
		[3] = {
			{129, 99, 122, 112},
			{122, 112, 187, 149},
			{187, 149, 187, 163},
			{187, 163, 129, 196}
		},
		[4] = {
			{129, 99, 201, 141},
			{201, 141, 201, 172},
			{201, 172, 129, 213}
		}
	}
}--]]

--local speed = 5000

function drawLogoAnimation(x, y, fftMul)
	if not renderData.logoAlpha then
		renderData.logoAlpha = 254
	end


	dxDrawImage(x + 63, y+20, 128, 128, "files/logo.png", 0, 0, 0, tocolor(255,255,255, renderData.logoAlpha))
end

function createHash(string, key)
    if not key then
        key = generateRandomString(8)
    end

    return "$" .. key .. "$" .. hash("sha512", "SARP#PW" .. md5(key) .. md5(string))
end

--addCommandHandler("password",
  --function(command, key, string)
    --  local passstring = createHash(key, string)
      --outputChatBox(passstring)
  	--end)