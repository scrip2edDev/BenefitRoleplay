-- // Variables \\ --

local Walls = {}
Walls.__index = Walls

local Shared = script.Parent.Parent
local Assets = Shared:WaitForChild("Assets")

local Upgrades = {
	Wood = { Color = Color3.fromRGB(86, 66, 54), Material = Enum.Material.Wood },
	Stone = { Color = Color3.fromRGB(116, 116, 116), Material = Enum.Material.Cobblestone },
	Metal = { Color = Color3.fromRGB(116, 116, 116), Material = Enum.Material.Metal },
	Armoured = { Color = Color3.fromRGB(116, 66, 56), Material = Enum.Material.CorrodedMetal },
}

-- // Functions \\ --

function Walls.new(cFrame: CFrame, Type: string)
	local self = setmetatable({
		Type = Type,
		Health = { MaxHealth = 100, CurrentHealth = 100 },
		CFrame = cFrame,
		UpgradeLevel = "Wood",
		Model = nil,
	}, Walls)

	local FoundWall = Assets:FindFirstChild(Type)
	if FoundWall then
		self.Model = FoundWall:Clone()
		self.Model.Parent = game.Workspace
		self.Model:PivotTo(cFrame)
		self.Model.Name = Type .. "_" .. game:GetService("HttpService"):GenerateGUID(false)

		return self
	else
		warn("Couldn't find " .. Type .. " in Assets! or type provided wasn't a wall.")
	end

	return nil
end

function Walls:Break()
	if not self or not self.Model then
		warn("Cannot break wall: Invalid wall instance or missing model")
		return
	end

	for _, WallPart in ipairs(self.Model:GetDescendants()) do
		if WallPart:IsA("BasePart") then
			WallPart.Anchored = false
		end
	end

	task.delay(3, function()
		if self.Model then
			self.Model:Destroy()
			self.Model = nil
		end
	end)
end

function Walls:setUpgrade(Level: string)
	local upgradeTable = Upgrades[Level]
	local material, color = upgradeTable.Material, upgradeTable.Color
	if (not self or not self.Model) or (not material or not color) or not upgradeTable then
		warn("Cannot upgrade wall: Invalid wall instance or missing model or incorrect upgrade level provided")
		return
	end

	self.UpgradeLevel = Level
	for _, WallPart in ipairs(self.Model:GetDescendants()) do
		if WallPart:IsA("BasePart") then
			WallPart.Color = color
			WallPart.Material = material
		end
	end
end

-- // Return \\ --

return Walls
