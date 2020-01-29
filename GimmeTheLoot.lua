if not _TEST then
    GimmeTheLoot =
        LibStub('AceAddon-3.0'):NewAddon('GimmeTheLoot', 'AceConsole-3.0', 'AceEvent-3.0')
end

local defaults = {profile = {rolls = {}}}
pendingLootSessions = {}

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
    self:RegisterChatCommand('gtl', 'DisplayFrame')

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
    scroll:SetLayout('Flow') -- probably?
    scrollcontainer:AddChild(scroll)
end

function GimmeTheLoot:CmdDisplayold(_)
    -- display frame
    local gui = LibStub('AceGUI-3.0')
    local frame = gui:Create('Frame')
    frame:SetTitle('Roll History')
    frame:SetCallback('OnClose', function(widget)
        gui:Release(widget)
    end)
    frame:SetLayout('Fill')

    local _, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(13262)
    local _, itemLink2, _, _, _, _, _, _, _, itemIcon2 = GetItemInfo(19019)
    local _, itemLink3, _, _, _, _, _, _, _, itemIcon3 = GetItemInfo(13947)

    local testTable = {
        {
            value = 'weapons',
            text = 'weapons',
            children = {
                {value = '13262', text = itemLink, icon = itemIcon},
                {value = '19019', text = itemLink2, icon = itemIcon2},
            },
        },
        {value = '13947', text = itemLink3, icon = itemIcon3},
        {value = '', text = 'foobar'},
    }

    local tree = gui:Create('TreeGroup')
    tree:SetTree(testTable)
    tree:SetRelativeWidth(1)
    frame:AddChild(tree)
    tree:EnableButtonTooltips(false)
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
