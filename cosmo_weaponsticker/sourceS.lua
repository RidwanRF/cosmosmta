function setStickerOnWeapon(player,shader,image, eleres)
	exports.cosmo_dclog:sendDiscordMessage("[WEAPONSTICKER - DEBUG] SHADER : "..image.. " WEAPON : " ..eleres, "anticheat")
	triggerClientEvent(getRootElement(), "setWeaponStickerC", getRootElement(), player, shader, image, eleres)
end

function removeWeaponStickers(player)
	triggerClientEvent(getRootElement(), "removeWeaponStickerC", getRootElement(), player)
end

function setObjectPaintjob(object,shader,image, eleres)
	triggerClientEvent(getRootElement(), "setObjectPaintjobC", getRootElement(), object, shader, image, eleres)
end
addEvent("setObjectPaintjob", true)
addEventHandler("setObjectPaintjob", getRootElement(), setObjectPaintjob)

function removeStickerFromObject(object)
	triggerClientEvent(getRootElement(), "removeStickerFromObjectC", getRootElement(), object)
end
