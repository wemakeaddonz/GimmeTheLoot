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

    for i = 1, lootCounterMax do
        local record = {item = {}, rolls = {}}
        local _, itemLink, numPlayers = C_LootHistory.GetItem(i)
        local itemName, _, itemQuality = GetItemInfo(itemLink)

        record.item.link = itemLink
        record.item.name = itemName
        record.item.quality = itemQuality

        for p = 1, numPlayers do
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

-- consider memoizing
function GimmeTheLoot:SearchMatchItemText(text, record)
    return not text or text == '' or string.find(string.lower(record.item.name), string.lower(text))
end

-- consider memoizing
function GimmeTheLoot:SearchMatchItemQuality(quality, record)
    return not quality or next(quality) == nil or quality[record.item.quality]
end

function GimmeTheLoot:SearchRecords(search)
    local results = {}
    search = search or {}

    for _, record in pairs(self.db.profile.records) do
        if record.item.name and record.item.quality then
            if self:SearchMatchItemText(search.text, record) and
                self:SearchMatchItemQuality(search.quality, record) then
                table.insert(results, record)
            end
        end
    end

    return results
end

function GimmeTheLoot:DisplayFrame()
    --[[
+-mainFrame (Frame)---------------------------------------------+
|---mainContainer (SimpleGroup)---------------------------------|
|| +--utilityContainer (SimpleGroup)-------------------------+ ||
|| |                                                         | ||
|| |  +-searchBox (EditBox)--+                               | ||
|| |  |                      |                               | ||
|| |  +----------------------+                               | ||
|| +---------------------------------------------------------+ ||
||                                                             ||
|| +-resultsContainer (SimpleGroup)--------------------------+ ||
|| |                                                         | ||
|| | +--recordsContainer (ScrollFrame)---------------------+ | ||
|| | |                                                     | | ||
|| | | +--recordContainer (SimpleGroup)------------------+ | | ||
|| | | |                                                 | | | ||
|| | | |                                                 | | | ||
|| | | +-------------------------------------------------+ | | ||
|| | |                                                     | | ||
|| | |                                                     | | ||
|| | |                                                     | | ||
|| | |                                                     | | ||
|| | +-----------------------------------------------------+ | ||
|| +---------------------------------------------------------+ ||
|---------------------------------------------------------------|
+---------------------------------------------------------------+
    --]]
    local gui = LibStub('AceGUI-3.0')
    local searchQuery = {quality = {}}

    local mainFrame = gui:Create('Frame')
    local mainContainer = gui:Create('SimpleGroup')
    local utilityContainer = gui:Create('SimpleGroup')
    local searchBox = gui:Create('EditBox')
    local qualityDropdown = gui:Create('Dropdown')
    local resultsContainer = gui:Create('InlineGroup')
    local recordsContainer = gui:Create('ScrollFrame')

    mainFrame:SetTitle('Roll History')
    mainFrame:SetCallback('OnClose', function(widget)
        gui:Release(widget)
    end)
    mainFrame:SetLayout('Fill')

    mainContainer:SetLayout('Flow')
    mainFrame:AddChild(mainContainer)

    utilityContainer:SetLayout('Flow')
    mainContainer:AddChild(utilityContainer)

    searchBox:SetLabel('search')
    searchBox:DisableButton(true)
    searchBox:SetMaxLetters(20)
    searchBox:SetCallback('OnTextChanged', function(_, _, text)
        searchQuery.text = text
        self:RenderRecords(recordsContainer, self:SearchRecords(searchQuery))
    end)
    utilityContainer:AddChild(searchBox)

    qualityDropdown:SetList({
        [2] = '|cff00ff00Uncommon',
        [3] = '|cff0000ffRare',
        [4] = '|cffa335eeEpic',
        [5] = '|cffff8000Legendary',
    })
    qualityDropdown:SetMultiselect(true)
    qualityDropdown:SetCallback('OnValueChanged', function(_, _, key, checked)
        searchQuery.quality[key] = checked or nil
        self:RenderRecords(recordsContainer, self:SearchRecords(searchQuery))
    end)
    utilityContainer:AddChild(qualityDropdown)

    resultsContainer:SetTitle('History:')
    resultsContainer:SetFullWidth(true)
    resultsContainer:SetFullHeight(true)
    resultsContainer:SetLayout('Fill')
    mainContainer:AddChild(resultsContainer)

    recordsContainer:SetLayout('List')
    recordsContainer:SetFullHeight(true)
    resultsContainer:AddChild(recordsContainer)

    self:RenderRecords(recordsContainer, self:SearchRecords(searchQuery))
end

function GimmeTheLoot:RenderRecords(container, records)
    local gui = LibStub('AceGUI-3.0')

    -- empty all records before rendering
    container:ReleaseChildren()
    for _, v in pairs(records) do
        local recordContainer = gui:Create('SimpleGroup')
        recordContainer:SetFullWidth(true)
        recordContainer:SetLayout('Flow')
        container:AddChild(recordContainer)

        local itemName = gui:Create('InteractiveLabel')
        itemName:SetRelativeWidth(.4)
        itemName:SetText(v.item.link)
        itemName:SetHighlight({255, 0, 0, 255})
        itemName:SetUserData('text', v.item.link)
        itemName:SetCallback('OnEnter', function(widget)
            GameTooltip:SetOwner(widget.frame, 'ANCHOR_LEFT')
            GameTooltip:SetHyperlink(widget:GetUserData('text'))
            GameTooltip:Show()
        end)
        itemName:SetCallback('OnLeave', function()
            GameTooltip:Hide()
        end)
        recordContainer:AddChild(itemName)

        local rollTime = gui:Create('Label')
        rollTime:SetRelativeWidth(.25)
        rollTime:SetText(date('%b %d %Y %I:%M %p', v['rollCompleted']))
        recordContainer:AddChild(rollTime)

        local winner = gui:Create('Label')
        winner:SetRelativeWidth(.25)
        winner:SetText(v['winner'])
        recordContainer:AddChild(winner)
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
