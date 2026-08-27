require "TimedActions/ISBaseTimedAction"

local enable = SandboxVars.Wringer.Enable

local og_perform = ISWringClothing:perform
function ISWringClothing:perform()
    if not enable then
        og_perform(self)
    end

    self:stopSound()
    self.item:setJobDelta(0.0)
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)

    -- auto equip after wringing if it was equipped before
    if self.wasEquipped then
        ISTimedActionQueue.add(ISWearClothing:new(self.character, self.item, 50))
    end
end

local og_complete = ISWringClothing:complete
function ISWringClothing:complete()
    if not enable then
        og_complete(self)
    end

    local wetLevel = SandboxVars.Wringer.WetnessAfterWringing
    if self.item == nil then
        return false
    end
    if instanceof(self.item, "Clothing") then
        if self.item:getBodyLocation() == "Shoes" then
            self.item:setWetness(math.min(self.item:getWetness(), wetLevel))
        else
            self.item:setWetness(math.min(self.item:getWetness(), wetLevel))
        end
    end
    syncItemFields(self.character, self.item)
    return true
end

local og_getDuration = ISWringClothing:getDuration
function ISWringClothing:getDuration()
    if not enable then
        og_getDuration(self)
    end

    local durationOption = SandboxVars.Wringer.WringingDuration
    if self.item == nil then
        return 0
    end
    if self.character:isTimedActionInstant() then
        return 1
    end
    return math.ceil(self.item:getWetness() * durationOption)
end

function ISWringClothing:WringerContextMenu(playerNum, context)
    local player = getSpecificPlayer(playerNum)
    local wornItems = player:getWornItems():getItems()

    -- check if we have any wet clothes
    local wet = false
    for _, item in ipairs(wornItems) do
        if instanceof(item, "InventoryItem") and instanceof(item, "Clothing") then
            if item:getWetness() > 10 then wet = true break end
        end
    end
    if not wet then return end

    -- we have wet clothes 
    local function WringAllOption()
        for _, item in ipairs(wornItems) do
            if item:getWetness() > 10 then
                -- unequip
                ISTimedActionQueue.add(
                    ISUnequipAction:new(player, item, 50)
                )
                -- wring 
                ISTimedActionQueue.add(ISWringClothing:new(player, item))

                -- re-equip
                ISTimedActionQueue.add(
                    ISWearClothing:new(player, item, 50)
                )
            end
        end
    end

    context:addOption("Wring all clothes", player, WringAllOption)
end

Events.OnFillInventoryObjectContextMenu.Add(ISWringClothing.WringerContextMenu)