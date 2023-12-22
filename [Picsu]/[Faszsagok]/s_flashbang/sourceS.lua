
local flashbangEnabled = {};



addEventHandler ("onResourceStart", getResourceRootElement(getThisResource()),
	function ()
		local players = getElementsByType ("player", getRootElement ());
		for i,j in ipairs (players) do
			flashbangEnabled [j] = true;
		end;
	end);

addEventHandler ("onPlayerJoin", getRootElement (),
	function ()
		flashbangEnabled [source] = true;
	end);

addEventHandler ("onPlayerQuit", getRootElement (),
	function () 
		flashbangEnabled [source] = nil;
	end);

addEvent ("onClientRequestPlayerData", true);
addEventHandler ("onClientRequestPlayerData", getRootElement (), 
	function ()
		triggerClientEvent (source, "onPlayerToggleFlashbangGranade", getRootElement (),
			flashbangEnabled);
	end);
	
addEvent ("onPlayerToggleFlashbangGranade", true);
addEventHandler ("onPlayerToggleFlashbangGranade", getRootElement (),	
	function (state) 
		flashbangEnabled [source] = state;
		triggerClientEvent (getRootElement (), "onPlayerToggleFlashbangGranade", source, state);
	end);
	
-- exported function.
-- toggleFlashbangGranade (player or ped) 
function toggleFlashbangGranade (player, state) 
	if (player == nil) or (not isElement (player)) then 
		outputDebugString ("Bad Argument @ \"toggleFlashbangGranade\" [Expected element at argument 1, got " .. type (player) .. "]",2);
		return;
	end;
	if getElementType (player) ~= "player" then 
		outputDebugString ("Bad Argument @ \"toggleFlashbangGranade\" [Expected element (player) at argument 1, got " .. getElementType (player) .. " element]",2);
		return;
	end;
	if type (state) ~= "boolean" then 
		outputDebugString ("Bad Argument @ \"toggleFlashbangGranade\" [Expected boolean at argument 2, got " .. type (state) .. "]",2);
		return;
	end;
	flashbangEnabled [player] = state;
	triggerClientEvent (getRootElement (), "onPlayerToggleFlashbangGranade", player, state);
end;

addCommandHandler ("toggle", 
	function (thePlayer, theCommand)
		toggleFlashbangGranade (thePlayer, not flashbangEnabled [thePlayer]);
	end);