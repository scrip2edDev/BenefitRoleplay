-- // Variables \\ --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ClientPainter = {}
ClientPainter.__index = ClientPainter

-- // Main \\ --

function ClientPainter.new(plot, selectedColor, onExitCallback)
	local self = setmetatable({}, ClientPainter)

	self.plot = plot
	self.selectedColor = selectedColor or Color3.fromRGB(255, 255, 255)
	self.onExitCallback = onExitCallback
	self.active = true
	self.hoveredObject = nil
	self.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	self.originalColors = {}

	self.connections = {}

	self:setupConnections()

	return self
end

function ClientPainter:SetColor(newColor)
	self.selectedColor = newColor
	if self.hoveredObject then
		self:updateObjectColors(self.hoveredObject, newColor)
		local selectionBox = self.hoveredObject:FindFirstChild("PaintSelectionBox")
		if selectionBox then
			selectionBox.Color3 = newColor
		end
	end
end

function ClientPainter:storeOriginalColors(object)
	for _, descendant in pairs(object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			self.originalColors[descendant] = descendant.Color
		end
	end
end

function ClientPainter:restoreOriginalColors(object)
	for _, descendant in pairs(object:GetDescendants()) do
		if descendant:IsA("BasePart") and self.originalColors[descendant] then
			descendant.Color = self.originalColors[descendant]
		end
	end
end

function ClientPainter:updateObjectColors(object, color)
	for _, descendant in pairs(object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Color = color
		end
	end
end

function ClientPainter:resetHoveredObject()
	if self.hoveredObject then
		self:restoreOriginalColors(self.hoveredObject)

		local selectionBox = self.hoveredObject:FindFirstChild("PaintSelectionBox")
		if selectionBox then
			selectionBox:Destroy()
		end
	end

	self.hoveredObject = nil
	self.originalColors = {}
end

function ClientPainter:highlightObject(object)
	self:resetHoveredObject()
	self:storeOriginalColors(object)
	self:updateObjectColors(object, self.selectedColor)

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "PaintSelectionBox"
	selectionBox.Parent = object
	selectionBox.Adornee = object
	selectionBox.Color3 = self.selectedColor
	selectionBox.LineThickness = 0.1
	selectionBox.SurfaceTransparency = 0.5

	self.hoveredObject = object
end

function ClientPainter:updateHover()
	if not self.active then
		return
	end

	local mouse = game.Players.LocalPlayer:GetMouse()
	local camera = workspace.CurrentCamera

	if not self.plot then
		self:resetHoveredObject()
		return
	end

	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {}
	params.FilterType = Enum.RaycastFilterType.Include

	local WallsAndFloorsFolder = self.plot:FindFirstChild("WallsAndFloors")
	if WallsAndFloorsFolder then
		params.FilterDescendantsInstances = WallsAndFloorsFolder:GetDescendants()
	end

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

	if result and result.Instance then
		local hitPart = result.Instance
		local objectToPaint = hitPart

		if WallsAndFloorsFolder then
			while objectToPaint and objectToPaint.Parent ~= WallsAndFloorsFolder do
				objectToPaint = objectToPaint.Parent
			end
		end

		if objectToPaint and objectToPaint ~= self.hoveredObject then
			self:highlightObject(objectToPaint)
		end
	else
		self:resetHoveredObject()
	end
end

function ClientPainter:setupConnections()
	self.connections.Hover = RunService.RenderStepped:Connect(function()
		self:updateHover()
	end)

	self.connections.Click = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not self.active then
			return
		end

		local validInput = input.UserInputType == Enum.UserInputType.MouseButton1
			or (self.isMobile and input.UserInputType == Enum.UserInputType.Touch)

		if validInput and self.hoveredObject then
			-- send stuff to server
		end
	end)

	self.connections.Exit = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not self.active then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape then
			if self.onExitCallback then
				self.onExitCallback()
			end
			self:Destroy()
		end
	end)
end

function ClientPainter:Destroy()
	self.active = false
	self:resetHoveredObject()

	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end

	self.connections = {}
end

-- // Return \\ --

return ClientPainter
