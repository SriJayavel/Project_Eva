--!strict
-- Shared type definitions for the Eva economy system.

export type OreType = {
	Name: string,
	Health: number,
	Value: number,
	Color: Color3,
}

export type MineDef = {
	Name: string,
	Size: Vector3,
	Position: Vector3,
	SpawnPosition: Vector3,
	Ores: { { Ore: OreType, Weight: number } },
}

export type PickaxeTier = { Name: string, Power: number, Cost: number }

export type BackpackTier = { Capacity: number, Cost: number }

export type RankDef = { Rank: string, Next: string, Cost: number }

export type PetDef = {
	Name: string,
	Rarity: string,
	Cost: number,
	EarningsBonus: number,
	PowerBonus: number,
	Symbol: string,
}

export type QuestDef = {
	Id: string,
	Name: string,
	Desc: string,
	Target: number,
	Reward: number,
	Type: string,
}

-- GameConfig module type
export type GameConfigType = typeof GameConfig

local Types = {}
return Types