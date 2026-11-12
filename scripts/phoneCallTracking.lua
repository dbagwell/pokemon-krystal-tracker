PHONE_CALL_ITEMS = {}
HOSTED_PHONE_NUMBER_ITEMS = {}
HOSTED_PHONE_CALL_ITEMS = {}

function activatePhoneNumber(baseItem)
  if not baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneNumberCode"]] then
    baseItem.Name = baseItem.ItemState["phoneNumberName"]
    baseItem.IconMods = baseItem.ItemState["phoneNumberIconMods"]
    baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneNumberCode"]] = true
    Tracker:FindObjectForCode(baseItem.ItemState["phoneNumberCode"] .. "_HOSTED").Active = true
  end
end

function disablePhoneNumber(baseItem)
  if baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneNumberCode"]] then
    baseItem.Name = baseItem.ItemState["phoneNumberName"]
    baseItem.IconMods = baseItem.ItemState["disabledIconMods"]
    baseItem.ItemState["currentCodes"] = {}
    Tracker:FindObjectForCode(baseItem.ItemState["phoneNumberCode"] .. "_HOSTED").Active = false
    Tracker:FindObjectForCode(baseItem.ItemState["phoneCallCode"] .. "_HOSTED").Active = false
  end
end

function activatePhoneCall(baseItem)
  if not baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneCallCode"]] then
    baseItem.Name = baseItem.ItemState["phoneCallName"]
    baseItem.IconMods = baseItem.ItemState["phoneCallIconMods"]
    baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneNumberCode"]] = true
    baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneCallCode"]] = true
    Tracker:FindObjectForCode(baseItem.ItemState["phoneNumberCode"] .. "_HOSTED").Active = true
    Tracker:FindObjectForCode(baseItem.ItemState["phoneCallCode"] .. "_HOSTED").Active = true
  end
end

function disablePhoneCall(baseItem)
  if baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneCallCode"]] then
    baseItem.Name = baseItem.ItemState["phoneNumberName"]
    baseItem.IconMods = baseItem.ItemState["phoneNumberIconMods"]
    baseItem.ItemState["currentCodes"][baseItem.ItemState["phoneCallCode"]] = false
    Tracker:FindObjectForCode(baseItem.ItemState["phoneCallCode"] .. "_HOSTED").Active = false
  end
end

function doesPhoneCallItemProvideCode(item, code)
  return item.ItemState["currentCodes"][code] == true
end

function phoneCallItemLeftClicked(item)
  if item.ItemState["currentCodes"][item.ItemState["phoneNumberCode"]] then
    activatePhoneCall(item)
  else
    activatePhoneNumber(item)
  end
end

function phoneCallItemRightClicked(item)
  if item.ItemState["currentCodes"][item.ItemState["phoneCallCode"]] then
    disablePhoneCall(item)
  else
    disablePhoneNumber(item)
  end
end

function hostedPhoneNumberItemLeftClicked(hostedNumberItem)
  local baseItem = Tracker:FindObjectForCode(hostedNumberItem.ItemState["baseCode"])
  activatePhoneNumber(baseItem)
end

function hostedPhoneNumberItemRightClicked(item)
  local baseItem = Tracker:FindObjectForCode(item.ItemState["baseCode"])
  disablePhoneNumber(baseItem)
end

function hostedPhoneCallItemLeftClicked(hostedNumberItem)
  local baseItem = Tracker:FindObjectForCode(hostedNumberItem.ItemState["baseCode"])
  activatePhoneCall(baseItem)
end

function hostedPhoneCallItemRightClicked(item)
  local baseItem = Tracker:FindObjectForCode(item.ItemState["baseCode"])
  disablePhoneCall(baseItem)
end

function resetPhoneCallItems()
  for _, item in pairs(PHONE_CALL_ITEMS) do
    disablePhoneNumber(item)
  end
end

function hostedPhoneNumberItemUpdated(code)
  local baseItem = Tracker:FindObjectForCode(code:match("(.*)_HOSTED"))
  toggleHostedItemWatches(baseItem, false)
  if Tracker:FindObjectForCode(code).Active then
    activatePhoneNumber(baseItem)
  else
    disablePhoneNumber(baseItem)
  end
  toggleHostedItemWatches(baseItem, true)
end

function hostedPhoneCallItemUpdated(code)
  local baseItem = Tracker:FindObjectForCode(code:match("(.*)_HOSTED"))
  toggleHostedItemWatches(baseItem, false)
  if Tracker:FindObjectForCode(code).Active then
    activatePhoneCall(baseItem)
  else
    disablePhoneCall(baseItem)
  end
  toggleHostedItemWatches(baseItem, true)
end

function toggleHostedItemWatches(baseItem, enableWatches)
  if enableWatches then
    ScriptHost:AddWatchForCode(baseItem.ItemState["phoneNumberCode"] .. "_HOSTED", baseItem.ItemState["phoneNumberCode"] .. "_HOSTED", hostedPhoneNumberItemUpdated)
    ScriptHost:AddWatchForCode(baseItem.ItemState["phoneCallCode"] .. "_HOSTED", baseItem.ItemState["phoneCallCode"] .. "_HOSTED", hostedPhoneCallItemUpdated)
  else
    ScriptHost:RemoveWatchForCode(baseItem.ItemState["phoneNumberCode"] .. "_HOSTED")
    ScriptHost:RemoveWatchForCode(baseItem.ItemState["phoneCallCode"] .. "_HOSTED")
  end
end

for id, info in pairs(PHONE_CALLS) do
  local baseItem = ScriptHost:CreateLuaItem()
  
  baseItem.ItemState = {
    phoneNumberName = info["name"] .. " - Registered Number",
    phoneCallName = info["name"] .. " - Received Call",
    disabledIconMods = "@disabled",
    phoneNumberIconMods = "dim",
    phoneCallIconMods = "",
    phoneNumberCode = id .. "_PHONE_NUMBER",
    phoneCallCode = id .. "_PHONE_CALL",
    locationIds = info["locationIds"],
    currentCodes = {},
  }
  
  baseItem.Name = baseItem.ItemState["phoneNumberName"]
  baseItem.PotentialCodes = {baseItem.ItemState["phoneNumberCode"], baseItem.ItemState["phoneCallCode"]}
  baseItem.Icon = ImageReference:FromPackRelativePath("images/locations/" .. info["sprite"] .. ".png")
  baseItem.IconMods = baseItem.ItemState["disabledIconMods"]
  baseItem.OnLeftClickFunc = phoneCallItemLeftClicked
  baseItem.OnRightClickFunc = phoneCallItemRightClicked
  baseItem.ProvidesCodeFunc = doesPhoneCallItemProvideCode
  
  PHONE_CALL_ITEMS[id] = baseItem
  
  toggleHostedItemWatches(baseItem, true)
end
