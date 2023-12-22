local screenX, screenY = guiGetScreenSize()

local page = "result"
local showPanel = false

local examW, examH = respc(700), respc(380)
local examX, examY = (screenX - examW) * 0.5, (screenY - examH) * 0.5

local currentQuestion = 8
local answeredQuestion = {}
local myPoint = 0
local neededPoint = 8
local examQuestions = 11
local examSuccess = false
BebasNeue = exports.cosmo_assets:loadFont("BebasNeue-Regular.ttf", respc(17), false, "antialiased")

function renderExamPanel()

    buttons = {}

    absX, absY = 0, 0

    if isCursorShowing() then
        local relX, relY = getCursorPosition()

        absX = screenX * relX
        absY = screenY * relY
    end

    --> Háttér
    dxDrawRectangle(examX, examY, examW, examH, tocolor(0, 0, 0, 175))

    --> Fejléc
    dxDrawRectangle(examX, examY, examW, 30, tocolor(0, 0, 0, 150))
--	dxDrawImage(math.floor(examX + 3), math.floor(examY + 3), 24, 24, ":cosmo_hud/files/logo.png", 0, 0, 0, tocolor(255, 255, 255))
    dxDrawText("Cosmo#ff9428MTA - Vizsga", examX + 3, examY + 1, 0, examY + 30, tocolor(255, 255, 255), 1, BebasNeue, "left", "center", false, false, false, true)
    
    if page == "main" then
        --> Bezárás
        local closeTextWidth = dxGetTextWidth("X", 1, BebasNeue)
        local closeTextPosX = examX + examW - closeTextWidth - 5
        local closeColor = tocolor(255, 255, 255)

        if absX >= closeTextPosX and absY >= examY and absX <= closeTextPosX + closeTextWidth and absY <= examY + 30 then
            closeColor = tocolor(215, 89, 89)

            if getKeyState("mouse1") then
                showExamPanel()
                showCursor(false)
                return
            end
        end
        
        dxDrawText("X", closeTextPosX, examY, 0, examY + 30, closeColor, 1, BebasNeue, "left", "center")

        --> Tartalom
        dxDrawText("Üdvözöljük!", examX, examY + 50, examW + examX, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "center")

        dxDrawText("Kérjük, figyelemmel olvassa át a kérdéseket. Sikeres vizsga esetén az oktató az épület mellett fogja várni, sikertelen vizsánál újból el kell végeznie a tesztet.", examX + 10, examY + 40, examW + examX - 10, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "center", "center", false, true)

        local buttonW, buttonH = respc(220), respc(40)

        dxDrawMetroButtonWithBorder("exam:theory:start", "Elméleti vizsga elkezdése", examX + (examW - buttonW) * 0.5, examY + examH - 10 - buttonH, buttonW, buttonH, {255, 148, 40, 125}, {255, 148, 40, 175}, {255, 255, 255}, BebasNeue, "center", "center", nil, nil, nil, nil)
    
    elseif page == "test" then
        dxDrawText(questions[currentQuestion]["question"], examX + respc(20), examY + 40, examW + examX, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "left", "top", false, true)
    


        if questions[currentQuestion]["image"] then
            --dxDrawRectangle(examX + respc(20), examY + 80, respc(150), respc(150))
            dxDrawImage(examX + respc(20), examY + (examH - respc(150)) * 0.5, respc(150), respc(150), questions[17]["image"])
        end

        local buttonW, buttonH = respc(490), respc(50)
        local buttonX = examX + respc(190)
        local buttonStartY = examY + (examH - respc(150)) * 0.5
        for k, v in pairs(questions[currentQuestion]["answers"]) do
            local buttonY = buttonStartY + ((buttonH + 10) * (k - 1))
            dxDrawMetroButtonWithBorder("exam:answer:" .. k, v, buttonX, buttonY, buttonW, buttonH, {255, 148, 40, 125}, {255, 148, 40, 175}, {255, 255, 255}, BebasNeue, "center", "center", nil, nil, nil, nil)
        end
    elseif page == "result" then
            --> Bezárás
            local closeTextWidth = dxGetTextWidth("X", 1, BebasNeue)
            local closeTextPosX = examX + examW - closeTextWidth - 5
            local closeColor = tocolor(255, 255, 255)
    
            if absX >= closeTextPosX and absY >= examY and absX <= closeTextPosX + closeTextWidth and absY <= examY + 30 then
                closeColor = tocolor(215, 89, 89)
    
                if getKeyState("mouse1") then
                    showCursor(false)
                    showExamPanel()
                    return
                end
            end
            
            dxDrawText("X", closeTextPosX, examY, 0, examY + 30, closeColor, 1, BebasNeue, "left", "center")
    
            --> Tartalom
            if examSuccess then
                dxDrawText("Gratulálunk!", examX, examY + 50, examW + examX, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "center")
        
                dxDrawText("Az ön ponszáma elérte a szükséges pontszámot! Az igazoló papírt átadtuk önnek. A továbbiakban keressen fel egy okatót a gyakorlati vizsga elkezdéséhez.", examX + 10, examY + 40, examW + examX - 10, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "center", "center", false, true)
            else
                dxDrawText("Sajnáljuk!", examX, examY + 50, examW + examX, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "center")
        
                dxDrawText("Az ön ponszáma nem érte el a szükséges pontszámot! Az igazoló papírt átadtuk önnek. A továbbiakban felkereshet minket a vizsga újrapróbálásáért.", examX + 10, examY + 40, examW + examX - 10, examH + examY, tocolor(255, 255, 255, 255), 1, BebasNeue, "center", "center", false, true)
            end
    end

    activeButtonChecker()
end

function showExamPanel(showPage)
    if not showPage then
        showPanel = false
        removeEventHandler("onClientRender", root, renderExamPanel)
        return
    end

    if not showPanel then
        addEventHandler("onClientRender", root, renderExamPanel)
    end

    page = showPage
    showPanel = true
end

function examIsCompleted()
    if table.size(answeredQuestion) == examQuestions then
        if myPoint >= neededPoint then
			setElementData(localPlayer, "startedQuest", false)
            examSuccess = true
            showExamPanel("result")
            triggerServerEvent("addItem", localPlayer, localPlayer, 113, 1, false, examSuccess, "vezetés-elmélet", getElementData(localPlayer, "char.ID"))
        else
			setElementData(localPlayer, "startedQuest", false)
            showExamPanel("result")
            triggerServerEvent("addItem", localPlayer, localPlayer, 113, 1, false, examSuccess, "vezetés-elmélet", getElementData(localPlayer, "char.ID"))
        end
    end
end

function nextQuestion(lastQuestion)
    if not questions[lastQuestion] then
        return
    end

    answeredQuestion[lastQuestion] = true
    examIsCompleted()
    print("Kérdések: " .. table.size(answeredQuestion) .. "/" .. #questions)
    local generatedQuestion = math.random(1, #questions)
    while answeredQuestion[generatedQuestion] do
        if table.size(answeredQuestion) == #questions then
            print("Nincs több kérdés")
            break
        end
        generatedQuestion = math.random(1, #questions)
    end

    currentQuestion = generatedQuestion
end

addEventHandler("onClientClick", root, function(button, state)
    if button == "left" and state == "down" then
        if page == "main" then
            if activeButton == "exam:theory:start" then
                currentQuestion = math.random(1, #questions)
                showExamPanel("test")
				setElementData(localPlayer, "startedQuest", true)
            end
        elseif page == "test" then
            for k, v in pairs(questions[currentQuestion]["answers"]) do
                if activeButton == "exam:answer:" .. k then
                    local myAnswer = split(activeButton, ":")
                    if tonumber(myAnswer[3]) == questions[currentQuestion]["good"] then
                        myPoint = myPoint + 1
                    end
                    print(myPoint .. "/" .. neededPoint)
                    nextQuestion(currentQuestion)
                end
            end
        end
    end
end)