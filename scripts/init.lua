Tracker.AllowDeferredLogicUpdate = true

function initializeGlobals()
  IS_IMPROVED_CONSUMABLES_ENABLED = false
  IS_RANDOM_SHOW_AND_TELL_ENABLED = false
  CURRENT_SHOW_AND_TELL_ITEM = nil
  SHOP_ITEMS_REMAINING = {}
  IMPORTANT_SHOP_ITEMS_REMAINING = {}
  SHOP_LOCATIONS_PROCESSED_FOR_IMPORTANT_SHOPS = {}
  VIEWED_SHOPS = {}
  RENEWABLE_SHOPS = {}
  COLLECTED_LOCATIONS = {}
  TRACKED_SHOP_SCOUTS = {}
  COLLECTED_EVENTS_KEY = ""
  CURRENT_MAP_KEY = ""
  VIEWED_SHOPS_KEY = ""
  SHOW_AND_TELL_POKEMON_ASSIGNMENTS = {}
  POKEMON_CAUGHT = {}
end

initializeGlobals()

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/events.json")
Tracker:AddItems("items/hostedEvents.json")
Tracker:AddItems("items/hostedPhoneCalls.json")
Tracker:AddItems("items/showAndTellPokemon.json")
Tracker:AddItems("items/settings.json")

-- Maps
Tracker:AddMaps("maps/maps.json")

-- Locations
Tracker:AddLocations("locations/locations.json")
Tracker:AddLocations("locations/nodes.json")

-- Layout
Tracker:AddLayouts("layouts/settings.json")
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/events.json")
Tracker:AddLayouts("layouts/pokemon.json")
Tracker:AddLayouts("layouts/showAndTell.json")
Tracker:AddLayouts("layouts/phoneCalls.json")
Tracker:AddLayouts("layouts/broadcast.json")
Tracker:AddLayouts("layouts/maps.json")
Tracker:AddLayouts("layouts/tracker.json")

-- Scripts
ScriptHost:LoadScript("scripts/rules/vanilla/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/vanilla/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/vanilla/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_kir/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_kir/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_kir/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_extreme_kir/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_extreme_kir/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_extreme_kir/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_fir/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_fir/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_fir/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_extreme_fir/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_extreme_fir/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_extreme_fir/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_crazy_fir/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_crazy_fir/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_crazy_fir/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_max/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_max/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/classic_max/visibilityRules.lua")
ScriptHost:LoadScript("scripts/rules/maximum_plus/logicalAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/maximum_plus/strictAccessRules.lua")
ScriptHost:LoadScript("scripts/rules/maximum_plus/visibilityRules.lua")
ScriptHost:LoadScript("scripts/items.lua")
ScriptHost:LoadScript("scripts/consumables.lua")
ScriptHost:LoadScript("scripts/locations.lua")
ScriptHost:LoadScript("scripts/events.lua")
ScriptHost:LoadScript("scripts/maps.lua")
ScriptHost:LoadScript("scripts/logic.lua")
ScriptHost:LoadScript("scripts/pokemon.lua")
ScriptHost:LoadScript("scripts/showAndTellPokemon.lua")
ScriptHost:LoadScript("scripts/phoneCalls.lua")
ScriptHost:LoadScript("scripts/pokemonTracking.lua")
ScriptHost:LoadScript("scripts/phoneCallTracking.lua")
ScriptHost:LoadScript("scripts/archipelago.lua")

-- Settings
Tracker:FindObjectForCode("AUTO_TAB").Active = true
Tracker:FindObjectForCode("SMART_MARTS").Active = true

PREVIOUS_MANUAL_SETTINGS_STAGE = 1

-- Watches
function update_logic_settings()
  if PREVIOUS_MANUAL_SETTINGS_STAGE == Tracker:FindObjectForCode("MANUAL_LOGIC_SETTINGS").CurrentStage then
    return
  end
  
  if Archipelago.PlayerNumber ~= -1 then
    Tracker:FindObjectForCode("MANUAL_LOGIC_SETTINGS").CurrentStage = PREVIOUS_MANUAL_SETTINGS_STAGE
    return
  end
  
  PREVIOUS_MANUAL_SETTINGS_STAGE = Tracker:FindObjectForCode("MANUAL_LOGIC_SETTINGS").CurrentStage
  
  if PREVIOUS_MANUAL_SETTINGS_STAGE == 1 then
    VISIBILITY_RULES = CLASSIC_KIR_VISIBILITY_RULES
    STRICT_ACCESS_RULES = CLASSIC_KIR_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = CLASSIC_KIR_LOGICAL_ACCESS_RULES
  elseif PREVIOUS_MANUAL_SETTINGS_STAGE == 2 then
    VISIBILITY_RULES = CLASSIC_EXTREME_KIR_VISIBILITY_RULES
    STRICT_ACCESS_RULES = CLASSIC_EXTREME_KIR_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = CLASSIC_EXTREME_KIR_LOGICAL_ACCESS_RULES
  elseif PREVIOUS_MANUAL_SETTINGS_STAGE == 3 then
    VISIBILITY_RULES = CLASSIC_FIR_VISIBILITY_RULES
    STRICT_ACCESS_RULES = CLASSIC_FIR_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = CLASSIC_FIR_LOGICAL_ACCESS_RULES
  elseif PREVIOUS_MANUAL_SETTINGS_STAGE == 4 then
    VISIBILITY_RULES = CLASSIC_EXTREME_FIR_VISIBILITY_RULES
    STRICT_ACCESS_RULES = CLASSIC_EXTREME_FIR_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = CLASSIC_EXTREME_FIR_LOGICAL_ACCESS_RULES
  elseif PREVIOUS_MANUAL_SETTINGS_STAGE == 5 then
    VISIBILITY_RULES = CLASSIC_CRAZY_FIR_VISIBILITY_RULES
    STRICT_ACCESS_RULES = CLASSIC_CRAZY_FIR_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = CLASSIC_CRAZY_FIR_LOGICAL_ACCESS_RULES
  elseif PREVIOUS_MANUAL_SETTINGS_STAGE == 6 then
    VISIBILITY_RULES = CLASSIC_MAX_VISIBILITY_RULES
    STRICT_ACCESS_RULES = CLASSIC_MAX_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = CLASSIC_MAX_LOGICAL_ACCESS_RULES
  elseif PREVIOUS_MANUAL_SETTINGS_STAGE == 7 then
    VISIBILITY_RULES = MAXIMUM_PLUS_VISIBILITY_RULES
    STRICT_ACCESS_RULES = MAXIMUM_PLUS_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = MAXIMUM_PLUS_LOGICAL_ACCESS_RULES
    IS_RANDOM_SHOW_AND_TELL_ENABLED = true
    resetShowAndTellItems()
  else
    VISIBILITY_RULES = VANILLA_VISIBILITY_RULES
    STRICT_ACCESS_RULES = VANILLA_STRICT_ACCESS_RULES
    LOGICAL_ACCESS_RULES = VANILLA_LOGICAL_ACCESS_RULES
    IS_RANDOM_SHOW_AND_TELL_ENABLED = false
    resetShowAndTellItems()
  end
  
  Tracker:FindObjectForCode("UPDATE_INVOKER").Active = not Tracker:FindObjectForCode("UPDATE_INVOKER").Active
end

update_logic_settings()

ScriptHost:AddWatchForCode("MANUAL_LOGIC_SETTINGS", "MANUAL_LOGIC_SETTINGS", update_logic_settings)

function toggle_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code .. "_HOSTED"
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  end
end

function toggle_hosted_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code:gsub("_HOSTED", "")
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  end
end

function upgrade_berry()
  if IS_IMPROVED_CONSUMABLES_ENABLED then
    local object = Tracker:FindObjectForCode("BERRY")
    if object.CurrentStage == 2 then
      object.CurrentStage = 8
    elseif object.CurrentStage == 7 then
      object.CurrentStage = 1
    end
  end
end

for code, _ in pairs(EVENT_NAMES) do
  ScriptHost:AddWatchForCode(code, code, toggle_item)
  ScriptHost:AddWatchForCode(code .. "_HOSTED", code .. "_HOSTED", toggle_hosted_item)
end

ScriptHost:AddWatchForCode("BERRY", "BERRY", upgrade_berry)

local resetListener = Tracker:FindObjectForCode("RESET_LISTENER")

function resetAdditionalState()
  initializeGlobals()
  resetShowAndTellItems()
  resetPhoneCallItems()
  resetListener.Active = true
end

function onFrameHandler()
  if not resetListener.Active then
    resetAdditionalState()
  end
end

ScriptHost:AddOnFrameHandler("onFrameHandler", onFrameHandler)