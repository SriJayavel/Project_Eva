--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return end

local DataStoreService = require(Shared:WaitForChild("DataStoreModule", 10) :: ModuleScript)

local function setupPlayer(player: Player)
	-- Get data from DataStore
	local data = DataStoreService.GetData(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.Coins
	coins.Parent = leaderstats

	local backpack = Instance.new("IntValue")
	backpack.Name = "Backpack"
	backpack.Value = 0
	backpack.Parent = leaderstats

	local rank = Instance.new("StringValue")
	rank.Name = "Rank"
	rank.Value = data.Rank
	rank.Parent = leaderstats

	local hiddenStats = Instance.new("Folder")
	hiddenStats.Name = "HiddenStats"
	hiddenStats.Parent = player

	local maxCapacity = Instance.new("IntValue")
	maxCapacity.Name = "MaxCapacity"
	maxCapacity.Value = data.MaxCapacity
	maxCapacity.Parent = hiddenStats

	local pickPower = Instance.new("IntValue")
	pickPower.Name = "PickPower"
	pickPower.Value = data.PickPower
	pickPower.Parent = hiddenStats

	local storedOreValue = Instance.new("IntValue")
	storedOreValue.Name = "StoredOreValue"
	storedOreValue.Value = data.StoredOreValue
	storedOreValue.Parent = hiddenStats

	local autoSellUnlocked = Instance.new("BoolValue")
	autoSellUnlocked.Name = "AutoSellUnlocked"
	autoSellUnlocked.Value = data.AutoSellUnlocked
	autoSellUnlocked.Parent = hiddenStats

	local autoSellActive = Instance.new("BoolValue")
	autoSellActive.Name = "AutoSellActive"
	autoSellActive.Value = data.AutoSellActive
	autoSellActive.Parent = hiddenStats

	-- Tutorial tracking
	local hasSeenTutorial = Instance.new("BoolValue")
	hasSeenTutorial.Name = "HasSeenTutorial"
	hasSeenTutorial.Value = data.HasSeenTutorial or false
	hasSeenTutorial.Parent = hiddenStats

	-- Pet bonuses
	local petBonuses = Instance.new("NumberValue")
	petBonuses.Name = "PetBonuses"
	petBonuses.Value = 0
	petBonuses.Parent = hiddenStats

	-- Active buffs folder
	local activeBuffs = Instance.new("Folder")
	activeBuffs.Name = "ActiveBuffs"
	activeBuffs.Parent = hiddenStats

	-- Player preferences
	local preferences = Instance.new("Folder")
	preferences.Name = "Preferences"
	preferences.Parent = hiddenStats

	local uiHidden = Instance.new("BoolValue")
	uiHidden.Name = "UIHidden"
	uiHidden.Value = false -- Start with UI visible
	uiHidden.Parent = preferences

	-- Auto-mine tier
	local autoMineTier = Instance.new("IntValue")
	autoMineTier.Name = "AutoMineTier"
	autoMineTier.Value = data.AutoMineTier or 1
	autoMineTier.Parent = hiddenStats

	print("✅ Player " .. player.Name .. " setup complete with rank " .. data.Rank)
end

Players.PlayerAdded:Connect(setupPlayer)

-- Save on server shutdown
game:BindToClose(function()
	if RunService:IsStudio() then
		task.wait(1)
	end
	for _, player in ipairs(Players:GetPlayers()) do
		-- Data is saved by DataStoreService
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end