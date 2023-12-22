local connection = false

addEventHandler("onResourceStart", getRootElement(),
    function (startedResource)
        if getResourceName(startedResource) == "cosmo_database" then
            connection = exports.cosmo_database:getConnection()
        elseif source == getResourceRootElement() then
            if getResourceFromName("cosmo_database") and getResourceState(getResourceFromName("cosmo_database")) == "running" then
                connection = exports.cosmo_database:getConnection()
            end
        end
    end
)

function takePlayerBankMoney(player, value)
    if not player then
        player = source
    end

    if getElementData(player, "char.bankMoney") > 0 and getElementData(player, "char.bankMoney") >= value then 
        local finalValue = getElementData(player, "char.bankMoney") - value

        dbQuery( -- PÉNZZEL NEM SZÓRAKOZUNK, EGYBŐL MENTÜNK ADATBÁZISBA HA PL. CRASHELNE A SZERVER NE VESSZEN EL A JÁTÉKOSTÓL
            function (qh, sourcePlayer)
                setElementData(sourcePlayer, "char.bankMoney", finalValue)
                exports.cosmo_core:giveMoney(sourcePlayer, value)

                exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(sourcePlayer, "visibleName"):gsub("_", " ").."** kivett pénzt a bankból! **["..value.."$]**", "moneylog")

                dbFree(qh)
            end, {player}, connection, "UPDATE characters SET bankMoney = ?, money = ? WHERE charID = ?", finalValue, getElementData(player, "char.Money") + value, getElementData(player, "char.ID")
        )
    else
        exports["cosmo_alert"]:showAlert(player, "error", "Sikeretelen tranzakció!", "Nincs ennyi pénz a számládon")
    end
end
addEvent("cosmo_bankS:takePlayerBankMoney", true)
addEventHandler("cosmo_bankS:takePlayerBankMoney", root, takePlayerBankMoney)

function givePlayerBankMoney(player, value)
    if not player then
        player = source
    end

    if (getElementData(player, "char.Money") or 0) - value >= 0 then
        local finalValue = getElementData(player, "char.bankMoney") + value

        dbQuery( -- PÉNZZEL NEM SZÓRAKOZUNK, EGYBŐL MENTÜNK ADATBÁZISBA HA PL. CRASHELNE A SZERVER NE VESSZEN EL A JÁTÉKOSTÓL
            function (qh, sourcePlayer)
                setElementData(sourcePlayer, "char.bankMoney", finalValue)
                exports.cosmo_core:takeMoney(sourcePlayer, value)

                exports.cosmo_dclog:sendDiscordMessage("**"..getElementData(sourcePlayer, "visibleName"):gsub("_", " ").."** betett pénzt a bankba! **["..value.."$]**", "moneylog")

                dbFree(qh)
            end, {player}, connection, "UPDATE characters SET bankMoney = ?, money = ? WHERE charID = ?", finalValue, getElementData(player, "char.Money") - value, getElementData(player, "char.ID")
        )
    else
        exports["cosmo_alert"]:showAlert(player, "error", "Sikeretelen tranzakció!", "Nincs ennyi pénz a kezedben")
    end
end

addEvent("cosmo_bankS:givePlayerBankMoney", true)
addEventHandler("cosmo_bankS:givePlayerBankMoney", root, givePlayerBankMoney)
