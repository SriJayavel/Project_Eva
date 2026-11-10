--!strict
local Tool = script.Parent :: Tool
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotesFolder then
	warn("Remotes folder not found in ReplicatedStorage")
	return
end

local mineEvent = remotesFolder:WaitForChild("MineBlockEvent", 10) :: RemoteEvent
if not mineEvent then
	warn("MineBlockEvent not found in Remotes")
	return
end

local mining = false
local HIT_COOLDOWN = 0.2

-- Play arm swing animation using standard Roblox Tool swing
local function swingArm()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- Standard swing track if available
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			-- Built-in slash / swing animation
			local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://522635533" -- Classic tool swing animation
			local track = animator:LoadAnimation(anim)
			track:Play()
		end
	end
end

-- Check for active buffs to adjust swing speed
local function getSwingSpeed()
	local hiddenStats = player:FindFirstChild("HiddenStats")
	if not hiddenStats then return 1 end

	local buffsFolder = hiddenStats:FindFirstChild("ActiveBuffs")
	if buffsFolder then
		-- Adrenaline buff speeds up swings
		if buffsFolder:FindFirstChild("Adrenaline") and buffsFolder.Adrenaline.Value then
			return 0.6
		end
		-- Molten Core buff
		if buffsFolder:FindFirstChild("MoltenCore") and buffsFolder.MoltenCore.Value then
			return 0.8
		end
	end
	return 1
end

Tool.Activated:Connect(function()
	if mining then return end

	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local root = character.HumanoidRootPart :: BasePart

	-- Prevent self-clicking
	mouse.TargetFilter = character

	local target = mouse.Target
	if target and target:IsA("BasePart") and target.Parent and target.Parent.Name == "ActiveMineBlocks" then
		local dist = (root.Position - target.Position).Magnitude
		if dist <= 22 then
			mining = true
			swingArm()
			mineEvent:FireServer(target)
			task.wait(HIT_COOLDOWN * getSwingSpeed())
			mining = false
		end
	end
end)