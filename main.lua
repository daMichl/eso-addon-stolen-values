-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
StolenValues = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
StolenValues.name = "StolenValues"

function StolenValues:FormatNumber(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

-- Next we create a function that will initialize our addon
function StolenValues:Initialize()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnSlotUpdate)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnSlotUpdate)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_FULL_UPDATE, self.OnSlotUpdate)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SKILLS_FULL_UPDATE, self.OnSlotUpdate)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, self.OnTargetChanged)

    

    self.savedVariables = ZO_SavedVars:New("StolenValuesSavedVariables", 2, nil, {})

    if self.savedVariables.left ~= nil then
    	self:RestorePosition()
	end
end

function StolenValues.OnIndicatorMoveStop()
	StolenValues.savedVariables.left = StolenValuesIndicator:GetLeft()
	StolenValues.savedVariables.top = StolenValuesIndicator:GetTop()
end


function StolenValues.OnSlotUpdate(event, bag, slot, isNewitem, itemSoundCategory, updateReason, stackCountChange)
	local value = 0

	if SHARED_INVENTORY.bagCache[BAG_BACKPACK] then
		for slotIndex, item in pairs(SHARED_INVENTORY.bagCache[BAG_BACKPACK])do
			if item.stolen then
				value = value + item.stackCount * GetItemSellValueWithBonuses(BAG_BACKPACK, slotIndex)
			end
		end
	end

	StolenValuesIndicator_Label:SetText(StolenValues:FormatNumber(value))
end

function StolenValues.OnTargetChanged(event)
  --d('changed')
end

function StolenValues.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == StolenValues.name then
    StolenValues:Initialize()
  end
end

function StolenValues:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  StolenValuesIndicator:ClearAnchors()
  StolenValuesIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(StolenValues.name, EVENT_ADD_ON_LOADED, StolenValues.OnAddOnLoaded)


-- EsoUI/Art/Inventory/inventory_stolenItem_icon.dds