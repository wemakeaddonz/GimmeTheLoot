if not _TEST then
    GimmeTheLoot =
        LibStub('AceAddon-3.0'):NewAddon('GimmeTheLoot', 'AceConsole-3.0', 'AceEvent-3.0')
end

local defaults = {profile = {rolls = {}}}

local function ItemIdFromRoll(rollID)
    -- TODO: implement
    return rollID
end

function GimmeTheLoot:TrackLootRoll(rollID, rollTime, lootHandle) -- luacheck: no unused args
    table.insert(self.db.profile.rolls, {time = rollTime, itemId = ItemIdFromRoll(rollID)})
end

function GimmeTheLoot:OnInitialize()
    -- TODO: use self vs GimmeTheLoot syntax
    self.db = LibStub('AceDB-3.0'):New('GTL_DB', defaults)
    self:RegisterEvent('START_LOOT_ROLL', 'TrackLootRoll')
    self:RegisterChatCommand('gtl', 'CmdDisplay')
end

function GimmeTheLoot:OnEnable()
    self:Print('GimmeTheLoot enabled')
    GimmeTheLoot:AddDummyRoll()
end

function GimmeTheLoot:AddDummyRoll()
    table.insert(self.db.profile.rolls,
                 {time = 1, itemId = 13262, type = 'need', won = true, value = 1})
end

function GimmeTheLoot:CmdDisplay()
    GimmeTheLoot:DisplayFrame()
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
