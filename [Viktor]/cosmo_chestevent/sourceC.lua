-- addEventHandler("onClientResourceStart", getResourceRootElement(), function()
-- 	col = engineLoadCOL( "egg.col" )
-- 	txd = engineLoadTXD( "egg.txd" )
-- 	dff = engineLoadDFF( "egg.dff", 0 )

-- 	engineReplaceCOL( col, 10442 )
-- 	engineImportTXD( txd, 10442 )
-- 	engineReplaceModel( dff, 10442 )
-- end)

local gotEgg = {}
function handleClick ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if ( clickedElement ) then
    	if getElementData(clickedElement, "specialChest") and not gotEgg[getElementID(clickedElement)] then
    		gotEgg[getElementID(clickedElement)] = true
    		triggerServerEvent("clickChest", localPlayer, getElementID(clickedElement))
		end
    end
end
addEventHandler ( "onClientClick", getRootElement(), handleClick )

addEvent("allowChest", true)
addEventHandler("allowChest", getRootElement(), function(eggId)
	gotEgg[eggId] = false
end)