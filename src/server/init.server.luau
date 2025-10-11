-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerServices = game:GetService("ServerScriptService"):WaitForChild("Services")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

-- // Main \\ --

Knit.AddServices(ServerServices)
Knit.Start({ ServicePromises = false }):andThen(function()
	warn("Knit Server started")
end)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CmdrCommands"))
Cmdr:RegisterHooksIn(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CmdrHooks"))
