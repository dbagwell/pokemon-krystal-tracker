function resetItems()
  for _, code in pairs(ITEMS_MAP) do
    if code then
      local object = Tracker:FindObjectForCode(code)
      if object then
        if object.Type == "toggle" then
          object.Active = false
        elseif object.Type == "progressive" then
          object.CurrentStage = 0
        else
          object.AcquiredCount = 0
        end
      end
    end
  end
  
  for code, _ in pairs(EVENT_NAMES) do
    Tracker:FindObjectForCode(code).Active = false
  end
  
  resetShowAndTellItems()
  resetPhoneCallItems()
  
  Tracker:FindObjectForCode("SHOW_AND_TELL_UNOWN").AcquiredCount = 0
end

function resetLocations()
  COLLECTED_LOCATIONS = {}
  for _, name in pairs(LOCATION_NAMES) do
    if SHOP_ITEMS_REMAINING[name] then
      local object = Tracker:FindObjectForCode("@locations/" .. name)
      if object then
        object.AvailableChestCount = SHOP_ITEMS_REMAINING[name]
      end
    else
      local object = Tracker:FindObjectForCode("@locations/" .. name)
      if object then
        object.AvailableChestCount = object.ChestCount
      end
    end
  end
end

function getShopInfo()
  local locations = {}
  for _, locationId in ipairs(SHOP_LOCATIONS_TO_TRACK) do
    if not SHOP_LOCATIONS_PROCESSED_FOR_IMPORTANT_SHOPS[locationId] then
      table.insert(locations, locationId)
    end
  end
  Archipelago:LocationScouts(locations, 0)
end

function onClear(slot_data)
  VISIBILITY_RULES = slot_data["visibility_rules"]
  LOGICAL_ACCESS_RULES = slot_data["logical_access_rules"]
  STRICT_ACCESS_RULES = slot_data["strict_access_rules"]
  SHOP_ITEMS_REMAINING = slot_data["shop_item_counts"]
  SHOP_LOCATIONS_TO_TRACK = slot_data["shop_location_numeric_ids"]
  for shop, numberOfItems in pairs(SHOP_ITEMS_REMAINING) do
    IMPORTANT_SHOP_ITEMS_REMAINING[shop] = numberOfItems
  end
  SHOP_LOCATIONS_PROCESSED_FOR_IMPORTANT_SHOPS = {}
  VIEWED_SHOPS = {}
  RENEWABLE_SHOPS = slot_data["renewable_shops"]
  TRACKED_SHOP_SCOUTS = {}
  IS_IMPROVED_CONSUMABLES_ENABLED = slot_data["is_improved_consumables_enabled"]
  IS_RANDOM_SHOW_AND_TELL_ENABLED = slot_data["is_random_show_and_tell_enabled"]
  SHOW_AND_TELL_POKEMON_ASSIGNMENTS = slot_data["show_and_tell_pokemon"]
  COLLECTED_EVENTS_KEY = "pokemon_krystal_collected_events_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  CURRENT_MAP_KEY = "pokemon_krystal_current_map_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  VIEWED_SHOPS_KEY = "pokemon_krystal_viewed_shops_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  POKEMON_CAUGHT_KEY = "pokemon_krystal_pokemon_caught_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  UNOWN_CAUGHT_KEY = "pokemon_krystal_unown_caught_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  PHONE_NUMBERS_REGISTERED_KEY = "pokemon_krystal_phone_numbers_registered_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  PHONE_CALLS_RECEIVED_KEY = "pokemon_krystal_phone_calls_received_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
  Tracker.BulkUpdate = true
  resetItems()
  resetLocations()
  getShopInfo()
  Tracker.BulkUpdate = false
  Archipelago:SetNotify({
    COLLECTED_EVENTS_KEY,
    CURRENT_MAP_KEY,
    VIEWED_SHOPS_KEY,
    POKEMON_CAUGHT_KEY,
    UNOWN_CAUGHT_KEY,
    PHONE_NUMBERS_REGISTERED_KEY,
    PHONE_CALLS_RECEIVED_KEY,
  })
  Archipelago:Get({
    COLLECTED_EVENTS_KEY,
    CURRENT_MAP_KEY,
    VIEWED_SHOPS_KEY,
    POKEMON_CAUGHT_KEY,
    UNOWN_CAUGHT_KEY,
    PHONE_NUMBERS_REGISTERED_KEY,
    PHONE_CALLS_RECEIVED_KEY,
  })
end

function onItem(index, item_id, item_name, player_number)
  trackItem(item_id, item_name, false)
end

function codeForItem(item_id, item_name)
  if item_name == "Progressive Rod" then
    local oldRod = Tracker:FindObjectForCode("OLD_ROD")
    local goodRod = Tracker:FindObjectForCode("GOOD_ROD")
    if goodRod and goodRod.Active then
      return "SUPER_ROD"
    elseif oldRod and oldRod.Active then
      return "GOOD_ROD"
    else
      return "OLD_ROD"
    end
  end
  
  return ITEMS_MAP[item_id]
end

function trackItem(item_id, item_name, from_scout)
  local code = codeForItem(item_id, item_name)
  if not code then
    return
  end
  
  local object = Tracker:FindObjectForCode(code)
  if object then
    if object.Type == "toggle" then
      object.Active = true
    elseif object.Type == "progressive" then
      if from_scout then
        if item_name == "Berry" then
          object.CurrentStage = 8
        else
          object.CurrentStage = 2
        end
        getShopInfo()
      elseif item_name == "Berry" then
        if object.CurrentStage ~= 8 then
          object.CurrentStage = math.min(7, object.CurrentStage + 1)
        end
      elseif object.CurrentStage ~= 2 then
        object.CurrentStage = 1
      end
    else
      object.AcquiredCount = object.AcquiredCount + 1
    end
  end
end

function onLocation(location_id, location_name)
  COLLECTED_LOCATIONS[location_id] = true
  local shopName = location_name:match("^(.*) %- Item %d")
  
  if shopName and SHOP_ITEMS_REMAINING[shopName] then
    SHOP_ITEMS_REMAINING[shopName] = SHOP_ITEMS_REMAINING[shopName] - 1
    local object = Tracker:FindObjectForCode("@locations/" .. shopName)
    if object and object.AvailableChestCount > 0 then
      object.AvailableChestCount = SHOP_ITEMS_REMAINING[shopName]
    end
    Archipelago:LocationScouts({location_id}, 0)
  else
    local object = Tracker:FindObjectForCode("@locations/" .. location_name)
    if object then
      object.AvailableChestCount = 0
    end
  end
end

function updateShopInfo(location_id, location_name, item_id, item_name, item_player)
  if SHOP_LOCATIONS_PROCESSED_FOR_IMPORTANT_SHOPS[location_id] then
    return
  end
  
  local shopName = location_name
  
  if location_name ~= "Mahogany Town - Street Vendor" and location_name ~= "Route 39 - Farmhouse - Shop" then
    shopName = location_name:match("^(.*) %- Item %d")
  end
  
  local itemCode = codeForItem(item_id, item_name)
  
  if
    COLLECTED_LOCATIONS[location_id]
    or item_player == Archipelago.PlayerNumber
    and (
      not itemCode
      or itemCode ~= "BERRY"
      and Tracker:FindObjectForCode(itemCode).CurrentStage == 2
      or itemCode == "BERRY"
      and Tracker:FindObjectForCode(itemCode).CurrentStage == 8
    )
  then
    IMPORTANT_SHOP_ITEMS_REMAINING[shopName] = IMPORTANT_SHOP_ITEMS_REMAINING[shopName] - 1
    SHOP_LOCATIONS_PROCESSED_FOR_IMPORTANT_SHOPS[location_id] = true
  end
  
  maybeClearShopLocation(shopName)
end

function maybeClearShopLocation(shopName)
  if VIEWED_SHOPS[shopName] and IMPORTANT_SHOP_ITEMS_REMAINING[shopName] < 1 and Tracker:FindObjectForCode("SMART_MARTS").CurrentStage == 1 then
    local object = Tracker:FindObjectForCode("@locations/" .. shopName)
    if object then
      object.AvailableChestCount = 0
    end
  end
end

function onScout(location_id, location_name, item_id, item_name, item_player)
  if 
    COLLECTED_LOCATIONS[location_id]
    and item_player == Archipelago.PlayerNumber
    and not TRACKED_SHOP_SCOUTS[location_id]
    and CONSUMABLE_ITEM_IDS[item_id]
  then
    for _, shop in ipairs(RENEWABLE_SHOPS) do
      if shop == location_id then
        TRACKED_SHOP_SCOUTS[location_id] = true
        trackItem(item_id, item_name, true)
      end
    end
  end
  
  updateShopInfo(location_id, location_name, item_id, item_name, item_player)
end

function onNotify(key, value)
  if not value then
    return
  end
  
  Tracker.BulkUpdate = true
  if key == COLLECTED_EVENTS_KEY then
    for _, event in ipairs(value) do
      local object = Tracker:FindObjectForCode(event)
      if object then
        object.Active = true
      else
        for _, item in pairs(SHOW_AND_TELL_ITEMS) do
          if item.ItemState["info"]["eventFlagId"] == event then
            setShowAndTellPokemon(item, SHOW_AND_TELL_POKEMON_ASSIGNMENTS[item.ItemState["info"]["defaultPokemonId"]])
          end
        end
      end
    end
  elseif 
    key == CURRENT_MAP_KEY 
    and Tracker:FindObjectForCode("AUTO_TAB").CurrentStage == 1
    and MAPS[value["group"]]
    and MAPS[value["group"]][value["number"]]
  then
    for _, tab in ipairs(MAPS[value["group"]][value["number"]]) do
      Tracker:UiHint("ActivateTab", tab)
    end
  elseif key == VIEWED_SHOPS_KEY then
    for _, shop in ipairs(value) do
      VIEWED_SHOPS[shop] = true
      maybeClearShopLocation(shop)
    end
    getShopInfo()
  elseif key == POKEMON_CAUGHT_KEY then
    for _, pokemon in ipairs(value) do
      POKEMON_CAUGHT[pokemon] = true
      for _, item in pairs(SHOW_AND_TELL_ITEMS) do
        if item.ItemState["pokemonId"] == pokemon then
          activateShowAndTellPokemon(item)
        end
      end
    end
  elseif key == UNOWN_CAUGHT_KEY then
    Tracker:FindObjectForCode("SHOW_AND_TELL_UNOWN").AcquiredCount = math.min(value, 3)
  elseif key == PHONE_NUMBERS_REGISTERED_KEY then
    for _, phoneCallId in ipairs(value) do
      activatePhoneNumber(Tracker:FindObjectForCode(phoneCallId .. "_PHONE_NUMBER"))
    end
  elseif key == PHONE_CALLS_RECEIVED_KEY then
    for _, phoneCallId in ipairs(value) do
      activatePhoneCall(Tracker:FindObjectForCode(phoneCallId .. "_PHONE_NUMBER"))
    end
  end
  Tracker.BulkUpdate = false
end

function onNotifyChange(key, value, old_value)
  if value ~= old_value then
    onNotify(key, value)
  end
end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddScoutHandler("scout handler", onScout)
Archipelago:AddRetrievedHandler("notify handler", onNotify)
Archipelago:AddSetReplyHandler("notify change handler", onNotifyChange)