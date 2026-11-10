--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return end

local Network = require(Shared:WaitForChild("Network", 10) :: ModuleScript)
local GameConfig = require(Shared:WaitForChild("GameConfig", 10) :: ModuleScript)

local buyPickaxe = Network.getRemoteFunction("BuyPickaxe")
local buyBackpack = Network.getRemoteFunction("BuyBackpack")
local rankUpEvent = Network.getRemoteFunction("RankUpEvent")
local teleportMine = Network.getRemoteFunction("TeleportToMine")
local countdownEvent = Network.getRemoteEvent("MineResetCountdown")
local buyPet = Network.getRemoteFunction("BuyPet")
local buyAutoMine = Network.getRemoteFunction("BuyAutoMine")
local activateBuff = Network.getRemoteFunction("ActivateBuff")
local claimQuest = Network.getRemoteFunction("ClaimQuest")
local prestigeEvent = Network.getRemoteFunction("PrestigeEvent")

-- ── Theme ──
local THEME = {
	BG = Color3.fromRGB(20, 22, 28),
	PANEL = Color3.fromRGB(25, 27, 34),
	PANEL_LIGHT = Color3.fromRGB(32, 35, 44),
	ACCENT = Color3.fromRGB(46, 204, 113),
	GOLD = Color3.fromRGB(255, 215, 0),
	BLUE = Color3.fromRGB(52, 152, 219),
	PURPLE = Color3.fromRGB(155, 89, 182),
	RED = Color3.fromRGB(231, 76, 60),
	ORANGE = Color3.fromRGB(243, 156, 18),
	TEXT = Color3.fromRGB(255, 255, 255),
	TEXT_DIM = Color3.fromRGB(180, 180, 190),
}

local function makeCorner(parent: GuiObject, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function makeButton(props: { text: string, color: Color3, size: UDim2, fontSize: number }): TextButton
	local btn = Instance.new("TextButton")
	btn.Size = props.size
	btn.BackgroundColor3 = props.color
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = props.fontSize
	btn.TextColor3 = THEME.TEXT
	btn.Text = props.text
	makeCorner(btn, 8)
	return btn
end

-- ── Main HUD ScreenGui ──
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EvaHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ══════════ TOP BAR: Coins / Rank / Prestige / Timer ══════════
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(0, 420, 0, 48)
topBar.Position = UDim2.new(0, 12, 0, 8)
topBar.BackgroundColor3 = THEME.PANEL
topBar.BorderSizePixel = 0
topBar.Parent = screenGui
makeCorner(topBar, 10)

local coinsIcon = Instance.new("TextLabel")
coinsIcon.Size = UDim2.new(0, 30, 0, 30)
coinsIcon.Position = UDim2.new(0, 8, 0.5, -15)
coinsIcon.BackgroundTransparency = 1
coinsIcon.Font = Enum.Font.GothamBold
coinsIcon.TextSize = 22
coinsIcon.TextColor3 = THEME.GOLD
coinsIcon.Text = "🪙"
coinsIcon.Parent = topBar

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(0, 150, 0, 34)
coinsLabel.Position = UDim2.new(0, 40, 0.5, -17)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Font = Enum.Font.GothamBlack
coinsLabel.TextSize = 20
coinsLabel.TextColor3 = THEME.GOLD
coinsLabel.Text = "0"
coinsLabel.Parent = topBar

local rankChip = Instance.new("TextLabel")
rankChip.Size = UDim2.new(0, 70, 0, 34)
rankChip.Position = UDim2.new(0, 195, 0.5, -17)
rankChip.BackgroundColor3 = THEME.BLUE
rankChip.Font = Enum.Font.GothamBold
rankChip.TextSize = 16
rankChip.TextColor3 = THEME.TEXT
rankChip.Text = "RANK A"
rankChip.Parent = topBar
makeCorner(rankChip, 8)

local prestigeChip = Instance.new("TextLabel")
prestigeChip.Size = UDim2.new(0, 90, 0, 34)
prestigeChip.Position = UDim2.new(0, 272, 0.5, -17)
prestigeChip.BackgroundColor3 = THEME.PURPLE
prestigeChip.Font = Enum.Font.GothamBold
prestigeChip.TextSize = 14
prestigeChip.TextColor3 = THEME.TEXT
prestigeChip.Text = "🔮 x1.0"
prestigeChip.Parent = topBar
makeCorner(prestigeChip, 8)

-- Reset timer (top center)
local timerFrame = Instance.new("Frame")
timerFrame.Name = "TimerFrame"
timerFrame.Size = UDim2.new(0, 200, 0, 34)
timerFrame.Position = UDim2.new(0.5, -100, 0, 8)
timerFrame.BackgroundColor3 = THEME.PANEL
timerFrame.BorderSizePixel = 0
timerFrame.Parent = screenGui
makeCorner(timerFrame, 8)

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 1, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextColor3 = THEME.GOLD
timerLabel.TextSize = 14
timerLabel.Text = "⏳ Reset in: 01:30"
timerLabel.Parent = timerFrame

countdownEvent.OnClientEvent:Connect(function(secondsLeft: number)
	local mins = math.floor(secondsLeft / 60)
	local secs = secondsLeft % 60
	timerLabel.Text = string.format("⏳ Reset in: %02d:%02d", mins, secs)
end)

-- ══════════ COMBO METER (center-top) ══════════
local comboFrame = Instance.new("Frame")
comboFrame.Size = UDim2.new(0, 240, 0, 56)
comboFrame.Position = UDim2.new(0.5, -120, 0, 52)
comboFrame.BackgroundColor3 = THEME.PANEL
comboFrame.BorderSizePixel = 0
comboFrame.Visible = false
comboFrame.Parent = screenGui
makeCorner(comboFrame, 10)

local comboLabel = Instance.new("TextLabel")
comboLabel.Size = UDim2.new(1, 0, 0, 30)
comboLabel.Position = UDim2.new(0, 0, 0, 4)
comboLabel.BackgroundTransparency = 1
comboLabel.Font = Enum.Font.GothamBlack
comboLabel.TextSize = 20
comboLabel.TextColor3 = THEME.ORANGE
comboLabel.Text = "COMBO x1.0"
comboLabel.Parent = comboFrame

local comboBar = Instance.new("Frame")
comboBar.Size = UDim2.new(0, 0, 0, 5)
comboBar.Position = UDim2.new(0.04, 0, 1, -10)
comboBar.BackgroundColor3 = THEME.ORANGE
comboBar.BorderSizePixel = 0
comboBar.Parent = comboFrame
makeCorner(comboBar, 3)

local comboBarBg = Instance.new("Frame")
comboBarBg.Size = UDim2.new(0.92, 0, 0, 5)
comboBarBg.Position = UDim2.new(0.04, 0, 1, -10)
comboBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
comboBarBg.BorderSizePixel = 0
comboBarBg.Parent = comboFrame
makeCorner(comboBarBg, 3)
comboBar.ZIndex = 2

-- ══════════ BUFF ACTIVATION BUTTON (quick) ══════════
local buffBtn = makeButton({ text = "🔥 Molten Core", color = Color3.fromRGB(211, 84, 0), size = UDim2.new(0, 130, 0, 34), fontSize = 12 })
buffBtn.Position = UDim2.new(0, 16, 0.5, 170)
buffBtn.Parent = screenGui
buffBtn.MouseButton1Click:Connect(function()
	local ok, msg = activateBuff:InvokeServer("MoltenCore")
	showToast(msg or "", ok)
end)

-- ══════════ BACKPACK BAR (bottom center) ══════════
local backpackBg = Instance.new("Frame")
backpackBg.Name = "BackpackBar"
backpackBg.Size = UDim2.new(0, 360, 0, 38)
backpackBg.Position = UDim2.new(0.5, -180, 1, -70)
backpackBg.BackgroundColor3 = THEME.PANEL
backpackBg.BorderSizePixel = 0
backpackBg.Parent = screenGui
makeCorner(backpackBg, 8)

local fillBar = Instance.new("Frame")
fillBar.Name = "Fill"
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BackgroundColor3 = THEME.ACCENT
fillBar.BorderSizePixel = 0
fillBar.Parent = backpackBg
makeCorner(fillBar, 8)

local capacityLabel = Instance.new("TextLabel")
capacityLabel.Name = "Label"
capacityLabel.Size = UDim2.new(1, 0, 1, 0)
capacityLabel.BackgroundTransparency = 1
capacityLabel.Font = Enum.Font.GothamBold
capacityLabel.TextColor3 = THEME.TEXT
capacityLabel.TextSize = 15
capacityLabel.Text = "Backpack: 0 / 35"
capacityLabel.Parent = backpackBg

-- ══════════ LEFT MENU BUTTONS ══════════
local menuBtns = Instance.new("Frame")
menuBtns.Size = UDim2.new(0, 130, 0, 300)
menuBtns.Position = UDim2.new(0, 16, 0.5, -150)
menuBtns.BackgroundTransparency = 1
menuBtns.Parent = screenGui

local function createMenuBtn(text: string, color: Color3, yPos: number)
	local btn = makeButton({ text = text, color = color, size = UDim2.new(1, 0, 0, 44), fontSize = 14 })
	btn.Position = UDim2.new(0, 0, 0, yPos)
	btn.Parent = menuBtns
	return btn
end

local shopBtn = createMenuBtn("🛒 UPGRADES", THEME.ORANGE, 0)
local teleportsBtn = createMenuBtn("⛏️ MINES", THEME.BLUE, 52)
local petsBtn = createMenuBtn("🐾 PETS", Color3.fromRGB(46, 160, 120), 104)
local prestigeBtn = createMenuBtn("🔮 PRESTIGE", THEME.PURPLE, 156)
local questBtn = createMenuBtn("📜 QUESTS", Color3.fromRGB(41, 128, 185), 208)

-- ══════════ QUEST PANEL (right side) ══════════
local questPanel = Instance.new("Frame")
questPanel.Size = UDim2.new(0, 260, 0, 150)
questPanel.Position = UDim2.new(1, -276, 0, 8)
questPanel.BackgroundColor3 = THEME.PANEL
questPanel.BorderSizePixel = 0
questPanel.Visible = false
questPanel.Parent = screenGui
makeCorner(questPanel, 10)

local questTitle = Instance.new("TextLabel")
questTitle.Size = UDim2.new(1, 0, 0, 34)
questTitle.BackgroundTransparency = 1
questTitle.Font = Enum.Font.GothamBlack
questTitle.TextSize = 16
questTitle.TextColor3 = THEME.BLUE
questTitle.Text = "📜 QUESTS"
questTitle.Parent = questPanel

local questList = Instance.new("ScrollingFrame")
questList.Size = UDim2.new(0.92, 0, 0.78, 0)
questList.Position = UDim2.new(0.04, 0, 0.12, 0)
questList.BackgroundTransparency = 1
questList.BorderSizePixel = 0
questList.ScrollBarThickness = 4
questList.Parent = questPanel

local questLayout = Instance.new("UIListLayout")
questLayout.Padding = UDim.new(0, 6)
questLayout.Parent = questList

for _, q in ipairs(GameConfig.QUESTS) do
	local qLabel = Instance.new("TextLabel")
	qLabel.Size = UDim2.new(1, 0, 0, 34)
	qLabel.BackgroundColor3 = THEME.PANEL_LIGHT
	qLabel.Font = Enum.Font.Gotham
	qLabel.TextSize = 12
	qLabel.TextColor3 = THEME.TEXT
	qLabel.Text = "📌 " .. q.Name .. " (+" .. q.Reward .. " Coins)"
	qLabel.Parent = questList
	makeCorner(qLabel, 6)
end

-- ══════════ TOAST ══════════
local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.Size = UDim2.new(0, 380, 0, 40)
toastLabel.Position = UDim2.new(0.5, -190, 0, 20)
toastLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toastLabel.TextColor3 = THEME.TEXT
toastLabel.Font = Enum.Font.GothamBold
toastLabel.TextSize = 15
toastLabel.Visible = false
toastLabel.Parent = screenGui
makeCorner(toastLabel, 8)

local function showToast(msg: string, isSuccess: boolean)
	toastLabel.Text = msg
	toastLabel.TextColor3 = isSuccess and THEME.ACCENT or THEME.RED
	toastLabel.Visible = true
	task.delay(3, function()
		if toastLabel.Text == msg then
			toastLabel.Visible = false
		end
	end)
end

-- ══════════ MODALS ══════════
local modalRoot = Instance.new("Frame")
modalRoot.Size = UDim2.new(1, 0, 1, 0)
modalRoot.BackgroundTransparency = 1
modalRoot.Parent = screenGui

local function makeModal(width: number, height: number): Frame
	local modal = Instance.new("Frame")
	modal.Size = UDim2.new(0, width, 0, height)
	modal.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	modal.BackgroundColor3 = THEME.BG
	modal.BorderSizePixel = 0
	modal.Visible = false
	modal.Parent = modalRoot
	makeCorner(modal, 12)

	local x = makeButton({ text = "X", color = THEME.RED, size = UDim2.new(0, 32, 0, 32), fontSize = 14 })
	x.Position = UDim2.new(1, -40, 0, 8)
	x.Parent = modal
	x.MouseButton1Click:Connect(function() modal.Visible = false end)

	return modal
end

-- ── SHOP MODAL ──
local shopModal = makeModal(420, 480)
local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 42)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBlack
shopTitle.TextSize = 17
shopTitle.TextColor3 = THEME.GOLD
shopTitle.Text = "UPGRADES & RANKS"
shopTitle.Parent = shopModal

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(0.92, 0, 0.84, 0)
shopScroll.Position = UDim2.new(0.04, 0, 0.13, 0)
shopScroll.BackgroundTransparency = 1
shopScroll.BorderSizePixel = 0
shopScroll.ScrollBarThickness = 6
shopScroll.CanvasSize = UDim2.new(0, 0, 0, 640)
shopScroll.Parent = shopModal

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 6)
shopLayout.Parent = shopScroll

local function addShopButton(text: string, color: Color3, onClick: () -> ())
	local btn = makeButton({ text = text, color = color, size = UDim2.new(1, 0, 0, 40), fontSize = 14 })
	btn.Parent = shopScroll
	btn.MouseButton1Click:Connect(onClick)
end

addShopButton("⭐ RANK UP TO NEXT RANK", THEME.PURPLE, function()
	local ok, msg = rankUpEvent:InvokeServer()
	showToast(msg or "", ok)
end)

for i, pick in ipairs(GameConfig.PICKAXES) do
	if i > 1 then
		addShopButton("⛏️ " .. pick.Name .. " (Pwr: " .. pick.Power .. ") — " .. pick.Cost .. " Coins", Color3.fromRGB(41, 128, 185), function()
			local ok, msg = buyPickaxe:InvokeServer(i)
			showToast(msg or "", ok)
		end)
	end
end

for i, bag in ipairs(GameConfig.BACKPACKS) do
	if i > 1 then
		addShopButton("🎒 Backpack (" .. bag.Capacity .. " Slots) — " .. bag.Cost .. " Coins", Color3.fromRGB(39, 174, 96), function()
			local ok, msg = buyBackpack:InvokeServer(i)
			showToast(msg or "", ok)
		end)
	end
end

addShopButton("⚙️ Toggle AUTO-SELL (1500 Coins)", Color3.fromRGB(192, 57, 43), function()
	local ok, msg = toggleAutoSell:InvokeServer()
	showToast(msg or "", ok)
end)

for i, am in ipairs(GameConfig.AUTO_MINE) do
	if i > 1 then
		addShopButton("🤖 Auto-Mine Lv" .. i .. " (+" .. am.Rate .. "/s) — " .. am.Cost .. " Coins", Color3.fromRGB(142, 68, 173), function()
			local ok, msg = buyAutoMine:InvokeServer(i)
			showToast(msg or "", ok)
		end)
	end
end

shopBtn.MouseButton1Click:Connect(function() shopModal.Visible = not shopModal.Visible end)

-- ── TELEPORTS MODAL ──
local teleModal = makeModal(340, 280)
local teleTitle = Instance.new("TextLabel")
teleTitle.Size = UDim2.new(1, 0, 0, 42)
teleTitle.BackgroundTransparency = 1
teleTitle.Font = Enum.Font.GothamBlack
teleTitle.TextSize = 17
teleTitle.TextColor3 = THEME.BLUE
teleTitle.Text = "MINE TELEPORTS"
teleTitle.Parent = teleModal

local function addTeleportButton(rankKey: string, name: string, yPos: number)
	local btn = makeButton({ text = "Teleport to " .. name, color = Color3.fromRGB(44, 62, 80), size = UDim2.new(0.9, 0, 0, 42), fontSize = 14 })
	btn.Position = UDim2.new(0.05, 0, 0, yPos)
	btn.Parent = teleModal
	btn.MouseButton1Click:Connect(function()
		local ok, msg = teleportMine:InvokeServer(rankKey)
		showToast(msg or "", ok)
		if ok then teleModal.Visible = false end
	end)
end

addTeleportButton("A", "Mine A (Starter)", 54)
addTeleportButton("B", "Mine B (Rank B)", 106)
addTeleportButton("C", "Mine C (Rank C)", 158)

teleportsBtn.MouseButton1Click:Connect(function() teleModal.Visible = not teleModal.Visible end)

-- ── PETS MODAL ──
local petModal = makeModal(440, 500)
local petTitle = Instance.new("TextLabel")
petTitle.Size = UDim2.new(1, 0, 0, 42)
petTitle.BackgroundTransparency = 1
petTitle.Font = Enum.Font.GothamBlack
petTitle.TextSize = 17
petTitle.TextColor3 = Color3.fromRGB(46, 160, 120)
petTitle.Text = "🐾 PETS (Earnings & Power Bonus)"
petTitle.Parent = petModal

local petScroll = Instance.new("ScrollingFrame")
petScroll.Size = UDim2.new(0.92, 0, 0.84, 0)
petScroll.Position = UDim2.new(0.04, 0, 0.13, 0)
petScroll.BackgroundTransparency = 1
petScroll.BorderSizePixel = 0
petScroll.ScrollBarThickness = 6
petScroll.CanvasSize = UDim2.new(0, 0, 0, 560)
petScroll.Parent = petModal

local petLayout = Instance.new("UIListLayout")
petLayout.Padding = UDim.new(0, 6)
petLayout.Parent = petScroll

local RARITY_COLORS = {
	Common = Color3.fromRGB(150, 150, 150),
	Rare = Color3.fromRGB(52, 152, 219),
	Epic = Color3.fromRGB(155, 89, 182),
	Legendary = Color3.fromRGB(241, 196, 15),
	Mythic = Color3.fromRGB(231, 76, 60),
	Celestial = Color3.fromRGB(255, 215, 0),
}

for id, pet in pairs(GameConfig.PETS) do
	local color = RARITY_COLORS[pet.Rarity] or Color3.fromRGB(150, 150, 150)
	local btn = makeButton({
		text = pet.Symbol .. " " .. pet.Name .. " [" .. pet.Rarity .. "] +" .. pet.EarningsBonus .. "% Earn +" .. pet.PowerBonus .. "% Pwr — " .. pet.Cost .. " Coins",
		color = color,
		size = UDim2.new(1, 0, 0, 42),
		fontSize = 13,
	})
	btn.Parent = petScroll
	btn.MouseButton1Click:Connect(function()
		local ok, msg = buyPet:InvokeServer(id)
		showToast(msg or "", ok)
	end)
end

petsBtn.MouseButton1Click:Connect(function() petModal.Visible = not petModal.Visible end)

-- ── PRESTIGE MODAL ──
local prestigeModal = makeModal(400, 360)
local prestTitle = Instance.new("TextLabel")
prestTitle.Size = UDim2.new(1, 0, 0, 42)
prestTitle.BackgroundTransparency = 1
prestTitle.Font = Enum.Font.GothamBlack
prestTitle.TextSize = 17
prestTitle.TextColor3 = THEME.PURPLE
prestTitle.Text = "🔮 PRESTIGE & EVA"
prestTitle.Parent = prestigeModal

local prestDesc = Instance.new("TextLabel")
prestDesc.Size = UDim2.new(0.9, 0, 0, 120)
prestDesc.Position = UDim2.new(0.05, 0, 0.12, 0)
prestDesc.BackgroundTransparency = 1
prestDesc.Font = Enum.Font.Gotham
prestDesc.TextSize = 14
prestDesc.TextColor3 = THEME.TEXT_DIM
prestDesc.TextWrapped = true
prestDesc.Text = "Prestige resets your rank, pickaxe & backpack, but grants a PERMANENT earnings multiplier.\n\nEach prestige makes Eva more powerful. Reach the next prestige to awaken her further!\n\nEva is your companion — she grows stronger with every prestige and boosts all your earnings."
prestDesc.Parent = prestigeModal

local prestBtn = makeButton({ text = "🔮 PRESTIGE (x1.5 → next)", color = THEME.PURPLE, size = UDim2.new(0.9, 0, 0, 48), fontSize = 16 })
prestBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
prestBtn.Parent = prestigeModal
prestBtn.MouseButton1Click:Connect(function()
	local ok, msg = prestigeEvent:InvokeServer()
	showToast(msg or "", ok)
end)

prestigeBtn.MouseButton1Click:Connect(function() prestigeModal.Visible = not prestigeModal.Visible end)

questBtn.MouseButton1Click:Connect(function()
	questPanel.Visible = not questPanel.Visible
end)

-- ══════════ EVA COMPANION (bottom-right) ══════════
local evaFrame = Instance.new("Frame")
evaFrame.Size = UDim2.new(0, 200, 0, 70)
evaFrame.Position = UDim2.new(1, -212, 1, -140)
evaFrame.BackgroundColor3 = THEME.PANEL
evaFrame.BorderSizePixel = 0
evaFrame.Parent = screenGui
makeCorner(evaFrame, 12)

local evaFace = Instance.new("TextLabel")
evaFace.Size = UDim2.new(0, 44, 0, 44)
evaFace.Position = UDim2.new(0, 10, 0.5, -22)
evaFace.BackgroundTransparency = 1
evaFace.Font = Enum.Font.GothamBlack
evaFace.TextSize = 32
evaFace.TextColor3 = THEME.PURPLE
evaFace.Text = "👾"
evaFace.Parent = evaFrame

local evaName = Instance.new("TextLabel")
evaName.Size = UDim2.new(0, 130, 0, 18)
evaName.Position = UDim2.new(0, 60, 0, 8)
evaName.BackgroundTransparency = 1
evaName.Font = Enum.Font.GothamBold
evaName.TextSize = 13
evaName.TextColor3 = THEME.PURPLE
evaName.Text = "EVA"
evaName.Parent = evaFrame

local evaLine = Instance.new("TextLabel")
evaLine.Size = UDim2.new(0, 130, 0, 30)
evaLine.Position = UDim2.new(0, 60, 0, 26)
evaLine.BackgroundTransparency = 1
evaLine.Font = Enum.Font.Gotham
evaLine.TextSize = 10
evaLine.TextColor3 = THEME.TEXT_DIM
evaLine.TextWrapped = true
evaLine.Text = "Keep mining, human!"
evaLine.Parent = evaFrame

local evaLines = {
	"Keep mining, human!",
	"Combo it up! ⚡",
	"Sell on the green pad!",
	"Buy a pet for passive income!",
	"Auto-mine pays while you AFK!",
	"Prestige for big multipliers!",
}
local currentLine = 1
task.spawn(function()
	while true do
		task.wait(6)
		currentLine = (currentLine % #evaLines) + 1
		TweenService:Create(evaLine, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		task.wait(0.4)
		evaLine.Text = evaLines[currentLine]
		TweenService:Create(evaLine, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
	end
end)

-- ══════════ DATA BINDING ══════════
local function bindStats()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	local hiddenStats = player:WaitForChild("HiddenStats", 10)
	if not leaderstats or not hiddenStats then return end

	local backpack = leaderstats:WaitForChild("Backpack", 10) :: IntValue
	local coins = leaderstats:WaitForChild("Coins", 10) :: IntValue
	local rank = leaderstats:WaitForChild("Rank", 10) :: StringValue
	local maxCapacity = hiddenStats:WaitForChild("MaxCapacity", 10) :: IntValue
	local petBonuses = hiddenStats:WaitForChild("PetBonuses", 10) :: NumberValue
	if not backpack or not coins or not rank or not maxCapacity or not petBonuses then return end

	local function formatNum(n: number): string
		if n >= 1e9 then return string.format("%.1fB", n / 1e9)
		elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
		elseif n >= 1e4 then return string.format("%.1fK", n / 1e3)
		else return tostring(math.floor(n)) end
	end

	local function update()
		local cur = backpack.Value
		local max = maxCapacity.Value
		local ratio = math.clamp(cur / max, 0, 1)

		TweenService:Create(fillBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(ratio, 0, 1, 0)
		}):Play()

		if cur >= max then
			capacityLabel.Text = "⚠️ FULL (" .. cur .. "/" .. max .. ") — Sell!"
			fillBar.BackgroundColor3 = THEME.RED
		else
			capacityLabel.Text = "Backpack: " .. cur .. " / " .. max
			fillBar.BackgroundColor3 = THEME.ACCENT
		end

		coinsLabel.Text = formatNum(coins.Value)
		rankChip.Text = "RANK " .. rank.Value
		rankChip.BackgroundColor3 = rank.Value == "A" and THEME.BLUE or rank.Value == "B" and THEME.ACCENT or rank.Value == "C" and THEME.PURPLE or rank.Value == "D" and THEME.ORANGE or THEME.RED
	end

	backpack.Changed:Connect(update)
	coins.Changed:Connect(update)
	rank.Changed:Connect(update)
	maxCapacity.Changed:Connect(update)
	update()
end

task.spawn(bindStats)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.B then
		shopModal.Visible = not shopModal.Visible
	elseif input.KeyCode == Enum.KeyCode.M then
		teleModal.Visible = not teleModal.Visible
	elseif input.KeyCode == Enum.KeyCode.P then
		petModal.Visible = not petModal.Visible
	elseif input.KeyCode == Enum.KeyCode.Q then
		questPanel.Visible = not questPanel.Visible
	elseif input.KeyCode == Enum.KeyCode.G then
		prestigeModal.Visible = not prestigeModal.Visible
	end
end)