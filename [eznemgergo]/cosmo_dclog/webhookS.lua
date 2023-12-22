local discordWebhookTypes = {
  --TYPE, WEBHOOK
  anticheat = {"anticheat", "https://discord.com/api/webhooks/992434036435845230/-u98ReG67kwSu4MXHGUxi6QEWluKOON9pXCBM_2mBJzH-JMafRqVO8Lov0oXs_SX_DWH"},
  moneylog = {"moneylog", "https://discord.com/api/webhooks/992434084150255697/uqS3JLEYe26oFZFj9TXhtjkqi5mXanFEYeJ8WdoDCXX_ffwXbw0U0p1LQ-pBx035aug5"},
  itemlog = {"itemlog", "https://discord.com/api/webhooks/992433959151599636/2npLxfFobu1uos003bjUaPdzaWJuNQVsQmNpNGKAWNL50euqqhi8a4PlMpSOHpqaRNQD"},
  adminlog = {"adminlog", "https://discord.com/api/webhooks/992433883855458354/iN86vjdxhzHsHngJiXiNWeyaPm2XG7UWCrTVm__6G-9fKWUfd-aSgpOQYGrrwDy3W_K0"},
  givelog = {"givelog", "https://discord.com/api/webhooks/992433817245724674/QWZQcZf3_DD5STZBh4zjrd75EEeNXPdgSf-xY7WKgcoCR6CLkF9rMK28kt2SscVQyJJW"},
  adminreplies = {"adminreplies", "https://discord.com/api/webhooks/992433569672740904/I1Dry23VwgSC6-Ox_0gHf7h0kByXdTJqW6bZCitMYvAj6jWH6e9A5RkGxsLmHPDfdkPX"},
  ooclog = {"ooclog", "https://discord.com/api/webhooks/992433703408128040/vq0dqw9Y7_b-0rypWBT0WevsqcQMdWHsmmWiIJRksAjshaK6rHbrt1GyJCtiVH2Hxkyx"},
  rplog = {"rplog", "https://discord.com/api/webhooks/992433762795262002/xNKZAOJi3nrGtr4GtYEGaNwkFoB7VWixrOvWDvPhkJvfkLza50y-HmEeVAvFxCYTX4lD"},
  weaponship = {"weaponship", "https://discord.com/api/webhooks/992434273250451466/7YlpSv3m5osUxaF-qPb6ar69yEU8D9DKTd7g0CB34gvlsXptKbYCBSig4t3_en995ulq"},
  killog = {"killog", "https://discord.com/api/webhooks/992434196637306931/XUGV1pGbxID3xA4X1t_vubo7PGJ2h3PslfFsyqK9IqPi-WSQn8dPZk7ftwD42Rj6-KaX"},
  selllog = {"selllog", "https://discord.com/api/webhooks/992433639545651330/2gkIutf7EUMkeAmfE6faFVy2WPZ_Vzqs3vqpx_5QfmLJkqZy6yve6fjnjHK-1DG5bi-6"},
  reports = {"reports", "https://discord.com/api/webhooks/992434147404558356/KVr3gOntQXjk85-0JAE1EI8JHiKliOzGDQSF-Ny_qQAYK0B8XZNFHBtG-KbNXwL1ocW9"}

}

function sendDiscordMessage(message, type)
sendOptions = {
    formFields = {
        content=""..message..""
    },
}
fetchRemote ( discordWebhookTypes[type][2], sendOptions, WebhookCallback )
end

addCommandHandler("sendDCN", function(message)
    sendDiscordMessage("test", "adminlog")
end)

function WebhookCallback(responseData) 
   -- outputDebugString("(Discord webhook callback): responseData: "..responseData)
end

--//EXPORTHOZ//--
--exports.cosmo_dclog:sendDiscordMessage("Az üzenet", "Tipus!")
--Konkrét példa : exports.cosmo_dclog:sendDiscordMessage("A fegyverhajó várhatóan x órakor érkezik meg!", "weaponship")