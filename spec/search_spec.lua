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
    it('should page correctly', function()
        table.insert(_G.GimmeTheLoot.db.profile.records, FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Cyclone Shoulderguards',
            quality = 4,
        }))
        table.insert(_G.GimmeTheLoot.db.profile.records, FakeRollSession(5, {
            link = '...Cyclone Shoulderguards...',
            name = 'Cyclone Shoulderguards',
            quality = 3,
        }))

        local cursor = Search:SearchIterator({text = 'cyclone'}, 1)
        local firstPage, secondPage, thirdPage = cursor(), cursor(), cursor()
        assert.is.equal(#firstPage, 1)
        assert.is.equal(#secondPage, 1)
        assert.is.equal(thirdPage, nil)
        assert.is.equal(firstPage[1].item.quality, 4)
        assert.is.equal(secondPage[1].item.quality, 3)

        cursor = Search:SearchIterator({text = 'doesntexist'})
        assert.is.equal(cursor(), nil)
    end)
end)
