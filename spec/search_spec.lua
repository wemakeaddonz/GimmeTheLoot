local fakeRollers = {
    'Basin',
    'Bullshizzle',
    'Congo',
    'Dyamito',
    'Eragdash',
    'Ixojos',
    'Karuga',
    'Lawlpwned',
    'Mosdef',
    'Panzesto',
    'Swischeese',
    'Waffles',
    'Zashin',
    'Zoke',
}

function FakeRollSession(numRollers, item)
    assert(numRollers >= 1 and numRollers <= 5)
    local session = {rolls = {}, item = item}

    for _ = 0, numRollers do
        table.insert(session.rolls, {
            name = fakeRollers[math.random(#fakeRollers)],
            type = math.random(0, 3),
            roll = math.random(100),
        })
    end

    -- needs winner
    return session
end

_G._TEST = true
_G.GimmeTheLoot = {db = {profile = {records = {}}}}
_G.Search = {}
require 'GimmeTheLoot'
require 'Search'

describe('record searching', function()
    it('should match a record with a substring', function()
        local record = FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        })

        assert.is.truthy(Search:SearchMatchItemText('Cyclone', record))
        assert.is.falsy(Search:SearchMatchItemText('NotCyclone', record))
    end)

    it('should match a record with a differently cased substring', function()
        local record = FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        })

        assert.is.truthy(Search:SearchMatchItemText('CyClONE', record))
        assert.is.falsy(Search:SearchMatchItemText('NotCyclone', record))
    end)

    it('should match a record with a specific quality level', function()
        local record = FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        })

        -- empty inputs for quality are trivially truthy
        assert.is.truthy(Search:SearchMatchItemQuality(nil, record))
        assert.is.truthy(Search:SearchMatchItemQuality({}, record))

        assert.is.truthy(Search:SearchMatchItemQuality({[4] = true}, record))
        assert.is.truthy(Search:SearchMatchItemQuality(
                             {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true}, record))

        assert.is.falsy(Search:SearchMatchItemQuality(
                            {[1] = true, [2] = true, [3] = true, [5] = true}, record))
    end)
end)

describe('record searching over multiple records', function()
    it('should match a record with a substring', function()
        table.insert(_G.GimmeTheLoot.db.profile.records, FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        }))
        table.insert(_G.GimmeTheLoot.db.profile.records, FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Pauldrons of The Five Thunders',
            quality = 3,
        }))

        assert.is.equal(#Search:SearchRecords(), 2)
        assert.is.equal(#Search:SearchRecords(nil), 2)
        assert.is.equal(#Search:SearchRecords({}), 2)

        assert.is.equal(#Search:SearchRecords({quality = {[4] = true}}), 1)
        assert.is.equal(#Search:SearchRecords({quality = {[3] = true}}), 1)
        assert.are_not.same(Search:SearchRecords({quality = {[4] = true}}),
                            Search:SearchRecords({quality = {[3] = true}}))

        assert.is.equal(#Search:SearchRecords({text = 'r'}), 2)

        assert.is.equal(#Search:SearchRecords({text = 'cyclone', quality = {[4] = true}}), 1)

        assert.is.equal(#Search:SearchRecords({text = 'cyclone', quality = {[3] = true}}), 0)
    end)
end)
