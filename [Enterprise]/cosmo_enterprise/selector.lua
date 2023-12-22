local show = false
local tick = 0

function removeSelector()
    show = false
    showChat(true)
    showCursor(false)
    removeEventHandler("onClientClick", getRootElement(), clickSelector)
    removeEventHandler("onClientRender", getRootElement(), renderSelector)
end
addEventHandler("onClientKey", getRootElement(), function(button, state)
    if getElementData(localPlayer, "loggedIn") or false then
        --if state and (button == "F1" or button == "F5") then
            --if getKeyState("lshift") or getKeyState("rshift") then
            if state and button == "F9" then
                if show then 
                    removeSelector()
                end
                --if button == "F5" then
                    triggerServerEvent("server->getEnterprises", localPlayer, true)
                    triggerServerEvent("server->getEntDatas", localPlayer)
                --else
                    --triggerEvent("show->faction", localPlayer) 
                --end
                return
            end
                
            --[[ if button == "F1" then
                if show then 
                    removeSelector()
                    return
                end
                showChat(false)
                showCursor(true)
                show = true
                tick = getTickCount()
                addEventHandler("onClientRender", getRootElement(), renderSelector)
                addEventHandler("onClientClick", getRootElement(), clickSelector)
            end ]]
        end
    --end
end)

local screenW, screenH = guiGetScreenSize()
local width, height = 550, 300
local pos = {screenW/2 - width/2, screenH/2 - height/2}

local font = dxCreateFont("files/Roboto.ttf", 12)
local font2 = dxCreateFont("files/Roboto.ttf", 11)
local font3 = dxCreateFont("files/Roboto.ttf", 8)
local logoY = 0

function renderSelector()
    local progress = (getTickCount() - tick) / 1000
    w, h = width, height
    
    logoY, _, _ = interpolateBetween(
        0, 0, 0,
        -30, 0, 0,
    progress, "CosineCurve")
    
    dxDrawRectangle(pos[1], pos[2], w, h, tocolor(0, 0, 0, 150))
    
    dxDrawImage(pos[1] + w/2-96*0.85/2, pos[2] + h/2-151*0.85 - 100 + logoY, 96*0.85, 151*0.85, "files/logo.png")
    
    dxDrawText("Üdvözöllek a menü választóban!\nKérlek válassz a lehetőség közül!", pos[1], pos[2] + 65, pos[1] + w, pos[2] + 65 + h, tocolor(255, 255, 255, 255), 1, font, "center", "top")
    
    local poz = {pos[1] + w*0.07, pos[2] + h/2 + 55, 190, 35}
    dxDrawRectangle(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and tocolor(255, 105, 38, 175) or tocolor(0, 0, 0, 175)))
    dxDrawText("Frakció menü", pos[1] + w*0.07, pos[2] + h/2 + 55, pos[1] + w*0.07 + 190, pos[2] + h/2 + 55 + 35, (isInSlot(poz[1], poz[2], poz[3], poz[4]) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font2, "center", "center")
    dxDrawText("(Gyorsgomb: shift + F1)", pos[1] + w*0.07, pos[2] + h/2 + 70, pos[1] + w*0.07 + 190, pos[2] + h/2 + 70 + 35, tocolor(255, 255, 255, 255), 1, font3, "center", "bottom")
    
    local poz = {pos[1] + w*0.58, pos[2] + h/2 + 55, 190, 35}
    dxDrawRectangle(poz[1], poz[2], poz[3], poz[4], (isInSlot(poz[1], poz[2], poz[3], poz[4]) and tocolor(255, 105, 38, 175) or tocolor(0, 0, 0, 175)))
    dxDrawText("Vállalkozás menü", pos[1] + w*0.58, pos[2] + h/2 + 55, pos[1] + w*0.58 + 190, pos[2] + h/2 + 55 + 35, (isInSlot(poz[1], poz[2], poz[3], poz[4]) and tocolor(0, 0, 0, 255) or tocolor(255, 255, 255, 255)), 1, font2, "center", "center")
    dxDrawText("(Gyorsgomb: shift + F5)", pos[1] + w*0.58, pos[2] + h/2 + 70, pos[1] + w*0.58 + 190, pos[2] + h/2 + 70 + 35, tocolor(255, 255, 255, 255), 1, font3, "center", "bottom")
end 

function clickSelector(button, state, abX, abY)
    if button == "left" and state == "down" then
        if show then
            if isInBox(pos[1] + w*0.07, pos[2] + h/2 + 55, 190, 35, abX, abY) then
                removeSelector()
                triggerEvent("show->faction", localPlayer)
                return
            elseif isInBox(pos[1] + w*0.58, pos[2] + h/2 + 55, 190, 35, abX, abY) then
                removeSelector()
                triggerServerEvent("server->getEnterprises", localPlayer, true)
                triggerServerEvent("server->getEntDatas", localPlayer)
                return
            end
        end
    end
end





