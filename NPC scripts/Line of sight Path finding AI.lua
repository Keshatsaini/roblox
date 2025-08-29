-- NPC A* Pathfinding with Line of Sight
-- Put inside your NPC model (ServerScript)
-- NPC must have Humanoid + HumanoidRootPart

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local rootPart = npc:WaitForChild("HumanoidRootPart")

-- SETTINGS
local CHASE_RANGE = 100       -- max distance to detect players
local REFRESH_TIME = 1        -- seconds between path recalculations

-- Function: Check if NPC has line of sight to target
local function hasLineOfSight(target)
	local origin = rootPart.Position
	local targetPos = target.Position
	local direction = (targetPos - origin)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {npc} -- ignore self
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = Workspace:Raycast(origin, direction, raycastParams)
	if result then
		-- check if the first thing hit is part of the target’s character
		if result.Instance:IsDescendantOf(target.Parent) then
			return true
		else
			return false
		end
	end
	return true -- no obstacle = clear
end

-- Function: Find closest visible player
local function getClosestVisiblePlayer()
	local closestPlayer = nil
	local closestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local playerRoot = player.Character.HumanoidRootPart
			local distance = (playerRoot.Position - rootPart.Position).Magnitude
			if distance < closestDistance and distance <= CHASE_RANGE then
				if hasLineOfSight(playerRoot) then
					closestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

-- Function: Move along path
local function followPath(targetPos)
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
		for _, waypoint in pairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	else
		warn("Path failed for NPC: " .. npc.Name)
	end
end

-- Main loop
while task.wait(REFRESH_TIME) do
	local targetPlayer = getClosestVisiblePlayer()
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local targetPos = targetPlayer.Character.HumanoidRootPart.Position
		followPath(targetPos)
	else
		humanoid:MoveTo(rootPart.Position) -- idle if no target
	end
end
