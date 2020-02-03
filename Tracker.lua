if not _TEST then
    Tracker = GimmeTheLoot:NewModule('Tracker', 'AceEvent-3.0')
end

activeRollCounter = 0
activeRollTotal = 0

function Tracker:OnEnable()
    self:RegisterEvent('START_LOOT_ROLL', function()
        activeRollCounter = activeRollCounter + 1
        activeRollTotal = activeRollTotal + 1
    end)
    self:RegisterEvent('LOOT_ROLLS_COMPLETE', function()
        activeRollCounter = activeRollCounter - 1
        if activeRollCounter == 0 then
            Tracker:AddRolls(activeRollTotal)
            activeRollTotal = 0
        end
    end)
end

-- add loot rolls to database
function Tracker:AddRolls(numRolls)
end
