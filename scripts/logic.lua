function shouldShowLocation(location)
  return VISIBILITY_RULES[location]
end

function accessibilityLevelForLocation(location, isPhoneNumber)
  for _, item in pairs(SHOW_AND_TELL_ITEMS) do
    if item.ItemState["info"]["locationId"] == location and not item.ItemState["isActive"] then
      return AccessibilityLevel.None
    end
  end
  
  if location == "RUINS_OF_ALPH_OUTSIDE_MAIN_AREA_RESEARCHERS_GIFT" and Tracker:ProviderCountForCode("SHOW_AND_TELL_UNOWN") < 3 then
    return AccessibilityLevel.None
  end
  
  local phoneCallId = location:match("(.*)_PHONE_CALL")
  if phoneCallId then
    if Tracker:ProviderCountForCode(phoneCallId .. "_PHONE_NUMBER") > 0 then
      return accessibilityLevelForLocation(next(PHONE_CALLS[phoneCallId]["locationIds"], nil))
    else
      return AccessibilityLevel.None
    end
  end
  
  if not isPhoneNumber then
    for _, item in pairs(PHONE_CALL_ITEMS) do
      if item.ItemState["locationIds"][location] and not item.ItemState["currentCodes"][item.ItemState["phoneCallCode"]] then
        return AccessibilityLevel.None
      end
    end
  end
  
  if areRulesSatisfied(location, LOGICAL_ACCESS_RULES, "logical", {}) then
    return AccessibilityLevel.Normal
  elseif areRulesSatisfied(location, STRICT_ACCESS_RULES, "strict", {}) then
    return AccessibilityLevel.SequenceBreak
  else
    return AccessibilityLevel.None
  end
end

function areRulesSatisfied(location, rules, level, previousEvents)
  local options = rules[location]
  
  for _, option in ipairs(options) do
    local success = true
    
    for _, requirement in ipairs(option) do
      if type(requirement) == "number" then
        if not has("BADGE", requirement, rules, level, previousEvents) then
          success = false
          break
        end
      elseif type(requirement) == "table" then
        if not has(requirement["item"], requirement["number"], rules, level, previousEvents) then
          success = false
          break
        end
      else
        if not has(requirement, 1, rules, level, previousEvents) then
          success = false
          break
        end
      end
    end
    
    if success then
      return true
    end
  end
  
  return false
end

function has(item, amount, rules, level, previousEvents)
  if LINKED_EVENTS[item] then
    local location = Tracker:FindObjectForCode("@locations/" .. LINKED_EVENTS[item])
    return location.AvailableChestCount == 0
  end
  
  if UNTRACKED_EVENTS[item] then
    if previousEvents[item] then
      return false
    end
    
    previousEvents[item] = true
    
    local result = areRulesSatisfied(item, rules, level, previousEvents)
    
    previousEvents[item] = false
    
    return result
  end
  
  local isTrackableItem = item == "BADGE"
  
  if not isTrackableItem then
    for _, code in pairs(ITEMS_MAP) do
      if code == item then
        isTrackableItem = true
        break
      end
    end
    
    for code, _ in pairs(EVENT_NAMES) do
      if code == item then
        isTrackableItem = true
        break
      end
    end
  end
  
  if not isTrackableItem then
    return true
  end
  
  if IS_IMPROVED_CONSUMABLES_ENABLED and CONSUMABLE_ITEM_IDS[REVERSE_ITEMS_MAP[item]] and level == "logical" then
    item = item .. "_PLUS"
  elseif item == "BERRY" then
    item = item .. "_" .. amount
    amount = 1
  end
  
  
  return Tracker:ProviderCountForCode(item) >= amount
end