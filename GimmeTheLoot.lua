if not _TEST then
  GimmeTheLoot = LibStub("AceAddon-3.0"):NewAddon("GimmeTheLoot", "AceConsole-3.0", "AceEvent-3.0")
end

local defaults = {
  profile = {
    rolls = {}
  }
}

local function ItemIdFromRoll(rollID)
  -- TODO: implement
  return rollID
end

function GimmeTheLoot:TrackLootRoll(rollID, rollTime, lootHandle) -- luacheck: no unused args
  table.insert(self.db.profile.rolls, {
                 time = rollTime,
                 itemId = ItemIdFromRoll(rollID)
  })
end

function GimmeTheLoot:OnInitialize()
  -- TODO: use self vs GimmeTheLoot syntax
  self.db = LibStub("AceDB-3.0"):New("GTL_DB", defaults)
  self:RegisterEvent("START_LOOT_ROLL", "TrackLootRoll")
end

function GimmeTheLoot:OnEnable()
  self:Print("GimmeTheLoot enabled")
end
