-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Sprinting
local SPRINT_KEY = Enum.KeyCode.LeftShift
local WALK_SPEED = 16
local SPRINT_SPEED = 38

-- Stamina System
local MAX_STAMINA = 100
local stamina = MAX_STAMINA
local shiftHeld = false
local isSprinting = false
local staminaDrainRate = 10 -- per second
local staminaRegenRate = 20 -- per second
local regenDelay = 0.25 -- seconds after stop sprinting

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local staminaBarBack = Instance.new("Frame")
staminaBarBack.Size = UDim2.new(0.3, 0, 0.005, 0)
staminaBarBack.Position = UDim2.new(0.35, 0, 0.9, 0)
staminaBarBack.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
staminaBarBack.BorderSizePixel = 0
staminaBarBack.Parent = screenGui

local staminaBar = Instance.new("Frame")
staminaBar.Size = UDim2.new(1, 0, 1, 0)
staminaBar.BackgroundColor3 = Color3.fromRGB(243, 255, 244)
staminaBar.BorderSizePixel = 0
staminaBar.Parent = staminaBarBack

-- Regen Timer
local lastSprintTime = 0

-- Handle input
UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == SPRINT_KEY and not processed then
		shiftHeld = true
		-- only allow sprint if stamina > 0
		if stamina > 0 then
			isSprinting = true
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == SPRINT_KEY then
		shiftHeld = false
		isSprinting = false
		lastSprintTime = tick()
	end
end)

-- Update Loop
RunService.RenderStepped:Connect(function(dt)
	if isSprinting and stamina > 0 and humanoid.MoveDirection.Magnitude > 0 then
		-- Sprint
		humanoid.WalkSpeed = SPRINT_SPEED
		stamina = math.max(0, stamina - staminaDrainRate * dt)

		-- Force stop if stamina runs out
		if stamina <= 0 then
			isSprinting = false
			humanoid.WalkSpeed = WALK_SPEED
			lastSprintTime = tick()
		end
	else
		-- Walk speed reset
		humanoid.WalkSpeed = WALK_SPEED

		-- Regen only after delay
		if tick() - lastSprintTime > regenDelay then
			stamina = math.min(MAX_STAMINA, stamina + staminaRegenRate * dt)
		end

		-- If shift is still held, don’t auto-resume until key is released & pressed again
		if shiftHeld and stamina > 0 and humanoid.MoveDirection.Magnitude > 0 then
			-- do nothing, wait until re-press
		end
	end

	-- Update stamina bar
	staminaBar.Size = UDim2.new(stamina / MAX_STAMINA, 0, 1, 0)

	-- Change color based on stamina
	if stamina < 30 then
		staminaBar.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	else
		staminaBar.BackgroundColor3 = Color3.fromRGB(255, 254, 254)
	end
end)
