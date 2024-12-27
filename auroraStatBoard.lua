--[[

|=========================|
| Server Statistics Board |
|=========================|

command /sb to view server statistics

]]

local auroraStatBoard = {}
auroraStatFunc = require("custom.auroraStatFunc")
auroraStatBoard.GUI = 3889165
local auroraCounterConfig = {}

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
				    --think this is backwards?
auroraStatBoard.Main = function(pid, eventStatus)

local daysPassed = WorldInstance.data.time.daysPassed
local hour = math.floor(WorldInstance.data.time.hour)
local day = WorldInstance.data.time.day
local month = WorldInstance.data.time.month
local totalPlayerKills = auroraCounterConfig.data.totalPlayerKills
local totalPlayerLevelUps = auroraCounterConfig.data.totalPlayerLevelUps
local totalPlayerLogins = auroraCounterConfig.data.totalPlayerLogins
local totalPlayerFactionPromotions = auroraCounterConfig.data.totalPlayerFactionPromotions
local totalPlayerJournalUpdates = auroraCounterConfig.data.totalPlayerJournalUpdates
local list = ""         		
list = list .. "Close"
  
	auroraCounterConfig.data = jsonInterface.load("custom/auroraDatabase.json")		  
	auroraStatBoard.Main = jsonInterface.load("custom/auroraDatabase.json")
	tes3mp.CustomMessageBox(pid, auroraStatBoard.GUI, color.DodgerBlue .. "Server Statistics Board\n" .. "\n" .. color.Yellow .. "Current Hour " .. hour .. "\n" .. "Current Day: " .. day .. "\n" .. "Current Month: " .. month .."\n" .. 
 "Days Passed: " .. daysPassed .. "\n" .. "Total Kills by Players: "  .. totalPlayerKills .. "\n" .. "Total Player Logins: " .. totalPlayerLogins .. "\n" .. "Total Player Level-Ups: " .. totalPlayerLevelUps .. "\n" .. 
 "Total Player Faction Promotions: " .. totalPlayerFactionPromotions .. "\n" .. "Total Player Journal Updates: " .. totalPlayerJournalUpdates .. color.Default, list) 
end

customCommandHooks.registerCommand("sb", auroraStatBoard.Main)
customEventHooks.registerHandler("OnServerPostInit", auroraCounterConfig.loadData)
