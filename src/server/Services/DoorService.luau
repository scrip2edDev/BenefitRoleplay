-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = Shared:WaitForChild("Modules")

local Doors = Modules:WaitForChild("Doors")
local DoorTags = { "Door_1", "Door_2", "Door_3", "Door_4" }
local DoorService = Knit.CreateService({
	Name = "DoorService",
	Client = {},
})

-- // Functions \\ --

function setupDoor(Door, TagName)
	local FoundDoorScript = Doors:FindFirstChild(TagName)
	if FoundDoorScript and FoundDoorScript:IsA("ModuleScript") then
		require(FoundDoorScript).Door_Run(Door)
	end
end

function checkAndSetupDoor(Item)
	if table.find(DoorTags, Item.Name) then
		setupDoor(Item, Item.Name)
	end
end

function getTagsAndSetupDoors()
	for _, Item in pairs(game.Workspace:GetDescendants()) do
		checkAndSetupDoor(Item)
	end

	game.Workspace.DescendantAdded:Connect(function(Item)
		checkAndSetupDoor(Item)
	end)
end

-- // Main \\ --

function DoorService:KnitStart()
	warn(`{script.Name} is now Running!`)
	getTagsAndSetupDoors()
end

-- // Return \\ --

return DoorService
