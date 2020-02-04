-- std = "min"
globals = {
    'GimmeTheLoot',
    'LibStub',
    'GetItemInfo',
    'GetLootMsgInfo',
    'tprint',
    'pendingLootSessions',
    'gtlSearch',
    'FakeRollSession',
    'recordsContainer',
    'GUI',
    'Search',
    'Tracker',
}
read_globals = {'_TEST', 'time', 'date', 'C_LootHistory', 'GameTooltip'}

max_line_length = 100
max_cyclomatic_complexity = 10

-- show warning codes on output
codes = true

self = false

exclude_files = {'Libs'}
