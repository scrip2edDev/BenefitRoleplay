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
		["Wall"] = {
			"Dog Picture",
			"Duck Picture",
			"Fancy Portraits",
			"Flower Painting",
			"Mini Painting",
			"Round Painting",
			"Shelf",
			"XL Cool Picture",
			"XL Picture",
		},
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
			"Grey Spike Light",
			"Laptop",
			"Large Lamp",
			"Lamp",
			"Light",
			"TV",
			"Yellow Spike Light",
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
			"Garden Bush 1",
			"Garden Bush 2",
			"Garden Bush 3",
			"Garden Bush 4",
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
			Price = 125,
		},
		["Modern Table Large"] = {
			Model = Furniture:WaitForChild("Modern Table Large"),
			Price = 100,
		},
		["Modern Table Small"] = {
			Model = Furniture:WaitForChild("Modern Table Small"),
			Price = 75,
		},
		["White Coffee Table"] = {
			Model = Furniture:WaitForChild("White Coffee Table"),
			Price = 75,
		},
		["Makeup Desk"] = {
			Model = Furniture:WaitForChild("Makeup Desk"),
			Price = 50,
		},
		["Bed Side Table"] = {
			Model = Furniture:WaitForChild("Bed Side Table"),
			Price = 100,
		},
		["Coffee Table"] = {
			Model = Furniture:WaitForChild("Coffee Table"),
			Price = 75,
		},
		["Table"] = {
			Model = Furniture:WaitForChild("Table"),
			Price = 75,
		},

		-- Seating
		["Dark Wood Chair"] = {
			Model = Furniture:WaitForChild("Dark Wood Chair"),
			Price = 125,
		},
		["Beige Chair"] = {
			Model = Furniture:WaitForChild("Beige Chair"),
			Price = 100,
		},
		["Beige Stool"] = {
			Model = Furniture:WaitForChild("Beige Stool"),
			Price = 75,
		},
		["Large Sofa"] = {
			Model = Furniture:WaitForChild("Large Sofa"),
			Price = 75,
		},
		["Sofa"] = {
			Model = Furniture:WaitForChild("Sofa"),
			Price = 50,
		},
		["Modern Wood Chair"] = {
			Model = Furniture:WaitForChild("Modern Wood Chair"),
			Price = 100,
		},
		["Office Chair"] = {
			Model = Furniture:WaitForChild("Office Chair"),
			Price = 75,
		},

		-- Wall
		["Dog Picture"] = {
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
		},

		-- Decorations
		["Air Freshner"] = {
			Model = Furniture:WaitForChild("Air Freshner"),
			Price = 125,
		},
		["Big Plant"] = {
			Model = Furniture:WaitForChild("Big Plant"),
			Price = 100,
		},
		["Books"] = {
			Model = Furniture:WaitForChild("Books"),
			Price = 75,
		},
		["Bowl"] = {
			Model = Furniture:WaitForChild("Bowl"),
			Price = 75,
		},
		["Candle"] = {
			Model = Furniture:WaitForChild("Candle"),
			Price = 50,
		},
		["Plate"] = {
			Model = Furniture:WaitForChild("Plate"),
			Price = 100,
		},
		["Little Plant"] = {
			Model = Furniture:WaitForChild("Little Plant"),
			Price = 75,
		},
		["Modern Plant"] = {
			Model = Furniture:WaitForChild("Modern Plant"),
			Price = 75,
		},
		["Vase"] = {
			Model = Furniture:WaitForChild("Vase"),
			Price = 75,
		},

		-- Bathroom
		["Washing Machine"] = {
			Model = Furniture:WaitForChild("Washing Machine"),
			Price = 125,
		},
		["Toilet"] = {
			Model = Furniture:WaitForChild("Toilet"),
			Price = 100,
		},
		["Sink"] = {
			Model = Furniture:WaitForChild("Sink"),
			Price = 75,
		},
		["Bath + Shower"] = {
			Model = Furniture:WaitForChild("Bath + Shower"),
			Price = 75,
		},

		-- Electricals
		["Grey Spike Light"] = {
			Model = Furniture:WaitForChild("Grey Spike Light"),
			Price = 125,
		},
		["Laptop"] = {
			Model = Furniture:WaitForChild("Laptop"),
			Price = 100,
		},
		["Large Lamp"] = {
			Model = Furniture:WaitForChild("Large Lamp"),
			Price = 75,
		},
		["Light"] = {
			Model = Furniture:WaitForChild("Light"),
			Price = 75,
		},
		["TV"] = {
			Model = Furniture:WaitForChild("TV"),
			Price = 50,
		},
		["Yellow Spike Light"] = {
			Model = Furniture:WaitForChild("Yellow Spike Light"),
			Price = 100,
		},

		-- Floor
		["Welcome Rug"] = {
			Model = Furniture:WaitForChild("Welcome Rug"),
			Price = 125,
		},
		["Round Rug"] = {
			Model = Furniture:WaitForChild("Round Rug"),
			Price = 100,
		},
		["Striped Rug"] = {
			Model = Furniture:WaitForChild("Striped Rug"),
			Price = 75,
		},
		["Crushed Velvet Rug"] = {
			Model = Furniture:WaitForChild("Crushed Velvet Rug"),
			Price = 75,
		},

		-- Bedroom
		["Bunk Bed"] = {
			Model = Furniture:WaitForChild("Bunk Bed"),
			Price = 125,
		},
		["Double Bed"] = {
			Model = Furniture:WaitForChild("Double Bed"),
			Price = 100,
		},
		["Single Bed"] = {
			Model = Furniture:WaitForChild("Single Bed"),
			Price = 75,
		},

		-- Outside
		["Garden Tree"] = {
			Model = Furniture:WaitForChild("Garden Tree"),
			Price = 125,
		},
		["Garden Bush 1"] = {
			Model = Furniture:WaitForChild("Garden Bush 1"),
			Price = 100,
		},
		["Garden Bush 2"] = {
			Model = Furniture:WaitForChild("Garden Bush 2"),
			Price = 75,
		},
		["Garden Bush 3"] = {
			Model = Furniture:WaitForChild("Garden Bush 3"),
			Price = 75,
		},
		["Garden Bush 4"] = {
			Model = Furniture:WaitForChild("Garden Bush 4"),
			Price = 50,
		},
		["Outside Bench"] = {
			Model = Furniture:WaitForChild("Outside Bench"),
			Price = 100,
		},
		["Grill"] = {
			Model = Furniture:WaitForChild("Grill"),
			Price = 75,
		},
		["Green Bin"] = {
			Model = Furniture:WaitForChild("Green Bin"),
			Price = 75,
		},
		["Brown Bin"] = {
			Model = Furniture:WaitForChild("Brown Bin"),
			Price = 125,
		},
		["Drying Rack"] = {
			Model = Furniture:WaitForChild("Drying Rack"),
			Price = 100,
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
			Price = 50,
		},

		-- Kitchen
		["Drawer Counter"] = {
			Model = Furniture:WaitForChild("Drawer Counter"),
			Price = 125,
		},
		["Microwave"] = {
			Model = Furniture:WaitForChild("Microwave"),
			Price = 100,
		},
		["Oven"] = {
			Model = Furniture:WaitForChild("Oven"),
			Price = 75,
		},
		["Half Cupboard Counter"] = {
			Model = Furniture:WaitForChild("Half Cupboard Counter"),
			Price = 75,
		},
		["Full Cupboard Counter"] = {
			Model = Furniture:WaitForChild("Full Cupboard Counter"),
			Price = 50,
		},
		["Sink Counter"] = {
			Model = Furniture:WaitForChild("Sink Counter"),
			Price = 100,
		},
		["Dishrack"] = {
			Model = Furniture:WaitForChild("Dishrack"),
			Price = 75,
		},
		["Stove Top"] = {
			Model = Furniture:WaitForChild("Stove Top"),
			Price = 75,
		},
		["Fridge"] = {
			Model = Furniture:WaitForChild("Fridge"),
			Price = 125,
		},
		["Oven Cupboard"] = {
			Model = Furniture:WaitForChild("Oven Cupboard"),
			Price = 100,
		},

		-- Storage
		["Chester Drawers"] = {
			Model = Furniture:WaitForChild("Chester Drawers"),
			Price = 125,
		},
		["Wardrobe"] = {
			Model = Furniture:WaitForChild("Wardrobe"),
			Price = 100,
		},
	},
}
