require "TimedActions/ISBaseTimedAction"

ISWringClothing = ISBaseTimedAction:derive("ISWringClothing")



function ISWringClothing:getDuration()
    if self.item == nil then
        return 0
    end
    if self.character:isTimedActionInstant() then
        return 1
    end
    return math.ceil(self.item:getWetness() * 1)
end