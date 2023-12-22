if fileExists("sourceC.lua") then
	fileDelete("sourceC.lua")
end

local renderData = {}
players = {}
local Key = "TAB"
local scoreboardState = false
local maxRows = 10 
local Distance = 35
local currentRow = 1
local movingcounter = 1
local Tick = nil
local Time = nil
local imgAlpha = 0
local s = {guiGetScreenSize()}
local box = {400,470}
local line = {397, 10}
local pos = {s[1]/2 -box[1]/2,s[2]/2 - box[2]/2}
local position = {s[1]/2 -box[1]/2,s[2]/2 - box[2]/2 + 35}
local posis = {s[1]/2 -box[1]/2,s[2]/2 - box[2]/2 + 40}
local bgMargin = 2
local customFont = exports.cosmo_assets:loadFont("roboto.ttf", 11 * 2, false),


bindKey(Key, "down", 
	function() 
		if getElementData(localPlayer, "loggedIn") then	
			Tick = getTickCount()
			scoreboardState = true
            imgAlpha = 0
            currentRow = 1
          --  setGameSpeed(0.6)
			addEventHandler("onClientRender", getRootElement(), renderScoreboard)
			executeCommandHandler("togbar")
			setElementData(localPlayer, "toghud",false)
            players = {}
            for k, v in pairs(getElementsByType("player")) do 
			    players[k] = v
		    end
            table.sort(players, function(a, b)
		        if a ~= localPlayer and b ~= localPlayer and getElementData(a, "playerID") and getElementData(b, "playerID" ) then
                    return tonumber(getElementData(a, "playerID") or 0) < tonumber(getElementData(b, "playerID") or 0)
                end
            end)
		end
	end
)

bindKey(Key, "up", 
	function() 
		if getElementData(localPlayer, "loggedIn") then	
			scoreboardState = false
			showChat(true)
           -- setGameSpeed(1)
			removeEventHandler("onClientRender", getRootElement(), renderScoreboard)
            executeCommandHandler("togbar")
            setElementData(localPlayer, "hudVisible",true)
            players = {}
		end
	end		
)

setTimer(
    function()
        if scoreboardState then
            players = {}
            for k, v in pairs(getElementsByType("player")) do 
			    players[k] = v
		    end
            table.sort(players, function(a, b)
		        if a ~= localPlayer and b ~= localPlayer and getElementData(a, "playerID") and getElementData(b, "playerID" ) then
                    return tonumber(getElementData(a, "playerID") or 0) < tonumber(getElementData(b, "playerID") or 0)
                end
            end)
        end
    end, 500, 0
)

function renderScoreboard()
	if scoreboardState then
        
        
        imgAlpha = imgAlpha + 2
		if imgAlpha >= 1000 then 
			imgAlpha = 0
		end
           
		dxDrawImage (pos[1]+150, pos[2]-100, 100, 100, ':cosmo_hud/files/logo.png') -- LOGO
    	dxDrawText("#ff9428 Online: #FFFFFF"..getCurrentPlayers().."/200", pos[1]+295,position[2]-25, 0, 0, tocolor(255, 255, 255, 200), 0.50, customFont, "left", "top", false, false, true, true, true) -- Playerszám
		dxDrawRectangle(pos[1]+2, pos[2]+5, 396, 30, tocolor(0,0,0,220)) -- Fekete Háttér
		dxDrawText("#ff9428CosmoMTA#ffffff scoreboard",pos[1]+7.5,pos[2]+10,0,0,tocolor(255, 148, 40, 255),0.50,customFont,"left","top",true,true,true,true) -- Text
		dxDrawRectangle(pos[1]+2, position[2], box[1]-3.8, 2, tocolor(255, 148, 40, 255)) -- Piros csík

		dxDrawRectangle(pos[1]+2, position[2], box[1]-4, 420, tocolor(0, 0, 0, 170)) --Szürke rész
        
        latestLine = currentRow + maxRows + 1
	    counter = 0  
		for k,v in pairs(players) do
			if k >= currentRow then
		    	if k <= latestLine then
		        	counter = counter + 1
					if getElementData(v, "loggedIn") == 0 then
						alpha = 60
					else
						alpha = 200
					end
					dxDrawRectangle(pos[1]+4, position[2]+2 + (Distance * (counter)-36), box[1]-8, 28, tocolor(0, 0, 0, 50))
					local name = nil 
					if (getElementData(v, "loggedIn")) then
					    name = getPlayerName(v):gsub("_", " ")
				    else
				    	name = getPlayerName(v):gsub("_", " ")
                    end
					
                    local ping = nil 
					if (getElementData(v, "loggedIn")) then
						ping = "Ping: "..getPlayerPing(v)
					else
					    ping= ""
					end
                    
                   local mins = nil
                   if (getElementData(v, "loggedIn")) then
					    mins = "LVL: "..exports.cosmo_core:getLevel(v)
                    else
                        mins = "Nincs bejelentkezve"
                    end
                    
                    --local pp  = getElementData(v, "premiumpoints")
					local adminduty = getElementData(v, "adminDuty")
					if (adminduty) and (adminduty) then
						color = ""
            
						name =  exports.cosmo_core:getAdminLevelColor( getElementData(v, "acc.adminLevel") ) .. "(" .. exports.cosmo_core:getPlayerAdminTitleByLevel(getElementData(v, "acc.adminLevel")) .. ") " .. color .. getElementData(v, "acc.adminNick")
					else 
						color = "#ffffff"
					end
					local asduty = getElementData(v, "helperDuty")
					local isPlayerAS = getElementData(v, "acc.helperLevel") or 0

					if (isPlayerAS >= 1) then
						color = ""
            
						name = exports.cosmo_core:getHelperLevelColor( getElementData(v, "acc.helperLevel") ) .. "(" .. exports.cosmo_core:getPlayerHelperTitleByLevel(getElementData(v, "acc.helperLevel")) .. ") " .. color .. getPlayerName(v):gsub("_", " ")
					elseif not (isPlayerAS) then 
						color = "#ffffff"

					end
					dxDrawText ("ID: " ..getElementData(v, "playerID"), pos[1] + 10, posis[2] + (Distance * (counter - 1)), 0, 0, tocolor(255, 255, 255, 230), 0.5, customFont, "left", "top", false, false, true, true)
					dxDrawText (color..name, pos[1] + 55, posis[2] + (Distance * (counter - 1)), 0,0 , tocolor(255, 255, 255, 230), 0.5, customFont, "left", "top", false, false, true, true)
				    dxDrawText (mins, pos[1] + 250, posis[2] + (Distance * (counter - 1)), 0,0 , tocolor(255,255,255,230), 0.5, customFont, "left", "top", false, false, true, true)
				    dxDrawText (ping, pos[1] + 340, posis[2] + (Distance * (counter - 1)), 0,0, tocolor(255,255,255,230), 0.5, customFont, "left", "top", false, false, true, true)
                    if (tonumber(getElementData(v, "loggedIn"))) == 1 then
				    else
				    end
				end
		    end
		end
	end
end

addEventHandler("onClientPlayerQuit", getRootElement(), 
	function() 
		if source then
			players[source] = nil
		end
	end
)

function getCurrentPlayers()
	--local counter = 0
	--for k, v in pairs(getElementsByType("player")) do
	--	counter = counter + 1
	--end 
	return #getElementsByType("player")
end

bindKey("mouse_wheel_down", "down", 
	function() 
		if scoreboardState then
			if currentRow < #players - 11 then
				currentRow = currentRow + 1		
			end
		end
	end
)

bindKey("mouse_wheel_up", "down", 
	function() 
		if scoreboardState then
			if currentRow > 1 then
				currentRow = currentRow - 1		
			end
		end
	end
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

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) 
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true)
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) 
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true) 
    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, false, false, false, true)
end

function convertNumber ( number )  
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')    
		if ( k==0 ) then      
			break   
		end  
	end  
	return formatted
end
