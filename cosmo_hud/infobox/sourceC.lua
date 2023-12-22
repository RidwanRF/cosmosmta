alertTypes = {
	info = {"Információ", ":cosmo_assets/images/alert/info.png", {0, 149, 217}, ":cosmo_assets/audio/alert/bulle.wav"},
	jail = {"Adminbörtön", ":cosmo_assets/images/alert/ajail.png", {233, 30, 99}, ":cosmo_assets/audio/alert/star.wav"},
	kick = {"Kirúgás", ":cosmo_assets/images/alert/akick.png", {218, 147, 44}, ":cosmo_assets/audio/alert/star.wav"},
	ban = {"Kitiltás", ":cosmo_assets/images/alert/aban.png", {218, 44, 73}, ":cosmo_assets/audio/alert/star.wav"},
	error = {"Hiba", ":cosmo_assets/images/alert/error.png", {200, 50, 50}, ":cosmo_assets/audio/alert/error.wav"},
	warning = {"Figyelmeztetés", ":cosmo_assets/images/alert/warning.png", {255, 128, 0}, ":cosmo_assets/audio/alert/error.wav"}, 
	aduty = {"Adminszolgálat", ":cosmo_assets/images/alert/info.png", {255, 148, 40}, ":cosmo_assets/audio/alert/victory.wav"},
	success = {"Információ", ":cosmo_assets/images/alert/success.png", {50, 200, 50}, ":cosmo_assets/audio/alert/star.wav"}
}

local infobox = {}
local iconSize = respc(35)
local customFont = exports.cosmo_assets:loadFont("Roboto-Regular.ttf", 6 * 2, false)

function showInfobox(type, msg, msg2, imgPath, color)
	if not (type and msg) then
		return
	end

	if msg2 and utf8.len(msg2) <= 0 then
		msg2 = nil
	end
	
	if imgPath then
		infobox.icon = imgPath
	else
		infobox.icon = alertTypes[type][2]
	end

	if color then
		infobox.color = color
	else
		infobox.color = alertTypes[type][3]
	end
	
	local messageWidth = math.max(dxGetTextWidth(msg, 0.85, customFont), dxGetTextWidth(msg2 or "", 0.85, customFont)) + 20
	local tileWidth = iconSize + messageWidth
	
	infobox.tileWidth = tileWidth
	infobox.tileHeight = math.max(dxGetFontHeight(0.85, customFont) * (msg2 and 2 or 1) + 10, respc(40))
	infobox.tilePosX = (screenX - tileWidth) / 2
	
	infobox.moveDownTick = getTickCount()
	infobox.moveUpTick = infobox.moveDownTick + 1000 + ((msg and utfLen(msg) or 0) + (msg2 and utfLen(msg2) or 0)) * 125
	
	infobox.state = true
	infobox.message = {msg, msg2}
	
	if alertTypes[type][4] then
		playSound(alertTypes[type][4])
	end

	if msg2 then
		outputConsole("[" .. alertTypes[type][1] .. "]: " .. msg .. ", " .. msg2)
	else
		outputConsole("[" .. alertTypes[type][1] .. "]: " .. msg)
	end
end
addEvent("showInfobox", true)
addEventHandler("showInfobox", getRootElement(), showInfobox)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if not infobox or not infobox.state then
			return
		end
		
		local tickCount = getTickCount()
		local x = infobox.tilePosX
		local y = -infobox.tileHeight
		local alpha = 0
		
		if tickCount >= infobox.moveDownTick and tickCount <= infobox.moveUpTick then
			alpha, y = interpolateBetween(0, -infobox.tileHeight, 0, 1, 50, 0, (tickCount - infobox.moveDownTick) / 500, "OutQuad")
		elseif tickCount >= infobox.moveUpTick then
			local progress = (tickCount - infobox.moveUpTick) / 500
			alpha, y = interpolateBetween(1, 50, 0, 0, -infobox.tileHeight, 0, progress, "OutQuad")
		
			if progress > 1 then
				infobox.state = false
			end
		end
		
		-- háttér
		roundedRectangle(math.floor(x), math.floor(y), infobox.tileHeight,infobox.tileHeight, tocolor(0, 0, 0, 0))
		roundedRectangle(x, y, infobox.tileWidth, infobox.tileHeight, tocolor(0, 0, 0, 130))
		roundedRectangle(x-2, y-2, infobox.tileWidth + 4, infobox.tileHeight + 4, tocolor(0, 0, 0, 0))

		
		--dxDrawRectangle(x + 2, y + 2, infobox.tileWidth - 4, infobox.tileHeight - 4, tocolor(infobox.color[1]*0.8, infobox.color[2]*0.8, infobox.color[3]*0.8, 175 * alpha))

		-- ** töltő csík
		local progress = (tickCount - infobox.moveDownTick) / (infobox.moveUpTick - infobox.moveDownTick)

		if progress <= 1 then
			dxDrawRectangle(x + infobox.tileWidth/2, y + infobox.tileHeight - 2, (infobox.tileWidth * (1 - progress)/2), 2, tocolor(infobox.color[1], infobox.color[2], infobox.color[3], 255 * alpha))
			dxDrawRectangle(x + infobox.tileWidth/2, y + infobox.tileHeight - 2, -(infobox.tileWidth * (1 - progress)/2), 2, tocolor(infobox.color[1], infobox.color[2], infobox.color[3], 255 * alpha))
		end

		-- ** Content
		local iconSizeEx = iconSize * 0.75

		
		dxDrawImage(math.floor(x + (infobox.tileHeight - iconSizeEx) / 2), math.floor(y + (infobox.tileHeight - iconSizeEx) / 2), iconSizeEx, iconSizeEx, infobox.icon, 0, 0, 0, tocolor(infobox.color[1], infobox.color[2], infobox.color[3], alpha * 255))
		
		if infobox.message[2] then
			dxDrawText(infobox.message[1] .. "\n" .. infobox.message[2], x + infobox.tileHeight, y, x + infobox.tileWidth, y + infobox.tileHeight, tocolor(220, 220, 220, alpha * 255), 0.85, customFont, "center", "center", true)
		else
			dxDrawText(infobox.message[1], x + infobox.tileHeight, y, x + infobox.tileWidth, y + infobox.tileHeight, tocolor(220, 220, 220, alpha * 255), 0.85, customFont, "center", "center", true)
		end
	end, true, "low-999999999"
)


function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
    if (x and y and w and h) then
        if (not borderColor) then
            borderColor = tocolor(0, 0, 0, 180);
        end
        if (not bgColor) then
            bgColor = borderColor;
        end
        dxDrawRectangle(x, y, w, h, bgColor, postGUI);
        dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
        dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
        dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
        dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
    end
end