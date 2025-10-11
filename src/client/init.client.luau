-- // Variables \\ --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Controllers")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Cmdr = require(ReplicatedStorage:FindFirstChild("CmdrClient") or ReplicatedStorage.Packages.Cmdr)

-- // Main \\ --

Knit.AddControllers(Controllers)
Knit.Start({ ServicePromises = false }):andThen(function()
	warn("Knit Client started")
end)

Cmdr:SetActivationKeys({ Enum.KeyCode.F2, Enum.KeyCode.Quote })
