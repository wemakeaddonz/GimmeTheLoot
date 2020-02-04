if not _TEST then
    GUI = GimmeTheLoot:NewModule('GUI')
end

local AceGUI = LibStub('AceGUI-3.0')
local Search

function GUI:OnInitialize()
    Search = GimmeTheLoot:GetModule('Search')
end


--[[ Frame guide:

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

local FrameLayout = {
    mainFrame = {
        type = 'Frame',
        title = 'Roll History',
        layout = 'Flow',
        callbacks = {
            OnClose = function(widget)
                AceGUI:Release(widget)
            end,
        },
        children = {
            {
                type = 'Button',
                text = 'TestButton1',
                callbacks = {
                    OnClick = function(widget)
                        print("Test1")
                    end,
                },
            },
            {
                type = 'Button',
                text = 'TestButton2',
                callbacks = {
                    OnClick = function(widget)
                        print("Test2")
                    end,
                },
            },
        },
    },
}

function GUI.CreateFrame(frameInfo)
    local widget
    
    if frameInfo.type then
        widget = AceGUI:Create(frameInfo.type)
    end

    if frameInfo.title then
        widget:SetTitle(frameInfo.title)
    end

    if frameInfo.layout then
        widget:SetLayout(frameInfo.layout)
    end

    if frameInfo.text then
        widget:SetText(frameInfo.text)
    end

    if frameInfo.callbacks then
        for name, callback in pairs(frameInfo.callbacks) do
            widget:SetCallback(name, callback)
        end
    end

    if frameInfo.children then
        for _, child in ipairs(frameInfo.children) do
            widget:AddChild(GUI.CreateFrame(child))
        end
    end

    return widget
end

function GUI:DisplayFrame()
    local searchQuery = {quality = {}}

    local mainFrame = AceGUI:Create('Frame')
    local mainContainer = AceGUI:Create('SimpleGroup')
    local utilityContainer = AceGUI:Create('SimpleGroup')
    local searchBox = AceGUI:Create('EditBox')
    local qualityDropdown = AceGUI:Create('Dropdown')
    local resultsContainer = AceGUI:Create('InlineGroup')
    local recordsContainer = AceGUI:Create('ScrollFrame')

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
        self:RenderRecords(recordsContainer, Search:SearchRecords(searchQuery))
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
        self:RenderRecords(recordsContainer, Search:SearchRecords(searchQuery))
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

    self:RenderRecords(recordsContainer, Search:SearchRecords(searchQuery))
end

function GUI:RenderRecords(container, records)
    -- empty all records before rendering
    container:ReleaseChildren()
    for _, v in pairs(records) do
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
