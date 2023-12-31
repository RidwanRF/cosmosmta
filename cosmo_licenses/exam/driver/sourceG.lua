--[[
questions = {
    [1] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "A közlekedés során ki felügyeli a közlekedés szabályosságát, biztonságát?",
        ["answers"] = {
            [1] = "A lakosság, aki mindig figyel.",
            [2] = "Mindenki, aki a közlekedésben részt vesz.",
            [3] = "A közlekedési hatóság.",
            [4] = "Az Állam rendvédelme.",
        },
        ["good"] = 4,
    },
    
    [2] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Hol olvashatunk a a közlekedéssel kapcsolatos jogsértésekről?",
        ["answers"] = {
            [1] = "San Andreas Állam Büntető törvénykönyvben.",
            [2] = "A polgári törványkönyvben.",
            [3] = "Infokommunikációs eszközzel, ami képes e cél kiszolgálására.",
            [4] = "Nincs lehetőség ilyenre.",
        },
        ["good"] = 1,
    },

    [3] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Kiknek kell rendelkezniük vezetői engedéllyel?",
        ["answers"] = {
            [1] = "Az állam lakosainak.",
            [2] = "Minden sofőrnek, kivétel a rendvédelmi szervezetek tagjainak.",
            [3] = "Akinek szüksége van rá.",
            [4] = "Azok állampolgároknak akik a nyilvános utakon, autópályákon vezetik a gépjárműveiket.",
        },
        ["good"] = 4,
    },

    [4] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Milyen esetben nem a vezetőre szabályk ki a biztonsági öv becsatolás hiányosságát.",
        ["answers"] = {
            [1] = "Ha az utas nem töltötte be a 16. életévét.",
            [2] = "Ha az utas még gyermekkorú.",
            [3] = "Ha a sofőrnek erre hivatalos felmentése van.",
        },
        ["good"] = 1,
    },

    [5] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Kik számára kötelező a biztonsági öv használata?",
        ["answers"] = {
            [1] = "Azon személy számára aki veszélyben érzi magát a forgalomban.",
            [2] = "Az elöl utazoknak.",
            [3] = "A jármű össze utasa számára.",
            [4] = "Elegendő csak jármű vontatás közben.",
        },
        ["good"] = 3,
    },

    [6] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Hány oldalú és milyen színű a STOP tábla?",
        ["answers"] = {
            [1] = "9 oldalú, piros színű.",
            [2] = "6 oldalú, sárga figyelmeztető színű..",
            [3] = "8 oldalú, piros színű.",
        },
        ["good"] = 3,
    },

    [7] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Milyen alakja van az elsőbség adás táblának??",
        ["answers"] = {
            [1] = "Háromszög.",
            [2] = "Lefele egy csúcsot mutató háromszög.",
            [3] = "Felfele egy csúcsot mutató háromszög.",
        },
        ["good"] = 2,
    },

    [8] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mire szólít fel az elsőbség adás tábla?",
        ["answers"] = {
            [1] = "Le kell lassítania és készen kell állnia a megállásra, mivel át kell engednie bármely járművet.",
            [2] = "Le kell lassítania és készen kell állnia a megállásra, mivel át kell engednie bármely járművet, biciklist vagy gyalogost.",
            [3] = "Le kell lassítania és készen kell állnia a megállásra, mivel át kell engednie bármely járművet, vagy gyalogost.",
        },
        ["good"] = 2,
    },

    [9] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Jobbkéz szabály elve szerint egy jobbról érkező járművel szemben elsőbbsége van?",
        ["answers"] = {
            [1] = "Igen elsőbbségem van.",
            [2] = "Ha lemondok az elsőbbségemről akkor ezt a jogom elvesztem, így nincsen.",
            [3] = "Nincs elsőbbségem.",
        },
        ["good"] = 3,
    },

    [10] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Los Santos városán megengedett nyílvános útjain mennyi a megengedett maximális sebesség?",
        ["answers"] = {
            [1] = "50 MPH.",
            [2] = "70 MPH.",
            [3] = "65MPH.",
        },
        ["good"] = 3,
    },

    [11] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mennyi a maximálisan megengedett sebesség a négysávos útszakoszokon?",
        ["answers"] = {
            [1] = "90 MPH.",
            [2] = "70 MPH.",
            [3] = "45MPH.",
        },
        ["good"] = 1,
    },

    [12] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Los Santos városán kívűl megengedett maximális sebesség?",
        ["answers"] = {
            [1] = "60 MPH.",
            [2] = "75 MPH.",
            [3] = "95 MPH.",
        },
        ["good"] = 2,
    },

    [13] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Los Santos városán megengedett nyílvános útjain mennyi a megengedett maximális sebesség?",
        ["answers"] = {
            [1] = "50 MPH.",
            [2] = "70 MPH.",
            [3] = "65MPH.",
        },
        ["good"] = 1,
    },

    [14] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mikor használd a dudát?",
        ["answers"] = {
            [1] = "Traffipax jelzése miatt a másik autósnak.",
            [2] = "Riadalom keltés céljából.",
            [3] = "Csak akkor, ha mindenképpen szükséges a baleset elkerülése érdekében..",
        },
        ["good"] = 3,
    },

    [15] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mikor NE használd a dudát?",
        ["answers"] = {
            [1] = "Ha egy másik jármű túl lassan halad, és ön azt szeretné, hogy gyorsabban haladjanak.",
            [2] = "Ha egy szűk útszakaszon halad a gépjárművel.",
            [3] = "Ha valami forgalmas csomóponthoz ért.",
        },
        ["good"] = 1,
    },

    [16] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Egy igazoltatás során mikor szállhat ki a járműből?",
        ["answers"] = {
            [1] = "Ha elkérik az iratait és át kell adja.",
            [2] = "Ha a rendőr arra utasítja önt.",
            [3] = "Amint félre áll a járművel a rendőr utasítására azon nyomban ki kell szállnia.",
        },
        ["good"] = 2,
    },

    [17] = {
        ["image"] = ":cosmo_licenses_OLD/150x150.png",
        ["question"] = "Los Santos városán megengedett nyílvános útjain mennyi a megengedett maximális sebesség?",
        ["answers"] = {
            [1] = "50 MPH.",
            [2] = "70 MPH.",
            [3] = "65MPH.",
        },
        ["good"] = 1,
    },

    [18] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mit jelent a pirossal áthúott tábla?",
        ["answers"] = {
            [1] = "Tilos.",
            [2] = "A tábla szabályozó végét.",
            [3] = "Település végét.",
        },
        ["good"] = 1,
    },

    [19] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mit jelent a sárga és fekete kör alakú jelzés?",
        ["answers"] = {
            [1] = "Egyenrangú kereszteződés.",
            [2] = "Veszélyes anyag kerülhet az útra.",
            [3] = "Vasúti átjáróhoz közeledik.",
        },
        ["good"] = 3,
    },

    [20] = {
        ["image"] = ":cosmo_licenses/150x150.png",
        ["question"] = "Mit jelent a 4-oldalú gyémánt alakú jelzés?",
        ["answers"] = {
            [1] = "Középület közelettét jelöli.",
            [2] = "Figyelmezteti önt a különleges útviszonyokra.",
            [3] = "Nem kell figyelembe venni.",
        },
        ["good"] = 2,
    },
}]]


questions = {
    [1] = {
        ["image"] = false,
        ["question"] = "A közlekedés során ki felügyeli a közlekedés szabályosságát, biztonságát?",
        ["answers"] = {
            [1] = "A lakosság, aki mindig figyel",
            [2] = "Mindenki, aki a közlekedésben részt vesz",
            [3] = "A gyalogosok",
            [4] = "Állam rendfenntartó szervei",
        },
        ["good"] = 4,
    },
    
    [2] = {
        ["image"] = false,
        ["question"] = "A rendvédelem mikor fog önnel szemben eljárást foganatosítani?",
        ["answers"] = {
            [1] = "Amikor a kedvük van ehhez a cselekményhez",
            [2] = "Ha ön bármelyik közlekedési szabálypontot megsérti",
            [3] = "Ha én azt szeretném, hogy ez történyen",
            [4] = "Csak ha olyan járművel vagyok, ami nem tetszik nekik",
        },
        ["good"] = 2,
    },

    [3] = {
        ["image"] = false,
        ["question"] = "Mire hatalmazza fel önt a San Andreas vezetői engedély?",
        ["answers"] = {
            [1] = "Az Állam bármely útján legálisan járművel közlekedjen",
            [2] = "Mások feletti ítélekézésre",
            [3] = "Egy felesleges újabb okmány",
            [4] = "Minden olyanra, amire eddig nem"
        },
        ["good"] = 1,
    },

    [4] = {
        ["image"] = false,
        ["question"] = "San Andreas Államban vétségnek számít ha ön vezetői engedély nélkül vezet?",
        ["answers"] = {
            [1] = "Csak városon belül",
            [2] = "Igen",
            [3] = "Nem",
            [4] = "Csak városon kívűl",
        },
        ["good"] = 2,
    },

    [5] = {
        ["image"] = false,
        ["question"] = "Ha ön vezetői engedély nélkül vezet, akkor önt milyen szankciókkal sújthatják?",
        ["answers"] = {
            [1] = "Elzárással",
            [2] = "Pénz bírsággal",
            [3] = "Semmivel sem",
            [4] = "Pénz bírsággal, elzárással",
        },
        ["good"] = 4,
    },

    [6] = {
        ["image"] = false,
        ["question"] = "Mire szolgál a biztonsági öv?",
        ["answers"] = {
            [1] = "Növelik a túlélés esélyét szinte minden ütközés típusnál",
            [2] = "A jármű utazóinak kényelmét növeli",
            [3] = "Növeli a jármű árát a piacon",
            [4] = "Egy kedvünkre használható eszköz",
        },
        ["good"] = 1,
    },

    [7] = {
        ["image"] = false,
        ["question"] = "A járműben űlő minden egyes személynek be kell kötnie a biztonsági övet?",
        ["answers"] = {
            [1] = "Igen, mivel megvéd minket baleset esetén, megakadályozza, hogy kirepüljünk",
            [2] = "Igen, mert miért ne",
            [3] = "Nem, mert csak további sérülést okoz",
            [4] = "Nem, mivel nem kötelező",
        },
        ["good"] = 1,
    },

    [8] = {
        ["image"] = false,
        ["question"] = "Mi történik, ha nem használja a biztonsági övet?",
        ["answers"] = {
            [1] = "Kirepülhetünk a járműből, életveszélyes sérüléseket szerezhetünk, bírsággal súlythatnak",
            [2] = "Kirepülhetünk a járműből",
            [3] = "Életveszélyes sérüléseket szerezhetünk",
            [4] = "Bírsággal súlythatnak",
        },
        ["good"] = 1,
    },

    [9] = {
        ["image"] = false,
        ["question"] = "Mit ajánlott szélsőséges időjárás esetén biztosítani?",
        ["answers"] = {
            [1] = "Hideg és forró időjárás esetén italt",
            [2] = "Semmit",
            [3] = "Hideg időjárás esetén italt",
            [4] = "Forró időjárás esetén italt",
        },
        ["good"] = 1,
    },

    [10] = {
        ["image"] = false,
        ["question"] = "Milyen alakú és színű a STOP tábla?",
        ["answers"] = {
            [1] = "10 oldalú, fehér színű",
            [2] = "8 oldalú, piros színű",
            [3] = "4 oldalú, piros színű",
            [4] = "3 oldalú, sárga színű",
        },
        ["good"] = 2,
    },

    [11] = {
        ["image"] = false,
        ["question"] = "Mit jelez önnek a STOP tábla?",
        ["answers"] = {
            [1] = "Meggyőzödni a forgalomról, majd tovább haladni",
            [2] = "Elsőbbség adást részemről",
            [3] = "Elsőbbségem van",
            [4] = "Teljesen meg kell állni a járművel amikor ezt látja",
        },
        ["good"] = 4,
    },
}

drivePositions = {
    {
        ["position"] = {1047.9250488281, -1494.5432128906, 13.387801170349},
        ["speedlimit"] = 70,
    },
    {
        ["position"] = {1034.9056396484, -1583.8485107422, 13.3828125},
        ["speedlimit"] = 70,
    },
    {
        ["position"] = {1017.53125, -1792.9180908203, 13.813630104065},
        ["speedlimit"] = 70,
    },
    {
        ["position"] = {847.18054199219, -1766.5688476563, 13.386378288269},
        ["speedlimit"] = 70,
    },
    {
        ["position"] = {724.80291748047, -1754.6217041016, 14.399353027344},
        ["speedlimit"] = 70,
    },
    {
        ["position"] = {634.36779785156, -1699.55078125, 14.866591453552},
        ["speedlimit"] = 70,
    },    
	{
        ["position"] = {672.26141357422, -1588.6173095703, 14.08874130249},
        ["speedlimit"] = 70,
    },	
	{
        ["position"] = {816.32647705078, -1599.8894042969, 13.3828125},
        ["speedlimit"] = 70,
    },	
	{
        ["position"] = {934.0732421875, -1574.5364990234, 13.3828125},
        ["speedlimit"] = 70,
    },	
	{
        ["position"] = {1022.0716552734, -1574.2912597656, 13.3828125},
        ["speedlimit"] = 70,
    },	
	{
        ["position"] = {1064.5760498047, -1440.4272460938, 13.35903263092},
        ["speedlimit"] = 70,
    },
}