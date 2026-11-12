IS_IMPROVED_CONSUMABLES_ENABLED = false

function shouldShowLocation(location)
  return true
end

function accessibilityLevelForLocation(location)
  local logicalResult = areRulesSatisfied(location, LOGICAL_ACCESS_RULES, "logical", {})
  if logicalResult == nil then
    return AccessibilityLevel.Inspect
  elseif logicalResult then
    return AccessibilityLevel.Normal
  else
    local strictResult = areRulesSatisfied(location, STRICT_ACCESS_RULES, "strict", {})
    if strictResult or strictResult == nil then
      return AccessibilityLevel.SequenceBreak
    else
      return AccessibilityLevel.None
    end
  end
end

function areRulesSatisfied(location, rules, level, previousEvents)
  local options = rules[location]
  
  for _, option in ipairs(options) do
    local success = true
    local partialSuccess = true
    
    for _, requirement in ipairs(option) do
      if type(requirement) == "number" then
        if not has("BADGE", requirement, rules, level, previousEvents) then
          success = false
          partialSuccess = false
          break
        end
      elseif type(requirement) == "table" then
        if not has(requirement["item"], requirement["number"], rules, level, previousEvents) then
          success = false
          partialSuccess = false
          break
        end
      else
        local result = has(requirement, 1, rules, level, previousEvents)
        if not result then
          success = false
          if result ~= nil then
            partialSuccess = false
            break
          end
        end
      end
    end
    
    if success then
      return true
    elseif partialSuccess then
      return nil
    end
  end
  
  return false
end

function has(item, amount, rules, level, previousEvents)
  if LINKED_EVENTS[item] then
    local location = Tracker:FindObjectForCode("@locations/" .. LINKED_EVENTS[item])
    if location.AvailableChestCount == 0 then
      return true
    else
      if previousEvents[item] then
        return false
      end
      
      previousEvents[item] = true
      
      local result = areRulesSatisfied(item, rules, level, previousEvents)
      
      previousEvents[item] = false
      
      if result then
        return nil
      else
        return false
      end
    end
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
  local isEvent = false
  
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
        isEvent = true
        break
      end
    end
  end
  
  if not isTrackableItem then
    return true
  end
  
  if IS_IMPROVED_CONSUMABLES_ENABLED and CONSUMABLE_ITEM_IDS[REVERSE_ITEMS_MAP[item]] and level == "logical" then
    item = item .. "_PLUS"
  end
  
  if Tracker:ProviderCountForCode(item) >= amount then
    return true
  elseif isEvent then
    if previousEvents[item] then
      return false
    end
    
    previousEvents[item] = true
    
    local result = areRulesSatisfied(item, rules, level, previousEvents)
    
    previousEvents[item] = false
    
    if result then
      return nil
    else
      return false
    end
  else
    return false
  end
end