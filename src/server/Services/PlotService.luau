type ObjectInfo = {
	Name: string,
	Cframe: { number },
}

-- // Variables \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlotsFolder = workspace:WaitForChild("Plots")
local Assets = Shared:WaitForChild("Assets")
local Modules = Shared:WaitForChild("Modules")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PlacementValidator = require(Modules:WaitForChild("PlacementValidator"))
local FurnitureFolder = Assets:WaitForChild("Furniture")

local plotSpawns = PlotsFolder:WaitForChild("PlotSpawns")
local allPlots = plotSpawns:GetChildren()

local plots: { Model } = {}
local usedplots: { BasePart } = {}

local PlotService = Knit.CreateService({
	Name = "PlotService",
	Client = {},
})

-- // Functions \\ --

function PlotService.serializePlot(plot: Model)
	local data = {}
	local objectsFolder = plot:FindFirstChild("Objects")
	if not objectsFolder then
		return data
	end

	for _, object in objectsFolder:GetChildren() do
		if object:IsA("Model") or object:IsA("BasePart") then
			local objectCFrame = plot:GetPivot():ToObjectSpace(object:GetPivot())
			local info: ObjectInfo = {
				Name = object.Name,
				Cframe = table.pack(objectCFrame:GetComponents()),
			}
			table.insert(data, info)
		end
	end
	return data
end

function PlotService.GetAvailablePlot(player: Player): BasePart
	local plotSpawn = table.remove(allPlots)
	usedplots[player.UserId] = plotSpawn
	return plotSpawn
end

function PlotService.ReturnAvailablePlot(player: Player)
	if not usedplots[player.UserId] then
		return
	end
	table.insert(allPlots, usedplots[player.UserId])
	usedplots[player.UserId] = nil
end

-- // Main \\ --

function PlotService.SpawnPlot(player: Player): Model
	local Plot = Assets.Plot_Template:Clone()
	Plot.Name = `Plot_{player.Name}`
	Plot.Parent = PlotsFolder
	Plot:PivotTo(PlotService.GetAvailablePlot(player).CFrame)
	plots[player.UserId] = Plot
	return Plot
end

function PlotService.Place(player: Player, name: string, targetCFrame: CFrame): boolean
	local object = FurnitureFolder:FindFirstChild(name)
	local plot = PlotService.GetPlot(player)

	if not object or not plot then
		warn(`{name} - could not be placed because object or plot is nil! Plot: {plot} Object: {object}`)
		return false
	end

	local objectSize = object:GetExtentsSize()

	if not PlacementValidator:WithinBounds(plot, objectSize, targetCFrame) then
		warn(`{name} - could not be placed because it is not within bounds`)
		return false
	end
	if not PlacementValidator:IsSupported(plot, objectSize, targetCFrame) then
		warn(`{name} - could not be placed because it is not supported (floating in air)`)
		return false
	end

	local newObject = object:Clone()

	newObject:PivotTo(targetCFrame)
	newObject.Parent = plot.Objects

	local cameraPoint = newObject:FindFirstChild("CameraPoint")
	if cameraPoint then
		cameraPoint:Destroy()
	end

	return true
end

function PlotService.Delete(player: Player, object: Part): boolean
	local plot = PlotService.GetPlot(player)
	if not plot or not object or not object:IsDescendantOf(plot.Objects) then
		return false
	end

	local actualObject = object
	while actualObject.Parent ~= plot.Objects do
		actualObject = actualObject:FindFirstAncestorWhichIsA("Model")
		if not actualObject then
			return false
		end
	end
	actualObject:Destroy()
	return true
end

function PlotService.GetPlot(player: Player): Model | nil
	return plots[player.UserId]
end

function PlotService.Client.GetPlot(_, player: Player): Model | nil
	return PlotService.GetPlot(player)
end

function PlotService.Client:Place(player: Player, name: string, targetCFrame: CFrame): boolean
	return PlotService.Place(player, name, targetCFrame)
end

function PlotService.Client:Delete(player: Player, object: Part): boolean
	return PlotService.Delete(player, object)
end

function PlotService:KnitStart()
	Players.PlayerAdded:Connect(function(player: Player)
		repeat
			task.wait()
		until Knit.GetService("PlayerData"):GetProfile(player) ~= nil
		local plot = PlotService.SpawnPlot(player)
		local profile = Knit.GetService("PlayerData"):GetProfile(player)
		if profile and profile.PlayerBuildData then
			for _, objectInfo in profile.PlayerBuildData do
				local object = FurnitureFolder:FindFirstChild(objectInfo.Name)
				if object then
					local objectClone = object:Clone()
					local relativeCFrame = CFrame.new(table.unpack(objectInfo.Cframe))

					objectClone:PivotTo(plot:GetPivot():ToWorldSpace(relativeCFrame))
					objectClone.Parent = plot.Objects

					local cameraPoint = objectClone:FindFirstChild("CameraPoint")
					if cameraPoint then
						cameraPoint:Destroy()
					end
				else
					warn(`Could not find furniture: {objectInfo.Name}`)
				end
			end
		end
	end)
end

-- // Return \\ --

return PlotService
