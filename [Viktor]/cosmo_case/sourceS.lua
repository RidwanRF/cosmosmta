addEvent("giveWinnedItem", true)
addEventHandler("giveWinnedItem", root,
    function (playerElement, caseType, winnedItem)
        if isElement(playerElement) and availableCases[caseType] then
            exports.cosmo_inventory:giveItem(playerElement, winnedItem[1], 1)
        end
    end
)