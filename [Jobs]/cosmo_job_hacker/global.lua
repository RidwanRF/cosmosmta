core = exports.cosmo_core
infobox = exports.cosmo_hud
color, r, g, b = 255, 148, 40

hackTexts = {"ping", "write", "init", "setnewid", "bytes", "get", "count", "mysql", "domain", "username", "generate", "join", "stat", "reset", "size", "xml", "file", "upload", "system", "load", "lua", "html", "php", "javascript"}
companys = {"Bank Of America", "OriginalShop Co.", "Walmart Inc.", "Ford Motorss Co.", "Amazon Inc.", "Apple Inc.", "CVS Health Co.", "AT&T Inc.", "Chevron Co.", "Microsoft Co.", "Dell Technologies Inc.", "IBM Co.", "American Express Co.", "NIKE Inc.", "Publix Super Markets Inc.", "Exelon Co.", "Jabil Inc.", "Visa Inc.", "Netflix Inc.", "Altria Group Inc.", "Salesforce Inc.", "Ecolab Inc.", "BlackRock Inc.", "Uber Technologies", "eBay", "PulteGroup", "Xerox Holdings Co.", "Masco Co.", "JetBlue Airways", "The Clorox Co.", "Cerner Co."}

accessStates = {
    ["granted"] = {"ACCESS \n GRANTED", tocolor(0, 255, 0, 255)},
    ["denied"] = {"ACCESS \n DENIED", tocolor(255, 0, 0, 255)},
}

function generateRandomIP()
    local ip = ""

    for i = 1, 4 do 
        for i2 = 1, math.random(1, 3) do 
            if i2 == 1 then 
                ip = ip .. math.random(1, 9)
            else
                ip = ip .. math.random(0, 9)
            end
        end 

        if i < 4 then  
            ip = ip .. "."
        end
    end

    return ip
end

deniedKeyboardLetters = {
    ["arrow_u"] = true,
    ["arrow_d"] = true,
    ["arrow_l"] = true,
    ["arrow_r"] = true,
    ["pgdn"] = true,
}