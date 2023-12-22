local registerEvent = function(eventName, element, func)
	addEvent(eventName, true)
	addEventHandler(eventName, element, func)
end

registerEvent("cosmo_licensesS:giveDocument", root, function(docID, data, money)
    if docID and data then
        if docID == 112 then
            if exports.cosmo_core:takeMoney(source,  money) then
                exports.cosmo_inventory:giveItem(source, docID, 1, toJSON(data), nil, nil)
            else
                exports["cosmo_alert"]:showAlert(source, "error", "Nincs elég pénzed")
            end
		elseif docID == 263 then
            if exports.cosmo_core:takeMoney(source,  money) then
                exports.cosmo_inventory:giveItem(source, docID, 1, toJSON(data), nil, nil)
            else
                exports["cosmo_alert"]:showAlert(source, "error", "Nincs elég pénzed")
            end
        elseif docID == 111 then
            local itemData = exports.cosmo_inventory:hasItemWithData(source, 113, "data2", "vezetés-gyakorlat")
            if itemData and (itemData.data1 or itemData.data1 == 1) and itemData.data2 == "vezetés-gyakorlat" and tonumber(itemData.data3) == getElementData(source, "char.ID") then
                if exports.cosmo_core:takeMoney(source,  money) then
                    --exports.cosmo_inventory:removeItemByData(source, 113, "data1", true)
                    exports.cosmo_inventory:removeItemByData(source, 113, "data2", "vezetés-gyakorlat")
                    exports.cosmo_inventory:removeItemByData(source, 113, "data2", "vezetés-elmélet")
                    exports.cosmo_inventory:giveItem(source, docID, 1, toJSON(data), nil, nil)
                else
                    exports["cosmo_alert"]:showAlert(source, "error", "Nincs elég pénzed")
                end
            else
                exports["cosmo_alert"]:showAlert(source, "error", "Névre szóló vizsga záradék nélkül nem", "válthatod ki a jogosítványodat")
            end
        end
    end
end)

