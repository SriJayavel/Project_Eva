--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return end

local Network = require(Shared:WaitForChild("Network", 10) :: ModuleScript)
local GameConfig = require(Shared:WaitForChild("GameConfig", 10) :: ModuleScript)
local DataStoreService = require(Shared:WaitForChild("DataStoreModule", 10) :: ModuleScript)

local buyPickaxe = Network.getRemoteFunction("BuyPickaxe")
local buyBackpack = Network.getRemoteFunction("BuyBackpack")
local rankUpEvent = Network.getRemoteFunction("RankUpEvent")
local teleportMine = Network.getRemoteFunction("TeleportToMine")
local toggleAutoSell = Network.getRemoteFunction("ToggleAutoSell")
local buyPet = Network.getRemoteFunction("BuyPet")
local buyAutoMine = Network.getRemoteFunction("BuyAutoMine")
local activateBuff = Network.getRemoteFunction("ActivateBuff")
local claimQuest = Network.getRemoteFunction("ClaimQuest")
local prestigeEvent = Network.getRemoteFunction("PrestigeEvent")

local AUTO_SELL_PRICE = 1500

-- Auto-Sell Background Service
task.spawn(function()
	local Players = game:GetService("Players")
	while true do
		task.wait(2.5)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataStoreService.GetData(player)
			if data and data.AutoSellActive then
				local leaderstats = player:FindFirstChild("leaderstats")
				local hiddenStats = player:FindFirstChild("HiddenStats")
				if leaderstats and hiddenStats then
					local backpack = leaderstats:FindFirstChild("Backpack") :: IntValue?
					local coins = leaderstats:FindFirstChild("Coins") :: IntValue?
					local stored = hiddenStats:FindFirstChild("StoredOreValue") :: IntValue?
					if backpack and coins and stored and backpack.Value > 0 then
						local payout = stored.Value
						if payout <= 0 then payout = backpack.Value * 2 end
						coins.Value += payout
						backpack.Value = 0
						stored.Value = 0
					end
				end
			end
		end
	end
end)

buyPickaxe.OnServerInvoke = function(player: Player, pickaxeIndex: any)
	local index = tonumber(pickaxeIndex)
	if not index then return false, "Invalid selection" end

	local tier = GameConfig.PICKAXES[index]
	if not tier then return false, "Pickaxe does not exist" end

	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local coins = data.Coins
	local currentPower = data.PickPower

	if currentPower >= tier.Power then
		return false, "You already have this or a better pickaxe!"
	end

	if coins < tier.Cost then
		return false, "Need " .. tier.Cost .. " Coins!"
	end

	DataStoreService.SetStat(player, "Coins", coins - tier.Cost)
	DataStoreService.SetStat(player, "PickPower", tier.Power)

	-- Update visible stats
	local leaderstats = player:FindFirstChild("leaderstats")
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if leaderstats and hiddenStats then
		leaderstats.Coins.Value = data.Coins - tier.Cost
		hiddenStats.PickPower.Value = tier.Power
	end

	local tool = player.Backpack:FindFirstChildWhichIsA("Tool") or (player.Character and player.Character:FindFirstChildWhichIsA("Tool"))
	if tool then
		tool.Name = tier.Name
	end

	return true, "Equipped " .. tier.Name .. "!"
end

buyBackpack.OnServerInvoke = function(player: Player, backpackIndex: any)
	local index = tonumber(backpackIndex)
	if not index then return false, "Invalid selection" end

	local tier = GameConfig.BACKPACKS[index]
	if not tier then return false, "Backpack tier does not exist" end

	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local coins = data.Coins
	local currentCapacity = data.MaxCapacity

	if currentCapacity >= tier.Capacity then
		return false, "You already have this or a larger backpack!"
	end

	if coins < tier.Cost then
		return false, "Need " .. tier.Cost .. " Coins!"
	end

	DataStoreService.SetStat(player, "Coins", coins - tier.Cost)
	DataStoreService.SetStat(player, "MaxCapacity", tier.Capacity)

	-- Update visible stats
	local leaderstats = player:FindFirstChild("leaderstats")
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if leaderstats and hiddenStats then
		leaderstats.Coins.Value = data.Coins - tier.Cost
		hiddenStats.MaxCapacity.Value = tier.Capacity
	end

	return true, "Backpack upgraded to " .. tier.Capacity .. " slots!"
end

toggleAutoSell.OnServerInvoke = function(player: Player)
	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local coins = data.Coins
	local unlocked = data.AutoSellUnlocked

	if not unlocked then
		if coins < AUTO_SELL_PRICE then
			return false, "Auto-Sell costs " .. AUTO_SELL_PRICE .. " Coins!"
		end
		DataStoreService.SetStat(player, "Coins", coins - AUTO_SELL_PRICE)
		DataStoreService.SetStat(player, "AutoSellUnlocked", true)
		DataStoreService.SetStat(player, "AutoSellActive", true)

		-- Update visible stats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			leaderstats.Coins.Value = coins - AUTO_SELL_PRICE
		end

		return true, "Unlocked Auto-Sell! (Now Active)"
	else
		data.AutoSellActive = not data.AutoSellActive
		local state = data.AutoSellActive and "ON" or "OFF"

		-- Sync to client
		local hiddenStats = player:FindFirstChild("HiddenStats")
		if hiddenStats then
			hiddenStats.AutoSellActive.Value = data.AutoSellActive
		end

		return true, "Auto-Sell turned " .. state
	end
end

rankUpEvent.OnServerInvoke = function(player: Player)
	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local currentRank = data.Rank
	local coins = data.Coins

	local targetRankData = nil
	for _, r in ipairs(GameConfig.RANKS) do
		if r.Rank == currentRank then
			targetRankData = r
			break
		end
	end

	if not targetRankData then
		return false, "Already at maximum rank!"
	end

	if coins < targetRankData.Cost then
		return false, "Need " .. targetRankData.Cost .. " Coins to rank up to " .. targetRankData.Next .. "!"
	end

	-- Apply rank up
	DataStoreService.SetStat(player, "Coins", coins - targetRankData.Cost)
	DataStoreService.SetStat(player, "Rank", targetRankData.Next)

	-- Update visible stats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Coins.Value = coins - targetRankData.Cost
		leaderstats.Rank.Value = targetRankData.Next
	end

	return true, "🎉 Ranked up to Rank " .. targetRankData.Next .. "!"
end

teleportMine.OnServerInvoke = function(player: Player, targetMineRank: any)
	local rankKey = tostring(targetMineRank)
	local mineData = GameConfig.MINES[rankKey]
	if not mineData then return false, "Mine does not exist" end

	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local playerRank = data.Rank

	-- Verify if player is high enough rank
	local rankWeight = { A = 1, B = 2, C = 3, D = 4, Free = 5 }
	local currentWeight = rankWeight[playerRank] or 1
	local targetWeight = rankWeight[rankKey] or 1

	if currentWeight < targetWeight then
		return false, "Locked! You must reach Rank " .. rankKey .. " to enter this mine."
	end

	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return false, "Character not found" end

	local root = character.HumanoidRootPart :: BasePart
	root.CFrame = CFrame.new(mineData.SpawnPosition)

	return true, "Teleported to " .. mineData.Name
end

-- PET PURCHASE SYSTEM
buyPet.OnServerInvoke = function(player: Player, petId: string)
	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local petDef = GameConfig.PETS[petId]
	if not petDef then return false, "Pet does not exist" end

	-- Check if already owned
	if DataStoreService.HasPet(player, petId) then
		return false, "You already own this pet!"
	end

	local coins = data.Coins
	if coins < petDef.Cost then
		return false, "Need " .. petDef.Cost .. " Coins for " .. petDef.Name .. "!"
	end

	-- Purchase
	DataStoreService.SetStat(player, "Coins", coins - petDef.Cost)
	DataStoreService.AddPet(player, petId)

	-- Update visible stats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Coins.Value = coins - petDef.Cost
	end

	return true, "Purchased " .. petDef.Name .. "!"
end

-- AUTO-MINE UPGRADE
buyAutoMine.OnServerInvoke = function(player: Player, tierIndex: any)
	local index = tonumber(tierIndex)
	if not index then return false, "Invalid tier" end

	local tier = GameConfig.AUTO_MINE[tierIndex]
	if not tier then return false, "Auto-mine tier does not exist" end

	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local coins = data.Coins
	local currentTier = data.AutoMineTier

	if currentTier >= index then
		return false, "You already have this or a better auto-mine!"
	end

	if coins < tier.Cost then
		return false, "Need " .. tier.Cost .. " Coins!"
	end

	-- Purchase
	DataStoreService.SetStat(player, "Coins", coins - tier.Cost)
	DataStoreService.SetStat(player, "AutoMineTier", index)

	-- Update visible stats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Coins.Value = coins - tier.Cost
	end

	return true, "Auto-Mine Level " .. index .. " purchased!"
end

-- BUFF ACTIVATION
activateBuff.OnServerInvoke = function(player: Player, buffName: string)
	local BUFFS = GameConfig.BUFFS
	local buffDef = BUFFS[buffName]
	if not buffDef then return false, "Buff does not exist" end

	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local coins = data.Coins
	local cost = buffDef.Cost or 1000

	if coins < cost then
		return false, "Need " .. cost .. " Coins to activate " .. buffDef.Name .. "!"
	end

	-- Apply buff with timer
	local leaderstats = player:FindFirstChild("leaderstats")
	local hiddenStats = player:FindFirstChild("HiddenStats")

	if not leaderstats or not hiddenStats then return false, "Stats missing" end

	local coinsVal = leaderstats:FindFirstChild("Coins") :: IntValue?
	local buffsFolder = hiddenStats:FindFirstChild("ActiveBuffs")
	if not buffsFolder then
		buffsFolder = Instance.new("Folder")
		buffsFolder.Name = "ActiveBuffs"
		buffsFolder.Parent = hiddenStats
	end

	local buffValue = Instance.new("BoolValue")
	buffValue.Name = buffName
	buffValue.Value = true
	buffValue.Parent = buffsFolder

	coinsVal.Value = coinsVal.Value - cost

	-- Auto-expire
	task.delay(buffDef.Duration, function()
		if buffValue then
			buffValue.Value = false
			buffValue:Destroy()
		end
	end)

	return true, buffDef.Emoji .. " " .. buffDef.Name .. " active for " .. buffDef.Duration .. "s!"
end

-- QUEST SYSTEM
local questProgress = {} -- Track progress per player

local function saveQuestProgress(player: Player)
	local data = DataStoreService.GetData(player)
	if not data then return end

	data.QuestProgress = questProgress[player.UserId] or {}
	DataStoreService.SetStat(player, "QuestProgress", data.QuestProgress)
end

claimQuest.OnServerInvoke = function(player: Player, questId: string)
	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local questDef = nil
	for _, q in ipairs(GameConfig.QUESTS) do
		if q.Id == questId then
			questDef = q
			break
		end
	end

	if not questDef then return false, "Quest does not exist" end

	-- Initialize progress if needed
	if not questProgress[player.UserId] then
		questProgress[player.UserId] = {}
	end

	local progress = questProgress[player.UserId]
	local completed = progress[questId]

	if completed then
		return false, "Quest already claimed!"
	end

	-- Check progress (simplified - assume completed for now)
	local current = progress[questId] or 0
	if current >= questDef.Target then
		progress[questId] = true
		saveQuestProgress(player)

		local coins = data.Coins
		DataStoreService.SetStat(player, "Coins", coins + questDef.Reward)

		-- Update visible stats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			leaderstats.Coins.Value = coins + questDef.Reward
		end

		return true, "🎉 Quest complete! +" .. questDef.Reward .. " Coins"
	end

	return false, "Quest not yet complete. Need " .. (questDef.Target - current) .. " more!"
end

-- PRESTIGE SYSTEM
prestigeEvent.OnServerInvoke = function(player: Player)
	local data = DataStoreService.GetData(player)
	if not data then return false, "Data missing" end

	local coins = data.Coins
	local prestigeLevel = data.PrestIGE_LEVEL or 0

	if prestigeLevel >= GameConfig.MAX_PRESTIGE then
		return false, "You're already at maximum prestige!"
	end

	-- Check if we have enough coins
	local prestigeReq = prestigeLevel > 0 and GameConfig.PRESTIGES[prestigeLevel].Cost or 0

	local totalCost = 0
	for i = 1, prestigeLevel + 1 do
		if GameConfig.PRESTIGES[i] then
			totalCost += GameConfig.PRESTIGES[i].Cost
		end
	end

	-- For first prestige, just need 350,000 coins (simple calculation)
	local cost = GameConfig.PRESTIGES[prestigeLevel + 1]
	if not cost then
		return false, "Can't prestige more!"
	end

	if coins < cost.Cost then
		return false, "Need " .. cost.Cost .. " Coins to prestige!"
	end

	-- Reset player data but keep prestige
	DataStoreService.SetStat(player, "Coins", 0)
	DataStoreService.SetStat(player, "Rank", "A")
	DataStoreService.SetStat(player, "PickPower", 1)
	DataStoreService.SetStat(player, "MaxCapacity", 35)
	DataStoreService.SetStat(player, "PrestigeLevel", prestigeLevel + 1)
	DataStoreService.SetStat(player, "StoredOreValue", 0)
	DataStoreService.SetStat(player, "QuestProgress", {})

	-- Update visible stats
	local leaderstats = player:FindFirstChild("leaderstats")
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if leaderstats and hiddenStats then
		leaderstats.Coins.Value = 0
		leaderstats.Rank.Value = "A"
		hiddenStats.PickPower.Value = 1
		hiddenStats.MaxCapacity.Value = 35
		hiddenStats.StoredOreValue.Value = 0
	end

	-- Notify player of prestige bonus
	return true, "🔮 PRESTIGE " .. (prestigeLevel + 1) .. " UNLOCKED! +x" .. cost.Multiplier .. " earnings!"
end