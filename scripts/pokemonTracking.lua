SHOW_AND_TELL_ITEMS = {}

local emptyIcon = ImageReference:FromPackRelativePath("images/pokemon/none.png")

function showAndTellLeftClicked(item)
  if item.ItemState["isEmpty"] then
    CURRENT_SHOW_AND_TELL_ITEM = item
    Tracker:UiHint("ActivateTab", "Pokemon")
  else
    activateShowAndTellPokemon(item)
  end
end

function showAndTellRightClicked(item)
  if item.ItemState["isActive"] then
    disableShowAndTellPokemon(item)
  elseif IS_RANDOM_SHOW_AND_TELL_ENABLED then
    clearShowAndTellPokemon(item)
  end
end

function activateShowAndTellPokemon(item)
    item.IconMods = item.ItemState["enabledIconMods"]
    item.ItemState["isActive"] = true
end

function disableShowAndTellPokemon(item)
  item.IconMods = item.ItemState["disabledIconMods"]
  item.ItemState["isActive"] = false
end

function setShowAndTellPokemon(item, pokemon)
  item.Icon = ImageReference:FromPackRelativePath("images/pokemon/" .. pokemon:lower()  .. ".png")
  item.ItemState["isEmpty"] = false
  item.ItemState["pokemonId"] = pokemon
  
  if POKEMON_CAUGHT[pokemon] then
    activateShowAndTellPokemon(item)
  end
end

function clearShowAndTellPokemon(item)
    item.Icon = emptyIcon
    item.ItemState["isEmpty"] = true
    item.ItemState["pokemonId"] = nil
    disableShowAndTellPokemon(item)
end

function pokemonLeftClicked(item)
  if CURRENT_SHOW_AND_TELL_ITEM then
    setShowAndTellPokemon(CURRENT_SHOW_AND_TELL_ITEM, item.ItemState["pokemonId"])
    CURRENT_SHOW_AND_TELL_ITEM = nil
    Tracker:UiHint("ActivateTab", "Tracking")
  end
end

function resetShowAndTellItems()
  for _, item in pairs(SHOW_AND_TELL_ITEMS) do
    disableShowAndTellPokemon(item)
    if IS_RANDOM_SHOW_AND_TELL_ENABLED then
      clearShowAndTellPokemon(item)
    else
      item.Icon = item.ItemState["defaultIcon"]
    end
  end
end

for id, info in pairs(SHOW_AND_TELL_POKEMON) do
  local defaultIcon = ImageReference:FromPackRelativePath("images/pokemon/" .. info["defaultPokemonId"]:lower() .. ".png")
  local enabledIconMods = "overlay|images/showAndTell/" .. info["locationImage"] .. ".png"
  local disabledIconMods = "@disabled," .. enabledIconMods
  local item = ScriptHost:CreateLuaItem()
  item.Name = info["name"]
  item.PotentialCodes = {id}
  item.Icon = defaultIcon
  item.IconMods = disabledIconMods
  item.OnLeftClickFunc = showAndTellLeftClicked
  item.OnRightClickFunc = showAndTellRightClicked
  item.ItemState = {
    info = info,
    enabledIconMods = enabledIconMods,
    disabledIconMods = disabledIconMods,
    defaultIcon = defaultIcon,
    emptyIcon = emptyIcon,
    isEmpty = false,
    isActive = false,
    pokemonId = info["defaultPokemonId"],
  }
  
  if IS_RANDOM_SHOW_AND_TELL_ENABLED then
    clearShowAndTellPokemon(item)
  end
  
  SHOW_AND_TELL_ITEMS[id] = item
end

for id, name in pairs(POKEMON) do
  local item = ScriptHost:CreateLuaItem()
  item.Name = name
  item.PotentialCodes = {id}
  item.Icon = ImageReference:FromPackRelativePath("images/pokemon/" .. id:lower() .. ".png")
  item.OnLeftClickFunc = pokemonLeftClicked
  item.ItemState = {
    pokemonId = id,
  }
end