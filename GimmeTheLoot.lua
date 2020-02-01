if not _TEST then
    GimmeTheLoot =
        LibStub('AceAddon-3.0'):NewAddon('GimmeTheLoot', 'AceConsole-3.0', 'AceEvent-3.0')
end

local defaults = {profile = {records = {}}}

local options = {
    name = 'GimmeTheLoot',
    handler = GimmeTheLoot,
    type = 'group',
    args = {
        show = {
            type = 'execute',
            name = 'Show',
            desc = 'Show roll history',
            func = 'DisplayFrame',
        },
        reset = {
            type = 'execute',
            name = 'Reset',
            desc = 'Reset this character\'s roll history',
            func = 'ResetDatabase',
        },
    },
}

function GimmeTheLoot:ResetDatabase(_)
    if self.db.profile.records then
        self.db.profile.records = {}
    end
    self:Print('Database reset.')
end

local lootCounter = 0
local lootCounterMax = 0

function GimmeTheLoot:OnInitialize()
    -- TODO: use self vs GimmeTheLoot syntax
    self.db = LibStub('AceDB-3.0'):New('GTL_DB', defaults)

    LibStub('AceConfig-3.0'):RegisterOptionsTable('GimmeTheLoot', options, {'gimmetheloot', 'gtl'})

    self:RegisterEvent('LOOT_ROLLS_COMPLETE', function(_, ...)
        return GimmeTheLoot:LootRollsComplete(...)
    end)
    self:RegisterEvent('START_LOOT_ROLL', function(_, _)
        lootCounter = lootCounter + 1
        lootCounterMax = lootCounterMax + 1
    end)
end

function GimmeTheLoot:LootRollsComplete(_)
    lootCounter = lootCounter - 1
    if lootCounter > 0 then
         return
    end

    for i=1,lootCounterMax do
        local record = {item = {}, rolls = {}}
        local _, itemLink, numPlayers = C_LootHistory.GetItem(i)

        record.item.link = itemLink

        for p=1, numPlayers do
            local playerName, _, rollType, rollValue, isWinner = C_LootHistory.GetPlayerInfo(i, p)

            table.insert(record.rolls, {name = playerName, type = rollType, roll = rollValue})

            if isWinner then
                record.winner = playerName
            end
        end

        record.rollCompleted = time()
        table.insert(self.db.profile.records, record)
    end

    lootCounterMax = 0
end

function GimmeTheLoot:DisplayFrame()
    local gui = LibStub('AceGUI-3.0')
    local frame = gui:Create('Frame')
    frame:SetTitle('Roll History')
    frame:SetCallback('OnClose', function(widget)
        gui:Release(widget)
    end)
    frame:SetLayout('Fill')

    local scrollcontainer = gui:Create('SimpleGroup') -- "InlineGroup" is also good
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout('Fill') -- important!
    frame:AddChild(scrollcontainer)

    local scroll = gui:Create('ScrollFrame')
    scroll:SetLayout('List') -- probably?
    scrollcontainer:AddChild(scroll)

    for _, v in pairs(self.db.profile.records) do
        local row = gui:Create('SimpleGroup')
        row:SetFullWidth(true)
        row:SetLayout('Flow')
        scroll:AddChild(row)

        local itemName = gui:Create('InteractiveLabel')
        itemName:SetRelativeWidth(.4)
        itemName:SetText(v.item.link)
        -- itemName:SetImage(itemInfo[10])
        itemName:SetHighlight({255, 0, 0, 255})
        row:AddChild(itemName)

        local rollTime = gui:Create('Label')
        rollTime:SetRelativeWidth(.25)
        rollTime:SetText(date('%b %d %Y %I:%M %p', v['rollCompleted']))
        row:AddChild(rollTime)

        local winner = gui:Create('Label')
        winner:SetRelativeWidth(.25)
        winner:SetText(v['winner'])
        row:AddChild(winner)
    end
end

-- debugging functions
function tprint(tbl, indent)
    if not indent then
        indent = 0
    end
    for k, v in pairs(tbl) do
        local formatting = string.rep('  ', indent) .. k .. ': '
        if type(v) == 'table' then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end
