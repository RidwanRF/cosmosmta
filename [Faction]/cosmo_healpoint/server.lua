function healPlayer(playerElement,price)
	if isElement(playerElement) then
		setElementHealth(playerElement, 100)
        setElementData(playerElement, "isPlayerDeath", false)
        setElementData(playerElement, "bulletDamages", false)
        setElementData(playerElement, "char.bone", {true, true, true, true, true})
        setElementData(playerElement, "bloodLevel", 100)
        setElementData(playerElement, "deathReason", false)
        setElementData(playerElement, "customDeath", false)
		setElementData(playerElement, "char.Money",getElementData(playerElement, "char.Money")-price)
	end
end

addEvent("healingPlayer", true)
addEventHandler("healingPlayer", getRootElement(),
	function (sourcePlayer,price)
		if isElement(sourcePlayer) then
			healPlayer(sourcePlayer,price)
		end
	end
)