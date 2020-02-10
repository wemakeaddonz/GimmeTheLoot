if not _TEST then
    GimmeTheLoot = LibStub('AceAddon-3.0'):NewAddon('GimmeTheLoot', 'AceConsole-3.0')
end

-- modules
local GUI

local defaults = {profile = {records = {}}}

local options = {
    name = 'GimmeTheLoot',
    handler = GimmeTheLoot,
    type = 'group',
    args = {
        show = {type = 'execute', name = 'Show', desc = 'Show roll history', func = 'ShowFrame'},
        reset = {
            type = 'execute',
            name = 'Reset',
            desc = 'Reset this character\'s roll history',
            func = 'ResetDatabase',
        },
    },
}

function GimmeTheLoot:ResetDatabase()
    if self.db.profile.records then
        self.db.profile.records = {}
    end
    self:Print('Database reset.')
end

function GimmeTheLoot:ShowFrame()
    GUI:DisplayFrame()
end

function GimmeTheLoot:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('GTL_DB', defaults)
    GUI = self:GetModule('GUI')
end

function GimmeTheLoot:OnEnable()
    LibStub('AceConfig-3.0'):RegisterOptionsTable('GimmeTheLoot', options, {'gimmetheloot', 'gtl'})
end
