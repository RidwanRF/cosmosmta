local nextInteriorReport = false
local notReportedInteriors = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		nextInteriorReport = getElementData(resourceRoot, "nextInteriorReport")
		notReportedInteriors = getElementData(localPlayer, "notReportedInteriors")

		if nextInteriorReport and notReportedInteriors then
			announceInteriorReport()
		end
	end
)

function announceInteriorReport()
	local interiorCount = 0

	for k, v in pairs(notReportedInteriors) do
		interiorCount = interiorCount + 1
	end

	if interiorCount > 0 then
		outputChatBox("#d75959[CosmoMTA]: #ffffffBe nem jelentett ingatlanjaid: #d75959" .. interiorCount .. " db", 255, 255, 255, true)
		outputChatBox("#d75959[CosmoMTA]: #ffffffNe felejtsd el a #598ed7városházán#ffffff bejelenteni azokat!", 255, 255, 255, true)
		outputChatBox("#d75959[CosmoMTA]: #ffffffIngatlanok bejelentésének határideje: #3d7abc" .. table.concat(nextInteriorReport, ". ") .. ". 00:00#ffffff.", 255, 255, 255, true)
	end
end

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "notReportedInteriors" then
			nextInteriorReport = getElementData(resourceRoot, "nextInteriorReport")
			notReportedInteriors = getElementData(localPlayer, "notReportedInteriors")

			if nextInteriorReport and notReportedInteriors then
				announceInteriorReport()
			end
		end
	end
)

function npcTalk(sourcePed, stage, state, price)
	if state == "deleting" then
		setElementFrozen(localPlayer, true)

		if stage == 1 then
			exports.cosmo_chat:sendLocalSay(sourcePed, "Jónapot! Most épp ebédszünet van! Ilyenkor nem tudok koncentrálni.")
			outputChatBox("#d75959[CosmoMTA]: #ffffffJelenleg az interiorok feldolgozása folyik. Kérlek próbáld meg egy óra múlva.", 255, 255, 255, true)
			setTimer(npcTalk, 8000, 1, sourcePed, stage + 1, state, price)
		elseif stage == 2 then
			exports.cosmo_chat:sendLocalSay(localPlayer, "Elnézést a zavarásért uram!")
			setElementFrozen(localPlayer, false)
		end
	else
		setElementFrozen(localPlayer, true)

		if stage == 1 then
			exports.cosmo_chat:sendLocalSay(sourcePed, "Jónapot! Én Dezső vagyok, az ingatlanok doktora!")
		elseif stage == 2 then
			exports.cosmo_chat:sendLocalSay(localPlayer, "Jónapot! Szeretném bejelenteni az ingatlanjaimat, Dezső úr.")
		elseif stage == 3 then
			exports.cosmo_chat:sendLocalSay(sourcePed, "Rendben, akkor " .. price .. " dollárt kérnék.")
		elseif stage == 4 then
			if state then
				exports.cosmo_chat:localActionC(localPlayer, "átad egy kis pénzt Ingatlanos Dezsőnek.")
				exports.cosmo_chat:sendLocalSay(localPlayer, "Rendben. Máris adom.")
			else
				exports.cosmo_chat:sendLocalSay(localPlayer, "Ó, a francba. Nincs nálam annyi!")
			end
		elseif stage == 5 then
			if state then
				exports.cosmo_chat:sendLocalSay(sourcePed, "Köszönöm szépen! Akkor megkezdem az iktatást!")
				outputChatBox("#d75959[CosmoMTA]: #ffffffSikeresen bejelentetted az ingatlanjaidat #3d7abc" .. price .. " dollárért#ffffff.", 255, 255, 255, true)
			else
				exports.cosmo_chat:sendLocalSay(sourcePed, "Sajnálom, de az adminisztrációnak ára van. Pénz nélkül nem tudok segíteni.")
				outputChatBox("#d75959[CosmoMTA]: #ffffffNincs elég pénzed! (#3d7abc" .. price .. " $#ffffff)", 255, 255, 255, true)
			end
			
			setElementFrozen(localPlayer, false)
		end

		if stage < 5 then
			setTimer(npcTalk, 6000, 1, sourcePed, stage + 1, state, price)
		end
	end
end
addEvent("npcTalk", true)
addEventHandler("npcTalk", getRootElement(), npcTalk)