-- LocalScript inside ScreenGui

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create circular crosshair dot (single Frame)
local crosshair = Instance.new("Frame")
crosshair.Name = "CrosshairDot"
crosshair.Size = UDim2.new(0, 4, 0, 4) -- small circle
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BackgroundTransparency = 1 -- start hidden
crosshair.BorderSizePixel = 0
crosshair.ZIndex = 10
crosshair.Parent = script.Parent

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0) -- full circle
corner.Parent = crosshair

-- Update visibility by transparency based on mouse lock
local function updateCrosshair()
	local locked = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter)
	crosshair.BackgroundTransparency = locked and 0 or 1
end

-- Initial state + reactive updates
updateCrosshair()
RunService.RenderStepped:Connect(updateCrosshair)
UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(updateCrosshair)
