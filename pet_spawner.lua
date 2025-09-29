--[[
    @author depso (depthso)
    @description Grow a Garden Pet Spawner Script
    https://www.roblox.com/games/126884695634066
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Leaderstats = LocalPlayer.leaderstats
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

local ShecklesCount = Leaderstats.Sheckles
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)

--// ReGui
local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local PrefabsId = "rbxassetid://" .. ReGui.PrefabsId

--// Folders
local GameEvents = ReplicatedStorage.GameEvents

local Accent = {
    DarkGreen = Color3.fromRGB(45, 95, 25),
    Green = Color3.fromRGB(69, 142, 40),
    Brown = Color3.fromRGB(26, 20, 8),
    Gold = Color3.fromRGB(255, 215, 0),
    Silver = Color3.fromRGB(192, 192, 192),
    Bronze = Color3.fromRGB(205, 127, 50),
}

--// ReGui configuration (Ui library)
ReGui:Init({
	Prefabs = InsertService:LoadLocalAsset(PrefabsId)
})
ReGui:DefineTheme("PetTheme", {
	WindowBg = Accent.Brown,
	TitleBarBg = Accent.DarkGreen,
	TitleBarBgActive = Accent.Green,
    ResizeGrab = Accent.DarkGreen,
    FrameBg = Accent.DarkGreen,
    FrameBgActive = Accent.Green,
	CollapsingHeaderBg = Accent.Green,
    ButtonsBg = Accent.Green,
    CheckMark = Accent.Green,
    SliderGrab = Accent.Green,
})

--// Pet Tier System
local PetTiers = {
    ["S Tier"] = {
        Color = Accent.Gold,
        Pets = {
            "Raccoon", "Lemon Lion", "Cockatrice", "Golden Goose", "Kitsune", 
            "Disco Bee", "T-Rex", "Corrupted Kitsune", "Raiju", "Lobster Thermidor", 
            "French Fry Ferret", "Apple Gazelle", "Spinosaurus", "Dragonfly", 
            "Butterfly", "Green Bean", "Blood Hedgehog", "Moon Cat", 
            "Spaghetti Sloth", "Kappa"
        }
    },
    ["A Tier"] = {
        Color = Accent.Silver,
        Pets = {
            "Tiger", "Sushi Bear", "Triceratops", "Pterodactyl", "Capybara", 
            "Pancake Mole", "Mole", "Mimic Octopus", "Queen Bee", "Griffin", 
            "Space Squirrel", "Tanchozuru", "Swan", "Barn Owl", "Luminous Sprite", 
            "Spriggan", "Hotdog Daschund", "Dairy Cow", "Gorilla Chef", "Moth", 
            "Brontosaurus", "Ostrich", "Seal"
        }
    },
    ["B Tier"] = {
        Color = Accent.Bronze,
        Pets = {
            "Junkbot", "Hyacinth Macaw", "Scarlet Macaw", "Red Fox", "Phoenix", 
            "Firefly", "Mizuchi", "Blood Owl", "Wisp", "Tree Frog", "Jackalope", 
            "Silver Dragonfly", "Hedgehog", "Tarantula Hawk", "Bear Bee", 
            "Night Owl", "Polar Bear", "Wasp", "Raptor", "Pachycephalosaurus", 
            "Red Panda", "Mochi Mouse", "Iguanodon", "Red Squirrel"
        }
    },
    ["C Tier"] = {
        Color = Color3.fromRGB(100, 100, 100),
        Pets = {
            "Snake", "Fennec Fox", "Grizzly Bear", "Fortune Squirrel", "Honey Bee", 
            "Petal Bee", "Bee", "Red Giant Ant", "Giant Ant", "Bald Eagle", "Owl", 
            "Praying Mantis", "Corrupted Kodama", "Kodama", "Squirrel", "Peacock", 
            "Marmot", "Toucan", "Bacon Pig", "Glimmering Sprite", "Axolotl", 
            "Meerkat", "Stegosaurus", "Seedling", "Badger", "Chicken Zombie", 
            "Starfish", "Salmon", "Chipmunk", "Blue Jay"
        }
    },
    ["D Tier"] = {
        Color = Color3.fromRGB(80, 80, 80),
        Pets = {
            "Ankylosaurus", "Golem", "Hamster", "Woodpecker", "Orangutan", "Pixie", 
            "Mallard", "Imp", "Nihonzaru", "Pack Bee", "Snail", "Shiba Inu", 
            "Ladybug", "Maneko Neko", "Silver Monkey", "Mandrake", "Sunny Side Chicken", 
            "Blood Kiwi", "Sugar Glider", "Cardinal", "Shroomie", "Bagel Bunny", 
            "Mouse", "Brown Mouse", "Golden Lab", "Monkey", "Flamingo", "Sea Turtle", 
            "Turtle", "Caterpillar", "Orange Tabby", "Cat", "Hummingbird", "Cow"
        }
    },
    ["E Tier"] = {
        Color = Color3.fromRGB(60, 60, 60),
        Pets = {
            "Lab", "Echo Frog", "Frog", "Kiwi", "Pig", "Tanuki", "Seagull", 
            "Sea Otter", "Black Bunny", "Bunny", "Rooster", "Chicken", "Elk", 
            "Spotted Deer", "Deer", "Panda", "Crab", "Drake", "Chimpanzee", 
            "Iguana", "Robin", "Parasaurolophus"
        }
    }
}

--// Globals
local SelectedPet, AutoSpawn, SpawnDelay, SelectedTier, SpawnCount, RandomSpawn, TierFilter

local function CreateWindow()
	local Window = ReGui:Window({
		Title = `{GameInfo.Name} | Pet Spawner | Depso`,
        Theme = "PetTheme",
		Size = UDim2.fromOffset(400, 300)
	})
	return Window
end

--// Pet spawning functions
local function SpawnPet(PetName: string)
    print("Attempting to spawn pet:", PetName)
    
    --// Method 1: Try various pet spawn remote events
    local PetSpawnREs = {
        "SpawnPet_RE", "PetSpawn_RE", "SpawnPet", "PetSpawn", 
        "SummonPet_RE", "SummonPet", "GetPet_RE", "GetPet",
        "BuyPet_RE", "BuyPet", "UnlockPet_RE", "UnlockPet"
    }
    
    for _, EventName in next, PetSpawnREs do
        local PetSpawnRE = GameEvents:FindFirstChild(EventName)
        if PetSpawnRE then
            print("Found remote event:", EventName)
            PetSpawnRE:FireServer(PetName)
            return true
        end
    end
    
    --// Method 2: Try to find pet shop or pet system in PlayerGui
    local PetShopNames = {"Pet_Shop", "PetShop", "PetShopGui", "Pet_Gui", "PetGui"}
    for _, ShopName in next, PetShopNames do
        local PetShop = PlayerGui:FindFirstChild(ShopName)
        if PetShop then
            print("Found pet shop:", ShopName)
            --// Try to find pet button
            local PetButton = PetShop:FindFirstChild(PetName, true)
            if PetButton and PetButton:IsA("GuiButton") then
                print("Found pet button for:", PetName)
                PetButton.Activated:Fire()
                return true
            end
            
            --// Try to find any button with pet name in text
            local function FindPetButtonInGui(Gui)
                for _, Child in next, Gui:GetDescendants() do
                    if Child:IsA("GuiButton") or Child:IsA("TextButton") then
                        local Text = Child:FindFirstChild("TextLabel") or Child:FindFirstChild("Text")
                        if Text and Text.Text:lower():find(PetName:lower()) then
                            print("Found pet button by text:", PetName)
                            Child.Activated:Fire()
                            return true
                        end
                    end
                end
                return false
            end
            
            if FindPetButtonInGui(PetShop) then
                return true
            end
        end
    end
    
    --// Method 3: Try workspace pet spawners
    local PetSpawnerNames = {"PetSpawners", "Pet_Spawners", "PetSpawn", "Pet_Spawn", "Pets"}
    for _, SpawnerName in next, PetSpawnerNames do
        local PetSpawners = workspace:FindFirstChild(SpawnerName)
        if PetSpawners then
            print("Found pet spawners:", SpawnerName)
            local Spawner = PetSpawners:FindFirstChild(PetName)
            if Spawner then
                local Prompt = Spawner:FindFirstChild("ProximityPrompt", true)
                if Prompt then
                    print("Found proximity prompt for:", PetName)
                    fireproximityprompt(Prompt)
                    return true
                end
            end
        end
    end
    
    --// Method 4: Try to find pet eggs or pet items
    local PetEggs = workspace:FindFirstChild("PetEggs") or workspace:FindFirstChild("Pet_Eggs")
    if PetEggs then
        print("Found pet eggs")
        local Egg = PetEggs:FindFirstChild(PetName)
        if Egg then
            local Prompt = Egg:FindFirstChild("ProximityPrompt", true)
            if Prompt then
                print("Found egg prompt for:", PetName)
                fireproximityprompt(Prompt)
                return true
            end
        end
    end
    
    --// Method 5: Try to find pet gacha or pet machine
    local PetGacha = workspace:FindFirstChild("PetGacha") or workspace:FindFirstChild("Pet_Gacha") or workspace:FindFirstChild("Gacha")
    if PetGacha then
        print("Found pet gacha")
        local Prompt = PetGacha:FindFirstChild("ProximityPrompt", true)
        if Prompt then
            print("Found gacha prompt")
            fireproximityprompt(Prompt)
            return true
        end
    end
    
    print("No pet spawning method found for:", PetName)
    return false
end

local function GetAvailablePets(): table
    local AvailablePets = {}
    
    --// Check each tier for available pets
    for TierName, TierData in next, PetTiers do
        for _, PetName in next, TierData.Pets do
            --// Check if pet is available (this would need to be implemented based on game mechanics)
            AvailablePets[PetName] = TierName
        end
    end
    
    return AvailablePets
end

local function GetPetsByTier(TierName: string): table
    local TierData = PetTiers[TierName]
    if not TierData then return {} end
    
    return TierData.Pets
end

local function GetRandomPetFromTier(TierName: string): string?
    local Pets = GetPetsByTier(TierName)
    if #Pets == 0 then return nil end
    
    return Pets[math.random(1, #Pets)]
end

local function SpawnRandomPet()
    local TierName = SelectedTier.Selected
    if not TierName or TierName == "" then return end
    
    local PetName = GetRandomPetFromTier(TierName)
    if PetName then
        SpawnPet(PetName)
    end
end

local function SpawnSelectedPet()
    local PetName = SelectedPet.Selected
    if not PetName or PetName == "" then return end
    
    SpawnPet(PetName)
end

local function SpawnMultiplePets()
    local PetName = SelectedPet.Selected
    local Count = SpawnCount.Value
    
    if not PetName or PetName == "" then return end
    
    for i = 1, Count do
        SpawnPet(PetName)
        wait(0.1) -- Small delay between spawns
    end
end

--// Auto spawn loop
local function AutoSpawnLoop()
    if not AutoSpawn.Value then return end
    
    if RandomSpawn.Value then
        SpawnRandomPet()
    else
        SpawnSelectedPet()
    end
    
    wait(SpawnDelay.Value)
end

local function MakeLoop(Toggle, Func)
	coroutine.wrap(function()
		while wait(.01) do
			if not Toggle.Value then continue end
			Func()
		end
	end)()
end

local function StartServices()
    --// Auto-Spawn
    MakeLoop(AutoSpawn, AutoSpawnLoop)
end

--// Create tier selection with colors
local function CreateTierSelection(Parent)
    local TierCombo = Parent:Combo({
        Label = "Tier",
        Selected = "",
        GetItems = function()
            local Tiers = {}
            for TierName, _ in next, PetTiers do
                table.insert(Tiers, TierName)
            end
            return Tiers
        end,
    })
    
    return TierCombo
end

--// Create pet selection based on tier
local function CreatePetSelection(Parent, TierCombo)
    local PetCombo = Parent:Combo({
        Label = "Pet",
        Selected = "",
        GetItems = function()
            local TierName = TierCombo.Selected
            if not TierName or TierName == "" then return {} end
            
            return GetPetsByTier(TierName)
        end,
    })
    
    return PetCombo
end

--// Window
local Window = CreateWindow()

--// Pet Spawner
local SpawnerNode = Window:TreeNode({Title="Pet Spawner 🐾"})

--// Tier Selection
SelectedTier = CreateTierSelection(SpawnerNode)

--// Pet Selection
SelectedPet = CreatePetSelection(SpawnerNode, SelectedTier)

--// Spawn Controls
SpawnerNode:Button({
    Text = "Spawn Selected Pet",
    Callback = SpawnSelectedPet,
})

SpawnerNode:Button({
    Text = "Spawn Random Pet",
    Callback = SpawnRandomPet,
})

SpawnCount = SpawnerNode:SliderInt({
    Label = "Spawn Count",
    Value = 1,
    Minimum = 1,
    Maximum = 10,
})

SpawnerNode:Button({
    Text = "Spawn Multiple",
    Callback = SpawnMultiplePets,
})

--// Auto Spawn
local AutoNode = Window:TreeNode({Title="Auto Spawn 🤖"})

AutoSpawn = AutoNode:Checkbox({
    Value = false,
    Label = "Enabled"
})

RandomSpawn = AutoNode:Checkbox({
    Value = false,
    Label = "Random Pet"
})

SpawnDelay = AutoNode:SliderInt({
    Label = "Spawn Delay (seconds)",
    Value = 5,
    Minimum = 1,
    Maximum = 60,
})

--// Pet Tier Display
local TierNode = Window:TreeNode({Title="Pet Tiers 📊"})

for TierName, TierData in next, PetTiers do
    local TierSection = TierNode:TreeNode({Title=TierName})
    
    --// Display pets in this tier
    for _, PetName in next, TierData.Pets do
        TierSection:Button({
            Text = PetName,
            Callback = function()
                SelectedPet.Selected = PetName
                SpawnPet(PetName)
            end,
        })
    end
end

--// Debug section - Add this to help identify game structure
local function DebugGameStructure()
    print("=== DEBUGGING GAME STRUCTURE ===")
    
    --// Check GameEvents
    print("GameEvents found:")
    for _, Child in next, GameEvents:GetChildren() do
        print("  -", Child.Name, "(" .. Child.ClassName .. ")")
    end
    
    --// Check PlayerGui for pet-related GUIs
    print("PlayerGui children:")
    for _, Child in next, PlayerGui:GetChildren() do
        if Child.Name:lower():find("pet") then
            print("  -", Child.Name, "(" .. Child.ClassName .. ")")
        end
    end
    
    --// Check workspace for pet-related objects
    print("Workspace children (pet-related):")
    for _, Child in next, workspace:GetChildren() do
        if Child.Name:lower():find("pet") or Child.Name:lower():find("gacha") or Child.Name:lower():find("egg") then
            print("  -", Child.Name, "(" .. Child.ClassName .. ")")
        end
    end
    
    print("=== END DEBUG ===")
end

--// Add debug button to UI
local DebugNode = Window:TreeNode({Title="Debug 🔍"})
DebugNode:Button({
    Text = "Debug Game Structure",
    Callback = DebugGameStructure,
})

--// Services
StartServices()

print("Pet Spawner loaded successfully!")
print("Select a tier and pet, then use the spawn buttons or enable auto-spawn!")
print("Use the Debug section to see what's available in the game!")
