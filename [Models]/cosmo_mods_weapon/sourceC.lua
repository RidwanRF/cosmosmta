function loadMod(path, model)
	engineImportTXD(engineLoadTXD("files/" .. path .. ".txd"), model)
	engineReplaceModel(engineLoadDFF("files/" .. path .. ".dff"), model)
end

loadMod("ak", 355)
loadMod("m4", 356)
loadMod("colt45", 346)
loadMod("ndesert", 348)
loadMod("katana", 339)
loadMod("nmicro_uzi", 352)
loadMod("mp5", 353)
loadMod("sawnoff", 350)
loadMod("shotgspa", 351)
loadMod("nsilenced", 347)
loadMod("nsniper", 358)
loadMod("ntec9", 372)
loadMod("knifecur", 335)
loadMod("chromegun", 349)
loadMod("pickaxe", 337)
loadMod("axe", 321)


