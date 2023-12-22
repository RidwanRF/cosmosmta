addEvent("bincoBuy", true)
addEventHandler("bincoBuy", getRootElement(),
	function (buyPrice, skinId)
		if isElement(source) then
			if buyPrice and skinId then
				if exports.cosmo_core:takeMoney(source, buyPrice, "bincoBuy") then
					setElementModel(source, skinId)
					setElementData(source, "char.skin", skinId)
					triggerClientEvent(source, "bincoBuy", source, skinId)
				else
					exports.cosmo_hud:showInfobox(source, "error", "Nincs elég pénzed!")
				end
			end
		end
	end
)

addEvent("setPlayerDimensionForBinco", true)
addEventHandler("setPlayerDimensionForBinco", getRootElement(),
	function(dimension)
		if isElement(source) then
			if dimension then
				setElementDimension(source, dimension)
			end
		end
	end
)