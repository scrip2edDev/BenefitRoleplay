-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Controllers")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- // Main \\ --

Knit.AddControllers(Controllers)
Knit.Start({ ServicePromises = false }):andThen(function()
	warn("Knit Client started")
end)
