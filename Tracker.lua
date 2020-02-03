if not _TEST then
    Tracker = GimmeTheLoot:NewModule('Tracker', 'AceEvent-3.0')
end

local LootHistoryGetItem = C_LootHistory.GetItem
local LootHistoryGetPlayerInfo = C_LootHistory.GetPlayerInfo

-- register loot events
function Tracker:OnEnable()
    local activeRollCounter = 0
    local activeRollTotal = 0

    -- increase counter whenever a loot roll starts
    self:RegisterEvent('START_LOOT_ROLL', function()
        activeRollCounter = activeRollCounter + 1
        activeRollTotal = activeRollTotal + 1
    end)

    -- decrease counter whenever a loot roll ends
    -- if counter == 0, all active loot rolls have ended, so call AddRolls and reset total
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
    for i = 1, numRolls do
        local record = {item = {}, rolls = {}}
        local _, itemLink, numPlayers = LootHistoryGetItem(i)
        local itemName, _, itemQuality = GetItemInfo(itemLink)

        record.item.link = itemLink
        record.item.name = itemName
        record.item.quality = itemQuality

        for p = 1, numPlayers do
            local playerName, _, rollType, rollValue, isWinner = LootHistoryGetPlayerInfo(i, p)

            table.insert(record.rolls, {name = playerName, type = rollType, roll = rollValue})
            record.winner = isWinner and playerName
        end
    end

    record.rollCompleted = time()
    table.insert(GimmeTheLoot.db.profile.records, record) -- needs test
end
