--[[
§ Server Statistics Board §

By Aurora Cloud (IM NEW TO THIS)
My first public tes3mp server script.
================
INSTALLATION
server/scripts/custom/

Add to customScripts.lua in server/scripts

require("custom.auroraStatBoard")
require("custom.auroraStatFunc")

This script only serves as a statistics display/counter for servers

DISPLAY
|Current Hour
|Current Day
|Current Month
|Days Passed
|Total kills made by players
|Total level ups by players
|Total faction promotions


==TODO==
Fix script does not count login counter for newly created characters, maybe use OnPlayerEndCharGen for totalPlayerLogins + 1?
Fix having to open and close stat board twice to see updated values

ADD: totalCellVisits
ADD: totalPlayerCustomItems, unsure as how im going to approach that method yet.

]]

local auroraStatFunc = {}
local auroraCounterConfig = {}
local methods = {}

auroraCounterConfig.loadData = function()
    auroraCounterConfig.data = jsonInterface.load("custom/auroraDatabase.json")
    if auroraCounterConfig.data == nil then
	
	auroraCounterConfig.data = {
		totalPlayerKills = 0,
		totalPlayerLevelUps = 0,
		totalPlayerLogins = 0,
		totalPlayerFactionPromotions = 0,
		totalPlayerJournalUpdates = 0
		
	}
    end
end

auroraCounterConfig.saveData = function()
	jsonInterface.save("custom/auroraDatabase.json", auroraCounterConfig.data)
end

methods.addKillData = function(pid)
	if totalPlayerKills == nil then totalPlayerKills = 0 end
		auroraCounterConfig.data.totalPlayerKills = auroraCounterConfig.data.totalPlayerKills + 1
		auroraCounterConfig.saveData()
	end

methods.addLevelUpData = function(pid)
	if totalPlayerLevelUps == nil then totalPlayerLevelUps = 0 end
		auroraCounterConfig.data.totalPlayerLevelUps = auroraCounterConfig.data.totalPlayerLevelUps + 1
		auroraCounterConfig.saveData()
	end
	
methods.addPlayerLoginData = function(pid)
	if totalPlayerLogins == nil then totalPlayerLogins = 0 end
		auroraCounterConfig.data.totalPlayerLogins = auroraCounterConfig.data.totalPlayerLogins + 1
		auroraCounterConfig.saveData()
	end
	
methods.addPlayerFactionPromoData = function(pid)
	if totalPlayerFactionPromotions == nil then totalPlayerFactionPromotions = 0 end
		auroraCounterConfig.data.totalPlayerFactionPromotions = auroraCounterConfig.data.totalPlayerFactionPromotions + 1
		auroraCounterConfig.saveData()
	end
	
methods.addPlayerJournalData = function(pid)
	if totalPlayerJournalUpdates == nil then totalPlayerJournalUpdates = 0 end
		auroraCounterConfig.data.totalPlayerJournalUpdates = auroraCounterConfig.data.totalPlayerJournalUpdates + 1
		auroraCounterConfig.saveData()
	end
			
auroraCounterConfig.saveDataCmd= function(pid, cmd)
--This was originally used for creating the json data for early testing
	if cmd == "savejson" and Players[pid].data.staffRank >= 1 then
	  jsonInterface.save("custom/auroraDatabase.json", auroraCounterConfig.data)
		else
		 tes3mp.SendMessage(pid, color.Error .. "Only Admins may use this command.\n")
	 end
end
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.loadData)

    customEventHooks.registerHandler("OnActorDeath", function(eventStatus, pid, cellDescription, actors)
		local pAccnt = Players[pid].data.accountName
        local cell = LoadedCells[cellDescription]
		
		--Do I need this stuff???
	tes3mp.ClearKillChanges()

	for uniqueIndex, actor in pairs(actors) do		
		if WorldInstance.data.kills[actor.refId] == nil then
			WorldInstance.data.kills[actor.refId] = 0
		end		
            table.insert(cell.unusableContainerUniqueIndexes, uniqueIndex)
        end

		tes3mp.SendWorldKillCount(pid, true)
			methods.addKillData(pid)--add kill count
              for id, _ in pairs(Players) do
                    if cellDescription == tes3mp.GetCell(id) then
			cell:LoadContainers(id, cell.data.objectData, {uniqueIndex})
		   end
		end
	end)
		
methods.auroraLevelUp = function(eventStatus, pid)

    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
       local levelUp = tes3mp.GetLevel(pid)
		if levelUp == 1 then return
		  end
		 methods.addLevelUpData(pid)--add level up count
	  end
	end

methods.auroraLogin = function(eventStatus, pid)
	methods.addPlayerLoginData(pid)--add login count
end

methods.auroraFactionPromotion = function(eventStatus, pid)

if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

	local action = tes3mp.GetFactionChangesAction(pid)       
           if action == enumerations.faction.RANK then
			methods.addPlayerFactionPromoData(pid)--add faction promotion count
	  end
  end
end

methods.auroraJournalUpdate = function(eventStatus, pid)

	local action = enumerations.journal.INDEX
		if action then
			methods.addPlayerJournalData(pid)
		end
	end


customCommandHooks.registerCommand("savejson", auroraCounterConfig.saveDataCmd)
customEventHooks.registerHandler("OnPlayerLevel", methods.auroraLevelUp)
customEventHooks.registerHandler("OnPlayerFinishLogin", methods.auroraLogin)
customEventHooks.registerHandler("OnPlayerFaction", methods.auroraFactionPromotion)
customEventHooks.registerHandler("OnPlayerJournal", methods.auroraJournalUpdate)
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.loadData)
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.saveData)
