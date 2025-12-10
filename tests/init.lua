loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local SeraphUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ardho206/ui/refs/heads/main/Seraphin/Example.lua"))()

local svc      = {
    Players     = game:GetService("Players"),
    RunService  = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    RS          = game:GetService("ReplicatedStorage"),
    VIM         = game:GetService("VirtualInputManager"),
    PG          = game:GetService("Players").LocalPlayer.PlayerGui,
    Camera      = workspace.CurrentCamera,
    GuiService  = game:GetService("GuiService"),
    CoreGui     = game:GetService("CoreGui"),
    Tween       = game:GetService("TweenService"),
}

_G.httpRequest =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request
if not _G.httpRequest then
    return
end

local player               = svc.Players.LocalPlayer
local hrp                  = player.Character and player.Character:WaitForChild("HumanoidRootPart") or
    player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")

local BaseFolder           = "Seraphin/FishIt"
local PositionFile         = BaseFolder .. "/Position.json"

local gui                  = {
    MerchantRoot    = svc.PG.Merchant.Main.Background,
    ItemsFrame      = svc.PG.Merchant.Main.Background.Items.ScrollingFrame,
    RefreshMerchant = svc.PG.Merchant.Main.Background.RefreshLabel,
}

local mods                 = {
    Net                = svc.RS.Packages._Index["sleitnick_net@0.2.0"].net,
    Replion            = require(svc.RS.Packages.Replion),
    FishingController  = require(svc.RS.Controllers.FishingController),
    TradingController  = require(svc.RS.Controllers.ItemTradingController),
    ItemUtility        = require(svc.RS.Shared.ItemUtility),
    VendorUtility      = require(svc.RS.Shared.VendorUtility),
    PlayerStatsUtility = require(svc.RS.Shared.PlayerStatsUtility),
    Effects            = require(svc.RS.Shared.Effects),
}

local api                  = {
    Events = {
        RECutscene                    = mods.Net["RE/ReplicateCutscene"],
        REStop                        = mods.Net["RE/StopCutscene"],
        REFav                         = mods.Net["RE/FavoriteItem"],
        REFavChg                      = mods.Net["RE/FavoriteStateChanged"],
        REFishDone                    = mods.Net["RE/FishingCompleted"],
        REFishGot                     = mods.Net["RE/FishCaught"],
        RENotify                      = mods.Net["RE/TextNotification"],
        REEquip                       = mods.Net["RE/EquipToolFromHotbar"],
        REEquipItem                   = mods.Net["RE/EquipItem"],
        REAltar                       = mods.Net["RE/ActivateEnchantingAltar"],
        REAltar2                      = mods.Net["RE/ActivateSecondEnchantingAltar"],
        UpdateOxygen                  = mods.Net["URE/UpdateOxygen"],
        REPlayFishEffect              = mods.Net["RE/PlayFishingEffect"],
        RETextEffect                  = mods.Net["RE/ReplicateTextEffect"],
        REEvReward                    = mods.Net["RE/ClaimEventReward"],
        Totem                         = mods.Net["RE/SpawnTotem"],
        REObtainedNewFishNotification = mods.Net["RE/ObtainedNewFishNotification"],
        FishingMinigameChanged        = mods.Net["RE/FishingMinigameChanged"],
        FishingStopped                = mods.Net["RE/FishingStopped"],
    },
    Functions = {
        Trade       = mods.Net["RF/InitiateTrade"],
        BuyRod      = mods.Net["RF/PurchaseFishingRod"],
        BuyBait     = mods.Net["RF/PurchaseBait"],
        BuyWeather  = mods.Net["RF/PurchaseWeatherEvent"],
        ChargeRod   = mods.Net["RF/ChargeFishingRod"],
        StartMini   = mods.Net["RF/RequestFishingMinigameStarted"],
        UpdateRadar = mods.Net["RF/UpdateFishingRadar"],
        Cancel      = mods.Net["RF/CancelFishingInputs"],
        Dialogue    = mods.Net["RF/SpecialDialogueEvent"],
        Done        = mods.Net["RF/RequestFishingMinigameStarted"],
        AutoEnabled = mods.Net["RF/UpdateAutoFishingState"]
    }
}

local repl                 = {
    Data = mods.Replion.Client:WaitReplion("Data"),
    Items = svc.RS:WaitForChild("Items"),
    PlayerStat = require(svc.RS.Packages._Index:FindFirstChild("ytrev_replion@2.0.0-rc.3").replion)
}

local st                   = {
    autoInstant      = false,
    selectedEvents   = {},
    autoWeather      = false,
    autoSellEnabled  = false,
    autoFavEnabled   = false,
    autoEventActive  = false,
    canFish          = true,
    savedCFrame      = nil,
    sellMode         = "Delay",
    sellDelay        = 60,
    inputSellCount   = 50,
    selectedName     = {},
    selectedRarity   = {},
    selectedVariant  = {},
    rodDataList      = {},
    rodDisplayNames  = {},
    baitDataList     = {},
    baitDisplayNames = {},
    selectedRodId    = nil,
    selectedBaitId   = nil,
    rods             = {},
    baits            = {},
    weathers         = {},
    lcc              = 0,
    player           = player,
    stats            = player:WaitForChild("leaderstats"),
    caught           = player:WaitForChild("leaderstats"):WaitForChild("Caught"),
    char             = player.Character or player.CharacterAdded:Wait(),
    vim              = svc.VIM,
    cam              = svc.Camera,
    offs             = { ["Worm Hunt"] = 25 },
    curCF            = nil,
    origCF           = nil,
    flt              = false,
    con              = nil,
    Instant          = false,
    CancelWaitTime   = 3.0,
    ResetTimer       = 0.5,
    hasTriggeredBug  = false,
    lastFishTime     = 0,
    fishConnected    = false,
    lastCancelTime   = 0,
    hasFishingEffect = false,
    trade            = {
        selectedPlayer = nil,
        selectedItem   = nil,
        tradeAmount    = 1,
        targetCoins    = 0,
        trading        = false,
        awaiting       = false,
        lastResult     = nil,
        successCount   = 0,
        failCount      = 0,
        totalToTrade   = 0,
        sentCoins      = 0,
        successCoins   = 0,
        failCoins      = 0,
        totalReceived  = 0,
        currentGrouped = {},
        TotemActive    = false,
    },
    ignore           = {
        Cloudy = true,
        Day = true,
        ["Increased Luck"] = true,
        Mutated = true,
        Night = true,
        Snow = true,
        ["Sparkling Cove"] = true,
        Storm = true,
        Wind = true,
        UIListLayout = true,
        ["Admin - Shocked"] = true,
        ["Admin - Super Mutated"] = true,
        Radiant = true,
    },
    notifConnections = {},
    defaultHandlers  = {},
    disabledCons     = {},
    CEvent           = true
}

-- Helpers
_G.Celestial               = _G.Celestial or {}
_G.Celestial.DetectorCount = _G.Celestial.DetectorCount or 0
_G.Celestial.InstantCount  = _G.Celestial.InstantCount or 0

function getFishCount()
    local bag = st.player.PlayerGui:WaitForChild("Inventory")
        :WaitForChild("Main"):WaitForChild("Top")
        :WaitForChild("Options"):WaitForChild("Fish")
        :WaitForChild("Label"):WaitForChild("BagSize")
    return tonumber((bag.Text or "0/???"):match("(%d+)/")) or 0
end

local fishNames = {}

for _, module in ipairs(repl.Items:GetChildren()) do
    if module:IsA("ModuleScript") then
        local ok, data = pcall(require, module)
        if ok and data.Data and data.Data.Type == "Fish" then
            table.insert(fishNames, data.Data.Name)
        end
    end
end

table.sort(fishNames)

_G.TierFish = {
    [1] = " ",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret"
}

_G.WebhookRarities = _G.WebhookRarities or {}
_G.WebhookNames = _G.WebhookNames or {}

_G.Variant = {
    "Galaxy",
    "Corrupt",
    "Gemstone",
    "Ghost",
    "Lightning",
    "Fairy Dust",
    "Gold",
    "Midnight",
    "Radioactive",
    "Stone",
    "Holographic",
    "Albino"
}

function toSet(sel)
    local set = {}
    if type(sel) == "table" then
        for _, v in ipairs(sel) do set[v] = true end
        for k, v in pairs(sel) do if v then set[k] = true end end
    end
    return set
end

local favState = {}
api.Events.REFavChg.OnClientEvent:Connect(function(uuid, state)
    rawset(favState, uuid, state)
end)

function checkAndFavorite(item)
    if not st.autoFavEnabled then return end
    local info = mods.ItemUtility.GetItemDataFromItemType("Items", item.Id)
    if not info or info.Data.Type ~= "Fish" then return end

    local rarity       = _G.TierFish[info.Data.Tier]
    local name         = info.Data.Name
    local variant      = (item.Metadata and item.Metadata.VariantId) or "None"

    local nameMatch    = st.selectedName[name]
    local rarityMatch  = st.selectedRarity[rarity]
    local variantMatch = st.selectedVariant[variant]

    local isFav        = rawget(favState, item.UUID)
    if isFav == nil then isFav = item.Favorited end

    local shouldFav = false
    if next(st.selectedVariant) ~= nil and next(st.selectedName) ~= nil then
        shouldFav = nameMatch and variantMatch
    else
        shouldFav = nameMatch or rarityMatch
    end

    if shouldFav and not isFav then
        api.Events.REFav:FireServer(item.UUID)
        rawset(favState, item.UUID, true)
    end
end

function scanInventory()
    if not st.autoFavEnabled then return end
    for _, item in ipairs(repl.Data:GetExpect({ "Inventory", "Items" })) do
        checkAndFavorite(item)
    end
end

for _, item in ipairs(svc.RS.Items:GetChildren()) do
    if item:IsA("ModuleScript") and item.Name:match("Rod") then
        local ok, moduleData = pcall(require, item)
        if ok and typeof(moduleData) == "table" and moduleData.Data then
            local name = moduleData.Data.Name or "Unknown"
            local id = moduleData.Data.Id or "Unknown"
            local price = moduleData.Price or 0
            local cleanName = name:gsub("^!!!%s*", "")
            local display = cleanName .. " ($" .. price .. ")"
            local entry = { Name = cleanName, Id = id, Price = price, Display = display }
            st.rods[id] = entry
            st.rods[cleanName] = entry
            table.insert(st.rodDisplayNames, display)
        end
    end
end

BaitsFolder = svc.RS:WaitForChild("Baits")
for _, module in ipairs(BaitsFolder:GetChildren()) do
    if module:IsA("ModuleScript") then
        local ok, data = pcall(require, module)
        if ok and typeof(data) == "table" and data.Data then
            local name = data.Data.Name or "Unknown"
            local id = data.Data.Id or "Unknown"
            local price = data.Price or 0
            local display = name .. " ($" .. price .. ")"
            local entry = { Name = name, Id = id, Price = price, Display = display }
            st.baits[id] = entry
            st.baits[name] = entry
            table.insert(st.baitDisplayNames, display)
        end
    end
end

function _cleanName(display)
    if type(display) ~= "string" then
        return tostring(display)
    end
    return display:match("^(.-) %(") or display
end

function SavePosition(cf)
    local data = { cf:GetComponents() }
    writefile(PositionFile, svc.HttpService:JSONEncode(data))
end

function LoadPosition()
    if isfile(PositionFile) then
        local success, data = pcall(function()
            return svc.HttpService:JSONDecode(readfile(PositionFile))
        end)
        if success and typeof(data) == "table" then
            return CFrame.new(unpack(data))
        end
    end
    return nil
end

function TeleportLastPos(char)
    spawn(LPH_NO_VIRTUALIZE(function()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local last = LoadPosition()

        if last then
            task.wait(2)
            hrp.CFrame = last
            notify("Teleported to your last position...")
        end
    end))
end

player.CharacterAdded:Connect(TeleportLastPos)
if player.Character then
    TeleportLastPos(player.Character)
end

ignore = {
    Cloudy = true,
    Day = true,
    ["Increased Luck"] = true,
    Mutated = true,
    Night = true,
    Snow = true,
    ["Sparkling Cove"] = true,
    Storm = true,
    Wind = true,
    UIListLayout = true,
    ["Admin - Shocked"] = true,
    ["Admin - Super Mutated"] = true,
    Radiant = true
}

local function root(c)
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildWhichIsA("BasePart"))
end

local function setFreeze(c, freeze)
    if not c then return end
    for _, x in ipairs(c:GetDescendants()) do
        if x:IsA("BasePart") then
            x.Anchored = freeze
        end
    end
end

local function float(c, r, off)
    if st.flt and st.con then st.con:Disconnect() end
    st.flt = off or false
    if off then
        local F = c:FindFirstChild("FloatPart") or Instance.new("Part")
        F.Name, F.Size, F.Transparency, F.Anchored, F.CanCollide =
            "FloatPart", Vector3.new(3, .2, 3), 1, true, true
        F.Parent = c
        st.con = svc.RunService.Heartbeat:Connect(function()
            if c and r and F then
                F.CFrame = r.CFrame * CFrame.new(0, -3.1, 0)
            end
        end)
    else
        local p = c and c:FindFirstChild("FloatPart")
        if p then p:Destroy() end
    end
end

local function getEvents()
    local l, eg = {}, st.player:WaitForChild("PlayerGui"):FindFirstChild("Events")
    eg = eg and eg:FindFirstChild("Frame") and eg.Frame:FindFirstChild("Events")
    if eg then
        for _, e in ipairs(eg:GetChildren()) do
            local dn = (e:IsA("Frame") and e:FindFirstChild("DisplayName") and e.DisplayName.Text) or e.Name
            if typeof(dn) == "string" and dn ~= "" and not st.ignore[dn] then
                table.insert(l, (dn:gsub("^Admin %- ", "")))
            end
        end
    end
    return l
end

local function findTarget(n)
    if not n then return end
    if n == "Megalodon Hunt" then
        local menu = workspace:FindFirstChild("!!! MENU RINGS")
        if menu then
            for _, c in ipairs(menu:GetChildren()) do
                local m = c:FindFirstChild("Megalodon Hunt")
                local p = m and m:FindFirstChild("Megalodon Hunt")
                if p and p:IsA("BasePart") then return p end
            end
        end
        return
    end
    local props = { workspace:FindFirstChild("Props") }
    local menu = workspace:FindFirstChild("!!! MENU RINGS")
    if menu then
        for _, c in ipairs(menu:GetChildren()) do
            if c.Name:match("^Props") then table.insert(props, c) end
        end
    end
    for _, pr in ipairs(props) do
        for _, m in ipairs(pr:GetChildren()) do
            for _, o in ipairs(m:GetDescendants()) do
                if o:IsA("TextLabel") and o.Name == "DisplayName" then
                    local txt = o.ContentText ~= "" and o.ContentText or o.Text
                    if txt:lower() == n:lower() then
                        local anc = o:FindFirstAncestorOfClass("Model")
                        local p = (anc and anc:FindFirstChild("Part")) or m:FindFirstChild("Part")
                        if p and p:IsA("BasePart") then return p end
                    end
                end
            end
        end
    end
end

local function setState(state)
    if st.lastState ~= state then
        notify(state)
        st.lastState = state
    end
end

st.loop = function()
    while st.autoEventActive do
        local tar, nm
        if st.priorityEvent then
            local t = findTarget(st.priorityEvent)
            if t then tar, nm = t, st.priorityEvent end
        end
        if not tar and #st.selectedEvents > 0 then
            for _, n in ipairs(st.selectedEvents) do
                local t = findTarget(n)
                if t then
                    tar, nm = t, n
                    break
                end
            end
        end

        local r = root(st.player.Character)

        if tar and r then
            if not st.origCF then st.origCF = r.CFrame end
            if (r.Position - tar.Position).Magnitude > 40 then
                st.curCF = tar.CFrame + Vector3.new(0, st.offs[nm] or 7, 0)
                st.player.Character:PivotTo(st.curCF)
                float(st.player.Character, r, true)
                task.wait(1)
                setFreeze(st.player.Character, true)
                setState("Event! " .. nm)
            end
        elseif tar == nil and st.curCF and r then
            setFreeze(st.player.Character, false)
            float(st.player.Character, nil, false)
            if st.origCF then
                st.player.Character:PivotTo(st.origCF)
                setState("Event end → Back")
                st.origCF = nil
            end
            st.curCF = nil
        elseif not st.curCF then
            setState("Idle")
        end

        task.wait(0.2)
    end

    setFreeze(st.player.Character, false)
    float(st.player.Character, nil, false)
    if st.origCF and st.player.Character then
        st.player.Character:PivotTo(st.origCF)
        setState("Auto Event off")
    end
    st.origCF, st.curCF = nil, nil
end

st.player.CharacterAdded:Connect(function(nc)
    if st.autoEventActive then
        spawn(LPH_NO_VIRTUALIZE(function()
            local r = nc:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.3)
            if r then
                if st.curCF then
                    nc:PivotTo(st.curCF)
                    float(nc, r, true)
                    task.wait(0.5)
                    setFreeze(nc, true)
                    notify("Respawn → Back")
                elseif st.origCF then
                    nc:PivotTo(st.origCF)
                    setFreeze(nc, false)
                    float(nc, r, true)
                    notify("Back to farm")
                end
            end
        end))
    end
end)

local function getPlayerList()
    local list = {}
    for _, p in ipairs(svc.Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    return list
end

local locations = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270.86, 2.50, 2228.10),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136.10, 2.61, 2126.11),
    ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Kohana SPOT 1"] = Vector3.new(-367.77, 6.75, 521.91),
    ["Kohana SPOT 2"] = Vector3.new(-623.96, 19.25, 419.36),
    ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
    ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
    ["Tropical Grove Highground"] = Vector3.new(-2139, 53, 3624),
    ["Fisherman Island Underground"] = Vector3.new(-62, 3, 2846),
    ["Fisherman Island Mid"] = Vector3.new(33, 3, 2764),
    ["Fisherman Island Rift Left"] = Vector3.new(-26, 10, 2686),
    ["Fisherman Island Rift Right"] = Vector3.new(95, 10, 2684),
    ["Secred Temple"] = Vector3.new(1475, -22, -632),
    ["Ancient Jungle Outside"] = Vector3.new(1488, 8, -392),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Underground Cellar"] = Vector3.new(2136, -91, -699),
    ["Crystalline Pessage"] = Vector3.new(6052, -539, 4386),
    ["Ancient Ruin"] = Vector3.new(6073, -586, 4622),
    ["Classic Island"] = Vector3.new(1440.77368, 45.9999962, 2777.31909),
    ["Iron Cavern"] = Vector3.new(-8799.15527, -585.000061, 80.0701294),
    ["Iron Cafe"] = Vector3.new(-8627.36035, -547.500183, 179.2005),
 }

function disconnectNotifs()
    for _, ev in ipairs({
        mods.Net["RE/ObtainedNewFishNotification"],
        mods.Net["RE/TextNotification"],
        mods.Net["RE/ClaimNotification"]
    }) do
        for _, conn in ipairs(getconnections(ev.OnClientEvent)) do
            conn:Disconnect()
            table.insert(st.notifConnections, conn)
        end
    end
end

function reconnectNotifs()
    st.notifConnections = {}
end

local Window = SeraphUI:Window({
    Title = "Seraphin | Premium",
    Desc = "Seraphin on top!",
    Icon = 122018672226954,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.G,
        Size = UDim2.new(0, 640, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Icon = "122018672226954"
    }
})

function notify(msg)
    Window:Notify({
        Title = "Seraphin Notifier!",
        Desc = msg,
        Time = 4
    })
end

if Window then
    notify("Window loaded!")
end

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui")

--// INFO TAB
local Info = Window:Tab({ Title = "Info", Icon = "user-round" }) do
    Info:Section({Title = "Information Script"})

    Info:Label({
        Title = "Seraphin Information",
        Desc = "This script is still under development. Check for updates on our Discord!\n Please report to us if you find any bugs, errors, or patched!."
    })

    Info:Label({
        Title = "Seraphin Official Discord!",
        Desc = "Join Us!",
    })

    Info:Button({
        Title = "Copy Discord Link",
        Callback = function()
            local link = "https://discord.gg/getseraphin"
            if setclipboard then
                setclipboard(link)
            end
        end
    })
end

--// EXCLUSIVE TAB
local Exclusive = Window:Tab({ Title = "Exclusive", Icon = 107005941750079 }) do
    Exclusive:Section({Title = "Double Enchants"})

    Exclusive:Label({
        Title = "Reminder for you :3",
        Desc = "U must nearby in Altar for starting enchant!"
    })

    Exclusive:Button({
        Title = "Teleport to Second Altar",
        Callback = function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:PivotTo(CFrame.new(1481, 128, -592))
            end
        end
    })

    Data = repl.Data
    ItemUtility = mods.ItemUtility
    equipItemRemote = api.Events.REEquipItem
    equipToolRemote = api.Events.REEquip
    activateAltarRemote2 = api.Events.REAltar2
    local function getData(stoneId)
        local rod, ench, stones, uuids = "None", "None", 0, {}
        local equipped = Data:Get("EquippedItems") or {}
        local rods = Data:Get({ "Inventory", "Fishing Rods" }) or {}

        for _, u in pairs(equipped) do
            for _, r in ipairs(rods) do
                if r.UUID == u then
                    local d = ItemUtility:GetItemData(r.Id)
                    rod = (d and d.Data.Name) or r.ItemName or "None"
                    if r.Metadata and r.Metadata.EnchantId then
                        local e = ItemUtility:GetEnchantData(r.Metadata.EnchantId)
                        ench = (e and e.Data.Name) or "None"
                    end
                end
            end
        end

        for _, it in pairs(Data:GetExpect({ "Inventory", "Items" })) do
            local d = ItemUtility:GetItemData(it.Id)
            if d and d.Data.Type == "Enchant Stones" and it.Id == stoneId then
                stones += 1
                table.insert(uuids, it.UUID)
            end
        end
        return rod, ench, stones, uuids
    end

    Exclusive:Button({
        Title = "Start Double Enchant",
        Callback = function()
            spawn(LPH_NO_VIRTUALIZE(function()
                local rod, ench, stoneCount, uuids = getData(246)
                if rod == "None" or stoneCount <= 0 then return end

                local slot, start = nil, tick()
                while tick() - start < 5 do
                    for sl, id in pairs(Data:Get("EquippedItems") or {}) do
                        if id == uuids[1] then
                            slot = sl
                            break
                        end
                    end
                    if slot then break end
                    equipItemRemote:FireServer(uuids[1], "EnchantStones")
                    task.wait(0.3)
                end

                if not slot then return end

                equipToolRemote:FireServer(slot)
                task.wait(0.25)
                activateAltarRemote2:FireServer()
            end))
        end
    })

    Exclusive:Section({Title = "Auto Reconnect"})

    _G.AutoReconnect = false
    _G.ReconnectAttempts = 0

    function AutoReconnect()
        if not game:GetService("Players"):FindFirstChild(game:GetService("Players").LocalPlayer.Name) then
            while _G.ReconnectAttempts < 5 and _G.AutoReconnect do
                _G.ReconnectAttempts = _G.ReconnectAttempts + 1

                local success = pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                end)

                if success then
                    _G.ReconnectAttempts = 0
                    break
                else
                    wait(5)
                end
            end

            if _G.ReconnectAttempts >= 5 then
                _G.ReconnectAttempts = 0
            end
        end
    end

    Exclusive:Toggle({
        Title = "Auto Reconnect",
        Value = _G.AutoReconnect,
        Callback = function(value)
            _G.AutoReconnect = value
            _G.ReconnectAttempts = 0
        end
    })

    spawn(LPH_NO_VIRTUALIZE(function()
        while task.wait(1) do
            if _G.AutoReconnect then
                AutoReconnect()
            end
        end
    end))
end

--// MAIN TAB
local Main = Window:Tab({ Title = "Main", Icon = 9920770417 }) do
    Main:Section({Title = "Fishing"})

    Main:Toggle({
        Title = "Show Fishing Panel",
        Default = false,
        Callback = function(state)
            if state then
                local player = game:GetService("Players").LocalPlayer
                if game.CoreGui:FindFirstChild("ChloeX_FishingPanel") then
                    game.CoreGui:FindFirstChild("ChloeX_FishingPanel"):Destroy()
                end

                local gui = Instance.new("ScreenGui")
                gui.Name = "ChloeX_FishingPanel"
                gui.IgnoreGuiInset = true
                gui.ResetOnSpawn = false
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
                gui.Parent = game.CoreGui

                local card = Instance.new("Frame", gui)
                card.Size = UDim2.new(0, 400, 0, 210)
                card.AnchorPoint = Vector2.new(0.5, 0.5)
                card.Position = UDim2.new(0.5, 0, 0.5, 0)
                card.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
                card.BorderSizePixel = 0
                card.BackgroundTransparency = 0.05
                card.Active = true
                card.Draggable = true

                local outline = Instance.new("UIStroke", card)
                outline.Thickness = 2
                outline.Color = Color3.fromRGB(80, 150, 255)
                outline.Transparency = 0.35

                local corner = Instance.new("UICorner", card)
                corner.CornerRadius = UDim.new(0, 14)

                local title = Instance.new("TextLabel", card)
                title.Size = UDim2.new(1, -40, 0, 36)
                title.Position = UDim2.new(0, 45, 0, 5)
                title.BackgroundTransparency = 1
                title.Font = Enum.Font.GothamBold
                title.Text = "Seraphin FIshing Panel"
                title.TextSize = 22
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextXAlignment = Enum.TextXAlignment.Left

                local titleGradient = Instance.new("UIGradient", title)
                titleGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 220, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 120, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 220, 255))
                })
                titleGradient.Rotation = 45

                local invLabel = Instance.new("TextLabel", card)
                invLabel.Position = UDim2.new(0, 15, 0, 55)
                invLabel.Size = UDim2.new(1, -30, 0, 22)
                invLabel.Font = Enum.Font.GothamBold
                invLabel.TextSize = 18
                invLabel.BackgroundTransparency = 1
                invLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
                invLabel.Text = "INVENTORY COUNT:"

                local fishCount = Instance.new("TextLabel", card)
                fishCount.Position = UDim2.new(0, 15, 0, 75)
                fishCount.Size = UDim2.new(1, -30, 0, 22)
                fishCount.Font = Enum.Font.Gotham
                fishCount.TextSize = 18
                fishCount.BackgroundTransparency = 1
                fishCount.TextColor3 = Color3.fromRGB(255, 255, 255)
                fishCount.Text = "Main: 0/0"

                local totalLabel = Instance.new("TextLabel", card)
                totalLabel.Position = UDim2.new(0, 15, 0, 105)
                totalLabel.Size = UDim2.new(1, -30, 0, 22)
                totalLabel.Font = Enum.Font.GothamBold
                totalLabel.TextSize = 18
                totalLabel.BackgroundTransparency = 1
                totalLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
                totalLabel.Text = "TOTAL FISH CAUGHT:"

                local totalCaught = Instance.new("TextLabel", card)
                totalCaught.Position = UDim2.new(0, 15, 0, 125)
                totalCaught.Size = UDim2.new(1, -30, 0, 22)
                totalCaught.Font = Enum.Font.Gotham
                totalCaught.TextSize = 18
                totalCaught.BackgroundTransparency = 1
                totalCaught.TextColor3 = Color3.fromRGB(255, 255, 255)
                totalCaught.Text = "Value: 0"

                local status = Instance.new("TextLabel", card)
                status.Position = UDim2.new(0.5, 0, 0, 165)
                status.AnchorPoint = Vector2.new(0.5, 0)
                status.Size = UDim2.new(0.8, 0, 0, 30)
                status.Font = Enum.Font.GothamBold
                status.TextSize = 22
                status.Text = "FISHING NORMAL"
                status.BackgroundTransparency = 1
                status.TextColor3 = Color3.fromRGB(0, 255, 100)

                local lastCaught = player.leaderstats.Caught.Value
                local lastChange = tick()
                local stuck = false
                st.fishingPanelRunning = true

                spawn(LPH_NO_VIRTUALIZE(function()
                    while st.fishingPanelRunning and task.wait(1) do
                        local fishText = ""
                        pcall(function()
                            fishText = player.PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize.Text
                        end)
                        local caught = player.leaderstats.Caught.Value
                        fishCount.Text = "Main: " .. (fishText or "0/0")
                        totalCaught.Text = "Value: " .. tostring(caught)
                        if caught > lastCaught then
                            lastCaught = caught
                            lastChange = tick()
                            if stuck then
                                stuck = false
                                status.Text = "FISHING NORMAL"
                                status.TextColor3 = Color3.fromRGB(0, 255, 100)
                            end
                        end
                        if not stuck and tick() - lastChange >= 10 then
                            stuck = true
                            status.Text = "FISHING STUCK"
                            status.TextColor3 = Color3.fromRGB(255, 70, 70)
                        end
                    end
                end))
            else
                st.fishingPanelRunning = false
                local g = game.CoreGui:FindFirstChild("ChloeX_FishingPanel")
                if g then g:Destroy() end
            end
        end
    })

    Main:Textbox({
        Title = "Fishing Delay",
        Desc = "Delay complete fishing!",
        Value = tostring(_G.Delay),
        Callback = function(val)
            local num = tonumber(val)
            if num and num > 0 then
                _G.Delay = num
                print("Fishing Delay set to:", _G.Delay)

                spawn(LPH_NO_VIRTUALIZE(function()
                    print("Started")
                    while true do
                        if mods.FishingController and mods.FishingController._autoLoop then
                            local fishing = mods.FishingController
                            if fishing:GetCurrentGUID() then
                                print("Waiting", _G.Delay)
                                task.wait(_G.Delay)

                                repeat
                                    local ok, err = pcall(function()
                                        api.Events.REFishDone:FireServer()
                                    end)
                                    if ok then
                                        print("Successfully")
                                    else
                                        warn("Failed to Fire REFishDone:", err)
                                    end
                                    task.wait(0.05)
                                until not fishing:GetCurrentGUID() or not fishing._autoLoop

                                print("loop ended")
                            end
                        end
                        task.wait(0.1)
                    end
                end))
            else
                warn("Invalid fishing delay input")
            end
        end
    })

    shakeDelay = 0
    Main:Textbox({
        Title = "Shake Delay",
        Value = tostring(shakeDelay),
        Callback = function(val)
            local num = tonumber(val)
            if num and num >= 0 then
                shakeDelay = num
            end
        end
    })

    userId = tostring(svc.Players.LocalPlayer.UserId)
    CosmeticFolder = workspace:WaitForChild("CosmeticFolder")

    Main:Dropdown({
        Title = "Fishing Mode",
        List = { "Auto Perfect", "Legit" },
        Value = "Auto Perfect",
        Multi = false,
        Callback = function(v)
            selectedMode = v
        end
    })

    function tryCast()
        local gui = svc.PG
        local cam = svc.Camera
        local vim = svc.VIM
        local player = game:GetService("Players").LocalPlayer
        local pos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local lastGUID

        while mods.FishingController._autoLoop do
            if mods.FishingController:GetCurrentGUID() then
                task.wait(0.05)
            else
                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                task.wait(0.05)
                local bar = gui:WaitForChild("Charge")
                    :WaitForChild("Main")
                    :WaitForChild("CanvasGroup")
                    :WaitForChild("Bar")

                local tCharge = tick()
                while bar:IsDescendantOf(gui) and bar.Size.Y.Scale < 0.95 do
                    task.wait(0.001)
                    if tick() - tCharge > 1 then
                        break
                    end
                end

                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)

                local tWait = tick()
                local gotShake = false
                while tick() - tWait < 3 do
                    local guid = mods.FishingController:GetCurrentGUID()
                    if guid and guid ~= lastGUID then
                        gotShake = true
                        print("[DEBUG] Shake detected! GUID:", guid)
                        lastGUID = guid
                        break
                    end
                    task.wait(0.05)
                end

                if gotShake then
                    local prevCaught = player.leaderstats and player.leaderstats.Caught.Value or 0
                    local tCatch = tick()
                    while tick() - tCatch < 8 do
                        if (player.leaderstats and player.leaderstats.Caught.Value > prevCaught)
                            or not mods.FishingController:GetCurrentGUID() then
                            break
                        end
                        task.wait(0.1)
                    end
                    while mods.FishingController:GetCurrentGUID() do
                        task.wait(0.05)
                    end
                    task.wait(1.3)
                end
            end
            task.wait(0.05)
        end
    end

    Main:Toggle({
        Title = "Legit Fishing",
        Default = false,
        Callback = function(state)
            local fishing = mods.FishingController
            local folder = CosmeticFolder
            local id = userId
            local running = state

            fishing._autoLoop = state

            if state then
                if selectedMode == "Auto Perfect" then
                    spawn(LPH_NO_VIRTUALIZE(function()
                        while running and fishing._autoLoop do
                            if not folder:FindFirstChild(id) then
                                repeat
                                    tryCast()
                                    task.wait(0.1)
                                until folder:FindFirstChild(id) or not fishing._autoLoop
                            end
                            while folder:FindFirstChild(id) and fishing._autoLoop do
                                if fishing:GetCurrentGUID() then
                                    local start = tick()
                                    while fishing:GetCurrentGUID() and fishing._autoLoop do
                                        pcall(function()
                                            fishing:RequestFishingMinigameClick()
                                        end)
                                        if tick() - start >= (_G.Delay) then
                                            task.wait(_G.Delay)
                                            repeat
                                                pcall(function()
                                                    api.Events.REFishDone:FireServer()
                                                end)
                                                task.wait(0.05)
                                            until not fishing:GetCurrentGUID() or not fishing._autoLoop
                                            break
                                        end
                                        task.wait()
                                    end
                                end
                                task.wait(0.2)
                            end
                            repeat task.wait(0.1) until not folder:FindFirstChild(id) or not fishing._autoLoop
                            if fishing._autoLoop then
                                task.wait(0.2)
                                tryCast()
                            end
                            task.wait(0.2)
                        end
                    end))
                elseif selectedMode == "Legit" then
                    if not fishing._oldGetPower then
                        fishing._oldGetPower = fishing._getPower
                    end
                    fishing._getPower = function(...)
                        return 0.999
                    end
                    spawn(LPH_NO_VIRTUALIZE(function()
                        while running and fishing._autoLoop do
                            if _G.ShakeEnabled and fishing:GetCurrentGUID() then
                                local start = tick()
                                while fishing:GetCurrentGUID() and fishing._autoLoop and _G.ShakeEnabled do
                                    pcall(function()
                                        fishing:RequestFishingMinigameClick()
                                    end)
                                    if tick() - start >= (_G.Delay or 1) then
                                        repeat
                                            pcall(function()
                                                api.Events.REFishDone:FireServer()
                                            end)
                                            task.wait(0.1)
                                        until not fishing:GetCurrentGUID() or not fishing._autoLoop or not _G.ShakeEnabled
                                        break
                                    end
                                    task.wait(0.1)
                                end
                            elseif not fishing:GetCurrentGUID() then
                                local center = Vector2.new(svc.Camera.ViewportSize.X / 2, svc.Camera.ViewportSize.Y / 2)
                                pcall(function()
                                    fishing:RequestChargeFishingRod(center, true)
                                end)
                                task.wait(0.25)
                            end
                            task.wait(0.05)
                        end
                    end))
                end
            else
                fishing._autoLoop = false
                if fishing._oldGetPower then
                    fishing._getPower = fishing._oldGetPower
                    fishing._oldGetPower = nil
                end
            end
        end
    })

    Main:Toggle({
        Title = "Auto Shake",
        Default = false,
        Callback = function(state)
            mods._autoShake = state
            local clickEffect = svc.PG:FindFirstChild("!!! Click Effect")

            if state then
                if clickEffect then
                    clickEffect.Enabled = false
                end

                spawn(LPH_NO_VIRTUALIZE(function()
                    while mods._autoShake do
                        pcall(function()
                            mods.FishingController:RequestFishingMinigameClick()
                        end)
                        task.wait(shakeDelay)
                    end
                end))
            else
                if clickEffect then
                    clickEffect.Enabled = true
                end
            end
        end
    })

    Main:Textbox({
        Title = "Delay Complete Instant",
        Value = tostring(_G.DelayComplete),
        Callback = function(val)
            local num = tonumber(val)
            if num and num >= 0 then
                _G.DelayComplete = num
            end
        end
    })

    Main:Toggle({
        Title = "Instant Fishing",
        Desc = "Auto instantly catch fish (Slowed)",
        Default = false,
        Callback = function(s)
            st.autoInstant = s
            if s then
                _G.Celestial.InstantCount = getFishCount()
                spawn(LPH_NO_VIRTUALIZE(function()
                    while st.autoInstant do
                        if st.canFish then
                            st.canFish = false
                            local ok, _, serverTime = pcall(function()
                                return api.Functions.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
                            end)
                            if ok and typeof(serverTime) == "number" then
                                local yPos = -1.233184814453125
                                local power = 0.999
                                task.wait(0.1)
                                pcall(function()
                                    api.Functions.StartMini:InvokeServer(yPos, power, serverTime)
                                end)
                                local started = tick()
                                repeat
                                    task.wait(0.05)
                                until (_G.FishMiniData and _G.FishMiniData.LastShift) or tick() - started > 1
                                task.wait(_G.DelayComplete)
                                pcall(function()
                                    api.Events.REFishDone:FireServer()
                                end)
                                local startCount = getFishCount()
                                local waitStart = tick()
                                repeat
                                    task.wait(0.05)
                                until getFishCount() > startCount or tick() - waitStart > 1
                            end
                            st.canFish = true
                        end
                        task.wait(0.05)
                    end
                end))
            end
        end
    })

    if MiniEvent then
        if _G._MiniEventConn then
            _G._MiniEventConn:Disconnect()
        end
        _G._MiniEventConn = MiniEvent.OnClientEvent:Connect(function(state, data)
            if state and data then
                _G.FishMiniData = data
            end
        end)
    end

    function Fastest()
        task.spawn(function()
            pcall(function() api.Functions.Cancel:InvokeServer() end)
            _G.FishMiniData = nil
            task.wait()
            local now = workspace:GetServerTimeNow()
            pcall(function() api.Functions.ChargeRod:InvokeServer(now) end)
            pcall(function() api.Functions.StartMini:InvokeServer(-1, 0.999) end)
            task.wait(_G.FishingDelay)
            pcall(function() api.Events.REFishDone:FireServer() end)
            task.delay(1.25, function()
                if _G.FBlatant then
                    pcall(function()
                        api.Functions.Cancel:InvokeServer()
                    end)
                end
            end)
        end)
    end

    Main:Textbox({
        Title = "Delay Bait",
        Value = tostring(_G.Reel),
        Default = "1.9",
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then _G.Reel = n end
            SaveConfig()
        end
    })

    Main:Textbox({
        Title = "Delay Reel",
        Value = tostring(_G.FishingDelay),
        Default = "1.1",
        Callback = function(v)
            local n = tonumber(v)
            if n and n > 0 then _G.FishingDelay = n end
            SaveConfig()
        end
    })

    Main:Toggle({
        Title = "Fast Reel",
        Default = _G.FBlatant,
        Callback = function(s)
            _G.FBlatant = s
            api.Functions.AutoEnabled:InvokeServer(s)
            if not s then
                pcall(function() api.Functions.Cancel:InvokeServer() end)
                _G.FishMiniData = nil
                return
            end
            task.spawn(function()
            while _G.FBlatant do
                Fastest()
                task.wait(_G.Reel)
            end
        end)
        end
    })

    Main:Button({
        Title = "Recovery Fishing",
        Callback = function()
            pcall(function()
                api.Functions.Cancel:InvokeServer()
            end)
        end
    })

    Main:Toggle({
        Title = "No Fishing Animations",
        Default = false,
        Callback = function(state)
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local animator = hum:FindFirstChildOfClass("Animator")
            if not animator then return end

            if state then
                st.stopAnimHookEnabled = true
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
                st.stopAnimConn = animator.AnimationPlayed:Connect(function(track)
                    if st.stopAnimHookEnabled then
                        task.defer(function()
                            pcall(function()
                                track:Stop(0)
                            end)
                        end)
                    end
                end)
            else
                st.stopAnimHookEnabled = false
                if st.stopAnimConn then
                    st.stopAnimConn:Disconnect()
                    st.stopAnimConn = nil
                end
            end
        end
    })

    Main:Toggle({
        Title = "Auto Equip Rod",
        Desc = "Automatically equip your fishing rod",
        Default = false,
        Callback = function(state)
            st.autoEquipRod = state

            local function hasRodEquipped()
                local equippedId = repl.Data:Get("EquippedId")
                if not equippedId then return false end
                local item = mods.PlayerStatsUtility:GetItemFromInventory(repl.Data, function(it)
                    return it.UUID == equippedId
                end)
                if not item then return false end
                local data = mods.ItemUtility:GetItemData(item.Id)
                return data and data.Data.Type == "Fishing Rods"
            end

            local function equipRod()
                if not hasRodEquipped() then
                    api.Events.REEquip:FireServer(1)
                end
            end

            task.spawn(function()
                while st.autoEquipRod do
                    equipRod()
                    task.wait(1)
                end
            end)
        end
    })

    Main:Toggle({
        Title = "Freeze Player",
        Default = false,
        Callback = function(state)
            st.frozen = state
            local char = st.player.Character

            local function hasRodEquipped()
                local equippedId = repl.Data:Get("EquippedId")
                if not equippedId then return false end
                local item = mods.PlayerStatsUtility:GetItemFromInventory(repl.Data, function(it)
                    return it.UUID == equippedId
                end)
                if not item then return false end
                local data = mods.ItemUtility:GetItemData(item.Id)
                return data and data.Data.Type == "Fishing Rods"
            end

            local function equipRod()
                if not hasRodEquipped() then
                    api.Events.REEquip:FireServer(1)
                    task.wait(0.5)
                end
            end

            local function setFreeze(c, freeze)
                if not c then return end
                for _, x in ipairs(c:GetDescendants()) do
                    if x:IsA("BasePart") then
                        x.Anchored = freeze
                    end
                end
            end

            local function apply(c)
                if st.frozen then
                    equipRod()
                    if hasRodEquipped() then
                        setFreeze(c, true)
                    end
                else
                    setFreeze(c, false)
                end
            end

            apply(char)

            st.player.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                apply(newChar)
            end)
        end
    })

    Main:Section({Title = "Sell Item"})

    Main:Dropdown({
        Title = "Select Sell Mode",
        List = { "Delay", "Count" },
        Value = "Delay",
        Callback = function(o)
            st.sellMode = o
            SaveConfig()
        end
    })

    Main:Textbox({
        Title = "Set Value",
        Desc = "Delay = Minutes | Count = Backpack Count",
        Value = "1",
        Placeholder = "Input Here",
        Callback = function(v)
            local n = tonumber(v) or 1
            if st.sellMode == "Delay" then
                st.sellDelay = n * 60
            else
                st.inputSellCount = n
            end
            SaveConfig()
        end
    })

    Main:Toggle({
        Title = "Start Selling",
        Default = false,
        Callback = function(s)
            st.autoSellEnabled = s
            if s then
                task.spawn(function()
                    local RFSellAllItems = mods.Net["RF/SellAllItems"]
                    while st.autoSellEnabled do
                        local bagLabel = player:WaitForChild("PlayerGui")
                            :WaitForChild("Inventory")
                            .Main.Top.Options.Fish.Label:FindFirstChild("BagSize")

                        local cur, max = 0, 0
                        if bagLabel and bagLabel:IsA("TextLabel") then
                            local txt = bagLabel.Text or ""
                            local c, m = txt:match("(%d+)%s*/%s*(%d+)")
                            cur, max = tonumber(c) or 0, tonumber(m) or 0
                        end

                        if st.sellMode == "Delay" then
                            task.wait(st.sellDelay)
                            RFSellAllItems:InvokeServer()

                        elseif st.sellMode == "Count" then
                            local target = tonumber(st.inputSellCount) or max
                            if cur >= target then
                                RFSellAllItems:InvokeServer()
                            end
                            task.wait()
                        end
                    end
                end)
            end
        end
    })

    Main:Section({Title = "Favorite"})

    Main:Dropdown({
        Title = "Name",
        Desc = "Favorite By Name Fish (Recommended)",
        List = #fishNames > 0 and fishNames or { "No Fish Found" },
        Multi = true,
        Callback = function(o)
            st.selectedName = toSet(o)
        end
    })

    Main:Dropdown({
        Title = "Rarity",
        List = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
        Multi = true,
        Callback = function(o)
            st.selectedRarity = toSet(o)
        end
    })

    Main:Dropdown({
        Title = "Variant",
        List = _G.Variant,
        Multi = true,
        Callback = function(o)
            if next(st.selectedName) ~= nil then
                st.selectedVariant = toSet(o)
            else
                st.selectedVariant = {}
                warn("Pilih Name dulu sebelum memilih Variant.")
            end
        end
    })

    Main:Toggle({
        Title = "Auto Favorite",
        Default = false,
        Callback = function(s)
            st.autoFavEnabled = s
            if s then
                scanInventory()
                repl.Data:OnChange({ "Inventory", "Items" }, scanInventory)
            end
        end
    })

    Main:Button({
        Title    = "Unfavorite Fish",
        Callback = function()
            for _, item in ipairs(repl.Data:GetExpect({ "Inventory", "Items" })) do
                local isFav = rawget(favState, item.UUID)
                if isFav == nil then
                    isFav = item.Favorited
                end
                if isFav then
                    api.Events.REFav:FireServer(item.UUID)
                    rawset(favState, item.UUID, false)
                end
            end
        end
    })
end

--// MENU TAB
local Menu = Window:Tab({ Title = "Menu", Icon = 115745994221305 }) do
    Menu:Section({Title = "Event"})

    Menu:Dropdown({
        Title = "Priority Event",
        List = getEvents() or {},
        Multi = false,
        Callback = function(v)
            st.priorityEvent = v
        end
    })

    Menu:Dropdown({
        Title = "Select Event",
        List = getEvents() or {},
        Multi = true,
        Callback = function(o)
            st.selectedEvents = {}
            for _, v in pairs(o) do
                table.insert(st.selectedEvents, v)
            end
            st.curCF = nil
            if st.autoEventActive and (#st.selectedEvents > 0 or st.priorityEvent) then
                task.spawn(st.loop)
            end
        end
    })

    Menu:Toggle({
        Title = "Auto Event",
        Default = false,
        Callback = function(s)
            st.autoEventActive = s
            if s and (#st.selectedEvents > 0 or st.priorityEvent) then
                st.origCF = st.origCF or root(player.Character).CFrame
                task.spawn(st.loop)
            else
                if st.origCF then
                    player.Character:PivotTo(st.origCF)
                    notify("Auto Event Off")
                end
                st.origCF, st.curCF = nil, nil
            end
        end
    })

    Menu:Section({Title = "Coin"})

    CoinParagraph = Menu:Label({
        Title = "Coin Farm Panel",
        Desc = [[
Current : 0
Target : 0
Progress : 0%
    ]]
    })

    CoinTarget, CoinBase = 0, 0
    CoinSpotOptions = {
        ["Kohana Volcano"] = Vector3.new(-552, 19, 183),
        ["Tropical Grove"] = Vector3.new(-2084, 3, 3700)
    }

    Menu:Dropdown({
        Title = "Coin Location",
        List = { "Kohana Volcano", "Tropical Grove" },
        Multi = false,
        Callback = function(val)
            SelectedCoinSpot = CoinSpotOptions[val]
        end
    })

    Menu:Textbox({
        Title = "Target Coin",
        Placeholder = "Enter coin target...",
        Callback = function(val)
            local n = tonumber(val)
            if n then CoinTarget = n end
        end
    })

    Menu:Toggle({
        Title = "Enable Coin Farm",
        Default = false,
        Callback = function(state)
            _G.CoinFarm = state
            if state then
                repeat task.wait() until repl.Data
                local Data = repl.Data
                CoinBase = Data:Get({ "Coins" }) or 0
            end
        end
    })

    Menu:Section({Title = "Enchant Stone"})

    EnchantParagraph = Menu:Label({
        Title = "Enchant Stone Farm Panel",
        Desc = [[
Current : 0
Target : 0
Progress : 0%
    ]]
    })
    EnchantTarget, EnchantBase = 0, 0
    EnchantSpotOptions = {
        ["Tropical Grove"] = Vector3.new(-2084, 3, 3700),
        ["Esoteric Depths"] = Vector3.new(3272, -1302, 1404)
    }
    Menu:Dropdown({
        Title = "Enchant Stone Location",
        List = { "Tropical Grove", "Esoteric Depths" },
        Multi = false,
        Callback = function(val)
            SelectedEnchantSpot = EnchantSpotOptions[val]
        end
    })
    Menu:Textbox({
        Title = "Target Enchant Stone",
        Placeholder = "Enter enchant stone target...",
        Callback = function(val)
            local n = tonumber(val)
            if n then EnchantTarget = n end
        end
    })
    Menu:Toggle({
        Title = "Enable Enchant Farm",
        Default = false,
        Callback = function(state)
            _G.EnchantFarm = state
            if state then
                local Data = repl.Data
                local inv = Data:Get({ "Inventory", "Items" }) or {}
                local amt = 0
                for _, v in ipairs(inv) do
                    if v.Id == 10 then
                        amt += v.Amount or 1
                    end
                end
                EnchantBase = amt
            end
        end
    })

    task.spawn(function()
        local switching = false
        local startPos = nil
        local ThresholdTotalBase = 0
        while task.wait(1) do
            local Data = repl.Data
            if Data then
                local plr = svc.Players.LocalPlayer
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and not startPos then startPos = hrp.CFrame end

                if _G.ThresholdFarm then
                    local stats = Data:Get({ "Statistics" }) or {}
                    local fish = stats.FishCaught or 0
                    if ThresholdTotalBase == 0 then ThresholdTotalBase = ThresholdBase end
                    local diff = fish - ThresholdBase
                    local progress = (ThresholdTarget > 0) and math.min((diff / ThresholdTarget) * 100, 100) or 0
                    ThresholdParagraph:SetDesc(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", diff,
                        ThresholdTarget, progress))

                    if hrp and ThresholdPos1 ~= "" and ThresholdPos2 ~= "" and not switching then
                        switching = true
                        task.spawn(function()
                            local pos1 = Vector3.new(unpack(string.split(ThresholdPos1, ",")))
                            local pos2 = Vector3.new(unpack(string.split(ThresholdPos2, ",")))
                            local baseFish = fish
                            local target1 = baseFish + ThresholdTarget
                            while _G.ThresholdFarm do
                                repeat
                                    task.wait(1)
                                    local s = Data:Get({ "Statistics" }) or {}
                                    fish = s.FishCaught or 0
                                until fish >= target1 or not _G.ThresholdFarm
                                if not _G.ThresholdFarm then break end
                                hrp.CFrame = CFrame.new(pos2 + Vector3.new(0, 3, 0))
                                ThresholdBase = fish
                                baseFish = fish
                                target1 = baseFish + ThresholdTarget
                                repeat
                                    task.wait(1)
                                    local s = Data:Get({ "Statistics" }) or {}
                                    fish = s.FishCaught or 0
                                until fish >= target1 or not _G.ThresholdFarm
                                if not _G.ThresholdFarm then break end
                                hrp.CFrame = CFrame.new(pos1 + Vector3.new(0, 3, 0))
                                ThresholdBase = fish
                                baseFish = fish
                                target1 = baseFish + ThresholdTarget
                            end
                            switching = false
                        end)
                    end
                end

                if _G.CoinFarm then
                    local coins = Data:Get({ "Coins" }) or 0
                    local diff = coins - CoinBase
                    local progress = (CoinTarget > 0) and math.min((diff / CoinTarget) * 100, 100) or 0
                    CoinParagraph:SetDesc(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", diff, CoinTarget,
                        progress))
                    if SelectedCoinSpot and hrp then
                        if diff < CoinTarget then
                            if (hrp.Position - SelectedCoinSpot).Magnitude > 10 then
                                hrp.CFrame = CFrame.new(SelectedCoinSpot + Vector3.new(0, 3, 0))
                            end
                        else
                            if startPos then
                                hrp.CFrame = startPos
                            end
                            _G.CoinFarm = false
                        end
                    end
                end

                if _G.EnchantFarm then
                    local inv = Data:Get({ "Inventory", "Items" }) or {}
                    local amt = 0
                    for _, v in ipairs(inv) do
                        if v.Id == 10 then
                            amt += v.Amount or 1
                        end
                    end
                    local diff = amt - EnchantBase
                    local progress = (EnchantTarget > 0) and math.min((diff / EnchantTarget) * 100, 100) or 0
                    EnchantParagraph:SetDesc(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", diff,
                        EnchantTarget, progress))
                    if SelectedEnchantSpot and hrp then
                        if diff < EnchantTarget then
                            if (hrp.Position - SelectedEnchantSpot).Magnitude > 10 then
                                hrp.CFrame = CFrame.new(SelectedEnchantSpot + Vector3.new(0, 3, 0))
                            end
                        else
                            if startPos then
                                hrp.CFrame = startPos
                            end
                            _G.EnchantFarm = false
                        end
                    end
                end
            else
                task.wait(1)
            end
        end
    end)

    Menu:Section({Title = "Auto Enchant"})

    local enchantNames = {
        "Big Hunter 1", "Cursed 1", "Empowered 1", "Glistening 1",
        "Gold Digger 1", "Leprechaun 1", "Leprechaun 2",
        "Mutation Hunter 1", "Mutation Hunter 2", "Prismatic 1",
        "Reeler 1", "Stargazer 1", "Stormhunter 1", "XPerienced 1"
    }

    local enchantIdMap = {
        ["Big Hunter 1"] = 3,
        ["Cursed 1"] = 12,
        ["Empowered 1"] = 9,
        ["Glistening 1"] = 1,
        ["Gold Digger 1"] = 4,
        ["Leprechaun 1"] = 5,
        ["Leprechaun 2"] = 6,
        ["Mutation Hunter 1"] = 7,
        ["Mutation Hunter 2"] = 14,
        ["Prismatic 1"] = 13,
        ["Reeler 1"] = 2,
        ["Stargazer 1"] = 8,
        ["Stormhunter 1"] = 11,
        ["XPerienced 1"] = 10
    }

    local equipItemRemote = api.Events.REEquipItem
    local equipToolRemote = api.Events.REEquip
    local activateAltarRemote = api.Events.REAltar

    local Data = repl.Data

    local function countDisplayImageButtons()
        local ok, backpackGui = pcall(function()
            return player.PlayerGui.Backpack
        end)
        if not ok or not backpackGui then return 0 end
        local display = backpackGui:FindFirstChild("Display")
        if not display then return 0 end
        local count = 0
        for _, child in ipairs(display:GetChildren()) do
            if child:IsA("ImageButton") then
                count += 1
            end
        end
        return count
    end

    local function findEnchantStones()
        if not Data then return {} end
        local inv = Data:GetExpect({ "Inventory", "Items" })
        if not inv then return {} end
        local stones = {}
        for _, item in pairs(inv) do
            local def = mods.ItemUtility:GetItemData(item.Id)
            if def and def.Data and def.Data.Type == "Enchant Stones" then
                table.insert(stones, { UUID = item.UUID, Quantity = item.Quantity or 1 })
            end
        end
        return stones
    end

    local function getEquippedRodName()
        local equipped = Data:Get("EquippedItems") or {}
        local rods = Data:GetExpect({ "Inventory", "Fishing Rods" }) or {}
        for _, uuid in pairs(equipped) do
            for _, rod in ipairs(rods) do
                if rod.UUID == uuid then
                    local d = mods.ItemUtility:GetItemData(rod.Id)
                    if d and d.Data and d.Data.Name then
                        return d.Data.Name
                    elseif rod.ItemName then
                        return rod.ItemName
                    end
                end
            end
        end
        return "None"
    end

    local function getCurrentRodEnchant()
        local equipped = Data:Get("EquippedItems") or {}
        local rods = Data:GetExpect({ "Inventory", "Fishing Rods" }) or {}
        for _, uuid in pairs(equipped) do
            for _, rod in ipairs(rods) do
                if rod.UUID == uuid and rod.Metadata and rod.Metadata.EnchantId then
                    return rod.Metadata.EnchantId
                end
            end
        end
        return nil
    end

    local Paragraph = Menu:Label({
        Title = "Enchant Panel",
        Desc = "Loading...",
    })

    spawn(LPH_NO_VIRTUALIZE(function()
        while task.wait(1) do
            local stones = findEnchantStones()
            local total = 0
            for _, s in ipairs(stones) do total += s.Quantity end
            local rodName = getEquippedRodName()
            local currentEnchantId = getCurrentRodEnchant()
            local currentEnchantName = "None"
            for name, id in pairs(enchantIdMap) do
                if id == currentEnchantId then
                    currentEnchantName = name
                    break
                end
            end
            Paragraph:SetDesc(
                "Rod Active <font color='rgb(0,191,255)'>= " .. rodName .. "</font>\n" ..
                "Enchant Now <font color='rgb(200,0,255)'>= " .. currentEnchantName .. "</font>\n" ..
                "Enchant Stone Left <font color='rgb(255,215,0)'>= " .. total .. "</font>"
            )
        end
    end))

    Menu:Button({
        Title = "Teleport to Altar",
        Callback = function()
            local target = CFrame.new(3234.83667, -1302.85486, 1398.39087, 0.464485794, -1.12043161e-07, -0.885580599,
                6.74793981e-08, 1, -9.11265872e-08, 0.885580599, -1.74314394e-08, 0.464485794)
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(target)
            end
        end
    })

    Menu:Button({
        Title = "Teleport to Second Altar",
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char:PivotTo(CFrame.new(1481, 128, -592))
            end
        end
    })

    local TargetEnchantDropdown = Menu:Dropdown({
        Title = "Target Enchant",
        List = enchantNames,
        Default = _G.TargetEnchant or enchantNames[1],
        Callback = function(selected)
            _G.TargetEnchant = selected
        end
    })

    Menu:Toggle({
        Title = "Auto Enchant",
        Value = _G.AutoEnchant,
        Callback = function(state)
            _G.AutoEnchant = state
        end
    })

    spawn(LPH_NO_VIRTUALIZE(function()
        while task.wait(0.5) do
            if _G.AutoEnchant then
                local currentEnchantId = getCurrentRodEnchant()
                local targetEnchantId = enchantIdMap[_G.TargetEnchant]
                if not targetEnchantId then
                    _G.AutoEnchant = false
                elseif currentEnchantId == targetEnchantId then
                    _G.AutoEnchant = false
                else
                    local stones = findEnchantStones()
                    if #stones > 0 then
                        local uuid = stones[1].UUID
                        equipItemRemote:FireServer(uuid, "EnchantStones")
                        task.wait(0.3)

                        local slot = math.max(countDisplayImageButtons() - 2, 1)
                        equipToolRemote:FireServer(slot)
                        task.wait(0.4)

                        activateAltarRemote:FireServer()
                        task.wait(5)
                    end
                end
            end
        end
    end))

    Menu:Section({Title = "Save position"})

    function SavePosition(cf)
        local data = { cf:GetComponents() }
        writefile(PositionFile, svc.HttpService:JSONEncode(data))
    end

    function LoadPosition()
        if isfile(PositionFile) then
            local success, data = pcall(function()
                return svc.HttpService:JSONDecode(readfile(PositionFile))
            end)
            if success and typeof(data) == "table" then
                return CFrame.new(unpack(data))
            end
        end
        return nil
    end

    function TeleportLastPos(char)
        task.spawn(function()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local last = LoadPosition()

            if last then
                task.wait(2)
                hrp.CFrame = last
                notify("Teleported to your last position...")
            end
        end)
    end

    player.CharacterAdded:Connect(TeleportLastPos)
    if player.Character then
        TeleportLastPos(player.Character)
    end

    Menu:Button({
        Title = "Save Position",
        Callback = function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                SavePosition(hrp.CFrame)
                notify("Position saved successfully!")
            end
        end
    })

    Menu:Button({
        Title = "Reset Position",
        Callback = function()
            if isfile(PositionFile) then
                delfile(PositionFile)
            end
            notify("Last position has been reset.")
        end
    })

    Menu:Section({Title = "Event Features"})

    countdownParagraph = Menu:Label({
        Title = "Ancient Lochness Monster Countdown",
        Content = "<font color='#ff4d4d'><b>waiting for ... for joined event!</b></font>"
    })

    st.FarmPosition = st.FarmPosition or nil
    st.autoCountdownUpdate = false

    Menu:Toggle({
        Title = "Auto Admin Event",
        Default = false,
        Callback = function(state)
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            st.autoCountdownUpdate = state

            local function getLabel()
                local ok, lbl = pcall(function()
                    return workspace["!!! MENU RINGS"]["Event Tracker"].Main.Gui.Content.Items.Countdown.Label
                end)
                return ok and lbl or nil
            end

            local function tpEventSpot(hrp)
                hrp.CFrame = CFrame.new(Vector3.new(6063, -586, 4715))
            end

            local function tpBackToFarm(hrp)
                if st.FarmPosition then
                    hrp.CFrame = st.FarmPosition
                    countdownParagraph:SetDesc("<font color='#00ff99'><b>✅ Returned to saved farm position!</b></font>")
                else
                    countdownParagraph:SetDesc("<font color='#ff4d4d'><b>❌ No saved farm position found!</b></font>")
                end
            end

            if state then
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp then
                    st.FarmPosition = hrp.CFrame
                    countdownParagraph:SetDesc(string.format(
                        "<font color='#00ff99'><b>Farm position saved!</b></font>"
                    ))
                end

                local labelPath = getLabel()
                if not labelPath then
                    countdownParagraph:SetDesc("<font color='#ff4d4d'><b>Label not found!</b></font>")
                    return
                end

                task.spawn(function()
                    local inEvent = false
                    while st.autoCountdownUpdate do
                        task.wait(1)

                        local text = ""
                        pcall(function() text = labelPath.Text or "" end)

                        if text == "" then
                            countdownParagraph:SetDesc("<font color='#ff4d4d'><b>Waiting for countdown...</b></font>")
                        else
                            countdownParagraph:SetDesc(string.format(
                                "<font color='#4de3ff'><b>Timer: %s</b></font>", text
                            ))

                            local char = player.Character or player.CharacterAdded:Wait()
                            local hrp = char:WaitForChild("HumanoidRootPart", 5)
                            if not hrp then
                                countdownParagraph:SetDesc(
                                    "<font color='#ff4d4d'><b>⚠️ HRP not found, retrying...</b></font>")
                            else
                                local h, m, s = text:match("(%d+)H%s*(%d+)M%s*(%d+)S")
                                h, m, s = tonumber(h), tonumber(m), tonumber(s)

                                if h == 3 and m == 59 and s == 59 and not inEvent then
                                    countdownParagraph:SetDesc(
                                        "<font color='#00ff99'><b>Event started! Teleporting...</b></font>")
                                    tpEventSpot(hrp)
                                    inEvent = true
                                elseif h == 3 and m == 49 and s == 59 and inEvent then
                                    countdownParagraph:SetDesc(
                                        "<font color='#ffaa00'><b>Event ended! Returning...</b></font>")
                                    tpBackToFarm(hrp)
                                    inEvent = false
                                end
                            end
                        end

                        if not labelPath or not labelPath.Parent then
                            labelPath = getLabel()
                            if not labelPath then
                                countdownParagraph:SetDesc(
                                    "<font color='#ff4d4d'><b>Label lost. Reconnecting...</b></font>")
                                task.wait(2)
                                labelPath = getLabel()
                            end
                        end
                    end
                end)
            else
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp then
                    tpBackToFarm(hrp)
                end
                countdownParagraph:SetDesc("<font color='#ff4d4d'><b>Auto Admin Event disabled.</b></font>")
            end
        end
    })

    Menu:Section({Title = "Totem"})

    TotemPanel = Menu:Label({
        Title = "Nearest Totem Detector",
        Desc = "Scanning Totems..."
    })

    function GetTT()
        local playerPos = st.char and st.char:FindFirstChild("HumanoidRootPart") and st.char.HumanoidRootPart.Position or
            Vector3.zero
        local foundTotems = {}
        for _, placed in pairs(workspace.Totems:GetChildren()) do
            if placed:IsA("Model") then
                local handle = placed:FindFirstChild("Handle")
                local overhead = handle and handle:FindFirstChild("Overhead")
                local content = overhead and overhead:FindFirstChild("Content")
                local header = content and content:FindFirstChild("Header")
                local timerLabel = content and content:FindFirstChild("TimerLabel")
                local pos = placed:GetPivot().Position
                local dist = (playerPos - pos).Magnitude
                local timeLeft = timerLabel and timerLabel.Text or "??"
                local TotemName = header and header.Text or "??"
                table.insert(foundTotems, {
                    Name = TotemName,
                    Distance = dist,
                    TimeLeft = timeLeft
                })
            end
        end
        return foundTotems
    end

    function UpdTT()
        local found = GetTT()
        if #found == 0 then
            TotemPanel:SetDesc("No active totems detected.")
            return
        end
        local lines = {}
        for _, t in ipairs(found) do
            table.insert(lines, string.format("%s • %.1f studs • %s", t.Name, t.Distance, t.TimeLeft))
        end
        TotemPanel:SetDesc(table.concat(lines, "\n"))
    end

    task.spawn(function()
        while task.wait(1) do
            pcall(UpdTT)
        end
    end)

    function GetTTUUID(selectedName)
        if not Data then
            Data = mods.Replion.Client:WaitReplion("Data")
            if not Data then
                return nil
            end
        end

        if not Totems then
            Totems = require(game:GetService("ReplicatedStorage"):WaitForChild("Totems"))
            if not Totems then
                return nil
            end
        end

        local invTotems = Data:GetExpect({ "Inventory", "Totems" }) or {}
        for _, item in ipairs(invTotems) do
            local name = "Unknown Totem"
            if typeof(Totems) == "table" then
                for _, def in pairs(Totems) do
                    if def.Data and def.Data.Id == item.Id then
                        name = def.Data.Name
                        break
                    end
                end
            end
            if name == selectedName then
                return item.UUID, name
            end
        end
        return nil
    end

    local function SafeShowRealPanel()
        if RealTotemPanel and RealTotemPanel.Show then
            RealTotemPanel:Show()
        end
    end

    local function TrySpawnTotem(uuid)
        if not uuid then return end
        local ok, err = pcall(function()
            api.Events.Totem:FireServer(uuid)
        end)
        if not ok then
            warn("[Chloe X] Totem spawn failed:", tostring(err))
        end
    end

    Menu:Button({
        Title = "Teleport To Nearest Totem",
        Callback = function()
            local hrp = st.char and st.char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local list = GetTT()
            if #list == 0 then return end
            table.sort(list, function(a, b) return a.Distance < b.Distance end)
            local nearest = list[1]
            for _, t in pairs(workspace.Totems:GetChildren()) do
                if t:IsA("Model") then
                    local pos = t:GetPivot().Position
                    if math.abs((pos - hrp.Position).Magnitude - nearest.Distance) < 1 then
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end
        end
    })

    TotemsFolder = svc.RS:WaitForChild("Totems")
    st.Totems = st.Totems or {}
    st.TotemDisplayName = st.TotemDisplayName or {}
    for _, moduleTotem in ipairs(TotemsFolder:GetChildren()) do
        if moduleTotem:IsA("ModuleScript") then
            local ok, data = pcall(require, moduleTotem)
            if ok and typeof(data) == "table" and data.Data then
                local name = data.Data.Name or "Unknown"
                local id = data.Data.Id or "Unknown"
                local entry = { Name = name, Id = id }
                st.Totems[id] = entry
                st.Totems[name] = entry
                table.insert(st.TotemDisplayName, name)
            end
        end
    end

    selectedTotem = nil
    TotemDropdown = Menu:Dropdown({
        Title = "Select Totem to Auto Place",
        List = st.TotemDisplayName or { "No Totems Found" },
        Default = st.TotemDisplayName and st.TotemDisplayName[1] or "No Totems Found",
        Callback = function(opt)
            selectedTotem = opt
        end
    })

    Menu:Toggle({
        Title = "Auto Place Totem (Beta)",
        Desc = "Place Totem every 60 minutes automatically.",
        Default = false,
        Callback = function(state)
            TotemActive = state
            if state then
                if not selectedTotem then
                    TotemActive = false
                    return
                end

                local uuid, name = GetTTUUID(selectedTotem)
                if not uuid then
                    TotemActive = false
                    return
                end

                task.spawn(function()
                    local notifShown = 0
                    while TotemActive do
                        TrySpawnTotem(uuid)
                        if notifShown < 3 then
                            notifShown += 1
                        elseif notifShown == 3 then
                            notifShown += 1
                            task.wait(1)
                            task.wait(0.5)
                            SafeShowRealPanel()
                        end
                        for i = 3600, 1, -1 do
                            if not TotemActive then break end
                            task.wait(1)
                        end
                        uuid, name = GetTTUUID(selectedTotem)
                        if not uuid then
                            TotemActive = false
                            break
                        end
                    end
                end)
            else
                SafeShowRealPanel()
            end
        end
    })

    -- ========== UPDATE MANGKRAK ==========
    -- local TweenService = svc.Tween

    -- local function tweenTo(hrp, targetPos, time)
    --     local tween = TweenService:Create(
    --         hrp,
    --         TweenInfo.new(time, Enum.EasingStyle.Linear),
    --         {CFrame = CFrame.new(targetPos)}
    --     )
    --     tween:Play()
    --     tween.Completed:Wait()
    --     hrp.CFrame = CFrame.new(targetPos)
    --     task.wait()
    -- end

    -- local function freezeChar(char)
    --     local hrp = char:FindFirstChild("HumanoidRootPart")
    --     local hum = char:FindFirstChildWhichIsA("Humanoid")
    --     if hrp and hum then
    --         hum.PlatformStand = true
    --         hrp.Anchored = true
    --     end
    -- end

    -- local function unfreezeChar(char)
    --     local hrp = char:FindFirstChild("HumanoidRootPart")
    --     local hum = char:FindFirstChildWhichIsA("Humanoid")
    --     if hrp and hum then
    --         hum.PlatformStand = false
    --         hrp.Anchored = false
    --     end
    -- end

    -- local function holdPosition(hrp, targetPos)
    --     local bp = Instance.new("BodyPosition")
    --     bp.Position = targetPos
    --     bp.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    --     bp.P = 1e5
    --     bp.D = 1e3
    --     bp.Parent = hrp
    --     return bp
    -- end

    -- local function makePlatform(pos)
    --     local p = Instance.new("Part")
    --     p.Size = Vector3.new(10,1,10)
    --     p.Anchored = true
    --     p.CanCollide = true
    --     p.Transparency = 1
    --     p.Position = pos - Vector3.new(0, 3, 0)
    --     p.Parent = workspace
    --     task.delay(10, function()
    --         if p then p:Destroy() end
    --     end)
    -- end

    -- Menu:Toggle({
    --     Title = "Auto Spam Totem (beta)",
    --     Desc = "Spam Selected Totem automatically.",
    --     Default = false,
    --     Callback = function(state)
    --         TotemActive = state

    --         if state then
    --             task.spawn(function()
    --                 local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart") or player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
    --                 if not hrp then
    --                     warn("HumanoidRootPart Not Found...")
    --                     return
    --                 end

    --                 local notifShown = 0
    --                 local totems = 0

    --                 local firstPos = hrp.Position
    --                 freezeChar(player.Character)

    --                 local offsets = {
    --                     Vector3.new(0, 0, -60),
    --                     Vector3.new(-60, 0, 0),
    --                     Vector3.new(60, 0, 60),

    --                     Vector3.new(0, 120, -60),
    --                     Vector3.new(-60, 120, 0),
    --                     Vector3.new(60, 120, 60),

    --                     Vector3.new(0, -120, -60),
    --                     Vector3.new(-60, -120, 0),
    --                     Vector3.new(60, -120, 60),
    --                 }


    --                 while TotemActive do
    --                     local lastPos = hrp.Position

    --                     for _, offset in ipairs(offsets) do
    --                         if not TotemActive then break end
    --                         if totems >= 9 then break end

    --                         local target = firstPos + offset

    --                         tweenTo(hrp, target, 5)
    --                         hrp.CFrame = CFrame.new(target)

    --                         local holder = holdPosition(hrp, target)
    --                         hrp.Anchored = false
    --                         task.wait(0.2)

    --                         makePlatform(target)
    --                         task.wait(0.1)

    --                         TrySpawnTotem(uuid)
    --                         if holder then holder:Destroy() end
    --                         hrp.Anchored = true
    --                         totems += 1

    --                         local newUUID = GetTTUUID(selectedTotem)
    --                         if not newUUID then
    --                             TotemActive = false
    --                             notify("Not Enough Totems")
    --                             break
    --                         end
    --                         uuid = newUUID

    --                         if notifShown < 3 then
    --                             notifShown += 1
    --                         elseif notifShown == 3 then
    --                             notifShown += 1
    --                             task.wait(1.2)
    --                             SafeShowRealPanel()
    --                         end

    --                         task.wait(3.5)
    --                     end

    --                     tweenTo(hrp, lastPos, 2)
    --                     unfreezeChar(player.Character)
    --                 end
    --             end)
    --         else
    --             unfreezeChar(player.Character)
    --             SafeShowRealPanel()
    --         end
    --     end
    -- })
end

local Shop = Window:Tab({ Title = "Shop", Icon = 71444644802667 }) do
    Shop:Section({Title = "Merchant Shop"})

    ShopParagraph = Shop:Label({
        Title = "MERCHANT STOCK PANEL",
        Desc = "Loading...",
    })

    Shop:Button({
        Title = "Open/Close Merchant",
        Callback = function()
            local merchant = svc.PG:FindFirstChild("Merchant")
            if merchant then
                merchant.Enabled = not merchant.Enabled
            end
        end
    })

    function UPX()
        local list = {}
        for _, child in ipairs(gui.ItemsFrame:GetChildren()) do
            if child:IsA("ImageLabel") and child.Name ~= "Frame" then
                local frame = child:FindFirstChild("Frame")
                if frame and frame:FindFirstChild("ItemName") then
                    local itemName = frame.ItemName.Text
                    if not string.find(itemName, "Mystery") then
                        table.insert(list, "- " .. itemName)
                    end
                end
            end
        end

        if #list == 0 then
            ShopParagraph:SetDesc("No items found\n" .. gui.RefreshMerchant.Text)
        else
            ShopParagraph:SetDesc(table.concat(list, "\n") .. "\n\n" .. gui.RefreshMerchant.Text)
        end
    end

    task.spawn(function()
        while task.wait(1) do
            pcall(UPX)
        end
    end)

    Shop:Section({Title = "Rods Shop"})

    Shop:Dropdown({
        Title = "Select Rod",
        List = st.rodDisplayNames,
        Callback = function(selected)
            if not selected then return end
            local clean = _cleanName(selected)
            local info  = st.rods[clean]
            if info then
                st.selectedRodId = info.Id
            end
        end
    })

    Shop:Button({
        Title = "Buy Selected Rod",
        Callback = function()
            if not st.selectedRodId then return end
            local info = st.rods[st.selectedRodId] or st.rods[_cleanName(st.selectedRodId)]
            if not info then return end
            pcall(function()
                api.Functions.BuyRod:InvokeServer(info.Id)
            end)
        end
    })

    Shop:Section({Title = "Bait Shop"})

    Shop:Dropdown({
        Title = "Select Bait",
        List = st.baitDisplayNames,
        Callback = function(selected)
            if not selected then return end
            local clean = _cleanName(selected)
            local info  = st.baits[clean]
            if info then
                st.selectedBaitId = info.Id
            end
        end
    })

    Shop:Button({
        Title = "Buy Selected Bait",
        Callback = function()
            if not st.selectedBaitId then return end
            local info = st.baits[st.selectedBaitId] or st.baits[_cleanName(st.selectedBaitId)]
            if not info then return end
            pcall(function()
                api.Functions.BuyBait:InvokeServer(info.Id)
            end)
        end
    })

    Shop:Section({Title = "Weather"})

    weatherinfo = {
        "Cloudy ($10000)",
        "Wind ($10000)",
        "Snow ($15000)",
        "Storm ($35000)",
        "Radiant ($50000)",
        "Shark Hunt ($300000)"
    }

    WeatherDropdown = Shop:Dropdown({
        Title = "Select Weather",
        List = weatherinfo,
        Multi = true,
        Callback = function(selected)
            st.selectedEvents = {}
            if type(selected) == "table" then
                for _, val in ipairs(selected) do
                    local clean = val:match("^(.-) %(") or val
                    table.insert(st.selectedEvents, clean)
                end
            elseif type(selected) == "string" then
                local clean = selected:match("^(.-) %(") or selected
                table.insert(st.selectedEvents, clean)
            end
            SaveConfig()
        end
    })

    Shop:Toggle({
        Title = "Auto Buy Weather",
        Default = false,
        Callback = function(state)
            st.autoBuyWeather = state
            if not api.Functions.BuyWeather then return end
            if state then
                spawn(LPH_NO_VIRTUALIZE(function()
                    while st.autoBuyWeather do
                        local selectedNow = st.selectedEvents or {}
                        if #selectedNow > 0 then
                            local active = {}
                            local folder = workspace:FindFirstChild("Weather")
                            if folder then
                                for _, w in ipairs(folder:GetChildren()) do
                                    table.insert(active, string.lower(w.Name))
                                end
                            end
                            for _, weather in ipairs(selectedNow) do
                                local lower = string.lower(weather)
                                if not table.find(active, lower) then
                                    pcall(function()
                                        api.Functions.BuyWeather:InvokeServer(weather)
                                    end)
                                    task.wait(0.05)
                                end
                            end
                        end

                        task.wait(0.1)
                    end
                end))
            end
        end
    })
end

--// TRADE TAB
local Trade = Window:Tab({ Title = "Trading", Icon = 15594035945 }) do

    function getGroupedByType(typeName)
        local items = repl.Data:GetExpect({ "Inventory", "Items" })
        local grouped, values = {}, {}
        for _, item in ipairs(items) do
            local info = mods.ItemUtility.GetItemDataFromItemType("Items", item.Id)
            if info and info.Data.Type == typeName then
                local name = info.Data.Name
                grouped[name] = grouped[name] or { count = 0, uuids = {} }
                grouped[name].count += (item.Quantity or 1)
                table.insert(grouped[name].uuids, item.UUID)
            end
        end
        for name, data in pairs(grouped) do
            table.insert(values, ("%s x%d"):format(name, data.count))
        end
        return grouped, values
    end

    Trade:Section({Title = "Trading Fish"})

    Name_Monitor = Trade:Label({
        Title = "Panel Name Trading",
        Desc = [[
Player : ???
Item   : ???
Amount : 0
Status : Idle
Success: 0 / 0
    ]]
    })

    _G.safeSetContent = function(obj, text)
        svc.RunService.Heartbeat:Once(function()
            if obj then
                obj:SetDesc(text)
            end
        end)
    end

    function updateNameStatus(statusText)
        local ts = st.trade
        local color = "200,200,200"
        if statusText and statusText:lower():find("send") then
            color = "51,153,255"
        elseif statusText and statusText:lower():find("complete") then
            color = "0,204,102"
        elseif statusText and statusText:lower():find("time") then
            color = "255,69,0"
        end

        local text = string.format([[
    <font color='rgb(173,216,230)'>Player : %s</font>
    <font color='rgb(173,216,230)'>Item   : %s</font>
    <font color='rgb(173,216,230)'>Amount : %d</font>
    <font color='rgb(%s)'>Status : %s</font>
    <font color='rgb(173,216,230)'>Success: %d / %d</font>
    ]],
            ts.selectedPlayer or "???",
            ts.selectedItem or "???",
            ts.tradeAmount or 0,
            color,
            statusText or "Idle",
            ts.successCount or 0,
            ts.totalToTrade or 0
        )
        _G.safeSetContent(Name_Monitor, text)
    end

    function hasItem(uuid)
        for _, it in ipairs(repl.Data:GetExpect({ "Inventory", "Items" })) do
            if it.UUID == uuid then
                return true
            end
        end
        return false
    end

    function sendTrade(targetName, uuid, itemName, price)
        local ts = st.trade
        ts.awaiting, ts.lastResult = true, nil
        local completed = false

        local target = svc.Players:FindFirstChild(targetName)
        if not target then
            ts.trading = false
            updateNameStatus("<font color='#ff3333'>Player not found</font>")
            return false
        end

        if itemName then
            updateNameStatus("Sending")
        end

        local ok = pcall(function()
            api.Functions.Trade:InvokeServer(target.UserId, uuid)
        end)
        if not ok then
            return false
        end

        local startTime = tick()
        while ts.trading and not completed do
            if not hasItem(uuid) then
                completed = true
                if itemName then
                    ts.successCount += 1
                    updateNameStatus("Completed")
                end
            elseif tick() - startTime > 10 then
                return false
            end
            task.wait(0.2)
        end

        return completed
    end

    function sendTradeWithRetry(targetName, uuid, itemName, price)
        local ts = st.trade
        local retries = 0
        while retries < 3 and ts.trading do
            local ok = sendTrade(targetName, uuid, itemName, price)
            if ok then
                task.wait(2.5)
                return true
            end
            retries += 1
            task.wait(1)
        end
        return false
    end

    function startTradeByName()
        local ts = st.trade
        if ts.trading then return end
        if not ts.selectedPlayer or not ts.selectedItem then
            return
        end

        ts.trading = true
        ts.successCount = 0

        local itemData = ts.currentGrouped[ts.selectedItem]
        if not itemData then
            ts.trading = false
            updateNameStatus("<font color='#ff3333'>Item not found</font>")
            return
        end

        ts.totalToTrade = math.min(ts.tradeAmount, #itemData.uuids)
        local i = 1
        while ts.trading and ts.successCount < ts.totalToTrade do
            sendTradeWithRetry(ts.selectedPlayer, itemData.uuids[i], ts.selectedItem)
            i += 1
            if i > #itemData.uuids then i = 1 end
            task.wait(2)
        end

        ts.trading = false
        updateNameStatus("<font color='#66ccff'>All trades finished</font>")
    end

    function chooseFishesByRange(fishes, target)
        table.sort(fishes, function(a, b) return a.Price > b.Price end)
        local chosen, total = {}, 0
        for _, fish in ipairs(fishes) do
            if total + fish.Price <= target then
                table.insert(chosen, fish)
                total += fish.Price
            end
            if total >= target then break end
        end
        if total < target and #fishes > 0 then
            table.insert(chosen, fishes[#fishes])
        end
        return chosen, total
    end

    itemDropdown = Trade:Dropdown({
        Title = "Select Item",
        List = {},
        Multi = false,
        Callback = function(value)
            st.trade.selectedItem = value and value:match("^(.-) x") or value
            updateNameStatus()
        end
    })

    Trade:Button({
        Title = "Refresh Fish",
        Callback = function()
            local grouped, values = getGroupedByType("Fish")
            st.trade.currentGrouped = grouped
            itemDropdown:Clear()
            for _, v in ipairs(values) do
                itemDropdown:Add(v)
            end
            itemDropdown:SetValue(values[1])
        end
    })

    Trade:Button({
        Title = "Refresh Stone",
        Callback = function()
            local grouped, values = getGroupedByType("Enchant Stones")
            st.trade.currentGrouped = grouped
            itemDropdown:Clear()
            for _, v in ipairs(values) do
                itemDropdown:Add(v)
            end
            itemDropdown:SetValue(values[1])
        end
    })

    Trade:Textbox({
        Title = "Amount to Trade",
        Default = "1",
        Callback = function(value)
            st.trade.tradeAmount = tonumber(value) or 1
            updateNameStatus()
        end
    })

    playerTradeDropdown = Trade:Dropdown({
        Title = "Select Player",
        List = {},
        Multi = false,
        Callback = function(value)
            st.trade.selectedPlayer = value
            updateNameStatus()
        end
    })

    Trade:Button({
        Title = "Refresh Player",
        Callback = function()
            local names = {}
            for _, plr in ipairs(svc.Players:GetPlayers()) do
                if plr ~= st.player then table.insert(names, plr.Name) end
            end
            playerTradeDropdown:Clear()
            for _, v in ipairs(names) do
                playerTradeDropdown:Add(v)
            end
            playerTradeDropdown:SetValue(names[1])
        end
    })

    Trade:Toggle({
        Title = "Start By Name",
        Default = false,
        Callback = function(state)
            if state then
                task.spawn(startTradeByName)
            else
                st.trade.trading = false
                updateNameStatus()
            end
        end
    })

    Trade:Section({Title = "Auto Accept"})

    Trade:Toggle({
        Title = "Auto Accept Trade",
        Default = _G.AutoAccept,
        Callback = function(value)
            _G.AutoAccept = value
        end
    })

    spawn(function()
        while true do
            task.wait(1)
            if _G.AutoAccept then
                pcall(function()
                    local promptGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Prompt")
                    if promptGui and promptGui:FindFirstChild("Blackout") then
                        local blackout = promptGui.Blackout
                        if blackout:FindFirstChild("Options") then
                            local options = blackout.Options
                            local yesButton = options:FindFirstChild("Yes")
                            if yesButton then
                                local vr = game:GetService("VirtualInputManager")
                                local absPos = yesButton.AbsolutePosition
                                local absSize = yesButton.AbsoluteSize
                                local clickX = absPos.X + (absSize.X / 2)
                                local clickY = absPos.Y + (absSize.Y / 2) + 50
                                vr:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                                task.wait(0.03)
                                vr:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                            end
                        end
                    end
                end)
            end
        end
    end)
end

--// QUESST TAB
local Quest = Window:Tab({ Title = "Quest", Icon = "scroll" }) do
    Quest:Section({Title = "Auto Artifact"})

    local Jungle = workspace:WaitForChild("JUNGLE INTERACTIONS")
    local LOOP_DELAY, running, waitingArtifact = 1, false, nil
    local ACTIVE_COLOR, DISABLE_COLOR = "0,255,0", "255,0,0"

    _G.artifactPositions = {
        ["Arrow Artifact"] = CFrame.new(875, 3, -368) * CFrame.Angles(0, math.rad(90), 0),
        ["Crescent Artifact"] = CFrame.new(1403, 3, 123) * CFrame.Angles(0, math.rad(180), 0),
        ["Hourglass Diamond Artifact"] = CFrame.new(1487, 3, -842) * CFrame.Angles(0, math.rad(180), 0),
        ["Diamond Artifact"] = CFrame.new(1844, 3, -287) * CFrame.Angles(0, math.rad(-90), 0)
    }

    orderList = { "Arrow Artifact", "Crescent Artifact", "Hourglass Diamond Artifact", "Diamond Artifact" }

    function getStatus()
        local s = {}
        for _, o in ipairs(Jungle:GetDescendants()) do
            if o:IsA("Model") and o.Name == "TempleLever" then
                s[o:GetAttribute("Type")] = not (o:FindFirstChild("RootPart") and o.RootPart:FindFirstChildWhichIsA("ProximityPrompt"))
            end
        end
        return s
    end

    function setStatusUI(st)
        local function seg(k, v)
            local n = (k == "Hourglass Diamond Artifact" and "Hourglass Diamond") or (k == "Arrow Artifact" and "Arrow") or
                (k == "Crescent Artifact" and "Crescent") or "Diamond"
            local c = v and ACTIVE_COLOR or DISABLE_COLOR
            return ('%s : <b><font color="rgb(%s)">%s</font></b>'):format(n, c, v and "ACTIVE" or "DISABLE")
        end
        ArtifactParagraph:SetDesc(table.concat({
            seg("Arrow Artifact", st["Arrow Artifact"]),
            seg("Crescent Artifact", st["Crescent Artifact"]),
            seg("Hourglass Diamond Artifact", st["Hourglass Diamond Artifact"]),
            seg("Diamond Artifact", st["Diamond Artifact"])
        }, "\n"))
    end

    function firePromptFor(name)
        for _, o in ipairs(Jungle:GetDescendants()) do
            if o:IsA("Model") and o.Name == "TempleLever" and o:GetAttribute("Type") == name then
                local p = o:FindFirstChild("RootPart") and o.RootPart:FindFirstChildWhichIsA("ProximityPrompt")
                if p then fireproximityprompt(p) end
                break
            end
        end
    end

    ArtifactParagraph = Quest:Label({
        Title = "Panel Progress Artifact",
        Desc = [[
    Arrow : <b><font color="rgb(255,0,0)">DISABLE</font></b>
    Crescent : <b><font color="rgb(255,0,0)">DISABLE</font></b>
    Hourglass Diamond : <b><font color="rgb(255,0,0)">DISABLE</font></b>
    Diamond : <b><font color="rgb(255,0,0)">DISABLE</font></b>
    ]]
    })

    api.Events.REFishGot.OnClientEvent:Connect(function(fish)
        if not running or not waitingArtifact then return end
        local head = string.split(waitingArtifact, " ")[1]
        if head and string.find(fish, head, 1, true) then
            task.wait(0)
            firePromptFor(waitingArtifact)
            waitingArtifact = nil
        end
    end)

    Quest:Toggle({
        Title = "Artifact Progress",
        Default = false,
        Callback = function(state)
            running = state
            if state then
                spawn(LPH_NO_VIRTUALIZE(function()
                    while running do
                        local status, all = getStatus(), true
                        for _, v in pairs(status) do
                            if not v then
                                all = false
                                break
                            end
                        end
                        setStatusUI(status)
                        if all then
                            running = false
                            break
                        end

                        for _, n in ipairs(orderList) do
                            if not status[n] then
                                waitingArtifact = n

                                local char = player.Character or player.CharacterAdded:Wait()
                                local hrp = char:WaitForChild("HumanoidRootPart")

                                if hrp and _G.artifactPositions[n] then
                                    hrp.CFrame = _G.artifactPositions[n]
                                end

                                repeat
                                    task.wait(LOOP_DELAY)
                                until not waitingArtifact or not running
                                break
                            end
                        end

                        task.wait(LOOP_DELAY)
                    end
                end))
            end
        end
    })

    task.spawn(function()
        while task.wait(LOOP_DELAY) do
            setStatusUI(getStatus())
        end
    end)

    local DeepSeaQuest = Quest:Section({Title = "Ghostfin Quest"})

    local DeepSeaPara = Quest:Label({
        Title = "Deep Sea Panel",
        Desc = ""
    })

    Quest:Toggle({
        Title = "Auto Deep Sea Quest",
        Default = false,
        Callback = function(state)
            st.autoDeepSea = state

            task.spawn(function()
                while st.autoDeepSea do
                    local trackerFolder = workspace:FindFirstChild("!!! MENU RINGS")
                    local tracker = trackerFolder and trackerFolder:FindFirstChild("Deep Sea Tracker")
                    if tracker then
                        local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and
                            tracker.Board.Gui:FindFirstChild("Content")
                        if content then
                            local firstLabel
                            for _, child in ipairs(content:GetChildren()) do
                                if child:IsA("TextLabel") and child.Name ~= "Header" then
                                    firstLabel = child
                                    break
                                end
                            end

                            if firstLabel then
                                local text = string.lower(firstLabel.Text)
                                local hrp = st.player.Character and st.player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    if string.find(text, "100%%") then
                                        hrp.CFrame = CFrame.new(-3763, -135, -995) * CFrame.Angles(0, math.rad(180), 0)
                                    else
                                        hrp.CFrame = CFrame.new(-3599, -276, -1641)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    })

    Quest:Section({Title = "Element Quest"})
    local ElementPara = Quest:Label({
        Title = "Element Panel",
        Desc = ""
    })

    Quest:Toggle({
        Title = "Auto Element Quest",
        Default = false,
        Callback = function(state)
            st.autoElement = state

            task.spawn(function()
                local doneFinal = false

                while st.autoElement and not doneFinal do
                    local trackerFolder = workspace:FindFirstChild("!!! MENU RINGS")
                    local tracker = trackerFolder and trackerFolder:FindFirstChild("Element Tracker")
                    if tracker then
                        local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and
                            tracker.Board.Gui:FindFirstChild("Content")
                        if content then
                            local labels = {}
                            for _, child in ipairs(content:GetChildren()) do
                                if child:IsA("TextLabel") and child.Name ~= "Header" then
                                    table.insert(labels, string.lower(child.Text))
                                end
                            end

                            local hrp = st.player.Character and st.player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and #labels >= 4 then
                                local label2 = labels[2]
                                local label4 = labels[4]

                                if not string.find(label4, "100%%") then
                                    hrp.CFrame = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                                elseif string.find(label4, "100%%") and not string.find(label2, "100%%") then
                                    hrp.CFrame = CFrame.new(1453, -22, -636)
                                elseif string.find(label2, "100%%") then
                                    hrp.CFrame = CFrame.new(1480, 128, -593)
                                    doneFinal = true
                                    st.autoElement = false
                                    if ElementPara and ElementPara.SetDesc then
                                        ElementPara:SetDesc("Element Quest Completed!")
                                    end
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    })

    function readTracker(name)
        local path = workspace["!!! MENU RINGS"]:FindFirstChild(name)
        if not path then return "" end
        local content = path:FindFirstChild("Board") and path.Board:FindFirstChild("Gui") and
            path.Board.Gui:FindFirstChild("Content")
        if not content then return "" end
        local lines = {}
        local index = 1
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("TextLabel") and child.Name ~= "Header" then
                table.insert(lines, index .. ". " .. child.Text)
                index += 1
            end
        end
        return table.concat(lines, "\n")
    end

    spawn(LPH_NO_VIRTUALIZE(function()
        while task.wait(2) do
            ElementPara:SetDesc(readTracker("Element Tracker"))
            DeepSeaPara:SetDesc(readTracker("Deep Sea Tracker"))
        end
    end))

    Quest:Section({Title = "Ancient Ruin Features"})
    local ruin = workspace:FindFirstChild("RUIN INTERACTIONS")
    local tiers = { "Rare", "Epic", "Legendary", "Mythic" }
    FishTargetIDs = {
        Rare = 284,
        Epic = 270,
        Legendary = 283,
        Mythic = 263
    }

    PromptParagraph = Quest:Label({
        Title = "Panel Ancient Ruin",
        Desc = "Checking..."
    })

    task.spawn(function()
        while task.wait(1) do
            if ruin and ruin:FindFirstChild("PressurePlates") then
                local plates = ruin.PressurePlates
                local rare = plates:FindFirstChild("Rare") and plates.Rare.Part:FindFirstChild("ProximityPrompt")
                local epic = plates:FindFirstChild("Epic") and plates.Epic.Part:FindFirstChild("ProximityPrompt")
                local legendary = plates:FindFirstChild("Legendary") and
                plates.Legendary.Part:FindFirstChild("ProximityPrompt")
                local mythic = plates:FindFirstChild("Mythic") and plates.Mythic.Part:FindFirstChild("ProximityPrompt")

                PromptParagraph:SetDesc(string.format(
                    "Rare : %s\nEpic : %s\nLegendary : %s\nMythic : %s",
                    rare and "<b>Disable</b>" or "<b>Active</b>",
                    epic and "<b>Disable</b>" or "<b>Active</b>",
                    legendary and "<b>Disable</b>" or "<b>Active</b>",
                    mythic and "<b>Disable</b>" or "<b>Active</b>"
                ))
            else
                PromptParagraph:SetDesc("<font color='rgb(255,69,0)'>PressurePlates folder not found!</font>")
            end
        end
    end)

    Quest:Toggle({
        Title = "Auto Ancient Ruin",
        Default = false,
        Callback = function(s)
            st.triggerRuin = s
            task.spawn(function()
                while st.triggerRuin do
                    local inv = repl.Data:GetExpect({ "Inventory", "Items" })
                    if ruin and ruin:FindFirstChild("PressurePlates") then
                        local plates = ruin.PressurePlates
                        for _, tier in ipairs(tiers) do
                            local id = FishTargetIDs[tier]
                            local hasFish = false
                            for _, item in ipairs(inv) do
                                if item.Id == id then
                                    hasFish = true
                                    break
                                end
                            end
                            if hasFish then
                                local folder = plates:FindFirstChild(tier)
                                local part = folder and folder:FindFirstChild("Part")
                                local prompt = part and part:FindFirstChild("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    })

    Quest:Section({Title = "Classic Event Features [BETA]"})
    ReqFish = {
        "Builderman Guppy",
        "Brighteyes Guppy",
        "Shedletsky Guppy",
        "Guest Guppy"
    }

    FishTargetIDs = {
        ["Builderman Guppy"] = 434,
        ["Brighteyes Guppy"] = 435,
        ["Shedletsky Guppy"] = 415,
        ["Guest Guppy"] = 422
    }

    FishRootTargets = {
        ["Brighteyes Guppy"] = CFrame.new(-8865.5, -580.75, 174.225006, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07),
        ["Builderman Guppy"] = CFrame.new(-8829.5, -580.75, 138.024994, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07),
        ["Guest Guppy"]      = CFrame.new(-8865.5, -580.75, 138.024994, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07),
        ["Shedletsky Guppy"] = CFrame.new(-8830.48926, -580.75, 174.635254, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    }

    Pillars = workspace.ClassicEvent["Fish Pillars"]
    function findRoot(targetCF)
        local closest, dist = nil, math.huge
        for _, p in ipairs(Pillars:GetChildren()) do
            local mov = p:FindFirstChild("Movement")
            local root = mov and mov:FindFirstChild("Root")
            if root then
                local d = (root.CFrame.Position - targetCF.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = root
                end
            end
        end
        return closest
    end

    Quest:Toggle({
        Title = "Auto Classic Event",
        Default = false,
        Callback = function(s)
            st.autoClassicEvent = s

            task.spawn(function()
                while st.autoClassicEvent do
                    local inv = repl.Data:GetExpect({"Inventory", "Items"})

                    for _, fishName in ipairs(ReqFish) do
                        local needID = FishTargetIDs[fishName]

                        local hasFish = false
                        for _, item in ipairs(inv) do
                            if item.Id == needID then
                                hasFish = true
                                break
                            end
                        end

                        if hasFish then
                            local targetCF = FishRootTargets[fishName]
                            local root = findRoot(targetCF)

                            if root then
                                local prompt = root:FindFirstChild("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end

                    task.wait(0.5)
                end
            end)
        end
    })
end

--// TELEPORT TAB
local Tele = Window:Tab({ Title = "Teleport", Icon = 14240466919 }) do
    Tele:Section({Title = "Teleport To Player"})

    playerDropdown = Tele:Dropdown({
        Title = "Select Player to Teleport",
        Desc = "Choose target player",
        List = getPlayerList(),
        Default = {},
        Callback = function(value)
            st.trade.teleportTarget = value
        end
    })

    Tele:Button({
        Title = "Refresh Player List",
        Desc = "Refresh list!",
        Callback = function()
            local playerList = getPlayerList()
            playerDropdown:Clear()
            for _, v in ipairs(playerList) do
                playerDropdown:Add(v)
            end
            playerDropdown:SetValue(playerList[1])
            notify("Player list refreshed!")
        end
    })

    Tele:Button({
        Title = "Teleport to Player",
        Desc = "Teleport to selected player from dropdown",
        Callback = function()
            local targetName = st.trade.teleportTarget
            if not targetName then
                notify("Please select a player first!")
                return
            end
            local target = svc.Players:FindFirstChild(targetName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    notify("Teleported to " .. target.Name)
                else
                    notify("Your HumanoidRootPart not found.")
                end
            else
                notify("Target not found or not loaded.")
            end
        end
    })
    
    Tele:Section({Title = "Location"})

    local locationNames = {}
    for name, _ in pairs(locations) do
        table.insert(locationNames, name)
    end

    Tele:Dropdown({
        Title = "Select Location",
        Desc = "Choose teleport destination",
        List = locationNames,
        Default = {},
        Callback = function(value)
            st.teleportTarget = value
        end
    })

    Tele:Button({
        Title = "Teleport to Location",
        Desc = "Teleport to selected location",
        Callback = function()
            local locName = st.teleportTarget
            if not locName then
                notify("Please select a location first!")
                return
            end
            local pos = locations[locName]
            if pos then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    notify("Teleported to " .. locName)
                end
            end
        end
    })
end

--// WEBHOOK TAB
local Web = Window:Tab({ Title ="Webhook", Icon = 137601480983962 }) do
    Web:Section({Title = "Webhook"})

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")

    local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or
        request
    if not httpRequest then return end

    local ItemUtility, Replion, DataService
    local fishDB = {}
    local rarityList = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" }
    local tierToRarity = {
        [1] = "Common",
        [2] = "Uncommon",
        [3] = "Rare",
        [4] = "Epic",
        [5] = "Legendary",
        [6] = "Mythic",
        [7] = "SECRET"
    }
    local knownFishUUIDs = {}

    pcall(function()
        ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        Replion = require(ReplicatedStorage.Packages.Replion)
        DataService = Replion.Client:WaitReplion("Data")
    end)

    function buildFishDatabase()
        local RS = game:GetService("ReplicatedStorage")
        local itemsContainer = RS:WaitForChild("Items")
        if not itemsContainer then return end

        for _, itemModule in ipairs(itemsContainer:GetChildren()) do
            local success, itemData = pcall(require, itemModule)
            if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
                local data = itemData.Data
                if data.Id and data.Name then
                    fishDB[data.Id] = {
                        Name = data.Name,
                        Tier = data.Tier,
                        Icon = data.Icon,
                        SellPrice = itemData.SellPrice
                    }
                end
            end
        end
    end

    function getInventoryFish()
        if not (DataService and ItemUtility) then return {} end
        local inventoryItems = DataService:GetExpect({ "Inventory", "Items" })
        local fishes = {}
        for _, v in pairs(inventoryItems) do
            local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
            if itemData and itemData.Data.Type == "Fish" then
                table.insert(fishes, { Id = v.Id, UUID = v.UUID, Metadata = v.Metadata })
            end
        end
        return fishes
    end

    function getPlayerCoins()
        if not DataService then return "N/A" end
        local success, coins = pcall(function() return DataService:Get("Coins") end)
        if success and coins then return string.format("%d", coins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") end
        return "N/A"
    end

    function getThumbnailURL(assetString)
        local assetId = assetString:match("rbxassetid://(%d+)")
        if not assetId then return nil end
        local api = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png",
            assetId)
        local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(api)) end)
        return success and response and response.data and response.data[1] and response.data[1].imageUrl
    end

    function sendTestWebhook()
        if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then
            WindUI:Notify({ Title = "Error", Content = "Webhook URL Empty" })
            return
        end

        local payload = {
            username = "Seraphin Webhook",
            avatar_url = "https://i.imgur.com/IvNLsLU.png",
            embeds = { {
                title = "Test Webhook Connected",
                description = "Webhook connection successful!",
                color = 0x00FF00
            } }
        }

        pcall(function()
            httpRequest({
                Url = _G.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end

    function sendNewFishWebhook(newlyCaughtFish)
        if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then return end

        local newFishDetails = fishDB[newlyCaughtFish.Id]
        if not newFishDetails then return end

        local newFishRarity = tierToRarity[newFishDetails.Tier] or "Unknown"
        if #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, newFishRarity) then return end

        local fishWeight           = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.Weight and string.format("%.2f Kg", newlyCaughtFish.Metadata.Weight)) or
        "N/A"
        local mutation             = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.VariantId and tostring(newlyCaughtFish.Metadata.VariantId)) or
        "None"
        local sellPrice            = (newFishDetails.SellPrice and ("$" .. string.format("%d", newFishDetails.SellPrice):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " Coins")) or
        "N/A"
        local currentCoins         = getPlayerCoins()

        local totalFishInInventory = #getInventoryFish()
        local backpackInfo         = string.format("%d/5000", totalFishInInventory)

        local playerName           = game.Players.LocalPlayer.Name

        local payload              = {
            content = nil,
            embeds = { {
                title = "Seraphin Fish caught!",
                description = string.format("Congrats! **%s** You obtained new **%s** here for full detail fish :",
                    playerName, newFishRarity),
                url = "https://discord.gg/getseraphin",
                color = 10027263,
                fields = {
                    { name = "Name Fish :",        value = "```\n" .. newFishDetails.Name .. "```" },
                    { name = "Rarity :",           value = "```" .. newFishRarity .. "```" },
                    { name = "Weight :",           value = "```" .. fishWeight .. "```" },
                    { name = "Mutation :",         value = "```" .. mutation .. "```" },
                    { name = "Sell Price :",       value = "```" .. sellPrice .. "```" },
                    { name = "Backpack Counter :", value = "```" .. backpackInfo .. "```" },
                    { name = "Current Coin :",     value = "```" .. currentCoins .. "```" },
                },
                footer = {
                    text = "Seraphin Webhook",
                    icon_url = "https://i.imgur.com/IvNLsLU.png"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
                thumbnail = {
                    url = getThumbnailURL(newFishDetails.Icon)
                }
            } },
            username = "Seraphin Webhook",
            avatar_url = "https://i.imgur.com/IvNLsLU.png",
            attachments = {}
        }

        pcall(function()
            httpRequest({
                Url = _G.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end

    Web:Textbox({
        Title = "URL Webhook",
        Placeholder = "Paste your Discord Webhook URL here",
        Value = _G.WebhookURL or "",
        Callback = function(text)
            _G.WebhookURL = text
        end
    })

    Web:Dropdown({
        Title = "Rarity Filter",
        List = rarityList,
        Multi = true,
        Value = _G.WebhookRarities or {},
        Callback = function(selected_options)
            _G.WebhookRarities = selected_options
        end
    })

    Web:Toggle({
        Title = "Send Webhook",
        Value = _G.DetectNewFishActive or false,
        Callback = function(state)
            _G.DetectNewFishActive = state
        end
    })

    Web:Button({
        Title = "Test Webhook",
        Callback = sendTestWebhook
    })

    buildFishDatabase()

    spawn(LPH_NO_VIRTUALIZE(function()
        local initialFishList = getInventoryFish()
        for _, fish in ipairs(initialFishList) do
            if fish and fish.UUID then
                knownFishUUIDs[fish.UUID] = true
            end
        end
    end))

    spawn(LPH_NO_VIRTUALIZE(function()
        while wait(0.1) do
            if _G.DetectNewFishActive then
                local currentFishList = getInventoryFish()
                for _, fish in ipairs(currentFishList) do
                    if fish and fish.UUID and not knownFishUUIDs[fish.UUID] then
                        knownFishUUIDs[fish.UUID] = true
                        sendNewFishWebhook(fish)
                    end
                end
            end
            wait(3)
        end
    end))
end

--// MISC TAB
local Misc = Window:Tab({ Title = "Misc", Icon = 12120710060 }) do
    Misc:Section({Title = "Miscellaneous"})

    Misc:Toggle({
        Title = "Anti Staff",
        Desc = "Auto kick if staff/developer joins the server.",
        Default = false,
        Callback = function(state)
            _G.AntiStaff = state
            if state then
                local GroupId = 35102746
                local StaffRoles = {
                    [2] = "OG",
                    [3] = "Tester",
                    [4] = "Moderator",
                    [75] = "Community Staff",
                    [79] = "Analytics",
                    [145] = "Divers / Artist",
                    [250] = "Devs",
                    [252] = "Partner",
                    [254] = "Talon",
                    [255] = "Wildes",
                    [55] = "Swimmer",
                    [30] = "Contrib",
                    [35] = "Contrib 2",
                    [100] = "Scuba",
                    [76] = "CC"
                }

                task.spawn(function()
                    while _G.AntiStaff do
                        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                            if plr ~= game.Players.LocalPlayer then
                                local rank = plr:GetRankInGroup(GroupId)
                                if StaffRoles[rank] then
                                    game.Players.LocalPlayer:Kick("Seraphin Detected Staff, Automatically Kicked!")
                                    return
                                end
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })

    local UltraConn

    Misc:Toggle({
        Title = "Boost Fps",
        Default = false,
        Callback = function(state)
            if state then
                local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
                local Lighting = game:GetService("Lighting")

                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                end

                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.FogStart = 9e9

                settings().Rendering.QualityLevel = 1

                for _, v in pairs(game:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CastShadow = false
                        v.Material = "Plastic"
                        v.Reflectance = 0
                        v.BackSurface = "SmoothNoOutlines"
                        v.BottomSurface = "SmoothNoOutlines"
                        v.FrontSurface = "SmoothNoOutlines"
                        v.LeftSurface = "SmoothNoOutlines"
                        v.RightSurface = "SmoothNoOutlines"
                        v.TopSurface = "SmoothNoOutlines"
                    elseif v:IsA("Decal") then
                        v.Transparency = 1
                        v.Texture = ""
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = NumberRange.new(0)
                    end
                end

                for _, v in pairs(Lighting:GetDescendants()) do
                    if v:IsA("PostEffect") then
                        v.Enabled = false
                    end
                end

                UltraConn = workspace.DescendantAdded:Connect(function(child)
                    task.spawn(function()
                        if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                            svc.RunService.Heartbeat:Wait()
                            child:Destroy()
                        elseif child:IsA("BasePart") then
                            child.CastShadow = false
                        end
                    end)
                end)
            else
                if UltraConn then
                    UltraConn:Disconnect()
                    UltraConn = nil
                end
            end
        end
    })

    Misc:Toggle({
        Title = "Disable 3D Render",
        Desc = "No Render Map",
        Default = false,
        Callback = function(state)
            if typeof(RunService.Set3dRenderingEnabled) == "function" then
                RunService:Set3dRenderingEnabled(not state)
            end
        end
    })

    Misc:Toggle({
        Title = "Bypass Radar",
        Default = false,
        Callback = function(state)
            pcall(function()
                api.Functions.UpdateRadar:InvokeServer(state)
            end)
        end,
    })

    local cutsceneController
    local originalPlay, originalStop

    do
        local ok, controller = pcall(function()
            return require(svc.RS.Controllers.CutsceneController)
        end)
        if ok and controller then
            cutsceneController = controller
            originalPlay = cutsceneController.Play
            originalStop = cutsceneController.Stop
        end
    end

    local function EnableSkip()
        if api.Events.RECutscene then
            api.Events.RECutscene.OnClientEvent:Connect(function(...)
                warn("[CELESTIAL] Cutscene blocked (ReplicateCutscene)", ...)
            end)
        end
        if api.Events.REStop then
            api.Events.REStop.OnClientEvent:Connect(function()
                warn("[CELESTIAL] Cutscene blocked (StopCutscene)")
            end)
        end
        if cutsceneController then
            cutsceneController.Play = function(...)
                warn("[CELESTIAL] Cutscene skipped!")
            end
            cutsceneController.Stop = function(...)
                warn("[CELESTIAL] Cutscene stop skipped")
            end
        end
        warn("[CELESTIAL] All cutscenes disabled successfully!")
    end

    local function DisableSkip()
        if cutsceneController and originalPlay and originalStop then
            cutsceneController.Play = originalPlay
            cutsceneController.Stop = originalStop
            warn("[CELESTIAL] Cutscenes restored to default")
        end
    end

    Misc:Toggle({
        Title = "Auto Skip Cutscene",
        Default = true,
        Callback = function(state)
            st.skipCutscene = state
            if state then
                EnableSkip()
            else
                DisableSkip()
            end
        end,
    })

    do
        Misc:Section({Title = "Hide Identifier"})

        local player = game:GetService("Players").LocalPlayer
        local running = false
        local customHeaderText, customLevelText
        local defaultTitle, defaultHeader, defaultLevel, defaultGradient, defaultRotation

        local function waitForOverhead()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return nil end
            repeat task.wait() until hrp:FindFirstChild("Overhead")
            return hrp:WaitForChild("Overhead", 5)
        end

        local function setupOverhead()
            local overhead = waitForOverhead()
            if not overhead then
                warn("[HideIdent] Overhead not found.")
                return
            end

            local titleLabel = overhead:FindFirstChild("TitleContainer") and overhead.TitleContainer:FindFirstChild("Label")
            local header = overhead:FindFirstChild("Content") and overhead.Content:FindFirstChild("Header")
            local levelLabel = overhead:FindFirstChild("LevelContainer") and overhead.LevelContainer:FindFirstChild("Label")
            local gradient = titleLabel and titleLabel:FindFirstChildOfClass("UIGradient")

            if not (titleLabel and header and levelLabel) then
                warn("[HideIdent] Missing UI components in Overhead.")
                return
            end
            if not gradient then
                gradient = Instance.new("UIGradient", titleLabel)
            end

            _G.hideident = {
                overhead = overhead,
                titleLabel = titleLabel,
                gradient = gradient,
                header = header,
                levelLabel = levelLabel,
            }

            defaultTitle = titleLabel.Text
            defaultHeader = header.Text
            defaultLevel = levelLabel.Text
            defaultGradient = gradient.Color
            defaultRotation = gradient.Rotation

            customHeaderText = customHeaderText or defaultHeader
            customLevelText = customLevelText or defaultLevel
        end

        local function applyCustom()
            local h = _G.hideident
            if not h or not h.overhead or not h.titleLabel then return end

            h.overhead.TitleContainer.Visible = true
            h.titleLabel.Text = "Seraphin"
            h.gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(145, 186, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 243, 255))
            })
            h.gradient.Rotation = 0
            h.header.Text = (customHeaderText ~= "" and customHeaderText) or "Seraph Rawr"
            h.levelLabel.Text = (customLevelText ~= "" and customLevelText) or "???"
        end

        setupOverhead()

        player.CharacterAdded:Connect(function()
            task.wait(2)
            setupOverhead()
            if running then
                task.spawn(function()
                    while running do
                        applyCustom()
                        task.wait(1)
                    end
                end)
            end
        end)

        Misc:Textbox({
            Title = "Input Name",
            Default = defaultHeader or "",
            Callback = function(v)
                customHeaderText = v
            end
        })

        Misc:Textbox({
            Title = "Input Level",
            Default = defaultLevel or "",
            Callback = function(v)
                customLevelText = v
            end
        })

        Misc:Toggle({
            Title = "Start Hide",
            Default = false,
            Callback = function(state)
                running = state
                if state then
                    task.spawn(function()
                        while running do
                            local ok, err = pcall(applyCustom)
                            if not ok then warn("[HideIdent] Error:", err) end
                            task.wait(1)
                        end
                    end)
                else
                    local h = _G.hideident
                    if not h or not h.overhead then return end
                    h.overhead.TitleContainer.Visible = false
                    h.titleLabel.Text = defaultTitle
                    h.header.Text = defaultHeader
                    h.levelLabel.Text = defaultLevel
                    h.gradient.Color = defaultGradient
                    h.gradient.Rotation = defaultRotation
                end
            end
        })
    end

    Misc:Section({Title = "Boost Player"})

    Misc:Toggle({
        Title = "Disable Notification",
        Default = false,
        Callback = function(state)
            st.disableNotifs = state
            if state then
                disconnectNotifs()
            else
                reconnectNotifs()
            end
        end
    })

    Misc:Toggle({
        Title = "Disable Fish Notification",
        Default = false,
        Callback = function(v)
            local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            local notif = gui:FindFirstChild("Small Notification")
            if notif and notif:FindFirstChild("Display") then
                notif.Display.Visible = not v
            end
        end
    })

    Misc:Toggle({
        Title = "Disable Char Effect",
        Default = false,
        Callback = function(state)
            if state then
                st.dummyCons = {}
                for _, ev in ipairs({
                    api.Events.REPlayFishEffect,
                    api.Events.RETextEffect
                }) do
                    for _, conn in ipairs(getconnections(ev.OnClientEvent)) do
                        conn:Disconnect()
                    end
                    local con = ev.OnClientEvent:Connect(function() end)
                    table.insert(st.dummyCons, con)
                end
            else
                if st.dummyCons then
                    for _, c in ipairs(st.dummyCons) do
                        c:Disconnect()
                    end
                end
                st.dummyCons = {}
            end
        end
    })

    Misc:Toggle({
        Title = "Delete Fishing Effects",
        Default = false,
        Callback = function(state)
            st.DelEffects = state
            if state then
                task.spawn(function()
                    while st.DelEffects do
                        local cosmetic = workspace:FindFirstChild("CosmeticFolder")
                        if cosmetic then
                            cosmetic:Destroy()
                        end
                        task.wait(60)
                    end
                end)
            end
        end
    })

    Misc:Toggle({
        Title = "Hide Rod On Hand",
        Default = false,
        Callback = function(state)
            st.IrRod = state
            if state then
                task.spawn(function()
                    while st.IrRod do
                        for _, char in ipairs(workspace.Characters:GetChildren()) do
                            local toolFolder = char:FindFirstChild("!!!EQUIPPED_TOOL!!!")
                            if toolFolder then
                                toolFolder:Destroy()
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

--// ANTI IDLE
local GC = getconnections or get_signal_cons
if GC then
    for _, v in pairs(GC(player.Idled)) do
        if v.Disable then
            v:Disable()
        elseif v.Disconnect then
            v:Disconnect()
        end
    end
else
    local VirtualUser = cloneref and cloneref(game:GetService("VirtualUser")) or game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
