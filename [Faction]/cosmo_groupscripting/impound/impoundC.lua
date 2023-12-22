local screenX, screenY = guiGetScreenSize()
local UI = exports.cosmo_ui
local isVisible = false
local widgets = {}
local Impound = {}

Impound.Show = function()
    if not exports.cosmo_groups:isPlayerHavePermission(localPlayer, "impoundVehicle") then
        exports.cosmo_alert:showAlert("error", "Nincs engedélyed a parancs használatához")
        return
    end

    local panelW, panelH = UI:respc(600), UI:respc(250)
    --print("asd")
	if isVisible then
		return
    end
    --print("asd2")
    showCursor(true)

	isVisible = true

	widgets.panel = UI:createCustomPanel({
		x = (screenX - panelW) / 2,
		y = (screenY - panelH) / 2,
		width = panelW,
		height = panelH,
        --rounded = true
        --enableAnimation = true
	})
	UI:addChild(widgets.panel)

	widgets.logo = UI:createImage({
		x = 5,
		y = 5,
		width = respc(403 * 0.075),
		height = respc(459 * 0.075),
		texture = ":cosmo_assets/images/sarplogo_big.png",
		color = tocolor(50, 179, 239),
		floorMode = true
	})
    UI:addChild(widgets.panel, widgets.logo)

	widgets.headerTitle = UI:createCustomLabel({
		x = 10 + respc(30.225),
		y = 5,
		width = 0,
		height = respc(34.425),
		color = tocolor(255, 255, 255),
		font = fonts.Roboto14,
		alignX = "left",
		alignY = "center",
		text = "Lefoglalás",
	})
	UI:addChild(widgets.panel, widgets.headerTitle)

	widgets.closeButton = UI:createCustomImageButton({
		x = panelW - respc(24) - 10,
		y = 5 + (respc(34.425) - respc(24)) / 2,
		width = respc(24),
		height = respc(24),
		hoverColor = tocolor(215, 89, 89),
		texture = ":cosmo_assets/images/cross_x.png"
	})
    UI:addChild(widgets.panel, widgets.closeButton)

    --[-----------------------------------------------------]--

    widgets.reasonLabel = UI:createCustomLabel({
        x = respc(10),
        y = respc(60),
        width = panelW - respc(20),
        height = respc(40),
		color = tocolor(255, 255, 255),
		font = fonts.Roboto14,
		alignX = "left",
		alignY = "center",
		text = "Indok:",
    })
    UI:addChild(widgets.panel, widgets.reasonLabel)

    widgets.reasonInput = UI:createCustomInput({
        x = respc(10),
        y = respc(105),
        width = panelW - respc(20),
        height = respc(40),
        font = fonts.Roboto14,
        maxLength = respc(48),
    })
    UI:addChild(widgets.panel, widgets.reasonInput)

    widgets.impoundButton = UI:createCustomButton({
        x = respc(10),
        y = panelH - respc(40) - respc(10),
        width = panelW - respc(20),
        height = respc(40),
        text = "Lefoglalás",
        font = fonts.Roboto14,
        color = {7, 112, 196, 125},
    })
    UI:addChild(widgets.panel, widgets.impoundButton)
end
addCommandHandler("parkeflefoglalas", Impound.Show)

Impound.Close = function()
    if not isVisible then
		return
	end
	isVisible = false

	UI:removeChild(widgets.panel)
	showCursor(false)
end

addEvent("sarpUI.click", false)
addEventHandler("sarpUI.click", resourceRoot, function (widget, button)
	if button == "left" then
		if widget == widgets.closeButton then
            Impound.Close()
        elseif widget == widgets.impoundButton then
		--reason, price, canGet, time
			local reason = UI:getText(widgets.reasonInput)
			local price = 30000000

			if utf8.len(reason) < 6 then
				exports.cosmo_alert:showAlert("error", "Az indoknak hosszabbnak kell lennie mint 5 karakter.")
				return
			end

			local impoundedDate = getRealTime().timestamp
			local expireDate = getRealTime().timestamp + (86400 * 0)
			local impoundedBy = getElementData(localPlayer, "char.ID")

			--outputChatBox(reason .. " :: " .. price .. " :: " .. tostring(canGet) .. " :: " .. time .. " :: " .. impoundedDate .. " :: " .. expireDate .. " :: " .. impoundedBy .. " :: ")
			triggerServerEvent("cosmo_impoundS:impoundVehicle", getElementData(localPlayer, "poundedVeh"), localPlayer, getElementData(localPlayer, "poundedVeh"), reason, price, true, impoundedDate, expireDate, impoundedBy)
			Impound.Close()
        end
	end
end)