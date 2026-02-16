local gameWork = game:GetService("Workspace"):FindFirstChild("Game")
local chests = gameWork and gameWork:FindFirstChild("Chests")
local fishes = gameWork and gameWork:FindFirstChild("Fish"):FindFirstChild("client")

local tierColors = {
    ["Tier 1"] = Color3.fromRGB(0, 255, 0),
    ["Tier 2"] = Color3.fromRGB(255, 255, 0),
    ["Tier 3"] = Color3.fromRGB(255, 0, 0)

    Cupid = Color3.fromRGB(255, 105, 180),   -- Pink
    Lonely = Color3.fromRGB(135, 206, 255)   -- Light Blue
}

getgenv().ESP_Table = getgenv().ESP_Table or {
    ChestConnections = {},
    FishConnections = {},
    CreatedUI = {}
}

local function clearESP(type)
    if type == "FISH" then
        for _, conn in pairs(getgenv().ESP_Table.FishConnections) do conn:Disconnect() end
        getgenv().ESP_Table.FishConnections = {}
    elseif type == "CHEST" then
        for _, conn in pairs(getgenv().ESP_Table.ChestConnections) do conn:Disconnect() end
        getgenv().ESP_Table.ChestConnections = {}
    end

    for obj, ui in pairs(getgenv().ESP_Table.CreatedUI) do
        if ui and ui.Parent and ui.Name == (type == "FISH" and "FISH_UI" or "CHEST_UI") then
            ui:Destroy()
            getgenv().ESP_Table.CreatedUI[obj] = nil
        end
    end
end

local function createESP(obj, text, subtext, color, uiName)
    if not obj or getgenv().ESP_Table.CreatedUI[obj] then return end

    local bbg = Instance.new("BillboardGui")
    bbg.Name = uiName
    bbg.Size = UDim2.new(0, 150, 0, 50)
    bbg.StudsOffset = Vector3.new(0, 3, 0)
    bbg.AlwaysOnTop = true
    bbg.Parent = obj

    local label = Instance.new("TextLabel")
    label.Parent = bbg
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.RichText = true
    label.Text = string.format("%s\n[%s]", text, subtext)
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.RobotoMono
    label.TextSize = 14

    getgenv().ESP_Table.CreatedUI[obj] = bbg
end

-- ✅ Modified function (only show mutated fish)
local function applyFishESP(fish)
    if not fish or not getgenv().toggleFish then return end
    
    local stat = fish:FindFirstChild("stats", true)
    if not stat then return end

    local name = stat:FindFirstChild("Fish") and stat.Fish.Text or fish.Name
    local mut = stat:FindFirstChild("Mutation") and stat.Mutation:FindFirstChildOfClass("TextLabel")
    local mutation = mut and mut.Text or nil

    -- Only show mutated fish (hide Normal and Shiny)
    if not mutation or mutation == "Normal" or mutation == "Shiny" then
        return
    end

    local coloredMutation = "<font color='#FFFF00'>" .. mutation .. "</font>"

    createESP(fish, name, coloredMutation, Color3.fromRGB(0, 255, 255), "FISH_UI")
end

clearESP("CHEST")
if getgenv().toggleChests and chests then
    for _, folder in pairs(chests:GetChildren()) do
        for _, chest in pairs(folder:GetChildren()) do
            createESP(chest, chest.Name, folder.Name, tierColors[folder.Name] or Color3.new(1,1,1), "CHEST_UI")
        end
    end
end

clearESP("FISH")
if getgenv().toggleFish and fishes then
    for _, fish in pairs(fishes:GetChildren()) do
        applyFishESP(fish)
    end

    local addConn = fishes.ChildAdded:Connect(function(child)
        task.wait(0.5)
        if getgenv().toggleFish then applyFishESP(child) end
    end)
    table.insert(getgenv().ESP_Table.FishConnections, addConn)

    local remConn = fishes.ChildRemoved:Connect(function(child)
        if getgenv().ESP_Table.CreatedUI[child] then
            getgenv().ESP_Table.CreatedUI[child]:Destroy()
            getgenv().ESP_Table.CreatedUI[child] = nil
        end
    end)
    table.insert(getgenv().ESP_Table.FishConnections, remConn)
end
