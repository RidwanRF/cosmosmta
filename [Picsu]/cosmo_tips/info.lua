local tipsElotag = "#ff9428[CosmoMTA - Tipp]#ffffff: "

local togtips = true;

function togtips()
    if togtips then
        togtips = false;
        outputChatBox(tipsElotag.."Tippek kikapcsolva!",255,255,255,true);
    else
        togtips = true;
        outputChatBox(tipsElotag.."Tippek bekapcsolva!",255,255,255,true);
    end
end
 addCommandHandler("togtips",togtips)

local tips = {
	"Szeretnéd támogatni a szervert? Keresd fel Discordon az illetékest!",
	"Elfogyott a pénzed? Ne ess kétségbe! Vegyél fel munkát a városházán! Jól fizetnek.",
	"Bugot találtál? Netalántán van egy frappáns ötleted a szerverhez? Discordon a megfelelő szobába tedd fel!",
	"A tippeket a /togtips parancsal tudod ki/be kapcsolni.",
	"Figyelj az éhség szintedre mert ha túl alacsony akkor a HP-d is csökkeni fog.",
	"A Prémium Panelt az 'F7'-gomb lenyomásával nyithatod meg.",
	"Bugot találtál? Jelezd egy adminisztrátornak.",
	"Discord szerverünk: https://discord.gg/AmtP8p5Wj3",
	"Munkát felvenni/leadni a városházán tudsz.",
	"A járműved ablakát 'F4' gomb lenyomásával tudod lehúzni/felhúzni.",
}

setTimer ( function () 
	local randomSzam = math.random(1, #tips)
	if togtips then 
		outputChatBox(tipsElotag..tips[randomSzam], 255, 255, 255, true)
	end
end, 180000, 0 )
--end, 5000, 0 )