-- // Variables \\ --

local PlacementValidator = {}

-- // Functions \\\ --

-- // Main \\ --

function PlacementValidator:WithinBounds(plot: Model, objectSize: Vector3, worldCFrame: CFrame)
	local plotCFrame, plotSize = plot:GetBoundingBox()
	local objectCFrame = plotCFrame:ToObjectSpace(worldCFrame)

	local cornerPoints = {}

	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			table.insert(
				cornerPoints,
				objectCFrame:PointToWorldSpace(Vector3.new(x * objectSize.X / 2, 0, z * objectSize.Z / 2))
			)
		end
	end

	for _, corner in cornerPoints do
		if math.abs(corner.X) > plotSize.X / 2 or math.abs(corner.Z) > plotSize.Z / 2 then
			return false
		end
	end

	return true
end

function PlacementValidator:NotIntersectingObjects(plot: Model, objectSize: Vector3, worldCFrame: CFrame)
	local params = OverlapParams.new()
	local objects = plot:FindFirstChild("Objects")
	if objects then
		params:AddToFilter(objects)
	end
	params.FilterType = Enum.RaycastFilterType.Include
	local parts = workspace:GetPartBoundsInBox(worldCFrame, objectSize, params)
	return #parts == 0
end

-- // Return \\ --

return PlacementValidator
