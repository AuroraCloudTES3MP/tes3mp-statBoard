--[[
AuroraStatBoard
tes3mp 0.8.1
---------------------------
INSTALLATION:
Save the file as AuroraStatBoard.lua inside your server/scripts/custom folder.
Edits to customScripts.lua add in :
require("custom.AuroraStatBoard")

Credits
-Aurora Cloud
-Rickoff Polishing up and adding TotalPlayTime counter

"Reimplemented original level up counter to fix server crash when
a newly made character gets created
---------------------------
command /sb to view server statistics
]]
local baseData = {
	totalPlayerKills = 0,
	totalPlayerLevelUps = 0,
	totalPlayerLogins = 0,
	totalPlayerFactionPromotions = 0,
	totalPlayerJournalUpdates = 0,
	totalPlayerPlayedTime = 0		
} 

local gui = {
	main = 3889165
}

local auroraData = {}

local function saveData()
	jsonInterface.save("custom/auroraDatabase.json", auroraData)
end

local function loadData()
	auroraData = jsonInterface.load("custom/auroraDatabase.json")
end

local methods = {}

local function GetTimePlayed(timer)
    local days = math.floor(timer / 86400)
    local hours = math.floor((timer % 86400) / 3600)
    local minutes = math.floor((timer % 3600) / 60)
    local seconds = timer % 60
    local timeFormat = string.format("%dd%02dh%02dm%02ds", days, hours, minutes, seconds)
    return timeFormat
end

local function showMainMenu(pid)
	local message = (
		color.DodgerBlue.."Server Statistics Board\n".."\n".. 
		color.Yellow.."Current Hour: "..math.floor(WorldInstance.data.time.hour).."\n"..
		"Current Day: "..WorldInstance.data.time.day.."\n".. 
		"Current Month: "..WorldInstance.data.time.month.."\n"..
		"Days Passed: "..WorldInstance.data.time.daysPassed.."\n"..
		"Total Kills by Players: "..auroraData.totalPlayerKills.."\n"..
		"Total Player Logins: "..auroraData.totalPlayerLogins.."\n"..
		"Total Player Level-Ups: "..auroraData.totalPlayerLevelUps.."\n"..
		"Total Player Faction Promotions: "..auroraData.totalPlayerFactionPromotions.."\n"..
		"Total Player Journal Updates: "..auroraData.totalPlayerJournalUpdates.."\n"..
		"Total Player Played Time: "..GetTimePlayed(auroraData.totalPlayerPlayedTime).."\n"
	)
	tes3mp.CustomMessageBox(pid, gui.main, message, "Close") 
end


customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	loadData()	
	local needSave = false
	if not auroraData then
		auroraData = baseData
		needSave = true
	else
		for data, value in pairs(baseData) do
			if not auroraData[data] then
				auroraData[data] = value
				needSave = true
			end
		end
	end
	if needSave then
		saveData()
	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(pid, eventStatus)
	auroraData.totalPlayerLogins = auroraData.totalPlayerLogins + 1
	saveData()
end)

methods.auroraLevelUp = function(eventStatus, pid)

 if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
	local levelUp = tes3mp.GetLevel(pid)
	if levelUp == 1 then return
      end
      auroraData.totalPlayerLevelUps = auroraData.totalPlayerLevelUps + 1
    saveData()
   end
end
customEventHooks.registerHandler("OnPlayerFaction", function(pid, eventStatus)
	local action = tes3mp.GetFactionChangesAction(pid)       
	if action == enumerations.faction.RANK then
		auroraData.totalPlayerFactionPromotions = auroraData.totalPlayerFactionPromotions + 1
		saveData()	
	end
end)

customEventHooks.registerHandler("OnPlayerJournal", function(pid, eventStatus)
	local action = enumerations.journal.INDEX
	if action then
		auroraData.totalPlayerJournalUpdates = auroraData.totalPlayerJournalUpdates + 1
		saveData()		
	end
end)

customEventHooks.registerHandler("OnActorDeath", function(eventStatus, pid, cellDescription, actors)
	for index, actor in pairs(actors) do
		if actor.killer.pid and actor.refId then			
			auroraData.totalPlayerKills = auroraData.totalPlayerKills + 1
			saveData()
		end
	end
end)

customEventHooks.registerValidator("OnPlayerDisconnect", function(eventStatus, pid)
    auroraData.totalPlayerPlayedTime = auroraData.totalPlayerPlayedTime + Players[pid].data.timestamps.lastSessionDuration
	saveData()
end)

customEventHooks.registerHandler("OnPlayerLevel", methods.auroraLevelUp)
customCommandHooks.registerCommand("sb", showMainMenu)
