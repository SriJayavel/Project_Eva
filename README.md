# Eva

A Roblox mining game where you dig ores, sell them, buy upgrades, rank up, prestige, collect pets, and unlock auto-mine income — all powered by Eva, your AI companion who grows stronger with every prestige.

## Getting Started

To build the place from scratch, use:

```bash
rojo build -o "Eva.rbxlx"
```

Next, open `Eva.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

## Features

- ⛏️ **Mining** — Click blocks with your pickaxe. TNT blast proc on high-tier pickaxes.
- 💰 **Sell Pad** — Sell ores for coins. Prestige + pets multiply your earnings.
- 🛠️ **Shops** — Buy pickaxes, backpacks, pets, auto-mine, and auto-sell.
- 🔮 **Prestige** — Reset progress for permanent earnings multipliers. Each prestige awakens Eva further.
- 🐾 **Pets** — Cosmetic companions with passive earnings and power bonuses.
- 🤖 **Auto-Mine** — Passive income while you AFK.
- ⚡ **Combo System** — Chain hits for escalating multipliers.
- 🔥 **Buffs** — Activate timed power/earnings boosts.
- 📜 **Quests** — Complete objectives for coin rewards.
- 🏆 **Achievements** — Track milestones and earn bonuses.
- 👾 **Eva Companion** — Your AI sidekick with hints and growing power.

## Libraries

- **Roact** — UI component library
- **Roact-Redux** — State management
- **Cryo** — Utility functions
- **Signal** — Event handling

## Setup

```bash
npm install -g rojo
rojo build -o "Eva.rbxlx"
```

## Controls

- `B` — Open shop
- `M` — Open mine teleports
- `P` — Open pets
- `Q` — Open quests
- `G` — Open prestige