addEvent("setPedFightingStyle", true)
addEventHandler("setPedFightingStyle", getRootElement(),
	function (fightStyle)
		if isElement(source) then
			setPedFightingStyle(source, fightStyle)
			setElementData(source, "fightStyle", fightStyle)
		end
	end
)

addEvent("setPedWalkingStyle", true)
addEventHandler("setPedWalkingStyle", getRootElement(),
	function (walkStyle)
		if isElement(source) then
			setPedWalkingStyle(source, walkStyle)
		end
	end
)

addEvent("talkingAnim", true)
addEventHandler("talkingAnim", getRootElement(),
	function (sayStyle)
		if isElement(source) then
			setPedAnimation(source, sayStyle)
		end
	end
)

addEvent("kickPlayerCuzScreenSize", true)
addEventHandler("kickPlayerCuzScreenSize", getRootElement(),
	function ()
		kickPlayer(source, "Nem megfelelő képernyőfelbontás! (Minimum 1024x768)")
	end
)