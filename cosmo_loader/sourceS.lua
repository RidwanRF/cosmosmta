function startLoadingScreen(elementToShow, timeToExecute, loadingTexts, event, eventArgs)
    triggerClientEvent(elementToShow, "startLoadingScreen", elementToShow, timeToExecute, loadingTexts, event, eventArgs)
end