-- // Variables \\ --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ClientDelete = {}
ClientDelete.__index = ClientDelete

-- // Main \\ --

function ClientDelete.new(plot, onDeleteCallback)
	local self = setmetatable({}, ClientDelete)

	self.plot = plot
	self.onDeleteCallback = onDeleteCallback
	self.active = true
	self.hoveredObject = nil
	self.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	self.connections = {}

	self:_setupConnections()

	return self
end

function ClientDelete:_resetHoveredObject()
	if self.hoveredObject then
		local selectionBox = self.hoveredObject:FindFirstChild("SelectionBox")
		if selectionBox then
			selectionBox:Destroy()
		end
		self.hoveredObject = nil
	end
end

function ClientDelete:_highlightObject(object)
	self:_resetHoveredObject()

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Parent = object
	selectionBox.Adornee = object
	selectionBox.Color3 = Color3.new(0.909804, 0.082353, 0.082353)
	selectionBox.LineThickness = 0.1
	selectionBox.SurfaceTransparency = 0.8

	self.hoveredObject = object
end

function ClientDelete:_updateHover()
	if not self.active then
		return
	end

	local mouse = game.Players.LocalPlayer:GetMouse()
	local camera = workspace.CurrentCamera

	if not self.plot then
		self:_resetHoveredObject()
		return
	end

	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {}
	params.FilterType = Enum.RaycastFilterType.Include

	local objectsFolder = self.plot:FindFirstChild("Objects")
	if objectsFolder then
		params.FilterDescendantsInstances = objectsFolder:GetDescendants()
	end

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

	if result and result.Instance then
		local hitPart = result.Instance
		local objectToDelete = hitPart

		if objectsFolder then
			while objectToDelete and objectToDelete.Parent ~= objectsFolder do
				objectToDelete = objectToDelete.Parent
			end
		end

		if objectToDelete and objectToDelete ~= self.hoveredObject then
			self:_highlightObject(objectToDelete)
		end
	else
		self:_resetHoveredObject()
	end
end

function ClientDelete:_setupConnections()
	self.connections.Hover = RunService.RenderStepped:Connect(function()
		self:_updateHover()
	end)

	self.connections.Click = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not self.active then
			return
		end

		local validInput = input.UserInputType == Enum.UserInputType.MouseButton1
			or (self.isMobile and input.UserInputType == Enum.UserInputType.Touch)

		if validInput and self.hoveredObject then
			if self.onDeleteCallback then
				local success = self.onDeleteCallback(self.hoveredObject)
				if success then
					self:_resetHoveredObject()
				end
			end
		end
	end)
end

function ClientDelete:Destroy()
	self.active = false
	self:_resetHoveredObject()

	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end

	self.connections = {}
end

-- // Return \\ --

return ClientDelete
