local screenX, screenY = guiGetScreenSize()

local responsiveMultipler = 1--exports.cosmo_hud:getResponsiveMultipler()

local function respc(x)
	return math.ceil(x * responsiveMultipler)
end

local function resp(x)
	return x * responsiveMultipler
end

local smsRenderTarget = dxCreateRenderTarget(270, 240, true)
local moveY = 0

local phoneWidth = respc(280)
local phoneHeight = respc(512)

local phonePosX = screenX - phoneWidth - resp(12)
local phonePosY = screenY / 2 - phoneHeight / 2

local forceState = true
local phoneState = false

local callMessages = {}
local currentCallMSG = -6

local callingMember = nil
local currentCallMemberName = ""
local currentCallMemberNumber = ""

local hirdetesTick = 0

local isNewMessage = false
local idNumber = nil

local currentPage = "lockscreen"

setElementData(localPlayer,"hiredetesbekapcsolva", true)
setElementData(localPlayer,"hiredetesbekapcsolvaillegal", true)
setElementData(localPlayer,"telefonszambekapcsolva", true)
setElementData(localPlayer,"telefonszambekapcsolvaillegal", true)

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

local textures = {}
local weatherData = {}

local buttons = {}
local activeButton = false

local fakeInputs = {}
local activeFakeInput = false

local apps = {
	{"settings.png", "changepage:settings", "Beállítások"},
	{"contacts.png", "changepage:contacts", "Névjegyzék"},
	{"phone.png", "changepage:phone", "Tárcsázó"},
	{"sms.png", "changepage:messages", "Üzenetek"},
	{"hirdetes.png", "changepage:hirdetes", "Hirdetés"},
	{"darkHirdetes.png", "changepage:darkHirdetes", "Illegál Hirdetés"},
}

local setNum = 11
local offsetSet = 0
local settings = {
	{"wallpaper_icon.png", "changepage:changewallpaper", "Háttérkép beállítása"},
}

local wallpapersNum = 5
local offsetWallpaper = 0
local selectedWallpaper = 1
local currentWallpaper = 1
local randomWallpaperMode = false

local myPhoneNum = false

local cursorState = false
local lastChangeCursorState = 0

local contacts = {}
local contactsEx = {}
local offsetContact = 0
local contactNum = 8
local selectedContact = false

local offsetMessages = 0
local messages = {}
local messagesNum = 7
local offsetSMS = 0
local selectedMessage = nil

addEventHandler("onClientResourceStart", getRootElement(),
	function(res)
		local weather = getResourceFromName("cosmo_weather")

		if weather and getResourceState(weather) == "running" then
			weatherData = getElementData(getResourceRootElement(weather), "serverWeather")
		end

		if res == getThisResource() then
			triggerEvent("requestChangePhoneStartPos", localPlayer)
		end
		
		triggerServerEvent("loadContact", localPlayer, localPlayer, getElementData(localPlayer, "acc.ID"))
	end)

addEventHandler("onClientElementDataChange", getRootElement(),
	function(data)
		if data == "serverWeather" then
			weatherData = getElementData(source, "serverWeather")
		end
	end)

local RobotoFont = false
local RobotoFontLighter = false

function createFonts()
	RobotoFont = dxCreateFont(":cosmo_assets/fonts/Roboto-Regular.ttf", resp(15), false, "antialiased")
	RobotoFontLighter = dxCreateFont(":cosmo_assets/fonts/Roboto-Light.ttf", resp(40), false, "cleartype")
	Roboto14 = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", respc(10), false, "antialiased")
end

function destroyFonts()
	if isElement(RobotoFont) then
		destroyElement(RobotoFont)
		RobotoFont = nil
	end

	if isElement(RobotoFontLighter) then
		destroyElement(RobotoFontLighter)
		RobotoFontLighter = nil
	end
end

function showPhoneInCall(number, player, dbId)
	setElementData(player, "inCall", true)
	if not getElementData(localPlayer, "phoneOpened") then
		exports.cosmo_inventory:useItem(dbId)
	end
	currentPage = "incoming"
	callingMember = player
	
	currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(number)
end
addEvent("showPhoneInCall", true)
addEventHandler("showPhoneInCall", getRootElement(), showPhoneInCall)

function calling(player)
	setElementData(localPlayer, "inCall", true)
	callingMember = player
	commandHandler("changepage:calling")
end
addEvent("calling", true)
addEventHandler("calling", getRootElement(), calling)

function cancelledCall()
	commandHandler("changepage:home")
	callMessages = {}
	currentCallMSG = -6

	callingMember = nil
	setElementData(localPlayer, "inCall", false)
end
addEvent("cancelledCall", true)
addEventHandler("cancelledCall", getRootElement(), cancelledCall)

function accpetedCall(member)
	callingMember = member
	commandHandler("changepage:chatCall")
end
addEvent("accpetedCall", true)
addEventHandler("accpetedCall", getRootElement(), accpetedCall)

addEvent("openPhone", true)
addEventHandler("openPhone", getRootElement(),
	function(dbID, phoneNumber, datas, balance)

		phoneState = not phoneState
	
		if phoneState == false then
			triggerServerEvent("cancelledCallSend", localPlayer, localPlayer, callingMember)
			callMessages = {}
			currentCallMSG = -6
			messages = {}

			callingMember = nil
		end

		myPhoneNum = phoneNumber
		
		
		triggerServerEvent("loadContact", localPlayer, localPlayer, getElementData(localPlayer, "acc.ID"))
		triggerServerEvent("loadSMS", localPlayer, localPlayer, myPhoneNum)
		
		if randomWallpaperMode then
			math.randomseed(getTickCount() + math.random(getTickCount()))

			currentWallpaper = math.random(wallpapersNum)
		end

		selectedWallpaper = currentWallpaper

		if not selectedWallpaper or selectedWallpaper < 0 or selectedWallpaper > wallpapersNum then
			selectedWallpaper = 1
		end

		if currentPage == "lockscreen" then
			commandHandler("changepage:lockscreen")
		elseif currentPage == "incoming" then
			commandHandler("changepage:incoming")
		end

		if phoneState then
			createFonts()

			addEventHandler("onClientRender", getRootElement(), renderThePhone)
			addEventHandler("onClientClick", getRootElement(), onPhoneClick)
			addEventHandler("onClientKey", getRootElement(), onPhoneKey)
			addEventHandler("onClientCharacter", getRootElement(), processFakeInput)
		else
			removeEventHandler("onClientRender", getRootElement(), renderThePhone)
			removeEventHandler("onClientClick", getRootElement(), onPhoneClick)
			removeEventHandler("onClientKey", getRootElement(), onPhoneKey)
			removeEventHandler("onClientCharacter", getRootElement(), processFakeInput)
			currentPage = "lockscreen"
			destroyFonts()
		end
	end)

function processPhoneShowHide(state)
	forceState = state
end

function changePhoneStartPos(x, y)
	phonePosX, phonePosY = x, y
end

function drawTaskbar()
	if currentPage == "lockscreen" then
		dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/taskbar.png"))
	else
		dxDrawImage(phonePosX + resp(-32), phonePosY, resp(280), resp(512), processPhoneTexture("files/taskbar.png"))
		dxDrawText(replaceDynamicText("#currenttime"), phonePosX, phonePosY + resp(33), phonePosX + resp(265), 0, tocolor(255, 255, 255), 0.5, RobotoFont, "right", "top")
	end
end

function drawBaseButtons()
	dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/mainbuttons.png"))

	buttons["changepage:home"] = {phonePosX + resp(140) - resp(12), phonePosY + resp(469) - resp(12), resp(24), resp(24)}
end

function renderThePhone()
	if phoneState and forceState then
		buttons = {}
		-- ** Alap
		dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/base.png"))

		-- ** Háttérkép
		dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/wallpapers/" .. currentWallpaper .. ".png"))

		-- ** Zárképernyő
		if currentPage == "lockscreen" then
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(0, 0, 0, 180))

			dxDrawText("Érintsd meg a kijelzőt a feloldáshoz", phonePosX, phonePosY + resp(360), phonePosX + resp(280), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "center", "top")

			drawTaskbar()

			dxDrawText(replaceDynamicText("#currenttime"), phonePosX + resp(30), phonePosY + resp(380), 0, 0, tocolor(255, 255, 255), 1, RobotoFontLighter, "left", "top")
			dxDrawText(replaceDynamicText("#currentdate"), phonePosX + resp(30), phonePosY + resp(450), 0, 0, tocolor(180, 180, 180), 0.625, RobotoFont, "left", "top")

			buttons["unlockphone"] = {phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452)}
		-- ** Bejövő hívás //incall
		elseif currentPage == "incoming" then
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(0, 0, 0, 180))
			dxDrawText(currentCallMemberName, phonePosX, phonePosY + resp(120), phonePosX + resp(280), 0, tocolor(255, 255, 255), 1, RobotoFont, "center", "top")
			dxDrawText(currentCallMemberNumber, phonePosX, phonePosY + resp(160), phonePosX + resp(280), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "center", "top")
			
			local coseColor
			local coseColor2
			
			if activeButton == "acceptCall" then
				coseColor = tocolor(43, 219, 37)
			else
				coseColor = tocolor(34, 173, 29)
			end
			dxDrawImage(phonePosX + 60, phonePosY, resp(280), resp(512), processPhoneTexture("files/call.png"), 0, 0, 0, coseColor)
			buttons["acceptCall"] = {phonePosX + 178, phonePosY + 405, resp(45), resp(52)}

			if activeButton == "declineCall" then
				coseColor2 = tocolor(222, 22, 22)
			else
				coseColor2 = tocolor(181, 16, 16)
			end
			
			dxDrawImage(phonePosX - 60, phonePosY, resp(280), resp(512), processPhoneTexture("files/call.png"), 0, 0, 0, coseColor2)
			buttons["declineCall"] = {phonePosX + 57, phonePosY + 405, resp(45), resp(52)}
		-- ** Kimenő hívás
		elseif currentPage == "calling" then
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(0, 0, 0, 180))
			dxDrawText(currentCallMemberName, phonePosX, phonePosY + resp(120), phonePosX + resp(280), 0, tocolor(255, 255, 255), 1, RobotoFont, "center", "top")
			dxDrawText(currentCallMemberNumber, phonePosX, phonePosY + resp(160), phonePosX + resp(280), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "center", "top")
			
			local coseColor2
			if activeButton == "declineCalling" then
				coseColor2 = tocolor(222, 22, 22)
			else
				coseColor2 = tocolor(181, 16, 16)
			end

			dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/call.png"), 0, 0, 0, coseColor2)
			buttons["declineCalling"] = {phonePosX + 117, phonePosY + 405, resp(45), resp(52)}
			--dxDrawRectangle(phonePosX + 117, phonePosY + 405, resp(45), resp(52), tocolor(255, 255, 255, 125))
		-- ** Telefonálás
		elseif currentPage == "chatCall" then
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(0, 0, 0, 180))
			drawTaskbar()
			drawFakeInput("callChatMsg", "normal|20", "Üzenet", phonePosX + resp(20), phonePosY + resp(390), resp(240), resp(30), tocolor(45, 45, 45, 200), tocolor(255, 255, 255), 0.75, RobotoFont, tocolor(100, 100, 100))
			
			local coseColor
			if activeButton == "endCall" then
				coseColor = tocolor(222, 22, 22)
			else
				coseColor = tocolor(181, 16, 16)
			end
			
			dxDrawImage(phonePosX, phonePosY + 20, resp(280), resp(512), processPhoneTexture("files/call.png"), 0, 0, 0, coseColor)
			buttons["endCall"] = {phonePosX + 117, phonePosY + 425, resp(45), resp(52)}
					
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(50), resp(260), resp(50), tocolor(25, 25, 25, 175))
			
			dxDrawText(currentCallMemberName, phonePosX + resp(25), phonePosY + resp(50), phonePosX + resp(50), 0, tocolor(255, 255, 255), 1, RobotoFont, "left", "top")
			dxDrawText(currentCallMemberNumber, phonePosX + resp(25), phonePosY + resp(80), phonePosX + resp(57), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "top")

			local callMSGCounter = 0
			for k, v in ipairs(callMessages) do
				if k >= currentCallMSG then
					if k <= (currentCallMSG + (7-1)) and v then
						callY = phonePosY + 130 + (callMSGCounter) * 35

						if tonumber(v[2]) == myPhoneNum then
							local textWidth = dxGetTextWidth(v[1], 1, Roboto14)
							dxDrawRoundedRectangle(phonePosX + 260 - textWidth - 15, callY - 5, textWidth + 10, resp(20), 5, tocolor(255, 148, 40, 220), "outer", tocolor(255, 148, 40, 220), false, false)
							dxDrawText(v[1], phonePosX - 10 + 260, callY - 3, phonePosX - 10 + 260, 50, tocolor(255, 255, 255), 1, Roboto14, "right", "top")						
						else
							local textWidth = dxGetTextWidth(v[1], scale, Roboto14)
							dxDrawRoundedRectangle(phonePosX + 20, callY - 5, textWidth + 10, resp(20), 5, tocolor(45, 45, 45, 220), "outer", tocolor(45, 45, 45, 220), false, false)
							dxDrawText(v[1], phonePosX + 25, callY - 3, 200, 50, tocolor(255, 255, 255), 1, Roboto14, "left", "top")
						end

						callMSGCounter = callMSGCounter + 1
					end
				end
			end
		-- ** Főképernyő
		elseif currentPage == "home" then
			drawTaskbar()
			drawBaseButtons()

			-- elválasztó
			dxDrawRectangle(phonePosX + resp(179), phonePosY + resp(83), 1, resp(67), tocolor(200, 200, 200))

			-- idő/dátum/pozíció
			dxDrawText(replaceDynamicText("#currenttime"), 0, phonePosY + resp(71), phonePosX + resp(168), 0, tocolor(255, 255, 255), 0.85, RobotoFontLighter, "right", "top")

			dxDrawText(replaceDynamicText("#currentdatefull"), 0, phonePosY + resp(125), phonePosX + resp(168), 0, tocolor(255, 255, 255), 0.53, RobotoFont, "right", "top")

			local mapMarkerSize = resp(14)

			dxDrawImage(math.floor(phonePosX + resp(168) - mapMarkerSize), math.floor(phonePosY + resp(140)), mapMarkerSize, mapMarkerSize, processPhoneTexture("files/mapmarker.png"))

			dxDrawText(replaceDynamicText("#currentcity"), 0, phonePosY + resp(140), phonePosX + resp(168) - mapMarkerSize, 0, tocolor(255, 255, 255), 0.53, RobotoFont, "right", "top")

			-- hőmérséklet/időjárás
			dxDrawImage(math.floor(phonePosX + resp(193)), math.floor(phonePosY + resp(85)), resp(26), resp(26), processPhoneTexture("files/cloud.png"))

		--	dxDrawText(math.floor(weatherData[1] * 10) / 10 .. "°", phonePosX + resp(191), phonePosY + resp(108), 0, 0, tocolor(255, 255, 255), 0.48, RobotoFontLighter, "left", "top")

		--	dxDrawText(utf8.lower(weatherData[2]), phonePosX + resp(191), phonePosY + resp(140), 0, 0, tocolor(255, 255, 255), 0.53, RobotoFont, "left", "top")

			-- applikációk
			local firstPosX = phonePosX + resp(27)
			local appStartPosX, appStartPosY = firstPosX, phonePosY + resp(380)

			for i=1,#apps do
				if i % 5 == 0 then
					appStartPosX = firstPosX
					appStartPosY = appStartPosY - resp(65)
				end

				dxDrawImage(math.floor(appStartPosX), math.floor(appStartPosY), resp(36), resp(36), processPhoneTexture("files/apps/" .. apps[i][1]))

				dxDrawText(apps[i][3], appStartPosX, appStartPosY + resp(40), appStartPosX + resp(36), 0, tocolor(255, 255, 255), 0.45, RobotoFont, "center", "top")

				buttons[apps[i][2]] = {appStartPosX, appStartPosY, resp(36), resp(36)}

				appStartPosX = appStartPosX + resp(64)
			end
		-- ** Beállítások
		elseif currentPage == "settings" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Beállítások", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")

			-- elválasztó
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(80), resp(260), resp(2), tocolor(50, 50, 50))

			-- menü elemek
			local oneSize = (resp(432) - resp(25) - resp(32)) / setNum

			for i=1,setNum do
				local x = phonePosX + resp(10)
				local y = phonePosY + resp(82) + (i-1) * oneSize

				if i % 2 == 0 then
					dxDrawRectangle(x, y, resp(260), oneSize, tocolor(0, 0, 0, 25))
				else
					dxDrawRectangle(x, y, resp(260), oneSize, tocolor(0, 0, 0, 50))
				end

				local set = settings[i + offsetSet]

				if set then
					local pictureSize = oneSize * 0.75

					dxDrawImage(math.floor(x + oneSize / 2 - pictureSize / 2), math.floor(y + oneSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/" .. set[1]), 0, 0, 0, tocolor(255, 148, 40))
				
					dxDrawText(set[3], x + oneSize, y, x + resp(260), y + oneSize, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "center")

					if activeButton == set[2] then
						dxDrawImage(math.floor(x + resp(260) - pictureSize), math.floor(y + oneSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/arrow.png"), 0, 0, 0, tocolor(255, 148, 40))
					else
						dxDrawImage(math.floor(x + resp(260) - pictureSize), math.floor(y + oneSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/arrow.png"), 0, 0, 0, tocolor(255, 255, 255, 50))
					end
				
					buttons[set[2]] = {x, y, resp(260), oneSize}
				end
			end
		-- ** Háttérkép beállítása
		elseif currentPage == "changewallpaper" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Háttérkép beállítása", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")

			-- elválasztó
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(80), resp(260), resp(2), tocolor(50, 50, 50))

			-- change wallpaper
			local y =  phonePosY + resp(82)

			dxDrawRectangle(phonePosX + resp(10),y, resp(260), respc(40), tocolor(0, 0, 0, 25))

			dxDrawText("Háttérkép kiválasztása", phonePosX + resp(20), y, 0, y + respc(40), tocolor(255, 255, 255), 0.6, RobotoFont, "left", "center")

			if activeButton == "changepage:selectwallpaper" then
				dxDrawImage(math.floor(phonePosX + resp(270) - respc(30)), math.floor(y + respc(40) / 2 - respc(30) / 2), respc(30), respc(30), processPhoneTexture("files/arrow.png"), 0, 0, 0, tocolor(255, 148, 40))
			else
				dxDrawImage(math.floor(phonePosX + resp(270) - respc(30)), math.floor(y + respc(40) / 2 - respc(30) / 2), respc(30), respc(30), processPhoneTexture("files/arrow.png"), 0, 0, 0, tocolor(255, 255, 255, 50))
			end

			buttons["changepage:selectwallpaper"] = {phonePosX + resp(10), y, resp(260), respc(40)}

			-- random wallpaper
			y = y + respc(40)

			dxDrawRectangle(phonePosX + resp(10), y, resp(260), respc(40), tocolor(0, 0, 0, 50))

			dxDrawText("Háttérkép véletlenszerű cseréje", phonePosX + resp(20), y, 0, y + respc(40), tocolor(255, 255, 255), 0.575, RobotoFont, "left", "center")
		
			drawButtonSlider("randomwallpaper", randomWallpaperMode, phonePosX + resp(265) - resp(64), y + respc(40) / 2 - resp(28) / 2, resp(28), {75, 75, 75}, {75, 75, 75}, {255, 148, 40})
		-- ** Háttérkép kiválasztása
		elseif currentPage == "selectwallpaper" then
			-- háttérkép
			if selectedWallpaper ~= currentWallpaper then
				dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/wallpapers/" .. selectedWallpaper .. ".png"))
			end

			drawBaseButtons()

			-- fade effekt
			dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/fade.png"))

			-- cím
			dxDrawText("Háttérkép beállítása", phonePosX, phonePosY + resp(40), phonePosX + resp(280), 0, tocolor(255, 255, 255), 0.75, RobotoFont, "center", "top")

			-- mégsem
			if activeButton == "closeSelectWallpaper" then
				dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(phonePosY + resp(40)), resp(20), resp(20), processPhoneTexture("files/x.png"), 0, 0, 0, tocolor(215, 89, 89))
			else
				dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(phonePosY + resp(40)), resp(20), resp(20), processPhoneTexture("files/x.png"))
			end
			buttons["closeSelectWallpaper"] = {phonePosX + resp(20) - resp(5), phonePosY + resp(40) - resp(5), resp(30), resp(30)}

			-- mentés
			if activeButton == "saveSelectWallpaper" then
				dxDrawImage(math.floor(phonePosX + resp(240)), math.floor(phonePosY + resp(40)), resp(20), resp(20), processPhoneTexture("files/check.png"), 0, 0, 0, tocolor(255, 148, 40))
			else
				dxDrawImage(math.floor(phonePosX + resp(240)), math.floor(phonePosY + resp(40)), resp(20), resp(20), processPhoneTexture("files/check.png"))
			end
			buttons["saveSelectWallpaper"] = {phonePosX + resp(240) - resp(5), phonePosY + resp(40) - resp(5), resp(30), resp(30)}

			-- képek
			local oneSize = (resp(260) - resp(10) - resp(10) * 4) / 4

			for i=1,4 do
				local wp = i + offsetWallpaper

				if wp then
					local x = phonePosX + resp(10) + (i-1) * oneSize + i * resp(10)
					local y = phonePosY + resp(427) - oneSize

					dxDrawImageSection(x, y, oneSize, oneSize, 280 / 2 - 128 / 2, 512 / 2 - 128 / 2, 128, 128, processPhoneTexture("files/wallpapers/" .. wp .. ".png"))

					if activeButton == "viewWallpaper:" .. i + offsetWallpaper then
						dxDrawRectangle(x, y, oneSize, oneSize, tocolor(0, 0, 0, 125))
					end

					if selectedWallpaper == wp then
						dxDrawRectangle(x - resp(2), y - resp(2), oneSize + resp(4), resp(2), tocolor(255, 148, 40)) -- teteje
						dxDrawRectangle(x - resp(2), y + oneSize, oneSize + resp(4), resp(2), tocolor(255, 148, 40)) -- alja
						dxDrawRectangle(x - resp(2), y, resp(2), oneSize, tocolor(255, 148, 40)) -- bal
						dxDrawRectangle(x + oneSize, y, resp(2), oneSize, tocolor(255, 148, 40)) -- jobb
					else
						dxDrawRectangle(x - resp(2), y - resp(2), oneSize + resp(4), resp(2), tocolor(75, 75, 75)) -- teteje
						dxDrawRectangle(x - resp(2), y + oneSize, oneSize + resp(4), resp(2), tocolor(75, 75, 75)) -- alja
						dxDrawRectangle(x - resp(2), y, resp(2), oneSize, tocolor(75, 75, 75)) -- bal
						dxDrawRectangle(x + oneSize, y, resp(2), oneSize, tocolor(75, 75, 75)) -- jobb

						buttons["viewWallpaper:" .. i + offsetWallpaper] = {x, y, oneSize, oneSize}
					end
				end
			end

			-- infó
			dxDrawText("A lapozáshoz használd a görgőt", phonePosX, phonePosY + resp(340), phonePosX + resp(280), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "center", "top")	
		-- ** Névjegyzék
		elseif currentPage == "contacts" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Névjegyek", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")

			-- elválasztó
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(80), resp(260), resp(2), tocolor(50, 50, 50))

			-- új névjegy hozzáadása
			if activeButton == "changepage:addcontact" then
				dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/addcontacthover.png"))
			else
				dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/addcontact.png"))
			end
			buttons["changepage:addcontact"] = {phonePosX + resp(111), phonePosY + resp(423), resp(55), resp(28)}

			-- menü elemek
			local oneSize = (resp(432) - resp(32) - resp(60)) / contactNum
			local pictureSize = oneSize * 0.75

			if #contacts < 1 then
				dxDrawText("Nincsenek hozzáadott névjegyeid.", phonePosX + resp(25), phonePosY + resp(85), 0, 0, tocolor(150, 150, 150, 150), 0.6, RobotoFont, "left", "top")
			else
				for i=1,contactNum do
					local x = phonePosX + resp(10)
					local y = phonePosY + resp(80) + (i-1) * oneSize

					local contact = contacts[i + offsetContact]

					if contact then
						if i + offsetContact ~= contactNum + offsetContact then
							dxDrawRectangle(x + resp(10), y + oneSize, resp(240), 1, tocolor(50, 50, 50))
						end

						dxDrawRectangle(x + resp(15), y + oneSize / 2 - pictureSize / 2, pictureSize, pictureSize, contact[3])
						
						dxDrawText(utf8.upper(utf8.sub(contact[1], 1, 1)), x + resp(15), y + oneSize / 2 - pictureSize / 2, x + resp(15) + pictureSize, y + oneSize / 2 + pictureSize / 2, tocolor(255, 255, 255), 0.75, RobotoFont, "center", "center")

						if activeButton == "selectcontact:" .. i then
							dxDrawText(contact[1], x + resp(15) + pictureSize + resp(5), y, x + resp(255) - pictureSize, y + oneSize, tocolor(255, 148, 40), 0.6, RobotoFont, "left", "center", true)
						else
							dxDrawText(contact[1], x + resp(15) + pictureSize + resp(5), y, x + resp(255) - pictureSize, y + oneSize, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "center", true)
						end
						
						if activeButton == "deletecontact:" .. i then
							dxDrawImage(math.floor(x + resp(250) - pictureSize), math.floor(y + oneSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/x.png"), 0, 0, 0, tocolor(215, 89, 89))
						else
							dxDrawImage(math.floor(x + resp(250) - pictureSize), math.floor(y + oneSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/x.png"), 0, 0, 0, tocolor(150, 150, 150, 150))
							
							buttons["selectcontact:" .. i] = {x + resp(10), y, resp(250) - pictureSize, oneSize}
						end

						buttons["deletecontact:" .. i] = {x + resp(250) - pictureSize, y + oneSize / 2 - pictureSize / 2, pictureSize, pictureSize}
					end
				end
			end

			if #contacts > contactNum then
				local totalSize = oneSize * contactNum

				dxDrawRectangle(phonePosX + resp(260), phonePosY + resp(80), respc(5), totalSize, tocolor(25, 25, 25))

				dxDrawRectangle(phonePosX + resp(260), phonePosY + resp(80) + (totalSize / #contacts) * offsetContact, respc(5), (totalSize / #contacts) * contactNum, tocolor(255, 148, 40))
			end
		-- ** Új névjegy
		elseif currentPage == "addcontact" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Új névjegy", phonePosX, phonePosY + resp(52), phonePosX + resp(280), 0, tocolor(255, 255, 255), 0.375, RobotoFontLighter, "center", "top")

			-- mégsem
			if activeButton == "changepage:contacts" then
				dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(phonePosY + resp(57)), resp(20), resp(20), processPhoneTexture("files/x.png"), 0, 0, 0, tocolor(215, 89, 89))
			else
				dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(phonePosY + resp(57)), resp(20), resp(20), processPhoneTexture("files/x.png"))
			end
			buttons["changepage:contacts"] = {phonePosX + resp(20) - resp(5), phonePosY + resp(57) - resp(5), resp(30), resp(30)}

			-- mentés
			if activeButton == "addcontact" then
				dxDrawImage(math.floor(phonePosX + resp(240)), math.floor(phonePosY + resp(57)), resp(20), resp(20), processPhoneTexture("files/check.png"), 0, 0, 0, tocolor(255, 148, 40))
			else
				dxDrawImage(math.floor(phonePosX + resp(240)), math.floor(phonePosY + resp(57)), resp(20), resp(20), processPhoneTexture("files/check.png"))
			end
			buttons["addcontact"] = {phonePosX + resp(240) - resp(5), phonePosY + resp(57) - resp(5), resp(30), resp(30)}

			-- név mező
			drawFakeInput("addContactName", "normal|40", "Név", phonePosX + resp(20), phonePosY + resp(100), resp(240), resp(40), false, tocolor(255, 255, 255), 0.75, RobotoFont, tocolor(100, 100, 100))

			if getActiveFakeInput() == "addContactName" then
				dxDrawRectangle(phonePosX + resp(20), phonePosY + resp(100) + resp(40), resp(240), resp(2), tocolor(255, 148, 40, 125))
			else
				dxDrawRectangle(phonePosX + resp(20), phonePosY + resp(100) + resp(40), resp(240), resp(2), tocolor(80, 80, 80, 80))
			end

			-- telefonszám mező
			drawFakeInput("addContactNum", "num-only|16", "Telefonszám", phonePosX + resp(20), phonePosY + resp(180), resp(240), resp(40), false, tocolor(255, 255, 255), 0.75, RobotoFont, tocolor(100, 100, 100))

			if getActiveFakeInput() == "addContactNum" then
				dxDrawRectangle(phonePosX + resp(20), phonePosY + resp(180) + resp(40), resp(240), resp(2), tocolor(255, 148, 40, 125))
			else
				dxDrawRectangle(phonePosX + resp(20), phonePosY + resp(180) + resp(40), resp(240), resp(2), tocolor(80, 80, 80, 80))
			end
		-- ** Névjegy megtekintése
		elseif currentPage == "viewcontact" and selectedContact and contacts[selectedContact] then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452) / 2, contacts[selectedContact][3]) -- teteje

			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30) + resp(452) / 2, resp(260), resp(452) / 2, tocolor(15, 15, 15, 240)) -- alja

			dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/fade.png"))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText(contacts[selectedContact][1] .. "\n" .. contacts[selectedContact][2], phonePosX + resp(22), phonePosY + resp(201), phonePosX + resp(248), phonePosY + resp(266), tocolor(255, 255, 255), 0.375, RobotoFontLighter, "left", "top", true)

			-- vissza gomb
			if activeButton == "changepage:contacts" then
				dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(phonePosY + resp(57)), resp(20), resp(20), processPhoneTexture("files/arrow2.png"), 0, 0, 0, tocolor(255, 148, 40))
			else
				dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(phonePosY + resp(57)), resp(20), resp(20), processPhoneTexture("files/arrow2.png"))
			end
			buttons["changepage:contacts"] = {phonePosX + resp(20) - resp(5), phonePosY + resp(57) - resp(5), resp(30), resp(30)}

			-- tárcsázás
			local y = phonePosY + resp(452) / 2 + resp(45)
			local holderSize = resp(40)
			local pictureSize = holderSize * 0.6

			dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(y + holderSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/phone_icon.png"), 0, 0, 0, tocolor(180, 180, 180, 180))

			dxDrawText("Tárcsázás", phonePosX + resp(30) + pictureSize, y, 0, y + holderSize, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "center")


			dxDrawRectangle(phonePosX + resp(20), y + holderSize, resp(240), 1, tocolor(50, 50, 50))

			buttons["viewCall"] = {phonePosX + resp(20), y + holderSize -40, resp(240),  resp(40)}

			dxDrawImage(math.floor(phonePosX + resp(270) - respc(30)), math.floor(y + holderSize / 2 - resp(24) / 2), respc(24), respc(24), processPhoneTexture("files/arrow.png"), 0, 0, 0, tocolor(255, 255, 255, 50))
			
			-- sms
			y = y + holderSize

			dxDrawImage(math.floor(phonePosX + resp(20)), math.floor(y + holderSize / 2 - pictureSize / 2), pictureSize, pictureSize, processPhoneTexture("files/comment_icon.png"), 0, 0, 0, tocolor(180, 180, 180, 180))

			dxDrawText("Üzenet küldés", phonePosX + resp(30) + pictureSize, y, 0, y + holderSize, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "center")

			dxDrawRectangle(phonePosX + resp(20), y + holderSize, resp(240), 1, tocolor(50, 50, 50))

			dxDrawImage(math.floor(phonePosX + resp(270) - respc(30)), math.floor(y + holderSize / 2 - resp(24) / 2), respc(24), respc(24), processPhoneTexture("files/arrow.png"), 0, 0, 0, tocolor(255, 255, 255, 50))
		-- ** Tárcsázó
		elseif currentPage == "phone" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			-- input
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(70), tocolor(25, 25, 25))
			drawFakeInput("callPhoneNum", "num-only|16|", false, phonePosX + resp(20), phonePosY + resp(50), resp(240), resp(50), false, tocolor(255, 255, 255), 1, RobotoFont, false, "center")
			activeFakeInput = "callPhoneNum|num-only|16"

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- hívás gomb
			dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/call.png"), 0, 0, 0, tocolor(124, 197, 118))
			buttons["dialNumber"] = {phonePosX + resp(118), phonePosY + resp(408), resp(44), resp(44)}

			-- számgombok
			for i=0,11 do
				if i ~= 9 then
					local x = phonePosX + resp(54) + (resp(44) + resp(20)) * (i % 3)
					local y = phonePosY + resp(210) + (resp(44) + resp(5)) * math.floor(i / 3)

					local num = i == 10 and "0" or tostring(1 + i)
					local colorOfHover = tocolor(255, 148, 40)

					if i == 11 then
						num = "X"
						colorOfHover = tocolor(215, 89, 89)
					end

					if activeButton == "injectFakeInput:callPhoneNum|num-only|16:" .. num then
						dxDrawImage(math.floor(x), math.floor(y), resp(44), resp(44), processPhoneTexture("files/numcircle.png"), 0, 0, 0, colorOfHover)

						dxDrawText(num, x, y, x + resp(44), y + resp(44), colorOfHover, 1, RobotoFont, "center", "center")
					else
						dxDrawImage(math.floor(x), math.floor(y), resp(44), resp(44), processPhoneTexture("files/numcircle.png"), 0, 0, 0, tocolor(150, 150, 150, 150))

						dxDrawText(num, x, y, x + resp(44), y + resp(44), tocolor(255, 255, 255), 1, RobotoFont, "center", "center")
					end

					buttons["injectFakeInput:callPhoneNum|num-only|16:" .. num] = {x, y, resp(44), resp(44)}
				end
			end
		-- ** Hirdetés
		elseif currentPage == "hirdetes" then
			if not fakeInputs["hirdetes"] then
				fakeInputs["hirdetes"] = ""
			end
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Hirdetés feladás", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")
			
			local coseColor
			
			if activeButton == "hirdetesKuldes" then
				coseColor = tocolor(255, 148, 40, 240)
			else
				coseColor = tocolor(168, 102, 35, 240)
			end
			
			local hirdsetkikapcsColor
			
			if activeButton == "hirdetesKikapcs" then
				hirdsetkikapcsColor = tocolor(255, 148, 40, 240)
			else
				hirdsetkikapcsColor = tocolor(168, 102, 35, 240)
			end
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 230, 240, 30, coseColor)
			buttons["hirdetesKuldes"] = {phonePosX + 20, phonePosY + 230, 240, 30}
			dxDrawText("Küldés", phonePosX + resp(105), phonePosY + resp(230), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 230 + 40, 240, 30, hirdsetkikapcsColor)
			buttons["hirdetesKikapcs"] = {phonePosX + 20, phonePosY + 230 + 40, 240, 30}
			if getElementData(localPlayer, "hiredetesbekapcsolva") then
				dxDrawText("Hirdetések kikapcsolása", phonePosX + resp(29), phonePosY + resp(230+40+2), 0, 0, tocolor(255, 255, 255), 0.36, RobotoFontLighter, "left", "top")
			else
				dxDrawText("Hirdetések bekapcsolása", phonePosX + resp(23.5), phonePosY + resp(230+40+2), 0, 0, tocolor(255, 255, 255), 0.36, RobotoFontLighter, "left", "top")
			end
			
			local telefonszamKikapcsColor
			
			if activeButton == "telefonszamKikapcs" then
				telefonszamKikapcsColor = tocolor(255, 148, 40, 240)
			else
				telefonszamKikapcsColor = tocolor(168, 102, 35, 240)
			end
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 230 + 80, 240, 30, telefonszamKikapcsColor)
			buttons["telefonszamKikapcs"] = {phonePosX + 20, phonePosY + 230 + 80, 240, 30}
			if getElementData(localPlayer, "telefonszambekapcsolva") then
				dxDrawText("Telefonszám kikapcsolása", phonePosX + resp(28), phonePosY + resp(230+80+4), 0, 0, tocolor(255, 255, 255), 0.34, RobotoFontLighter, "left", "top")
			else
				dxDrawText("Telefonszám bekapcsolása", phonePosX + resp(23.5), phonePosY + resp(230+80+4), 0, 0, tocolor(255, 255, 255), 0.34, RobotoFontLighter, "left", "top")
			end
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 100, 240, 100, tocolor(25, 25, 25, 240))
			buttons["setInput:hirdetes|normal|90"] = {phonePosX + 20, phonePosY + 100, 240, 100}
			
			if getActiveFakeInput() == "hirdetes" then
				if cursorState then
					dxDrawText(fakeInputs["hirdetes"].."|", phonePosX + 25, phonePosY + 105, phonePosX + 25 + 240 - 10, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				else
					dxDrawText(fakeInputs["hirdetes"], phonePosX + 25, phonePosY + 105, phonePosX + 25 + 240 - 10, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				end
				
				if getTickCount() - lastChangeCursorState >= 500 then
					cursorState = not cursorState
					lastChangeCursorState = getTickCount()
				end				
			else
				dxDrawText(fakeInputs["hirdetes"], phonePosX + 25, phonePosY + 105, phonePosX + 25 + 240 - 10, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
			end
			
		elseif currentPage == "darkHirdetes" then
			if not fakeInputs["hirdetes"] then
				fakeInputs["hirdetes"] = ""
			end
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Hirdetés feladás", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")
			
			local coseColor
			
			if activeButton == "hirdetesKuldes" then
				coseColor = tocolor(255, 148, 40, 240)
			else
				coseColor = tocolor(168, 102, 35, 240)
			end
			
			local hirdsetkikapcsColor
			
			if activeButton == "hirdetesKikapcs" then
				hirdsetkikapcsColor = tocolor(255, 148, 40, 240)
			else
				hirdsetkikapcsColor = tocolor(168, 102, 35, 240)
			end
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 230, 240, 30, coseColor)
			buttons["hirdetesKuldes"] = {phonePosX + 20, phonePosY + 230, 240, 30}
			dxDrawText("Küldés", phonePosX + resp(105), phonePosY + resp(230), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 230 + 40, 240, 30, hirdsetkikapcsColor)
			buttons["hirdetesKikapcs"] = {phonePosX + 20, phonePosY + 230 + 40, 240, 30}
			if getElementData(localPlayer, "hiredetesbekapcsolvaillegal") then
				dxDrawText("Hirdetések kikapcsolása", phonePosX + resp(29), phonePosY + resp(230+40+2), 0, 0, tocolor(255, 255, 255), 0.36, RobotoFontLighter, "left", "top")
			else
				dxDrawText("Hirdetések bekapcsolása", phonePosX + resp(23.5), phonePosY + resp(230+40+2), 0, 0, tocolor(255, 255, 255), 0.36, RobotoFontLighter, "left", "top")
			end
			
			local telefonszamKikapcsColor
			
			if activeButton == "telefonszamKikapcs" then
				telefonszamKikapcsColor = tocolor(255, 148, 40, 240)
			else
				telefonszamKikapcsColor = tocolor(168, 102, 35, 240)
			end
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 230 + 80, 240, 30, telefonszamKikapcsColor)
			buttons["telefonszamKikapcs"] = {phonePosX + 20, phonePosY + 230 + 80, 240, 30}
			if getElementData(localPlayer, "telefonszambekapcsolvaillegal") then
				dxDrawText("Telefonszám kikapcsolása", phonePosX + resp(28), phonePosY + resp(230+80+4), 0, 0, tocolor(255, 255, 255), 0.34, RobotoFontLighter, "left", "top")
			else
				dxDrawText("Telefonszám bekapcsolása", phonePosX + resp(23.5), phonePosY + resp(230+80+4), 0, 0, tocolor(255, 255, 255), 0.34, RobotoFontLighter, "left", "top")
			end
			
			dxDrawRectangle(phonePosX + 20, phonePosY + 100, 240, 100, tocolor(25, 25, 25, 240))
			buttons["setInput:hirdetes|normal|90"] = {phonePosX + 20, phonePosY + 100, 240, 100}
			
			if getActiveFakeInput() == "hirdetes" then
				if cursorState then
					dxDrawText(fakeInputs["hirdetes"].."|", phonePosX + 25, phonePosY + 105, phonePosX + 25 + 240 - 10, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				else
					dxDrawText(fakeInputs["hirdetes"], phonePosX + 25, phonePosY + 105, phonePosX + 25 + 240 - 10, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				end
				
				if getTickCount() - lastChangeCursorState >= 500 then
					cursorState = not cursorState
					lastChangeCursorState = getTickCount()
				end				
			else
				dxDrawText(fakeInputs["hirdetes"], phonePosX + 25, phonePosY + 105, phonePosX + 25 + 240 - 10, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
			end		
		elseif currentPage == "messages" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			-- cím
			dxDrawText("Üzenetek", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")
			
			-- új sms hozzáadása
			if activeButton == "changepage:addmessages" then
				dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/addmessageshover.png"))
			else
				dxDrawImage(phonePosX, phonePosY, resp(280), resp(512), processPhoneTexture("files/addmessages.png"))
			end
			buttons["changepage:addmessages"] = {phonePosX + resp(111), phonePosY + resp(423), resp(55), resp(28)}
		
			
			-- menü elemek
			local oneSize = (resp(432) - resp(32) - resp(30)) / messagesNum 
			
			if #messages < 1 then
				dxDrawText("Nincsenek üzeneteid.", phonePosX + resp(25), phonePosY + resp(85), 0, 0, tocolor(150, 150, 150, 150), 0.6, RobotoFont, "left", "top")			
			else
				for i = 1, messagesNum do
					local x = phonePosX + resp(10)
					local y = phonePosY + resp(80) + (i-1) * oneSize
					
					local ms = messages[i + offsetMessages]
					if ms then
						if activeButton == "selectmessage:"..i then
							dxDrawRoundedRectangle(x + 10, y + 10, 238, 40, 5, tocolor(255, 148, 40), "outer", tocolor(255, 148, 40), false, false)
						else
							dxDrawRoundedRectangle(x + 10, y + 10, 238, 40, 5, tocolor(45, 45, 45, 220), "outer", tocolor(45, 45, 45, 220), false, false)
						end
						local name, numi = checkNumberInContactList(messages[i + offsetMessages][1])
						
						if name == "Ismeretlen" then
							dxDrawText(name, x + resp(10), y + oneSize / 2, x + resp(10), y + oneSize / 2, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")
							dxDrawText(numi, x + resp(10), y + oneSize / 2 + 35, x + resp(10), y + oneSize / 2, tocolor(255, 255, 255), 0.75, Roboto14, "left", "center")
						else
							dxDrawText(name, x + resp(10), y + oneSize / 2, x + resp(10), y + oneSize / 2, tocolor(255, 255, 255), 0.75, RobotoFont, "left", "center")
							dxDrawText(numi, x + resp(10), y + oneSize / 2 + 35, x + resp(10), y + oneSize / 2, tocolor(255, 255, 255), 0.75, Roboto14, "left", "center")
						end
						buttons["selectmessage:"..i] = {x + 10, y + 10, 238, 40}
					end
				end
			end
		elseif currentPage == "addmessages" then
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			--dxDrawRectangle( phonePosX + resp(20), phonePosY + resp(360), resp(240), resp(80), tocolor(45, 45, 45, 200))
			
			-- cím
			dxDrawText("Üzenet kezdeményezés", phonePosX + resp(21), phonePosY + resp(52), 0, 0, tocolor(255, 255, 255), 0.4, RobotoFontLighter, "left", "top")	
			
			local color = tocolor(255, 255, 255, 255)
			
			if activeButton == "newSendBtn" then
				color = tocolor(255, 148, 40, 255)
			else
				color = tocolor(255, 255, 255, 255)
			end
			
			drawFakeInput("messageNumber", "num-only|16", "Telefonszám", phonePosX + resp(20), phonePosY + resp(100), resp(240), resp(40), tocolor(45, 45, 45, 200), tocolor(255, 255, 255), 0.75, RobotoFont, tocolor(100, 100, 100))			
			dxDrawImage(phonePosX + 230, phonePosY + 108, resp(22), resp(22), processPhoneTexture("files/nyil.png"), 0, 0, 0, color)
			buttons["newSendBtn"] = {phonePosX + 230, phonePosY + 108, 22, 22}
		elseif currentPage == "emptyMessage" then
			if not fakeInputs["sms"] then
				fakeInputs["sms"] = ""
			end
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			dxDrawRectangle( phonePosX + resp(20), phonePosY + resp(360), resp(240), resp(80), tocolor(45, 45, 45, 200))
			buttons["setInput:sms|normal|100"] = {phonePosX + resp(20), phonePosY + resp(360), resp(240), resp(80)}
			
			if getActiveFakeInput() == "sms" then
				if cursorState then
					dxDrawText(fakeInputs["sms"] .. "|", phonePosX + 25, phonePosY + 365, phonePosX + 25 + 200, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				else
					dxDrawText(fakeInputs["sms"], phonePosX + 25, phonePosY + 365, phonePosX + 25 + 200, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				end
				
				if getTickCount() - lastChangeCursorState >= 500 then
					cursorState = not cursorState
					lastChangeCursorState = getTickCount()
				end				
			else
				dxDrawText(fakeInputs["sms"], phonePosX + 25, phonePosY + 365, phonePosX + 25 + 200, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
			end	
			
			local color = tocolor(255, 255, 255, 255)
			
			if activeButton == "idgSMSButton" then
				color = tocolor(255, 148, 40, 255)
			else
				color = tocolor(255, 255, 255, 255)
			end			
			dxDrawImage(phonePosX + 230, phonePosY + 365, resp(22), resp(22), processPhoneTexture("files/nyil.png"), 0, 0, 0, color)
		
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(50), resp(260), resp(50), tocolor(25, 25, 25, 175))
			dxDrawText(currentCallMemberName, phonePosX + resp(25), phonePosY + resp(50), phonePosX + resp(50), 0, tocolor(255, 255, 255), 1, RobotoFont, "left", "top")
			dxDrawText(currentCallMemberNumber, phonePosX + resp(25), phonePosY + resp(80), phonePosX + resp(57), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "top")
			
			buttons["idgSMSButton"] = {phonePosX + 230, phonePosY + 365, resp(22), resp(22)}
		
		elseif currentPage == "viewMessage" and selectedMessage and messages[selectedMessage] then
			if not fakeInputs["sms"] then
				fakeInputs["sms"] = ""
			end
			-- háttér
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(30), resp(260), resp(452), tocolor(15, 15, 15, 240))

			drawTaskbar()
			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(457), resp(260), resp(25), tocolor(25, 25, 25, 75))
			drawBaseButtons()

			dxDrawRectangle(phonePosX + resp(10), phonePosY + resp(50), resp(260), resp(50), tocolor(25, 25, 25, 175))
			dxDrawText(currentCallMemberName, phonePosX + resp(25), phonePosY + resp(50), phonePosX + resp(50), 0, tocolor(255, 255, 255), 1, RobotoFont, "left", "top")
			dxDrawText(currentCallMemberNumber, phonePosX + resp(25), phonePosY + resp(80), phonePosX + resp(57), 0, tocolor(255, 255, 255), 0.6, RobotoFont, "left", "top")

			local lineSpace = 0
			local minus = 0

			if smsRenderTarget then
				dxSetRenderTarget(smsRenderTarget, true)
				for k, v in ipairs(table.reverse(messages[selectedMessage])) do
					if type(v) == "table" and v[1] and v[2] then
						
						local textWidth = dxGetTextWidth(v[1], 1, Roboto14)
						
						if textWidth >= 130 then
							textWidth = 130
							minus = 0
						else
							minus = 5
						end
						
						local fontHeight = dxGetFontHeight(1, Roboto14)
						local height = calculateRows(v[1], Roboto14, 1, textWidth + minus) * (fontHeight)
						
						lineSpace = lineSpace + height + 20
						
						lineY = lineSpace
						
						
						if v[2] == myPhoneNum then
							dxDrawRoundedRectangle(260 - textWidth - 10, moveY + 250 - lineY, textWidth +10, height, 5, tocolor(255, 148, 40, 220), "outer", tocolor(255, 148, 40, 220), false, false)
							dxDrawText(v[1], 260 - textWidth - 7, moveY + 250 - lineY, (260 - textWidth - 7)+textWidth, 0, tocolor(255, 255, 255, 255), 1, Roboto14, nil, nil, false, true)
						else
							dxDrawRoundedRectangle(26 ,  moveY + 250 - lineY, textWidth +10, height, 5, tocolor(45, 45, 45, 220), "outer", tocolor(45, 45, 45, 220), false, false)
							dxDrawText(v[1], 26, moveY + 250 - lineY, 26+textWidth, 0, tocolor(255, 255, 255, 255), 1, Roboto14, nil, nil, false, true)
						end
					end
				end
				dxSetRenderTarget()
				dxDrawImage(phonePosX, phonePosY+110, 270, 240, smsRenderTarget)
				--dxDrawRectangle(phonePosX, phonePosY+110, 270, 240, tocolor(255, 255, 255, 125))
			end
						
			dxDrawRectangle( phonePosX + resp(20), phonePosY + resp(360), resp(240), resp(80), tocolor(45, 45, 45, 200))
			buttons["setInput:sms|normal|100"] = {phonePosX + resp(20), phonePosY + resp(360), resp(240), resp(80)}
			
			if getActiveFakeInput() == "sms" then
				if cursorState then
					dxDrawText(fakeInputs["sms"] .."|", phonePosX + 25, phonePosY + 365, phonePosX + 25 + 200, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				else
					dxDrawText(fakeInputs["sms"], phonePosX + 25, phonePosY + 365, phonePosX + 25 + 200, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
				end
				
				if getTickCount() - lastChangeCursorState >= 500 then
					cursorState = not cursorState
					lastChangeCursorState = getTickCount()
				end				
			else
				dxDrawText(fakeInputs["sms"], phonePosX + 25, phonePosY + 365, phonePosX + 25 + 200, 0, tocolor(255, 255, 255, 255), 1, Roboto14, "left", "top", false, true)
			end
						
			local color = tocolor(255, 255, 255, 255)
			
			if activeButton == "smsSend" then
				color = tocolor(255, 148, 40, 255)
			else
				color = tocolor(255, 255, 255, 255)
			end
			
			dxDrawImage(phonePosX + 230, phonePosY + 365, resp(22), resp(22), processPhoneTexture("files/nyil.png"), 0, 0, 0, color)
			buttons["smsSend"] = {phonePosX + 230, phonePosY + 365, resp(22), resp(22)}
		end

		local cursorX, cursorY = getCursorPosition()

		activeButton = false

		if cursorX and cursorY then
			cursorX = cursorX * screenX
			cursorY = cursorY * screenY

			for k, v in pairs(buttons) do
				--dxDrawRectangle(v[1], v[2], v[3], v[4], tocolor(127, 0, 0, 127))

				if cursorX >= v[1] and cursorX <= v[1] + v[3] and cursorY >= v[2] and cursorY <= v[2] + v[4] then
					activeButton = k
				end
			end
		end
	end
end

function table.reverse(t) 
    local reversedTable = {} 
    local itemCount = #t  
    for k, v in ipairs(t) do 
        reversedTable[itemCount + 1 - k] = v  
    end 
    return reversedTable  
end 

function calculateRows(text, font, fontSize, rectangeWidth)
	local line_text = ""
	local line_count = 1
	
	for word in text:gmatch("%S+") do
		local temp_line_text = line_text .. " " .. word
		
		local temp_line_width = dxGetTextWidth(temp_line_text, fontSize, font)
		if temp_line_width >= rectangeWidth then
			line_text = word
			line_count = line_count + 1
		else
			line_text = temp_line_text
		end
	end
	
	return line_count
end

function getFitFontScale(text, scale, font, maxwidth)
	local scaleex = scale

	if dxGetTextWidth(text, scaleex, font) > maxwidth then
		while dxGetTextWidth(text, scaleex, font) > maxwidth do
			scaleex = scaleex - 0.01
		end
	end

	return scaleex
end

function drawFakeInput(name, properties, label, x, y, sx, sy, bgColor, textColor, fontScale, font, labelColor, alignX)
	if not fakeInputs[name] then
		fakeInputs[name] = ""
	end

	if bgColor then
		dxDrawRectangle(x, y, sx, sy, bgColor)
	end

	local activeInput = getActiveFakeInput()

	alignX = alignX or "left"

	local scale = fontScale

	if utf8.len(fakeInputs[name]) > 0 then
		scale = getFitFontScale(fakeInputs[name], fontScale, font, sx - resp(20))

		dxDrawText(fakeInputs[name], x + resp(10), y, x + sx - resp(10), y + sy, textColor, scale, font, alignX, "center", false, true)
	elseif label and activeInput ~= name then
		scale = getFitFontScale(label, fontScale, font, sx - resp(20))

		dxDrawText(label, x + resp(10), y, x + sx - resp(10), y + sy, labelColor or textColor, scale, font, alignX, "center", false, true)
	end

	if activeInput == name and alignX == "left" then
		dxDrawRectangle(x + resp(10) + dxGetTextWidth(fakeInputs[name], scale, font) + resp(2), y + resp(5), resp(2), sy - resp(10), textColor)
	end

	buttons["setInput:" .. name .. "|" .. properties] = {x, y, sx, sy}
end

function replaceDynamicText(text)
	if text == "#currenttime" then
		local time = getRealTime()

		text = string.format("%02d:%02d", time.hour, time.minute)
	elseif text == "#currentdate" then
		local time = getRealTime()

		text = utf8.lower(monthNames[time.month]:sub(1, 4)) .. " " .. time.monthday .. ", " .. dayNames[time.weekday]:sub(1, 3)
	elseif text == "#currentdatefull" then
		local time = getRealTime()

		text = utf8.lower(monthNames[time.month]) .. " " .. time.monthday .. "., " .. dayNames[time.weekday]
	elseif text == "#currentcity" then
		local x, y, z = getElementPosition(localPlayer)

		return getZoneNameEx(x, y, z, true)
	end

	return text
end

function processPhoneTexture(path)
	if isElement(textures[path]) then
		return textures[path]
	elseif not textures[path] then
		textures[path] = dxCreateTexture(path, "argb", true, "clamp")
	end

	return textures[path]
end

function commandHandler(command)
	command = split(command, ":")

	if command[1] == "changepage" then
		currentPage = command[2]

		activeFakeInput = false
		fakeInputs = {}

		if currentPage == "changewallpaper" then
			selectedWallpaper = currentWallpaper
		end
	elseif command[1] == "unlockphone" then
		commandHandler("changepage:home")
	elseif command[1] == "declineCall" then
		commandHandler("changepage:home")
		triggerServerEvent("cancelledCallSend", localPlayer, localPlayer, callingMember)
	elseif command[1] == "acceptCall" then
		commandHandler("changepage:chatCall")
		triggerServerEvent("acceptCallServer", localPlayer, localPlayer, callingMember)
	elseif command[1] == "declineCalling" then
		commandHandler("changepage:home")
		triggerServerEvent("cancelledCallSend", localPlayer, localPlayer, callingMember)
	elseif command[1] == "chatSend" then
		if fakeInputs["callChatMsg"] == "" then return end
		triggerServerEvent("sendCallMessages", localPlayer, localPlayer, callingMember, fakeInputs["callChatMsg"], myPhoneNum)
		fakeInputs["callChatMsg"] = ""
		activeButton = nil
	elseif command[1] == "endCall" then
		triggerServerEvent("cancelledCallSend", localPlayer, localPlayer, callingMember)
		commandHandler("changepage:home")
		callMessages = {}
		currentCallMSG = -6
	elseif command[1] == "viewWallpaper" then
		local id = tonumber(command[2])

		selectedWallpaper = id
	elseif command[1] == "closeSelectWallpaper" then
		commandHandler("changepage:changewallpaper")
	elseif command[1] == "dialNumber" then
		if tonumber(fakeInputs["callPhoneNum"]) == tonumber(myPhoneNum) then
			exports.cosmo_hud:showInfobox("error", "Saját magadat nem hívhatod fel!")
			return
		else
			triggerServerEvent("callTargetInServer", localPlayer, localPlayer, fakeInputs["callPhoneNum"], myPhoneNum)
			currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(fakeInputs["callPhoneNum"])
		end
	elseif command[1] == "saveSelectWallpaper" then
		randomWallpaperMode = false

		currentWallpaper = selectedWallpaper

		commandHandler("changepage:home")
	elseif command[1] == "randomwallpaper" then
		randomWallpaperMode = not randomWallpaperMode

		if randomWallpaperMode then
			math.randomseed(getTickCount() + math.random(getTickCount()))

			currentWallpaper = math.random(wallpapersNum)
		end

		selectedWallpaper = currentWallpaper
	elseif command[1] == "addcontact" then
		if utf8.len(fakeInputs.addContactName) > 0 and utf8.len(fakeInputs.addContactNum) > 0 then
			if contactsEx[tonumber(fakeInputs.addContactNum)] then
				exports.cosmo_hud:showInfobox("error", "A kiválasztott telefonszámhoz már társítva van egy névjegy!")
				return
			end

			table.insert(contacts, {fakeInputs.addContactName, tonumber(fakeInputs.addContactNum), tocolor(pastelcolor(fakeInputs.addContactName))})
			table.sort(contacts, function(a, b) return a[1] > b[1] end)

			contactsEx = {}

			for i=1,#contacts do
				if contacts[i] then
					contactsEx[contacts[i][2]] = contacts[i][1]
				end
			end
			
			-- Frissítem a kontakt listát egyből
			triggerServerEvent("addContact", localPlayer, localPlayer, tonumber(fakeInputs.addContactNum), fakeInputs.addContactName, myPhoneNum)
			
			commandHandler("changepage:contacts")
		end
	elseif command[1] == "deletecontact" then
		local id = tonumber(command[2])

		if contacts[id + offsetContact] then
			local newcontacts = {}

			for i=1,#contacts do
				if contacts[i] and i ~= id + offsetContact then
					table.insert(newcontacts, contacts[i])
				end
			end

			triggerServerEvent("removeContact", localPlayer, localPlayer, contacts[id][2], myPhoneNum)

			contacts = newcontacts
			contactsEx = {}

			for i=1,#contacts do
				if contacts[i] then
					contactsEx[contacts[i][2]] = contacts[i][1]
				end
			end

			if #contacts > contactNum then
				if offsetContact > #contacts - contactNum then
					offsetContact = #contacts - contactNum
				end
			else
				offsetContact = 0
			end
		end
	elseif command[1] == "selectcontact" then
		local id = tonumber(command[2])

		if contacts[id + offsetContact] then
			selectedContact = id + offsetContact

			commandHandler("changepage:viewcontact")
		end
	elseif command[1] == "selectmessage" then
		local id = tonumber(command[2])
		
		if messages[id + offsetMessages] then
			selectedMessage = id + offsetMessages
			commandHandler("changepage:viewMessage")
			currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(messages[selectedMessage][1])
		end
	elseif command[1] == "viewCall" then
		currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(contacts[selectedContact][2])
		triggerServerEvent("callTargetInServer", localPlayer, localPlayer, contacts[selectedContact][2], myPhoneNum)
	elseif command[1] == "injectFakeInput" then
		if utf8.lower(command[3]) == "x" then
			processFakeInput("backspace", command[2])
		else
			processFakeInput(command[3], command[2])
		end
	elseif command[1] == "hirdetesKuldes" then
		if getTickCount() - hirdetesTick > 10000 then
			if currentPage == "hirdetes" then
				if fakeInputs["hirdetes"] == "" then return end
				triggerServerEvent("onClientCallAd", localPlayer, localPlayer, fakeInputs["hirdetes"], myPhoneNum)
				fakeInputs["hirdetes"] = ""
				activeButton = nil
				hirdetesTick = getTickCount()
			elseif currentPage == "darkHirdetes" then
				if fakeInputs["hirdetes"] == "" then return end
				triggerServerEvent("onClientCallAdDark", localPlayer, localPlayer, fakeInputs["hirdetes"], myPhoneNum)
				fakeInputs["hirdetes"] = ""
				activeButton = nil
				hirdetesTick = getTickCount()
			end
		end
	elseif command[1] == "hirdetesKikapcs" then
		if currentPage == "hirdetes" then
			if getElementData(localPlayer,"hiredetesbekapcsolva") then
				setElementData(localPlayer,"hiredetesbekapcsolva", false)
				outputChatBox("#ff9428[Telefon]:#ffffff Kikapcsoltad a hirdetéseket.",0,0,0,true)
				--if fakeInputs["hirdetes"] == "" then return end
				--triggerServerEvent("onClientCallAd", localPlayer, localPlayer, fakeInputs["hirdetes"], myPhoneNum)
				--fakeInputs["hirdetes"] = ""
				activeButton = nil
				--hirdetesTick = getTickCount()
			else 
				activeButton = nil
				setElementData(localPlayer,"hiredetesbekapcsolva", true)
				outputChatBox("#ff9428[Telefon]:#ffffff Bekapcsoltad a hirdetéseket.",0,0,0,true)
			end
		elseif currentPage == "darkHirdetes" then		
			if getElementData(localPlayer,"hiredetesbekapcsolvaillegal") then
				setElementData(localPlayer,"hiredetesbekapcsolvaillegal", false)
				outputChatBox("#ff9428[Telefon]:#ffffff Kikapcsoltad a hirdetéseket.",0,0,0,true)
				activeButton = nil
			else 
				activeButton = nil
				setElementData(localPlayer,"hiredetesbekapcsolvaillegal", true)
				outputChatBox("#ff9428[Telefon]:#ffffff Bekapcsoltad a hirdetéseket.",0,0,0,true)
			end
		end
	elseif command[1] == "telefonszamKikapcs" then
		if currentPage == "hirdetes" then
			if getElementData(localPlayer,"telefonszambekapcsolva") then
				setElementData(localPlayer,"telefonszambekapcsolva", false)
				outputChatBox("#ff9428[Telefon]:#ffffff Kikapcsoltad a telefonszámod megjelenítését.",0,0,0,true)
				activeButton = nil
			else 
				activeButton = nil
				setElementData(localPlayer,"telefonszambekapcsolva", true)
				outputChatBox("#ff9428[Telefon]:#ffffff Bekapcsoltad a telefonszámod megjelenítését.",0,0,0,true)
			end
		elseif currentPage == "darkHirdetes" then
			if getElementData(localPlayer,"telefonszambekapcsolvaillegal") then
				setElementData(localPlayer,"telefonszambekapcsolvaillegal", false)
				outputChatBox("#ff9428[Telefon]:#ffffff Kikapcsoltad a telefonszámod megjelenítését.",0,0,0,true)
				activeButton = nil
			else 
				activeButton = nil
				setElementData(localPlayer,"telefonszambekapcsolvaillegal", true)
				outputChatBox("#ff9428[Telefon]:#ffffff Bekapcsoltad a telefonszámod megjelenítését.",0,0,0,true)
			end
		end
	elseif command[1] == "newSendBtn" then
		isNewMessage = false
		if fakeInputs["messageNumber"] == "" then return end
		if #messages > 0 then
			for k, v in ipairs(messages) do
				if type(v) == "table" and v[1] and v[2] then
					if tonumber(v[1]) == tonumber(fakeInputs["messageNumber"]) then
						currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(fakeInputs["messageNumber"]))
						selectedMessage = k
						commandHandler("changepage:viewMessage")
					else
						currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(fakeInputs["messageNumber"]))
						idNumber = fakeInputs["messageNumber"]
						commandHandler("changepage:emptyMessage")
					end
				end
			end
		else
			currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(fakeInputs["messageNumber"]))
			idNumber = fakeInputs["messageNumber"]
			commandHandler("changepage:emptyMessage")
		end
	elseif command[1] == "idgSMSButton" then
		if fakeInputs["sms"] == "" then return end
		triggerServerEvent("newSMS", localPlayer, localPlayer, myPhoneNum, tonumber(idNumber), fakeInputs["sms"], messages)
		isNewMessage = true
	elseif command[1] == "smsSend" then
		if fakeInputs["sms"] == "" then return end
		triggerServerEvent("sendMessages", localPlayer, localPlayer, myPhoneNum, tonumber(messages[selectedMessage][1]), fakeInputs["sms"])
		table.insert(messages[selectedMessage], {fakeInputs["sms"], myPhoneNum})
		triggerServerEvent("smsSync", localPlayer, localPlayer, myPhoneNum, messages)
		fakeInputs["sms"] = ""
		activeButton = nil
	end
end

function onPhoneClick(button, state)
	if button == "left" then
		if activeButton then
			if string.find(activeButton, "setInput") then
				if state == "down" then
					activeFakeInput = activeButton:gsub("setInput:", "")
				end
			else
				local button = split(activeButton, "_")
				local btnstate = "down"

				if button[2] == "[up]" then
					btnstate = "up"
				end

				if button[3] == "[isButtonDown]" then
					return
				end

				if state == btnstate then
					commandHandler(button[1])
				end
			end
		elseif state == "down" then
			activeFakeInput = false
		end
	end
end

function onPhoneKey(key, state)
	local theInput, inputType, maxChar = getActiveFakeInput()

	if theInput and key ~= "escape" then
		cancelEvent()
	end

	if state then
		if key == "backspace" then
			processFakeInput("backspace")
		end

		if key == "enter" or key == "num_enter" then
			processFakeInput("enter")
		end
		
		if currentPage == "hirdetes" then
			if key == "enter" or key == "num_enter" then
				if fakeInputs["hirdetes"] == "" then return end
				triggerServerEvent("onClientCallAd", localPlayer, localPlayer, fakeInputs["hirdetes"], myPhoneNum)
				fakeInputs["hirdetes"] = ""
				activeButton = nil
			end
		elseif currentPage == "chatCall" then
			if key == "enter" or key == "num_enter" then
				if fakeInputs["callChatMsg"] == "" then return end
				triggerServerEvent("sendCallMessages", localPlayer, localPlayer, callingMember, fakeInputs["callChatMsg"], myPhoneNum)
				fakeInputs["callChatMsg"] = ""
				activeButton = nil				
			end	
		elseif currentPage == "addmessages" then
			if key == "enter" or key == "num_enter" then
				isNewMessage = false
				if #messages > 0 then
					for k, v in ipairs(messages) do
						if type(v) == "table" and v[1] and v[2] then
							if tonumber(v[1]) == tonumber(fakeInputs["messageNumber"]) then
								currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(fakeInputs["messageNumber"]))
								selectedMessage = k
								commandHandler("changepage:viewMessage")
							else
								currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(fakeInputs["messageNumber"]))
								idNumber = fakeInputs["messageNumber"]
								commandHandler("changepage:emptyMessage")
							end
						end
					end
				else
					currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(fakeInputs["messageNumber"]))
					idNumber = fakeInputs["messageNumber"]
					commandHandler("changepage:emptyMessage")
				end
			end
		elseif currentPage == "emptyMessage" then
			if key == "enter" or key == "num_enter" then
				if fakeInputs["sms"] == "" then return end
				triggerServerEvent("newSMS", localPlayer, localPlayer, myPhoneNum, tonumber(idNumber), fakeInputs["sms"], messages)
				isNewMessage = true			
			end
		elseif currentPage == "viewMessage" then
			if key == "enter" or key == "num_enter" then
				if fakeInputs["sms"] == "" then return end
				triggerServerEvent("sendMessages", localPlayer, localPlayer, myPhoneNum, tonumber(messages[selectedMessage][1]), fakeInputs["sms"])
				table.insert(messages[selectedMessage], {fakeInputs["sms"], myPhoneNum})
				triggerServerEvent("smsSync", localPlayer, localPlayer, myPhoneNum, messages)
				fakeInputs["sms"] = ""
			end
		end
	end

	if currentPage == "selectwallpaper" then
		if key == "mouse_wheel_down" then
			if offsetWallpaper < wallpapersNum - 4 then
				offsetWallpaper = offsetWallpaper + 1
			end
		elseif key == "mouse_wheel_up" then
			if offsetWallpaper > 0 then
				offsetWallpaper = offsetWallpaper - 1
			end
		end
	elseif currentPage == "contacts" then
		if key == "mouse_wheel_down" then
			if offsetContact < #contacts - contactNum then
				offsetContact = offsetContact + 1
			end
		elseif key == "mouse_wheel_up" then
			if offsetContact > 0 then
				offsetContact = offsetContact - 1
			end
		end
	elseif currentPage == "messages" then
		if key == "mouse_wheel_down" then
			if offsetMessages < #messages - messagesNum then
				offsetMessages = offsetMessages + 1
			end		
		elseif key == "mouse_wheel_up" then
			if offsetMessages > 0 then
				offsetMessages = offsetMessages - 1
			end
		end
	elseif currentPage == "viewMessage" then
		if key == "mouse_wheel_down" then
			if moveY > 0 then
				moveY = moveY - 10
			end
		elseif key == "mouse_wheel_up" then
			moveY = moveY + 10
		end
	end
end

--[[local renderTarget = dxCreateRenderTarget(500, 50, true) -- Creating the renderTarget, 500 width and 50 height, with alpha enabled.
local tomb = {
"első",
"második",
"harmadik",
"negyedik",
"ötödik",
}
local moveY = 0

addEventHandler("onClientRender", getRootElement(), function()
	if (renderTarget) then -- Checking if we have the renderTarget.
		dxSetRenderTarget(renderTarget, true) -- Setting the renderTarget, and clearing it every frame.
		for i, v in pairs(table.reverse(tomb)) do
			dxDrawText(v, 0, moveY+47 - (i*10), 500, 50, tocolor(255, 255, 255, 255), 1, "default-bold", nil, nil, true) -- Drawing the text on moveY Y pos
		end
		dxSetRenderTarget() -- Setting the renderTarget nil, so we are out of the renderTarget
		dxDrawImage(phonePosX, phonePosY, 500, 50, renderTarget) -- Drawing the renderTarget
		dxDrawRectangle(phonePosX, phonePosY, 500, 50, tocolor(255, 255, 255, 100))
	end
end)

addEventHandler("onClientKey", getRootElement(), function(cK, cS)
	if cS then
		if cK == "mouse_wheel_up" then
			--if moveY < 0 then
				moveY = moveY + 1
			--end
		elseif cK == "mouse_wheel_down" then
			if moveY > 0 then
				moveY = moveY - 1
			end
		end
	end
end)]]


function getActiveFakeInput(forcedInput)
	if forcedInput then
		local input = split(forcedInput, "|")

		return input[1], input[2], tonumber(input[3]), input[4]
	elseif activeFakeInput then
		local input = split(activeFakeInput, "|")

		return input[1], input[2], tonumber(input[3]), input[4]
	end
end

function processFakeInput(key, forcedInput)
	local theInput, inputType, maxChar = getActiveFakeInput(type(forcedInput) == "string" and forcedInput or false)

	if theInput then
		if not fakeInputs[theInput] then
			fakeInputs[theInput] = ""
		end

		if key == "enter" then

		elseif key == "backspace" then
			fakeInputs[theInput] = utf8.sub(fakeInputs[theInput], 1, -2)
		else
			if maxChar > utf8.len(fakeInputs[theInput]) then
				if inputType == "num-only" then
					if tonumber(key) then
						fakeInputs[theInput] = fakeInputs[theInput] .. key
					end
				else
					fakeInputs[theInput] = fakeInputs[theInput] .. key
				end
			end
		end
	end
end


function insertMessages(msg, number)
	if msg then
		callMessages[#callMessages + 1] = {msg, number}
		currentCallMSG = currentCallMSG + 1
	end
end
addEvent("insertMessages", true)
addEventHandler("insertMessages", getRootElement(), insertMessages)

function pastelcolor(str)
	local baseRed, baseGreen, baseBlue = 128, 128, 128
	local seed = 0

	for character in utf8.gmatch(str, ".") do
		seed = seed + utf8.byte(character)
	end
	
	local rand1 = math.abs(math.sin(seed) * 10000) % 256

	seed = seed + seed

	local rand2 = math.abs(math.sin(seed) * 10000) % 256

	seed = seed + seed

	local rand3 = math.abs(math.sin(seed) * 10000) % 256

	return math.ceil(rand1 + baseRed) / 2, math.ceil(rand2 + baseGreen) / 2, math.ceil(rand3 + baseBlue) / 2
end

function drawButtonSlider(key, state, x, y, h, bgColor, offColor, onColor)
	local buttonColor

	if state then
		buttonColor = {onColor[1], onColor[2], onColor[3], 0}
	else
		buttonColor = {offColor[1], offColor[2], offColor[3], 255}
	end

	local alphaDifference = 255 - buttonColor[4]

	buttons[key] = {x, y, resp(64), resp(32)}

	y = y + (h - resp(32)) / 2

	dxDrawImage(x, y, resp(64), resp(32), processPhoneTexture("files/off.png"), 0, 0, 0, tocolor(bgColor[1], bgColor[2], bgColor[3], 255 - alphaDifference))

	dxDrawImage(x, y, resp(64), resp(32), processPhoneTexture("files/on.png"), 0, 0, 0, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 0 + alphaDifference))

	if not state then
		dxDrawImage(x + (state and 32 or 0), y, resp(64), resp(32), processPhoneTexture("files/circle.png"), 0, 0, 0, tocolor(bgColor[1], bgColor[2], bgColor[3], 255))
	else
		dxDrawImage(x + (state and 32 or 0), y, resp(64), resp(32), processPhoneTexture("files/circle.png"), 0, 0, 0, tocolor(255, 255, 255, 255))
	end
end

function loadSMSFromServer(serverSMS)
	messages = {}
	messages = serverSMS
	
	if isNewMessage then
		for k, v in ipairs(messages) do
			if type(v) == "table" and v[1] and v[2] then
				if tonumber(v[1]) == tonumber(idNumber) then
					currentCallMemberName, currentCallMemberNumber = checkNumberInContactList(tonumber(idNumber))
					selectedMessage = k
					commandHandler("changepage:viewMessage")
					isNewMessage = false
				end
			end
		end
	end
end
addEvent("loadSMSFromServer", true)
addEventHandler("loadSMSFromServer", getRootElement(), loadSMSFromServer)

addEvent("phone.smsSyncClient",true);
addEventHandler("phone.smsSyncClient",root,function(data)
    messages = {};
    messages = tableCopy(data);
end);

function loadContactsFromServer(serverContact)
	contacts = serverContact
	
	-- feltöltjük hogy ne tudjunk duplikálni
	contactsEx = {}

	for i=1,#contacts do
		if contacts[i] then
			contactsEx[contacts[i][2]] = contacts[i][1]
		end
	end
end
addEvent("loadContactsFromServer", true)
addEventHandler("loadContactsFromServer", getRootElement(), loadContactsFromServer)

local unknownZones = {
	["San Fierro Bay"] = true,
	["Gant Bridge"] = true,
	["Las Venturas"] = true,
	["Bone County"] = true,
	["Tierra Robada"] = true,
}

function getZoneNameEx(x, y, z, cities)
	local zoneName = getZoneName(x, y, z, cities)
	local cityName = zoneName

	if not cities then
		cityName = getZoneName(x, y, z, true)
	end

	if unknownZones[zoneName] or unknownZones[cityName] then
		return "Ismeretlen"
	end

	if zoneName == "Unknown" or cityName == "Unknown" then
		return "Ismeretlen"
	end

	return zoneName
end

function checkNumberInContactList(number)
	local num = number
	local name = "Ismeretlen"

	if #contacts > 0 then
		for i = 1, #contacts do
			if contacts[i] then
				if tonumber(number) == contacts[i][2] then
					name = contacts[i][1]
					num = number
					break
				else
					name = "Ismeretlen"
					num = number
				end
			else
				name = "Ismeretlen"
				num = number
			end
		end
	else
		name = "Ismeretlen"
		num = number
	end
	
	return name, num
end

function tableCopy(t)
	if type(t) == "table" then
		local r = {}
		for k, v in pairs(t) do
			r[k] = tableCopy(v);
		end
		return r;
	else
		return t;
	end
end

local roundTexture = dxCreateTexture(":cosmo_assets/images/alert/round.png", "argb", true, "clamp")
function dxDrawRoundedRectangle(x, y, w, h, radius, color, border, borderColor, postGUI, subPixelPositioning)
	radius = radius or 5
	
	if border == "outer" then
		dxDrawImage(x - radius, y - radius, radius, radius, roundTexture, 0, 0, 0, borderColor, postGUI)
		dxDrawImage(x + w, y - radius, radius, radius, roundTexture, 90, 0, 0, borderColor, postGUI)
		dxDrawImage(x - radius, y + h, radius, radius, roundTexture, 270, 0, 0, borderColor, postGUI)
		dxDrawImage(x + w, y + h, radius, radius, roundTexture, 180, 0, 0, borderColor, postGUI)
		
		dxDrawRectangle(x, y, w, h, color, postGUI, subPixelPositioning)
		dxDrawRectangle(x, y - radius, w, radius, borderColor, postGUI, subPixelPositioning)
		dxDrawRectangle(x, y + h, w, radius, borderColor, postGUI, subPixelPositioning)
		dxDrawRectangle(x - radius, y, radius, h, borderColor, postGUI, subPixelPositioning)
		dxDrawRectangle(x + w, y, radius, h, borderColor, postGUI, subPixelPositioning)
	elseif border == "inner" then
		dxDrawImage(x, y, radius, radius, roundTexture, 0, 0, 0, borderColor, postGUI)
		dxDrawImage(x, y + h - radius, radius, radius, roundTexture, 270, 0, 0, borderColor, postGUI)
		dxDrawImage(x + w - radius, y, radius, radius, roundTexture, 90, 0, 0, borderColor, postGUI)
		dxDrawImage(x + w - radius, y + h - radius, radius, radius, roundTexture, 180, 0, 0, borderColor, postGUI)
		
		dxDrawRectangle(x, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
		dxDrawRectangle(x + radius, y, w - radius * 2, h, color, postGUI, subPixelPositioning)
		dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
		dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, borderColor, postGUI, subPixelPositioning)
		dxDrawRectangle(x, y + radius, radius, h - radius * 2, borderColor, postGUI, subPixelPositioning)
		dxDrawRectangle(x + radius, y, w - radius * 2, radius, borderColor, postGUI, subPixelPositioning)
		dxDrawRectangle(x + radius, y + h - radius, w - radius * 2, radius, borderColor, postGUI, subPixelPositioning)
	else
		dxDrawImage(x, y, radius, radius, roundTexture, 0, 0, 0, color, postGUI)
		dxDrawImage(x, y + h - radius, radius, radius, roundTexture, 270, 0, 0, color, postGUI)
		dxDrawImage(x + w - radius, y, radius, radius, roundTexture, 90, 0, 0, color, postGUI)
		dxDrawImage(x + w - radius, y + h - radius, radius, radius, roundTexture, 180, 0, 0, color, postGUI)
		
		dxDrawRectangle(x, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
		dxDrawRectangle(x + radius, y, w - radius * 2, h, color, postGUI, subPixelPositioning)
		dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
	end
end

local sounds = {}

function playPhoneSound(e, type)
	print("első")
	if e and isElement(e) then
	print("második")
		if type == "call" then
			local x, y, z = getElementPosition(e)
			local sound = playSound3D("files/sounds/ringtone.mp3", x, y, z, false, true)
			attachElements(sound, e)
			sounds[e] = sound
		elseif type == "sms" then
	print("harmadik")
			local x, y, z = getElementPosition(e)
			local sound = playSound3D("files/sounds/sms.mp3", x, y, z, false, true)
			attachElements(sound, e)
			sounds[e] = sound		
		end
	end
end
addEvent("playPhoneSound", true)
addEventHandler("playPhoneSound", root, playPhoneSound)

function stopPhoneSound(e)
	if e and isElement(e) then
		for k, v in pairs(sounds) do
			if k == e then
				stopSound(v)
				sounds[k] = nil
			end
		end
	end
end
addEvent("stopPhoneSound", true)
addEventHandler("stopPhoneSound", root, stopPhoneSound)