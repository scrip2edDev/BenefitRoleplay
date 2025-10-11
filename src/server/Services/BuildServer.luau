-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classes")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Builds = {}
local BuildServer = Knit.CreateService({
	Name = "BuildServer",
	Client = {
		build = Knit.CreateSignal(),
		CanBuildAtPosition = Knit.CreateProperty("CanBuildAtPosition", false),
	},
})

local Config = {
	["Wall"] = Classes:WaitForChild("Walls"),
	["Window Frame"] = Classes:WaitForChild("Walls"),
	["Door Frame"] = Classes:WaitForChild("Doors&Frames"),
	["Door"] = Classes:WaitForChild("Doors&Frames"),
	["Foundation"] = Classes:WaitForChild("Foundation&Roofs"),
	["Roof"] = Classes:WaitForChild("Foundation&Roofs"),
	["Stairs"] = Classes:WaitForChild("Stairs"),
}

-- // Functions \\ --

local function getClassFromName(className: string)
	local classModule = Config[className]
	if classModule then
		return require(classModule)
	else
		warn("Class " .. className .. " not found in Classes folder.")
		return nil
	end
end

local function CanBuildAtPosition(cframe)
	local position = cframe.Position
	local modelSize = Vector3.new(4, 6, 4)

	local regionParts = workspace:GetPartBoundsInBox(cframe, modelSize, OverlapParams.new())

	for _, part in ipairs(regionParts) do
		if part:IsA("BasePart") then
			if not part.Parent or part.Parent.Name ~= "BuildPreview" then
				return false
			end
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {}

	local downwardRay = workspace:Raycast(position + Vector3.new(0, 2, 0), Vector3.new(0, -10, 0), raycastParams)

	return downwardRay ~= nil
end

-- // Main \\ --

function BuildServer:CanBuildAtPosition(cframe)
	return CanBuildAtPosition(cframe)
end

function BuildServer.Client:CanBuildAtPosition(player, cframe)
	return CanBuildAtPosition(cframe)
end

function BuildServer:KnitStart()
	BuildServer.Client.build:Connect(function(player, data)
		if not data or not data.Type or not data.CFrame then
			warn("Invalid build data received from player:", player.Name)
			return
		end

		local buildClass = getClassFromName(data.Type)
		if buildClass then
			local buildData = buildClass.new(data.CFrame, data.Type)
			Builds[player.UserId .. "_" .. buildData.Model.Name] = buildData or {}
		else
			warn("Failed to create building of type:", data.Type)
		end
	end)
end

-- // Return \\ --

return BuildServer
