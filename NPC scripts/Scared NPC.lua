
--NPC will run away after catching the player in its line of sight

-- NPC "Run Away" AI with Line of Sight & Random Patrol
-- Put inside NPC model (ServerScript)
-- NPC must have Humanoid + HumanoidRootPart
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local rootPart = npc:WaitForChild("HumanoidRootPart")

-- SETTINGS
local DETECTION_RANGE = 80     -- how far NPC can see players
local REFRESH_TIME = 1         -- seconds between checks
local FLEE_TIME = 5            -- how long NPC runs away
local WALK_SPEED = 10          -- normal speed
local RUN_SPEED = 20           -- flee speed
local PATROL_RADIUS = 50       -- how far NPC patrols randomly

-- Function: Line of sight check
local function hasLineOfSight(target)
	local origin = rootPart.Position
	local direction = (target.Position - origin)

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {npc}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = Workspace:Raycast(origin, direction, rayParams)
	if result then
		return result.Instance:IsDescendantOf(target.Parent)
	end
	return true
end

-- Function: Find visible player
local function getVisiblePlayer()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local playerRoot = player.Character.HumanoidRootPart
			local distance = (playerRoot.Position - rootPart.Position).Magnitude
			if distance <= DETECTION_RANGE then
				if hasLineOfSight(playerRoot) then
					return player
				end
			end
		end
	end
	return nil
end

-- Function: Move along path
local function moveToPosition(targetPos)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	path:ComputeAsync(rootPart.Position, targetPos)

	if path.Status == Enum.PathStatus.Complete then
		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait(1)
		end
	end
end

-- Function: Run away in random direction
local function fleeFromPlayer(playerRoot)
	humanoid.WalkSpeed = RUN_SPEED
	local startTime = tick()
	while tick() - startTime < FLEE_TIME do
		-- Pick a random direction away from the player
		local awayVector = (rootPart.Position - playerRoot.Position).Unit
		local randomOffset = Vector3.new(
			math.random(-20,20),
			0,
			math.random(-20,20)
		)
		local fleePos = rootPart.Position + awayVector * math.random(30,60) + randomOffset
		moveToPosition(fleePos)
	end
	humanoid.WalkSpeed = WALK_SPEED
end

-- Function: Random patrol
local function randomPatrol()
	local randomPos = rootPart.Position + Vector3.new(
		math.random(-PATROL_RADIUS, PATROL_RADIUS),
		0,
		math.random(-PATROL_RADIUS, PATROL_RADIUS)
	)
	moveToPosition(randomPos)
end

-- Main loop
while task.wait(REFRESH_TIME) do
	local player = getVisiblePlayer()
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		-- Run away if player seen
		local playerRoot = player.Character.HumanoidRootPart
		fleeFromPlayer(playerRoot)
	else
		-- Patrol randomly if no player
		randomPatrol()
	end
end
