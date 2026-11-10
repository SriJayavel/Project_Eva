--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return end

local GameConfig = require(Shared:WaitForChild("GameConfig", 10) :: ModuleScript)
local Network = require(Shared:WaitForChild("Network", 10) :: ModuleScript)
local DataStoreService = require(Shared:WaitForChild("DataStoreModule", 10) :: ModuleScript)
local countdownEvent = Network.getRemoteEvent("MineResetCountdown")

local activeBlocksFolder = Workspace:FindFirstChild("ActiveMineBlocks")
if not activeBlocksFolder then
	activeBlocksFolder = Instance.new("Folder")
	activeBlocksFolder.Name = "ActiveMineBlocks"
	activeBlocksFolder.Parent = Workspace
end

local function playWorldSound(position: Vector3, soundId: string, volume: number)
	local soundPart = Instance.new("Part")
	soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
	soundPart.Position = position
	soundPart.Transparency = 1
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Parent = Workspace

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 1
	sound.PlayOnRemove = true
	sound.Parent = soundPart

	soundPart:Destroy()
end

local function getRandomOreForMine(mineData: any)
	local totalWeight = 0
	for _, entry in ipairs(mineData.Ores) do
		totalWeight += entry.Weight
	end

	local roll = math.random(1, totalWeight)
	local current = 0
	for _, entry in ipairs(mineData.Ores) do
		current += entry.Weight
		if roll <= current then
			return entry.Ore
		end
	end
	return mineData.Ores[1].Ore
end

local function generateMinePit(rankKey: string, mineData: any)
	for _, child in ipairs(activeBlocksFolder:GetChildren()) do
		if child:GetAttribute("MineRank") == rankKey then
			child:Destroy()
		end
	end

	local bSize = GameConfig.BLOCK_SIZE
	local xCount = mineData.Size.X
	local yCount = mineData.Size.Y
	local zCount = mineData.Size.Z

	local origin = mineData.Position
	local startX = origin.X - ((xCount * bSize) / 2) + (bSize / 2)
	local startZ = origin.Z - ((zCount * bSize) / 2) + (bSize / 2)
	local baseY = 2

	for y = 0, yCount - 1 do
		for x = 0, xCount - 1 do
			for z = 0, zCount - 1 do
				local ore = getRandomOreForMine(mineData)

				local block = Instance.new("Part")
				block.Name = ore.Name
				block.Size = Vector3.new(bSize, bSize, bSize)
				block.Position = Vector3.new(startX + (x * bSize), baseY + (y * bSize), startZ + (z * bSize))
				block.Anchored = true
				block.Material = Enum.Material.Slate
				block.Color = ore.Color
				block.TopSurface = Enum.SurfaceType.Smooth
				block.BottomSurface = Enum.SurfaceType.Smooth

				block:SetAttribute("Health", ore.Health)
				block:SetAttribute("MaxHealth", ore.Health)
				block:SetAttribute("Value", ore.Value)
				block:SetAttribute("OreType", ore.Name)
				block:SetAttribute("MineRank", rankKey)

				block.Parent = activeBlocksFolder
			end
		end
	end
	print("⛏️ Generated " .. mineData.Name .. " (" .. (xCount * yCount * zCount) .. " blocks)")
end

local function generateAllMines()
	for rankKey, mineData in pairs(GameConfig.MINES) do
		generateMinePit(rankKey, mineData)
	end
end

generateAllMines()

-- Countdown loop with broadcast
task.spawn(function()
	local timeLeft = GameConfig.RESET_INTERVAL
	while true do
		task.wait(1)
		timeLeft -= 1
		countdownEvent:FireAllClients(timeLeft)

		if timeLeft <= 0 then
			generateAllMines()
			timeLeft = GameConfig.RESET_INTERVAL
		end
	end
end)

-- 3D World Signs
local function createFloatingSign(position: Vector3, text: string, color: Color3)
	local part = Instance.new("Part")
	part.Name = "WorldSign"
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = Workspace

	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.new(0, 240, 0, 60)
	bill.AlwaysOnTop = true
	bill.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Text = text
	label.Parent = bill
end

-- Procedural Quarry Architecture (Border Walls & Lanterns)
local function buildQuarrySurround(centerPos: Vector3, sizeBlocks: Vector3, bSize: number)
	local folder = Instance.new("Folder")
	folder.Name = "QuarryFrame"
	folder.Parent = Workspace

	local width = (sizeBlocks.X * bSize) + 4
	local length = (sizeBlocks.Z * bSize) + 4
	local height = 4

	local function makeWall(pos: Vector3, size: Vector3)
		local wall = Instance.new("Part")
		wall.Anchored = true
		wall.Material = Enum.Material.Cobblestone
		wall.Color = Color3.fromRGB(80, 80, 85)
		wall.Size = size
		wall.Position = pos
		wall.Parent = folder
	end

	-- 4 border walls
	makeWall(centerPos + Vector3.new(0, height / 2, -(length / 2)), Vector3.new(width + 4, height, 2)) -- North
	makeWall(centerPos + Vector3.new(0, height / 2, (length / 2)), Vector3.new(width + 4, height, 2))  -- South
	makeWall(centerPos + Vector3.new(-(width / 2), height / 2, 0), Vector3.new(2, height, length))     -- West
	makeWall(centerPos + Vector3.new((width / 2), height / 2, 0), Vector3.new(2, height, length))      -- East

	-- Corner Torches/Lanterns
	local corners = {
		centerPos + Vector3.new(-(width / 2), height + 1, -(length / 2)),
		centerPos + Vector3.new((width / 2), height + 1, -(length / 2)),
		centerPos + Vector3.new(-(width / 2), height + 1, (length / 2)),
		centerPos + Vector3.new((width / 2), height + 1, (length / 2)),
	}

	for _, cPos in ipairs(corners) do
		local lantern = Instance.new("Part")
		lantern.Size = Vector3.new(1.5, 2, 1.5)
		lantern.Position = cPos
		lantern.Anchored = true
		lantern.Material = Enum.Material.Neon
		lantern.Color = Color3.fromRGB(255, 170, 40)
		lantern.Parent = folder

		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 180, 70)
		light.Brightness = 3
		light.Range = 24
		light.Parent = lantern
	end
end

-- Build Quarry walls around Mine A, B, and C
for _, mineData in pairs(GameConfig.MINES) do
	buildQuarrySurround(mineData.Position, mineData.Size, GameConfig.BLOCK_SIZE)
end

-- Shop Stall Architecture around Sell Pad
local function buildShopStall(sellPos: Vector3)
	local stall = Instance.new("Folder")
	stall.Name = "ShopStall"
	stall.Parent = Workspace

	local function makeWood(pos: Vector3, size: Vector3)
		local p = Instance.new("Part")
		p.Anchored = true
		p.Material = Enum.Material.WoodPlanks
		p.Color = Color3.fromRGB(115, 75, 45)
		p.Size = size
		p.Position = pos
		p.Parent = stall
	end

	-- 4 Support Pillars
	makeWood(sellPos + Vector3.new(-8, 6, -8), Vector3.new(1.5, 12, 1.5))
	makeWood(sellPos + Vector3.new(8, 6, -8), Vector3.new(1.5, 12, 1.5))
	makeWood(sellPos + Vector3.new(-8, 6, 8), Vector3.new(1.5, 12, 1.5))
	makeWood(sellPos + Vector3.new(8, 6, 8), Vector3.new(1.5, 12, 1.5))

	-- Canopy Roof
	local roof = Instance.new("Part")
	roof.Anchored = true
	roof.Material = Enum.Material.Fabric
	roof.Color = Color3.fromRGB(230, 70, 60)
	roof.Size = Vector3.new(20, 1.5, 20)
	roof.Position = sellPos + Vector3.new(0, 12, 0)
	roof.Parent = stall

	local shopLight = Instance.new("PointLight")
	shopLight.Color = Color3.fromRGB(255, 230, 180)
	shopLight.Brightness = 3.5
	shopLight.Range = 28
	shopLight.Parent = roof
end

buildShopStall(Vector3.new(-22, 0.5, -20))

createFloatingSign(Vector3.new(-22, 6, -20), "💰 SELL ORES HERE\n(Walk onto pad)", Color3.fromRGB(46, 204, 113))
createFloatingSign(Vector3.new(0, 16, -45), "⛏️ MINE A (STARTER)\nClick blocks with Pickaxe!", Color3.fromRGB(241, 196, 15))

-- Sell Pad Logic with Cash Register Sound
local sellCooldowns: { [Player]: boolean } = {}
local sellPad = Workspace:WaitForChild("SellPad", 10) :: BasePart?

-- Get player's total earnings multiplier from prestige + pets
local function getEarningsMultiplier(player: Player): number
	local data = DataStoreService.GetData(player)
	local multiplier = 1.0

	-- Prestige multiplier
	local prestigeLevel = data.PrestigeLevel or 0
	if prestigeLevel > 0 then
		local prestigeDef = GameConfig.PRESTIGES[math.min(prestigeLevel + 1, #GameConfig.PRESTIGES)]
		if prestigeDef then
			multiplier = multiplier * prestigeDef.Multiplier
		end
	end

	-- Pet bonuses
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if hiddenStats then
		local petBonus = hiddenStats:FindFirstChild("PetBonuses") :: NumberValue?
		if petBonus then
			multiplier = multiplier * (1 + (petBonus.Value / 100))
		end

		-- Active buffs (Gold Rush)
		local buffsFolder = hiddenStats:FindFirstChild("ActiveBuffs")
		if buffsFolder then
			local goldRush = buffsFolder:FindFirstChild("GoldRush")
			if goldRush and goldRush.Value then
				multiplier = multiplier * 2.0
			end
		end
	end

	return multiplier
end

if sellPad then
	sellPad.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		if sellCooldowns[player] then return end
		sellCooldowns[player] = true

		local leaderstats = player:FindFirstChild("leaderstats")
		local hiddenStats = player:FindFirstChild("HiddenStats")
		if leaderstats and hiddenStats then
			local backpack = leaderstats:FindFirstChild("Backpack") :: IntValue
			local coins = leaderstats:FindFirstChild("Coins") :: IntValue
			local storedValue = hiddenStats:FindFirstChild("StoredOreValue") :: IntValue

			if backpack and coins and storedValue and backpack.Value > 0 then
				local payout = storedValue.Value
				if payout <= 0 then
					payout = backpack.Value * 2
				end

				-- Apply earnings multiplier (prestige + pets)
				local multiplier = getEarningsMultiplier(player)
				payout = math.floor(payout * multiplier)

				coins.Value += payout
				backpack.Value = 0
				storedValue.Value = 0

				playWorldSound(sellPad.Position, "rbxassetid://9069609200", 1.2) -- Cash register sound
				print(player.Name .. " sold their backpack for " .. payout .. " Coins!")
			end
		end

		task.wait(0.5)
		sellCooldowns[player] = nil
	end)
end

-- ══════════ AUTO-MINE SYSTEM ══════════
-- Passive income for players who purchase auto-mine tiers
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataStoreService.GetData(player)
			if data then
				local autoMineTier = data.AutoMineTier or 1
				if autoMineTier > 1 then
					local tier = GameConfig.AUTO_MINE[autoMineTier]
					if tier then
						local leaderstats = player:FindFirstChild("leaderstats")
						if leaderstats then
							local coins = leaderstats:FindFirstChild("Coins") :: IntValue?
							if coins then
								-- Apply prestige multiplier to auto-mine
								local multiplier = getEarningsMultiplier(player)
								local income = math.floor(tier.Rate * tier.ValueMultiplier * multiplier)
								coins.Value += income
							end
						end
					end
				end
			end
		end
	end
end)
