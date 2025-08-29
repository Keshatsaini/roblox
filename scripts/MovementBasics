local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local SPRINT_KEY = Enum.KeyCode.LeftShift
local WALK_SPEED = 20
local SPRINT_SPEED = 42
local MAX_STAMINA = 100
local staminaDrainRate = 10
local staminaRegenRate = 20
local regenDelay = 0.25

local shiftHeld = false
local isSprinting = false
local stamina = MAX_STAMINA
local lastSprintTime = 0

local staminaGui
local staminaBar
local healthBar

-- Create GUI (call each respawn)
local function createGui()
	if staminaGui then
		staminaGui:Destroy()
	end

	staminaGui = Instance.new("ScreenGui")
	staminaGui.Name = "PlayerGui"
	staminaGui.Parent = player:WaitForChild("PlayerGui")

	-- === Stamina Bar ===
	local staminaBack = Instance.new("Frame")
	staminaBack.Size = UDim2.new(0.3,0,0.01,0)
	staminaBack.Position = UDim2.new(0.35,0,0.92,0)
	staminaBack.BackgroundColor3 = Color3.fromRGB(48,48,48)
	staminaBack.BorderSizePixel = 0
	staminaBack.Parent = staminaGui

	staminaBar = Instance.new("Frame")
	staminaBar.Size = UDim2.new(1,0,1,0)
	staminaBar.BackgroundColor3 = Color3.fromRGB(243,255,244)
	staminaBar.BorderSizePixel = 0
	staminaBar.Parent = staminaBack

	-- === Health Bar ===
	local healthBack = Instance.new("Frame")
	healthBack.Size = UDim2.new(0.3,0,0.01,0)
	healthBack.Position = UDim2.new(0.35,0,0.88,0) -- slightly above stamina bar
	healthBack.BackgroundColor3 = Color3.fromRGB(48,48,48)
	healthBack.BorderSizePixel = 0
	healthBack.Parent = staminaGui

	healthBar = Instance.new("Frame")
	healthBar.Size = UDim2.new(1,0,1,0)
	healthBar.BackgroundColor3 = Color3.fromRGB(0,200,0)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBack
end

-- Sprint input
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == SPRINT_KEY then
		shiftHeld = true
		if stamina > 0 then isSprinting = true end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == SPRINT_KEY then
		shiftHeld = false
		isSprinting = false
		lastSprintTime = tick()
	end
end)

-- Setup character on spawn
local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	-- Recreate GUI
	createGui()

	-- Health change listener
	humanoid.HealthChanged:Connect(function(newHealth)
		if healthBar then
			local maxHealth = humanoid.MaxHealth
			healthBar.Size = UDim2.new(newHealth / maxHealth,0,1,0)
			if newHealth < maxHealth * 0.3 then
				healthBar.BackgroundColor3 = Color3.fromRGB(200,0,0) -- red when low
			else
				healthBar.BackgroundColor3 = Color3.fromRGB(0,200,0) -- green normal
			end
		end
	end)

	-- Double jump attributes
	if humanoid:GetAttribute("Jump1") == nil then humanoid:SetAttribute("Jump1", false) end
	if humanoid:GetAttribute("Jump2") == nil then humanoid:SetAttribute("Jump2", false) end
	if humanoid:GetAttribute("CanJump") == nil then humanoid:SetAttribute("CanJump", true) end

	local debounce = false

	-- Jump request
	UserInputService.JumpRequest:Connect(function()
		if not humanoid:GetAttribute("CanJump") then return end

		if humanoid:GetAttribute("Jump1") then
			humanoid.Jump = true
			humanoid:SetAttribute("Jump1", false)
			debounce = true
			task.delay(0.2, function() debounce = false end)
		elseif humanoid:GetAttribute("Jump2") and not debounce then
			local vel = rootPart.AssemblyLinearVelocity
			rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, humanoid.JumpPower, vel.Z)
			humanoid:SetAttribute("Jump2", false)
		end
	end)

	humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed then
			humanoid:SetAttribute("Jump1", true)
			humanoid:SetAttribute("Jump2", true)
		elseif new == Enum.HumanoidStateType.Freefall then
			humanoid:SetAttribute("Jump1", false)
		end
	end)

	humanoid.WalkSpeed = WALK_SPEED
end

-- Update loop
RunService.RenderStepped:Connect(function(dt)
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Sprinting
	if isSprinting and stamina > 0 and humanoid.MoveDirection.Magnitude > 0 then
		humanoid.WalkSpeed = SPRINT_SPEED
		stamina = math.max(0, stamina - staminaDrainRate * dt)
		if stamina <= 0 then
			isSprinting = false
			humanoid.WalkSpeed = WALK_SPEED
			lastSprintTime = tick()
		end
	else
		humanoid.WalkSpeed = WALK_SPEED
		if tick() - lastSprintTime > regenDelay then
			stamina = math.min(MAX_STAMINA, stamina + staminaRegenRate * dt)
		end
	end

	-- GUI update stamina
	if staminaBar then
		staminaBar.Size = UDim2.new(stamina / MAX_STAMINA,0,1,0)
		staminaBar.BackgroundColor3 = (stamina < 30) and Color3.fromRGB(200,0,0) or Color3.fromRGB(255,255,255)
	end
end)

-- Initial setup
if player.Character then
	setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)
