--!strict
local Players = game:GetService("Players")

-- Prison Inmate Jumpsuit Colors
local JUMPSUIT_COLOR = Color3.fromRGB(225, 95, 25) -- Classic Penitentiary Safety Orange
local SHIRT_ID = "rbxassetid://607785314" -- Classic prison jumpsuit template if available

local function dressInmate(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then return end

	-- Color avatar limbs in prison jumpsuit orange if no custom clothing
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and (part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Left Leg" or part.Name == "Right Leg" or part.Name == "LeftLowerLeg" or part.Name == "RightLowerLeg") then
			part.Color = JUMPSUIT_COLOR
		end
	end

	-- Add Prisoner Overhead Tag
	local head = character:WaitForChild("Head", 10) :: BasePart?
	if head and not head:FindFirstChild("InmateTag") then
		local bill = Instance.new("BillboardGui")
		bill.Name = "InmateTag"
		bill.Size = UDim2.new(0, 140, 0, 45)
		bill.StudsOffset = Vector3.new(0, 2.5, 0)
		bill.AlwaysOnTop = true
		bill.Parent = head

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.GothamBlack
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.TextSize = 14
		nameLabel.Text = character.Name
		nameLabel.Parent = bill

		local roleLabel = Instance.new("TextLabel")
		roleLabel.Name = "RoleLabel"
		roleLabel.Size = UDim2.new(1, 0, 0.45, 0)
		roleLabel.Position = UDim2.new(0, 0, 0.55, 0)
		roleLabel.BackgroundTransparency = 1
		roleLabel.Font = Enum.Font.GothamBold
		roleLabel.TextColor3 = Color3.fromRGB(245, 140, 30)
		roleLabel.TextStrokeTransparency = 0
		roleLabel.TextSize = 12
		roleLabel.Text = "[ INMATE ]"
		roleLabel.Parent = bill
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(dressInmate)
	if player.Character then
		dressInmate(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
	onPlayerAdded(p)
end

-- Spawn NPC Guard at the Contraband Depot
local Workspace = game:GetService("Workspace")

local function spawnGuardNPC()
	local compound = Workspace:FindFirstChild("PrisonCompound")
	if not compound then return end

	local guardModel = Instance.new("Model")
	guardModel.Name = "GuardOfficer"
	guardModel.Parent = compound

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = guardModel

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.Position = Vector3.new(-28, 5.5, -20)
	head.Color = Color3.fromRGB(245, 205, 175)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.Parent = guardModel

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = Vector3.new(-28, 4, -20)
	torso.Color = Color3.fromRGB(35, 45, 75) -- Guard navy blue
	torso.Material = Enum.Material.Fabric
	torso.Anchored = true
	torso.CanCollide = false
	torso.Parent = guardModel

	local lArm = Instance.new("Part")
	lArm.Size = Vector3.new(1, 2, 1)
	lArm.Position = Vector3.new(-29.5, 4, -20)
	lArm.Color = Color3.fromRGB(35, 45, 75)
	lArm.Anchored = true
	lArm.CanCollide = false
	lArm.Parent = guardModel

	local rArm = Instance.new("Part")
	rArm.Size = Vector3.new(1, 2, 1)
	rArm.Position = Vector3.new(-26.5, 4, -20)
	rArm.Color = Color3.fromRGB(35, 45, 75)
	rArm.Anchored = true
	rArm.CanCollide = false
	rArm.Parent = guardModel

	local lLeg = Instance.new("Part")
	lLeg.Size = Vector3.new(1, 2, 1)
	lLeg.Position = Vector3.new(-28.5, 2, -20)
	lLeg.Color = Color3.fromRGB(25, 25, 30)
	lLeg.Anchored = true
	lLeg.CanCollide = false
	lLeg.Parent = guardModel

	local rLeg = Instance.new("Part")
	rLeg.Size = Vector3.new(1, 2, 1)
	rLeg.Position = Vector3.new(-27.5, 2, -20)
	rLeg.Color = Color3.fromRGB(25, 25, 30)
	rLeg.Anchored = true
	rLeg.CanCollide = false
	rLeg.Parent = guardModel

	-- Floating 3D Overhead Name & Title
	local bill = Instance.new("BillboardGui")
	bill.Size = UDim2.new(0, 140, 0, 45)
	bill.StudsOffset = Vector3.new(0, 2.5, 0)
	bill.AlwaysOnTop = true
	bill.Parent = head

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(1, 0, 0.55, 0)
	nameL.BackgroundTransparency = 1
	nameL.Font = Enum.Font.GothamBlack
	nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameL.TextStrokeTransparency = 0
	nameL.TextSize = 14
	nameL.Text = "Officer Miller"
	nameL.Parent = bill

	local roleL = Instance.new("TextLabel")
	roleL.Size = UDim2.new(1, 0, 0.45, 0)
	roleL.Position = UDim2.new(0, 0, 0.55, 0)
	roleL.BackgroundTransparency = 1
	roleL.Font = Enum.Font.GothamBold
	roleL.TextColor3 = Color3.fromRGB(80, 150, 255)
	roleL.TextStrokeTransparency = 0
	roleL.TextSize = 11
	roleL.Text = "[ CORRECTIONS OFFICER ]"
	roleL.Parent = bill
end

spawnGuardNPC()
