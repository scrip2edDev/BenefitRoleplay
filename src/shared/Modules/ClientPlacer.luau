-- // Variables \\ --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Knit = require(ReplicatedStorage.Packages.Knit)
local PlacementValidator = require(Modules:WaitForChild("PlacementValidator"))

local ClientPlacer = {}
ClientPlacer.__index = ClientPlacer

-- // Functions \\ --

function ClientPlacer.new(plot: Model, object: Model, grid: number?, cancelCallback: () -> ())
	local self = setmetatable({}, ClientPlacer)

	self.plot = plot
	self.object = object:Clone()
	self.grid = grid or 0.25
	self.rotation = 0
	self.isPlacing = true
	self.cancelCallback = cancelCallback
	self.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	self.currentCFrame = nil
	self.selectionBox = nil

	self.object.Parent = workspace

	local cameraPoint = self.object:FindFirstChild("CameraPoint")
	if cameraPoint then
		cameraPoint:Destroy()
	end

	for _, part in pairs(self.object:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CanTouch = false
		end
	end

	self.selectionBox = Instance.new("SelectionBox")
	self.selectionBox.LineThickness = 0.05
	self.selectionBox.Transparency = 0
	self.selectionBox.Adornee = self.object
	self.selectionBox.Parent = self.object
	self.selectionBox.Color3 = Color3.fromRGB(255, 0, 0)

	self.renderConnection = RunService.RenderStepped:Connect(function()
		self:Update()
	end)

	if not self.isMobile then
		self.inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self:Place()
			elseif input.KeyCode == Enum.KeyCode.R then
				self:Rotate(45)
			elseif input.KeyCode == Enum.KeyCode.Q then
				self:Rotate(-45)
			elseif input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.X then
				self:Cancel()
			end
		end)
	end

	return self
end

function ClientPlacer:Update()
	if not self.isPlacing then
		return
	end

	local mouse = game.Players.LocalPlayer:GetMouse()
	local camera = workspace.CurrentCamera

	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()

	local filterList = { self.object }
	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

	if result then
		local hitPos = result.Position
		local hitInstance = result.Instance

		local isInPlot = false
		local current = hitInstance
		while current do
			if current == self.plot then
				isInPlot = true
				break
			end
			current = current.Parent
		end

		if not isInPlot then
			return
		end

		local plotCFrame = self.plot:GetPivot()
		local relativePos = plotCFrame:PointToObjectSpace(hitPos)

		local snappedX = math.floor(relativePos.X / self.grid + 0.5) * self.grid
		local snappedZ = math.floor(relativePos.Z / self.grid + 0.5) * self.grid

		local primaryPart = self.object.PrimaryPart
		if not primaryPart then
			warn("Object has no PrimaryPart set!")
			return
		end

		local objectPivot = self.object:GetPivot()
		local primaryPartCFrame = primaryPart.CFrame
		local primaryPartSize = primaryPart.Size

		local pivotToPrimaryPart = objectPivot:ToObjectSpace(primaryPartCFrame)
		local yOffset = pivotToPrimaryPart.Y - (primaryPartSize.Y / 2)

		local worldPos = plotCFrame:PointToWorldSpace(Vector3.new(snappedX, relativePos.Y - yOffset, snappedZ))

		local rotationCFrame = CFrame.Angles(0, math.rad(self.rotation), 0)
		local finalCFrame = CFrame.new(worldPos) * rotationCFrame

		self.object:PivotTo(finalCFrame)
		self.currentCFrame = finalCFrame

		local objectSize = self.object:GetExtentsSize()
		local canPlace = PlacementValidator:WithinBounds(self.plot, objectSize, finalCFrame)
			and PlacementValidator:IsSupported(self.plot, objectSize, finalCFrame)

		if self.selectionBox then
			if canPlace then
				self.selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
			else
				self.selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
			end
		end
	end
end

function ClientPlacer:Rotate(angle: number)
	self.rotation = (self.rotation + angle) % 360
end

function ClientPlacer:Place()
	if not self.isPlacing or not self.currentCFrame then
		return
	end

	local objectSize = self.object:GetExtentsSize()
	local objectName = self.object.Name

	if
		PlacementValidator:WithinBounds(self.plot, objectSize, self.currentCFrame)
		and PlacementValidator:IsSupported(self.plot, objectSize, self.currentCFrame)
	then
		local success = Knit.GetService("PlotService"):Place(objectName, self.currentCFrame)

		if success then
			if self.cancelCallback then
				self.cancelCallback()
			end
			self:Destroy()
		else
			warn("Failed to place object on server")
		end
	else
		warn("Cannot place object here - invalid position")
	end
end

function ClientPlacer:Cancel()
	if self.cancelCallback then
		self.cancelCallback()
	end
	self:Destroy()
end

function ClientPlacer:Destroy()
	self.isPlacing = false

	if self.renderConnection then
		self.renderConnection:Disconnect()
	end

	if self.inputConnection then
		self.inputConnection:Disconnect()
	end

	if self.selectionBox then
		self.selectionBox:Destroy()
		self.selectionBox = nil
	end

	if self.object then
		self.object:Destroy()
	end
end

-- // Return \\ --

return ClientPlacer
