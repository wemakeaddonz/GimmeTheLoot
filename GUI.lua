if not _TEST then
    GUI = GimmeTheLoot:NewModule('GUI')
end

local AceGUI = LibStub('AceGUI-3.0')
local Search
local searchOffset = 0
local searchLimit = 30

function GUI:OnInitialize()
    Search = GimmeTheLoot:GetModule('Search')
end

function GUI:PerformSearch(container, search)
    searchOffset = 0 -- reset offset when searching
    container:ReleaseChildren()
    self:AppendRecords(container, Search:SearchRecords(search, searchLimit, searchOffset))
end

--[[ Frame guide:

+-mainFrame (Frame)---------------------------------------------+
|---mainContainer (SimpleGroup)---------------------------------|
|| +--utilityContainer (SimpleGroup)-------------------------+ ||
|| |                                                         | ||
|| |  +-searchBox (EditBox)--+                               | ||
|| |  |                      |                               | ||
|| |  +----------------------+                               | ||
|| |  +-qualityDropdown (Dropdown)--+                        | ||
|| |  |                             |                        | ||
|| |  +-----------------------------+                        | ||
|| |  +-loadMoreButton (Button)--+                           | ||
|| |  |                          |                           | ||
|| |  +--------------------------+                           | ||
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
function GUI:DisplayFrame()
    local searchQuery = {quality = {}, type = {}}

    local mainFrame = AceGUI:Create('Frame')
    local mainContainer = AceGUI:Create('SimpleGroup')
    local utilityContainer = AceGUI:Create('SimpleGroup')
    local searchBox = AceGUI:Create('EditBox')
    local qualityDropdown = AceGUI:Create('Dropdown')
    local loadMoreButton = AceGUI:Create('Button')
    local resultsContainer = AceGUI:Create('InlineGroup')
    local recordsContainer = AceGUI:Create('ScrollFrame')
    local typeDropdown = AceGUI:Create('Dropdown')

    mainFrame:SetTitle('Roll History')
    mainFrame:SetCallback('OnClose', function(widget)
        AceGUI:Release(widget)
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
        self:PerformSearch(recordsContainer, searchQuery)
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
        self:PerformSearch(recordsContainer, searchQuery)
    end)
    utilityContainer:AddChild(qualityDropdown)

    typeDropdown:SetList(GimmeTheLoot.Resources.ItemTypes)
    typeDropdown:SetMultiselect(true)
    typeDropdown:SetCallback('OnValueChanged', function(_, _, key, checked)
        searchQuery.type[key] = checked or nil
        self:PerformSearch(recordsContainer, searchQuery)
    end)
    utilityContainer:AddChild(typeDropdown)

    loadMoreButton:SetText('Load more records')
    loadMoreButton:SetDisabled(#GimmeTheLoot.db.profile.records < searchLimit)
    loadMoreButton:SetCallback('OnClick', function()
        searchOffset = searchOffset + searchLimit
        self:AppendRecords(recordsContainer,
                           Search:SearchRecords(searchQuery, searchLimit, searchOffset))
    end)
    utilityContainer:AddChild(loadMoreButton)

    resultsContainer:SetTitle('History:')
    resultsContainer:SetFullWidth(true)
    resultsContainer:SetFullHeight(true)
    resultsContainer:SetLayout('Fill')
    mainContainer:AddChild(resultsContainer)

    recordsContainer:SetLayout('List')
    recordsContainer:SetFullHeight(true)
    resultsContainer:AddChild(recordsContainer)

    self:AppendRecords(recordsContainer,
                       Search:SearchRecords(searchQuery, searchLimit, searchOffset))
end

function GUI:AppendRecords(container, records)
    for _, v in ipairs(records) do
        local recordContainer = AceGUI:Create('SimpleGroup')
        recordContainer:SetFullWidth(true)
        recordContainer:SetLayout('Flow')
        container:AddChild(recordContainer)

        local itemName = AceGUI:Create('InteractiveLabel')
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

        local rollTime = AceGUI:Create('Label')
        rollTime:SetRelativeWidth(.25)
        rollTime:SetText(date('%b %d %Y %I:%M %p', v['rollCompleted']))
        recordContainer:AddChild(rollTime)

        local winner = AceGUI:Create('Label')
        winner:SetRelativeWidth(.25)
        winner:SetText(v['winner'])
        recordContainer:AddChild(winner)
    end
end
