local serverDatabase

local db = {}


addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		serverDatabase = dbConnect("mysql", "dbname=s15516_kozmacsabi;host=mysql.srkhost.eu;charset=utf8", "u15516_14O6iOQf8y", "x1yw2TLYO0NL", "tag=sarpdb;multi_statements=1")
		
		if not serverDatabase then
			outputServerLog("[MySQL]: Failed to connect the database.")
			outputDebugString("[MySQL]: Sikertelen kapcsolódás az adatbázishoz!", 1)
			cancelEvent()
		else
			dbExec(serverDatabase, "SET NAMES utf8")
			outputDebugString("[MySQL]: Sikeres kapcsolódás az adatbázishoz.")
		end
	end
)

function getConnection()
	return serverDatabase, db
end
