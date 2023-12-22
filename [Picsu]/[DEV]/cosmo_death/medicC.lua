
function registerEvent(event, element, xfunction)
    addEvent(event, true)
    addEventHandler(event, element, xfunction)
end

local targetedPlayer = nil

registerEvent("cosmo_medicC:playerHeal", root, function(targetPlayer)
	targetedPlayer = nil
    if targetPlayer then
        if not isPedDead(targetPlayer) then
			targetedPlayer = targetPlayer
            exports.cosmo_minigames:startMinigame("buttons", "healSuccess", "healFailed", 0.27, 0.75, 175, 40)
        else
            outputChatBox(exports.cosmo_core:getServerTag("info") .. "A páciens halott.", 0, 0, 0, true)
        end
    end
end)

registerEvent("healSuccess", root, function(player)	
    triggerServerEvent("cosmo_medicS:healPlayer", player, targetedPlayer, player)
    --triggerServerEvent("cosmo_medicS", player)
end)

registerEvent("healFailed", root, function(player)
    exports.cosmo_hud:showAlert("error", "Sikertelen ellátás!", "Nem sikerült az ellátást szakszerűen végrehajtanod")
end)