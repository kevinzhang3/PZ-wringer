require "TimedActions/ISBaseTimedAction"

function ISWringClothing:getDuration()
    local durationOption = SandboxVars.wringer.WringingDuration
    if self.item == nil then
        return 0
    end
    if self.character:isTimedActionInstant() then
        return 1
    end
    return math.ceil(self.item:getWetness() * durationOption)
end