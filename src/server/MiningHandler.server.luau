--!strict
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return end

local Network = require(Shared:WaitForChild("Network", 10) :: ModuleScript)
local GameConfig = require(Shared:WaitForChild("GameConfig", 10) :: ModuleScript)
local DataStoreService = require(Shared:WaitForChild("DataStoreModule", 10) :: ModuleScript)

local mineEvent = Network.getRemoteEvent("MineBlockEvent")

local MAX_REACH = 24

-- Combo tracking per player
local playerCombos = {} -- [player.UserId] = { count = 0, lastHit = tick() }

-- Sound helper
local function playSound(position: Vector3, soundId: string, volume: number, pitch: number)
	local soundPart = Instance.new("Part")
	soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
	soundPart.Position = position
	soundPart.Transparency = 1
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Parent = Workspace

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.8
	sound.PlaybackSpeed = pitch or 1
	sound.PlayOnRemove = true
	sound.Parent = soundPart

	soundPart:Destroy()
end

local function spawnBreakParticles(position: Vector3, color: Color3)
	local emitterPart = Instance.new("Part")
	emitterPart.Size = Vector3.new(0.5, 0.5, 0.5)
	emitterPart.Position = position
	emitterPart.Transparency = 1
	emitterPart.Anchored = true
	emitterPart.CanCollide = false
	emitterPart.Parent = Workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 0)
	})
	emitter.Speed = NumberRange.new(12, 22)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Lifetime = NumberRange.new(0.3, 0.5)
	emitter.Rate = 0
	emitter.Parent = emitterPart

	emitter:Emit(25)
	Debris:AddItem(emitterPart, 0.8)
end

local function showFloatingNumber(position: Vector3, text: string, color: Color3)
	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.new(0, 80, 0, 40)
	bill.AlwaysOnTop = true

	local part = Instance.new("Part")
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Position = position + Vector3.new(math.random(-10, 10) / 10, 1.5, math.random(-10, 10) / 10)
	part.Parent = Workspace

	bill.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = bill

	local tween = TweenService:Create(part, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = part.Position + Vector3.new(0, 3, 0)
	})
	tween:Play()

	Debris:AddItem(part, 0.7)
end

-- Calculate combo multiplier
local function getComboMultiplier(player: Player)
	local data = DataStoreService.GetData(player)
	local combo = playerCombos[player.UserId]

	if not combo or combo.count < 5 then
		return 1.0, false
	end

	-- Apply buff multipliers
	local multiplier = 1.0
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if hiddenStats then
		local buffsFolder = hiddenStats:FindFirstChild("ActiveBuffs")
		if buffsFolder then
			local moltenCore = buffsFolder:FindFirstChild("MoltenCore")
			if moltenCore and moltenCore.Value then
				multiplier = multiplier * 1.5
			end
		end
	end

	-- Check combo tiers from GameConfig
	local comboMultipliers = GameConfig.COMBO.ComboMultipliers
	for threshold, mult in pairs(comboMultipliers) do
		if combo.count >= threshold then
			multiplier = multiplier * mult
		end
	end

	return multiplier, true
end

-- Update player combo
local function updateCombo(player: Player)
	local combo = playerCombos[player.UserId]
	if not combo then
		combo = { count = 0, lastHit = tick() }
		playerCombos[player.UserId] = combo
	end

	-- Reset if too slow
	if tick() - combo.lastHit > GameConfig.COMBO.ComboBaseTime then
		combo.count = 0
	end

	combo.count += 1
	combo.lastHit = tick()
end

-- Reset player combo (on death or disconnect)
local function resetCombo(player: Player)
	playerCombos[player.UserId] = nil
end

local function breakBlock(player: Player, block: BasePart, power: number, backpack: IntValue, maxCapacity: IntValue, storedValue: IntValue)
	if backpack.Value >= maxCapacity.Value then return end

	local currentHealth = (block:GetAttribute("Health") :: number or 1) - power
	block:SetAttribute("Health", currentHealth)

	-- Get combo multiplier
	local comboMult, hasCombo = getComboMultiplier(player)
	local displayValue = math.floor((block:GetAttribute("Value") :: number) or 1 * comboMult)

	-- Hit sound & floating number
	playSound(block.Position, "rbxassetid://9114223173", 0.7, math.random(90, 110) / 100)

	local displayText = "-" .. power
	if hasCombo then
		displayText = displayText .. " ⚡ COMBO x" .. math.floor(comboMult * 10) / 10
	end
	showFloatingNumber(block.Position, displayText, Color3.fromRGB(255, 230, 80))

	-- Quick white hit flash
	local originalColor = block.Color
	block.Color = Color3.fromRGB(255, 255, 255)
	task.delay(0.05, function()
		if block and block.Parent then
			block.Color = originalColor
		end
	end)

	if currentHealth <= 0 then
		local oreVal = (block:GetAttribute("Value") :: number) or 1
		local finalValue = math.floor(oreVal * comboMult)

		backpack.Value = math.min(backpack.Value + 1, maxCapacity.Value)
		storedValue.Value = storedValue.Value + finalValue

		-- Update combo
		updateCombo(player)

		playSound(block.Position, "rbxassetid://9119717013", 1, math.random(95, 105) / 100)
		showFloatingNumber(block.Position + Vector3.new(0, 1, 0), "+" .. finalValue .. " 💎", Color3.fromRGB(46, 204, 113))
		spawnBreakParticles(block.Position, originalColor)

		block:Destroy()
	end
end

-- Explosive Blast (Proc on high-tier pickaxes)
local function triggerExplosion(player: Player, centerPos: Vector3, blastRadius: number, backpack: IntValue, maxCapacity: IntValue, storedValue: IntValue)
	-- Spawn visual explosion
	local explosion = Instance.new("Explosion")
	explosion.Position = centerPos
	explosion.BlastRadius = 0 -- Visual only, no damage to player
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = Workspace

	playSound(centerPos, "rbxassetid://9114223173", 1.2, 0.8)

	local activeBlocks = Workspace:FindFirstChild("ActiveMineBlocks")
	if not activeBlocks then return end

	for _, block in ipairs(activeBlocks:GetChildren()) do
		if block:IsA("BasePart") and (block.Position - centerPos).Magnitude <= blastRadius then
			breakBlock(player, block, 999, backpack, maxCapacity, storedValue)
		end
	end
end

-- Get active pick power with buffs
local function getEffectivePower(player: Player, basePower: number)
	local multiplier = 1.0
	local hiddenStats = player:FindFirstChild("HiddenStats")

	if hiddenStats then
		-- Pet bonus
		local petsValue = hiddenStats:FindFirstChild("PetBonuses")
		if petsValue then
			multiplier = multiplier + (petsValue.Value / 100)
		end

		-- Active buffs
		local buffsFolder = hiddenStats:FindFirstChild("ActiveBuffs")
		if buffsFolder then
			local moltenCore = buffsFolder:FindFirstChild("MoltenCore")
			if moltenCore and moltenCore.Value then
				multiplier = multiplier * 1.5
			end
		end
	end

	return basePower * math.clamp(multiplier, 1.0, 10.0)
end

mineEvent.OnServerEvent:Connect(function(player: Player, targetBlock: any)
	if not targetBlock or not targetBlock:IsA("BasePart") or not targetBlock:GetAttribute("Health") then
		return
	end

	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local root = character.HumanoidRootPart :: BasePart

	if (root.Position - targetBlock.Position).Magnitude > MAX_REACH then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if not leaderstats or not hiddenStats then return end

	local backpack = leaderstats:FindFirstChild("Backpack") :: IntValue
	local maxCapacity = hiddenStats:FindFirstChild("MaxCapacity") :: IntValue
	local pickPower = hiddenStats:FindFirstChild("PickPower") :: IntValue
	local storedValue = hiddenStats:FindFirstChild("StoredOreValue") :: IntValue

	if not backpack or not maxCapacity or not pickPower or not storedValue then return end

	if backpack.Value >= maxCapacity.Value then
		return
	end

	local basePower = pickPower.Value
	local effectivePower = getEffectivePower(player, basePower)

	-- 12% Chance of TNT Explosion for Pickaxes with Power >= 6
	if effectivePower >= 6 and math.random(1, 100) <= 12 then
		triggerExplosion(player, targetBlock.Position, 8, backpack, maxCapacity, storedValue)
	else
		breakBlock(player, targetBlock, effectivePower, backpack, maxCapacity, storedValue)
	end
end)

-- Combo decay
task.spawn(function()
	while true do
		task.wait(GameConfig.COMBO.ComboBaseTime)
		for userId, combo in pairs(playerCombos) do
			if tick() - combo.lastHit > GameConfig.COMBO.ComboBaseTime + 2 then
				combo.count = 0
			end
		end
	end
end)

-- Clean up on player leave
game.Players.PlayerRemoving:Connect(function(player)
	resetCombo(player)
	playerCombos[player.UserId] = nil
end)