-- // Variables \\ --

local PlacementValidator = {}

-- // Main \\ --

function PlacementValidator:WithinBounds(plot: Model, objectSize: Vector3, worldCFrame: CFrame)
	local plotCFrame, plotSize = plot:GetBoundingBox()
	local relativePos = plotCFrame:PointToObjectSpace(worldCFrame.Position)

	local halfSizeX = plotSize.X / 2
	local halfSizeZ = plotSize.Z / 2

	local margin = math.max(objectSize.X, objectSize.Z) / 2

	if math.abs(relativePos.X) <= halfSizeX - margin and math.abs(relativePos.Z) <= halfSizeZ - margin then
		return true
	end

	return false
end

function PlacementValidator:IsSupported(plot: Model, objectSize: Vector3, worldCFrame: CFrame)
	local params = RaycastParams.new()

	local filterList = { plot }
	local objects = plot:FindFirstChild("Objects")
	if objects then
		for _, obj in objects:GetChildren() do
			table.insert(filterList, obj)
		end
	end

	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Include

	local rayOrigin = worldCFrame.Position
	local rayDirection = Vector3.new(0, -objectSize.Y, 0)

	local result = workspace:Raycast(rayOrigin, rayDirection, params)

	return result ~= nil
end

function PlacementValidator:GetSurfaceHeight(plot: Model, xPos: number, zPos: number, fromHeight: number)
	fromHeight = fromHeight or 100

	local params = RaycastParams.new()
	local objects = plot:FindFirstChild("Objects")
	local filterList = { plot }
	if objects then
		for _, obj in objects:GetChildren() do
			table.insert(filterList, obj)
		end
	end
	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Include

	local plotCFrame = plot:GetPivot()
	local rayOrigin = plotCFrame.Position + Vector3.new(xPos, fromHeight, zPos)
	local rayDirection = Vector3.new(0, -(fromHeight + 50), 0)

	local result = workspace:Raycast(rayOrigin, rayDirection, params)

	if result then
		return result.Position.Y, result.Instance
	end

	return nil, nil
end

function PlacementValidator:CanPlaceOnSurface(
	plot: Model,
	objectSize: Vector3,
	worldCFrame: CFrame,
	surfaceNormal: Vector3
)
	local params = RaycastParams.new()
	local filterList = { plot }
	local objects = plot:FindFirstChild("Objects")
	if objects then
		for _, obj in objects:GetChildren() do
			table.insert(filterList, obj)
		end
	end
	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Include

	local rayOrigin = worldCFrame.Position
	local rayDirection = surfaceNormal * 0.5

	local result = workspace:Raycast(rayOrigin, rayDirection, params)

	return result ~= nil, result
end

function PlacementValidator:GetAllSurfacesAtPosition(plot: Model, xPos: number, zPos: number)
	local surfaces = {}
	local params = RaycastParams.new()
	local objects = plot:FindFirstChild("Objects")
	local filterList = { plot }
	if objects then
		for _, obj in objects:GetChildren() do
			table.insert(filterList, obj)
		end
	end
	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Include

	local plotCFrame = plot:GetPivot()
	local rayOrigin = plotCFrame.Position + Vector3.new(xPos, 100, zPos)
	local rayDirection = Vector3.new(0, -200, 0)

	local currentOrigin = rayOrigin
	for i = 1, 10 do
		local result = workspace:Raycast(currentOrigin, rayDirection, params)
		if result then
			table.insert(surfaces, {
				Height = result.Position.Y,
				Instance = result.Instance,
				Normal = result.Normal,
			})
			currentOrigin = result.Position + Vector3.new(0, -0.1, 0)
			rayDirection = Vector3.new(0, -(rayOrigin.Y - currentOrigin.Y), 0)
		else
			break
		end
	end

	return surfaces
end

-- // Return \\ --

return PlacementValidator
