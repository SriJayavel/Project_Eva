--!strict
-- Achievements system - tracks player milestones

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return end

local Network = require(Shared:WaitForChild("Network", 10) :: ModuleScript)
local GameConfig = require(Shared:WaitForChild("GameConfig", 10) :: ModuleScript)
local DataStoreService = require(Shared:WaitForChild("DataStoreModule", 10) :: ModuleScript)

-- Define achievements
local ACHIEVEMENTS = {
	{ Id = "first_ore", Name = "First Blood", Desc = "Mine your first block", Target = 1, Reward = 10 },
	{ Id = "miner_100", Name = "Dedicated Miner", Desc = "Mine 100 blocks", Target = 100, Reward = 50 },
	{ Id = "miner_1000", Name = "Excavator", Desc = "Mine 1000 blocks", Target = 1000, Reward = 500 },
	{ Id = "miner_10000", Name = "Drill Master", Desc = "Mine 10000 blocks", Target = 10000, Reward = 5000 },
	{ Id = "rich_1000", Name = "Small Fortune", Desc = "Earn 1000 Coins", Target = 1000, Reward = 100 },
	{ Id = "rich_100000", Name = "Big Fortune", Desc = "Earn 100000 Coins", Target = 100000, Reward = 5000 },
	{ Id = "prestige_1", Name = "Prestige Seeker", Desc = "Prestige once", Target = 1, Reward = 10000 },
	{ Id = "pet_1", Name = "Pet Collector", Desc = "Own 1 pet", Target = 1, Reward = 200 },
	{ Id = "pet_5", Name = "Zoo Keeper", Desc = "Own 5 pets", Target = 5, Reward = 2000 },
	{ Id = "rank_b", Name = "Rising Star", Desc = "Reach Rank B", Target = 1, Reward = 500 },
	{ Id = "rank_d", Name = "Legend", Desc = "Reach Rank D", Target = 1, Reward = 10000 },
	{ Id = "combo_10", Name = "Combo King", Desc = "Get a 10+ combo", Target = 10, Reward = 1000 },
	{ Id = "combo_20", Name = "Combo God", Desc = "Get a 20+ combo", Target = 20, Reward = 5000 },
}

-- Track achievement progress per player
local achievementProgress = {}

-- Hook into mining events to track progress
local mineEvent = Network.getRemoteEvent("MineBlockEvent")
mineEvent.OnServerEvent:Connect(function(player: Player, targetBlock: any)
	-- Track blocks mined
	if not achievementProgress[player.UserId] then
		achievementProgress[player.UserId] = {}
	end
	local progress = achievementProgress[player.UserId]

	-- Increment block counter
	progress["blocks_mined"] = (progress["blocks_mined"] or 0) + 1

	-- Check achievements
	for _, ach in ipairs(ACHIEVEMENTS) do
		if not progress[ach.Id] and progress["blocks_mined"] >= ach.Target then
			-- Claim achievement
			progress[ach.Id] = true
			local data = DataStoreService.GetData(player)
			if data then
				DataStoreService.SetStat(player, "Coins", data.Coins + ach.Reward)
				-- Notify
				local leaderstats = player:FindFirstChild("leaderstats")
				if leaderstats then
					leaderstats.Coins.Value = data.Coins + ach.Reward
				end
			end
			print("🏆 " .. player.Name .. " earned achievement: " .. ach.Name)
		end
	end
end)

-- Hook into coin earnings
local function onCoinEarned(player: Player, amount: number)
	if not achievementProgress[player.UserId] then
		achievementProgress[player.UserId] = {}
	end
	local progress = achievementProgress[player.UserId]

	-- Track total coins earned
	progress["total_coins"] = (progress["total_coins"] or 0) + amount

	for _, ach in ipairs(ACHIEVEMENTS) do
		if not progress[ach.Id] and progress["total_coins"] >= ach.Target then
			progress[ach.Id] = true
			local data = DataStoreService.GetData(player)
			if data then
				DataStoreService.SetStat(player, "Coins", data.Coins + ach.Reward)
			end
			print("🏆 " .. player.Name .. " earned achievement: " .. ach.Name)
		end
	end
end

-- Hook into prestige
local prestigeEvent = Network.getRemoteFunction("PrestigeEvent")
local originalPrestige = prestigeEvent.OnServerInvoke
prestigeEvent.OnServerInvoke = function(player: Player)
	-- Call original
	local result = originalPrestige(player)

	if result then
		-- Check prestige achievement
		if not achievementProgress[player.UserId] then
			achievementProgress[player.UserId] = {}
		end
		local progress = achievementProgress[player.UserId]
		if not progress["prestige_1"] then
			progress["prestige_1"] = true
			local data = DataStoreService.GetData(player)
			if data then
				DataStoreService.SetStat(player, "Coins", data.Coins + 10000)
			end
		end
	end

	return result
end

return ACHIEVEMENTS