--!strict
-- DataStoreService - Centralized data management for players

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local playerDataStore: any = nil
pcall(function()
	playerDataStore = DataStoreService:GetDataStore("EvaPlayerData_v2")
end)

-- Default data structure
local DEFAULT_DATA = {
	Coins = 0,
	Rank = "A",
	PickPower = 1,
	MaxCapacity = 35,
	StoredOreValue = 0,
	PrestigeLevel = 0,
	AutoSellUnlocked = false,
	AutoSellActive = false,
	Pets = {}, -- array of pet IDs
	AutoMineTier = 1,
	SavedCombos = {},
	QuestProgress = {},
	UnclaimedAchievements = {},
	HasSeenTutorial = false, -- New player tutorial tracking
}

-- In-memory cache for quick access
local playerCache = {}

local DataStoreServiceModule = {}

function DataStoreServiceModule.GetData(player: Player): any
	return playerCache[player.UserId] or DEFAULT_DATA
end

function DataStoreServiceModule.GetStat(player: Player, stat: string): any
	local data = DataStoreServiceModule.GetData(player)
	return data[stat]
end

function DataStoreServiceModule.SetStat(player: Player, stat: string, value: any): boolean
	local data = DataStoreServiceModule.GetData(player)
	data[stat] = value
	playerCache[player.UserId] = data
	return true
end

function DataStoreServiceModule.AddStat(player: Player, stat: string, amount: number): boolean
	local data = DataStoreServiceModule.GetData(player)
	if typeof(data[stat]) == "number" then
		data[stat] = data[stat] + amount
		playerCache[player.UserId] = data
		return true
	end
	return false
end

function DataStoreServiceModule.HasPet(player: Player, petId: string): boolean
	local data = DataStoreServiceModule.GetData(player)
	return table.find(data.Pets or {}, petId) or false
end

function DataStoreServiceModule.AddPet(player: Player, petId: string): boolean
	local data = DataStoreServiceModule.GetData(player)
	if not table.find(data.Pets, petId) then
		table.insert(data.Pets, petId)
		playerCache[player.UserId] = data
		return true
	end
	return false
end

function DataStoreServiceModule.SavePlayerData(player: Player)
	local data = playerCache[player.UserId]
	if not data then return end

	if not playerDataStore then return end

	local success, err = pcall(function()
		playerDataStore:SetAsync("PlayerData_" .. player.UserId, data)
	end)

	if success then
		print("💾 Saved data for " .. player.Name)
		-- Clear temp stored value on success
		data.StoredOreValue = 0
	else
		warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

function DataStoreServiceModule.LoadPlayerData(player: Player)
	if not playerDataStore then
		playerCache[player.UserId] = table.clone(DEFAULT_DATA)
		return
	end

	local success, savedData = pcall(function()
		return playerDataStore:GetAsync("PlayerData_" .. player.UserId)
	end)

	if success and savedData then
		-- Merge with defaults for new keys
		for key, defaultValue in pairs(DEFAULT_DATA) do
			if savedData[key] == nil then
				savedData[key] = defaultValue
			end
		end
		playerCache[player.UserId] = savedData
		print("✅ Loaded data for " .. player.Name)
	else
		if not success then
			warn("Error loading data for " .. player.Name .. ": " .. tostring(savedData))
		end
		playerCache[player.UserId] = table.clone(DEFAULT_DATA)
	end
end

Players.PlayerAdded:Connect(function(player)
	DataStoreServiceModule.LoadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DataStoreServiceModule.SavePlayerData(player)
	playerCache[player.UserId] = nil
end)

game:BindToClose(function()
	if RunService:IsStudio() then
		task.wait(1)
	end
	for userId, _ in pairs(playerCache) do
		for _, player in ipairs(Players:GetPlayers()) do
			if player.UserId == userId then
				DataStoreServiceModule.SavePlayerData(player)
				break
			end
		end
	end
end)

return DataStoreServiceModule