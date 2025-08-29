-- 🔎 How to set this up:
--In Workspace, insert two parts → rename them StartPart and FinalPart.
--Insert a Dummy NPC (View > Toolbox > Rig Builder → R15 or R6 Dummy). Rename it Dummy.
--Paste the script inside ServerScriptService (or directly inside the Dummy model if you prefer).
--Hit Play → NPC will walk from StartPart → FinalPart following the computed A* path. 

local PathfindingService = game:GetService("PathfindingService")

-- Change these names to match your parts in Workspace
local startPart = workspace:WaitForChild("StartPart")
local finalPart = workspace:WaitForChild("FinalPart")

-- If this is for an NPC, reference the NPC humanoid
-- For testing, you can also create a Dummy from Rig Builder and place script inside it
local npc = workspace:WaitForChild("Dummy")  -- <-- NPC model with Humanoid + HumanoidRootPart
local humanoid = npc:WaitForChild("Humanoid")
local rootPart = npc:WaitForChild("HumanoidRootPart")

-- Function to move along path
local function moveToTarget(startPos, endPos)
	-- Create A* path
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentMaxSlope = 45,
	})

	-- Compute path between start and end
	path:ComputeAsync(startPos, endPos)

	if path.Status == Enum.PathStatus.Complete then
		print("Path found!")

		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end

		print("Reached destination!")
	else
		warn("Path failed!")
	end
end

-- Run pathfinding
task.wait(1)
moveToTarget(startPart.Position, finalPart.Position)
