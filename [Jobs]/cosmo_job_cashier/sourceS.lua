addEvent("giveMoney", true)
addEventHandler("giveMoney", resourceRoot, function(money)
    exports.cosmo_core:giveMoney(client, money, "cashierJob")
end)