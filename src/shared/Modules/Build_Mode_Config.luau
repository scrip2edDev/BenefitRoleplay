local Furniture = game:GetService("ReplicatedStorage").Shared.Assets.Furniture

return {
	["Categories"] = {
		["Tables"] = {
			"Dinner Table",
			"Modern Table Large",
			"Modern Table Small",
			"White Coffee Table",
			"Makeup Desk",
			"Bed Side Table",
			"Coffee Table",
			"Table",
		},
		["Seating"] = {
			"Dark Wood Chair",
			"Beige Chair",
			"Beige Stool",
			"Large Sofa",
			"Sofa",
			"Modern Wood Chair",
			"Office Chair",
		},
		--[[ ["Wall"] = {
			"Dog Picture",
			"Duck Picture",
			"Fancy Portraits",
			"Flower Painting",
			"Mini Painting",
			"Round Painting",
			"Shelf",
			"XL Cool Picture",
			"XL Picture",
		},]]
		["Decorations"] = {
			"Air Freshner",
			"Big Plant",
			"Books",
			"Bowl",
			"Candle",
			"Plate",
			"Little Plant",
			"Modern Plant",
			"Vase",
		},
		["Bathroom"] = {
			"Washing Machine",
			"Toilet",
			"Sink",
			"Bath & Shower",
		},
		["Electricals"] = {
			--"Grey Spike Light",
			"Laptop",
			"Large Lamp",
			"Light",
			"TV",
			--"Yellow Spike Light",
		},
		["Floor"] = {
			"Welcome Rug",
			"Round Rug",
			"Striped Rug",
			"Crushed Velvet Rug",
		},
		["Bedroom"] = {
			"Bunk Bed",
			"Double Bed",
			"Single Bed",
		},
		["Outside"] = {
			"Garden Tree",
			"Outside Bench",
			"Grill",
			"Green Bin",
			"Brown Bin",
			"Drying Rack",
			"Shed",
			"Pool",
			"Trampoline",
		},
		["Kitchen"] = {
			"Drawer Counter",
			"Microwave",
			"Oven",
			"Half Cupboard Counter",
			"Full Cupboard Counter",
			"Sink Counter",
			"Dishrack",
			"Stove Top",
			"Fridge",
			"Oven Cupboard",
		},
		["Storage"] = {
			"Chester Drawers",
			"Wardrobe",
		},
	},

	["Items"] = {
		-- Tables
		["Dinner Table"] = {
			Model = Furniture:WaitForChild("Dinner Table"),
			Price = 50,
		},
		["Modern Table Large"] = {
			Model = Furniture:WaitForChild("Modern Table Large"),
			Price = 65,
		},
		["Modern Table Small"] = {
			Model = Furniture:WaitForChild("Modern Table Small"),
			Price = 25,
		},
		["White Coffee Table"] = {
			Model = Furniture:WaitForChild("White Coffee Table"),
			Price = 15,
		},
		["Makeup Desk"] = {
			Model = Furniture:WaitForChild("Makeup Desk"),
			Price = 35,
		},
		["Bed Side Table"] = {
			Model = Furniture:WaitForChild("Bed Side Table"),
			Price = 10,
		},
		["Coffee Table"] = {
			Model = Furniture:WaitForChild("Coffee Table"),
			Price = 20,
		},
		["Table"] = {
			Model = Furniture:WaitForChild("Table"),
			Price = 35,
		},

		-- Seating
		["Dark Wood Chair"] = {
			Model = Furniture:WaitForChild("Dark Wood Chair"),
			Price = 20,
		},
		["Beige Chair"] = {
			Model = Furniture:WaitForChild("Beige Chair"),
			Price = 20,
		},
		["Beige Stool"] = {
			Model = Furniture:WaitForChild("Beige Stool"),
			Price = 15,
		},
		["Large Sofa"] = {
			Model = Furniture:WaitForChild("Large Sofa"),
			Price = 65,
		},
		["Sofa"] = {
			Model = Furniture:WaitForChild("Sofa"),
			Price = 55,
		},
		["Modern Wood Chair"] = {
			Model = Furniture:WaitForChild("Modern Wood Chair"),
			Price = 25,
		},
		["Office Chair"] = {
			Model = Furniture:WaitForChild("Office Chair"),
			Price = 35,
		},

		-- Wall
		--[[["Dog Picture"] = {
			Model = Furniture:WaitForChild("Dog Picture"),
			Price = 125,
		},
		["Duck Picture"] = {
			Model = Furniture:WaitForChild("Duck Picture"),
			Price = 100,
		},
		["Fancy Portraits"] = {
			Model = Furniture:WaitForChild("Fancy Portraits"),
			Price = 75,
		},
		["Flower Painting"] = {
			Model = Furniture:WaitForChild("Flower Painting"),
			Price = 75,
		},
		["Mini Painting"] = {
			Model = Furniture:WaitForChild("Mini Painting"),
			Price = 50,
		},
		["Round Painting"] = {
			Model = Furniture:WaitForChild("Round Painting"),
			Price = 100,
		},
		["Shelf"] = {
			Model = Furniture:WaitForChild("Shelf"),
			Price = 75,
		},
		["XL Picture"] = {
			Model = Furniture:WaitForChild("XL Picture"),
			Price = 75,
		},
		["XL Cool Picture"] = {
			Model = Furniture:WaitForChild("XL Cool Picture"),
			Price = 75,
		},]]

		-- Decorations
		["Air Freshner"] = {
			Model = Furniture:WaitForChild("Air Freshner"),
			Price = 5,
		},
		["Big Plant"] = {
			Model = Furniture:WaitForChild("Big Plant"),
			Price = 5,
		},
		["Books"] = {
			Model = Furniture:WaitForChild("Books"),
			Price = 5,
		},
		["Bowl"] = {
			Model = Furniture:WaitForChild("Bowl"),
			Price = 5,
		},
		["Candle"] = {
			Model = Furniture:WaitForChild("Candle"),
			Price = 5,
		},
		["Plate"] = {
			Model = Furniture:WaitForChild("Plate"),
			Price = 5,
		},
		["Little Plant"] = {
			Model = Furniture:WaitForChild("Little Plant"),
			Price = 5,
		},
		["Modern Plant"] = {
			Model = Furniture:WaitForChild("Modern Plant"),
			Price = 5,
		},
		["Vase"] = {
			Model = Furniture:WaitForChild("Vase"),
			Price = 5,
		},

		-- Bathroom
		["Washing Machine"] = {
			Model = Furniture:WaitForChild("Washing Machine"),
			Price = 30,
		},
		["Toilet"] = {
			Model = Furniture:WaitForChild("Toilet"),
			Price = 35,
		},
		["Sink"] = {
			Model = Furniture:WaitForChild("Sink"),
			Price = 30,
		},
		["Bath + Shower"] = {
			Model = Furniture:WaitForChild("Bath + Shower"),
			Price = 40,
		},

		-- Electricals
		--[[["Grey Spike Light"] = {
			Model = Furniture:WaitForChild("Grey Spike Light"),
			Price = 125,
		},]]
		["Laptop"] = {
			Model = Furniture:WaitForChild("Laptop"),
			Price = 10,
		},
		["Large Lamp"] = {
			Model = Furniture:WaitForChild("Large Lamp"),
			Price = 20,
		},
		["Light"] = {
			Model = Furniture:WaitForChild("Light"),
			Price = 25,
		},
		["TV"] = {
			Model = Furniture:WaitForChild("TV"),
			Price = 25,
		},
		--[[["Yellow Spike Light"] = {
			Model = Furniture:WaitForChild("Yellow Spike Light"),
			Price = 100,
		},]]

		-- Floor
		["Welcome Rug"] = {
			Model = Furniture:WaitForChild("Welcome Rug"),
			Price = 15,
		},
		["Round Rug"] = {
			Model = Furniture:WaitForChild("Round Rug"),
			Price = 25,
		},
		["Striped Rug"] = {
			Model = Furniture:WaitForChild("Striped Rug"),
			Price = 10,
		},
		["Crushed Velvet Rug"] = {
			Model = Furniture:WaitForChild("Crushed Velvet Rug"),
			Price = 20,
		},

		-- Bedroom
		["Bunk Bed"] = {
			Model = Furniture:WaitForChild("Bunk Bed"),
			Price = 55,
		},
		["Double Bed"] = {
			Model = Furniture:WaitForChild("Double Bed"),
			Price = 65,
		},
		["Single Bed"] = {
			Model = Furniture:WaitForChild("Single Bed"),
			Price = 50,
		},

		-- Outside
		["Outside Bench"] = {
			Model = Furniture:WaitForChild("Outside Bench"),
			Price = 25,
		},
		["Grill"] = {
			Model = Furniture:WaitForChild("Grill"),
			Price = 65,
		},
		["Green Bin"] = {
			Model = Furniture:WaitForChild("Green Bin"),
			Price = 10,
		},
		["Brown Bin"] = {
			Model = Furniture:WaitForChild("Brown Bin"),
			Price = 10,
		},
		["Drying Rack"] = {
			Model = Furniture:WaitForChild("Drying Rack"),
			Price = 15,
		},
		["Shed"] = {
			Model = Furniture:WaitForChild("Shed"),
			Price = 75,
		},
		["Pool"] = {
			Model = Furniture:WaitForChild("Pool"),
			Price = 75,
		},
		["Trampoline"] = {
			Model = Furniture:WaitForChild("Trampoline"),
			Price = 75,
		},

		-- Kitchen
		["Drawer Counter"] = {
			Model = Furniture:WaitForChild("Drawer Counter"),
			Price = 25,
		},
		["Microwave"] = {
			Model = Furniture:WaitForChild("Microwave"),
			Price = 30,
		},
		["Oven"] = {
			Model = Furniture:WaitForChild("Oven"),
			Price = 30,
		},
		["Half Cupboard Counter"] = {
			Model = Furniture:WaitForChild("Half Cupboard Counter"),
			Price = 25,
		},
		["Full Cupboard Counter"] = {
			Model = Furniture:WaitForChild("Full Cupboard Counter"),
			Price = 25,
		},
		["Sink Counter"] = {
			Model = Furniture:WaitForChild("Sink Counter"),
			Price = 25,
		},
		["Dishrack"] = {
			Model = Furniture:WaitForChild("Dishrack"),
			Price = 10,
		},
		["Stove Top"] = {
			Model = Furniture:WaitForChild("Stove Top"),
			Price = 30,
		},
		["Fridge"] = {
			Model = Furniture:WaitForChild("Fridge"),
			Price = 30,
		},
		["Oven Cupboard"] = {
			Model = Furniture:WaitForChild("Oven Cupboard"),
			Price = 30,
		},

		-- Storage
		["Chester Drawers"] = {
			Model = Furniture:WaitForChild("Chester Drawers"),
			Price = 25,
		},
		["Wardrobe"] = {
			Model = Furniture:WaitForChild("Wardrobe"),
			Price = 35,
		},
	},
}
