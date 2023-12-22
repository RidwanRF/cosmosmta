

Documents["weapon"] = function(data)
    local date = getRealTime(data["expire"])
	dxDrawRectangle(docX-1, docY-1, docW+2, docH+2, tocolor(0, 0, 0, 255))
    dxDrawImage(docX, docY, docW, docH, "files/weapon.png")   
	dxDrawRectangle(docX, docY, 25, docH, tocolor(255, 148, 40, 255))
	dxDrawRectangle(docX+25, docY, 1, docH, tocolor(0, 0, 0, 255))
    dxDrawText(data["name"], docX + 220, docY + 56, docW + docX - 10, docH + docY, tocolor(255, 255, 255, 255), 1, fonts.Roboto13, "left", "top") 
    dxDrawText(data["birth"], docX + 315, docY + 85.5, docW + docX - 10, docH + docY, tocolor(255, 255, 255, 255), 1, fonts.Roboto13, "left", "top") 
    dxDrawText("Amerikai", docX + 337, docY + 122, docW + docX - 10, docH + docY, tocolor(255, 255, 255, 255), 1, fonts.Roboto13, "left", "top") 
    dxDrawText(date.year + 1900 .. ". " .. string.format("%02d", date.month + 1) .. ". " .. string.format("%02d", date.monthday) .. ".", docX + 275, docY + 156, docW + docX - 10, docH + docY, tocolor(255, 255, 255, 255), 1, fonts.Roboto13, "left", "top") 

    local signW, signH = 210, 30
    local signX, signY = docX + 33, docY + 195

    dxDrawText(data["name"], signX, signY + 3, signX + signW, signY + signH, tocolor(190, 190, 190, 255), 1, fonts.lunabar, "center", "top") 
end