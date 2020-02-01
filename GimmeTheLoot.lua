if not _TEST then
    GimmeTheLoot =
        LibStub('AceAddon-3.0'):NewAddon('GimmeTheLoot', 'AceConsole-3.0', 'AceEvent-3.0')
end

local defaults = {profile = {rolls = {}}}

local options = {
    name = 'GimmeTheLoot',
    handler = GimmeTheLoot,
    type = 'group',
    args = {
        show = {type = 'execute', name = 'Show', desc = 'Show roll history', func = 'DisplayFrame'},
        reset = {
            type = 'execute',
            name = 'Reset',
            desc = 'Reset this character\'s roll history',
            func = 'ResetDatabase',
        },
    },
}

function GimmeTheLoot:ResetDatabase(_)
    if self.db.profile.rolls then
        self.db.profile.rolls = {}
    end
    self:Print('Database reset.')
end

function GimmeTheLoot:OnInitialize()
    -- TODO: use self vs GimmeTheLoot syntax
    self.db = LibStub('AceDB-3.0'):New('GTL_DB', defaults)

    LibStub('AceConfig-3.0'):RegisterOptionsTable('GimmeTheLoot', options, {'gimmetheloot', 'gtl'})

    self:RegisterEvent('LOOT_HISTORY_ROLL_COMPLETE', function(_, ...)
        return GimmeTheLoot:rollcomplete(...)
    end)
end

function GimmeTheLoot:rollcomplete()
    local record = {item = {}, rolls = {}}

    local _, itemLink, numPlayers = C_LootHistory.GetItem(1)
    record['item']['link'] = itemLink

    for i = 1, numPlayers do
        name, _, rollType, roll, isWinner = C_LootHistory.GetPlayerInfo(1, i)
        table.insert(record['rolls'], {name = name, rollType = rollType, roll = roll})

        if isWinner then
            record['winner'] = name
        end
    end

    record['rollCompleted'] = time()

    table.insert(self.db.profile.rolls, record)
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

    for _, v in pairs(self.db.profile.rolls) do
        local row = gui:Create('SimpleGroup')
        row:SetFullWidth(true)
        row:SetLayout('Flow')
        scroll:AddChild(row)

        local itemName = gui:Create('InteractiveLabel')
        itemName:SetRelativeWidth(.4)
        itemName:SetText(v['item']['link'])
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
