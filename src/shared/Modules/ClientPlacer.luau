-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ContextActionService = game:GetService("ContextActionService")

local Camera = workspace.CurrentCamera
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = Shared:WaitForChild("Assets")

local FurnitureFolder = Assets:WaitForChild("Furniture")
local PlacementValidator = require(Shared:WaitForChild("Modules"):WaitForChild("PlacementValidator"))
local Knit = require(ReplicatedStorage.Packages.Knit)

local ClientPlacer = {}
ClientPlacer.__index = ClientPlacer

-- // Functions \\ --

local function castMouse()
	local mouseLocation = UserInputService:GetMouseLocation()
	local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	return workspace:Raycast(ray.Origin, ray.Direction * 1000)
end

-- // Main \\ --

function ClientPlacer.new(plot: Model)
	local self = setmetatable({
		Plot = plot,
		Preview = nil,
		BoxOutline = nil,
		Rotation = 0,
	}, ClientPlacer)

	self:InitiateRenderPreview()
	ContextActionService:BindAction("PLACE", function(...)
		self:TryPlaceBlock(...)
	end, false, Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction("DELETE", function(...)
		self:TryDeleteBlock(...)
	end, false, Enum.KeyCode.X)
	ContextActionService:BindAction("ROTATE", function(...)
		self:RotateBlock(...)
	end, true, Enum.KeyCode.R)

	return self
end

function ClientPlacer:InitiateRenderPreview()
	self:PreparePreviewModel(FurnitureFolder["Dinner Table"])
	RunService:BindToRenderStep("PREVIEW_RENDER", Enum.RenderPriority.Camera.Value, function(...)
		self:RenderPreview(...)
	end)
end

function ClientPlacer:PreparePreviewModel(model: Model)
	if self.Preview then
		self.Preview:Destroy()
	end

	self.Preview = model:Clone()
	self.BoxOutline = Instance.new("SelectionBox", self.Preview)
	self.BoxOutline.Adornee = self.Preview
	self.BoxOutline.LineThickness = 0.05

	for _, part: BasePart in self.Preview:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency ~= 1 then
			part.Transparency = 0.5
			part.CanCollide = false
			part.CanQuery = false
			part.Anchored = true
		end
	end

	self.Preview.Parent = workspace
end

function ClientPlacer:RenderPreview()
	local cast = castMouse()
	if cast and cast.Position then
		local cframe = CFrame.new(cast.Position) * CFrame.Angles(0, self.Rotation, 0)
		self.Preview:PivotTo(cframe)

		local size = self.Preview:GetExtentsSize()
		self.BoxOutline.Color3 = if PlacementValidator:WithinBounds(self.Plot, size, cframe)
				and PlacementValidator:NotIntersectingObjects(self.Plot, size, cframe)
			then Color3.fromRGB(0, 255, 0)
			else Color3.fromRGB(255, 0, 0)
	end
end

function ClientPlacer:TryPlaceBlock(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end
	local success = Knit.GetService("PlotService"):Place(self.Preview.Name, self.Preview:GetPivot())
	if success then
		warn(`Successfully placed {self.Preview.Name}!`)
	else
		warn(`Could not place {self.Preview.Name}!`)
	end
end

function ClientPlacer:RotateBlock(_, state, _)
	if state == Enum.UserInputState.Begin then
		self.Rotation += math.pi / 2
	end
end

function ClientPlacer:TryDeleteBlock(_, state, _)
	if state == Enum.UserInputState.Begin then
		local cast = castMouse()
		if cast and cast.Instance then
			local success = Knit.GetService("PlotService"):Delete(cast.Instance)
			if success then
				warn(`Successfully deleted object!`)
			else
				warn(`Could not delete object!`)
			end
		end
	end
end

function ClientPlacer:Destroy()
	if self.Preview then
		self.Preview:Destroy()
	end
	if self.BoxOutline then
		self.BoxOutline:Destroy()
	end
	RunService:UnbindFromRenderStep("PREVIEW_RENDER")
	ContextActionService:UnbindAction("PLACE")
	ContextActionService:UnbindAction("DELETE")
	ContextActionService:UnbindAction("ROTATE")
end

-- // Return \\ --

return ClientPlacer
