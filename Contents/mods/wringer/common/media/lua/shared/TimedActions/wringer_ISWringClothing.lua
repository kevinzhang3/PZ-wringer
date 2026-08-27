require "TimedActions/ISBaseTimedAction"

local enable = SandboxVars.Wringer.Enable

function ISWringClothing:perform()
    if not enable then
        ISWringClothing:getDuration()
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

function ISWringClothing:getDuration()
    local durationOption = SandboxVars.Wringer.WringingDuration
    if not enable then
        ISWringClothing:getDuration()
    end

    -- custom code 
    if self.item == nil then
        return 0
    end
    if self.character:isTimedActionInstant() then
        return 1
    end
    return math.ceil(self.item:getWetness() * durationOption)
end

function ISWringClothing:WringerContextMenu(playerNum, context, items)
    local player = getSpecificPlayer(playerNum)

    -- check if we have any wet clothes
    for index, item in ipairs(items) do
        if instanceof(item, "InventoryItem") and instanceof(item, "Clothing") then
            if item:getWetness() <= 10 then return else break end
        end
    
    local function WringAllOption()
        for _, item in ipairs(player:getWornItems()) do
            if item:getWetness() > 10 then
                -- unequip
                ISTimedActionQueue.add(
                    ISUnequipAction:new(character, item, 50)
                )
                -- wring 
                ISTimedActionQueue.add(ISWringClothing:new(character, item))

                -- re-equip
                ISTimedActionQueue.add(
                    ISWearClothing:new(character, item, 50)
                )
            end
        end
    end

    context:addOption("Wring all clothes", player, WringAllOption)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(ISWringClothing.WringerContextMenu)