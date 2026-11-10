# Eva - Roblox Prison Mine Simulator

## Project Overview
This is a modern Roblox Prison Mining Simulator developed using **Luau** and managed via **Rojo**.
All game code is structured locally on disk in `src/` and synced into Roblox Studio or compiled into `EvaGame.rbxl`.

## Build & Sync Commands
- **Live Sync into Roblox Studio**: `rojo serve` (Connect using the Rojo Studio plugin)
- **Compile Place File**: `rojo build -o EvaGame.rbxl`

## Directory Structure
- `default.project.json`: Rojo configuration mapping local files to Roblox DataModel instances.
- `src/shared/`:
  - `GameConfig.luau`: Central configuration for Ores, Mines (A, B, C), Pickaxe Tiers, Backpack Tiers, and Ranks.
  - `Network.luau`: RemoteEvent and RemoteFunction retrieval with timeout guards.
- `src/server/`:
  - `Leaderstats.server.luau`: Manages player stats (`Coins`, `Backpack`, `Rank`, `PickPower`, `MaxCapacity`) with DataStore persistence.
  - `MineManager.server.luau`: Procedural mine generation, auto-reset countdown broadcast, quarry border walls, lanterns, and Sell Pad logic.
  - `MiningHandler.server.luau`: Raycast hit verification, block damage, floating damage/coin numbers, break particle effects, sound emitters, and explosive mining (TNT proc).
  - `ShopManager.server.luau`: Handles pickaxe purchases, backpack upgrades, rank-ups, mine teleports, and Auto-Sell service.
- `src/client/`:
  - `HUDController.client.luau`: On-screen GUI (backpack capacity bar, live reset countdown, upgrade shop modal, mine teleports modal, toast notifications).
- `src/tools/`:
  - `PickaxeController.client.luau`: Player mouse raycasting tool script attached to the Pickaxe in `StarterPack`.

## Key Coding Conventions & Guidelines
- Use `--!strict` at the top of Luau files where applicable.
- Client-Server boundary: Client requests actions through `ReplicatedStorage.Remotes` using `RemoteEvent:FireServer()` or `RemoteFunction:InvokeServer()`.
- Never trust the client for money, stats, or block breaking; always validate distance and stats on the server.
- Block attributes: Each active ore block uses attributes: `Health`, `MaxHealth`, `Value`, `OreType`, `MineRank`.
- When adding new remotes, declare them under `ReplicatedStorage.Remotes` in `default.project.json`.

