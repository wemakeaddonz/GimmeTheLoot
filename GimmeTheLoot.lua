if not _TEST then
    GimmeTheLoot =
        LibStub('AceAddon-3.0'):NewAddon('GimmeTheLoot', 'AceConsole-3.0', 'AceEvent-3.0')
end

local defaults = {profile = {rolls = {}}}
pendingLootSessions = {}

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
    if self.db.profile.rolls then self.db.profile.rolls = {} end
    self:Print('Database reset.')
end

-- TODO: Make this an actual class
--[[
    An example row in pendingLootSessions is:
    {
        item = "|cff1eff00|Hitem:4564::::::1097:639026432:60:::1::::|h[Spiked Club of the Boar]|h|r"
        rollID = 1
        rollTime = 1580064360
        rolls = {
            greeds = {
                "Dyamito" = 79
                "Etsumira" = 42
                "Congo" = 69
            },
            needs = {
                "Swazzle" = 1
            },
            passes = {
                "Muffinmaam",
            }
        },
        winner = "Swazzle"
    }
]]
function GimmeTheLoot:OnInitialize()
    -- TODO: use self vs GimmeTheLoot syntax
    self.db = LibStub('AceDB-3.0'):New('GTL_DB', defaults)

    LibStub('AceConfig-3.0'):RegisterOptionsTable('GimmeTheLoot', options, {'gimmetheloot', 'gtl'})

    self:RegisterEvent('START_LOOT_ROLL', function(_, ...)
        return GimmeTheLoot:START_LOOT_ROLL(...)
    end)
    self:RegisterEvent('LOOT_ITEM_AVAILABLE', function(_, ...)
        return GimmeTheLoot:LOOT_ITEM_AVAILABLE(...)
    end)
    self:RegisterEvent('CHAT_MSG_LOOT', function(_, ...)
        return GimmeTheLoot:CHAT_MSG_LOOT(...)
    end)
    self:RegisterEvent('LOOT_ROLLS_COMPLETE', function(_, ...)
        return GimmeTheLoot:LOOT_ROLLS_COMPLETE(...)
    end)
end

function GimmeTheLoot:START_LOOT_ROLL(rollID, _, lootHandle)
    pendingLootSessions[lootHandle] = {
        item = nil,
        rollID = rollID,
        -- intentionally ignore the rollTime arg as it seems to provide a constant value
        rollTime = time(),
        rolls = {greeds = {}, needs = {}, passes = {}},
        winner = nil,
    }
end

function GimmeTheLoot:LOOT_ITEM_AVAILABLE(item, lootHandle)
    local itemName = GetItemInfo(item)
    pendingLootSessions[lootHandle]['item'] = itemName
end

function GimmeTheLoot:CHAT_MSG_LOOT(text)
    for _, v in pairs(pendingLootSessions) do
        local lootMsgInfo = {GetLootMsgInfo(text, v['item'])}
        -- print(text)
        -- tprint(lootMsgInfo--)

        if lootMsgInfo then
            if lootMsgInfo[1] == 'greed' then
                v['rolls']['greeds'][lootMsgInfo[2]] = lootMsgInfo[3]
            elseif lootMsgInfo[1] == 'need' then
                v['rolls']['needs'][lootMsgInfo[2]] = lootMsgInfo[3]
            elseif lootMsgInfo[1] == 'pass' then
                v['rolls']['passes'][lootMsgInfo[2]] = true
            elseif lootMsgInfo[1] == 'win' then
                v['winner'] = lootMsgInfo[2]
            end
        end
    end
end

function GimmeTheLoot:LOOT_ROLLS_COMPLETE(lootHandle)
    table.insert(self.db.profile.rolls, pendingLootSessions[lootHandle])
    return pendingLootSessions[lootHandle]
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
        --itemName:SetText(v['item'])
        local itemInfo = {GetItemInfo(18805)}
        itemName:SetText(itemInfo[2])
        --itemName:SetImage(itemInfo[10])
        itemName:SetHighlight({255, 0, 0, 255})
        row:AddChild(itemName)

        local rollID = gui:Create('Label')
        rollID:SetRelativeWidth(.1)
        rollID:SetText(v['rollID'])
        row:AddChild(rollID)

        local rollTime = gui:Create('Label')
        rollTime:SetRelativeWidth(.25)
        rollTime:SetText(v['rollTime'])
        row:AddChild(rollTime)

        local winner = gui:Create('Label')
        winner:SetRelativeWidth(.25)
        winner:SetText(v['winner'])
        row:AddChild(winner)



        --local label = gui:Create('Label')
        --label:SetText(v['item'] .. v['winner'] .. date('%m/%d/%y %H:%M:%S', v['rollTime']))
        --scroll:AddChild(label)
    end

end

-- utility functions
function GetLootMsgInfo(msg, item)
    local passer, needer, greeder, roll, winner
    passer = string.match(msg, '%s(.+) passed on: .+' .. item)
    if passer then
        return 'pass', passer
    end

    roll, greeder = string.match(msg, 'Greed Roll %- (%d+) for .+' .. item .. '.+by (.+)')
    if greeder then
        return 'greed', greeder, tonumber(roll)
    end

    roll, needer = string.match(msg, 'Need Roll %- (%d+) for .+' .. item .. '.+ by (.+)')
    if needer then
        return 'need', needer, tonumber(roll)
    end

    winner = string.match(msg, '(.+) won: .+' .. item)
    if winner then
        return 'win', winner
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
