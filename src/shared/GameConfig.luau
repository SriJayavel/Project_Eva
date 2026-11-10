--!strict
local GameConfig = {}

GameConfig.BLOCK_SIZE = 4
GameConfig.RESET_INTERVAL = 90 -- seconds

-- Ore types definition
GameConfig.ORES = {
	Stone = { Name = "Stone", Health = 2, Value = 1, Color = Color3.fromRGB(128, 128, 128) },
	Coal = { Name = "Coal", Health = 3, Value = 3, Color = Color3.fromRGB(35, 35, 35) },
	Iron = { Name = "Iron", Health = 6, Value = 8, Color = Color3.fromRGB(215, 185, 145) },
	Gold = { Name = "Gold", Health = 10, Value = 20, Color = Color3.fromRGB(255, 215, 0) },
	Diamond = { Name = "Diamond", Health = 18, Value = 65, Color = Color3.fromRGB(0, 220, 255) },
	Emerald = { Name = "Emerald", Health = 25, Value = 160, Color = Color3.fromRGB(46, 204, 113) },
	Obsidian = { Name = "Obsidian", Health = 50, Value = 450, Color = Color3.fromRGB(40, 20, 60) },
}

-- Mine definitions for each rank
GameConfig.MINES = {
	A = {
		Name = "Mine A (Starter)",
		Size = Vector3.new(8, 3, 8),
		Position = Vector3.new(0, 0, -45),
		SpawnPosition = Vector3.new(0, 3, -15),
		Ores = {
			{ Ore = GameConfig.ORES.Stone, Weight = 55 },
			{ Ore = GameConfig.ORES.Coal, Weight = 30 },
			{ Ore = GameConfig.ORES.Iron, Weight = 15 },
		}
	},
	B = {
		Name = "Mine B (Iron & Gold)",
		Size = Vector3.new(8, 3, 8),
		Position = Vector3.new(80, 0, -45),
		SpawnPosition = Vector3.new(80, 3, -15),
		Ores = {
			{ Ore = GameConfig.ORES.Stone, Weight = 25 },
			{ Ore = GameConfig.ORES.Iron, Weight = 45 },
			{ Ore = GameConfig.ORES.Gold, Weight = 25 },
			{ Ore = GameConfig.ORES.Diamond, Weight = 5 },
		}
	},
	C = {
		Name = "Mine C (Gems & Obsidian)",
		Size = Vector3.new(8, 3, 8),
		Position = Vector3.new(160, 0, -45),
		SpawnPosition = Vector3.new(160, 3, -15),
		Ores = {
			{ Ore = GameConfig.ORES.Gold, Weight = 30 },
			{ Ore = GameConfig.ORES.Diamond, Weight = 40 },
			{ Ore = GameConfig.ORES.Emerald, Weight = 20 },
			{ Ore = GameConfig.ORES.Obsidian, Weight = 10 },
		}
	}
}

-- Pickaxes progression
GameConfig.PICKAXES = {
	{ Name = "Wooden Pickaxe",    Power = 1,  Cost = 0 },
	{ Name = "Stone Pickaxe",     Power = 3,  Cost = 150 },
	{ Name = "Iron Pickaxe",      Power = 6,  Cost = 600 },
	{ Name = "Diamond Pickaxe",   Power = 15, Cost = 2500 },
	{ Name = "Netherite Pickaxe", Power = 35, Cost = 10000 },
	{ Name = "Atomic Pickaxe",    Power = 90, Cost = 50000 },
}

-- Backpack progression
GameConfig.BACKPACKS = {
	{ Capacity = 35,  Cost = 0 },
	{ Capacity = 75,  Cost = 200 },
	{ Capacity = 160, Cost = 800 },
	{ Capacity = 350, Cost = 3000 },
	{ Capacity = 800, Cost = 12000 },
}

-- Ranks progression
GameConfig.RANKS = {
	{ Rank = "A", Next = "B", Cost = 500 },
	{ Rank = "B", Next = "C", Cost = 3500 },
	{ Rank = "C", Next = "D", Cost = 15000 },
	{ Rank = "D", Next = "Free", Cost = 60000 },
}

-- PRESTIGE SYSTEM
GameConfig.PRESTIGES = {
	{ Level = 1, Multiplier = 1.5, Cost = 0, Desc = "Eva Awakens" },
	{ Level = 2, Multiplier = 2.0, Cost = 10000, Desc = "Eva Grows Stronger" },
	{ Level = 3, Multiplier = 2.8, Cost = 50000, Desc = "Eva Becomes Legendary" },
	{ Level = 4, Multiplier = 3.8, Cost = 200000, Desc = "Eva Transcends" },
	{ Level = 5, Multiplier = 5.0, Cost = 1000000, Desc = "Eva Ascends" },
	{ Level = 6, Multiplier = 6.5, Cost = 5000000, Desc = "Eva Evolves" },
	{ Level = 7, Multiplier = 8.0, Cost = 25000000, Desc = "Eva Ascended+" },
	{ Level = 8, Multiplier = 10.0, Cost = 100000000, Desc = "Eva Supreme" },
}
GameConfig.MAX_PRESTIGE = #GameConfig.PRESTIGES

-- PETS SYSTEM
-- Pets provide +X% Earnings and +Y% Mining Power
GameConfig.PETS = {
	-- Common
	StonePup = { Name = "Stone Pup", Rarity = "Common", Cost = 100, EarningsBonus = 2, PowerBonus = 1, Symbol = "🪨" },
	Woodlins = { Name = "Woodlins", Rarity = "Common", Cost = 250, EarningsBonus = 3, PowerBonus = 2, Symbol = "🌳" },

	-- Rare
	CrystalFox = { Name = "Crystal Fox", Rarity = "Rare", Cost = 1000, EarningsBonus = 8, PowerBonus = 5, Symbol = "💎" },
	PetalSprite = { Name = "Petal Sprite", Rarity = "Rare", Cost = 1500, EarningsBonus = 10, PowerBonus = 6, Symbol = "🌸" },

	-- Epic
	GemDragon = { Name = "Gem Dragon", Rarity = "Epic", Cost = 8000, EarningsBonus = 20, PowerBonus = 12, Symbol = "🐉" },
	OmniFawn = { Name = "Omni Fawn", Rarity = "Epic", Cost = 12000, EarningsBonus = 25, PowerBonus = 15, Symbol = "🦄" },

	-- Legendary
	PrimalBeast = { Name = "Primal Beast", Rarity = "Legendary", Cost = 50000, EarningsBonus = 45, PowerBonus = 30, Symbol = "🦁" },
	EvaSpirit = { Name = "Eva Spirit", Rarity = "Legendary", Cost = 75000, EarningsBonus = 60, PowerBonus = 40, Symbol = "👻" },

	-- Mythic
	QuantumWisp = { Name = "Quantum Wisp", Rarity = "Mythic", Cost = 250000, EarningsBonus = 100, PowerBonus = 65, Symbol = "⚛️" },
	PrimeValkyrie = { Name = "Prime Valkyrie", Rarity = "Mythic", Cost = 500000, EarningsBonus = 150, PowerBonus = 100, Symbol = "⚡" },

	-- Celestial (Ultra-Rare)
	EvaCore = { Name = "Eva Core", Rarity = "Celestial", Cost = 2000000, EarningsBonus = 300, PowerBonus = 200, Symbol = "🔮" },
}

-- QUEST SYSTEM
GameConfig.QUESTS = {
	-- Daily Mining Quests
	{ Id = "daily_stone", Name = "Mine Stone", Desc = "Mine 100 Stone blocks", Target = 100, Reward = 50, Type = "mine" },
	{ Id = "daily_coal", Name = "Coal Rush", Desc = "Mine 75 Coal blocks", Target = 75, Reward = 100, Type = "mine" },
	{ Id = "daily_iron", Name = "Iron Rush", Desc = "Mine 50 Iron blocks", Target = 50, Reward = 200, Type = "mine" },
	{ Id = "daily_gold", Name = "Golden Touch", Desc = "Mine 25 Gold blocks", Target = 25, Reward = 500, Type = "mine" },
	{ Id = "daily_sell", Name = "Peddler", Desc = "Sell 1000 coins worth of ores", Target = 1000, Reward = 150, Type = "sell" },
	{ Id = "daily_rank", Name = "Rank Up", Desc = "Rank up to a new rank", Target = 1, Reward = 1000, Type = "rank" },

	-- Special Quest Chains
	{ Id = "prestige_seeker", Name = "Prestige Seeker", Desc = "Prestige once", Target = 1, Reward = 5000, Type = "prestige" },
	{ Id = "diamond_miner", Name = "Diamond Miner", Desc = "Mine 10 Diamonds", Target = 10, Reward = 10000, Type = "mine" },
	{ Id = "obsidian_dig", Name = "Obsidian Dig", Desc = "Mine 5 Obsidian blocks", Target = 5, Reward = 25000, Type = "mine" },
}

-- AUTO-MINE SETTINGS
GameConfig.AUTO_MINE = {
	{ Tier = 1, Cost = 0, Rate = 2, ValueMultiplier = 0.5 },   -- +2 coins/sec @ 0.5x ore value
	{ Tier = 2, Cost = 250, Rate = 3, ValueMultiplier = 0.75 }, -- +3 coins/sec @ 0.75x
	{ Tier = 3, Cost = 800, Rate = 5, ValueMultiplier = 1.0 },  -- +5 coins/sec @ 1x
	{ Tier = 4, Cost = 2500, Rate = 8, ValueMultiplier = 1.5 }, -- +8 coins/sec @ 1.5x
	{ Tier = 5, Cost = 8000, Rate = 12, ValueMultiplier = 2.0 }, -- +12 coins/sec @ 2x
	{ Tier = 6, Cost = 25000, Rate = 18, ValueMultiplier = 3.0 }, -- +18 coins/sec @ 3x
	{ Tier = 7, Cost = 100000, Rate = 25, ValueMultiplier = 4.0 }, -- +25 coins/sec @ 4x
	{ Tier = 8, Cost = 500000, Rate = 35, ValueMultiplier = 5.0 }, -- +35 coins/sec @ 5x
}

-- COMBO SYSTEM
GameConfig.COMBO = {
	MaxCombo = 20,
	ComboBaseTime = 5, -- seconds to reset combo
	ComboMultipliers = {
		[5] = 1.2,
		[10] = 1.5,
		[15] = 2.0,
		[20] = 3.0,
	},
}

-- MINING BUFFS
GameConfig.BUFFS = {
	Adrenaline = { Name = "Adrenaline", Duration = 10, PowerBoost = 1.5, Emoji = "💥" },
	GoldRush = { Name = "Gold Rush", Duration = 15, EarningsBoost = 2.0, Emoji = "🌟" },
	MoltenCore = { Name = "Molten Core", Duration = 20, PowerBoost = 2.0, EarningsBoost = 1.5, Emoji = "🔥" },
}

return GameConfig