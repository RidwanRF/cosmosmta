screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultiplier = math.min(1, reMap(screenX, 1024, 1920, 0.75, 1))

function resp(num)
    return num * responsiveMultiplier
end

function respc(num)
  return math.ceil(num * responsiveMultiplier)
end

windowValues = {
    headH = respc(30)
}

function drawBasicWindow(type, posX, posY, sizeW, sizeH, color, state, alphaText, fontSize, font, adjX, adjY)
    if settingsTable[2][2] then
        backColor = {60, 60, 60, 255}
        headColor = {70, 70, 70, 255}
        txtColor = {255, 255, 255, 255}
    else
        backColor = {255, 255, 255, 255}
        headColor = {160, 160, 160, 255}    
        txtColor = {50, 50, 50, 255}           
    end
    
    adjX = adjX or "center"
    adjY = adjY or "center"
    
    drawBoxByState(type .. "backGround", posX, posY + windowValues.headH, sizeW, sizeH - windowValues.headH, backColor, color, false, false, state)
    drawRoundedBoxByState(type .. "headLine", posX + respc(1), posY, sizeW - respc(2), respc(30), headColor, headColor, color, false, false, state)
    
    if isCursorInBox(posX + respc(20), posY + respc(10), respc(10), respc(10)) then
        drawAlphaText(type .. "icon1", color, "\239\132\145", posX + respc(20), posY + respc(1), sizeW - respc(2), respc(30), {217, 83, 79, 255}, 0.7, fonts.iconFont, "left", "center")
    else
        drawAlphaText(type .. "icon1", color, "\239\132\145", posX + respc(20), posY + respc(1), sizeW - respc(2), respc(30), {217, 83, 79, 150}, 0.7, fonts.iconFont, "left", "center")
    end   
    
    if isCursorInBox(posX + respc(37), posY + respc(10), respc(10), respc(10)) then
        drawAlphaText(type .. "icon2", color, "\239\132\145", posX + respc(37), posY + respc(1), sizeW - respc(2), respc(30), {255, 155, 69, 255}, 0.7, fonts.iconFont, "left", "center")
    else
        drawAlphaText(type .. "icon2", color, "\239\132\145", posX + respc(37), posY + respc(1), sizeW - respc(2), respc(30), {255, 155, 69, 150}, 0.7, fonts.iconFont, "left", "center")
    end
    
    if isCursorInBox(posX + respc(54), posY + respc(10), respc(10), respc(10)) then
        drawAlphaText(type .. "icon3", color, "\239\132\145", posX + respc(54), posY + respc(1), sizeW - respc(2), respc(30), {81, 211, 118, 255}, 0.7, fonts.iconFont, "left", "center")
    else
        drawAlphaText(type .. "icon3", color, "\239\132\145", posX + respc(54), posY + respc(1), sizeW - respc(2), respc(30), {81, 211, 118, 150}, 0.7, fonts.iconFont, "left", "center")
    end
    if alphaText then
        drawAlphaText(type .. "title", color, alphaText, posX, posY, sizeW, windowValues.headH, txtColor, fontSize, font, adjX, adjY)
    end
end

function drawBoxByCursor(type, posX, posY, sizeW, sizeH, theColor, customAplha, postGui)
    button = button or false
    ARG7 = ARG7 or false
    if renderData.activeButton == type then
        buttonColor = {processColorSwitchEffect(type, {theColor[1], theColor[2], theColor[3], theColor[4]})}
    else
        buttonColor = {processColorSwitchEffect(type, {theColor[1], theColor[2], theColor[3], customAplha})}
    end
    dxDrawRectangle(posX, posY, sizeW, sizeH, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], theColor[4] - (theColor[4] - buttonColor[4])), postGui)
end

function drawBoxByState(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_)
    _ARG_7_ = _ARG_7_ or false
    _ARG_8_ = _ARG_8_ or false
    _ARG_9_ = _ARG_9_ or 800
    if _ARG_6_ then
        buttonColor = {
        processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], _ARG_5_[4]}, _ARG_9_)}
    else
        buttonColor = {
        processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], 0}, _ARG_9_)}
    end
    dxDrawRectangle(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], _ARG_5_[4] - (_ARG_5_[4] - buttonColor[4])), _ARG_8_)
    if _ARG_7_ then
        renderData.buttons[_ARG_0_] = {_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_}
    end
end

function drawButtonByState(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_)
      button = button or false
      _ARG_8_ = _ARG_8_ or false
      _ARG_9_ = _ARG_9_ or 800
      if _ARG_7_ then
        if isCursorInBox(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_) then
            buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], _ARG_6_[4]}, _ARG_9_)}
        else
            buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], _ARG_5_[4]}, _ARG_9_)}
        end
    else
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], 0}, _ARG_9_)}
    end
    dxDrawRectangle(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], _ARG_5_[4] - (_ARG_5_[4] - buttonColor[4])), _ARG_8_)
end

function drawImageByState(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_)
    _ARG_9_ = _ARG_9_ or false
    _ARG_13_ = _ARG_13_ or false
    _ARG_10_ = _ARG_10_ or 0
    _ARG_11_ = _ARG_11_ or 0
    _ARG_12_ = _ARG_12_ or 0
    if _ARG_6_ then
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], _ARG_5_[4]}, _ARG_8_)}
    else
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], 0}, _ARG_8_)}
    end
    dxDrawImage(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_7_, _ARG_10_, _ARG_11_, _ARG_12_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], _ARG_5_[4] - (_ARG_5_[4] - buttonColor[4])), _ARG_13_)
    if _ARG_9_ then
        renderData.buttons[_ARG_0_] = {_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_}
    end
end

function drawRoundedBoxByState(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_)
    _ARG_8_ = _ARG_8_ or false
    _ARG_9_ = _ARG_9_ or false
    if _ARG_7_ then
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], _ARG_5_[4]}, 800)}
        borderColor = {processColorSwitchEffect(_ARG_0_ .. "border", {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], _ARG_6_[4]}, 800)}
    else
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], 0}, 800)}
        borderColor = {processColorSwitchEffect(_ARG_0_ .. "border", {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], 0}, 800)}
    end
    roundedRectangle(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, tocolor(borderColor[1], borderColor[2], borderColor[3], _ARG_6_[4] - (_ARG_6_[4] - buttonColor[4])), tocolor(buttonColor[1], buttonColor[2], buttonColor[3], _ARG_5_[4] - (_ARG_5_[4] - buttonColor[4])), _ARG_9_)
    if _ARG_8_ then
        renderData.buttons[_ARG_0_] = {_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_}
    end
end

function drawRoundedBoxByStateAndCursor(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_)
    _ARG_9_ = _ARG_9_ or false
    _ARG_10_ = _ARG_10_ or false
    if _ARG_7_ then
        if isCursorInBox(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_) then
            buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_8_[1], _ARG_8_[2], _ARG_8_[3], _ARG_8_[4]})}
            borderColor = {processColorSwitchEffect(_ARG_0_ .. "border", {_ARG_8_[1], _ARG_8_[2], _ARG_8_[3], _ARG_8_[4]}, 1000)}
        else
            buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], _ARG_5_[4]}, 1000)}
            borderColor = {processColorSwitchEffect(_ARG_0_ .. "border", {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], _ARG_6_[4]}, 1000)}
        end
    else
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_5_[1], _ARG_5_[2], _ARG_5_[3], 0}, 800)}
        borderColor = {processColorSwitchEffect(_ARG_0_ .. "border", {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], 0}, 800)}
    end
    roundedRectangleNormal(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, tocolor(borderColor[1], borderColor[2], borderColor[3], _ARG_6_[4] - (_ARG_6_[4] - buttonColor[4])), tocolor(buttonColor[1], buttonColor[2], buttonColor[3], _ARG_5_[4] - (_ARG_5_[4] - buttonColor[4])), _ARG_10_)
    if _ARG_9_ then
        renderData.buttons[_ARG_0_] = {_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_}
    end
end

function drawAlphaText(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_12_, _ARG_13_, _ARG_14_, _ARG_15_, _ARG_16_, _ARG_17_, _ARG_18_)
    if _ARG_1_ then
        textColor = {processColorSwitchEffect(_ARG_0_, {_ARG_7_[1], _ARG_7_[2], _ARG_7_[3], _ARG_7_[4]}, _ARG_12_ or 800)}
    else
        textColor = {processColorSwitchEffect(_ARG_0_, {_ARG_7_[1], _ARG_7_[2], _ARG_7_[3], 0}, _ARG_12_ or 800)}
    end
    dxDrawText(_ARG_2_, _ARG_3_, _ARG_4_, _ARG_3_ + _ARG_5_, _ARG_4_ + _ARG_6_, tocolor(textColor[1], textColor[2], textColor[3], _ARG_7_[4] - (_ARG_7_[4] - textColor[4])), _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_, _ARG_13_ or false, _ARG_14_ or false, _ARG_15_ or false, _ARG_16_ or false, _ARG_17_ or false, _ARG_18_ or 0)
end

function drawFrame(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_)
    _ARG_7_ = _ARG_7_ or false
    _ARG_8_ = _ARG_8_ or false
    if isCursorInBox(_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_) then
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], 255})}
    else
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], 0})}
    end
    dxDrawRectangle(_ARG_1_, _ARG_2_ - _ARG_5_, _ARG_3_, _ARG_5_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    dxDrawRectangle(_ARG_1_ - _ARG_5_, _ARG_2_ - _ARG_5_, _ARG_5_, _ARG_4_ + _ARG_5_ * 2, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    dxDrawRectangle(_ARG_1_ + _ARG_3_, _ARG_2_ - _ARG_5_, _ARG_5_, _ARG_4_ + _ARG_5_ * 2, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    dxDrawRectangle(_ARG_1_, _ARG_2_ + _ARG_4_, _ARG_3_, _ARG_5_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    if _ARG_7_ then
        dxDrawText(_ARG_7_, _ARG_1_, _ARG_2_, _ARG_1_ + _ARG_3_, _ARG_2_ + _ARG_4_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])), 1, twcentFont, "center", "center")
    end
    if _ARG_8_ then
        renderData.buttons[_ARG_0_] = {_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_}
    end
end

function drawFrameByState(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_)
    _ARG_7_ = _ARG_7_ or false
    _ARG_9_ = _ARG_9_ or false
    if _ARG_8_ then
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], 255})}
    else
        buttonColor = {processColorSwitchEffect(_ARG_0_, {_ARG_6_[1], _ARG_6_[2], _ARG_6_[3], 0})}
    end
    dxDrawRectangle(_ARG_1_, _ARG_2_ - _ARG_5_, _ARG_3_, _ARG_5_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    dxDrawRectangle(_ARG_1_ - _ARG_5_, _ARG_2_ - _ARG_5_, _ARG_5_, _ARG_4_ + _ARG_5_ * 2, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    dxDrawRectangle(_ARG_1_ + _ARG_3_, _ARG_2_ - _ARG_5_, _ARG_5_, _ARG_4_ + _ARG_5_ * 2, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    dxDrawRectangle(_ARG_1_, _ARG_2_ + _ARG_4_, _ARG_3_, _ARG_5_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])))
    if _ARG_7_ then
        dxDrawText(_ARG_7_, _ARG_1_, _ARG_2_, _ARG_1_ + _ARG_3_, _ARG_2_ + _ARG_4_, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], 175 - (175 - buttonColor[4])), 1, twcentFont, "center", "center")
    end
    if _ARG_9_ then
        renderData.buttons[_ARG_0_] = {_ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_}
    end
end

function drawScrollbar(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_, _ARG_7_, _ARG_8_, _ARG_9_, _ARG_10_, _ARG_11_)
    if _ARG_6_ < _ARG_5_ then
        _ARG_11_ = _ARG_11_ or false
        drawBoxByState(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_9_, _ARG_10_, _ARG_11_)
        drawBoxByState(_ARG_0_ .. "2", _ARG_1_, _ARG_2_ + _ARG_7_ * (_ARG_4_ / _ARG_5_), _ARG_3_, _ARG_4_ / math.max(_ARG_5_ / _ARG_6_, 1), _ARG_8_, _ARG_10_, _ARG_11_)
    end
end

function dxDrawInnerBorder(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_)
    _ARG_0_ = _ARG_0_ or 2
    dxDrawLine(_ARG_1_, _ARG_2_, _ARG_1_ + _ARG_3_, _ARG_2_, _ARG_5_, _ARG_0_, _ARG_6_)
    dxDrawLine(_ARG_1_, _ARG_2_ + _ARG_4_, _ARG_1_ + _ARG_3_, _ARG_2_ + _ARG_4_, _ARG_5_, _ARG_0_, _ARG_6_)
    dxDrawLine(_ARG_1_, _ARG_2_, _ARG_1_, _ARG_2_ + _ARG_4_, _ARG_5_, _ARG_0_, _ARG_6_)
    dxDrawLine(_ARG_1_ + _ARG_3_, _ARG_2_, _ARG_1_ + _ARG_3_, _ARG_2_ + _ARG_4_, _ARG_5_, _ARG_0_, _ARG_6_)
end

function roundedRectangleNormal(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_)
    if _ARG_0_ and _ARG_1_ and _ARG_2_ and _ARG_3_ then
        _ARG_4_ = _ARG_4_ or tocolor(0, 0, 0, 200)
        _ARG_5_ = _ARG_5_ or _ARG_4_
        dxDrawRectangle(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_5_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ + 2, _ARG_1_ - 1, _ARG_2_ - 4, 1, _ARG_4_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ + 2, _ARG_1_ + _ARG_3_, _ARG_2_ - 4, 1, _ARG_4_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ - 1, _ARG_1_ + 2, 1, _ARG_3_ - 4, _ARG_4_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ + _ARG_2_, _ARG_1_ + 2, 1, _ARG_3_ - 4, _ARG_4_, _ARG_6_)
    end
end

function roundedRectangle(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_4_, _ARG_5_, _ARG_6_)
    if _ARG_0_ and _ARG_1_ and _ARG_2_ and _ARG_3_ then
        _ARG_4_ = _ARG_4_ or tocolor(0, 0, 0, 200)
        _ARG_5_ = _ARG_5_ or _ARG_4_
        dxDrawRectangle(_ARG_0_, _ARG_1_, _ARG_2_, _ARG_3_, _ARG_5_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ + 2, _ARG_1_ - 1, _ARG_2_ - 4, 1, _ARG_4_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ - 1, _ARG_1_ + 2, 1, _ARG_3_ - 2, _ARG_4_, _ARG_6_)
        dxDrawRectangle(_ARG_0_ + _ARG_2_, _ARG_1_ + 2, 1, _ARG_3_ - 2, _ARG_4_, _ARG_6_)
    end
end

local renderData = {}

renderData.colorSwitches = {}
renderData.lastColorSwitches = {}
renderData.startColorSwitch = {}
renderData.lastColorConcat = {}

function processColorSwitchEffect(key, color, duration, type)
    if not renderData.colorSwitches[key] then
        if not color[4] then
            color[4] = 255
        end

        renderData.colorSwitches[key] = color
        renderData.lastColorSwitches[key] = color

        renderData.lastColorConcat[key] = table.concat(color)
    end

    duration = duration or 500
    type = type or "Linear"

    if renderData.lastColorConcat[key] ~= table.concat(color) then
        renderData.lastColorConcat[key] = table.concat(color)
        renderData.lastColorSwitches[key] = color
        renderData.startColorSwitch[key] = getTickCount()
    end

    if renderData.startColorSwitch[key] then
        local progress = (getTickCount() - renderData.startColorSwitch[key]) / duration

        local r, g, b = interpolateBetween(
                renderData.colorSwitches[key][1], renderData.colorSwitches[key][2], renderData.colorSwitches[key][3],
                color[1], color[2], color[3],
                progress, type
        )

        local a = interpolateBetween(renderData.colorSwitches[key][4], 0, 0, color[4], 0, 0, progress, type)

        renderData.colorSwitches[key][1] = r
        renderData.colorSwitches[key][2] = g
        renderData.colorSwitches[key][3] = b
        renderData.colorSwitches[key][4] = a

        if progress >= 1 then
            renderData.startColorSwitch[key] = false
        end
    end

    return renderData.colorSwitches[key][1], renderData.colorSwitches[key][2], renderData.colorSwitches[key][3], renderData.colorSwitches[key][4]
end

local screenX, screenY = guiGetScreenSize()

function isCursorInBox(x, y, w, h)
    if(isCursorShowing()) then
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX*screenX, cursorY*screenY
        if(cursorX >= x and cursorX <= x+w and cursorY >= y and cursorY <= y+h) then
            return true
        else
            return false
        end
    end
end