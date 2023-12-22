local sx, sy = guiGetScreenSize(); 
local relX, relY = sx/1920, sy/1080; 

local relX2, relY2 = 1768, 992

local myX, myY = 1600, 900

local szin = color;

local fonts = {
	["condensed-14"] = font:loadFont("Roboto-Regular.ttf", 14),
	["condensed-15"] = font:loadFont("Roboto-Regular.ttf", 15),
	["condensed-20"] = font:loadFont("Roboto-Regular.ttf", 20),
	["bebasneue-40"] = font:loadFont("Roboto-Regular.ttf", 40),
}

function isElementInRange(ele, x, y, z, range)
   if isElement(ele) and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(range) == "number" then
      return getDistanceBetweenPoints3D(x, y, z, getElementPosition(ele)) <= range -- returns true if it the range of the element to the main point is smaller than (or as big as) the maximum range.
   end
   return false
end

serverColor = "#ff9428"
serverRGB = {255, 148, 40}

function getServerColor()
    return serverColor, serverRGB[1], serverRGB[2], serverRGB[3]
end

addEventHandler("onClientResourceStart", root, function(res)
	if getResourceName(res) == "cosmo_core" then  
      core = exports.cosmo_core
		--color, r, g, b = getServerColor()
		serverColor = getServerColor()
		serverSyntax = serverColor.."[Pizza készítő]:#ffffff"
	end
end)

l = 0;

local moveElement = false

addEventHandler("onClientResourceStop", resourceRoot, function()
	if isElement(enterMarker) then 
		destroyElement(enterMarker)
	end

	if isElement(skinMarker) then 
		destroyElement(skinMarker)
	end

	if isElement(orderMarker) then 
		destroyElement(orderMarker) 
	end

	if isElement(creatorMarker) then 
		destroyElement(creatorMarker)
	end

	if isElement(pizzaBakeMarker) then 
		destroyElement(pizzaBakeMarker)
	end

	if isElement(jobEndMarker) then 
		destroyElement(jobEndMarker)
	end

	if getElementData(localPlayer, "pizza:isPlayerInInt") then 
		warpPedOutOfInterior()
	end
end)

function printJobTips()
	outputChatBox("#ff9428[Pizza készítő]:#ffffff A munkát egy #ff9428sárga #fffffftáska ikonnal jelöltük. Két helyen is van pizzázó és a munka mind két helyen #ff9428elérhető#ffffff.", 255, 255, 255, true)
	outputChatBox("#ff9428[Pizza készítő]:#ffffff A munka kezdéséhez csak menj be a #4287f5kék #ffffffmarkerbe és lépj be az épületbe.", 255, 255, 255, true)
	outputChatBox("#ff9428[Pizza készítő]:#ffffff Ezt követően vedd fel a munkaruhádat és már kezdheted is a vásárlók kiszolgálását.", 255, 255, 255, true)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	color = "#ff9428"
	r, g, b = serverRGB[1], serverRGB[2], serverRGB[3]

	if getElementData(localPlayer, "char.Job") == 2 then 
		printJobTips()

		enterMarker = exports.cosmo_custommarker:createCustomMarker(2109.0700683594, -1790.1712646484, 13.56875038147, 2.5, 0, 145, 150, 255, "arrow")
		blip = createBlip(2109.0700683594, -1790.1712646484, 13.56875038147)
		setElementData(blip, "blipTooltipText", "Pizzázó")
		setElementData(blip, "blipIcon", "taska")
		setElementData(blip, "blipSize", 22)
		setElementData(blip, "blipColor", tocolor(255, 255, 255))

		enterMarker2 = exports.cosmo_custommarker:createCustomMarker(1382.3280029297, 260.23034667969, 19.566932678223, 2.5, 0, 145, 150, 255, "arrow")
		blip2 = createBlip(1382.3280029297, 260.23034667969, 19.566932678223)
		setElementData(blip2, "blipTooltipText", "Pizzázó")
		setElementData(blip2, "blipIcon", "taska")
		setElementData(blip2, "blipSize", 22)
		setElementData(blip2, "blipColor", tocolor(255, 255, 255))
	end
end)

function isInSlot(x,y,w,h)
    if isCursorShowing() then 
        local cX,cY = getCursorPosition()
        if cX and cY then 
            local sx,sy = guiGetScreenSize()
            cX,cY = cX*sx,cY*sy 

            if cX > x and cX < x + w and cY > y and cY < y + h then 
                return true 
            else 
                return false 
            end
        else 
            return false 
        end
    else 
        return false
    end
end

function dxDrawShadowedText(text, x, y, w, h, color, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	if not font then
		return
	end

    local textWithoutColors = string.gsub(text, "#......", "")

    local shadowType = "anyad"
    if shadowType == 1 then 
        dxDrawText(textWithoutColors, x - 1, y - 1, w - 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
        dxDrawText(textWithoutColors, x - 1, y + 1, w - 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
        dxDrawText(textWithoutColors, x + 1, y - 1, w + 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
        dxDrawText(textWithoutColors, x + 1, y + 1, w + 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    elseif shadowType == 2 then 
        dxDrawText(textWithoutColors, x, y + 1, w, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
        dxDrawText(textWithoutColors, x + 1, y, w + 1, h, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    end

	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

function dxDrawButton(x, y, w, h, br, bg, bb, ba, text, textColor, fontSize, font, borderedText, borderColor)
    if isInSlot(x, y, w, h) then
        dxDrawRectangle(x, y, w, h, tocolor(255, 148, 40, ba*0.55))
        dxDrawRectangle(x + 2/relX2*sx, y + 2/relY2*sy, w - 4/relX2*sx, h - 4/relY2*sy, tocolor(255, 148, 40, ba))
    else
        dxDrawRectangle(x, y, w, h, tocolor(255, 148, 40, ba*0.40))
        dxDrawRectangle(x + 2/relX2*sx, y + 2/relY2*sy, w - 4/relX2*sx, h - 4/relY2*sy, tocolor(255, 148, 40, ba*0.70))
    end

    if borderedText then
        if not borderColor then borderColor = tocolor(0, 0, 0, 255) end 
        dxDrawShadowedText(text, x, y, x + w, y + h, textColor, borderColor, fontSize, font, "center", "center")
    else
        dxDrawText(text, x, y, x + w, y + h, textColor, fontSize, font, "center", "center")
    end
end

addEventHandler("onClientElementDataChange", root, function(key, old, new)
	if source == localPlayer then 
		if key == "char.Job" then 
			if new == 2 then 
				enterMarker = exports.cosmo_custommarker:createCustomMarker(2109.0700683594, -1790.1712646484, 13.56875038147, 2.5, 0, 145, 150, 255, "arrow")
				blip = createBlip(2109.0700683594, -1790.1712646484, 13.56875038147, 11)
				setElementData(blip, "blipTooltipText", "Pizzázó")
				setElementData(blip, "blipIcon", "taska")
				setElementData(blip, "blipSize", 22)
				setElementData(blip, "blipColor", tocolor(255, 255, 255))

				enterMarker2 = exports.cosmo_custommarker:createCustomMarker(1382.3280029297, 260.23034667969, 19.566932678223, 2.5, 0, 145, 150, 255, "arrow")
				blip2 = createBlip(1382.3280029297, 260.23034667969, 19.566932678223, 11)
				setElementData(blip2, "blipTooltipText", "Pizzázó")
				setElementData(blip2, "blipIcon", "taska")
				setElementData(blip2, "blipSize", 22)
				setElementData(blip2, "blipColor", tocolor(255, 255, 255))
				printJobTips()
			end

			if old == 2 then 
				if isElement(enterMarker) then 
					destroyElement(enterMarker)
				end

				if isElement(blip) then 
					destroyElement(blip)
				end

				if isElement(enterMarker2) then 
					destroyElement(enterMarker2)
				end

				if isElement(blip2) then 
					destroyElement(blip2)
				end
			end
		end
	end
end)

local pizzaIngs = {}

local tooltipText = "Az interakcióhoz"

function render()
		if(startedMaking) then
			if(playerAtTable) then
				--dxDrawLine(0, sy*0.5, sx, sy*0.5)
				dxDrawRectangle(sx*0.29-2/myX*sx, sy*0.25-2/myY*sy, sx*0.15+sx*0.25+4/myX*sx+4/myX*sx, sy*0.5+4/myY*sy, tocolor(0, 0, 0, 170))
				dxDrawRectangle(sx*0.29, sy*0.25, sx*0.15, sy*0.5, tocolor(0, 0, 0, 150))
				dxDrawRectangle(sx*0.29+sx*0.15+5/myX*sx, sy*0.25, sx*0.25, sy*0.5, tocolor(0, 0, 0, 150))

				if core:isInSlot(sx*0.29, sy*0.25+5/myY*sy, 40/myX*sx, 40/myY*sy) then 
					dxDrawImage(sx*0.29, sy*0.25+5/myY*sy, 40/myX*sx, 40/myY*sy, "images/trash.png", 0, 0, 0, tocolor(235, 52, 52, 255))
				else
					dxDrawImage(sx*0.29, sy*0.25+5/myY*sy, 40/myX*sx, 40/myY*sy, "images/trash.png", 0, 0, 0, tocolor(220, 220, 220, 255))
				end
				
				if(onPizzaWidth == 0) then
					dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, 'images/pizzaalap.png')
					dxDrawText(color.."1. #dcdcdc| TÉSZTA VASTAGSÁGA", sx*0.29+sx*0.15+10/myX*sx, sy*0.25+5/myY*sy, sx*0.29+sx*0.15+10/myX*sx+sx*0.25, sy*0.25+sy*0.5+5/myY*sy, tocolor(255,255,255,255), 0.8/myX*sx, fonts["condensed-20"], "left", "top", false, false, false, true);
					
					local starty = sy*0.31
					for k, v in ipairs(thicknesses) do 
						--dxDrawImage(sx*0.46, starty, 120/myX*sx, 120/myY*sy, "images/"..v.file)

						if core:isInSlot(sx*0.29+sx*0.15+5/myX*sx, starty, sx*0.25, 120/myY*sy) then 
							dxDrawText(v.name, sx*0.29+sx*0.15+5/myX*sx, starty, sx*0.29+sx*0.15+5/myX*sx+sx*0.25, starty+120/myY*sy, tocolor(r, g, b, 255), 1/myX*sx, fonts["condensed-20"], "center", "center")
						else
							dxDrawText(v.name, sx*0.29+sx*0.15+5/myX*sx, starty, sx*0.29+sx*0.15+5/myX*sx+sx*0.25, starty+120/myY*sy, tocolor(220, 220, 220, 255), 1/myX*sx, fonts["condensed-20"], "center", "center")
						end

						starty = starty+125/myY*sy
					end

				elseif(onPizzaSauce == 0) then -- van rajta szósz
					dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, 'images/pizzaalap.png')
					-- majd még ide kell a törlés

					dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, 'images/pizzaalap.png')
					dxDrawText(color.."2. #dcdcdc| SZÓSZOK", sx*0.29+sx*0.15+10/myX*sx, sy*0.25+5/myY*sy, sx*0.29+sx*0.15+10/myX*sx+sx*0.25, sy*0.25+sy*0.5+5/myY*sy, tocolor(255,255,255,255), 0.8/myX*sx, fonts["condensed-20"], "left", "top", false, false, false, true);
					local starty = sy*0.31
					for k, v in ipairs(sauces) do 
						dxDrawImage(sx*0.46, starty, 120/myX*sx, 120/myY*sy, "images/"..v.file)

						dxDrawText(v.name, sx*0.46, starty, sx*0.46+sx*0.2, starty+120/myY*sy, tocolor(220, 220, 220, 255), 1/myX*sx, fonts["condensed-20"], "right", "center")

						starty = starty+125/myY*sy
					end
				else
					dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, 'images/'..sauces[onPizzaSauce].base, 0, 0, 0)
					if(onPizzaCheese == 0) then
						dxDrawText(color.."3. #dcdcdc| SAJT", sx*0.29+sx*0.15+10/myX*sx, sy*0.25+5/myY*sy, sx*0.29+sx*0.15+10/myX*sx+sx*0.25, sy*0.25+sy*0.5+5/myY*sy, tocolor(255,255,255,255), 0.8/myX*sx, fonts["condensed-20"], "left", "top", false, false, false, true);
						
						local starty = sy*0.31
						for k, v in ipairs(cheeses) do 
							dxDrawImage(sx*0.46, starty, 120/myX*sx, 120/myY*sy, "images/"..v.file)

							dxDrawText(v.name, sx*0.46, starty, sx*0.46+sx*0.2, starty+120/myY*sy, tocolor(220, 220, 220, 255), 1/myX*sx, fonts["condensed-20"], "right", "center")

							starty = starty+125/myY*sy
						end
					else
						if onPizzaCheese > 1 then 
							dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, 'images/'..cheeses[onPizzaCheese].file, 0, 0, 0)
						end
						dxDrawText(color.."4. #dcdcdc| FELTÉTEK", sx*0.29+sx*0.15+10/myX*sx, sy*0.25+5/myY*sy, sx*0.29+sx*0.15+10/myX*sx+sx*0.25, sy*0.25+sy*0.5+5/myY*sy, tocolor(255,255,255,255), 0.8/myX*sx, fonts["condensed-20"], "left", "top", false, false, false, true);
						
						local starty = sy*0.285
						local startx = sx*0.445
						for k, v in ipairs(ingredients) do 

							if core:isInSlot(startx, starty, 100/myX*sx, 100/myY*sy) then 
								dxDrawImage(startx, starty, 100/myX*sx, 100/myY*sy, "images/ings/"..ingredientFiles[k], 0, 0, 0, tocolor(255, 255, 255, 100))
								dxDrawText(v, startx, starty, startx+100/myX*sx, starty+100/myY*sy, tocolor(255, 255, 255, 200), 0.6/myX*sx, fonts["condensed-20"], "center", "center")
							else
								dxDrawText(v, startx, starty, startx+100/myX*sx, starty+100/myY*sy, tocolor(255, 255, 255, 50), 0.5/myX*sx, fonts["condensed-20"], "center", "center")
								dxDrawImage(startx, starty, 100/myX*sx, 100/myY*sy, "images/ings/"..ingredientFiles[k])
							end

							starty = starty+105/myY*sy

							if k % 4 == 0 then 
								startx = startx + 100/myX*sx
								starty = sy*0.285
							end
						end

						for k, v in ipairs(pizzaIngs) do 
							dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, 'images/ings/'..ingredientFiles[v])
						end

						dxDrawButton(sx*0.295, sy*0.7, sx*0.14, sy*0.04, r, g, b, 200, "Elkészítés", tocolor(255, 255, 255, 255), 0.5/myX*sx, fonts["condensed-20"], true, tocolor(0, 0, 0, 100))
					end
				end
			end
		end

		if(orderPos == true) then

			dxDrawRectangle(sx*0.83-2/myX*sx, sy*0.27-2/myY*sy, 250/myX*sx+4/myX*sx, 400/myY*sy+4/myY*sy, tocolor(0, 0, 0, 170)) -- blokk alap 
			dxDrawRectangle(sx*0.83, sy*0.27, 250/myX*sx, 400/myY*sy, tocolor(0, 0, 0, 150)) -- blokk alap 
			dxDrawRectangle(sx*0.83, sy*0.27, 250/myX*sx, 70/myY*sy, tocolor(0, 0, 0, 150)) -- blokk alap 

			dxDrawText("RENDELÉS", sx*0.83, sy*0.27, sx*0.83+250/myX*sx, sy*0.27+70/myY*sy, tocolor(220, 220, 220, 255), 0.9/myX*sx, fonts["condensed-20"], "center", "center", false, false, false, true);

			if (not startedMaking) then
				dxDrawButton(sx*0.83+5/myX*sx, sy*0.677, 250/myX*sx-10/myX*sx, sy*0.03, r, g, b, 200, orderText, tocolor(255, 255, 255, 255), 0.5/myX*sx, fonts["condensed-20"], true, tocolor(0, 0, 0, 100))
			elseif(startedMaking) then
				dxDrawText("Ennyi ideje készíted: "..color..makingTime.." #dcdcdcmásodperc", sx*0.83+5/myX*sx, sy*0.665, sx*0.83+5/myX*sx+250/myX*sx-10/myX*sx, sy*0.665+sy*0.025, tocolor(220, 220, 220, 245), 0.5/myX*sx, fonts["condensed-20"], "left", "center", false, false, false, true);
				dxDrawText("Elvárt készítési idő: "..color..elvartIdo.." #dcdcdcmásodperc", sx*0.83+5/myX*sx, sy*0.69, sx*0.83+5/myX*sx+250/myX*sx-10/myX*sx, sy*0.69+sy*0.025, tocolor(220, 220, 220, 245), 0.5/myX*sx, fonts["condensed-20"], "left", "center", false, false, false, true);
			end	

			if(orderNow == true) then
				dxDrawText("Chk "..randomChk.."", sx*0.83+2/myX*sx, sy*0.27+2/myY*sy, sx*0.83+252/myX*sx, sy*0.27+72/myY*sy, tocolor(220, 220, 220, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "top", false, false, false, true);
				dxDrawText("Guest "..makedPizzas, sx*0.83-2/myX*sx, sy*0.27-2/myY*sy, sx*0.83+248/myX*sx, sy*0.27+68/myY*sy, tocolor(220, 220, 220, 245), 0.6/myX*sx, fonts["condensed-15"], "right", "bottom", false, false, false, true);
			end

			dxDrawRectangle(sx*0.835, sy*0.36, 50/myX*sx, 50/myY*sy, tocolor(0, 0, 0, 150))

			if sauce > 0 then 
				dxDrawImage(sx*0.835 + 5/myX*sx, sy*0.36 + 5/myY*sy, 40/myX*sx, 40/myY*sy, "images/"..sauces[sauce].file)

				if onPizzaSauce == sauce then 
					dxDrawText(sauces[sauce].name.." szósz", sx*0.872+50/myX*sx, sy*0.36, sx*0.872+50/myX*sx+sx*0.07, sy*0.36+sy*0.02, tocolor(r, g, b, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "center")
				else
					dxDrawText(sauces[sauce].name.." szósz", sx*0.872+50/myX*sx, sy*0.36, sx*0.872+50/myX*sx+sx*0.07, sy*0.36+sy*0.02, tocolor(220, 220, 220, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "center")
				end
			end

			dxDrawRectangle(sx*0.868, sy*0.36, 50/myX*sx, 50/myY*sy, tocolor(0, 0, 0, 150))

			if cheese > 0 then 
				dxDrawImage(sx*0.868 + 5/myX*sx, sy*0.36 + 5/myY*sy, 40/myX*sx, 40/myY*sy, "images/"..cheeses[cheese].file)

				if onPizzaCheese == cheese then 
					dxDrawText(cheeses[cheese].name, sx*0.872+50/myX*sx, sy*0.375, sx*0.872+50/myX*sx+sx*0.07, sy*0.375+sy*0.02, tocolor(r, g, b, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "center")
				else
					dxDrawText(cheeses[cheese].name, sx*0.872+50/myX*sx, sy*0.375, sx*0.872+50/myX*sx+sx*0.07, sy*0.375+sy*0.02, tocolor(220, 220, 220, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "center")
				end
			end

			if thickness > 0 then 
				if onPizzaWidth == thickness then 
					dxDrawText(thicknesses[thickness].name, sx*0.872+50/myX*sx, sy*0.39, sx*0.872+50/myX*sx+sx*0.07, sy*0.39+sy*0.02, tocolor(r, g, b, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "center")
				else
					dxDrawText(thicknesses[thickness].name, sx*0.872+50/myX*sx, sy*0.39, sx*0.872+50/myX*sx+sx*0.07, sy*0.39+sy*0.02, tocolor(220, 220, 220, 255), 0.6/myX*sx, fonts["condensed-15"], "left", "center")
				end
			end

			--dxDrawRectangle(sx*0.83+5/myX*sx, sy*0.642, 250/myX*sx-10/myX*sx, sy*0.03)

			if drinkChosen > 0 then 
				if drinkChosen == activeDrink then 
					dxDrawText(drinks[drinkChosen].name, sx*0.83+5/myX*sx, sy*0.642, sx*0.83+5/myX*sx+250/myX*sx-10/myX*sx, sy*0.642+sy*0.03, tocolor(r, g, b, 255), 0.75/myX*sx, fonts["condensed-15"], "left", "center")
				else
					dxDrawText(drinks[drinkChosen].name, sx*0.83+5/myX*sx, sy*0.642, sx*0.83+5/myX*sx+250/myX*sx-10/myX*sx, sy*0.642+sy*0.03, tocolor(220, 220, 220, 255), 0.75/myX*sx, fonts["condensed-15"], "left", "center")
				end
			end

			local starty = sy*0.42
			for k, v in ipairs(active_ings) do 
				local alpha = 255 

				if k % 2 == 0 then 
					alpha = 180
				end

				dxDrawRectangle(sx*0.835, starty, sx*0.147, sy*0.025, tocolor(0, 0, 0, alpha))

				if table.contains(pizzaIngs, v) then 
					dxDrawText(ingredients[v], sx*0.835, starty, sx*0.835+sx*0.147, starty+sy*0.025, tocolor(r, g, b, 255), 0.6/myX*sx, fonts["condensed-15"], "center", "center")
				else
					dxDrawText(ingredients[v], sx*0.835, starty, sx*0.835+sx*0.147, starty+sy*0.025, tocolor(220, 220, 220, 255), 0.6/myX*sx, fonts["condensed-15"], "center", "center")
				end
				starty = starty + sy*0.027
			end
		end
		
		if(bakeReady) then
			if(bakeStarted) then
				if(pizzaWrapPanelStatus) then
					dxDrawRectangle(sx*0.4, sy*0.35, sx*0.2, sy*0.25, tocolor(0, 0, 0, 170))
					dxDrawRectangle(sx*0.4+2/myX*sx, sy*0.35+2/myY*sy, sx*0.2-4/myX*sx, sy*0.25-4/myY*sy, tocolor(0, 0, 0, 170))
					if not(pizzaOut) then
						dxDrawText("Pizza állapota: "..color..pizzaStatus, sx*0.4, sy*0.36, sx*0.4+sx*0.2, sy*0.36+sy*0.25, tocolor(220, 220, 220, 255), 1/myX*sx, fonts["condensed-15"], "center", "top", false, false, false, true);
						dxDrawText(color..sutesIdo.." #dcdcdcmp", sx*0.4, sy*0.36, sx*0.4+sx*0.2, sy*0.36+sy*0.25, tocolor(255,255,255,255), 0.95/myX*sx, fonts["bebasneue-40"], "center", "center", false, false, false, true);

						dxDrawButton(sx*0.4+8/myX*sx, sy*0.552, sx*0.2-16/myX*sx, sy*0.04, r, g, b, 200, "Pizza kivétele", tocolor(255, 255, 255, 255), 0.5/myX*sx, fonts["condensed-20"], true, tocolor(0, 0, 0, 100))
					elseif(pizzaOut) then
						if(startedWrapping) then

							local lineHeight = interpolateBetween(oldWrapButtonTimes/20, 0, 0, wrapButtonTimes/20, 0, 0, (getTickCount()-wrapButtonTimesTick)/100, "Linear")

							dxDrawRectangle(sx*0.4+8/myX*sx, sy*0.47, sx*0.2-16/myX*sx, sy*0.025, tocolor(0, 0, 0, 170))
							dxDrawRectangle(sx*0.4+10/myX*sx, sy*0.47+2/myY*sy, sx*0.2-20/myX*sx, sy*0.025-4/myY*sy, tocolor(0, 0, 0, 170))
							dxDrawRectangle(sx*0.4+10/myX*sx, sy*0.47+2/myY*sy, (sx*0.2-20/myX*sx)*(lineHeight), sy*0.025-4/myY*sy, tocolor(r, g, b, 255))

							if not (pizzaWrapped) then
								dxDrawText("Csomagold a pizzát a lenti\n gombra kattintgatva. ", sx*0.4, sy*0.36, sx*0.4+sx*0.2, sy*0.36+sy*0.25, tocolor(220, 220, 220, 255), 0.9/myX*sx, fonts["condensed-14"], "center", "top", false, false, false, true);
						
								dxDrawButton(sx*0.4+8/myX*sx, sy*0.552, sx*0.2-16/myX*sx, sy*0.04, r, g, b, 200, "Pizza csomagolása", tocolor(255, 255, 255, 255), 0.5/myX*sx, fonts["condensed-20"], true, tocolor(0, 0, 0, 100))
							elseif(pizzaWrapped) then
								dxDrawText("Sikeresen becsomagoltad a pizzát!", sx*0.4, sy*0.36, sx*0.4+sx*0.2, sy*0.36+sy*0.25, tocolor(220, 220, 220, 255), 0.9/myX*sx, fonts["condensed-14"], "center", "top", false, false, false, true);

								dxDrawButton(sx*0.4+8/myX*sx, sy*0.552, sx*0.2-16/myX*sx, sy*0.04, r, g, b, 200, "Pizza kivétele", tocolor(255, 255, 255, 255), 0.5/myX*sx, fonts["condensed-20"], true, tocolor(0, 0, 0, 100))
							end
						end
					end
				end
			end
		end
		
		if(pizzaIsInCustomersHand) then
			if not (drinkChosen == 0) then
				dxDrawRectangle(sx*0.29-2/myX*sx, sy*0.25-2/myY*sy, sx*0.15+sx*0.25+5/myX*sx+4/myX*sx, sy*0.5+4/myY*sy, tocolor(0, 0, 0, 170))
				dxDrawRectangle(sx*0.29, sy*0.25, sx*0.15, sy*0.5, tocolor(0, 0, 0, 150))
				dxDrawRectangle(sx*0.29+sx*0.15+5/myX*sx, sy*0.25, sx*0.25, sy*0.5, tocolor(0, 0, 0, 150))

				dxDrawText(color.."5. #dcdcdc| ITAL KIVÁLASZTÁSA", sx*0.29+sx*0.15+10/myX*sx, sy*0.25+5/myY*sy, sx*0.29+sx*0.15+10/myX*sx+sx*0.25, sy*0.25+sy*0.5+5/myY*sy, tocolor(255,255,255,255), 0.8/myX*sx, fonts["condensed-20"], "left", "top", false, false, false, true);
						
				local starty = sy*0.285
				local startx = sx*0.445
				for k, v in ipairs(drinks) do 

					if core:isInSlot(startx, starty, 100/myX*sx, 100/myY*sy) then 
						dxDrawImage(startx+10/myX*sx, starty+10/myY*sy, 80/myX*sx, 80/myY*sy, "images/"..v.file, 0, 0, 0, tocolor(255, 255, 255, 100))
						dxDrawText(v.name, startx, starty, startx+100/myX*sx, starty+100/myY*sy, tocolor(255, 255, 255, 200), 0.6/myX*sx, fonts["condensed-20"], "center", "center")
					else
						dxDrawText(v.name, startx, starty, startx+100/myX*sx, starty+100/myY*sy, tocolor(255, 255, 255, 50), 0.5/myX*sx, fonts["condensed-20"], "center", "center")
						dxDrawImage(startx+10/myX*sx, starty+10/myY*sy, 80/myX*sx, 80/myY*sy, "images/"..v.file)
					end

					starty = starty+105/myY*sy

					if k % 4 == 0 then 
						startx = startx + 100/myX*sx
						starty = sy*0.285
					end
				end

				if activeDrink > 0 then 
					dxDrawImage(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy, "images/"..drinks[activeDrink].file)
				end

				dxDrawButton(sx*0.295, sy*0.7, sx*0.14, sy*0.04, r, g, b, 200, "Kiadás", tocolor(255, 255, 255, 255), 0.5/myX*sx, fonts["condensed-20"], true, tocolor(0, 0, 0, 100))
			end
		end

		if moveElement then 
			local cpos = Vector2(getCursorPosition())
			if moveElement[1] == "sauce" then 
				dxDrawImage(sx*cpos.x-60/myX*sx, sy*cpos.y-60/myY*sy, 120/myX*sx, 120/myY*sy, "images/"..sauces[moveElement[2]].file)
			elseif moveElement[1] == "cheese" then 
				dxDrawImage(sx*cpos.x-60/myX*sx, sy*cpos.y-60/myY*sy, 120/myX*sx, 120/myY*sy, "images/"..cheeses[moveElement[2]].file)
			elseif moveElement[1] == "ing" then 
				dxDrawImage(sx*cpos.x-60/myX*sx, sy*cpos.y-60/myY*sy, 120/myX*sx, 120/myY*sy, "images/ings/"..ingredientFiles[moveElement[2]])
			elseif moveElement[1] == "drink" then 
				dxDrawImage(sx*cpos.x-60/myX*sx, sy*cpos.y-60/myY*sy, 120/myX*sx, 120/myY*sy, "images/"..drinks[moveElement[2]].file)
			end
		end
end

function pizzaMakingPanelKey(key, state)
	if key == "mouse1" then 
		if state then 
			if(startedMaking) then
				if(playerAtTable) then

					if core:isInSlot(sx*0.29, sy*0.25+5/myY*sy, 40/myX*sx, 40/myY*sy) then 
						playSound("trash_to_bin.wav")

						onPizzaWidth = 0
						onPizzaSauce = 0
						onPizzaCheese = 0
						wrapButtonTimes = 0
						oldWrapButtonTimes = 0
						wrapButtonTimesTick = 0

						pizzaIngs = {}
					
						pizzaOut = false 
						bakeReady = false
						activeDrink = 0

						sutesIdo = 0
						bakeStarted = false 

						pizzaWrapped = false
						pizzaStatus="Nyers"
					end
					
					if(onPizzaWidth == 0) then
						 -- alap, most kezdődik szószválasztás
						local starty = sy*0.31
							for k, v in ipairs(thicknesses) do 
								if core:isInSlot(sx*0.29+sx*0.15+5/myX*sx, starty, sx*0.25, 120/myY*sy) then 
									onPizzaWidth = k
								end	

								starty = starty+125/myY*sy
							end
					elseif(onPizzaWidth > 0) then -- van rajta szósz
						-- majd még ide kell a törlés

						if(onPizzaSauce == 0) then
							local starty = sy*0.31
							for k, v in ipairs(sauces) do 
	
								if core:isInSlot(sx*0.46, starty, 120/myX*sx, 120/myY*sy) then 
									moveElement = {"sauce", k}
								end
	
								starty = starty+125/myY*sy
							end
						else
							if(onPizzaCheese == 0) then
								local starty = sy*0.31
								for k, v in ipairs(cheeses) do 
									if core:isInSlot(sx*0.46, starty, 120/myX*sx, 120/myY*sy) then 
										if k == 1 then 
											onPizzaCheese = 1
										else
											moveElement = {"cheese", k}
										end
									end

									starty = starty+125/myY*sy
								end
							else
								local starty = sy*0.285
								local startx = sx*0.445
								for k, v in ipairs(ingredients) do 

									if core:isInSlot(startx, starty, 100/myX*sx, 100/myY*sy) then 
										if not (table.contains(pizzaIngs, k)) then
											moveElement = {"ing", k}
										else 
											outputChatBox("#ff9428[Pizza készítő]:#ffffff Ez a feltét már rajta van a pizzán!", 255, 255, 255, true)
										end
									end

									starty = starty+105/myY*sy

									if k % 4 == 0 then 
										startx = startx + 100/myX*sx
										starty = sy*0.285
									end
								end

								if core:isInSlot(sx*0.295, sy*0.7, sx*0.14, sy*0.04) then 
									playerAtTable = false 
									setElementFrozen(localPlayer, false)

									destroyElement(creatorMarker)

									bakeReady = true;
									
									outputChatBox("#ff9428[Pizza készítő]:#ffffff Most, hogy a pizza alapja elkészült, süsd meg.", 0, 0, 0, true)
									outputChatBox("#ff9428[Pizza készítő]:#ffffff De vigyázz, a pizza ne legyen nyers és ne égesd oda!", 0, 0, 0, true)
									pizzaBakeMarker = exports.cosmo_custommarker:createCustomMarker(376.31536865234, -113.79496002197, 1001.4921875, 2.0, 168, 50, 50, 220, "oven")
									setElementDimension(pizzaBakeMarker, playerID)
									setElementInterior(pizzaBakeMarker, 5)
									sutesIdoAlap = 20;
									sutesIng = #pizzaIngs*3;
									sutesIdo = sutesIdoAlap+sutesIng;
								end
							end
						end
					end
				end
			end

			if(orderPos == true) then
				if (not startedMaking) then
					if core:isInSlot(sx*0.83+5/myX*sx, sy*0.677, 250/myX*sx-10/myX*sx, sy*0.03) then 
						if orderText == "Elkészítés" then 
							startedMaking = true
							destroyElement(orderMarker)

							tooltipText = "Az interakcióhoz"
							removeEventHandler("onClientRender", root, interactionRender)
							unbindKey("e", "up", takeOrder)

							outputChatBox("#ff9428[Pizza készítő]:#ffffff Most menj a "..color.."balra #fffffflevő pulthoz, majd kezd el készíteni a pizzát a szükséges hozzávalók alapján.", 0, 0, 0, true)

							creatorMarker = exports.cosmo_custommarker:createCustomMarker(378.88125610352, -114.21686553955, 1001.4921875, 2.0, 245, 167, 66, 255, "pizza")
							setElementDimension(creatorMarker, playerID)
							setElementInterior(creatorMarker, 5)

							theMakingTimePlusTimer()
						end
					end
				end
			end

			if(bakeReady) then
				if(bakeStarted) then
					if(pizzaWrapPanelStatus) then
						if not(pizzaOut) then -- sütés
							if core:isInSlot(sx*0.4+8/myX*sx, sy*0.552, sx*0.2-16/myX*sx, sy*0.04) then -- pizza kivétele
								if isTimer(bakeTimer) then 
									killTimer(bakeTimer)
								end
								pizzaOut = true
								startedWrapping = true
							end
						elseif(pizzaOut) then
							if(startedWrapping) then
								if not (pizzaWrapped) then
									if core:isInSlot(sx*0.4+8/myX*sx, sy*0.552, sx*0.2-16/myX*sx, sy*0.04) then -- csomagolás
										oldWrapButtonTimes = wrapButtonTimes
										wrapButtonTimes = wrapButtonTimes + 1
										wrapButtonTimesTick = getTickCount()
										
										if wrapButtonTimes == 20 then 
											pizzaWrapped = true
										end
									end
								elseif(pizzaWrapped) then -- pizza felvétele csomagolás után
									if core:isInSlot(sx*0.4+8/myX*sx, sy*0.552, sx*0.2-16/myX*sx, sy*0.04) then
										if isElement(pizzaBakeMarker) then 
											destroyElement(pizzaBakeMarker)
										end

										setElementFrozen(localPlayer, false)
										startedWrapping = false
										bakeReady = false
										bakeStarted = false
										pizzaOut = false

										jobEndMarker = exports.cosmo_custommarker:createCustomMarker(376.65289306641, -116.92543029785, 1001.4921875, 2.0, 94, 163, 38, 200, "pizza")
										setElementDimension(jobEndMarker, playerID)
										setElementInterior(jobEndMarker, 5)

										pizzaobj = createObject(2814, 1, 1, 1)
										setElementDimension(pizzaobj, playerID)
										setElementInterior(pizzaobj, 5)

										for k, v in ipairs(carryToggleControlls) do 
											toggleControl(v, false)
										end

										setPedAnimation(localPlayer, "CARRY", "crry_prtial", 0, true, false, true, true)
										exports.cosmo_boneattach:attachElementToBone(pizzaobj, localPlayer, 12, 0.15, -0.05, 0.1, 350, 90, 70)
									end
								end
							end
						end
					end
				end
			end

			if(pizzaIsInCustomersHand) then
				if not (drinkChosen == 0) then
					local starty = sy*0.285
					local startx = sx*0.445
					for k, v in ipairs(drinks) do 
	
							if core:isInSlot(startx, starty, 100/myX*sx, 100/myY*sy) then 
								moveElement = {"drink", k}
							end
	
						starty = starty+105/myY*sy
	
						if k % 4 == 0 then 
							startx = startx + 100/myX*sx
							starty = sy*0.285
						end
					end
				end

				if core:isInSlot(sx*0.295, sy*0.7, sx*0.14, sy*0.04) then -- end job
					endJob()
					startedMaking = false
					orderReady = false
					pizzaIsInCustomersHand = false
				end
			end
		else
			if(startedMaking) then
				if(playerAtTable) then
					if core:isInSlot(sx*0.29+5/myX*sx, sy*0.37, 230/myX*sx, 230/myY*sy) then 
						if moveElement then 
							if moveElement[1] == "sauce" then 
								onPizzaSauce = moveElement[2]
							elseif moveElement[1] == "cheese" then 
								onPizzaCheese = moveElement[2]
							elseif moveElement[1] == "ing" then 
								table.insert(pizzaIngs, #pizzaIngs+1, moveElement[2])
							end
						end
					end
					moveElement = false
				end

				if(pizzaIsInCustomersHand) then
					if not (drinkChosen == 0) then 
						if core:isInSlot(sx*0.29, sy*0.25, sx*0.15, sy*0.5) then 
							if moveElement then 
								activeDrink = moveElement[2]
							end
						end
					end
					moveElement = false
				end
			end
		end
	end
end

orderPos = false;
orderNow = false;
randomChk = math.random(1000,1999)

drinkChosen = 0;

pizzaIsInCustomersHand = false;

howmanyingOnPizza = 0;
playerAtTable = false;
jobTakingPanelStatus = false;
playerHasSkinStatus = false;
orderReady = false;
startedMaking = false;

sauce = 0;
thickness = 0;
cheese = 0;

makingTime = 0;

orderText = "Elkészítem";
makedPizzas = 1;

pizzaOut = false;
startedWrapping = false;
bakeStarted = false;

onPizzaSauce = 0;
pizzaWidth = 0;
onPizzaCheese = 0;
onPizzaWidth = 0

pizzaStatus ="Nyers";

active_ings = {}

wrapButtonTimes = 0;
oldWrapButtonTimes = 0
wrapButtonTimesTick = 0
pizzaWrapped = false;
pizzaWrapPanelStatus = false;
bakeReady = false

sutesIdo = 0

activeDrink = 0

elvartIdo = 0

function choosePizzaIngs()
	startedMaking = false

	sauce = math.random(#sauces)
	if(sauce == 1) then
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Paradicsomos szósszal kérném.", 50, 255, 50, true)
	elseif(sauce == 2) then
		outputChatBox("#ff9428[Pizza készítő]:#ffffff BBQ szósszal kérném.", 50, 255, 50, true)
	elseif(sauce == 3) then
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Tejfölös szósszal kérném.", 50, 255, 50, true)
	end
		
	setTimer(function() 
		thickness = math.random(#thicknesses)
		if(thickness == 1) then
			outputChatBox("#ff9428[Pizza készítő]:#ffffff Vékony tésztával.", 50, 255, 50, true)
		elseif(thickness == 2) then
			outputChatBox("#ff9428[Pizza készítő]:#ffffff Normál tésztával.", 50, 255, 50, true)
		elseif(thickness == 3) then
			outputChatBox("#ff9428[Pizza készítő]:#ffffff Vastag tésztával.", 50, 255, 50, true)
		end

		setTimer(function() 
			cheese = math.random(#cheeses)
			if(cheese == 1) then
				outputChatBox("#ff9428[Pizza készítő]:#ffffff Sajt nélkül.", 50, 255, 50, true)
			elseif(cheese == 2) then
				outputChatBox("#ff9428[Pizza készítő]:#ffffff Sima, normál mozzarella sajttal.", 50, 255, 50, true)
			elseif(cheese == 3) then
				outputChatBox("#ff9428[Pizza készítő]:#ffffff Extra sok sajttal kérném.", 50, 255, 50, true)
			end

			setTimer(function() 
				drinkChosen = math.random(0, #drinks)
				if drinkChosen == 0 then 
					outputChatBox("#ff9428[Pizza készítő]:#ffffff Italt nem kérek.", 50, 255, 50, true)
				else
					outputChatBox("#ff9428[Pizza készítő]:#ffffff Italnak pedig egy "..color..drinks[drinkChosen].name.."#ffffff-at/et kérnék!", 50, 255, 50, true)
				end


				local choosableIngs = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}

				local random = math.random(2, 8)
				for i = 1, random do 
					setTimer(function() 
						local randomNum = math.random(#choosableIngs)
						local randomIng = choosableIngs[randomNum]
						table.remove(choosableIngs, randomNum)
						table.insert(active_ings, #active_ings+1, randomIng)

						local randText = ing_texts[randomIng][math.random(#ing_texts[randomIng])]

						outputChatBox("#ff9428[Pizza készítő]:#ffffff "..randText, 255, 255, 255, true)

						if i == random then 
							orderText = "Elkészítés"
							setPedAnimation(customer)

							elvartIdo = ((#active_ings*15) + 20)
						end
					end, i*1000, 1)
				end
			end, 1000, 1)
		end, 1000, 1)
	end, 1000, 1)
end

addEventHandler("onClientMarkerHit", root,
	function(player, dimensionmatch)
		if player == localPlayer then 
			if(dimensionmatch) then
				if source == enterMarker then 
					tooltipText = "A belépéshez"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", warpToInt)
				elseif source == skinMarker then 
					tooltipText = "A munkaruha felvételéhez"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", pickUpWorkSkin)
				elseif source == orderMarker then 
					tooltipText = "A rendelés felvételéhez"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", takeOrder)
				elseif source == creatorMarker then 
					tooltipText = "A kezdéshez"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", startPizzaMaking)
				elseif source == pizzaBakeMarker then 
					tooltipText = "A sütés elkezdéséhez"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", startPizzaBaking)
				elseif source == jobEndMarker then 
					tooltipText = "Az átadáshoz"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", givePizzaToGuest)
				elseif source == enterMarker2 then 
					tooltipText = "A belépéshez"
					addEventHandler("onClientRender", root, interactionRender)
					bindKey("e", "up", warpToInt)
				end
			end
		end
	end
);

addEventHandler("onClientMarkerLeave", root,
	function(player, dimensionmatch)
		if player == localPlayer then 
			if(dimensionmatch) then
				if source ==  enterMarker then
					unbindKey("e", "up", warpToInt)
					removeEventHandler("onClientRender", root, interactionRender)
					tooltipText = "Az interakcióhoz"
				elseif source == skinMarker then 
					tooltipText = "Az interakcióhoz"
					removeEventHandler("onClientRender", root, interactionRender)
					unbindKey("e", "up", pickUpWorkSkin)
				elseif source == orderMarker then 
					tooltipText = "Az interakcióhoz"
					removeEventHandler("onClientRender", root, interactionRender)
					unbindKey("e", "up", takeOrder)
				elseif source == creatorMarker then 
					tooltipText = "Az interakcióhoz"
					removeEventHandler("onClientRender", root, interactionRender)
					unbindKey("e", "up", startPizzaMaking)
				elseif source == pizzaBakeMarker then 
					tooltipText = "Az interakcióhoz"
					removeEventHandler("onClientRender", root, interactionRender)
					unbindKey("e", "up", startPizzaBaking)
				elseif source == jobEndMarker then 
					tooltipText = "Az interakcióhoz"
					removeEventHandler("onClientRender", root, interactionRender)
					unbindKey("e", "up", givePizzaToGuest)
				elseif source == enterMarker2 then 
					unbindKey("e", "up", warpToInt)
					removeEventHandler("onClientRender", root, interactionRender)
					tooltipText = "Az interakcióhoz"
				end
			end
		end
	end
);

function interactionRender()
    dxDrawShadowedText(tooltipText.." nyomd meg az "..color.."[E] #ffffffgombot.", 0, sy*0.89, sx, sy*0.89+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 0.9/myX*sx, fonts["condensed-14"], "center", "center", false, false, false, true)
end

local startX, startY, startZ 

function warpToInt()
	addEventHandler("onClientRender", getRootElement(), render)
	addEventHandler("onClientKey", root, pizzaMakingPanelKey)
	removeEventHandler("onClientRender", root, interactionRender)
	tooltipText = "Az interakcióhoz"

	startX, startY, startZ = getElementPosition(localPlayer)
	setElementData(localPlayer, "pizza > startOutPos", {startX, startY, startZ })
	triggerServerEvent("pizza > setPlayerStartPos", resourceRoot)
	playerID = getElementData(localPlayer, "playerID")

	setElementData(localPlayer, "pizza:isPlayerInInt", true)

	setElementPosition(localPlayer, 368.99938964844, -115.02285003662, 1001.4995117188)
	setElementInterior(localPlayer, 5)
	setElementDimension(localPlayer, playerID)

	skinMarker =  exports.cosmo_custommarker:createCustomMarker(370.60638427734, -117.57601165771, 1001.4921875, 2.0, 200, 50, 0, 150, "shirt")
	setElementDimension(skinMarker, playerID)
	setElementInterior(skinMarker, 5)

	orderMarker = exports.cosmo_custommarker:createCustomMarker(376.69171142578, -116.91826629639, 1001.4921875, 2.0,  200, 50, 0, 150, "pizza")
	setElementDimension(orderMarker, playerID)
	setElementInterior(orderMarker, 5)

	obj1 = createObject(8681, 379.52008056641, -118.00287628174, 1002.521484375, 0, 0, 90)
	setElementDimension(obj1, playerID)
	setElementInterior(obj1, 5)
	setElementAlpha(obj1, 0)

	obj2 = createObject(8681, 370.52008056641, -118.00287628174, 1002.521484375, 0, 0, 90)
	setElementDimension(obj2, playerID)
	setElementInterior(obj2, 5)
	setElementAlpha(obj2, 0)
end

function warpPedOutOfInterior()
	setPedAnimation(localPlayer)
	setElementFrozen(localPlayer, false)

	removeEventHandler("onClientKey", root, pizzaMakingPanelKey)
	removeEventHandler("onClientRender", getRootElement(), render)
	setElementData(localPlayer, "pizza:isPlayerInInt", false)

	local start = getElementData(localPlayer, "pizza > startOutPos")
	setElementPosition(localPlayer, unpack(start))

	setElementInterior(localPlayer, 0)
	setElementDimension(localPlayer, 0)

	if isElement(skinMarker) then 
		destroyElement(skinMarker)
	end

	if isElement(orderMarker) then 
		destroyElement(orderMarker) 
	end

	if isElement(obj1) then 
		destroyElement(obj1)
	end

	if isElement(obj2) then 
		destroyElement(obj2) 
	end

	if isElement(customer) then 
		destroyElement(customer)
	end
end

function pickUpWorkSkin()
	if not (getElementModel(localPlayer) == 155) then 
		setElementData(localPlayer, "pizza:startSkin", getElementModel(localPlayer))
		setElementModel(localPlayer, 155)
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Sikeresen felvetted a munkaruhádat!", 255, 255, 255, true)
	else
		if (not orderPos) and (not isElement(customer)) then 
			startedMaking = false
			orderPos = false
			setElementModel(localPlayer, getElementData(localPlayer, "pizza:startSkin"))
			outputChatBox("#ff9428[Pizza készítő]:#ffffff Sikeresen leadtad a munkaruhádat!", 255, 255, 255, true)
			warpPedOutOfInterior()
		else
			outputChatBox("#ff9428[Pizza készítő]:#ffffff Munka közben nem adhatod le a munkaruhádat!", 255, 255, 255, true)
		end
	end
end

function takeOrder()
	if getElementModel(localPlayer) == 155 then 
		if not orderNow then 
			randomChk = math.random(1000,1999)
			exports.cosmo_hud:showInfobox("info", "Érkezik a következő vendég!")
			outputChatBox("#ff9428[Pizza készítő]:#ffffff Érkezik a következő vendég.", 0, 0, 0, true)

			randomChk = math.random(1000,1999)
			orderNow = true;

			orderText = "*Vendég érkezik*"
			customer = createPed(skins[math.random(#skins)], 371.20880126953, -132.11357116699, 1001.4921875)

			setElementInterior(customer, 5)
			setElementDimension(customer, playerID)

			--local skin = getElementModel(customer)
			--setPedAnimation(customer, walks[skin].group, walks[skin].name)

			startedMaking = false

			setPedAnimation(customer, "ped", "walk_civi")

			setTimer(function()
				setElementRotation(customer, 0, 0, 270)
				setTimer(function()
					setElementRotation(customer, 0, 0, 0)
					setTimer(function() 
						setPedAnimation(customer, "GHANDS", "gsign3")
						outputChatBox("#ff9428[Pizza készítő]:#ffffff Helló. Szeretnék kérni egy pizzát.", 50, 255, 50, true)
						orderText = "*Rendelés alatt*"
						choosePizzaIngs()

						orderPos = true
					end, 500, 1)
				end, 3500, 1)
			end, 8000, 1)
		end
	else
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Előbb vedd fel a munkaruhádat!", 255, 255, 255, true)
	end
end

function startPizzaMaking()
	tooltipText = "Az interakcióhoz"
	removeEventHandler("onClientRender", root, interactionRender)
	unbindKey("e", "up", startPizzaMaking)

	playerAtTable = true 
	setElementFrozen(localPlayer, true)
end

function startPizzaBaking()
	tooltipText = "Az interakcióhoz"
	removeEventHandler("onClientRender", root, interactionRender)
	unbindKey("e", "up", startPizzaBaking)

	bakeStarted = true
	pizzaWrapPanelStatus = true

	setElementFrozen(localPlayer, true)
	outputChatBox("#ff9428[Pizza készítő]:#ffffff A pizzát elkezdted sütni, vedd ki, amikor "..color.."optimális#FFFFFF az állapota.", 0, 0, 0, true)

	bakeTimer = setTimer(function()
		if(sutesIdo >= 10)	then
			pizzaStatus="Nyers";
		elseif(sutesIdo <= 9 and sutesIdo >= 3) then
			pizzaStatus ="Félkész"
		elseif(sutesIdo <= 2 and sutesIdo >= -10) then
			pizzaStatus ="Optimális"
		elseif(sutesIdo < -10 ) then
			pizzaStatus ="Odaégett"
		end
		sutesIdo = sutesIdo-1;
		if(sutesIdo == -20) then
			killTimer(bakeTimer)
			outputChatBox("\n"..szin.."[Pizza készítő]#FFFFFF A pizza nagyon odaégett, későn vetted ki.\n"..szin.. "[Pizza készítő] #FFFFFFMost már nincs idő újat készíteni, csomagold be és add ki.", 0, 0, 0, true)
			pizzaOut = true
			orderText = "Becsomagolom"
			startedWrapping = true
			pizzaStatus = 4
		end
	end, 1000, sutesIdo+21)	
end

function givePizzaToGuest()
	setElementFrozen(localPlayer, true)
	destroyElement(pizzaobj)
	setPedAnimation(localPlayer, "", "")

	pizzaIsInCustomersHand = true

	if drinkChosen == 0 then 
		endJob()
	end

	for k, v in ipairs(carryToggleControlls) do 
		toggleControl(v, true)
	end
end

function endJob()
	exports.cosmo_hud:showInfobox("success", "Sikeresen átadtad a pizzát! (Részeletek a chatboxban)")
	local payment = 0

	if (onPizzaWidth == thickness) then 
		payment = payment + 100000
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Megfelelő tészta!", 255, 255, 255, true)
	else
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Nem ilyen pizzatésztát kértem!", 255, 255, 255, true)
	end

	if (onPizzaSauce == sauce) then 
		payment = payment + 100000
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Megfelelő szósz!", 255, 255, 255, true)
	else
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Nem ilyen szószt kértem!", 255, 255, 255, true)
	end

	if (onPizzaCheese == cheese) then 
		payment = payment + 100000
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Megfelelő sajt!", 255, 255, 255, true)
	else
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Nem ilyen sajtot kértem!", 255, 255, 255, true)
	end

	if (drinkChosen == activeDrink) then 
		payment = payment + 100000
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Megfelelő üdítő!", 255, 255, 255, true)
	else
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Nem ezt az üdítőt kértem!", 255, 255, 255, true)
	end

	if pizzaStatus == "Optimális" then 
		payment = payment + 100000
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Ez a pizzatészta kiváló!", 255, 255, 255, true)

		local idobonusz = elvartIdo - makingTime 

		if idobonusz > 0 then 
			payment = idobonusz + idobonusz * 120

			outputChatBox("#ff9428[Pizza készítő]:#ffffff Mivel az elvártnál hamarabb végeztél kaptál "..color..idobonusz.."$#ffffff borravalót.", 255, 255, 255, true)
		end
	elseif pizzaStatus == "Félkész" then 
		payment = payment + 100000
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Ez a pizzatészta félkész!", 255, 255, 255, true)
	elseif pizzaStatus == "Odaégett" then 
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Ez a pizzatészta odaégett!", 255, 255, 255, true)
	elseif pizzaStatus == "Nyers" then 
		outputChatBox("#ff9428[Pizza készítő]:#ffffff Ez a pizzatészta nyers!", 255, 255, 255, true)
	end

	local egyezett = 0 
	for k, v in ipairs(pizzaIngs) do
		if table.contains(active_ings, v) then 
			egyezett = egyezett + 1
		else 
			egyezett = egyezett - 1
		end 
	end

	local egyezesSzazalek = egyezett/#active_ings
	local egyezesSzazalek2 = math.floor(egyezesSzazalek * 100)

	local egyezesFizetes = (#active_ings*34) * egyezesSzazalek

	outputChatBox("#ff9428[Pizza készítő]:#ffffff A pizza feltétei "..color..egyezesSzazalek2.."#ffffff%-ban egyeztek a megrendeléssel.", 255, 255, 255, true)

	payment = payment + egyezesFizetes

	if payment then
		payment = payment * 2
	end

	outputChatBox("#ff9428[Pizza készítő]:#ffffff Az összes fizetésed: "..color..payment.."$#ffffff.", 255, 255, 255, true)

	triggerServerEvent("pizza > giveMoney", resourceRoot, payment)

	orderPos = false 
	orderNow = false

	setElementFrozen(localPlayer, false)
	setPedAnimation(localPlayer, "", "")

	walkPedOut()

	destroyElement(jobEndMarker)
	tooltipText = "Az interakcióhoz"
	removeEventHandler("onClientRender", root, interactionRender)
	unbindKey("e", "up", givePizzaToGuest)

	onPizzaWidth = 0
	onPizzaSauce = 0
	onPizzaCheese = 0
	thickness = 0
	sauce = 0
	cheese = 0
	drinkChosen = 0
	makingTime = 0

	wrapButtonTimes = 0
	oldWrapButtonTimes = 0
	wrapButtonTimesTick = 0

	killTimer(makingTimePlusTimer)

	pizzaIngs = {}
	active_ings = {}

	makedPizzas = makedPizzas + 1

	pizzaIsInCustomersHand = false 
	pizzaOut = false 
	bakeReady = false
	activeDrink = 0

	sutesIdo = 0

	pizzaOut = false 
	bakeStarted = false 

	pizzaWrapped = false
	pizzaStatus="Nyers"
end

function walkPedOut()
	setPedAnimation(customer, "ped", "walk_civi")
	setElementRotation(customer, 0, 0, 180)

	setTimer(function()
		setElementRotation(customer, 0, 0, 90)

		setTimer(function()
			setElementRotation(customer, 0, 0, 180)

			setTimer(function()
				destroyElement(customer)

				orderMarker = exports.cosmo_custommarker:createCustomMarker(376.69171142578, -116.91826629639, 1001.4921875, 2.0,  200, 50, 0, 150, "pizza")
				setElementDimension(orderMarker, playerID)
				setElementInterior(orderMarker, 5)
			end, 1000, 1)
		end, 2500, 1)
	end, 8000, 1)
end

function makingTimePlus()
	makingTime = makingTime+1;
end

function theMakingTimePlusTimer()
	makingTimePlusTimer = setTimer(makingTimePlus, 1000, 0)
end