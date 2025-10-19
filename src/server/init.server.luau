-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerServices = game:GetService("ServerScriptService"):WaitForChild("Services")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- // Main \\ --

Knit.AddServices(ServerServices)
Knit.Start({ ServicePromises = false }):andThen(function()
	warn("Knit Server started")
end)
