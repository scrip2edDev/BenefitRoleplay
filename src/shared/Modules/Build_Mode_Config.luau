local Furniture = game:GetService("ReplicatedStorage").Shared.Assets.Furniture

return {
	["Categories"] = {
		["Kitchen"] = {
			"Dinner Table",
		},
	},

	["Items"] = {
		["Dinner Table"] = {
			Model = Furniture:WaitForChild("Dinner Table"),
			Price = 50,
		},
	},
}
